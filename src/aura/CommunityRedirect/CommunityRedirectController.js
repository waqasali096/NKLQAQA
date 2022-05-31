({
    redirectToAccount: function(component, event, helper) {
        var loggedInUser;
        var state;
        var navEvt;
        
        var action = component.get("c.getLoggedInUser");
        action.setCallback(this, function(response) {
            state = response.getState();
            if (state === "SUCCESS") {
                loggedInUser = response.getReturnValue();
                navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": loggedInUser.Account_Id__c,
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }
        });
        $A.enqueueAction(action);
    }
})