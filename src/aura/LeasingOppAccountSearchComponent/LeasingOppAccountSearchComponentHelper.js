({
    checkAccountExist: function (component) {
        component.set('v.spinner', true);
        var recordId = component.get('v.recordId');
        var action = component.get("c.checkAccountExists");
        action.setParams({
            'recordId': recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('acc exist result' + JSON.stringify(result));
                if (result) {
                    //  alert(JSON.stringify(result));
                    //component.set('v.accExist',result.brokerExist);
                    component.set('v.accountId', result.accId);
                    component.set('v.accExist', result.accExist);
                    component.set('v.addrData', result.addressList);
                    //alert(result.isPerson);
                    //alert(result.isOrg);

                    if (result.isPerson) {
                        component.set('v.isBusiness', false);
                        component.set('v.isPerson', true);
                    }
                    if (result.isOrg) {
                        component.set('v.isBusiness', true);
                        component.set('v.isPerson', false);
                        //alert(component.get("v.isBusiness"));
                    }

                }
            } else {
                console.log('something bad happend! ');
            }
        });
        console.log('accExist' + component.get('v.accExist'));
        component.set('v.spinner', false);
        $A.enqueueAction(action);
    },

    showToast: function (component, message, title, type) {
        component.set('v.spinner', false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },

    subscribe: function (component, event, helper) {
        // Get the empApi component.
        const empApi = component.find('empApi');
        // Get the channel from the attribute.
        const channel = component.get('v.channel');
        // Subscription option to get only new events.
        const replayId = -1;
        // Callback function to be passed in the subscribe call.
        // After an event is received, this callback prints the event
        // payload to the console. A helper method displays the message
        // in the console app.
        const callback = function (message) {
            debugger;
            console.log('Event Received : ' + JSON.stringify(message));
            //helper.onReceiveNotification(component, message);
            debugger;
            // Message is received.
            var action = component.get("c.fetchExistingAccount");
            debugger;
            var transactionId = component.get("v.transactionId");
            action.setParams({
                'jsonDt': JSON.stringify(message),
                'transactionId': transactionId,
                'oppId': component.get('v.recordId')
            });

            action.setCallback(this, function (response) {

                var state = response.getState();
                console.log('@@@ ' + state);

                if (state == 'SUCCESS') {
                    var result = response.getReturnValue();
                    console.log('subscribe result' + JSON.stringify(result));

                    if (result) {
                        component.set('v.accExist', true);
                        component.set('v.accEdit', false);
                        component.set('v.isPerson', true);
                        var accIds = JSON.stringify(result);
                        console.log('@@@ ' + result[0].Id);
                        component.set('v.accountId', result[0].Id);
                        var accId = component.get('v.accountId', result[0].Id);
                        console.log('@@@ accId ' + accId);
                        $A.get('e.force:refreshView').fire();
                    }

                } else {
                    console.log('something bad happend! ');
                }


            });
            $A.enqueueAction(action);

            console.log('Served called.');

            console.log('Event Received : ' + JSON.stringify(message));
        };
        // Subscribe to the channel and save the returned subscription object.
        empApi.subscribe(channel, replayId, $A.getCallback(callback)).then($A.getCallback(function (newSubscription) {
            console.log('Subscribed to channel ' + channel);
            component.set('v.subscription', newSubscription);
        }));
    },

    // Client-side function that invokes the unsubscribe method on the
    // empApi component.
    unsubscribe: function (component, event, helper) {
        // Get the empApi component.
        const empApi = component.find('empApi');
        // Get the channel from the component attribute.
        const channel = component.get('v.subscription').channel;
        // Callback function to be passed in the unsubscribe call.
        const callback = function (message) {
            console.log('Unsubscribed from channel ' + message.channel);
        };
        // Unsubscribe from the channel using the subscription object.
        empApi.unsubscribe(component.get('v.subscription'), $A.getCallback(callback));
    },

    // Client-side function that displays the platform event message
    // in the console app and displays a toast if not muted.
    onReceiveNotification: function (component, message) {
        // Extract notification from platform event
        const newNotification = {
            time: $A.localizationService.formatDateTime(
                message.data.payload.CreatedDate, 'HH:mm'),
            message: message.data.payload.Message__c
        };
        // Save notification in history
        //const notifications = component.get('v.notifications');
        //notifications.push(newNotification);
        // component.set('v.notifications', notifications);
        // Display notification in a toast
        this.displayToast(component, 'info', newNotification.message);
    },

    // Displays the given toast message.
    displayToast: function (component, type, message) {
        const toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
    },

    optyRecord: function (component, event, helper) {
        var personcolumns = [
            { label: 'Name', fieldName: 'Name', type: 'text' },
            { label: 'Nationality', fieldName: 'Nationality__c', type: 'text' },
            { label: 'Emirates Id', fieldName: 'Emirates_Ids__c', type: 'text' },
            { label: 'Country', fieldName: 'Country_New__c', type: 'text' },
            { label: 'Passport No', fieldName: 'Passport_Number__c', type: 'text' },
        ];
        var businesscolumns = [
            { label: 'Name', fieldName: 'Name', type: 'text' },
            { label: 'Trade License Number', fieldName: 'Trade_License_Number__c', type: 'text' },
            { label: 'Company Type', fieldName: 'Company_Type__c', type: 'text' },
        ];
        var action = component.get("c.fetchOptyRecord");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            if (result.Leasing_Type__c == 'Residential Shops') {
                component.set("v.showbusiness", true);
                component.set("v.fields", component.get("v.businessfields"));
                component.set("v.columns", businesscolumns);
            } else {
                component.set("v.showbusiness", false);
                component.set("v.fields", component.get("v.personfields"));
                component.set("v.columns", personcolumns);
            }
        });
        $A.enqueueAction(action);
    },

    handleOpenNewWindowWithUserId: function (component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var randNumber = Math.floor(100000 + Math.random() * 900000);
        const str1 = 'TRX';
        const transactionId = str1.concat(randNumber);
        component.set('v.transactionId', transactionId);
        //https://eiduat.nakheel.com/home.aspx
        window.open($A.get("$Label.c.Customer_EID_Url")+'?app=sf&transactionId=' + transactionId + '&userid=' + userId, '_blank');

    },

    fetchAccountData: function (component, event, helper) {
        if ($A.util.isUndefinedOrNull(component.get("v.buttonSelection"))) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select Customer Type!',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        } else {
            if (($A.util.isUndefinedOrNull(component.get("v.accName")) ||
                component.get("v.accName") == '') &&
                ($A.util.isUndefinedOrNull(component.get("v.accNum")) ||
                    component.get("v.accNum") == '') &&
                ($A.util.isUndefinedOrNull(component.get("v.accMob")) ||
                    component.get("v.accMob") == '') &&
                ($A.util.isUndefinedOrNull(component.get("v.accEID")) ||
                    component.get("v.accEID") == '') &&
                ($A.util.isUndefinedOrNull(component.get("v.accTDN")) ||
                    component.get("v.accTDN") == '') &&
                ($A.util.isUndefinedOrNull(component.get("v.accEmail")) ||
                    component.get("v.accEmail") == '')) {
                component.set("v.spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'Please filter your search!',
                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                return;
            }
            var action = component.get('c.fetchAccountList');
            action.setParams({
                'accName': component.get('v.accName'),
                'accNumber': component.get('v.accNum'),
                'accEmail': component.get("v.accEmail"),
                'mobNumber': component.get('v.accMob'),
                'eid': component.get('v.accEID'),
                'accTDN': component.get('v.accTDN'),
                'isPerson': component.get('v.isPerson')
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                //alert(JSON.stringify(response.getReturnValue()));
                if (state == 'SUCCESS') {
                    var result = response.getReturnValue();
                    //alert(result.accRecLst.length);
                    if (result.length == 0) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "No records found!!",
                            "type": "error"
                        });
                        toastEvent.fire();
                    }
                    if (result.accRecLst.length > 0) {
                        component.set('v.displayAccTable', true);
                        var acclist = [];
                        for (let i = 0; i < result.accRecLst.length; i++) {
                            var record = result.accRecLst[i];
                            record.linkName = '/' + record.Id;
                            acclist.push(record);
                        }
                        component.set("v.data", acclist);
                        //alert(JSON.stringify(result.flagDescList));
                        component.set("v.mapOfflagCheck", result.flagDescList);
                        component.set("v.showError", false);
                    }
                    if (result.accRecLst.length == 0) {
                        component.set('v.displayAccTable', false);
                        //this.showErrorMsg(component,event,'No records found!!');  
                        component.set("v.showError", true);
                    }
                } else if (state === "ERROR") {
                    component.set('v.displayAccTable', false);
                    var errors = action.getError();
                    if (errors) {
                        this.showErrorMsg(component, event, 'Something went wrong, please try again.');
                        if (errors[0] && errors[0].message) {
                            console.log(errors[0].message);
                        }
                    }
                }
                component.set("v.spinner", false);
            });
            $A.enqueueAction(action);
        }
    },

    checkAccountExists: function (component) {
        component.set('v.spinner', true);
        var recordId = component.get('v.recordId');
        var action = component.get("c.checkAccountExists");
        action.setParams({
            'recordId': recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                var result = response.getReturnValue();
                // alert('result'+result);
                if (result) {
                    //component.set('v.accExist',result.brokerExist);
                    component.set('v.accountId', result.accId);
                    component.set('v.accExist', result.accExist);
                    component.set('v.addrData', result.addressList);
                    // alert(result.isPerson);
                    // alert(result.isOrg);
                    if (result.isPerson) {
                        component.set('v.isBusiness', false);
                        component.set('v.isPerson', true);
                    } else if (result.isOrg) {
                        component.set('v.isBusiness', true);
                        component.set('v.isPerson', false);
                    }
                }
            } else {
                console.log('something bad happend! ');
            }
        });
        console.log('accExist' + component.get('v.accExist'));
        component.set('v.spinner', false);
        $A.enqueueAction(action);
    },

    getCountryValues: function (component, event) {
        var action = component.get("c.getCountryValues");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var installmentPayMap = [];
                var installmentIndexPayMap = new Map();
                var i = 0;
                for (var key in result) {
                    installmentPayMap.push({ key: key, value: result[key] });
                    installmentIndexPayMap.set(i, key);
                    i++;
                }
                component.set("v.countryMap", installmentPayMap);
            }
        });
        $A.enqueueAction(action);
    },

    setAddrColumns: function (component, event, helper) {
        component.set('v.addrColumns', [
            { label: 'Country', fieldName: 'Country_New__c', type: 'text' },
            { label: 'City', fieldName: 'City__c', type: 'text' },
            { label: 'Street', fieldName: 'Street__c', type: 'text' },
            { label: 'Postal Code', fieldName: 'Postal_Code__c', type: 'text' },
            { label: 'Primary Address', fieldName: 'Primary__c', type: 'boolean' },
        ]);
    },

    fetchAddRecord: function (component, event) {
        var action = component.get("c.addressRecord");
        action.setParams({ 'recordId': component.get("v.recordId") });

        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            component.set("v.existingAccAddressfields", result);
            if (result.length === 0) {
                component.set("v.allowAddAddress", true);
            }
        });
        $A.enqueueAction(action);
    },

    fetchOppRecord: function (component, event, helper) {
        //alert('in here ');
        var action = component.get("c.oppRecord");
        action.setParams({ 'recordId': component.get("v.recordId") });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            
            if (result.Leasing_Type__c == 'Commercial Units') {
                component.set("v.Iscompany", true);
                component.set("v.IsUnit", false);
                component.set("v.buttonSelection", 'Organization');
                component.set("v.isPerson", false);
                component.set("v.isBusiness", true);
            }

            if (result.Leasing_Type__c == 'Residential Units') {
                component.set("v.Iscompany", false);
                component.set("v.IsUnit", true);
                component.set("v.isBusinessConcept", false);

                if (result.Account != undefined && result.Account.RecordType.DeveloperName == 'PersonAccount') {
                    component.set("v.buttonSelection", 'Individual');
                    component.set("v.isPerson", true);
                    component.set("v.isBusiness", false);
                }else if(result.Account != undefined && result.Account.RecordType.DeveloperName == 'Business_RecordType'){
                    component.set("v.isPerson", false);
                    component.set("v.isBusiness", true);
                    component.set("v.buttonSelection", 'Organization');
                }     
                
                if(result.Unit_Plans__r != undefined && result.Unit_Plans__r.length > 1){
                    component.set("v.Iscompany", true);
                    component.set("v.IsUnit", false);
                    component.set("v.buttonSelection", 'Organization');
                    component.set("v.isPerson", false);
                    component.set("v.isBusiness", true);
                }
            }            
        });
        $A.enqueueAction(action);
    },

    fetchFields: function (component, event, helper) {
        var action = component.get("c.getFieldSet");
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            var individualfields = []; var corporatefields = []; var signatoryfields = []; var brandingfields = [];


            for (var i = 0; i < result.length; i++) {
                if (result[i].title == 'Individual') {
                    individualfields.push(result[i]);
                }
                if (result[i].title == 'Organisation') {
                    corporatefields.push(result[i]);
                }
                if (result[i].title == 'Signatory') {
                    signatoryfields.push(result[i]);
                }
                if (result[i].title == 'Branding') {
                    brandingfields.push(result[i]);
                }
            }
            component.set("v.indfields", individualfields);
            component.set("v.orgAccfields", corporatefields);
            component.set("v.Brandingfields", brandingfields);
            component.set("v.signatoryfields", signatoryfields);

        });
        $A.enqueueAction(action);
    },
	
 	handleSubmit: function (component, event) {
        component.set('v.spinner', true);
        //event.preventDefault();
        //var recordData = event.getParam("fields");
        //var record = event.getParam("record");
        var isNewAcc;
        if (component.get("v.accExist")) {
            isNewAcc = false;
        } else {
            isNewAcc = true;
        }
        var recordData = component.get("v.recordData");
        var action = component.get("c.createRecords");
        action.setParams({
            "recordJSON": JSON.stringify(recordData),
            "ObjectName": "Account",
            "recordId": component.get("v.recordId"),
            "accId": component.get("v.accountId"),
            'isPerson': component.get("v.isPerson"),
            'isNewAccount': isNewAcc,
            'primaryAddress': JSON.stringify(component.get("v.primaryAddress")),
            'otherAddress': JSON.stringify(component.get("v.secAddress")),
            'updateAddress': JSON.stringify(component.get("v.existingAccAddressfields")),
        });
        action.setCallback(this, function (response) {
            // you should be using getState on result as getStatus doesn't exist in standard API
            var status = response.getState();
            //alert(status);
            
            if (status === "SUCCESS") {
                this.fetchAddRecord(component, event);
                component.set('v.spinner', false);
                var result = response.getReturnValue();
                //alert(result);
                component.set('v.accountId', result.accId);
                component.set('v.accExist', result.accExist);
                component.set('v.addrData', result.addressList);
                if (component.get("v.newAcc")) {
                    this.showToast(component, 'Customer Created Successfully!', 'Success', 'Success');
                } else {
                    this.showToast(component, 'Customer details updated Successfully!', 'Success', 'Success');
                	$A.get('e.force:refreshView').fire();
                }
                component.set('v.newAcc', false);
                if (result.isPerson) {
                    component.set('v.isBusiness', false);
                    component.set('v.isPerson', true);
                } else if (result.isOrg) {
                    component.set('v.isBusiness', true);
                    component.set('v.isPerson', false);
                }
                component.set("v.accEdit", false);
                
                
            }
            if (status == "ERROR") {
                component.set('v.spinner', false);
                var errorMsg = response.getError()[0].message;
                var substring;
                if (errorMsg != null) {
                    if (errorMsg.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                        substring = errorMsg.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1];
                        substring = substring.split(':')[0];
                        
                    } else {
                        if (errorMsg.includes('DUPLICATES_DETECTED')) {
                            substring = 'Duplicate account found in the system';
                        }
                        
                    }
                }
                this.showToast(component, substring, 'Error', 'Error');
            }
        });
        //component.set('v.spinner',false);
        $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
        
    },
})