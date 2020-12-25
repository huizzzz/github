/********************************************************************************
 * クラス名 ： Quote_ReflectToOppClass
 * 概　　要 ： 見積のカスタムボタンから呼び出されるクラス。見積情報を商談へ反映する。
 * 作 成 日 ： 2020/01/28 中野
 * 更 新 日 ： 2020/05/26 張 反映項目増減対応
 ********************************************************************************/


Global class Quote_ReflectToOppClass {
    /*
    *コンストラクタ
    */
    public Quote_ReflectToOppClass(){}


    @AuraEnabled
    webService static String QuoteLineItemReflection(String qid){
        //データベースのセーブポイント作成
        Savepoint sp = Database.setSavepoint();
        system.debug('★★★レコードId:'+ qid);

        try{
            Quote quote = [SELECT OpportunityId FROM Quote WHERE Id =: qid];

            //見積に紐づく見積品目名の項目を取得する。
            List<QuoteLineItem> qitem = [SELECT PricebookEntryId
                                                ,COWO_MC__c
                                                ,COWO_PartsNo__c
                                                ,COWO_S4LinkagePrice__c
                                                ,COWO_TC__c
                                                ,Text__c
                                                ,COWO_TotalDiscountPercent__c
                                                ,COWO_FrontPurchasePrice__c
                                                ,ListPrice
                                                ,COWO_HHTWholesalePrice__c
                                                ,CreatedById
                                                ,COWO_HHTProfitRate__c
                                                ,COWO_FrontProfitRate__c
                                                ,COWO_HHTProfit__c
                                                ,COWO_FrontProfit__c
                                                ,Discount
                                                ,Unit__c
                                                ,COWO_TotalPrice__c
                                                ,TotalPrice
                                                ,Item_Name__c
                                                ,hinmokuCode__c
                                                ,LineNumber
                                                ,Description
                                                ,Product2Id
                                                ,COWO_SalesStandard__c
                                                ,Subtotal
                                                ,COWO_ListPrice__c
                                                ,COWO_DesiredDeliveryDate__c
                                                ,Quantity
                                                ,ServiceDate
                                                ,COWO_DiscountPrice__c
                                                ,LastModifiedById
                                                ,COWO_TaxPrice__c
                                                ,COWO_TaxPercent__c
                                                ,COWO_Rate__c
                                                ,COWO_LocalCorporationTC__c
                                                ,ItemType__c
                                                ,Requested_delivery_date_of_the_document__c
                                                ,COWO_TotalMC__c
                                                ,COWO_TotalTC__c
                                                ,COWO_TotalFrontPurchasePrice__c
                                                ,COWO_TotalLocalCorporationTC__c
                                                ,COWO_ProductText__c
                                                ,COWO_Product_Name__c
                                                ,QuoteId
                                                ,UnitPrice
                                                ,COWO_Currency__c
                                                ,COWO_Price__c
                                                ,Item_Number__c
                                                ,COWO_SortNo__c
                                                ,COWO_DiscountUnitPrice__c
                                                ,COWO_ProductCode__c
                                                ,COWO_QuantityUnit__c
                                                ,COWO_DetailCategory__c
                                                ,COWO_DetailCategory_MTE__c
                                                ,COWO_RejectionReason__c
                                                ,COWO_PlantCode__c
                                                ,COWO_PlantCode_MTE__c
                                                ,COWO_StorageLocation__c
                                                ,COWO_StorageLocation_MTE__c
                                                ,COWO_Recording_Division__c
                                                ,COWO_ProfitCenter__c
                                                ,COWO_MaterialGroup1__c
                                                ,COWO_ItemNumber__c
                                                ,COWO_ItemText__c
                                                ,COWO_WBSElement__c
                                                ,COWO_MaterialAvailDate__c
                                                ,COWO_DeliverySchedule__c 
                                                ,COWO_SalesNoteCustome__c
                                                ,COWO_ShippingInstructions__c
                                                ,COWO_SalesUnit__c
                                                ,COWO_PartitionPrice__c
                                                ,COWO_NoDiscountFlg__c
                                                ,COWO_Description__c
                                        FROM QuoteLineItem
                                        WHERE QuoteId =: qid
                                        order by COWO_SortNo__c Asc
                                        ];
            system.debug('★★★見積品目名取得');

            //1件もない場合、処理終了;
            if(qitem.isEmpty()){
                return 'noitem';
            }

            //商談に紐づく商談商品の項目を取得する。
            List<OpportunityLineItem> o = [SELECT Id
                                                 ,CO_ovcUpdateFlag__c
                                                 ,CO_ovcUpdateFlag_MTE__c
                                                 ,SAWO_ItemNumber__c
                                                 ,SAWO_ProductCode__c
                                           FROM OpportunityLineItem
                                           WHERE OpportunityId = :quote.OpportunityId];
                                           
            List<OpportunityLineItem> delOliList = new List<OpportunityLineItem>();
            List<OpportunityLineItem> updateOliList = new List<OpportunityLineItem>();
            List<OpportunityLineItem> insertOliList = new List<OpportunityLineItem>();
            List<OpportunityLineItem> upsertOliList = new List<OpportunityLineItem>();
            Set<Decimal> uniqueKey = new Set<Decimal>();
            //商談商品を削除する。
            if(o.size() > 0 && qitem.size() > 0){
                system.debug('★★★商談商品削除処理開始');
                // S4連携データは削除データから抜く
                for(OpportunityLineItem opplineItem : o){
                    if(opplineItem.CO_ovcUpdateFlag__c != 'U' && opplineItem.CO_ovcUpdateFlag_MTE__c != 'U'){
                        delOliList.add(opplineItem);
                    }else{
                        uniqueKey.add(opplineItem.SAWO_ItemNumber__c);
                    }
                 }
                
                delete delOliList;
                Database.emptyRecycleBin(delOliList);
                system.debug('★★★削除処理終了');	
            }

            //商談商品を作成する
            for(QuoteLineItem q : qitem){
                
                system.debug('★★★商談商品作成処理開始');
                if(!uniqueKey.contains(q.COWO_ItemNumber__c)){
                    OpportunityLineItem oitem = new OpportunityLineItem();
                    oitem.OpportunityId = Quote.OpportunityId;
                    oitem.Product2Id = q.Product2Id;
                    oitem.PricebookEntryId = q.PricebookEntryId;
                    oitem.Quantity = q.Quantity;
                    oitem.UnitPrice = q.UnitPrice;
                    oitem.SAWO_SalesPrice__c = q.UnitPrice;
                    //oitem.SAWO_Rate__c = q.COWO_Rate__c;
                    oitem.SAWO_LocalCorporationTC__c = q.COWO_LocalCorporationTC__c;
                    oitem.SAWO_FrontPurchasePrice__c = q.COWO_FrontPurchasePrice__c;
                    //oitem.SAWO_HHTWholesalePrice__c = q.COWO_HHTWholesalePrice__c;
                    oitem.TC__c = q.COWO_TC__c;
                    oitem.MC__c = q.COWO_MC__c;
                    oitem.ProductName__c = q.COWO_Product_Name__c;
                    oitem.SAWO_ProductName__c = q.COWO_Product_Name__c;
                    oitem.SAWO_Price__c = q.COWO_DiscountUnitPrice__c;
                    //oitem.SAWO_TotalPrice__c = q.COWO_TotalPrice__c;
                    oitem.SAWO_SortNo__c = q.COWO_SortNo__c;
                    oitem.SAWO_Parts_No__c = q.COWO_PartsNo__c;
                    oitem.SAWO_S4LinkagePrice__c = q.COWO_TotalPrice__c;//S/4連携金額
                    oitem.SAWO_ProductCode__c = q.COWO_ProductCode__c;//商品コード
                    oitem.SAWO_QuantityUnit__c = q.COWO_QuantityUnit__c;
                    oitem.SAWO_DetailCategory__c = q.COWO_DetailCategory__c;
                    oitem.SAWO_DetailCategory_MTE__c = q.COWO_DetailCategory_MTE__c;
                    oitem.SAWO_RejectionReason__c = q.COWO_RejectionReason__c;
                    oitem.SAWO_PlantCode__c = q.COWO_PlantCode__c;
                    oitem.SAWO_PlantCode_MTE__c = q.COWO_PlantCode_MTE__c;
                    oitem.SAWO_StorageLocation__c = q.COWO_StorageLocation__c;
                    oitem.SAWO_StorageLocation_MTE__c  = q.COWO_StorageLocation_MTE__c;
                    oitem.SAWO_Currency__c = q.COWO_Currency__c;
                    oitem.SAWO_Recording_Division__c = q.COWO_Recording_Division__c;
                    oitem.SAWO_ProfitCenter__c = q.COWO_ProfitCenter__c;
                    oitem.SAWO_MaterialGroup1__c = q.COWO_MaterialGroup1__c;
                    oitem.SAWO_ItemNumber__c = q.COWO_ItemNumber__c;
                    oitem.SAWO_ItemText__c = q.COWO_ItemText__c;
                    //oitem.SAWO_WBSElement__c = q.COWO_WBSElement__c;
                    oitem.SAWO_MaterialAvailDate__c = q.COWO_MaterialAvailDate__c;
                    oitem.SAWO_DeliverySchedule__c = q.COWO_DeliverySchedule__c; 
                    oitem.SAWO_SalesNoteCustome__c = q.COWO_SalesNoteCustome__c;
                    oitem.SAWO_ShippingInstructions__c = q.COWO_ShippingInstructions__c;
                    oitem.SAWO_SalesUnit__c = q.COWO_SalesUnit__c;
                    oitem.SAWO_PartitionPrice__c = q.COWO_PartitionPrice__c;
                    oitem.SAWO_NoDiscountFlg__c = q.COWO_NoDiscountFlg__c;
                    oitem.SAWO_DiscountPrice__c = q.COWO_DiscountPrice__c;
                    oitem.Tekiyo__c = q.COWO_Description__c;
                    upsertOliList.add(oitem);
                }else{
                    for(OpportunityLineItem updOitem : o){
                        if(updOitem.SAWO_ItemNumber__c == q.COWO_ItemNumber__c){
                            if(updOitem.SAWO_ProductCode__c == q.COWO_ProductCode__c){
                                OpportunityLineItem updOli = new OpportunityLineItem();
                                updOli.Id = updOitem.Id;
                                updOli.Quantity = q.Quantity;
                                updOli.UnitPrice = q.UnitPrice;
                                //updOli.SAWO_Rate__c = q.COWO_Rate__c;
                                updOli.SAWO_LocalCorporationTC__c = q.COWO_LocalCorporationTC__c;
                                updOli.SAWO_FrontPurchasePrice__c = q.COWO_FrontPurchasePrice__c;
                                //updOli.SAWO_HHTWholesalePrice__c = q.COWO_HHTWholesalePrice__c;
                                updOli.TC__c = q.COWO_TC__c;
                                updOli.MC__c = q.COWO_MC__c;
                                updOli.ProductName__c = q.COWO_Product_Name__c;
                                updOli.SAWO_ProductName__c = q.COWO_Product_Name__c;
                                updOli.SAWO_Price__c = q.COWO_DiscountUnitPrice__c;
                                //updOli.SAWO_TotalPrice__c = q.COWO_TotalPrice__c;
                                updOli.SAWO_SortNo__c = q.COWO_SortNo__c;
                                updOli.SAWO_Parts_No__c = q.COWO_PartsNo__c;
                                updOli.SAWO_S4LinkagePrice__c = q.COWO_TotalPrice__c;//S/4連携金額
                                updOli.SAWO_ProductCode__c = q.COWO_ProductCode__c;//商品コード
                                updOli.SAWO_QuantityUnit__c = q.COWO_QuantityUnit__c;
                                updOli.SAWO_DetailCategory__c = q.COWO_DetailCategory__c;
                                updOli.SAWO_DetailCategory_MTE__c = q.COWO_DetailCategory_MTE__c;
                                updOli.SAWO_RejectionReason__c = q.COWO_RejectionReason__c;
                                updOli.SAWO_PlantCode__c = q.COWO_PlantCode__c;
                                updOli.SAWO_PlantCode_MTE__c = q.COWO_PlantCode_MTE__c;
                                updOli.SAWO_StorageLocation__c = q.COWO_StorageLocation__c;
                                updOli.SAWO_StorageLocation_MTE__c  = q.COWO_StorageLocation_MTE__c;
                                updOli.SAWO_Currency__c = q.COWO_Currency__c;
                                updOli.SAWO_Recording_Division__c = q.COWO_Recording_Division__c;
                                updOli.SAWO_ProfitCenter__c = q.COWO_ProfitCenter__c;
                                updOli.SAWO_MaterialGroup1__c = q.COWO_MaterialGroup1__c;
                                updOli.SAWO_ItemNumber__c = q.COWO_ItemNumber__c;
                                updOli.SAWO_ItemText__c = q.COWO_ItemText__c;
                                //updOli.SAWO_WBSElement__c = q.COWO_WBSElement__c;
                                updOli.SAWO_MaterialAvailDate__c = q.COWO_MaterialAvailDate__c;
                                updOli.SAWO_DeliverySchedule__c = q.COWO_DeliverySchedule__c; 
                                updOli.SAWO_SalesNoteCustome__c = q.COWO_SalesNoteCustome__c;
                                updOli.SAWO_ShippingInstructions__c = q.COWO_ShippingInstructions__c;
                                updOli.SAWO_SalesUnit__c = q.COWO_SalesUnit__c;
                                updOli.SAWO_PartitionPrice__c = q.COWO_PartitionPrice__c;
                                updOli.SAWO_NoDiscountFlg__c = q.COWO_NoDiscountFlg__c;
                                updOli.Tekiyo__c = q.COWO_Description__c;
                                upsertOliList.add(updOli);
                            }else{
                                throw new CustomException(system.label.COWO_MSG_ProductCodeErr);
                            }
                            
                        }
                    }
                }
            }

            //insert insertOliList;
            //update updateOliList;
            upsert upsertOliList;
            system.debug('★★★商談商品作成処理終了');


            //見積の御値引き後合計金額を商談の提案金額に反映。

            Quote quo = [SELECT Id
                               ,COWO_Tax_Rate__c
                               ,COWO_Final_Amount__c
                               ,COWO_Final_Amount_Tax_Included__c
                               ,COWO_Discount_Amount__c
                               ,QuoteNumber
                               ,COWO_Payment_Terms__c
                               ,COWO_Transaction_Terms_Import_Export__c
                               ,COWO_Install_Adjust_Cost__c
                               ,COWO_Transport_Cost__c
                               ,COWO_Sales_Desired_Delivery_Date__c
                               ,COWO_Scheduled_Shipping_Date__c
                               ,SubTotal
                               ,Consumption_Tax__c
                               ,COWO_Total_Tax__c
                               ,COWO_Total_MC__c
                               ,COWO_Total_TC__c
                               ,COWO_Total_FrontPurchasePrice__c
                               ,COWO_Total_LocalCorporationTC__c
                               ,COWO_Total_Profit__c
                               ,COWO_Profit_Rate__c
                               ,COWO_HHT_Total_Profit__c
                               ,COWO_HHT_Profit_Rate__c
                               ,COWO_Gross_Profit_Rate__c
                               ,COWO_Gross_Profit__c
                               ,COWO_LocalCorporationTC_Total_Profit__c
                               ,COWO_LocalCorporationTC_Profit_Rate__c
                         FROM Quote 
                         WHERE id =:qid
                        ];  //★★★要修正　項目

            Opportunity opp = new Opportunity();
            system.debug('★★★商談更新処理開始');

            opp.Id = quote.OpportunityId;
            // opp.SAWO_Discount_Price__c = quo.COWO_Discount_Amount__c;
            opp.SAWO_Consumption_Tax__c = quo.COWO_Tax_Rate__c;
            //opp.SAWO_Install_Adjust_Cost__c = quo.COWO_Install_Adjust_Cost__c;
            //opp.SAWO_Transport_Cost__c = quo.COWO_Transport_Cost__c;
            //opp.SAWO_Sales_Desired_Delivery_Date__c = quo.COWO_Sales_Desired_Delivery_Date__c;
            //opp.SAWO_Shipping_ExpectedDate__c = quo.COWO_Scheduled_Shipping_Date__c;
            //opp.EstimatedAmount__c = quo.COWO_Final_Amount__c;
            // opp.SAWO_SubTotal__c = quo.SubTotal;
            // opp.SAWO_Final_Price__c = quo.COWO_Final_Amount__c;
            opp.SAWO_Consumption_Tax__c	 = quo.Consumption_Tax__c;
            // opp.SAWO_MC_Amount__c = quo.COWO_Total_MC__c;
            // opp.SAWO_TC_Amount__c = quo.COWO_Total_TC__c;
            // opp.SAWO_Front_Purchase_Amount__c = quo.COWO_Total_FrontPurchasePrice__c;
            // opp.SAWO_Currentlaw_TC_Amount__c = quo.COWO_Total_LocalCorporationTC__c;
            // opp.SAWO_Benefit_Hsl_Amount__c = quo.COWO_Total_Profit__c;
            // opp.SAWO_Benefit_Hsl_Rate__c = quo.COWO_Profit_Rate__c;
            // opp.SAWO_HHT_Benefit__c = quo.COWO_HHT_Total_Profit__c;
            // opp.SAWO_HHT_Benefit_Rate__c = quo.COWO_HHT_Profit_Rate__c;
            // opp.SAWO_Gross_Profit_Rate__c = quo.COWO_Gross_Profit_Rate__c;
            // opp.SAWO_Gross_Profit__c = quo.COWO_Gross_Profit__c;
            opp.SAWO_MainQuote__c = quo.Id;
            // opp.SAWO_LocalCorporationTC_Total_Profit__c = quo.COWO_LocalCorporationTC_Total_Profit__c;
            // opp.SAWO_LocalCorporationTC_Profit_Rate__c = quo.COWO_LocalCorporationTC_Profit_Rate__c;
            
            update opp;
            system.debug('★★★商談更新処理終了');

            return 'success';
        }catch(Exception e){
            Database.rollback(sp);
            system.debug('e.getMessage()' + e.getMessage());
            return null;
        }
    }

    /**
    * カスタムエクセプションクラス
    */
    public class CustomException extends Exception {
    }
}