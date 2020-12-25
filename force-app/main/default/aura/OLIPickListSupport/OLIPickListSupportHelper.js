({
    doInit: function (cmp, params) {
        // Display the total in a "toast" status message
        //alert(cmp.get("v.opportunityLineItemId"));
        var resultsToast = $A.get("e.force:showToast");

        this.sendRequest(cmp, 'c.init', params)
        .then($A.getCallback(function(response) {

            var returnVal = JSON.parse(response);

            // 正常終了の場合
            if(returnVal.returnCode == 0){
                cmp.set("v.quantityUnitOptions", returnVal.SAWO_QuantityUnit__c);
                cmp.set("v.detailCategoryOptions", returnVal.SAWO_DetailCategory__c);
                cmp.set("v.detailCategoryMTEOptions", returnVal.SAWO_DetailCategory_MTE__c);
                cmp.set("v.rejectionReasonOptions", returnVal.SAWO_RejectionReason__c);
                cmp.set("v.plantCodeOptions", returnVal.SAWO_PlantCode__c); 
                cmp.set("v.plantCodeMTEOptions", returnVal.SAWO_PlantCode_MTE__c); 
                cmp.set("v.storageLocationOptions", returnVal.SAWO_StorageLocation__c); 
                cmp.set("v.storageLocationMTEOptions", returnVal.SAWO_StorageLocation_MTE__c); 
                cmp.set("v.currencyOptions", returnVal.SAWO_Currency__c); 
                cmp.set("v.recordingDivisionOptions", returnVal.SAWO_Recording_Division__c); 
                cmp.set("v.profitCenterOptions", returnVal.SAWO_ProfitCenter__c); 
                cmp.set("v.profitCenterMTEOptions", returnVal.SAWO_ProfitCenter_MTE__c); 
                cmp.set("v.materialGroup1Options", returnVal.SAWO_MaterialGroup1__c); 
                cmp.set("v.salesUnitOptions", returnVal.SAWO_SalesUnit__c); 
                // 通貨フォーマット設定
                // cmp.set('v.format',returnVal.format);
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
            // ローディングを解除する
            cmp.set('v.showSpinner', false);
            
            resultsToast.fire();

            console.error('ERROR: ' + errors);
        });
    },
    changePlantste: function (cmp, params) {
      // ローディングを設定する
      cmp.set('v.showSpinner', true);
      
     // Display the total in a "toast" status message
        //alert(cmp.get("v.opportunityLineItemId"));
        var resultsToast = $A.get("e.force:showToast");

        this.sendRequest(cmp, 'c.getStorageSTEByPlantste', params)
        .then($A.getCallback(function(response) {
            var returnVal = JSON.parse(response);

            // 正常終了の場合
            if(returnVal.returnCode == 0){
                cmp.set("v.storageLocationOptions", returnVal.SAWO_StorageLocation__c); 
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
            // ローディングを解除する
            cmp.set('v.showSpinner', false);
            resultsToast.fire();
            console.error('ERROR: ' + errors);
        });
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
      doOnClose : function(cmp, event) {
        // notice parent component to go back to the OpportunityLineItemBulkEdit component
        var gobackEvent = cmp.getEvent("closeOLIPickListSupport");
        gobackEvent.fire();
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
    doCalculate: function(cmp) {
        var conditionRateInsurance = this.convertNumber(cmp.get('v.conditionRateInsurance'));
        var insuranceFee = this.convertNumber(cmp.get('v.insuranceFee'));
        var conditionRateTaxes = this.convertNumber(cmp.get('v.conditionRateTaxes'));
        var freight = this.convertNumber(cmp.get('v.freight'));
        var conditionDeliveryCost = this.convertNumber(cmp.get('v.conditionDeliveryCost'));
        var reserversFixed = this.convertNumber(cmp.get('v.reserversFixed'));
        var trgInstRsrvsFixed = this.convertNumber(cmp.get('v.trgInstRsrvsFixed'));
        var conditionRateTotal = this.convertNumber(cmp.get('v.conditionRateTotal'));
        var cnAMTTOTAL = this.convertNumber(cmp.get('v.cnAMTTOTAL'));
        conditionRateTotal = conditionRateInsurance + conditionRateTaxes + conditionDeliveryCost;
        cnAMTTOTAL = insuranceFee + freight + reserversFixed + trgInstRsrvsFixed;
        cmp.set('v.conditionRateTotal',conditionRateTotal);
        cmp.set('v.cnAMTTOTAL',cnAMTTOTAL);
    },
})