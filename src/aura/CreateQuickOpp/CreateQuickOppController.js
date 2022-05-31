({
    doInit: function(component, event, helper) {
        component.set('v.spinner',true);
        //helper.fetchProjects(component,event,helper);
        var action = component.get('c.getQuickOppDefaultValue');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var data = response.getReturnValue();
                component.set('v.spinner',false);
                if(data && data.defaults){
                    component.set('v.defaults', data.defaults);
                }else{
                    console.log("Error in default value capture");
                }
            }else if(state === 'ERROR'){
                component.set('v.spinner',false);
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Connection Error in Init: " + errors[0].message);
                    } else if (errors.message) {
                        console.log("Connection Error msg: " + errors.message);
                    }
                } else {
                    console.log("Something went in Apex call-Init");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    /*handleProjectOnChange: function(component, event, helper){
        var projList = component.get('v.projectsList');
        var selectedProj = component.get('v.selectedProject');
        //console.log('selected'+component.get('v.selectedProject'));
        var unitsCount;
        if(selectedProj){
            for(var i=0;i<projList.length; i++) {
                if(projList[i].Id == selectedProj){
                    unitsCount = projList[i].Available_Units__c;
                }
            }
            if(unitsCount){
                component.set('v.availableUnitsCount',unitsCount); 
            }else{
                component.set('v.availableUnitsCount',0);
            } 
        }else{
           component.set('v.availableUnitsCount','Please select a Project'); 
        }
    },*/
    
    handleOnSubmit: function(component, event, helper){
        component.set('v.spinner',true);
        var objs = component.get('v.defaults');
        var selectedProj = component.get('v.selectedProject');
        objs['Project__c'] = selectedProj;

        var action = component.get('c.createOpps');
        action.setParams({
            "oppValues":JSON.stringify(component.get('v.defaults'))
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var data = response.getReturnValue();
                component.set('v.spinner',false);
                if(data.success && data.recId){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": data.recId
                    });
                    navEvt.fire();
                }else{
                    console.log(data.message);
                }
            }else if(state === 'ERROR'){
                component.set('v.spinner',false);
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Connection Error: " + errors[0].message);
                    }else if(errors.message) {
                        console.log("Connection Error Msg: " + errors.message);
                    }
                }else{
                    console.log("Something went in Apex call.");
                }
            }
        });
        $A.enqueueAction(action);
    }
})