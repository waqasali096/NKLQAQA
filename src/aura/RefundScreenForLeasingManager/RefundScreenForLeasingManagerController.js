({
    doInit : function(component, event, helper){
        component.set('v.spinner',true);
        var recordId = component.get("v.recordId");
        console.log('recordId',recordId);
        component.set('v.spinner',false);
        helper.fetchCaseDetails(component, event, recordId);
    },

    handleSuccess : function(component, event, helper) {
        component.set('v.spinner',true);
        var recordId = component.get("v.recordId");
        var navService = component.find("navService");        
        var pageReference = {
            "type": 'standard__recordPage',         
            "attributes": {              
                "recordId": recordId, //component.get("v.recordId"),
                "actionName": "view",               
                "objectApiName":"Case"              
            }        
        };
                
        component.set("v.pageReference", pageReference);
        component.set('v.spinner',false);
        var pageReference = component.get("v.pageReference");
        navService.navigate(pageReference);
    },
    
    handleError: function (component, event, helper) {
        component.set('v.spinner',false);
        //var dismissActionPanel = $A.get("e.force:closeQuickAction");
        //dismissActionPanel.fire();
    },
    
    handleSubmit: function(component, event, helper) {
        component.set('v.spinner',true);
        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');
        console.log('fields',fields);
        //fields.recordTypeId= component.get('v.recordTypeId');
        var selectedValue = component.find("refundApplicableId").get("v.value");
        if(selectedValue == 'No'){
            fields.No_of_Mths_Rent_Deduction__c = 0;
            fields.Penalty_charges__c = 0.00;
        }
        component.find('recordEditForm').submit(fields);
    },

    onclickCancel: function (cmp, event, helper) {
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    onPicklistChange : function(cmp, event, helper){
        var selectedValue = cmp.find("refundApplicableId").get("v.value");
        var flag = false;
        console.log('selectedValue',selectedValue);
        if(selectedValue == 'Yes'){
            flag = true;
        }
        cmp.set('v.refundApplicable',flag);
    }
})