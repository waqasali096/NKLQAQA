({
    doInit : function(component, event, helper) {
        helper.getHoldingDepositAmount(component);
        var action = component.get("c.mandatoryCheck");
        action.setParams({'recordId' : component.get("v.recordId")});
        action.setCallback(this,function(response){
            component.set("v.mandateCheck",response.getReturnValue().mandateCheck);
            component.set("v.isAgencyAttached",response.getReturnValue().isAgencyAttached);
        });
        $A.enqueueAction(action);
    },
    handleOnSubmit: function(component, event, helper) {
        //helper.showSpinner(component);
        component.set("v.IsSpinner", true);
        if(component.get("v.mandateCheck")){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Please make sure the Customer details and Units are selected',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            component.set("v.IsSpinner", false);
            toastEvent.fire(); 
        } else {
            event.preventDefault(); //Prevent default submit
            if($A.util.isUndefinedOrNull(component.get("v.BookingMode"))
              ){
                var toastEvent = $A.get("e.force:showToast");
                
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Booking Mode is required'  ,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                component.set("v.IsSpinner", false);
                toastEvent.fire();
            }else {
                
                var action = component.get("c.convertRecordType");
                action.setParams({'recordId' : component.get("v.recordId"),
                                  'BookingMode' : component.get("v.BookingMode"),
                                  'paymentMode' : component.get("v.paymentMode"),
                                  'TokenAmount' : component.get("v.TokenAmount")});  
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    var result = response.getReturnValue();
                    var toastEvent = $A.get("e.force:showToast");
                    if(result == 'You cannot re-book this unit for next 48 hours'){
                        toastEvent.setParams({
                            title : 'Error',
                            message: result,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        component.set("v.IsSpinner", false);
                        toastEvent.fire(); 
                    }
                    $A.get("e.force:closeQuickAction").fire(); 
                    $A.get('e.force:refreshView').fire();
                });
                $A.enqueueAction(action);
            }
        }
    },
    
    handleOnSuccess: function(component, event, helper) {
        component.set("v.IsSpinner", false);
        
        var record = event.getParam("response");
        // alert(JSON.stringify(record));
        component.find("notificationsLibrary").showToast({
            "title": "Success",
            "variant": "success",
            "message": "Leasing Created successfully!.",
            "messageData": [
                {
                    url: '/' + record.id,
                    label: record.fields.Name.value
                }
            ]
        });
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            "recordId": record.id,
            "slideDevName": "related"
        });
        navEvent.fire();
    },
    handleOnError: function(component, event, helper) {
        component.set("v.IsSpinner", false);
        var err = event.getParam('error');
        component.find("notificationsLibrary").showToast({
            "title": "Error",
            "variant": "error",
            "message": err.body ? err.body.message : (err.data ? err.data.message : 'Something went wrong.')
        });
    },
    
    handleProjectOnChange : function(component,event,helper){
        var val = component.get("v.ProjectsMap");
        var selProj = component.get("v.selectedProject");
    },
    bookChange : function(component,event,helper){
        if(component.get("v.BookingMode") == 'Reservation with token amount'){
            component.set("v.tokenRequired",true);
        } else {
            component.set("v.tokenRequired",false); 
        } 
        
    },
    onChangepaymentMode : function(component,event,helper){
        var selPickListValue = event.getSource().get("v.value");
        
        
        if(selPickListValue === ""){
            component.set("v.paymentMode",null);
        }else{
            component.set("v.paymentMode",selPickListValue);
        }
        
    },
})