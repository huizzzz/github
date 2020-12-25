({
    fetchData: function (cmp) {
        // Display the total in a "toast" status message
        var resultsToast = $A.get("e.force:showToast");

        var params = { quoteId:cmp.get("v.recordId") };
        this.sendRequest(cmp, 'c.getCOWOQuoteLineItems', params)
        .then($A.getCallback(function(response) {

            var returnVal = JSON.parse(response);

            // 正常終了の場合
            if(returnVal.returnCode == 0){
                
                cmp.find("datatable").set('v.data',returnVal.data);
                cmp.set('v.originalData', returnVal.data);
                cmp.set('v.currencyIsoCode',returnVal.currencyIsoCode);
                // 通貨フォーマット設定
                cmp.set('v.format',returnVal.qliDisplayParams.format);
                cmp.set('v.symbol',returnVal.qliDisplayParams.symbol);
                cmp.set('v.digits',returnVal.qliDisplayParams.digits);
                cmp.set('v.digitsInput',returnVal.qliDisplayParams.digitsInput);
                cmp.set('v.finalAmount',returnVal.qliDisplayParams.finalAmount);
                cmp.set('v.amountSummary',returnVal.qliDisplayParams.amountSummary);
                cmp.set('v.remainAmount',returnVal.qliDisplayParams.remainAmount);
                cmp.set('v.warnMessage',returnVal.qliDisplayParams.warnMessage);
                cmp.set('v.fertilityDiscount1',returnVal.qliDisplayParams.fertilityDiscount1);
                cmp.set('v.fertilityDiscount2',returnVal.qliDisplayParams.fertilityDiscount2);
                if(cmp.get('v.remainAmount') < 0){
                    cmp.set('v.isRemainAmountMinus',true);
                }else{
                    cmp.set('v.isRemainAmountMinus',false);
                }
                var columns = [
                    {label: $A.get("$Label.c.COWO_LBL_ItemNumber"), fieldName: 'COWO_ItemNumber__c', type: 'text', sortable: false, editable: true, cellAttributes: { iconName: {fieldName: 'trendIcon'} }, iconPosition: 'right', initialWidth:100 },
                    {label: $A.get("$Label.c.COWO_LBL_ProductName"), fieldName: 'COWO_ProductName__c', type: 'text', sortable: false, editable: true, initialWidth:300 },
                    {label: $A.get("$Label.c.COWO_LBL_Description_Tekeiyo"), fieldName: 'COWO_Description__c', type: 'text', sortable: false, editable: false, initialWidth:200 ,wrapText:true },
                    {label: $A.get("$Label.c.COWO_LBL_InputDescriptiom"), type: 'button', initialWidth: 80, typeAttributes: { label: "摘要入力", name: 'COWOQLISupport', title: 'Click to View Details'},style:'height:1px'},
                    {label: $A.get("$Label.c.COWO_LBL_Quantity"), fieldName: 'COWO_Quantity__c', type: 'text', sortable: false, editable: true , initialWidth:100},
                    // {label: $A.get("$Label.c.COWO_LBL_UnitPrice"), fieldName: 'COWO_DiscountUnitPrice__c', type: 'currency', sortable: false, typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, editable: true, initialWidth:200},
                    {label: $A.get("$Label.c.COWO_LBL_UnitPrice"), fieldName: 'COWO_Price__c', type: 'currency', sortable: false, typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, editable: true, initialWidth:200},
                    {label: $A.get("$Label.c.COWO_LBL_Amount"), fieldName: 'COWO_SubTotal__c', type: 'currency',sortable: false, typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, editable: true, initialWidth:200},
                    //{label: $A.get("$Label.c.COWO_LBL_Sort"), fieldName: 'COWO_SortNo__c', type: 'number',sortable: true, editable: false, initialWidth:190}              
                ];
                cmp.set('v.columns', columns);

            // 警告終了の場合
            } else if (returnVal.returnCode == 6){
                resultsToast.setParams({
                    type: "warning",
                    mode: 'sticky',
                    message: returnVal.returnMsg
                });
                resultsToast.fire();

            // 異常終了の場合
            } else if (returnVal.returnCode == 9){
                resultsToast.setParams({
                    type: "error",
                    mode: 'sticky',
                    message: returnVal.returnMsg
                });
                resultsToast.fire();
            }
            
            // ローディングを解除する
            cmp.set('v.showSpinner', false);
        }))
        .catch(function(errors) {
            var resultsToast = $A.get("e.force:showToast");
            var message = errors;
            resultsToast.setParams({
                type: "error",
                mode: 'sticky',
                message: message
            });
            resultsToast.fire();

            // ローディングを解除する
            cmp.set('v.showSpinner', false);
            
            console.error('ERROR: ' + errors);
        });	
    },
    reflectEditedData: function (cmp, params) {
        // Display the total in a "toast" status message
        var resultsToast = $A.get("e.force:showToast");

        this.sendRequest(cmp, 'c.reflectEditedData', params)
        .then($A.getCallback(function(response) {
            var returnVal = JSON.parse(response);

            // 正常終了の場合
            if(returnVal.returnCode == 0){
                // 戻るデータを処理したい場合 TODO
                //console.log(returnVal.addNewOpportunityLineItemList);  // 追加/新規データ
                //console.log(returnVal.draftIdList);
                
                // var data = cmp.get("v.data");

                // // var mergedData = Object.assign(cmp.get('v.data'), cmp.find("datatable").get("v.draftValues"));
                // // console.log(mergedData);
                // // draftValuesをdataに反映する
                // cmp.find("datatable").get("v.draftValues").forEach(function(element){
                //     for(var dataIndex = 0; dataIndex < data.length; dataIndex++){
                //         if(data[dataIndex].Id == element.Id){
                //             var mergedDataRow = Object.assign(data[dataIndex], element);
                //             console.log("mergedDataRow: " + mergedDataRow);
                //             break;
                //         }
                //     }
                // });
                
                // for(var addNewIndex = 0; addNewIndex < returnVal.addNewOpportunityLineItemList.length; addNewIndex++){
                //     for(var dataIndex = 0; dataIndex < data.length; dataIndex++){
                //         if(data[dataIndex].Id.substr(0,3) == "Add"){
                //             data[dataIndex].Id = data[dataIndex].Id.substr(3);
                //             break;
                //         } else if(data[dataIndex].Id.substr(0,3) == "New"){
                //             data[dataIndex].Id = addNewOpportunityLineItemList[addNewIndex].Id;
                //             break;
                //         }
                //     }
                // }
                
                // 編集画面を最新化する
                cmp.find("datatable").set("v.draftValues", []);
                // 関連リストをリフレッシュする
                $A.get("e.force:refreshView").fire();
                // クイックアクション画面を閉じる
                $A.get("e.force:closeQuickAction").fire();

                resultsToast.setParams({
                    type: "success",
                    mode: 'dismissible',
                    message: returnVal.returnMsg
                });
                resultsToast.fire();

            // 警告終了の場合
            } else if (returnVal.returnCode == 6){
                resultsToast.setParams({
                    type: "warning",
                    mode: 'dismissible',
                    message: returnVal.returnMsg
                });
                resultsToast.fire();

            // 異常終了の場合
            } else if (returnVal.returnCode == 9){
                resultsToast.setParams({
                    type: "error",
                    mode: 'sticky',
                    message: returnVal.returnMsg
                });
                resultsToast.fire();
            }
        }))
        .catch(function(errors) {
            var message = errors;
            resultsToast.setParams({
                type: "error",
                mode: 'sticky',
                message: message
            });
            resultsToast.fire();
            
            // ローディングを解除する
            cmp.set('v.showSpinner', false);

            console.error('ERROR: ' + errors);
        }).then(function(){
            // disable page
            cmp.set('v.showSpinner', false);
            console.log('処理終了');
        });
    },
    resetLocalStorage: function () {
        localStorage.setItem('datatable-in-action', null);
    },
    /**
     * Call Apex Server-Side method in Promise
     */
    sendRequest : function(cmp, methodName, params){
      return new Promise($A.getCallback(function(resolve, reject) {
        var action = cmp.get(methodName);
        action.setParams(params);
        action.setCallback(self, function(res) {
          var state = res.getState();
          if(state === 'SUCCESS') {
            resolve(res.getReturnValue());
          } else if(state === 'ERROR') {
            reject(action.getError())
          }
        });
        $A.enqueueAction(action);
      }));
    },
    showRowDetails : function(cmp,row) {
        // eslint-disable-next-line no-alert
        // notice parent component to open the SearchProduct component
        var openCOWOQLISupportEvent = cmp.getEvent("openCOWOQLISupport");
        var description = '';
        if(row.COWO_Description__c != null){
            description = row.COWO_Description__c;
        }
        openCOWOQLISupportEvent.setParams({quoteLineItemId: row.Id
                                          ,description:description
        }).fire();
    },
    sortBy: function (field, reverse, primer) {
        var key = primer
            ? function(x) {
        return primer(x[field]);
        }
            : function(x) {
        return x[field];
        };

        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.find("datatable").get("v.data");
        var reverse = sortDirection !== 'asc';
        var draftValues = cmp.find("datatable").get("v.draftValues");
        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        cmp.find("datatable").set("v.data", data);
        if(draftValues.length > 0){
            for(var idx = 0;idx < data.length; idx++){
                for(var dftIdx = 0;dftIdx < draftValues.length; dftIdx++){
                    if(data[idx].Id == draftValues[dftIdx].Id && draftValues[dftIdx].Id.substr(0,3) == "New"){
                        var newTempdraft = [
                            {
                                Id: data[idx].Id,
                                COWO_ProductName__c: data[idx].COWO_ProductName__c,
                                COWO_Quantity__c: data[idx].COWO_Quantity__c,
                                COWO_DiscountUnitPrice__c: data[idx].COWO_DiscountUnitPrice__c,
                                COWO_SubTotal__c: data[idx].COWO_SubTotal__c,
                                COWO_SortNo__c:data[idx].COWO_SortNo__c,
                                CurrencyIsoCode:cmp.get('v.currencyIsoCode'),
                                trendIcon: 'utility:warning'
                            }];
                        draftValues.splice(dftIdx,1);
                        Array.prototype.push.apply(draftValues, newTempdraft); 
                    }
                }
            }
        }
        cmp.find("datatable").set("v.draftValues", draftValues);
    },
    storeColumnWidths: function (widths) {
        localStorage.setItem('datatable-in-action', JSON.stringify(widths));
    },
    convertNumber: function (val) {
        var regexp = new RegExp(/^[+,-]?([0-9]\d*|0)(\.\d+)?$/);
        if (!regexp.test(val)) {
            return 0;
        } 
        return parseFloat(val);
    },
    validationCheck: function (cmp) {
        var data = cmp.find("datatable").get('v.data');
        var amountSummary = 0;
        var remainAmount = 0;
        var isLengthOver = false;
    　　for(var idx=0;idx < data.length;idx++){
            // 金額サマリを再計算する
            amountSummary += this.convertNumber(data[idx].COWO_SubTotal__c);
            // 商品名長さチェックする
            if(!isLengthOver){
                if(data[idx].COWO_ProductName__c != null && data[idx].COWO_ProductName__c != ''){
                    if(data[idx].COWO_ProductName__c.length > 23){
                        cmp.set('v.warnMessage',$A.get("$Label.c.COWO_MSG_LenOver"));
                        /*var rowsError = {};
                        rowsError[data[idx].Id] = {
                            messages: $A.get("$Label.c.COWO_MSG_LenOver"),
                            fieldNames: 'COWO_ProductName__c',
                            title: $A.get("$Label.c.COWO_MSG_LenOver")
                        };
                        
                        cmp.set('v.errors', {
                            rows: rowsError
                        });*/
                        isLengthOver = true;
                    }else{
                        cmp.set('v.warnMessage','');
                    }
                }
            }
        }
        remainAmount = amountSummary - cmp.get('v.finalAmount');
        if(remainAmount > 0){
            cmp.set('v.isRemainAmountMinus',true);
        }else{
            cmp.set('v.isRemainAmountMinus',false);
        }
        cmp.set('v.remainAmount',remainAmount);
        cmp.set('v.amountSummary',amountSummary);
    },
})