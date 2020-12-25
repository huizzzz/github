trigger TR_OpportunityLineItemTrigger on OpportunityLineItem (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

    TriggerConfig__c tr = TriggerConfig__c.getInstance('TriggerStop');
    if(tr.OpportunityLineItemTrigger__c){return ;}

    CL_OpportunityLineItemTriggerHandler handler = new CL_OpportunityLineItemTriggerHandler();
    CL_TriggerUtil util = new CL_TriggerUtil();    //[Add]2016.09.15 Toyoda CAS-HiSAS組織統合

    /* Before Insert */
    if(Trigger.isInsert && Trigger.isBefore){
        if( util.isHiSASUser() ){    //[Add]2016.09.15 Toyoda CAS-HiSAS組織統合
        	// if(!util.isHHSUser()){	//[Add]2017.12.16 handa HHS
            // 	handler.recalPrice(Trigger.new);
        	// }
            handler.beforeUpdateAutoSetup(Trigger.old, Trigger.new);
            handler.setInitializeFieldOvc(Trigger.new);
        }
    }
    /* After Insert */
    else if(Trigger.isInsert && Trigger.isAfter){
        if( util.isHiSASUser() ){    //[Add]2016.09.15 Toyoda CAS-HiSAS組織統合
        	if(!util.isHHSUser()){	//[Add]2017.12.16 handa HHS
                handler.syncFromOpportunity(Trigger.newMap);
                handler.recalPrice(Trigger.new);
            }
            handler.setPrice_DX(Trigger.new);
        }
    }
    /* Before Update */
    else if(Trigger.isUpdate && Trigger.isBefore){
        if( util.isHiSASUser() ){    //[Add]2016.09.15 Toyoda CAS-HiSAS組織統合
        	// if(!util.isHHSUser()){	//[Add]2017.12.16 handa HHS
            // 	handler.recalPrice(Trigger.new);
        	// }
            handler.beforeUpdateAutoSetup(Trigger.old, Trigger.new);
        }
    }
    /* After Update */
    else if(Trigger.isUpdate && Trigger.isAfter){
        if( util.isHiSASUser() ){
            if(!util.isHHSUser()){	//[Add]2017.12.16 handa HHS
                handler.recalPrice(Trigger.new);
            }
        }
    }
        
    /* Before Delete */
    else if(Trigger.isDelete && Trigger.isBefore){
    }
    /* After Delete */
    else if(Trigger.isDelete && Trigger.isAfter){
    }
    /* After Undelete */
    else if(Trigger.isUnDelete){
    }
}