({
    doInit: function (component, event, helper) {
        component.set('v.spinner', true);
        
        component.set('v.addressColumns', [
            
            { label: 'Country', fieldName: 'Country_New__c', type: 'text' },
            { label: 'City', fieldName: 'City__c', type: 'text' },
            { label: 'Street', fieldName: 'Street__c', type: 'text' },
            { label: 'Postal Code', fieldName: 'Postal_Code__c', type: 'text' },
            { label: 'Primary Address', fieldName: 'Primary__c', type: 'boolean' },
        ]);
            
            helper.checkAccountExist(component, event, helper);
            helper.getCountryValues(component, event);
            helper.setAddrColumns(component, event, helper);
            component.set('v.spinner', false);
            helper.fetchAddRecord(component, event, helper);
            helper.fetchFields(component, event, helper);
            helper.fetchOppRecord(component, event, helper);
            component.set("v.buttonSelection", 'Individual');
            component.set("v.isPerson", true);
            component.set("v.isBusiness", false);
            //=========Emirates Id Integration Section=========================================================
            component.set('v.subscription', null);
            //  component.set('v.notifications', []);
            // Get empApi component.
            const empApi = component.find('empApi');
            // Define an error handler function that prints the error to the console.
            const errorHandler = function (message) {
            console.error('Received error ', JSON.stringify(message));
            };
            // Register empApi error listener and pass in the error handler function.
            empApi.onError($A.getCallback(errorHandler));
            helper.subscribe(component, event, helper);
            },
            
            doFilter: function (component, event, helper) {
            //console.log(JSON.stringify(event.getSource().get("v.value")));
            component.set('v.searchKey', event.getSource().get("v.value"));
            if (component.get('v.searchKey')) {
            helper.filterRecords(component, event);
            } else {
            component.set("v.data", "");
            component.set('v.displayAccTable', false);
            }
            $A.get('e.force:refreshView').fire();
            },
            
            handleAccSelect: function (component, event, helper) {
            var selectedAccRows = event.getParam('selectedRows');
            var setRows = [];
                      for (var i = 0; i < selectedAccRows.length; i++) {
            setRows.push(selectedAccRows[i]);
        }
        component.set("v.selectedAccts", setRows);
        console.log('%%selectedAccRows :- ' + JSON.stringify(component.get("v.selectedAccts")));
    },

    handleSubmit: function (component, event, helper) {
        event.preventDefault();
        component.set('v.spinner', true);
        var recordData = event.getParam("fields");
        var tempCustomerName = '';
        if(recordData.Name != undefined && recordData.Name != ''){
            tempCustomerName = recordData.Name;
        }
        if(recordData.LastName != undefined && recordData.LastName != ''){
            if(recordData.FirstName != undefined && recordData.FirstName != ''){
                tempCustomerName = recordData.FirstName;
            }
            if(tempCustomerName != ''){
                tempCustomerName += ' ' + recordData.LastName;
            }else{
                tempCustomerName = recordData.LastName;
            }
        }
        component.set("v.custmerNameParam", tempCustomerName); 
        component.set('v.recordData', recordData);
        
        if(component.get('v.accountPrimaryMobile') != component.get('v.accountPrimaryMobileOld') 
           || component.get('v.accountPrimaryMobileCountryCode') != component.get('v.accountPrimaryMobileCountryCodeOld')){
            component.set("v.showOTPVerificationCmpt", true); 
        }
        else{
            component.set("v.showOTPVerificationCmpt", false); 
            helper.handleSubmit(component, event);
        }
        
        

        
    },
    
    cancel: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    
    onTypeChange: function (component, event, helper) {
        if (component.get("v.buttonSelection") == 'Capture from Emirates Id') {
            helper.handleOpenNewWindowWithUserId(component, event, helper);
            component.set("v.isPerson", false);
            component.set("v.isBusiness", false);
            // component.set("v.displayAccTable",false);
        }
        if (component.get("v.buttonSelection") == 'Individual') {
            component.set("v.isPerson", true);
            component.set("v.isBusiness", false);
            component.set("v.spinner", true);
            component.set("v.accName", '');
            component.set("v.accNum", '');
            component.set("v.accEmail", '');
            component.set("v.accMob", '');
            component.set("v.accEID", '');
            component.set("v.accTDN", '');
            component.set('v.displayAccTable', false);
            component.set('v.data', '');
            component.set("v.spinner", false);
            component.set("v.showError", false);
        }
        if (component.get("v.buttonSelection") == 'Organization') {
            component.set("v.isPerson", false);
            component.set("v.isBusiness", true);
            component.set("v.spinner", true);
            component.set("v.accName", '');
            component.set("v.accNum", '');
            component.set("v.accEmail", '');
            component.set("v.accMob", '');
            component.set("v.accEID", '');
            component.set("v.accTDN", '');
            component.set('v.displayAccTable', false);
            component.set('v.data', '');
            component.set("v.spinner", false);
            component.set("v.showError", false);
        }
    },
    
    searchFunction: function (component, event, helper) {
        component.set('v.spinner', true);
        if (component.get("v.isPerson")) {
            component.set('v.columns', [
                {
                    label: 'Name', fieldName: 'linkName', type: 'url',
                    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
                },
                //{label: 'Account Number', fieldName: 'AccountNumber', type: 'text'},
                { label: 'ERP Account Number', fieldName: 'ERP_Account_Number__c', type: 'text' },
                { label: 'Emirates Id', fieldName: 'Emirates_Ids__c', type: 'text' },
                { label: 'Passport No', fieldName: 'Passport_Number__c', type: 'text' },
                { label: 'Nationality', fieldName: 'Nationality__c', type: 'text' },
                { label: 'Country of Residence', fieldName: 'Country__c', type: 'text' },
                {
                    type: "button", typeAttributes: {
                        label: 'Select Customer',
                        name: 'Select',
                        title: 'Select',
                        class: 'textColor',
                        disabled: false,
                        value: 'Select'
                    }
                }
            ]);
        }
        if (component.get("v.isBusiness")) {
            component.set('v.columns', [
                {
                    label: 'Name', fieldName: 'linkName', type: 'url',
                    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
                },
                { label: 'ERP Account Number', fieldName: 'ERP_Account_Number__c', type: 'text' },
                { label: 'Trade License Number', fieldName: 'Trade_License_Number__c', type: 'text' },
                { label: 'Country', fieldName: 'Country__c', type: 'text' },
                {
                    type: "button", typeAttributes: {
                        label: 'Select Customer',
                        name: 'Select',
                        title: 'Select',
                        class: 'textColor',
                        disabled: false,
                        value: 'Select'
                    }
                }
            ]);
        }
        helper.fetchAccountData(component, event, helper);
    },
    
    //method to select & add Customer to opp
    addCustomer: function (component, event, helper) {
        
        component.set('v.spinner', true);
        var recId = event.getParam('row').Id;
        var selectedRow = event.getParam('row');
        var setRows = [];
        setRows.push(selectedRow);
        var flagpresent;
        var pastDates;
        var checkflag = component.get("v.mapOfflagCheck");
        
        for (var key in checkflag) {
            if (recId == key) {
                flagpresent = true;
            }
        }
        
        for (let j = 0; j < setRows.length; j++) {
            
            var passportExpDate = new Date(setRows[j].Passport_Expiry_Date__c);
            var visaExpDate = new Date(setRows[j].Visa_End_Date__c);
            var tradeLicenseExpDate = new Date(setRows[j].Trade_License_End_Date__c);
            var today = new Date();
            if (component.get("v.isPerson")) {
                if (passportExpDate < today || visaExpDate < today) {
                    pastDates = true;
                    break;
                }
            }
            if (component.get("v.isBusiness")) {
                if (tradeLicenseExpDate < today) {
                    pastDates = true;
                    break;
                }
            }
            
        }
        if (flagpresent) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Customer has an active flag and cannot be added to new lease, please contact relevant team for more details.',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            component.set('v.spinner', false);
        }
        else if (pastDates) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: component.get("v.isPerson") ? 'Customer has expired passport or visa dates, so won\'t be able to select this customer' : 'Customer has expired trade license date, so won\'t be able to select this customer',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            component.set('v.spinner', false);
        }
            else {
                component.set("v.selectedAccts", setRows);
                
                var selectedAccRows = component.get("v.selectedAccts");
                
                if (selectedAccRows) {
                    var action = component.get("c.createAccounts");
                    action.setParams({
                        'accList': selectedAccRows,
                        'recordId': component.get("v.recordId")
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state == 'SUCCESS') {
                            helper.fetchAddRecord(component, event, helper);
                            var result = response.getReturnValue();
                            component.set('v.spinner', false);
                            if (result) {
                                component.set('v.accExist', true);
                                component.set('v.accountId', result.accId);
                                var addList = [];
                                if (result.addressList) {
                                    for (var i = 0; i < result.addressList.length; i++) {
                                        if (result.addressList[i].Account__c != null) {
                                            result.addressList[i].addName = result.addressList[i].Account__r.BillingAddress;
                                        }
                                        addList.push(result.addressList[i]);
                                    }
                                }// to check if address is empty
                                component.set('v.addrData', addList);
                                
                                component.set('v.newAcc', false);
                            }
                            
                            helper.showToast(component, 'Customer Added', 'Success', 'Success');
                            $A.get('e.force:refreshView').fire();
                            component.set("v.data", null);
                            
                        } else {
                            component.set('v.spinner', false);
                            console.log('something bad happend! ');
                        }
                    });
                    
                    $A.enqueueAction(action);
                }
            }
    },
    
    reset: function (component, event, helper) {
        component.set("v.spinner", true);
        component.set("v.accName", '');
        component.set("v.accNum", '');
        component.set("v.accEmail", '');
        component.set("v.accMob", '');
        component.set("v.accEID", '');
        component.set("v.accTDN", '');
        component.set('v.displayAccTable', false);
        component.set('v.data', '');
        component.set("v.spinner", false);
        component.set("v.showError", false);
        
    },
    
    createNewAcc: function (component, event, helper) {
        
        component.set("v.showAddressTable", false);
        component.set("v.primaryAddress", {});
        component.set("v.secAddress", []);
        component.set("v.spinner", true);
        component.set("v.newAcc", true);
        component.set("v.spinner", false);
    },
    
    editCustomer: function (component, event, helper) {
        component.set('v.spinner', true);
        component.set("v.accEdit", true);
        component.set('v.spinner', false);
    },
    
    //method to remove Customer
    removeCustomer: function (component, event, helper) {
        component.set('v.accountPrimaryMobileOld', "");
        component.set('v.accountPrimaryMobileCountryCodeOld', "");
        component.set('v.spinner', true);
        var action = component.get("c.removeAccounts");
        action.setParams({
            'recordId': component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                if (result) {
                    component.set('v.spinner', false);
                    component.set('v.accExist', false);
                    component.set('v.accountId', '');
                    component.set('v.displayAccTable', false);
                    //component.set('v.isPerson', false);
                    component.set('v.isOrg', false);
                    component.set("v.accName", '');
                    component.set("v.accNum", '');
                    component.set("v.accEmail", '');
                    component.set("v.accMob", '');
                    component.set("v.accEID", '');
                    component.set("v.accTDN", '');
                    
                    component.set('v.data', '');
                    
                    helper.fetchOppRecord(component, event, helper);
                }
                helper.showToast(component, 'Customer Removed', 'Success', 'Success');
                $A.get('e.force:refreshView').fire();
                component.set("v.data", null);
                component.set("v.recordData", null);
            } else {
                component.set('v.spinner', false);
                console.log('something bad happend!');
            }
        });
        
        $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
    },
    
    cancelAccEdit: function (component, event, helper) {
        component.set("v.accEdit", false);
        component.set("v.newAcc", false);
    },
    
    addAnotherAddress: function (component, event, helper) {
        
        var myData = component.get("v.secAddress");
        var primaryAddress = component.get("v.primaryAddress");
        myData.push({
            Country_New__c: "Emirates",
            City__c: "",
            Street__c: "",
            Postal_Code__c: "",
            Arabic_Address__c: "",
            
        });
        component.set("v.secAddress", myData);
        component.set("v.showAddressTable", true);
        
    },
    
    deleteAddressRec: function (component, event, helper) {
        var myData = component.get("v.secAddress");
        var index = event.getSource().get("v.title");
        myData.splice(index, 1);
        
        if (myData.length === 0) {
            component.set("v.showAddressTable", false);
        }
        component.set("v.secAddress", myData);
    },
    
    addAddress: function (component, event, helper) {
        
        var myData = component.get("v.existingAccAddressfields");
        var primaryAddress = component.get("v.primaryAddress");
        myData.push({
            Country_New__c: "Emirates",
            City__c: "",
            Street__c: "",
            Postal_Code__c: "",
            Primary__c: myData.length === 0 ? true : false,
            Arabic_Address__c: "",
        });
        component.set("v.existingAccAddressfields", myData);
        
    },
    
    deleteNewAddressRec: function (component, event, helper) {
        var myData = component.get("v.existingAccAddressfields");
        var index = event.getSource().get("v.title");
        if (index != 0) {
            myData.splice(index, 1);
        }
        component.set("v.existingAccAddressfields", myData);
    },
    
    handleOTPVerificationEvent : function (component, event, helper) {
        component.set("v.spinner", false);
        var showOTPModal = event.getParam("showOTPModal");
        var validOTP = event.getParam("validOTP");
        component.set("v.showOTPVerificationCmpt", showOTPModal);     
        if(validOTP){
            component.set('v.accountPrimaryMobileOld', component.get('v.accountPrimaryMobile'));
            component.set('v.accountPrimaryMobileCountryCodeOld', component.get('v.accountPrimaryMobileCountryCode'));
            helper.handleSubmit(component, event);
        }
        else{            
            component.set('v.spinner', false);
        }
    },
    
    handleFieldOnChange : function (component, event, helper) {
        let fieldName = event.getSource().get("v.fieldName"); 
        let newValue =  event.getSource().get("v.value"); 
        if(fieldName == 'Primary_Mobile__c'){
            component.set('v.accountPrimaryMobileOld', component.get('v.accountPrimaryMobile'));
            component.set('v.accountPrimaryMobile', newValue);
        }
        if(fieldName == 'Primary_Country_Code__c'){
            component.set('v.accountPrimaryMobileCountryCodeOld', component.get('v.accountPrimaryMobileCountryCode'));
            component.set('v.accountPrimaryMobileCountryCode', newValue);
        }
    }
})