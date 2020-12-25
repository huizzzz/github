({
    doOnClose : function(cmp, event) {
        // notice parent component to go back to the OpportunityLineItemBulkEdit component
        var gobackEvent = cmp.getEvent("closeSearchProduct");
        gobackEvent.fire();
    },
    doInit: function (cmp, params) {
        // Display the total in a "toast" status message
        var resultsToast = $A.get("e.force:showToast");

        this.sendRequest(cmp, 'c.init', params)
        .then($A.getCallback(function(response) {

            var returnVal = JSON.parse(response);

            // 正常終了の場合
            if(returnVal.returnCode == 0){
                cmp.set("v.KatashikiOptions", returnVal.Katashiki__c);
                // 通貨設定
                cmp.set('v.currencyIsoCode', returnVal.currencyIsoCode);
				cmp.set("v.firstHierarchyOptions", returnVal.firstHierarchyOptions);
                cmp.set("v.secondHierarchyOptions", returnVal.secondHierarchyOptions);
                cmp.set("v.thirdHierarchyOptions", returnVal.thirdHierarchyOptions);
                cmp.set("v.secondHierarchyMap",returnVal.secondHierarchyMap);
                cmp.set("v.thirdHierarchyMap",returnVal.thirdHierarchyMap);
                // 通貨フォーマット設定
                if(cmp.get('v.currencyIsoCode') == 'JPY'){
                    cmp.set('v.digits',0);
                }

                var columns = [];
                if(cmp.get('v.isPSGHHTUser')){
                    columns = [
                        {label: "P_Id", fieldName: 'product2_Id', type: 'text', initialWidth:250, sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_ItemName"), fieldName: 'product2_ItemName', type: 'text', initialWidth:250, sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_ProdDescription"), fieldName: 'product2_Description', type: 'text', initialWidth:350, sortable: false ,wrapText:true},
                        {label: $A.get("$Label.c.COWO_LBL_Katashiki"), fieldName: 'product2_Katashiki', type: 'text', initialWidth:85,sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_PartsNo"), fieldName: 'product2_PartsNo', type: 'text',initialWidth:85, type: 'text', sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_TC"), fieldName: 'product2_TC', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'product2_CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, initialWidth:100, sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_MC"), fieldName: 'product2_MC', type: 'currency',  typeAttributes: { currencyCode: { fieldName: 'product2_CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, initialWidth:100, sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_B"), fieldName: 'product2_b', type: 'number',initialWidth:20, sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_PartitionPrice"), fieldName: 'product2_PartitionPrice', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'product2_CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, initialWidth:100, sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_Q"), fieldName: 'product2_Q', type: 'currency',  typeAttributes: { currencyCode: { fieldName: 'product2_CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, initialWidth:100, sortable: false},
                       // {label: $A.get("$Label.c.COWO_LBL_OrderNumber"), fieldName: 'product2_OrderNumber', type: 'number',  initialWidth:100, sortable: false},
                       // {label: $A.get("$Label.c.COWO_LBL_SalesUnit"), fieldName: 'product2_SalesUnit', type: 'text', initialWidth:100, sortable: false},
                       // {label: $A.get("$Label.c.COWO_LBL_PartitionPrice"), fieldName: 'product2_PartitionPrice', type: 'text', initialWidth:100, sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_ProductCode"), fieldName: 'product2_ProductCode', type: 'text',initialWidth:85, type: 'text', sortable: false},
                        //{label: $A.get("$Label.c.CountryMode"), fieldName: 'product2_CountryMode', type: 'text', initialWidth:350, sortable: true},
                        // {label: '仕入先', fieldName: 'SupplierName__c', type: 'text', sortable: true},
                        //{label: $A.get("$Label.c.StructureSortNo"), fieldName: 'product2_StructureSortNo', initialWidth:350, type: 'text', sortable: true},
                        {label: "現地調達品", fieldName: 'product2_LocalParts', initialWidth:350, type: 'text', sortable: true},
                    ];
                }else{
                    columns = [
                        //{label: "P_Id", fieldName: 'product2_Id', type: 'text', initialWidth:250, sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_ItemName"), fieldName: 'product2_ItemName', type: 'text', initialWidth:250, sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_ProdDescription"), fieldName: 'product2_Description', type: 'text', initialWidth:350, sortable: false,wrapText:true},
                        {label: $A.get("$Label.c.COWO_LBL_Katashiki"), fieldName: 'product2_Katashiki', type: 'text', initialWidth:85,sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_PartsNo"), fieldName: 'product2_PartsNo', type: 'text',initialWidth:85, type: 'text', sortable: false},
                        //{label: $A.get("$Label.c.COWO_LBL_TC"), fieldName: 'display_TC', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'product2_CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, initialWidth:100, sortable: false},
                        //{label: $A.get("$Label.c.COWO_LBL_MC"), fieldName: 'display_MC', type: 'currency',  typeAttributes: { currencyCode: { fieldName: 'product2_CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, initialWidth:100, sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_B"), fieldName: 'product2_b', type: 'number',initialWidth:20, sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_PartitionPrice"), fieldName: 'product2_PartitionPrice', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'product2_CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, initialWidth:100, sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_Q"), fieldName: 'product2_Q', type: 'currency',  typeAttributes: { currencyCode: { fieldName: 'product2_CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, initialWidth:100, sortable: false},
                       // {label: $A.get("$Label.c.COWO_LBL_OrderNumber"), fieldName: 'product2_OrderNumber', type: 'number',  initialWidth:100, sortable: false},
                       // {label: $A.get("$Label.c.COWO_LBL_SalesUnit"), fieldName: 'product2_SalesUnit', type: 'text', initialWidth:100, sortable: false},
                       // {label: $A.get("$Label.c.COWO_LBL_PartitionPrice"), fieldName: 'product2_PartitionPrice', type: 'text', initialWidth:100, sortable: false},
                        {label: $A.get("$Label.c.COWO_LBL_ProductCode"), fieldName: 'product2_ProductCode', type: 'text',initialWidth:85, type: 'text', sortable: false},
                        //{label: $A.get("$Label.c.CountryMode"), fieldName: 'product2_CountryMode', type: 'text', initialWidth:350, sortable: true},
                        // {label: '仕入先', fieldName: 'SupplierName__c', type: 'text', sortable: true},
                        //{label: $A.get("$Label.c.StructureSortNo"), fieldName: 'product2_StructureSortNo', initialWidth:350, type: 'text', sortable: true},
                        {label: "現地調達品", fieldName: 'product2_LocalParts', initialWidth:350, type: 'text', sortable: true},
                    ];
                }
                
                cmp.set('v.columns', columns);
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
    fetchData: function (cmp, params) {
        // Display the total in a "toast" status message
        var resultsToast = $A.get("e.force:showToast");

        this.sendRequest(cmp, 'c.searchProduct', params)
        .then($A.getCallback(function(response) {
            var returnVal = JSON.parse(response);

            // 正常終了の場合
            if(returnVal.returnCode == 0){
                cmp.set('v.data', returnVal.data);
                if(returnVal.count == 0 || returnVal.count > 200){
                    resultsToast.setParams({
                        type: "warning",
                        mode: 'dismissible',
                        message: returnVal.returnMsg
                    });
                    resultsToast.fire();
                }

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
            var resultsToast = $A.get("e.force:showToast");
            var message = errors;
            resultsToast.setParams({
                type: "error",
                mode: 'sticky',
                message: message
            });
            resultsToast.fire();

            console.error('ERROR: ' + errors);
        });
    },
    getColumnDefinitions: function () {
        var columnsWidths = this.getColumnWidths();
        var columns = [
            {label: $A.get("$Label.c.CountryMode"), fieldName: 'product2_CountryMode', type: 'text',  initialWidth:350,sortable: true},
            {label: $A.get("$Label.c.Katashiki"), fieldName: 'product2_Katashiki', type: 'text', initialWidth:350, sortable: true},
            {label: $A.get("$Label.c.StructureSortNo"), fieldName: 'product2_StructureSortNo',  initialWidth:350,type: 'text', sortable: true},
            {label: $A.get("$Label.c.ItemName"), fieldName: 'product2_ItemName', type: 'text',  initialWidth:350,sortable: true}//,
            // {label: '品名コード', fieldName: 'ProductCode', type: 'text', sortable: true},
            // {label: '仕入先', fieldName: 'SupplierName__c', type: 'text', sortable: true},
            // {label: 'パーツ No. 見積 No.', fieldName: 'PartsNo__c', type: 'text', sortable: true},
            // {label: '摘要', fieldName: 'Description', type: 'text', sortable: true},
            // {label: 'b', fieldName: 'b__c', type: 'number', sortable: true},
            // {label: 'リスト価格', fieldName: 'PartitionPrice__c', type: 'currency', sortable: true},
            // {label: 'X', fieldName: 'Q__c', type: 'currency', sortable: true},
            // {label: 'Q', fieldName: 'Q__c', type: 'currency', sortable: true},
            // {label: 'TC', fieldName: 'TC__c', type: 'currency', sortable: true},
            // {label: 'MC', fieldName: 'MC__c', type: 'currency', sortable: true}
        ];

        if (columnsWidths.length === columns.length) {
            return columns.map(function (col, index) {
                return Object.assign(col, { initialWidth: columnsWidths[index] });
            });
        }
        return columns;
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';

        data = Object.assign([],
            data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        cmp.set("v.data", data);
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
    storeColumnWidths: function (widths) {
        localStorage.setItem('datatable-in-action', JSON.stringify(widths));
    },
    resetLocalStorage: function () {
        localStorage.setItem('datatable-in-action', null);
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
})