({
	doInit : function(component, event, helper) {
		var action = component.get("c.ConvertLeadToLeasing");
        action.setParams({
            recordId : component.get("v.recordId")
        });
         action.setCallback(this, function(response) {
             var state = response.getState();
            if (state === "SUCCESS") {
                //alert(response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Sales lead Converted to leasing lead Successfully.",
                    "type": "success",
                    "mode": "pester"
                });
                toastEvent.fire();
                $A.get("e.force:refreshView").fire();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Error occured while converting Sales lead to Leasing.Please contact system Administrator!!.",
                    "type": "error",
                    "mode": "pester"
                });
                toastEvent.fire();
                $A.get("e.force:refreshView").fire();
            }
         });
         $A.enqueueAction(action);
	}
})