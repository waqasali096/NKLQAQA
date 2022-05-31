({
	
    getHoldingDepositAmount: function(component){
         var action = component.get("c.fetchHoldingDepositAmount");
        action.setParams({'recordId' : component.get("v.recordId")});
        action.setCallback(this,function(response){
           component.set("v.TokenAmount",response.getReturnValue());
        });
         $A.enqueueAction(action);
    },
})