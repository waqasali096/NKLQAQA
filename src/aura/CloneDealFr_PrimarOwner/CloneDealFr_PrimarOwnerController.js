({
    doInit:function(component, event, helper) {
     var action = component.get("c.cloneDeal");
        console.log('component.get("v.recordId") is ' + component.get("v.recordId")); 
        action.setParams({ 
           "caseIDS" : component.get("v.recordId")
            //"Comments" : component.get("v.comment")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('state is '+ state);
                var result = response.getReturnValue();
                if(result==true){
                    helper.showToastMessage('Success!', 'Deal creation is initiated succesfully !','success'); 
                    
                
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
        });
        $A.enqueueAction(action);  
    },
	
    
})