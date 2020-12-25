@isTest
public with sharing class QuoteLineItemBulkEditControllerTest {
    
    public static final String USER_NAME = 'test_user@psn.dummy.com';
    
    /**
     * 初期処理：データ取得
     * 
     */
    static testMethod void unitTest_001() {
        // ユーザ選択
        User user1 = [Select id From User Where Username = 'test_user@psn.dummy.com' Limit 1];
        // 見積選択
        Quote quote = [select Id from Quote limit 1];
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            quote.COWO_Tax_Rate__c = 10;
            update quote;
            // 検索
            String result = QuoteLineItemBulkEditController.getQuoteLineItems(quote.Id);
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            //実施結果確認
            Object checkResult = (Object) JSON.deserializeUntyped(result);
            Map<String,Object> checkResultMap = (Map<String, Object>)checkResult;
            String data = String.valueOf(checkResultMap.get('data'));
            system.debug('data' + data);
            List<String> dataList = data.split('},');
            system.assertEquals(Integer.valueOf(checkResultMap.get('returnCode')), 0);
            system.assertEquals(String.valueOf(checkResultMap.get('returnMsg')), System.Label.COWO_MSG_Search_NormalEnd);
            system.assertEquals(dataList.size(), 5);
        }
    }
    
    /**
     * ＤＢ反映処理：正常終了の場合
     * 
     */
    @isTest static void unitTest_002(){
        
        // ユーザ選択
        User user1 = [Select id From User Where Username = 'test_user@psn.dummy.com' Limit 1];
        // 見積選択
        Quote quote = [Select id From Quote Limit 1 ];
        // 見積品目選択
        QuoteLineItem qi = [select id from QuoteLineItem where quoteId = :quote.Id limit 1];
        // 製品選択
        Product2 prod = [select id from Product2 limit 1];
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            quote.COWO_Tax_Rate__c = 10;
            update quote;
            Boolean NoDiscountFlg = false;
            //テスト対象メソッド実行
            String draftValue = '[{  '+
                '   \"COWO_Product_Name__c\":\"テスト002\",'+
                '   \"Quantity\": \"10000\",'+
                '   \"UnitPrice\":\"20000\",'+
                '   \"COWO_ListPrice__c\": \"30000\",'+
                '   \"COWO_DiscountPrice__c\":\"40000\",'+
                '   \"COWO_TotalPrice__c\":\"50000\",'+
                '   \"COWO_LocalCorporationTC__c\":\"60000\",'+
                '   \"COWO_FrontPurchasePrice__c\":\"70000\",'+
                '   \"COWO_TC__c\":\"80000\",'+
                '   \"COWO_MC__c\":\"90000\",'+
                '   \"COWO_DiscountUnitPrice__c\":\"20000\",'+
                '   \"Subtotal\":\"20000\",'+
                '   \"COWO_SortNo__c\":\"10\",'+
                '   \"COWO_ItemNumber__c\":\"1\",'+
                '   \"COWO_PartsNo__c\":\"testPartsNo\",'+
                '   \"Id\":\"Add' + prod.Id + '\",'+
                '   \"COWO_NoDiscountFlg__c\":false'+
                '}]';
            
            String datas = '[{  '+
                '   \"Id\":\"Add' + prod.Id + '\",'+
                '   \"COWO_Product_Name__c\":\"テスト002\",'+
                '   \"Quantity\": \"20\",'+
                '   \"UnitPrice\": \"200\",'+
                '   \"COWO_ListPrice__c\": \"30000\",'+
                '   \"COWO_DiscountPrice__c\":\"40000\",'+
                '   \"COWO_TotalPrice__c\":\"50000\",'+
                '   \"COWO_LocalCorporationTC__c\":\"60000\",'+
                '   \"COWO_FrontPurchasePrice__c\":\"70000\",'+
                '   \"COWO_TC__c\":\"80000\",'+
                '   \"COWO_MC__c\":\"90000\",'+
                '   \"COWO_DiscountUnitPrice__c\":\"20000\",'+
                '   \"Subtotal\":2345,'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"COWO_SortNo__c\":\"10\",'+
                '   \"COWO_ItemNumber__c\":\"1\",'+
                '   \"COWO_NoDiscountFlg__c\":false'+
                '}]';
            
            //String delData = '[{"attributes":{"type":"QuoteLineItem","url":"/services/data/v49.0/sobjects/QuoteLineItem/"'+qi.Id +'"},"Id":"'+ qi.Id +'"}]';
			String delData = '[]';
            
            String params = '{  '+
                '   \"nebikiKingaku\":\"100\",'+
                '   \"headerNebikiritsu\":\"20\",'+
                '   \"headerNebiki01\":\"2000\",'+
                '   \"syuseiNebiki01\":\"3000\",'+
                '   \"syuseiNebiki02\":\"4000\",'+
                '   \"allQuantity\":\"20\",'+
                '   \"allUnitprice\":\"200\",'+
                '   \"allTotalprice\":\"4000\",'+
                '   \"zeikomiCheck\":true,'+
                '   \"ishikiCheck\":true,'+
                '   \"saisyuKingaku\":\"40000\",'+
                '   \"shokei\":\"50000\",'+
                '   \"fertilityDiscountTitle1\":\"出精値引1\",'+
                '   \"fertilityDiscountTitle2\":\"出精値引2\"'+
                '}';
            
            String result = QuoteLineItemBulkEditController.reflectEditedData(quote.Id,draftValue,delData,datas,params,0,true,false);
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            //実施結果確認
            //resultCheck(result,isUpdatePrice);
            //実施結果確認
            //resultCheck(result,isUpdatePrice);
            quote = [select COWO_Discount_Amount__c,COWO_Header_Discount_Rate__c,COWO_Header_Discount_Amount__c,COWO_Fertility_Discount1__c,
                    COWO_Fertility_Discount2__c,COWO_Report_Item_Flag__c from quote limit 1];
            List<COWO_QuoteLineItem__c> cowoQIList = [select id,CurrencyIsoCode,COWO_ProductName__c,COWO_Price__c,COWO_SubTotal__c,COWO_Quantity__c from COWO_QuoteLineItem__c where COWO_Quote__c = :quote.Id]; 
            List<QuoteLineItem> QIList = [select Id, CurrencyIsoCode, COWO_Product_Name__c, Quantity, COWO_ListPrice__c, 
                                                     UnitPrice, Subtotal, COWO_DiscountPrice__c, COWO_TotalPrice__c, COWO_TotalLocalCorporationTC__c, 
                                                     COWO_TotalFrontPurchasePrice__c,COWO_TotalTC__c,COWO_TotalMC__c
                                                     from QuoteLineItem where COWO_Product_Name__c = 'テスト002'];
            system.assertEquals(quote.COWO_Discount_Amount__c, 100);
            system.assertEquals(quote.COWO_Header_Discount_Rate__c, 20);
            system.assertEquals(quote.COWO_Header_Discount_Amount__c, 2000);
            system.assertEquals(quote.COWO_Fertility_Discount1__c, 3000);
            system.assertEquals(quote.COWO_Fertility_Discount2__c, 4000);
            system.assertEquals(quote.COWO_Report_Item_Flag__c, true);
            system.assertEquals(cowoQIList.size(), 1);
            system.assertEquals(cowoQIList[0].COWO_ProductName__c,'一式');
            system.assertEquals(cowoQIList[0].COWO_Price__c,QIList[0].UnitPrice);
            system.assertEquals(cowoQIList[0].COWO_SubTotal__c,QIList[0].Subtotal);
            system.assertEquals(cowoQIList[0].COWO_Quantity__c,'1');
            system.assertEquals(cowoQIList[0].CurrencyIsoCode ,'JPY');
            system.assertEquals(QIList[0].Quantity,20);
        }
        
    }
    
    /**
     * ＤＢ反映処理：正常終了の場合
     * 
     */
    @isTest static void unitTest_003(){
        
        // ユーザ選択
        User user1 = [Select id From User Where Username = 'test_user@psn.dummy.com' Limit 1];
        // 見積選択
        Quote quote = [Select id From Quote Limit 1 ];
        // 見積品目選択
        QuoteLineItem qi = [select id from QuoteLineItem where quoteId = :quote.Id limit 1];
        // 製品選択
        Product2 prod = [select id from Product2 limit 1];
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            quote.COWO_Tax_Rate__c = 10;
            update quote;
            //テスト対象メソッド実行
            String draftValue = '[{  '+
                '   \"COWO_Product_Name__c\":\"テスト003\",'+
                '   \"Quantity\": \"20\",'+
                '   \"UnitPrice\":\"200\",'+
                '   \"COWO_ListPrice__c\": \"159\",'+
                '   \"COWO_DiscountPrice__c\":\"200\",'+
                '   \"COWO_ListPrice__c\": \"30000\",'+
                '   \"COWO_DiscountPrice__c\":\"40000\",'+
                '   \"COWO_TotalPrice__c\":\"50000\",'+
                '   \"COWO_LocalCorporationTC__c\":\"60000\",'+
                '   \"COWO_FrontPurchasePrice__c\":\"70000\",'+
                '   \"COWO_TC__c\":\"80000\",'+
                '   \"COWO_MC__c\":\"90000\",'+
                '   \"COWO_DiscountUnitPrice__c\":\"20000\",'+
                '   \"Subtotal\":\"20000\",'+
                '   \"COWO_SortNo__c\":\"10\",'+
                '   \"COWO_ItemNumber__c\":\"1\",'+
                '   \"COWO_NoDiscountFlg__c\":false,'+
                '   \"Id\":\"New' + prod.Id + '\"'+
                '}]';
            
            String datas = '[{  '+
                '   \"Id\":\"New' + prod.Id + '\",'+
                '   \"COWO_Product_Name__c\":\"テスト003\",'+
                '   \"Quantity\": \"20\",'+
                '   \"UnitPrice\": \"200\",'+
                '   \"COWO_ListPrice__c\": \"30000\",'+
                '   \"COWO_DiscountPrice__c\":\"40000\",'+
                '   \"COWO_TotalPrice__c\":\"50000\",'+
                '   \"COWO_LocalCorporationTC__c\":\"60000\",'+
                '   \"COWO_FrontPurchasePrice__c\":\"70000\",'+
                '   \"COWO_TC__c\":\"80000\",'+
                '   \"COWO_MC__c\":\"90000\",'+
                '   \"COWO_DiscountUnitPrice__c\":\"20000\",'+
                '   \"Subtotal\":2345,'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"COWO_SortNo__c\":\"10\",'+
                '   \"COWO_ItemNumber__c\":\"1\",'+
                '   \"COWO_NoDiscountFlg__c\":false,'+
                '   \"trendIcon\":\"utility:warning\"'+
                '}]';
            
            String delData = '[]';
            
            String params = '{  '+
                '   \"nebikiKingaku\":\"100\",'+
                '   \"headerNebikiritsu\":\"20\",'+
                '   \"headerNebiki01\":\"2000\",'+
                '   \"syuseiNebiki01\":\"3000\",'+
                '   \"syuseiNebiki02\":\"4000\",'+
                '   \"allQuantity\":\"20\",'+
                '   \"allUnitprice\":\"200\",'+
                '   \"allTotalprice\":\"4000\",'+
                '   \"zeikomiCheck\":false,'+
                '   \"ishikiCheck\":false,'+
                '   \"saisyuKingaku\":\"40000\",'+
                '   \"shokei\":\"50000\",'+
                '   \"fertilityDiscountTitle1\":\"出精値引1\",'+
                '   \"fertilityDiscountTitle2\":\"出精値引2\"'+                
                '}';
            
            String result = QuoteLineItemBulkEditController.reflectEditedData(quote.Id,draftValue,delData,datas,params,0,true,false);
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            //実施結果確認
            //resultCheck(result,isUpdatePrice);
            quote = [select COWO_Discount_Amount__c,COWO_Header_Discount_Rate__c,COWO_Header_Discount_Amount__c,COWO_Fertility_Discount1__c,
                    COWO_Fertility_Discount2__c,COWO_Report_Item_Flag__c from quote limit 1];
            List<COWO_QuoteLineItem__c> cowoQIList = [select id,CurrencyIsoCode,COWO_ProductName__c,COWO_Price__c,COWO_SubTotal__c,COWO_Quantity__c from COWO_QuoteLineItem__c where COWO_Quote__c = :quote.Id]; 
            List<QuoteLineItem> QIList = [select Id, CurrencyIsoCode, COWO_Product_Name__c, Quantity, COWO_ListPrice__c, 
                                                     UnitPrice, Subtotal, COWO_DiscountPrice__c, COWO_TotalPrice__c, COWO_TotalLocalCorporationTC__c, 
                                                     COWO_TotalFrontPurchasePrice__c,COWO_TotalTC__c,COWO_TotalMC__c
                                                     from QuoteLineItem where COWO_Product_Name__c = 'テスト003'];
            system.assertEquals(quote.COWO_Discount_Amount__c, 100);
            system.assertEquals(quote.COWO_Header_Discount_Rate__c, 20);
            system.assertEquals(quote.COWO_Header_Discount_Amount__c, 2000);
            system.assertEquals(quote.COWO_Fertility_Discount1__c, 3000);
            system.assertEquals(quote.COWO_Fertility_Discount2__c, 4000);
            system.assertEquals(quote.COWO_Report_Item_Flag__c, false);
            system.assertEquals(cowoQIList.size(), 1);
            system.assertEquals(cowoQIList[0].COWO_ProductName__c,QIList[0].COWO_Product_Name__c);
            system.assertEquals(cowoQIList[0].COWO_Price__c,QIList[0].UnitPrice);
            //system.assertEquals(cowoQIList[0].COWO_SubTotal__c,QIList[0].COWO_TotalPrice__c);
            //system.assertEquals(cowoQIList[0].COWO_Quantity__c,'20');
            //system.assertEquals(cowoQIList[0].CurrencyIsoCode ,'JPY');
            //system.assertEquals(QIList[0].Quantity,20);
        }
        
    }
    
    /**
     * ＤＢ反映処理：正常終了の場合
     * 
     */
    @isTest static void unitTest_004(){
        
        // ユーザ選択
        User user1 = [Select id From User Where Username = 'test_user@psn.dummy.com' Limit 1];
        // 見積選択
        Quote quote = [Select id From Quote Limit 1 ];
        // 見積品目選択
        QuoteLineItem qi = [select id from QuoteLineItem where quoteId = :quote.Id limit 1];
        // 製品選択
        Product2 prod = [select id from Product2 limit 1];
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            //テスト対象メソッド実行
            String draftValue = '[{  '+
                '   \"COWO_Product_Name__c\":\"テスト004\",'+
                '   \"Quantity\": \"20\",'+
                '   \"UnitPrice\":\"200\",'+
                '   \"COWO_ListPrice__c\": \"159\",'+
                '   \"COWO_DiscountPrice__c\":\"200\",'+
                '   \"COWO_TotalPrice__c\":\"200\",'+
                '   \"COWO_TotalLocalCorporationTC__c\":\"200\",'+
                '   \"COWO_TotalFrontPurchasePrice__c\":\"200\",'+
                '   \"COWO_TotalTC__c\":\"200\",'+
                '   \"COWO_TotalMC__c\":\"200\",'+
                '   \"Subtotal\":\"200\",'+
                '   \"COWO_ItemNumber__c\":\"1\",'+         
                '   \"COWO_NoDiscountFlg__c\":false,'+
                '   \"Id\":\"Add' + prod.Id + '\"'+
                '}]';
            
            String datas = '[{  '+
                '   \"Id\":\"Add' + prod.Id + '\",'+
                '   \"COWO_Product_Name__c\":\"テスト004\",'+
                '   \"Quantity\": \"1\",'+
                '   \"UnitPrice\": \"200\",'+
                '   \"COWO_ListPrice__c\":\"159\",'+
                '   \"COWO_DiscountPrice__c\":\"200\",'+
                '   \"COWO_TotalPrice__c\":200,'+
                '   \"COWO_TotalLocalCorporationTC__c\":\"200\",'+
                '   \"COWO_TotalFrontPurchasePrice__c\":\"200\",'+
                '   \"COWO_TotalTC__c\":\"200\",'+
                '   \"COWO_TotalMC__c\":\"200\",'+
                '   \"Subtotal\":2345,'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"COWO_ItemNumber__c\":\"1\",'+
                '   \"COWO_NoDiscountFlg__c\":false,'+
                '   \"trendIcon\":\"utility:warning\"'+
                '}]';
            
            String delData = '[]';
            
            String params = '{  '+
                '   \"nebikiKingaku\":\"100\",'+
                '   \"headerNebikiritsu\":\"20\",'+
                '   \"headerNebiki01\":\"2000\",'+
                '   \"syuseiNebiki01\":\"3000\",'+
                '   \"syuseiNebiki02\":\"4000\",'+
                '   \"allQuantity\":\"20\",'+
                '   \"allUnitprice\":\"200\",'+
                '   \"allTotalprice\":\"4000\",'+
                '   \"zeikomiCheck\":true,'+
                '   \"ishikiCheck\":false,'+
                '   \"saisyuKingaku\":\"40000\",'+
                '   \"shokei\":\"50000\",'+
                '   \"fertilityDiscountTitle1\":\"出精値引1\",'+
                '   \"fertilityDiscountTitle2\":\"出精値引2\"'+     
                '}';
            
            String result = QuoteLineItemBulkEditController.reflectEditedData(quote.Id,draftValue,delData,datas,params,0,false,true);
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            //実施結果確認
            //resultCheck(result,isUpdatePrice);
            
        }
        
    }
    
    
    
    /**
     * ＤＢ反映処理：異常終了の場合
     * 
     */
    @isTest static void unitTest_005(){
        
        // ユーザ選択
        User user1 = [Select id From User Where Username = 'test_user@psn.dummy.com' Limit 1];
        // 見積選択
        Quote quote = [Select id From Quote Limit 1 ];
        // 見積品目選択
        QuoteLineItem qi = [select id from QuoteLineItem where quoteId = :quote.Id limit 1];
        // 製品選択
        Product2 prod = [select id from Product2 limit 1];
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            //テスト対象メソッド実行
            String draftValue = '';
            
            String datas = '';
            
            String delData = '';
            
            String params = '';
            
            String result = QuoteLineItemBulkEditController.reflectEditedData(quote.Id,draftValue,delData,datas,params,0,false,false);
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            //実施結果確認
            //resultCheck(result,isUpdatePrice);
            
        }
        
    }

    /**************************************************************************
       テストデータ作成関連
     **************************************************************************/
    /**************************************************************************
       プロファイル名
     **************************************************************************/
    /** システム管理者 */
    public static final String PROFILENAME_ADMIN                    {get{return 'システム管理者';}}

    /**
     * テストデータ作成
     * 
     */
    @testSetup static void dataCreate() {
        // ユーザ作成
        User user = createUser(PROFILENAME_ADMIN);
        insert user;

        // 商品作成
        List<Product2> product2List = CreateProduct2(5);
        insert product2List;

        //価格表エントリ
        List<PricebookEntry> pbeList = CreatePricebookEntry(product2List);
        insert pbeList;
        
        // 自由入力商品
        Product2 freeProd = CreateFreeProduct2();
        insert freeProd;
        
        // 自由入力商品価格エントリー        
        PricebookEntry freePBE = CreateFreePBE(freeProd);
        insert freePBE;
        
        SAWO_CurrencyConsumptionTaxConfig__c currencySetting = CreateCurrencySetting();
        insert currencySetting;
        
        System.runAs(user) {
                        
            // 商談
            Opportunity opp = CreateOpportunities();
            insert opp;
            // 見積
            Quote quote = CreateQuote(opp);
            insert quote;
            system.debug('quote'+ quote.COWO_Tax_Rate__c);
            // 見積品目
            List<QuoteLineItem> qiList = CreateQuoteLineItem(quote,pbeList);
            insert qiList;
            
            system.debug('qiList' + qiList.size());
            // 見積明細
            List<COWO_QuoteLineItem__c> cowoQuoteList= CreateCOWO_QuoteLineItem(quote);
            insert cowoQuoteList;
        }
    }
    
    /**
     * 商品作成
     *
     * @param 作成件数
     * @return 取引先
     */
    public static SAWO_CurrencyConsumptionTaxConfig__c CreateCurrencySetting() {
        return new SAWO_CurrencyConsumptionTaxConfig__c(SAWO_Consumption_Tax__c = 10,name = 'JPY');
    }

    /**
     * 商品作成
     *
     * @param 作成件数
     * @return 取引先
     */
    public static List<Product2> CreateProduct2(Integer count) {
        List<Product2> product2List = new List<Product2>();
        for(Integer i = 0; i < count; i++){
            Product2 a = new Product2();
            a.Name = '商品名' + i;
            a.CountryMode__c = 'CountryMode' + i;
            product2List.add(a);
        }
        return product2List;
    }
    
    /**
     * 自由入力製品作成
     *
     * @param 作成件数
     * @return 商品
     */
    public static Product2 CreateFreeProduct2() {
        return new Product2(Name = '自由入力製品',CountryMode__c = '000');
    }
    
    /**
     * 自由入力製品価格エントリー作成
     *
     * @param 商品
     * @return 価格エントリー
     */
    public static PricebookEntry CreateFreePBE(Product2 p) {
        return new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                  Product2Id = p.Id,
                                  CurrencyIsoCode = 'JPY',
                                  UnitPrice = 2000,
                                  COWO_FrontPurchasePrice__c = 1300,
                                  COWO_LocalCorporationTC__c = 1200,
                                  COWO_MC__c = 1000,
                                  COWO_TC__c = 1100,
                                  IsActive = true);
    }
    
    /**
     * 価格表エントリ
     * 
     * @param productList 商品
     * @return 価格表エントリ
     */
    public static List<PricebookEntry> CreatePricebookEntry(List<Product2> productList){
        // 標準価格表を取得
        Id pricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> standardPriceList = new List<PricebookEntry>();
        // 標準価格表に自由入力製品を追加.
        Integer i = 0;
        for(Product2 pro : productList){
            PricebookEntry pb = new PricebookEntry();
            pb.Pricebook2Id = pricebookId;
            pb.Product2Id   = pro.Id;
            pb.IsActive = true;
            pb.CurrencyIsoCode = 'JPY';
            
            pb.UnitPrice = 2000 + i;
            pb.COWO_FrontPurchasePrice__c = (decimal)(1300 + i);
            pb.COWO_LocalCorporationTC__c = (decimal)(1200 + i);
            pb.COWO_MC__c = (decimal)(1000 + i);
            pb.COWO_TC__c = (decimal)(1100 + i);                
            
            standardPriceList.add(pb);
            i++;
        }
        return standardPriceList;
    }

    /**
     * 商談
     *
     * @param acc 取引先
     * @return 商談
     */
    public static Opportunity CreateOpportunities() {
        Opportunity testOpp = new Opportunity();
        testOpp.StageName = '00';
        testOpp.Name = 'TEST_COPY_QUOTE001';
        testOpp.Benefit__c = 10000;
        testOpp.BudgetAmount__c = 20000;
        testOpp.closeDate = System.today();
        testOpp.CurrencyIsoCode = 'JPY';
        testOpp.Pricebook2Id = Test.getStandardPricebookId();
        testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId();
        testOpp.SAWO_Consumption_Tax__c = 10;
        return testOpp;
    }
    
    /**
     * 見積
     *
     * @param opp 商談
     * @return 見積
     */
    public static Quote CreateQuote(Opportunity opp) {
        Quote testQ = new Quote();
        testQ.Name = 'test quote';
        testQ.OpportunityId = opp.id;
        testQ.COWO_Tax_Rate__c = 10;
        testQ.COWO_Report_Item_Flag__c = true;
        testQ.COWO_Discount_Amount__c = 100000;
        testQ.COWO_Header_Discount_Rate__c = 15;
        testQ.COWO_Header_Discount_Amount__c = 10000;
        testQ.COWO_Fertility_Discount1__c = 2000;
        testQ.COWO_Fertility_Discount2__c = 3000;
        testQ.CurrencyIsoCode = 'JPY';
        testQ.Pricebook2Id = opp.Pricebook2Id;
        testQ.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('COWO_DX_Quote').getRecordTypeId();
        testQ.COWO_Tax_Rate__c = 10;
        testQ.Consumption_Tax__c = 10;
        return testQ;
    }

    /**
     * 見積品目名
     * 
     * @param quote 見積
     * @param PricebookEntry 価格表エントリ
     * @return 見積品目名
     */
    public static List<QuoteLineItem> CreateQuoteLineItem(Quote quote,List<PricebookEntry> pbeList){
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();

        Integer i = 0;
        for(PricebookEntry pbe : pbeList){
            QuoteLineItem qli = new QuoteLineItem();
            qli.QuoteId = quote.Id;
            qli.PricebookEntryId = pbe.Id;
            qli.Product2Id = pbe.Product2Id;
            qli.Quantity = 10;
            qli.UnitPrice = (decimal)(555 + i);
            qli.COWO_Product_Name__c = 'テスト';
            qli.COWO_DiscountPrice__c = 5000;
            qli.COWO_ListPrice__c = 8000;
            qli.COWO_FrontPurchasePrice__c = (decimal)(111 + i);
            qli.COWO_LocalCorporationTC__c = (decimal)(222 + i);
            qli.COWO_MC__c = (decimal)(333 + i);
            qli.COWO_TC__c = (decimal)(444 + i);
            qli.COWO_TotalLocalCorporationTC__c = 7000;
            qli.COWO_TotalPrice__c = 6000;
            qli.COWO_TotalFrontPurchasePrice__c = 5000;
            qli.COWO_TotalTC__c = 29999;
            qli.COWO_TotalMC__c = 39999;
            qli.COWO_ItemNumber__c = i;
            qli.COWO_NoDiscountFlg__c = false;
            qliList.add(qli);
            i++;
        }        
        
        return qliList;
    }
    
    /**
     * 見積帳票明細
     * 
     * @param quote 見積
     * @return 見積帳票明細
     */
    public static List<COWO_QuoteLineItem__c> CreateCOWO_QuoteLineItem(Quote quote){
        List<COWO_QuoteLineItem__c> qpiList = new List<COWO_QuoteLineItem__c>();
        
        qpiList.add(new COWO_QuoteLineItem__c(COWO_Quote__c = quote.Id,COWO_Price__c = (Decimal)1000,COWO_Quantity__c = '20',COWO_SubTotal__c = (Decimal)3000));
        qpiList.add(new COWO_QuoteLineItem__c(COWO_Quote__c = quote.Id,COWO_Price__c = (Decimal)1001,COWO_Quantity__c = '21',COWO_SubTotal__c = (Decimal)3001));
        
        return qpiList;
    }    

    
    /**************************************************************************
       ユーザ作成関連
     **************************************************************************/
    /**
     * ユーザー作成
     *
     * @param profName プロファイル名
     * @param SystemCoordinationFlg システム連携ユーザフラグ
     * @return ユーザー
     */
    public static User createUser(String profName) {
        Datetime dt = Datetime.now();

        User user = new User();
        user.ProfileId = [select Id from Profile where Name =: profName limit 1].Id;
        user.LastName = 'テスト';
        user.FirstName = 'テスト';
        user.Alias = 'test' + String.valueOf(dt.second());
        user.Email = String.valueOf(dt.second()) + String.valueOf(dt.millisecond()) + '@psn.dummy.com';
        user.Username = USER_NAME;
        user.CommunityNickname = String.valueOf(dt.second()) + String.valueOf(dt.millisecond()) ;
        user.TimeZoneSidKey = 'Asia/Tokyo';
        user.LocaleSidKey = 'ja_JP';
        user.EmailEncodingKey = 'ISO-2022-JP';
        user.LanguageLocaleKey = 'ja';
        user.CurrencyIsoCode = 'JPY';
        return user;
    }
    
     /**************************************************************************
       実行結果確認
     **************************************************************************/

    public static void resultCheck(String result,Boolean isUpdatePrice){
        System.debug('■■■比較開始■■■');
        
        //■実行結果取得
        //見積
        List<Quote> rQuoteList = [select Id,Name,COWO_Customer_Adopted_Quote__c,COWO_Customer_Presented_Quote__c,
                                  COWO_Imprint1__c,COWO_Imprint2__c,COWO_Imprint3__c,Status,COWO_Approval_Status__c, COWO_CopyFlag__c
                                  from Quote where Id = :result Limit 1];
        Quote rQuote = rQuoteList.get(0);            
        //見積品目名
        List<QuoteLineItem> rQliList = 
            [select Id,QuoteId,PricebookEntryId,Product2Id,Quantity,
             COWO_FrontPurchasePrice__c,COWO_LocalCorporationTC__c,COWO_MC__c,COWO_TC__c,
             COWO_TotalFrontPurchasePrice__c,COWO_TotalLocalCorporationTC__c,COWO_TotalMC__c,COWO_TotalTC__c 
             from QuoteLineItem where QuoteId = :result order by COWO_FrontPurchasePrice__c];
        //見積帳票明細
        List<COWO_QuoteLineItem__c> rQpiList = [select Id,COWO_Quote__c,COWO_SubTotal__c,COWO_Price__c,COWO_Quantity__c from COWO_QuoteLineItem__c where COWO_Quote__c = :result order by COWO_Price__c];
            
        //■期待値作成
        //商談
        Opportunity opp = CreateOpportunities();
        insert opp;
        //商品
        List<Product2> productList = CreateProduct2(20);
        insert productList;
        //価格表エントリ
        List<PricebookEntry> pbeList = CreatePricebookEntry(productList); 
        insert pbeList;
        //見積
        Quote quote = CreateQuote(opp);
        insert quote;
        //見積品目名
        List<QuoteLineItem> qliList = CreateQuoteLineItem(quote, pbeList);
        insert qliList;
        //見積帳票明細
        List<COWO_QuoteLineItem__c> qpiList = CreateCOWO_QuoteLineItem(quote);            
        insert qpiList;
        
        //■実施結果比較
        //見積
        System.assertEquals(result,rQuote.Id);
        System.assertEquals(quote.Name,rQuote.Name);
        //コピー前の値がクリアされている事の確認
        System.assertEquals(false,rQuote.COWO_Customer_Adopted_Quote__c);
        System.assertEquals(false,rQuote.COWO_Customer_Presented_Quote__c);
        System.assertEquals(null,rQuote.COWO_Imprint1__c);
        System.assertEquals(null,rQuote.COWO_Imprint2__c);
        System.assertEquals(null,rQuote.COWO_Imprint3__c);
        System.assertEquals(null,rQuote.Status);
        System.assertEquals(null,rQuote.COWO_Approval_Status__c);
        System.assertEquals(True,rQuote.COWO_CopyFlag__c);

        //見積品目名
        Integer qliCount = 0;
        Boolean isFirst = True;
        for(QuoteLineItem qli :qliList){
            QuoteLineItem rQli = rQliList.get(qliCount);
            
            System.assertEquals(result,rQli.QuoteId);
            System.assertEquals(qli.Quantity,rQli.Quantity);

            //価格表取得フラグがTrueの場合かつ自由入力製品でない場合
            if(isUpdatePrice && !isFirst){
                List<PricebookEntry> pList =
                    [select id,UnitPrice,COWO_MC__c,COWO_TC__c,COWO_FrontPurchasePrice__c,COWO_LocalCorporationTC__c from PriceBookEntry where id =:qli.PricebookEntryId ];
                PricebookEntry p = pList.get(0);
                
                //金額項目に価格表の値が登録されている事の確認
                System.assertEquals(p.COWO_FrontPurchasePrice__c,rQli.COWO_FrontPurchasePrice__c);
                System.assertEquals(p.COWO_LocalCorporationTC__c,rQli.COWO_LocalCorporationTC__c);
                System.assertEquals(p.COWO_MC__c,rQli.COWO_MC__c);
                System.assertEquals(p.COWO_TC__c,rQli.COWO_TC__c);
                
                //価格表から取得する場合、合計を計算する。
                System.assertEquals(qli.Quantity * p.COWO_FrontPurchasePrice__c,rQli.COWO_TotalFrontPurchasePrice__c);
                System.assertEquals(qli.Quantity * p.COWO_LocalCorporationTC__c,rQli.COWO_TotalLocalCorporationTC__c);
                System.assertEquals(qli.Quantity * p.COWO_MC__c,rQli.COWO_TotalMC__c);
                System.assertEquals(qli.Quantity * p.COWO_TC__c,rQli.COWO_TotalTC__c);
                
            }else{
                //価格表取得フラグがFalseの場合又は自由入力製品の場合元の値である事を確認する。
                System.assertEquals(qli.COWO_FrontPurchasePrice__c,rQli.COWO_FrontPurchasePrice__c);
                System.assertEquals(qli.COWO_LocalCorporationTC__c,rQli.COWO_LocalCorporationTC__c);
                System.assertEquals(qli.COWO_MC__c,rQli.COWO_MC__c);
                System.assertEquals(qli.COWO_TC__c,rQli.COWO_TC__c);

                System.assertEquals(qli.COWO_TotalFrontPurchasePrice__c,rQli.COWO_TotalFrontPurchasePrice__c);
                System.assertEquals(qli.COWO_TotalLocalCorporationTC__c,rQli.COWO_TotalLocalCorporationTC__c);
                System.assertEquals(qli.COWO_TotalMC__c,rQli.COWO_TotalMC__c);
                System.assertEquals(qli.COWO_TotalTC__c,rQli.COWO_TotalTC__c);
                
            }
            
            qliCount++;
            isFirst = false;
        }
        
        //見積帳票明細
        Integer qpiCount = 0;
        for(COWO_QuoteLineItem__c qpi :qpiList){
            COWO_QuoteLineItem__c rQpi = rQpiList.get(qpiCount);
            System.debug(qpi);
            System.debug(rQpi);
            System.assertEquals(result,rQpi.COWO_Quote__c);
            System.assertEquals(qpi.COWO_Price__c,rQpi.COWO_Price__c);
            System.assertEquals(qpi.COWO_Quantity__c,rQpi.COWO_Quantity__c);
            qpiCount++;
        }
        System.debug('■■■比較完了■■■');
        
    }
}