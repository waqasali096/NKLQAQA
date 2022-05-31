({  
    filterRecords: function(component) { 
        component.set('v.spinner',true);
        var searchKeyName = component.get("v.searchKeyName");  
        var searchKeyTLNNumber = component.get("v.searchKeyTLNNumber"); 
        var searchKeyPrimaryemail = component.get("v.searchKeyPrimaryemail"); 
        
        var action = component.get("c.fetchBrokerAccounts");  
        action.setParams({
            'searchKeyName' : searchKeyName,
            'searchKeyTLNNumber': searchKeyTLNNumber ,
            'primaryEmail': searchKeyPrimaryemail
        });
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                if(result && result!= ''){
                    component.set('v.displayAccTable',true); 
                    component.set('v.showSearchErr',false);
                    result.forEach(ele => {
                        ele.format = ele.Is_Trade_Licence_Expired__c ? 'slds-text-color_error' : '';
                    });
                    component.set("v.data",result);  
                }else if( result==''){
                    component.set('v.displayAccTable',false);
                    component.set('v.showSearchErr',true);
                }
            }else{  
                console.log('something bad happend! ');  
            }  
        });
        component.set('v.spinner',false);
        $A.enqueueAction(action);
    },
    
    showAccounts: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        var action = component.get('c.getBrokerAccountValues');
        action.setParams({
            'oppId': recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('%%response'+JSON.stringify(response.getReturnValue()));
            if(state === 'SUCCESS'){
                var data = response.getReturnValue();
                component.set('v.defaults', data.defaults);
                component.set('v.editSection', data.editFields);
                console.log("%%defaults"+JSON.stringify(component.get('v.defaults')));
            } else if(state === 'ERROR'){
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error: " + errors[0].message);
                    } else if (errors.message) {
                        console.log("Error: " + errors.message);
                    }
                } else {
                    console.log("Something went wrong.");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    checkAccountExists: function(component) {
        component.set('v.spinner',true);
        var recordId = component.get('v.recordId');
        var action = component.get("c.checkBrokerAccountExists");  
        action.setParams({
            'recordId' : recordId
        });
        action.setCallback(this,function(response){  
            var state = response.getState();
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                console.log('result'+JSON.stringify(result));
                if(result){
                    var check = !(result.brokerExist || result.EmployeeExist);
                    component.set('v.accExist',result.brokerExist); 
                    component.set('v.accountId',result.accId);
                    component.set('v.isEmpRef',result.EmployeeExist);
                    component.set('v.empExist',result.EmployeeExist);
                    component.set('v.isBroker',result.brokerExist);
                    component.set('v.displaySalesSelection',check); 
                    component.set('v.hasCustomerReferral', result.referralCustomer);
                }else{
                }
            }else{  
                console.log('something bad happend! ');  
            }  
        });
        
        component.set('v.spinner',false);
        $A.enqueueAction(action);
    },
    
    showToast : function(component, message, title, type) {
        component.set('v.spinner',false);
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
    
    checkAccountAndUnitsExists: function(component){
        //Server call for checking the Customers or Units for an Account.
        var action = component.get("c.checksAccountAndUnit");
        action.setParams({ oppId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.hasCustomerAndUnit', response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
   
    
    
   
})