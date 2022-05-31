({
    doInit:function(component, event, helper) {
    component.set("v.spinner", true); 
    
     var action = component.get("c.clone");
        console.log('component.get("v.recordId") is ' + component.get("v.recordId")); 
        action.setParams({ 
           "recordID" : component.get("v.recordId")
            //"Comments" : component.get("v.comment")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('state is '+ state);
                var result = response.getReturnValue();
                if(result==true){
                    helper.showToastMessage('Success!', 'Cloning is initiated succesfully !','success'); 
                    $A.get("e.force:closeQuickAction").fire();
                    console.log('close');
                    console.log('refresh');
  
                }
                else if(result==false){
                    helper.showToastMessage('Error!', 'There is some error. Please contact Admin','error'); 
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                    

            }


            }
           component.set("v.spinner", false); 
        });
        $A.enqueueAction(action);  
    },
	
    
})