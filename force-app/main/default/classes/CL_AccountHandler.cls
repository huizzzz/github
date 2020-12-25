/**
 * 施設トリガ処理クラス(Account trigger processing class)
 *
 * Copyright (c) Hitachi Solutions, Ltd. Japan
 */
public class CL_AccountHandler {

    // [S][Add] 2017/05/19 Toshima HTD向け権限付与改修
    // [S][Mod] 2017/06/15 Toshima 権限付与改修
    
    // User.AgencyRole__cの値(value of User.AgencyRole__c)
    private static final String AGENCY_WORKER  = '担当者';
    private static final String AGENCY_MANAGER = 'マネージャー';
    // 変更されていたかチェックする項目(Items to check if they have been changed)

    // AccountShare作成時のデフォルト値(Default value when creating AccountShare)
    private static final List<String> CHECK_TARGET_FIELDS = new List<String>{'OwnerId','CustomShareMaster__c'};
    // [E][Mod] 2017/06/15 Toshima 権限付与改修
    // HTD向け、参照権限付与対象のレコードタイプ.developerName
    //(Record type for HTD for which reference authority is granted.developerName)
    private static final String HTD_RECORDTYPE_DEVELOPERNAME = 'Asia';
    private static final Id HTD_RECORDTYPE_ID;

    static{
        List<RecordType> htdRecordTypeId = [select id from recordtype where DeveloperName = :HTD_RECORDTYPE_DEVELOPERNAME limit 1];
        if(!htdRecordTypeId.isEmpty()) HTD_RECORDTYPE_ID = htdRecordTypeId[0].Id;
    }
    // [E][Add] 2017/05/19 Toshima HTD向け権限付与改修
    
    //JTL会社施設レコードタイプ取得(Get the record type JTL of Account)
    List<RecordType> jtlRecordTypeId = [select Id from recordtype where SobjectType = 'Account' and  DeveloperName = 'HHT_JTL' limit 1];
    //CBI会社施設レコードタイプ取得(Get the record type CBI of Account)
    List<RecordType> cbiRecordTypeId = [select Id from recordtype where SobjectType = 'Account' and  DeveloperName = 'COWO_CBI' limit 1];
    //コンストラクタ(constructor)
    public CL_AccountHandler(){}
    
    /**
     * BeforeUpdateイベントの場合の処理(Processing for BeforeUpdate event)
     * @param List<Account> newAccountList,List<Account> oldAccountList
     */
    //public void onBeforeUpdate(List<Account> newAccountList,List<Account> oldAccountList){
      public void onBeforeUpdate(List<Account> newAccountList, Map<Id, Account> newMap, List<Account> oldAccountList, Map<Id, Account> oldMap ){

        System.debug(LoggingLevel.INFO, '■newMap ：' + newMap);
        System.debug(LoggingLevel.INFO, '■oldMap ：' + oldMap);
        System.debug(LoggingLevel.INFO, '■newList ：' + newAccountList);
        System.debug(LoggingLevel.INFO, '■oldList ：' + oldAccountList);
          
        CL_TriggerUtil util = new CL_TriggerUtil();    //[Add]2016.09.15 Toyoda CAS-HiSAS組織統合
        if( !util.isCasUser() )    return;             //[Add]2016.09.15 Toyoda CAS-HiSAS組織統合

        if(oldAccountList[0].OwnerId != newAccountList[0].OwnerId){
            //納入装置の所有者を取得する(Get the owner of the DeliveryDevice__c)
            List<DeliveryDevice__c> deliveryList = [SELECT OwnerId FROM DeliveryDevice__c WHERE Acount_ref__c IN :newAccountList limit 50000];
            //エラーチェック(Error checking)
            if(deliveryList.size()>10000){
                newAccountList[0].adderror(System.Label.CDL0001_MSG_0001);
                return;
            }
            //施設の所有者のセット処理(Account owner set processing)
            for(integer i=0;i<deliveryList.size();i++){
                deliveryList[i].OwnerId = newAccountList[0].OwnerId;
            }
            update deliveryList;
        }

        //[Add]2016.12.08 Toyoda GeocodeAutoUpdate対応
        //ジオコード取得(Get Geocode)
        GeocodeAutoUpdate(newMap,oldMap);
    }
    
    //[Add]2016.12.08 Toyoda GeocodeAutoUpdate対応
    // 挿入前トリガ(Before insert trigger)
    public void onBeforeInsert(List<Account> newAccountList, Map<Id, Account> newMap, List<Account> oldAccountList, Map<Id, Account> oldMap ){
        //ダンズナンバーコピー(Copy CBI_PKG__DunsNbr__c to COWO_DunsNbr__c)
        for(Account newAcc : newAccountList){
            newAcc.COWO_DunsNbr__c = newAcc.CBI_PKG__DunsNbr__c;
        }
    }

    //[S][Add]2016.12.08 Toyoda GeocodeAutoUpdate対応
    /**
     * ジオコード自動更新(Geocode automatic update)
     */
    private void GeocodeAutoUpdate(Map<Id, Account> newMap, Map<Id, Account> oldMap){
        try{
            // 変更レコードでループ(Loop on change record)
            for(Account newAcc : newMap.values()){
                Account oldAcc = (oldMap!=null?oldMap.get(newAcc.Id):null);

                string oldAddress = (oldAcc.BillingState!=null?oldAcc.BillingState:'') + (oldAcc.BillingCity!=null?oldAcc.BillingCity:'') + (oldAcc.BillingStreet!=null?oldAcc.BillingStreet:'');
                string newAddress = (newAcc.BillingState!=null?newAcc.BillingState:'') + (newAcc.BillingCity!=null?newAcc.BillingCity:'') + (newAcc.BillingStreet!=null?newAcc.BillingStreet:'');
                
                System.debug(LoggingLevel.INFO, '■旧住所 ：' + oldAddress);
                System.debug(LoggingLevel.INFO, '■新住所 ：' + newAddress);
                //住所情報に変更がある場合(When address information is changed)
                if( oldAcc==null || oldAddress != newAddress ){
                    updateAccoountGeometory(newAcc.Id);
                }
                newAcc.COWO_DunsNbr__c = newAcc.CBI_PKG__DunsNbr__c;
            }
        }catch(Exception ex){
            //ApexからのAPIコールの場合、GoogleMapの制約で1日2500回を超えるとOVER_QUERY_LIMITが出る。
            //(When API called from Apex, OVER_QUERY_LIMIT will appear if the number of times exceeds 2500 times a day due to Google Map restrictions.)
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }
    }
    
    /**
     * ジオコード自動更新_insert用(Geocode automatic update for inserting)
     */
    private void GeocodeAutoUpdate2(Map<Id, Account> newMap){
        try{
            // 変更レコードでループ(Loop on change record)
            for(Account newAcc : newMap.values()){
                string newAddress = (newAcc.BillingState!=null?newAcc.BillingState:'') + (newAcc.BillingCity!=null?newAcc.BillingCity:'') + (newAcc.BillingStreet!=null?newAcc.BillingStreet:'');
                System.debug(LoggingLevel.INFO, '■住所 ：' + newAddress);
                if (newAddress == '') {
                    return;
                }
                //住所情報に変更がある場合(When address information is changed)
                if( newAcc.lat__c==null || newAcc.lng__c==null ){
                    updateAccoountGeometory(newAcc.Id);
                }
            }
        }catch(Exception ex){
            //ApexからのAPIコールの場合、GoogleMapの制約で1日2500回を超えるとOVER_QUERY_LIMITが出る。
            //(When API called from Apex, OVER_QUERY_LIMIT will appear if the number of times exceeds 2500 times a day due to Google Map restrictions.)
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }
    }
    
    @Future(callout=true)
    private static void updateAccoountGeometory(Id accountId){
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        Account acc = [SELECT Id, lat__c, lng__c, BillingState, BillingCity, BillingStreet FROM Account WHERE Id = :accountId LIMIT 1];
        string add = (acc.BillingState!=null?acc.BillingState:'') + (acc.BillingCity!=null?acc.BillingCity:'') + (acc.BillingStreet!=null?acc.BillingStreet:'');
        System.debug(LoggingLevel.INFO, '■取引先 ：' + acc);

        if (add == null || add == '') {
            return;
        }
        //GoogleMapから緯度経度情報を取得(Get latitude and longitude information from Google Map)
        //https://maps.googleapis.com/maps/api/geocode/output?parameters
        req.setMethod('GET');
        req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='
                                   + EncodingUtil.urlEncode(add, 'UTF-8')
                                   + '&key='
                                   + Label.CAS_APIKEY
                                   + '&sensor=false;');
        HttpResponse res = http.send(req);
        System.debug(LoggingLevel.INFO, '■responseBody ：' + res.getBody().replace('\n',''));

        if (res.getStatusCode() == 200) {            
            Location loc = toLocation(res.getBody());
            if(loc!=null) {
                if ( loc.getLatitude() != null || loc.getLongitude() != null) {
                    acc.lat__c = loc.getLatitude();
                    acc.lng__c = loc.getLongitude();
                } else {
                    // 何もしない
                }
            }
        }
        System.debug(LoggingLevel.INFO, '■取引先更新 ：' + acc);
        update acc;
    }
    
    private static Location toLocation(String jsonBody) {
        Map<String, Object> resMap   = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
        string status = (string) resMap.get('status');
        if(status == 'OK') {
            List<Object> results  = (List<Object>) resMap.get('results');
            Map<String, Object> result   = (Map<String, Object>) results[0];
            Map<String, Object> geometry = (Map<String, Object>) result.get('geometry');
            Map<String, Object> loc      = (Map<String, Object>) geometry.get('location');
            Decimal latitude = (Decimal) loc.get('lat');
            Decimal longtude = (Decimal) loc.get('lng');
            return Location.newInstance(latitude, longtude);
        } else {
            return null;
        }
    }

    //[E][Add]2016.12.08 Toyoda GeocodeAutoUpdate対応
    
    // [S][Add] 2017/05/19 Toshima HTD向け権限付与改修
    public void onAfterInsert(Map<Id,Account> newMap){
        Map<Id,Account> HTDAccountsMap = new Map<Id,Account>();
        for(Id accId:newMap.keySet()){
            // レコードタイプが「HTD医用」の場合、共有付与対象に追加
            //(If the record type is "HTD Medical", add it to the sharing setting target)
            if(newMap.get(accId).RecordTypeId.equals(HTD_RECORDTYPE_ID)){
                //shareMgr.addAccount(newMap.get(accId));
                HTDAccountsMap.put(accId,newMap.get(accId));
            }
        }
        if(!HTDAccountsMap.isEmpty()){
            CL_CustomShareHandler Handler = new CL_CustomShareHandler(Account.sObjectType,HTDAccountsMap);
            Map<sObject,List<sObject>> results = Handler.createShare();
            system.debug('results:\n'+results);
        }

        //ジオコード取得(Get Geocode)
        GeocodeAutoUpdate2(newMap);
    }
    public void onAfterUpdate(Map<Id,Account> oldMap,Map<Id,Account> newMap){
        Map<Id,Account> HTDAccountsOldMap = new Map<Id,Account>();
        Map<Id,Account> HTDAccountsNewMap = new Map<Id,Account>();
        Map<Id,T_InquiriesContactform__c> HTDInquiriesContactformOldMap = new Map<Id,T_InquiriesContactform__c>();
        Map<Id,T_InquiriesContactform__c> HTDInquiriesContactformNewMap = new Map<Id,T_InquiriesContactform__c>();
        
        //★
        Map<Id,T_KGK_IBase__c> HTDT_KGK_IBaseOldMap = new Map<Id,T_KGK_IBase__c>();
        Map<Id,T_KGK_IBase__c> HTDT_KGK_IBaseNewMap = new Map<Id,T_KGK_IBase__c>();
        Map<Id,T_KGK_ForwardingInfo__c> HTDT_KGK_ForwardingInfoOldMap = new Map<Id,T_KGK_ForwardingInfo__c>();
        Map<Id,T_KGK_ForwardingInfo__c> HTDT_KGK_ForwardingInfoNewMap = new Map<Id,T_KGK_ForwardingInfo__c>();
        Map<Id,T_KGK_WorkHistory__c> HTDT_KGK_WorkHistoryOldMap = new Map<Id,T_KGK_WorkHistory__c>();
        Map<Id,T_KGK_WorkHistory__c> HTDT_KGK_WorkHistoryNewMap = new Map<Id,T_KGK_WorkHistory__c>();
        //★
        
        for(Id accId:newMap.keySet()){
            // レコードタイプが「HTD医用」の場合、共有付与対象に追加
            //(If the record type is "HTD Medical", add it to the sharing setting target)
            if(newMap.get(accId).RecordTypeId.equals(HTD_RECORDTYPE_ID) && !isFieldsAllEqual(oldMap.get(accId),newMap.get(accId),CHECK_TARGET_FIELDS)){
                System.debug('added\t' +newMap.get(accId) );
                HTDAccountsOldMap.put(accId,oldMap.get(accId));
                HTDAccountsNewMap.put(accId,newMap.get(accId));
            }
        }
        // 更新前の会社名に紐付く、連絡票を取得(Associate with Account name before update, get T_InquiriesContactform__c)
        List<T_InquiriesContactform__c> HTDICsOldList = [SELECT id,CustomShareMaster__c from T_InquiriesContactform__c where kokyakumei__c In :HTDAccountsOldMap.keySet()];
        if(HTDICsOldList.size()!=0){
            for(T_InquiriesContactform__c HTDIC : HTDICsOldList){
                HTDInquiriesContactformOldMap.put(HTDIC.id,HTDIC); 
            }
        }
        
        // 更新後の会社名に紐付く、連絡票を取得(Associate with updated Account name, get T_InquiriesContactform__c)
        List<T_InquiriesContactform__c> HTDICsNewList = [SELECT id,CustomShareMaster__c,Kokyakumei__c from T_InquiriesContactform__c where kokyakumei__c In :HTDAccountsNewMap.keySet()];
        if(HTDICsNewList.size()!=0){
            for(T_InquiriesContactform__c HTDIC : HTDICsNewList){
                HTDIC.CustomShareMaster__c = HTDAccountsNewMap.get(HTDIC.Kokyakumei__c).CustomShareMaster__c;
                HTDInquiriesContactformNewMap.put(HTDIC.id,HTDIC); 
            }
        }


        // 更新前の会社名に紐付く、設置ベースを取得(Associate with Account name before update, get T_KGK_IBase__c)
        List<T_KGK_IBase__c> HTDIBsOldList = [SELECT id,CustomShareMaster__c from T_KGK_IBase__c where SalesAccount__c In :HTDAccountsOldMap.keySet()];
        System.debug('HTDIBsOldList size: ' +HTDIBsOldList.size());
        if(HTDIBsOldList.size()!=0){
            for(T_KGK_IBase__c HTDIB : HTDIBsOldList){
                HTDT_KGK_IBaseOldMap.put(HTDIB.id,HTDIB); 
            }
        }
        
        // 更新後の会社名に紐付く、設置ベースを取得(Associate with updated Account name, get T_KGK_IBase__c)
        List<T_KGK_IBase__c> HTDIBsNewList = [SELECT id,CustomShareMaster__c,SalesAccount__c from T_KGK_IBase__c where SalesAccount__c In :HTDAccountsNewMap.keySet()];
        System.debug('HTDIBsNewList size: ' +HTDIBsNewList.size());
        if(HTDIBsNewList.size()!=0){
            for(T_KGK_IBase__c HTDIB : HTDIBsNewList){
                HTDIB.CustomShareMaster__c = HTDAccountsNewMap.get(HTDIB.SalesAccount__c).CustomShareMaster__c;
                HTDT_KGK_IBaseNewMap.put(HTDIB.id,HTDIB); 
            }
        }
        
        // 更新前の設置ベースに紐付く、納入機器を取得(Associate with T_KGK_IBase__c before update, get T_KGK_ForwardingInfo__c)
        List<T_KGK_ForwardingInfo__c> HTDFIsOldList = [SELECT id,CustomShareMaster__c from T_KGK_ForwardingInfo__c where SecchiBaseNo__c In :HTDT_KGK_IBaseOldMap.keySet()];
        if(HTDFIsOldList.size()!=0){
            for(T_KGK_ForwardingInfo__c HTDFI : HTDFIsOldList){
                HTDT_KGK_ForwardingInfoOldMap.put(HTDFI.id,HTDFI); 
            }
        }
        
        // 更新後の会社名に紐付く、納入機器を取得(Associate with updated Account name, get T_KGK_ForwardingInfo__c)
        List<T_KGK_ForwardingInfo__c> HTDFIsNewList = [SELECT id,CustomShareMaster__c,SecchiBaseNo__c from T_KGK_ForwardingInfo__c where SecchiBaseNo__c In :HTDT_KGK_IBaseNewMap.keySet()];
        if(HTDFIsNewList.size()!=0){
            for(T_KGK_ForwardingInfo__c HTDFI : HTDFIsNewList){
                System.debug('HTDFIsNewList ID: ' +HTDFI.Id);
                System.debug('HTDFIsNewList SecchiBaseNo__c: ' +HTDFI.SecchiBaseNo__c);
                System.debug('HTDFIsNewList CustomShareMaster__c: ' +HTDT_KGK_ForwardingInfoNewMap.get(HTDFI.SecchiBaseNo__c).CustomShareMaster__c);
              
                HTDFI.CustomShareMaster__c = HTDT_KGK_ForwardingInfoNewMap.get(HTDFI.SecchiBaseNo__c).CustomShareMaster__c;
                HTDT_KGK_ForwardingInfoNewMap.put(HTDFI.id,HTDFI); 
            }
        }
        
        // 更新前の納入機器に紐付く、報告書を取得(Associate with T_KGK_ForwardingInfo__c before update, get T_KGK_WorkHistory__c)
        List<T_KGK_WorkHistory__c> HTDWHsOldList = [SELECT id,CustomShareMaster__c from T_KGK_WorkHistory__c where Shukkahanbaijoho__c In :HTDT_KGK_ForwardingInfoOldMap.keySet()];
        if(HTDWHsOldList.size()!=0){
            for(T_KGK_WorkHistory__c HTDWH : HTDWHsOldList){
                HTDT_KGK_WorkHistoryOldMap.put(HTDWH.id,HTDWH); 
            }
        }
        
        // 更新後の納入機器に紐付く、報告書を取得(Associate with updated T_KGK_ForwardingInfo__c, get T_KGK_WorkHistory__c)
        List<T_KGK_WorkHistory__c> HTDWHsNewList = [SELECT id,CustomShareMaster__c,Shukkahanbaijoho__c from T_KGK_WorkHistory__c where Shukkahanbaijoho__c In :HTDT_KGK_ForwardingInfoNewMap.keySet()];
        if(HTDWHsNewList.size()!=0){
            for(T_KGK_WorkHistory__c HTDWH : HTDWHsNewList){
                HTDWH.CustomShareMaster__c = HTDT_KGK_ForwardingInfoNewMap.get(HTDWH.Shukkahanbaijoho__c).CustomShareMaster__c;
                HTDT_KGK_WorkHistoryNewMap.put(HTDWH.id,HTDWH); 
            }
        }

        if(!HTDAccountsOldMap.isEmpty()){
            CL_CustomShareHandler deleteHandlerIC = new CL_CustomShareHandler(T_InquiriesContactform__c.sObjectType,HTDInquiriesContactformOldMap);
            Map<sObject,List<sObject>> deleteResultsIC = deleteHandlerIC.deleteShare();
            CL_CustomShareHandler createHandlerIC = new CL_CustomShareHandler(T_InquiriesContactform__c.sObjectType,HTDInquiriesContactformNewMap);
            Map<sObject,List<sObject>> createResultsIC = createHandlerIC.createShare();
            update HTDICsNewList;


            CL_CustomShareHandler deleteHandlerIB = new CL_CustomShareHandler(T_KGK_IBase__c.sObjectType,HTDT_KGK_IBaseOldMap);
            Map<sObject,List<sObject>> deleteResultsIB = deleteHandlerIB.deleteShare();
            CL_CustomShareHandler createHandlerIB = new CL_CustomShareHandler(T_KGK_IBase__c.sObjectType,HTDT_KGK_IBaseNewMap);
            Map<sObject,List<sObject>> createResultsIB = createHandlerIB.createShare();
            update HTDIBsNewList;            

            CL_CustomShareHandler deleteHandlerFI = new CL_CustomShareHandler(T_KGK_ForwardingInfo__c.sObjectType,HTDT_KGK_ForwardingInfoOldMap);
            Map<sObject,List<sObject>> deleteResultsFI = deleteHandlerFI.deleteShare();
            CL_CustomShareHandler createHandlerFI = new CL_CustomShareHandler(T_KGK_ForwardingInfo__c.sObjectType,HTDT_KGK_ForwardingInfoNewMap);
            Map<sObject,List<sObject>> createResultsFI = createHandlerFI.createShare();
            update HTDFIsNewList;

            CL_CustomShareHandler deleteHandlerWH = new CL_CustomShareHandler(T_KGK_WorkHistory__c.sObjectType,HTDT_KGK_WorkHistoryOldMap);
            Map<sObject,List<sObject>> deleteResultsWH = deleteHandlerWH.deleteShare();
            CL_CustomShareHandler createHandlerWH = new CL_CustomShareHandler(T_KGK_WorkHistory__c.sObjectType,HTDT_KGK_WorkHistoryNewMap);
            Map<sObject,List<sObject>> createResultsWH = createHandlerWH.createShare();
            update HTDWHsNewList;
            
            CL_CustomShareHandler deleteHandler = new CL_CustomShareHandler(Account.sObjectType,HTDAccountsOldMap);
            Map<sObject,List<sObject>> deleteResults = deleteHandler.deleteShare();
            CL_CustomShareHandler createHandler = new CL_CustomShareHandler(Account.sObjectType,HTDAccountsNewMap);
            Map<sObject,List<sObject>> createResults = createHandler.createShare();
            system.debug('deleteResults:\n'+deleteResults+'\ncreateResults\n'+createResults);
        }
    }
    
    //add 2019/04/17 kim
    //JTL会社施設削除可否チェック(Check whether JTL Account can be deleted)
    public void onBeforeDeleteFromJtl(Map<Id,Account> oldMap){
        for(Id accId:oldMap.keySet()){
            if(oldMap.get(accId).RecordTypeId.equals(jtlRecordTypeId[0].Id)){
                //会社情報の受注先が入力されていた場合、SFバッチユーザが削除を実施した際にエラーとする。
                //(If the orderee of Account information is entered, an error occurs when the SF batch user deletes it.)
                if(!String.isEmpty(oldMap.get(accId).Sold_to_party__c)){
                    trigger.oldMap.get(accId).addError(System.Label.AP43_CONST_0007);
                }
                Account ac = [SELECT (SELECT Id FROM Contacts), (SELECT Id FROM Opportunities), Id, Name FROM Account where Id =: accId];
                system.debug('Contacts :'+ac.Contacts);
                system.debug('Contacts size:'+ac.Contacts.size());
                system.debug('Opportunities :'+ac.Opportunities);
                system.debug('Opportunities size:'+ac.Opportunities.size());
                //削除を行った際に会社情報に紐つく顧客担当者が存在していた場合にエラーとする。
                //(It will be an error if there is an Account associated with the Contact when the deletion is performed.)
                system.debug('Contacts :'+oldMap.get(accId).Contacts);
                system.debug('Contacts size:'+oldMap.get(accId).Contacts.size());
                if(ac.Contacts.size() > 0){
                    trigger.oldMap.get(accId).addError(System.Label.AP43_CONST_0008);
                }
                system.debug('Opportunities :'+oldMap.get(accId).Opportunities);
                system.debug('Opportunities size:'+oldMap.get(accId).Opportunities.size());
                //削除を行った際に会社情報に紐つく引合/案件が存在していた場合にエラーとする。
                //(It will be an error if there is an Opportunity associated with the Account when the deletion is performed.)
                if(ac.Opportunities.size() > 0){
                    trigger.oldMap.get(accId).addError(System.Label.AP43_CONST_0009);
                }
            }
        }
    }
    
    /**
     * fieldNamesで指定された項目のどれかが変更されたかを返す(returns whether any of the fields specified in fieldNames have changed)
     * @param sObject compareFrom 比較元のsObject(The sObject to compare from)
     * @param sObject compareTo   比較対象のsObject(SObject to compare)
     * @param List<String> fieldNames   比較する項目(Items to compare)
     */
    private Boolean isFieldsAllEqual(sObject compareFrom,sObject compareTo,List<String> fieldNames){
        boolean result = true;
        for(String field:fieldNames) {
            result &= isFieldEqual(compareFrom,compareTo,field);// fieldNamesのうち、ひとつでも差分があると結果をfalseにする(If any one of fieldNames is different, the result will be false)
            system.debug('field:'+field+'\nisFieldEqual:'+isFieldEqual(compareFrom,compareTo,field)+'\nresult:'+result);
        }
        return result;
    }
    /**
     * fieldNameで指定された項目が変更されたかを返す(returns whether any of the fields specified in fieldNames have changed)
     * @param sObject compareFrom 比較元のsObject(The sObject to compare from)
     * @param sObject compareTo   比較対象のsObject(SObject to compare)
     * @param String fieldName   比較する項目(Items to compare)
     */
    private Boolean isFieldEqual(sObject compareFrom,sObject compareTo,String fieldName){
        return compareFrom.get(fieldName) == compareTo.get(fieldName);
    }
    /**
     * NonDunsCodedeで採番処理(NonDunsCodede numbering process)
     * 採番マスタより現在の番号を取得し採番を行う。(Acquire the current number from the numbering master and perform numbering.)
     * @param List<Account> newAccountList
     * @return エラーメッセージ(Error message)
     */  
    public void setNonDunsCode(List<Account> newAccountList) {
        Decimal currentNo;
        COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // 取引先のレコードタイプ取得(Get record type of account)
        Id accType = comTypeManager.getRecordTypeId( 'Account', 'COWO_CBI' );
        //採番管理レコード取得(Numbering management record acquisition)
        List<M_Sequence__c> seqList = [SELECT CurrentNo__c,SaibanItem__c FROM M_Sequence__c WHERE SaibanItem__c = 'NonDuns番号' FOR Update];
        for(Account newAcc : newAccountList){
            if(newAcc.RecordTypeId == null) { continue; }
            if(newAcc.RecordTypeId.equals(accType) && String.IsBlank(newAcc.CBI_PKG__DunsNbr__c)){
                //採番項目がNonDunsNumberのレコードの有無(Whether there is a record whose numbering item is NonDunsNumber)
                if(seqList.size() == 0){
                    currentNo = 1;
                }else{
                    currentNo = seqList[0].CurrentNo__c;
                }
                if(currentNo > 99999999){
                    newAcc.COWO_NonDunsCode__c.addError(System.Label.AP06_MSG_0001);
                    return;
                }else{
                    newAcc.COWO_NonDunsCode__c = 'Z' + CL_CommonUtils.paddingLeftZero(currentNo.intValue(), 8);
                    currentNo++;
                }
                //採番管理更新(Numbering management update)
                if(seqList.size() == 0){
                    M_Sequence__c newseq = new M_Sequence__c(
                        Name = 'NonDuns番号',
                        CurrentNo__c = currentNo,
                        SaibanItem__c = 'NonDuns番号'
                        );
                    insert newseq;
                    seqList.add(newseq);
                }else{
                    M_Sequence__c updateseq = seqList[0];
                    updateseq.CurrentNo__c = currentNo;
                    update updateseq;
                }
                
            }
            
        }
    }
    /**
     * BeforeUpdateイベントの場合の処理(Processing for BeforeUpdate event)
     * 取引先名の変更により、旧社名を更新(Update the COWO_OldAccountName__c when account name is changed)
     * @param Map<Id, Account> newMap, Map<Id, Account> oldMap
     */
    public void UpdateOldAccountName(Map<Id, Account> newMap, Map<Id, Account> oldMap ){
        for(Account newAcc : newMap.values()){
            Account oldAcc = oldMap.get(newAcc.Id);
            // レコタイがCBI、取引先名に変更がある場合(Recordtype is CBI and there is a change in Account name)
            if(newAcc.RecordTypeId.equals(cbiRecordTypeId[0].Id) && newAcc.Name != oldAcc.Name){
                newAcc.COWO_OldAccountName__c = oldAcc.Name;
            }
        }        
    }
}