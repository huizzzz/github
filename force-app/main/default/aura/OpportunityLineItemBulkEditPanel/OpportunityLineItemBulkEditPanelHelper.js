({
    createOpportunityLineItemBulkEditCmp: function(cmp, event) {
      $A.createComponent(
          "c:OpportunityLineItemBulkEdit",
          {
              "aura:id" : "OpportunityLineItemBulkEditCmp",
              "recordId" : cmp.get("v.recordId"),
          },
          function(newCmp, status, errorMessage){
              if (status === "SUCCESS") {
                  cmp.find("OpportunityLineItemBulkEdit").set("v.body", newCmp);
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
    createSearchProductCmp: function(cmp, event) {
      $A.createComponent(
          "c:SearchProduct",
          {
              "aura:id" : "SearchProductCmp",
              "opportunityId" : cmp.get("v.recordId"),
              "isPSGHHTUser" : event.getParam("isPSGHHTUser"),
              "pricebook2Id":event.getParam("pricebook2Id"),
          },
          function(newCmp, status, errorMessage){
              if (status === "SUCCESS") {
                  cmp.find("SearchProduct").set("v.body", newCmp);
                  // 親画面のレコードIDを保持する
                  cmp.find("SearchProductCmp").set("v.pricebook2Id", event.getParam("pricebook2Id"));
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

    createOLIPickListSupportCmp: function(cmp, event) {
        $A.createComponent(
            "c:OLIPickListSupport",
            {
                "aura:id" : "OLIPickListSupportCmp",
                "oppLineItemId" : event.getParam("oppLineItemId"),
                "currencyISOCode" : event.getParam("currencyISOCode"),
                "selectQuantityUnit" : event.getParam("selectQuantityUnit"),
                "selectDetailCategory" : event.getParam("selectDetailCategory"),
                "selectDetailCategoryMTE" : event.getParam("selectDetailCategoryMTE"),
                "selectRejectionReason" : event.getParam("selectRejectionReason"),
                "selectPlantCode" : event.getParam("selectPlantCode"),
                "selectPlantCodeMTE" : event.getParam("selectPlantCodeMTE"),
                "selectStorageLocation" : event.getParam("selectStorageLocation"),
                "selectStorageLocationMTE" : event.getParam("selectStorageLocationMTE"),
                "selectCurrency" : event.getParam("selectCurrency"),
                "selectRecordingDivision" : event.getParam("selectRecordingDivision"),
                "selectProfitCenter" : event.getParam("selectProfitCenter"),
                "selectProfitCenterMTE" : event.getParam("selectProfitCenterMTE"),
                "selectMaterialGroup1" : event.getParam("selectMaterialGroup1"),
                "shippingInstructions" : event.getParam("shippingInstructions"),
                "salesNoteCustome" : event.getParam("salesNoteCustome"),
                "selectSalesUnit" : event.getParam("selectSalesUnit"),
                "conditionRateInsurance" : event.getParam("conditionRateInsurance"),
                "insuranceFee" : event.getParam("insuranceFee"),
                "conditionRateTaxes" : event.getParam("conditionRateTaxes"),
                "freight" : event.getParam("freight"),
                "conditionDeliveryCost" : event.getParam("conditionDeliveryCost"),
                "otherDuties" : event.getParam("otherDuties"),
                "reserversFixed" : event.getParam("reserversFixed"),
                "trgInstRsrvsFixed" : event.getParam("trgInstRsrvsFixed"),
                "format":  event.getParam("format"),
            },
            function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    cmp.find("OLIPickListSupport").set("v.body", newCmp);
                    /*if(newCmp){
                        [].concat(newCmp)[0].open();
                    }*/
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

    convertNumber: function (val) {
        var regexp = new RegExp(/^[+,-]?([0-9]\d*|0)(\.\d+)?$/);
        if (!regexp.test(val)) {
            return 0;
        } 
        return parseFloat(val);
    },
})