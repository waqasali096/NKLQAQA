({
	doInit : function(component, event, helper) {
        helper.fetchSpecialOffers(component, event,helper);
    },
    
    showSpinner : function (component, event, helper) {
        component.set("v.chspinner", true);  
    },
    
    hideSpinner : function(component,event,helper){
        component.set("v.chspinner", false);
    },
    
    handleAddOffers : function(component,event,helper) {
        var allOffers = component.get("v.availableDLDOffers");
        var selectedRecords = [];
        if(allOffers){
            for (var i = 0; i < allOffers.length; i++) {
                if (allOffers[i].SpecialOfferLineExists) {
                    selectedRecords.push(allOffers[i]);
                }
            } 
        }
        if(selectedRecords.length == 0){
            //helper.showToast(component,'Please select an offer.','Error','Error'); 
        }
        //else if(selectedRecords.length >= 0){
            component.set("v.chspinner", true);
            var action = component.get("c.createOfferApplied");
            action.setParams({
                "specialOfferItems":selectedRecords,
                "oppId":component.get("v.recordIds"),
            });
            action.setCallback(this,function(response){  
                var state = response.getState();  
                if(state == 'SUCCESS'){  
                    var result = response.getReturnValue();
                    if(result.success){
                        helper.showToast(component,'Offer Applied Successfully!','Success','Success'); 
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        //dismissActionPanel.fire();
                        //$A.get('e.force:refreshView').fire();
                        component.set("v.chspinner", false);
                    }else{
                        component.set("v.chspinner", false);
                        helper.showToast(component,'Offer Applied Failed!','Error','Error'); 
                    }
                }else{  
                    component.set("v.chspinner", false);
                    console.log('something bad happend! ');  
                }              
            });
            $A.enqueueAction(action);
        //}
    },
    
    handleSingleOffers : function(component,event,helper) {
        var allOffers = component.get("v.availableSinglePPOffers");
        var selectedRecords = [];
        var opId;
        if(component.get("v.recordIds")){
            opId = component.get("v.recordIds");
        }else if(component.get("v.recordId")){
            opId = component.get("v.recordId");
        }
        
        if(allOffers){
            for (var i = 0; i < allOffers.length; i++) {
                if (allOffers[i].SpecialOfferLineExists) {
                    selectedRecords.push(allOffers[i]);
                }
            } 
        }
        if(selectedRecords.length == 0){
            //helper.showToast(component,'Please select an offer.','Error','Error'); 
        }
        //else if(selectedRecords.length >= 0){
            component.set("v.chspinner", true);
            var action = component.get("c.createSingleOfferApplied");
            action.setParams({
                "specialOfferItems":selectedRecords,
                "oppId":opId,
            });
            action.setCallback(this,function(response){  
                var state = response.getState();  
                if(state == 'SUCCESS'){  
                    var result = response.getReturnValue();
                    if(result.success){
                        helper.showToast(component,'Offer Applied Successfully!','Success','Success'); 
                        //var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        //dismissActionPanel.fire();
                        //$A.get('e.force:refreshView').fire();
                        component.set("v.chspinner", false);
                    }else{
                        component.set("v.chspinner", false);
                        helper.showToast(component,'Offer Applied Failed!','Error','Error'); 
                    }
                }else{  
                    component.set("v.chspinner", false);
                    console.log('something bad happend! ');  
                }              
            });
            $A.enqueueAction(action);
        //}
    },
    
    /*Purpose - checkbox selection*/
    dldSelection: function(component, event, helper) {
        var selectedRec = event.getSource().get("v.checked");
        var selectedRecId = event.getSource().get("v.value");
        console.log('selectedRecId'+selectedRecId);
        var getSelectedNumber = component.get("v.dldSelectedCount");
        if(selectedRec == true){
            getSelectedNumber++;
        }else{
            getSelectedNumber--;
        }
        component.set("v.dldSelectedCount", getSelectedNumber);
        /*if(component.get("v.dldSelectedCount") > 1){
           helper.showToast(component,'You can only select one DLD Offer','Error','Error');  
        }*/  
        var allOffers = component.get("v.availableDLDOffers");
        if(allOffers){
            for (var i = 0; i < allOffers.length; i++) {
                if (allOffers[i].SpecialOfferLineExists && selectedRecId && allOffers[i].SpecialOfferLineId != selectedRecId) {
                    allOffers[i].SpecialOfferLineExists = false;
                }
            } 
        }
        component.set("v.availableDLDOffers", allOffers);
    },
    
    /*Purpose - checkbox selection*/
    singleSelection: function(component, event, helper) {
        var selectedRec = event.getSource().get("v.checked");
        var selectedRecId = event.getSource().get("v.value");
        console.log('selectedRecId'+selectedRecId);
        var getSelectedNumber = component.get("v.singleSelectedCount");
        if(selectedRec == true){
            getSelectedNumber++;
        }else{
            getSelectedNumber--;
        }
        component.set("v.singleSelectedCount", getSelectedNumber);
        /*if(component.get("v.dldSelectedCount") > 1){
           helper.showToast(component,'You can only select one DLD Offer','Error','Error');  
        }*/  
        var allOffers = component.get("v.availableSinglePPOffers");
        if(allOffers){
            for (var i = 0; i < allOffers.length; i++) {
                if (allOffers[i].SpecialOfferLineExists && selectedRecId && allOffers[i].SpecialOfferLineId != selectedRecId) {
                    allOffers[i].SpecialOfferLineExists = false;
                }
            } 
        }
        component.set("v.availableSinglePPOffers", allOffers);
    },
    closeModal : function(component, event, helper){
        var qbEvent = $A.get("e.c:QuickBookEvent");
        qbEvent.setParams({
            "closePopUp" : false 
        });
        qbEvent.fire();
    }
    
})