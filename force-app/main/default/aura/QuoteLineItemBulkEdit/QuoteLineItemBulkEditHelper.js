({
    fetchData: function (cmp) {
        // Display the total in a "toast" status message
        var resultsToast = $A.get("e.force:showToast");

        var params = { quoteId:cmp.get("v.recordId") };
        this.sendRequest(cmp, 'c.getQuoteLineItems', params)
        .then($A.getCallback(function(response) {

            var returnVal = JSON.parse(response);

            // 正常終了の場合
            if(returnVal.returnCode == 0){
                cmp.set('v.data', returnVal.data);
                cmp.set('v.originalData', returnVal.originData);
                cmp.set('v.canEditProduct2', true);
                cmp.set('v.quoteLineItemParams',returnVal.displayParams);
                cmp.set('v.pricebook2Id',returnVal.pricebook2Id);
                // 通貨設定
                cmp.set('v.currencyIsoCode', returnVal.currencyIsoCode);
                cmp.set('v.isPSGHHTUser', returnVal.isPSGHHTUser);
                // 通貨フォーマット設定
                cmp.set('v.format',returnVal.displayParams.format);
                cmp.set('v.symbol',returnVal.displayParams.symbol);
                cmp.set('v.digits',returnVal.displayParams.digits);
                cmp.set('v.digitsInput',returnVal.displayParams.digitsInput);
                //計算セクション
                cmp.set("v.shokei",returnVal.displayParams.shokei);
                cmp.set("v.shohizeiRitsu",returnVal.displayParams.shohizeiRitsu);
                cmp.set("v.riekiGokei",returnVal.displayParams.riekiGokei);
                cmp.set("v.nebikiKingaku",returnVal.displayParams.nebikiKingaku);
                cmp.set("v.shohizeiGokei",returnVal.displayParams.shohizeiGokei);
                cmp.set("v.riekiRitsu",returnVal.displayParams.riekiRitsu);
                cmp.set("v.saisyuKingaku",returnVal.displayParams.saisyuKingaku);
                cmp.set("v.mcGokei",returnVal.displayParams.mcGokei);
                cmp.set("v.hhtRieki",returnVal.displayParams.hhtRieki);
                cmp.set("v.tcGokei",returnVal.displayParams.tcGokei);
                cmp.set("v.hhtRiekiritsu",returnVal.displayParams.hhtRiekiritsu);
                cmp.set("v.furontoKakaku",returnVal.displayParams.furontoKakaku);
                cmp.set("v.genpoTCGokei",returnVal.displayParams.genpoTCGokei);
                cmp.set("v.ararieki",returnVal.displayParams.ararieki);
                cmp.set("v.arariekiRitsu",returnVal.displayParams.arariekiRitsu);
                cmp.set("v.headerNebiki01",returnVal.displayParams.headerNebiki01);
                cmp.set("v.headerNebiki02",returnVal.displayParams.headerNebiki02);
                cmp.set("v.headerNebikiritsu",returnVal.displayParams.headerNebikiritsu);   
                cmp.set("v.syuseiNebiki01",returnVal.displayParams.syuseiNebiki01);   
                cmp.set("v.syuseiNebiki02",returnVal.displayParams.syuseiNebiki02);   
                cmp.set("v.mesainebikiGokei",returnVal.displayParams.mesainebikiGokei);
                //cmp.set("v.zeikomiCheck",returnVal.displayParams.zeikomiCheck);
                cmp.set("v.ishikiCheck",returnVal.displayParams.isIshiki);
                //cmp.set("v.originDatas",returnVal.originDatas);
                cmp.set("v.saisyuKingakuZeikomi",returnVal.displayParams.saisyuKingakuZeikomi);
                cmp.set('v.fertilityDiscountTitle1',returnVal.displayParams.fertilityDiscountTitle1);
                cmp.set("v.fertilityDiscountTitle2",returnVal.displayParams.fertilityDiscountTitle2);
                cmp.set("v.localCorporationTCProfit",returnVal.displayParams.localCorporationTCProfit);
                cmp.set("v.localCorporationTCProfitRate",returnVal.displayParams.localCorporationTCProfitRate);
                cmp.set('v.discountRate',returnVal.displayParams.discountRate);

                var columns = [];
                if(cmp.get("v.isPSGHHTUser")){
                    columns = [
                        {label: "Id", fieldName: 'Id', type: 'text', sortable: false, editable: true, initialWidth:300 },
                        {label: $A.get("$Label.c.COWO_LBL_ItemNumberInEdit"), fieldName: 'COWO_ItemNumber__c', type: 'number', typeAttributes: { required: true },sortable: false, editable: true, initialWidth:100, cellAttributes: { iconName: {fieldName: 'trendIcon'} }, iconPosition: 'right' },
                        {label: $A.get("$Label.c.COWO_LBL_ItemName"), fieldName: 'COWO_Product_Name__c', type: 'text', sortable: false, editable: true, initialWidth:300 },
                        {label: $A.get("$Label.c.COWO_LBL_ProductCode"), fieldName: 'COWO_ProductCode__c', type: 'text', sortable: false, editable: true , initialWidth:150 },
                        {label: $A.get("$Label.c.COWO_LBL_Parts_No"), fieldName: 'COWO_PartsNo__c', type: 'text', sortable: false, editable: true, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_Quantity"), fieldName: 'Quantity', type: 'number', sortable: false, editable: true, initialWidth:60},
                        {label: $A.get("$Label.c.COWO_LBL_UnitPrice"), fieldName: 'UnitPrice', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_DiscountPrice"), fieldName: 'COWO_DiscountPrice__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_DiscountUnitPrice"), fieldName: 'COWO_DiscountUnitPrice__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: false, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_TotalPrice"), fieldName: 'COWO_TotalPrice__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: false, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_QuantityUnit"), fieldName: 'COWO_QuantityUnit__c', type: 'text', sortable: false, editable: false, initialWidth:100 },                    
                        {label: $A.get("$Label.c.COWO_LBL_SalesUnit"), fieldName: 'COWO_SalesUnit__c', type: 'text', sortable: false, editable: true, initialWidth:100 },                    
                        {label: $A.get("$Label.c.COWO_LBL_PartitionPrice"), fieldName: 'COWO_PartitionPrice__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_TC"), fieldName: 'COWO_TC__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: cmp.get("v.isPSGHHTUser"), initialWidth:150},
                        {label: $A.get("$Label.c.COWO_LBL_MC"), fieldName: 'COWO_MC__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: cmp.get("v.isPSGHHTUser"), initialWidth:150},
                        {label: $A.get("$Label.c.COWO_LBL_LocalCorporationTC"), fieldName: 'COWO_LocalCorporationTC__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:150},
                        {label: $A.get("$Label.c.COWO_LBL_FrontPurchasePrice"), fieldName: 'COWO_FrontPurchasePrice__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:150},   
                        {label: $A.get("$Label.c.COWO_LBL_DetailCategory_STE"), fieldName: 'COWO_DetailCategory__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_DetailCategory"), fieldName: 'COWO_DetailCategory_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_RejectionReason"), fieldName: 'COWO_RejectionReason__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_PlantCode"), fieldName: 'COWO_PlantCode__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_PlantCode_MTE"), fieldName: 'COWO_PlantCode_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_StorageLocation"), fieldName: 'COWO_StorageLocation__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_StorageLocation_MTE")    , fieldName: 'COWO_StorageLocation_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        // {label: $A.get("$Label.c.COWO_LBL_Currency"), fieldName: 'COWO_Currency__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_RecordingDivision"), fieldName: 'COWO_Recording_Division__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_WBSElement"), fieldName: 'COWO_WBSElement__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ProfitCenter"), fieldName: 'COWO_ProfitCenter__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ProfitCenter_MTE"), fieldName: 'COWO_ProfitCenter_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ItemText"), fieldName: 'COWO_ItemText__c', type: 'text', sortable: false, editable: true, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_DeliverySchedule"), fieldName: 'COWO_DeliverySchedule__c', type: 'date-local', typeAttributes:{month: "2-digit",day: "2-digit"}, sortable: false, editable: true, initialWidth:150},
                        {label: $A.get("$Label.c.COWO_LBL_SummaryMaterialAvailDate"), fieldName: 'COWO_MaterialAvailDate__c', type: 'date-local', typeAttributes:{month: "2-digit",day: "2-digit"}, sortable: false, editable: true, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_MaterialGroup1"), fieldName: 'COWO_MaterialGroup1__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ShippingInstructions"), fieldName: 'COWO_ShippingInstructions__c', type: 'text', sortable: false, editable: false, initialWidth:100,wrapText:true },
                        {label: $A.get("$Label.c.COWO_LBL_SalesNoteCustome"), fieldName: 'COWO_SalesNoteCustome__c', type: 'text', sortable: false, editable: false, initialWidth:100 ,wrapText:true},
                        {label: "SAP Update Flag (STE)", fieldName: 'CO_ovcUpdateFlag__c', type: 'text', sortable: false, editable: false, initialWidth:100 ,wrapText:true},
                        {label: "SAP Update Flag (MTE)", fieldName: 'CO_ovcUpdateFlag_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 ,wrapText:true},
                        {label: $A.get("$Label.c.COWO_LBL_SetPicklist"), type: 'button', initialWidth: 135, typeAttributes: { label: $A.get("$Label.c.COWO_LBL_SetPicklist"), name: 'picklistSupport', title: 'Click to View Details'},style:'height:3px'}
                    ];
                }else{
                    columns = [
                        {label: "Id", fieldName: 'Id', type: 'text', sortable: false, editable: true, initialWidth:300 },
                        {label: $A.get("$Label.c.COWO_LBL_ItemNumberInEdit"), fieldName: 'COWO_ItemNumber__c', type: 'number', typeAttributes: { required: true },sortable: false, editable: true, initialWidth:100, cellAttributes: { iconName: {fieldName: 'trendIcon'} }, iconPosition: 'right' },
                        {label: $A.get("$Label.c.COWO_LBL_ItemName"), fieldName: 'COWO_Product_Name__c', type: 'text', sortable: false, editable: true, initialWidth:300 },
                        {label: $A.get("$Label.c.COWO_LBL_ProductCode"), fieldName: 'COWO_ProductCode__c', type: 'text', sortable: false, editable: true, initialWidth:150 },
                        {label: $A.get("$Label.c.COWO_LBL_Parts_No"), fieldName: 'COWO_PartsNo__c', type: 'text', sortable: false, editable: true, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_Quantity"), fieldName: 'Quantity', type: 'number', sortable: false, editable: true, initialWidth:60},
                        {label: $A.get("$Label.c.COWO_LBL_UnitPrice"), fieldName: 'UnitPrice', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_DiscountPrice"), fieldName: 'COWO_DiscountPrice__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_DiscountUnitPrice"), fieldName: 'COWO_DiscountUnitPrice__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: false, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_TotalPrice"), fieldName: 'COWO_TotalPrice__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: false, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_QuantityUnit"), fieldName: 'COWO_QuantityUnit__c', type: 'text', sortable: false, editable: false, initialWidth:100 },                    
                        {label: $A.get("$Label.c.COWO_LBL_SalesUnit"), fieldName: 'COWO_SalesUnit__c', type: 'text', sortable: false, editable: true, initialWidth:100 },                    
                        {label: $A.get("$Label.c.COWO_LBL_PartitionPrice"), fieldName: 'COWO_PartitionPrice__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:100},
                        {label: $A.get("$Label.c.COWO_LBL_LocalCorporationTC"), fieldName: 'COWO_LocalCorporationTC__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:150},
                        {label: $A.get("$Label.c.COWO_LBL_FrontPurchasePrice"), fieldName: 'COWO_FrontPurchasePrice__c', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, minimumFractionDigits: cmp.get("v.digits"), maximumFractionDigits: cmp.get("v.digits")}, sortable: false, editable: true, initialWidth:150},   
                        {label: $A.get("$Label.c.COWO_LBL_DetailCategory_STE"), fieldName: 'COWO_DetailCategory__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_DetailCategory"), fieldName: 'COWO_DetailCategory_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_RejectionReason"), fieldName: 'COWO_RejectionReason__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_PlantCode"), fieldName: 'COWO_PlantCode__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_PlantCode_MTE"), fieldName: 'COWO_PlantCode_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_StorageLocation"), fieldName: 'COWO_StorageLocation__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_StorageLocation_MTE")    , fieldName: 'COWO_StorageLocation_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        // {label: $A.get("$Label.c.COWO_LBL_Currency"), fieldName: 'COWO_Currency__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_RecordingDivision"), fieldName: 'COWO_Recording_Division__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_WBSElement"), fieldName: 'COWO_WBSElement__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ProfitCenter"), fieldName: 'COWO_ProfitCenter__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ProfitCenter_MTE"), fieldName: 'COWO_ProfitCenter_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ItemText"), fieldName: 'COWO_ItemText__c', type: 'text', sortable: false, editable: true, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_DeliverySchedule"), fieldName: 'COWO_DeliverySchedule__c', type: 'date-local', typeAttributes:{month: "2-digit",day: "2-digit"}, sortable: false, editable: true, initialWidth:150},
                        {label: $A.get("$Label.c.COWO_LBL_SummaryMaterialAvailDate"), fieldName: 'COWO_MaterialAvailDate__c', type: 'date-local', typeAttributes:{month: "2-digit",day: "2-digit"}, sortable: false, editable: true, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_MaterialGroup1"), fieldName: 'COWO_MaterialGroup1__c', type: 'text', sortable: false, editable: false, initialWidth:100 },
                        {label: $A.get("$Label.c.COWO_LBL_ShippingInstructions"), fieldName: 'COWO_ShippingInstructions__c', type: 'text', sortable: false, editable: false, initialWidth:100,wrapText:true },
                        {label: $A.get("$Label.c.COWO_LBL_SalesNoteCustome"), fieldName: 'COWO_SalesNoteCustome__c', type: 'text', sortable: false, editable: false, initialWidth:100 ,wrapText:true},
                        {label: "SAP Update Flag (STE)", fieldName: 'CO_ovcUpdateFlag__c', type: 'text', sortable: false, editable: false, initialWidth:100 ,wrapText:true},
                        {label: "SAP Update Flag (MTE)", fieldName: 'CO_ovcUpdateFlag_MTE__c', type: 'text', sortable: false, editable: false, initialWidth:100 ,wrapText:true},
                        {label: $A.get("$Label.c.COWO_LBL_SetPicklist"), type: 'button', initialWidth: 135, typeAttributes: { label: $A.get("$Label.c.COWO_LBL_SetPicklist"), name: 'picklistSupport', title: 'Click to View Details'},style:'height:3px'}
                    ];
                }

                cmp.set('v.columns', columns);
                //cmp.find("amount").set("v.format",'$#,###.00');
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
                // 戻るデータを処理したい場合 TODO
                console.log(returnVal.addNewQuoteLineItemList);  // 追加/新規データ
                console.log(returnVal.draftIdList);
                
                // var data = cmp.get("v.data");

                // // var mergedData = Object.assign(cmp.get('v.data'), cmp.find("datatable").get("v.draftValues"));
                // // console.log(mergedData);
                // // draftValuesをdataに反映する
                // cmp.find("datatable").get("v.draftValues").forEach(function(element){
                //     for(var dataIndex = 0; dataIndex < data.length; dataIndex++){
                //         if(data[dataIndex].Id == element.Id){
                //             var mergedDataRow = Object.assign(data[dataIndex], element);
                //             console.log("mergedDataRow: " + mergedDataRow);
                //             break;
                //         }
                //     }
                // });
                
                // for(var addNewIndex = 0; addNewIndex < returnVal.addNewQuoteLineItemList.length; addNewIndex++){
                //     for(var dataIndex = 0; dataIndex < data.length; dataIndex++){
                //         if(data[dataIndex].Id.substr(0,3) == "Add"){
                //             data[dataIndex].Id = data[dataIndex].Id.substr(3);
                //             break;
                //         } else if(data[dataIndex].Id.substr(0,3) == "New"){
                //             data[dataIndex].Id = addNewQuoteLineItemList[addNewIndex].Id;
                //             break;
                //         }
                //     }
                // }
                
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
    cellRecalculate: function (cmp) {
        
        // Display the total in a "toast" status message
        var resultsToast = $A.get("e.force:showToast");
        
        var data = cmp.get('v.data');
        var shokei = 0;
        var mesainebikiGokei = 0;
        var nebikiKingaku = 0;
        var tcGokei = 0;
        var mcGokei = 0;
        var frontGokei = 0;
        var genpoTCGokei = 0;
        for(var dataIndex = 0; dataIndex < data.length; dataIndex++){
            shokei += data[dataIndex].Subtotal;
            // if(!data[dataIndex].COWO_NoDiscountFlg__c){
            //     mesainebikiGokei += this.convertNumber(data[dataIndex].COWO_DiscountPrice__c);
            // }
            mesainebikiGokei += this.convertNumber(data[dataIndex].COWO_DiscountPrice__c);
            tcGokei += this.convertNumber(data[dataIndex].COWO_TC__c) * this.convertNumber(data[dataIndex].Quantity);
            mcGokei += this.convertNumber(data[dataIndex].COWO_MC__c) * this.convertNumber(data[dataIndex].Quantity);
            frontGokei += this.convertNumber(data[dataIndex].COWO_FrontPurchasePrice__c) * this.convertNumber(data[dataIndex].Quantity);
            genpoTCGokei += this.convertNumber(data[dataIndex].COWO_LocalCorporationTC__c) * this.convertNumber(data[dataIndex].Quantity);
        }
        // 小計
        cmp.set('v.shokei',shokei);
        cmp.set('v.mesainebikiGokei',mesainebikiGokei);
        cmp.set('v.tcGokei',tcGokei);
        cmp.set('v.mcGokei',mcGokei);
        cmp.set('v.genpoTCGokei',genpoTCGokei);
        cmp.set('v.furontoKakaku',frontGokei);
        this.kingakuRecal(cmp);
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
        var openQLIPickListSupportEvent = cmp.getEvent("openQLIPickListSupport");
        openQLIPickListSupportEvent.setParams({quoteLineItemId: row.Id
                                              ,selectQuantityUnit:row.COWO_QuantityUnit__c
                                              ,selectDetailCategory:row.COWO_DetailCategory__c
                                              ,selectDetailCategoryMTE:row.COWO_DetailCategory_MTE__c
                                              ,selectRejectionReason:row.COWO_RejectionReason__c
                                              ,selectPlantCode:row.COWO_PlantCode__c
                                              ,selectPlantCodeMTE:row.COWO_PlantCode_MTE__c
                                              ,selectStorageLocation:row.COWO_StorageLocation__c
                                              ,selectStorageLocationMTE:row.COWO_StorageLocation_MTE__c
                                              ,selectRecordingDivision:row.COWO_Recording_Division__c
                                              ,selectProfitCenter:row.COWO_ProfitCenter__c
                                              ,selectMaterialGroup1:row.COWO_MaterialGroup1__c
                                              ,selectSalesUnit:row.COWO_SalesUnit__c
                                              ,shippingInstructions:row.COWO_ShippingInstructions__c
                                              ,salesNoteCustome:row.COWO_SalesNoteCustome__c
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

        data = Object.assign([], data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
        );
        cmp.set("v.data", data);
        //cmp.set("v.draftValues", data);
    },
    storeColumnWidths: function (widths) {
        localStorage.setItem('datatable-in-action', JSON.stringify(widths));
    },
    /**
     * 見積金額再計算
     */
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
        var localCorporationTCProfit;
        var localCorporationTCProfitRate;
        var discountRate;
        
        //ヘッダ値引き(割引額)02
        //headernebiki02 = cmp.get('v.shokei') * this.convertNumber(cmp.get('v.headerNebikiritsu')) /100;
        headernebiki02 = cmp.get('v.shokei') * this.convertNumber(cmp.get('v.headerNebikiritsu')) ;
        
        //値引金額
        nebikiKingaku = this.convertNumber(cmp.get('v.mesainebikiGokei')) + this.convertNumber(cmp.get('v.headerNebiki01')) + headernebiki02
        + this.convertNumber(cmp.get('v.syuseiNebiki01')) + this.convertNumber(cmp.get('v.syuseiNebiki02'));

        //最終金額
        saisyuKingaku = cmp.get('v.shokei') - nebikiKingaku;
        //消費税合計
        shohizeiGokei = saisyuKingaku * this.convertNumber(cmp.get('v.shohizeiRitsu'));
        //最終金額(税込)
        saisyuKingakuZeikomi = saisyuKingaku + shohizeiGokei;
        //利益合計
        riekiGokei = saisyuKingaku - this.convertNumber(cmp.get('v.furontoKakaku'));
        //利益率
        riekiRitsu = saisyuKingaku != 0 ? riekiGokei / saisyuKingaku : 0;
        //HHT利益
        //hhtRieki = this.convertNumber(cmp.get('v.furontoKakaku')) - this.convertNumber(cmp.get('v.tcGokei'));
        hhtRieki = saisyuKingaku - this.convertNumber(cmp.get('v.tcGokei'));
        //粗利益
        //arairieki = this.convertNumber(cmp.get('v.furontoKakaku')) - this.convertNumber(cmp.get('v.mcGokei'));
        arairieki = saisyuKingaku - this.convertNumber(cmp.get('v.mcGokei'));
        //HHT利益率
        hhtRiekiritsu = saisyuKingaku != 0 ? hhtRieki / saisyuKingaku : 0;
        //粗利益率
        arairiekiRitsu = saisyuKingaku != 0 ? arairieki / saisyuKingaku : 0;
        //現法利益合計
        localCorporationTCProfit = saisyuKingaku - this.convertNumber(cmp.get('v.genpoTCGokei'));
        //現法利益合計率
        localCorporationTCProfitRate =  saisyuKingaku != 0 ? localCorporationTCProfit / saisyuKingaku : 0;
        //値引率
        discountRate = this.convertNumber(cmp.get('v.shokei')) != 0 ? nebikiKingaku / this.convertNumber(cmp.get('v.shokei')) : 0;

        cmp.set('v.nebikiKingaku',nebikiKingaku);
        cmp.set('v.saisyuKingaku',saisyuKingaku);
        cmp.set('v.shohizeiGokei',shohizeiGokei);
        cmp.set('v.riekiGokei',riekiGokei);
        cmp.set('v.hhtRieki',hhtRieki);
        cmp.set('v.ararieki',arairieki);
        cmp.set('v.hhtRiekiritsu',hhtRiekiritsu);
        cmp.set('v.arariekiRitsu',arairiekiRitsu);
        cmp.set('v.riekiRitsu',riekiRitsu);
        cmp.set('v.headerNebiki02',headernebiki02);
        cmp.set('v.saisyuKingakuZeikomi',saisyuKingakuZeikomi);
        cmp.set('v.localCorporationTCProfit',localCorporationTCProfit);
        cmp.set('v.localCorporationTCProfitRate',localCorporationTCProfitRate);
        cmp.set('v.discountRate',discountRate);
    },
    /**
     * 端数調整
     */
    adjustFraction: function (cmp) {
        // TC案分端数処理
        var maxTotalPrice = 0;
        var finalAmount = cmp.get('v.saisyuKingaku');
        var allTotalPrice = 0;
        var allTCDiscount = 0;
        var data = cmp.find("datatable").get("v.data");
        var draftValues = cmp.find("datatable").get("v.draftValues");
        cmp.find("datatable").get("v.data").forEach(function(element){
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
                    cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get("v.draftValues").concat(tempDraft));
                    break;
                }
            }
            cmp.find('datatable').set('v.data',data);
        }
    },
    /**
     * 金額再計算
     */
    recalPrice: function (cmp,tcTemp) {
        var data = cmp.find("datatable").get("v.data");
        var draftValues = cmp.find("datatable").get("v.draftValues");
        for(var index = 0;index < data.length; index++){
            // 小計計算
            data[index].Subtotal = Math.round(this.convertNumber(data[index].Quantity) * this.convertNumber(data[index].UnitPrice));
            // TC&TC合計再計算
            // if(data[index].COWO_TC__c != null){
            //     tcTemp = tcTemp - data[index].COWO_TotalTC__c;
            //     data[index].COWO_TotalTC__c = this.convertNumber(data[index].COWO_TC__c) * this.convertNumber(data[index].Quantity);
            //     tcTemp = tcTemp + data[index].COWO_TotalTC__c;
            // }
            if(data[index].COWO_TC__c != null){
                tcTemp = tcTemp - data[index].COWO_TotalTC__c;
                if(!data[index].COWO_NoDiscountFlg__c){
                    data[index].COWO_TotalTC__c = this.convertNumber(data[index].COWO_TC__c) * this.convertNumber(data[index].Quantity);
                    tcTemp = tcTemp + data[index].COWO_TotalTC__c;
                }
            }

            // 合計金額再計算
            // if(cmp.get('v.tcGokei') != 0 && !data[index].COWO_NoDiscountFlg__c){
            //     data[index].COWO_TotalPrice__c = Math.round(data[index].Subtotal - data[index].COWO_DiscountPrice__c - 
            //         ((this.convertNumber(data[index].COWO_TotalTC__c) / cmp.get('v.tcGokei')) * (this.convertNumber(cmp.get('v.headerNebiki01')) + this.convertNumber(cmp.get('v.headerNebiki02')) + 
            //         this.convertNumber(cmp.get('v.syuseiNebiki01'))  + this.convertNumber(cmp.get('v.syuseiNebiki02')))));
            //         // alert('COWO_TotalPrice__c'+data[index].COWO_TotalPrice__c);
            // }else{
            //     data[index].COWO_TotalPrice__c = Math.round(data[index].Subtotal - data[index].COWO_DiscountPrice__c);
            // }
            if(tcTemp != 0 && !data[index].COWO_NoDiscountFlg__c){
                data[index].COWO_TotalPrice__c = Math.round(data[index].Subtotal - data[index].COWO_DiscountPrice__c - 
                    ((this.convertNumber(data[index].COWO_TotalTC__c) / tcTemp) * (this.convertNumber(cmp.get('v.headerNebiki01')) + this.convertNumber(cmp.get('v.headerNebiki02')) + 
                    this.convertNumber(cmp.get('v.syuseiNebiki01'))  + this.convertNumber(cmp.get('v.syuseiNebiki02')))));
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

            this.cellRecalculate(cmp);
            cmp.find("datatable").set("v.draftValues", cmp.find("datatable").get("v.draftValues").concat(tempDraft));
        }
        cmp.find('datatable').set('v.data',data);
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