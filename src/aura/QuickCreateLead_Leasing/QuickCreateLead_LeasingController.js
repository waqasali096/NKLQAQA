({
    
    doInit : function(component, event, helper) {
	 helper.getAllValuesonLoad(component, event);
	
	},
    
    handleOnSuccess : function(component, event, helper) {
        var recordCreated = event.getParams().response;
         component.set("v.spinner", false); 

        console.log(recordCreated);
       //alert('leasingtype is '+  component.get('v.leasingtype'));

        //alert('recordCreated is '+ (recordCreated.Leasing_Type__c));
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been created successfully.",
            "type": "success",
            "mode": "pester"
        });
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordCreated.id
        });
        navEvt.fire();
    },
    
    onRecordSubmit: function(component, event, helper) {
       component.set("v.spinner", true); 

        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        //alert('leasingtype is '+  component.get('v.leasingtype'));
        //eventFields["LeadSource"] = 'Salesman';
        eventFields["Leasing_Type__c"] = component.get('v.leasingtype');
        eventFields["Interested_In__c"] = component.get('v.leasingtype') == 'Residential Shops' ? 'Commercial Unit' : 'Residential Leasing';
		component.find('leadCreateForm').submit(eventFields);
},
    
    handleError: function(component, event, helper) {
        const fieldErrors = event.getParam('output').fieldErrors;
        const separator = ' ';
        
        let message = Object.values(fieldErrors).map(field => {
        return field.map(error => error.message).join(separator);
    }).join(separator);
    
    $A.get("e.force:showToast").setParams({
        type: 'error',
        mode: 'pester',
        message: message 
    }).fire();
        
    },
    //
    
    
     callGetRecordType:function(component, event ,result) {
       var leaseType = event.getSource().get("v.value");
         console.log('leaseType',leaseType);
         if(leaseType == 'Residential Shops'){
             component.set('v.displayedNoOfBedrooms',false);
             component.set('v.displayedsqft',true);
         }
         if(leaseType == 'Residential Units'){
             component.set('v.displayedNoOfBedrooms',true);
             component.set('v.displayedsqft',false);
         }
       //alert('leaseType is '+ leaseType);  
       var action = component.get("c.getRecordTypeID");
        action.setParams({ 
            "leasingType" : leaseType
        });
         
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.recordtypeID',result);
                component.set('v.isDisabled',false);
                
                
            }
        });
        $A.enqueueAction(action);
    },
    
})