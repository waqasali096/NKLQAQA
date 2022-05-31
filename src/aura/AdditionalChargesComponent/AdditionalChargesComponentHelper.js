({
	showErrorMsg : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message:message,
            type: 'Success'
        });
        //component.set("v.isSpinner", false);  
        toastEvent.fire();
    },
    showErrorMsgs : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:message,
            type: 'Error'
        });
        //component.set("v.isSpinner", false);  
        toastEvent.fire();
    },
})