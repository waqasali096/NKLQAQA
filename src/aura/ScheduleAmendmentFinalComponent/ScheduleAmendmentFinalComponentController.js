({
    doInit : function(component, event, helper) {
        helper.getAmendments(component, event,helper);
    },
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.checked");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfProperty = component.get("v.parentWrapper.resultWrapperList");
        // play a for loop on all records list 
        for (var i = 0; i < listOfProperty.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfProperty[i].isChecked = true;
                component.set("v.selectedCount", listOfProperty.length);
            } else {
                listOfProperty[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfProperty[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        
        component.set("v.parentWrapper.resultWrapperList", updatedAllRecords);
        //component.set("v.PaginationList", updatedPaginationList);
    },
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.checked");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.checked", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.checked", true);
        }
    },
    
    //method to get save receipts
    handleSubmit : function(component,helper) {
        var totalAmount = 0.00;
        var installmentList = component.get('v.parentWrapper.resultWrapperList');
       
            var action = component.get("c.createScheduleAmendments");
            var selectedRecords = [];
            var parentWrapper =  component.get('v.parentWrapper');
            var installList = component.get('v.parentWrapper.resultWrapperList')
            for (var i = 0; i < installList.length; i++) {
                if (installList[i].isChecked) {
                    selectedRecords.push(installList[i]);
                }
            }
            parentWrapper.resultWrapperList = selectedRecords;
            action.setParams({ parentWrapper :  parentWrapper,
                                  isEdit : true,
                                 fromCashier : true} );
            action.setCallback(this,function(response) {
                var state = response.getState();
                if(state == 'SUCCESS'){  
                    var result = response.getReturnValue();
                    if(result){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'Receipts created successfully',
                            type: 'success'
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }else{
                        helper.showToast(component,'Error in Receipt Creation','Error','Error');
                        console.log('Error in receipt creation');
                    }
                }else if(state === "ERROR"){
                    var errors = action.getError();
                    if (errors) {
                        helper.showToast(component,'Error in Receipt Creation','Error','Error');
                        if (errors[0] && errors[0].message) {
                            console.log(errors[0].message);
                        }
                    }
                } 
            });
            $A.enqueueAction(action);
        
    },
    handleConfirm : function(component, event, helper) {
         if(component.get('v.selectedCount') == 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: 'Please make a selection',
                type: 'error'
            });
            toastEvent.fire();
         }else if(component.get('v.showConfirmBox')){
             helper.handleSubmit(component, helper);
         }else if(!component.get('v.showConfirmBox')){
             helper.handleConfirmDialog(component, event, helper);
         }
    },
    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    validateAmount: function(component, event, helper) {
        helper.validateAmountHelper(component, event,helper);
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.isSpinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.isSpinner", false);
    },  // function to handle the Modal Popup window.
   
    //Function to handle Cancel Popup.
    handleConfirmDialogCancel : function(component, helper) {
        console.log('Cancel');
        component.set('v.showConfirmBox', false);
        
    },
    
})