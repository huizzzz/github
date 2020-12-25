public with sharing class OpportunityLineItemBulkEditController {

    /**
     * 商談商品取得
     * @param oppId:商談ID
     * @return 処理結果
     */
    @AuraEnabled
    public static String getOppLineItems(String oppId){

        // 異常終了時のロールバックポイント
        Savepoint sp = Database.setSavepoint();

        try{
            // 商談に紐づく価格表が指定されないと、後続の処理は行えない
            // この商談に関連付ける価格表を選択してください。この商談を関連付ける価格表の商品のみを追加できます。価格表を変更すると、商談からすべての商品が削除されます。
            Opportunity opp = [select Pricebook2Id, CurrencyIsoCode from Opportunity where Id =: oppId];
            String Pricebook2Id = opp.Pricebook2Id;
            String CurrencyIso = opp.CurrencyIsoCode;
            if(String.isEmpty(Pricebook2Id)){
                // 警告終了する
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeNumberField('returnCode', 6); // 警告終了
                gen.writeObjectField('returnMsg', System.Label.COWO_MSG_NoPBESelected);
                gen.writeEndObject();
                
                // Get the JSON string.
                String JSONString = gen.getAsString();
                return JSONString;
            }

            List<OpportunityLineItem> opportunityLineItems = [select Id
                                                                    ,SAWO_ItemNumber__c
                                                                    ,SAWO_ProductName__c
                                                                    ,SAWO_ProductCode__c
                                                                    ,SAWO_Parts_No__c
                                                                    ,Quantity
                                                                    ,SAWO_QuantityUnit__c
                                                                    ,TC__c
                                                                    ,MC__c
                                                                    ,SAWO_LocalCorporationTC__c
                                                                    ,SAWO_FrontPurchasePrice__c
                                                                    ,SAWO_DetailCategory__c
                                                                    ,SAWO_DetailCategory_MTE__c
                                                                    ,SAWO_RejectionReason__c
                                                                    ,SAWO_PlantCode__c
                                                                    ,SAWO_PlantCode_MTE__c
                                                                    ,SAWO_StorageLocation__c
                                                                    ,SAWO_StorageLocation_MTE__c
                                                                    ,SAWO_S4LinkagePrice__c
                                                                    ,SAWO_Currency__c
                                                                    ,SAWO_Recording_Division__c
                                                                    ,SAWO_WBSElement__c
                                                                    ,SAWO_ProfitCenter__c
                                                                    ,SAWO_ProfitCenter_MTE__c
                                                                    ,SAWO_ItemText__c
                                                                    ,SAWO_DeliverySchedule__c
                                                                    ,SAWO_MaterialAvailDate__c
                                                                    ,SAWO_MaterialGroup1__c
                                                                    ,Name
                                                                    ,UnitPrice
                                                                    ,CurrencyIsoCode 
                                                                    ,SAWO_SalesNoteCustome__c
                                                                    ,SAWO_ShippingInstructions__c
                                                                    ,SAWO_SalesUnit__c
                                                                    ,SAWO_PartitionPrice__c
                                                                    ,SAWO_NoDiscountFlg__c
                                                                    ,CO_ovcUpdateFlag__c
                                                                    ,CO_ovcUpdateFlag_MTE__c
                                                                    ,SAWO_DiscountPrice__c
                                                                    ,SAWO_SalesPrice__c
                                                                    ,SAWO_LocalParts__c
                                                                    ,Tekiyo__c 
                                                                    ,SAWO_ConditionRate_DeliveryCost__c
                                                                    ,SAWO_ConditionRate_Taxes__c
                                                                    ,SAWO_ConditionRate_Insurance__c
                                                                    ,SA_Insurance_fee__c
                                                                    ,SA_Freight__c
                                                                    ,SA_Other_Duties__c
                                                                    ,SA_Reservers_Fixed__c
                                                                    ,SA_TrgInstRsrvsFixed__c
                                                              from OpportunityLineItem
                                                              where OpportunityId =: oppId
                                                              order by CountNumber__c asc];

             //Login User Permission check
            Boolean isPSGHHTUser = true;
            List<String> dx_Permissionsets = System.Label.COWO_LBL_PermissionSet.split(',');
            system.debug('dx_Permissionsets' + dx_Permissionsets);
            if([SELECT count() FROM PermissionSetAssignment where assigneeid =: System.UserInfo.getUserId() and PermissionSet.Name in: dx_Permissionsets ] == 0){
                isPSGHHTUser = false;
                // if(opportunityLineItems.size() > 0 ){
                //     for(Integer idx = 0;idx < opportunityLineItems.size(); idx++){
                //         opportunityLineItems[idx].TC__c = 0;
                //         opportunityLineItems[idx].MC__c = 0;
                //     }
                // }
            }

            List<OpportunityLineItems> opportunityLineItemList = new List<OpportunityLineItems>();
            for(OpportunityLineItem opportunityLineItem : opportunityLineItems){
                OpportunityLineItems displayOpportunityLineItems = new OpportunityLineItems();
                displayOpportunityLineItems.Id = opportunityLineItem.Id;
                displayOpportunityLineItems.sawo_ProductCode = opportunityLineItem.SAWO_ProductCode__c;
                opportunityLineItemList.add(displayOpportunityLineItems);
            }
            
            COWO_CurrencyIsoCode__mdt currencymdt = [SELECT Id, DeveloperName, COWO_Digits__c, COWO_CurrencyMark__c, COWO_DisplayFormat__c, COWO_DigitsInput__c FROM COWO_CurrencyIsoCode__mdt where DeveloperName =: opp.CurrencyIsoCode limit 1];

            // 画面表示変数初期化
            DisplayParams displayParams = new DisplayParams(currencymdt.COWO_Digits__c,currencymdt.COWO_DigitsInput__c,currencymdt.COWO_DisplayFormat__c,currencymdt.COWO_CurrencyMark__c);


            // 正常終了の場合
            String resultString = doNormalEnd(opportunityLineItems, Pricebook2Id,CurrencyIso,displayParams,isPSGHHTUser,opportunityLineItemList);
            //String resultString = doNormalEnd(opportunityLineItemList, Pricebook2Id,CurrencyIso,displayParams,isPSGHHTUser);
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
            String JSONString = gen.getAsString();
            return JSONString;
        }
    }

    /**
     * 画面編集データを反映する
     * @param draftValues:新規/更新データ
     * @param deletedData:削除データ
     * @return 処理結果
     */
    @AuraEnabled
    public static String reflectEditedData(String opportunityId, String draftValues,String datas, String deletedData,Decimal digits,Boolean isPSGHHTUser){

        // 異常終了時のロールバックポイント
        Savepoint sp = Database.setSavepoint();

        try{
            // 処理正常終了時戻す用のIDリスト（Insert後のIDを画面に戻す）
            List<String> draftIdList = new List<String>();
            
            Opportunity opportunity = [SELECT Pricebook2Id, CurrencyIsoCode FROM Opportunity WHERE Id =: opportunityId LIMIT 1];
            // Price Book IDを取得する
            String pricebook2Id = opportunity.Pricebook2Id;
            // 商談の通貨 ISO コードを取得する
            String currencyIsoCode = opportunity.CurrencyIsoCode;

            // 見積品目一覧
            List<Object> oppLineItemList = (List<Object>) JSON.deserializeUntyped(datas);
            // 画面から取得された変更データ一覧取得
            List<Object> draftList = (List<Object>) JSON.deserializeUntyped(draftValues);
            
            // 追加商品Id一覧
            List<String> product2IdForNewQLI = new List<String>();
            // 商談商品変更レコードリスト
            List<opportunityLineItem> oppLineItemUpsertList = new List<opportunityLineItem>();
            
            //変更有レコードId
            Set<String> draftIdSet = new Set<String>();

            for(Object draftValue : draftList){
                Map<String, Object> draftValueMap = (Map<String, Object>)draftValue;
                // 見積品目ID
                String oppLineItemId = (String)draftValueMap.get('Id');
                // 商品ID
                String product2Id = (oppLineItemId).right((oppLineItemId).length() - 3);
                // データパターン
                String dataPattern = (oppLineItemId).left(3);
                // draftValueIdSet
                draftIdSet.add(oppLineItemId);
                // 追加された商品Id
                if('Add'.equals(dataPattern)){
                    product2IdForNewQLI.add(product2Id);
                }
            }

            System.debug('oppLineItemList.size()' + oppLineItemList.size());
            if(oppLineItemList.size() > 200){
                throw new CustomException(System.label.COWO_MSG_201Error);
            }

             // 自由入力製品の価格エントリー取得
             PricebookEntry pricebookEntryByNew = [SELECT Id, Product2Id 
                                                   FROM PricebookEntry 
                                                   WHERE Pricebook2Id = :pricebook2Id
                                                   AND Product2.Name = :System.Label.AP00_CONST_0001
                                                   AND CurrencyIsoCode = :currencyIsoCode limit 1];
            
            // 商品追加で検索された商品と価格エントリーを取得
            List<PriceBookEntry> pricebookEntriesByAdd = [SELECT id,Product2Id 
                                                          FROM PriceBookEntry 
                                                          WHERE Pricebook2Id = :pricebook2Id
                                                          AND product2Id in :product2IdForNewQLI
                                                          AND CurrencyIsoCode = :currencyIsoCode];   
            
            // 新規/更新見積品目
            for(Object opportunityLineItem : oppLineItemList){
                Map<String, Object> oppLineItemMap = (Map<String, Object>)opportunityLineItem;
                      
                if(oppLineItemMap.get('SAWO_ItemNumber__c') == null || oppLineItemMap.get('SAWO_ItemNumber__c') == ''){
                    throw new CustomException(System.label.COWO_MSG_ItemNumberRequired);
                }

                // data.Id に、追加の場合、商品ID(Product2Id)が入ってる、更新の場合、見積商品ID(quoteLineItemId)が入ってる
                // 見積品目ID
                String oppLineItemId = (String)oppLineItemMap.get('Id');
                // 商品ID
                String product2Id = (oppLineItemId).right((oppLineItemId).length() - 3);
                // データパターン
                String dataPattern = (oppLineItemId).left(3);
                
                opportunityLineItem oppLineItemUpsert = new opportunityLineItem();
                
                if(draftIdSet.contains(oppLineItemId)){
                    // 新規見積品目
                    if('Add'.equals(dataPattern) || 'New'.equals(dataPattern)){
                        //PricebookEntryIdとProduct2Id設定
                        if('Add'.equals(dataPattern)){
                            for(PriceBookEntry pbe : pricebookEntriesByAdd){
                                if(pbe.Product2Id == product2Id){
                                    oppLineItemUpsert.PricebookEntryId = pbe.id;
                                    oppLineItemUpsert.Product2Id = pbe.Product2Id;
                                }
                            }
                        }else{
                            oppLineItemUpsert.PricebookEntryId = pricebookEntryByNew.id;
                            oppLineItemUpsert.Product2Id = pricebookEntryByNew.Product2Id;
                        }
                        oppLineItemUpsert.OpportunityId = opportunityId;
                        //更新の場合、見積品目Id設定
                    }else{
                        oppLineItemUpsert.Id = oppLineItemId;
                    }
                    
                    integer quantity = 0;
                    if(oppLineItemMap.get('Quantity') == null || oppLineItemMap.get('Quantity') == ''){
                        quantity = 1;
                    }else{
                        quantity = Integer.valueOf(oppLineItemMap.get('Quantity'));
                    }
                    Decimal salesPrice = 0;
                    if(oppLineItemMap.get('SAWO_SalesPrice__c') != null && oppLineItemMap.get('SAWO_SalesPrice__c') != ''){
                        salesPrice = convertNullToDecimal(oppLineItemMap.get('SAWO_SalesPrice__c'),digits);
                    }
                    Decimal discountPrice = 0; 
                    if(oppLineItemMap.get('SAWO_DiscountPrice__c') != null && oppLineItemMap.get('SAWO_DiscountPrice__c') != ''){
                        discountPrice = convertNullToDecimal(oppLineItemMap.get('SAWO_DiscountPrice__c'),digits);
                    }
                    oppLineItemUpsert.Quantity = quantity;
                    oppLineItemUpsert.UnitPrice = salesPrice;
                    // oppLineItemUpsert.SAWO_TotalPrice__c = quantity * convertNullToDecimal(oppLineItemMap.get('UnitPrice'),digits) - convertNullToDecimal(oppLineItemMap.get('SAWO_DiscountPrice__c'),digits);
                    oppLineItemUpsert.SAWO_TotalPrice__c = quantity * salesPrice - discountPrice;
                    oppLineItemUpsert.ServiceDate = oppLineItemMap.get('ServiceDate')== null || oppLineItemMap.get('ServiceDate') == '' ? null :Date.valueOf(String.valueOf(oppLineItemMap.get('ServiceDate')));
                    oppLineItemUpsert.Description = oppLineItemMap.get('Description') == null ? null : String.valueOf(oppLineItemMap.get('Description')).abbreviate(255);
                    oppLineItemUpsert.SAWO_LocalCorporationTC__c = convertNullToDecimal(oppLineItemMap.get('SAWO_LocalCorporationTC__c'),digits);
                    oppLineItemUpsert.SAWO_FrontPurchasePrice__c = convertNullToDecimal(oppLineItemMap.get('SAWO_FrontPurchasePrice__c'),digits);
                    integer productNameLength = Schema.SObjectType.OpportunityLineItem.fields.SAWO_ProductName__c.getLength();
                    oppLineItemUpsert.SAWO_ProductName__c = oppLineItemMap.get('SAWO_ProductName__c') == null ? null : String.valueOf(oppLineItemMap.get('SAWO_ProductName__c')).abbreviate(productNameLength); 
                    oppLineItemUpsert.MC__c = convertNullToDecimal(oppLineItemMap.get('MC__c'),digits);
                    oppLineItemUpsert.TC__c = convertNullToDecimal(oppLineItemMap.get('TC__c'),digits);
                    oppLineItemUpsert.SAWO_Parts_No__c = (String)oppLineItemMap.get('SAWO_Parts_No__c');
                    oppLineItemUpsert.SAWO_ProductCode__c = (String)oppLineItemMap.get('SAWO_ProductCode__c');
                    oppLineItemUpsert.SAWO_ItemText__c = (String)oppLineItemMap.get('SAWO_ItemText__c');
                    oppLineItemUpsert.SAWO_ItemNumber__c = Integer.valueOf(oppLineItemMap.get('SAWO_ItemNumber__c'));
                    oppLineItemUpsert.SAWO_QuantityUnit__c = (String)oppLineItemMap.get('SAWO_QuantityUnit__c');//getSelectPicklistValue('OpportunityLineItem','SAWO_QuantityUnit__c',(String)oppLineItemMap.get('SAWO_QuantityUnit__c'));
                    oppLineItemUpsert.SAWO_DetailCategory__c = (String)oppLineItemMap.get('SAWO_DetailCategory__c');
                    oppLineItemUpsert.SAWO_DetailCategory_MTE__c = (String)oppLineItemMap.get('SAWO_DetailCategory_MTE__c');
                    oppLineItemUpsert.SAWO_RejectionReason__c = (String)oppLineItemMap.get('SAWO_RejectionReason__c');
                    oppLineItemUpsert.SAWO_PlantCode__c = (String)oppLineItemMap.get('SAWO_PlantCode__c');
                    oppLineItemUpsert.SAWO_PlantCode_MTE__c = (String)oppLineItemMap.get('SAWO_PlantCode_MTE__c');
                    oppLineItemUpsert.SAWO_StorageLocation__c = (String)oppLineItemMap.get('SAWO_StorageLocation__c');
                    oppLineItemUpsert.SAWO_StorageLocation_MTE__c = (String)oppLineItemMap.get('SAWO_StorageLocation_MTE__c');
                    oppLineItemUpsert.SAWO_Currency__c = oppLineItemMap.get('SAWO_Currency__c') == null ? currencyIsoCode : (String)oppLineItemMap.get('SAWO_Currency__c');
                    oppLineItemUpsert.SAWO_Recording_Division__c = (String)oppLineItemMap.get('SAWO_Recording_Division__c');
                    oppLineItemUpsert.SAWO_ProfitCenter__c = (String)oppLineItemMap.get('SAWO_ProfitCenter__c');
                    //oppLineItemUpsert.SAWO_ProfitCenter_MTE__c = (String)oppLineItemMap.get('SAWO_ProfitCenter_MTE__c');
                    oppLineItemUpsert.SAWO_MaterialGroup1__c = (String)oppLineItemMap.get('SAWO_MaterialGroup1__c');
                    oppLineItemUpsert.SAWO_MaterialAvailDate__c = oppLineItemMap.get('SAWO_MaterialAvailDate__c') != null ? Date.valueOf((String)oppLineItemMap.get('SAWO_MaterialAvailDate__c')) : (Date)null;
                    oppLineItemUpsert.SAWO_DeliverySchedule__c = oppLineItemMap.get('SAWO_DeliverySchedule__c') != null ? Date.valueOf((String)oppLineItemMap.get('SAWO_DeliverySchedule__c')) : (Date)null;
                    oppLineItemUpsert.SAWO_S4LinkagePrice__c = convertNullToDecimal(oppLineItemMap.get('SAWO_S4LinkagePrice__c'),digits);
                    oppLineItemUpsert.SAWO_SalesNoteCustome__c = (String)oppLineItemMap.get('SAWO_SalesNoteCustome__c');
                    oppLineItemUpsert.SAWO_ShippingInstructions__c = (String)oppLineItemMap.get('SAWO_ShippingInstructions__c');
                    oppLineItemUpsert.SAWO_SalesUnit__c = (String)oppLineItemMap.get('SAWO_SalesUnit__c');
                    oppLineItemUpsert.SAWO_PartitionPrice__c = convertNullToDecimal(oppLineItemMap.get('SAWO_PartitionPrice__c'),digits);
                    oppLineItemUpsert.SAWO_NoDiscountFlg__c = (Boolean)oppLineItemMap.get('SAWO_NoDiscountFlg__c');
                    oppLineItemUpsert.SAWO_DiscountPrice__c = discountPrice;
                    oppLineItemUpsert.SAWO_SalesPrice__c = salesPrice;
                    oppLineItemUpsert.SAWO_LocalParts__c = (Boolean)oppLineItemMap.get('SAWO_LocalParts__c');
                    oppLineItemUpsert.Tekiyo__c = (String)oppLineItemMap.get('Tekiyo__c');
                    oppLineItemUpsert.SAWO_ConditionRate_DeliveryCost__c = convertNullToDecimal(oppLineItemMap.get('SAWO_ConditionRate_DeliveryCost__c'),digits);
                    oppLineItemUpsert.SAWO_ConditionRate_Taxes__c = convertNullToDecimal(oppLineItemMap.get('SAWO_ConditionRate_Taxes__c'),digits);
                    oppLineItemUpsert.SAWO_ConditionRate_Insurance__c = convertNullToDecimal(oppLineItemMap.get('SAWO_ConditionRate_Insurance__c'),digits);
                    oppLineItemUpsert.SA_Insurance_fee__c = convertNullToDecimal(oppLineItemMap.get('SA_Insurance_fee__c'),digits);
                    oppLineItemUpsert.SA_Freight__c = convertNullToDecimal(oppLineItemMap.get('SA_Freight__c'),digits);
                    oppLineItemUpsert.SA_Reservers_Fixed__c = convertNullToDecimal(oppLineItemMap.get('SA_Reservers_Fixed__c'),digits);
                    oppLineItemUpsert.SA_TrgInstRsrvsFixed__c = convertNullToDecimal(oppLineItemMap.get('SA_TrgInstRsrvsFixed__c'),digits);
                    oppLineItemUpsert.SA_Other_Duties__c = convertNullToDecimal(oppLineItemMap.get('SA_Other_Duties__c')) * 100;
                    System.debug(oppLineItemMap.get('SA_Other_Duties__c'));
                    oppLineItemUpsertList.add(oppLineItemUpsert);
                }
            }
            // データを新規もしくは更新する
            if(oppLineItemUpsertList.size() > 0){
                upsert oppLineItemUpsertList;
            }

            // 削除データリスト
            List<OpportunityLineItem> delOpportunityLineItemList = new List<OpportunityLineItem>();
            
            // 削除データ処理
            List<Object> deletedDataList = (List<Object>) JSON.deserializeUntyped(deletedData);
            for(Object deletedDataItem : deletedDataList){
                Map<String, Object> deletedDataMap = (Map<String, Object>)deletedDataItem;
                // 商談商品ID
                String opportunityLineItemId = (String)deletedDataMap.get('Id');
                OpportunityLineItem delOpportunityLineItem = new OpportunityLineItem();
                delOpportunityLineItem.Id = opportunityLineItemId;
                delOpportunityLineItemList.add(delOpportunityLineItem);
            }

            // データを削除する
            if(delOpportunityLineItemList.size() > 0){
                delete delOpportunityLineItemList;
            }

            List<OpportunityLineItem> opportunityLineItemList = [select Id, SAWO_SortNo__c
                                                                 from OpportunityLineItem
                                                                 where OpportunityId =: opportunityId
                                                                 order by CountNumber__c asc];

            List<OpportunityLineItem> updateOpportunityLineItem = new List<OpportunityLineItem>();

            Integer sortNo = 1;
            for(OpportunityLineItem oppLI : opportunityLineItemList) {
                oppLI.SAWO_SortNo__c = sortNo;
                updateOpportunityLineItem.add(oppLI);
                sortNo++;
            }

            if(updateOpportunityLineItem.size() > 0) {
                update updateOpportunityLineItem;
            }

            // 正常終了した場合
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeNumberField('returnCode', 0); // 正常終了
            gen.writeObjectField('returnMsg', System.Label.COWO_MSG_Product2Add_NormalEnd);
            //gen.writeObjectField('addNewOpportunityLineItemList', addNewOpportunityLineItemList);
            gen.writeObjectField('draftIdList', draftIdList);
            gen.writeEndObject();
            
            // Get the JSON string.
            String JSONString = gen.getAsString();
            return JSONString;
            
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
            String JSONString = gen.getAsString();
            return JSONString;
        }
    }

    /**
     * 正常終了処理
     * @param lists:データリスト
     * @return 処理結果
     */
    private static String doNormalEnd(List<Object> lists
                                     ,String Pricebook2Id
                                     ,String CurrencyIsoCode
                                     ,DisplayParams displayParams
                                     ,Boolean isPSGHHTUser
                                     ,List<OpportunityLineItems> opportunityLineItemList){
        System.debug('★★★★★ 正常終了処理 start ★★★★★');
        System.debug('★★★★★ Pricebook2Id ★★★★★' + Pricebook2Id);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeNumberField('returnCode', 0); // 正常終了
        gen.writeObjectField('returnMsg', System.Label.COWO_MSG_Product2Search_NormalEnd);
        gen.writeObjectField('data', lists);
        gen.writeStringField('pricebook2Id', Pricebook2Id);
        gen.writeStringField('currencyIsoCode', CurrencyIsoCode);
        gen.writeObjectField('displayParams', displayParams);
        gen.writeBooleanField('isPSGHHTUser', isPSGHHTUser);
        gen.writeObjectField('originalData', opportunityLineItemList);
        gen.writeEndObject();
        
        // Get the JSON string.
        String JSONString = gen.getAsString();
        
        System.debug('★★★★★ JSONString ★★★★★' + JSONString);
        
        System.debug('★★★★★ 正常終了処理 end ★★★★★');

        return JSONString;
    }

    /**
     * 見積品目Nullデータを転換する
     * @param data:見積品目から読込だデータ
     * @return 処理結果
     */
    private static Decimal convertNullToDecimal(Object fieldValue){
        return fieldValue == null || fieldValue == '' ? 0 : Decimal.valueOf(String.valueOf(fieldValue));
    }

    /**
     * Nullデータを転換する
     * @param data:商談商品から読込だデータ
     * @return 処理結果
     */
    private static Decimal convertNullToDecimal(Object fieldValue,Decimal digits){
        // return fieldValue == null || fieldValue == '' ? (Decimal)null : Decimal.valueOf(String.valueOf(fieldValue)).setScale((Integer)digits, System.RoundingMode.HALF_UP);
        return fieldValue == null || fieldValue == '' ? 0 : Decimal.valueOf(String.valueOf(fieldValue)).setScale((Integer)digits, System.RoundingMode.HALF_UP);
    }

    /**
     * 選択肢API名取得
     * @param objectName:オブジェクト名
     * @param fieldName:項目名
     * @param selectValue:選択値
     * @return 処理結果
     */
    public static String getSelectPicklistValue(String objectName, String fieldName,String selectLabel) {
        String selectValue;
        Map<String, String> values = new Map<String, String>{};

        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});

        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                    values.put(entry.getLabel(), entry.getValue());
            }
        }

        selectValue = values.get(selectLabel);
        system.debug('selectLabel' + selectLabel);
        system.debug('selectvalue' + selectvalue);
        system.debug('values' + values);

        return selectValue;
    }

    public class DisplayParams {
        Decimal digits {get;set;}
        Decimal digitsInput{get;set;}
        String format {get;set;}
        String symbol {get;set;}
        public DisplayParams(Decimal digits,
                            Decimal digitsInput,
                            String format,
                            String symbol){
                                this.digits = digits;
                                this.digitsInput = digitsInput;
                                this.format = format;
                                this.symbol = symbol;
                            }
     }

    public class OpportunityLineItems {
        public String Id {get;set;}
        public String sawo_ProductCode {get;set;}
    }
 
    /**
    * カスタムエクセプションクラス
    */
    public class CustomException extends Exception {
    }
}