({
    showSpinner: function(component){
        var spinner = component.find('quote_spinner');
        $A.util.removeClass(spinner, 'slds-hide');
    },
    hideSpinner: function(component){
        var spinner = component.find('quote_spinner');
        $A.util.addClass(spinner, 'slds-hide');
    },
    
    fetchProjects:function(component,event,helper){
        var action = component.get("c.fetchProjects");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.spinner',false);
                var result = response.getReturnValue();
                if(result){
                   component.set("v.projectsList", result); 
                }else{
                    console.log('Error in Projects Fetching');
                }
            }
        });
        $A.enqueueAction(action);
    }
})