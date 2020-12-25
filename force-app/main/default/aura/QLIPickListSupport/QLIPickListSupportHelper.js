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
                cmp.set("v.quantityUnitOptions", returnVal.COWO_QuantityUnit__c);
                cmp.set("v.detailCategoryOptions", returnVal.COWO_DetailCategory__c);
                cmp.set("v.detailCategoryMTEOptions", returnVal.COWO_DetailCategory_MTE__c);
                cmp.set("v.rejectionReasonOptions", returnVal.COWO_RejectionReason__c);
                cmp.set("v.plantCodeOptions", returnVal.COWO_PlantCode__c); 
                cmp.set("v.plantCodeMTEOptions", returnVal.COWO_PlantCode_MTE__c); 
                cmp.set("v.storageLocationOptions", returnVal.COWO_StorageLocation__c); 
                cmp.set("v.storageLocationMTEOptions", returnVal.COWO_StorageLocation_MTE__c); 
                cmp.set("v.currencyOptions", returnVal.COWO_Currency__c); 
                cmp.set("v.recordingDivisionOptions", returnVal.COWO_Recording_Division__c); 
                cmp.set("v.profitCenterOptions", returnVal.COWO_ProfitCenter__c); 
                cmp.set("v.profitCenterMTEOptions", returnVal.COWO_ProfitCenter_MTE__c); 
                cmp.set("v.materialGroup1Options", returnVal.COWO_MaterialGroup1__c);
                cmp.set("v.salesUnitOptions", returnVal.COWO_SalesUnit__c);
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
                cmp.set("v.storageLocationOptions", returnVal.COWO_StorageLocation__c); 
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
        var gobackEvent = cmp.getEvent("closeQLIPickListSupport");
        gobackEvent.fire();
    },
})