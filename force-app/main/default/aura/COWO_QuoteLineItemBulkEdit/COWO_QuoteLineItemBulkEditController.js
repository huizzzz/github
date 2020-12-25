({
	formPress: function(cmp, event, helper) {
        if (event.keyCode === 27) {
            // alert("EditClose");
        }
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
        
        var sortNo = cmp.find("datatable").get('v.data').length + 1;
        var newData = [
            {
                Id: format_str,
                COWO_ProductName__c: "",
                COWO_Quantity__c: "",
                COWO_Price__c: null,
                COWO_SubTotal__c: null,
                COWO_SortNo__c:sortNo,
                CurrencyIsoCode:cmp.get('v.currencyIsoCode'),
                COWO_ItemNumber__c: "",
                trendIcon: 'utility:warning',
                COWO_Description__c:"",
            }
        ];

        // データ行を追加する
        cmp.find("datatable").set('v.data', cmp.find("datatable").get('v.data').concat(newData));
        
        // draftValuesを設定する
        cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get("v.draftValues").concat(newData));
        
        // enable button
        if(cmp.find("datatable").get("v.draftValues").length > 0 || cmp.get('v.deletedData').length > 0){
            cmp.set('v.hasChanged', true);
        } else {
            cmp.set('v.hasChanged', false);
        }
    },
    cancelSummary:function(cmp, event){
        var data = cmp.get('v.data');
        var originalData = cmp.get('v.originalData');
        console.log(originalData);
        if(data.length > 0){
            data.splice(0,data.length);
        }
        var delData = cmp.get('v.deletedData');
        delData.splice(0,delData.length);
        cmp.set('v.deletedData',delData);
        cmp.set("v.data",data.concat(originalData));
        cmp.set('v.noSelected',true);
        cmp.set('v.canceled',true);
    },
    clearAmount: function (cmp, event,helper) {
        var data = cmp.find("datatable").get('v.data');
        var amountSummary = cmp.get('v.amountSummary');
        var remainAmount = cmp.get('v.remainAmount');
        cmp.find("datatable").get("v.selectedRows").forEach(function(element){
            // var data = cmp.find("datatable").get('v.data');
            // dataを再設定する
            for(var i = 0; i < data.length; i++){
                if(data[i].Id == element){
                    amountSummary = helper.convertNumber(amountSummary) - helper.convertNumber(data[i].COWO_SubTotal__c);
                    data[i].COWO_Price__c = '';
                    data[i].COWO_SubTotal__c = '';
                    break;
                }
            }
            // draftValuesにも保持する必要がある
            var newDraftTmp = [
                {
                    Id: data[i].Id,
                    COWO_Price__c: '',
                    COWO_SubTotal__c:'',
                    trendIcon: 'utility:warning'
                }
            ];
            cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get('v.draftValues').concat(newDraftTmp));
        });
        remainAmount = amountSummary - helper.convertNumber(cmp.get('v.finalAmount'));
        cmp.find("datatable").set("v.data", data);
        cmp.set('v.amountSummary',amountSummary);
        cmp.set('v.remainAmount',remainAmount);
        cmp.set('v.hasChanged', true);
    },
    clearQuantity: function (cmp, event) {
        var data = cmp.find("datatable").get('v.data');
        cmp.find("datatable").get("v.selectedRows").forEach(function(element){
            for(var i = 0; i < data.length; i++){
                if(data[i].Id == element){
                    data[i].COWO_Quantity__c = '';
                    break;
                }
            }
            var newDraftTmp = [
                {
                    Id: data[i].Id,
                    COWO_Quantity__c: '',
                    trendIcon: 'utility:warning'
                }
            ];
            cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get('v.draftValues').concat(newDraftTmp));
        
        });
        cmp.find("datatable").set("v.data", data);
        cmp.set('v.hasChanged', true);
    },
    deleteRows: function (cmp, event,helper) {
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

        cmp.find("datatable").get("v.selectedRows").forEach(function(element){
            var data = cmp.find("datatable").get('v.data');
            // dataを再設定する
            for(var i = 0; i < data.length; i++){
                if(data[i].Id == element){
                    data.splice(i,1);
                    cmp.find("datatable").set('v.data', data);
                    break;
                }
            }
            // draftValuesにも保持する必要がある
            var draftValues = cmp.find("datatable").get("v.draftValues");
            for(var i = 0; i < draftValues.length; i++){
                if(draftValues[i].Id == element){
                    draftValues.splice(i,1);
                    cmp.find("datatable").set("v.draftValues", draftValues);
                    break;
                }
            }
        });

        // 選択行をdeleteListに追加
        selectedRows.forEach(function(element){
            cmp.set('v.deletedData', cmp.get('v.deletedData').concat(element));
        });
        
        var newData = cmp.find("datatable").get('v.data');
    　　for(var idx=0;idx < newData.length;idx++){
            newData[idx].COWO_SortNo__c = idx + 1;
        }
        cmp.find("datatable").set('v.data',newData);
        // sortNo更新
        helper.sortData(cmp, 'COWO_SortNo__c', 'asc');
        // 入力チェックを行う
        helper.validationCheck(cmp);

        // enable button
        if(cmp.find("datatable").get("v.draftValues").length > 0 || cmp.get('v.deletedData').length > 0){
            cmp.set('v.hasChanged', true);
        } else {
            cmp.set('v.hasChanged', false);
        }
    },
    doSummary: function(cmp, event, helper){
        cmp.set("v.hasChanged", true);

        var selectRows = cmp.get("v.selectedRows");
        var data = cmp.find("datatable").get("v.data");
        var draftValues = cmp.find("datatable").get("v.draftValues");
        //var sumQuantity = 0;
        var sumUnitprice= 0;
        var sumSubtotal = 0;
        var delRows = [];
            
        if(selectRows.length > 0){
            for(var selectIdx = 0 ; selectIdx < selectRows.length ; selectIdx++){
                //sumQuantity += helper.convertNumber(selectRows[selectIdx].COWO_Quantity__c);
                sumUnitprice += helper.convertNumber(selectRows[selectIdx].COWO_Price__c);
                sumSubtotal += helper.convertNumber(selectRows[selectIdx].COWO_SubTotal__c);
                // 選択行をDataから削除する
                for(var dataIdx = 0; dataIdx < data.length; dataIdx++){
                    if(data[dataIdx].Id == selectRows[selectIdx].Id){
                        data.splice(dataIdx,1);
                    }
                }
                // 選択行をdraftValueから削除する
                for(var dftIdx = 0; dftIdx < draftValues.length; dftIdx++){
                    if(draftValues[dftIdx].Id == selectRows[selectIdx].Id){
                        // 古いdraftを削除する
                        draftValues.splice(dftIdx,1);
                    }
                }
            }
            
            var date = new Date();
            var format_str = 'NewYYYYMMDDhhmmss';
            format_str = format_str.replace(/YYYY/g, date.getFullYear());
            format_str = format_str.replace(/MM/g, ('' + (date.getMonth() + 1)).padStart(2, '0'));
            format_str = format_str.replace(/DD/g, ('' + date.getDate()).padStart(2, '0'));
            format_str = format_str.replace(/hh/g, ('' + date.getHours()).padStart(2, '0'));
            format_str = format_str.replace(/mm/g, ('' + date.getMinutes()).padStart(2, '0'));
            format_str = format_str.replace(/ss/g, ('' + date.getSeconds()).padStart(2, '0'));
            format_str = format_str + ('' + date.getMilliseconds()).padStart(3, '0');
            
            var newData = [
                {
                    Id: format_str,
                    COWO_ProductName__c: $A.get("$Label.c.COWO_Label_OneSet"),
                    COWO_Quantity__c: $A.get("$Label.c.COWO_Label_OneSet"),
                    COWO_Price__c: sumUnitprice,
                    COWO_SubTotal__c: sumSubtotal,
                    COWO_SortNo__c: 1,
                    CurrencyIsoCode:cmp.get('v.currencyIsoCode'),
                    trendIcon: 'utility:warning'
                }
            ];
            
            // ソートNoを再適用
            if(data.length > 0){
                for(var idx = 0 ; idx < data.length; idx++){
                    data[idx].COWO_SortNo__c = idx + 2;
                }
            }
            cmp.set('v.deletedData',cmp.get('v.deletedData').concat(selectRows));
            cmp.find("datatable").set('v.data',data.concat(newData));
            cmp.find("datatable").set("v.draftValues", draftValues.concat(newData));
            // sortNo更新
            helper.sortData(cmp, 'COWO_SortNo__c', 'asc');
            // 入力チェックを行う
            helper.validationCheck(cmp);
        }
        cmp.set('v.canceled', false);  
    },
    handleCancel: function (cmp, event, helper) {
        cmp.find("datatable").set("v.data", cmp.get("v.originalData"));
        cmp.find("datatable").set("v.draftValues", []);
        cmp.set('v.deletedData', []);
        
        // enable button
        if(cmp.find("datatable").get("v.draftValues").length > 0 || cmp.get('v.deletedData').length > 0){
            cmp.set('v.hasChanged', true);
        } else {
            cmp.set('v.hasChanged', false);
        }
    },
    handleCellchange: function (cmp, event,helper) {
        // enable button
        if(cmp.find("datatable").get("v.draftValues").length > 0 || cmp.get('v.deletedData').length > 0){
            var data =cmp.find("datatable").get("v.data");
            var draftValues =  cmp.find("datatable").get("v.draftValues");
            var amountSummary = cmp.get('v.amountSummary');
            var remainAmount = 0;
            for(var index = 0;index < data.length; index++){
                for(var draftIndex = 0;draftIndex < draftValues.length; draftIndex++){
                    if(data[index].Id == draftValues[draftIndex].Id){
                        // data 行を最新化する
                        Object.assign(data[index], draftValues[draftIndex]);
                        break;
                    }
                }
            }
            // 入力チェックを行う
            helper.validationCheck(cmp);
            cmp.set('v.hasChanged', true);
        } else {
            cmp.set('v.hasChanged', false);
        }
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'COWOQLISupport':
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
		// Data値を最新化
        var data = cmp.find("datatable").get("v.data");

        // パラメータ設定
        var params = {
           quoteId:cmp.get("v.recordId"),
           draftValues:JSON.stringify(draftValues),
           deletedData:JSON.stringify(deletedData),
           datas:JSON.stringify(data),
           currencyIsoCode:cmp.get('v.currencyIsoCode'),
           digits:cmp.get('v.digits')
        };

        // データ登録
        helper.reflectEditedData(cmp, params);
    },
    init: function (cmp, event, helper) {
        // デバイスの確認
        cmp.set('v.device', $A.get("$Browser.formFactor"));
        // データ取得
        helper.fetchData(cmp);
    },
    changeRecal: function(cmp, event, helper) {
    },
    onCloseClicked: function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    onOpenCalled: function(cmp, event, helper) {
    },　
    setItemNumber: function(cmp, event, helper) {
        var data = cmp.find("datatable").get("v.data");
        var draftValues = cmp.find("datatable").get("v.draftValues");
        if(data.length > 0){
            for(var idx = 0;idx < data.length; idx++){
                data[idx].COWO_ItemNumber__c = idx + 1;
            }
        }
        
        cmp.find("datatable").set('v.data',data);
        cmp.set("v.hasChanged",true);
    },　
    storeColumnWidths: function (cmp, event, helper) {
        helper.storeColumnWidths(event.getParam('columnWidths'));
    },
    upSort:function (cmp, event, helper) {
        var selectRows = cmp.get("v.selectedRows");
        var data = cmp.find("datatable").get("v.data");
        var draftValues = cmp.find("datatable").get("v.draftValues");
                
        if(selectRows.length > 0){
            for(var selectIdx = 0 ; selectIdx < selectRows.length ; selectIdx++){
                selectRows[selectIdx].COWO_SortNo__c = selectIdx + 1;
                for(var idx = 0;idx < data.length;idx++){
                    if(data[idx].Id == selectRows[selectIdx].Id){
                        // 古いdraftを削除する
                        data.splice(idx,1);
                    }
                    // 選択行以外レコード並び順更新
                    if(data[idx] != null){
                        data[idx].COWO_SortNo__c = idx + 1 + selectRows.length;
                    }
                }
            }  
            cmp.find("datatable").set('v.data',data.concat(selectRows));
            helper.sortData(cmp, 'COWO_SortNo__c', 'asc');
        }
    },
    upSortOne:function (cmp, event, helper) {
        var selectRows = cmp.get("v.selectedRows");
        var data = cmp.find("datatable").get("v.data");
        var draftValues = cmp.find("datatable").get("v.draftValues");
        var endSortNo = 0;
        
        if(selectRows.length > 0 && data.length > 1){
            // 選択行の並び番号リセット処理
            for(var idx = 0; idx < data.length; idx++) {
                for(var selectIdx = 0 ; selectIdx < selectRows.length; selectIdx++) {
                    endSortNo = selectRows[selectRows.length -1].COWO_SortNo__c;
                    if(data[idx].Id == selectRows[selectIdx].Id) {
                        if(endSortNo != selectRows.length){
                            if(data[idx].COWO_SortNo__c - 1 > 0){ 
                                data[idx].COWO_SortNo__c = data[idx].COWO_SortNo__c - 1;
                                endSortNo--;
                            }
                        }
                        break;
                    }
                }
            }
            // 選択行以外の並び番号リセット処理
            for(var loopTimes = 0; loopTimes < selectRows.length; loopTimes++){
                for(var idx = 0; idx < data.length; idx++) {
                    for(var selectIdx = 0 ; selectIdx < selectRows.length; selectIdx++) {
                        if(data[idx].COWO_SortNo__c == selectRows[selectIdx].COWO_SortNo__c && data[idx].Id != selectRows[selectIdx].Id) {
                            data[idx].COWO_SortNo__c = data[idx].COWO_SortNo__c + 1;
                            break;
                        }
                    }
                }
            }
            // リソートする
            cmp.find("datatable").set('v.data',data);
            helper.sortData(cmp, 'COWO_SortNo__c', 'asc');
        }

    },
    underSortOne:function (cmp, event, helper) {
        var selectRows = cmp.get("v.selectedRows");
        var data = cmp.find("datatable").get("v.data");
        var draftValues = cmp.find("datatable").get("v.draftValues");
        
        if(selectRows.length > 0 && data.length > 1){
            // 選択行の並び番号リセット処理
            for(var idx = 0; idx < data.length; idx++) {
                for(var selectIdx = 0 ; selectIdx < selectRows.length; selectIdx++) {
                    if(data[idx].Id == selectRows[selectIdx].Id) {
                        if(data[idx].COWO_SortNo__c < data.length){
                            data[idx].COWO_SortNo__c = data[idx].COWO_SortNo__c + 1;
                        }
                        break;
                    }
                }
            }
            // 選択行以外の並び番号リセット処理
            for(var loopTimes = 0; loopTimes < selectRows.length; loopTimes++){
                for(var idx = 0; idx < data.length; idx++) {
                    for(var selectIdx = 0 ; selectIdx < selectRows.length; selectIdx++) {
                        if(data[idx].COWO_SortNo__c == selectRows[selectIdx].COWO_SortNo__c && data[idx].Id != selectRows[selectIdx].Id) {
                            data[idx].COWO_SortNo__c = data[idx].COWO_SortNo__c - 1;
                            break;
                        }
                    }
                }
            }
            // リソートする
            cmp.find("datatable").set('v.data',data);
            helper.sortData(cmp, 'COWO_SortNo__c', 'asc');
        }
    },
    underSort:function (cmp, event, helper) {
        var selectRows = cmp.get("v.selectedRows");
        var data = cmp.find("datatable").get("v.data");
        var draftValues = cmp.find("datatable").get("v.draftValues");
        const originalLen = data.length;
        if(selectRows.length > 0){
            var lenNoSelect = originalLen - selectRows.length;
            for(var idx = 0;idx < data.length;idx++){
                for(var selectIdx = 0 ; selectIdx < selectRows.length ; selectIdx++){
                    selectRows[selectIdx].COWO_SortNo__c = lenNoSelect + selectIdx + 1;
                    if(data[idx].Id == selectRows[selectIdx].Id){
                       // 古いdraftを削除する
                      data.splice(idx,1);
                    }
                 }
                if(data[idx] != null){
                    data[idx].COWO_SortNo__c = idx + 1;
                } 
            }   
            cmp.find("datatable").set('v.data',data.concat(selectRows));
            helper.sortData(cmp, 'COWO_SortNo__c', 'asc');
        }
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
        cmp.set("v.hasChanged",true);
        cmp.set("v.noSelected",false);
        console.log('selectedRows'+ cmp.get("v.selectedRows"));
    },
})