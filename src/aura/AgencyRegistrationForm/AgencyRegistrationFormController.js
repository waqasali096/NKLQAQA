({
    doInit: function (component, event, helper) {
        helper.getAgencyTypePicklist(component, event);
        helper.getAgencyLocationPicklist(component, event);
        helper.getAgencyCountryCodePicklist(component, event);
        helper.getAgencyBankAccountCurrencyPicklist(component, event);
        helper.getPlaceOfIncorporationPicklist(component, event);
        helper.getEmiratePicklist(component, event);
        helper.getBankNamePicklist(component,event);
        helper.getAgreementStatusPicklist(component,event);
        helper.getNationalityMap(component,event);
        //helper.getCountryPicklist(component,event);
        
        var agencyRecordId = component.get('v.agencyRecordId');
        
        if(agencyRecordId != null){
            console.log('Called');
            helper.getAgencyRegistrationDetails(component, event,helper);
            component.set("v.existingRegistraionRecord", true);
            console.log('existingRegistraionRecord', component.get('v.existingRegistraionRecord'));
        }
        
        var action = component.get("c.fetchRecordTypeValues");
        action.setCallback(this, function(response) {
            component.set("v.lstOfRecordType", response.getReturnValue());
        });
        $A.enqueueAction(action);
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
    },
    
    emirateFieldChange : function (component, event, helper) {
        var placeOfIncorporationValue = event.getSource().get("v.value");
        console.log('placeOfIncorporationValue', placeOfIncorporationValue);
        var placeOfIncorporationMap = component.get("v.placeOfIncorporationMap");
        
        if (placeOfIncorporationValue == 'AE') {
            console.log('placeOfIncorporationValue', placeOfIncorporationValue);
            
            component.set('v.disabledEmirateField', false);
            component.set('v.emirateRequired',true);
            component.set('v.cityRequired',false);
            component.set('v.agencyRegistration.Agency_Location__c', 'Local');
            
            helper.getEmiratePicklist(component, event);
        }else {
            component.set('v.disabledEmirateField', true);
            component.set('v.emirateRequired',false);
            component.set('v.cityRequired',true);
            component.set('v.emirateMap', '--None--');
            component.set('v.agencyRegistration.Emirate__c', null);
            component.set('v.agencyRegistration.Agency_Location__c', 'International');
            
            //component.set('v.ornRequired', false); commented by hitarth 7/8
        }
    },
    
    IBANNumberFieldChange : function (component, event, helper) {
        // console.log('v.agencyRegistration.Bank_IBAN_Number__c  is '+ component.get('v.agencyRegistration.Bank_IBAN_Number__c'));
        var IBANNumValue = event.getSource().get("v.value");
        console.log('IBANNUmbet', IBANNumValue);
        //var placeOfIncorporationMap = component.get("v.placeOfIncorporationMap");
        
        if (IBANNumValue.length <16) {
            component.set('v.issueIBANValidationError', true);
            //helper.getEmiratePicklist(component, event);
        }
        else{
            component.set('v.issueIBANValidationError', false);
            
        }
        
    },
    
    /*ornNumberRequired : function (component, event, helper) {
        var emirateValue = event.getSource().get("v.value");
        console.log('emirateValue', emirateValue);
        var emirateMap = component.get("v.emirateMap");
        
        if (emirateValue == 'Dubai') {
            console.log('emirateValue', emirateValue);
            component.set('v.ornRequired', true);
            console.log('ornRequired', component.get('v.ornRequired'));
        }else {
            component.set('v.ornRequired', false);
            console.log('ornRequired', component.get('v.ornRequired'));
        }
    }, commented by hitarth 7/8 */ 
    
    addBrokerProprietorDetailsRow : function (component, event, helper) {
        
        helper.addBrokerProprietorRecord(component, event);
        
    },
    
    removeBrokerProprietorDetailsRow: function(component, event, helper) {
        //Get the account list
        var brokerProprietorsList = component.get("v.brokerProprietorsList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        console.log('Partner record ',brokerProprietorsList[index].Id); 
        var brokerProprietorsListtoDelete=[];
        console.log('index to delete is '+ brokerProprietorsList[index].Id);
        
        if(brokerProprietorsList[index].Id!=null && brokerProprietorsList[index].Id!=undefined){
            brokerProprietorsListtoDelete.push(brokerProprietorsList[index]);
            console.log('brokerProprietorsListtoDelete ', brokerProprietorsListtoDelete);
            
        }
        console.log('brokerProprietorsListtoDelete ', brokerProprietorsListtoDelete);
        var action = component.get("c.deleteBrokerPartners");
        
        action.setParams({
            bokerPartnerLst : brokerProprietorsListtoDelete
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state', state);
            if(state == "SUCCESS"){
                var response = response.getReturnValue();
                console.log('response', response);
                
            } 
            else if(state == "ERROR"){
                console.log('error ');
            }
        });
        $A.enqueueAction(action);
        console.log('index is '+ index);
        brokerProprietorsList.splice(index, 1);
        component.set("v.brokerProprietorsList", brokerProprietorsList);
        
    },
    
    addBrokerAgentAuthDetailsRow : function (component, event, helper) {
        
        helper.addBrokerAgentAuthRecord(component, event);
        
    },
    
    removeBrokerAgentAuthDetailsRow: function(component, event, helper) {
        //Get the account list
        var brokerAgentAuthList = component.get("v.brokerAgentAuthList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        
        var brokerAgentLsttoDelete=[];
        if(brokerAgentAuthList[index].Id!=null && brokerAgentAuthList[index].Id!=undefined){
            brokerAgentLsttoDelete.push(brokerAgentAuthList[index]); 
            helper.deleteCreatedBrokerAgents(component, event,brokerAgentLsttoDelete);
            
        }
        brokerAgentAuthList.splice(index, 1);
        component.set("v.brokerAgentAuthList", brokerAgentAuthList);
    },
    
    addBrokerAgentRepresentativeDetailsRow : function (component, event, helper) {
        
        helper.addBrokerAgentRepresentativeRecord(component, event);
        
    },
    
    removeBrokerAgentRepresentativeDetailsRow: function(component, event, helper) {
        //Get the account list
        var brokerAgentRepresentativeList = component.get("v.brokerAgentRepresentativeList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        
        var brokerAgentLsttoDelete=[];
        if(brokerAgentRepresentativeList[index].Id!=null && brokerAgentRepresentativeList[index].Id!=undefined){
            brokerAgentLsttoDelete.push(brokerAgentRepresentativeList[index]); 
            helper.deleteCreatedBrokerAgents(component, event,brokerAgentLsttoDelete);
        }
        
        brokerAgentRepresentativeList.splice(index, 1);
        component.set("v.brokerAgentRepresentativeList", brokerAgentRepresentativeList);
    },
    
    addBrokerAgentContactsDetailsRow : function (component, event, helper) {
        
        helper.addBrokerAgentContactsRecord(component, event);
        
    },
    
    removeBrokerAgentContactsDetailsRow: function(component, event, helper) {
        //Get the account list
        var brokerAgentContactsList = component.get("v.brokerAgentContactsList");
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        
        var brokerAgentLsttoDelete=[];
        if(brokerAgentContactsList[index].Id!=null && brokerAgentContactsList[index].Id!=undefined){
            brokerAgentLsttoDelete.push(brokerAgentContactsList[index]); 
            helper.deleteCreatedBrokerAgents(component, event,brokerAgentLsttoDelete);
        }
        brokerAgentContactsList.splice(index, 1);
        component.set("v.brokerAgentContactsList", brokerAgentContactsList);
    },
    
    addRowBrokerAgent : function (component, event, helper) {
        
        // this fetches the existing data as rendered in datatable
        var myData = component.get("v.brokerAgentData"); 
        console.log('myData', myData);
        // now push a new empty row in the array retrieved
        myData.push(
            {
                First_Name__c: "",
                Last_Name__c: "",
                Country_Code__c: "",
                Mobile__c: "",
                Designation__c: "",
                Email__c: ""
            }
        );
        
        // now add the new array back to the attribute, so that it reflects on the component
        component.set("v.brokerAgentData", myData);  
    },
    
    handleOnLoad : function(component, event, helper) {
        
    },
    
    handleOnSubmit : function(component, event, helper) {
        
    },
    
    handleOnSuccess : function(component, event, helper) {
        console.log('registrationForm');
        var payload = event.getParams().response;
        console.log(payload.id);
        component.set('v.agencyRecordId', payload.id);
        console.log('agencyRecordId', component.get('v.agencyRecordId'));
        component.set("v.agencyDocumentUploadSection", true);
        component.set("v.agentsDetailSection", false);
        
        
        // component.set("v.reloadForm", false);
        //component.set("v.reloadForm", true);
        
    },
    
    handleOnSuccessAdditionalDetailsForm : function(component, event, helper) {
        var payload = event.getParams().response;
        console.log(">>> payload... "+payload.id);
    },
    
    handleOnSuccessauthorisedSignatoryForm : function(component, event, helper) {
        var payload = event.getParams().response;
        console.log(">>> payload... "+payload.id);
    },
    
    handleOnError : function(component, event, helper) {
        
    },
    
    goToBankDetails : function(component, event, helper) {
        component.set("v.agentsDetailSection", false);
        component.set("v.bankDetailSection", true);
    },
    
    backToAgentsDetails : function(component, event, helper) {
        component.set("v.agentsDetailSection", true);
        component.set("v.bankDetailSection", false);
        
    },
    
    recordTypeChange: function(component, event, helper) {
        var action = component.get("c.getRecTypeId");
        var recordTypeLabel = component.find("selectid").get("v.value");
        action.setParams({
            "recordTypeLabel": recordTypeLabel
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var RecTypeID  = response.getReturnValue();
                console.log('RecTypeID', RecTypeID);
                component.set('v.RecTypeID', RecTypeID);
                component.set('v.agencyRegistration.RecordTypeId', RecTypeID);
                
                /*var createRecordEvent = $A.get("e.force:createRecord");
                
                createRecordEvent.setParams({
                    "entityApiName": 'Broker__c',
                    "recordTypeId": RecTypeID
                });
                createRecordEvent.fire();*/
                
            } 
        });
        $A.enqueueAction(action);
    },
    
    //Added By Mamta//
    saveFirstPageAsDraft : function(component, event, helper) {
        component.set('v.saveFirstPgasDraft', true);  
        var AgencyDetails = component.get('v.agencyRegistration');  
        AgencyDetails.Status__c ='Draft';
        /*component.set('v.agencyRegistration', AgencyDetails);  
         component.set("v.agentsDetailSection", false);
         component.set("v.bankDetailSection", false);
         component.set("v.additionalDetailSection", false);
         component.set("v.agencyDocumentUploadSection", false);*/
        var action = component.get('c.goToDocumentUpload');
        $A.enqueueAction(action);        
        
    },
    
    //Added By Mamta//
    saveSecondPageAsDraft : function(component, event, helper) {
        component.set("v.spinner", true);
        component.set('v.saveFirstPgasDraft', true);  
        var AgencyDetails = component.get('v.agencyRegistration');  
        AgencyDetails.Status__c ='Draft';
        helper.saveAgencyRegistrationDetails(component,event);
        component.set("v.spinner", false);        
    },
    
    
    
    goToDocumentUpload : function(component, event, helper) {
        var trnCheck = component.get("v.tradeLicenseValidationError");
        var emailCheck = component.get("v.emailValidationError");
        var IBANCheck = component.get("v.issueIBANValidationError");
        var allValid = component.find('agencyInfo').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if(trnCheck){
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                "title": "Error",
                "type": "Error",
                "message": 'Trade license number is not unique'
            });
            toast.fire();
            
        }else if(IBANCheck){
            var toastfire = $A.get("e.force:showToast");
            toastfire.setParams({
                "title": "Error",
                "type": "Error",
                "message": 'IBAN should be in between 16 to 32 characters'
            });
            toastfire.fire();
        }else if(emailCheck){
            var toastfire = $A.get("e.force:showToast");
            toastfire.setParams({
                "title": "Error",
                "type": "Error",
                "message": 'Email should be Unique'
            });
            toastfire.fire();
        }else if( component.get( "v.tradeNumberWithSpace" ) ){
            var toastfire = $A.get("e.force:showToast");
            toastfire.setParams({
                "title": "Error",
                "type": "Error",
                "message": 'Trade Licence Number should not contain spaces.'
            });
            toastfire.fire();
        }else if (allValid) {
            component.set('v.agencyRegistration.Name', component.get('v.agencyRegistration.Company_Name__c'));
            component.set('v.agencyRegistration.Source__c', 'Broker Portal');
            component.set('v.agencyRegistration.Bank_Account__c',component.get('v.agencyRegistration.Bank_Account_Name__c'));
            if(component.get('v.agencyRegistration.Emirate__c')!=null)
                component.set('v.agencyRegistration.City__c',component.get('v.agencyRegistration.Emirate__c'));
            console.log('abc');
            var delayInMilliseconds = 700; //0.7 seconds
            component.set("v.spinner", true);
            component.set("v.disableBtn", true); 
            
            window.setTimeout(
                $A.getCallback(function() {
                    helper.saveAgencyRegistrationDetails(component, event);
                    console.log('v.agencyAccount '+ JSON.stringify(component.get('v.agencyAccount')));
                    if(component.get('v.agencyAccount')!=null && component.get('v.agencyAccount')!=undefined){
                        helper.saveAccountDetails(component, event);
                    }
                    
                    helper.fetchRecordIDDocStatusofPartners(component,event,helper);
                    helper.fetchRecordIDDocStatusofPartners(component,event,helper);
                    helper.fetchRecordIDDocStatusRepAgents(component,event,helper);
                    helper.fetchRecordIDDocStatusContacts(component, event, helper);
                }), delayInMilliseconds
            ); 
        }else {
            //alert('Please update the invalid form entries and try again.');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type": "Error",
                "message": 'Please fill all mandatory fields'
            });
            toastEvent.fire();
        }
    },
    
    goToadditionalDetails : function(component, event, helper) {
        component.set("v.spinner", true);
        var isCheckNext = component.get("v.IsallrequiredFilesUploaded");
        var isAllFileUploaded = true;
        var action = component.get("c.checkIfAllBrokerFilesUploaded");
        
        action.setParams({
            agencyRecordId : component.get('v.agencyRecordId')
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state', state);
            if(state == "SUCCESS"){
                isAllFileUploaded = response.getReturnValue();
                console.log('response ', response); 
                isAllFileUploaded=  response.getReturnValue();
                if(isAllFileUploaded==false){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "Error",
                        "message": 'Please add all required documents before moving to next'
                    });
                    toastEvent.fire();
                }
                else{
                    component.set("v.agentsDetailSection", false);
                    component.set("v.agencyDocumentUploadSection", false);
                    component.set("v.bankDetailSection", false);
                    component.set("v.additionalDetailSection", true);
                    var brokerProprietorsList = component.get("v.brokerProprietorsList");
                    var brokerAgentAuthList = component.get("v.brokerAgentAuthList");
                    var brokerAgentRepresentativeList = component.get("v.brokerAgentRepresentativeList");
                    var brokerAgentContactsList = component.get("v.brokerAgentContactsList");
                    
                    if(brokerProprietorsList.length < 1){
                        helper.addBrokerProprietorRecord(component, event);
                    }
                    if(brokerAgentAuthList.length < 1){
                        helper.addBrokerAgentAuthRecord(component, event);
                    } 
                    if(brokerAgentRepresentativeList.length < 1){
                        helper.addBrokerAgentRepresentativeRecord(component, event);
                    } 
                    if(brokerAgentContactsList.length < 1){
                        helper.addBrokerAgentContactsRecord(component, event);
                    }
                    helper.getCountryCodePicklist(component, event);
                    helper.getBrokerAccessTypePicklist(component, event);
                }  
                component.set("v.spinner", false);  
            } 
            else if(state == "ERROR"){
                alert('Error in calling server side action');
                component.set("v.spinner", false);  
            }
        });
        $A.enqueueAction(action);
        console.log('isAllFileUploaded is '+ isAllFileUploaded);
        
    },
    goToBack:function(component, event, helper) {
        component.set("v.spinner", true);
        var agencyRecordId = component.get('v.agencyRecordId');
        console.log('agencyRecordId on Go Back', component.get('v.agencyRecordId'));
        if(agencyRecordId != null){
            component.set("v.spinner", true);
            console.log('Called');
            helper.getAgencyRegistrationDetails(component, event);
            //component.set("v.existingRegistraionRecord", true);
            component.set("v.agentsDetailSection", true);
            console.log('existingRegistraionRecord', component.get('v.existingRegistraionRecord'));
        }
        //component.set("v.agentsDetailSection", true);
        component.set("v.additionalDetailSection", false);
        component.set("v.agencyDocumentUploadSection", false); 
        component.set("v.spinner", false);
    },
    backToDoc:function(component, event, helper) {
        component.set("v.agentsDetailSection", false);
        component.set("v.additionalDetailSection", false);
        component.set("v.agencyDocumentUploadSection", true);
        
    },
    saveBrokerProprietor : function(component, event, helper) {
        //component.find("additionalDetailsForm").submit();
        console.log('saveBrokerProprietor Called');
        component.set("v.agentsDetailSection", false);
        component.set("v.bankDetailSection", false);
        component.set("v.additionalDetailSection", true);
    },
    
    authorisedSignatory : function(component, event, helper) {
        //component.find("registrationForm").submit();
        //component.find("authorisedSignatoryForm").submit();
        //component.find("additionalDetailsForm").submit();
        //console.log('authorisedSignatoryForm Called');
        component.set("v.agentsDetailSection", false);
        component.set("v.bankDetailSection", false);
        component.set("v.additionalDetailSection", true);
    },
    
    goToAgencyDetails : function(component, event, helper) {
        component.set("v.agencyDocumentUploadSection", false);
        component.set("v.agentsDetailSection", True);
        
        component.set("v.bankDetailSection", false);
        component.set("v.additionalDetailSection", false);
    },
    
    setAgencyName : function(component, event, helper) {
        var companyName = component.find('companyName').get('v.value');
        console.log('companyName', companyName);
        component.set('v.agencyName', companyName);
    },
    
    tradeLicenseNumberFieldChange : function (component, event, helper) {
        var tradeLicenseNumber = event.getSource().get("v.value");
        let AgencyDetails = component.get('v.agencyRegistration');  
        
        let spaceAvailale = false
        if( tradeLicenseNumber.indexOf(' ') >= 0 ){
            spaceAvailale = true;
        }
        component.set( "v.tradeNumberWithSpace", spaceAvailale );
        
        console.log('tradeLicenseNumber', tradeLicenseNumber);
        var action = component.get("c.checkDuplicateTRN");
        action.setParams({
            "tradeLicenseNumber": tradeLicenseNumber,
            "brokerId": AgencyDetails.Id,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result  = response.getReturnValue();
                component.set('v.tradeLicenseValidationError', result);
                
            } 
        });
        $A.enqueueAction(action);
        
    },
    
    //Created by Sourabh for check email unique
    emailFieldChange : function (component, event, helper) {
        var brokerEmail  = event.getSource().get("v.value");
        let AgencyDetails = component.get('v.agencyRegistration');
        console.log('brokerEmail', brokerEmail );
        var action = component.get("c.checkDuplicateEmailAddress");
        action.setParams({
            "brokerEmail": brokerEmail,
            "brokerId": AgencyDetails.Id,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result  = response.getReturnValue();
                component.set('v.emailValidationError', result);
                
            } 
        });
        $A.enqueueAction(action);
        
    },
    
    //Created by Mamta to check validate number in mobile
    mobileFieldChange : function (component, event, helper) {
        var phone  = event.getSource().get("v.value");
        console.log('phone', phone );
        console.log(isNaN(phone));
        if (isNaN(phone)) 
        {
            component.set('v.phoneValidationError', true);
        }
        else{
            component.set('v.phoneValidationError', false);
            
        }
        
    },
    
    
    //Added By Mamta//
    saveThirdPageAsDraft : function(component, event, helper) {
        component.set('v.saveThirdPgasDraft', true);  
        var AgencyDetails = component.get('v.agencyRegistration');  
        AgencyDetails.Status__c ='Draft';
        /*component.set('v.agencyRegistration', AgencyDetails);  
         component.set("v.agentsDetailSection", false);
         component.set("v.bankDetailSection", false);
         component.set("v.additionalDetailSection", false);
         component.set("v.agencyDocumentUploadSection", false);*/
        var action = component.get('c.saveRecord');
        $A.enqueueAction(action);
        
        
        
    },
    
    saveRecord: function(component, event, helper) {
        if( component.get('v.disableFields') ){
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                "title": "Error",
                "type": "Error",
                "message": $A.get("$Label.c.NKHL_Allowed_To_Update")
            });
            toast.fire();
        }else{
            var allValid = component.find('myinput').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && !inputCmp.get('v.validity').valueMissing;
            }, true);
            if (allValid) {
                var brokerProprietorsList = component.get("v.brokerProprietorsList");
                var totalPrcntShare =0;
                for(var i=0;i<brokerProprietorsList.length;i++){
                    totalPrcntShare+= parseInt(brokerProprietorsList[i].Shareholder_Percentage__c);
                }
                console.log('totalPrcntShare is '+ totalPrcntShare);
                if(totalPrcntShare!=100){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "Error",
                        "message": 'Total sharehold percentage of all partners must be 100%'
                    });
                    toastEvent.fire();
                }
                else{
                    helper.saveRecord(component, event, helper);
                }
            } else {
                //alert('Please update the invalid form entries and try again.');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "type": "Error",
                    "message": 'Please fill all mandatory fields'
                });
                toastEvent.fire();
            }
        }
        
    },
    
    handleSaveBrokerProp : function(component, event, helper) {
        console.log('handleSave');
        var draftValues = component.find("brokerPropDataTable").get("v.draftValues");
        console.log('draftValues',  draftValues);
        
        var newBrokerProp = component.get("v.data");
        console.log('newBrokerProp', newBrokerProp);
        var action = component.get("c.createBrokerProprietorRecord");
        action.setParams({ 
            "newBrokerProp": newBrokerProp
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            console.log('state', state);
            if (state === "SUCCESS") {
                var name = a.getReturnValue();
                console.log('name', name);
            }
        });
        $A.enqueueAction(action)
    },
    
    
    handleSaveBrokerAgent : function(component, event, helper) {
        console.log('handleSave');
        var draftValues = component.find("brokerAgentDataTable").get("v.draftValues");
        console.log('draftValues',  draftValues);
        
        var newBrokerProp = component.get("v.brokerAgentData");
        console.log('newBrokerProp', newBrokerProp);
        var action = component.get("c.createBrokerAgentRecord");
        action.setParams({ 
            "newBrokerProp": newBrokerProp
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            console.log('state', state);
            if (state === "SUCCESS") {
                var name = a.getReturnValue();
                console.log('name', name);
            }
        });
        $A.enqueueAction(action)
    },
    
    saveBrokerPartners : function(component, event, helper) {
        component.set("v.spinner", true); 
        if( component.get('v.disableFields') ){
            component.set("v.spinner", false); 
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                "title": "Error",
                "type": "Error",
                "message": $A.get("$Label.c.NKHL_Allowed_To_Update")
            });
            toast.fire();
        }else{
            var brokerProprietorsList = component.get("v.brokerProprietorsList");
            var emiratesIdPatternMismatch = false;
            var emiratesIdPattern = new RegExp("[0-9]{3}-[0-9]{4}-[0-9]{7}-[0-9]{1}");
            var totalPrcntShare =0;
            
            for(var i=0;i<brokerProprietorsList.length;i++){
                totalPrcntShare+= parseInt(brokerProprietorsList[i].Shareholder_Percentage__c);
                if(component.get("v.agencyRegistration").Place_of_Incorporation__c == 'AE'){
                    if( !emiratesIdPattern.test(brokerProprietorsList[i].Emirates_Id__c) ){
                        emiratesIdPatternMismatch = true;
                    }
                }
            }
            
            console.log('totalPrcntShare is '+ totalPrcntShare);
            if(totalPrcntShare!=100){
                component.set("v.spinner", false); 
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "type": "Error",
                    "message": 'Total sharehold percentage of all partners must be 100%'
                });
                toastEvent.fire();
                
            }else if( emiratesIdPatternMismatch ){
                component.set("v.spinner", false); 
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "type": "Error",
                    "message": 'Please enter Emirates Id in correct format.'
                });
                toastEvent.fire();
            }else{
                console.log('spinner ',component.get("v.spinner"));
                component.set("v.disableBtn", true);
                helper.saveBrokerProprietor(component, event, helper);
            }    
        }
        
        
        
    },
    
    saveAuthAgent : function(component, event, helper) {
        
        
        if( component.get('v.disableFields') ){
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                "title": "Error",
                "type": "Error",
                "message": $A.get("$Label.c.NKHL_Allowed_To_Update")
            });
            toast.fire();
        }else{
            component.set("v.disableBtn", true);
            helper.saveAuthAgent(component, event, helper);
        }
        
        
    },
    
    saveRepresentativeAgent : function(component, event, helper) {
        
        
        if( component.get('v.disableFields') ){
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                "title": "Error",
                "type": "Error",
                "message": $A.get("$Label.c.NKHL_Allowed_To_Update")
            });
            toast.fire();
        }else{
            var brokerAgentRepresentativeList = component.get("v.brokerAgentRepresentativeList");
            let isValid = true;
            for( let i=0; i<brokerAgentRepresentativeList.length; i++ ){
                let rec = brokerAgentRepresentativeList[i];
                if( !rec.First_Name__c || !rec.Last_Name__c || !rec.Country_Code__c || !rec.Mobile__c || !rec.Email__c ){
                    isValid = false;
                }
            }
            if( isValid ){
                component.set("v.disableBtn", true);
                helper.saveRepresentativeAgent(component, event, helper);
            }else{
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    "title": "Error",
                    "type": "Error",
                    "message": "Fill all the required fields for Admin and Sales Manager."
                });
                toast.fire();
            }
        }
        
        
    },
    
    saveAdditionalContacts : function(component, event, helper) {
        
        if( component.get('v.disableFields') ){
            var toast = $A.get("e.force:showToast");
            toast.setParams({
                "title": "Error",
                "type": "Error",
                "message": $A.get("$Label.c.NKHL_Allowed_To_Update")
            });
            toast.fire();
        }else{
            component.set("v.disableBtn", true);
            helper.saveAdditionalContacts(component, event, helper);
        }
        
        
    },
    
    
    /* Popup Modal Method To Upload Documents For Broker Agent */
    showModelBrokerPartners: function(component, event, helper) {
        
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        console.log('index', index);
        var brokerPartnersLst = component.get("v.brokerProprietorsList");
        console.log('brokerPartnersLst index', brokerPartnersLst[index].Id);
        component.set('v.parentId', brokerPartnersLst[index].Id);
        console.log('parentId', component.get('v.parentId'));
        component.set('v.brokerAgentName', brokerPartnersLst[index].Name);
        component.set("v.showModelBrokerPartners", true);
        component.set("v.UploadType", 'brokerPartner');
        
        
    },
    
    showModelAuthAgent: function(component, event, helper) {
        
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        console.log('index', index);
        var brokerAgentAuthList = component.get("v.brokerAgentAuthList");
        console.log('brokerAgentAuthList index', brokerAgentAuthList[index].Id);
        component.set('v.parentId', brokerAgentAuthList[index].Id);
        console.log('parentId', component.get('v.parentId'));
        component.set('v.brokerAgentName', brokerAgentAuthList[index].First_Name__c + ' ' + brokerAgentAuthList[index].Last_Name__c);
        component.set("v.showModelAuthAgent", true);
        
    },
    
    showModelRepresentativeAgent: function(component, event, helper) {
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        console.log('index is '+ index);
        var brokerAgentRepresentativeList = component.get("v.brokerAgentRepresentativeList");
        console.log('brokerAgentRepresentativeList index is '+ brokerAgentRepresentativeList[index].Id);
        component.set('v.parentId', brokerAgentRepresentativeList[index].Id);
        console.log('parentId', component.get('v.parentId'));
        component.set('v.brokerAgentName', brokerAgentRepresentativeList[index].First_Name__c + ' ' + brokerAgentRepresentativeList[index].Last_Name__c);
        component.set("v.showModelRepresentativeAgent", true);
        
    },
    
    showModelAdditionalContacts: function(component, event, helper) {
        
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        console.log('index', index);
        var brokerAgentContactsList = component.get("v.brokerAgentContactsList");
        console.log('brokerAgentContactsList index', brokerAgentContactsList[index].Id);
        component.set('v.parentId', brokerAgentContactsList[index].Id);
        console.log('parentId', component.get('v.parentId'));
        component.set('v.brokerAgentName', brokerAgentContactsList[index].First_Name__c + ' ' + brokerAgentContactsList[index].Last_Name__c);
        component.set("v.showModelAdditionalContacts", true);
        //console.log('agencyApprovalStatus is '+ component.get('v.agencyApprovalStatus'));
        
    },
    hideModelBrokerPartners: function(component, event, helper) {
        component.set("v.showModelBrokerPartners", false);
    },
    
    hideModelAuthAgent: function(component, event, helper) {
        component.set("v.showModelAuthAgent", false);
    },
    
    hideModelRepresentativeAgent: function(component, event, helper) {
        component.set("v.showModelRepresentativeAgent", false);
    },
    
    hideModelAdditionalContacts: function(component, event, helper) {
        component.set("v.showModelAdditionalContacts", false);
    },
    
    saveDetailsBrokerPartners: function(component, event, helper) {
        component.set("v.showModelBrokerPartners", false);
        helper.fetchRecordIDDocStatusofPartners(component, event, helper);
        
    },
    
    saveDetailsAuthAgent: function(component, event, helper) {
        component.set("v.showModelAuthAgent", false);
        helper.fetchRecordIDDocStatusAuthSigns(component, event, helper);
        
    },
    
    saveDetailsRepresentativeAgent: function(component, event, helper) {
        component.set("v.showModelRepresentativeAgent", false);
        helper.fetchRecordIDDocStatusRepAgents(component, event, helper);
        
    },
    
    saveDetailsAdditionalContacts: function(component, event, helper) {
        component.set("v.showModelAdditionalContacts", false);
        helper.fetchRecordIDDocStatusContacts(component, event, helper);
    },
    
    /* Popup Modal Method To Upload Documents For Broker Agent */
    
    handleEmiratesIdChange : function(component, event, helper) {
        let index = event.target.dataset.id;
        let bp = component.get('v.brokerProprietorsList');
        if(bp[index].Emirates_Id__c.length == 3){
            bp[index].Emirates_Id__c = bp[index].Emirates_Id__c + '-';
        }else if(bp[index].Emirates_Id__c.length == 8){
            bp[index].Emirates_Id__c = bp[index].Emirates_Id__c + '-';
        }
            else if(bp[index].Emirates_Id__c.length == 16){
                bp[index].Emirates_Id__c = bp[index].Emirates_Id__c + '-';
            }
        component.set('v.brokerProprietorsList[index].Emirates_Id__c',bp[index].Emirates_Id__c);
    },
    
})