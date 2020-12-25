({
    doInit: function(cmp){

    },
    doOnClose : function(cmp, event) {
        // notice parent component to go back to the OpportunityLineItemBulkEdit component
        var gobackEvent = cmp.getEvent("closeCOWOQLISupport");
        gobackEvent.fire();
    },
   
})