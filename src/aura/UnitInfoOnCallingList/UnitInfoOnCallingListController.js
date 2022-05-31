({
    
    doInit : function(component, event, helper) {
       
	 var action = component.get("c.getUnitID");
        action.setParams({ 
           "recID" : component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('state is '+ state);
                var result = response.getReturnValue();
                if(result!='' && result!=undefined){
                 // alert('result is '+ result);  
                  component.set('v.unitID', result);
                }
               

            }
             });
           
      
        $A.enqueueAction(action);  
        
    }
})