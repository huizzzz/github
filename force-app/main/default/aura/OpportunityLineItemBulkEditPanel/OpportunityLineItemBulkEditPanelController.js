({
	formPress: function(cmp, event, helper) {
        if (event.keyCode === 27) {
            // alert("panelClose");
        }
    },
    doInit: function(cmp, event, helper) {
        if(!cmp.get("v.isLoadedOpportunityLineItemBulkEdit")){
            cmp.set("v.isLoadedOpportunityLineItemBulkEdit", true);
            // create the OpportunityLineItemBulkEdit component
            helper.createOpportunityLineItemBulkEditCmp(cmp, event);
        } else {
            // open the OpportunityLineItemBulkEdit component
            if(cmp.find("OpportunityLineItemBulkEditCmp")){
                [].concat(cmp.find("OpportunityLineItemBulkEditCmp"))[0].open();
            }
            $A.util.removeClass(cmp.find('OpportunityLineItemBulkEdit'), 'slds-hide');
        }
    },
    openSearchProduct: function(cmp, event, helper) {
        // hide the OpportunityLineItemBulkEdit component
        $A.util.addClass(cmp.find('OpportunityLineItemBulkEdit'), 'slds-hide');
        if(!cmp.get("v.isLoadedSearchProduct")){
            cmp.set("v.isLoadedSearchProduct", true);
            // create the SearchProduct component
            helper.createSearchProductCmp(cmp, event, helper);
        } else{
            // open the SearchProduct component
            if(cmp.find("SearchProductCmp")){
                [].concat(cmp.find("SearchProductCmp"))[0].open();
            }
            $A.util.removeClass(cmp.find('SearchProduct'), 'slds-hide');
        }
    },
    closeSearchProduct: function(cmp, event, helper) {
        // hide the SearchProduct component
        $A.util.addClass(cmp.find('SearchProduct'), 'slds-hide');
        // go back to the OpportunityLineItemBulkEdit component
        $A.util.removeClass(cmp.find('OpportunityLineItemBulkEdit'), 'slds-hide');

        // call open method of SearchProduct component
        [].concat(cmp.find("SearchProductCmp"))[0].open();
    },
    reflectSearchProduct: function(cmp, event, helper) {
        // hide the SearchProduct component
        $A.util.addClass(cmp.find('SearchProduct'), 'slds-hide');
        // go back to the OpportunityLineItemBulkEdit component
        $A.util.removeClass(cmp.find('OpportunityLineItemBulkEdit'), 'slds-hide');
        
        // currentDatas取得
        var currentDatas = cmp.find('OpportunityLineItemBulkEditCmp').get("v.data");
		var priceBookId  = '';
        
        // 選択データ処理
        var selectedProducts = [];
        event.getParam("selectedProducts").forEach(function(selectedProduct){
            // 既に選択済みデータは追加しない
            var isAddFlag = true;
            currentDatas.forEach(function(currentData){
                if(currentData.Id == selectedProduct.Id || currentData.Id == ("Add" + selectedProduct.Id)){
                    isAddFlag = false;
                }
            });

            // 既存データに存在しなかった、または検索画面にて選択してなかった場合
            if(isAddFlag){
                var Q;
                if (selectedProduct.Q__c == null || String(selectedProduct.Q__c).trim() === ""){
                    Q = 0;
                } else{
                    Q = selectedProduct.Q__c;
                }
                selectedProducts.push({
                    Id : "Add" + selectedProduct.product2_Id,
                    SAWO_ProductName__c : selectedProduct.product2_ItemName,
                    Quantity : 1,
                    UnitPrice : selectedProduct.unitPrice,
                    SAWO_SalesPrice__c : selectedProduct.unitPrice,
                    SAWO_LocalCorporationTC__c : helper.convertNumber(selectedProduct.COWO_LocalCorporationTC),
                    SAWO_FrontPurchasePrice__c : helper.convertNumber(selectedProduct.COWO_FrontPurchasePrice),
                    TC__c : helper.convertNumber(selectedProduct.product2_TC),
                    MC__c : helper.convertNumber(selectedProduct.product2_MC),
                    SAWO_Parts_No__c : selectedProduct.product2_PartsNo,
                    SAWO_ProductCode__c : selectedProduct.product2_ProductCode,
                    SAWO_Currency__c : cmp.find('OpportunityLineItemBulkEditCmp').get('v.currencyIsoCode'),
                    CurrencyIsoCode : cmp.find('OpportunityLineItemBulkEditCmp').get('v.currencyIsoCode'),
                    SAWO_ItemNumber__c : selectedProduct.product2_OrderNummber,
                    SAWO_SalesUnit__c : selectedProduct.product2_SalesUnit,
                    SAWO_PartitionPrice__c : selectedProduct.product2_PartitionPrice,
                    SAWO_NoDiscountFlg__c : selectedProduct.product2_NoDiscountFlg,
                    SAWO_S4LinkagePrice__c : selectedProduct.unitPrice,
                    SAWO_DiscountPrice__c : 0,
                    SAWO_LocalParts__c : selectedProduct.product2_LocalParts,
                    Tekiyo__c : selectedProduct.product2_Description,
                });
            }
        });
        // 選択データ反映
        var currentDatas = cmp.find('OpportunityLineItemBulkEditCmp').get("v.data");
        var newData = currentDatas.concat(selectedProducts);
        cmp.find('OpportunityLineItemBulkEditCmp').set("v.data", newData);
        // draftValuesを設定する
        cmp.find('OpportunityLineItemBulkEditCmp').find("datatable").set("v.draftValues", cmp.find('OpportunityLineItemBulkEditCmp').find("datatable").get("v.draftValues").concat(selectedProducts));
        
        // enable button
        if(cmp.find('OpportunityLineItemBulkEditCmp').find("datatable").get("v.draftValues").length > 0 || cmp.find('OpportunityLineItemBulkEditCmp').get('v.deletedData').length > 0){
            cmp.find('OpportunityLineItemBulkEditCmp').set('v.hasChanged', true);
        } else {
            cmp.find('OpportunityLineItemBulkEditCmp').set('v.hasChanged', false);
        }
    },
    openOLIPickListSupport: function(cmp, event, helper) {
        // hide the OpportunityLineItemBulkEdit component
        $A.util.addClass(cmp.find('OpportunityLineItemBulkEdit'), 'slds-hide');
        if(!cmp.get("v.isLoadedPickListSupport")){
            cmp.set("v.isLoadedPickListSupport", true);
            // create the SearchProduct component
            helper.createOLIPickListSupportCmp(cmp, event);
        } else{
            // open the SearchProduct component
            if(cmp.find("OLIPickListSupportCmp")){
                cmp.find("OLIPickListSupportCmp").set("v.oppLineItemId", event.getParam("oppLineItemId"));
                cmp.find("OLIPickListSupportCmp").set("v.currencyISOCode", event.getParam("currencyISOCode"));
                cmp.find("OLIPickListSupportCmp").set("v.selectQuantityUnit", event.getParam("selectQuantityUnit"));
                cmp.find("OLIPickListSupportCmp").set("v.selectDetailCategory", event.getParam("selectDetailCategory"));
                cmp.find("OLIPickListSupportCmp").set("v.selectDetailCategoryMTE", event.getParam("selectDetailCategoryMTE"));
                cmp.find("OLIPickListSupportCmp").set("v.selectRejectionReason", event.getParam("selectRejectionReason"));
                cmp.find("OLIPickListSupportCmp").set("v.selectPlantCode", event.getParam("selectPlantCode"));
                cmp.find("OLIPickListSupportCmp").set("v.selectPlantCodeMTE", event.getParam("selectPlantCodeMTE"));
                cmp.find("OLIPickListSupportCmp").set("v.selectStorageLocation", event.getParam("selectStorageLocation"));
                cmp.find("OLIPickListSupportCmp").set("v.selectStorageLocationMTE", event.getParam("selectStorageLocationMTE"));
                cmp.find("OLIPickListSupportCmp").set("v.selectCurrency", event.getParam("selectCurrency"));
                cmp.find("OLIPickListSupportCmp").set("v.selectRecordingDivision", event.getParam("selectRecordingDivision"));
                cmp.find("OLIPickListSupportCmp").set("v.selectProfitCenter", event.getParam("selectProfitCenter"));
                cmp.find("OLIPickListSupportCmp").set("v.selectProfitCenterMTE", event.getParam("selectProfitCenterMTE"));
                cmp.find("OLIPickListSupportCmp").set("v.selectMaterialGroup1", event.getParam("selectMaterialGroup1"));
                cmp.find("OLIPickListSupportCmp").set("v.shippingInstructions", event.getParam("shippingInstructions"));
                cmp.find("OLIPickListSupportCmp").set("v.salesNoteCustome", event.getParam("salesNoteCustome"));
                cmp.find("OLIPickListSupportCmp").set("v.selectSalesUnit", event.getParam("selectSalesUnit"));
                cmp.find("OLIPickListSupportCmp").set("v.conditionRateInsurance", event.getParam("conditionRateInsurance"));
                cmp.find("OLIPickListSupportCmp").set("v.insuranceFee", event.getParam("insuranceFee"));
                cmp.find("OLIPickListSupportCmp").set("v.conditionRateTaxes", event.getParam("conditionRateTaxes"));
                cmp.find("OLIPickListSupportCmp").set("v.freight", event.getParam("freight"));
                cmp.find("OLIPickListSupportCmp").set("v.conditionDeliveryCost", event.getParam("conditionDeliveryCost"));
                cmp.find("OLIPickListSupportCmp").set("v.otherDuties", event.getParam("otherDuties"));
                cmp.find("OLIPickListSupportCmp").set("v.reserversFixed", event.getParam("reserversFixed"));
                cmp.find("OLIPickListSupportCmp").set("v.trgInstRsrvsFixed", event.getParam("trgInstRsrvsFixed"));
                [].concat(cmp.find("OLIPickListSupportCmp"))[0].open();
            }
            $A.util.removeClass(cmp.find('OLIPickListSupport'), 'slds-hide');
        }
    },
    closeOLIPickListSupport: function(cmp, event, helper) {
        // hide the SearchProduct component
        $A.util.addClass(cmp.find('OLIPickListSupport'), 'slds-hide');
        // go back to the QuoteLineItemBulkEdit component
        $A.util.removeClass(cmp.find('OpportunityLineItemBulkEdit'), 'slds-hide');

    },
    reflectSelectPickListValues: function(cmp, event, helper) {
        // hide the SelectPickListValues component
        $A.util.addClass(cmp.find('OLIPickListSupport'), 'slds-hide');
        // go back to the OpportunityLineItemBulkEdit component
        $A.util.removeClass(cmp.find('OpportunityLineItemBulkEdit'), 'slds-hide');
        
        // currentDatas取得
        var currentDatas = cmp.find('OpportunityLineItemBulkEditCmp').find("datatable").get("v.data");
        // draftValue取得
        var draftValues = cmp.find('OpportunityLineItemBulkEditCmp').find("datatable").get("v.draftValues");
        // draftValue取得
        //var draftValues = cmp.find('OpportunityLineItemBulkEditCmp').get("v.draftValues");
        for(var idx = 0;idx < currentDatas.length;idx ++){
            if(currentDatas[idx].Id == event.getParam("oppLineItemId")){
                currentDatas[idx].SAWO_QuantityUnit__c = event.getParam("selectQuantityUnit");
                currentDatas[idx].SAWO_DetailCategory__c = event.getParam("selectDetailCategory");
                currentDatas[idx].SAWO_DetailCategory_MTE__c = event.getParam("selectDetailCategoryMTE");
                currentDatas[idx].SAWO_RejectionReason__c = event.getParam("selectRejectionReason");
                currentDatas[idx].SAWO_PlantCode__c = event.getParam("selectPlantCode");
                currentDatas[idx].SAWO_PlantCode_MTE__c = event.getParam("selectPlantCodeMTE");
                currentDatas[idx].SAWO_StorageLocation__c = event.getParam("selectStorageLocation");
                currentDatas[idx].SAWO_StorageLocation_MTE__c = event.getParam("selectStorageLocationMTE");
                currentDatas[idx].SAWO_Currency__c = event.getParam("selectCurrency");
                currentDatas[idx].SAWO_Recording_Division__c = event.getParam("selectRecordingDivision");
                currentDatas[idx].SAWO_ProfitCenter__c = event.getParam("selectProfitCenter");
                currentDatas[idx].SAWO_ProfitCenter_MTE__c = event.getParam("selectProfitCenterMTE");
                currentDatas[idx].SAWO_MaterialGroup1__c = event.getParam("selectMaterialGroup1");
                currentDatas[idx].SAWO_ShippingInstructions__c = event.getParam("shippingInstructions");
                currentDatas[idx].SAWO_SalesNoteCustome__c = event.getParam("salesNoteCustome");
                currentDatas[idx].SAWO_SalesUnit__c = event.getParam("selectSalesUnit");
                currentDatas[idx].SAWO_ConditionRate_Insurance__c = event.getParam("conditionRateInsurance");
                currentDatas[idx].SA_Insurance_fee__c = event.getParam("insuranceFee");
                currentDatas[idx].SAWO_ConditionRate_Taxes__c = event.getParam("conditionRateTaxes");
                currentDatas[idx].SA_Freight__c = event.getParam("freight");
                currentDatas[idx].SAWO_ConditionRate_DeliveryCost__c = event.getParam("conditionDeliveryCost");
                currentDatas[idx].SA_TrgInstRsrvsFixed__c = event.getParam("trgInstRsrvsFixed");
                currentDatas[idx].SA_Other_Duties__c = event.getParam("otherDuties");
                currentDatas[idx].SA_Reservers_Fixed__c = event.getParam("reserversFixed");
            }
        }
        cmp.find('OpportunityLineItemBulkEditCmp').find("datatable").set("v.data", currentDatas);

        var dftExist = false;
        draftValues.forEach(function(draftValue){
            if(draftValue.Id == event.getParam("oppLineItemId")){
                dftExist = true;
            }
            if(dftExist){
                draftValue.SAWO_QuantityUnit__c = event.getParam("selectQuantityUnit");
                draftValue.SAWO_DetailCategory__c = event.getParam("selectDetailCategory");
                draftValue.SAWO_DetailCategory_MTE__c = event.getParam("selectDetailCategoryMTE");
                draftValue.SAWO_RejectionReason__c = event.getParam("selectRejectionReason");
                draftValue.SAWO_PlantCode__c = event.getParam("selectPlantCode");
                draftValue.SAWO_PlantCode_MTE__c = event.getParam("selectPlantCodeMTE");
                draftValue.SAWO_StorageLocation__c = event.getParam("selectStorageLocation");
                draftValue.SAWO_StorageLocation_MTE__c = event.getParam("selectStorageLocationMTE");
                draftValue.SAWO_Currency__c = event.getParam("selectCurrency");
                draftValue.SAWO_Recording_Division__c = event.getParam("selectRecordingDivision");
                draftValue.SAWO_ProfitCenter__c = event.getParam("selectProfitCenter");
                draftValue.SAWO_ProfitCenter_MTE__c = event.getParam("selectProfitCenterMTE");
                draftValue.SAWO_MaterialGroup1__c = event.getParam("selectMaterialGroup1");
                draftValue.SAWO_ShippingInstructions__c = event.getParam("shippingInstructions");
                draftValue.SAWO_SalesNoteCustome__c = event.getParam("salesNoteCustome");
                draftValue.SAWO_SalesUnit__c = event.getParam("selectSalesUnit");
                draftValue.CurrencyIsoCode = event.getParam("currencyISOCode");
                draftValue.SAWO_ConditionRate_Insurance__c = event.getParam("conditionRateInsurance");
                draftValue.SA_Insurance_fee__c = event.getParam("insuranceFee");
                draftValue.SAWO_ConditionRate_Taxes__c = event.getParam("conditionRateTaxes");
                draftValue.SA_Freight__c = event.getParam("freight");
                draftValue.SAWO_ConditionRate_DeliveryCost__c = event.getParam("conditionDeliveryCost");
                draftValue.SA_Other_Duties__c = event.getParam("otherDuties");
                draftValue.SA_Reservers_Fixed__c = event.getParam("reserversFixed");
                dftExist = false;
                //break;
                cmp.find('OpportunityLineItemBulkEditCmp').find("datatable").set("v.draftValues", draftValues);
            }
        });
      
        if(!dftExist){
            var draftValues = [];
            draftValues.push({
                Id : event.getParam("oppLineItemId"),
                SAWO_QuantityUnit__c : event.getParam("selectQuantityUnit"),
                SAWO_DetailCategory__c : event.getParam("selectDetailCategory"),
                SAWO_DetailCategory_MTE__c : event.getParam("selectDetailCategoryMTE"),
                SAWO_RejectionReason__c : event.getParam("selectRejectionReason"),
                SAWO_PlantCode__c : event.getParam("selectPlantCode"),
                SAWO_PlantCode_MTE__c : event.getParam("selectPlantCodeMTE"),
                SAWO_StorageLocation__c : event.getParam("selectStorageLocation"),
                SAWO_StorageLocation_MTE__c : event.getParam("selectStorageLocationMTE"),
                SAWO_Currency__c : event.getParam("selectCurrency"),
                SAWO_Recording_Division__c : event.getParam("selectRecordingDivision"),
                SAWO_ProfitCenter__c : event.getParam("selectProfitCenter"),
                SAWO_ProfitCenter_MTE__c : event.getParam("selectProfitCenterMTE"),
                SAWO_MaterialGroup1__c : event.getParam("selectMaterialGroup1"),
                SAWO_ShippingInstructions__c : event.getParam("shippingInstructions"),
                SAWO_SalesNoteCustome__c : event.getParam("salesNoteCustome"),
                SAWO_SalesUnit__c : event.getParam("selectSalesUnit"),
                CurrencyIsoCode : event.getParam("currencyISOCode"),
                SAWO_ConditionRate_Insurance__c : event.getParam("conditionRateInsurance"),
                SA_Insurance_fee__c : event.getParam("insuranceFee"),
                SAWO_ConditionRate_Taxes__c : event.getParam("conditionRateTaxes"),
                SA_Freight__c : event.getParam("freight"),
                SAWO_ConditionRate_DeliveryCost__c : event.getParam("conditionDeliveryCost"),
                SA_Other_Duties__c : event.getParam("otherDuties"),
                SA_Reservers_Fixed__c : event.getParam("reserversFixed"),
            });
            // draftValuesを設定する
            cmp.find('OpportunityLineItemBulkEditCmp').find("datatable").set("v.draftValues", cmp.find('OpportunityLineItemBulkEditCmp').find("datatable").get("v.draftValues").concat(draftValues));
        }        
        


        //TODO copyMethod最適化
        // cmp.find('OpportunityLineItemBulkEditCmp').set('v.selectQuantityUnit',event.getParam("selectQuantityUnit"));
        // cmp.find('OpportunityLineItemBulkEditCmp').set('v.selectDetailCategory',event.getParam("selectDetailCategory"));
        // cmp.find('OpportunityLineItemBulkEditCmp').set('v.selectDetailCategoryMTE',event.getParam("selectDetailCategoryMTE"));
        // cmp.find('OpportunityLineItemBulkEditCmp').set('v.selectRejectionReason',event.getParam("selectRejectionReason"));
        // cmp.find('OpportunityLineItemBulkEditCmp').set('v.selectPlantCode',event.getParam("selectPlantCode"));
        // cmp.find('OpportunityLineItemBulkEditCmp').set('v.selectPlantCodeMTE',event.getParam("selectPlantCodeMTE"));
        // cmp.find('OpportunityLineItemBulkEditCmp').set('v.selectStorageLocation',event.getParam("selectStorageLocation"));
        // cmp.find('OpportunityLineItemBulkEditCmp').set('v.selectStorageLocationMTE',event.getParam("selectStorageLocationMTE"));
        // cmp.find('OpportunityLineItemBulkEditCmp').set('v.selectCurrency',event.getParam("selectCurrency"));
        // cmp.find('OpportunityLineItemBulkEditCmp').set('v.selectRecordingDivision',event.getParam("selectRecordingDivision"));
        // cmp.find('OpportunityLineItemBulkEditCmp').set('v.selectProfitCenter',event.getParam("selectProfitCenter"));
        // cmp.find('OpportunityLineItemBulkEditCmp').set('v.selectProfitCenterMTE',event.getParam("selectProfitCenterMTE"));
        // cmp.find('OpportunityLineItemBulkEditCmp').set('v.selectMaterialGroup1',event.getParam("selectMaterialGroup1"));
        // // enable button
        if(cmp.find('OpportunityLineItemBulkEditCmp').find("datatable").get("v.draftValues").length > 0 || cmp.find('OpportunityLineItemBulkEditCmp').get('v.deletedData').length > 0){
            cmp.find('OpportunityLineItemBulkEditCmp').set('v.hasChanged', true);
        } else {
            cmp.find('OpportunityLineItemBulkEditCmp').set('v.hasChanged', false);
        }
    },
})