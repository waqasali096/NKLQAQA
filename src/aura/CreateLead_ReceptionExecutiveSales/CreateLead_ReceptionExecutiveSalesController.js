({
    handleOnSuccess : function(component, event, helper) {
        var recordCreated = event.getParams().response;
        console.log(recordCreated);
        component.set("v.spinner", false); 

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
     onRecordRefresh : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
         $A.get("e.force:refreshView").fire();   
   },
    
    
     onRecordSubmit: function(component, event, helper) {
       component.set("v.spinner", true); 

        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        //alert('leasingtype is '+  component.get('v.leasingtype'));
        eventFields["LeadSource"] = 'Walk In';
        component.find('leadCreateForm').submit(eventFields);
},
})