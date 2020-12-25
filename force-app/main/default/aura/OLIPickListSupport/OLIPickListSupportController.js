({
    doInit: function(cmp, event, helper) {
        // デバイスの確認
        cmp.set('v.device', $A.get("$Browser.formFactor"));
        // パラメータ設定
        var params = {
            opportunityLineItemId:cmp.get('v.oppLineItemId'),
            currencyISOCode:cmp.get('v.currencyISOCode'),
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
        helper.doCalculate(cmp);
    },
    doCalculate: function(cmp, event, helper) {
        helper.doCalculate(cmp);
        // var conditionRateInsurance = helper.convertNumber(cmp.get('v.conditionRateInsurance'));
        // var insuranceFee = helper.convertNumber(cmp.get('v.insuranceFee'));
        // var conditionRateTaxes = helper.convertNumber(cmp.get('v.conditionRateTaxes'));
        // var freight = helper.convertNumber(cmp.get('v.freight'));
        // var conditionDeliveryCost = helper.convertNumber(cmp.get('v.conditionDeliveryCost'));
        // var reserversFixed = helper.convertNumber(cmp.get('v.reserversFixed'));
        // var conditionRateTotal = helper.convertNumber(cmp.get('v.conditionRateTotal'));
        // var cnAMTTOTAL = helper.convertNumber(cmp.get('v.cnAMTTOTAL'));
        // conditionRateTotal = conditionRateInsurance + conditionRateTaxes + conditionDeliveryCost;
        // cnAMTTOTAL = insuranceFee + freight + reserversFixed;
        // cmp.set('v.conditionRateTotal',conditionRateTotal);
        // cmp.set('v.cnAMTTOTAL',cnAMTTOTAL);
    },
    doSelectPicvalues: function(cmp, event, helper) {
        // notice parent component to go back to the OpportunityLineItemBulkEdit component and reflect selected Products
        var reflectSelectedPicklistValuesEvent = cmp.getEvent("reflectSelectedPicklistValues");
        reflectSelectedPicklistValuesEvent.setParams({
            selectQuantityUnit : cmp.find("SAWO_QuantityUnit__c").get("v.value"),
            selectDetailCategory : cmp.find("SAWO_DetailCategory__c").get("v.value"),
            selectDetailCategoryMTE : cmp.find("SAWO_DetailCategory_MTE__c").get("v.value"),
            selectRejectionReason : cmp.find("SAWO_RejectionReason__c").get("v.value"),
            selectPlantCode : cmp.find("SAWO_PlantCode__c").get("v.value"),
            selectPlantCodeMTE : cmp.find("SAWO_PlantCode_MTE__c").get("v.value"),
            selectStorageLocation : cmp.find("SAWO_StorageLocation__c").get("v.value"),
            selectStorageLocationMTE : cmp.find("SAWO_StorageLocation_MTE__c").get("v.value"),
            //selectCurrency : cmp.find("SAWO_Currency__c").get("v.value"),
            selectRecordingDivision : cmp.find("SAWO_Recording_Division__c").get("v.value"),
            selectProfitCenter : cmp.find("SAWO_ProfitCenter__c").get("v.value"),
            //selectProfitCenterMTE : cmp.find("SAWO_ProfitCenter_MTE__c").get("v.value"),
            selectMaterialGroup1 : cmp.find("SAWO_MaterialGroup1__c").get("v.value"),
            shippingInstructions : cmp.find("SAWO_ShippingInstructions__c").get("v.value"),
            salesNoteCustome : cmp.find("SAWO_SalesNoteCustome__c").get("v.value"),
            selectSalesUnit : cmp.find("SAWO_SalesUnit__c").get("v.value"),
            conditionRateInsurance : cmp.find("SAWO_ConditionRate_Insurance__c").get("v.value"),
            insuranceFee : cmp.find("SA_Insurance_fee__c").get("v.value"),
            conditionRateTaxes : cmp.find("SAWO_ConditionRate_Taxes__c").get("v.value"),
            freight : cmp.find("SA_Freight__c").get("v.value"),
            conditionDeliveryCost : cmp.find("SAWO_ConditionRate_DeliveryCost__c").get("v.value"),
            trgInstRsrvsFixed : cmp.find("SA_TrgInstRsrvsFixed__c").get("v.value"),
            otherDuties : cmp.find("SA_Other_Duties__c").get("v.value"),
            reserversFixed : cmp.find("SA_Reservers_Fixed__c").get("v.value"),
            oppLineItemId : cmp.get('v.oppLineItemId'),
        }).fire();
    },
    onCloseClicked: function(cmp, event, helper) {
        helper.doOnClose(cmp, event);
    },
    onOpenCalled: function(cmp, event, helper) {
        helper.doCalculate(cmp);
    },
    changePlantste: function(cmp, event, helper) {
        // パラメータ設定
        var params = {
            plantste:cmp.get('v.selectPlantCode')
        };
        helper.changePlantste(cmp, params);
    }
})