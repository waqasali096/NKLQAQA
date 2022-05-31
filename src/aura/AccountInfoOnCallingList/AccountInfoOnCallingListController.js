({
    
    doInit : function(component, event, helper) {
       
	 var action = component.get("c.getAccountID");
        action.setParams({ 
           "recID" : component.get("v.recordId"),
            "obJname" :  component.get("v.sObjectName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('state is '+ state);
                var result = response.getReturnValue();
                if(result!='' && result!=undefined){
                  component.set('v.accountID', result);
                }
               

            }
             });
           
      
        $A.enqueueAction(action);  
        
    }
})