({
	formPress: function(cmp, event, helper) {
        if (event.keyCode === 27) {
            // alert("panelClose");
        }
    },
    doInit: function(cmp, event, helper) {
        if(!cmp.get("v.isLoadedQuoteLineItemBulkEdit")){
            cmp.set("v.isLoadedQuoteLineItemBulkEdit", true);
            // create the QuoteLineItemBulkEdit component
            helper.createQuoteLineItemBulkEditCmp(cmp, event);
        } else {
            // open the QuoteLineItemBulkEdit component
            if(cmp.find("QuoteLineItemBulkEditCmp")){
                [].concat(cmp.find("QuoteLineItemBulkEditCmp"))[0].open();
            }
            $A.util.removeClass(cmp.find('QuoteLineItemBulkEdit'), 'slds-hide');
        }
    },
    openSearchProduct: function(cmp, event, helper) {
        // hide the QuoteLineItemBulkEdit component
        $A.util.addClass(cmp.find('QuoteLineItemBulkEdit'), 'slds-hide');
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
        // go back to the QuoteLineItemBulkEdit component
        $A.util.removeClass(cmp.find('QuoteLineItemBulkEdit'), 'slds-hide');

        // call open method of SearchProduct component
        [].concat(cmp.find("SearchProductCmp"))[0].open();
    },
    reflectSearchProduct: function(cmp, event, helper) {
        // hide the SearchProduct component
        $A.util.addClass(cmp.find('SearchProduct'), 'slds-hide');
        // go back to the QuoteLineItemBulkEdit component
        $A.util.removeClass(cmp.find('QuoteLineItemBulkEdit'), 'slds-hide');
        
        // currentDatas取得
        var currentDatas = cmp.find('QuoteLineItemBulkEditCmp').get("v.data");
        //現在のTC合計取得
        var tcGokei = cmp.find('QuoteLineItemBulkEditCmp').get("v.tcGokei") + event.getParam("tcGokeiProduct2");
        //現在のヘッダ値引き(割引額)取得
        var headerNebiki01 = cmp.find('QuoteLineItemBulkEditCmp').get("v.headerNebiki01");
        //現在のヘッダ値引き(割引額)02取得
        var headerNebiki02 = (cmp.find('QuoteLineItemBulkEditCmp').get('v.shokei') + event.getParam("shokeiAddProduct2")) * cmp.find('QuoteLineItemBulkEditCmp').get("v.headerNebikiritsu");
        // 現在のDraftValueリスト取得
        var currentDraftValues = cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.draftValues");
        // 案分値引金額合計
        var neibikiGokei = helper.convertNumber(headerNebiki01) + helper.convertNumber(headerNebiki02) + helper.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.syuseiNebiki01'))+ helper.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.syuseiNebiki02')); 
        
        
		var priceBookId  = '';
        // 選択データ処理
        var selectedProducts = [];
        var selectedProductsIdx = 1;
        event.getParam("selectedProducts").forEach(function(selectedProduct){
            // 既に選択済みデータは追加しない
            var isAddFlag = true;
            currentDatas.forEach(function(currentData){
                if(currentData.Id == selectedProduct.product2_Id || currentData.product2_Id == ("Add" + selectedProduct.product2_Id)){
                    isAddFlag = false;
                }
            });
            // 既存データに存在しなかった、または検索画面にて選択してなかった場合
            if(isAddFlag){
        //         var totalPrice;
        //         if(tcGokei != 0){
        //             totalPrice = Math.round(selectedProduct.subtotal - ((helper.convertNumber(selectedProduct.product2_TC) / helper.convertNumber(tcGokei)) * (helper.convertNumber(headerNebiki01) + helper.convertNumber(headerNebiki02))));
        // 　        }else{
        //             totalPrice = selectedProduct.subtotal;
                // }
                //2020/01/20 TODO
                selectedProducts.push({
                    
                    Id: "Add" + selectedProduct.product2_Id,
                    COWO_Product_Name__c: selectedProduct.product2_ItemName,
                    COWO_DiscountPrice__c: '0',
                    Quantity: '1',
                    UnitPrice: selectedProduct.unitPrice,
                    Subtotal: selectedProduct.subtotal,
                    COWO_TotalLocalCorporationTC__c: helper.convertNumber(selectedProduct.localCorporationTC),
                    COWO_TotalFrontPurchasePrice__c: helper.convertNumber(selectedProduct.frontPurchasePrice),
                    // COWO_TotalPrice__c: totalPrice,
                    //COWO_TotalTC__c: helper.convertNumber(selectedProduct.pricebookentry_TC),
                    //COWO_TotalMC__c: helper.convertNumber(selectedProduct.pricebookentry_MC),
                    COWO_TotalTC__c: helper.convertNumber(selectedProduct.product2_TC),
                    COWO_TotalMC__c: helper.convertNumber(selectedProduct.product2_MC),
                    COWO_LocalCorporationTC__c: helper.convertNumber(selectedProduct.localCorporationTC),
                    COWO_FrontPurchasePrice__c: helper.convertNumber(selectedProduct.frontPurchasePrice),
                    COWO_TC__c: helper.convertNumber(selectedProduct.product2_TC),
                    COWO_MC__c: helper.convertNumber(selectedProduct.product2_MC),
                    // COWO_DiscountUnitPrice__c:totalPrice,
                    COWO_PartsNo__c:selectedProduct.product2_PartsNo, 
                    COWO_SortNo__c:currentDatas.length + selectedProductsIdx,
                    COWO_ProductCode__c:selectedProduct.product2_ProductCode,
                    COWO_Currency__c: cmp.find("QuoteLineItemBulkEditCmp").get("v.currencyIsoCode"),
                    CurrencyIsoCode: cmp.find("QuoteLineItemBulkEditCmp").get("v.currencyIsoCode"),
                    COWO_ItemNumber__c : selectedProduct.product2_OrderNummber,
                    COWO_SalesUnit__c : selectedProduct.product2_SalesUnit,
                    COWO_PartitionPrice__c : selectedProduct.product2_PartitionPrice,
                    COWO_NoDiscountFlg__c : selectedProduct.product2_NoDiscountFlg,
                    COWO_Currency__c: cmp.get("v.currencyIsoCode"),
                    COWO_DetailCategory__c : "",
                    COWO_DetailCategory_MTE__c : "",
                    COWO_RejectionReason__c : "",
                    COWO_PlantCode__c : "",
                    COWO_PlantCode_MTE__c : "",
                    COWO_StorageLocation__c : "",
                    COWO_StorageLocation_MTE__c : "",
                    COWO_Recording_Division__c : "",
                    COWO_WBSElement__c : "",
                    COWO_ProfitCenter__c : "",
                    COWO_ProfitCenter_MTE__c : "",
                    COWO_ItemText__c : "",
                    COWO_DeliverySchedule__c : $A.localizationService.formatDate(new Date(), "YYYY-MM-DD"),
                    COWO_MaterialAvailDate__c : $A.localizationService.formatDate(new Date(), "YYYY-MM-DD"),
                    COWO_MaterialGroup1__c : "",
                    COWO_ShippingInstructions__c : "",
                    COWO_SalesNoteCustome__c : "",
                    COWO_PartitionPrice__c : "",
                    COWO_PartitionPrice__c : "",
                    CO_ovcUpdateFlag__c : "",
                    CO_ovcUpdateFlag_MTE__c : "",
                    COWO_Description__c : selectedProduct.product2_Description,
                });
                }
            selectedProductsIdx++;
        });
        // 選択データ反映
        var currentDatas = cmp.find('QuoteLineItemBulkEditCmp').get("v.data");
        var newData = currentDatas.concat(selectedProducts);
        cmp.find('QuoteLineItemBulkEditCmp').set("v.data", newData);
        // draftValuesを設定する
        cmp.find('QuoteLineItemBulkEditCmp').find("datatable").set("v.draftValues", cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.draftValues").concat(selectedProducts));
        // tc合計を設定する
        cmp.find('QuoteLineItemBulkEditCmp').set("v.tcGokei", tcGokei);
        // 金額再計算
        helper.recalPrice(cmp,neibikiGokei);
        // 見積金額項目再計算
        helper.cellRecalculate(cmp);
        // 端数調整
        helper.adjustFraction(cmp);
        // enable button
        if(cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.draftValues").length > 0 || cmp.find('QuoteLineItemBulkEditCmp').get('v.deletedData').length > 0){
            cmp.find('QuoteLineItemBulkEditCmp').set('v.hasChanged', true);
        } else {
            cmp.find('QuoteLineItemBulkEditCmp').set('v.hasChanged', false);
        }
    },
    openQLIPickListSupport: function(cmp, event, helper) {
        // hide the OpportunityLineItemBulkEdit component
        $A.util.addClass(cmp.find('QuoteLineItemBulkEdit'), 'slds-hide');
        if(!cmp.get("v.isLoadedPickListSupport")){
            cmp.set("v.isLoadedPickListSupport", true);
            // create the SearchProduct component
            helper.createQLIPickListSupportCmp(cmp, event);
        } else{
            // open the SearchProduct component
            if(cmp.find("QLIPickListSupportCmp")){
                cmp.find("QLIPickListSupportCmp").set("v.quoteLineItemId", event.getParam("quoteLineItemId"));
                cmp.find("QLIPickListSupportCmp").set("v.selectQuantityUnit", event.getParam("selectQuantityUnit"));
                cmp.find("QLIPickListSupportCmp").set("v.selectDetailCategory", event.getParam("selectDetailCategory"));
                cmp.find("QLIPickListSupportCmp").set("v.selectDetailCategoryMTE", event.getParam("selectDetailCategoryMTE"));
                cmp.find("QLIPickListSupportCmp").set("v.selectRejectionReason", event.getParam("selectRejectionReason"));
                cmp.find("QLIPickListSupportCmp").set("v.selectPlantCode", event.getParam("selectPlantCode"));
                cmp.find("QLIPickListSupportCmp").set("v.selectPlantCodeMTE", event.getParam("selectPlantCodeMTE"));
                cmp.find("QLIPickListSupportCmp").set("v.selectStorageLocation", event.getParam("selectStorageLocation"));
                cmp.find("QLIPickListSupportCmp").set("v.selectStorageLocationMTE", event.getParam("selectStorageLocationMTE"));
                cmp.find("QLIPickListSupportCmp").set("v.selectCurrency", event.getParam("selectCurrency"));
                cmp.find("QLIPickListSupportCmp").set("v.selectRecordingDivision", event.getParam("selectRecordingDivision"));
                cmp.find("QLIPickListSupportCmp").set("v.selectProfitCenter", event.getParam("selectProfitCenter"));
                cmp.find("QLIPickListSupportCmp").set("v.selectProfitCenterMTE", event.getParam("selectProfitCenterMTE"));
                cmp.find("QLIPickListSupportCmp").set("v.selectMaterialGroup1", event.getParam("selectMaterialGroup1"));
                cmp.find("QLIPickListSupportCmp").set("v.selectSalesUnit", event.getParam("selectSalesUnit"));
                cmp.find("QLIPickListSupportCmp").set("v.shippingInstructions",event.getParam("shippingInstructions")),
                cmp.find("QLIPickListSupportCmp").set("v.salesNoteCustome",event.getParam("salesNoteCustome")),
                [].concat(cmp.find("QLIPickListSupportCmp"))[0].open();
            }
            $A.util.removeClass(cmp.find('QLIPickListSupport'), 'slds-hide');
        }
    },
    closeQLIPickListSupport: function(cmp, event, helper) {
        // hide the SearchProduct component
        $A.util.addClass(cmp.find('QLIPickListSupport'), 'slds-hide');
        // go back to the QuoteLineItemBulkEdit component
        $A.util.removeClass(cmp.find('QuoteLineItemBulkEdit'), 'slds-hide');

    },
    reflectSelectPickListValues: function(cmp, event, helper) {
        // hide the SelectPickListValues component
        $A.util.addClass(cmp.find('QLIPickListSupport'), 'slds-hide');
        // go back to the OpportunityLineItemBulkEdit component
        $A.util.removeClass(cmp.find('QuoteLineItemBulkEdit'), 'slds-hide');
        
        // currentDatas取得
        var currentDatas = cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.data");
        // draftValue取得
        var draftValues = cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.draftValues");
        for(var idx = 0;idx < currentDatas.length;idx ++){
            if(currentDatas[idx].Id == event.getParam("quoteLineItemId")){
                currentDatas[idx].COWO_QuantityUnit__c = event.getParam("selectQuantityUnit");
                currentDatas[idx].COWO_DetailCategory__c = event.getParam("selectDetailCategory");
                currentDatas[idx].COWO_DetailCategory_MTE__c = event.getParam("selectDetailCategoryMTE");
                currentDatas[idx].COWO_RejectionReason__c = event.getParam("selectRejectionReason");
                currentDatas[idx].COWO_PlantCode__c = event.getParam("selectPlantCode");
                currentDatas[idx].COWO_PlantCode_MTE__c = event.getParam("selectPlantCodeMTE");
                currentDatas[idx].COWO_StorageLocation__c = event.getParam("selectStorageLocation");
                currentDatas[idx].COWO_StorageLocation_MTE__c = event.getParam("selectStorageLocationMTE");
                currentDatas[idx].COWO_Currency__c = event.getParam("selectCurrency");
                currentDatas[idx].COWO_Recording_Division__c = event.getParam("selectRecordingDivision");
                currentDatas[idx].COWO_ProfitCenter__c = event.getParam("selectProfitCenter");
                currentDatas[idx].COWO_ProfitCenter_MTE__c = event.getParam("selectProfitCenterMTE");
                currentDatas[idx].COWO_MaterialGroup1__c = event.getParam("selectMaterialGroup1");
                currentDatas[idx].COWO_ShippingInstructions__c = event.getParam("shippingInstructions");
                currentDatas[idx].COWO_SalesNoteCustome__c = event.getParam("salesNoteCustome");
                currentDatas[idx].COWO_SalesUnit__c = event.getParam("selectSalesUnit");
            }
        }
        cmp.find('QuoteLineItemBulkEditCmp').find("datatable").set("v.data", currentDatas);

        var dftExist = false;
        draftValues.forEach(function(draftValue){
            if(draftValue.Id == event.getParam("quoteLineItemId")){
                dftExist = true;
            }
            if(dftExist){
                draftValues[dftIdx].COWO_QuantityUnit__c = event.getParam("selectQuantityUnit");
                draftValues[dftIdx].COWO_DetailCategory__c = event.getParam("selectDetailCategory");
                draftValues[dftIdx].COWO_DetailCategory_MTE__c = event.getParam("selectDetailCategoryMTE");
                draftValues[dftIdx].COWO_RejectionReason__c = event.getParam("selectRejectionReason");
                draftValues[dftIdx].COWO_PlantCode__c = event.getParam("selectPlantCode");
                draftValues[dftIdx].COWO_PlantCode_MTE__c = event.getParam("selectPlantCodeMTE");
                draftValues[dftIdx].COWO_StorageLocation__c = event.getParam("selectStorageLocation");
                draftValues[dftIdx].COWO_StorageLocation_MTE__c = event.getParam("selectStorageLocationMTE");
                draftValues[dftIdx].COWO_Currency__c = event.getParam("selectCurrency");
                draftValues[dftIdx].COWO_Recording_Division__c = event.getParam("selectRecordingDivision");
                draftValues[dftIdx].COWO_ProfitCenter__c = event.getParam("selectProfitCenter");
                draftValues[dftIdx].COWO_ProfitCenter_MTE__c = event.getParam("selectProfitCenterMTE");
                draftValues[dftIdx].COWO_MaterialGroup1__c = event.getParam("selectMaterialGroup1");
                draftValues[dftIdx].COWO_ShippingInstructions__c = event.getParam("shippingInstructions");
                draftValues[dftIdx].COWO_SalesNoteCustome__c = event.getParam("salesNoteCustome");
                draftValues[dftIdx].COWO_SalesUnit__c = event.getParam("selectSalesUnit");
                dftExist = false;
                cmp.find('QuoteLineItemBulkEditCmp').find("datatable").set("v.draftValues", draftValues);
            }
        });
      
        if(!dftExist){
            var draftValues = [];
            draftValues.push({
                Id : event.getParam("quoteLineItemId"),
                COWO_QuantityUnit__c : event.getParam("selectQuantityUnit"),
                COWO_DetailCategory__c : event.getParam("selectDetailCategory"),
                COWO_DetailCategory_MTE__c : event.getParam("selectDetailCategoryMTE"),
                COWO_RejectionReason__c : event.getParam("selectRejectionReason"),
                COWO_PlantCode__c : event.getParam("selectPlantCode"),
                COWO_PlantCode_MTE__c : event.getParam("selectPlantCodeMTE"),
                COWO_StorageLocation__c : event.getParam("selectStorageLocation"),
                COWO_StorageLocation_MTE__c : event.getParam("selectStorageLocationMTE"),
                COWO_Currency__c : event.getParam("selectCurrency"),
                COWO_Recording_Division__c : event.getParam("selectRecordingDivision"),
                COWO_ProfitCenter__c : event.getParam("selectProfitCenter"),
                COWO_ProfitCenter_MTE__c : event.getParam("selectProfitCenterMTE"),
                COWO_MaterialGroup1__c : event.getParam("selectMaterialGroup1"),
                COWO_ShippingInstructions__c : event.getParam("shippingInstructions"),
                COWO_SalesNoteCustome__c : event.getParam("salesNoteCustome"),
                COWO_SalesUnit__c : event.getParam("selectSalesUnit"),
            });
            // draftValuesを設定する
            cmp.find('QuoteLineItemBulkEditCmp').find("datatable").set("v.draftValues", cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.draftValues").concat(draftValues));
        } 

        // //TODO copyMethod最適化
        // cmp.find('QuoteLineItemBulkEditCmp').set('v.selectQuantityUnit',event.getParam("selectQuantityUnit"));
        // cmp.find('QuoteLineItemBulkEditCmp').set('v.selectDetailCategory',event.getParam("selectDetailCategory"));
        // cmp.find('QuoteLineItemBulkEditCmp').set('v.selectDetailCategoryMTE',event.getParam("selectDetailCategoryMTE"));
        // cmp.find('QuoteLineItemBulkEditCmp').set('v.selectRejectionReason',event.getParam("selectRejectionReason"));
        // cmp.find('QuoteLineItemBulkEditCmp').set('v.selectPlantCode',event.getParam("selectPlantCode"));
        // cmp.find('QuoteLineItemBulkEditCmp').set('v.selectPlantCodeMTE',event.getParam("selectPlantCodeMTE"));
        // cmp.find('QuoteLineItemBulkEditCmp').set('v.selectStorageLocation',event.getParam("selectStorageLocation"));
        // cmp.find('QuoteLineItemBulkEditCmp').set('v.selectStorageLocationMTE',event.getParam("selectStorageLocationMTE"));
        // cmp.find('QuoteLineItemBulkEditCmp').set('v.selectCurrency',event.getParam("selectCurrency"));
        // cmp.find('QuoteLineItemBulkEditCmp').set('v.selectRecordingDivision',event.getParam("selectRecordingDivision"));
        // cmp.find('QuoteLineItemBulkEditCmp').set('v.selectProfitCenter',event.getParam("selectProfitCenter"));
        // cmp.find('QuoteLineItemBulkEditCmp').set('v.selectProfitCenterMTE',event.getParam("selectProfitCenterMTE"));
        // cmp.find('QuoteLineItemBulkEditCmp').set('v.selectMaterialGroup1',event.getParam("selectMaterialGroup1"));
        // enable button
        if(cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.draftValues").length > 0 || cmp.find('QuoteLineItemBulkEditCmp').get('v.deletedData').length > 0){
            cmp.find('QuoteLineItemBulkEditCmp').set('v.hasChanged', true);
        } else {
            cmp.find('QuoteLineItemBulkEditCmp').set('v.hasChanged', false);
        }
    },
})