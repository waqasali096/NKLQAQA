({
    navigateToeDiscoverySearchCmp : function(component, event, helper) {
        debugger;
         $A.get("e.force:closeQuickAction").fire();
        var recordId =  component.get("v.recordId");
        var action = component.get("c.getOpportunityRecord");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result === 'success'){
                   $A.get("e.force:closeQuickAction").fire();
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:UnitSelectionForLeasing",
                        componentAttributes: {
                            recordId : component.get("v.recordId")
                        }
                    });
                    evt.fire(); 
                }else{
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please change opportunity stage to Unit reservation and add booking mode and Booking amount to book unit."
    });
    toastEvent.fire(); 
                }
            }
             });
             $A.enqueueAction(action);
       
        
    } 
})