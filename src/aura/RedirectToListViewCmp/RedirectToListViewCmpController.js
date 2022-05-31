({
	doInit : function(component, event, helper) {
        const recordId = component.get("v.recordId");
        var action = component.get("c.getCurrentUserState");
        action.setParams({
            recordId : recordId
        });
		action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
               var showRec = response.getReturnValue();  
                if(!showRec){
                    var act = component.get("c.getSObjectList");
                    act.setParams({
                        ObjectApi : component.get("v.sobjecttype")
                    });
                    act.setCallback(this,function(response){
                        var status = response.getState();
                        if (status === "SUCCESS") {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Success Message',
                                message:'The lead has been qualified successfully and sent to the sales team.' ,
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'success',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                            var listview = response.getReturnValue();
                            var navEvent = $A.get("e.force:navigateToList");
                            navEvent.setParams({
                                "listViewId": listview.Id,
                                "listViewName": null,
                                "scope": component.get("v.sobjecttype")
                            });
                            navEvent.fire();
                        }
                    });
                     $A.enqueueAction(act); 
                }
            }
        });
         $A.enqueueAction(action);
	}
})