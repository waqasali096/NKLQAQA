({
    
    
    getEjariList: function(component, event, helper) {
        var action = component.get("c.getEjariIntegration");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ejariMap = [];
                var allValues = response.getReturnValue();
                for ( var key in allValues ) {
                	ejariMap.push({value:allValues[key], key:key});
                }
                component.set("v.ejariRecords", ejariMap);
            }                    
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } 
                else {
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSubmit : function(component, event, helper) {
         component.set("v.spinner", true);
        var action = component.get("c.selectEjari");
        
        action.setParams({
        	methodName: component.get("v.selectedValue"),
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            component.set("v.spinner", false);
            if(state === "SUCCESS"){
                var returnResponce = response.getReturnValue();
                //alert(returnResponce);
                if(returnResponce){
                    helper.showSuccess(component, event, helper);
                }
                else{
                    helper.showError(component, event, helper);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } 
                else {
                    console.log("Unknown Error");
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    
    handleExit : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire()
    
    },
    
})