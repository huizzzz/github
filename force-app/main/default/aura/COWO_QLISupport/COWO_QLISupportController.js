({
    doInit: function(cmp,event,helper){
    },
    doReflectEditedValues: function(cmp,event,helper){
        // notice parent component to go back to the OpportunityLineItemBulkEdit component and reflect selected Products
        var reflectEditedValuesEvent = cmp.getEvent("reflectEditedValues");
        reflectEditedValuesEvent.setParams({
            description : cmp.find("COWO_Description__c").get("v.value"),
            quoteLineItemId : cmp.get('v.quoteLineItemId'),
        }).fire();
    },
    onOpenCalled: function(cmp, event, helper) {

    },
    onCloseClicked: function(cmp,event,helper){
        helper.doOnClose(cmp, event);
    },
})