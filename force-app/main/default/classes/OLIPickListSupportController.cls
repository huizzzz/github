public with sharing class OLIPickListSupportController {
    public OLIPickListSupportController() {}

    /**
     * 画面初期処理
     * @param なし
     * @return 結果
     */
    @AuraEnabled
    public static String init(String opportunityLineItemId,
                              String currencyISOCode,
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
        System.debug('init');

        UTL_CO_OvcSapPlant sap = new UTL_CO_OvcSapPlant();
        UTL_CO_OvcSapPlant.UTL_CO_PlantAll res = sap.getOrgInfo('1710', '1000', selectPlantCode);
        System.debug('selectPlantCode' + selectPlantCode);

        // 型式の選択リスト定義を取得する
        List<SerializableSelectOption> quantityUnitOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'OpportunityLineItem', 'SAWO_QuantityUnit__c',selectQuantityUnit);
        List<SerializableSelectOption> detailCategoryOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'OpportunityLineItem', 'SAWO_DetailCategory__c',selectDetailCategory);
        List<SerializableSelectOption> detailCategoryMTEOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'OpportunityLineItem', 'SAWO_DetailCategory_MTE__c',selectDetailCategoryMTE);
        List<SerializableSelectOption> rejectionReasonOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'OpportunityLineItem', 'SAWO_RejectionReason__c',selectRejectionReason);
        List<SerializableSelectOption> plantCodeOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'plantSTE',selectPlantCode);
        List<SerializableSelectOption> plantCodeMTEOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'plantMTE',selectPlantCodeMTE);//plantSelectOptions;
        List<SerializableSelectOption> storageLocationOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'storageLocSTE',selectStorageLocation);//storageLocationOptionSTE;
        List<SerializableSelectOption> storageLocationMTEOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'storageLocMTE',selectStorageLocationMTE);//storageLocationOptionMTE;
        List<SerializableSelectOption> currencyOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'OpportunityLineItem', 'CurrencyISOCode',selectCurrency);
        List<SerializableSelectOption> recordingDivisionOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'OpportunityLineItem', 'SAWO_Recording_Division__c',selectRecordingDivision);
        List<SerializableSelectOption> profitCenterOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'profitCenterSTE',selectProfitCenter);//profitCenterOptionSTE;
        List<SerializableSelectOption> profitCenterMTEOptions = getS4SalutationPicklist(new SerializableSelectOption('', '--',FALSE), res, 'profitCenterMTE',selectProfitCenterMTE);//profitCenterOptionMTE;
        List<SerializableSelectOption> materialGroup1Options = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'OpportunityLineItem', 'SAWO_MaterialGroup1__c',selectMaterialGroup1);
        List<SerializableSelectOption> salesUnitOptions = getSalutationPicklist(new SerializableSelectOption('', '--',FALSE), 'OpportunityLineItem', 'SAWO_SalesUnit__c',selectSalesUnit);

        // 画面表示フォーマット
        system.debug('currencyCode ' + CurrencyIsoCode );
        COWO_CurrencyIsoCode__mdt currencymdt = [SELECT Id, DeveloperName, COWO_Digits__c, COWO_CurrencyMark__c, COWO_DisplayFormat__c, COWO_DigitsInput__c FROM COWO_CurrencyIsoCode__mdt where DeveloperName =: CurrencyIsoCode limit 1];
        String format = currencymdt.COWO_DisplayFormat__c;

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeNumberField('returnCode', 0); // 正常終了
        gen.writeObjectField('SAWO_QuantityUnit__c', quantityUnitOptions);
        gen.writeObjectField('SAWO_DetailCategory__c', detailCategoryOptions);
        gen.writeObjectField('SAWO_DetailCategory_MTE__c', detailCategoryMTEOptions);
        gen.writeObjectField('SAWO_RejectionReason__c', rejectionReasonOptions);
        gen.writeObjectField('SAWO_PlantCode__c', plantCodeOptions);
        gen.writeObjectField('SAWO_PlantCode_MTE__c', plantCodeMTEOptions);
        gen.writeObjectField('SAWO_StorageLocation__c', storageLocationOptions);
        gen.writeObjectField('SAWO_StorageLocation_MTE__c', storageLocationMTEOptions);
        gen.writeObjectField('SAWO_Currency__c', currencyOptions);
        gen.writeObjectField('SAWO_Recording_Division__c', recordingDivisionOptions);
        gen.writeObjectField('SAWO_ProfitCenter__c', profitCenterOptions);
        gen.writeObjectField('SAWO_ProfitCenter_MTE__c', profitCenterMTEOptions);
        gen.writeObjectField('SAWO_MaterialGroup1__c', materialGroup1Options);
        gen.writeObjectField('SAWO_SalesUnit__c', salesUnitOptions);
        gen.writeStringField('format', format);
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
        gen.writeObjectField('SAWO_StorageLocation__c', storageLocationOptions);
        gen.writeEndObject();

        // Get the JSON string.
        String JSONString = gen.getAsString();

        return JSONString;
        

    }

    public static Map<String, String> picklistValues(String objectName, String fieldName) {
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

    public static Map<String, String> pickS4listValues(UTL_CO_OvcSapPlant.UTL_CO_PlantAll plantAll,String fieldName) {
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

    public static List<SerializableSelectOption> getSalutationPicklist(SerializableSelectOption selectOption, String objectName, String fieldName,String selectValue) {
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

    public static List<SerializableSelectOption> getS4SalutationPicklist(SerializableSelectOption selectOption, UTL_CO_OvcSapPlant.UTL_CO_PlantAll plantAll,String fieldName,String selectValue) {
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