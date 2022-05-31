({
    doInit : function(component, event) {
        component.set("v.spinner", true);
        var action = component.get("c.leadConvertMethod");        
        action.setParams({
            leadId:component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.objResultWrapper", result);

                if(result.strMessage == 'success'){ 
                     var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Lead is converted successfully !',
                        type: 'Success',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject"); 
                    navEvt.setParams({ 
                        "recordId": result.strOpportunityId
                    }); 
                    navEvt.fire(); 
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: result.strMessage,
                        type: 'error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }
                component.set("v.spinner", false);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    }
})