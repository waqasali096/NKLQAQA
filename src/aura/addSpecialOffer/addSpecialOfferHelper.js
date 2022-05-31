({
	fetchSpecialOffers: function(component, event, helper) {
        component.set("v.chspinner", true);
        var opId;
        if(component.get("v.recordIds")){
            opId = component.get("v.recordIds");
        }else if(component.get("v.recordId")){
            opId = component.get("v.recordId");
        }
        var action = component.get("c.getSpecialOffers");
        action.setParams({
            'oppId' : opId,
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('%result'+ JSON.stringify(result));
                if(!result.success){
                    component.set("v.chspinner", false);
                    //show no units error
                }else{
                    component.set("v.chspinner", false);
                    if(result.data && result.data.specialOfferDLDList){
                        component.set("v.availableDLDOffers", result.data.specialOfferDLDList);
                    }
                    if(result.data && result.data.specialOfferSinglePPList){
                        component.set("v.availableSinglePPOffers", result.data.specialOfferSinglePPList);
                    }
                    if(result.data && result.data.specialOfferSpecialPPList){
                        component.set("v.availableSpecialPPDLDOffers", result.data.specialOfferSpecialPPList);
                    }
                }
            }
            else if(state === "ERROR"){
                var errors = action.getError();
                component.set("v.chspinner", false);
                if (errors) {
                    this.showToast(component,'Something went wrong, please try again','Error','Error'); 
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
        });
        $A.enqueueAction(action);  
    },
    
    //Method to show toast message
    showToast : function(component, message, title, type) {
        component.set('v.chspinner',false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message:message,
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },
})