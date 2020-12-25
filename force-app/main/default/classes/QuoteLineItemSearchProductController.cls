public with sharing class QuoteLineItemSearchProductController {
    
    public static List<String> TARGET_FIELDS = new List<String>{
          'Product2.Id'
        , 'Product2.CountryMode__c'
        , 'Product2.Katashiki__c'
        , 'Product2.Name'
        , 'Product2.ProductCode'
        , 'Product2.SupplierName__c'
        , 'Product2.PartsNo__c'
        , 'Product2.Description'
        , 'Product2.b__c'
        , 'Product2.PartitionPrice__c'
        , 'Product2.Q__c'
        , 'Product2.TC__c'
        , 'Product2.MC__c'
        , 'Product2.StructureSortNo__c'
        , 'Product2.CurrencyIsoCode'
        , 'UnitPrice'
        , 'PartitionPrice__c'
        , 'Pricebook2EntryKey__c'
        , 'Supplier_Amount__c'
        , 'Saiteibaika__c'
        , 'Teika__c'
        , 'COWO_LocalCorporationTC__c'
        , 'COWO_FrontPurchasePrice__c'
        , 'COWO_TC__c'
        , 'COWO_MC__c'
        , 'Product2.SAWO_OrderNnumber__c'
        , 'Product2.SAWO_SalesUnit__c'
        , 'Product2.SAWO_NoDiscountFlg__c'
    };

    public static SearchCondition condition{ get;set; } 
    
    /**
     * 画面初期処理
     * @param なし
     * @return 結果
     */
    @AuraEnabled
    public static String init(String quoteId,String pricebook2Id){

        Quote quote = [SELECT CurrencyIsoCode, Pricebook2Id FROM Quote WHERE Id = :quoteId];
        Pricebook2 pb2 = [select name from Pricebook2 where id =: pricebook2Id];
        List<COWO_First_HierarchyManage__mdt> firstHierarchyMDTList = [select COWO_FirstHierarchyText__c,COWO_SecondHierarchyText__c from COWO_First_HierarchyManage__mdt where COWO_PriceBook_Name__c =: pb2.name];
        List<COWO_Second_HierarchyManage__mdt> secondHierarchyMDTList = [select COWO_ThirdHierarchyText__c,COWO_SecondHierarchyText__c from COWO_Second_HierarchyManage__mdt where COWO_PriceBook_Name__c =: pb2.name];
        Set<String> firstHierarchyMDTSet = new Set<String>();
        //Set<String> secondHierarchyMDTSet =new Set<String>();
        //Map<String,List<String>> secondHierarchyOptionMap = new Map<String,List<String>>();
        //Map<String,List<String>> thirdHierarchyOptionMap = new Map<String,List<String>>();
        Map<String,List<SerializableSelectOption>> secondHierarchyOptionMap = new Map<String,List<SerializableSelectOption>>();
        Map<String,List<SerializableSelectOption>> thirdHierarchyOptionMap = new Map<String,List<SerializableSelectOption>>();
        if(firstHierarchyMDTList.size() > 0){
            for(COWO_First_HierarchyManage__mdt firstHierarchyMDT : firstHierarchyMDTList){
                firstHierarchyMDTSet.add(firstHierarchyMDT.COWO_FirstHierarchyText__c);
                if(firstHierarchyMDT.COWO_SecondHierarchyText__c != null){
                    List<String> secondHierarchyList = firstHierarchyMDT.COWO_SecondHierarchyText__c.split(',');
                    Set<String> secondHierarchySet = new Set<String>();
                    for(String secondHierarchy : secondHierarchyList){
                        secondHierarchySet.add(secondHierarchy);
                    }
                    List<SerializableSelectOption> secondHierarchySelectOptionList = getSalutationPicklist(secondHierarchySet);
                    secondHierarchyOptionMap.put(firstHierarchyMDT.COWO_FirstHierarchyText__c,secondHierarchySelectOptionList);
                }
            }
            if(secondHierarchyMDTList.size() > 0){
                for(COWO_Second_HierarchyManage__mdt secondHierarchyMDT : secondHierarchyMDTList){
                    //secondHierarchyMDTSet.add(secondHierarchyMDT.COWO_SecondHierarchyText__c);
                    if(secondHierarchyMDT.COWO_ThirdHierarchyText__c != null){
                        List<String> thirdHierarchyList = secondHierarchyMDT.COWO_ThirdHierarchyText__c.split(',');
                        Set<String> thirdHierarchySet = new Set<String>();
                        for(String thirdHierarchy : thirdHierarchyList){
                            thirdHierarchySet.add(thirdHierarchy);
                        }
                        List<SerializableSelectOption> thirdHierarchySelectOptionList = getSalutationPicklist(thirdHierarchySet);
                        thirdHierarchyOptionMap.put(secondHierarchyMDT.COWO_SecondHierarchyText__c,thirdHierarchySelectOptionList);
                    }
                }
            }

            List<SerializableSelectOption> firstHierarchyOptionsList = getSalutationPicklist(firstHierarchyMDTSet);
            List<SerializableSelectOption>  secondHierarchyOptionsList = new List<SerializableSelectOption>();//getSalutationPicklist(secondHierarchySet);
            List<SerializableSelectOption>  thirdHierarchyOptionsList = new List<SerializableSelectOption>();//getSalutationPicklist(thirdHierarchySet);
            System.debug('firstHierarchyOptionsList' + firstHierarchyOptionsList);
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeNumberField('returnCode', 0); // 正常終了
            //gen.writeObjectField('Katashiki__c', selectOptionsList);
            gen.writeObjectField('firstHierarchyOptions', firstHierarchyOptionsList);
            gen.writeObjectField('secondHierarchyOptions', secondHierarchyOptionsList);
            gen.writeObjectField('thirdHierarchyOptions', thirdHierarchyOptionsList);
            gen.writeObjectField('secondHierarchyMap', secondHierarchyOptionMap);
            gen.writeObjectField('thirdHierarchyMap', thirdHierarchyOptionMap);
            gen.writeStringField('currencyIsoCode', quote.currencyIsoCode);
            gen.writeEndObject();

            
            // Get the JSON string.
            String JSONString = gen.getAsString();

            return JSONString;
        }else{
            List<pricebookentry> pricebookentryList = [select SAWO_FirstHierarchy__c, SAWO_SecondHierarchy__c,SAWO_ThirdHierarchy__c from pricebookentry  where Pricebook2Id =: pricebook2Id order by SAWO_FirstHierarchy__c, SAWO_SecondHierarchy__c,SAWO_ThirdHierarchy__c]; 
            Set<String> firstHierarchySet = new Set<String>();
            Set<String> secondHierarchySet = new Set<String>();
            Set<String> thirdHierarchySet = new Set<String>();
            if(pricebookentryList != null){
                for(pricebookentry p : pricebookentryList){
                    if(p.SAWO_FirstHierarchy__c != null){
                        firstHierarchySet.add(p.SAWO_FirstHierarchy__c);
                    }
                    if(p.SAWO_SecondHierarchy__c != null){
                        secondHierarchySet.add(p.SAWO_SecondHierarchy__c);
                    }
                    if(p.SAWO_ThirdHierarchy__c != null){
                        thirdHierarchySet.add(p.SAWO_ThirdHierarchy__c);
                    }
                }
            }
            Boolean isFirstHierarchyExist = false;
            Boolean isSecondHierarchyExist = false;
            Boolean isThirdHierarchyExist = false;
            if(firstHierarchySet.size() > 0){
                isFirstHierarchyExist = true;
            }
            if(secondHierarchySet.size() > 0){
                isSecondHierarchyExist = true;
            }
            if(thirdHierarchySet.size() > 0){
                isThirdHierarchyExist = true;
            }
            system.debug(firstHierarchySet);
            system.debug(secondHierarchySet);
            system.debug(thirdHierarchySet);
    
            List<SerializableSelectOption> firstHierarchyOptionsList = getSalutationPicklist(firstHierarchySet);
            List<SerializableSelectOption>  secondHierarchyOptionsList = getSalutationPicklist(secondHierarchySet);
            List<SerializableSelectOption>  thirdHierarchyOptionsList = getSalutationPicklist(thirdHierarchySet);

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeNumberField('returnCode', 0); // 正常終了
            gen.writeObjectField('firstHierarchyOptions', firstHierarchyOptionsList);
            gen.writeObjectField('secondHierarchyOptions', secondHierarchyOptionsList);
            gen.writeObjectField('thirdHierarchyOptions', thirdHierarchyOptionsList);
            gen.writeBooleanField('isFirstHierarchyExist',isFirstHierarchyExist);
            gen.writeBooleanField('isSecondHierarchyExist',isSecondHierarchyExist);
            gen.writeBooleanField('isThirdHierarchyExist',isThirdHierarchyExist);
            gen.writeStringField('currencyIsoCode', quote.currencyIsoCode);
            gen.writeEndObject();
    
            
            // Get the JSON string.
            String JSONString = gen.getAsString();
    
            return JSONString;

        }
    }
    
    /**
     * 画面入力条件により、商品を検索する
     * @param countryMode__c:検索条件 国コード
     * @param katashiki__c:検索条件 型式
     * @param productCalledName:検索条件 商品略称
     * @param structureSortNo__c:検索条件 構成順
     * @param itemName:検索条件 商品名
     * @param partsNo:検索条件 パーツNo.
     * @return 検索結果
     */
    @AuraEnabled
    public static String searchProduct(String quoteId,
                                       String pricebook2Id, 
                                       String firstLayer, 
                                       String secondLayer, 
                                       String thaadLayer, 
                                       String product2_Name, 
                                       String partsNo,
                                       Boolean isPSGHHTUser){

        // // 異常終了時のロールバックポイント
        // Savepoint sp = Database.setSavepoint();
        system.debug(quoteId);
		Quote quote = [SELECT CurrencyIsoCode FROM Quote WHERE Id = :quoteId];
        system.debug('quote.CurrencyIsoCode' + quote.CurrencyIsoCode);
        String currencyIsoCode = quote.CurrencyIsoCode;                               
                                           
        // try{
            // 検索条件を設定する
            condition = new SearchCondition(pricebook2Id, firstLayer, secondLayer, thaadLayer,  product2_Name, partsNo, currencyIsoCode);

            // 件数チェック
            Integer count = doCount();
            System.debug('★★★★★ count ★★★★★' + count);
            // Integer count = [select count() 
            //                  from Product2
            //                  where CountryMode__c =: countryMode 
            //                  and Katashiki__c =: katashiki
            //                  and StructureSortNo__c =: structureSortNo];


            // JSONGenerator gen = JSON.createGenerator(true);
            // gen.writeStartObject();
            // gen.writeNumberField('returnCode', 9); // 警告終了
            // gen.writeObjectField('returnMsg', condition);
            // gen.writeEndObject();
            
            // // Get the JSON string.
            // String jsonString = gen.getAsString();
            // return jsonString;
        
            // ０件の場合
            if (count == 0){
                String resultString = doZeroEnd();
                return resultString;
            }

            // 検索を行う
            List<PricebookEntry> pricebookEntryList = doSearch();
            List<QuoteLineItemSearchProducts> searchProducts = new List<QuoteLineItemSearchProducts> ();
            for (PricebookEntry pricebookEntry : pricebookEntryList) {
                QuoteLineItemSearchProducts searchProduct = new QuoteLineItemSearchProducts();
                searchProduct.product2_Id = pricebookEntry.Product2.Id;
                searchProduct.product2_CountryMode = pricebookEntry.Product2.CountryMode__c;
                searchProduct.product2_Katashiki = pricebookEntry.Product2.Katashiki__c;
                searchProduct.product2_ItemName = pricebookEntry.Product2.Name;
                searchProduct.product2_ProductCode = pricebookEntry.Product2.ProductCode;
                searchProduct.product2_SupplierName = pricebookEntry.Product2.SupplierName__c;
                searchProduct.product2_PartsNo = pricebookEntry.Product2.PartsNo__c;
                searchProduct.product2_Description = pricebookEntry.Product2.Description;
                searchProduct.product2_b = pricebookEntry.Product2.b__c;
                searchProduct.product2_PartitionPrice = pricebookEntry.Product2.PartitionPrice__c;
                searchProduct.product2_Q = pricebookEntry.Product2.Q__c;
                searchProduct.product2_TC = pricebookEntry.Product2.TC__c;
                searchProduct.product2_MC = pricebookEntry.Product2.MC__c;
                searchProduct.product2_StructureSortNo = pricebookEntry.Product2.StructureSortNo__c;
                searchProduct.product2_CurrencyIsoCode = pricebookEntry.Product2.CurrencyIsoCode;
                searchProduct.unitPrice = pricebookEntry.UnitPrice;
                searchProduct.partitionPrice = pricebookEntry.PartitionPrice__c;
                searchProduct.pricebook2EntryKey = pricebookEntry.Pricebook2EntryKey__c;
                searchProduct.supplier_Amount = pricebookEntry.Supplier_Amount__c;
                searchProduct.saiteibaika = pricebookEntry.Saiteibaika__c;
                searchProduct.teika = pricebookEntry.Teika__c;
                searchProduct.localCorporationTC = pricebookEntry.COWO_LocalCorporationTC__c;
                searchProduct.frontPurchasePrice = pricebookEntry.COWO_FrontPurchasePrice__c;
                searchProduct.pricebookentry_TC = pricebookEntry.COWO_TC__c;
                searchProduct.pricebookentry_MC = pricebookEntry.COWO_MC__c;
                searchProduct.subtotal = pricebookEntry.UnitPrice != null ? pricebookEntry.UnitPrice : 0;
                searchProduct.display_TC = isPSGHHTUser ? pricebookEntry.Product2.TC__c : 0;
                searchProduct.display_MC = isPSGHHTUser ? pricebookEntry.Product2.MC__c : 0;
                searchProduct.product2_OrderNumber = pricebookEntry.Product2.SAWO_OrderNnumber__c;
                searchProduct.product2_SalesUnit = pricebookEntry.Product2.SAWO_SalesUnit__c;
                searchProduct.product2_NoDiscountFlg = pricebookEntry.Product2.SAWO_NoDiscountFlg__c;
                searchProducts.add(searchProduct);
            }
            // List<Product2> product2s = [select 
            //                                 Id, 
            //                                 CountryMode__c,
            //                                 Katashiki__c,
            //                                 ItemName__c,
            //                                 ProductCode,
            //                                 SupplierName__c,
            //                                 PartsNo__c,
            //                                 Description,
            //                                 b__c,
            //                                 PartitionPrice__c,
            //                                 Q__c,
            //                                 TC__c,
            //                                 MC__c,
            //                                 StructureSortNo__c
            //                             from Product2
            //                             where CountryMode__c =: countryMode 
            //                             and Katashiki__c =: katashiki
            //                             and StructureSortNo__c =: structureSortNo
            //                             limit 200];

            // 正常終了の場合
            String resultString = doNormalEnd(searchProducts, count);
            return resultString;
            
        // } catch (Exception e){

        //     // 異常終了する場合、ロールバックする
        //     Database.rollback(sp);
            
        //     JSONGenerator gen = JSON.createGenerator(true);
        //     gen.writeStartObject();
        //     gen.writeNumberField('returnCode', 9); // 異常終了
        //     gen.writeObjectField('returnMsg', e.getMessage());
        //     gen.writeEndObject();
            
        //     // Get the JSON string.
        //     String jsonString = gen.getAsString();
        //     return jsonString;
        // }
    }

    /**
     * ０件の場合
     * @param なし
     * @return 処理結果
     */
    private static String doZeroEnd(){
        System.debug('★★★★★ 正常終了処理 start ★★★★★');

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeNumberField('returnCode', 6); // 警告終了
        gen.writeObjectField('returnMsg', System.Label.Product2Search_NoDataFetch);
        gen.writeObjectField('count', 0);
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonString = gen.getAsString();
        
        System.debug('★★★★★ jsonString ★★★★★' + jsonString);
        
        System.debug('★★★★★ 正常終了処理 end ★★★★★');

        return jsonString;
    }

    /**
     * 正常終了処理
     * @param quoteLineItemSearchProductList:データリスト
     * @return 処理結果
     */
    private static String doNormalEnd(List<QuoteLineItemSearchProducts> quoteLineItemSearchProductList, Integer count){
        System.debug('★★★★★ 正常終了処理 start ★★★★★');

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeNumberField('returnCode', 0); // 正常終了
        if (count > 200){
            // 200件以上合致する場合、警告メッセージを表示する
            gen.writeObjectField('returnMsg', System.Label.Product2Search_FetchDataMoreThan200);
        } else{
            gen.writeObjectField('returnMsg', System.Label.Product2Search_NormalEnd);
        }
        gen.writeObjectField('data', quoteLineItemSearchProductList);
        gen.writeNumberField('count', count);
        gen.writeEndObject();
        
        // Get the JSON string.
        String jsonString = gen.getAsString();
        
        System.debug('★★★★★ jsonString ★★★★★' + jsonString);
        
        System.debug('★★★★★ 正常終了処理 end ★★★★★');

        return jsonString;
    }

    public static Map<String, String> convPicklistValues(String objectName, String fieldName) {
        Map<String, String> values = new Map<String, String>{};

        List<Schema.DescribeSobjectResult> resultList = Schema.describeSObjects(new List<String>{objectName});
        
        for(Schema.DescribeSobjectResult res : resultList) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }

        return values;
    }

    public static List<SerializableSelectOption> getSalutationPicklist(SerializableSelectOption selectOption, String objectName, String fieldName) {
        List<SerializableSelectOption> selectOptionsList = new List<SerializableSelectOption>();
        if(selectOption != null){
            selectOptionsList.add(selectOption);
        }

        Map<String, String> salutationValueLabels = convPicklistValues(objectName, fieldName);
        for (String value : salutationValueLabels.keySet()) {
            selectOptionsList.add(new SerializableSelectOption(value, salutationValueLabels.get(value)));
        }

        return selectOptionsList;
    }

    public static List<SerializableSelectOption> getSalutationPicklist(Set<String> targetFieldSet) {
        List<SerializableSelectOption> selectOptionsList = new List<SerializableSelectOption>();
        selectOptionsList.add(new SerializableSelectOption('--',''));
        for (String value : targetFieldSet) {
            selectOptionsList.add(new SerializableSelectOption(value, value));
        }
        return selectOptionsList;
    }
    
    public static Integer doCount(){
        String soqlCountQuery = condition.getSoqlCountQuery();
        System.debug('★★★★★ soqlCountQuery ★★★★★' + soqlCountQuery);
        return database.countQuery(soqlCountQuery);
    }
    
    public static List<SObject> doSearch(){
        String soqlQuery = condition.getSoqlQuery();
        System.debug('★★★★★ soqlQuery ★★★★★' + soqlQuery);
        return database.query(soqlQuery);
    }

    public Class SearchCondition {

        public PricebookEntry obj {get;set;} 

        public String sortkey { get;set; }

        public String order { get;set; }

        private String pricebook2Id;

        //private String countryMode;

        // private String katashiki;

        // private String productCalledName;

        // private String structureSortNo;

        private String firstLayer;

        private String secondLayer;

        private String thaadLayer;

        private String product2_Name;

        private String partsNo;

        private String currencyIsoCode;

        public SearchCondition(String pricebook2Id,
                               String firstLayer, 
                               String secondLayer, 
                               String thaadLayer, 
                               String product2_Name, 
                               String partsNo,
                               String currencyIsoCode){
            this.pricebook2Id = pricebook2Id;
            this.firstLayer = firstLayer;
            this.secondLayer = secondLayer;
            this.thaadLayer = thaadLayer;
            this.product2_Name = product2_Name.trim();
            this.partsNo = partsNo.trim();
            this.currencyIsoCode = currencyIsoCode;                       

            this.obj = new PricebookEntry();
            sortkey = 'Product2.StructureSortNo__c';
            order = 'ASC';
        }
  
        public String getSoqlCountQuery(){
            List<String> param = new String[]{ getWhere() };
            return String.format('SELECT COUNT() FROM PricebookEntry {0}', param);
        }
  
        public String getSoqlQuery(){
            List<String> param = new String[]{ getFieldList(), getWhere(), getOrder() };
            return String.format('SELECT {0} FROM PricebookEntry {1}{2} LIMIT 200', param);
        }
        
        private String getFieldList(){
            return String.join(TARGET_FIELDS, ',');
        }

        private String getWhere(){
            List<String> param = new String[]{ };
            // String ani = ApexPages.currentPage().getParameters().get('ANI');
            
            // String queryAni = escape(ani);
                
            // param.add('Phone like \'%' + queryAni + '\'');
            // param.add('TelNo1__c like \'%' + queryAni + '\'');
            // param.add('TelNo2__c like \'%' + queryAni + '\'');
			System.debug('★' + pricebook2Id);
            // 検索条件を設定する
            String pricebook2Id = escape(pricebook2Id);
            // String countryMode = escape(countryMode);
            // String katashiki = escape(katashiki);
            // String productCalledName = escape(productCalledName);
            // String structureSortNo = escape(structureSortNo);
            String firstLayer = escape(firstLayer);
            String secondLayer = escape(secondLayer);
            String thaadLayer = escape(thaadLayer);
            String product2_Name = escape(product2_Name);
            String partsNo = escape(partsNo);
			String currencyIsoCode = escape(currencyIsoCode);
            
            if(String.isNotBlank(pricebook2Id)){
                param.add('Pricebook2Id = \'' + pricebook2Id + '\'');
            }
            // if(String.isNotBlank(countryMode)){
            //     param.add('Product2.CountryMode__c = \'' + countryMode + '\'');
            // }
            // if(String.isNotBlank(katashiki)){
            //     param.add('Product2.Katashiki__c = \'' + katashiki + '\'');
            // }
            // if(String.isNotBlank(productCalledName)){
            //     param.add('Product2.ProductCalledName__c like \'%' + productCalledName + '%\'');
            // }
            // if(String.isNotBlank(structureSortNo)){
            //     param.add('Product2.StructureSortNo__c like \'%' + structureSortNo + '%\'');
            // }
            if(String.isNotBlank(firstLayer)){
                param.add('Product2.SAWO_FirstHierarchy__c = \'' + firstLayer + '\'');
            }
            if(String.isNotBlank(secondLayer)){
                param.add('Product2.SAWO_SecondHierarchy__c = \'' + secondLayer + '\'');
            }
            if(String.isNotBlank(thaadLayer)){
                param.add('Product2.SAWO_ThirdHierarchy__c = \'' + thaadLayer + '\'');
            }
            if(String.isNotBlank(product2_Name)){
                param.add('Product2.Name like \'%' + product2_Name + '%\'');
            }
            if(String.isNotBlank(partsNo)){
                param.add('Product2.PartsNo__c like \'%' + partsNo + '%\'');
            }
            if(String.isNotBlank(currencyIsoCode)){
                param.add('Product2.currencyIsoCode = \'' + currencyIsoCode + '\'');
            }
            if(String.isNotBlank(currencyIsoCode)){
                param.add('currencyIsoCode = \'' + currencyIsoCode + '\'');
            }
            param.add('isActive = true ');

            if(param.isEmpty()){
                return '';
            }
            return 'WHERE ' + String.join(param, ' AND ');
        }

        private String getOrder(){
            List<String> paramList = new String[]{ sortkey, order };
            return String.format('ORDER BY {0} {1}', paramList);
        }

        // public void setOrderReverse(){
        //     if(this.order == 'DESC'){
        //         this.order = 'ASC';
        //     }else{
        //         this.order = 'DESC';
        //     }
        // }

        // public String sortOrderToString(){
        //     if(this.order == 'DESC'){
        //         return '↓';
        //     }
        //     return '↑';
        // }

        private String escape(String str){
            String retStr = String.escapeSingleQuotes(str);
            retStr = retStr.replace('%', '\\%');
            // retStr = retStr.replace('_', '\\_');
            return retStr;
        }
    }

    // public String getSortKey(){
    //     return this.condition.sortkey;
    // }

    // public String getSortOrder(){
    //     return this.condition.sortOrderToString();
    // }

    public class SerializableSelectOption {

        public String label {get; set;}
        public String value {get; set;}

        public SerializableSelectOption(SelectOption so) {
            this.label = so.getLabel();
            this.value = so.getValue();
        }

        public SerializableSelectOption(PicklistEntry pe) {
            this.label = pe.getLabel();
            this.value = pe.getValue();
        }

        public SerializableSelectOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    public class QuoteLineItemSearchProducts {
        public String product2_Id {get;set;}
        public String product2_CountryMode {get;set;}
        public String product2_Katashiki {get;set;}
        public String product2_ItemName {get;set;}
        public String product2_ProductCode {get;set;}
        public String product2_SupplierName {get;set;}
        public String product2_PartsNo {get;set;}
        public String product2_Description {get;set;}
        public Decimal product2_b {get;set;}
        public Decimal product2_PartitionPrice {get;set;}
        public Decimal product2_Q {get;set;}
        public Decimal product2_TC {get;set;}
        public Decimal product2_MC {get;set;}
        public String product2_StructureSortNo {get;set;}
        public String product2_CurrencyIsoCode {get;set;}
        public Decimal unitPrice {get;set;}
        public Decimal partitionPrice {get;set;}
        public String pricebook2EntryKey {get;set;}
        public Decimal supplier_Amount {get;set;}
        public Decimal saiteibaika {get;set;}
        public Decimal teika {get;set;}
        public Decimal localCorporationTC {get;set;}
        public Decimal frontPurchasePrice {get;set;}
        public Decimal pricebookentry_TC {get;set;}
        public Decimal pricebookentry_MC {get;set;}
        public Decimal subtotal{get;set;}
        public Decimal display_TC {get;set;}
        public Decimal display_MC {get;set;}
        public Decimal product2_OrderNumber {get;set;}
        public String product2_SalesUnit {get;set;}
        public Boolean product2_NoDiscountFlg {get;set;}
    }
}