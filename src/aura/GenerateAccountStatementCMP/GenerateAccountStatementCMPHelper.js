({
	generateAccountStat : function(component, selOppId) {
        var action = component.get("c.generateAccountStatement");
        action.setParams({ 
            opportunityId: selOppId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": '/apex/loop__looplus?eid=' + response
                });
                urlEvent.fire();
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
	}
})