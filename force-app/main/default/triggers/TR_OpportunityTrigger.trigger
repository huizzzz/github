trigger TR_OpportunityTrigger on Opportunity (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    CL_TriggerUtil util = new CL_TriggerUtil();    //[Add]2016.09.15 Toyoda CAS-HiSAS組織統合
    //if( util.isHiSASUser()){    //[Add]2016.09.15 Toyoda CAS-HiSAS組織統合、[Add]2017.02.02 Kakino 医用・アジア
    System.debug('★：' + util.isHiSASUser());
    System.debug('★：' + isJTLBatch() );
    if( util.isHiSASUser(CL_TriggerUtil.p.Name) && !isJTLBatch()){    //modify 2019/06/18 tyo バッチユーザでJTLデータ投入するアクセス対応
        TriggerConfig__c tr = TriggerConfig__c.getInstance('TriggerStop');
        //if(tr.OpportunityTrigger__c){return ;}
        if(tr==null || tr.OpportunityTrigger__c){return ;}    //[Mod]2016.09.15 Toyoda CAS-HiSAS組織統合

        CL_OpportunityTriggerHandler handler = new CL_OpportunityTriggerHandler();

        /* Before Insert */
        if(Trigger.isInsert && Trigger.isBefore){
            List<Opportunity> dxOpportunitiesNew = new List<Opportunity>();
            List<Opportunity> nonDXOpportunitiesNew = new List<Opportunity>();

            for(Opportunity opp : Trigger.new){
                if(opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId()){
                    dxOpportunitiesNew.add(opp);  
                }else{
                    nonDXOpportunitiesNew.add(opp);
                }
            }
            if(dxOpportunitiesNew.size() > 0){
                // if(!util.isAsiaUser()){
                if(!util.isAsiaUser(CL_TriggerUtil.p.Name)){
                    // handler.oppDefaultPricebook(Trigger.new);
                    handler.setDefaultPricebook_DX(dxOpportunitiesNew);
                }
                //採番(INSERTフラグON)
                // if(util.isAsiaUser()){
                if(util.isAsiaUser(CL_TriggerUtil.p.Name)){
                    handler.oppNumberSaibanAsia(Trigger.old, dxOpportunitiesNew, TRUE);
                }else{
                    // handler.oppNumberSaiban(Trigger.old, Trigger.new, TRUE);
                    handler.setDXOpportunityNumbering(dxOpportunitiesNew);
                }
                // 予定月更新
                handler.oppYoteigetsuKoshinInsert(dxOpportunitiesNew,CL_TriggerUtil.p.Name);
                // 本体台数更新処理
                handler.updateHontaiQuantity(dxOpportunitiesNew,CL_TriggerUtil.p.Name);
                // デフォルト値セット
                if(util.isHHSUser(CL_TriggerUtil.p.Name)){
                    // handler.oppHHSDefalt(Trigger.new, TRUE);
                }else{
                    handler.oppDefalt(dxOpportunitiesNew,TRUE);
                }
                handler.setConsumptionTax(dxOpportunitiesNew);
                // Overcast用項目初期化/Initialize items for Overcast
                handler.setInitializeFieldOvc(Trigger.new);
                // DXS4連携用項目更新
                handler.setOvcField(null, Trigger.new);
            }
            if(nonDXOpportunitiesNew.size() > 0){
                //採番(INSERTフラグON)
                // if(util.isAsiaUser()){
                if(util.isAsiaUser(CL_TriggerUtil.p.Name)){
                    handler.oppNumberSaibanAsia(Trigger.old, nonDXOpportunitiesNew, TRUE);
                }else{
                    // handler.oppNumberSaiban(Trigger.old, Trigger.new, TRUE);
                    handler.setDXOpportunityNumbering(nonDXOpportunitiesNew);
                }
                // SAP マスタチェック
                handler.SAPMasterCheck(nonDXOpportunitiesNew);
            
                // 予定月更新
                handler.oppYoteigetsuKoshinInsert(nonDXOpportunitiesNew,CL_TriggerUtil.p.Name);
                // 本体台数更新処理
                handler.updateHontaiQuantity(nonDXOpportunitiesNew,CL_TriggerUtil.p.Name);
                // デフォルト値セット
                if(util.isHHSUser(CL_TriggerUtil.p.Name)){
                    // handler.oppHHSDefalt(Trigger.new, TRUE);
                }else{
                    handler.oppDefalt(nonDXOpportunitiesNew,TRUE);
                }
                handler.setConsumptionTax(nonDXOpportunitiesNew);
            }

        }
        /* After Insert */
        else if(Trigger.isInsert && Trigger.isAfter){
            // 他決後続処理(INSERTフラグON)
            handler.TaketsuKozoku(Trigger.old, Trigger.new, TRUE);
            // 既納品フォロー対象外
            handler.AssetFollowTaishogai(Trigger.new);
            // 引合連絡票更新
            handler.ReturnICf(Trigger.new);
            // DX_参照用商談作成
            handler.setDisplayOpportunity(Trigger.new, TRUE);
            
        }
        /* Before Update */
        else if(Trigger.isUpdate && Trigger.isBefore){
            List<Opportunity> dxOpportunitiesOld = new List<Opportunity>();
            List<Opportunity> dxOpportunitiesNew = new List<Opportunity>();
            List<Opportunity> nonDXOpportunitiesOld = new List<Opportunity>();
            List<Opportunity> nonDXOpportunitiesNew = new List<Opportunity>();
            Map<Id,Opportunity> dxOpportunitiesMapNew = new Map<Id,Opportunity>();
            Map<Id,Opportunity> dxOpportunitiesMapOld = new Map<Id,Opportunity>();
            Map<Id,Opportunity> nonDXOpportunitiesMapOld = new Map<Id,Opportunity>();
            Map<Id,Opportunity> nonDXOpportunitiesMapNew = new Map<Id,Opportunity>();

            for(Opportunity opp : Trigger.old){
                if(opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId()){
                    dxOpportunitiesOld.add(opp);
                    dxOpportunitiesMapOld.put(opp.Id, opp);
                }else{
                    nonDXOpportunitiesOld.add(opp);
                    nonDXOpportunitiesMapOld.put(opp.Id, opp);  
                }
            }
            for(Opportunity opp : Trigger.new){
                if(opp.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SAWO_DX_Opportunity').getRecordTypeId()){
                    dxOpportunitiesNew.add(opp);  
                    dxOpportunitiesMapNew.put(opp.Id, opp);  
                }else{
                    nonDXOpportunitiesNew.add(opp);
                    nonDXOpportunitiesMapNew.put(opp.Id, opp);
                }
            }
            if(dxOpportunitiesNew.size() > 0 && dxOpportunitiesOld.size() > 0){
                // 2017/07/12 toshima add 配下予実の職制更新
                handler.DXupdateBudgetShokusei(dxOpportunitiesMapOld,dxOpportunitiesMapNew);
                // 本体台数更新処理
                handler.updateHontaiQuantity(dxOpportunitiesNew,CL_TriggerUtil.p.Name);
                //採番(INSERTフラグFALSE)
                // if(util.isAsiaUser()){
                if(util.isAsiaUser(CL_TriggerUtil.p.Name)){
                    handler.oppNumberSaibanAsia(dxOpportunitiesOld, dxOpportunitiesNew, FALSE);
                    handler.poNumberSibanAsia(dxOpportunitiesOld, dxOpportunitiesNew);
                    handler.authorizedNoSibanAsia(dxOpportunitiesOld, dxOpportunitiesNew);
                }
                //SAP連携日時登録
                handler.oppSAPrenkeinichiji(dxOpportunitiesOld, dxOpportunitiesNew, FALSE);
                // 予定月更新
                handler.oppYoteigetsuKoshinUpdate(dxOpportunitiesMapOld, dxOpportunitiesNew,CL_TriggerUtil.p.Name);
                // 装置名更新Y15
                handler.ChangeDeviceType(dxOpportunitiesOld, dxOpportunitiesNew);
                // デフォルト値セット
                // if(util.isHHSUser()){
                if(util.isHHSUser(CL_TriggerUtil.p.Name)){
                    // 引合連絡票更新(案件変更反映)
                    handler.ReturnIC(dxOpportunitiesNew);
                    handler.oppHHSupdate(dxOpportunitiesMapOld,dxOpportunitiesMapNew);
                }else{
                    handler.oppDefalt(dxOpportunitiesNew,FALSE);
                }
                // DXS4連携用項目更新
                handler.setOvcField(dxOpportunitiesOld, dxOpportunitiesNew);
                
            }
            if(nonDXOpportunitiesOld.size() > 0 && nonDXOpportunitiesNew.size() > 0){
                // 2017/07/12 toshima add 配下予実の職制更新
                handler.nonDXupdateBudgetShokusei(nonDXOpportunitiesMapOld,nonDXOpportunitiesMapNew);
                // 本体台数更新処理
                handler.updateHontaiQuantity(nonDXOpportunitiesNew,CL_TriggerUtil.p.Name);
                //採番(INSERTフラグFALSE)
                // if(util.isAsiaUser()){
                if(util.isAsiaUser(CL_TriggerUtil.p.Name)){
                    handler.oppNumberSaibanAsia(nonDXOpportunitiesOld, nonDXOpportunitiesNew, FALSE);
                    handler.poNumberSibanAsia(nonDXOpportunitiesOld, nonDXOpportunitiesNew);
                    handler.authorizedNoSibanAsia(nonDXOpportunitiesOld, nonDXOpportunitiesNew);
                }
                // SAP マスタチェック
                handler.SAPMasterCheck(nonDXOpportunitiesNew);
                //SAP連携日時登録
                handler.oppSAPrenkeinichiji(nonDXOpportunitiesOld, nonDXOpportunitiesNew, FALSE);
                // 予定月更新
                handler.oppYoteigetsuKoshinUpdate(nonDXOpportunitiesMapOld, nonDXOpportunitiesNew,CL_TriggerUtil.p.Name);
                // 装置名更新Y15
                handler.ChangeDeviceType(nonDXOpportunitiesOld, nonDXOpportunitiesNew);

                // デフォルト値セット
                // if(util.isHHSUser()){
                if(util.isHHSUser(CL_TriggerUtil.p.Name)){
                    // 引合連絡票更新(案件変更反映)
                    handler.ReturnIC(nonDXOpportunitiesNew);
                    handler.oppHHSupdate(nonDXOpportunitiesMapOld,nonDXOpportunitiesMapNew);
                }else{
                    handler.oppDefalt(nonDXOpportunitiesNew,FALSE);
                }
            }
       }
        /* After Update */
        else if(Trigger.isUpdate && Trigger.isAfter){
            // 他決後続処理(INSERTフラグOFF)
            handler.TaketsuKozoku(Trigger.old, Trigger.new, FALSE);
            // 消滅後続処理(DELETEフラグOFF)
            handler.ShometsugoKozoku(Trigger.old, Trigger.new, FALSE);
            // 既納品フォロー対象外
            handler.AssetFollowTaishogai(Trigger.new);
            // DX_S4へ連携する/Link to S4
            handler.s4Linkage_changePhase(Trigger.old, Trigger.new);
            // DX_参照用商談更新
            handler.setDisplayOpportunity(Trigger.new, FALSE);
        }
        /* Before Delete */
        else if(Trigger.isDelete && Trigger.isBefore){
            // 予算削除処理(DELETEフラグON)
            handler.delYosan(Trigger.old, TRUE);

            // DX_参照用商談削除
            handler.deleteDisplayOpportunity(Trigger.old);

        }
        /* After Delete */
        else if(Trigger.isDelete && Trigger.isAfter){
            // 消滅後続処理(DELETEフラグON)
            handler.ShometsugoKozoku(Trigger.old, Trigger.new, TRUE);
        }
        /* After Undelete */
        else if(Trigger.isUnDelete){
        }
    }
    // [S][Add] 2017/09/27 toshima 医用作業機能追加(CAS)
    
    else if( new Set<Id>((List<Id>) System.Label.AP35_CONST_0027.split(',')).contains(UserInfo.getProfileId())) {
        
        TriggerConfig__c tr = TriggerConfig__c.getInstance('TriggerStop');
        if(tr==null || tr.OpportunityTrigger__c){return ;}    //[Mod]2016.09.15 Toyoda CAS-HiSAS組織統合

        CL_OpportunityTriggerHandler handler = new CL_OpportunityTriggerHandler();

        if(Trigger.isBefore && Trigger.isInsert){
            // 案件番号採番(+職制の入力チェック)
            // handler.validateShokusei(Trigger.new);
            // handler.oppNumberSaiban_cas(Trigger.old, Trigger.new, TRUE);
            handler.oppDefaultPricebook(Trigger.new);
        }
        if(Trigger.isBefore && Trigger.isUpdate){
            // 案件番号採番(+職制の入力チェック)
            //handler.validateShokusei(Trigger.new);
            //handler.oppNumberSaiban_cas(Trigger.old, Trigger.new, false);
        }
    }
    
    // [E][Add] 2017/09/27 toshima 医用作業機能追加(CAS)
    //add 2019/05/23 kim JTLトリガ対応
    //modify 2019/06/18 tyo バッチユーザでJTLデータ投入するアクセス対応
    //else if(util.isJTLUser()){
    else if(util.isJTLUser(CL_TriggerUtil.p.Name) || isJTLBatch()){
        TriggerConfig__c tr = TriggerConfig__c.getInstance('TriggerStop');
        if(tr==null || tr.OpportunityTrigger__c){return ;}    //[Mod]2016.09.15 Toyoda CAS-HiSAS組織統合

        CL_OpportunityTriggerHandler handler = new CL_OpportunityTriggerHandler();
        //add 2019/05/22 kim JTL得意先発注番号連携項目登録
        if(Trigger.isUpdate && Trigger.isBefore){
            handler.SetCustomerOrderNoJtl(Trigger.new);
        }
    } else {}
    
    CL_OpportunityTriggerHandler handler = new CL_OpportunityTriggerHandler();
    if(Trigger.isInsert && Trigger.isAfter){
        //LEX対応顧客氏名の役割生成　add kim 2019/04/26
        handler.CreateOpportunityContactRole(Trigger.new);
    }
    
   /*
    * add 2019/06/18 tyo
    * SFバッチユーザでJTLデータ投入するかどうかの判定
    * @return Boolean true/false
    */
    public Boolean isJTLBatch(){
        Boolean bRet = false;
        if(!Trigger.isDelete){
            //SFバッチで操作するかどうかフラグ
            Boolean isBatchUser = util.isBatchUser(CL_TriggerUtil.p.Name);
            Boolean isJTLOpp = false;
            
            Id oppRt = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HHT_JTL').getRecordTypeId();
            //一件目はJTLの案件のところ、すべてはJTLの案件で判断
            if( Trigger.new[0].RecordTypeId == oppRt){
                isJTLOpp = true;
            }
            if(isBatchUser && isJTLOpp){
                bRet = true;
            } 
        }
        return bRet;
    }
}