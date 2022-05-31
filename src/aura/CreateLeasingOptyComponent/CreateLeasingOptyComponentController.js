({
    doInit : function(component, event, helper) {
        helper.showSpinner(component);
        
        var action = component.get("c.fetchProjects");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.hideSpinner(component);
                
                var result = response.getReturnValue();
                var projMap = [];
                for(var key in result){
                    projMap.push({key: key, value: result[key]});
                }
                component.set("v.ProjectsMap", projMap);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getLeasingType : function(component, event, helper) {
        helper.showSpinner(component);
        
        var action = component.get("c.getLeasingTypePicklist");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.hideSpinner(component);
                var result = response.getReturnValue();
                component.set("v.leasingTypeList", result);               
            }
        });
        $A.enqueueAction(action);
    },
    
    handleOnSubmit: function(component, event, helper) {
       component.set("v.showSpinner", true);
       
        //helper.showSpinner(component);
        
        event.preventDefault(); //Prevent default submit
        var eventFields = event.getParam("fields"); //get the fields
        eventFields["StageName"] = 'New'; //
        eventFields["Name"] = 'Draft Booking'; 
        eventFields["Interested_In__c"] = 'Residential Leasing';
        eventFields["Leasing_Type__c"] = component.get("v.leasingType");    
        eventFields["Project__c"] = component.get("v.selectedProject"); 
        eventFields["Lease_Start_Date__c"] = component.get("v.startdate");  
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var leasestartdate = component.get("v.startdate");  
        if(leasestartdate < today){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'Lease start date cannot be a past date',
                type: 'error'
            });
            
            toastEvent.fire();
            //helper.hideSpinner(component);
            component.set("v.showSpinner", false);
        }else{
            eventFields["CloseDate"] = today; 
            var recordtypeId = $A.get("$Label.c.LeasingDefaultRecordType");
            var recordIds = $A.get("$Label.c.LeasinCommercialUnitId");
            //alert(component.get("v.leasingType"));
            if(component.get("v.leasingType") == 'Commercial Units'){
                eventFields["RecordTypeId"] = recordIds; 
            }   
            
            if(component.get("v.leasingType") == 'Residential Units'){
                eventFields["RecordTypeId"] = recordtypeId;   
            }
            component.find('opportunityRecordForm').submit(eventFields); //Submit For
            //helper.hideSpinner(component);
            //component.set("v.showSpinner", false);
        }
        
    },
    
    handleOnSuccess: function(component, event, helper) {
        component.set("v.showSpinner", false);
        //helper.hideSpinner(component);
        var record = event.getParam("response");
        // alert(JSON.stringify(record));
        component.find("notificationsLibrary").showToast({
            "title": "Success",
            "variant": "success",
            "message": "Booking Created successfully!",
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
        helper.hideSpinner(component);
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
    handleLeasingTypeOnChange : function(component,event,helper){
       
        var leasingType = component.get("v.leasingType");
    }
})