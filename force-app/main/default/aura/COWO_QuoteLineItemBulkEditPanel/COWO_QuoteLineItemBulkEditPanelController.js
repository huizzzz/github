({
    formPress: function(cmp, event, helper) {
        if (event.keyCode === 27) {
            // alert("panelClose");
        }
    },
    doInit: function(cmp, event, helper) {
        if(!cmp.get("v.isLoadedCOWOQuoteLineItemBulkEdit")){
            cmp.set("v.isLoadedCOWOQuoteLineItemBulkEdit", true);
            // create the OpportunityLineItemBulkEdit component
            helper.createCOWOQuoteLineItemBulkEditCmp(cmp, event);
        } else {
            // open the OpportunityLineItemBulkEdit component
            if(cmp.find("COWOQuoteLineItemBulkEditCmp")){
                [].concat(cmp.find("COWOQuoteLineItemBulkEditCmp"))[0].open();
            }
            $A.util.removeClass(cmp.find('COWOQuoteLineItemBulkEditCmp'), 'slds-hide');
        }
    },
    openCOWOQLISupport: function(cmp, event, helper) {
        // hide the OpportunityLineItemBulkEdit component
        // $A.util.addClass(cmp.find('COWOQuoteLineItemBulkEdit'), 'slds-hide');
        if(!cmp.get("v.isLoadedCOWOQLISupport")){
            cmp.set("v.isLoadedCOWOQLISupport", true);
            // create the SearchProduct component
            helper.createCOWOQLISupportCmp(cmp, event);
        } else{
            // open the SearchProduct component
            if(cmp.find("COWOQLISupportCmp")){
                cmp.find("COWOQLISupportCmp").set('v.quoteLineItemId',event.getParam("quoteLineItemId"));
                cmp.find("COWOQLISupportCmp").set('v.description',event.getParam("description"));
                [].concat(cmp.find("COWOQLISupportCmp"))[0].open();
                // cmp.find("COWOQLISupportCmp").open();
            }
            $A.util.removeClass(cmp.find('COWOQLISupport'), 'slds-hide');
        }
    },
    closeCOWOQLISupport: function(cmp, event, helper) {
        // hide the SearchProduct component
        $A.util.addClass(cmp.find('COWOQLISupport'), 'slds-hide');
        // go back to the QuoteLineItemBulkEdit component
        $A.util.removeClass(cmp.find('COWOQuoteLineItemBulkEdit'), 'slds-hide');
    },
    reflectEditedValues: function(cmp, event, helper) {
        // hide the SelectPickListValues component
        $A.util.addClass(cmp.find('COWOQLISupport'), 'slds-hide');
        // go back to the OpportunityLineItemBulkEdit component
        $A.util.removeClass(cmp.find('COWOQuoteLineItemBulkEdit'), 'slds-hide');
        
        // currentDatas取得
        var currentDatas = cmp.find('COWOQuoteLineItemBulkEditCmp').find("datatable").get("v.data");
        // draftValue取得
        var draftValues = cmp.find('COWOQuoteLineItemBulkEditCmp').find("datatable").get("v.draftValues");
        for(var idx = 0;idx < currentDatas.length;idx ++){
            if(currentDatas[idx].Id == event.getParam("quoteLineItemId")){
                currentDatas[idx].COWO_Description__c = event.getParam("description");
            }
        }
        cmp.find('COWOQuoteLineItemBulkEditCmp').find("datatable").set("v.data", currentDatas);

        var dftExist = false;
        draftValues.forEach(function(draftValue){
            if(draftValue.Id == event.getParam("quoteLineItemId")){
                dftExist = true;
            }
            if(dftExist){
                draftValue.COWO_Description__c = event.getParam("description");
                dftExist = false;
                //break;
                cmp.find('COWOQuoteLineItemBulkEditCmp').find("datatable").set("v.draftValues", draftValues);
            }
        });
      
        if(!dftExist){
            var draftValues = [];
            draftValues.push({
                Id : event.getParam("quoteLineItemId"),
                COWO_Description__c : event.getParam("description"),
            });
            // draftValuesを設定する
            cmp.find('COWOQuoteLineItemBulkEditCmp').find("datatable").set("v.draftValues", cmp.find('COWOQuoteLineItemBulkEditCmp').find("datatable").get("v.draftValues").concat(draftValues));
        }        
        
        // // enable button
        if(cmp.find('COWOQuoteLineItemBulkEditCmp').find("datatable").get("v.draftValues").length > 0 || cmp.find('COWOQuoteLineItemBulkEditCmp').get('v.deletedData').length > 0){
            cmp.find('COWOQuoteLineItemBulkEditCmp').set('v.hasChanged', true);
        } else {
            cmp.find('OpportunityLineItemBulkEditCmp').set('v.hasChanged', false);
        }
    },
})
