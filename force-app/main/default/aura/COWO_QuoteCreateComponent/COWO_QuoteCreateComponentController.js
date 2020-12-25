({
    QuoteCreate : function(component, event, helper) {
        component.set("v.setMessage", $A.get("$Label.c.COWO_MSG_Processing"));
   
        var id = component.get("v.simpleRecord.Id");
        var result;
        var action = component.get("c.getOpportunityLineItems");         
        action.setParams({ "oid" : id });
        action.setCallback(this, function(response) {              
            result = response.getReturnValue();
            console.log(result);
                if(result){
                    var ret;
                    var action2 = component.get("c.quoteCreate");
                    action2.setParams({ "oid" : id });
                    action2.setCallback(this, function(response) {               
                        ret = response.getReturnValue();
                        console.log(ret);
                        
                        if(ret != ""){
                            // 正常完了
                            $A.get("e.force:navigateToURL").setParams({
                            "url": "/"+ret
                            }).fire();
                        }else{
                            component.set("v.setMessage", $A.get("$Label.c.AP06_MSG_0013"));
                        }         
                    });
                    $A.enqueueAction(action2);
                }else{
                    component.set("v.setMessage", $A.get("$Label.c.COWO_MSG_InactivePBEErr"));
                }
        });
        $A.enqueueAction(action);
}
})