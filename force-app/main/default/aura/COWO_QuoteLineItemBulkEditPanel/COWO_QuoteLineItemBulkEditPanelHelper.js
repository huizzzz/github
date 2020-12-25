({
    createCOWOQuoteLineItemBulkEditCmp: function(cmp, event) {
        $A.createComponent(
            "c:COWO_QuoteLineItemBulkEdit",
            {
                "aura:id" : "COWOQuoteLineItemBulkEditCmp",
                "recordId" : cmp.get("v.recordId"),
            },
            function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    cmp.find("COWOQuoteLineItemBulkEdit").set("v.body", newCmp);
                    if(newCmp){
                        [].concat(newCmp)[0].open();
                    }
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
      },

      createCOWOQLISupportCmp: function(cmp, event) {
        $A.createComponent(
            "c:COWO_QLISupport",
            {
                "aura:id" : "COWOQLISupportCmp",
                "quoteLineItemId" : event.getParam("quoteLineItemId"),
                "description" : event.getParam("description"),
            },
            function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    cmp.find("COWOQLISupport").set("v.body", newCmp);
                    /*if(newCmp){
                        [].concat(newCmp)[0].open();
                    }*/
                    console.log("success");
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },
})
