({
    doInit: function(cmp, event, helper) {
        // デバイスの確認
        cmp.set('v.device', $A.get("$Browser.formFactor"));
        // パラメータ設定
        var params = {
            quoteLineItemId:cmp.get('v.quoteLineItemId'),
            selectQuantityUnit : cmp.get('v.selectQuantityUnit'),
            selectDetailCategory : cmp.get('v.selectDetailCategory'),
            selectDetailCategoryMTE : cmp.get('v.selectDetailCategoryMTE'),
            selectRejectionReason : cmp.get('v.selectRejectionReason'),
            selectPlantCode : cmp.get('v.selectPlantCode'),
            selectPlantCodeMTE : cmp.get('v.selectPlantCodeMTE'),
            selectStorageLocation : cmp.get('v.selectStorageLocation'),
            selectStorageLocationMTE : cmp.get('v.selectStorageLocationMTE'),
            selectCurrency : cmp.get('v.selectCurrency'),
            selectRecordingDivision : cmp.get('v.selectRecordingDivision'),
            selectProfitCenter : cmp.get('v.selectProfitCenter'),
            selectProfitCenterMTE : cmp.get('v.selectProfitCenterMTE'),
            selectMaterialGroup1 : cmp.get('v.selectMaterialGroup1'),
            selectSalesUnit : cmp.get('v.selectSalesUnit'),
        };
        helper.doInit(cmp, params);
    },
    doSelectPicvalues: function(cmp, event, helper) {
        // notice parent component to go back to the OpportunityLineItemBulkEdit component and reflect selected Products
        var reflectSelectedPicklistValuesEvent = cmp.getEvent("reflectSelectedPicklistValues");
        reflectSelectedPicklistValuesEvent.setParams({
            selectQuantityUnit : cmp.find("COWO_QuantityUnit__c").get("v.value"),
            selectDetailCategory : cmp.find("COWO_DetailCategory__c").get("v.value"),
            selectDetailCategoryMTE : cmp.find("COWO_DetailCategory_MTE__c").get("v.value"),
            selectRejectionReason : cmp.find("COWO_RejectionReason__c").get("v.value"),
            selectPlantCode : cmp.find("COWO_PlantCode__c").get("v.value"),
            selectPlantCodeMTE : cmp.find("COWO_PlantCode_MTE__c").get("v.value"),
            selectStorageLocation : cmp.find("COWO_StorageLocation__c").get("v.value"),
            selectStorageLocationMTE : cmp.find("COWO_StorageLocation_MTE__c").get("v.value"),
            //selectCurrency : cmp.find("COWO_Currency__c").get("v.value"),
            selectRecordingDivision : cmp.find("COWO_Recording_Division__c").get("v.value"),
            selectProfitCenter : cmp.find("COWO_ProfitCenter__c").get("v.value"),
            //selectProfitCenterMTE : cmp.find("COWO_ProfitCenter_MTE__c").get("v.value"),
            selectMaterialGroup1 : cmp.find("COWO_MaterialGroup1__c").get("v.value"),
            shippingInstructions : cmp.find("COWO_ShippingInstructions__c").get("v.value"),
            salesNoteCustome : cmp.find("COWO_SalesNoteCustome__c").get("v.value"),
            selectSalesUnit : cmp.find("COWO_SalesUnit__c").get("v.value"),
            quoteLineItemId : cmp.get('v.quoteLineItemId'),
        }).fire();
    },
    onCloseClicked: function(cmp, event, helper) {
        helper.doOnClose(cmp, event);
    },
    onOpenCalled: function(cmp, event, helper) {
        var params = {
            quoteLineItemId:cmp.get('v.quoteLineItemId'),
            selectQuantityUnit : cmp.get('v.selectQuantityUnit'),
            selectDetailCategory : cmp.get('v.selectDetailCategory'),
            selectDetailCategoryMTE : cmp.get('v.selectDetailCategoryMTE'),
            selectRejectionReason : cmp.get('v.selectRejectionReason'),
            selectPlantCode : cmp.get('v.selectPlantCode'),
            selectPlantCodeMTE : cmp.get('v.selectPlantCodeMTE'),
            selectStorageLocation : cmp.get('v.selectStorageLocation'),
            selectStorageLocationMTE : cmp.get('v.selectStorageLocationMTE'),
            selectCurrency : cmp.get('v.selectCurrency'),
            selectRecordingDivision : cmp.get('v.selectRecordingDivision'),
            selectProfitCenter : cmp.get('v.selectProfitCenter'),
            selectProfitCenterMTE : cmp.get('v.selectProfitCenterMTE'),
            selectMaterialGroup1 : cmp.get('v.selectMaterialGroup1'),
            shippingInstructions : cmp.get("v.shippingInstructions"),
            salesNoteCustome : cmp.get("v.salesNoteCustome"),
            selectSalesUnit : cmp.get('v.selectSalesUnit'),
        };
        helper.doInit(cmp, params);
    },
    changePlantste: function(cmp, event, helper) {
        // パラメータ設定
        var params = {
            plantste:cmp.get('v.selectPlantCode')
        };
        helper.changePlantste(cmp, params);
    }
})