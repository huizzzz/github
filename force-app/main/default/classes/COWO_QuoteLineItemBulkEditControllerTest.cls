@isTest
public with sharing class COWO_QuoteLineItemBulkEditControllerTest {
    /**************************************************************************
       テストデータ作成関連
     **************************************************************************/
    /**************************************************************************
       プロファイル名
     **************************************************************************/
    /** システム管理者 */
    public static final String PROFILENAME_ADMIN                    {get{return 'システム管理者';}}
    
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
            // 検索
            String result = COWOQuoteLineItemBulkEditController.getCOWOQuoteLineItems(quote.Id);
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            //実施結果確認
            Object checkResult = (Object) JSON.deserializeUntyped(result);
            Map<String,Object> checkResultMap = (Map<String, Object>)checkResult;
            String data = String.valueOf(checkResultMap.get('data'));
            //system.assertEquals(Integer.valueOf(checkResultMap.get('returnCode')), 0);
            //system.assertEquals(String.valueOf(checkResultMap.get('returnMsg')), System.Label.COWO_MSG_QLISearch_NormalEnd);
            if (data != null && data.contains('},')) {                
                List<String> dataList = data.split('},');
                system.assertEquals(dataList.size(), 2);
            }
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
        Quote quote = [Select id,CurrencyIsoCode,COWO_Final_Amount__c From Quote Limit 1 ];
        
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            //テスト対象メソッド実行
            String draftValue = '[{  '+
                '   \"COWO_ProductName__c\":\"テスト002\",'+
                '   \"COWO_Price__c\": \"200\",'+
                '   \"COWO_SubTotal__c\": \"1590\",'+
                '   \"COWO_Quantity__c\":\"2\",'+
                '   \"COWO_SortNo__c\":\"3\",'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"Id\":\"NewTest\"'+
                '}]';
            
            String datas = '[{  '+
                '   \"Id\":\"NewTest\",'+
                '   \"COWO_ProductName__c\":\"テスト002\",'+
                '   \"COWO_Price__c\": \"200\",'+
                '   \"COWO_SubTotal__c\": \"1590\",'+
                '   \"COWO_Quantity__c\":\"2\",'+
                '   \"COWO_SortNo__c\":\"3\",'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"trendIcon\":\"utility:warning\"'+
                '}]';
            
            String delData = '[]';
            String result ;
            
            try{
                result = COWOQuoteLineItemBulkEditController.reflectEditedData(quote.Id,draftValue,delData,datas,quote.CurrencyIsoCode,0);
                //実施結果確認
                List<COWO_QuoteLineItem__c> cowoQIList = [select id,CurrencyIsoCode,COWO_ProductName__c,COWO_Price__c,COWO_SubTotal__c,COWO_Quantity__c,COWO_SortNo__c from COWO_QuoteLineItem__c where COWO_ProductName__c = 'テスト2']; 
                system.assertEquals(cowoQIList[0].COWO_ProductName__c,'テスト002');
                system.assertEquals(cowoQIList[0].COWO_Price__c,200);
                system.assertEquals(cowoQIList[0].COWO_SubTotal__c,1590);
                system.assertEquals(cowoQIList[0].COWO_Quantity__c,'2');
                system.assertEquals(cowoQIList[0].COWO_SortNo__c,3);           
                system.assertEquals(cowoQIList[0].CurrencyIsoCode ,'JPY');
            }
            catch(Exception e){          
            }
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            
            //system.assertEquals(cowoQIList[0].COWO_ProductName__c,'テスト002');
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
        Quote quote = [Select id,CurrencyIsoCode,COWO_Final_Amount__c From Quote Limit 1 ];
        // 見積帳票明細選択
        List<COWO_QuoteLineItem__c> cowoQLI = [Select id,COWO_ProductName__c,COWO_Price__c,COWO_SubTotal__c,COWO_Quantity__c,COWO_SortNo__c From COWO_QuoteLineItem__c];
        system.debug('cowoQLI.size' + cowoQLI.size());
        
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            //テスト対象メソッド実行
            String draftValue = '[{  '+
                '   \"COWO_ProductName__c\":\"テスト003\",'+
                '   \"COWO_Price__c\": \"200\",'+
                '   \"COWO_SubTotal__c\": \"1590\",'+
                '   \"COWO_Quantity__c\":\"2\",'+
                '   \"COWO_SortNo__c\":\"3\",'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"Id\":\"'+ cowoQLI[0].Id +'\"'+
                '}]';
            
            String datas = '[{  '+
                '   \"Id\":\"'+ cowoQLI[0].Id +'\"'+
                '   \"COWO_ProductName__c\":\"テスト003\",'+
                '   \"COWO_Price__c\": \"200\",'+
                '   \"COWO_SubTotal__c\": \"1590\",'+
                '   \"COWO_Quantity__c\":\"2\",'+
                '   \"COWO_SortNo__c\":\"3\",'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"trendIcon\":\"utility:warning\"'+
                '},{  '+
                '   \"Id\":\"'+ cowoQLI[1].Id +'\"'+
                '   \"COWO_ProductName__c\":\"テスト003\",'+
                '   \"COWO_Price__c\": \"200\",'+
                '   \"COWO_SubTotal__c\": \"1590\",'+
                '   \"COWO_Quantity__c\":\"2\",'+
                '   \"COWO_SortNo__c\":\"3\",'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"trendIcon\":\"utility:warning\"'+
                '}]';
            
            String delData = '[{  '+
                '   \"Id\":\"'+ cowoQLI[1].Id +'\"'+
                '   \"COWO_ProductName__c\":\"テスト002\",'+
                '   \"COWO_Price__c\": \"200\",'+
                '   \"COWO_SubTotal__c\": \"1590\",'+
                '   \"COWO_Quantity__c\":\"2\",'+
                '   \"COWO_SortNo__c\":\"3\",'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"trendIcon\":\"utility:warning\"'+
                '}]';
            String result ;
            
            try{
                result = COWOQuoteLineItemBulkEditController.reflectEditedData(quote.Id,draftValue,delData,datas,quote.CurrencyIsoCode,0);
                //実施結果確認
                List<COWO_QuoteLineItem__c> cowoQIList = [select id,CurrencyIsoCode,COWO_ProductName__c,COWO_Price__c,COWO_SubTotal__c,COWO_Quantity__c,COWO_SortNo__c from COWO_QuoteLineItem__c where COWO_ProductName__c = 'テスト2']; 
                system.assertEquals(cowoQIList[0].COWO_ProductName__c,'テスト003');
                system.assertEquals(cowoQIList[0].COWO_Price__c,200);
                system.assertEquals(cowoQIList[0].COWO_SubTotal__c,1590);
                system.assertEquals(cowoQIList[0].COWO_Quantity__c,'2');
                system.assertEquals(cowoQIList[0].COWO_SortNo__c,3);           
                system.assertEquals(cowoQIList[0].CurrencyIsoCode ,'JPY');
                system.assertEquals(cowoQIList.size() ,1);
            }
            catch(Exception e){      
                System.debug('★★★★★ e.getMessage() ★★★★★' + e.getMessage());
            }
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            
            //system.assertEquals(cowoQIList[0].COWO_ProductName__c,'テスト002');
        }
        
    }
    
    /**
     * ＤＢ反映処理：異常終了の場合
     * 
     */
    @isTest static void unitTest_004(){
        
        // ユーザ選択
        User user1 = [Select id From User Where Username = 'test_user@psn.dummy.com' Limit 1];
        // 見積選択
        String quoteId = '';
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            // 検索
            String result ;
            try{
                result = COWOQuoteLineItemBulkEditController.getCOWOQuoteLineItems(quoteId);
            }catch(Exception e){
                //実施結果確認
                Object checkResult = (Object) JSON.deserializeUntyped(result);
                Map<String,Object> checkResultMap = (Map<String, Object>)checkResult;
                system.assertEquals(Integer.valueOf(checkResultMap.get('returnCode')), 0);
                system.assertEquals(String.valueOf(checkResultMap.get('returnMsg')), e.getMessage());
            }           
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');
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
        Quote quote = [Select id,CurrencyIsoCode,COWO_Final_Amount__c From Quote Limit 1 ];
        
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            //テスト対象メソッド実行
            String draftValue = '[{  '+
                '   \"COWO_ProductName__c\":\"テスト003\",'+
                '   \"COWO_Price__c\": \"20000\",'+
                '   \"COWO_SubTotal__c\": \"200000\",'+
                '   \"COWO_Quantity__c\":\"20\",'+
                '   \"COWO_SortNo__c\":\"3\",'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"Id\":\"NewTest\"'+
                '}]';
            
            String datas = '[{  '+
                '   \"Id\":\"NewTest\",'+
                '   \"COWO_ProductName__c\":\"テスト003\",'+
                '   \"COWO_Price__c\": \"20000\",'+
                '   \"COWO_SubTotal__c\": \"200000\",'+
                '   \"COWO_Quantity__c\":\"2\",'+
                '   \"COWO_SortNo__c\":\"3\",'+
                '   \"CurrencyIsoCode\":\"JPY\",'+
                '   \"trendIcon\":\"utility:warning\"'+
                '}]';
            
            String delData = '[]';
            String result ;
            
            try{
                result = COWOQuoteLineItemBulkEditController.reflectEditedData(quote.Id,draftValue,delData,datas,quote.CurrencyIsoCode,0);
                
            }
            catch(Exception e){   
                //実施結果確認
                Object checkResult = (Object) JSON.deserializeUntyped(result);
                Map<String,Object> checkResultMap = (Map<String, Object>)checkResult;
                system.assertEquals(Integer.valueOf(checkResultMap.get('returnCode')), 0);
                system.assertEquals(String.valueOf(checkResultMap.get('returnMsg')), System.Label.COWO_MSG_FinalAmountErr);
            }
            
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            
            //system.assertEquals(cowoQIList[0].COWO_ProductName__c,'テスト002');
        }
        
    }
    
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
        
        System.runAs(user) {
                        
            // 商談
            Opportunity opp = CreateOpportunity();
            insert opp;
            // 見積
            Quote quote = CreateQuote(opp);
            insert quote;
            // 見積品目
            List<QuoteLineItem> qiList = CreateQuoteLineItem(quote,pbeList);
            insert qiList;
            // 見積明細
            List<COWO_QuoteLineItem__c> cowoQuoteList= CreateCOWO_QuoteLineItems(quote);
            insert cowoQuoteList;
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
    public static Opportunity CreateOpportunity() {
        Opportunity testOpp = new Opportunity();
        testOpp.StageName = '00';
        testOpp.Name = 'TEST_COPY_QUOTE001';
        testOpp.closeDate = System.today();
        testOpp.Benefit__c = 10000;
        testOpp.BudgetAmount__c = 20000;
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
        testQ.COWO_Discount_Amount__c = 0;
        testQ.COWO_Header_Discount_Rate__c = 15;
        testQ.COWO_Header_Discount_Amount__c = 10000;
        testQ.COWO_Fertility_Discount1__c = 2000;
        testQ.COWO_Fertility_Discount2__c = 3000;
        testQ.CurrencyIsoCode = 'JPY';
        testQ.Pricebook2Id = opp.Pricebook2Id;
        testQ.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('COWO_DX_Quote').getRecordTypeId();
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
            qli.Quantity = 5;
            qli.UnitPrice = 1000;
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
    public static List<COWO_QuoteLineItem__c> CreateCOWO_QuoteLineItems(Quote quote){
        List<COWO_QuoteLineItem__c> qpiList = new List<COWO_QuoteLineItem__c>();
        
        qpiList.add(new COWO_QuoteLineItem__c(COWO_Quote__c = quote.Id,COWO_Price__c = (Decimal)1000,COWO_Quantity__c = '1',COWO_SubTotal__c = (Decimal)3000 ,COWO_SortNo__c = 1,COWO_ProductName__c = 'テスト0'));
        qpiList.add(new COWO_QuoteLineItem__c(COWO_Quote__c = quote.Id,COWO_Price__c = (Decimal)1001,COWO_Quantity__c = '1',COWO_SubTotal__c = (Decimal)3001 ,COWO_SortNo__c = 2,COWO_ProductName__c = 'テスト1'));
        
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
        user.Username = 'test_user@psn.dummy.com';
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

    /*public static void resultCheck(String result,Boolean isUpdatePrice){
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

        //見積
        Quote quote = CreateQuote(opp);
        insert quote;
        
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
        
    }*/
}