({
	formPress: function(cmp, event, helper) {
        // if (evt.keyCode === 27) {
        //     // alert("EditClose");
        // }
        //alert(event.getParams().keyCode);
        // var ctrlDown = evt.ctrlKey||evt.metaKey; // Mac support
        // if (evt.metaKey && evt.keyCode === 67) {
        //     alert(evt.keyCode);
        // }

        // // Check for Alt+Gr (http://en.wikipedia.org/wiki/AltGr_key)
        // if (ctrlDown && evt.altKey) return true

        // // Check for ctrl+c, v and x
        // else if (ctrlDown && c==67) alert("crtl + c"); // c
        // else if (ctrlDown && c==86) return false // v
        // else if (ctrlDown && c==88) return false // x

        // // Otherwise allow
        // return true
    },
    addLineItem: function (cmp, event, helper) {
        // notice parent component to open the SearchProduct component
        var openSearchProductEvent = cmp.getEvent("openSearchProduct");
        openSearchProductEvent.setParams({pricebook2Id: cmp.get("v.pricebook2Id"),
                                          opportunityId: cmp.get("v.recordId"),
                                          isPSGHHTUser:cmp.get('v.isPSGHHTUser')}).fire();
    },
    addRowsToBeginning: function (cmp, event, helper) {
        var data = helper.addData();
        var currentData = cmp.get('v.data');
        var newData = data.concat(currentData);
        cmp.set('v.data', newData);
    },
    addRowsToEnd: function (cmp, event, helper) {
        
        var date = new Date();
        var format_str = 'NewYYYYMMDDhhmmss';
        format_str = format_str.replace(/YYYY/g, date.getFullYear());
        format_str = format_str.replace(/MM/g, ('' + (date.getMonth() + 1)).padStart(2, '0'));
        format_str = format_str.replace(/DD/g, ('' + date.getDate()).padStart(2, '0'));
        format_str = format_str.replace(/hh/g, ('' + date.getHours()).padStart(2, '0'));
        format_str = format_str.replace(/mm/g, ('' + date.getMinutes()).padStart(2, '0'));
        format_str = format_str.replace(/ss/g, ('' + date.getSeconds()).padStart(2, '0'));
        format_str = format_str + ('' + date.getMilliseconds()).padStart(3, '0');
        
        var data = cmp.find("datatable").get('v.data');
        var newData = [
            {
                Id: format_str,
                SAWO_ItemNumber__c : data.length + 1,
                SAWO_ProductName__c : "",
                SAWO_ProductCode__c : "",
                SAWO_Parts_No__c :  "",
                Quantity : 1,
                UnitPrice : 0,
                SAWO_SalesPrice__c : 0,
                SAWO_QuantityUnit__c : "",
                SAWO_SalesUnit__c : "",
                SAWO_PartitionPrice__c : "",
                TC__c : 0,
                MC__c : 0,
                SAWO_LocalCorporationTC__c : 0,
                SAWO_FrontPurchasePrice__c : 0,
                SAWO_DetailCategory__c : "",
                SAWO_DetailCategory_MTE__c : "",
                SAWO_RejectionReason__c : "",
                SAWO_PlantCode__c : "",
                SAWO_PlantCode_MTE__c : "",
                SAWO_StorageLocation__c : "",
                SAWO_StorageLocation_MTE__c : "",
                SAWO_S4LinkagePrice__c : 0,
                SAWO_Currency__c : cmp.get('v.currencyIsoCode'),
                SAWO_Recording_Division__c : "",
                SAWO_WBSElement__c : "",
                SAWO_ProfitCenter__c : "",
                SAWO_ProfitCenter_MTE__c : "",
                SAWO_ItemText__c : "",
                SAWO_DeliverySchedule__c : $A.localizationService.formatDate(new Date(), "YYYY-MM-DD"),
                SAWO_MaterialAvailDate__c : $A.localizationService.formatDate(new Date(), "YYYY-MM-DD"),
                SAWO_MaterialGroup1__c : "",
                SAWO_ShippingInstructions__c : "",
                SAWO_SalesNoteCustome__c : "",
                SAWO_NoDiscountFlg__c : false,
                SAWO_DiscountPrice__c : 0,
                CurrencyIsoCode:cmp.get('v.currencyIsoCode'),
                SAWO_LocalParts__c : false,
                SAWO_ConditionRate_DeliveryCost__c : 0,
                SAWO_ConditionRate_Taxes__c : 0,
                SAWO_ConditionRate_Insurance__c : 0,
                SA_Insurance_fee__c : 0,
                SA_Freight__c : 0,
                SA_Other_Duties__c : 0,
                SA_Reservers_Fixed__c : 0,
                trendIcon: 'utility:warning'
            }
        ];
        // データ行を追加する
        cmp.set('v.data', cmp.get('v.data').concat(newData));
        
        // draftValuesを設定する
        cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get("v.draftValues").concat(newData));
        
        // enable button
        if(cmp.find("datatable").get("v.draftValues").length > 0 || cmp.get('v.deletedData').length > 0){
            cmp.set('v.hasChanged', true);
        } else {
            cmp.set('v.hasChanged', false);
        }
    },
    deleteRows: function (cmp, event) {
        if(cmp.find("datatable").get("v.selectedRows").length == 0){
            // Display the total in a "toast" status message
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                type: "warning",
                mode: 'dismissible',
                message: $A.get("$Label.c.COWO_MSG_NoRowsSelected")
            });
            resultsToast.fire();
            return;
        };

        // 削除対象行情報を保持する
        var selectedRows = cmp.get("v.selectedRows");
        for(var idx = 0; idx < selectedRows.length; idx++){
           if(selectedRows[idx].CO_ovcUpdateFlag__c == 'U' || selectedRows[idx].CO_ovcUpdateFlag_MTE__c == 'U' ){
                // Display the total in a "toast" status message
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    type: "warning",
                    mode: 'dismissible',
                    message:$A.get("$Label.c.COWO_MSG_S4UpdateDataCannotDelete")
                });
                resultsToast.fire();
           }
        }

        // 削除対象行情報を保持する
        var selectedRows = cmp.get("v.selectedRows");

        var data = cmp.find("datatable").get('v.data');
        var draftValues = cmp.find("datatable").get("v.draftValues");
        cmp.find("datatable").get("v.selectedRows").forEach(function(element){
            
            // dataを再設定する
            for(var i = 0; i < data.length; i++){
                if(data[i].CO_ovcUpdateFlag__c != 'U' && data[i].CO_ovcUpdateFlag_MTE__c != 'U'){
                    if(data[i].Id == element){
                        for(var idx = 0; idx < draftValues.length; idx++){
                            if(draftValues[idx].Id == data[i].Id){
                                draftValues.splice(idx,1);
                                cmp.find("datatable").set("v.draftValues", draftValues);
                            }
                        }
                        data.splice(i,1);
                        cmp.find("datatable").set('v.data', data);
                        break;
                    }
                    
                }
            }
        });

        // 削除列が元データの場合、それを保持する TODO
        selectedRows.forEach(function(element){
            if(element.Id.substr(0,3) != "Add" && element.Id.substr(0,3) != "New"){
                if(element.CO_ovcUpdateFlag__c != 'U' && element.CO_ovcUpdateFlag_MTE__c != 'U'){
                    cmp.set('v.deletedData', cmp.get('v.deletedData').concat(element));
                    cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get("v.draftValues").concat(element));
                }
            }
        });
        
        // enable button
        if(cmp.find("datatable").get("v.draftValues").length > 0 || cmp.get('v.deletedData').length > 0){
            cmp.set('v.hasChanged', true);
        } else {
            cmp.set('v.hasChanged', false);
        }
    },
    handleCancel: function (cmp, event, helper) {
        cmp.set("v.data", cmp.get("v.originalData"));
        cmp.find("datatable").set("v.draftValues", []);
        cmp.set('v.deletedData', []);
        
        // enable button
        if(cmp.find("datatable").get("v.draftValues").length > 0 || cmp.get('v.deletedData').length > 0){
            cmp.set('v.hasChanged', true);
        } else {
            cmp.set('v.hasChanged', false);
        }
    },
    handleCellchange: function (cmp, event, helper) {
        // enable button
        if(cmp.find("datatable").get("v.draftValues").length > 0 || cmp.get('v.deletedData').length > 0){
            var data = cmp.find("datatable").get("v.data");
            var draftValues =  cmp.find("datatable").get("v.draftValues");
            var originData = cmp.get("v.originalData");
            for(var index = 0;index < data.length; index++){
                for(var draftIndex = 0;draftIndex < draftValues.length; draftIndex++){
                    var tempD = JSON.stringify(draftValues[draftIndex]);
                    if(data[index].Id == draftValues[draftIndex].Id){
                        // data 行を最新化する
                        Object.assign(data[index], draftValues[draftIndex]);
                        // S4連携済みレコードは品目コード変更不可
                        if(data[index].CO_ovcUpdateFlag_MTE__c == 'U'|| data[index].CO_ovcUpdateFlag__c == 'U'){
                            if(originData[index].Id == data[index].Id){
                                data[index].SAWO_ProductCode__c = originData[index].sawo_ProductCode;
                                draftValues[draftIndex].SAWO_ProductCode__c = data[index].SAWO_ProductCode__c;
                            }
                        }
                        data[index].SAWO_S4LinkagePrice__c = helper.convertNumber(data[index].SAWO_SalesPrice__c) - helper.convertNumber(data[index].SAWO_DiscountPrice__c);
                        draftValues[draftIndex].SAWO_S4LinkagePrice__c = data[index].SAWO_S4LinkagePrice__c;
                        // 古いdraftを削除する
                        var tempDraft = draftValues[draftIndex];
                        draftValues.splice(draftIndex,1);
                        cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get("v.draftValues").concat(tempDraft));
                        break;
                    }
                }
            }
            cmp.set('v.hasChanged', true);
        } else {
            cmp.set('v.hasChanged', false);
        }
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'picklistSupport':
                helper.showRowDetails(cmp,row);
                break;
            default:
                helper.showRowDetails(cmp,row);
                break;
        }
    },
    handleSave: function (cmp, event, helper) {
        // disable page
        cmp.set('v.showSpinner', true);

        // new data and updated data
        // var draftValues = event.getParam('draftValues');
        var draftValues = cmp.find("datatable").get("v.draftValues");
        // deleted data
        var deletedData = cmp.get("v.deletedData");

        // パラメータ設定
        var params = {
            opportunityId:cmp.get("v.recordId"),
            draftValues:JSON.stringify(draftValues),
            datas:JSON.stringify(cmp.find("datatable").get("v.data")),
            deletedData:JSON.stringify(deletedData),
            digits:cmp.get('v.digits'),
            isPSGHHTUser:cmp.get('v.isPSGHHTUser')
        };

        // データ登録
        helper.reflectEditedData(cmp, params);
    },
    init: function (cmp, event, helper) {
        // デバイスの確認
        cmp.set('v.device', $A.get("$Browser.formFactor"));
        // 列名設定
        //cmp.set('v.columns', helper.getColumnDefinitions());
        // データ取得
        helper.fetchData(cmp);
    },
    onCloseClicked: function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    onOpenCalled: function(cmp, event, helper) {
    },
    resetColumns: function (cmp, event, helper) {
        helper.resetLocalStorage();

        // なぜかcolumnsを設定後、draftValuesが前回のdraftValuesになる
        // そのため、勝手に変更される前にバックアップする
        var tmpDraftValues = cmp.find("datatable").get("v.draftValues");

        // なぜかcolumnsを設定後、draftValuesが前回のdraftValuesになる
        cmp.set('v.columns', helper.getColumnDefinitions());

        // draftValuesをリセットする
        cmp.find("datatable").set("v.draftValues", tmpDraftValues);
    },
    selectValueCopy: function (cmp, event, helper) {
        var selectRows = cmp.get("v.selectedRows");
        var copyFrom = cmp.get('v.copyFrom');
        console.log('copyFrom' + copyFrom);
        var data = cmp.find("datatable").get("v.data");
        var draftValues = cmp.find("datatable").get("v.draftValues");
        if(selectRows.length > 0){
            for(var idx = 0; idx < selectRows.length;idx ++){
                for(var dataIdx = 0;dataIdx < data.length; dataIdx++){
                    if(data[dataIdx].Id == selectRows[idx].Id){
                        data[dataIdx].SAWO_QuantityUnit__c = copyFrom.SAWO_QuantityUnit__c;
                        data[dataIdx].SAWO_DetailCategory__c = copyFrom.SAWO_DetailCategory__c;
                        data[dataIdx].SAWO_DetailCategory_MTE__c = copyFrom.SAWO_DetailCategory_MTE__c;
                        data[dataIdx].SAWO_RejectionReason__c = copyFrom.SAWO_RejectionReason__c;
                        data[dataIdx].SAWO_PlantCode__c = copyFrom.SAWO_PlantCode__c;
                        data[dataIdx].SAWO_PlantCode_MTE__c = copyFrom.SAWO_PlantCode_MTE__c;
                        data[dataIdx].SAWO_StorageLocation__c = copyFrom.SAWO_StorageLocation__c;
                        data[dataIdx].SAWO_StorageLocation_MTE__c = copyFrom.SAWO_StorageLocation_MTE__c;
                        data[dataIdx].SAWO_Currency__c = copyFrom.SAWO_Currency__c;
                        data[dataIdx].SAWO_Recording_Division__c = copyFrom.SAWO_Recording_Division__c;
                        data[dataIdx].SAWO_ProfitCenter__c = copyFrom.SAWO_ProfitCenter__c;
                        data[dataIdx].SAWO_ProfitCenter_MTE__c = copyFrom.SAWO_ProfitCenter_MTE__c;
                        data[dataIdx].SAWO_MaterialGroup1__c = copyFrom.SAWO_MaterialGroup1__c;
                    }
                }
                if(draftValues.length > 0){
                    for(var dftIdx = 0;dftIdx < draftValues.length; dftIdx++){
                        if(draftValues[dftIdx].Id == selectRows[idx].Id){
                            draftValues[dftIdx].SAWO_QuantityUnit__c = copyFrom.SAWO_QuantityUnit__c;
                            draftValues[dftIdx].SAWO_DetailCategory__c = copyFrom.SAWO_DetailCategory__c;
                            draftValues[dftIdx].SAWO_DetailCategory_MTE__c = copyFrom.SAWO_DetailCategory_MTE__c;
                            draftValues[dftIdx].SAWO_RejectionReason__c = copyFrom.SAWO_RejectionReason__c;
                            draftValues[dftIdx].SAWO_PlantCode__c = copyFrom.SAWO_PlantCode__c;
                            draftValues[dftIdx].SAWO_PlantCode_MTE__c = copyFrom.SAWO_PlantCode_MTE__c;
                            draftValues[dftIdx].SAWO_StorageLocation__c = copyFrom.SAWO_StorageLocation__c;
                            draftValues[dftIdx].SAWO_StorageLocation_MTE__c = copyFrom.SAWO_StorageLocation_MTE__c;
                            draftValues[dftIdx].SAWO_Currency__c = copyFrom.SAWO_Currency__c;
                            draftValues[dftIdx].SAWO_Recording_Division__c = copyFrom.SAWO_Recording_Division__c;
                            draftValues[dftIdx].SAWO_ProfitCenter__c = copyFrom.SAWO_ProfitCenter__c;
                            draftValues[dftIdx].SAWO_ProfitCenter_MTE__c = copyFrom.SAWO_ProfitCenter_MTE__c;
                            draftValues[dftIdx].SAWO_MaterialGroup1__c = copyFrom.SAWO_MaterialGroup1__c;
                        }else{
                            var newDraftTmp = [
                                {
                                    Id: selectRows[idx].Id,
                                    SAWO_QuantityUnit__c : copyFrom.SAWO_QuantityUnit__c,
                                    SAWO_DetailCategory__c : copyFrom.SAWO_DetailCategory__c,
                                    SAWO_DetailCategory_MTE__c : copyFrom.SAWO_DetailCategory_MTE__c,
                                    SAWO_RejectionReason__c : copyFrom.SAWO_RejectionReason__c,
                                    SAWO_PlantCode__c : copyFrom.SAWO_PlantCode__c,
                                    SAWO_PlantCode_MTE__c : copyFrom.SAWO_PlantCode_MTE__c,
                                    SAWO_StorageLocation__c : copyFrom.SAWO_StorageLocation__c,
                                    SAWO_StorageLocation_MTE__c : copyFrom.SAWO_StorageLocation_MTE__c,
                                    SAWO_Currency__c : copyFrom.SAWO_Currency__c,
                                    SAWO_Recording_Division__c : copyFrom.SAWO_Recording_Division__c,
                                    SAWO_ProfitCenter__c : copyFrom.SAWO_ProfitCenter__c,
                                    SAWO_ProfitCenter_MTE__c : copyFrom.SAWO_ProfitCenter_MTE__c,
                                    SAWO_MaterialGroup1__c : copyFrom.SAWO_MaterialGroup1__c,
                                    trendIcon: 'utility:warning'
                                }
                            ];
                            cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get("v.draftValues").concat(newDraftTmp));
                        }
                        break;
                    }
                }else{
                    var newDraftTmp = [
                        {
                            Id: selectRows[idx].Id,
                            SAWO_QuantityUnit__c : copyFrom.SAWO_QuantityUnit__c,
                            SAWO_DetailCategory__c : copyFrom.SAWO_DetailCategory__c,
                            SAWO_DetailCategory_MTE__c : copyFrom.SAWO_DetailCategory_MTE__c,
                            SAWO_RejectionReason__c : copyFrom.SAWO_RejectionReason__c,
                            SAWO_PlantCode__c : copyFrom.SAWO_PlantCode__c,
                            SAWO_PlantCode_MTE__c : copyFrom.SAWO_PlantCode_MTE__c,
                            SAWO_StorageLocation__c : copyFrom.SAWO_StorageLocation__c,
                            SAWO_StorageLocation_MTE__c : copyFrom.SAWO_StorageLocation_MTE__c,
                            SAWO_Currency__c : copyFrom.SAWO_Currency__c,
                            SAWO_Recording_Division__c : copyFrom.SAWO_Recording_Division__c,
                            SAWO_ProfitCenter__c : copyFrom.SAWO_ProfitCenter__c,
                            SAWO_ProfitCenter_MTE__c : copyFrom.SAWO_ProfitCenter_MTE__c,
                            SAWO_MaterialGroup1__c : copyFrom.SAWO_MaterialGroup1__c,
                            trendIcon: 'utility:warning'
                        }
                    ];
                    cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get("v.draftValues").concat(newDraftTmp));
                }
            }
            cmp.find("datatable").set("v.data", data);
            selectRows.splice(0,selectRows.length);
            cmp.find("datatable").set("v.selectedRows",selectRows);
            console.log(cmp.get("v.data"));
            cmp.set('v.hasChanged', true);
        }
    },
    setItemNumber: function(cmp, event, helper) {
        var data = cmp.find("datatable").get("v.data");
        if(cmp.find("datatable").get("v.draftValues").length > 0){
            cmp.find("datatable").get("v.draftValues").splice(0,cmp.find("datatable").get("v.draftValues").length);
        }
        if(data.length > 0){
            for(var idx = 0;idx < data.length; idx++){
                data[idx].SAWO_ItemNumber__c = idx + 1;
                var newDraftTmp = [
                    {
                        Id: data[idx].Id,
                        SAWO_ItemNumber__c : data[idx].SAWO_ItemNumber__c,
                        trendIcon: 'utility:warning'
                    }
                ];
                cmp.find("datatable").set('v.draftValues',cmp.find("datatable").get('v.draftValues').concat(newDraftTmp));
            }
            
        }
        //alert(draftValues.length);
        cmp.find("datatable").set('v.data',data);
        
        cmp.set("v.hasChanged",true);
    },
    storeColumnWidths: function (cmp, event, helper) {
        helper.storeColumnWidths(event.getParam('columnWidths'));
    },
    updateColumnSorting: function (cmp, event, helper) {
        cmp.set('v.isLoading', true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        setTimeout($A.getCallback(function() {
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            cmp.set("v.sortedBy", fieldName);
            cmp.set("v.sortedDirection", sortDirection);
            helper.sortData(cmp, fieldName, sortDirection);
            cmp.set('v.isLoading', false);
        }), 0);
    },
    updateSelectedText: function (cmp, event) {
        cmp.set("v.selectedRows", event.getParam('selectedRows'));
    },
    chooseCopyFrom: function(cmp, event, helper){
        if(cmp.find("datatable").get("v.selectedRows").length == 0){
            // Display the total in a "toast" status message
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                type: "warning",
                mode: 'dismissible',
                message: $A.get("$Label.c.COWO_LBL_OriginDataNoSelected")
            });
            resultsToast.fire();
            return;
        };

        var selectRows = cmp.get("v.selectedRows");
        cmp.set('v.copyFrom',selectRows[0]);
        selectRows.splice(0,selectRows.length);
        cmp.find("datatable").set("v.selectedRows",selectRows);
    }
})