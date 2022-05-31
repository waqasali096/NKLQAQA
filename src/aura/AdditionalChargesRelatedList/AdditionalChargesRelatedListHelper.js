({
	fetchAdditionalCharges : function(component,event) {
		//component.set("v.showLoadingSpinner", true);
        var action = component.get("c.getadditionalCharges");
        action.setParams({
            OppId: component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('<--Resopnse-->'+JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {
                component.set("v.additionalCharges", response.getReturnValue());
                if(response.getReturnValue().length > 0){
                    component.set("v.showCharges",true);
                }  
                else{
                    component.set("v.showCharges",false);
                }
                //component.set("v.showLoadingSpinner", false);
            }else{
                
            }
          });
        // enqueue the action
        $A.enqueueAction(action); 

	}
})