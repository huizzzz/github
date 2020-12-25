/********************************************************************************
 * クラス名 ： CL_OpportunityLineItemTriggerHandler
 * 概　　要 ： 案件製品のトリガハンドラークラス
 * 作 成 日 ： 2016/01/29 Fujii
 * 更 新 日 ：
 ********************************************************************************/
public with sharing class CL_OpportunityLineItemTriggerHandler {

    /**
     * コンストラクタ
     **/
    public CL_OpportunityLineItemTriggerHandler(){
    }

    /**
     * 金額項目更新処理
     * @param List<OpportunityLineItem> newObjects newTriggerの値
     */
    public void recalPrice(List<OpportunityLineItem> newObjects){

        // String recId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId();
        // COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // 商談のレコードタイプ取得
        // Id recId = comTypeManager.getRecordTypeId( 'Opportunity', 'SAWO_DX_Opportunity' );
        Id recId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId();

        //Product の取得
        //金額項目の更新
        List<Id> pbeIds = new List<Id>();
        //更新対象Idの取得20170613addKakino
        List<Id> LItemIds = new List<Id>();
        //案件Idの取得20170613addKakino
        List<Id> OppIds = new List<Id>();
        for(OpportunityLineItem tmpLine :newObjects ){
            pbeIds.add(tmpLine.PricebookEntryId);
            //20170613addKakino
            LItemIds.add(tmpLine.Id);
            //20170613addKakino
        }
        //価格表・製品の情報を取得
        List<PricebookEntry> pbeLists = [
                                         SELECT
                                         Id,
                                         PartitionPrice__c,
                                         Product2.b__c,
                                         Product2.Q__c,
                                         Product2.TC__c,
                                         Product2.MC__c
                                         FROM
                                         PricebookEntry
                                         where id in :pbeIds
                                         ];

        //20170613addKakino
        //案件製品情報を取得
        List<OpportunityLineItem> oppLILists = [
                                         SELECT
                                         Id,
                                         Opportunity.Id
                                         FROM
                                         OpportunityLineItem
                                         where Id in :LItemIds AND Opportunity.Id != ''
                                         ];

        for(OpportunityLineItem tmpopp : oppLILists){
        	OppIds.add(tmpopp.opportunity.id);
        }

        //案件情報を取得
        List<Opportunity> oppLists = [
                              SELECT
                              Id,
                              ISCLOSED,
                              recordTypeId
                              FROM
                              Opportunity
                              WHERE Id in:OppIds
                              ];

        //案件情報をマップに設定
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for(Opportunity tmpOpp : oppLists){
        	oppMap.put(tmpOpp.Id, tmpOpp);
        }

        //案件製品Idをkey、案件情報をvalueとしてマップに設定
        Map<Id, Opportunity> oppAndItemMap = new Map<Id, Opportunity>();
        for(OpportunityLineItem tempLI : oppLILists){
        	oppAndItemMap.put(tempLI.Id, oppMap.get(tempLI.opportunity.Id));
        }

        //20170613addKakino
		CL_TriggerUtil util = new CL_TriggerUtil();

        //処理の簡易化のためにマップに設定
        Map<ID, PricebookEntry> pbeMap = new Map<ID, PricebookEntry>();
        for(PricebookEntry tmpLine :pbeLists ){
            pbeMap.put(tmpLine.Id, tmpLine);
        }
        //数量と金額は必須項目
        for(OpportunityLineItem tmpLine :newObjects ){

            if(oppMap.get(tmpLine.opportunityId).recordTypeId == recId) { continue; } 
            system.debug('tmpLine.OpportunityId:'+ oppMap.get(tmpLine.opportunityId).recordTypeId);

            // 20190116 Mamada Add 見積調書対応
            // 見積調書からの案件製品作成の場合、下記の処理を行わない
            if(!tmpLine.specialQuotationFlg__c) {
            // 20190116 Mamada Add End
                if(!((oppAndItemMap.containskey(tmpLine.Id) && oppAndItemMap.get(tmpLine.Id).ISCLOSED) || util.isBatchUser())){
                    PricebookEntry tmpPbe = pbeMap.get(tmpLine.PricebookEntryId);
                    if(!tmpLine.FreeProductFlag__c){
                        tmpLine.b__c  = tmpPbe.Product2.b__c;
                        if( tmpPbe.Product2.Q__c == null){
                            tmpLine.Q__c = null;
                        }else{
                            tmpLine.Q__c  = tmpPbe.Product2.Q__c * tmpLine.Quantity;
                        }
    
                        if( tmpPbe.Product2.TC__c == null){
                            tmpLine.TC__c = null;
                        }else{
                            tmpLine.TC__c  = tmpPbe.Product2.TC__c * tmpLine.Quantity;
                        }
    
                        if( tmpPbe.Product2.MC__c == null){
                            tmpLine.MC__c = null;
                        }else{
                            tmpLine.MC__c  = tmpPbe.Product2.MC__c * tmpLine.Quantity;
                        }
                        if( tmpPbe.PartitionPrice__c == null){
                            tmpLine.ShikiriPrice__c = null;
                        }else{
                            tmpLine.ShikiriPrice__c  = tmpPbe.PartitionPrice__c * tmpLine.Quantity;
                        }
                    }
                }
            }
        }
    }

    /**
     * 案件製品の保存時に自動で入力内容を設定する
     * @param oldList 案件製品リスト(変更前)
     * @param newList 案件製品リスト(変更後)
     *
     * @return void
     **/
    public void beforeUpdateAutoSetup(List<OpportunityLineItem> oldList, List<OpportunityLineItem> newList){

        Boolean isInsert = false;
        Boolean isUpdate = false;

        // 追加か更新か判断する
        if(oldList == null){
            isInsert = true;
        }
        else{
            isUpdate = true;
        }

        // 型式に対応する仕入先情報を取得する
        Map<String, KatashikiAndShiresakiMap__c> katashikiMap = KatashikiAndShiresakiMap__c.getAll();

        // 案件製品に自動設定する
        for(OpportunityLineItem oppItem : newList){

            if(!String.isBlank(oppItem.katashiki__c)){
                if(katashikiMap.containsKey(oppItem.katashiki__c)){
                    // 仕入先コードに那珂のコードを設定する
                    oppItem.SupplierCode__c = System.Label.AP31_CONST_0005;
                }
            }
        }
    }

    /**
     * 案件製品が新規作成された場合、案件の情報を同期する
     * @param List<OpportunityLineItem> newMap Trigger.newの値
     */
    public void syncFromOpportunity(Map<ID, OpportunityLineItem> newMap){

        if(newMap.size() <= 0){ return; }

        syncFromOpportunity(new Set<ID>(newMap.keySet()));
    }

    /**
     *　対象の案件製品の親案件の入力内容と同期をとる
     * @param Set<ID> ids 同期対象の案件製品SFDC IDリスト
     */
    @future
    static private void syncFromOpportunity(Set<ID> ids){

        // 対象の案件製品および案件を取得する
        List<OpportunityLineItem> oppLines = [
                                                Select
                                                        id,
                                                        ShukkaRequestDate__c,
                                                        TehaiYoteiDate__c,
                                                        FunazumiYoteiDate__c,
                                                        HannyuYoteiDate__c,
                                                        SuetsukeStartDate__c,
                                                        SuetsukeKanryoDate__c,
                                                        OrdersYoteiDate__c,
                                                        SalesYoteiDate__c,
                                                        Jinendoyosanfuragu__c,
                                                        Nendoyosanfuragu__c,
                                                        Kakimitoshiyosanfuragu__c,
                                                        BudgetAddUpFlg__c,
                                                        Opportunity.ZyuyoShukkaRequestDate__c,
                                                        Opportunity.TehaiYoteiDate__c,
                                                        Opportunity.FunazumiYoteiDate__c,
                                                        Opportunity.HannyuYoteiDate__c,
                                                        Opportunity.SuetsukeStartDate__c,
                                                        Opportunity.SuetsukeKanryoDate__c,
                                                        Opportunity.OrdersYotei__c,
                                                        Opportunity.SalesDate__c,
                                                        Opportunity.Jinendoyosanfuragu__c,
                                                        Opportunity.Nendoyosanfuragu__c,
                                                        Opportunity.Kakimitoshiyosanfuragu__c,
                                                        Opportunity.Jikkenfuragu__c
                                                From
                                                        OpportunityLineItem
                                                Where
                                                        id = :ids
                                            ];

        // 更新対象が検索できなかった場合は終了
        if(opplines.size() <= 0){ return; }

        for(OpportunityLineItem target : oppLines){
            // 需要情報
            target.ShukkaRequestDate__c     = target.Opportunity.ZyuyoShukkaRequestDate__c; // 出荷要求日
            target.TehaiYoteiDate__c        = target.Opportunity.TehaiYoteiDate__c;         //　手配予定日
            target.FunazumiYoteiDate__c     = target.Opportunity.FunazumiYoteiDate__c;      // 船積予定日
            target.HannyuYoteiDate__c       = target.Opportunity.HannyuYoteiDate__c;        // 搬入予定日
            target.SuetsukeStartDate__c     = target.Opportunity.SuetsukeStartDate__c;      // 据付開始日
            target.SuetsukeKanryoDate__c    = target.Opportunity.SuetsukeKanryoDate__c;     // 据付完了日

            // 予算情報
            target.Jinendoyosanfuragu__c        = target.Opportunity.Jinendoyosanfuragu__c;     // 次年度予算フラグ
            target.Nendoyosanfuragu__c          = target.Opportunity.Nendoyosanfuragu__c;       // 年度予算フラグ
            target.Kakimitoshiyosanfuragu__c    = target.Opportunity.Kakimitoshiyosanfuragu__c; // 下期見通フラグ
            target.BudgetAddUpFlg__c            = target.Opportunity.Jikkenfuragu__c;           // 実推フラグ
            target.OrdersYoteiDate__c           = target.Opportunity.OrdersYotei__c;            // 受注月
            target.SalesYoteiDate__c            = target.Opportunity.SalesDate__c;              // 売上月
        }

        update oppLines;
    }

    public void setPrice_DX(List<OpportunityLineItem> newObjects){
        // COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // 見積のレコードタイプ取得
        // Id oppType = comTypeManager.getRecordTypeId( 'Opportunity', 'SAWO_DX_Opportunity' );
        Id oppType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId();

        List<Id> pbeIds = new List<Id>();
        //更新対象Idの取得
        List<Id> LItemIds = new List<Id>();
        //案件Idの取得
        List<Id> OppIds = new List<Id>();
        for(OpportunityLineItem tmpLine :newObjects ){
            pbeIds.add(tmpLine.PricebookEntryId);
            LItemIds.add(tmpLine.Id);
        }

        //価格表・製品の情報を取得
        List<PricebookEntry> pbeLists = [
                                         SELECT
                                         Id,
                                         Product2.MC__c,
                                         Product2.TC__c,
                                         COWO_MC__c,
                                         COWO_TC__c,
                                         Product2Id,
                                         Product2.Description //2020/11/18 Cho Add
                                         FROM PricebookEntry
                                         WHERE Id IN :pbeIds
                                         ];

        Map<Id, PricebookEntry> pbeMap = new Map<Id, PricebookEntry>();                               
        for(PricebookEntry pbe : pbeLists) {
            pbeMap.put(pbe.Id, pbe);
        }

        //自由入力製品の取得
        Id freeProductId = [SELECT Id 
                            FROM Product2 
                            WHERE Name = :System.Label.AP00_CONST_0001 LIMIT 1].Id;

        for(OpportunityLineItem tmpLine :newObjects ) {
            if(tmpLine.Opportunity.recordTypeId == oppType) {
                if(tmpLine.Product2Id != freeProductId) {
                    tmpLine.MC__c = pbeMap.get(tmpLine.PricebookEntryId).Product2.MC__c;
                    tmpLine.TC__c = pbeMap.get(tmpLine.PricebookEntryId).Product2.TC__c;
                }
                tmpLine.Tekiyo__c = pbeMap.get(tmpLine.PricebookEntryId).Product2.Description;
            }
        }

    }
    
    /** 
     * setInitializeFieldOvc　初期値設定　Initialize
     * 商談商品新規登録時に項目の初期化を行う。
     * コピー元の値を初期化する。
     * Initialize items when registering new business negotiations.
     * Initialize the copy source value.
     *
     * @param List<Opportunity> newObjects
     */
    public void setInitializeFieldOvc(List<OpportunityLineItem> newObjects){
        for(OpportunityLineItem oppItem:newObjects){
            oppItem.CO_ovcSendStatus__c = null;
            oppItem.CO_ovcSendDate__c = null;
            oppItem.CO_ovcPostDate__c = null;
            oppItem.CO_ovcSendStatus_WBS__c = null;
            oppItem.CO_ovcSendDate_WBS__c = null;
            oppItem.CO_ovcSalesOrderNumber__c = null;
            oppItem.CO_SAPSalesOrderNumber_MTE__c = null;
            oppItem.CO_ovcSendStatus_MTE__c = null;
            oppItem.CO_ovcSendDate_MTE__c = null;
            oppItem.CO_ovcPostDate_MTE__c = null;
        }
        
    }

}