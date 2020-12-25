/********************************************************************************
 * クラス名 ： CL_OpportunityTriggerHandler
 * 概　　要 ： 案件のトリガハンドラークラス
 * 作 成 日 ： 2016/01/29 Fujii
 * 更 新 日 ： 2017/10/19 Handa
 * 更新履歴
   ・2017/10/19_Handa HHS_課題No119(やるぞフラグ改修)_oppHHSDefalt
   ・kim 2019/04/26 LEX対応 顧客氏名の役割生成
   ・2020/03/09 sakamoto DX対応商談番号採番追加

 ********************************************************************************/
public without sharing class CL_OpportunityTriggerHandler {

    //多重起動防止フラグ
    public static boolean firstRun = true;
    
    /**
     * コンストラクタ
     **/
    public CL_OpportunityTriggerHandler(){}

    // COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();

    /*
    * 受権票番号採番処理(医用・アジア)
    * @param List<Opportunity> oldObjects oldTriggerの値
    * @param List<Opportunity> newObjects newTriggerの値
    */
    public void authorizedNoSibanAsia(List<Opportunity> oldObjects, List<Opportunity> newObjects){
        String saibankomoku = '受権票番号';
        Decimal currentNo;
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> newMap = new Map<Id, Opportunity>();

        List<Opportunity> saibanOppList = new List<Opportunity>();    // 採番対象案件リスト
        List<M_Sequence__c> targetUpdate = new List<M_Sequence__c>();   // 新規作成(更新)採番リスト

        if(oldObjects != null){
            for(Opportunity o : oldObjects){
                oldMap.put(o.Id, o);
            }
        }

        for(Opportunity o : newObjects){
            if( !oldMap.get(o.Id).authorizedFlgToApproval__c && o.authorizedFlgToApproval__c){
                saibanOppList.add(o);
            }
        }

        //採番管理レコード取得
        List<M_Sequence__c> seqList = [SELECT CurrentNo__c,SaibanItem__c FROM M_Sequence__c WHERE SaibanItem__c = '受権票番号'];

        for(Opportunity o : saibanOppList){
            //採番項目がPO番号のレコードの有無
            if(seqList.size() == 0){
                currentNo = 1;
            }else{
                currentNo = seqList[0].CurrentNo__c;
            }

            if(currentNo > 999999){
                o.authorizedNo__c.addError(System.Label.AP06_MSG_0001);
                return;
            }else{
                o.authorizedNo__c = 'J' + '-' + CL_CommonUtils.paddingLeftZero(currentNo.intValue(), 6);
                currentNo++;
            }

            //採番管理更新
            if(seqList.size() == 0){
                M_Sequence__c newseq = new M_Sequence__c(
                        Name = '受権票番号',
                        CurrentNo__c = currentNo,
                        SaibanItem__c = saibankomoku
                        );
                targetUpdate.add(newseq);
                if(targetUpdate.size() > 0){
                    insert targetUpdate;
                }
            }else{
                M_Sequence__c updateseq = seqList[0];
                updateseq.CurrentNo__c = currentNo;
                targetUpdate.add(updateseq);
                if(targetUpdate.size() > 0){
                    update targetUpdate;
                }
            }
        }
    }

    /*
    * PO番号採番処理(医用・アジア)
    * @param List<Opportunity> oldObjects oldTriggerの値
    * @param List<Opportunity> newObjects newTriggerの値
    */
    public void poNumberSibanAsia(List<Opportunity> oldObjects, List<Opportunity> newObjects){
        String saibankomoku = 'PO番号';
        Decimal currentNo;
        String YYYY = System.DateTime.now().format('YYYY');
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> newMap = new Map<Id, Opportunity>();

        List<Opportunity> saibanOppList = new List<Opportunity>();    // 採番対象案件リスト
        List<M_Sequence__c> targetUpdate = new List<M_Sequence__c>();   // 新規作成(更新)採番リスト

        if(oldObjects != null){
            for(Opportunity o : oldObjects){
                oldMap.put(o.Id, o);
            }
        }

        for(Opportunity o : newObjects){
            if( !oldMap.get(o.Id).POhatsubanflg__c && o.POhatsubanflg__c){
                saibanOppList.add(o);
            }
        }

        //採番管理レコード取得
        List<M_Sequence__c> seqList = [SELECT CurrentNo__c,LastOutputMonth__c,SaibanItem__c FROM M_Sequence__c WHERE SaibanItem__c = 'PO番号'];

        for(Opportunity o : saibanOppList){
            //採番項目がPO番号のレコードの有無
            if(seqList.size() == 0){
                currentNo = 1;
            }else{
                //年初採番チェック
                if(seqList[0].LastOutputMonth__c == YYYY){ // ★項目修正対応
                    currentNo = seqList[0].CurrentNo__c;
                }else{
                    currentNo = 1;
                }
            }

            if(currentNo > 99999){
                o.PONo__c.addError(System.Label.AP06_MSG_0001);
                return;
            }else{
                o.PONo__c = 'A' + '-' + YYYY +
                        CL_CommonUtils.paddingLeftZero(currentNo.intValue(), 5);
                currentNo++;
            }

            //採番管理更新
            if(seqList.size() == 0){
                M_Sequence__c newseq = new M_Sequence__c(
                        Name = 'PO採番用',
                        CurrentNo__c = currentNo,
                        LastOutputMonth__c = YYYY,
                        SaibanItem__c = saibankomoku
                        );
                targetUpdate.add(newseq);
                if(targetUpdate.size() > 0){
                    insert targetUpdate;
                }
            }else{
                M_Sequence__c updateseq = seqList[0];
                updateseq.CurrentNo__c = currentNo;
                updateseq.LastOutputMonth__c = YYYY;
                targetUpdate.add(updateseq);
                if(targetUpdate.size() > 0){
                    update targetUpdate;
                }
            }
        }
    }

    /*
    * 案件番号採番処理(医用・アジア)
    * @param List<Opportunity> oldObjects oldTriggerの値
    * @param List<Opportunity> newObjects newTriggerの値
    * @parm Boolean isInsert 登録処理判定
    */
    public void oppNumberSaibanAsia(List<Opportunity> oldObjects, List<Opportunity> newObjects, boolean isInsert){
        String saibankomoku = System.Label.AP06_CONST_0001;
        Decimal currentNo;
        String YYMM = System.DateTime.now().format(System.Label.AP06_CONST_0002);

        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> newMap = new Map<Id, Opportunity>();

        List<Opportunity> saibanOppList = new List<Opportunity>();    // 採番対象案件リスト

        if(oldObjects != null){
            for(Opportunity o : oldObjects){
                oldMap.put(o.Id, o);
            }
        }
        Set<Id> AgencyIdList = new Set<Id>();    // 代理店Idリスト
        for(Opportunity o : newObjects){
            if(isInsert && !o.LeadFlg__c){
                //★リード以外からの登録の場合、会社名.代理店コードのnull判定を行う
                AgencyIdList.add(o.Agency__c);
            }
        }

        Map<Id, Account> AccountMap = new Map<Id, Account>([SELECT Id, AgencyCode__c FROM Account where id in :AgencyIdList]);

        // 採番で使用する代理店コードリスト
        List<String> AgencyCodeList = new List<String>();

        for(Opportunity o : newObjects){
                if(!isInsert && oldMap.get(o.Id).OpportunityNo__c != null ){
                    continue;
                }else{
                    AgencyCodeList.add(o.AgencyCode__c);
                    saibanOppList.add(o);
                }
        }

        //採番管理レコード取得
        List<M_Sequence__c> seqList = [SELECT CurrentNo__c,LastOutputMonth__c, AgencyNo__c FROM M_Sequence__c WHERE AgencyNo__c = :AgencyCodeList AND SaibanItem__c = :System.Label.AP21_CONST_0001 FOR Update];

        //職制_採番Map(Key_代理店コード(代理店No), Value_採番OBJ)
        Map<String, M_Sequence__c> seqMap = new Map<String, M_Sequence__c>();
        Map<String, M_Sequence__c> updateSeqMap = new Map<String, M_Sequence__c>();

        for(M_Sequence__c s : seqList){
            seqMap.put(s.AgencyNo__c, s);
        }
        for(Opportunity o : saibanOppList){

            //取得した代理店コードでの採番有無チェック
            if(seqMap.get(o.AgencyCode__c) == null){
                currentNo = 1;
            }else{
                //月初採番チェック
                if(seqMap.get(o.AgencyCode__c).LastOutputMonth__c == YYMM){
                    currentNo = seqMap.get(o.AgencyCode__c).CurrentNo__c;
                }else{
                    currentNo = 1;
                }
            }

            if(currentNo > 99999){
                o.OpportunityNo__c.addError(System.Label.AP06_MSG_0001);
                return;
            }else{
                o.OpportunityNo__c = o.AgencyCode__c + '-' + YYMM +
                        CL_CommonUtils.paddingLeftZero(currentNo.intValue(), 5);
                currentNo++;
            }

            //採番管理更新
            if(seqMap.get(o.AgencyCode__c) == null){
                M_Sequence__c newseq = new M_Sequence__c(
                        Name = o.AgencyCode__c,
                        CurrentNo__c = currentNo,
                        LastOutputMonth__c = YYMM,
                        SaibanItem__c = saibankomoku,
                        AgencyNo__c = o.AgencyCode__c
                        );
                seqMap.put(o.AgencyCode__c, newseq);
                updateSeqMap.put(o.AgencyCode__c, newseq);
            }else{
                M_Sequence__c updateseq = seqMap.get(o.AgencyCode__c);
                updateseq.CurrentNo__c = currentNo;
                updateseq.LastOutputMonth__c = YYMM;
                seqMap.put(o.AgencyCode__c, updateseq);
                updateSeqMap.put(o.AgencyCode__c, updateseq);
            }
        }

        List<M_Sequence__c> iSaibanList = new List<M_Sequence__c>();    // INSERT 用採番リスト
        List<M_Sequence__c> uSaibanList = new List<M_Sequence__c>();    // UPDATE 用採番リスト

        for (String sKey : updateSeqMap.keySet()) {
            M_Sequence__c temp = updateSeqMap.get(sKey);
            if(temp.Id == null){
                iSaibanList.add(temp);
            }else{
                uSaibanList.add(temp);
            }
        }

        if(iSaibanList.size() > 0){
            insert iSaibanList;
        }
        if(uSaibanList.size() > 0){
            update uSaibanList;
        }
    }

    /*
    * 案件番号採番処理
    * @param List<Opportunity> oldObjects oldTriggerの値
    * @param List<Opportunity> newObjects newTriggerの値
    * @parm Boolean isInsert 登録処理判定
    */
    public void oppNumberSaiban(List<Opportunity> oldObjects, List<Opportunity> newObjects, boolean isInsert){
        String saibankomoku = System.Label.AP06_CONST_0001;
        String shokusei;
        Decimal currentNo;
        String YYMM = System.DateTime.now().format(System.Label.AP06_CONST_0002);

        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> newMap = new Map<Id, Opportunity>();

        List<Opportunity> saibanOppList = new List<Opportunity>();    // 採番対象案件リスト

        List<Id> userIdList = new List<Id>();    // ユーザIdリスト

        if(oldObjects != null){
            for(Opportunity o : oldObjects){
                oldMap.put(o.Id, o);
            }
        }
        Set<Id> userRoleIdList = new Set<Id>();    // ロールIdリスト
        for(Opportunity o : newObjects){
            if(isInsert && !o.LeadFlg__c){
                //リード以外からの登録の場合、職制(担当者)の整合性チェックを行う
                userRoleIdList.add(o.ownerId);
            }
        }


        Map<Id, User> UserMap = new Map<Id, User>([SELECT Id, UserRole.developerName FROM User where id in :userRoleIdList]);

        // 採番で使用する職制リスト
        List<String> shokuseiList = new List<String>();

        for(Opportunity o : newObjects){

            /*	★★2019/12/02 Sprint2-1テスト実施のため一時的にコメントアウト★★
            if(o.OwnerShokusei__c == null && !o.LeadFlg__c){
                o.OwnerShokusei__c.addError(System.Label.AP06_MSG_0016);
                continue;
            }
            if(o.Shokusei__c == null){
                o.Shokusei__c.addError(System.Label.AP06_MSG_0017);
                continue;
            }
            if(isInsert && !o.LeadFlg__c){
                //リード以外からの登録の場合、職制(担当者)の整合性チェックを行う
                if(!o.OwnerShokusei__c.equals(UserMap.get(o.ownerId).UserRole.DeveloperName)){
                     o.OwnerShokusei__c.addError(System.Label.AP06_MSG_0018_PRE + UserMap.get(o.ownerId).UserRole.DeveloperName + System.Label.AP06_MSG_0018_POST );
                    continue;
                }
            }
			*/


            if(!isInsert && oldMap.get(o.Id).OpportunityNo__c != null){
                continue;

            }else{
                if(o.LeadFlg__c){
                    o.OwnerShokusei__c = o.Shokusei__c;
                    o.LeadFlg__c = false;
                }
                shokuseiList.add(o.Shokusei__c);
                saibanOppList.add(o);
            }
        }

        //採番管理レコード取得
        List<M_Sequence__c> seqList = [SELECT  CurrentNo__c,LastOutputMonth__c, RoleNo__c FROM M_Sequence__c WHERE RoleNo__c = :shokuseiList AND SaibanItem__c = :System.Label.AP21_CONST_0001 FOR Update];

        //職制_採番Map(Key_職制(ロールNo), Value_採番OBJ)
        Map<String, M_Sequence__c> seqMap = new Map<String, M_Sequence__c>();
        Map<String, M_Sequence__c> updateSeqMap = new Map<String, M_Sequence__c>();

        for(M_Sequence__c s : seqList){
            seqMap.put(s.RoleNo__c, s);
        }
        for(Opportunity o : saibanOppList){

            //取得した職制での採番有無チェック
            if(seqMap.get(o.Shokusei__c) == null){
                currentNo = 1;
            }else{
                //月初採番チェック
                if(seqMap.get(o.Shokusei__c).LastOutputMonth__c == YYMM){
                    currentNo = seqMap.get(o.Shokusei__c).CurrentNo__c;
                }else{
                    currentNo = 1;
                }
            }

            if(currentNo > 9999){
                o.OpportunityNo__c.addError(System.Label.AP06_MSG_0001);
                return;
            }else{
                o.OpportunityNo__c = o.Shokusei__c + '-' + YYMM +
                        CL_CommonUtils.paddingLeftZero(currentNo.intValue(), 4);
                currentNo++;
            }

            //採番管理更新
            if(seqMap.get(o.Shokusei__c) == null){
                M_Sequence__c newseq = new M_Sequence__c(
                        Name = o.Shokusei__c,
                        CurrentNo__c = currentNo,
                        LastOutputMonth__c = YYMM,
                        SaibanItem__c = saibankomoku,
                        RoleNo__c = o.Shokusei__c
                        );
                seqMap.put(o.Shokusei__c, newseq);
                updateSeqMap.put(o.Shokusei__c, newseq);
            }else{
                M_Sequence__c updateseq = seqMap.get(o.Shokusei__c);
                updateseq.CurrentNo__c = currentNo;
                updateseq.LastOutputMonth__c = YYMM;
                seqMap.put(o.Shokusei__c, updateseq);
                updateSeqMap.put(o.Shokusei__c, updateseq);
            }
        }

        List<M_Sequence__c> iSaibanList = new List<M_Sequence__c>();    // INSERT 用採番リスト
        List<M_Sequence__c> uSaibanList = new List<M_Sequence__c>();    // UPDATE 用採番リスト

        for (String sKey : updateSeqMap.keySet()) {
            M_Sequence__c temp = updateSeqMap.get(sKey);
            if(temp.Id == null){
                iSaibanList.add(temp);
            }else{
                uSaibanList.add(temp);
            }
        }

        if(iSaibanList.size() > 0){
            insert iSaibanList;
        }
        if(uSaibanList.size() > 0){
            update uSaibanList;
        }
    }

    /*
    * 職制更新処理
    * @param List<Opportunity> oldbjects oldTriggerの値
    * @param List<Opportunity> newObjects newTriggerの値
    */
    public void updateShinShokusei(List<Opportunity> oldbjects, List<Opportunity> newObjects){
        /* ★★2020/09/25 ガバナ制限対応のため一時にコメントアウト★★
         *
        Integer len = oldbjects.size();
        Opportunity oppNew;
        Opportunity oppOld;
        List<User> uList = [Select u.Profile.Name, u.ProfileId From User u where id = :Userinfo.getUserId()];
        String userProfileName = uList[0].Profile.Name;
        Set<String> profileNameSet = new Set<String>(System.Label.AP35_LBL_0038.split(','));
        for (Integer i=0; i<len; i++) {
            oppNew = newObjects[i];
            oppOld = oldbjects[i];*/


            /*	★★2019/12/02 Sprint2-1テスト実施のため一時的にコメントアウト★★
             * 
            if(oppNew.OwnerShokusei__c != oppOld.OwnerShokusei__c){
                if(!profileNameSet.contains(userProfileName)) {
                    oppNew.OwnerShokusei__c.addError(System.Label.AP35_MSG_0026);
                }

            } if(oppNew.Shokusei__c != oppOld.Shokusei__c){
                if(!profileNameSet.contains(userProfileName)) {
                    oppNew.Shokusei__c.addError(System.Label.AP35_MSG_0027);
                }

            }else if (!String.isBlank(oppNew.ShinShokusei__c) && String.isBlank(oppOld.ShinShokusei__c)) {
                oppNew.Shokusei__c = oppNew.ShinShokusei__c;
                oppNew.OwnerShokusei__c = oppNew.ShinShokusei__c;
                oppNew.ShinShokusei__c = null;
            }
			*/

        // }
    }

    /**
     * 2017/07/12 toshima add
     * 案件の職制更新時、配下予実の職制の値を更新後の案件の職制の値で更新する
     */
    public void DXupdateBudgetShokusei(map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap){
        Map<Id,String> Id_ShokuseiMap = new Map<Id,String>();
        // 職制変更された案件、変更前の職制、変更後の職制の値取得
        for(Id objId:oldMap.keySet()){
            if(oldMap.get(objId).SAWO_AdminSystem__c != newMap.get(objId).SAWO_AdminSystem__c) Id_ShokuseiMap.put(objId,newMap.get(objId).SAWO_AdminSystem__c);
        }
        // 職制変更された案件に紐づく予実を取得
        if(!Id_ShokuseiMap.isEmpty() ){
            // 取得条件:Opportunity__c in (変更された案件のkeyset) である
            List<T_BudgetResults__c> budgets = [select id,Shokusei__c,Opportunity__c,HeaderBudgetResults__c from T_BudgetResults__c where Opportunity__c in :Id_ShokuseiMap.keySet() and HeaderBudgetResults__c = null];
            for(T_BudgetResults__c budget: budgets){
                budget.Shokusei__c = newMap.get(budget.Opportunity__c).SAWO_AdminSystem__c;
            }
            update budgets;
        }
    }
    /**
     * 案件の職制更新時、配下予実の職制の値を更新後の案件の職制の値で更新する
     */
    public void nonDXupdateBudgetShokusei(map<Id,Opportunity> oldMap,Map<Id,Opportunity> newMap){
        Map<Id,String> Id_ShokuseiMap = new Map<Id,String>();
        // 職制変更された案件、変更前の職制、変更後の職制の値取得
        for(Id objId:oldMap.keySet()){
            if(oldMap.get(objId).Shokusei__c != newMap.get(objId).Shokusei__c) Id_ShokuseiMap.put(objId,newMap.get(objId).Shokusei__c);
        }
        // 職制変更された案件に紐づく予実を取得
        if(!Id_ShokuseiMap.isEmpty() ){
            // 取得条件:Opportunity__c in (変更された案件のkeyset) である
            List<T_BudgetResults__c> budgets = [select id,Shokusei__c,Opportunity__c,HeaderBudgetResults__c from T_BudgetResults__c where Opportunity__c in :Id_ShokuseiMap.keySet() and HeaderBudgetResults__c = null];
            for(T_BudgetResults__c budget: budgets){
                budget.Shokusei__c = newMap.get(budget.Opportunity__c).Shokusei__c;
            }
            update budgets;
        }
    }
    /*
    * 本体台数更新処理
    * @param List<Opportunity> newObjects newTriggerの値
    */
    public void updateHontaiQuantity(List<Opportunity> newObjects,String profileName){
        // Map<Id, RecordType> rtMap = new Map<Id, RecordType>([Select Id,DeveloperName from RecordType  where SobjectType = 'Opportunity' and DeveloperName in ('PublicOffice', 'Private', 'HHS')]);
        // COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // Id oppDXRec = comTypeManager.getRecordTypeId( 'Opportunity', 'SAWO_DX_Opportunity' );
        // Id oppHHSRec = comTypeManager.getRecordTypeId( 'Opportunity', 'HHS' );
        // Id oppPublicOfficeRec = comTypeManager.getRecordTypeId( 'Opportunity', 'PublicOffice' );
        // Id oppPrivateRec = comTypeManager.getRecordTypeId( 'Opportunity', 'Private' );
        Id oppDXRec = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId();
        Id oppHHSRec = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HHS').getRecordTypeId();
        Id oppPublicOfficeRec = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PublicOffice').getRecordTypeId();
        Id oppPrivateRec = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Private').getRecordTypeId();

        // String profileId = UserInfo.getProfileId();

        List<String> dxHontaiQuantityProfs = System.Label.SAWO_CON_HontaiQuantity.split(',');
        // Map<Id, Profile> dxHontaiQuantityProfsMap = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE Name IN :dxHontaiQuantityProfs]);
        
        for (Opportunity opp : newObjects) {
            // if(opp.recordTypeId == oppDXRec && dxHontaiQuantityProfsMap.keySet().contains(profileId)) {
            if(opp.recordTypeId == oppDXRec && dxHontaiQuantityProfs.contains(profileName)) {
                opp.HontaiQuantity__c = opp.Quantity__c;
            } else {
                if (opp.recordTypeId == oppDXRec 
                    || opp.recordTypeId == oppPublicOfficeRec
                    || opp.recordTypeId == oppPrivateRec) {
                    opp.HontaiQuantity__c = opp.Quantity__c;
                }
            }
        }
        
    }

    /*
    * 他決後続処理
    * @param List<Opportunity> oldObjects oldTriggerの値
    * @param List<Opportunity> newObjects newTriggerの値
    * @parm Boolean isInsert 登録処理判定
    */
    public void TaketsuKozoku(List<Opportunity> oldObjects, List<Opportunity> newObjects, Boolean isInsert){

        List<String> nOppIdList = new List<String>();    // NEW案件Idリスト
        List<Id> oppConList = new List<Id>();    // 顧客氏名リスト
        List<Id> oppOwnerList = new List<Id>();    // 所有者Idリスト
        List<Id> oppAccountList = new List<Id>();    // 会社名Idリスト
        List<Id> oppAgencyList = new List<Id>();    // 代理店Idリスト

        boolean checkFlag = true;
        // NEW案件Map(Key_Id,Value_案件OBJ)
        Map<Id, Opportunity> nOppMap = new Map<Id, Opportunity>();
        for(Opportunity n : newObjects){
            if(!(n.StageName == '06Lost' && n.SAWO_Order_Reason__c.contains('Option'))){
                continue;
            }
            checkFlag = false;
            nOppIdList.add(n.Id);
            nOppMap.put(n.Id, n);

            oppConList.add(n.Contact__c);
            oppOwnerList.add(n.OwnerId);
            oppAccountList.add(n.AccountId);
            oppAgencyList.add(n.Agency__c);
        }

        if(checkFlag){
            return;
        }

        // OLD案件Idリスト
        List<String> oOppIdList = new List<String>();
        // OLD案件Map(Key_Id,Value_案件OBJ)
        Map<Id, Opportunity> oOppMap = new Map<Id, Opportunity>();

        // UPDATE 時のみ
        if(!isInsert){

            for(Opportunity o : oldObjects){
                oOppIdList.add(o.Id);
                oOppMap.put(o.Id, o);
            }
            // INSERT 時はold情報が存在しない
        }else{
            oOppMap = nOppMap.clone();
        }

        // INSERT 用既納品 List
        List<Asset> inesrtAssetList = new List<Asset>();

        // 他決レコードタイプId取得
        // Id otherRTId = [SELECT Id FROM RecordType WHERE sObjectType = :'Asset' AND DeveloperName = :'Other'].Id;
        Id otherRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Other').getRecordTypeId();

        // 案件_案件製品Map(Key_案件Id,Value_案件製品Id(案件製品が複数存在する場合、案件製品Idは上書き))
        Map<Id, Id> oppIdMap = new Map<Id, Id>();

        // 顧客氏名情報Map作成(Key_Id、Value_顧客氏名OBJ)
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id,
                                                            UnitName1__c,
                                                            UnitName2__c,
                                                            UnitName3__c,
                                                            Name,
                                                            Phone,
                                                            Fax,
                                                            Email,
                                                            MailingState,       //add 170519
                                                            MailingPostalCode,  //add 170519
                                                            MailingCity,        //add 170519
                                                            MailingStreet,      //add 170519
                                                            Title               //add 170519
                                                            FROM Contact
                                                            WHERE Id = :oppConList
                                                            ]);

        // 所有者情報Map作成(Key_Id、Value_所有者(ユーザOBJ))
        Map<Id, User> ownerMap = new Map<Id, User>([SELECT Id,
                                                    Department,
                                                    Name
                                                    FROM User
                                                    WHERE Id = :oppOwnerList
                                                    ]);

        // 会社情報Map作成(Key_Id、Value_会社名OBJ)
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Name,
                                                            BillingAddress
                                                            FROM Account
                                                            WHERE Id = :oppAccountList
                                                            ]);

        // 代理店Map作成(Key_Id、Value_会社名OBJ)
        Map<Id, Account> agencyMap = new Map<Id, Account>([SELECT Name
                                                           FROM Account
                                                           WHERE Id = :oppAgencyList
                                                           ]);
        // 他決リスト作成
        for(Opportunity n : newObjects){
            // 新規作成時で失注フェーズ，受他決理由が他決、または、失注以外から失注に変更され、かつ受他決理由が他決の場合、または、フェーズが失注、かつ受他決理由が他決以外から他決に変更された場合
            if(isInsert && n.StageName == '06Lost' && n.SAWO_Order_Reason__c.contains('Option')
                    || (oOppMap.get(n.Id).StageName != '06Lost' && n.StageName == '06Lost' && n.SAWO_Order_Reason__c.contains('Option')
                        || n.StageName == '06Lost' && ! oOppMap.get(n.Id).SAWO_Order_Reason__c.contains('Option') && n.SAWO_Order_Reason__c.contains('Option'))){
                Asset insertAsset = new Asset();

                String CompetitionMaker = '';
                if(n.CompetitionMaker__c != null){
                    CompetitionMaker = n.CompetitionMaker__c;
                }
                String CompetitionModels = '';
                if(n.CompetitionModels__c != null){
                    CompetitionModels = n.CompetitionModels__c;
                }
                insertAsset.Name = CompetitionMaker + ' ' + CompetitionModels;

                // ★競合メーカー名、型式ともに blank の場合、'他決リスト'を設定
                if(insertAsset.Name == ' '){
                    insertAsset.Name = '他決リスト';
                }
                insertAsset.recordTypeId = otherRTId;
                insertAsset.AccountId = n.AccountId;
                insertAsset.ContactId = n.Contact__c;

                //            insertAsset.ProductId__c = ;    // ★「製品ID」確認中
                //            insertAsset.ProductGun__c = ;    // ★「製品群」確認中
                insertAsset.ProductKeishikiName__c = n.CompetitionModels__c;    // ★「製品形式名」確認中
                insertAsset.ShokaiSuetsukeKanryoDate__c = n.CloseDate;

                if(accountMap.get(n.AccountId) != null){
                    insertAsset.CommonCustomerAccountName__c = accountMap.get(n.AccountId).Name;
                    insertAsset.CustomerNameSite1__c = accountMap.get(n.AccountId).Name;
                    if(accountMap.get(n.AccountId).BillingAddress != null){    // ★ 住所について、確認中
                        //                        insertAsset.PostalCode__c = accountMap.get(n.AccountId).BillingAddress.getPostalCode();
                        insertAsset.State__c = accountMap.get(n.AccountId).BillingAddress.getState();
                        //                        insertAsset.City__c = accountMap.get(n.AccountId).BillingAddress.getCity();
                        //                        insertAsset.Street__c = accountMap.get(n.AccountId).BillingAddress.getStreet();
                    }
                }
                if(contactMap.get(n.Contact__c) != null){
                    //insertAsset.CommonCustomerOfficeName__c = contactMap.get(n.Contact__c).UnitName1__c;

                    //insertAsset.CustomerTantoshaDepartment__c = contactMap.get(n.Contact__c).UnitName1__c;
                    insertAsset.CustomerTantoshaDepartment2__c = contactMap.get(n.Contact__c).UnitName2__c;
                    insertAsset.CustomerTantoshaDepartment3__c = contactMap.get(n.Contact__c).UnitName3__c;
                    insertAsset.CustomerTantosha__c = contactMap.get(n.Contact__c).Name;
                    //addS 文字切り対策 170519
                    if(contactMap.get(n.Contact__c).Name.length() > 20){
                        insertAsset.CustomerTantosha__c = contactMap.get(n.Contact__c).Name.substring(0,20);
                    }else{
                        insertAsset.CustomerTantosha__c = contactMap.get(n.Contact__c).Name;
                    }
                    //addE
                    insertAsset.CustomerTantoshaTel__c = contactMap.get(n.Contact__c).Phone;
                    insertAsset.CustomerTantoshaFax__c = contactMap.get(n.Contact__c).Fax;
                    insertAsset.CustomerTantoshaMail__c = contactMap.get(n.Contact__c).Email;
                    //addS 170519
                    insertAsset.State3__c = contactMap.get(n.Contact__c).MailingState;
                    insertAsset.PostalCode__c = contactMap.get(n.Contact__c).MailingPostalCode;
                    insertAsset.City__c = contactMap.get(n.Contact__c).MailingCity;
                    insertAsset.Street__c = contactMap.get(n.Contact__c).MailingStreet;
                    insertAsset.CustomerTantoshaTitle__c = contactMap.get(n.Contact__c).Title;
                    //addE 170519
                }
                if(ownerMap.get(n.OwnerId) != null){
                    insertAsset.EigyoTantoBuName__c = ownerMap.get(n.OwnerId).Department;
                    insertAsset.EigyoTantoShaName__c = ownerMap.get(n.OwnerId).Name;
                }

                insertAsset.Quantity = n.Quantity__c;
                insertAsset.ProductMaker__c = n.CompetitionMaker__c;
                if(AgencyMap.get(n.Agency__c) != null){
                    insertAsset.AgencyName__c = AgencyMap.get(n.Agency__c).Name;
                }
                insertAsset.HikiaiNyushuKeiro__c = n.LeadSource;
                insertAsset.IndustryCategory1__c = n.Area1__c;
                insertAsset.IndustryCategory2__c = n.Area2__c;
                insertAsset.IndustryCategory3__c = n.Area3__c;
                insertAsset.HontaiAmount__c = String.valueOf(n.CompetitionPrice__c);
                insertAsset.AllAmount__c = String.valueOf(n.CompetitionPrice__c);
                insertAsset.MainAccessory_upper05M__c = n.CompetitionConstitution__c;
                insertAsset.BudgetHimoku__c = n.BudgetExpense__c;
                insertAsset.Shinki_Zosetsu_Koshin__c = n.SalesChannel__c;
                insertAsset.DeliveredItemKeishikiPurchaseYear__c = n.UpdateDeviceType__c;
                insertAsset.Demonstration__c = n.Demonstration__c;
                insertAsset.DocumentCreateOnly__c = n.DocumetCreateOnly__c;
                insertAsset.MeasurementUnexecuted__c = n.MeasurementUnexecuted__c;
                insertAsset.CompetitorMakerInfo__c = n.CompetitionDetail__c;
                insertAsset.LostReason1__c = n.LostReason__c;
                insertAsset.LostReason2__c = n.LostReason2__c;
                insertAsset.LostReason3__c = n.LostReason3__c;
                insertAsset.SpecialNotes__c = n.Remarks__c;
                //            insertAsset.HitachiKeishiki__c = ;    // ★「日立形式」確認中
                insertAsset.HHTTeishutsuChiM__c = String.valueOf(n.EstimatedAmount__c);
                insertAsset.HHTMCM__c = String.valueOf(n.MC__c);

                insertAsset.OpportunityNoLink__c = n.Id;     //作成元案件

                inesrtAssetList.add(insertAsset);
            }
        }
        if(inesrtAssetList.size() > 0){
            insert inesrtAssetList;
        }

    }

    /**
     * AssetFollowTaishogai 既納品フォロー対象外
     * @param List<Opportunity> newObjects
     * @return
     */
    public void AssetFollowTaishogai(List<Opportunity> newObjects){
        //元納品商品の更新は別トリガで行っている。

        // フォロー対象外既納品Idリスト
        List<String> oppIdList = new List<String>();

        // チェック用Map
        Map<ID, ID> CheckMap = new Map<ID, ID>();

        // エラーMap
        Map<ID, ID> ErrorMap = new Map<ID, ID>();

        for(Opportunity n : newObjects){
            if(n.AssetName__c != null && n.StageName != System.Label.AP06_CONST_0004){
                if(CheckMap.containsKey(n.AssetName__c)){
                    //制約エラー
                    n.AssetName__c.addError(System.Label.AP15_MSG_0001);
                    ErrorMap.put(n.Id, n.Id);
                    continue;
                }
                oppIdList.add(n.AssetName__c);
                CheckMap.put(n.AssetName__c, n.Id);
            }
        }
        if(oppIdList.size() > 0){
            // 既納品の項目取得
            List<Asset> assetList = [SELECT Id, OpportunityNo__c FROM Asset WHERE Id =: oppIdList];

            Map<ID, Asset> AssetMap = new Map<ID, Asset>();
            for(Asset a : assetList){
                AssetMap.put(a.id, a);
            }
            List<Asset> updateAsset = new List<Asset>();
            for(Opportunity n : newObjects){
                if(n.AssetName__c != null && n.StageName != System.Label.AP06_CONST_0004){
                    Asset a = AssetMap.get(n.AssetName__c);
                    if(ErrorMap.containsKey(n.Id)){
                        continue;
                    }
                    if(a.OpportunityNo__c != null && a.OpportunityNo__c != n.Id){
                        n.AssetName__c.addError(System.Label.AP15_MSG_0001);
                        continue;
                    }
                    a.TriggerFlg__c = TRUE;
                    a.FollowTaisyoGai__c = TRUE;
                    a.OpportunityNo__c = n.Id;
                    updateAsset.add(a);
                }
            }
            // フォロー対象外フラグをONにする

            if(updateAsset.size() > 0){
                update updateAsset;
            }
        }
    }

    /*
    * 消滅後続処理
    * @param List<Opportunity> oldObjects oldTriggerの値
    * @param List<Opportunity> newObjects newTriggerの値
    * @parm Boolean isDelete 削除処理判定
    */
    public void ShometsugoKozoku(List<Opportunity> oldObjects, List<Opportunity> newObjects, Boolean isDelete){

        // NEW案件Map(Key_Id,Value_案件OBJ)
        Map<Id, Opportunity> nOppMap = new Map<Id, Opportunity>();
        if(!isDelete){
            for(Opportunity n : newObjects){
                //            nOppIdList.add(n.Id);
                nOppMap.put(n.Id, n);
            }
        }

        // OLD案件Idリスト
        List<String> oOppIdList = new List<String>();
        // OLD案件Map(Key_Id,Value_案件OBJ)
        Map<Id, Opportunity> oOppMap = new Map<Id, Opportunity>();

        for(Opportunity o : oldObjects){
            oOppIdList.add(o.Id);
            oOppMap.put(o.Id, o);
        }

        // 更新対象既納品Idリスト
        List<Id> oppIdList = new List<Id>();
        for(Opportunity o : oldObjects){

            // 案件 DELETE 時
            if(isDelete){
                if(o.AssetName__c != null){
                    oppIdList.add(o.AssetName__c);

                }
                // 案件の作成元既納品変更
            }else if(o.AssetName__c != null && ((o.AssetName__c != nOppMap.get(o.Id).AssetName__c) || nOppMap.get(o.Id).StageName == '消滅')){
                oppIdList.add(o.AssetName__c);
            }
        }

        // 更新対象既納品リスト
        List<Asset> updateAssetList = new List<Asset>();

        for(Id o : oppIdList){
            Asset updateAsset = new Asset();
            updateAsset.Id = o;
            updateAsset.FollowTaisyoGai__c = FALSE;

            updateAssetList.add(updateAsset);
        }

        if(updateAssetList.size() > 0){
            update updateAssetList;
        }
    }

    /*
    * SAPマスタチェック
    * @param List<Opportunity> newObjects newTriggerの値
    */
    public void SAPMasterCheck(List<Opportunity> newObjects){

        // COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // 商談のレコードタイプ取得
        Id recId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId();

        // 案件IdList
        List<Id> chkOppIdList = new List<Id>();

        // SAPマスタ検索条件
        Set<String> searcSapMaster = new Set<String>();
        Set<String> searcSoshikiCd = new Set<String>();

        //案件製品チェック結果まとめ用
        Map<Id,Opportunity> oppMassageMap = new Map<Id, Opportunity>();

        //SAPマスタ重複チェック
        Map<String,Id> accSapMap = new Map<String,Id>();
        Map<String,String> errSapMap = new Map<String,String>();
        Map<Id, String> orgMap = new Map<Id, String>();

        for(Opportunity o : newObjects){
            //SAPチェック結果の初期化
            // チェック結果・エラー内容を初期化
            o.TokuisakiCheckResult__c = null;
            o.TokuisakiCheckErrorDescription__c = null;
            o.SupplierCheckResult__c = null;
            o.ItemCheckResult__c = null;
            o.MasterCheckResult__c = null;
            o.MasterCheckJisshi__c = FALSE;
            oppMassageMap.put(o.Id, o);
            if(o.OrganizationCode__c != null){
                searcSoshikiCd.add(o.OrganizationCode__c);

                if(o.TokuisakiCode__c != null){
                    searcSapMaster.add(o.OrganizationCode__c + '_' + o.TokuisakiCode__c);
                    if(accSapMap.containsKey(o.OrganizationCode__c + '_' + o.TokuisakiCode__c)){
                        if(!o.AccountId.equals(accSapMap.get(o.OrganizationCode__c + '_' + o.TokuisakiCode__c))){
                            errSapMap.put(o.OrganizationCode__c + '_' + o.TokuisakiCode__c , o.OrganizationCode__c + '_' + o.TokuisakiCode__c);
                        }
                    }else{
                        accSapMap.put(o.OrganizationCode__c + '_' + o.TokuisakiCode__c, o.AccountId);
                    }
                }
            }
        }
        for(Opportunity o : newObjects){
            if(errSapMap.containsKey(o.OrganizationCode__c + '_' + o.TokuisakiCode__c)){
                continue;
            }
            orgMap.put(o.Id, o.OrganizationCode__c);
            chkOppIdList.add(o.Id);
        }

        //SAP重複エラーの行は以下の処理の対象外とする。

        // SAPマスタのレコードタイプを取得
        // List<RecordType> sapRt = [SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = :'M_SAPCode__c'];

        Id shiiresakiRT = Schema.SObjectType.M_SAPCode__c.getRecordTypeInfosByDeveloperName().get('ShiiresakiRecordType').getRecordTypeId(); // 仕入れ先レコードタイプ格納用
        Id hinmokuRT = Schema.SObjectType.M_SAPCode__c.getRecordTypeInfosByDeveloperName().get('HinmokuRecordType').getRecordTypeId(); // 品目レコードタイプ格納用
        Id tokuisakiRT = Schema.SObjectType.M_SAPCode__c.getRecordTypeInfosByDeveloperName().get('TokuisakiRecordType').getRecordTypeId(); // 得意先レコードタイプ格納用
        // for(RecordType s : sapRt){

        //     if(System.Label.AP06_CONST_0010.equals(s.DeveloperName)){
        //         shiiresakiRT = s.Id;

        //     }else if(System.Label.AP06_CONST_0011.equals(s.DeveloperName)){
        //         hinmokuRT = s.Id;

        //     }else if(System.Label.AP06_CONST_0012.equals(s.DeveloperName)){
        //         tokuisakiRT = s.Id;
        //     }
        // }

        // 案件に紐づいている案件製品情報取得
        List<OpportunityLineItem> oppLineList = [SELECT
                                                 Id,
                                                 OpportunityId,
                                                 SupplierCode__c,
                                                 HinmokuCode__c
                                                 FROM OpportunityLineItem
                                                 WHERE OpportunityId = :chkOppIdList
                                                 AND Opportunity.recordTypeId != :recId
                                                 ];

        for(OpportunityLineItem oi : oppLineList){
            if(orgMap.get(oi.OpportunityId) != null){
                if(oi.SupplierCode__c != null){
                    searcSapMaster.add(orgMap.get(oi.OpportunityId) + '_' + oi.SupplierCode__c);
                }
                if(oi.HinmokuCode__c != null){
                    searcSapMaster.add(orgMap.get(oi.OpportunityId) + '_' + oi.HinmokuCode__c);
                }
            }
        }

        // SAPコードマスタ情報を分類
        Map<String,M_SAPCode__c> tokuisakiSapMap = new Map<String,M_SAPCode__c>();
        Map<String,M_SAPCode__c> shiiresakiSapMap = new Map<String,M_SAPCode__c>();
        Map<String,M_SAPCode__c> hinmokuSapMap = new Map<String,M_SAPCode__c>();

        if(searcSapMaster.size() > 0){
            List<M_SAPCode__c> sapList = [SELECT Id,
                         RecordTypeId,
                         ShiiresakiCode__c,
                         SoshikiCode__c,
                         TokuisakiCode__c,
                         HinmokuCode__c,
                         DeleteFlag__c,
                         SearchCode__c
                       FROM M_SAPCode__c
                       WHERE SoshikiCode__c = :searcSoshikiCd
                       AND   SearchCode__c = :searcSapMaster
                      ];
            for(M_SAPCode__c sap :sapList){
                if(sap.RecordTypeId.equals(tokuisakiRT)){
                    //得意先
                    tokuisakiSapMap.put(sap.SearchCode__c, sap);
                }else if(sap.RecordTypeId.equals(shiiresakiRT)){
                    //仕入先
                    shiiresakiSapMap.put(sap.SearchCode__c, sap);
                }else if(sap.RecordTypeId.equals(hinmokuRT)){
                    //品目
                    hinmokuSapMap.put(sap.SearchCode__c, sap);
                }
            }
        }

        // UPDATE 用案件製品リスト
        List<OpportunityLineItem> updateOppItemList = new List<OpportunityLineItem>();

        // 案件製品のマスタチェック
        for(OpportunityLineItem oi : oppLineList){
            // チェック結果・エラー内容を初期化
            oi.SupplierCheckResult__c = null;
            oi.SupplierCheckErrorDescription__c = null;
            oi.ItemCheckResult__c = null;
            oi.ItemCheckErrorDescription__c = null;
            //組織コードなし
            if(orgMap.get(oi.OpportunityId) == null){
                //仕入先
                oi.SupplierCheckResult__c = System.Label.AP06_CONST_0005;
                if(oi.SupplierCode__c == null){
                    oi.SupplierCheckErrorDescription__c = System.Label.AP06_MSG_0009;
                }else{
                    oi.SupplierCheckErrorDescription__c = System.Label.AP06_MSG_0005;
                }
                //品目
                oi.ItemCheckResult__c = System.Label.AP06_CONST_0005;
                if(oi.HinmokuCode__c == null){
                    oi.ItemCheckErrorDescription__c = System.Label.AP06_MSG_0011;
                }else{
                    oi.ItemCheckErrorDescription__c = System.Label.AP06_MSG_0005;
                }
            }else{
                //仕入先チェック
                if(oi.SupplierCode__c == null){
                    oi.SupplierCheckResult__c = System.Label.AP06_CONST_0005;
                    oi.SupplierCheckErrorDescription__c = System.Label.AP06_MSG_0004;

                }else{
                    if(!shiiresakiSapMap.containsKey(orgMap.get(oi.OpportunityId) + '_' + oi.SupplierCode__c)){
                        //SAPマスタに存在しない
                        oi.SupplierCheckResult__c = System.Label.AP06_CONST_0006;
                        oi.SupplierCheckErrorDescription__c = System.Label.AP06_MSG_0012;
                    }else{
                        if(shiiresakiSapMap.get(orgMap.get(oi.OpportunityId) + '_' + oi.SupplierCode__c).DeleteFlag__c){
                            //削除済み
                            oi.SupplierCheckResult__c = System.Label.AP06_CONST_0006;
                            oi.SupplierCheckErrorDescription__c = System.Label.AP06_MSG_0008;
                        }else{
                            oi.SupplierCheckResult__c = System.Label.AP06_CONST_0007;
                        }
                    }
                }
                //品目チェック
                if(oi.HinmokuCode__c == null){
                    oi.ItemCheckResult__c = System.Label.AP06_CONST_0005;
                    oi.ItemCheckErrorDescription__c = System.Label.AP06_MSG_0010;

                }else{
                    if(!hinmokuSapMap.containsKey(orgMap.get(oi.OpportunityId) + '_' + oi.HinmokuCode__c)){
                        //SAPマスタに存在しない
                        oi.ItemCheckResult__c = System.Label.AP06_CONST_0006;
                        oi.ItemCheckErrorDescription__c = System.Label.AP06_MSG_0012;
                    }else{
                        if(hinmokuSapMap.get(orgMap.get(oi.OpportunityId) + '_' + oi.HinmokuCode__c).DeleteFlag__c){
                            //削除済み
                            oi.ItemCheckResult__c = System.Label.AP06_CONST_0006;
                            oi.ItemCheckErrorDescription__c = System.Label.AP06_MSG_0008;
                        }else{
                            oi.ItemCheckResult__c = System.Label.AP06_CONST_0007;
                        }
                    }
                }
            }
            oppMassageMap.get(oi.OpportunityId).SupplierCheckResult__c = setCheckKekka(oppMassageMap.get(oi.OpportunityId).SupplierCheckResult__c, oi.SupplierCheckResult__c);
            oppMassageMap.get(oi.OpportunityId).ItemCheckResult__c = setCheckKekka(oppMassageMap.get(oi.OpportunityId).ItemCheckResult__c, oi.ItemCheckResult__c);
        }

        // SAPマスタ更新用List
        List<M_SAPCode__c> updateSapList = new List<M_SAPCode__c>();
        Map<Id, Id> updateSapMap = new Map<Id, Id>();

        //案件のチェック
        for(Opportunity o : newObjects){
            if(o.OrganizationCode__c == null){
                o.TokuisakiCheckResult__c = System.Label.AP06_CONST_0005;
                if(o.TokuisakiCode__c == null){
                    o.TokuisakiCheckErrorDescription__c = System.Label.AP06_MSG_0007;
                }else{
                    o.TokuisakiCheckErrorDescription__c = System.Label.AP06_MSG_0005;
                }
            }else{
                if(o.TokuisakiCode__c == null){
                    o.TokuisakiCheckResult__c = System.Label.AP06_CONST_0005;
                    o.TokuisakiCheckErrorDescription__c = System.Label.AP06_MSG_0006;

                }else{
                    if(errSapMap.containsKey(o.OrganizationCode__c + '_' + o.TokuisakiCode__c)){
                        o.TokuisakiCode__c.addError(System.Label.AP06_MSG_0015);
                        continue;
                    }
                    if(!tokuisakiSapMap.containsKey(o.OrganizationCode__c + '_' + o.TokuisakiCode__c)){
                        //SAPマスタに存在しない
                        o.TokuisakiCheckResult__c = System.Label.AP06_CONST_0006;
                        o.TokuisakiCheckErrorDescription__c = System.Label.AP06_MSG_0012;
                    }else{
                        if(tokuisakiSapMap.get(o.OrganizationCode__c + '_' + o.TokuisakiCode__c).DeleteFlag__c){
                            //削除済み
                            o.TokuisakiCheckResult__c = System.Label.AP06_CONST_0006;
                            o.TokuisakiCheckErrorDescription__c = System.Label.AP06_MSG_0008;
                        }else{
                            o.TokuisakiCheckResult__c = System.Label.AP06_CONST_0007;
                            if(!updateSapMap.containsKey(tokuisakiSapMap.get(o.OrganizationCode__c + '_' + o.TokuisakiCode__c).Id)){
                                updateSapMap.put(tokuisakiSapMap.get(o.OrganizationCode__c + '_' + o.TokuisakiCode__c).Id, o.AccountId);

                                M_SAPCode__c updateSap = new M_SAPCode__c();
                                updateSap.Id =tokuisakiSapMap.get(o.OrganizationCode__c + '_' + o.TokuisakiCode__c).Id;
                                updateSap.Account__c =o.AccountId;
                                updateSapList.add(updateSap);
                            }
                        }
                    }
                }
            }
            // マスタチェック結果の設定(優先順位 : NG/未チェック/OK)
            o.MasterCheckResult__c = setCheckKekka(o.TokuisakiCheckResult__c, o.SupplierCheckResult__c);
            o.MasterCheckResult__c = setCheckKekka(o.MasterCheckResult__c, o.ItemCheckResult__c);
        }

        // SAPコードマスタの更新
        if(updateSapList.size() > 0){
            update updateSapList;
        }

        // 案件製品の更新
            if(oppLineList.size() > 0){
                List<Database.SaveResult> uOLL =database.update(oppLineList,false);
                Integer i = 0;
                for(Database.SaveResult u :uOLL){
                    if(!u.isSuccess()) {
                        Database.Error err = u.getErrors()[0];
                        System.debug('★エラーメッセ'+err.getMessage());
                        // 更新時自己更新エラーキャッチ
                        if(err.getMessage().contains('therefore it cannot recursively update itself')){
                            trigger.newMap.get(oppLineList[i].OpportunityId).addError(System.Label.AP06_MSG_0019);
                        }else{
                            trigger.newMap.get(oppLineList[i].OpportunityId).addError(System.Label.AP06_MSG_0020 + err.getMessage());
                        }
                    }
                    i++;
                }
            }
    }

    // マスタチェック結果の設定(優先順位 : NG/未チェック/OK)
    private String setCheckKekka(String oldStatus, String newStatus){
        if( System.Label.AP06_CONST_0006.equals(oldStatus) || System.Label.AP06_CONST_0006.equals(newStatus) ){
            return System.Label.AP06_CONST_0006;
        }else if( System.Label.AP06_CONST_0005.equals(oldStatus) || System.Label.AP06_CONST_0005.equals(newStatus) ){
            return System.Label.AP06_CONST_0005;
        }
        return newStatus;
    }


    /*
    * 初期価格表の設定
    * @param List<Opportunity> newObjects newTriggerの値
    */
    public void oppDefaultPricebook(List<Opportunity> newObjects){
        //作業者に紐付く設定を取得する
        ProfileConfig__c setting = ProfileConfig__c.getInstance();
        if(setting != null){
            String pbName = setting.DefaultPricebookName__c;
            List<Pricebook2> tmpBooks = [Select Name FROM Pricebook2 WHERE Name = :pbName and IsActive = TRUE];
            if(tmpBooks.size() > 0){
                Id pbId = tmpBooks[0].Id;
                for(Opportunity tmpOpp : newObjects){
                    if(tmpOpp.Pricebook2Id == null){
                        tmpOpp.Pricebook2Id = pbId;
                        tmpOpp.QuoteSaiban__c = 0;
                        tmpOpp.QuoteBangouFix__c  = ''; // [Add] 2017.03.01 Hand Y67
                        tmpOpp.ShiharaiJoken__c   = ''; // [Add] 2017.03.01 Hand Y67
                    }
                        tmpOpp.QuoteSaiban__c = 0;
                        tmpOpp.QuoteBangouFix__c  = ''; // [Add] 2017.03.01 Hand Y67
                        tmpOpp.ShiharaiJoken__c   = ''; // [Add] 2017.03.01 Hand Y67
                }
            }
        }
    }

    /*
    * SAP連携日時登録
    * @param List<Opportunity> oldObjects oldTriggerの値
    * @param List<Opportunity> newObjects newTriggerの値
    * @parm Boolean isInsert 登録処理判定
    */

    public void oppSAPrenkeinichiji(List<Opportunity> oldObjects, List<Opportunity> newObjects, boolean isInsert){

        Integer i = 0;
        for(Opportunity o : newObjects){
            if(o.SAPrenkeizumifuragu__c){
                if(isInsert || !oldObjects[i].SAPrenkeizumifuragu__c ){
                    o.SAPrenkeinichiji__c = system.now();
                }
            }
            i++;
        }

    }

    /*
    * 予定月更新(新規)
    * @param List<Opportunity> newObjects newTriggerの値
    */
    public void oppYoteigetsuKoshinInsert(List<Opportunity> newObjects,string profileName){
        // COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // Id oppDXRec = comTypeManager.getRecordTypeId( 'Opportunity', 'SAWO_DX_Opportunity' );
        // Id oppHHSRec = comTypeManager.getRecordTypeId( 'Opportunity', 'HHS' );
        // Id oppHHSRollerRec = comTypeManager.getRecordTypeId( 'Opportunity', 'HHS_Roller' );
        Id oppDXRec = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId(); 
        Id oppHHSRec = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HHS').getRecordTypeId();
        Id oppHHSRollerRec = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HHS_Roller').getRecordTypeId();

        // String profileId = UserInfo.getProfileId();

        List<String> dxYojituProfs = System.Label.SAWO_CON_YojitsuProfile.split(',');
        // Map<Id, Profile> dxYojituProfsMap = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE Name IN :dxYojituProfs]);

        //[Add]180123 HHS_E2E-0144(HHS)受注月値セットロジック改修
        // Map<Id, RecordType> rtMap = new Map<Id, RecordType>([Select Id,DeveloperName from RecordType  where SobjectType = 'Opportunity' and DeveloperName in ('HHS', 'HHS_Roller')]);
        for(Opportunity o : newObjects){
            // if(o.recordTypeId == oppDXRec && dxYojituProfsMap.keySet().contains(profileId)) {
            if(o.recordTypeId == oppDXRec && dxYojituProfs.contains(profileName)) {
                o.OrderYoteiDate__c = o.CloseDate;
                Datetime ydt = Datetime.newInstance(o.OrderYoteiDate__c.year(), o.OrderYoteiDate__c.month(), o.OrderYoteiDate__c.day());
                o.OrdersYotei__c = ydt.format('yyyy/MM');

            } else {
                //受注予定月を更新
                //[Add]180123 HHS_E2E-0144(HHS)受注月値セットロジック改修 HHSの場合完了予定日
                // if(rtMap.keySet().contains(o.recordTypeId)){
                if(o.recordTypeId == oppHHSRec || o.recordTypeId == oppHHSRollerRec) {
                    Datetime ydt = Datetime.newInstance(o.CloseDate.year(), o.CloseDate.month(), o.CloseDate.day());
                    o.OrdersYotei__c = ydt.format('yyyy/MM');
                }//HHS以外の場合
                else if(o.OrderYoteiDate__c != null){
                    Datetime ydt = Datetime.newInstance(o.OrderYoteiDate__c.year(), o.OrderYoteiDate__c.month(), o.OrderYoteiDate__c.day());
                    o.OrdersYotei__c = ydt.format('yyyy/MM');
                }
                //売上予定月を更新
                if(o.UriageYoteiBi__c != null){
                    Datetime udt = Datetime.newInstance(o.UriageYoteiBi__c.year(), o.UriageYoteiBi__c.month(), o.UriageYoteiBi__c.day());
                    o.SalesDate__c = udt.format('yyyy/MM');
                }
            }
        }
    }

    /*
    * 予定月更新(更新)
    * @param Map<Id,Opportunity> oldObjectsMap oldTriggerの値
    * @param List<Opportunity> newObjects newTriggerの値
    */
    public void oppYoteigetsuKoshinUpdate(Map<Id,Opportunity> oldObjectsMap, List<Opportunity> newObjects,string profileName){
      //[Add]180123 HHS_E2E-0144(HHS)受注月値セットロジック改修
        // Map<Id, RecordType> rtMap = new Map<Id, RecordType>([Select Id,DeveloperName from RecordType  where SobjectType = 'Opportunity' and DeveloperName in ('HHS', 'HHS_Roller')]);
        // COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // Id oppDXRec = comTypeManager.getRecordTypeId( 'Opportunity', 'SAWO_DX_Opportunity' );
        // Id oppHHSRec = comTypeManager.getRecordTypeId( 'Opportunity', 'HHS' );
        // Id oppHHSRollerRec = comTypeManager.getRecordTypeId( 'Opportunity', 'HHS_Roller' );

        Id oppDXRec = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId(); 
        Id oppHHSRec = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HHS').getRecordTypeId();
        Id oppHHSRollerRec = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HHS_Roller').getRecordTypeId();

        // String profileId = UserInfo.getProfileId();

        List<String> dxYojituProfs = System.Label.SAWO_CON_YojitsuProfile.split(',');
        // Map<Id, Profile> dxYojituProfsMap = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE Name IN :dxYojituProfs]);


        for(Opportunity o : newObjects){
            if(o.recordTypeId == oppDXRec && dxYojituProfs.contains(profileName)) {
                o.OrderYoteiDate__c = o.CloseDate;
                Datetime ydt = Datetime.newInstance(o.OrderYoteiDate__c.year(), o.OrderYoteiDate__c.month(), o.OrderYoteiDate__c.day());
                o.OrdersYotei__c = ydt.format('yyyy/MM');

            } else {
                if(o.recordTypeId == oppHHSRec || o.recordTypeId == oppHHSRollerRec) {
                    //受注予定月を更新
                    //[Add]180123 HHS_E2E-0144(HHS)受注月値セットロジック改修 HHSの場合完了予定日
                    // if(rtMap.keySet().contains(o.recordTypeId)){
                    if(oldObjectsMap.get(o.Id).CloseDate != o.CloseDate && o.OrdersYotei__c != null){
                        Datetime ydt = Datetime.newInstance(o.CloseDate.year(), o.CloseDate.month(), o.CloseDate.day());
                        o.OrdersYotei__c = ydt.format('yyyy/MM');
                    }else{
                        Datetime ydt = Datetime.newInstance(o.CloseDate.year(), o.CloseDate.month(), o.CloseDate.day());
                        o.OrdersYotei__c = ydt.format('yyyy/MM');
                    }
                //HHS以外の場合
                } else if(o.OrderYoteiDate__c != null){
                    if(oldObjectsMap.get(o.Id).OrderYoteiDate__c != null && o.OrdersYotei__c != null){
                        if(oldObjectsMap.get(o.Id).OrderYoteiDate__c != o.OrderYoteiDate__c) {
                            Datetime ydt = Datetime.newInstance(o.OrderYoteiDate__c.year(), o.OrderYoteiDate__c.month(), o.OrderYoteiDate__c.day());
                            o.OrdersYotei__c = ydt.format('yyyy/MM');
                        }
                    }else{
                        Datetime ydt = Datetime.newInstance(o.OrderYoteiDate__c.year(), o.OrderYoteiDate__c.month(), o.OrderYoteiDate__c.day());
                        o.OrdersYotei__c = ydt.format('yyyy/MM');
                    }
                }    
            }

            //売上予定月を更新
            if(o.UriageYoteiBi__c != null){
                if(oldObjectsMap.get(o.Id).UriageYoteiBi__c != null && o.SalesDate__c != null){
                    if(oldObjectsMap.get(o.Id).UriageYoteiBi__c != o.UriageYoteiBi__c) {
                        Datetime udt = Datetime.newInstance(o.UriageYoteiBi__c.year(), o.UriageYoteiBi__c.month(), o.UriageYoteiBi__c.day());
                        o.SalesDate__c = udt.format('yyyy/MM');
                    }
                }
                else{
                    Datetime udt = Datetime.newInstance(o.UriageYoteiBi__c.year(), o.UriageYoteiBi__c.month(), o.UriageYoteiBi__c.day());
                    o.SalesDate__c = udt.format('yyyy/MM');
                }
            }
        }
    }


    /*
    * 引合連絡票更新(案件返し)
    * @param List<Opportunity> newObjects newTriggerの値
    */
    public void ReturnICf(List<Opportunity> newObjects){

        // 引合IdList
        List<Id> chkICfIdList = new List<Id>();
        // 案件Map(Key_元引合Id,Value_案件Id)
        Map<Id, Id> OppMap = new Map<Id, Id>();


        for(Opportunity o : newObjects){
            if(o.OppIC__c != null){
                OppMap.put(o.OppIC__c, o.Id);
                chkICfIdList.add(o.OppIC__c);
            }
        }

        if(chkICfIdList.size() > 0){
            // 引合連絡票に案件を返す　　　半田 代理店
            List<T_InquiriesContactform__c> icfList = [Select Id,CreateOpp__c From T_InquiriesContactform__c Where Id in :chkICfIdList ];
            if(icfList.size() > 0){
                for(T_InquiriesContactform__c icf :icfList){
                    icf.CreateOpp__c = OppMap.get(icf.Id);
                }
            }
            update icfList;
        }

    }
    
    //add kim 2019/04/26 LEX対応
    /*
    * 顧客氏名の役割生成
    * @param List<Opportunity> newObjects newTriggerの値
    */
    public void CreateOpportunityContactRole(List<Opportunity> newObjects){
        system.debug('役割ログ　CreateOpportunityContactRole');
        User u = [SELECT Id,UserPreferencesLightningExperiencePreferred FROM User WHERE Id =:userInfo.getUserId()];
        //画面がLEXの場合、処理を行う。
        if(u.UserPreferencesLightningExperiencePreferred){
            system.debug('役割ログ　LEX画面確認');
            List<OpportunityContactRole> roleList = new List<OpportunityContactRole>();
            OpportunityContactRole role = null;
            for(Opportunity o : newObjects){
                 system.debug('役割ログ　レコード存在確認');
                if(o.Contact__c != null){
                     system.debug('役割ログ　顧客氏名登録確認');
                    role = new OpportunityContactRole();
                    role.ContactId = o.Contact__c;
                    role.OpportunityId = o.Id;
                    role.IsPrimary = true;
                    roleList.add(role);
                }
            }
            if(role != null && roleList.size() > 0){
                 system.debug('役割ログ　役割インサート');
                insert roleList;
            }
        }
        
    }

    /*
    * 2017/07/19 Handa add
    * デフォルト値セット
    * @param List<Opportunity> newObjects newTriggerの値
    * @parm Boolean isInsert 登録処理判定
    */
    public void oppDefalt(List<Opportunity> newObjects, boolean isInsert){

        List<Id> oppAccountList = new List<Id>();    // 会社名Idリスト
        List<Id> oppConList     = new List<Id>();    // 顧客氏名リスト

        //納入先用 会社Id取得
        for(Opportunity o : newObjects){
                oppAccountList.add(o.AccountId);
        }

        //分野用 顧客氏名Id取得
        for(Opportunity o : newObjects){
                oppConList.add(o.Contact__c);
        }

        //科学レコードタイプ取得
        // Map<Id, RecordType> rtMap = new Map<Id, RecordType>([Select
        //                                                        Id,
        //                                                        DeveloperName
        //                                                      FROM
        //                                                        RecordType
        //                                                      WHERE
        //                                                        SobjectType = 'Opportunity'
        //                                                       AND
        //                                                        DeveloperName in ('PublicOffice', 'Private')]);
        
                                                               
        Id oppPublicOffice = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('PublicOffice').getRecordTypeId();
        Id oppPrivate = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Private').getRecordTypeId();


        // 会社名情報Map作成(Key_Id、Value_顧客氏名OBJ)
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT
                                                              Name
                                                            FROM
                                                              Account
                                                            WHERE
                                                              id in :oppAccountList]);

        // 顧客氏名Map作成(Key_Id、Value_顧客氏名OBJ)
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT
                                                              Area1__c,
                                                              Area2__c,
                                                              Area3__c
                                                            FROM
                                                              Contact
                                                            WHERE
                                                              id in :oppConList]);

        // 納入先名、分野(1),分野(2),分野(3)set
        Integer i = 0;
        for (Opportunity opp : newObjects) {
            // if (rtMap.keySet().contains(opp.recordTypeId)) {
            if (oppPublicOffice == opp.recordTypeId || oppPrivate == opp.recordTypeId) {
                if(isInsert){
/*
                    if(opp.StageName == System.Label.AP06_CONST_0015){
                        opp.CloseDate = System.today();
                    }
*/
                    if(opp.AccountId != null && opp.Nounyusaki__c == null){
                        opp.Nounyusaki__c = accountMap.get(opp.AccountId).Name;
                    }
                    if(opp.Contact__c != null && opp.Area1__c == null && opp.Area2__c == null && opp.Area3__c == null){
                        opp.Area1__c = contactMap.get(opp.Contact__c).Area1__c;
                        opp.Area2__c = contactMap.get(opp.Contact__c).Area2__c;
                        opp.Area3__c = contactMap.get(opp.Contact__c).Area3__c;
                    }
                }else{
                    // 更新時のみ判定
                   /*
                    if(opp.StageName == System.Label.AP06_CONST_0015){
                        if(oldObjects[i].StageName != System.Label.AP06_CONST_0015){
                            opp.CloseDate = System.today();
                        }
                    }
*/
                    if(opp.Contact__c != null && opp.Area1__c == null && opp.Area2__c == null && opp.Area3__c == null){
                        opp.Area1__c = contactMap.get(opp.Contact__c).Area1__c;
                        opp.Area2__c = contactMap.get(opp.Contact__c).Area2__c;
                        opp.Area3__c = contactMap.get(opp.Contact__c).Area3__c;
                    }
                }
            }
        }
    }


    /*
    * 装置名更新(Y15半田)
    * @param List<Opportunity> oldObjects oldTriggerの値
    * @param List<Opportunity> newObjects newTriggerの値
    */
    public void ChangeDeviceType(List<Opportunity> oldObjects , List<Opportunity> newObjects){
        List<Id> Ids = new List<Id>();

        for(integer i = 0; i < newObjects.size(); i++){
            //案件製品一括編集画面経由は更新しない
            if(!newObjects[i].DelOppLFlg__c){
                if(newObjects[i].OppNumber__c != oldObjects[i].OppNumber__c){
                    //案件製品数が変更された案件取得
                    Ids.add(newObjects[i].Id);
                }
            }else{
                newObjects[i].DeviceType__c = oldObjects[i].DeviceType__c;
            }
            newObjects[i].DelOppLFlg__c =false;
        }
        if(Ids.size() > 0){
            //案件製品数が変更された案件の案件製品
            List<OpportunityLineItem> OppL = [Select Id,Katashiki__c,OpportunityId,ProductFlg__c From OpportunityLineItem Where OpportunityId =:Ids];
            //案件の装置名に入れる値
            // String DeviceTypeList;
            //重複チェックフラグ
            // boolean Check;

            //案件に型式セット
            for(integer i = 0; i < newObjects.size(); i++){
                //2017/09/07 toshima mod Set使用するよう改修
                Set<String> DeviceTypeSet = new Set<String>();
                // DeviceTypeList = '';
                //型式の重複チェック用
                // List<String> DeviceTypeCheck = new List<String> ();
                // Check = false;
                for(OpportunityLineItem tmpLine :OppL ){
                    //案件製品が本体かつ親案件が同じ
                    if(tmpLine.OpportunityId.equals(newObjects[i].Id) && tmpLine.ProductFlg__c ){
                        /*//1つの場合はカンマ無し
                        if(String.isBlank(DeviceTypeList)){
                            DeviceTypeList += tmpLine.Katashiki__c;
                        }else{
                            for(String OppLDT : DeviceTypeCheck){
                                if(OppLDT.equals(tmpLine.Katashiki__c)){
                                    Check = true;
                                }
                            }
                            if(!Check){
                                DeviceTypeList += '、' + tmpLine.Katashiki__c;
                            }
                        }
                        //格納済型式
                        DeviceTypeCheck.add(tmpLine.Katashiki__c);
                        */
                        // 案件製品.型式の値が空でない場合、Setに追加
                        if(String.isNotBlank(tmpLine.Katashiki__c)) DeviceTypeSet.add(tmpLine.Katashiki__c);
                    }
                }
                // newObjects[i].DeviceType__c = DeviceTypeList;
                // 値が空でない案件製品.型式を'、'区切りで繋げて装置名に設定
                newObjects[i].DeviceType__c = String.join(new List<String>(DeviceTypeSet),'、');
            }
    }
    }


   /*
    * 予算削除
    * @param List<Opportunity> oldObjects oldTriggerの値
    * @parm Boolean isDelete 削除処理判定
    */
    public void delYosan(List<Opportunity> oldObjects, Boolean isDelete){

        Set<Id> OppdelId = new Set<Id>();
        // 削除Id取得(案件)
        for(Opportunity o : oldObjects){
            if(isDelete){
                OppdelId.add(o.Id);
            }
        }
System.debug('★削除案件'+OppdelId);
        List<T_BudgetResults__c> delYosanList = new List<T_BudgetResults__c>();
        delYosanList = [
                  SELECT
                    Id
                  FROM
                    T_BudgetResults__c
                  WHERE
                    RecordType.Name = '予算'
                    AND
                    HeaderBudgetResults__c = null
                    AND
                    Opportunity__c IN :OppdelId
                ];
System.debug('★削除予算'+delYosanList);

        try{
          if(delYosanList.size() > 0){
            delete delYosanList;
          }
        }
        catch(Exception e){
          return;
        }
      }


    /**
     * 2017/09/27 toshima add
    * 職制の値チェック(CASで使用)
    * 以下いずれかの条件に該当時エラーとする
    * ・String.isBlank(Opportunity.OwnerShokusei__c)
    * ・String.isBlank(Opportunity.Shokusei__c)
    * ・Opportunity.OwnerShokusei__c != Opportunity.Owner.UserRole.DeveloperName.left(4)
     *
    */
    public void validateShokusei(List<Opportunity> newRecords){
        // insert/updateする案件の所有者のMap取得
        Set<Id> oppOwnerIdSet = new Set<ID>();
        for(Opportunity o:newRecords) oppOwnerIdSet.add(o.OwnerId);
        Map<Id, User> oppOwnerMap = new Map<Id, User>([SELECT Id, UserRole.developerName FROM User where id in :oppOwnerIdSet]);

        // insert/updateする案件のエラーチェック
       /*	★★2019/12/02 Sprint2-1テスト実施のため一時的にコメントアウト★★

        for(Opportunity o:newRecords){
            
            
            if(String.isBlank(o.Shokusei__c)) {
                o.Shokusei__c.addError(System.Label.AP06_MSG_0017);
                continue;
            }
            if(String.isBlank(o.OwnerShokusei__c)) {
                o.OwnerShokusei__c.addError(System.Label.AP06_MSG_0016);
                continue;
            }
            if(o.OwnerShokusei__c != oppOwnerMap.get(o.OwnerId).UserRole.developerName.left(4)) {
                o.OwnerShokusei__c.addError(System.Label.AP06_MSG_0018_PRE + oppOwnerMap.get(o.ownerId).UserRole.DeveloperName + System.Label.AP06_MSG_0018_POST );
                continue;
            }
        }
		*/

    }

    /*
    * 引合連絡票更新(案件変更反映)
    * @param List<Opportunity> newObjects newTriggerの値
    */
    public void ReturnIC(List<Opportunity> newObjects){

        // 連絡票IdList
        List<Id> chkICfIdList = new List<Id>();
        // 案件Map(Key_元引合Id,Value_案件obj)
        Map<Id, Opportunity> newOppMap = new Map<Id, Opportunity>();


        for(Opportunity n : newObjects){
            if(n.OppIC__c != null && n.HHS_IChanei__c){
                newOppMap.put(n.OppIC__c, n);   //key 連絡票id,value 案件obj
                chkICfIdList.add(n.OppIC__c);   //更新対象の連絡票
                n.HHS_IChanei__c = false;           //反映フラグ消し込み
            }
        }

        if(chkICfIdList.size() > 0){
            // 連絡票更新（連絡票←案件）
            List<T_InquiriesContactform__c> icfList = [ Select Id From T_InquiriesContactform__c Where Id in :chkICfIdList ];

            if(icfList.size() > 0 ){
                for(T_InquiriesContactform__c icf :icfList){

                    icf.HHS_ProductFamily__c = newOppMap.get(icf.Id).HHS_ProductFamilys__c;//製品群
                    icf.HHS_ModelOther__c = newOppMap.get(icf.Id).  HHS_ModelOther__c;//型式(その他)
                    icf.HHS_Model1__c = newOppMap.get(icf.Id).HHS_Model1__c;//型式1
                    icf.HHS_Model2__c = newOppMap.get(icf.Id).HHS_Model2__c;//型式2
                    icf.HHS_Model3__c = newOppMap.get(icf.Id).HHS_Model3__c;//型式3
                    icf.HHS_Model4__c = newOppMap.get(icf.Id).HHS_Model4__c;//型式4
                    icf.HHS_Quantity1__c = newOppMap.get(icf.Id).HHS_Quantity1__c;//数量1
                    icf.HHS_Quantity2__c = newOppMap.get(icf.Id).HHS_Quantity2__c;//数量2
                    icf.HHS_Quantity3__c = newOppMap.get(icf.Id).HHS_Quantity3__c;//数量3
                    icf.HHS_Quantity4__c = newOppMap.get(icf.Id).HHS_Quantity4__c;//数量4
                    icf.KonyuJiki_Year__c = newOppMap.get(icf.Id).CloseDate.year() + '年';//購入時期(年)←受注予定日（年）
                    icf.KonyuJiki_Month__c = newOppMap.get(icf.Id).CloseDate.month() +'月';//購入時期(月)←受注予定日（月）
                    icf.HHS_OrdersAccuracy__c = newOppMap.get(icf.Id).OrdersAccuracy__c;//受注確度←受注確度
                    icf.ICkigen__c = newOppMap.get(icf.Id).HHS_ExpirationDate__c;//有効期限←有効期限日
                    icf.CompetitionMaker__c = newOppMap.get(icf.Id).CompetitionMaker__c;//競合メーカ←競合メーカー名

                    icf.KyougoSonota__c = newOppMap.get(icf.Id).CompetitionMaker_Other__c;//競合メーカ（その他）←競合メーカー（その他）

                    if(newOppMap.get(icf.Id).SAWO_InquiriesContactformType__c == '02'){
                        //DX移行後連絡票
                        icf.HHS_BudgetAmount__c = newOppMap.get(icf.Id).SAWO_Approved_Budget__c;//予算金額←金額
                        icf.HHS_BudgetAccuracy__c = newOppMap.get(icf.Id).SAWO_BudgetAccuracy__c;//予算確度←予算確度
                    }
                 }
            }
            update icfList;

        }

    }


    /*
    * 2017/09/01 Handa add
    * デフォルト値セット(HHS)
    * @param List<Opportunity> newObjects newTriggerの値
    * @parm Boolean isInsert 登録処理判定
    */
    public void oppHHSDefalt(List<Opportunity> newObjects, boolean isInsert){

        List<Id> oppAccountList            = new List<Id>();    // 会社名リスト
        List<Id> oppContactList            = new List<Id>();    // 顧客氏名リスト
        List<Id> oppAgencyList             = new List<Id>();    // 代理店リスト

        // 顧客氏名、代理店Id取得
        for(Opportunity opp : newObjects){
                oppAccountList.add(opp.AccountId);
                oppContactList.add(opp.Contact__c);
                oppAgencyList.add(opp.HHS_AgencyOwner__c);
        }

        //HHSレコードタイプ取得
        // Map<Id, RecordType> rtMap = new Map<Id, RecordType>([Select
        //                                                        Id,
        //                                                        DeveloperName
        //                                                      FROM
        //                                                        RecordType
        //                                                      WHERE
        //                                                        SobjectType = 'Opportunity'
        //                                                       AND
        //                                                        DeveloperName in ('HHS')]);

        Id oppHHS = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HHS').getRecordTypeId();
        Id oppHHSRoller = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HHS_Roller').getRecordTypeId();                                                       

        // 会社名Map作成(Key_Id、Value_会社名OBJ)
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT
                                                              Name
                                                            FROM
                                                              Account
                                                            WHERE
                                                              id in :oppAccountList]);
        // 顧客氏名Map作成(Key_Id、Value_顧客氏名OBJ)
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT
                                                              MailingState,
                                                              MailingCity,
                                                              MailingStreet,
                                                              //171113 [Add] S
                                                              MailingPostalCode,
                                                              UnitName1__c,
                                                              Name
                                                              //171113 [Add] E
                                                            FROM
                                                              Contact
                                                            WHERE
                                                              id in :oppContactList]);

        // 顧客氏名Map作成(Key_Id、Value_顧客氏名OBJ)
        Map<Id, Contact> agencyMap = new Map<Id, Contact>([SELECT
                                                              MailingState,
                                                              MailingCity,
                                                              MailingStreet,
                                                              //171113 [Add] S
                                                              MailingPostalCode,
                                                              UnitName1__c,
                                                              Name
                                                              //171113 [Add] E
                                                            FROM
                                                              Contact
                                                            WHERE
                                                              id in :oppAgencyList]);
        // 受注先都道府県、受注先住所set
        Integer i = 0;
        for (Opportunity opp : newObjects) {
            // if (rtMap.keySet().contains(opp.recordTypeId)) {
                if (oppHHS == opp.recordTypeId || oppHHSRoller == opp.recordTypeId) {    
                if(isInsert){
                    if(opp.AccountId != null){
                        if(String.isBlank(opp.HHS_ShukkaSaki3__c)){
                            //案件.出荷先 ③←案件.会社/施設.会社/施設
                            opp.HHS_ShukkaSaki3__c = accountMap.get(opp.AccountId).Name;
                        }
                        //if(opp.Contact__c == null){
                            //if(String.isBlank(opp.HHS_ShukkaSaki2__c)){
                                //案件.出荷先 ②←案件.会社/施設.会社/施設 案件.顧客氏名.部署 案件.顧客氏名.名前「様」
                                //opp.HHS_ShukkaSaki2__c = accountMap.get(opp.AccountId).Name;
                            //}
                        //}
                    }
                    if(opp.Contact__c != null){
                        if(String.isBlank(opp.HHS_OrdersSakiState__c) ){
                            opp.HHS_OrdersSakiState__c = contactMap.get(opp.Contact__c).MailingState; //受注先都道府県 ←contact都道府県（郵送先）
                        }
                        if(String.isBlank(opp.HHS_OrdersSakiAddress__c)){
                            opp.HHS_OrdersSakiAddress__c =  (String.isBlank(contactMap.get(opp.Contact__c).MailingCity)) ? '' : contactMap.get(opp.Contact__c).MailingCity;
                            opp.HHS_OrdersSakiAddress__c += (String.isBlank(contactMap.get(opp.Contact__c).MailingStreet)) ? '' : '_' + contactMap.get(opp.Contact__c).MailingStreet; //受注先住所 ←contact市区郡_町名・番地（郵送先）

                        }
                        //if(String.isBlank(opp.HHS_ShukkaSakiSectionName__c)){
                            //案件.出荷先部署名称←案件.顧客氏名.部署1
                            //opp.HHS_ShukkaSakiSectionName__c = contactMap.get(opp.Contact__c).UnitName1__c;
                        //}
                        if(String.isBlank(opp.HHS_ShukkaSakiOwnerName__c)){
                            //案件.出荷先担当者名称←案件.顧客氏名.名前
                            opp.HHS_ShukkaSakiOwnerName__c = contactMap.get(opp.Contact__c).Name;
                        }
                        if(String.isBlank(opp.HHS_ShukkaSaki1__c)){
                            //案件.出荷先 ①←案件.顧客氏名.住所→郵便番号から最後まで全て
                            opp.HHS_ShukkaSaki1__c =  (String.isBlank(contactMap.get(opp.Contact__c).MailingPostalCode)) ? '' : contactMap.get(opp.Contact__c).MailingPostalCode;
                            opp.HHS_ShukkaSaki1__c += (String.isBlank(contactMap.get(opp.Contact__c).MailingState)) ? '' : contactMap.get(opp.Contact__c).MailingState;
                            opp.HHS_ShukkaSaki1__c += (String.isBlank(contactMap.get(opp.Contact__c).MailingCity)) ? '' : contactMap.get(opp.Contact__c).MailingCity;
                            opp.HHS_ShukkaSaki1__c += (String.isBlank(contactMap.get(opp.Contact__c).MailingStreet)) ? '' : contactMap.get(opp.Contact__c).MailingStreet;

                        }
                        //if(String.isBlank(opp.HHS_ShukkaSaki2__c)){
                            //案件.出荷先 ②←案件.会社/施設.会社/施設 案件.顧客氏名.部署1 案件.顧客氏名.名前「様」
                            //opp.HHS_ShukkaSaki2__c = accountMap.get(opp.AccountId).Name;
                            //opp.HHS_ShukkaSaki2__c += (String.isBlank(contactMap.get(opp.Contact__c).UnitName1__c)) ? '' : ' ' + contactMap.get(opp.Contact__c).UnitName1__c;
                            //opp.HHS_ShukkaSaki2__c += ' ' + contactMap.get(opp.Contact__c).Name +'様';
                        //}
                    }
                    if(opp.HHS_AgencyOwner__c != null){
                        //代理店有
                        //if(String.isBlank(opp.HHS_BillingDestinationSectionName__c)){
                            //案件. 請求書送付宛先部署名称←案件.代理店担当者.事業所 案件.代理店担当者.部署1
                            //opp.HHS_BillingDestinationSectionName__c += (String.isBlank(agencyMap.get(opp.HHS_AgencyOwner__c).UnitName1__c)) ? '' : ' ' + agencyMap.get(opp.HHS_AgencyOwner__c).UnitName1__c;
                        //}
                        if(String.isBlank(opp.HHS_BillingDestinationOwnerName__c)){
                            //案件. 請求書送付宛先担当名称←案件.代理店担当者.名前
                            opp.HHS_BillingDestinationOwnerName__c = agencyMap.get(opp.HHS_AgencyOwner__c).Name;
                        }
                    }else if(opp.Contact__c != null){
                        //代理店無、顧客氏名有
                        //if(String.isBlank(opp.HHS_BillingDestinationSectionName__c)){
                            //案件. 請求書送付宛先部署名称←案件.顧客氏名.事業所 案件.顧客氏名.部署1
                            //opp.HHS_BillingDestinationSectionName__c += (String.isBlank(contactMap.get(opp.Contact__c).UnitName1__c)) ? '' : ' ' + contactMap.get(opp.Contact__c).UnitName1__c;

                        //}
                        if(String.isBlank(opp.HHS_BillingDestinationOwnerName__c)){
                            //案件. 請求書送付宛先担当名称←案件.顧客氏名.名前
                            opp.HHS_BillingDestinationOwnerName__c = contactMap.get(opp.Contact__c).Name;
                        }
                    }

                }
            }
            //2017/10/19_Handa No.119やるぞフラグ
            if(opp.HHS_Yaruzo__c){
                opp.HHS_Tonyufuragu__c = true;
            }
            //2017/10/20_Handa No144.金額ブランク時0埋め
/*
            if(opp.BudgetAmount__c == null){
                opp.BudgetAmount__c = 0;
            }
            if(opp.Benefit__c == null){
                opp.Benefit__c = 0;
            }
            if(opp.HHS_SupplierOrdersAmount__c == null){
                opp.HHS_SupplierOrdersAmount__c = 0;
            }
*/
        }
    }


    /*
    * 2017/10/23 Handa add
    * デフォルト値セット(HHS),insert時メソッドに時間あるとき組みこむ。
    * @param List<Opportunity> oldObjects oldTriggerの値
    * @param List<Opportunity> newObjects newTriggerの値
    * @parm Boolean isInsert 登録処理判定
    */
    public void oppHHSupdate(Map<ID, Opportunity> oldObjectsMap,Map<ID, Opportunity> newObjectsMap){
        //2017/10/23_Handa No.119やるぞフラグ
        for(Id id:newObjectsMap.keySet()){
            if (!oldObjectsMap.get(id).HHS_Yaruzo__c && newObjectsMap.get(id).HHS_Yaruzo__c) {
                newObjectsMap.get(id).HHS_Tonyufuragu__c = true;
            }
        }
    }

    /*
    * CAS用案件番号採番処理
    * @param List<Opportunity> oldObjects oldTriggerの値
    * @param List<Opportunity> newObjects newTriggerの値
    * @parm Boolean isInsert 登録処理判定
    */
    public void oppNumberSaiban_cas(List<Opportunity> oldObjects, List<Opportunity> newObjects, boolean isInsert){
        String saibankomoku = System.Label.AP06_CONST_0001;
        String shokusei;
        Decimal currentNo;
        String YYMM = System.DateTime.now().format(System.Label.AP06_CONST_0002);

        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> newMap = new Map<Id, Opportunity>();

        List<Opportunity> saibanOppList = new List<Opportunity>();    // 採番対象案件リスト

        List<Id> userIdList = new List<Id>();    // ユーザIdリスト

        if(oldObjects != null){
            for(Opportunity o : oldObjects){
                oldMap.put(o.Id, o);
            }
        }
        Set<Id> userRoleIdList = new Set<Id>();    // ロールIdリスト
        for(Opportunity o : newObjects){
            if(isInsert && !o.LeadFlg__c){
                //リード以外からの登録の場合、職制(担当者)の整合性チェックを行う
                userRoleIdList.add(o.ownerId);
            }
        }


        Map<Id, User> UserMap = new Map<Id, User>([SELECT Id, UserRole.developerName FROM User where id in :userRoleIdList]);

        // 採番で使用する職制リスト
        List<String> shokuseiList = new List<String>();

        for(Opportunity o : newObjects){

            if(!isInsert && oldMap.get(o.Id).OpportunityNo__c != null){
                continue;

            }else{
                if(o.LeadFlg__c){
                    o.OwnerShokusei__c = o.Shokusei__c;
                    o.LeadFlg__c = false;
                }
                shokuseiList.add(o.Shokusei__c);
                saibanOppList.add(o);
            }
        }

        //採番管理レコード取得
        List<M_Sequence__c> seqList = [SELECT  CurrentNo__c,LastOutputMonth__c, RoleNo__c FROM M_Sequence__c WHERE RoleNo__c = :shokuseiList AND SaibanItem__c = :System.Label.AP21_CONST_0001 FOR Update];

        //職制_採番Map(Key_職制(ロールNo), Value_採番OBJ)
        Map<String, M_Sequence__c> seqMap = new Map<String, M_Sequence__c>();
        Map<String, M_Sequence__c> updateSeqMap = new Map<String, M_Sequence__c>();

        for(M_Sequence__c s : seqList){
            seqMap.put(s.RoleNo__c, s);
        }
        for(Opportunity o : saibanOppList){

            //取得した職制での採番有無チェック
            if(seqMap.get(o.Shokusei__c) == null){
                currentNo = 1;
            }else{
                //月初採番チェック
                if(seqMap.get(o.Shokusei__c).LastOutputMonth__c == YYMM){
                    currentNo = seqMap.get(o.Shokusei__c).CurrentNo__c;
                }else{
                    currentNo = 1;
                }
            }

            if(currentNo > 9999){
                o.OpportunityNo__c.addError(System.Label.AP06_MSG_0001);
                return;
            }else{
                o.OpportunityNo__c = o.Shokusei__c + '-' + YYMM +
                        CL_CommonUtils.paddingLeftZero(currentNo.intValue(), 4);
                currentNo++;
            }

            //採番管理更新
            if(seqMap.get(o.Shokusei__c) == null){
                M_Sequence__c newseq = new M_Sequence__c(
                        Name = o.Shokusei__c,
                        CurrentNo__c = currentNo,
                        LastOutputMonth__c = YYMM,
                        SaibanItem__c = saibankomoku,
                        RoleNo__c = o.Shokusei__c
                        );
                seqMap.put(o.Shokusei__c, newseq);
                updateSeqMap.put(o.Shokusei__c, newseq);
            }else{
                M_Sequence__c updateseq = seqMap.get(o.Shokusei__c);
                updateseq.CurrentNo__c = currentNo;
                updateseq.LastOutputMonth__c = YYMM;
                seqMap.put(o.Shokusei__c, updateseq);
                updateSeqMap.put(o.Shokusei__c, updateseq);
            }
        }

        List<M_Sequence__c> iSaibanList = new List<M_Sequence__c>();    // INSERT 用採番リスト
        List<M_Sequence__c> uSaibanList = new List<M_Sequence__c>();    // UPDATE 用採番リスト

        for (String sKey : updateSeqMap.keySet()) {
            M_Sequence__c temp = updateSeqMap.get(sKey);
            if(temp.Id == null){
                iSaibanList.add(temp);
            }else{
                uSaibanList.add(temp);
            }
        }

        if(iSaibanList.size() > 0){
            insert iSaibanList;
        }
        if(uSaibanList.size() > 0){
            update uSaibanList;
        }
    }
    
    /** add kim 2019/05/22
     * SetCustomerOrderNoJtl JTL得意先発注番号連携項目登録
     * @param List<Opportunity> newObjects
     */
    public void SetCustomerOrderNoJtl(List<Opportunity> newObjects){
        Id oppRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HHT_JTL').getRecordTypeId();
        for(Opportunity o : newObjects){
            //レコードタイプが「HHT_JTL」でフェーズが作業完了の場合
            //if(o.RecordTypeId == oppRt && o.StageName == System.Label.AP43_CONST_0011){  //modify 2019/06/18 tyo ラベルが重複のため、新しい方削除 & JTL_OrderNo__cが非空白必要対応
            if(o.RecordTypeId == oppRt && o.StageName == System.Label.AP43_CONST_0003 && String.isNotBlank(o.JTL_OrderNo__c)){
                //注文番号が半角のみの場合
                if (Pattern.matches('[ -~]+', o.JTL_OrderNo__c)) {
                    o.CustomerOrderNo__c = o.JTL_OrderNo__c;
                }else{
                    //注文番号が半角のみではない場合、同期化されている見積番号を取得
                    List<Quote> qList = [SELECT Id, OpportunityId,QuoteNumber  FROM Quote 
                                         WHERE IsSyncing = true And OpportunityId =: o.Id];
                    if(qList.size() > 0){
                        o.CustomerOrderNo__c = qList[0].QuoteNumber;                        
                    }
                }
            }
        }
        
    }

    /**
     * setDXOpportunityNumbering DX商談採番処理
     * 採番マスタより現在の番号を取得し採番を行う。
     * 採番マスタに現在の値が登録されていない場合は新規番号を登録する。
     * 採番された結果がオーバーフローしている場合、
     * 排他チェックエラーの場合はエラーメッセージを出力する。
     * @param List<Opportunity> newObjects
     * @return エラーメッセージ
     * add sakamoto 2020/03/09
     */
    public void setDXOpportunityNumbering(List<Opportunity> newObjects){
		//現在年月を取得する。
		String yymm = null;
		if (Test.isRunningTest()) {
            // テスト実行時のシステム日付が変更できないためテスト用の値を設定する。
            yymm = '2003';
        } else {
			yymm = String.valueOf(Date.today().year()).substring(2,4)
            							+ String.valueOf(Date.today().month()).leftPad(2,'0');
        }
        
        // COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // 商談のレコードタイプ取得
        Id oppType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId();
        // カスタム表示ラベルより、文字採番順を取得する。
        List<String> baseNumList = System.Label.SAWO_CON_NumberingMaster.split(',');
        
        List<String> recTypeList = new List<String>(); 
        for(Opportunity o : newObjects){
            recTypeList.add(o.recordTypeId);
        }

        M_Sequence__c[] dxNumbering = null;
		String currentNo = null;
        boolean isFirst = false;
        try{
            if(recTypeList.contains(oppType)) {
                // DX商談用の案件番号を採番マスタよりFOR UPDATEで取得する
                dxNumbering = [SELECT SAWO_Numbering_Key__c,SAWO_Numbering_Number__c FROM M_Sequence__c 
                               WHERE SaibanItem__c =: 'DX_商談番号' AND SAWO_Numbering_YYMM__c =:yymm LIMIT 1 FOR UPDATE];
                if(dxNumbering.size() == 0){
                    //連番が取得できなかった場合には新規採番を行う。
                    dxNumbering = createSequence_DX(yymm,baseNumList);
                    currentNo = dxNumbering[0].SAWO_Numbering_Number__c;
                    isFirst = true;
                    System.debug('■■■新規採番した値：'+ currentNo);
                }else{
                    currentNo = dxNumbering[0].SAWO_Numbering_Number__c;
                }
            }
            boolean isErr = false;
            for(Opportunity o : newObjects){
                
                System.debug('■■■採番前の値：'+ currentNo);
                if(o.RecordTypeId != oppType) { continue; }
                if(isFirst){
                    //新規作成した場合には採番処理を行わない
                    isFirst = false;
                }else{
                    //採番処理実施
                    currentNo = editNumbering(currentNo,baseNumList);
                    //採番した結果が最小値の場合エラー
                    if(currentNo == baseNumList.get(0) + baseNumList.get(0) + baseNumList.get(0) + '0' || isErr){
                        isErr = true;
                        //採番した結果が最大値を超えた場合にはエラーメッセージを返却する。
                        o.OpportunityNo__c.addError(System.Label.SAWO_MSG_OpportunityNo_Overflow);
                    }
                }
                o.OpportunityNo__c = yymm + currentNo;
                System.debug('■■■採番後の値：'+ currentNo);
            }
            if(recTypeList.contains(oppType)) {
                //採番マスタ更新
                dxNumbering[0].SAWO_Numbering_Number__c = currentNo;
                update dxNumbering[0];
            }
        }catch(DmlException e){
            for(Opportunity o : newObjects){
                //採番マスタ更新時にエラーが発生した際にエラーメッセー時を出力する。
                o.OpportunityNo__c.addError(System.Label.SAWO_MSG_OpportunityNo_UpdateErr);
            }
        }catch(QueryException e){
            for(Opportunity o : newObjects){
                //採番マスタ更新時にエラーが発生した際にエラーメッセー時を出力する。
                o.OpportunityNo__c.addError(System.Label.SAWO_MSG_OpportunityNo_UpdateErr);
            }           
        }
    }

    /**
     * setDisplayOpportunity 参照用商談作成・更新
     * 商談作成時、参照用商談オブジェクトを商談の内容をコピー作成する。
     * 商談更新時、対応する参照用商談レコードに変更内容を反映する。
     * @param List<Opportunity> newObjects newTriggerの値
     * @parm Boolean isInsert 登録処理判定
     * add mamada 2020/03/23
     */
    public void setDisplayOpportunity(List<Opportunity> newObjects, boolean isInsert){
        // COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // 商談のレコードタイプ取得
        // Id oppType = comTypeManager.getRecordTypeId( 'Opportunity', 'SAWO_DX_Opportunity' );
        Id oppType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId();
        
        List<String> oppList = new List<String>(); 
        for(Opportunity o : newObjects){
            oppList.add(o.Id);
        }

        List<SAWO_DisplayOpportunity__c> displayOpportunityList = new List<SAWO_DisplayOpportunity__c>();
        if(!isInsert) {
            displayOpportunityList = [SELECT Id,
                                             Name,
                                             SAWO_Opportunity__c
                                      FROM SAWO_DisplayOpportunity__c
                                      WHERE SAWO_Opportunity__c IN: oppList 
                                     ];
        }
        Map<String, SAWO_DisplayOpportunity__c> displayOpportunitMap = new Map<String, SAWO_DisplayOpportunity__c>();
        if(displayOpportunityList.size() > 0) {
            for(SAWO_DisplayOpportunity__c dOpp : displayOpportunityList) {
                displayOpportunitMap.put(dOpp.SAWO_Opportunity__c, dOpp);
            }
        }

        List<SAWO_DisplayOpportunity__c> upsertDisplayOpportunityList = new List<SAWO_DisplayOpportunity__c>();
        for(Opportunity o : newObjects){
            if(o.RecordTypeId != oppType) { continue; }
            SAWO_DisplayOpportunity__c displayOpportunity;
            if(!isInsert) {
                displayOpportunity = displayOpportunitMap.get(o.Id);
            } else {
                displayOpportunity = new SAWO_DisplayOpportunity__c();
            }
            displayOpportunity.Accounting_Classification__c =o.Accounting_Classification__c;
            displayOpportunity.AddUpKijun__c=o.AddUpKijun__c;
            displayOpportunity.Area1__c =o.Area1__c;
            displayOpportunity.Area2__c =o.Area2__c;
            displayOpportunity.Area3__c =o.Area3__c;
            displayOpportunity.BusinessUnit__c=o.BusinessUnit__c;
            displayOpportunity.Catergory_HHS__c =o.Catergory_HHS__c;
            displayOpportunity.CompetitionMaker__c=o.CompetitionMaker__c;
            displayOpportunity.CompetitionMaker_Other__c=o.CompetitionMaker_Other__c;
            displayOpportunity.DairiBiko__c =o.DairiBiko__c;
            displayOpportunity.Demander__c=o.Demander__c;
            displayOpportunity.Demonstration__c =o.Demonstration__c;
            displayOpportunity.Design_Department__c =o.Design_Department__c;
            displayOpportunity.ExternalNo__c=o.ExternalNo__c;
            displayOpportunity.FunazumiYoteiDate__c =o.FunazumiYoteiDate__c;
            displayOpportunity.HannyuYoteiDate__c =o.HannyuYoteiDate__c;
            displayOpportunity.HHS_AgencyOwner__c =o.HHS_AgencyOwner__c;
            displayOpportunity.HHS_ApprovalStockNo__c =o.HHS_ApprovalStockNo__c;
            displayOpportunity.HHS_BehhyoKoban__c =o.HHS_BehhyoKoban__c;
            displayOpportunity.HHS_BudgetExistence__c =o.HHS_BudgetExistence__c;
            displayOpportunity.HHS_CommonItem1__c =o.HHS_CommonItem1__c;
            displayOpportunity.HHS_CommonItem2__c =o.HHS_CommonItem2__c;
            displayOpportunity.HHS_EAR__c =o.HHS_EAR__c;
            displayOpportunity.HHS_ELKbn__c =o.HHS_ELKbn__c;
            displayOpportunity.HHS_ExportControlJudgementNo__c=o.HHS_ExportControlJudgementNo__c;
            displayOpportunity.HHS_IChanei__c =o.HHS_IChanei__c;
            displayOpportunity.HHS_JippiShikiri__c=o.HHS_JippiShikiri__c;
            displayOpportunity.HHS_Model1__c=o.HHS_Model1__c;
            displayOpportunity.HHS_Model2__c=o.HHS_Model2__c;
            displayOpportunity.HHS_Model3__c=o.HHS_Model3__c;
            displayOpportunity.HHS_Model4__c=o.HHS_Model4__c;
            displayOpportunity.HHS_ModelOther__c=o.HHS_ModelOther__c;
            displayOpportunity.HHS_OfficeCommunication__c =o.HHS_OfficeCommunication__c;
            displayOpportunity.HHS_OrdersSakiAddress__c =o.HHS_OrdersSakiAddress__c;
            displayOpportunity.HHS_OrdersSakiState__c =o.HHS_OrdersSakiState__c;
            displayOpportunity.HHS_OriginCountry__c =o.HHS_OriginCountry__c;
            displayOpportunity.HHS_PartialFullDeliveryPart__c =o.HHS_PartialFullDeliveryPart__c;
            displayOpportunity.HHS_ProductFamilys__c=o.HHS_ProductFamilys__c;
            displayOpportunity.HHS_PurchaseReserveNo__c =o.HHS_PurchaseReserveNo__c;
            displayOpportunity.HHS_PurchaseReserveRate__c =o.HHS_PurchaseReserveRate__c;
            displayOpportunity.HHS_Quantity1__c =o.HHS_Quantity1__c;
            displayOpportunity.HHS_Quantity2__c =o.HHS_Quantity2__c;
            displayOpportunity.HHS_Quantity3__c =o.HHS_Quantity3__c;
            displayOpportunity.HHS_Quantity4__c =o.HHS_Quantity4__c;
            displayOpportunity.HHS_SaleReserveNo__c =o.HHS_SaleReserveNo__c;
            displayOpportunity.HHS_SaleReserveRate__c =o.HHS_SaleReserveRate__c;
            displayOpportunity.HHS_ServiceOffice__c =o.HHS_ServiceOffice__c;
            displayOpportunity.HHS_Supplier__c=o.HHS_Supplier__c;
            displayOpportunity.InquiryClassification__c =o.InquiryClassification__c;
            displayOpportunity.InquiryInfo__c =o.InquiryInfo__c;
            displayOpportunity.Keishiki__c=o.Keishiki__c;
            displayOpportunity.KokyakuKadai__c=o.KokyakuKadai__c;
            displayOpportunity.SAWO_LeadSource__c =o.LeadSource;
            displayOpportunity.Name =o.Name;
            displayOpportunity.NohinKenshuOwner__c=o.NohinKenshuOwner__c;
            displayOpportunity.NouhinDBStatus__c=o.NouhinDBStatus__c;
            displayOpportunity.NouhinTime__c=o.NouhinTime__c;
            displayOpportunity.OppIC__c =o.OppIC__c;
            displayOpportunity.OpportunityNo__c =o.OpportunityNo__c;
            displayOpportunity.OrdersAccuracy__c=o.OrdersAccuracy__c;
            displayOpportunity.OwnerId=o.OwnerId;
            displayOpportunity.Predefined_Classification__c =o.Predefined_Classification__c;
            displayOpportunity.Quantity__c=o.Quantity__c;
            displayOpportunity.SalesChannel__c=o.SalesChannel__c;
            displayOpportunity.SAWO_AccountName__c=o.AccountId;
            displayOpportunity.SAWO_AdminSystem__c=o.SAWO_AdminSystem__c;
            displayOpportunity.SAWO_Agency__c =o.SAWO_Agency__c;
            displayOpportunity.SAWO_Approval_Category__c=o.SAWO_Approval_Category__c;
            displayOpportunity.SAWO_BudgetAccuracy__c =o.SAWO_BudgetAccuracy__c;
            displayOpportunity.SAWO_CloseDate__c=o.CloseDate;
            displayOpportunity.SAWO_Competition__c=o.SAWO_Competition__c;
            displayOpportunity.SAWO_Conflict_information_memo__c=o.SAWO_Conflict_information_memo__c;
            displayOpportunity.SAWO_CurrencyIsoCode__c=o.CurrencyIsoCode;
            displayOpportunity.SAWO_Currentlaw_PO__c=o.SAWO_Currentlaw_PO__c;
            displayOpportunity.SAWO_CustomerPONumber__c =o.SAWO_CustomerPONumber__c;
            displayOpportunity.SAWO_Destination_Country__c=o.SAWO_Destination_Country__c;
            displayOpportunity.SAWO_Evaluation_Lending_Flag__c=o.SAWO_Evaluation_Lending_Flag__c;
            displayOpportunity.SAWO_Fail_Memo__c=o.SAWO_Fail_Memo__c;
            displayOpportunity.SAWO_FCA_Point__c=o.SAWO_FCA_Point__c;
            displayOpportunity.SAWO_Filnal_Delivery_Date__c =o.SAWO_Filnal_Delivery_Date__c;
            displayOpportunity.SAWO_FMS_Branch__c =o.SAWO_FMS_Branch__c;
            displayOpportunity.SAWO_GeneralCheckBox1__c =o.SAWO_GeneralCheckBox1__c;
            displayOpportunity.SAWO_GeneralCheckBox2__c =o.SAWO_GeneralCheckBox2__c;
            displayOpportunity.SAWO_GeneralCheckBox3__c =o.SAWO_GeneralCheckBox3__c;
            displayOpportunity.SAWO_GeneralDate1__c =o.SAWO_GeneralDate1__c;
            displayOpportunity.SAWO_GeneralText3__c =o.SAWO_GeneralText3__c;
            displayOpportunity.SAWO_GeneralText4__c =o.SAWO_GeneralText4__c;
            displayOpportunity.SAWO_Install_Acceptance_Scheduled_Date__c=o.SAWO_Install_Acceptance_Scheduled_Date__c;
            displayOpportunity.SAWO_Opps_Outline__c =o.SAWO_Opps_Outline__c;
            displayOpportunity.SAWO_Order_Reason__c =o.SAWO_Order_Reason__c;
            displayOpportunity.SAWO_PrimaryQuote__c =o.SAWO_MainQuote__c;
            displayOpportunity.SAWO_Probability__c=o.Probability;
            displayOpportunity.SAWO_Product_Use__c=o.SAWO_Product_Use__c;
            displayOpportunity.SAWO_ResponseDate__c =o.SAWO_ResponseDate__c;
            displayOpportunity.SAWO_Sales_Date__c =o.SAWO_Sales_Date__c;
            displayOpportunity.SAWO_Sales_Request_FCA__c=o.SAWO_Sales_Request_FCA__c;
            displayOpportunity.SAWO_ScheduledCompletionDate__c=o.SAWO_ScheduledCompletionDate__c;
            displayOpportunity.SAWO_Shipping_ExpectedDate__c=o.SAWO_Shipping_ExpectedDate__c;
            displayOpportunity.SAWO_StageName__c=o.StageName;
            displayOpportunity.SAWO_Trustee_Inspection_Company__c =o.SAWO_Trustee_Inspection_Company__c;
            displayOpportunity.SAWO_User_Request_FCA__c =o.SAWO_User_Request_FCA__c;
            displayOpportunity.Subcategory__c =o.Subcategory__c;
            displayOpportunity.Subsubcatergory_HHS__c =o.Subsubcatergory_HHS__c;
            displayOpportunity.SuetsukeKanryoDate__c=o.SuetsukeKanryoDate__c;
            displayOpportunity.SuetsukeStartDate__c =o.SuetsukeStartDate__c;
            displayOpportunity.SummaryTable_WeavingFlag__c=o.SummaryTable_WeavingFlag__c;
            displayOpportunity.TehaiYoteiDate__c=o.TehaiYoteiDate__c;
            displayOpportunity.UriageYoteiBi__c =o.UriageYoteiBi__c;
            displayOpportunity.WorkReportURL__c =o.WorkReportURL__c;
            displayOpportunity.YusoHoShiki__c =o.YusoHoShiki__c;
            displayOpportunity.ZyuyoShukkaRequestDate__c=o.ZyuyoShukkaRequestDate__c;

            if(isInsert) {
                displayOpportunity.SAWO_Opportunity__c = o.Id; 
            } 
            upsertDisplayOpportunityList.add(displayOpportunity);
        }
        
        if(upsertDisplayOpportunityList.size() > 0) {
            upsert upsertDisplayOpportunityList;
        }
    }

    /**
     * deleteDisplayOpportunity 参照用商談削除
     * 商談削除時、対応する参照用商談レコードを削除する。
     * @param List<Opportunity> oldObjects oldTriggerの値
     * add mamada 2020/03/23
     */
    public void deleteDisplayOpportunity(List<Opportunity> oldObjects){

        List<String> oppList = new List<String>(); 
        for(Opportunity o : oldObjects){
            oppList.add(o.Id);
        }

        List<SAWO_DisplayOpportunity__c> displayOpportunityList  = [SELECT Id
                                                                    FROM SAWO_DisplayOpportunity__c
                                                                    WHERE SAWO_Opportunity__c IN: oppList]; 

        if(displayOpportunityList.size() > 0) {
            delete displayOpportunityList;
        }                                                            

    }

    /**
     * setConsumptionTax 消費税率設定
     * 商談作成時、使用通貨ごとの消費税率を設定する。
     * @param List<Opportunity> newObjects newTriggerの値
     * add mamada 2020/03/23
     */
    public void setConsumptionTax(List<Opportunity> newObjects){

        List<String> oppOwnerList = new List<String>(); 
        for(Opportunity o : newObjects){
            System.debug('★★★：' + o.OwnerId);
            oppOwnerList.add(o.OwnerId);
        }
        
        List<User> userList = [SELECT Id, DefaultCurrencyIsoCode FROM User WHERE Id IN: oppOwnerList];
        Map<String, String> userCurrencyMap = new Map<String, String>();
        for(User u : userList) {
            userCurrencyMap.put(u.Id, u.DefaultCurrencyIsoCode);
        }

        // カスタム設定「通過別消費税率設定」を呼び出す
        List<SAWO_CurrencyConsumptionTaxConfig__c> taxList = [SELECT Name, SAWO_Consumption_Tax__c FROM SAWO_CurrencyConsumptionTaxConfig__c];
        Map<String, Decimal> currencyTaxMap = new Map<String, Decimal>();
        for(SAWO_CurrencyConsumptionTaxConfig__c ct : taxList) {
            currencyTaxMap.put(ct.Name, ct.SAWO_Consumption_Tax__c);
        }

        for(Opportunity o : newObjects) {
            if(o.SAWO_Consumption_Tax__c == null) {
                o.SAWO_Consumption_Tax__c = currencyTaxMap.get(userCurrencyMap.get(o.OwnerId));
            }
        }

    }
    
   /*
    * setDefaultPricebook_DX 初期価格表の設定(DX)
    * 商談に設定された職制からカスタム設定「職性別設定」を呼び出し
    * そこに設定されている価格表を商談に設定する
    * @param List<Opportunity> newObjects newTriggerの値
    * add sakamoto 2020/05/19
    */
    public void setDefaultPricebook_DX(List<Opportunity> newObjects){
		
        // 商談のレコードタイプ取得
		// COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // Id oppType = comTypeManager.getRecordTypeId( 'Opportunity', 'SAWO_DX_Opportunity' );
        Id oppType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId();

        Id userId = UserInfo.getUserId();
        User user = [SELECT Shokusei__c FROM User WHERE Id = :userId];
        
        // 商談に設定されている職制のリストを作成する
        List<String> adminSystemList = new List<String>();
        for(Opportunity opp : newObjects) {
            if(opp.SAWO_AdminSystem__c != null) {
                adminSystemList.add(opp.SAWO_AdminSystem__c);
            }
        }

        if(adminSystemList.size() == 0) {
            adminSystemList.add(user.Shokusei__c);
        }
        
        Map<String, String> adminSystemMap = new Map<String, String>();
        List<String> defaultPriceBookList = new List<String>();
        List<ShokuseiConfig__c> sList = [SELECT Name, SAWO_DefaultPriceBook__c
                                         FROM ShokuseiConfig__c
                                         WHERE Name = :adminSystemList
                                        ];
        
        for(ShokuseiConfig__c sc : sList) {
            if(!String.isBlank(sc.SAWO_DefaultPriceBook__c)) {
                adminSystemMap.put(sc.Name, sc.SAWO_DefaultPriceBook__c);
            }
        }
        
        List<Pricebook2> pricebookList = [Select Id, Name 
                                          FROM Pricebook2 
                                          WHERE Name IN :adminSystemMap.values()                                                 
                                          AND IsActive = TRUE];
        
        Map<String, String> pricebookMap = new Map<String, String>();
        for(Pricebook2 pricebook : pricebookList) {
        	pricebookMap.put(pricebook.Name, pricebook.Id);
        }
        
        for(Opportunity opp : newObjects) {
            if(opp.RecordTypeId != oppType) {continue;}
            if(String.isNotBlank(opp.Pricebook2Id)){
                continue;
            }
              
            System.debug('★★adminSystemMap:' + adminSystemMap);
            System.debug('★★pricebookMap:' + pricebookMap);           
            if(!String.isBlank(adminSystemMap.get(opp.SAWO_AdminSystem__c))) {
                opp.Pricebook2Id = pricebookMap.get(adminSystemMap.get(opp.SAWO_AdminSystem__c));
            } else if(!String.isBlank(user.Shokusei__c)){
                opp.Pricebook2Id = pricebookMap.get(adminSystemMap.get(user.Shokusei__c));
            }
            System.debug('★★SAWO_AdminSystem__c:' + opp.SAWO_AdminSystem__c);
            System.debug('★★Pricebook2Id:' + opp.Pricebook2Id);
        }

    }
    
    /**
     * editNumbering
     * 採番処理実施
     * @param no
     * @return String 新規に採番された番号
     * add sakamoto 2020/03/09
     */
    private String editNumbering(String no,List<String> chrList){
        //現在の番号を1桁毎に分割する。
        List<String> noList = new List<String>();
        for(Integer i = 0 ; i < no.length() ; i++){
            noList.add(no.substring(i,i+1));
        }
        //1桁目から順に採番を行う。
        String chr = null;
        String retChr = '';
        boolean isNext = false;
        for(Integer i = noList.size() - 1 ; 0 <= i ; i--){
            chr = noList.get(i);
    	    //数字の場合の採番 0が返却されたら次の桁を実施する。
            if(chr.isNumeric()){
                chr = editNumberingInt(chr);
                noList.set(i,chr);
                if(chr != '0'){
                    break;//採番後の文字が0以外の場合には次の桁の処理は行わない。
                }
            }else{
	        	//文字の場合の採番 文字リストの最後の値が返却されたら次の桁を実施する。
    			chr = editNumberingAlphabet(chr, chrList);
                noList.set(i,chr);
                if(chr != chrList.get(0)){
                    break;//採番後の文字が最初の文字以外の場合には次の桁の処理は行わない。
                }
            }
        }
        for(String c:noList){
            retChr += c;
        }

        //採番した値を返却する
        return retChr;
    }
    
    /**
     * editNumberingInt
     * 数字を1つ繰り上げる
     * 10になった場合には0を返却する
     * @param 採番を行う値
     * @return 採番後の値
     */
    private String editNumberingInt(String no){
        //引数の文字列を数値に変換する
        Integer intNo = Integer.valueOf(no);
        intNo++;
        if(intNo >= 10){
            //数値が10となった場合には0を設定する。
            intNo = 0;
        }
        return String.valueOf(intNo);
    }
    
    /**
     * editNumberingAlphabet
     * 文字を1つ繰り上げる
     * 文字列リストの最後の値になった場合には最初の値を返却する
     * @param 採番を行う値
     * @param 採番文字列のリスト
     * @return 採番後の値
     * add sakamoto 2020/03/09
     */
    private String editNumberingAlphabet(String no,List<String> chrList){

        boolean isChange = false;//変更判定フラグ
        for(String chr :chrList){
            //文字列リストを順に処理する
            if(isChange){
                //変更対象の場合、文字列を入れ替える
                no = chr;
                isChange = false;
                break;
            }

            if(no == chr){
                //文字が一致する場合次の文字へ変更するフラグを立てる
                isChange = true;
            }
        }
        if(isChange){
           //現在の文字が最後の文字の場合最初の文字を設定する。
            no = chrList[0];
        }
        return no;
    }
    
    /**
     * 採番マスタ作成処理
     * 新規番号で採番を行う。
     * @param yymm　採番時の年月
     * @param chrList 採番順の文字列
     * @return 新規発番した番号
     * add sakamoto 2020/03/09
     */
    private M_Sequence__c[] createSequence_DX(String yymm ,List<String> chrList){
        //新規採番を発行する。
        String no = chrList.get(0) + chrList.get(0) + chrList.get(0) + '0';
        M_Sequence__c[] dxNumbering = new M_Sequence__c[1];
        dxNumbering[0] = new M_Sequence__c();
        dxNumbering[0].SaibanItem__c = 'DX_商談番号';
        dxNumbering[0].SAWO_Numbering_YYMM__c = yymm;
        dxNumbering[0].SAWO_Numbering_Number__c = no;
        dxNumbering[0].SAWO_Numbering_Key__c = dxNumbering[0].SaibanItem__c + yymm;//キーを設定
        dxNumbering[0].Name = dxNumbering[0].SAWO_Numbering_Key__c;
        insert dxNumbering;
        return dxNumbering;
    }

    /**
     * 商談フェーズ変更時S4連携処理
     * 商談レコードタイプがDX用の場合
     * フェーズが04,05,06へ変更されたタイミングでS4へ連携する。
     * 
     * S4 linkage process when changing negotiation phase
     * When the opportunity record type is for DX
     * Cooperate with S4 at the timing when the phase is changed to 04, 05, 06.
     */
    public void s4Linkage_changePhase(List<Opportunity> oldObjects, List<Opportunity> newObjects){
		// COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // Id oppRecType = comTypeManager.getRecordTypeId( 'Opportunity', 'SAWO_DX_Opportunity' );
        Id oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId();
        List<ShokuseiConfig__c> confList = [Select Id, name FROM ShokuseiConfig__c WHERE SA_S4LinkageFlg__c = true];
        Set<String> confSet = new Set<String>();
        for(ShokuseiConfig__c conf:confList){
            confSet.add(conf.name);
        }        
        
        Integer cnt = 0;
        for(Opportunity newOpp:newObjects){
            if(newOpp.RecordTypeId == oppRecType && confSet.contains(newOpp.SAWO_AdminSystem__c)){
                Opportunity oldOpp = oldObjects.get(cnt);
				//00-03所要登録承認された際にS4連携フローを起動する。
				//When the phase is 00-03_Approved　, S4 linkage flow is started.
				s4Linkage_00_03Approved(oldOpp,newOpp);
                //フェーズが04へ変更された際S4連携フローを起動する。
                //When the phase is changed to 04, S4 linkage flow is started.
                s4Linkage_stage4(oldOpp,newOpp);
                //フェーズが05へ変更された際S4連携フローを起動する。
        		//When the phase is changed to 05, S4 linkage flow is started.
        		s4Linkage_stage5(oldOpp,newOpp);
        		//フェーズが06Won、06Lost、06Cancelへ変更された際S4連携フローを起動する。
        		//When the phase is changed to 06Won,06Lost,06Cancel S4 linkage flow is started.
        		s4Linkage_stage6(oldOpp,newOpp);
            }
            cnt++;
        }        
    }    

    /**
     * 00,01,02,03所要登録時連携処理/S4 Linkage phase 00,01,02,03
     * 承認ステータスが「00-03所要登録申請中」から「00-03所要登録承認済み」へ変更された場合下記処理を実行する。
     * ・フロー「CO_OvcOpportunityStage04」を実行する。
     * 
     * If the SAWO_Approval_Status__c changed "00-03_Applying"->"00-03_Approved" execute the following process.
     * 　Execute the flow "CO_OvcOpportunityStage04".
     * 
     **/
    private void s4Linkage_00_03Approved(Opportunity oldOpp, Opportunity newOpp){
        if(oldOpp.SAWO_Approval_Status__c == '00-03_Applying' && newOpp.SAWO_Approval_Status__c == '00-03_Approved'){
            Map<String,String> inputMap = new Map<String,String>();
            inputMap.put('recordId',newOpp.Id);
            System.debug('フロー4処理実行開始');
            if(test.isRunningTest()){
                System.debug('フロー4 テスト時はフローが起動しないようにする。');    
            }else{
                Flow.Interview s4Flow = Flow.Interview.createInterview('CO_OvcOpportunityStage04', inputMap);
                s4Flow.start();
            }
            System.debug('フロー4処理実行完了');
        }
    }    
    
    /**
     * 商談フェーズ4変更時S4連携/S4 Linkage when changing negotiation phase 4
     * 商談フェーズが4かつステージ４承認フラグがtrueに変更された場合下記処理を実行する。
     * ・フロー「CO_OvcOpportunityStage04」を実行する。
     * 
     * If the negotiation phase is 4 and the stage 4 approval flag is changed to true, execute the following process.
     * 　Execute the flow "CO_OvcOpportunityStage04".
     * 
     **/
    private void s4Linkage_stage4(Opportunity oldOpp, Opportunity newOpp){
        if(newOpp.StageName == '04' && newOpp.SAWO_ApprovalStage4Flag__c == true){
            if(newOpp.StageName != oldOpp.StageName 
               && newOpp.SAWO_ApprovalStage4Flag__c != oldOpp.SAWO_ApprovalStage4Flag__c ){
                Map<String,String> inputMap = new Map<String,String>();
                inputMap.put('recordId',newOpp.Id);
                System.debug('フロー4処理実行開始');
                if(test.isRunningTest()){
                    System.debug('フロー4 テスト時はフローが起動しないようにする。');                    
                }else{
                    Flow.Interview s4Flow = Flow.Interview.createInterview('CO_OvcOpportunityStage04', inputMap);
                    s4Flow.start();
                }
                System.debug('フロー4処理実行完了');
            }
        }
    }

    /**
     * 商談フェーズ5変更時S4連携/S4 Linkage when changing negotiation phase 5
     * 商談フェーズが5に変更された場合下記処理を実行する。
     * ・フロー「CO_OvcOpportunityStage05」を実行する。
     * 
     * If the negotiation phase is 5  changed to true, execute the following process.
     * 　Execute the flow "CO_OvcOpportunityStage05".
     * 
     **/
    private void s4Linkage_stage5(Opportunity oldOpp, Opportunity newOpp){
        if(newOpp.StageName == '05' && oldOpp.StageName == '04' ){
            Map<String,String> inputMap = new Map<String,String>();
            inputMap.put('recordId',newOpp.Id);
            System.debug('フロー5処理実行開始');
            if(test.isRunningTest()){
                System.debug('フロー5 テスト時はフローが起動しないようにする。');                    
            }else{
                Flow.Interview s4Flow = Flow.Interview.createInterview('CO_OvcOpportunityStage05', inputMap);
                s4Flow.start();
            }
            System.debug('フロー5処理実行完了');
        }
    }

    /**
     * 商談フェーズ6変更時S4連携/S4 Linkage when changing negotiation phase 6
     * 商談フェーズが6かつステージ6承認フラグがtrueに変更された場合下記処理を実行する。
     * ・フロー「CO_OvcOpportunityStage06」を実行する。
     * 
     * If the negotiation phase is 6 and the stage6approval flag is changed to true, execute the following process.
     * 　Execute the flow "CO_OvcOpportunityStage04".
     * 
     **/
    private void s4Linkage_stage6(Opportunity oldOpp, Opportunity newOpp){
        if(newOpp.StageName == '06Won' && newOpp.SAWO_ApprovalStage6Flag__c == true){
            if(newOpp.StageName != oldOpp.StageName 
               && newOpp.SAWO_ApprovalStage6Flag__c != oldOpp.SAWO_ApprovalStage6Flag__c ){
                Map<String,String> inputMap = new Map<String,String>();
                inputMap.put('recordId',newOpp.Id);
                System.debug('フロー6処理実行開始');
                if(oldOpp.StageName == '04' || oldOpp.StageName == '05'){
                    if(test.isRunningTest()){
                        System.debug('フロー6 テスト時はフローが起動しないようにする。');                    
                    }else{
                        Flow.Interview s4Flow = Flow.Interview.createInterview('CO_OvcOpportunityStage06', inputMap);
                        s4Flow.start();
                    }
                }else{
                    //00→06受注申請後の処理
                    if(test.isRunningTest()){
                        System.debug('フロー6 テスト時はフローが起動しないようにする。');                    
                    }else{
                        Flow.Interview s4Flow = Flow.Interview.createInterview('CO_OvcOpportunityStage06Direct', inputMap);
                        s4Flow.start();
                    }
                }
                System.debug('フロー6処理実行完了');
            }
        }else if((newOpp.StageName == '06Lost' || newOpp.StageName == '06Cancel' ) && newOpp.SAWO_ApprovalStage6Flag__c == true){
            if(newOpp.StageName != oldOpp.StageName 
               && !String.isBlank( newOpp.CO_ovcSAPSalesOrderNumber__c) ){
                                   Map<String,String> inputMap = new Map<String,String>();
                inputMap.put('recordId',newOpp.Id);
                System.debug('フロー6失注処理実行開始');
                if(test.isRunningTest()){
                    System.debug('フロー6失注 テスト時はフローが起動しないようにする。');                    
                }else{
                    Flow.Interview s4Flow = Flow.Interview.createInterview('CO_OvcOpportunityStage06Lost', inputMap);
                    s4Flow.start();
                }
                System.debug('フロー6失注処理実行完了');
            }
        }
    }
    
    /** 
     * setInitializeField　初期値設定　Initialize
     * 商談新規登録時に項目の初期化を行う。
     * コピー元の値を初期化する。
     * Initialize items when registering new business negotiations.
     * Initialize the copy source value.
     *
     * @param List<Opportunity> newObjects
     */
    public void setInitializeFieldOvc(List<Opportunity> newObjects){
        for(Opportunity opp:newObjects){
            opp.CO_ovcChatter_ID__c = null;
            opp.CO_ovcUpdateFlag__c = null;
            opp.CO_ovcSendStatus__c = null;
            opp.CO_ovcSendDate__c = null;
            opp.CO_ovcPostDate__c = null;
            opp.CO_ovcSendStatus_MTE__c = null;
            opp.CO_ovcSendDate_MTE__c = null;
            opp.CO_ovcPostDate_MTE__c = null;
            opp.CO_ovcSAPSalesOrderNumber__c = null;
            opp.CO_SAPSalesOrderNumber_MTE__c = null;
        }
        
    }
    
    /** 
     * setOvcField　Overcast用項目設定
     * 
     * Overcast連携用に項目の設定を行う
     *
     * @param List<Opportunity> oldObjects
     * @param List<Opportunity> newObjects
     */
    public void setOvcField(List<Opportunity> oldObjects, List<Opportunity> newObjects){
		// COM_RecordTypeManager comTypeManager = new COM_RecordTypeManager();
        // Id oppRecType = comTypeManager.getRecordTypeId( 'Opportunity', 'SAWO_DX_Opportunity' );
        Id oppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId();

        Map<Id,Opportunity> newOppMap = new Map<Id,Opportunity>();
        List<Id> oppIdList = new List<Id>();
        for(Opportunity newOpp:newObjects){
            if(newOpp.RecordTypeId == oppRecType){
                oppIdList.add(newOpp.Id);
                newOppMap.put(newOpp.Id,newOpp);
            }
        }
        if(oppIdList.size() > 0){
            setOvcField_OppLineItem(oppIdList,newOppMap);
            setOvcField(oppIdList,newOppMap);
        }
    }
    
    /**
     * setOvcField_OppLineItem
     * Overcast用商談商品更新
     * 商談に紐つく商談商品を更新する。
     * 
     */
    private void setOvcField_OppLineItem(List<Id> oppIdList,Map<Id,Opportunity> newOppMap){
        Boolean isUpd = false;
        List<OpportunityLineItem> oppItemList = 
            [select id, SAWO_RejectionReason__c, Opportunity.StageName from OpportunityLineItem where Opportunity.Id in : oppIdList ];
        for(OpportunityLineItem oli : oppItemList ){
            Opportunity newOpp = newOppMap.get(oli.OpportunityId);
            if(newOpp.StageName == '06Lost' || newOpp.StageName == '06Cancel'){
                oli.SAWO_RejectionReason__c = 'Z1';
                isUpd = true;
            }
        }
        if(isUpd){
            Update oppItemList;
        }
    }
    
    /**
     * setOvcField
     * Overcast連携用項目設定
     * 
     */
    private void setOvcField(List<Id> oppIdList,Map<Id,Opportunity> newOppMap){
        List<ShokuseiConfig__c> confList = [Select Id, name,SA_LocalCorporationBPcode__c,SA_S4CompanyCode__c FROM ShokuseiConfig__c WHERE SA_S4LinkageFlg__c = true];
        Map<String,ShokuseiConfig__c> orgMap = new Map<String,ShokuseiConfig__c>();
        for(ShokuseiConfig__c org:confList){
            orgMap.put(org.Name,org);
        }

        for(Id oppId:oppIdList){
            Opportunity opp = newOppMap.get(oppId);
            ShokuseiConfig__c org = orgMap.get(opp.SAWO_AdminSystem__c);
            //S4連携に値が設定されていない場合、職制別設定のS4会社コードを設定する。
            if( !String.isEmpty(opp.SAWO_AdminSystem__c) && String.isEmpty(opp.SAWO_S4Cooperation__c) && 
               org != null){
                opp.SAWO_S4Cooperation__c = org.SA_S4CompanyCode__c;
            }
            //MTE連携対象で職制に設定があり、受注先（BPコード）(STE)に値が無い場合、受注先（BPコード）(STE)に職制別設定の現法BPコードを設定する。
            if( !String.isEmpty(opp.SAWO_AdminSystem__c) && String.isEmpty(opp.SAWO_Order_BPcode__c) && 
               !String.isEmpty(opp.SAWO_S4Cooperation__c) && opp.SAWO_S4Cooperation__c !='01' && org != null){
                opp.SAWO_Order_BPcode__c = org.SA_LocalCorporationBPcode__c;
            }            
        }
        
    }
    
}