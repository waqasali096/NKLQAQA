({  
    doInit :function(component,event,helper){  
        //Setting Account columns for Data Table
        component.set('v.spinner',true);
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Trade License No', fieldName: 'Trade_License_Number__c', type: 'text'},
            {label: 'Trade License Expiry Date', fieldName: 'Trade_License_End_Date__c', text:'text',cellAttributes: {class: {fieldName: 'format'}}},
            {label: 'Primary Email', fieldName: 'Primary_Email__c', type: 'text'},
            {type: "button", typeAttributes: {
                label: 'Select Broker',
                name: 'Select Broker',
                title: 'Select Broker',
                variant:'Neutral',
                disabled: false,
                value: 'view',
                iconPosition: 'left'
            }}
        ]);
        helper.checkAccountExists(component, event,helper);
        helper.showAccounts(component, event,helper);
        component.set('v.spinner',false);
        
        helper.checkAccountAndUnitsExists(component);
        
    }, 
    
    handleSubmit : function(component, event, helper) {	
       component.set('v.spinner',true);
        event.preventDefault();   
        	
        var showValidationError = false;	
        var vaildationFailReason = '';	
        const fields = event.getParam('fields');	
        if(fields){	
            if(!fields.Employee_Name__c && component.get('v.isEmpRef')) {	
                showValidationError = true;	
                vaildationFailReason = "Please Enter Employee Name";	
            }else if(!fields.Employee_Number__c && component.get('v.isEmpRef')){	
                showValidationError = true;	
                vaildationFailReason = "Please Enter Employee Number";	
            }else if(!fields.Referred_Customer__c && component.get('v.isCustomeRef')){	
                showValidationError = true;	
                vaildationFailReason = "Please Select Customer";	
            }	
        }	
        if(!showValidationError){	
            component.find('myRecordForm').submit(fields);	
            component.set('v.hasCustomerReferral',true);	
            component.set('v.displaySalesSelection',false);	
            component.set('v.empExist',true);	
            component.set('v.spinner',false);
            
            
            
        }else{	
            helper.showToast(component,vaildationFailReason,'Error','Error');	
        } 	
        	
        $A.get('e.force:refreshView').fire();	
    },
    handlesuccess: function(component, event, helper) {
         component.set('v.spinner',false);
    },
    
    handleTypeChange: function (component, event){
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
        if(component.get('v.hasCustomerAndUnit')){
            var typeValue = event.getParam("value");
            if(typeValue == 'EmployeeReferral'){
                component.set('v.isEmpRef',true);
                component.set('v.isBroker',false);
                component.set('v.isCustomeRef',false);
            }else if(typeValue == 'Broker'){
                component.set('v.isEmpRef',false);
                component.set('v.isBroker',true);
                component.set('v.isCustomeRef',false);
            }else if(typeValue == 'customerReferral'){
                component.set('v.isEmpRef',false);
                component.set('v.isBroker',false);
                component.set('v.isCustomeRef',true);
            }
        }
    },
    
    doFilter: function(component, event, helper) {
        component.set('v.spinner',true);
        
        var myAttri = component.find("name").get("v.value");
        var myAttri = component.find("name").get("v.value");
        var myAttri = component.find("name").get("v.value");
        
        component.set('v.searchKeyName', component.find("name").get("v.value"));
        component.set('v.searchKeyTLNNumber', component.find("TLNNumb").get("v.value"));
        component.set('v.searchKeyPrimaryemail', component.find("priEmail").get("v.value"));
        if(component.get('v.searchKeyName') || component.get('v.searchKeyTLNNumber') || component.get('v.searchKeyPrimaryemail')){
            
            helper.filterRecords(component, event); 
            component.set('v.spinner',false);
        }else{
            component.set("v.data", "");
            component.set('v.displayAccTable',false); 
            component.set('v.spinner',false);
            helper.showToast(component,'Please enter the details in below fields','Error','error'); 
        }
        
        /*
        if(event.getSource().get("v.name")==='x'){
            component.set('v.searchKeyName', event.getSource().get("v.value"));
        }
        if(event.getSource().get("v.name")==='y'){
            component.set('v.searchKeyTLNNumber', event.getSource().get("v.value"));
        }
        if(event.getSource().get("v.name")==='z'){
            component.set('v.searchKeyPrimaryemail', event.getSource().get("v.value"));
        }
        if(component.get('v.searchKeyName')){
            helper.filterRecords(component, event); 
        }else if(component.get('v.searchKeyTLNNumber')){
            helper.filterRecords(component, event); 
        }else if(component.get('v.searchKeyPrimaryemail')){
            helper.filterRecords(component, event); 
        }else{
            component.set("v.data", "");
            component.set('v.displayAccTable',false); 
            
        }*/
        
        
    },
    
    handleAccSelect : function(component, event, helper) {
        var selectedAccRows = event.getParam('selectedRows');
        var setRows = [];
        for (var i=0; i<selectedAccRows.length; i++ ) {
            setRows.push(selectedAccRows[i]);
        }
        component.set("v.selectedAccts", setRows);
        console.log('%%selectedAccRows :- '+JSON.stringify(component.get("v.selectedAccts")));
    },
    
    addCustomer: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var selectedAccRows = [];
        selectedAccRows.push(row);
        
         if(row){
            component.set('v.spinner',true);
            var action = component.get("c.createBrokerAccounts");  
            action.setParams({
                'accList' : selectedAccRows,
                'recordId' : component.get("v.recordId")
            });
            action.setCallback(this,function(response){  
                var state = response.getState();  
                if(state == 'SUCCESS'){  
                    var result = response.getReturnValue();
                    if(result){
                        component.set('v.accExist',true); 
                        component.set('v.accountId',result);
                        component.set('v.displaySalesSelection',false); 
                        component.set('v.spinner',false);
                    }
                    helper.showToast(component,'Broker Added','Success','Success'); 
                    //$A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                    
                }else{  
                    console.log('something bad happend! ');  
                    component.set('v.spinner',false);
                }  
            });
            $A.get('e.force:refreshView').fire();
            $A.enqueueAction(action);
         }
        
    },
    
    removeReferral : function(component, event, helper) {
        component.set('v.spinner',true);
        var referralType;
        if(component.get('v.accExist')){
            referralType = 'broker';
        }else if(component.get('v.isEmpRef')){
            referralType = 'referral';
        }else if(component.get('v.isCustomeRef')){
            referralType = 'CustomerReferral'
        }
        var action = component.get("c.removeReferrals");  
        action.setParams({
            'recordId' : component.get("v.recordId"),
            'referralType': referralType
        });
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                if(result){
                    component.set('v.accExist',false); 
                    component.set('v.isEmpRef',false); 
                    component.set('v.empExist',false); 
                    component.set('v.isCustomeRef',false);   //Added by Jayesh Date: 12 April 22
                    component.set('v.hasCustomerReferral',false);  //Added by Jayesh Date: 12 April 22
                    component.set('v.filterName',''); 
                    component.set('v.filterTLNNumber',''); 
                    component.set('v.filterPrimaryEmail',''); 
                    component.set('v.accountId','');
                    component.set("v.selectedAccts",'');
                    component.set('v.displayAccTable',false);
                    component.set('v.showSearchErr',false);
                    component.set('v.displaySalesSelection',true);
					component.set('v.spinner',false);


                    if(referralType == 'broker'){
                        helper.showToast(component,'Broker Removed','Success','Success'); 
                    }else if(referralType == 'referral'){
                        helper.showToast(component,'Employee referral Removed','Success','Success'); 
                    }else if(referralType == 'CustomerReferral'){
                        helper.showToast(component,'Customer referral Removed','Success','Success'); 
                        
                    }
                    
                }else{
                    console.log('Error in apex result');
                    
                }
                $A.get('e.force:refreshView').fire();
                component.set("v.data",null);
            }else{  
                console.log('something bad happend! ');
 
            }  
        });
        
        $A.enqueueAction(action);
        
    },
    
    reset: function(component, event, helper) {
        component.set("v.filterName", '');  
        component.set("v.filterTLNNumber", '');  
        component.set("v.filterPrimaryEmail", '');  
        component.set("v.data", '');
        component.set("v.displayAccTable", false);
        component.set("v.showSearchErr", '');
    }
    
   
})