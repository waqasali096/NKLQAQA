({
	doInit : function(component, event, helper) {
		var recId = component.get("v.recordId");
        
        var action = component.get("c.fetchOpportunity");
        action.setParams({ 
            accountId: recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                var oppOpts = [];
                if(response != undefined && response.length > 0) {
                    for(var i=0;i<response.length;i++) {
                        var optOp = {};
                        optOp['label'] = response[i].Name;
                        optOp['value'] = response[i].Id;
                        oppOpts.push(optOp);
                    }
                }
                component.set("v.opportunities", oppOpts);
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
	},
    
    generateStatement : function(component, event, helper) {
        var selectedOppId = component.get("v.selOpportunity");
        console.log('@@: ' + selectedOppId);
        
        if(selectedOppId == undefined) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please select Opportunity.",
                "type": "error"
            });
            toastEvent.fire();
        } else {
            helper.generateAccountStat(component,selectedOppId);
        }
    }
})