@isTest
public with sharing class OpportunityLineItemBulkEditTest {
    
    public static final String USER_NAME = 'test_user@psn.dummy.com';
    
    /**
     * 初期処理：データ取得
     * 
     */
    static testMethod void unitTest_001() {
        // ユーザ選択
        User user1 = [Select id From User Where Username = 'test_user@psn.dummy.com' Limit 1];
        // 商談選択
        Opportunity opportunity = [select Id from Opportunity limit 1];
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            
            // 検索
            String result = OpportunityLineItemBulkEditController.getOppLineItems(opportunity.Id);
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            //実施結果確認
            Object checkResult = (Object) JSON.deserializeUntyped(result);
            Map<String,Object> checkResultMap = (Map<String, Object>)checkResult;
            String data = String.valueOf(checkResultMap.get('data'));
            system.debug('data' + data);
            List<String> dataList = data.split('},');
            system.assertEquals(Integer.valueOf(checkResultMap.get('returnCode')), 0);
            system.assertEquals(String.valueOf(checkResultMap.get('returnMsg')), System.Label.COWO_MSG_Product2Search_NormalEnd);
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
        // 商談選択
        Opportunity Opportunity = [Select id From Opportunity Limit 1 ];
        // 商談商品選択
        OpportunityLineItem oli = [select id from OpportunityLineItem where OpportunityId = :Opportunity.Id limit 1];
        // 製品選択
        Product2 prod = [select id from Product2 limit 1];
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            //テスト対象メソッド実行
            String draftValue = '[{  '+
                '   \"SAWO_ProductName__c\":\"テスト002\",'+
                '   \"Quantity\": \"10000\",'+
                '   \"UnitPrice\":\"20000\",'+
                '   \"SAWO_ListPrice__c\": \"30000\",'+
                '   \"SAWO_DiscountPrice__c\":\"40000\",'+
                '   \"SAWO_TotalPrice__c\":\"50000\",'+
                '   \"SAWO_LocalCorporationTC__c\":\"60000\",'+
                '   \"SAWO_FrontPurchasePrice__c\":\"70000\",'+
                '   \"TC__c\":\"80000\",'+
                '   \"MC__c\":\"90000\",'+
                '   \"SAWO_DiscountUnitPrice__c\":\"20000\",'+
                '   \"Subtotal\":\"20000\",'+
                '   \"SAWO_SortNo__c\":\"10\",'+
                '   \"SAWO_ItemNumber__c\":\"1\",'+
                '   \"SAWO_PartsNo__c\":\"testPartsNo\",'+
                '   \"Id\":\"Add' + prod.Id + '\",'+
                '   \"SAWO_NoDiscountFlg__c\":false'+
                '}]';
            
                String datas = '[{  '+
                '   \"Id\":\"Add' + prod.Id + '\",'+
                '   \"SAWO_ProductName__c\":\"テスト002\",'+
                '   \"Quantity\": \"10000\",'+
                '   \"UnitPrice\": \"200\",'+
                '   \"SAWO_ListPrice__c\": \"30000\",'+
                '   \"SAWO_DiscountPrice__c\":\"40000\",'+
                '   \"SAWO_TotalPrice__c\":\"50000\",'+
                '   \"SAWO_LocalCorporationTC__c\":\"60000\",'+
                '   \"SAWO_FrontPurchasePrice__c\":\"70000\",'+
                '   \"TC__c\":\"80000\",'+
                '   \"MC__c\":\"90000\",'+
                '   \"SAWO_DiscountUnitPrice__c\":\"20000\",'+
                '   \"Subtotal\":2345,'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"SAWO_SortNo__c\":\"10\",'+
                '   \"SAWO_ItemNumber__c\":\"1\",'+
                '   \"SAWO_NoDiscountFlg__c\":false'+
                '}]';
            
            //String delData = '[{"attributes":{"type":"QuoteLineItem","url":"/services/data/v49.0/sobjects/QuoteLineItem/"'+qi.Id +'"},"Id":"'+ qi.Id +'"}]';
			String delData = '[]';
            
            String result = OpportunityLineItemBulkEditController.reflectEditedData(Opportunity.Id,draftValue,datas,delData,0,true);
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            //実施結果確認
            //resultCheck(result,isUpdatePrice);
        }
        
    }

    /**
     * ＤＢ反映処理：正常終了の場合
     * 
     */
    @isTest static void unitTest_003(){
        
        // ユーザ選択
        User user1 = [Select id From User Where Username = 'test_user@psn.dummy.com' Limit 1];
        // 商談選択
        Opportunity Opportunity = [Select id From Opportunity Limit 1 ];
        // 商談商品選択
        OpportunityLineItem oli = [select id from OpportunityLineItem where OpportunityId = :Opportunity.Id limit 1];
        // 製品選択
        Product2 prod = [select id from Product2 limit 1];
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            //テスト対象メソッド実行
            String draftValue = '[{  '+
                '   \"SAWO_ProductName__c\":\"テスト003\",'+
                '   \"UnitPrice\":\"20000\",'+
                '   \"SAWO_ListPrice__c\": \"30000\",'+
                '   \"SAWO_DiscountPrice__c\":\"40000\",'+
                '   \"SAWO_TotalPrice__c\":\"50000\",'+
                '   \"SAWO_LocalCorporationTC__c\":\"60000\",'+
                '   \"SAWO_FrontPurchasePrice__c\":\"70000\",'+
                '   \"TC__c\":\"80000\",'+
                '   \"MC__c\":\"90000\",'+
                '   \"SAWO_DiscountUnitPrice__c\":\"20000\",'+
                '   \"Subtotal\":\"20000\",'+
                '   \"SAWO_SortNo__c\":\"10\",'+
                '   \"SAWO_ItemNumber__c\":\"1\",'+
                '   \"SAWO_PartsNo__c\":\"testPartsNo\",'+
                '   \"SAWO_SalesPrice__c\":\"20000\",'+
                '   \"Id\":\"Add' + prod.Id + '\",'+
                '   \"SAWO_NoDiscountFlg__c\":false'+
                '}]';
            
                String datas = '[{  '+
                '   \"Id\":\"Add' + prod.Id + '\",'+
                '   \"SAWO_ProductName__c\":\"テスト003\",'+
                '   \"UnitPrice\": \"200\",'+
                '   \"SAWO_ListPrice__c\": \"30000\",'+
                '   \"SAWO_DiscountPrice__c\":\"40000\",'+
                '   \"SAWO_TotalPrice__c\":\"50000\",'+
                '   \"SAWO_LocalCorporationTC__c\":\"60000\",'+
                '   \"SAWO_FrontPurchasePrice__c\":\"70000\",'+
                '   \"TC__c\":\"80000\",'+
                '   \"MC__c\":\"90000\",'+
                '   \"SAWO_DiscountUnitPrice__c\":\"20000\",'+
                '   \"Subtotal\":2345,'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"SAWO_SortNo__c\":\"10\",'+
                '   \"SAWO_ItemNumber__c\":\"1\",'+
                '   \"SAWO_SalesPrice__c\":\"20000\",'+
                '   \"SAWO_NoDiscountFlg__c\":false'+
                '}]';
            
            //String delData = '[{"attributes":{"type":"QuoteLineItem","url":"/services/data/v49.0/sobjects/QuoteLineItem/"'+qi.Id +'"},"Id":"'+ qi.Id +'"}]';
			String delData = '[]';
            
            String result = OpportunityLineItemBulkEditController.reflectEditedData(Opportunity.Id,draftValue,datas,delData,0,false);
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            //実施結果確認
            //resultCheck(result,isUpdatePrice);
        }
        
    }

    /**
     * ＤＢ反映処理：正常終了の場合
     * 
     */
    @isTest static void unitTest_004(){
        
        // ユーザ選択
        User user1 = [Select id From User Where Username = 'test_user@psn.dummy.com' Limit 1];
        // 商談選択
        Opportunity Opportunity = [Select id From Opportunity Limit 1 ];
        // 商談商品選択
        OpportunityLineItem oli = [select id from OpportunityLineItem where OpportunityId = :Opportunity.Id limit 1];
        // 製品選択
        Product2 prod = [select id from Product2 limit 1];
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            //テスト対象メソッド実行
            String draftValue = '[]';
            
            String datas = '[]';
            
            String delData = '[{"attributes":{"type":"OpportunityLineItem","url":"/services/data/v49.0/sobjects/OpportunityLineItem/"'+oli.Id +'"},"Id":"'+ oli.Id +'"}]';
			// String delData = '[]';
            
            String result = OpportunityLineItemBulkEditController.reflectEditedData(Opportunity.Id,draftValue,datas,delData,0,false);
            
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
        // 商談選択
        Opportunity Opportunity = [Select id From Opportunity Limit 1 ];
        // 商談商品選択
        OpportunityLineItem oli = [select id from OpportunityLineItem where OpportunityId = :Opportunity.Id limit 1];
        // 製品選択
        Product2 prod = [select id from Product2 limit 1];
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            //テスト対象メソッド実行
            String draftValue = '[{  '+
                '   \"SAWO_ProductName__c\":\"テスト00\",'+
                '   \"Quantity\": \"10000\",'+
                '   \"UnitPrice\":\"20000\",'+
                '   \"SAWO_ListPrice__c\": \"30000\",'+
                '   \"SAWO_DiscountPrice__c\":\"40000\",'+
                '   \"SAWO_TotalPrice__c\":\"50000\",'+
                '   \"SAWO_LocalCorporationTC__c\":\"60000\",'+
                '   \"SAWO_FrontPurchasePrice__c\":\"70000\",'+
                '   \"TC__c\":\"80000\",'+
                '   \"MC__c\":\"90000\",'+
                '   \"SAWO_DiscountUnitPrice__c\":\"20000\",'+
                '   \"Subtotal\":\"20000\",'+
                '   \"SAWO_SortNo__c\":\"10\",'+
                '   \"SAWO_PartsNo__c\":\"testPartsNo\",'+
                '   \"Id\":\"Add' + prod.Id + '\",'+
                '   \"SAWO_NoDiscountFlg__c\":false'+
                '}]';
            
                String datas = '[{  '+
                '   \"Id\":\"Add' + prod.Id + '\",'+
                '   \"SAWO_ProductName__c\":\"テスト005\",'+
                '   \"Quantity\": \"20\",'+
                '   \"UnitPrice\": \"200\",'+
                '   \"SAWO_ListPrice__c\": \"30000\",'+
                '   \"SAWO_DiscountPrice__c\":\"40000\",'+
                '   \"SAWO_TotalPrice__c\":\"50000\",'+
                '   \"SAWO_LocalCorporationTC__c\":\"60000\",'+
                '   \"SAWO_FrontPurchasePrice__c\":\"70000\",'+
                '   \"TC__c\":\"80000\",'+
                '   \"MC__c\":\"90000\",'+
                '   \"SAWO_DiscountUnitPrice__c\":\"20000\",'+
                '   \"Subtotal\":2345,'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"SAWO_SortNo__c\":\"10\",'+
                '   \"SAWO_NoDiscountFlg__c\":false'+
                '}]';
            
            //String delData = '[{"attributes":{"type":"QuoteLineItem","url":"/services/data/v49.0/sobjects/QuoteLineItem/"'+qi.Id +'"},"Id":"'+ qi.Id +'"}]';
			String delData = '[]';
            
            String result = OpportunityLineItemBulkEditController.reflectEditedData(Opportunity.Id,draftValue,datas,delData,0,false);
            
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
        
        TriggerConfig__c triggerConfig = CreateTriggerConfig();
        insert triggerConfig;
        
        System.runAs(user) {
                        
            // 商談
            Opportunity opp = CreateOpportunities();
            insert opp;
            
            // 商談商品
            List<OpportunityLineItem> oiList = CreateOpportunityLineItem(opp,pbeList);
            insert oiList;
        }
    }
    
    /**
     * 消費税カスタム設定
     * @return SAWO_CurrencyConsumptionTaxConfig__c
     */
    public static SAWO_CurrencyConsumptionTaxConfig__c CreateCurrencySetting() {
        return new SAWO_CurrencyConsumptionTaxConfig__c(SAWO_Consumption_Tax__c = 10,name = 'JPY');
    }
    
    /**
     * トリガカスタム設定
     * @return TriggerConfig__c
     */
     public static TriggerConfig__c CreateTriggerConfig() {
        return new TriggerConfig__c(Name = 'TriggerStop',QuoteTrigger__c = true,QuoteLineItemTrigger__c = true,OpportunityTrigger__c = true,OpportunityLineItemTrigger__c = true);
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
     * 商談商品名
     * 
     * @param opportunity 商談
     * @param PricebookEntry 価格表エントリ
     * @return 商談商品名
     */
    public static List<OpportunityLineItem> CreateOpportunityLineItem(Opportunity opportunity,List<PricebookEntry> pbeList){
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();

        Integer i = 0;
        for(PricebookEntry pbe : pbeList){
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opportunity.Id;
            oli.PricebookEntryId = pbe.Id;
            oli.Product2Id = pbe.Product2Id;
            oli.Quantity = 10;
            oli.UnitPrice = (decimal)(555 + i);
            oli.SAWO_ProductName__c = 'テスト';
            oli.SAWO_DiscountPrice__c = 5000;
            oli.SAWO_ListPrice__c = 8000;
            oli.SAWO_FrontPurchasePrice__c = (decimal)(111 + i);
            oli.SAWO_LocalCorporationTC__c = (decimal)(222 + i);
            oli.MC__c = (decimal)(333 + i);
            oli.TC__c = (decimal)(444 + i);
            oli.SAWO_ItemNumber__c = i;
            oli.SAWO_NoDiscountFlg__c = false;
            oliList.add(oli);
            i++;
        }        
        
        return oliList;
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
}