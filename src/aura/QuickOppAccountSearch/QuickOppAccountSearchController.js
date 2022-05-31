({  
    doInit :function(component,event,helper){  
        //component.set('v.spinner',true);
        helper.getCountryValues(component, event,helper);
        helper.getCountryCodes(component, event,helper);
        helper.getCountryResidences(component, event,helper);
        helper.getnationalities(component, event,helper);
        helper.setAddrColumns(component, event,helper);
        helper.checkAccountExists(component,event,helper);
       	component.set("v.accSelection",'Individual');
        component.set('v.isPerson', true);
        
        //=========Emirates Id Integration Section============================
        component.set('v.subscription', null);
        component.set('v.notifications', []);
        const empApi = component.find('empApi');
        const errorHandler = function (message) {
            console.error('Received error ', JSON.stringify(message));
        };
        empApi.onError($A.getCallback(errorHandler));
        helper.subscribe(component, event, helper);
    }, 
    
    /*handleOnload : function(component,event,helper){
        var recUi = event.getParam("recordUi");
        var residence = recUi.record.fields["Country_Of_Residence__c"].value;
        console.log('%%residence'+JSON.stringify(residence));
        if(residence && residence == 'AE'){
            component.set("v.displayVisaFields", false);
        }else{
            component.set("v.displayVisaFields", true);
        }
    },*/
    
    handleCountryofResidenceChange : function(component,event,helper){
        helper.callCountryofResidenceChange(component,event,helper);
    },
       
    //method to set Account Type
    handleTypeChange: function (component, event) {
        var typeValue = component.get("v.accSelection");
        if(typeValue == 'Individual'){
            component.set('v.recordType', 'PersonAccount');
            component.set('v.isPerson', true);
            component.set('v.isOrg', false); 
            component.set('v.data', '');
            component.set("v.accName", '');  
            component.set("v.accNum", '');  
            component.set("v.accEmail", '');  
            component.set("v.accMob", '');  
            component.set("v.accEID", '');  
            component.set('v.displayAccTable',false);
        }else if(typeValue == 'Organization'){
            component.set('v.recordType', 'Business_RecordType');
            component.set('v.isOrg', true); 
            component.set('v.isPerson', false); 
            component.set('v.data', '');
            component.set("v.accName", '');  
            component.set("v.accNum", '');  
            component.set("v.accEmail", '');  
            component.set("v.accMob", '');  
            component.set("v.accEID", '');  
            component.set('v.displayAccTable',false);
        }else if(typeValue == 'Capture from Emirates Id'){
            component.set('v.isPerson', true);
            component.set('v.accEdit', false);
            console.log('@@@ isPerson');
            var userId = $A.get("$SObjectType.CurrentUser.Id");
            var randNumber = Math.floor(100000 + Math.random() * 900000);
            const str1 = 'TRX';
            const transactionId = str1.concat(randNumber);
            component.set('v.transactionId', transactionId);            
            window.open('https://eiduat.nakheel.com/home.aspx?app=sf&transactionId='+transactionId+'&userid='+userId,'_blank');
        }
    },
    
    //method to set Search Existing Accounts
    searchCustomers : function(component, event, helper) {
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
                helper.setSearchTableColumns(component, event,helper);
                helper.getAccounts(component,event);
            }
        }else if(selection == 'Organization'){
            component.set("v.isOrg", true); 
            if(!accName && !accNum && !accEmail && !accMob && !accTDN){
                helper.showToast(component,'Please Enter any filter','Error','Error');
            }else{
                helper.setSearchTableColumns(component, event,helper);
                helper.getAccounts(component,event);
            }
        }
    },
   
    //method to reset Filters
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
        component.set("v.showSearchErr", false); 
    },
    
    //method to create new Account
    createNewAcc : function(component, event, helper) {
        var selection = component.get("v.accSelection");
        console.log('account'+JSON.stringify(component.get("v.account")));  
        component.set("v.newAccount",{'sobjectType':'Account'});
        component.set("v.primaryAddress",{'sobjectType':'Address__c'});
        component.set("v.secAddress",{'sobjectType':'Address__c'});
        if(!selection){
            component.set("v.spinner", false);
            alert('Please select Customer Type'); 
        }else if(selection == 'Individual'){
            component.set("v.isPerson", true); 
            component.set("v.spinner", false);  
            component.set("v.newAcc", true);  
            component.set("v.spinner", false);
            //component.set("v.account", '');
            helper.callCountryofResidenceChange(component,event,helper);
        }else if(selection == 'Organization'){
            component.set("v.isOrg", true); 
            component.set("v.spinner", false);  
            component.set("v.newAcc", true);  
            component.set("v.spinner", false);
            helper.callCountryofResidenceChange(component,event,helper);
            //component.set("v.account", '');
        }
    },
    
    //method to edit Account details
    editCustomer : function(component, event, helper) {
        component.set('v.spinner',true);
        component.set("v.isEdit", false);
    	//component.set("v.accEdit", true); 
        component.set('v.spinner',false);
    },
    
    //method to remove Customer
    removeCustomer : function(component, event, helper) {
        component.set('v.spinner',true);
        var action = component.get("c.checkChildBookedOpportunity");  
            action.setParams({
                'recordId' : component.get("v.recordId")
            });
            action.setCallback(this,function(response){  
                var state = response.getState();  
                if(state == 'SUCCESS'){  
                    var result = response.getReturnValue();
                    if(result){
                        helper.showToast(component,'Booked units linked with this customer.','Cannot remove','Error');
                    }else{
                        var action = component.get("c.removeAccounts");  
                        action.setParams({
                            'recordId' : component.get("v.recordId")
                        });
                        action.setCallback(this,function(response){  
                            var state = response.getState();  
                            if(state == 'SUCCESS'){  
                                var result = response.getReturnValue();
                                if(result){
                                    component.set('v.accExist',false); 
                                    component.set("v.data",null);
                                    component.set('v.accountId','');
                                    component.set('v.displayAccTable',false);
                                    component.set('v.isPerson', false);
                                    component.set('v.isOrg', false);
                                    var qbEvent = $A.get("e.c:QuickBookEvent");
                                    qbEvent.setParams({
                                        "customerAdded" : false,
                                        "addedAccount" : null
                                    });
                                    qbEvent.fire();
                                }
                                helper.showToast(component,'Customer Removed','Success','Success'); 
                            }else{ 
                                console.log('something bad happend! ');  
                            }  
                        });
                        component.set('v.spinner',false);
                        //$A.get('e.force:refreshView').fire();
                        $A.enqueueAction(action);
                    }
                }else{  
                    console.log('something bad happend! ');  
                }  
            });
            //component.set('v.spinner',false);
            $A.enqueueAction(action);
    },
    
    //method to show Third Party Details
    addViewThirdParty : function(component, event, helper) {
        component.set('v.showThirdPartyModal',true);
    },
    //method to hide Third Party Details
    closeThirdPartyModal : function(component, event, helper) {
        component.set('v.showThirdPartyModal',false);
    },

    //method to cancel Account edit
    cancelAccEdit : function(component, event, helper) {
        component.set("v.thirdPartyAccount", undefined);
        component.set("v.isEdit", true);
        component.set("v.newAcc", false);
        helper.checkAccountExists(component,event,helper);
        /*var el = component.find("fieldId");
        for(var i=0;i<el.length;i++){
            $A.util.removeClass(el[i], "slds-has-error"); // remove red border
            $A.util.addClass(el[i], "hide-error-message"); // hide error message
        }*/
    },
    
    //method to select & add Customer to opp
    addCustomer : function(component, event, helper) {
        component.set('v.spinner',true);
        var recId = event.getParam('row').Id;
		var selectedRow = event.getParam('row');
        var setRows = [];
        setRows.push(selectedRow);
        component.set("v.selectedAccts", setRows);
        var selectedAccRows = component.get("v.selectedAccts");
        if(selectedAccRows){
            var action = component.get("c.createAccounts");  
            action.setParams({
                'accList' : selectedAccRows,
                'recordId' : component.get("v.recordId")
            });
            action.setCallback(this,function(response){  
                var state = response.getState();
                if(state == 'SUCCESS'){  
                    var result = response.getReturnValue();
                    component.set('v.spinner',false);
                    if(result){
                        component.set("v.data",null);
                        component.set('v.newAcc',false);
                        component.set('v.accountId',result.accId);
                        component.set('v.accExist',result.accExist); 
                        component.set("v.accEdit", false);
                        component.set('v.newAccount',result.accounts);
                        var qbEvent = $A.get("e.c:QuickBookEvent");
                        qbEvent.setParams({
                            "customerAdded" : true,
                            "accountId" : result.accId,
                            "addedAccount" : component.get('v.newAccount')
                        });
                        qbEvent.fire();
                        helper.showToast(component,'Customer Added','Success','Success');
                    }
                }else{  
                    component.set('v.spinner',false);
                    console.log('something bad happend!');  
                }  
            });
            $A.enqueueAction(action);
        }
    },
    
    //method to create Account from form
    handleSubmit : function(component, event, helper) {
        component.set('v.spinner',true);
        event.preventDefault();
        helper.handleFormSubmit(component,event);
    },
    
    handleThirdPartyDetails : function(component, event, helper) {
        component.set('v.spinner',true);
        event.preventDefault();
        const fields = event.getParam('fields');
        component.find('thirdPartyForm').submit(fields);
        component.set('v.spinner',false);
        component.set('v.showThirdPartyModal',false);
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
        var fields = component.find('fieldId');
        if(fields){
            allValid = component.find('fieldId').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
        }
        
        if(account && account.Visa_Start_Date__c && account.Visa_Start_Date__c>currentDate && account.Country_Of_Residence__c != 'AE'  && account.Country_Of_Residence__c){ 
            console.log('visa start'+ account.Visa_Start_Date__c);
            showValidationError = true;
            vaildationFailReason = "Visa Start Date cannot be in Future!";
        } else if (account && account.Visa_End_Date__c && account.Visa_End_Date__c<currentDate && account.Country_Of_Residence__c != 'AE'  && account.Country_Of_Residence__c) {
            console.log('visa end'+account.Visa_End_Date__c);
            showValidationError = true;
            vaildationFailReason = "Visa End Date cannot be in Past!";
        }else if(account && (!account.Passport_Number__c || !account.Passport_Issue_Date__c || !account.Passport_Expiry_Date__c) && account.Country_Of_Residence__c != 'AE'  && account.Country_Of_Residence__c){
            showValidationError = true;
            vaildationFailReason = "Please fill passport details!";
        }else if(account && account.Passport_Issue_Date__c && account.Passport_Issue_Date__c>currentDate  && account.Country_Of_Residence__c){
            console.log('pass start'+account.Passport_Issue_Date__c);
            showValidationError = true;
            vaildationFailReason = "Passport Issue Date cannot be in Future!";
        } else if (account && account.Passport_Expiry_Date__c && account.Passport_Expiry_Date__c<currentDate  && account.Country_Of_Residence__c) {
            console.log('pass end'+account.Passport_Expiry_Date__c);
            showValidationError = true;
            vaildationFailReason = "Passport Expiry Date cannot be in Past!";
        } else if (account &&  account.Country_Of_Residence__c == 'AE'  && !account.Emirates_Ids__c) {
            showValidationError = true;
            vaildationFailReason = "Emirates Id is mandatory if Country of Residence is UAE";
        }
        if(!allValid){
            helper.showToast('Error','Please resolve issues on the screen','error');  
        }else if(showValidationError){
            helper.showToast(component,vaildationFailReason,'Error','Error');
        }else{
            var thirdPartyAccount = component.get("v.thirdPartyAccount");
            console.log('accParty-->',thirdPartyAccount);
            //console.log('accPartyId-->',thirdPartyAccount.val);
            if(thirdPartyAccount){
                helper.callThirdPartyUpdate(component,event,helper);
            }
            helper.callAccountSave(component,event,helper);
        }
        
    },
    
    /*-------Emirates Id Methods Jayesh------------------*/
    onClear: function (component, event, helper) {
        component.set('v.notifications', []);
    },
    // Mute toast messages and unsubscribe/resubscribe to channel.
    onToggleMute: function (component, event, helper) {
        const isMuted = !(component.get('v.isMuted'));
        component.set('v.isMuted', isMuted);
        if (isMuted) {
            helper.unsubscribe(component, event, helper);
        } else {
            helper.subscribe(component, event, helper);
        }
        helper.displayToast(component, 'success', 'Notifications ' +
                            ((isMuted) ? 'muted' : 'unmuted') + '.');
    },
    
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    }
    
})