({
    getAllValuesonLoad :function(component, event){ 
        var action = component.get("c.getWrapperValues");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
               // alert('Leasing types are '+ result.leasingTypes);
                this.getLeasingValues(component, event ,result.leasingTypes);
                
            }
        });
        $A.enqueueAction(action);
		
	},
    
    getLeasingValues:function(component, event ,result) {
       var actionMap = [];
        for(var key in result){
            actionMap.push({key: key, value: result[key]});
        }
        component.set("v.leasingTypeMap", actionMap);    
        
    },
})