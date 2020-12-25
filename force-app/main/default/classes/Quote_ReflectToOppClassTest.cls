@isTest
private class Quote_ReflectToOppClassTest {

    public static final String OPP_NAME = 'TEST_REFLECT_QUOTE00';
    public static final String USER_NAME = 'test_user@psn.dummy.com';
    
    //見積品目:0件のケース
    @isTest static void testReflectQuote001(){
        
        // ユーザ選択
        User user1 = [Select id From User Where Username = 'test_user@psn.dummy.com' Limit 1];
        System.debug('★★ユーザ選択完了★★');
        // 見積選択
        Quote quote0 = [Select Id,Name,OpportunityId,COWO_Discount_Amount__c,COWO_Tax_Rate__c,COWO_Payment_Terms__c,COWO_Transaction_Terms_Import_Export__c,
                       COWO_Install_Adjust_Cost__c,COWO_Transport_Cost__c,COWO_Sales_Desired_Delivery_Date__c,COWO_Scheduled_Shipping_Date__c,
                       COWO_Final_Amount__c,SubTotal,COWO_Total_Tax__c,COWO_Total_MC__c,COWO_Total_TC__c,COWO_Total_FrontPurchasePrice__c,
                       COWO_Total_LocalCorporationTC__c,COWO_Total_Profit__c,COWO_Profit_Rate__c,COWO_HHT_Total_Profit__c,COWO_HHT_Profit_Rate__c,
                       COWO_Gross_Profit_Rate__c,COWO_Gross_Profit__c
                       From Quote Where Name = 'test0' Limit 1 ];
        List<QuoteLineItem> qli0 = [SELECT Id,QuoteId FROM QuoteLineItem WHERE QuoteId =: quote0.Id];//デバッグ用
        System.debug('★★★★見積品目名数：' + qli0.size());
        System.debug('★★見積選択完了★★');
        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            //テスト対象メソッド実行
            String result =  Quote_ReflectToOppClass.QuoteLineItemReflection(quote0.Id);

            //実施結果確認
			resultCheck(quote0,result);
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');


            
        }
        
    }


    //見積品目:複数件、商談商品:0件のケース
    @isTest static void testReflectQuote002(){
        
        // ユーザ選択
        User user1 = [Select id From User Where Username = 'test_user@psn.dummy.com' Limit 1];
        
        // 見積選択
        Quote quote1 = [Select Id,Name,OpportunityId,COWO_Discount_Amount__c,COWO_Tax_Rate__c,COWO_Payment_Terms__c,COWO_Transaction_Terms_Import_Export__c,
                       COWO_Install_Adjust_Cost__c,COWO_Transport_Cost__c,COWO_Sales_Desired_Delivery_Date__c,COWO_Scheduled_Shipping_Date__c,
                       COWO_Final_Amount__c,SubTotal,COWO_Total_Tax__c,COWO_Total_MC__c,COWO_Total_TC__c,COWO_Total_FrontPurchasePrice__c,
                       COWO_Total_LocalCorporationTC__c,COWO_Total_Profit__c,COWO_Profit_Rate__c,COWO_HHT_Total_Profit__c,COWO_HHT_Profit_Rate__c,
                       COWO_Gross_Profit_Rate__c,COWO_Gross_Profit__c 
                       From Quote Where Name = 'test1' Limit 1 ];

        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            //テスト対象メソッド実行
            String result = Quote_ReflectToOppClass.QuoteLineItemReflection(quote1.Id);

            //実施結果確認
			resultCheck(quote1,result);
           
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            
        }
        
    }

    //見積品目:複数件、商談商品:複数件のケース
    @isTest static void testReflectQuote003(){
        
        // ユーザ選択
        User user1 = [Select id From User Where Username = 'test_user@psn.dummy.com' Limit 1];
        // 見積選択
        Quote quote2 = [Select Id,Name,OpportunityId,COWO_Discount_Amount__c,COWO_Tax_Rate__c,COWO_Payment_Terms__c,COWO_Transaction_Terms_Import_Export__c,
                       COWO_Install_Adjust_Cost__c,COWO_Transport_Cost__c,COWO_Sales_Desired_Delivery_Date__c,COWO_Scheduled_Shipping_Date__c,
                       COWO_Final_Amount__c,SubTotal,COWO_Total_Tax__c,COWO_Total_MC__c,COWO_Total_TC__c,COWO_Total_FrontPurchasePrice__c,
                       COWO_Total_LocalCorporationTC__c,COWO_Total_Profit__c,COWO_Profit_Rate__c,COWO_HHT_Total_Profit__c,COWO_HHT_Profit_Rate__c,
                       COWO_Gross_Profit_Rate__c,COWO_Gross_Profit__c 
                       From Quote Where Name = 'test2' Limit 1 ];

        System.runas(user1){
            System.debug('■■■テスト実行開始■■■');            
            Test.startTest();
            //テスト対象メソッド実行
            String result = Quote_ReflectToOppClass.QuoteLineItemReflection(quote2.Id);

            //実施結果確認
			resultCheck(quote2,result);
            
            Test.stopTest();
            System.debug('■■■テスト実行完了■■■');

            
        }
        
    }

    /**************************************************************************
       実行結果確認
     **************************************************************************/

    public static void resultCheck(Quote quote,String result){
        System.debug('■■■比較開始■■■');
      
        //■実行結果取得
        //見積
        List<Quote> rQuoteList = [SELECT Id,Name,COWO_Discount_Amount__c,COWO_Tax_Rate__c,COWO_Payment_Terms__c,COWO_Transaction_Terms_Import_Export__c,
                                  COWO_Install_Adjust_Cost__c,COWO_Transport_Cost__c,COWO_Sales_Desired_Delivery_Date__c,COWO_Scheduled_Shipping_Date__c,
                                  COWO_Final_Amount__c,SubTotal,COWO_Total_Tax__c,COWO_Total_MC__c,COWO_Total_TC__c,COWO_Total_FrontPurchasePrice__c,
                                  COWO_Total_LocalCorporationTC__c,COWO_Total_Profit__c,COWO_Profit_Rate__c,COWO_HHT_Total_Profit__c,COWO_HHT_Profit_Rate__c,
                                  COWO_Gross_Profit_Rate__c,COWO_Gross_Profit__c
                                  FROM Quote WHERE Id =:quote.Id  LIMIT 1];
		Quote rQuote = rQuoteList.get(0);            
        System.debug('★★実行結果：見積取得★★');        
        System.debug('★★★★見積取得数：' + rQuoteList.size());
        System.debug('★★★見積名：'+ rQuote.Name);
        
        //見積品目名
        List<QuoteLineItem> rQliList = [SELECT Id,QuoteId,Product2Id,PricebookEntryId,Quantity,UnitPrice,COWO_Rate__c,COWO_LocalCorporationTC__c,Quote.OpportunityId,Quote.Name,
                                        COWO_FrontPurchasePrice__c,COWO_HHTWholesalePrice__c,COWO_TC__c,COWO_MC__c,COWO_Product_Name__c,COWO_Price__c,COWO_DiscountUnitPrice__c,COWO_TotalPrice__c
                                        FROM QuoteLineItem WHERE QuoteId =:quote.Id ORDER BY Product2Id];
        System.debug('★★実行結果：見積品目取得★★');
        System.debug('★★★★見積品目名取得数：' + rQliList.size());

        
        //商談
        List<Opportunity> rOppList = [SELECT Id,Name,SAWO_Discount_Price__c,SAWO_Consumption_Tax__c,
                                      SAWO_Install_Adjust_Cost__c,SAWO_Transport_Cost__c,SAWO_Shipping_ExpectedDate__c,
                                      EstimatedAmount__c,SAWO_SubTotal__c,SAWO_Final_Price__c,SAWO_MC_Amount__c,
                                      SAWO_TC_Amount__c,SAWO_Front_Purchase_Amount__c,SAWO_Currentlaw_TC_Amount__c,SAWO_Benefit_Hsl_Amount__c,
                                      SAWO_Benefit_Hsl_Rate__c,SAWO_HHT_Benefit__c,SAWO_HHT_Benefit_Rate__c,SAWO_Gross_Profit_Rate__c,SAWO_Gross_Profit__c
                                      FROM Opportunity WHERE Id =:quote.OpportunityId LIMIT 1];
        Opportunity rOpp = rOppList.get(0);            
        System.debug('★★実行結果：商談取得★★');
        System.debug('★★★★商談取得数：' + rOppList.size());


        //商談商品
        List<OpportunityLineItem> rOliList = [SELECT Id,OpportunityId,Product2Id,PricebookEntryId,Quantity,UnitPrice,SAWO_Rate__c,SAWO_LocalCorporationTC__c,Opportunity.Name,
                                              SAWO_FrontPurchasePrice__c,SAWO_HHTWholesalePrice__c,TC__c,
                                              MC__c,ProductName__c,SAWO_Price__c,SAWO_TotalPrice__c
                                              FROM OpportunityLineItem WHERE OpportunityId =:quote.OpportunityId ORDER BY Product2Id];
        System.debug('★★実行結果：商談商品取得★★');
        System.debug('★★★★商談商品取得数：' + rOliList.size());
        
        
/*        //■期待値作成
        System.debug('★★実行結果：期待値作成開始★★');

        //商談
        List<Opportunity> oppList = CreateOpportunities();
        insert oppList;
        //商品
        List<Product2> productList = CreateProduct2(20);
        insert productList;
        //価格表エントリ
        List<PricebookEntry> pbeList = CreatePricebookEntry(productList); 
        insert pbeList;
        //見積
        List<Quote> quoteList = CreateQuote(oppList);
        insert quoteList;
        //見積品目名
        List<QuoteLineItem> qliList = CreateQuoteLineItem(quoteList, pbeList);
        insert qliList;

        System.debug('★★実行結果：期待値作成完了★★');
*/
        
        //■実施結果比較
        //見積の値が商談に反映されていることの確認
        //見積品目が0件の場合
        if(rQuote.Name == 'test0'){
            System.debug('★★★リザルト：' + result);
            System.assertEquals('noitem',result);

            //見積品目が複数件の場合
        }else{     
            System.debug('★★実行結果：見積商談比較開始★★');
            System.debug('★★★値引金額：' + rQuote.COWO_Discount_Amount__c+ '='+ rOpp.SAWO_Discount_Price__c);
            System.debug('★★★消費税率：' + rQuote.COWO_Tax_Rate__c+ '='+ rOpp.SAWO_Consumption_Tax__c);
            System.debug('★★★据付調整費：' + rQuote.COWO_Install_Adjust_Cost__c+ '='+ rOpp.SAWO_Install_Adjust_Cost__c);
            System.debug('★★★運送費：' + rQuote.COWO_Transport_Cost__c+ '='+ rOpp.SAWO_Transport_Cost__c);
            System.debug('★★★出荷予定日：' + rQuote.COWO_Scheduled_Shipping_Date__c+ '='+ rOpp.SAWO_Shipping_ExpectedDate__c);
            System.debug('★★★最終金額：' + rQuote.COWO_Final_Amount__c+ '='+ rOpp.EstimatedAmount__c);
            System.debug('★★★小計：' + rQuote.SubTotal+ '='+ rOpp.SAWO_SubTotal__c);
            System.debug('★★★MC合計：' + rQuote.COWO_Total_MC__c+ '='+ rOpp.SAWO_MC_Amount__c);
            System.debug('★★★TC合計：' + rQuote.COWO_Total_TC__c+ '='+ rOpp.SAWO_TC_Amount__c);
            System.debug('★★★フロント仕入価格合計：' + rQuote.COWO_Total_FrontPurchasePrice__c+ '='+ rOpp.SAWO_Front_Purchase_Amount__c);
            System.debug('★★★現法TC合計：' + rQuote.COWO_Total_LocalCorporationTC__c+ '='+ rOpp.SAWO_Currentlaw_TC_Amount__c);
            System.debug('★★★利益合計：' + rQuote.COWO_Total_Profit__c+ '='+ rOpp.SAWO_Benefit_Hsl_Amount__c);
            System.debug('★★★利益率：' + rQuote.COWO_Profit_Rate__c+ '='+ rOpp.SAWO_Benefit_Hsl_Rate__c);
            System.debug('★★★HHT利益：' + rQuote.COWO_HHT_Total_Profit__c+ '='+ rOpp.SAWO_HHT_Benefit__c);
            System.debug('★★★HHT利益率：' + rQuote.COWO_HHT_Profit_Rate__c+ '='+ rOpp.SAWO_HHT_Benefit_Rate__c);
            System.debug('★★★粗利益率：' + rQuote.COWO_Gross_Profit_Rate__c+ '='+ rOpp.SAWO_Gross_Profit_Rate__c);
            System.debug('★★★粗利益：' + rQuote.COWO_Gross_Profit__c+ '='+ rOpp.SAWO_Gross_Profit__c);


            //System.assertEquals(rQuote.COWO_Discount_Amount__c,rOpp.SAWO_Discount_Price__c);
            System.assertEquals(rQuote.COWO_Tax_Rate__c,rOpp.SAWO_Consumption_Tax__c);
            //System.assertEquals(rQuote.COWO_Install_Adjust_Cost__c,rOpp.SAWO_Install_Adjust_Cost__c);
            //System.assertEquals(rQuote.COWO_Transport_Cost__c,rOpp.SAWO_Transport_Cost__c);
            //System.assertEquals(rQuote.COWO_Sales_Desired_Delivery_Date__c,rOpp.SAWO_Sales_Desired_Delivery_Date__c);
            //System.assertEquals(rQuote.COWO_Scheduled_Shipping_Date__c,rOpp.SAWO_Shipping_ExpectedDate__c);
            //System.assertEquals(rQuote.COWO_Final_Amount__c,rOpp.EstimatedAmount__c);
            //System.assertEquals(rQuote.SubTotal,rOpp.SAWO_SubTotal__c);
            //System.assertEquals(rQuote.COWO_Total_MC__c,rOpp.SAWO_MC_Amount__c);
            //System.assertEquals(rQuote.COWO_Total_TC__c,rOpp.SAWO_TC_Amount__c);
            //System.assertEquals(rQuote.COWO_Total_FrontPurchasePrice__c,rOpp.SAWO_Front_Purchase_Amount__c);
            //System.assertEquals(rQuote.COWO_Total_LocalCorporationTC__c,rOpp.SAWO_Currentlaw_TC_Amount__c);
            //System.assertEquals(rQuote.COWO_Total_Profit__c,rOpp.SAWO_Benefit_Hsl_Amount__c);
            //System.assertEquals(rQuote.COWO_Profit_Rate__c,rOpp.SAWO_Benefit_Hsl_Rate__c);
            //System.assertEquals(rQuote.COWO_HHT_Total_Profit__c,rOpp.SAWO_HHT_Benefit__c);
            //System.assertEquals(rQuote.COWO_HHT_Profit_Rate__c,rOpp.SAWO_HHT_Benefit_Rate__c);
            //System.assertEquals(rQuote.COWO_Gross_Profit_Rate__c,rOpp.SAWO_Gross_Profit_Rate__c);
            //System.assertEquals(rQuote.COWO_Gross_Profit__c,rOpp.SAWO_Gross_Profit__c);
            System.debug('★★実行結果：見積商談比較完了★★');

        //見積品目名
        //見積品目が0件の場合
        System.debug('★★実行結果：見積品目商談商品比較開始★★');


            System.assertEquals('success',result);

            //見積品目名と商談商品の件数一致確認
            System.assertEquals(rQliList.size(),rOliList.size());
                
            //見積品目名の項目値が商談商品に反映されていることの確認
            Integer qliCount = 0;
            for(QuoteLineItem qli :rQliList){
                OpportunityLineItem Oli = rOliList.get(qliCount);
                System.assertEquals(qli.Quote.OpportunityId,Oli.OpportunityId);
                System.assertEquals(qli.Product2Id,Oli.Product2Id);
                System.assertEquals(qli.PricebookEntryId,Oli.PricebookEntryId);
                System.assertEquals(qli.Quantity,Oli.Quantity);
                //System.assertEquals(qli.UnitPrice,Oli.UnitPrice);
                //System.assertEquals(qli.COWO_Rate__c,Oli.SAWO_Rate__c);
                //System.assertEquals(qli.COWO_LocalCorporationTC__c,Oli.SAWO_LocalCorporationTC__c);
                //System.assertEquals(qli.COWO_FrontPurchasePrice__c,Oli.SAWO_FrontPurchasePrice__c);
                //System.assertEquals(qli.COWO_HHTWholesalePrice__c,Oli.SAWO_HHTWholesalePrice__c);
                //System.assertEquals(qli.COWO_TC__c,Oli.TC__c);
                //System.assertEquals(qli.COWO_MC__c,Oli.MC__c);
                //System.assertEquals(qli.COWO_Product_Name__c,Oli.ProductName__c);
                //System.assertEquals(qli.COWO_DiscountUnitPrice__c,Oli.SAWO_Price__c);
                //System.assertEquals(qli.COWO_TotalPrice__c,Oli.SAWO_TotalPrice__c);

                qliCount++;
            }

        }
        System.debug('■■■比較完了■■■');
    }

    
    
    
    
    

    /**************************************************************************
       テストデータ作成関連
     **************************************************************************/
    /**************************************************************************
       プロファイル名
     **************************************************************************/
    /** 科学＿販売部門 */
    public static final String PROFILENAME_ADMIN {get{return '科学＿販売部門';}}
    
    /**
     * テストオブジェクト作成メソッド 
     * 下記オブジェクトを作成する。
     * ・商談
     * ・商談商品
     * ・見積
     * ・見積品目名
     * ・見積帳票明細
     * ・価格表
     * ・価格表エントリ
     */
    @testSetup static void dataCreate() {
        System.debug('■■■テストデータ作成開始■■■');
        // ユーザ作成
        User user = createUser(PROFILENAME_ADMIN);
        insert user;

        System.runAs(user) {

            //トリガ停止設定
            TriggerConfig__c TriggerSetting = CreateTriggerConfig();
            insert TriggerSetting;
            System.debug('★★トリガ停止設定完了★★');

            // 職制別設定            
            ShokuseiConfig__c shokuseiSetting = CreateShokuseiConfig();
            insert shokuseiSetting;
            System.debug('★★職制別設定完了★★');
            
            //採番用レコード作成
            M_Sequence__c seq = new M_Sequence__c();
            seq.CurrentNo__c = 1;
            seq.SaibanItem__c = 'DX_商談番号';
            insert seq;
            
            //商品
            List<Product2> productList = CreateProduct2(20);
            insert productList;
            System.debug('★★商品作成完了★★');
            //価格表エントリ
            List<PricebookEntry> pbeList = CreatePricebookEntry(productList); 
            insert pbeList;
            System.debug('★★価格表エントリ作成完了★★');
            
            // 商談
            List<Opportunity> oppList = CreateOpportunities();
            insert oppList;
            System.debug('★★商談作成完了★★');         

            //商談商品
            List<OpportunityLineItem> oliList = CreateOpportunityLineItem(oppList, pbeList);
            insert oliList;
            System.debug('★★商談商品作成完了★★');            
            //見積
            List<Quote> quote = CreateQuote(oppList);
            insert quote;
            // 見積品目情報削除処理
            String test0Id = [SELECT Id FROM Quote WHERE Name = 'test0'].Id;
            List<QuoteLineItem> delQuoteLineItemList = [SELECT Id FROM QuoteLineItem WHERE QuoteId =: test0Id];
            delete delQuoteLineItemList;
            List<COWO_QuoteLineItem__c> delQuoteLineItemList2 = [SELECT Id FROM COWO_QuoteLineItem__c WHERE COWO_Quote__c =: test0Id];
            delete delQuoteLineItemList2;
            System.debug('★★見積作成完了★★');
            
            //見積品目名
            List<QuoteLineItem> qliList = CreateQuoteLineItem(quote, pbeList);
            insert qliList;
            System.debug('★★見積品目名作成完了★★');            
                
            //見積帳票明細
            List<COWO_QuoteLineItem__c> qpiList = CreateCOWO_QuoteLineItem(quote);
            insert qpiList;
            System.debug('★★見積帳票明細作成完了★★');            

        }
        System.debug('■■■テストデータ作成完了■■■');
    }
    
    
    //トリガ停止設定
    public static TriggerConfig__c CreateTriggerConfig() {
        TriggerConfig__c TrgSet = new TriggerConfig__c();
        TrgSet.Name = 'TriggerStop';
        TrgSet.TaskTrigger__c = false;
        TrgSet.LeadTrigger__c = false;
        TrgSet.OpportunityTrigger__c = false;
        TrgSet.OpportunityLineItemTrigger__c = false;
        TrgSet.QuoteTrigger__c = false;
        TrgSet.EventTrigger__c = false;
        TrgSet.AdvancedOrderTrigger__c = false;
        TrgSet.AdvancedOrderLineTrigger__c = false;
        TrgSet.AssetTrigger__c = false;
        return TrgSet;
        
    }
    
    
    // 職制別設定
    public static ShokuseiConfig__c CreateShokuseiConfig() {
        ShokuseiConfig__c SksSet = new ShokuseiConfig__c();
        SksSet.NAME = 'ZZZZ';
        SksSet.KAISHAMEI__C = '株式会社　日立ハイテクノロジーズ';
        SksSet.BUSHO1__C = '科学･医用システム事業統括本部　科学システム営業本部';
        SksSet.BUSHO2__C = '科学システム二部　科学２－２Ｇ';
        SksSet.TEL__C = '03-3504-7233';
        SksSet.FAX__C = '03-3504-7745';
        SksSet.JUSHO1__C = '東京都港区';
        SksSet.JUSHO2__C = '西新橋一丁目24番14号';
        SksSet.DELIVERYDATE__C = '４ヶ月';
        SksSet.DELIVERYLOCATION__C = '貴社御指定場所(但し、日本国内に限る)';
        SksSet.SHIHARAIJOKEN__C = '検収末日締切、翌月末日銀行振込';
        SksSet.QUOTEREMARKS__C = '消費税を含んでおりません。';
        return SksSet;
    }

    /**
     * 商談
     *
     * @param acc 取引先
     * @return 商談
     */
    public static List<Opportunity> CreateOpportunities() {
        //レコードタイプID取得
        COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        Id oppType = comTypeManager.getRecordTypeId( 'Opportunity', 'SAWO_DX_Opportunity' );

        List<Opportunity> a = new List<Opportunity>();
        for(Integer i=0;i<3;i++) {
            a.add(new Opportunity(StageName = '00',Name = OPP_NAME +i,closeDate = System.today(),RecordTypeId = oppType,SAWO_AdminSystem__c = 'ZZZZ',SAWO_Consumption_Tax__c = 10));
            system.debug('★★★商談名：' + OPP_NAME +i);
        }                  
        return a;
    }

    /**
     *商談商品
     * 
     * @param oppList 見積
     * @param PricebookEntry 価格表エントリ
     * @return 商談商品
     */
    public static List<OpportunityLineItem> CreateOpportunityLineItem(List<Opportunity> oppList,List<PricebookEntry> pbeList){
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        
        Integer i = 0;
        for(Opportunity opp : oppList){
            if(i != 1){
                for(PricebookEntry pbe : pbeList){
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.OpportunityId = opp.Id;
                    oli.PricebookEntryId = pbe.Id;
                    oli.Product2Id = pbe.Product2Id;
                    oli.Quantity = 10;
                    oli.UnitPrice = 555;
                    oliList.add(oli);
                }   
            }
            i++;
        }
        return oliList;
    }
            
                  
    /**
     * 見積
     *
     * @param oppList 商談
     * @return 見積
     */
    public static List<Quote> CreateQuote(List<Opportunity> oppList){
        List<Quote> quoteList = new List<Quote>();

        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'COWO_DX_Quote' AND SObjectType = 'Quote' LIMIT 1];
        integer i = 0;
        for(Opportunity opp : oppList){
            Quote quote = new Quote();
            System.debug('★★★見積作成商談名：' + opp.Name +'見積名：test' + i);
            quote.RecordTypeId = rt.Id;
            quote.OpportunityId = opp.Id;
            quote.Pricebook2Id = Test.getStandardPricebookId();
            quote.Name = 'test'+ i;
            quote.COWO_Customer_Adopted_Quote__c = true;
            quote.COWO_Customer_Presented_Quote__c = true;
            quote.COWO_Imprint1__c = '押印１';
            quote.COWO_Imprint2__c = '押印２';
            quote.COWO_Imprint3__c = '押印３';
            quote.Status = '見積作成完了';
            quote.COWO_Approval_Status__c = '3';
            quote.COWO_Payment_Terms__c = 'Test';
            quote.COWO_Transaction_Terms_Import_Export__c = 'Test';
            quote.COWO_Install_Adjust_Cost__c = 100;
            quote.COWO_Transport_Cost__c = 100;
            quote.COWO_Sales_Desired_Delivery_Date__c = System.Today();
            quote.COWO_Scheduled_Shipping_Date__c = System.Today();
            quote.COWO_Discount_Amount__c = 100;
            quote.COWO_Tax_Rate__c = 10;
            quote.Consumption_Tax__c = 10;
            quoteList.add(quote);
            i++;
        }
        return quoteList;
    }

    
    
    /**
     * 見積品目名
     * 
     * @param quote 見積
     * @param PricebookEntry 価格表エントリ
     * @return 見積品目名
     */
    public static List<QuoteLineItem> CreateQuoteLineItem(List<Quote> quoteList,List<PricebookEntry> pbeList){
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();

		Integer i = 0;
        for(Quote quote : quoteList){
            if(quote.Name != 'test0'){
                for(PricebookEntry pbe : pbeList){
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.QuoteId = quote.Id;
                    qli.PricebookEntryId = pbe.Id;
                    qli.Product2Id = pbe.Product2Id;
                    qli.Quantity = 10;
                    qli.UnitPrice = 555 + i;
                    qli.COWO_Rate__c = 10;
                    qli.COWO_FrontPurchasePrice__c = 111 + i;
                    qli.COWO_LocalCorporationTC__c = 222 + i;
                    qli.COWO_HHTWholesalePrice__c = 111 + i;
                    qli.COWO_MC__c = 333 + i;
                    qli.COWO_TC__c = 444 + i;
                    qli.COWO_Product_Name__c = 'test'+ i ;
                    qli.COWO_Price__c = 555 + i;
                    qli.COWO_DiscountUnitPrice__c = 555 +1;
                    qli.COWO_TotalPrice__c = (555 + i) * 10;

                    System.debug('★★★見積品目名の親見積：' + quote.name);
                    qliList.add(qli);                  
                }
            }
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
    public static List<COWO_QuoteLineItem__c> CreateCOWO_QuoteLineItem(List<Quote> quoteList){
        List<COWO_QuoteLineItem__c> qpiList = new List<COWO_QuoteLineItem__c>();

        for(Quote quote : quoteList){
        qpiList.add(new COWO_QuoteLineItem__c(COWO_Quote__c = quote.Id,COWO_Price__c = 1000,COWO_Quantity__c = '20',COWO_SubTotal__c = 3000));
        qpiList.add(new COWO_QuoteLineItem__c(COWO_Quote__c = quote.Id,COWO_Price__c = 1001,COWO_Quantity__c = '21',COWO_SubTotal__c = 3001));
        }
        return qpiList;
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
            if(i == 0){
                //1件目に自由入力製品を設定する。
                a.Name = System.Label.AP00_CONST_0001;
            }else{
            	a.Name = '商品名' + i;
            }
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
            
            pb.UnitPrice = 2000 + i;
            pb.COWO_FrontPurchasePrice__c = 1300 + i;
            pb.COWO_LocalCorporationTC__c = 1200 + i;
            pb.COWO_MC__c = 1000 + i;
            pb.COWO_TC__c = 1100 + i;                

            standardPriceList.add(pb);
            i++;
        }
        return standardPriceList;
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
        return user;
    }

}