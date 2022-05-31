({
    fetchObjectDetails: function(component, event, recordId){
        var self = this;
        var toastEvent = $A.get("e.force:showToast");
        var callToERP = component.get("c.loadObjectInfoById");
        callToERP.setParams({
            recordId : recordId
        });
        callToERP.setCallback(this, function(response){
            console.log('state :'+JSON.stringify(response.getState()));
            if(response.getState() == 'SUCCESS'){
                var objectRecord = response.getReturnValue();
                console.log('result :'+JSON.stringify(objectRecord));
                toastEvent.setParams({ "title": "Success!", "message": "Contract terminated successfully in ERP","type":"success"  });
                toastEvent.fire();
            }else{
                toastEvent.setParams({ "title": "Error!", "message": "Something went wrong please try again later","type":"error"  });
                toastEvent.fire();
            }
            // Close the action panel
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(callToERP);

        
    },
})