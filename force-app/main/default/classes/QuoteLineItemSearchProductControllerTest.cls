@isTest
public with sharing class QuoteLineItemSearchProductControllerTest {

 /**
     * ０件の場合
     * 
     */
    static testMethod void unitTest_001() {
        String countryMode = 'CountryMode1000'; 
        String katashiki = '';
        String productCalledName = '';
        String structureSortNo = '';
        String itemName = '';
        String partsNo = '';
        Quote q = [select id from quote limit 1];
        // 検索
        QuoteLineItemSearchProductController.searchProduct(q.Id,Test.getStandardPricebookId(), katashiki, productCalledName, structureSortNo, itemName, partsNo, false);
    }

    /**
     * ０件以上の場合
     * 
     */
    static testMethod void unitTest_002() {
        String countryMode = 'CountryMode1'; 
        String katashiki = '';
        String productCalledName = '';
        String structureSortNo = '';
        String itemName = '';
        String partsNo = '';
        Quote q = [select id from quote limit 1];
        // 検索
        QuoteLineItemSearchProductController.searchProduct(q.Id,Test.getStandardPricebookId(), katashiki, productCalledName, structureSortNo, itemName, partsNo, false);
    }

    /**
     * ２００件以上の場合
     * 
     */
    static testMethod void unitTest_003() {
        String countryMode = ''; 
        String katashiki = '';
        String productCalledName = '';
        String structureSortNo = '';
        String itemName = '';
        String partsNo = '';
        Quote q = [select id from quote limit 1];
        // 検索
        QuoteLineItemSearchProductController.searchProduct(q.Id,Test.getStandardPricebookId(), katashiki, productCalledName, structureSortNo, itemName, partsNo, false);
    }

    /**
     * init
     * 
     */
    static testMethod void unitTest_004() {
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = 'HHS価格表';
        insert pb2;
        Pricebook2 pb22 = new Pricebook2();
        pb22.Name = 'test';
        insert pb22;  
        Opportunity testOpp = new Opportunity();
        testOpp.StageName = '契約準備中';
        testOpp.Name = 'test';
        testOpp.Benefit__c = 10000;
        testOpp.BudgetAmount__c = 20000;
        testOpp.closeDate = System.today();
        testOpp.CurrencyIsoCode = 'JPY';
        testOpp.Pricebook2Id = pb2.Id;
        insert testOpp;
        Quote testQ = new Quote();
        testQ.Name = 'test quote';
        testQ.OpportunityId = testOpp.id;
        testQ.COWO_Tax_Rate__c = 10;
        testQ.COWO_Report_Item_Flag__c = true;
        testQ.COWO_Discount_Amount__c = 100000;
        testQ.COWO_Header_Discount_Rate__c = 15;
        testQ.COWO_Header_Discount_Amount__c = 10000;
        testQ.COWO_Fertility_Discount1__c = 2000;
        testQ.COWO_Fertility_Discount2__c = 3000;
        testQ.CurrencyIsoCode = 'JPY';
        testQ.Pricebook2Id = pb2.Id;
        testQ.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('COWO_DX_Quote').getRecordTypeId();
        Insert testQ;
        // 検索
        QuoteLineItemSearchProductController.init(testQ.Id, pb2.Id);
        QuoteLineItemSearchProductController.init(testQ.Id, pb22.Id);
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
        List<Product2> product2List = CreateProduct2(201);
        insert product2List;

        //価格表エントリ
        List<PricebookEntry> pbeList = CreatePricebookEntry(product2List);
        insert pbeList;
        
        system.debug('pbeList' + pbeList[0].SAWO_FirstHierarchy__c);
        
        System.runAs(user) {
                        
            // 商談
            Opportunity opp = CreateOpportunity();
            insert opp;
            // 見積
            Quote quote = CreateQuote(opp);
            insert quote;
        }
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
            a.SAWO_FirstHierarchy__c = 'FirstHierarchy';
            a.SAWO_SecondHierarchy__c = 'SecondHierarchy';
            a.SAWO_ThirdHierarchy__c = 'ThirdHierarchy';
            product2List.add(a);
        }
        return product2List;
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
        boolean isFirst = true;
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
     * @param なし
     * @return 商談
     */
    public static Opportunity CreateOpportunity() {
        Opportunity testOpp = new Opportunity();
        testOpp.StageName = '00';
        testOpp.Name = 'test';
        testOpp.Benefit__c = 10000;
        testOpp.BudgetAmount__c = 20000;
        testOpp.closeDate = System.today();
        testOpp.CurrencyIsoCode = 'JPY';
        testOpp.Pricebook2Id = Test.getStandardPricebookId();
        testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId();
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
        return testQ;
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
        user.Username = String.valueOf(dt.second()) + String.valueOf(dt.millisecond()) + '@psn.dummy.com';
        user.CommunityNickname = String.valueOf(dt.second()) + String.valueOf(dt.millisecond()) ;
        user.TimeZoneSidKey = 'Asia/Tokyo';
        user.LocaleSidKey = 'ja_JP';
        user.EmailEncodingKey = 'ISO-2022-JP';
        user.LanguageLocaleKey = 'ja';
        return user;
    }
}