({  
    doInit :function(component,event,helper){  
        //Setting Account columns for Data Table
        
        component.set('v.spinner',true);
        component.set('v.columns', [
            {label: 'Name', fieldName: 'linkName',type: 'url', 
             typeAttributes:{label: { fieldName: 'Name' }, target: '_blank'}}, 
            {label: 'Trade License No', fieldName: 'Trade_License_Number__c', type: 'text'},
            {label: 'Email', fieldName: 'Primary_Email__c', type: 'email'},
            {label: 'Mobile', fieldName: 'Primary_Mobile__c', type: 'text'},
            {type: "button", typeAttributes: {
                    label: 'Select Broker Agency', //Modify by Sajid
                    name: 'Select',
                    title: 'Select',
                    class : 'textColor',
                    disabled: false,
                    value: 'Select'
                }}]);
            
 
       // helper.checkAccountExists(component, event,helper);
       // helper.showAccounts(component, event,helper);
       		component.set('v.spinner',false);
        
        var action = component.get("c.fetchBrokerAccountDetails"); 
        action.setParams({
                'recordId' : component.get("v.recordId")
            });
            action.setCallback(this,function(response){  
                var state = response.getState();  
                if(state == 'SUCCESS'){  
                    var result = response.getReturnValue();
                    if(result != null){
                        //component.set('v.accExist',true); 
                        //component.set('v.accountId',result);
                        //component.set('v.displaySalesSelection',false);
                        //'Name','Trade_License_Number__c','Primary_Country_Code__c',
                        //'Trade_License_Expiry_Date__c','Primary_Mobile__c',
                        //'Primary_Email__c','Rera_ORN__c','Agency_Status__c'
                        
                        
                        component.set('v.accountId',result.Agency_Name__c);
                        component.set('v.isRecordSelected',true);
                        component.set('v.hideSearchOption',false);
                        component.set('v.agencyName',result.Agency_Name__r.Name);
                        component.set('v.agencyTradeLicenseNumber',result.Agency_Name__r.Trade_Licence_Number__c);
                        component.set('v.agencyEmail',result.Agency_Name__r.Email__c);
                        component.set('v.agencyMobile',result.Agency_Name__r.Primary_Mobile__c);
                    }
                  //  helper.showToast(component,'Agency Added','Success','Success'); 
                  //  $A.get('e.force:refreshView').fire();
                  //  $A.get("e.force:closeQuickAction").fire();
                }else{  
                    console.log('something bad happend! ');  
                }  
            });
            //component.set('v.spinner',false);
            //$A.get('e.force:refreshView').fire();
            $A.enqueueAction(action);
        
    }, 
    
    handleSubmit : function(component, event, helper) {
        console.log('In save');
        event.preventDefault();   
        const fields = event.getParam('fields');
        component.find('myRecordForm').submit(fields);
        component.set('v.displaySalesSelection',false);
        $A.get('e.force:refreshView').fire();
    },

    doFilter: function(component, event, helper) {
        //console.log(JSON.stringify(event.getSource().get("v.value")));
        component.set('v.searchKey', event.getSource().get("v.value"));
        if(component.get('v.searchKey')){
            helper.filterRecords(component, event); 
        }else{
           component.set("v.data", "");
           component.set('v.displayAccTable',false); 
        }
        $A.get('e.force:refreshView').fire();
    },
    
    handleAccSelect : function(component, event, helper) {
       
        console.log('%%selectedAccRows :- '+JSON.stringify(component.get("v.selectedAccts")));
    },

    removeOperation : function(component, event, helper) {
        component.set('v.spinner',true);
        var action = component.get("c.removeAgencyFromOpportunity"); 
        action.setParams({
                'recordId' : component.get("v.recordId")
            });
            action.setCallback(this,function(response){ 
                component.set('v.spinner',false);
                var state = response.getState();  
                if(state == 'SUCCESS'){  
                    var result = response.getReturnValue();
                    if(result == true){
                        component.set('v.filter',null);
                        component.set('v.isRecordSelected',false);
                        component.set('v.hideSearchOption',true);
                    }else{
                        console.log('Something went wrong!!');
                    }
                    helper.showToast(component,'Agency Removed','Success','Success'); 
                    $A.get('e.force:refreshView').fire();
                  //  $A.get("e.force:closeQuickAction").fire();
                }else{  
                    console.log('something bad happend! ');  
                }  
            });
            //component.set('v.spinner',false);
            $A.get('e.force:refreshView').fire();
            $A.enqueueAction(action);
        
    },
    
    addCustomer : function(component, event, helper) {
        component.set('v.spinner',true);
         var recId = event.getParam('row').Id;
        console.log('record id ',recId);
		var selectedRow = event.getParam('row');
        
        console.log('selected Row ', selectedRow);
        var setRows = [];
        setRows.push(selectedRow);
        //component.set("v.selectedAccts", setRows);
       // var selectedAccRows = component.get("v.selectedAccts");
       //alert(JSON.stringify(setRows));
       var pastDates;
        var emptyTradeLicense;
        for(let j=0; j< setRows.length; j++){

            var tradeLicenseExpDate = new Date(setRows[j].Trade_License_End_Date__c);
            var tradeLicenseNumber = setRows[j].Trade_License_Number__c;
            
            var today = new Date();
            var tradeLicenseError;
            if(tradeLicenseNumber == "" || tradeLicenseNumber == null){
                emptyTradeLicense = true;
                tradeLicenseError = 'The given broker doesn\'t have a Trade license number, so you won\'t be able to add broker for this customer'
            }
            else if(setRows[j].Trade_License_End_Date__c == "" || setRows[j].Trade_License_End_Date__c == null){
                emptyTradeLicense = true;
                tradeLicenseError = 'The given broker doesn\'t have a Trade license expiry date, so you won\'t be able to add broker for this customer'
            }
            else if (tradeLicenseExpDate < today) {
                pastDates = true;
                tradeLicenseError = 'Trade license is expired, So you won\'t be able to add broker for this customer'
                break;
            }  
        }
       
        if(pastDates || emptyTradeLicense){
           
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message: tradeLicenseError,
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            component.set('v.spinner',false);
        }
        else{
            if(setRows){
                console.log('set rows value ',setRows);
                var action = component.get("c.createBrokerAccounts");  
                action.setParams({
                    'accList' : setRows,
                    'recordId' : component.get("v.recordId")
                });
                action.setCallback(this,function(response){  
                    var state = response.getState();  
                    if(state == 'SUCCESS'){  
                        component.set('v.spinner',false);
                        var result = response.getReturnValue();
                        if(result){
                            
                            component.set('v.accExist',true); 
                            component.set('v.accountId',result);
                            component.set('v.displaySalesSelection',false);
                            component.set('v.isRecordSelected',true);
                            component.set('v.displayAccTable',false);
                            component.set('v.hideSearchOption',false);
                            // component.set('v.agencyName',result.name);
                            // component.set('v.agencyTradeLicenseNumber',result.Trade_Licence_Number__c);
                            // component.set('v.agencyEmail',result.Email__c);
                            // component.set('v.agencyMobile',result.Primary_Mobile__c);
                        }
                        helper.showToast(component,'Broker agency is added','Success','Success'); //Modified by sajid
                        $A.get('e.force:refreshView').fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }else{  
                        component.set('v.spinner',false);
                        console.log('something bad happend! ');  
                    }  
                });
                
                $A.get('e.force:refreshView').fire();
                $A.enqueueAction(action);
            }
        }
    },

})