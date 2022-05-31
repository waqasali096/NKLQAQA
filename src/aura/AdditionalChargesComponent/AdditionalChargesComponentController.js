({
	doInit : function(component, event, helper) {
        debugger;
        var recordId = component.get("v.recordId");
         var action = component.get("c.findUnitByName");
        action.setParams({ 
            recordId : recordId,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.ejari",result.Ejari__c);
                component.set("v.deposit",result.Security_Deposit__c);
                component.set("v.poolCharges",result.Swimming_Pool_Charges__c);
                component.set("v.utilityCharges",result.Utility_Charges__c);
                
            }
        });
        $A.enqueueAction(action);
		
	},
    selectEjari : function(component, event, helper) {
        debugger;
      var ejari =   component.get("v.ejari");
        component.set("v.selectedejari",ejari);
        var message = "Ejari Fee Selected";
       
        helper.showErrorMsg(component,event,message); 
    },
    selectDeposit : function(component, event, helper) {
        debugger;
      var deposit =   component.get("v.deposit");
        component.set("v.selecteddeposit",deposit);
        var message = "Security  Deposit is Selected";
       
        helper.showErrorMsg(component,event,message); 
    },
    selectCharges : function(component, event, helper) {
        debugger;
      var poolCharges =   component.get("v.poolCharges");
        component.set("v.selectedpoolCharges",poolCharges);
        var message = "Swimming pool charges is Selected";
       
        helper.showErrorMsg(component,event,message); 
    },
    createExpense : function(component, event, helper) {
        debugger;
      var utilityCharges =   component.get("v.utilityCharges");
        component.set("v.selectedutilityCharges",utilityCharges);
        var message = "Utility charges is selected";
       
        helper.showErrorMsg(component,event,message); 
    },
    save : function(component, event, helper) {
        debugger;
         var recordId = component.get("v.recordId");
         var selectedejari =   component.get("v.selectedejari");
         var selecteddeposit =   component.get("v.selecteddeposit");
         var selectedpoolCharges =   component.get("v.selectedpoolCharges");
        var selectedutilityCharges =   component.get("v.selectedutilityCharges");
        if(selectedejari === undefined && selecteddeposit === undefined && selectedpoolCharges === undefined && selectedutilityCharges === undefined){
            var message = "Please select either one charges to save record";
       
       			 helper.showErrorMsgs(component,event,message); 
                 
        }else{
         var action = component.get("c.updateOppUnitRecord");
        action.setParams({ 
            recordId : recordId,
            selectedejari : selectedejari,
            selecteddeposit : selecteddeposit,
            selectedpoolCharges : selectedpoolCharges,
            selectedutilityCharges : selectedutilityCharges
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var message = "Opportunity Record updated with additional charges";
       
       			 helper.showErrorMsg(component,event,message); 
                 $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                
            }
        });
        $A.enqueueAction(action);
        }
		
    },
    cancel :  function(component, event, helper) {
         component.set("v.selectedejari",null);
         component.set("v.selecteddeposit",null);
        component.set("v.selectedpoolCharges",null);
        component.set("v.selectedutilityCharges",null);
        $A.get("e.force:closeQuickAction").fire();
    }
    
})