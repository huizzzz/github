({
	formPress: function(cmp, event, helper) {
        if (event.keyCode === 27) {
            helper.doOnClose(cmp, event);
            // alert("SearchClose");
        }
    },
    // TODO 共通まとめ
    changefirstLayer: function(cmp, event, helper) {
        var selectFirstLayer = cmp.find('firstLayer').get("v.value");
        var secondHierarchyMap = cmp.get('v.secondHierarchyMap');
        if(secondHierarchyMap != null){
            var secondHierarchyOptions = secondHierarchyMap[selectFirstLayer];
            if(secondHierarchyOptions != null && secondHierarchyOptions.length > 0){
                cmp.set('v.bDisabledsecondHierarchy',false);
                cmp.set('v.secondHierarchyOptions',secondHierarchyOptions);
            }else{
                cmp.set('v.bDisabledsecondHierarchy',true);
                cmp.set('v.secondHierarchyOptions',[]);
            }
            cmp.set('v.thirdHierarchyOptions', []);
            cmp.set('v.bDisabledthirdHierarchy',true);
            cmp.find("secondLayer").set("v.value",'');
            cmp.find("thaadLayer").set("v.value",'');
        }
    },
    changeSecondLayer: function(cmp, event, helper) {
        var selectSecondLayer = cmp.find('secondLayer').get("v.value");
        var thirdHierarchyMap = cmp.get('v.thirdHierarchyMap');
        if(thirdHierarchyMap != null){
            var thirdHierarchyOptions = thirdHierarchyMap[selectSecondLayer];
            if(thirdHierarchyOptions != null && thirdHierarchyOptions.length > 0){
                cmp.set('v.thirdHierarchyOptions',thirdHierarchyOptions);
                cmp.set('v.bDisabledthirdHierarchy',false);
            }else{
                cmp.set('v.thirdHierarchyOptions', []);
                cmp.set('v.bDisabledthirdHierarchy',true);
            }
            console.log(thirdHierarchyOptions);
            cmp.find("thaadLayer").set("v.value",'');
        }
    },
    doInit: function(cmp, event, helper) {
        // デバイスの確認
        cmp.set('v.device', $A.get("$Browser.formFactor"));
        // 列名設定
        //cmp.set('v.columns', helper.getColumnDefinitions());
        // 選択リスト作成（型式）
        var opportunityId = cmp.get("v.opportunityId");
        // パラメータ設定
        var params = {
            opportunityId:opportunityId,
            pricebook2Id:cmp.get("v.pricebook2Id")};
        helper.doInit(cmp, params);
    },
    doSearch: function(cmp, event, helper) {
        // 検索条件取得
        var opportunityId = cmp.get("v.opportunityId");
        var pricebook2Id = cmp.get("v.pricebook2Id");
        //var CountryMode = cmp.find("CountryMode__c").get("v.value");
        //var Katashiki = cmp.find("Katashiki__c").get("v.value");
        //var ProductCalledName = cmp.find("ProductCalledName__c").get("v.value");
        var firstLayer = cmp.find("firstLayer").get("v.value");
        var secondLayer = cmp.find("secondLayer").get("v.value");
        var thaadLayer = cmp.find("thaadLayer").get("v.value");
        //var StructureSortNo = cmp.find("StructureSortNo__c").get("v.value");
        var StructureSortNo;
        var product2_Name = cmp.find("product2_Name").get("v.value");
        var PartsNo = cmp.find("PartsNo__c").get("v.value");
        var isPSGHHTUser = cmp.get("v.isPSGHHTUser");

        // パラメータ設定
        var params = {
            opportunityId:opportunityId,
            pricebook2Id:pricebook2Id,
            firstLayer:firstLayer,
            secondLayer:secondLayer,
            thaadLayer:thaadLayer,
            product2_Name:product2_Name,
            partsNo:PartsNo,
            isPSGHHTUser:isPSGHHTUser};

        // データ取得
        helper.fetchData(cmp, params);
    },
    doOnload: function(cmp, event, helper) {
        cmp.set('v.isOnload', false);
    },
    onCloseClicked: function(cmp, event, helper) {
        helper.doOnClose(cmp, event);
    },
    doAddProducts: function(cmp, event, helper) {
        // notice parent component to go back to the OpportunityLineItemBulkEdit component and reflect selected Products
        var reflectSearchProductEvent = cmp.getEvent("reflectSearchProduct");
        reflectSearchProductEvent.setParams({
            selectedProducts : cmp.get("v.selectedRows"),
        }).fire();
        //2020/03/31 ZH add 追加ボタン押す後レコード結果を消す Begin
        var data = cmp.get('v.data');
        if(data.length > 0){
            data.splice(0,data.length);
        }
        cmp.set('v.data',data);
        //2020/03/31 ZH add 追加ボタン押す後レコード結果を消す End
    },
    onOpenCalled: function(cmp, event, helper) {
        // alert('open');
        // alert(cmp.get("v.masterRecordId"));
    },
    resetColumns: function (cmp, event, helper) {
        helper.resetLocalStorage();

        cmp.set('v.columns', helper.getColumnDefinitions());
    },
    storeColumnWidths: function (cmp, event, helper) {
        helper.storeColumnWidths(event.getParam('columnWidths'));
    },
    updateColumnSorting: function (cmp, event, helper) {
        cmp.set('v.isLoading', true);
        // We use the setTimeout method here to simulate the async
        // process of the sorting data, so that user will see the
        // spinner loading when the data is being sorted.
        setTimeout($A.getCallback(function() {
            var fieldName = event.getParam('fieldName');
            var sortDirection = event.getParam('sortDirection');
            cmp.set("v.sortedBy", fieldName);
            cmp.set("v.sortedDirection", sortDirection);
            helper.sortData(cmp, fieldName, sortDirection);
            cmp.set('v.isLoading', false);
        }), 0);
    },
    updateSelectedText: function (cmp, event) {
        cmp.set("v.selectedRows", event.getParam('selectedRows'));
    },
})