public with sharing class QLIPickListSupportController {
    public QLIPickListSupportController() {}

    /**
     * 画面初期処理
     * @param 見積品目Id
     * @return 結果
     */
    @AuraEnabled
    public static String init(String quoteLineItemId,
                              String selectQuantityUnit,
                              String selectDetailCategory,
                              String selectDetailCategoryMTE,
                              String selectRejectionReason,
                              String selectPlantCode,
                              String selectPlantCodeMTE,
                              String selectStorageLocation,
                              String selectStorageLocationMTE,
                              String selectCurrency,
                              String selectRecordingDivision,
                              String selectProfitCenter,
                              String selectProfitCenterMTE,
                              String selectMaterialGroup1,
                              String selectSalesUnit){
                              
        //QuoteLineItem qli = [select id,COWO_quantityUnit__c,COWO_DetailCategory__c,COWO_RejectionReason__c,COWO_PlantCode__c,COWO_PlantCode_MTE__c,COWO_StorageLocation__c,COWO_StorageLocation_MTE__c,COWO_Currency__c,COWO_Recording_Division__c,COWO_ProfitCenter__c,COWO_ProfitCenter_MTE__c,COWO_MaterialGroup1__c from QuoteLineItem where Id =: quoteLineItemId];

        UTL_CO_OvcSapPlant sap = new UTL_CO_OvcSapPlant();
        //UTL_CO_OvcSapPlant.UTL_CO_PlantAll res = sap.getOrgInfo('1710', '1000', '1000');
        //UTL_CO_OvcSapPlant.UTL_CO_PlantAll res = sap.getOrgInfo('1710', '1000', qli.COWO_PlantCode__c);
        UTL_CO_OvcSapPlant.UTL_CO_PlantAll res = sap.getOrgInfo('1710', '1000', selectPlantCode);
        
        // 型式の選択リスト定義を取得する
        /*List<SerializableSelectOption> quantityUnitOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_QuantityUnit__c',(String)initPicklistMap.get('selectQuantityUnit'));//getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_QuantityUnit__c');
        List<SerializableSelectOption> detailCategoryOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_DetailCategory__c',qli.COWO_DetailCategory__c);
        List<SerializableSelectOption> rejectionReasonOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_RejectionReason__c',qli.COWO_RejectionReason__c);
        List<SerializableSelectOption> plantCodeOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'plantSTE',qli.COWO_PlantCode__c);
        List<SerializableSelectOption> plantCodeMTEOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'plantMTE',qli.COWO_PlantCode_MTE__c);//plantSelectOptions;
        List<SerializableSelectOption> storageLocationOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'storageLocSTE',qli.COWO_StorageLocation__c);//storageLocationOptionSTE;
        List<SerializableSelectOption> storageLocationMTEOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'storageLocMTE',qli.COWO_StorageLocation_MTE__c);//storageLocationOptionMTE;
        List<SerializableSelectOption> currencyOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'CurrencyISOCode',qli.COWO_Currency__c);
        List<SerializableSelectOption> recordingDivisionOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_Recording_Division__c',qli.COWO_Recording_Division__c);
        List<SerializableSelectOption> profitCenterOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'profitCenterSTE',qli.COWO_ProfitCenter__c);//profitCenterOptionSTE;
        List<SerializableSelectOption> profitCenterMTEOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'profitCenterMTE',qli.COWO_ProfitCenter_MTE__c);//profitCenterOptionMTE;
        List<SerializableSelectOption> materialGroup1Options = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_MaterialGroup1__c',qli.COWO_MaterialGroup1__c);*/ 
        List<SerializableSelectOption> quantityUnitOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_QuantityUnit__c',selectQuantityUnit);//getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_QuantityUnit__c');
        List<SerializableSelectOption> detailCategoryOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_DetailCategory__c',selectDetailCategory);
        List<SerializableSelectOption> detailCategoryMTEOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_DetailCategory_MTE__c',selectDetailCategoryMTE);
        List<SerializableSelectOption> rejectionReasonOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_RejectionReason__c',selectRejectionReason);
        List<SerializableSelectOption> plantCodeOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'plantSTE',selectPlantCode);
        List<SerializableSelectOption> plantCodeMTEOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'plantMTE',selectPlantCodeMTE);//plantSelectOptions;
        List<SerializableSelectOption> storageLocationOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'storageLocSTE',selectStorageLocation);//storageLocationOptionSTE;
        List<SerializableSelectOption> storageLocationMTEOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'storageLocMTE',selectStorageLocationMTE);//storageLocationOptionMTE;
        List<SerializableSelectOption> currencyOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'CurrencyISOCode',selectCurrency);
        List<SerializableSelectOption> recordingDivisionOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_Recording_Division__c',selectRecordingDivision);
        List<SerializableSelectOption> profitCenterOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'profitCenterSTE',selectProfitCenter);//profitCenterOptionSTE;
        List<SerializableSelectOption> profitCenterMTEOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'profitCenterMTE',selectProfitCenterMTE);//profitCenterOptionMTE;
        List<SerializableSelectOption> materialGroup1Options = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_MaterialGroup1__c',selectMaterialGroup1);
        List<SerializableSelectOption> salesUnitOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'QuoteLineItem', 'COWO_SalesUnit__c',selectSalesUnit);

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeNumberField('returnCode', 0); // 正常終了
        gen.writeObjectField('COWO_QuantityUnit__c', quantityUnitOptions);
        gen.writeObjectField('COWO_DetailCategory__c', detailCategoryOptions);
        gen.writeObjectField('COWO_DetailCategory_MTE__c', detailCategoryMTEOptions);
        gen.writeObjectField('COWO_RejectionReason__c', rejectionReasonOptions);
        gen.writeObjectField('COWO_PlantCode__c', plantCodeOptions);
        gen.writeObjectField('COWO_PlantCode_MTE__c', plantCodeMTEOptions);
        gen.writeObjectField('COWO_StorageLocation__c', storageLocationOptions);
        gen.writeObjectField('COWO_StorageLocation_MTE__c', storageLocationMTEOptions);
        gen.writeObjectField('COWO_Currency__c', currencyOptions);
        gen.writeObjectField('COWO_Recording_Division__c', recordingDivisionOptions);
        gen.writeObjectField('COWO_ProfitCenter__c', profitCenterOptions);
        gen.writeObjectField('COWO_ProfitCenter_MTE__c', profitCenterMTEOptions);
        gen.writeObjectField('COWO_MaterialGroup1__c', materialGroup1Options);
        gen.writeObjectField('COWO_SalesUnit__c', salesUnitOptions);
        gen.writeEndObject();
        
        // Get the JSON string.
        String JSONString = gen.getAsString();

        return JSONString;
    }

    /**
     * plantSTE Changeイベント処理
     * @param plantste
     * @return 結果
     */
    @AuraEnabled
    public static String getStorageSTEByPlantste(String plantste){
        System.debug('plantste' + plantste);
        /*UTL_CO_OvcSapPlant sap = new UTL_CO_OvcSapPlant();
        //UTL_CO_OvcSapPlant.UTL_CO_PlantAll res = sap.getOrgInfo('1710', '1000', '1000');
        UTL_CO_OvcSapPlant.UTL_CO_PlantAll res = sap.getOrgInfo('1710', '1000',plantste);
        List<SerializableSelectOption> storageLocationOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'storageLocSTE','');//storageLocationOptionSTE;
*/
        UTL_CO_OvcSapPlant sap = new UTL_CO_OvcSapPlant();
        UTL_CO_OvcSapPlant.UTL_CO_PlantAll res = sap.getOrgInfo('1710', '1000',plantste);
        List<SerializableSelectOption> storageLocationOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'storageLocSTE','');//storageLocationOptionSTE;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeNumberField('returnCode', 0); // 正常終了
        gen.writeObjectField('COWO_StorageLocation__c', storageLocationOptions);
        gen.writeEndObject();

        // Get the JSON string.
        String JSONString = gen.getAsString();

        return JSONString;
        

    }

    private static Map<String, String> picklistValues(String objectName, String fieldName) {
        Map<String, String> values = new Map<String, String>{};

        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    if(fieldName.equals('CurrencyISOCode')){
                        values.put(entry.getValue(), entry.getValue() +':'+ entry.getLabel());
                    }else {
                        values.put(entry.getValue(), entry.getLabel());
                    }
                }
            }
        }

        return values;
    }

    private static Map<String, String> pickS4listValues(UTL_CO_OvcSapPlant.UTL_CO_PlantAll plantAll,String fieldName) {
        Map<String, String> values = new Map<String, String>{};

        List<UTL_CO_OvcSapPlant.UTL_CO_Plant> plantList = plantAll.plantMte;
        List<UTL_CO_OvcSapPlant.UTL_CO_StorageLocation> storageLocSteList = plantAll.storageLocSte;
        List<UTL_CO_OvcSapPlant.UTL_CO_ProfitCenter> profitCenterMTEList = plantAll.profitCenterMte;
        List<UTL_CO_OvcSapPlant.UTL_CO_ProfitCenter> profitCenterSTEList = plantAll.profitCenterSte;
        List<UTL_CO_OvcSapPlant.UTL_CO_StorageLocation> storageLocationList = new List<UTL_CO_OvcSapPlant.UTL_CO_StorageLocation>();
        if(fieldName.equals('plantMTE')){
            for(UTL_CO_OvcSapPlant.UTL_CO_Plant plant : plantList){
                values.put(plant.code, plant.code + ':' + plant.text);
            }
        }else if(fieldName.equals('plantSTE')){
                values.put('1000', '1000:日立ハイテク（本社）');
                values.put('1010', '1010:日立ハイテク（那珂）');
                values.put('1020', '1020:日立ハイテク（笠戸）');
                values.put('1030', '1030:日立ハイテク（大牟田）');
        }else if(fieldName.equals('storageLocMTE')){
            storageLocationList = plantList[0].storageLocations;
            for(UTL_CO_OvcSapPlant.UTL_CO_StorageLocation storageLocation : storageLocationList){
                values.put(storageLocation.code,storageLocation.code  + ':' + storageLocation.text);
            }
        }else if(fieldName.equals('storageLocSTE')){
            for(UTL_CO_OvcSapPlant.UTL_CO_StorageLocation storageLocationSTE : storageLocSteList){
                values.put(storageLocationSTE.code,storageLocationSTE.code  + ':' + storageLocationSTE.text);
            }
        }
        else if(fieldName.equals('profitCenterMTE')){
            for(UTL_CO_OvcSapPlant.UTL_CO_ProfitCenter profitCenterMTE : profitCenterMTEList){
                values.put(profitCenterMTE.code,profitCenterMTE.code  + ':' + profitCenterMTE.text);
            }
        }else if(fieldName.equals('profitCenterSTE')){
            for(UTL_CO_OvcSapPlant.UTL_CO_ProfitCenter profitCenterSTE : profitCenterSTEList){
                values.put(profitCenterSTE.code,profitCenterSTE.code  + ':' + profitCenterSTE.text);
            }
        }
        return values;
    }

    /*public static List<SerializableSelectOption> getSalutationPicklist(SerializableSelectOption selectOption, String objectName, String fieldName) {
        List<SerializableSelectOption> selectOptions = new List<SerializableSelectOption>();
        if(selectOption != null){
            selectOptions.add(selectOption);
        }

        Map<String, String> salutationValueLabels = picklistValues(objectName, fieldName);
        for (String value : salutationValueLabels.keySet()) {
            selectOptions.add(new SerializableSelectOption(value, salutationValueLabels.get(value)));
        }

        return selectOptions;
    }*/

    private static List<SerializableSelectOption> getSalutationPicklist(SerializableSelectOption selectOption, String objectName, String fieldName,String selectValue) {
        List<SerializableSelectOption> selectOptions = new List<SerializableSelectOption>();
        if(selectOption != null){
            selectOptions.add(selectOption);
        }
        Map<String, String> salutationValueLabels = picklistValues(objectName, fieldName);
        for (String value : salutationValueLabels.keySet()) {
            Boolean selected = false;
            if(selectValue != null && value.equals(selectValue)){
                selected = true;
            }
            selectOptions.add(new SerializableSelectOption(value, salutationValueLabels.get(value),selected));
        }

        return selectOptions;
    }

    /*public static List<SerializableSelectOption> getS4SalutationPicklist(SerializableSelectOption selectOption, UTL_CO_OvcSapPlant.UTL_CO_PlantAll plantAll,String fieldName) {
        List<SerializableSelectOption> selectOptions = new List<SerializableSelectOption>();
        if(selectOption != null){
            selectOptions.add(selectOption);
        }
        Map<String, String> salutationValueLabels = pickS4listValues(plantAll,fieldName);
        for (String value : salutationValueLabels.keySet()) {
            selectOptions.add(new SerializableSelectOption(value, salutationValueLabels.get(value)));
        }
        return selectOptions;
    }*/

    private static List<SerializableSelectOption> getS4SalutationPicklist(SerializableSelectOption selectOption, UTL_CO_OvcSapPlant.UTL_CO_PlantAll plantAll,String fieldName,String selectValue) {
        List<SerializableSelectOption> selectOptions = new List<SerializableSelectOption>();
        if(selectOption != null){
            selectOptions.add(selectOption);
        }
        Map<String, String> salutationValueLabels = pickS4listValues(plantAll,fieldName);
        for (String value : salutationValueLabels.keySet()) {
            Boolean selected = false;
            if(selectValue != null && value.equals(selectValue)){
                selected = true;
            }
            selectOptions.add(new SerializableSelectOption(value, salutationValueLabels.get(value),selected));
        }
        return selectOptions;
    }
    
    public class SerializableSelectOption {

        public String label {get; set;}
        public String value {get; set;}
        public Boolean selected{get; set;}

        public SerializableSelectOption(SelectOption so) {
            this.label = so.getLabel();
            this.value = so.getValue();
            this.selected = false;
        }

        public SerializableSelectOption(PicklistEntry pe) {
            this.label = pe.getLabel();
            this.value = pe.getValue();
            this.selected = false;
        }

        public SerializableSelectOption(String label, String value,Boolean selected) {
            this.label = label;
            this.value = value;
            this.selected = selected;
        }
    }
}