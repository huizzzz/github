/********************************************************************************
 * クラス名 ： QuoteHandler
 * 概　　要 ： 見積(標準オブジェクト)トリガハンドラークラス
 * 作 成 日 ： 2020/01/21 MAMADA
 * 更 新 日 ：
 ********************************************************************************/
global class QuoteHandler {
    
    public QuoteHandler() {}
    
   /*
    * 見積作成時商談項目コピー処理
    * @param List<T_Quote__c> newObjects newTriggerの値
    */
    public void convOpportunityToQuote(List<Quote> newObjects) {

        COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // 見積のレコードタイプ取得
        Id quoteType = comTypeManager.getRecordTypeId( 'Quote', 'COWO_DX_Quote' );
        
        // 作成対象の見積に対応する商談のIDを格納する
        List<String> opportunityIdList = new List<String>();
        
        for(Quote quote : newObjects) {
            opportunityIdList.add(quote.OpportunityId);
        }
        
        // 商談の取得
        List<Opportunity> opportunityList = [SELECT Id, // 商談ID
                                                    Account.Name,
                                                    OpportunityNo__c, // 商談番号
                                                    // SAWO_SubTotal__c, // 小計
                                                    // SAWO_Final_Price__c, // 最終金額
                                                    SAWO_Discount_Price__c, // 値引金額
                                                    SAWO_Consumption_Tax__c, // 消費税率
                                                    // SAWO_MC_Amount__c, // MC合計
                                                    // SAWO_TC_Amount__c, // TC合計
                                                    // SAWO_Front_Purchase_Amount__c, // フロント仕入価格合計
                                                    // SAWO_Benefit_Hsl_Amount__c, // 利益合計
                                                    // SAWO_Benefit_Hsl_Rate__c, // 利益率
                                                    // SAWO_HHT_Benefit__c, // HHT利益
                                                    // SAWO_HHT_Benefit_Rate__c, // HHT利益率
                                                    // SAWO_Gross_Profit__c, // 粗利益
                                                    // SAWO_Gross_Profit_Rate__c, // 粗利益率
                                                    // SAWO_Currentlaw_TC_Amount__c, // 現法TC合計
                                                    SAWO_Install_Adjust_Cost__c, // 据付調整費
                                                    SAWO_Transport_Cost__c, // 運送費
                                                    SAWO_Shipping_ExpectedDate__c, // 出荷予定日
                                                    AccountId, // 取引先名
                                                    CurrencyIsoCode, // 通貨
                                                    SAWO_AdminSystem__c, // 職制
                                                    //SAWO_Incoterms__c, // インコタームズ
                                                    StageName // フェーズ
                                             FROM Opportunity
                                             WHERE Id IN: opportunityIdList];
        
        
        // 見積番号をキーに商談のマップを作成する
        Map<String, Opportunity> opportunityToQuoteMap = new Map<String, Opportunity>();
        // 商談に設定されている職制のリストを作成する
        List<String> adminSystemList = new List<String>();
        
        for(Opportunity opp : opportunityList) {
            adminSystemList.add(opp.SAWO_AdminSystem__c);
            for(Quote quote : newObjects) {
                if(quote.OpportunityId == opp.Id) {
                   opportunityToQuoteMap.put(quote.QuoteNumber, opp);
                }
            }
        }
        
        // 職制を元にカスタム設定「職制別設定」を取得しマップを作成する
        // 職制別の見積書出力情報Map作成(Key_職制、Value_見積書出力情報)
        Map<String, ShokuseiConfig__c> adminSystemMap = new Map<String, ShokuseiConfig__c>();
        List<ShokuseiConfig__c> sList = [SELECT
                                         Name,
                                         FAX__c,
                                         TEL__c,
                                         Kaishamei__c,
                                         ShiharaiJoken__c,
                                         DeliveryLocation__c,
                                         Jusho1__c,
                                         Jusho2__c,
                                         DeliveryDate__c,
                                         QuoteRemarks__c,
                                         Busho1__c,
                                         Busho2__c,
                                         Buchoin__c,
                                         ShiharaiJokenDaigaku__c,
                                         SyachoMei__c,
                                         BuchoMei__c,
                                         DeliveryLocation_daigaku_kankoucho__c,
                                         QuoteRemarks_daigaku_kankoucho__c,
                                         Buin__c,
                                         QuoteExpirationDate__c,
                                         CO_DepartmentSeal_GovtOffice__c,
                                         SAWO_CompanyStamp__c //社印
                                         FROM ShokuseiConfig__c
                                         WHERE Name = :adminSystemList
                                         ];
        
        for(ShokuseiConfig__c s : sList){
            adminSystemMap.put(s.Name, s);
        }
        
        for(Quote quote : newObjects) {
            
            // レコードタイプDX以外の見積は処理を行わない
            if(quote.RecordTypeId != quoteType) {
                continue;
            }
            if(!quote.COWO_CopyFlag__c) {
                quote.COWO_Discount_Amount__c = opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_Discount_Price__c; // 値引金額
                quote.COWO_Tax_Rate__c = opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_Consumption_Tax__c; // 消費税率
                quote.COWO_Install_Adjust_Cost__c = opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_Install_Adjust_Cost__c; // 据付調整費
                quote.COWO_Transport_Cost__c = opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_Transport_Cost__c; // 運送費
                quote.CurrencyIsoCode = opportunityToQuoteMap.get(quote.QuoteNumber).CurrencyIsoCode; // 通貨
                quote.ExpirationDate = Date.today() +30; // 有効期限
                quote.COWO_Scheduled_Shipping_Date__c = opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_Shipping_ExpectedDate__c; // 出荷予定日
                quote.COWO_Address__c = opportunityToQuoteMap.get(quote.QuoteNumber).Account.Name; // 宛名
                //quote.COWO_Incoterms__c = opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_Incoterms__c; // インコタームズ
                quote.COWO_Approval_Status__c = '1'; // 承認ステータス

                // 職制が入力されていた場合
                if( opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c != null ){
                    quote.COWO_Company_Name__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).Kaishamei__c; // 会社名
                    quote.COWO_Report_PaymentTerms__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).ShiharaiJoken__c; // 支払条件
                    quote.COWO_PaymentTerms_Univ_GovtOffice__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).ShiharaiJokenDaigaku__c; // 支払条件 (大学官公庁)
                    quote.COWO_President__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).SyachoMei__c; // 社長名
                    quote.COWO_Delivery_Place__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).DeliveryLocation__c; // 受渡場所
                    quote.COWO_DeliveryPlace_Univ_GovtOffice__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).DeliveryLocation_daigaku_kankoucho__c; // 受渡場所(大学・官公庁用)
                    quote.COWO_Address1__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).Jusho1__c; // 住所1
                    quote.COWO_Address2__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).Jusho2__c; // 住所2
                    quote.COWO_Delivery_Date__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).DeliveryDate__c; // 納期
                    quote.COWO_Report_Remarks__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).QuoteRemarks__c; // 備考
                    quote.COWO_Remarks_Univ_GovtOffice__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).QuoteRemarks_daigaku_kankoucho__c; // 備考（大学・官公庁用）
                    quote.COWO_Department1__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).Busho1__c; // 部署1
                    quote.COWO_Department2__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).Busho2__c; // 部署2
                    quote.COWO_Department_Manager__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).BuchoMei__c; // 部長名
                    quote.Fax = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).FAX__c; // FAX
                    quote.Phone = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).TEL__c; // 電話
                    quote.COWO_QuoteExpirationDate__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).QuoteExpirationDate__c; // 見積有効期限
                    quote.COWO_ManagerSeal__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).Buchoin__c; // 部長印
                    quote.CO_DepartmentSeal_GovtOffice__c =adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).CO_DepartmentSeal_GovtOffice__c; // 官公庁用部印
                    quote.COWO_DepartmentSeal__c =adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).Buin__c; // 部印
                    quote.COWO_CompanyStamp__c = adminSystemMap.get(opportunityToQuoteMap.get(quote.QuoteNumber).SAWO_AdminSystem__c).SAWO_CompanyStamp__c; // 社印
                }
            }
        }

    }
    
    /*
    * 見積作成時商談商品項目コピー処理
    * @param List<T_Quote__c> newObjects newTriggerの値
    */
    public void convOpportunityLineItemToQuoteLineItem(List<Quote> newObjects) {
        
        COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // 見積のレコードタイプ取得
        Id quoteType = comTypeManager.getRecordTypeId( 'Quote', 'COWO_DX_Quote' );

                // 作成対象の見積に対応する商談のIDを格納する
        List<String> opportunityIdList = new List<String>();
        
        for(Quote quote : newObjects) {
            opportunityIdList.add(quote.OpportunityId);
        }
        
        // 商談の取得
        List<Opportunity> opportunityList = [SELECT Id // 商談ID
                                             FROM Opportunity
                                             WHERE Id IN: opportunityIdList];
        
        // 商談商品の取得
        List<OpportunityLineItem> opportunityLineItemList = [SELECT Id,
                                                                    Name,
                                                                    ProductName__c,
                                                                    SAWO_ProductName__c,
                                                                    OpportunityId,
                                                                    //SAWO_PartsNo__c, // P/N
                                                                    SAWO_Parts_No__c, // P/N
                                                                    Quantity, // 数量
                                                                    SAWO_SalesPrice__c, // 販売単価
                                                                    UnitPrice, // 販売価格
                                                                    TotalPrice, // 合計金額
                                                                    SAWO_TaxPercent__c, // 消費税率
                                                                    SAWO_Currency__c, // 通貨
                                                                    SAWO_Rate__c, // 為替レート
                                                                    MC__c, // MC
                                                                    TC__c, // TC
                                                                    SAWO_TotalMC__c, // 総MC
                                                                    SAWO_TotalFrontPurchasePrice__c, // 総フロント仕入価格
                                                                    SAWO_LocalCorporationTC__c, // 現法TC
                                                                    SAWO_TotalLocalCorporationTC__c, // 総現法TC
                                                                    SAWO_FrontPurchasePrice__c, // フロント仕入価格
                                                                    SAWO_HHTWholesalePrice__c, // 仕切価格（HHT）
                                                                    SAWO_SalesStandard__c, // 売上基準
                                                                    Product2Id,
                                                                    Product2.Name, // 商品名
                                                                    Tekiyo__c, // 摘要
                                                                    PricebookEntryId, // 価格表エントリ
                                                                    FreeProductFlag__c, // 自由入力製品
                                                                    SAWO_ListPrice__c, // 希望価格
                                                                    SAWO_TotalPrice__c, // 合計金額
                                                                    SAWO_TaxPrice__c, // 消費税
                                                                    SAWO_Price__c, // 金額
                                                                    SAWO_TotalTC__c, // 総TC
                                                                    SAWO_FrontProfit__c, // 利益（フロント）
                                                                    SAWO_HHTProfit__c, // 利益（HHT）
                                                                    SAWO_Hangings__c, // 諸掛
                                                                    SAWO_S4LinkagePrice__c, // S/4連携金額
                                                                    SAWO_SortNo__c, // 並び順
                                                                    SAWO_ProductCode__c, // 商品コード
                                                                    SAWO_QuantityUnit__c, //基本数量単位
                                                                    SAWO_DetailCategory__c, //明細カテゴリ
                                                                    SAWO_RejectionReason__c, //拒否理由
                                                                    SAWO_PlantCode__c, //プラントSTE
                                                                    SAWO_PlantCode_MTE__c, //プラントMTE
                                                                    SAWO_StorageLocation__c, //保管場所STE
                                                                    SAWO_StorageLocation_MTE__c, //保管場所MTE
                                                                    SAWO_Recording_Division__c, //条件グループ
                                                                    SAWO_ProfitCenter__c, //利益センタSTE
                                                                    SAWO_MaterialGroup1__c, //品目グループ1
                                                                    SAWO_ItemNumber__c, //明細番号
                                                                    SAWO_ItemText__c, //明細テキスト
                                                                    SAWO_WBSElement__c, //WBS要素
                                                                    SAWO_MaterialAvailDate__c, //品目利用可能日
                                                                    SAWO_DeliverySchedule__c, //納入日程日付
                                                                    SAWO_SalesNoteCustome__c,//得意先の販売ノート
                                                                    SAWO_ShippingInstructions__c,//出荷指図
                                                                    SAWO_SalesUnit__c,//販売単位
                                                                    SAWO_PartitionPrice__c,//仕切値
                                                                    SAWO_NoDiscountFlg__c, //値引対象外フラグ
                                                                    CO_ovcSalesOrderNumber__c, //SAP Sales Order Number (STE)
                                                                    CO_SAPSalesOrderNumber_MTE__c, //SAP Sales Order Number (MTE)
                                                                    SAWO_DiscountPrice__c, // 値引金額
                                                                    CurrencyIsoCode // 通貨コード
                                                             FROM OpportunityLineItem
                                                             WHERE OpportunityId IN: opportunityIdList
                                                             ORDER BY CreatedDate DESC];
        
        Map<String, List<OpportunityLineItem>> OpportunityLineItemMap = new Map<String, List<OpportunityLineItem>>();
        
        // 商談レコードIDをキーに商談に紐づく商談商品のマップを作成する
        for(String opportunityId : opportunityIdList) {
            List<OpportunityLineItem> setOpportunityLineItemList = new List<OpportunityLineItem>();
            for(OpportunityLineItem opportunityLineItem : opportunityLineItemList) {
                if(opportunityLineItem.OpportunityId == opportunityId) {
                    setOpportunityLineItemList.add(opportunityLineItem);
                }
            }
            OpportunityLineItemMap.put(opportunityId, setOpportunityLineItemList);
        }
        
        // 見積レコードIDをキーに商談のマップを作成する
        Map<String, Opportunity> opportunityToQuoteMap = new Map<String, Opportunity>();
        for(Opportunity opp : opportunityList) {
            for(Quote quote : newObjects) {
                if(quote.OpportunityId == opp.Id) {
                   opportunityToQuoteMap.put(quote.Id, opp);
                }
            }
        }

        List<QuoteLineItem> insertQuoteLineItemList = new List<QuoteLineItem>();
        List<COWO_QuoteLineItem__c> insertQuoteReportList = new List<COWO_QuoteLineItem__c>();
        for(Quote quote : newObjects) {
            
            if(quote.RecordTypeId != quoteType) {
                continue;
            }
            
            // 見積コピー時には作成処理をスキップする
            if(!quote.COWO_CopyFlag__c) {
                if(!OpportunityLineItemMap.get(opportunityToQuoteMap.get(quote.Id).Id).isEmpty()) {
                    for(OpportunityLineItem opportunityLineItem : OpportunityLineItemMap.get(opportunityToQuoteMap.get(quote.Id).Id)) {
                        // 商談に紐づく商談商品のデータを見積品目にコピーする
                        QuoteLineItem quoteLineItem = new QuoteLineItem();
                        quoteLineItem.QuoteId = quote.Id;
                        quoteLineItem.Product2Id = opportunityLineItem.Product2Id; // 商品
                        quoteLineItem.PricebookEntryId = opportunityLineItem.PricebookEntryId; // 価格表エントリ
                        quoteLineItem.Quantity = opportunityLineItem.Quantity; // 数量
                        // quoteLineItem.UnitPrice = opportunityLineItem.UnitPrice; // 販売価格
                        Decimal salesPrice = 0;
                        if(opportunitylineitem.SAWO_SalesPrice__c != null){
                            salesPrice = opportunitylineitem.SAWO_SalesPrice__c;
                        }
                        quoteLineItem.UnitPrice = salesPrice; // 販売価格
                        quoteLineItem.COWO_Currency__c = opportunityLineItem.SAWO_Currency__c; // 通貨
                        quoteLineItem.COWO_Rate__c = opportunityLineItem.SAWO_Rate__c; // 為替レート
                        quoteLineItem.COWO_TotalMC__c = opportunityLineItem.SAWO_TotalMC__c; // 総MC
                        quoteLineItem.COWO_TotalFrontPurchasePrice__c = opportunityLineItem.SAWO_TotalFrontPurchasePrice__c; // 総フロント仕入価格
                        quoteLineItem.COWO_LocalCorporationTC__c = opportunityLineItem.SAWO_LocalCorporationTC__c; // 現法TC
                        quoteLineItem.COWO_TotalLocalCorporationTC__c = opportunityLineItem.SAWO_TotalLocalCorporationTC__c; // 総現法TC
                        quoteLineItem.COWO_FrontPurchasePrice__c = opportunityLineItem.SAWO_FrontPurchasePrice__c; // フロント仕入価格
                        quoteLineItem.COWO_HHTWholesalePrice__c = opportunityLineItem.SAWO_HHTWholesalePrice__c; // 仕切価格（HHT）
                        quoteLineItem.COWO_TC__c = opportunityLineItem.TC__c; // TC
                        quoteLineItem.COWO_MC__c = opportunityLineItem.MC__c;// MC
                        quoteLineItem.COWO_PartsNo__c = opportunityLineItem.SAWO_Parts_No__c; // P/N
                        quoteLineItem.COWO_ProductCode__c = opportunityLineItem.SAWO_ProductCode__c; // 商品コード
                        Decimal discountPrice = 0;
                        if(opportunityLineItem.SAWO_DiscountPrice__c != null) {
                            discountPrice = opportunityLineItem.SAWO_DiscountPrice__c;
                        }
                        quotelineitem.COWO_DiscountPrice__c = discountPrice;
                        if(opportunityLineItem.SAWO_ListPrice__c == null) {
                            quoteLineItem.COWO_ListPrice__c = 0;
                        } else {
                            quoteLineItem.COWO_ListPrice__c = opportunityLineItem.SAWO_ListPrice__c;    // 希望価格
                        }
                        quoteLineItem.COWO_SalesPrice__c = opportunityLineItem.SAWO_SalesPrice__c; // 販売単価
                        quoteLineItem.COWO_TotalPrice__c = opportunityLineItem.SAWO_TotalPrice__c; // 合計金額
                        quoteLineItem.COWO_TaxPrice__c = opportunityLineItem.SAWO_TaxPrice__c; // 消費税
                        quoteLineItem.COWO_Price__c = opportunityLineItem.SAWO_Price__c; // 金額
                        quoteLineItem.COWO_TotalTC__c = opportunityLineItem.SAWO_TotalTC__c; // 総TC
                        quoteLineItem.COWO_FrontProfit__c = opportunityLineItem.SAWO_FrontProfit__c; // 利益（フロント）
                        quoteLineItem.COWO_HHTProfit__c = opportunityLineItem.SAWO_HHTProfit__c; // 利益（HHT）
                        quoteLineItem.COWO_Hangings__c = opportunityLineItem.SAWO_Hangings__c; // 諸掛
                        quoteLineItem.COWO_S4LinkagePrice__c = opportunityLineItem.SAWO_S4LinkagePrice__c; // S/4連携金額
                        // 自由入力製品の場合は名称を設定
                        if(opportunityLineItem.FreeProductFlag__c) {
                            quoteLineItem.COWO_Product_Name__c = opportunityLineItem.ProductName__c; // 製品名
                        } else {
                            quoteLineItem.COWO_Product_Name__c = opportunityLineItem.SAWO_ProductName__c; // 品名
                        }
                        quoteLineItem.COWO_SortNo__c = opportunityLineItem.SAWO_SortNo__c; // 並び順
                        quotelineitem.COWO_QuantityUnit__c = opportunitylineitem.SAWO_QuantityUnit__c;
                        quotelineitem.COWO_DetailCategory__c = opportunitylineitem.SAWO_DetailCategory__c;
                        quotelineitem.COWO_RejectionReason__c = opportunitylineitem.SAWO_RejectionReason__c;
                        quotelineitem.COWO_PlantCode__c = opportunitylineitem.SAWO_PlantCode__c;
                        quotelineitem.COWO_PlantCode_MTE__c = opportunitylineitem.SAWO_PlantCode_MTE__c;
                        quotelineitem.COWO_StorageLocation__c = opportunitylineitem.SAWO_StorageLocation__c;
                        quotelineitem.COWO_StorageLocation_MTE__c  = opportunitylineitem.SAWO_StorageLocation_MTE__c;
                        quotelineitem.COWO_Recording_Division__c = opportunitylineitem.SAWO_Recording_Division__c;
                        quotelineitem.COWO_ProfitCenter__c = opportunitylineitem.SAWO_ProfitCenter__c;
                        quotelineitem.COWO_MaterialGroup1__c = opportunitylineitem.SAWO_MaterialGroup1__c;
                        quotelineitem.COWO_ItemNumber__c = opportunitylineitem.SAWO_ItemNumber__c;
                        quotelineitem.COWO_ItemText__c = opportunitylineitem.SAWO_ItemText__c;
                        //quotelineitem.COWO_WBSElement__c = opportunitylineitem.SAWO_WBSElement__c;
                        quotelineitem.COWO_MaterialAvailDate__c = opportunitylineitem.SAWO_MaterialAvailDate__c;
                        quotelineitem.COWO_DeliverySchedule__c = opportunitylineitem.SAWO_DeliverySchedule__c;
                        quotelineitem.COWO_SalesNoteCustome__c = opportunitylineitem.SAWO_SalesNoteCustome__c;
                        quotelineitem.COWO_ShippingInstructions__c = opportunitylineitem.SAWO_ShippingInstructions__c;
                        quotelineitem.COWO_SalesUnit__c = opportunitylineitem.SAWO_SalesUnit__c;
                        quotelineitem.COWO_PartitionPrice__c = opportunitylineitem.SAWO_PartitionPrice__c;
                        quotelineitem.COWO_NoDiscountFlg__c = opportunitylineitem.SAWO_NoDiscountFlg__c;
                        quotelineitem.CO_ovcSalesOrderNumber__c = opportunitylineitem.CO_ovcSalesOrderNumber__c;
                        quotelineitem.CO_SAPSalesOrderNumber_MTE__c = opportunitylineitem.CO_SAPSalesOrderNumber_MTE__c;
                        quotelineitem.COWO_DiscountUnitPrice__c = salesPrice - discountPrice; // お値引後見積明細単価
                        quotelineitem.COWO_Description__c = opportunityLineItem.Tekiyo__c; // 摘要
                        insertQuoteLineItemList.add(quoteLineItem);
                        
                        COWO_QuoteLineItem__c  quoteReport = new COWO_QuoteLineItem__c();
                        quoteReport.CurrencyIsoCode = opportunityLineItem.CurrencyIsoCode; // 通貨コード
                        quoteReport.COWO_Price__c = opportunityLineItem.SAWO_SalesPrice__c; // 単価
                        quoteReport.COWO_Quote__c = quote.Id; // 見積
                        quoteReport.COWO_SubTotal__c = opportunityLineItem.TotalPrice; // 金額
                        quoteReport.COWO_Quantity__c = String.valueOf(opportunityLineItem.Quantity.intValue()); // 数量
                        quoteReport.COWO_PartsNo__c = opportunityLineItem.SAWO_Parts_No__c; // パーツNo
                        if(opportunityLineItem.SAWO_SalesPrice__c != null && opportunityLineItem.SAWO_DiscountPrice__c != null ){
                            quoteReport.COWO_DiscountUnitPrice__c = opportunityLineItem.SAWO_SalesPrice__c - opportunityLineItem.SAWO_DiscountPrice__c; // お値引後見積明細単価
                        }else{
                            quoteReport.COWO_DiscountUnitPrice__c = 0;
                        }
                        
                        // 自由入力製品の場合は名称を設定
                        if(opportunityLineItem.FreeProductFlag__c) {
                            quoteReport.COWO_ProductName__c = opportunityLineItem.ProductName__c; // 品名
                        } else {
                            quoteReport.COWO_ProductName__c = opportunityLineItem.SAWO_ProductName__c; // 品名
                        }
                        quoteReport.COWO_SortNo__c = opportunityLineItem.SAWO_SortNo__c; // 並び順 
                        quoteReport.COWO_Description__c = opportunityLineItem.Tekiyo__c; // 摘要
                        insertQuoteReportList.add(quoteReport);
                    }
                }
            }
        }
        
        if(insertQuoteLineItemList.size() > 0) {
            insert insertQuoteLineItemList;
            insert insertQuoteReportList;
        }
    }
   /*
    * 見積作成時商談商品項目コピー処理
    * @param List<T_Quote__c> oldObjectsMap oldTriggerの値
    * @param List<T_Quote__c> newObjects newTriggerの値
    */
    public void setQuoteNumbering(Map<Id, Quote> oldObjectsMap, List<Quote> newObjects) {

        List<String> oppIdList = new List<String>();
        for(Quote quote : newObjects) {
            oppIdList.add(quote.OpportunityId);
        }

        List<Opportunity> oppList = [SELECT Id, OpportunityNo__c, SAWO_QuoteNumbering__c FROM Opportunity WHERE Id IN: oppIdList];
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for(Opportunity opp : oppList) {
            oppMap.put(opp.Id, opp);
        }

        List<Opportunity> updateOppList = new List<Opportunity>();
        for(Quote quote : newObjects) {
            // 見積承認ステータスが「承認済」に変更された場合
            System.debug('★★★' + quote.COWO_Approval_Status__c);
            System.debug('★★★' + oldObjectsMap.get(quote.Id).COWO_Approval_Status__c);
            if(quote.COWO_Approval_Status__c == System.Label.COWO_CON_ApprovalStatus
               && oldObjectsMap.get(quote.Id).COWO_Approval_Status__c != System.Label.COWO_CON_ApprovalStatus) {
                if(oppMap.get(quote.OpportunityId).SAWO_QuoteNumbering__c == null) {
                    oppMap.get(quote.OpportunityId).SAWO_QuoteNumbering__c = 0;
                }
                String QuoteNumber = String.valueOf(oppMap.get(quote.OpportunityId).SAWO_QuoteNumbering__c + 1);
                QuoteNumber = QuoteNumber.leftPad(3, '0');
                quote.COWO_QuoteNumber__c = oppMap.get(quote.OpportunityId).OpportunityNo__c + '_' + QuoteNumber;
                oppMap.get(quote.OpportunityId).SAWO_QuoteNumbering__c += 1;
                updateOppList.add(oppMap.get(quote.OpportunityId));
                System.debug('★★★' + quote.COWO_QuoteNumber__c);
            }
        }

        if(updateOppList.size() > 0) {
            update updateOppList;
        }
    }

   /*
    * ㈱を株式会社に変換する
    * @param List<T_Quote__c> oldObjectsMap oldTriggerの値
    * @param List<T_Quote__c> newObjects newTriggerの値
    */
    public void convertAccountName(List<Quote> newObjects) {
        Id RecordTypeDx = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('COWO_DX_Quote').getRecordTypeId();
        UTL_COJP_Utils util = new UTL_COJP_Utils ();
        for(Quote quote : newObjects) {
            List<String> convertList = new List<String>();
            convertList.add(quote.COWO_Address__c);
            if(util.nameConversion(convertList)[0] != null) {
                if(quote.RecordTypeId == RecordTypeDx && !quote.COWO_CopyFlag__c) {
                    quote.COWO_Address__c = leftByte(util.nameConversion(convertList)[0], 79 - getByteSize(SYSTEM.Label.COWO_CON_YOU)) + ' ' + SYSTEM.Label.COWO_CON_YOU;
                } else {
                    quote.COWO_Address__c = leftByte(util.nameConversion(convertList)[0], 80);
                }
            }
        }
    }

   /*
    * 指定するByte数まで、文字列を切り取る
    * @param str 対象文字列
    * @param byteSize 切り取るByteサイズ
    */
    private String leftByte(String str, Integer byteSize) {
        Integer sumSize = 0;
        Integer cutNum = 0;
        // 一文字ずつバイト数をチェックする
        for(Integer i = 0 ; i < str.length(); i++) {
            // 一文字バイト数計算
            Integer oneSize = Blob.valueOf(str.substring(i, (i + 1))).size() == 3 ? 2 : 1;
            if (sumSize + oneSize <= byteSize) {
                sumSize = sumSize + oneSize;
                cutNum = i + 1;
            } else {
                return str.left(cutNum);
            }
        }
        return str.left(cutNum);
    }

   /*
    * 文字列Byte数算出
    * @param str 対象文字列
    */
    private Integer getByteSize(String str) {
        Integer sumSize = 0;
        // 一文字ずつバイト数をチェックする
        for(Integer i = 0 ; i < str.length(); i++) {
            // 一文字バイト数計算
            Integer oneSize = Blob.valueOf(str.substring(i, (i + 1))).size() == 3 ? 2 : 1;
            sumSize = sumSize + oneSize;
        }
        return sumSize;
    }
}