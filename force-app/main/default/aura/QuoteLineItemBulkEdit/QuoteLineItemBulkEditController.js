({
	formPress: function(cmp, event, helper) {
        if (event.keyCode === 27) {
            // alert("EditClose");
        }
    },
    addLineItem: function (cmp, event, helper) {
        // notice parent component to open the SearchProduct component
        var openSearchProductEvent = cmp.getEvent("openSearchProduct");
        openSearchProductEvent.setParams({pricebook2Id: cmp.get("v.pricebook2Id"),
                                          quoteId:cmp.get("v.recordId"),
                                          isPSGHHTUser:cmp.get("v.isPSGHHTUser")}).fire();
    },
    addRowsToBeginning: function (cmp, event, helper) {
        var data = helper.addData();
        var currentData = cmp.get('v.data');
        var newData = data.concat(currentData);
        cmp.set('v.data', newData);
    },
    addRowsToEnd: function (cmp, event, helper) {
        var data = cmp.find("datatable").get("v.data");
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
                COWO_ItemNumber__c : data.length + 1,
                COWO_Product_Name__c: "",
                Quantity: '1',
                UnitPrice: '0',
                COWO_DiscountPrice__c: '0',
                COWO_TotalPrice__c: '0',
                COWO_DiscountUnitPrice__c:'0',
                COWO_TotalLocalCorporationTC__c: '0',
                COWO_TotalFrontPurchasePrice__c: '0',
                COWO_TotalTC__c: '0',
                COWO_TotalMC__c: '0',
                COWO_LocalCorporationTC__c: '0',
                COWO_FrontPurchasePrice__c: '0',
                COWO_QuantityUnit__c : "",
                COWO_TC__c: '0',
                COWO_MC__c: '0',
                Subtotal: '0',
                COWO_PartsNo__c:"",
                COWO_ProductCode__c:"",
                COWO_SortNo__c:data.length + 1,
                CurrencyIsoCode: cmp.get("v.currencyIsoCode"),
                COWO_Currency__c: cmp.get("v.currencyIsoCode"),
                COWO_DetailCategory__c : "",
                COWO_DetailCategory_MTE__c : "",
                COWO_RejectionReason__c : "",
                COWO_PlantCode__c : "",
                COWO_PlantCode_MTE__c : "",
                COWO_StorageLocation__c : "",
                COWO_StorageLocation_MTE__c : "",
                COWO_S4LinkagePrice__c : 0,
                COWO_Currency__c : "",
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
                COWO_NoDiscountFlg__c : false,
                COWO_PartitionPrice__c : "",
                COWO_PartitionPrice__c : "",
                COWO_SalesUnit__c : "",
                CO_ovcUpdateFlag__c : "",
                CO_ovcUpdateFlag_MTE__c : "",
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
    deleteRows: function (cmp, event,helper) {
    //     if(cmp.find("datatable").get("v.selectedRows").length == 0){
    //         // Display the total in a "toast" status message
    //         var resultsToast = $A.get("e.force:showToast");
    //         resultsToast.setParams({
    //             type: "warning",
    //             mode: 'dismissible',
    //             message: $A.get("$Label.c.COWO_MSG_NoRowsSelected")
    //         });
    //         resultsToast.fire();
    //         return;
    //     };

    //     // 削除対象行情報を保持する
    //     var selectedRows = cmp.get("v.selectedRows");

    //     for(var idx = 0; idx < selectedRows.length; idx++){
    //         if(selectedRows[idx].CO_ovcUpdateFlag__c == 'U' || selectedRows[idx].CO_ovcUpdateFlag_MTE__c == 'U' ){
    //              // Display the total in a "toast" status message
    //              var resultsToast = $A.get("e.force:showToast");
    //              resultsToast.setParams({
    //                  type: "warning",
    //                  mode: 'dismissible',
    //                  message:$A.get("$Label.c.COWO_MSG_S4UpdateDataCannotDelete")
    //              });
    //              resultsToast.fire();
    //         }
    //      }

    //     var delFlg = true;
    //     var draftValues = cmp.find("datatable").get("v.draftValues");
    //     var data = cmp.find("datatable").get('v.data');
    //     cmp.find("datatable").get("v.selectedRows").forEach(function(element){
            
    //         // dataを再設定する
    //         for(var i = 0; i < data.length; i++){
    //             if(data[i].Id == element){
    //                 if(data[i].CO_ovcUpdateFlag__c != 'U' && data[i].CO_ovcUpdateFlag_MTE__c != 'U' ){
    //                     data.splice(i,1);
    //                     for(var idx = 0; idx < draftValues.length; idx++){
    //                         if(draftValues[idx].Id == data[i].Id){
    //                             draftValues.splice(idx,1);
    //                             cmp.find("datatable").set("v.draftValues", draftValues);
    //                         }
    //                     }
    //                     if(delFlg == true){
    //                         if(cmp.get('v.delete0Idx') === undefined || i < cmp.get('v.delete0Idx')){
    //                             cmp.set('v.delete0Idx', i);
    //                         }
    //                         delFlg = false;
    //                     }
    //                     cmp.find("datatable").set('v.data', data);
    //                     break;
    //                 }
    //             }
    //         }
    //     });

    //     // 削除列が元データの場合、それを保持する TODO
    //     selectedRows.forEach(function(element){
    //         if(element.Id.substr(0,3) != "Add" && element.Id.substr(0,3) != "New"){
    //             if(element.CO_ovcUpdateFlag__c != 'U' && element.CO_ovcUpdateFlag_MTE__c != 'U'){
    //                 cmp.set('v.deletedData', cmp.get('v.deletedData').concat(element));
    //                 cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get("v.draftValues").concat(element));
    //             }
    //         }   
    //     });
        
    //     helper.cellRecalculate(cmp);
        
    //     // enable button
    //     if(cmp.find("datatable").get("v.draftValues").length > 0 || cmp.get('v.deletedData').length > 0){
    //         cmp.set('v.hasChanged', true);
    //     } else {
    //         cmp.set('v.hasChanged', false);
    //     }
    // },



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
        
        var delFlg = true;
        var draftValues = cmp.find("datatable").get("v.draftValues");
        var data = cmp.find("datatable").get('v.data');
        cmp.find("datatable").get("v.selectedRows").forEach(function(element){
            // dataを再設定する
            for(var i = 0; i < data.length; i++){
                if(data[i].Id == element){
                    if(data[i].CO_ovcUpdateFlag__c != 'U' && data[i].CO_ovcUpdateFlag_MTE__c != 'U' ){
                        for(var idx = 0; idx < draftValues.length; idx++){
                            if(draftValues[idx].Id == data[i].Id){
                                draftValues.splice(idx,1);
                                cmp.find("datatable").set("v.draftValues", draftValues);
                            }
                        }
                        if(delFlg == true){
                            if(cmp.get('v.delete0Idx') === undefined || i < cmp.get('v.delete0Idx')){
                                cmp.set('v.delete0Idx', i);
                            }
                            delFlg = false;
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
        
        helper.cellRecalculate(cmp);
        var tcTemp = cmp.get('v.tcGokei');
        helper.recalPrice(cmp,tcTemp);
        helper.adjustFraction(cmp);
        
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
            var data = cmp.get("v.data");
            var draftValues =  cmp.find("datatable").get("v.draftValues");
            var originData = cmp.get("v.originalData");
            var neibikiGokei = helper.convertNumber(cmp.get('v.headerNebiki01')) + helper.convertNumber(cmp.get('v.headerNebiki02'))+ helper.convertNumber(cmp.get('v.syuseiNebiki01'))+ helper.convertNumber(cmp.get('v.syuseiNebiki02'));
            var tcTemp = helper.convertNumber(cmp.get('v.tcGokei'));
           
            for(var index = 0;index < data.length; index++){
                for(var draftIndex = 0;draftIndex < draftValues.length; draftIndex++){
                    if(data[index].Id == draftValues[draftIndex].Id){
                        //行追加または商品追加レコードは
                       // if(data[index].Id.substr(0,3) == "New" || data[index].Id.substr(0,3) == "Add"){
                            // data 行を最新化する
                            var tempD = JSON.stringify(draftValues[draftIndex]);
                            Object.assign(data[index], draftValues[draftIndex]);
                            if(tempD.indexOf('COWO_DiscountPrice__c') != -1 || tempD.indexOf('COWO_TC__c') != -1 || tempD.indexOf('Quantity') != -1 || tempD.indexOf('UnitPrice') != -1 ){
                                helper.recalPrice(cmp,tcTemp);
                                break;
                            }else{
                                // S4連携済みレコードは品目コード変更不可
                                if(data[index].CO_ovcUpdateFlag_MTE__c == 'U'|| data[index].CO_ovcUpdateFlag__c == 'U'){
                                    if(originData[index].Id == data[index].Id){
                                        data[index].COWO_ProductCode__c = originData[index].cowo_ProductCode;
                                        draftValues[draftIndex].COWO_ProductCode__c = data[index].COWO_ProductCode__c;
                                    }
                                }
                                // 古いdraftを削除する
                                var tempDraft = draftValues[draftIndex];
                                draftValues.splice(draftIndex,1);
                                cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get("v.draftValues").concat(tempDraft));
                                helper.cellRecalculate(cmp);
                                break;	
                            }   
                    }
                }
            }
            helper.adjustFraction(cmp);
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
		// Data値を最新化
        var data = cmp.get("v.data");
		// 数量一式
		var allQuantity = 0;
		// 単価一式
        var allUnitprice = 0;
        // 合計金額一式
        var allTotalprice = 0;
        // 割引単価
        var allDiscountUnitPrice = 0;
        if(draftValues.length > 0 || deletedData.length > 0){
            // draftValuesをdataに反映する
            draftValues.forEach(function(element){
                for(var dataIndex = 0; dataIndex < data.length; dataIndex++){
                    if(data[dataIndex].Id == element.Id){
                        // data 行を最新化する
                        Object.assign(data[dataIndex], element);
                        break;
                    }
                }
            });
        }

        // draftValuesにソートを追加する
        var del0Idx = cmp.get('v.delete0Idx');
        for(var idx = 0;idx < data.length; idx++){
            data[idx].COWO_SortNo__c = idx + 1;
            if(idx >= del0Idx){
                var updFlg = false;
                for(var draftIdx = 0; draftIdx < draftValues.length ; draftIdx++){
                    if(data[idx].Id == draftValues[draftIdx].Id){
                        // update
                        //data[idx].SortOrder = idx + 1;
                        draftValues[draftIdx].COWO_SortNo__c = data[idx].COWO_SortNo__c;
                        updFlg = true;
                    }
                }
                // new 
                if (updFlg == false) {
                    var newDraftTmp = [
                        {
                            Id: data[idx].Id,
                            COWO_SortNo__c: idx + 1
                        }];
                    Array.prototype.push.apply(draftValues, newDraftTmp);
                }
            }
        }
        
        //draftValues.splice(0,draftValues.length);
        /*for(var idx = 0;idx < data.length; idx++){
            data[idx].SortOrder = idx + 1;
        }*/
        console.log(draftValues);

        //一式集計
        for(var dataIndex = 0; dataIndex < data.length; dataIndex++){
            allQuantity += helper.convertNumber(data[dataIndex].Quantity);
            allUnitprice += helper.convertNumber(data[dataIndex].Subtotal);
            allDiscountUnitPrice += helper.convertNumber(data[dataIndex].COWO_DiscountUnitPrice__c);
            // allTotalprice += helper.convertNumber(data[dataIndex].COWO_TotalPrice__c);
            allTotalprice += helper.convertNumber(data[dataIndex].Subtotal);
        }
		cmp.set('v.quoteLineItemParams.nebikiKingaku',cmp.get('v.nebikiKingaku'));
        cmp.set('v.quoteLineItemParams.headerNebikiritsu',cmp.get('v.headerNebikiritsu'));
        cmp.set('v.quoteLineItemParams.headerNebiki01',helper.convertNumber(cmp.get('v.headerNebiki01')));
        cmp.set('v.quoteLineItemParams.headerNebiki02',cmp.get('v.headerNebiki02'));
        cmp.set('v.quoteLineItemParams.syuseiNebiki01',cmp.get('v.syuseiNebiki01'));
        cmp.set('v.quoteLineItemParams.syuseiNebiki02',cmp.get('v.syuseiNebiki02'));
        cmp.set('v.quoteLineItemParams.ishikiCheck',cmp.get('v.ishikiCheck'));
        cmp.set('v.quoteLineItemParams.shokei',cmp.get('v.shokei'));
        cmp.set('v.quoteLineItemParams.allQuantity',allQuantity);
        cmp.set('v.quoteLineItemParams.allUnitprice',allUnitprice);
        cmp.set('v.quoteLineItemParams.allTotalprice',allTotalprice);
        cmp.set('v.quoteLineItemParams.allDiscountUnitPrice',allDiscountUnitPrice);
        cmp.set('v.quoteLineItemParams.fertilityDiscountTitle1',cmp.get('v.fertilityDiscountTitle1'));
        cmp.set('v.quoteLineItemParams.fertilityDiscountTitle2',cmp.get('v.fertilityDiscountTitle2'));
        cmp.set('v.quoteLineItemParams.saisyuKingaku',cmp.get('v.saisyuKingaku'));
        cmp.set('v.quoteLineItemParams.shokei',cmp.get('v.shokei'));
		// Params
		//var quoteLineparams = cmp.get("v.quoteLineItemParams");
        console.log(data);
        // パラメータ設定
        var params = {
            quoteId:cmp.get("v.recordId"),
            draftValues:JSON.stringify(draftValues),
            deletedData:JSON.stringify(deletedData),
            datas:JSON.stringify(data),
            quoteParams: JSON.stringify(cmp.get("v.quoteLineItemParams")),
            digits:cmp.get('v.digits'),
            qliReflectCheck:cmp.get('v.qliReflectCheck'),
            isPSGHHTUser:cmp.get('v.isPSGHHTUser')
        };

        // データ登録
        helper.reflectEditedData(cmp, params);
    },
    init: function (cmp, event, helper) {
        // デバイスの確認
        cmp.set('v.device', $A.get("$Browser.formFactor"));
        // 列名設定
        //　cmp.set('v.columns', helper.getColumnDefinitions(cmp));
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
    // TODO selectPickListValue 最適化必要
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
                        data[dataIdx].COWO_QuantityUnit__c = copyFrom.COWO_QuantityUnit__c;
                        data[dataIdx].COWO_DetailCategory__c = copyFrom.COWO_DetailCategory__c;
                        data[dataIdx].COWO_DetailCategory_MTE__c = copyFrom.COWO_DetailCategory_MTE__c;
                        data[dataIdx].COWO_RejectionReason__c = copyFrom.COWO_RejectionReason__c;
                        data[dataIdx].COWO_PlantCode__c = copyFrom.COWO_PlantCode__c;
                        data[dataIdx].COWO_PlantCode_MTE__c = copyFrom.COWO_PlantCode_MTE__c;
                        data[dataIdx].COWO_StorageLocation__c = copyFrom.COWO_StorageLocation__c;
                        data[dataIdx].COWO_StorageLocation_MTE__c = copyFrom.COWO_StorageLocation_MTE__c;
                        data[dataIdx].COWO_Currency__c = copyFrom.COWO_Currency__c;
                        data[dataIdx].COWO_Recording_Division__c = copyFrom.COWO_Recording_Division__c;
                        data[dataIdx].COWO_ProfitCenter__c = copyFrom.COWO_ProfitCenter__c;
                        data[dataIdx].COWO_ProfitCenter_MTE__c = copyFrom.COWO_ProfitCenter_MTE__c;
                        data[dataIdx].COWO_MaterialGroup1__c = copyFrom.COWO_MaterialGroup1__c;
                    }
                }
                if(draftValues.length > 0){
                    for(var dftIdx = 0;dftIdx < draftValues.length; dftIdx++){
                        if(draftValues[dftIdx].Id == selectRows[idx].Id){
                            draftValues[dftIdx].COWO_QuantityUnit__c = copyFrom.COWO_QuantityUnit__c;
                            draftValues[dftIdx].COWO_DetailCategory__c = copyFrom.COWO_DetailCategory__c;
                            draftValues[dftIdx].COWO_DetailCategory_MTE__c = copyFrom.COWO_DetailCategory_MTE__c;
                            draftValues[dftIdx].COWO_RejectionReason__c = copyFrom.COWO_RejectionReason__c;
                            draftValues[dftIdx].COWO_PlantCode__c = copyFrom.COWO_PlantCode__c;
                            draftValues[dftIdx].COWO_PlantCode_MTE__c = copyFrom.COWO_PlantCode_MTE__c;
                            draftValues[dftIdx].COWO_StorageLocation__c = copyFrom.COWO_StorageLocation__c;
                            draftValues[dftIdx].COWO_StorageLocation_MTE__c = copyFrom.COWO_StorageLocation_MTE__c;
                            draftValues[dftIdx].COWO_Currency__c = copyFrom.COWO_Currency__c;
                            draftValues[dftIdx].COWO_Recording_Division__c = copyFrom.COWO_Recording_Division__c;
                            draftValues[dftIdx].COWO_ProfitCenter__c = copyFrom.COWO_ProfitCenter__c;
                            draftValues[dftIdx].COWO_ProfitCenter_MTE__c = copyFrom.COWO_ProfitCenter_MTE__c;
                            draftValues[dftIdx].COWO_MaterialGroup1__c = copyFrom.COWO_MaterialGroup1__c;
                        }else{
                            var newDraftTmp = [
                                {
                                    Id: selectRows[idx].Id,
                                    COWO_QuantityUnit__c : copyFrom.COWO_QuantityUnit__c,
                                    COWO_DetailCategory__c : copyFrom.COWO_DetailCategory__c,
                                    COWO_DetailCategory_MTE__c : copyFrom.COWO_DetailCategory_MTE__c,
                                    COWO_RejectionReason__c : copyFrom.COWO_RejectionReason__c,
                                    COWO_PlantCode__c : copyFrom.COWO_PlantCode__c,
                                    COWO_PlantCode_MTE__c : copyFrom.COWO_PlantCode_MTE__c,
                                    COWO_StorageLocation__c : copyFrom.COWO_StorageLocation__c,
                                    COWO_StorageLocation_MTE__c : copyFrom.COWO_StorageLocation_MTE__c,
                                    COWO_Currency__c : copyFrom.COWO_Currency__c,
                                    COWO_Recording_Division__c : copyFrom.COWO_Recording_Division__c,
                                    COWO_ProfitCenter__c : copyFrom.COWO_ProfitCenter__c,
                                    COWO_ProfitCenter_MTE__c : copyFrom.COWO_ProfitCenter_MTE__c,
                                    COWO_MaterialGroup1__c : copyFrom.COWO_MaterialGroup1__c,
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
                            COWO_QuantityUnit__c : copyFrom.COWO_QuantityUnit__c,
                            COWO_DetailCategory__c : copyFrom.COWO_DetailCategory__c,
                            COWO_DetailCategory_MTE__c : copyFrom.COWO_DetailCategory_MTE__c,
                            COWO_RejectionReason__c : copyFrom.COWO_RejectionReason__c,
                            COWO_PlantCode__c : copyFrom.COWO_PlantCode__c,
                            COWO_PlantCode_MTE__c : copyFrom.COWO_PlantCode_MTE__c,
                            COWO_StorageLocation__c : copyFrom.COWO_StorageLocation__c,
                            COWO_StorageLocation_MTE__c : copyFrom.COWO_StorageLocation_MTE__c,
                            COWO_Currency__c : copyFrom.COWO_Currency__c,
                            COWO_Recording_Division__c : copyFrom.COWO_Recording_Division__c,
                            COWO_ProfitCenter__c : copyFrom.COWO_ProfitCenter__c,
                            COWO_ProfitCenter_MTE__c : copyFrom.COWO_ProfitCenter_MTE__c,
                            COWO_MaterialGroup1__c : copyFrom.COWO_MaterialGroup1__c,
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
        // 明細番号設定
        var data = cmp.find("datatable").get("v.data");
        if(cmp.find("datatable").get("v.draftValues").length > 0){
            cmp.find("datatable").get("v.draftValues").splice(0,cmp.find("datatable").get("v.draftValues").length);
        }
        if(data.length > 0){
            for(var idx = 0;idx < data.length; idx++){
                data[idx].COWO_ItemNumber__c = idx + 1;
                var newDraftTmp = [
                    {
                        Id: data[idx].Id,
                        COWO_ItemNumber__c : data[idx].COWO_ItemNumber__c,
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
    changeRecal: function (cmp, event, helper) {
        cmp.set("v.hasChanged", true);
        helper.kingakuRecal(cmp);
        var tcTemp = cmp.get('v.tcGokei');
        helper.recalPrice(cmp,tcTemp);

        helper.adjustFraction(cmp);
    },
    changeIshiki: function(cmp, event, helper){
        cmp.set("v.hasChanged", true);
        
       /* var originData = cmp.get("v.originalData");
        var originDraftValues = cmp.get("v.originalData");
        if(cmp.get("v.ishikiCheck") == true){
            var data = cmp.find("datatable").get("v.data");
            var draftValues = cmp.find("datatable").get("v.draftValues");
            
            // 古いdraftを削除する
            data.splice(0,data.length);
            cmp.find("datatable").set("v.data", data);
            draftValues.splice(0,data.length);
            cmp.find("datatable").set("v.draftValues", draftValues);
            // cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get("v.draftValues").concat(tempDraft));
            
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
                    COWO_Product_Name__c: "一式",
                    Quantity: 1,
                    UnitPrice: 0,
                    COWO_ListPrice__c: 0,
                    COWO_DiscountPrice__c: 0,
                    cowo_TotalPrice: 0,
                    COWO_TotalLocalCorporationTC__c: cmp.get("v.genpoTCGokei"),
                    COWO_TotalFrontPurchasePrice__c: cmp.get("v.furontoKakaku"),
                    COWO_TotalTC__c: cmp.get("v.tcGokei"),
                    COWO_TotalMC__c: cmp.get("v.mcGokei"),
                    Subtotal: cmp.get("v.shokei"),
                    trendIcon: 'utility:warning'
                }
            ];
            // draftValuesを設定する
            cmp.find("datatable").set("v.data", cmp.find("datatable").get("v.data").concat(newData));
            cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get("v.draftValues").concat(newData));
        }else{
            cmp.find("datatable").set("v.data", cmp.find("datatable").get("v.data").concat(originData));
            cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get("v.draftValues").concat(originDraftValues));
        }*/
        
    },
    changeFDTitle: function(cmp, event, helper){
        var fertilityDiscountTitle1 = cmp.get('v.fertilityDiscountTitle1');
        var result = 0;
        for(var i=0;i<fertilityDiscountTitle1.length;i++){
            var chr = fertilityDiscountTitle1.charCodeAt(i);
            if((chr >= 0x00 && chr < 0x81) ||
            (chr === 0xf8f0) ||
            (chr >= 0xff61 && chr < 0xffa0) ||
            (chr >= 0xf8f1 && chr < 0xf8f4)){
            //半角文字の場合は1を加算
            cmp.set("v.maxLength",16);
            break;
            }else{
            //それ以外の文字の場合は2を加算
            cmp.set("v.maxLength",9);
            break;
            }
        }
        cmp.set("v.hasChanged", true);
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