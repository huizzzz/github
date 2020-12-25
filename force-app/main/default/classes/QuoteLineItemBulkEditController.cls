public with sharing class QuoteLineItemBulkEditController {

	/**
     * 見積品目取得
     * @param quoteId:見積ID
     * @return 処理結果
     */
    @AuraEnabled
    public static String getQuoteLineItems(String quoteId){
        
        // 異常終了時のロールバックポイント
        Savepoint sp = Database.setSavepoint();

        try{
            // 見積に紐づく価格表が指定されないと、後続の処理は行えない
            // この見積に関連付ける価格表を選択してください。この見積を関連付ける価格表の商品のみを追加できます。価格表を変更すると、見積からすべての商品が削除されます。
            String pricebook2Id = [select Pricebook2Id from Quote where Id =: quoteId].Pricebook2Id;
            if(String.isEmpty(pricebook2Id)){
                // 警告終了する
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeNumberField('returnCode', 6); // 警告終了
                gen.writeObjectField('returnMsg', System.Label.COWO_MSG_ExceptionEnd);
                gen.writeEndObject();
                
                // Get the JSON string.
                String jsonString = gen.getAsString();
                return jsonString;
            }
            
            // 見積更新用情報取得
            Quote quote = [select CurrencyIsoCode
                                 ,COWO_Tax_Rate__c
                                 ,COWO_Report_Item_Flag__c
                                 ,COWO_Discount_Amount__c
                                 ,COWO_Header_Discount_Rate__c
                                 ,COWO_Header_Discount_Amount__c
                                 ,COWO_Fertility_Discount1__c
                                 ,COWO_Fertility_Discount2__c
                                 ,COWO_Gross_Profit_Rate__c
                                 ,COWO_Final_Amount__c
                                 ,COWO_Total_Tax__c
                                 ,COWO_Final_Amount_Tax_Included__c
                                 ,COWO_Total_Profit__c
                                 ,COWO_Profit_Rate__c
                                 ,COWO_HHT_Total_Profit__c
                                 ,COWO_HHT_Profit_Rate__c
                                 ,COWO_Gross_Profit__c
                                 ,COWO_Total_LocalCorporationTC__c
                                 ,COWO_Total_FrontPurchasePrice__c
                                 ,COWO_Total_MC__c
                                 ,COWO_Total_TC__c
                                 ,COWO_Fertility_Discount_Title1__c
                                 ,COWO_Fertility_Discount_Title2__c
                                 ,COWO_SVF_DiscoutText1__c
                                 ,COWO_SVF_DiscoutText2__c
                                 ,COWO_SVF_DiscoutText3__c
                                 ,COWO_SVF_DiscoutText4__c
                                 ,COWO_SVF_DiscoutAmount1__c
                                 ,COWO_SVF_DiscoutAmount2__c
                                 ,COWO_SVF_DiscoutAmount3__c
                                 ,COWO_SVF_DiscoutAmount4__c
                                 ,COWO_LocalCorporationTC_Total_Profit__c
                                 ,COWO_LocalCorporationTC_Profit_Rate__c
                                 ,COWO_Discount_Amount_Rate__c
                            from quote
                            where id =: quoteId];
            
            // 見積に紐付く見積品目一覧を取得
            List<QuoteLineItem> quoteLineItems = [select Id
                                                            ,COWO_ItemNumber__c
                                                            ,COWO_Product_Name__c
                                                            ,COWO_ProductCode__c
                                                            ,COWO_PartsNo__c
                                                            ,Quantity
                                                            ,COWO_QuantityUnit__c
                                                            ,COWO_TC__c
                                                            ,COWO_MC__c
                                                            ,COWO_LocalCorporationTC__c
                                                            ,COWO_FrontPurchasePrice__c
                                                            ,COWO_DetailCategory__c
                                                            ,COWO_DetailCategory_MTE__c
                                                            ,COWO_RejectionReason__c
                                                            ,COWO_PlantCode__c
                                                            ,COWO_PlantCode_MTE__c
                                                            ,COWO_StorageLocation__c
                                                            ,COWO_StorageLocation_MTE__c
                                                            ,COWO_S4LinkagePrice__c
                                                            ,COWO_Currency__c
                                                            ,COWO_Recording_Division__c
                                                            ,COWO_WBSElement__c
                                                            ,COWO_ProfitCenter__c
                                                            ,COWO_ProfitCenter_MTE__c
                                                            ,COWO_ItemText__c
                                                            ,COWO_DeliverySchedule__c
                                                            ,COWO_MaterialAvailDate__c
                                                            ,COWO_MaterialGroup1__c
                                                            ,COWO_DiscountPrice__c
                                                            ,COWO_DiscountUnitPrice__c
                                                            ,COWO_TotalPrice__c
                                                            ,COWO_TotalLocalCorporationTC__c
                                                            ,COWO_TotalFrontPurchasePrice__c
                                                            ,COWO_TotalTC__c
                                                            ,COWO_TotalMC__c
                                                            ,UnitPrice
                                                            ,CurrencyIsoCode 
                                                            ,SortOrder
                                                            ,Subtotal
                                                            ,COWO_ShippingInstructions__c
                                                            ,COWO_SalesNoteCustome__c
                                                            ,COWO_SalesUnit__c
                                                            ,COWO_PartitionPrice__c
                                                            ,COWO_NoDiscountFlg__c
                                                            ,CO_ovcUpdateFlag__c
                                                            ,CO_ovcUpdateFlag_MTE__c
                                                            ,COWO_Description__c
                                                     from QuoteLineItem
                                                     where QuoteId =: quoteId order by COWO_SortNo__c ASC];

            system.debug('quoteLineItems' + quoteLineItems);

            //Login User Permission check
            Boolean isPSGHHTUser = true;
            List<String> dx_Permissionsets = System.Label.COWO_LBL_PermissionSet.split(',');
            system.debug('dx_Permissionsets' + dx_Permissionsets);
            if([SELECT count() FROM PermissionSetAssignment where assigneeid =: System.UserInfo.getUserId() and PermissionSet.Name in: dx_Permissionsets] == 0){
                isPSGHHTUser = false;
            }
            
            // OriginData
            List<QuoteLineItems> quoteLineItemList = new List<QuoteLineItems>();
            for(quoteLineItem quoteLineItem : quoteLineItems){
                QuoteLineItems displayQuoteLineItems = new QuoteLineItems();
                displayQuoteLineItems.Id = quoteLineItem.Id;
                displayQuoteLineItems.cowo_ProductCode = quoteLineItem.COWO_ProductCode__c;
                quoteLineItemList.add(displayQuoteLineItems);
            }
              
            // 画面表示用データ計算処理
            //QuoteLineItemDisplayParams displayParams = calculateData(quoteLineItemList,quote,isPSGHHTUser);
            QuoteLineItemDisplayParams displayParams = calculateData(quoteLineItems,quote,isPSGHHTUser);
            system.debug('displayParams' + displayParams);

            // 正常終了の場合
            //String resultString = doNormalEnd(quoteLineItemList, displayParams, pricebook2Id, quote.CurrencyIsoCode,isPSGHHTUser);
            String resultString = doNormalEnd(quoteLineItems, displayParams, pricebook2Id, quote.CurrencyIsoCode,isPSGHHTUser,quoteLineItemList);
            
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
     * 正常終了処理
     * @param objectList:データリスト
     * @param displayParams:
     * @param pricebook2Id:Price Book ID
     * @return 処理結果
     */
    private static String doNormalEnd(List<Object> objectList, 
                                      QuoteLineItemDisplayParams displayParams, 
                                      String pricebook2Id,
                                      String currencyIsoCode,
                                      Boolean isPSGHHTUser,
                                      List<QuoteLineItems> quoteLineItemList){
        System.debug('★★★★★ 正常終了処理 start ★★★★★');

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeNumberField('returnCode', 0); // 正常終了
        gen.writeObjectField('returnMsg', System.Label.COWO_MSG_Search_NormalEnd);
        gen.writeObjectField('data', objectList);
        gen.writeObjectField('displayParams', displayParams);
        gen.writeStringField('pricebook2Id', pricebook2Id);
       // gen.writeObjectField('originDatas', originDataList);
        gen.writeObjectField('currencyIsoCode', currencyIsoCode); // 通貨設定
        gen.writeBooleanField('isPSGHHTUser',isPSGHHTUser); //Login User権限判別
        gen.writeObjectField('originData', quoteLineItemList);
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonString = gen.getAsString();
        
        System.debug('★★★★★ jsonString ★★★★★' + jsonString);
        
        System.debug('★★★★★ 正常終了処理 end ★★★★★');

        return jsonString;
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
    public static String reflectEditedData(String quoteId, String draftValues, String deletedData, String datas,String quoteParams,Decimal digits,Boolean qliReflectCheck,Boolean isPSGHHTUser){

        // 異常終了時のロールバックポイント
        Savepoint sp = Database.setSavepoint();

        try{
            // 見積品目一覧
            List<Object> quoteLineItemList = (List<Object>) JSON.deserializeUntyped(datas);
            system.debug('quoteLineItemList' + quoteLineItemList);
            
            if(quoteLineItemList.size() > 200){
                throw new CustomException(System.label.COWO_MSG_201Error);
            }
            
            // 処理正常終了時戻す用のIDリスト（Insert後のIDを画面に戻す）
            List<String> draftIdList = new List<String>();
            // 見積の価格表IDと通貨 ISO コードを取得する
            Quote quote = [SELECT Pricebook2Id, CurrencyIsoCode,COWO_Tax_Rate__c FROM quote WHERE Id =: quoteId LIMIT 1];
            system.debug('quote' + quote);
            
            // 画面から取得された変更データ一覧取得
            List<Object> draftList = (List<Object>) JSON.deserializeUntyped(draftValues);
            // 追加商品Id一覧
            List<String> product2IdForNewQLI = new List<String>();
            // 見積品目変更レコードリスト
            List<quoteLineItem> quoteLineItemUpsertList = new List<quoteLineItem>();
            //変更有レコードId
            Set<String> draftIdSet = new Set<String>();
            for(Object draftValue : draftList){
                Map<String, Object> draftValueMap = (Map<String, Object>)draftValue;
                // 見積品目ID
                String quoteLineItemId = (String)draftValueMap.get('Id');
                // 商品ID
                String product2Id = (quoteLineItemId).right((quoteLineItemId).length() - 3);
                // データパターン
                String dataPattern = (quoteLineItemId).left(3);
                // draftValueIdSet
                draftIdSet.add(quoteLineItemId);
                // 追加された商品Id
                if('Add'.equals(dataPattern)){
                    product2IdForNewQLI.add(product2Id);
                }
            }

            Decimal allDiscountunitPrice = 0;

            for(Object data : quoteLineItemList){
                Map<String, Object> dataMap = (Map<String, Object>)data;
                if(dataMap.get('COWO_DiscountPrice__c') != null && dataMap.get('COWO_DiscountPrice__c') != ''){
                    allDiscountunitPrice += convertNullToDecimal(dataMap.get('COWO_DiscountPrice__c'),digits);
                }
            }
            System.debug('allDiscountunitPrice' + allDiscountunitPrice);

            // 自由入力製品の価格エントリー取得
            PricebookEntry pricebookEntryByNew = [SELECT Id, Product2Id 
                                                  FROM PricebookEntry 
                                                  WHERE Pricebook2Id = :quote.pricebook2Id 
                                                  AND Product2.Name = '自由入力製品'
                                                  AND CurrencyIsoCode = :quote.currencyIsoCode limit 1];
            system.debug('pricebookEntryByNew' + pricebookEntryByNew);    
                        
            // 商品追加で検索された商品と価格エントリーを取得
            List<PriceBookEntry> pricebookEntriesByAdd = [SELECT id,Product2Id 
                                                          FROM PriceBookEntry 
                                                          WHERE Pricebook2Id = :quote.pricebook2Id 
                                                          AND product2Id in :product2IdForNewQLI
                                                          AND CurrencyIsoCode = :quote.currencyIsoCode];                                                     
            
            // 新規/更新見積品目
            for(Object quoteLineItem : quoteLineItemList){
                Map<String, Object> quoteLineItemMap = (Map<String, Object>)quoteLineItem;
                //system.debug('quoteLineItemMap' + quoteLineItemMap.get('SortOrder'));

                if(quoteLineItemMap.get('COWO_ItemNumber__c') == null || quoteLineItemMap.get('COWO_ItemNumber__c') == ''){
                    throw new CustomException(System.label.COWO_MSG_ItemNumberRequired);
                }

                // data.Id に、追加の場合、商品ID(Product2Id)が入ってる、更新の場合、見積商品ID(quoteLineItemId)が入ってる
                // 見積品目ID
                String quoteLineItemId = (String)quoteLineItemMap.get('Id');
                // 商品ID
                String product2Id = (quoteLineItemId).right((quoteLineItemId).length() - 3);
                // データパターン
                String dataPattern = (quoteLineItemId).left(3);
                
                QuoteLineItem quoteLineItemUpsert = new QuoteLineItem();
                
                if(draftIdSet.contains(quoteLineItemId)){
                    // 新規見積品目
                    if('Add'.equals(dataPattern) || 'New'.equals(dataPattern)){
                        //PricebookEntryIdとProduct2Id設定
                        if('Add'.equals(dataPattern)){
                            for(PriceBookEntry pbe : pricebookEntriesByAdd){
                                if(pbe.Product2Id == product2Id){
                                    quoteLineItemUpsert.PricebookEntryId = pbe.id;
                                    quoteLineItemUpsert.Product2Id = pbe.Product2Id;
                                }
                            }
                        }else{
                            quoteLineItemUpsert.PricebookEntryId = pricebookEntryByNew.id;
                            quoteLineItemUpsert.Product2Id = pricebookEntryByNew.Product2Id;
                        }
                        quoteLineItemUpsert.QuoteId = quoteId;
                        //更新の場合、見積品目Id設定
                    }else{
                        quoteLineItemUpsert.Id = quoteLineItemId;
                        system.debug('quoteLineItemUpsert' + quoteLineItemUpsert.id);
                    }
                    integer quantity = 0;
                    if(quoteLineItemMap.get('Quantity') == null || quoteLineItemMap.get('Quantity') == ''){
                        quantity = 1;
                    }else{
                        quantity = Integer.valueOf(String.valueOf(quoteLineItemMap.get('Quantity')));
                    }  
                    Decimal unitPrice = 0;
                    if(quoteLineItemMap.get('UnitPrice') != null && quoteLineItemMap.get('UnitPrice') != ''){
                        unitPrice = convertNullToDecimal(quoteLineItemMap.get('UnitPrice'),digits);
                    }
                    Decimal totalTC = convertNullToDecimal(quoteLineItemMap.get('COWO_TC__c')) * quantity;
                    Decimal totalMC = convertNullToDecimal(quoteLineItemMap.get('COWO_MC__c')) * quantity;
                    Decimal totalFrontPurchasePrice = convertNullToDecimal(quoteLineItemMap.get('COWO_FrontPurchasePrice__c')) * quantity;
                    Decimal totalLocalCorporationTC = convertNullToDecimal(quoteLineItemMap.get('COWO_LocalCorporationTC__c')) * quantity;
                    Decimal hhtProfit = totalFrontPurchasePrice - totalTC;
                    Decimal frontProfit = convertNullToDecimal(quoteLineItemMap.get('COWO_TotalPrice__c')) - convertNullToDecimal(quoteLineItemMap.get('COWO_FrontPurchasePrice__c'));
                    Decimal frontProfitRate = convertNullToDecimal(quoteLineItemMap.get('COWO_TotalPrice__c')) ==0 ? frontProfit : frontProfit / convertNullToDecimal(quoteLineItemMap.get('COWO_TotalPrice__c'));
                    Decimal hhtProfitRate = totalTC == 0 ? hhtProfit : hhtProfit / totalTC;
                    Decimal taxPrice = convertNullToDecimal(quoteLineItemMap.get('COWO_TotalPrice__c')) * quote.COWO_Tax_Rate__c;
                    Decimal price = taxPrice + convertNullToDecimal(quoteLineItemMap.get('COWO_TotalPrice__c'));
                    quoteLineItemUpsert.Quantity =  quantity;
                    quoteLineItemUpsert.UnitPrice = convertNullToDecimal(quoteLineItemMap.get('UnitPrice'),digits);
                    quoteLineItemUpsert.COWO_DiscountPrice__c = convertNullToDecimal(quoteLineItemMap.get('COWO_DiscountPrice__c'),digits);
                    quoteLineItemUpsert.COWO_TotalPrice__c = convertNullToDecimal(quoteLineItemMap.get('COWO_TotalPrice__c'),digits);
                    integer productNameLength = Schema.SObjectType.QuoteLineItem.fields.COWO_Product_Name__c.getLength();
                    quoteLineItemUpsert.COWO_Product_Name__c = quoteLineItemMap.get('COWO_Product_Name__c') == null ? '' :  String.valueOf(quoteLineItemMap.get('COWO_Product_Name__c')).abbreviate(productNameLength);   
                    quoteLineItemUpsert.COWO_DiscountUnitPrice__c = convertNullToDecimal(quoteLineItemMap.get('COWO_DiscountUnitPrice__c'),digits);
                    quoteLineItemUpsert.COWO_TotalTC__c = setScale(totalTC,digits);
                    quoteLineItemUpsert.COWO_TotalMC__c = setScale(totalMC,digits);
                    quoteLineItemUpsert.COWO_TotalFrontPurchasePrice__c = setScale(totalFrontPurchasePrice,digits);
                    quoteLineItemUpsert.COWO_TotalLocalCorporationTC__c = setScale(totalLocalCorporationTC,digits);
                    quoteLineItemUpsert.COWO_TC__c = convertNullToDecimal(quoteLineItemMap.get('COWO_TC__c'),digits);
                    quoteLineItemUpsert.COWO_MC__c = convertNullToDecimal(quoteLineItemMap.get('COWO_MC__c'),digits);
                    quoteLineItemUpsert.COWO_FrontPurchasePrice__c = convertNullToDecimal(quoteLineItemMap.get('COWO_FrontPurchasePrice__c'),digits);
                    quoteLineItemUpsert.COWO_LocalCorporationTC__c = convertNullToDecimal(quoteLineItemMap.get('COWO_LocalCorporationTC__c'),digits);
                    quoteLineItemUpsert.COWO_HHTProfit__c = setScale(hhtProfit,digits);
                    quoteLineItemUpsert.COWO_FrontProfit__c = setScale(frontProfit,digits);
                    quoteLineItemUpsert.COWO_HHTProfitRate__c = hhtProfitRate;
                    quoteLineItemUpsert.COWO_FrontProfitRate__c = frontProfitRate;
                    quoteLineItemUpsert.COWO_PartsNo__c = (String)quoteLineItemMap.get('COWO_PartsNo__c');   
                    quoteLineItemUpsert.COWO_S4LinkagePrice__c = convertNullToDecimal(quoteLineItemMap.get('COWO_TotalPrice__c'),digits);
                    quoteLineItemUpsert.COWO_TaxPrice__c = setScale(taxPrice,digits);
                    quoteLineItemUpsert.COWO_Price__c = setScale(price,digits);
                    quoteLineItemUpsert.COWO_QuoteLineItem_IsActive__c = true;
                    quoteLineItemUpsert.SortOrder = Integer.valueOf(String.valueOf(quoteLineItemMap.get('COWO_SortNo__c')));
                    quoteLineItemUpsert.COWO_SortNo__c = Integer.valueOf(String.valueOf(quoteLineItemMap.get('COWO_SortNo__c')));
                    quoteLineItemUpsert.COWO_ProductCode__c = (String)quoteLineItemMap.get('COWO_ProductCode__c');
                    quoteLineItemUpsert.COWO_QuantityUnit__c = (String)quoteLineItemMap.get('COWO_QuantityUnit__c');
                    quoteLineItemUpsert.COWO_DetailCategory__c = (String)quoteLineItemMap.get('COWO_DetailCategory__c');
                    quoteLineItemUpsert.COWO_DetailCategory_MTE__c = (String)quoteLineItemMap.get('COWO_DetailCategory_MTE__c');
                    quoteLineItemUpsert.COWO_RejectionReason__c = (String)quoteLineItemMap.get('COWO_RejectionReason__c');
                    quoteLineItemUpsert.COWO_PlantCode__c = (String)quoteLineItemMap.get('COWO_PlantCode__c');
                    quoteLineItemUpsert.COWO_PlantCode_MTE__c = (String)quoteLineItemMap.get('COWO_PlantCode_MTE__c');
                    quoteLineItemUpsert.COWO_StorageLocation__c = (String)quoteLineItemMap.get('COWO_StorageLocation__c');
                    quoteLineItemUpsert.COWO_StorageLocation_MTE__c = (String)quoteLineItemMap.get('COWO_StorageLocation_MTE__c');
                    quoteLineItemUpsert.COWO_Currency__c = quoteLineItemMap.get('COWO_Currency__c') == null ? quote.CurrencyISOCode : (String)quoteLineItemMap.get('COWO_Currency__c');
                    quoteLineItemUpsert.COWO_Recording_Division__c = (String)quoteLineItemMap.get('COWO_Recording_Division__c');
                    quoteLineItemUpsert.COWO_ProfitCenter__c = (String)quoteLineItemMap.get('COWO_ProfitCenter__c');
                    quoteLineItemUpsert.COWO_MaterialGroup1__c = (String)quoteLineItemMap.get('COWO_MaterialGroup1__c');
                    quoteLineItemUpsert.COWO_ItemNumber__c = Integer.valueOf(quoteLineItemMap.get('COWO_ItemNumber__c'));
                    quoteLineItemUpsert.COWO_ItemText__c = (String)quoteLineItemMap.get('COWO_ItemText__c');
                    //quoteLineItemUpsert.COWO_WBSElement__c = (String)quoteLineItemMap.get('COWO_WBSElement__c');
                    quoteLineItemUpsert.COWO_MaterialAvailDate__c = quoteLineItemMap.get('COWO_MaterialAvailDate__c') != null ? Date.valueOf((String)quoteLineItemMap.get('COWO_MaterialAvailDate__c')) : (Date)null;
                    quoteLineItemUpsert.COWO_DeliverySchedule__c = quoteLineItemMap.get('COWO_DeliverySchedule__c') != null ? Date.valueOf((String)quoteLineItemMap.get('COWO_DeliverySchedule__c')) : (Date)null;
                    quoteLineItemUpsert.COWO_SalesNoteCustome__c = (String)quoteLineItemMap.get('COWO_SalesNoteCustome__c');
                    quoteLineItemUpsert.COWO_ShippingInstructions__c = (String)quoteLineItemMap.get('COWO_ShippingInstructions__c');
                    quoteLineItemUpsert.COWO_SalesUnit__c = (String)quoteLineItemMap.get('COWO_SalesUnit__c');
                    quoteLineItemUpsert.COWO_PartitionPrice__c = convertNullToDecimal(quoteLineItemMap.get('COWO_PartitionPrice__c'),digits);
                    quoteLineItemUpsert.COWO_NoDiscountFlg__c = (Boolean)quoteLineItemMap.get('COWO_NoDiscountFlg__c');
                    quoteLineItemUpsert.COWO_Description__c = (String)quoteLineItemMap.get('COWO_Description__c');
                    quoteLineItemUpsertList.add(quoteLineItemUpsert);
                }
            }
            System.debug(quoteLineItemUpsertList);
            // データを新規もしくは更新する
            if(quoteLineItemUpsertList.size() > 0){
                upsert quoteLineItemUpsertList;
            }
            
            // 削除データリスト
            List<QuoteLineItem> delQuoteLineItemList = new List<QuoteLineItem>();
            
            // 削除データ処理
            List<Object> delDataList = (List<Object>) JSON.deserializeUntyped(deletedData);
            for(Object deletedDataItem : delDataList){
                Map<String, Object> delDataMap = (Map<String, Object>)deletedDataItem;
                // 見積商品ID
                String quoteLineItemId = (String)delDataMap.get('Id');
                QuoteLineItem delQuoteLineItem = new QuoteLineItem();
                delQuoteLineItem.Id = quoteLineItemId;
                delQuoteLineItemList.add(delQuoteLineItem);
            }
            
            // データを削除する
            if(delQuoteLineItemList.size() > 0){
                delete delQuoteLineItemList;
            }

            // 見積更新用変数
            Object quoteParamsUpdate = (Object)JSON.deserializeUntyped(quoteParams);
            Map<String,Object> quoteparamsUpdateMap = (Map<String, Object>)quoteParamsUpdate;
            
            system.debug('quoteParams' + quoteParams);
            // 見積更新
            Quote quoteUpdate = new Quote();
            quoteUpdate.id = quoteId;
            quoteUpdate.COWO_Discount_Amount__c = convertNullToDecimal(quoteparamsUpdateMap.get('nebikiKingaku'),digits); 
            quoteUpdate.COWO_Header_Discount_Rate__c = convertNullToDecimal(quoteparamsUpdateMap.get('headerNebikiritsu'));
            quoteUpdate.COWO_Header_Discount_Amount__c = convertNullToDecimal(quoteparamsUpdateMap.get('headerNebiki01'),digits);
            quoteUpdate.COWO_Fertility_Discount1__c = convertNullToDecimal(quoteparamsUpdateMap.get('syuseiNebiki01'),digits);
            quoteUpdate.COWO_Fertility_Discount2__c = convertNullToDecimal(quoteparamsUpdateMap.get('syuseiNebiki02'),digits);
            quoteUpdate.COWO_Report_Item_Flag__c = Boolean.valueOf(String.valueOf(quoteparamsUpdateMap.get('ishikiCheck')));
            quoteUpdate.COWO_Fertility_Discount_Title1__c = quoteparamsUpdateMap.get('fertilityDiscountTitle1') != null ? (String)quoteparamsUpdateMap.get('fertilityDiscountTitle1') : System.Label.COWO_LBL_Syuseinebiki01;
            quoteUpdate.COWO_Fertility_Discount_Title2__c = quoteparamsUpdateMap.get('fertilityDiscountTitle2') != null ? (String)quoteparamsUpdateMap.get('fertilityDiscountTitle2') : System.Label.COWO_LBL_Syuseinebiki02;
            if(convertNullToDecimal(quoteparamsUpdateMap.get('syuseiNebiki01'))!= 0 && convertNullToDecimal(quoteparamsUpdateMap.get('syuseiNebiki02')) != 0){
                    quoteUpdate.COWO_SVF_DiscoutText1__c = System.Label.COWO_LBL_Shokei;
                    quoteUpdate.COWO_SVF_DiscoutAmount1__c = convertNullToDecimal(quoteparamsUpdateMap.get('shokei'),digits) - convertNullToDecimal(quoteparamsUpdateMap.get('headerNebiki01'),digits) - (convertNullToDecimal(quoteparamsUpdateMap.get('shokei'),digits) * convertNullToDecimal(quoteparamsUpdateMap.get('headerNebikiritsu')));
                    quoteUpdate.COWO_SVF_DiscoutText2__c = (String)quoteparamsUpdateMap.get('fertilityDiscountTitle1');
                    quoteUpdate.COWO_SVF_DiscoutAmount2__c = 0 - convertNullToDecimal(quoteparamsUpdateMap.get('syuseiNebiki01'),digits);
                    quoteUpdate.COWO_SVF_DiscoutText3__c = (String)quoteparamsUpdateMap.get('fertilityDiscountTitle2');
                    quoteUpdate.COWO_SVF_DiscoutAmount3__c = 0 - convertNullToDecimal(quoteparamsUpdateMap.get('syuseiNebiki02'),digits);
            }else{
                quoteUpdate.COWO_SVF_DiscoutText1__c = '';
                quoteUpdate.COWO_SVF_DiscoutAmount1__c = (Decimal)null;
                if(convertNullToDecimal(quoteparamsUpdateMap.get('syuseiNebiki01')) == 0 && convertNullToDecimal(quoteparamsUpdateMap.get('syuseiNebiki02')) == 0){
                    quoteUpdate.COWO_SVF_DiscoutText2__c = '';
                    quoteUpdate.COWO_SVF_DiscoutAmount2__c = (Decimal)null;
                    quoteUpdate.COWO_SVF_DiscoutText3__c = '';
                    quoteUpdate.COWO_SVF_DiscoutAmount3__c = (Decimal)null;
                }else{
                    quoteUpdate.COWO_SVF_DiscoutText2__c = System.Label.COWO_LBL_Shokei;
                    quoteUpdate.COWO_SVF_DiscoutAmount2__c = convertNullToDecimal(quoteparamsUpdateMap.get('shokei'),digits) - convertNullToDecimal(quoteparamsUpdateMap.get('headerNebiki01'),digits) - (convertNullToDecimal(quoteparamsUpdateMap.get('shokei'),digits) * convertNullToDecimal(quoteparamsUpdateMap.get('headerNebikiritsu')));//convertNullToDecimal(quoteparamsUpdateMap.get('shokei'),digits);
                    if(convertNullToDecimal(quoteparamsUpdateMap.get('syuseiNebiki01')) != 0 ){
                        quoteUpdate.COWO_SVF_DiscoutText3__c = (String)quoteparamsUpdateMap.get('fertilityDiscountTitle1');
                        quoteUpdate.COWO_SVF_DiscoutAmount3__c = 0 - convertNullToDecimal(quoteparamsUpdateMap.get('syuseiNebiki01'),digits);
                    }else{
                        quoteUpdate.COWO_SVF_DiscoutText3__c = (String)quoteparamsUpdateMap.get('fertilityDiscountTitle2');
                        quoteUpdate.COWO_SVF_DiscoutAmount3__c = 0 - convertNullToDecimal(quoteparamsUpdateMap.get('syuseiNebiki02'),digits);
                    }
                }
            }
            quoteUpdate.COWO_SVF_DiscoutText4__c = System.Label.COWO_LBL_SummaryTitle;
            quoteUpdate.COWO_SVF_DiscoutAmount4__c = convertNullToDecimal(quoteparamsUpdateMap.get('saisyuKingaku'),digits);
            quoteUpdate.COWO_Final_Amount_Discount_Exclude__c = convertNullToDecimal(quoteparamsUpdateMap.get('shokei'),digits) - convertNullToDecimal(quoteparamsUpdateMap.get('headerNebiki01'),digits) - 
                                                                (convertNullToDecimal(quoteparamsUpdateMap.get('shokei'),digits) * convertNullToDecimal(quoteparamsUpdateMap.get('headerNebikiritsu'))) - allDiscountunitPrice ;
            update quoteUpdate;
            
            if(qliReflectCheck){
                // 見積明細レコード更新
                // 既存帳票見積明細レコード削除
                List<COWO_QuoteLineItem__c> delCOWOQIList = [select id from COWO_QuoteLineItem__c where COWO_Quote__c =: quoteId];
                if(delCOWOQIList.size() > 0){
                    delete delCOWOQIList;
                }
                if(Boolean.valueOf(String.valueOf(quoteparamsUpdateMap.get('ishikiCheck')))){
                    // 一式帳票見積明細レコード追加
                    COWO_QuoteLineItem__c cowoQuoteLineItem = new COWO_QuoteLineItem__c();
                    cowoQuoteLineItem.COWO_ProductName__c = System.label.COWO_Label_OneSet;
                    cowoQuoteLineItem.COWO_Quote__c = quoteId;
                    cowoQuoteLineItem.COWO_Price__c = convertNullToDecimal(quoteparamsUpdateMap.get('allUnitprice'),digits);
                    cowoQuoteLineItem.COWO_Quantity__c = '1';
                    cowoQuoteLineItem.COWO_SubTotal__c = convertNullToDecimal(quoteparamsUpdateMap.get('allTotalprice'),digits);
                    cowoQuoteLineItem.COWO_DiscountUnitPrice__c = convertNullToDecimal(quoteparamsUpdateMap.get('allDiscountUnitPrice'),digits);
                    cowoQuoteLineItem.COWO_SortNo__c = 1;
                    cowoQuoteLineItem.CurrencyIsoCode = quote.CurrencyIsoCode;
                    insert cowoQuoteLineItem;
                    // 品目のレコードずつ明細に追加する
                }else{
                    List<COWO_QuoteLineItem__c> insertCOWOQIList = new List<COWO_QuoteLineItem__c>();
                    List<Object> dataList = (List<Object>) JSON.deserializeUntyped(datas);
                    for(integer cnt = 0;cnt < dataList.size() ;cnt++){
                        Map<String, Object> cowoQIForInsMap = (Map<String, Object>)dataList[cnt];
                        COWO_QuoteLineItem__c cowoQuoteLineItem = new COWO_QuoteLineItem__c();
                        integer quantity = 0;
                        if(cowoQIForInsMap.get('Quantity') == null || cowoQIForInsMap.get('Quantity') == ''){
                            quantity = 1;
                        }else{
                            quantity = Integer.valueOf(String.valueOf(cowoQIForInsMap.get('Quantity')));
                        } 
                        cowoQuoteLineItem.COWO_Quote__c = quoteId;
                        cowoQuoteLineItem.COWO_ProductName__c = String.valueOf(cowoQIForInsMap.get('COWO_Product_Name__c'));
                        cowoQuoteLineItem.COWO_Price__c = convertNullToDecimal(cowoQIForInsMap.get('UnitPrice'),digits);
                        // cowoQuoteLineItem.COWO_SubTotal__c = convertNullToDecimal(cowoQIForInsMap.get('COWO_TotalPrice__c'),digits);
                        cowoQuoteLineItem.COWO_SubTotal__c = convertNullToDecimal(cowoQIForInsMap.get('UnitPrice'),digits) * quantity;
                        cowoQuoteLineItem.COWO_Quantity__c = String.valueOf(cowoQIForInsMap.get('Quantity'));
                        cowoQuoteLineItem.COWO_DiscountUnitPrice__c = convertNullToDecimal(cowoQIForInsMap.get('COWO_DiscountUnitPrice__c'),digits);
                        cowoQuoteLineItem.COWO_SortNo__c = cnt + 1;
                        cowoQuoteLineItem.CurrencyIsoCode = quote.CurrencyIsoCode;
                        cowoQuoteLineItem.COWO_PartsNo__c = String.valueOf(cowoQIForInsMap.get('COWO_PartsNo__c'));
                        cowoQuoteLineItem.COWO_Description__c = String.valueOf(cowoQIForInsMap.get('COWO_Description__c'));
                        insertCOWOQIList.add(cowoQuoteLineItem);
                    }
                    insert insertCOWOQIList;
                }
            }
            
            
            // 正常終了した場合
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeNumberField('returnCode', 0); // 正常終了
            gen.writeObjectField('returnMsg', System.Label.COWO_MSG_QuoteProduct2Add_NormalEnd);
            gen.writeEndObject();
            
            // Get the JSON string.
            String jsonString = gen.getAsString();
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
            String jsonString = gen.getAsString();
            return jsonString;
        }
    }
    
    /**
     * 画面編集データを計算する
     * @param deletedData:削除データ
     * @param draftValues:新規/更新データ
     * @param deletedData:削除データ
     * @param datas:見積品目から読込だデータ
     * @return 処理結果
     */
    public static QuoteLineItemDisplayParams calculateData(List<QuoteLineItem> quoteLineItemList,Quote quote,Boolean isPSGHHTUser){
        
        QuoteLineItemDisplayParams quoteLineItemDisplay = initParams();
                
        if(quoteLineItemList.size() > 0){
            for(QuoteLineItem loopItem : quoteLineItemList){
                //小計
                if(loopItem.Subtotal != null && loopItem.Subtotal > 0){
                    quoteLineItemDisplay.shokei += (Decimal)loopItem.Subtotal;
                }
                //明細値引き
                if(loopItem.COWO_DiscountPrice__c != null && loopItem.COWO_DiscountPrice__c > 0){
                    quoteLineItemDisplay.mesainebikiGokei += loopItem.COWO_DiscountPrice__c;
                }
            }
            //MC合計
            quoteLineItemDisplay.mcGokei = quote.COWO_Total_MC__c;
            //TC合計
            quoteLineItemDisplay.tcGokei = quote.COWO_Total_TC__c;
            //フロント仕入価格合計
            quoteLineItemDisplay.furontoKakaku = quote.COWO_Total_FrontPurchasePrice__c;
            //現法TC合計
            quoteLineItemDisplay.genpoTCGokei = quote.COWO_Total_LocalCorporationTC__c;
	        //ヘッダ値引き(割引額)_01
            quoteLineItemDisplay.headerNebiki01 = quote.COWO_Header_Discount_Amount__c;
	        //出精値引き① 
            quoteLineItemDisplay.syuseiNebiki01 = quote.COWO_Fertility_Discount1__c;
	        //出精値引き②
            quoteLineItemDisplay.syuseiNebiki02 = quote.COWO_Fertility_Discount2__c;
	        //ヘッダ値引き(割引率) 
            quoteLineItemDisplay.headerNebikiritsu = quote.COWO_Header_Discount_Rate__c;
	        //値引金額 
            quoteLineItemDisplay.nebikiKingaku = quote.COWO_Discount_Amount__c;
            //値引率
            quoteLineItemDisplay.discountRate = quote.COWO_Discount_Amount_Rate__c / 100;
            //一式チェック
            quoteLineItemDisplay.isIshiki = quote.COWO_Report_Item_Flag__c;
            //消費税率
            //quoteLineItemDisplay.shohizeiRitsu = quote.COWO_Tax_Rate__c == null ? 0.1 : quote.COWO_Tax_Rate__c / 100;
            quoteLineItemDisplay.shohizeiRitsu = quote.COWO_Tax_Rate__c / 100;
            //最終金額
            quoteLineItemDisplay.saisyuKingaku = quote.COWO_Final_Amount__c	;
	        //消費税合計
            quoteLineItemDisplay.shohizeiGokei = quote.COWO_Total_Tax__c;
            //最終金額(税込)
            quoteLineItemDisplay.saisyuKingakuZeikomi = quote.COWO_Final_Amount_Tax_Included__c;
	        //利益合計
            quoteLineItemDisplay.riekiGokei = quote.COWO_Total_Profit__c;
	        //利益率
            quoteLineItemDisplay.riekiRitsu = quote.COWO_Profit_Rate__c / 100;
	        //HHT利益
            quoteLineItemDisplay.hhtRieki = quote.COWO_HHT_Total_Profit__c;
	        //HHT利益率
            quoteLineItemDisplay.hhtRiekiritsu = quote.COWO_HHT_Profit_Rate__c / 100;
	        //粗利益
            quoteLineItemDisplay.ararieki = quote.COWO_Gross_Profit__c;
            //粗利益率
            quoteLineItemDisplay.arariekiRitsu = quote.COWO_Gross_Profit_Rate__c / 100;
            //現法利益合計
            quoteLineItemDisplay.localCorporationTCProfit = quote.COWO_LocalCorporationTC_Total_Profit__c;
            //現法利益率
            quoteLineItemDisplay.localCorporationTCProfitRate = quote.COWO_LocalCorporationTC_Profit_Rate__c / 100;
            //ヘッダ値引き(割引額)_02
	        if(quoteLineItemDisplay.headerNebikiritsu != null){
                quoteLineItemDisplay.headerNebiki02 =  quoteLineItemDisplay.shokei * quoteLineItemDisplay.headerNebikiritsu;
            }
            // 画面表示フォーマット
            COWO_CurrencyIsoCode__mdt currencymdt = [SELECT Id, DeveloperName, COWO_Digits__c, COWO_CurrencyMark__c, COWO_DisplayFormat__c, COWO_DigitsInput__c FROM COWO_CurrencyIsoCode__mdt where DeveloperName =: quote.CurrencyIsoCode limit 1];
            quoteLineItemDisplay.digits = currencymdt.COWO_Digits__c;
            quoteLineItemDisplay.digitsInput = currencymdt.COWO_DigitsInput__c;
            quoteLineItemDisplay.format = currencymdt.COWO_DisplayFormat__c;
            quoteLineItemDisplay.symbol = currencymdt.COWO_CurrencyMark__c;
            //出精値引1_タイトル
            quoteLineItemDisplay.fertilityDiscountTitle1 = String.isNotBlank(quote.COWO_Fertility_Discount_Title1__c) ? quote.COWO_Fertility_Discount_Title1__c : System.Label.COWO_LBL_Syuseinebiki01;
            //出精値引2_タイトル
            quoteLineItemDisplay.fertilityDiscountTitle2 = String.isNotBlank(quote.COWO_Fertility_Discount_Title2__c) ? quote.COWO_Fertility_Discount_Title2__c : System.Label.COWO_LBL_Syuseinebiki02;
        }
		system.debug('★★★★★ quoteLineItemDisplay ★★★★★' + quoteLineItemDisplay);
        return quoteLineItemDisplay;
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
     * 見積品目Nullデータを転換する
     * @param data:見積品目から読込だデータ
     * @return 処理結果
     */
    private static Decimal convertNullToDecimal(Object fieldValue,Decimal digits){
        // return fieldValue == null || fieldValue == '' ? (Decimal)null : Decimal.valueOf(String.valueOf(fieldValue)).setScale((Integer)digits, System.RoundingMode.HALF_UP);
        return fieldValue == null || fieldValue == '' ? 0 : Decimal.valueOf(String.valueOf(fieldValue)).setScale((Integer)digits, System.RoundingMode.HALF_UP);
    }

    /**
     * 見積品目Nullデータを転換する
     * @param data:見積品目から読込だデータ
     * @return 処理結果
     */
    private static Decimal setScale(Decimal fieldValue,Decimal digits){
        return fieldValue == null ? (Decimal)null : fieldValue.setScale((Integer)digits, System.RoundingMode.HALF_UP);
    }
    
    /**画面計算用クラス**/
    public class QuoteLineItemDisplayParams{
        public Decimal shokei{get;set;}
        public Decimal shohizeiRitsu{get;set;}
        public Decimal riekiGokei{get;set;}
        public Decimal nebikiKingaku{get;set;}
        public Decimal shohizeiGokei{get;set;}
        public Decimal riekiRitsu{get;set;}
        public Decimal saisyuKingaku{get;set;}
        public Decimal mcGokei{get;set;}
        public Decimal hhtRieki{get;set;}
        public Decimal tcGokei{get;set;}
        public Decimal hhtRiekiritsu{get;set;}
        public Decimal furontoKakaku{get;set;}
        public Decimal genpoTCGokei{get;set;}
        public Decimal ararieki{get;set;}
        public Decimal arariekiRitsu{get;set;}
        public Decimal headerNebikiritsu{get;set;}
        public Decimal headerNebiki01{get;set;}
        public Decimal headerNebiki02{get;set;}
        public Decimal syuseiNebiki01{get;set;}
        public Decimal syuseiNebiki02{get;set;}
        public Decimal mesainebikiGokei{get;set;}
        //public Boolean zeikomiCheck{get;set;}
        public Boolean isIshiki{get;set;}
        public integer allQuantity{get;set;}
        public Decimal allUnitprice{get;set;}
        public Decimal allTotalprice{get;set;}
        public Decimal allDiscountUnitPrice{get;set;}
        public Decimal saisyuKingakuZeikomi{get;set;}
        public Decimal digits {get;set;}
        public Decimal digitsInput{get;set;}
        public String format {get;set;}
        public String symbol {get;set;}
        public String fertilityDiscountTitle1 {get;set;}
        public String fertilityDiscountTitle2 {get;set;}
        public String discoutText1 {get;set;}
        public String discoutText2 {get;set;}
        public String discoutText3 {get;set;}
        public String discoutText4 {get;set;}
        public Decimal discoutAmount1{get;set;}
        public Decimal discoutAmount2{get;set;}
        public Decimal discoutAmount3{get;set;}
        public Decimal discoutAmount4{get;set;}
        public Decimal localCorporationTCProfit{get;set;}
        public Decimal localCorporationTCProfitRate{get;set;}
        public Decimal discountRate{get;set;}
    }
	
    private static QuoteLineItemDisplayParams initParams(){
        QuoteLineItemDisplayParams displayParams = new QuoteLineItemDisplayParams();
        displayParams.shokei = 0;
        displayParams.shohizeiRitsu = 0.1;
        displayParams.riekiGokei = 0;
        displayParams.nebikiKingaku = 0;
        displayParams.shohizeiGokei = 0;
		displayParams.riekiRitsu = 0;
        displayParams.saisyuKingaku = 0;
        displayParams.mcGokei = 0;
        displayParams.hhtRieki = 0;
        displayParams.tcGokei = 0;
        displayParams.hhtRiekiritsu = 0;
        displayParams.furontoKakaku = 0;
        displayParams.genpoTCGokei = 0;
        displayParams.ararieki = 0;
        displayParams.arariekiRitsu = 0;  
        displayParams.headerNebikiritsu = 0; 
        displayParams.headerNebiki01 = 0;
        displayParams.headerNebiki02 = 0;
        displayParams.syuseiNebiki01 = 0;
        displayParams.syuseiNebiki02 = 0;
        displayParams.mesainebikiGokei = 0;
        //displayParams.zeikomiCheck = false;
        displayParams.isIshiki = false;
        displayParams.allQuantity = 0;
        displayParams.allUnitprice = 0;
        displayParams.allTotalprice = 0;
        displayParams.allDiscountUnitPrice = 0;
        displayParams.saisyuKingakuZeikomi = 0;
        displayParams.digits = 0;
        displayParams.digitsInput = 0.00;
        displayParams.format = '';
        displayParams.symbol = '';
        displayParams.fertilityDiscountTitle1 = '';
        displayParams.fertilityDiscountTitle2 = '';
        displayParams.discoutText1 = '';
        displayParams.discoutText2 = '';
        displayParams.discoutText3 = '';
        displayParams.discoutText4 = '';
        displayParams.discoutAmount1 = 0;
        displayParams.discoutAmount2 = 0;
        displayParams.discoutAmount3 = 0;
        displayParams.discoutAmount4 = 0;
        displayParams.localCorporationTCProfit = 0;
        displayParams.localCorporationTCProfitRate = 0;
        displayParams.discountRate = 0;
        return displayParams;
    }
    
    public class QuoteLineItems {
        public String Id {get;set;}
        public String cowo_ProductCode {get;set;}
    }
 
    /**
    * カスタムエクセプションクラス
    */
    public class CustomException extends Exception {
    }
}