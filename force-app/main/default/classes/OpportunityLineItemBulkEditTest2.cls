@isTest
public with sharing class OpportunityLineItemBulkEditTest2 {

    class DraftValues {
        String Id{get; set;}
        String Name{get; set;}
        Integer Quantity{get; set;}
        Double UnitPrice{get; set;}
        String ServiceDate{get; set;}
        String Description{get; set;}
    }

    class DraftValues2 {
        String Id{get; set;}
        String Name{get; set;}
        String Quantity{get; set;}
        String UnitPrice{get; set;}
        String ServiceDate{get; set;}
        String Description{get; set;}
    }

    class DeletedData {
        String Id{get; set;}
    }

    /**
     * ＤＢ反映処理：正常終了の場合（追加商品）
     * 価格表エントリ(商談に紐づく価格表)が未登録
     * 価格表エントリ(標準価格表)が未登録
     * 
     */
     @isTest(SeeAllData=true)
    static void unitTest_001() {
        Opportunity opp = [select Id from Opportunity limit 1];
        OpportunityLineItem opportunityLineItem = [select Id from OpportunityLineItem limit 1];
        // 商品登録
        Product2 product2 = new Product2();
        product2.Name = 'Name';
        product2.IsActive = true;
        product2.CountryMode__c = 'J';  // TODO
        product2.Katashiki__c = 'SU8240(Regulus)';  // TODO
        product2.ItemName__c = 'ItemName';
        insert product2;
        
        // draftValues
        JSONGenerator gen = JSON.createGenerator(true);
        List<DraftValues> draftValuesList = new List<DraftValues>();
        DraftValues d = new DraftValues();
        d.Id = 'Add' + product2.Id;
        d.Name = 'Name';
        d.Quantity = 1;
        d.UnitPrice = 100.1;
        d.ServiceDate = '2019-12-05';
        d.Description = 'Description';
        draftValuesList.add(d);
        gen.writeObject(draftValuesList);
        String draftValues = gen.getAsString();

        // deletedData
        gen = JSON.createGenerator(true);
        List<DraftValues> deletedDataList = new List<DraftValues>();
        DraftValues del = new DraftValues();
        del.Id = opportunityLineItem.Id;
        deletedDataList.add(del);
        gen.writeObject(deletedDataList);
        String deletedData = gen.getAsString();

        // ＤＢ反映
        OpportunityLineItemBulkEditController.reflectEditedData(opp.Id, draftValues, deletedData, null, 0, false);
    }

    /**
     * ＤＢ反映処理：正常終了の場合（追加商品）
     * 価格表エントリ(商談に紐づく価格表)が未登録
     * 価格表エントリ(標準価格表)が登録済み
     * 
     */
     @isTest(SeeAllData=true)
    static void unitTest_002() {
        Opportunity opp = [select Id from Opportunity limit 1];
        OpportunityLineItem opportunityLineItem = [select Id from OpportunityLineItem limit 1];
        // スタンダードの価格表を指定する必要がある
        Pricebook2 pricebook2Standard = [select Id from Pricebook2 where isStandard = true];
        // 商品登録
        Product2 product2 = new Product2();
        product2.Name = 'Name';
        product2.IsActive = true;
        product2.CountryMode__c = 'J';  // TODO
        product2.Katashiki__c = 'SU8240(Regulus)';  // TODO
        product2.ItemName__c = 'ItemName';
        insert product2;
        PricebookEntry pricebookEntryStandard = new PricebookEntry();
        pricebookEntryStandard.Pricebook2Id = pricebook2Standard.Id;
        pricebookEntryStandard.Product2Id = product2.Id;
        pricebookEntryStandard.UnitPrice = 10000;
        pricebookEntryStandard.IsActive = true;
        // 一旦FORループの中にinsertしますが、後ほど外側に移動する TODO
        insert pricebookEntryStandard;
        
        // draftValues
        JSONGenerator gen = JSON.createGenerator(true);
        List<DraftValues2> draftValuesList = new List<DraftValues2>();
        DraftValues2 d = new DraftValues2();
        d.Id = 'Add' + product2.Id;
        d.Name = 'Name';
        d.Quantity = '1';
        d.UnitPrice = '100.1';
        d.ServiceDate = '';
        d.Description = '';
        draftValuesList.add(d);
        gen.writeObject(draftValuesList);
        String draftValues = gen.getAsString();

        // deletedData
        gen = JSON.createGenerator(true);
        List<DraftValues> deletedDataList = new List<DraftValues>();
        DraftValues del = new DraftValues();
        del.Id = opportunityLineItem.Id;
        deletedDataList.add(del);
        gen.writeObject(deletedDataList);
        String deletedData = gen.getAsString();

        // ＤＢ反映
        OpportunityLineItemBulkEditController.reflectEditedData(opp.Id, draftValues, deletedData, null, 0, false);
    }

    /**
     * ＤＢ反映処理：正常終了の場合（追加商品）
     * 価格表エントリ(商談に紐づく価格表)が登録済み
     * 価格表エントリ(標準価格表)が登録済み
     * 
     */
     @isTest(SeeAllData=true)
    static void unitTest_003() {
        Opportunity opp = [select Id, Pricebook2Id from Opportunity where Pricebook2Id != null limit 1];
        OpportunityLineItem opportunityLineItem = [select Id from OpportunityLineItem limit 1];
        // スタンダードの価格表を指定する必要がある
        Pricebook2 pricebook2Standard = [select Id from Pricebook2 where isStandard = true];
        // 商品登録
        Product2 product2 = new Product2();
        product2.Name = 'Name';
        product2.IsActive = true;
        product2.CountryMode__c = 'J';  // TODO
        product2.Katashiki__c = 'SU8240(Regulus)';  // TODO
        product2.ItemName__c = 'ItemName';
        insert product2;
        PricebookEntry pricebookEntryStandard = new PricebookEntry();
        pricebookEntryStandard.Pricebook2Id = pricebook2Standard.Id;
        pricebookEntryStandard.Product2Id = product2.Id;
        pricebookEntryStandard.UnitPrice = 10000;
        pricebookEntryStandard.IsActive = true;
        insert pricebookEntryStandard;
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = opp.Pricebook2Id;
        pricebookEntry.Product2Id = product2.Id;
        pricebookEntry.UnitPrice = 10001;
        pricebookEntry.IsActive = true;
        insert pricebookEntry;
        
        // draftValues
        JSONGenerator gen = JSON.createGenerator(true);
        List<DraftValues2> draftValuesList = new List<DraftValues2>();
        DraftValues2 d = new DraftValues2();
        d.Id = 'Add' + product2.Id;
        d.Name = 'Name';
        d.Quantity = '1';
        d.UnitPrice = '100.1';
        d.ServiceDate = '';
        d.Description = '';
        draftValuesList.add(d);
        gen.writeObject(draftValuesList);
        String draftValues = gen.getAsString();

        // deletedData
        gen = JSON.createGenerator(true);
        List<DraftValues> deletedDataList = new List<DraftValues>();
        DraftValues del = new DraftValues();
        del.Id = opportunityLineItem.Id;
        deletedDataList.add(del);
        gen.writeObject(deletedDataList);
        String deletedData = gen.getAsString();

        // ＤＢ反映
        OpportunityLineItemBulkEditController.reflectEditedData(opp.Id, draftValues, deletedData, null, 0, false);
    }

    /**
     * ＤＢ反映処理：正常終了の場合（新規商品）
     * 
     */
     @isTest(SeeAllData=true)
    static void unitTest_004() {
        Opportunity opp = [select Id from Opportunity limit 1];
        OpportunityLineItem opportunityLineItem = [select Id from OpportunityLineItem limit 1];
        
        // draftValues
        JSONGenerator gen = JSON.createGenerator(true);
        List<DraftValues> draftValuesList = new List<DraftValues>();
        DraftValues d = new DraftValues();
        d.Id = 'New';
        d.Name = 'Name';
        d.Quantity = 1;
        d.UnitPrice = 100.1;
        d.ServiceDate = '2019-12-05';
        d.Description = 'Description';
        draftValuesList.add(d);
        gen.writeObject(draftValuesList);
        String draftValues = gen.getAsString();

        // deletedData
        gen = JSON.createGenerator(true);
        List<DraftValues> deletedDataList = new List<DraftValues>();
        DraftValues del = new DraftValues();
        del.Id = opportunityLineItem.Id;
        deletedDataList.add(del);
        gen.writeObject(deletedDataList);
        String deletedData = gen.getAsString();

        // ＤＢ反映
        OpportunityLineItemBulkEditController.reflectEditedData(opp.Id, draftValues, deletedData, null, 0, false);
    }

    /**
     * ＤＢ反映処理：正常終了の場合（更新商品）
     * 
     */
     @isTest(SeeAllData=true)
    static void unitTest_005() {
        Opportunity opp = [select Id from Opportunity limit 1];
        OpportunityLineItem opportunityLineItem = [select Id from OpportunityLineItem limit 1];
        
        // draftValues
        JSONGenerator gen = JSON.createGenerator(true);
        List<DraftValues> draftValuesList = new List<DraftValues>();
        DraftValues d = new DraftValues();
        d.Id = opportunityLineItem.Id;
        d.Name = 'Name';
        d.Quantity = 1;
        d.UnitPrice = 100.1;
        d.ServiceDate = '2019-12-05';
        d.Description = 'Description';
        draftValuesList.add(d);
        gen.writeObject(draftValuesList);
        String draftValues = gen.getAsString();

        // deletedData
        gen = JSON.createGenerator(true);
        List<DraftValues> deletedDataList = new List<DraftValues>();
        DraftValues del = new DraftValues();
        del.Id = opportunityLineItem.Id;
        deletedDataList.add(del);
        gen.writeObject(deletedDataList);
        String deletedData = gen.getAsString();

        // ＤＢ反映
        OpportunityLineItemBulkEditController.reflectEditedData(opp.Id, draftValues, deletedData, null, 0, false);
    }
}