({
    fetchData: function (cmp) {
        // Display the total in a "toast" status message
        var resultsToast = $A.get("e.force:showToast");

        var params = { oppId:cmp.get("v.recordId") };
        this.sendRequest(cmp, 'c.getOppLineItems', params)
        .then($A.getCallback(function(response) {

            var returnVal = JSON.parse(response);

            // 正常終了の場合
            if(returnVal.returnCode == 0){
                cmp.set('v.data', returnVal.data);
                cmp.set('v.originalData', returnVal.originalData);
                cmp.set('v.canEditProduct2', true);
                cmp.set('v.pricebook2Id',returnVal.pricebook2Id);
                cmp.set('v.currencyIsoCode',returnVal.currencyIsoCode);
                cmp.set('v.isPSGHHTUser',returnVal.isPSGHHTUser);
                // 通貨フォーマット設定
                cmp.set('v.format',returnVal.displayParams.format);
                cmp.set('v.symbol',returnVal.displayParams.symbol);
                cmp.set('v.digits',returnVal.displayParams.digits);
                cmp.set('v.digitsInput',returnVal.displayParams.digitsInput);

                var columns = [];
                if(cmp.get('v.isPSGHHTUser')){
                    columns = [
                        {label: $A.get("$Label.c.COWO_LBL_SetPicklist"), type: 'button', initialWidth: 80, typeAttributes: { label: $A.get("$Label.c.COWO_LBL_SetPicklist"), name: 'picklistSupport', title: 'Click to View Details'},style:'height:3px'},
                        {label: $A.get("$Label.c.COWO_LBL_ItemNumberInEdit"), fieldName: 'SAWO_ItemNumber__c', type: 'number',typeAttributes: { required: true },sortable: false, editable: true, initialWidth:100, cellAttributes: { iconName: {fieldName: 'trendIcon'} }, iconPosition: 'right' },
                        {label: $A.get("$Label.c.COWO_LBL_ItemName"), fieldName: 'SAWO_ProductName__c', type: 'text', sortable: false, editable: true, initialWidth:300 },
                        {label: $A.get("$Label.c.COWO_LBL_ProductCode"), fieldName: 'SAWO_ProductCode__c', type: 'text', sortable: false, editable: true, initialWidth:150 },
                        {label: $A.get("$Label.c.COWO_LBL_Parts_No"), fieldName: 'SAWO_Parts_No__c', type: 'text', sortable: false, editable: true, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_Quantity"), fieldName: 'Quantity', type: 'number', sortable: false, editable: true, initialWidth:60},
                        {label: $A.get("$Label.c.COWO_LBL_UnitPrice"), fieldName: 'SAWO_SalesPrice__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_DiscountPrice_OLI"), fieldName: 'SAWO_DiscountPrice__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_Price_OLI"), fieldName: 'SAWO_S4LinkagePrice__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_QuantityUnit"), fieldName: 'SAWO_QuantityUnit__c', type: 'text', sortable: false, editable: false, initialWidth:100 },                    
                        {label: $A.get("$Label.c.COWO_LBL_SalesUnit"), fieldName: 'SAWO_SalesUnit__c', type: 'text', sortable: false, editable: false, initialWidth:100 },                    
                        {label: $A.get("$Label.c.COWO_LBL_PartitionPrice"), fieldName: 'SAWO_PartitionPrice__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_TC"), fieldName: 'TC__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:150},
                        {label: $A.get("$Label.c.COWO_LBL_MC"), fieldName: 'MC__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:150},
                        {label: $A.get("$Label.c.COWO_LBL_LocalCorporationTC"), fieldName: 'SAWO_LocalCorporationTC__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:150},
                        {label: $A.get("$Label.c.COWO_LBL_FrontPurchasePrice"), fieldName: 'SAWO_FrontPurchasePrice__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:150},   
                        {label: $A.get("$Label.c.COWO_LBL_DetailCategory_STE"), fieldName: 'SAWO_DetailCategory__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_DetailCategory"), fieldName: 'SAWO_DetailCategory_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_RejectionReason"), fieldName: 'SAWO_RejectionReason__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_PlantCode"), fieldName: 'SAWO_PlantCode__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_PlantCode_MTE"), fieldName: 'SAWO_PlantCode_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_StorageLocation"), fieldName: 'SAWO_StorageLocation__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_StorageLocation_MTE")	, fieldName: 'SAWO_StorageLocation_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        // {label: $A.get("$Label.c.COWO_LBL_Currency"), fieldName: 'SAWO_Currency__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_RecordingDivision"), fieldName: 'SAWO_Recording_Division__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_WBSElement"), fieldName: 'SAWO_WBSElement__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ProfitCenter"), fieldName: 'SAWO_ProfitCenter__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ProfitCenter_MTE"), fieldName: 'SAWO_ProfitCenter_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ItemText"), fieldName: 'SAWO_ItemText__c', type: 'text', sortable: false, editable: true, initialWidth:100,wrapText:true },
                        {label: $A.get("$Label.c.COWO_LBL_DeliverySchedule"), fieldName: 'SAWO_DeliverySchedule__c', type: 'date-local', typeAttributes:{month: "2-digit",day: "2-digit"}, sortable: false, editable: true, initialWidth:150},
                        {label: $A.get("$Label.c.COWO_LBL_SummaryMaterialAvailDate"), fieldName: 'SAWO_MaterialAvailDate__c', type: 'date-local', typeAttributes:{month: "2-digit",day: "2-digit"}, sortable: false, editable: true, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_MaterialGroup1"), fieldName: 'SAWO_MaterialGroup1__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ShippingInstructions"), fieldName: 'SAWO_ShippingInstructions__c', type: 'text', sortable: false, editable: false, initialWidth:100,wrapText:true },
                        {label: $A.get("$Label.c.COWO_LBL_SalesNoteCustome"), fieldName: 'SAWO_SalesNoteCustome__c', type: 'text', sortable: false, editable: false, initialWidth:100 ,wrapText:true},
                        {label: "SAP Update Flag (STE)", fieldName: 'CO_ovcUpdateFlag__c', type: 'text', sortable: false, editable: false, initialWidth:100 ,wrapText:true},
                        {label: "SAP Update Flag (MTE)", fieldName: 'CO_ovcUpdateFlag_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 ,wrapText:true},
                    ];
                }else{
                    columns = [
                        {label: $A.get("$Label.c.COWO_LBL_SetPicklist"), type: 'button', initialWidth: 80, typeAttributes: { label: $A.get("$Label.c.COWO_LBL_SetPicklist"), name: 'picklistSupport', title: 'Click to View Details'},style:'height:3px'},
                        {label: $A.get("$Label.c.COWO_LBL_ItemNumberInEdit"), fieldName: 'SAWO_ItemNumber__c', type: 'number',typeAttributes: { required: true },sortable: false, editable: true, initialWidth:100, cellAttributes: { iconName: {fieldName: 'trendIcon'} }, iconPosition: 'right' },
                        {label: $A.get("$Label.c.COWO_LBL_ItemName"), fieldName: 'SAWO_ProductName__c', type: 'text', sortable: false, editable: true, initialWidth:300 },
                        {label: $A.get("$Label.c.COWO_LBL_ProductCode"), fieldName: 'SAWO_ProductCode__c', type: 'text', sortable: false, editable: true, initialWidth:150 },
                        {label: $A.get("$Label.c.COWO_LBL_Parts_No"), fieldName: 'SAWO_Parts_No__c', type: 'text', sortable: false, editable: true, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_Quantity"), fieldName: 'Quantity', type: 'number', sortable: false, editable: true, initialWidth:60},
                        {label: $A.get("$Label.c.COWO_LBL_UnitPrice"), fieldName: 'SAWO_SalesPrice__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_DiscountPrice_OLI"), fieldName: 'SAWO_DiscountPrice__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_Price_OLI"), fieldName: 'SAWO_S4LinkagePrice__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_QuantityUnit"), fieldName: 'SAWO_QuantityUnit__c', type: 'text', sortable: false, editable: false, initialWidth:100 },                    
                        {label: $A.get("$Label.c.COWO_LBL_SalesUnit"), fieldName: 'SAWO_SalesUnit__c', type: 'text', sortable: false, editable: false, initialWidth:100 },                    
                        {label: $A.get("$Label.c.COWO_LBL_PartitionPrice"), fieldName: 'SAWO_PartitionPrice__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_LocalCorporationTC"), fieldName: 'SAWO_LocalCorporationTC__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:150},
                        {label: $A.get("$Label.c.COWO_LBL_FrontPurchasePrice"), fieldName: 'SAWO_FrontPurchasePrice__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:150},   
                        {label: $A.get("$Label.c.COWO_LBL_DetailCategory_STE"), fieldName: 'SAWO_DetailCategory__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_DetailCategory"), fieldName: 'SAWO_DetailCategory_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_RejectionReason"), fieldName: 'SAWO_RejectionReason__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_PlantCode"), fieldName: 'SAWO_PlantCode__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_PlantCode_MTE"), fieldName: 'SAWO_PlantCode_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_StorageLocation"), fieldName: 'SAWO_StorageLocation__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_StorageLocation_MTE")	, fieldName: 'SAWO_StorageLocation_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        // {label: $A.get("$Label.c.COWO_LBL_Currency"), fieldName: 'SAWO_Currency__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_RecordingDivision"), fieldName: 'SAWO_Recording_Division__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_WBSElement"), fieldName: 'SAWO_WBSElement__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ProfitCenter"), fieldName: 'SAWO_ProfitCenter__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ProfitCenter_MTE"), fieldName: 'SAWO_ProfitCenter_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ItemText"), fieldName: 'SAWO_ItemText__c', type: 'text', sortable: false, editable: true, initialWidth:100,wrapText:true },
                        {label: $A.get("$Label.c.COWO_LBL_DeliverySchedule"), fieldName: 'SAWO_DeliverySchedule__c', type: 'date-local', typeAttributes:{month: "2-digit",day: "2-digit"}, sortable: false, editable: true, initialWidth:150},
                        {label: $A.get("$Label.c.COWO_LBL_SummaryMaterialAvailDate"), fieldName: 'SAWO_MaterialAvailDate__c', type: 'date-local', typeAttributes:{month: "2-digit",day: "2-digit"}, sortable: false, editable: true, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_MaterialGroup1"), fieldName: 'SAWO_MaterialGroup1__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ShippingInstructions"), fieldName: 'SAWO_ShippingInstructions__c', type: 'text', sortable: false, editable: false, initialWidth:100,wrapText:true },
                        {label: $A.get("$Label.c.COWO_LBL_SalesNoteCustome"), fieldName: 'SAWO_SalesNoteCustome__c', type: 'text', sortable: false, editable: false, initialWidth:100 ,wrapText:true},
                        {label: "SAP Update Flag (STE)", fieldName: 'CO_ovcUpdateFlag__c', type: 'text', sortable: false, editable: false, initialWidth:100 ,wrapText:true},
                        {label: "SAP Update Flag (MTE)", fieldName: 'CO_ovcUpdateFlag_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 ,wrapText:true},
                    ];
                }
                
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
    getColumnDefinitions: function () {
        var columnsWidths = this.getColumnWidths();
        var columns = [
            {label: $A.get("$Label.c.COWO_LBL_ItemName"), fieldName: 'SAWO_ProductName__c', type: 'text', sortable: true, editable: true, initialWidth:300, cellAttributes: { iconName: {fieldName: 'trendIcon'} }, iconPosition: 'right' },
            {label: $A.get("$Label.c.COWO_LBL_Quantity"), fieldName: 'Quantity', type: 'number', sortable: true, editable: true, initialWidth:150},
            {label: $A.get("$Label.c.COWO_LBL_UnitPrice"), fieldName: 'UnitPrice', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")},sortable: true, editable: true, initialWidth:150},
            //{label: $A.get("$Label.c.COWO_LBL_ServiceDate"), fieldName: 'ServiceDate', type: 'date-local', sortable: true, editable: true, initialWidth:150},
            //{label: $A.get("$Label.c.COWO_LBL_Description"), fieldName: 'Description', type: 'text', sortable: true, editable: true, initialWidth:200},
            {label: $A.get("$Label.c.COWO_LBL_LocalCorporationTC"), fieldName: 'SAWO_LocalCorporationTC__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: true, editable: true, initialWidth:150},
            {label: $A.get("$Label.c.COWO_LBL_FrontPurchasePrice"), fieldName: 'SAWO_FrontPurchasePrice__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: true, editable: true, initialWidth:150},
            {label: "TC", fieldName: 'TC__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: true, editable: true, initialWidth:150},
            {label: "MC", fieldName: 'MC__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: true, editable: true, initialWidth:150}

        ];

        if (columnsWidths.length === columns.length) {
            return columns.map(function (col, index) {
                return Object.assign(col, { initialWidth: columnsWidths[index] });
            });
        }
        return columns;
    },
    getColumnWidths: function () {
        var widths = localStorage.getItem('datatable-in-action');

        try {
            widths = JSON.parse(widths);
        } catch(e) {
            return [];
        }
        return Array.isArray(widths) ? widths : [];
    },
    reflectEditedData: function (cmp, params) {
        
        // Display the total in a "toast" status message
        var resultsToast = $A.get("e.force:showToast");

        this.sendRequest(cmp, 'c.reflectEditedData', params)
        .then($A.getCallback(function(response) {
            var returnVal = JSON.parse(response);

            // 正常終了の場合
            if(returnVal.returnCode == 0){
                
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
        var openOLIPickListSupportEvent = cmp.getEvent("openOLIPickListSupport");
        openOLIPickListSupportEvent.setParams({oppLineItemId: row.Id
                                             ,currencyISOCode:row.CurrencyIsoCode
                                             ,selectQuantityUnit:row.SAWO_QuantityUnit__c
                                             ,selectDetailCategory:row.SAWO_DetailCategory__c
                                             ,selectDetailCategoryMTE:row.SAWO_DetailCategory_MTE__c
                                             ,selectRejectionReason:row.SAWO_RejectionReason__c
                                             ,selectPlantCode:row.SAWO_PlantCode__c
                                             ,selectPlantCodeMTE:row.SAWO_PlantCode_MTE__c
                                             ,selectStorageLocation:row.SAWO_StorageLocation__c
                                             ,selectStorageLocationMTE:row.SAWO_StorageLocation_MTE__c
                                             ,selectRecordingDivision:row.SAWO_Recording_Division__c
                                             ,selectProfitCenter:row.SAWO_ProfitCenter__c
                                             ,selectMaterialGroup1:row.SAWO_MaterialGroup1__c
                                             ,selectSalesUnit:row.SAWO_SalesUnit__c
                                             ,shippingInstructions:row.SAWO_ShippingInstructions__c
                                             ,salesNoteCustome:row.SAWO_SalesNoteCustome__c
                                             ,conditionRateInsurance:row.SAWO_ConditionRate_Insurance__c
                                             ,insuranceFee:row.SA_Insurance_fee__c
                                             ,conditionRateTaxes:row.SAWO_ConditionRate_Taxes__c
                                             ,freight:row.SA_Freight__c
                                             ,conditionDeliveryCost:row.SAWO_ConditionRate_DeliveryCost__c
                                             ,otherDuties:row.SA_Other_Duties__c / 100
                                             ,reserversFixed:row.SA_Reservers_Fixed__c
                                             ,trgInstRsrvsFixed:row.SA_TrgInstRsrvsFixed__c
                                             ,format:cmp.get('v.format'),

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
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        cmp.set("v.data", data);
    },
    storeColumnWidths: function (widths) {
        localStorage.setItem('datatable-in-action', JSON.stringify(widths));
    },
    /**
     * Null転換
     */
    convertNumber: function (val) {
        var regexp = new RegExp(/^[+,-]?([0-9]\d*|0)(\.\d+)?$/);
        if (!regexp.test(val)) {
            return 0;
        } 
        return parseFloat(val);
    },
})