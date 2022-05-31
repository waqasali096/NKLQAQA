({ 
    searchAccounts: function(component) { 
        component.set('v.spinner',true);
        var accName = component.get("v.accName");
        var accNum = component.get("v.accNum");
        var accEmail = component.get("v.accEmail");
        var accMob = component.get("v.accMob");
        var accEID = component.get("v.accEID");
        var accTDN = component.get("v.accTDN");
        var isPerson = component.get("v.isPerson");
        var searchKey = component.get("v.accName");  
        
        var action = component.get("c.searchAccounts");  
        action.setParams({
            'recordId': component.get('v.recordId'),
            'accName' : accName,
            'accNum' : accNum,
            'accEmail' : accEmail,
            'accMob' : accMob,
            'accEID' : accEID,
            'accTDN' : accTDN,
            'isPerson' : isPerson
        });
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                if(result && result!= ''){
                    component.set('v.displayAccTable',true); 
                    component.set("v.data",result);  
                    component.set('v.showSearchErr',false)
                }else if( result==''){
                    component.set('v.displayAccTable',false);
                    component.set('v.showSearchErr',true);
                }
                component.set('v.spinner',false);
            }else{  
                component.set('v.spinner',false);
                console.log('Error in Account Search');  
            }  
        });
        //component.set('v.spinner',false);
        $A.enqueueAction(action);
    },
    
    setSearchTableColumns:function(component, event,helper) {
        var isPerson = component.get("v.isPerson");
        var isOrg = component.get("v.isOrg");
        console.log('isPerson:'+isPerson);
        console.log('isOrg:'+isOrg);
        if(isPerson){
            component.set('v.columns', [
                {label: 'Name', fieldName: 'Name', type: 'text'},
                {label: 'Emirates Id', fieldName: 'Emirates_Ids__c', type: 'text'},
                {label: 'Passport No', fieldName: 'Passport_Number__c', type: 'text'},
                {label: 'Nationality', fieldName: 'Nationality__c', type: 'text'},
                {label: 'Country of Residence', fieldName: 'Country_Of_Residence__c', type: 'text'},
                {label: 'Relationship',fieldName: 'Relationship_with_Owner__c', type: 'picklist', editable:'true'}, 
                {label: 'Percentage',fieldName: 'Percentage__c', type: 'number', editable:'true'}
            ]);
        } 
        if(isOrg){
            component.set('v.columns', [
                {label: 'Name', fieldName: 'Name', type: 'text'},
                {label: 'Trade License Number', fieldName: 'Trade_License_Number__c', type: 'text'},
                {label: 'Country', fieldName: 'Country__c', type: 'text'},
                {label: 'Relationship',fieldName: 'Relationship_with_Owner__c', type: 'picklist', editable:'true'}, 
                {label: 'Percentage',fieldName: 'Percentage__c', type: 'number', editable:'true'}
            ]);
        }
    },
    
    getJointOwners: function(component, event) {
        var action = component.get("c.getJointOwners");
        action.setParams({
            'recordId' : component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result && result.jointOwnersList){
                    component.set("v.jointOwnerList", result.jointOwnersList);
                    component.set("v.joCount", result.joCount);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getAccountRelations: function(component, event) {
        var action = component.get("c.getRelationshipValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var relationMap = [];
                var i=0;
                for(var key in result){
                    relationMap.push({key: key, value: result[key]});
                    i++;                 
                }
                component.set("v.relationMap", relationMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCountryValues: function(component, event) {
        var action = component.get("c.getCountryValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var countryMap = [];
                var i=0;
                for(var key in result){
                    countryMap.push({key: key, value: result[key]});
                    i++;                 
                }
                component.set("v.countryMap", countryMap);
            }
        });
        $A.enqueueAction(action);
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
        component.set("v.spinner", true); 
        //Server call for checking the Customers or Units for an Account.
        var action = component.get("c.checksAccountAndUnit");
        action.setParams({ oppId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.hasCustomerAndUnit', response.getReturnValue());
                component.set("v.spinner", false);
            }
            else if (state === "ERROR") {
                component.set("v.spinner", false);
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
    
    //account save
    callAccountSave : function(component, event, helper){
        component.set('v.spinner',true);
        var account = component.get("v.newAccount");
        var primAddr = component.get("v.primaryAddress");
        var secAddr = component.get("v.secAddress");
        console.log('new account'+JSON.stringify(account));
        console.log('primAddr'+JSON.stringify(primAddr));
        console.log('secAddr'+JSON.stringify(secAddr));
        var recordType = component.get("v.recordType");
        var action = component.get("c.createAccounts");
        action.setParams({
            "accounts":account,
            "primaryAddress":primAddr,
            "secAddress":secAddr,
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
                    component.set('v.openNewAcc',false);
                    component.set('v.accountId',result.accId);
                    component.set('v.accExist',result.accExist); 
                    component.set("v.displayAccTable", false);
                    this.showToast(component,'Joint Owner Added','Success','Success'); 
                    $A.get('e.force:refreshView').fire();
                }
                component.set('v.spinner',false);
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
    
})