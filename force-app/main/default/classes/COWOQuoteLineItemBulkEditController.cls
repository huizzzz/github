public with sharing class COWOQuoteLineItemBulkEditController {

    /**
     * 見積品目取得
     * @param quoteId:見積ID
     * @return 処理結果
     */
    @AuraEnabled
    public static String getCOWOQuoteLineItems(String quoteId){

        // 異常終了時のロールバックポイント
        Savepoint sp = Database.setSavepoint();

        try{
            
            // 見積更新用情報取得
            Quote quote = [select CurrencyIsoCode
                                  //COWO_Final_Amount__c,
                                 ,COWO_Fertility_Discount1__c
                                 ,COWO_Fertility_Discount2__c
                                 ,COWO_Final_Amount_HDA_Exclude__c
                                 ,COWO_Final_Amount_Discount_Exclude__c
                                 ,TotalPrice  
                           from quote 
                           where id =: quoteId];
            
            // 見積に紐付く見積品目一覧を取得
            List<COWO_QuoteLineItem__c> cowoQuoteLineItemList = [select Id, 
                                                                        CurrencyIsoCode, 
                                                                        COWO_DiscountUnitPrice__c,
                                                                        COWO_SubTotal__c,
                                                                        COWO_Quote__c,
                                                                        COWO_ItemNumber__c,
                                                                        COWO_Quantity__c,
                                                                        COWO_Price__c,
                                                                        COWO_ProductName__c,
                                                                        COWO_SortNo__c,
                                                                        COWO_Description__c
                                                                 from COWO_QuoteLineItem__c
                                                                 where COWO_Quote__c =: quoteId 
                                                                 order by COWO_SortNo__c asc];
            // 見積詳細金額サマリ
            Decimal amountSummary = 0;
            Decimal allDiscountPrice = 0;
            Decimal remainAmount = 0;
            String warnMessage = '';
            if(cowoQuoteLineItemList.size() > 0){
                for(COWO_QuoteLineItem__c qli : cowoQuoteLineItemList){
                    if(qli.COWO_SubTotal__c != null){
                        amountSummary += qli.COWO_SubTotal__c;
                    }
                    if(qli.COWO_Price__c != null && qli.COWO_DiscountUnitPrice__c != null){
                        allDiscountPrice += qli.COWO_Price__c - qli.COWO_DiscountUnitPrice__c;
                    }
                    if(String.isNotBlank(qli.COWO_ProductName__c) && qli.COWO_ProductName__c.length() > 23){
                        if(String.isBlank(warnMessage)){
                            warnMessage = System.Label.COWO_MSG_LenOver;
                        }
                    }
                }
            }
            if(quote.COWO_Final_Amount_Discount_Exclude__c == null || quote.COWO_Final_Amount_Discount_Exclude__c == 0){
                quote.COWO_Final_Amount_Discount_Exclude__c = quote.TotalPrice - allDiscountPrice;
                update quote;
            }
            // remainAmount = amountSummary - quote.COWO_Final_Amount_HDA_Exclude__c;
            remainAmount = amountSummary - quote.COWO_Final_Amount_Discount_Exclude__c;

            COWO_CurrencyIsoCode__mdt currencymdt = [SELECT Id, DeveloperName, COWO_Digits__c, COWO_CurrencyMark__c, COWO_DisplayFormat__c, COWO_DigitsInput__c FROM COWO_CurrencyIsoCode__mdt where DeveloperName =: quote.CurrencyIsoCode limit 1];

            // 画面表示変数初期化
            // QLIDisplayParams qliDisplayParams = new QLIDisplayParams(quote.COWO_Final_Amount_HDA_Exclude__c,amountSummary,remainAmount,warnMessage,quote.COWO_Fertility_Discount1__c,quote.COWO_Fertility_Discount2__c,currencymdt.COWO_Digits__c,currencymdt.COWO_DigitsInput__c,currencymdt.COWO_DisplayFormat__c,currencymdt.COWO_CurrencyMark__c);
            QLIDisplayParams qliDisplayParams = new QLIDisplayParams(quote.COWO_Final_Amount_Discount_Exclude__c,amountSummary,remainAmount,warnMessage,quote.COWO_Fertility_Discount1__c,quote.COWO_Fertility_Discount2__c,currencymdt.COWO_Digits__c,currencymdt.COWO_DigitsInput__c,currencymdt.COWO_DisplayFormat__c,currencymdt.COWO_CurrencyMark__c);

            system.debug('currencymdt' + currencymdt);
            // 正常終了の場合
            String resultString = doNormalEnd(cowoQuoteLineItemList,quote.CurrencyIsoCode,qliDisplayParams);
            
            
            return resultString;
            
        } catch (Exception e){

            // 異常終了する場合、ロールバックする
            Database.rollback(sp);
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeNumberField('returnCode', 9); // 異常終了
            gen.writeObjectField('returnMsg', e.getMessage());
            gen.writeEndObject();
            
            // Get the JSON string.
            String jsonString = gen.getAsString();
            return jsonString;
        }
    }

    /**
     * 画面編集データを反映する
     * @param quoteId:見積レコードID
     * @param draftValues:新規/更新データ
     * @param deletedData:削除データ
     * @param datas:画面編集後最新データ
     * @param quoteParams:見積更新用画面変数
     * @return 処理結果
     */
    @AuraEnabled
    public static String reflectEditedData(String quoteId, String draftValues, String deletedData, String datas,String currencyIsoCode,Decimal digits){

        // 異常終了時のロールバックポイント
        Savepoint sp = Database.setSavepoint();
        // Get the JSON string.
        String jsonString;

        try{
            // 処理正常終了時戻す用のIDリスト（Insert後のIDを画面に戻す）
            List<String> draftIdList = new List<String>();
           
		    // 見積帳票明細一覧
            List<Object> cowoQLIList = (List<Object>) JSON.deserializeUntyped(datas);
            // 画面から取得された変更データ一覧取得
            List<Object> draftList = (List<Object>) JSON.deserializeUntyped(draftValues);
            // 見積品目変更レコードリスト
            List<COWO_QuoteLineItem__c> cowoQLIUpsertList = new List<COWO_QuoteLineItem__c>();

            // 新規/更新見積品目
            for(Object cowoQLI : cowoQLIList){
                Map<String, Object> cowoQLIMap = (Map<String, Object>)cowoQLI;
               
                // data.Id に、追加の場合、商品ID(Product2Id)が入ってる、更新の場合、見積商品ID(quoteLineItemId)が入ってる
                // 見積品目ID
                String cowoQLIId = (String)cowoQLIMap.get('Id');
                // データパターン
                String dataPattern = (cowoQLIId).left(3);
                
                COWO_QuoteLineItem__c cowoQLIUpsert = new COWO_QuoteLineItem__c();
                
                // 新規見積品目
                if('New'.equals(dataPattern)){
                    cowoQLIUpsert.COWO_Quote__c = quoteId;
                    //更新の場合、見積品目Id設定
                }else{
                    cowoQLIUpsert.Id = cowoQLIId;
                }
                cowoQLIUpsert.COWO_ItemNumber__c = String.valueOf(cowoQLIMap.get('COWO_ItemNumber__c'));   
                cowoQLIUpsert.COWO_Quantity__c = String.valueOf(cowoQLIMap.get('COWO_Quantity__c'));
                cowoQLIUpsert.COWO_Price__c = convertNullToDecimal(cowoQLIMap.get('COWO_Price__c'),digits);
                cowoQLIUpsert.COWO_DiscountUnitPrice__c = convertNullToDecimal(cowoQLIMap.get('COWO_DiscountUnitPrice__c'),digits);
                cowoQLIUpsert.COWO_SubTotal__c = convertNullToDecimal(cowoQLIMap.get('COWO_SubTotal__c'),digits);
                cowoQLIUpsert.COWO_ProductName__c = String.valueOf(cowoQLIMap.get('COWO_ProductName__c'));
                cowoQLIUpsert.COWO_SortNo__c = convertNullToDecimal(cowoQLIMap.get('COWO_SortNo__c'),0);
                cowoQLIUpsert.COWO_Description__c = String.valueOf(cowoQLIMap.get('COWO_Description__c'));
                cowoQLIUpsert.CurrencyIsoCode = currencyIsoCode;
                cowoQLIUpsertList.add(cowoQLIUpsert);
            }
            if(!validationCheck(quoteId,cowoQLIUpsertList)){
               jsonString = doErrorEnd(9,System.Label.COWO_MSG_FinalAmountErr);
                
            }else{
                // データを新規もしくは更新する
                if(cowoQLIUpsertList.size() > 0){
                   upsert cowoQLIUpsertList; 
                }
                
                // 削除データリスト
                List<COWO_QuoteLineItem__c> delcowoQLIList = new List<COWO_QuoteLineItem__c>();
                
                // 削除データ処理
                List<Object> delDataList = (List<Object>) JSON.deserializeUntyped(deletedData);
                for(Object deletedDataItem : delDataList){
                    Map<String, Object> delDataMap = (Map<String, Object>)deletedDataItem;
                    // 見積商品ID
                    String delCowoQLIId = (String)delDataMap.get('Id');
                    if(!delCowoQLIId.contains('New')){
                        COWO_QuoteLineItem__c delCOWOQLI = new COWO_QuoteLineItem__c();
                        delCOWOQLI.Id = delCowoQLIId;
                        delcowoQLIList.add(delCOWOQLI); 
                    }
                }
                
                // データを削除する
                if(delcowoQLIList.size() > 0){
                    delete delcowoQLIList;
                }
                
            
                // 正常終了した場合
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeNumberField('returnCode', 0); // 正常終了
                gen.writeObjectField('returnMsg', System.Label.COWO_MSG_QLIAdd_NormalEnd);
                gen.writeEndObject();

                jsonString = gen.getAsString();
                
            }
            return jsonString;
        } catch (Exception e){
            
            // 異常終了する場合、ロールバックする
            Database.rollback(sp);
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeNumberField('returnCode', 9); // 異常終了
            gen.writeObjectField('returnMsg', e.getMessage());
            gen.writeEndObject();
            System.debug('★★★★★ e.getMessage() ★★★★★' + e.getMessage());
            
            // Get the JSON string.
            jsonString = gen.getAsString();
            return jsonString;
        }
    }

    /**
     * 各バリデーションチェック
     */
    public static Boolean validationCheck(String quoteId,List<COWO_QuoteLineItem__c> upsertQLILst){
        Boolean result = true;
        // 見積最終金額チェックフラグ
        Boolean finalAmountChk = true;
        // 見積最終金額取得
        // Quote quote = [select COWO_Final_Amount_HDA_Exclude__c from quote where id =: quoteId];
        Quote quote = [select COWO_Final_Amount_Discount_Exclude__c from quote where id =: quoteId];

        // 
        if(upsertQLILst.size() > 0){
            Decimal totalAmount = 0;
            // 見積明細総金額取得
            for(COWO_QuoteLineItem__c qli : upsertQLILst){
                if(qli.COWO_SubTotal__c != null){
                    totalAmount += qli.COWO_SubTotal__c;
                }
            }
            // 総金額が見積最終金額より大きい場合、Falseになる
            // if(quote.COWO_Final_Amount_HDA_Exclude__c != totalAmount){
            if(quote.COWO_Final_Amount_Discount_Exclude__c != totalAmount){
                finalAmountChk = false;
            }
        }
        if(!finalAmountChk){
            result = false;
        }
        return result; 
    }

    /**
     * 正常終了処理
     * @param lists:データリスト
     * @return 処理結果
     */
    private static String doNormalEnd(List<SObject> lists,String currencyIsoCode,QLIDisplayParams qliDisplayParams){
        System.debug('★★★★★ 正常終了処理 start ★★★★★');
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeNumberField('returnCode', 0); // 正常終了
        gen.writeObjectField('returnMsg', System.Label.COWO_MSG_QLISearch_NormalEnd);
        gen.writeObjectField('data', lists);
        gen.writeObjectField('currencyIsoCode', currencyIsoCode); // 通貨設定
        gen.writeObjectField('qliDisplayParams', qliDisplayParams);// 画面表示用変数
        gen.writeEndObject();
        
        // Get the JSON string.
        String JSONString = gen.getAsString();
        
        System.debug('★★★★★ JSONString ★★★★★' + JSONString);
        
        System.debug('★★★★★ 正常終了処理 end ★★★★★');

        return JSONString;
    }

     /**
     * 異常終了処理
     * @param lists:データリスト
     * @return 処理結果
     */
    private static String doErrorEnd(Integer returnCode,String returnMsg){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeNumberField('returnCode', returnCode); // 異常終了
        gen.writeObjectField('returnMsg', returnMsg);
        gen.writeEndObject();
        System.debug('★★★★★ returnMsg ★★★★★' + returnMsg);
        
        // Get the JSON string.
        String jsonString = gen.getAsString();
        return jsonString; 
    }

    /**
     * 見積品目Nullデータを転換する
     * @param data:見積品目から読込だデータ
     * @return 処理結果
     */
    private static Decimal convertNullToDecimal(Object fieldValue,Decimal digits){
        system.debug(digits);
        return fieldValue == null || fieldValue == '' ? (Decimal)null : Decimal.valueOf(String.valueOf(fieldValue)).setScale((Integer)digits, System.RoundingMode.HALF_UP);
    }

    public class QLIDisplayParams {
        Decimal finalAmount {get;set;}
        Decimal amountSummary {get;set;}
        Decimal remainAmount {get;set;}
        String warnMessage {get;set;}
        Decimal fertilityDiscount1 {get;set;}
        Decimal fertilityDiscount2 {get;set;}
        Decimal digits {get;set;}
        Decimal digitsInput{get;set;}
        String format {get;set;}
        String symbol {get;set;}
        public QLIDisplayParams(Decimal finalAmount,
                                Decimal amountSummary,
                                Decimal remainAmount,
                                String warnMessage,
                                Decimal fertilityDiscount1,
                                Decimal fertilityDiscount2,
                                Decimal digits,
                                Decimal digitsInput,
                                String format,
                                String symbol){
                                    this.finalAmount = finalAmount;
                                    this.amountSummary = amountSummary;
                                    this.remainAmount = remainAmount;
                                    this.warnMessage = warnMessage;
                                    this.fertilityDiscount1 = fertilityDiscount1;
                                    this.fertilityDiscount2 = fertilityDiscount2;
                                    this.digits = digits;
                                    this.digitsInput = digitsInput;
                                    this.format = format;
                                    this.symbol = symbol;

        }
    }
}