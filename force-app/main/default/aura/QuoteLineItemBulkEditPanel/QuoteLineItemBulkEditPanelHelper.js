({
    createQuoteLineItemBulkEditCmp: function(cmp, event) {
      $A.createComponent(
          "c:QuoteLineItemBulkEdit",
          {
              "aura:id" : "QuoteLineItemBulkEditCmp",
              "recordId" : cmp.get("v.recordId"),
          },
          function(newCmp, status, errorMessage){
              if (status === "SUCCESS") {
                  cmp.find("QuoteLineItemBulkEdit").set("v.body", newCmp);
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
          "c:QuoteLineItemSearchProduct",
          {
              "aura:id" : "SearchProductCmp",
              "quoteId" : cmp.get("v.recordId"),
              "pricebook2Id":event.getParam("pricebook2Id"),
              "isPSGHHTUser" : event.getParam("isPSGHHTUser")
          },
          function(newCmp, status, errorMessage){
              if (status === "SUCCESS") {
                  cmp.find("SearchProduct").set("v.body", newCmp);
                  // 親画面のレコードIDを保持する
                  cmp.find("SearchProductCmp").set("v.pricebook2Id", event.getParam("pricebook2Id"));
                  cmp.find("SearchProductCmp").set("v.quoteId", event.getParam("quoteId"));
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
    createQLIPickListSupportCmp: function(cmp, event) {
        $A.createComponent(
            "c:QLIPickListSupport",
            {
                "aura:id" : "QLIPickListSupportCmp",
                "quoteLineItemId" : event.getParam("quoteLineItemId"),
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
                "selectSalesUnit" : event.getParam("selectSalesUnit"),
                "shippingInstructions" : event.getParam("shippingInstructions"),
                "salesNoteCustome" : event.getParam("salesNoteCustome")
            },
            function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    cmp.find("QLIPickListSupport").set("v.body", newCmp);
                    // if(newCmp){
                    //     [].concat(newCmp)[0].open();
                    // }
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
    
    cellRecalculate: function (cmp) {
        
        // Display the total in a "toast" status message
        var resultsToast = $A.get("e.force:showToast");
        
        var data = cmp.find('QuoteLineItemBulkEditCmp').get('v.data');
        var shokei = 0;
        var mesainebikiGokei = 0;
        var nebikiKingaku = 0;
        var tcGokei = 0;
        var mcGokei = 0;
        var frontGokei = 0;
        var genpoTCGokei = 0;
        for(var dataIndex = 0; dataIndex < data.length; dataIndex++){
            shokei += data[dataIndex].Subtotal;
            mesainebikiGokei += this.convertNumber(data[dataIndex].COWO_DiscountPrice__c);
            tcGokei += this.convertNumber(data[dataIndex].COWO_TotalTC__c);
            mcGokei += this.convertNumber(data[dataIndex].COWO_TotalMC__c);
            frontGokei += this.convertNumber(data[dataIndex].COWO_TotalFrontPurchasePrice__c);
            genpoTCGokei += this.convertNumber(data[dataIndex].COWO_TotalLocalCorporationTC__c);
        }
        // 小計
        cmp.find('QuoteLineItemBulkEditCmp').set('v.shokei',shokei);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.mesainebikiGokei',mesainebikiGokei);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.tcGokei',tcGokei);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.mcGokei',mcGokei);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.genpoTCGokei',genpoTCGokei);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.furontoKakaku',frontGokei);
        this.kingakuRecal(cmp);
    },
    
    kingakuRecal: function (cmp) {
        var nebikiKingaku;
        var saisyuKingaku;
        var shohizeiGokei;
        var riekiGokei;
        var riekiRitsu;
        var hhtRieki;
        var hhtRiekiritsu;
        var arairieki;
        var arairiekiRitsu;
        var headernebiki02;
        var saisyuKingakuZeikomi;
        
        //ヘッダ値引き(割引額)02
        headernebiki02 = cmp.find('QuoteLineItemBulkEditCmp').get('v.shokei') * this.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.headerNebikiritsu'));
        
        //値引金額
        nebikiKingaku = this.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.mesainebikiGokei')) + this.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.headerNebiki01')) + headernebiki02
        + this.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.syuseiNebiki01')) + this.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.syuseiNebiki02'));
        
        //最終金額
        saisyuKingaku = cmp.find('QuoteLineItemBulkEditCmp').get('v.shokei') - nebikiKingaku;
        //消費税合計
        shohizeiGokei = saisyuKingaku * this.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.shohizeiRitsu'));
        //最終金額(税込)
        saisyuKingakuZeikomi = saisyuKingaku + shohizeiGokei;
        //利益合計
        riekiGokei = saisyuKingaku - this.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.furontoKakaku'));
        //利益率
        riekiRitsu = saisyuKingaku != 0 ? riekiGokei / saisyuKingaku : 0;
        //HHT利益
        hhtRieki = saisyuKingaku - this.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.tcGokei'));
        //粗利益
        arairieki = saisyuKingaku - this.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.mcGokei'));
        //HHT利益率
        hhtRiekiritsu = this.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.furontoKakaku')) != 0 ? hhtRieki / this.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.furontoKakaku')) : 0;
        //粗利益率
        arairiekiRitsu = this.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.furontoKakaku')) != 0 ? arairieki / this.convertNumber(cmp.find('QuoteLineItemBulkEditCmp').get('v.furontoKakaku')) : 0;
        
        cmp.find('QuoteLineItemBulkEditCmp').set('v.nebikiKingaku',nebikiKingaku);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.saisyuKingaku',saisyuKingaku);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.shohizeiGokei',shohizeiGokei);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.riekiGokei',riekiGokei);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.hhtRieki',hhtRieki);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.ararieki',arairieki);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.hhtRiekiritsu',hhtRiekiritsu);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.arariekiRitsu',arairiekiRitsu);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.riekiRitsu',riekiRitsu);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.headerNebiki02',headernebiki02);
        cmp.find('QuoteLineItemBulkEditCmp').set('v.saisyuKingakuZeikomi',saisyuKingakuZeikomi);
    },
    /**
     * 金額再計算
     */
    recalPrice: function (cmp,neibikiGokei) {
        var data = cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.data");
        var draftValues = cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.draftValues");
        var tcTemp = cmp.find('QuoteLineItemBulkEditCmp').get('v.tcGokei');
        for(var index = 0;index < data.length; index++){
            // 小計計算
            data[index].Subtotal = Math.round(this.convertNumber(data[index].Quantity) * this.convertNumber(data[index].UnitPrice));
            // TC&TC合計再計算
            if(data[index].COWO_TC__c != null){
                tcTemp = tcTemp - data[index].COWO_TotalTC__c;
                if(!data[index].COWO_NoDiscountFlg__c){
                    data[index].COWO_TotalTC__c = this.convertNumber(data[index].COWO_TC__c) * this.convertNumber(data[index].Quantity);
                    tcTemp = tcTemp + data[index].COWO_TotalTC__c;
                }
            }
            // 合計金額再計算
            if(tcTemp != 0 && !data[index].COWO_NoDiscountFlg__c){
                data[index].COWO_TotalPrice__c = Math.round(data[index].Subtotal - data[index].COWO_DiscountPrice__c - 
                    ((this.convertNumber(data[index].COWO_TotalTC__c) / tcTemp) * neibikiGokei));
                    // alert('COWO_TotalPrice__c'+data[index].COWO_TotalPrice__c);
            }else{
                data[index].COWO_TotalPrice__c = Math.round(data[index].Subtotal - data[index].COWO_DiscountPrice__c);
            }
            data[index].COWO_DiscountUnitPrice__c = Math.round(data[index].COWO_TotalPrice__c / data[index].Quantity);
            var tempDraft = [
                {
                    Id: data[index].Id,
                    COWO_TotalPrice__c : data[index].COWO_TotalPrice__c,
                    COWO_DiscountUnitPrice__c : data[index].COWO_DiscountUnitPrice__c,
                    Subtotal : data[index].Subtotal,
                }
            ];
            cmp.find('QuoteLineItemBulkEditCmp').find("datatable").set("v.draftValues", cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.draftValues").concat(tempDraft));
        }
        cmp.find('QuoteLineItemBulkEditCmp').find('datatable').set('v.data',data);
    },
     /**
     * 端数調整
     */
    adjustFraction: function (cmp) {
        // TC案分端数処理
        var maxTotalPrice = 0;
        var finalAmount = cmp.find('QuoteLineItemBulkEditCmp').get('v.saisyuKingaku');
        var allTotalPrice = 0;
        var allTCDiscount = 0;
        var data = cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.data");
        var draftValues = cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.draftValues");
        cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.data").forEach(function(element){
            if(element.COWO_TotalPrice__c != null){
                if(!element.COWO_NoDiscountFlg__c){
                    allTotalPrice += element.COWO_TotalPrice__c;
                    if(element.COWO_TotalPrice__c >= maxTotalPrice){
                        maxTotalPrice = element.COWO_TotalPrice__c;
                    }
                }else{
                    allTCDiscount += element.COWO_DiscountPrice__c;
                    finalAmount -= element.Subtotal;
                }
            }
        });

        var finalAmtWithoutTC = this.convertNumber(finalAmount) + this.convertNumber(allTCDiscount);

        if(Math.abs(finalAmtWithoutTC - allTotalPrice) > 0){
            for(var index = 0;index < data.length; index++){
                if(maxTotalPrice == data[index].COWO_TotalPrice__c && !data[index].COWO_NoDiscountFlg__c){
                    if((finalAmtWithoutTC - allTotalPrice) > 0){
                        data[index].COWO_TotalPrice__c = data[index].COWO_TotalPrice__c + Math.abs((finalAmtWithoutTC - allTotalPrice));
                    }else{
                        data[index].COWO_TotalPrice__c = data[index].COWO_TotalPrice__c - Math.abs((finalAmtWithoutTC - allTotalPrice));
                    }
                    data[index].COWO_DiscountUnitPrice__c = data[index].COWO_TotalPrice__c / data[index].Quantity;
                    var tempDraft = [
                        {
                            Id: data[index].Id,
                            COWO_TotalPrice__c : data[index].COWO_TotalPrice__c,
                            COWO_DiscountUnitPrice__c : data[index].COWO_DiscountUnitPrice__c
                        }
                    ];
                    cmp.find('QuoteLineItemBulkEditCmp').find("datatable").set("v.draftValues", cmp.find('QuoteLineItemBulkEditCmp').find("datatable").get("v.draftValues").concat(tempDraft));
                    break;
                }
            }
            cmp.find('QuoteLineItemBulkEditCmp').find('datatable').set('v.data',data);
        }
    },
    convertNumber: function (val) {
        var regexp = new RegExp(/^[+,-]?([0-9]\d*|0)(\.\d+)?$/);
        if (!regexp.test(val)) {
            return 0;
        } 
        return parseFloat(val);
    },
})