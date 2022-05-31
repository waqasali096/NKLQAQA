({  
    //method to check Opp has account & set related attributes
    checkAccountExists : function(component,event,helper) {  
        component.set('v.spinner',true);
        var action = component.get("c.getAccountDetails");
        action.setParams({
            "accountId":'',
            "OppId":component.get("v.recordId"),
        });
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                if(result.isSucess){
                    component.set('v.newAccount',result.accounts);
                    console.log('account'+JSON.stringify(result));  
                    component.set('v.accountId',result.accId);
                    component.set('v.accExist',result.accExist);
                    component.set('v.newAcc',false);
            		component.set('v.spinner',false);

                    // var qbEvent = $A.get("e.c:QuickBookEvent");
                    // qbEvent.setParams({
                    //     "customerAdded" : true,
                    //     "accountId" : result.accId,
                    //     "addedAccount" : component.get('v.newAccount')
                    // });
                    // qbEvent.fire();
                }
            }else{  
            	component.set('v.spinner',false);
                component.set('v.accExist',false);
                component.set('v.newAcc',false);
                console.log('something bad happend! ');  
            }              
        });
        component.set('v.spinner',false);
        $A.enqueueAction(action);
    },
    
	//set Visa fields visibility based country of residence
    callCountryofResidenceChange : function(component,event,helper){
        var accountsData = component.get("v.newAccount");
        var residence = component.get("v.newAccount.Country_Of_Residence__c");
        console.log('acc'+JSON.stringify(accountsData));
        console.log('residence'+residence);
        if(residence!='AE' && residence){
            component.set("v.displayVisaFields", true);
            component.set("v.makePassportsMandatory", true);
        }else if(!residence || residence=='AE'){
            component.set("v.displayVisaFields", false);
            component.set("v.makePassportsMandatory", false);
        }
    },
    
    getCountryResidences: function(component, event,helper) {
        var action = component.get("c.getResidenceCountryValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var countryMap = [];
                var i=0;
                for(var key in result){
                    countryMap.push({key: key, value: result[key]});
                }
                component.set("v.countryResMap", countryMap);
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCountryValues: function(component, event,helper) {
        var action = component.get("c.getCountryValues");
        /*action.setParams({
            "obj":'Account',
            "fld":'Customer_Nationality__c',
        });*/
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var countryMap = [];
                var i=0;
                for(var key in result){
                    countryMap.push({key: key, value: result[key]});
                }
                component.set("v.countryMap", countryMap);
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getnationalities: function(component, event,helper) {
        var action = component.get("c.getNationalityValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var countryMap = [];
                var i=0;
                for(var key in result){
                    countryMap.push({key: key, value: result[key]});
                }
                component.set("v.nationalityMap", countryMap);
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCountryCodes: function(component, event,helper) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "obj":'Account',
            "fld":'Primary_Country_Code__c',
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var countryCodeMap = [];
                var countryCodeIndexPayMap = new Map();
                var i=0;
                for(var key in result){
                    countryCodeMap.push({key: key, value: result[key]});
                    countryCodeIndexPayMap.set(i,key);
                    i++;                 
                }
                component.set("v.countryCodeMap", countryCodeMap);
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action);
    },
    
    //account save
    callAccountSave : function(component, event, helper){
        component.set('v.spinner',true);
        var account = component.get("v.newAccount");
        var primAddr = component.get("v.primaryAddress");
        var secAddr = component.get("v.secAddress");
        console.log('new account'+JSON.stringify(account));
        console.log('primAddr'+JSON.stringify(primAddr));
        console.log('secAddr'+JSON.stringify(secAddr));
        var isEdit = component.get("v.isEdit");
        var recordType = component.get("v.recordType");
        console.log('recordType'+JSON.stringify(recordType));
        var action = component.get("c.addAccounts");
        action.setParams({
            "accounts":account,
            "primaryAddress":primAddr,
            "secAddress":secAddr,
            "isEdit":isEdit,
            "recordId":component.get("v.recordId"),
            "recordType":recordType
        });
        action.setCallback(this,function(response){
            var status = response.getState();
            if(status === "SUCCESS"){
                var result = response.getReturnValue();
                if(!result.isSucess){
                    component.set('v.spinner',false);
                    this.showToast(component,result.respMsg,'Error','Error');
                }else if(result.isSucess){
                    console.log('success result'+JSON.stringify(result));
                    component.set("v.newAccount",result.accounts);
                    component.set('v.newAcc',false);
                    component.set('v.accountId',result.accId);
                    component.set('v.accExist',result.accExist); 
                    component.set("v.accEdit", false);
                    component.set('v.spinner',false);
                    component.set("v.isEdit", true);
                    var qbEvent = $A.get("e.c:QuickBookEvent");
                        qbEvent.setParams({
                            "customerAdded" : true,
                            "accountId" : result.accId, 
                            "addedAccount" : result.accounts
                        });
                        qbEvent.fire();
                    this.showToast(component,'Customer Added','Success','Success'); 
                }
                component.set('v.spinner',false);
                //$A.get('e.force:refreshView').fire();
            }else if(status === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
                component.set('v.spinner',false);
            } 
        });
        $A.enqueueAction(action);
    },
    //third party update
    callThirdPartyUpdate : function(component, event, helper){
        var account = component.get("v.thirdPartyAccount");
        var thirdPartyId = account.val;
        var action = component.get("c.updateThirdParty");
        action.setParams({
            "accId":thirdPartyId,
            "recordId":component.get("v.recordId"),
        });
        action.setCallback(this,function(response){
            var status = response.getState();
            if(status === "SUCCESS"){
                var result = response.getReturnValue();
                if(!result.isSucess){
                    this.showToast(component,result.respMsg,'Error','Error');
                }else if(result.isSucess){
                    console.log('Third party saved');
                }
                    
            }else if(status === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
                component.set('v.spinner',false);
            } 
            
        });
        $A.enqueueAction(action);
    },
    
    //customer creation
    handleFormSubmit: function(component,event) {
        component.set('v.spinner',true);
        var showValidationError = false;
        var fields = component.find("visaField");
        var vaildationFailReason = '';
        var isOrg = component.get("v.isOrg");
        var isPerson = component.get("v.isPerson");
        var personAccRecTypeCheck;
        if(isPerson){
            personAccRecTypeCheck = true;
        }else if(isOrg){
            personAccRecTypeCheck = false;
        }
        
        var primaryAddrs = component.get('v.primaryAddress');
        var secAddrs = component.get('v.secAddress');
        var accountId = component.get("v.accountId");
        
        if(fields){
            fields.forEach(function (field) {
                var now_date = new Date();
                var currentDate = now_date.toISOString().split('T')[0];
                console.log('now_date'+currentDate);
                
                if(field.get("v.fieldName") === 'Visa_Start_Date__c' && field.get("v.value")>currentDate && field.get("v.value")){
                    console.log('visa start'+field.get("v.value"));
                    showValidationError = true;
                    vaildationFailReason = "Visa Start Date cannot be in Future!";
                } else if (field.get("v.fieldName") === 'Visa_End_Date__c' && field.get("v.value")<currentDate && field.get("v.value")) {
                    console.log('visa end'+field.get("v.value"));
                    showValidationError = true;
                    vaildationFailReason = "Visa End Date cannot be in Past!";
                }else if(field.get("v.fieldName") === 'Passport_Issue_Date__c' && field.get("v.value")>currentDate && field.get("v.value")){
                    console.log('pass start'+field.get("v.value"));
                    showValidationError = true;
                    vaildationFailReason = "Passport Issue Date cannot be in Future!";
                } else if (field.get("v.fieldName") === 'Passport_Expiry_Date__c' && field.get("v.value")<currentDate && field.get("v.value")) {
                    console.log('pass end'+field.get("v.value"));
                    showValidationError = true;
                    vaildationFailReason = "Passport Expiry Date cannot be in Past!";
                }
            });
        }
        console.log('showValidationError'+showValidationError);
        
        if(!showValidationError){
            var recordData = event.getParam("fields");
            //console.log('accValues'+JSON.stringify(recordData));
            var action = component.get("c.createNewAccounts");
            action.setParams({
                "accValues":JSON.stringify(recordData),
                "ObjectName": "Account",
                "recordId":component.get("v.recordId"),
                "personRecType":personAccRecTypeCheck,
                "accountId":component.get("v.accountId"),
                "primaryAddrs":primaryAddrs,
                "secAddrs":secAddrs
            });
            action.setCallback(this,function(response){
                var status = response.getState();
                if(status === "SUCCESS"){
                    var result = response.getReturnValue();
                    console.log('accId'+result);
                    if(result.isError){
                        component.set('v.spinner',false);
                        this.showToast(component,result.respMsg,'Error','Error');
                    }else{
                        component.set('v.newAcc',false);
                        component.set('v.accountId',result.accId);
                        component.set('v.accExist',true); 
                        component.set("v.accEdit", false);
                        component.set('v.addrData',result.addressList); 
                        component.set('v.spinner',false);
                        //$A.get('e.force:refreshView').fire();
                        this.showToast(component,'Customer Added','Success','Success'); 
                    }
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);
        }else{
            component.set('v.spinner',false);
            this.showToast(component,vaildationFailReason,'Error','Error');
        }
    },
    
    //method to set Search Existing Accounts
    getAccounts : function(component, helper) {
        component.set("v.spinner", true); 
        var accName = component.get("v.accName");
        var accNum = component.get("v.accNum");
        var accEmail = component.get("v.accEmail");
        var accMob = component.get("v.accMob");
        var accEID = component.get("v.accEID");
        var accTDN = component.get("v.accTDN");
        var isPerson = component.get("v.isPerson");
        var action = component.get("c.fetchAccounts");
        action.setParams({
            'accName' : accName,
            'accNum' : accNum,
            'accEmail' : accEmail,
            'accMob' : accMob,
            'accEID' : accEID,
            'accTDN' : accTDN,
            'isPerson' : isPerson
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                if(result.length > 0 && result.length){
                    component.set('v.displayAccTable',true); 
                    var acclist = [];
                    for (let i = 0; i < result.length; i++) {
                        var record = result[i];
                        record.linkName = '/' + record.Id;
                        acclist.push(record);
                    }
                    component.set("v.data",acclist);  
                    component.set('v.showSearchErr',false);
                }else if( result=='' || !result || result.length==0){
                    component.set('v.displayAccTable',false); 
                    component.set('v.showSearchErr',true); 
                }
                component.set("v.spinner", false); 
            }else if(state === "ERROR"){
                component.set('v.displayAccTable',false); 
                var errors = action.getError();
                if (errors) {	
                    this.showErrorMsg(component,event,'Something went wrong, please try again.');  
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
               component.set("v.spinner", false); 
            } 
        });
        $A.enqueueAction(action);
    },
    
    //method to set Table columns for search
    setSearchTableColumns:function(component, event,helper) {
        var isPerson = component.get("v.isPerson");
        var isOrg = component.get("v.isOrg");
        console.log('isPerson:'+isPerson);
        console.log('isOrg:'+isOrg);
        if(isPerson){
            component.set('v.columns', [
                {
                    label: 'Name', fieldName: 'linkName', type: 'url',
                    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
                },
                //{label: 'Name', fieldName: 'Name', type: 'text'},
                {label: 'Emirates Id', fieldName: 'Emirates_Ids__c', type: 'text'},
                {label: 'Passport No', fieldName: 'Passport_Number__c', type: 'text'},
                {label: 'Nationality', fieldName: 'Nationality__c', type: 'text'},
                {label: 'Country of Residence', fieldName: 'Country_Of_Residence__c', type: 'text'},
                {type: "button",label: 'Add Customer', typeAttributes: {
                    label: 'Add Customer',
                    name: 'Select',
                    title: 'Select',
                    disabled: false,
                    value: 'Select'
                }}
            ]);
        } 
        if(isOrg){
            component.set('v.columns', [
                {
                    label: 'Name', fieldName: 'linkName', type: 'url',
                    typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
                },
                //{label: 'Name', fieldName: 'Name', type: 'text'},
                {label: 'Trade License Number', fieldName: 'Trade_License_Number__c', type: 'text'},
                {label: 'Country', fieldName: 'Country__c', type: 'text'},
                {label: 'Account Number', fieldName: 'AccountNumber', type: 'text'},
                {type: "button", typeAttributes: {
                    label: 'Select Customer',
                    name: 'Select',
                    title: 'Select',
                    disabled: false,
                    value: 'Select'
                }}
            ]);
        }
    },
    
    setAddrColumns:function(component, event,helper) {
        component.set('v.addrColumns', [
            //{label: 'Address', fieldName: 'Name', type: 'text'},
            {label: 'Country', fieldName: 'Country_New__c', type: 'text'},
            {label: 'City', fieldName: 'City__c', type: 'text'},
            {label: 'Postal Code', fieldName: 'Postal_Code__c', type: 'text'},
            {label: 'Street Name', fieldName: 'Street_Name__c', type: 'text'},
            {label: 'House/Apartment No', fieldName: 'House_Apartment_No__c', type: 'text'},
            {label: 'Arabic Address', fieldName: 'Arabic_Address__c', type: 'text'},
            {label: 'Primary Address', fieldName: 'Primary__c', type: 'boolean'},
        ]);
        component.set('v.spinner',false);
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
    
    /*-----------------Emirates ID Methods-------------------*/
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
       
       console.log('Event Received : ' + JSON.stringify(message));
      //helper.onReceiveNotification(component, message);
        
        // Message is received.
        var action = component.get("c.fetchExistingAccount");  
        var transactionId = component.get("v.transactionId");  
        action.setParams({
            'jsonDt' : JSON.stringify(message),
            'transactionId': transactionId,
            'oppId' : component.get('v.recordId')
        });
        
        action.setCallback(this,function(response){

            var state = response.getState();
            console.log('@@@ '+ state);

            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                console.log('result'+JSON.stringify(result));
                
                if(result){
                    /*component.set('v.accExist',true);
                    component.set('v.accEdit',false);
                    var accIds = JSON.stringify(result);
                    //console.log('@@@ ' + result[0].Id);
                    component.set('v.accountId',result[0].Id);
                    var accId = component.get('v.accountId', result[0].Id);
                    //console.log('@@@ accId '+ accId);*/
                    
                    component.set("v.account",result);
                    component.set('v.newAcc',false);
                    component.set('v.accountId',result.accId);
                    component.set('v.accExist',true); 
                    component.set("v.accEdit", false);
                    component.set('v.spinner',false);
                    component.set("v.isEdit", true);
                    $A.get('e.force:refreshView').fire();
                }
                
            }else{
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
    const notifications = component.get('v.notifications');
    notifications.push(newNotification);
    component.set('v.notifications', notifications);
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
  }
})