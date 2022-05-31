({  
    doInit :function(component,event,helper){  
        helper.getAccountRelations(component, event);
        helper.getCountryValues(component, event);
        helper.getJointOwners(component, event);
        helper.getnationalities(component, event,helper);
        helper.getCountryResidences(component, event,helper);
        component.set("v.accSelection",'Individual');
        component.set('v.isPerson', true);
        helper.checkAccountAndUnitsExists(component);
    },  
    
    handleTypeChange: function (component, event) {
        
        //Server call for checking the Customers or Units for an Account.
        var action = component.get("c.checksAccountAndUnit");
        
        action.setParams({ oppId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.hasCustomerAndUnit', response.getReturnValue());
                console.log('@@@ hasCustomerAndUnit '+ component.get('v.hasCustomerAndUnit'));
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
        
        var typeValue = component.get("v.accSelection");
        if(typeValue == 'Individual'){
            component.set('v.recordType', 'PersonAccount');
            component.set('v.isPerson', true);
            component.set('v.isOrg', false); 
            component.set('v.data', ''); 
            component.set('v.displayAccTable',false);
            component.set("v.accName", '');  
            component.set("v.accNum", '');  
            component.set("v.accEmail", '');  
            component.set("v.accMob", '');  
            component.set("v.accEID", '');  
            component.set("v.accTDN", '');
        }else if(typeValue == 'Organization'){
            component.set('v.recordType', 'Business_RecordType');
            component.set('v.isOrg', true); 
            component.set('v.isPerson', false);
            component.set('v.data', ''); 
            component.set('v.displayAccTable',false);
            component.set("v.accName", '');  
            component.set("v.accNum", '');  
            component.set("v.accEmail", '');  
            component.set("v.accMob", '');  
            component.set("v.accEID", '');  
            component.set("v.accTDN", '');
        }
    },
    
    handleCountryChange : function(component,event,helper){
        let fieldName = event.getSource().get("v.fieldName") ; 
        let residenceValue =  event.getSource().get("v.value") ; 
        if(residenceValue && residenceValue=='AE'){
            component.set("v.displayVisaFields", false);
        }else{
            component.set("v.displayVisaFields", true);
        }
    },
    
    search : function(component, event, helper) {
       var selection = component.get("v.accSelection");
       var accName = component.get("v.accName");
       var accNum = component.get("v.accNum");
       var accEmail = component.get("v.accEmail");
       var accMob = component.get("v.accMob");
       var accEID = component.get("v.accEID");
       var accTDN = component.get("v.accTDN");
       if(!selection){
           helper.showToast(component,'Please select Customer Type','Error','Error');
       }else if(selection == 'Individual'){
           component.set("v.isPerson", true); 
           if(!accName && !accNum && !accEmail && !accMob && !accEID){
               helper.showToast(component,'Please Enter any filter','Error','Error');
           }else{
               helper.searchAccounts(component,event);
           }
       }else if(selection == 'Organization'){
           component.set("v.isOrg", true); 
           if(!accName && !accNum && !accEmail && !accMob && !accTDN){
               helper.showToast(component,'Please Enter any filter','Error','Error');
           }else{
               helper.searchAccounts(component,event);
           }
       }
    },
    
    reset : function(component, event, helper) {
    	component.set("v.spinner", true);  
    	component.set("v.accName", '');  
        component.set("v.accNum", '');  
        component.set("v.accEmail", '');  
        component.set("v.accMob", '');  
        component.set("v.accEID", '');  
        component.set("v.accTDN", '');
        component.set('v.displayAccTable',false);
        component.set('v.data', '');
        component.set("v.spinner", false); 
        component.set('v.showSearchErr',false);
    },
    
    createNewAcc : function(component, event, helper) {
        component.set("v.newAccount",{'sobjectType':'Account'});
        component.set("v.primaryAddress",{'sobjectType':'Address__c'});
        component.set("v.secAddress",{'sobjectType':'Address__c'});
        
        //component.set('v.primaryAddress','');
        //component.set('v.secAddress','');
        var isPerson = component.get("v.isPerson");
        var isOrg = component.get("v.isOrg");
        if(!isPerson && !isOrg){
            component.set("v.spinner", false);
            alert('Please select Customer Type'); 
        }else{
            component.set("v.openNewAcc",true);
        }
    },
            
    addJointOwner: function(component, event, helper) {
        component.set('v.spinner',true);
        var isError = false;
        var accList = component.get("v.data");
        var index = event.getSource().get("v.name");
        var selectedAcc = accList[index];
        
        if(selectedAcc && !isError){
            var acc = [];
        	acc.push(selectedAcc);
            var action = component.get("c.createJointOwners");  
            action.setParams({
                'accList' : acc,
                'recordId' : component.get("v.recordId")
            });
            action.setCallback(this,function(response){  
                var state = response.getState();  
                if(state == 'SUCCESS'){ 
                    var result = response.getReturnValue();
                    if(result && result.jointOwnersList){
                        component.set('v.displayAccTable',false);
                        component.set('v.accExist',true); 
                        component.set("v.selectedAccts","");
                        component.set("v.data", "");
                        component.set('v.spinner',false);
                        helper.showToast(component,'Joint Owner Added','Success','Success'); 
                        $A.get('e.force:refreshView').fire();
                    }else if(result && result.isError){  
                        component.set('v.spinner',false);
                        helper.showToast(component,result.respMsg,'Error','Error'); 
                        console.log('result.respMsg');  
                    } 
                } 
            });
            //$A.get('e.force:refreshView').fire();
            $A.enqueueAction(action);
        }
    },
    
    removeJointOwner : function(component, event, helper) {
        component.set('v.spinner',true);
        var joLists = component.get("v.jointOwnerList");
        var index = event.getSource().get("v.name");
        var selectedJo = joLists[index];
        
        if(selectedJo){
            var joListtoDelete = [];
            joListtoDelete.push(selectedJo);
            var action = component.get("c.removeJointOwners");  
            action.setParams({
                'joList' : joListtoDelete,
                'recordId' : component.get("v.recordId")
            });
            action.setCallback(this,function(response){  
                var state = response.getState();  
                if(state == 'SUCCESS'){ 
                    var result = response.getReturnValue();
                    if(result && result.jointOwnersList && !result.isError){
                        component.set("v.jointOwnerList", result.jointOwnersList);
                        component.set("v.joCount", result.joCount);
                        component.set('v.spinner',false);
                    }else if(result && result.isError){
                        component.set("v.joCount", result.joCount);
                        component.set('v.spinner',false);
                        helper.showToast(component,'Joint Owner Removed','Success','Success');
                    }else{ 
                        component.set("v.joCount", result.joCount);
                        helper.showToast(component,'Error in Joint Owner Removal','Error','Error'); 
                        component.set('v.spinner',false);
                    } 
                } 
            });
            //$A.get('e.force:refreshView').fire();
            $A.enqueueAction(action);
        }
    },
    
    //method to create Account from form
    handleAccountSave : function(component, event, helper) {
        //component.set('v.spinner',true);
        var account = component.get("v.newAccount");
        var showValidationError = false;
        var vaildationFailReason = '';
        var now_date = new Date();
        var currentDate = now_date.toISOString().split('T')[0];
        var allValid = true;
        console.log('Nationality__c'+ account.Nationality__c);
        console.log('Country_Of_Residence__c'+ account.Country_Of_Residence__c);
        allValid = component.find('fieldId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
       
        if(account && account.Visa_Start_Date__c && account.Visa_Start_Date__c>currentDate && account.Country_Of_Residence__c != 'AE'  && account.Country_Of_Residence__c){ 
            console.log('visa start'+ account.Visa_Start_Date__c);
            showValidationError = true;
            vaildationFailReason = "Visa Start Date cannot be in Future!";
        } else if (account && account.Visa_End_Date__c && account.Visa_End_Date__c<currentDate && account.Country_Of_Residence__c != 'AE'  && account.Country_Of_Residence__c) {
            console.log('visa end'+account.Visa_End_Date__c);
            showValidationError = true;
            vaildationFailReason = "Visa End Date cannot be in Past!";
        }else if(account && account.Passport_Issue_Date__c && account.Passport_Issue_Date__c>currentDate){
            console.log('pass start'+account.Passport_Issue_Date__c);
            showValidationError = true;
            vaildationFailReason = "Passport Issue Date cannot be in Future!";
        } else if (account && account.Passport_Expiry_Date__c && account.Passport_Expiry_Date__c<currentDate) {
            console.log('pass end'+account.Passport_Expiry_Date__c);
            showValidationError = true;
            vaildationFailReason = "Passport Expiry Date cannot be in Past!";
        } else if (account && account.Country_Of_Residence__c == 'AE' && !account.Emirates_Ids__c) {
            showValidationError = true;
            vaildationFailReason = "Emirates Id is mandatory if Country of Residence is UAE";
        }
        if(!allValid){
            helper.showToast('Error','Please resolve issues on the screen','error');  
        }else if(showValidationError){
            helper.showToast(component,vaildationFailReason,'Error','Error');
        }else{
            helper.callAccountSave(component,event,helper);
        }
        
    },
    
    handleCountryofResidenceChange : function(component,event,helper){
        helper.callCountryofResidenceChange(component,event,helper);
    },
    
    closeAction : function(component, event, helper) {
        component.set("v.openNewAcc",false);
    },
})