({
    getAgencyRegistrationDetails: function(component, event,helper) {
        component.set("v.spinner", true);
        var action = component.get("c.getBrokerRegistrationDetails");
        var brokerAgentContactsList  = component.get('v.brokerAgentContactsList');
        console.log('brokerAgentContactsList', brokerAgentContactsList);
        
        action.setParams({
            recordId : component.get('v.agencyRecordId')
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state', state);
            if(state == "SUCCESS"){
                var response = response.getReturnValue();
                console.log('==response==', response);
                console.log('==responseApproval==', response.broker.Agency_Approval_Status__c);
                console.log('==responseAccounts==', response.broker.Accounts__r);
                //console.log(response.broker.Accounts__r[0]);
                if(response.broker.Accounts__r!=null && response.broker.Accounts__r!=undefined){
                   component.set('v.agencyAccount', response.broker.Accounts__r[0]);

                }

                if(response.broker.Place_of_Incorporation__c == 'AE'){
                    component.set('v.disabledEmirateField',false);
                }
                console.log('v.agencyAccount', component.get('v.agencyAccount'));
                component.set('v.agencyApprovalStatus', response.broker.Agency_Approval_Status__c);

                if(response.broker.Agency_Approval_Status__c == 'Approved' || 
                response.broker.Agency_Approval_Status__c == 'Pending' ||
                response.broker.Agency_Approval_Status__c == 'Pending 1st level' ||
                response.broker.Agency_Approval_Status__c == 'Pending 2nd level' ||
                response.broker.Agency_Approval_Status__c == 'Rejected 1st level'){
                    component.set('v.disableFields',true);
                }
                
                console.log('responseAutoNumber', response.broker.Broker_Number__c);
                component.set('v.refNumber', response.broker.Broker_Number__c);
                console.log('refNumber', component.get('v.refNumber'));
                
                component.set('v.agencyRegistration', response.broker);
                component.set('v.brokerProprietorsList', response.brokerprop);
                
                 this.fetchRecordIDDocStatusofPartners(component,event,helper);

                
                component.set('v.brokerAgentAuthList', response.brokerAgentAuth);
                 this.fetchRecordIDDocStatusAuthSigns(component,event,helper);

                var brokerAgentAuthList = component.get('v.brokerAgentAuthList');
                for(var i = 0; i < brokerAgentAuthList.length; i++){
                    component.set('v.parentId', brokerAgentAuthList[i].Id);
                    console.log('parentId', component.get('v.parentId'));
                    component.set('v.brokerAgentName', brokerAgentAuthList[i].First_Name__c + ' ' + brokerAgentAuthList[i].Last_Name__c);
                }
                
                component.set('v.brokerAgentRepresentativeList', response.brokerAgentRepresentativeList);

                var brokerAgentRepresentativeList = component.get('v.brokerAgentRepresentativeList');
                this.fetchRecordIDDocStatusRepAgents(component,event,helper);

                for(var i = 0; i < brokerAgentRepresentativeList.length; i++){
                    component.set('v.parentId', brokerAgentRepresentativeList[i].Id);
                    console.log('parentId', component.get('v.parentId'));
                    component.set('v.brokerAgentName', brokerAgentRepresentativeList[i].First_Name__c + ' ' + brokerAgentRepresentativeList[i].Last_Name__c);
                }
                
                component.set('v.brokerAgentContactsList', response.brokerAgentContactsList);
                var brokerAgentContactsList = component.get('v.brokerAgentContactsList');
                this.fetchRecordIDDocStatusContacts(component, event, helper);

                for(var i = 0; i < brokerAgentContactsList.length; i++){
                    component.set('v.parentId', brokerAgentContactsList[i].Id);
                    console.log('parentId', component.get('v.parentId'));
                    component.set('v.brokerAgentName', brokerAgentContactsList[i].First_Name__c + ' ' + brokerAgentContactsList[i].Last_Name__c);
                }
                
                console.log('brokerAgentContactsList', component.get('v.brokerAgentContactsList'));
                component.set("v.spinner", false);
            } 
            else if(state == "ERROR"){
                alert('Error in calling server side action');
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    saveAgencyRegistrationDetails: function(component, event) {
        component.set("v.disableBtn", true); 

        var AgencyDetails = component.get('v.agencyRegistration');
        console.log('AgencyDetails', JSON.stringify(AgencyDetails));

        if(AgencyDetails.Agency_Approval_Status__c != 'Rejected 1st level'){
        
        var action = component.get("c.createAgencyRegistrationRecord");
         
        // Added by Rohit - to avoid updating agency status from portal
        AgencyDetails.Agency_Approval_Status__c = undefined;

        action.setParams({
            AgencyDetails : AgencyDetails,
            saveAsDraft:component.get('v.saveFirstPgasDraft')
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state', state);
            if(state == "SUCCESS"){
                var response = response.getReturnValue();
                console.log('response', response);
                console.log('responseId', response.Id);
                console.log('refNumber', response.Broker_Number__c);
                component.set('v.refNumber', response.Broker_Number__c);
                component.set("v.agencyRecordId", response.Id);
                
                console.log('==response==', component.get('v.agencyRecordId'));                
                component.set("v.agentsDetailSection", false);
                component.set("v.bankDetailSection", false);
                component.set("v.additionalDetailSection", false);
                console.log('==agencyDocumentUploadSection==',component.get('v.agencyDocumentUploadSection'));
                if( component.get('v.saveFirstPgasDraft')==true){
                  // this.sendDraftWelcomeEmail(component,event);  //send draft Welcome email
                   component.set("v.agencyDocumentUploadSection", false);
                   component.set('v.savePageAsDraft',true ); 
 
                }
                else{
                   component.set("v.agencyDocumentUploadSection", true);
   
                }
                
            } 
            else if(state == "ERROR"){
                alert('Error -  in calling server side action');
            }
           component.set("v.disableBtn", false);
           component.set("v.spinner", false);    


        });
        $A.enqueueAction(action);
        }else{
            component.set("v.agencyDocumentUploadSection", true);
            component.set("v.agentsDetailSection", false);
            component.set("v.bankDetailSection", false);
            component.set("v.additionalDetailSection", false);
            component.set("v.agencyRecordId", AgencyDetails.Id);
            component.set("v.spinner", false);
            component.set("v.disableBtn", false); 

        }
        
         
    },
    //added By mamta- Send welcome email on being saved as draft
    sendDraftWelcomeEmail: function(component, event) {
        
        var action = component.get("c.sendEmailtoAgency");
        
        action.setParams({
            agencyRecordId : component.get('v.agencyRecordId'),
            TemplateName: 'Draft_registration_of_Agency'
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state', state);
            if(state == "SUCCESS"){
                var response = response.getReturnValue();
                console.log('response', response);
                
            } 
            else if(state == "ERROR"){
                //alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },
    
     deleteCreatedBrokerAgents: function(component, event,brokerAgents) {
        
        var action = component.get("c.deleteBrokerAgents");
        
        action.setParams({
            bokerAgentLst : brokerAgents
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state', state);
            if(state == "SUCCESS"){
                var response = response.getReturnValue();
                console.log('response', response);
                
            } 
            else if(state == "ERROR"){
                console.log('ERROR');
            }
        });
        $A.enqueueAction(action);
    },
     saveAccountDetails: function(component, event) {
        
        var action = component.get("c.updateAccount");
        
        action.setParams({
            account : component.get('v.agencyAccount')
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state', state);
            if(state == "SUCCESS"){
                var response = response.getReturnValue();
                console.log('response', response);
                
            } 
            else if(state == "ERROR"){
                alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },
    
    addBrokerProprietorRecord: function(component, event) {
        
        var brokerProprietorsList = component.get("v.brokerProprietorsList");
        
        
            brokerProprietorsList.push({
                Name: "",
                Shareholder_Passport_No__c: "",
                Shareholder_Percentage__c: "",
                Agency_Registration__c: component.get('v.agencyRecordId')
            });
        
        component.set("v.brokerProprietorsList", brokerProprietorsList);
    },
    
    addBrokerAgentAuthRecord: function(component, event) {
        
        var brokerAgentAuthList = component.get("v.brokerAgentAuthList");
        
            brokerAgentAuthList.push({
                First_Name__c: "",
                Last_Name__c: "",
                Country_Code__c: "",
                Mobile__c: "",
                Designation__c: "",
                Email__c: "",
                Broker_Access_Type__c:"Admin",
                Agency_Registration__c: component.get('v.agencyRecordId')
            });
        
        component.set("v.brokerAgentAuthList", brokerAgentAuthList);
    },
    
    addBrokerAgentRepresentativeRecord: function(component, event) {
        
        var brokerAgentRepresentativeList = component.get("v.brokerAgentRepresentativeList");
        
        if(brokerAgentRepresentativeList.length < 1){
            brokerAgentRepresentativeList.push(
                {
                    First_Name__c: "",
                    Last_Name__c: "",
                    Country_Code__c: "",
                    Mobile__c: "",
                    Designation__c: "",
                    Email__c: "",
                    Broker_Access_Type__c: "Admin",
                    Agency_Registration__c: component.get('v.agencyRecordId')
                },
                {
                    First_Name__c: "",
                    Last_Name__c: "",
                    Country_Code__c: "",
                    Mobile__c: "",
                    Designation__c: "",
                    Email__c: "",
                    Broker_Access_Type__c: "Agents",
                    Agency_Registration__c: component.get('v.agencyRecordId')
                }
            );
        }else {
            brokerAgentRepresentativeList.push(
                {
                    First_Name__c: "",
                    Last_Name__c: "",
                    Country_Code__c: "",
                    Mobile__c: "",
                    Designation__c: "",
                    Email__c: "",
                    Agency_Registration__c: component.get('v.agencyRecordId')
                }
            );
        }
        
        component.set("v.brokerAgentRepresentativeList", brokerAgentRepresentativeList);
    },
    
    addBrokerAgentContactsRecord: function(component, event) {
        
        var brokerAgentContactsList = component.get("v.brokerAgentContactsList");
        
        brokerAgentContactsList.push({
            First_Name__c: "",
            Last_Name__c: "",
            Country_Code__c: "",
            Mobile__c: "",
            Designation__c: "",
            Email__c: "",
            //Broker_Access_Type__c:"Admin",
            Agency_Registration__c: component.get('v.agencyRecordId')
        });
        
        component.set("v.brokerAgentContactsList", brokerAgentContactsList);
    },
    
    getAgencyTypePicklist: function(component, event) {
        var action = component.get("c.getAgencyType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var agencyTypeMap = [];
                for(var key in result){
                    agencyTypeMap.push({key: key, value: result[key]});
                }
                component.set("v.agencyTypeMap", agencyTypeMap);
            }
        });
        $A.enqueueAction(action);
    },
    getAgencyLocationPicklist: function(component, event) {
        var action = component.get("c.getAgencyLocation");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var agencyLocationMap = [];
                for(var key in result){
                    agencyLocationMap.push({key: key, value: result[key]});
                }
                component.set("v.agencyLocationMap", agencyLocationMap);
            }
        });
        $A.enqueueAction(action);
    },
    getBankNamePicklist: function(component, event) {
        var action = component.get("c.getBankName");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var bankNameMap = [];
                for(var key in result){
                    bankNameMap.push({key: key, value: result[key]});
                }
                component.set("v.bankNameMap", bankNameMap);
            }
        });
        $A.enqueueAction(action);
    },
    getAgreementStatusPicklist: function(component, event) {
        var action = component.get("c.getAgreementStatus");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var agreementMap = [];
                for(var key in result){
                    agreementMap.push({key: key, value: result[key]});
                }
                component.set("v.agreementStatusMap", agreementMap);
            }
        });
        $A.enqueueAction(action);
    },
    getNationalityMap: function(component, event) {
        var action = component.get("c.getNationality");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var naMap = [];
                for(var key in result){
                    naMap.push({key: key, value: result[key]});
                }
                component.set("v.nationalityMap", naMap);
            }
        });
        $A.enqueueAction(action);
    },
    getAgencyCountryCodePicklist: function(component, event) {
        var action = component.get("c.getAgencyCountryCode");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
                var agencyCountryCodeMap = [];
                agencyCountryCodeMap.push(
                    {key:'971',value:'UAE(+971)'},
                    {key:'965',value:'Kuwait(+965)'},
                    {key:'973',value:'Bahrain(+973)'},
                    {key:'968',value:'Oman(+968)'},
                    {key:'966',value:'Saudi Arabia(+966)'},
                    {key:'91',value:'India(+91)'},
                    {key:'92',value:'Pakistan(+92)'}
                );
                for(var key in result){
                    agencyCountryCodeMap.push({key: key, value: result[key]});
                }
                
                component.set("v.agencyCountryCodeMap", agencyCountryCodeMap.sort());
            }
        });
        $A.enqueueAction(action);
    },
    /*getCountryPicklist: function(component, event) {
        var action = component.get("c.getCountryList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var countryNameMap = [];
                for(var key in result){
                    countryNameMap.push({key: key, value: result[key]});
                }
                component.set("v.countryMap", countryNameMap);
            }
        });
        $A.enqueueAction(action);
    },*/
    
    
    
    getAgencyBankAccountCurrencyPicklist: function(component, event) {
        var action = component.get("c.getAgencyBankAccountCurrency");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var agencyBankAccountCurrencyMap = [];
                
                for(var key in result){
                    agencyBankAccountCurrencyMap.push({key: key, value: result[key]});
                }
                component.set("v.agencyBankAccountCurrencyMap", agencyBankAccountCurrencyMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCountryCodePicklist: function(component, event) {
        var action = component.get("c.getCountryCode");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var countryCodeMap = [];
                countryCodeMap.push({key:'971',value:'UAE(+971)'});
                for(var key in result){
                    countryCodeMap.push({key: key, value: result[key]});
                }
                component.set("v.countryCodeMap", countryCodeMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getBrokerAccessTypePicklist: function(component, event) {
        var action = component.get("c.getBrokerAccessType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var brokerAccessMap = [];
                for(var key in result){
                    brokerAccessMap.push({key: key, value: result[key]});
                }
                component.set("v.brokerAccessMap", brokerAccessMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getPlaceOfIncorporationPicklist: function(component, event) {
        var action = component.get("c.getPlaceOfIncorporation");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var placeOfIncorporationMap = [];
                for(var key in result){
                    placeOfIncorporationMap.push({key: key, value: result[key]});
                }
                console.log('incorp==',placeOfIncorporationMap);
                component.set("v.placeOfIncorporationMap", placeOfIncorporationMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    getEmiratePicklist: function(component, event) {
        var action = component.get("c.getEmirate");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var emirateMap = [];
                for(var key in result){
                    emirateMap.push({key: key, value: result[key]});
                }
                component.set("v.emirateMap", emirateMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    saveRecord: function(component, event, helper) {
        component.set("v.disableBtn", true); 
        component.set("v.spinner", true);
        
        var brokerProprietorsList = component.get("v.brokerProprietorsList");
        console.log('brokerProprietorsList', brokerProprietorsList);
        
        var brokerAgentAuthList = component.get("v.brokerAgentAuthList");
        console.log('brokerAgentAuthList', brokerAgentAuthList);
        
        var brokerAgentRepresentativeList = component.get("v.brokerAgentRepresentativeList");
        console.log('brokerAgentRepresentativeList', brokerAgentRepresentativeList);
        
        var brokerAgentContactsList = component.get("v.brokerAgentContactsList");
        console.log('brokerAgentContactsList', brokerAgentContactsList);
        
        var action = component.get("c.createBrokerProprietorsAndAgentsRecord");
        
        action.setParams({
            "agencyRecordId" : component.get("v.agencyRecordId"),
            "brokerProprietorsList": brokerProprietorsList,
            "brokerAgentAuthList": brokerAgentAuthList,
            "brokerAgentRepresentativeList": brokerAgentRepresentativeList,
            "brokerAgentContactsList": brokerAgentContactsList,
            "saveAsDraft":component.get('v.saveThirdPgasDraft')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state', state);
            
            //var result = JSON.stringify(response.getReturnValue());
            var result = (response.getReturnValue());

            console.log('result', result);
            
            if (state === "SUCCESS") {
                console.log('Response', response.getReturnValue());
                if(result[0]=='true'){
                    /*Added By Mamta- Start- Save page as Draft*/
                   if(component.get('v.saveThirdPgasDraft')==true){
                        component.set("v.savePageAsDraft", true);
                    }
                    else{
                      component.set("v.greetingPage", true);
                    }     /*Added By Mamta- End- Save page as Draft*/
                component.set("v.agentsDetailSection", false);
                component.set("v.bankDetailSection", false);
                component.set("v.additionalDetailSection", false);
                }
                else{
                    var errorMsg = result[1];
                    console.log('errormsg is '+ errorMsg);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "Error",
                        "message": errorMsg
                    });
                    toastEvent.fire();
                }
            }
             component.set("v.disableBtn", false);
             component.set("v.spinner", false); 


            
        });
        $A.enqueueAction(action);
        
    },
    
    saveBrokerProprietor : function(component, event, helper) {
        
        console.log(component.get('v.spinner'));
        var brokerProprietorsList = component.get("v.brokerProprietorsList");
        console.log('brokerProprietorsList', brokerProprietorsList);
        //var brokerPr
        var brokerPartnersRecords = [];
        for(var i=0;i<brokerProprietorsList.length;i++){
            brokerPartnersRecords.push(brokerProprietorsList[i]);
        }
        
        var action = component.get("c.createBrokerProprietorsRecord");
        
        action.setParams({
            "agencyRecordId" : component.get("v.agencyRecordId"),
            "brokerProprietorsList": brokerPartnersRecords//brokerProprietorsList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state', state);
            
            var result = JSON.stringify(response.getReturnValue());
            console.log('result', result);
            
            if (state === "SUCCESS") {
                console.log('Response', response.getReturnValue());
                var response = response.getReturnValue();
                component.set('v.brokerProprietorsList', response);
                this.fetchRecordIDDocStatusofPartners(component,event,helper);
                var brokerPartnerList = component.get('v.brokerProprietorsList');
                for(var i = 0; i < brokerPartnerList.length; i++){
                    component.set('v.parentId', brokerPartnerList[i].Id);
                   // component.set("v.IsallrequiredFilesUploaded",false);//Added by mamta for file upload validation
                    console.log('parentId', component.get('v.parentId'));
                    component.set('v.brokerAgentName', brokerPartnerList[i].Name );
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "type": "Success",
                    "message": 'Record is created successfully!'
                });
                toastEvent.fire();
            }
            
            component.set("v.disableBtn", false);
            
        });
        $A.enqueueAction(action);
        

        component.set("v.spinner", false); 
    },
    
    fetchRecordIDDocStatusofPartners : function(component, event, helper) {
        var brokerProprietorsList = component.get("v.brokerProprietorsList");
        var brokerAgentAuthList = component.get("v.brokerAgentAuthList");
        var action = component.get("c.getrecIDDocStatusMap");
        action.setParams({
            "brokerProprietorsList" : brokerProprietorsList,
            "brokerAgentsList": brokerAgentAuthList//brokerProprietorsList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                /*var CheckedRecsMap = component.get("v.idDOCMap");
                var newMap= new Map();
                newMap.forEach((value,key)=>CheckedRecsMap.set(value,key));*/
                console.log('map of partners are '+ JSON.stringify(response.getReturnValue()));
                //component.set("v.idDOCMap",response.getReturnValue());
                var brokerDocMap = response.getReturnValue();
                var brokerPartners=[];
                for(var i=0; i <brokerProprietorsList.length;i++){
                    var brokerPartner = new Object();
                    brokerPartner=brokerProprietorsList[i];
                    brokerPartner.DocUploadStatus = brokerDocMap[brokerPartner.Id];
                    brokerPartners.push(brokerPartner);
                    
                }
                component.set('v.brokerProprietorsList',brokerPartners );
               // alert(JSON.stringify(component.get('v.brokerProprietorsList')));

            }
        });
        $A.enqueueAction(action);
    },
    
    fetchRecordIDDocStatusAuthSigns : function(component, event, helper) {
        var brokerProprietorsList = component.get("v.brokerProprietorsList");
        var brokerAgentAuthList = component.get("v.brokerAgentAuthList");
        var action = component.get("c.getrecIDDocStatusMap");
        action.setParams({
            "brokerProprietorsList" : brokerProprietorsList,
            "brokerAgentsList": brokerAgentAuthList//brokerProprietorsList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                /*var CheckedRecsMap = component.get("v.idDOCMap");
                var newMap= new Map();
                newMap.forEach((value,key)=>CheckedRecsMap.set(value,key));*/
               // alert(JSON.stringify(response.getReturnValue()));
                //component.set("v.idDOCMap",response.getReturnValue());
                var brokerDocMap = response.getReturnValue();
                var brokerAuths=[];
                for(var i=0; i <brokerAgentAuthList.length;i++){
                    var brokerAuth = new Object();
                    brokerAuth=brokerAgentAuthList[i];
                    brokerAuth.DocUploadStatus = brokerDocMap[brokerAuth.Id];
                    brokerAuths.push(brokerAuth);
                    
                }
                component.set('v.brokerAgentAuthList',brokerAuths );
                //alert(JSON.stringify(component.get('v.brokerAgentAuthList')));

            }
        });
        $A.enqueueAction(action);
    },
                   



    saveAuthAgent : function(component, event, helper) {
        component.set("v.spinner", true); 
        var brokerAgentAuthList = component.get("v.brokerAgentAuthList");
        console.log('brokerAgentAuthList', brokerAgentAuthList);
        
        var action = component.get("c.createBrokerAgentsAuthorisedSignatoryRecord");
        
        action.setParams({
            "agencyRecordId" : component.get("v.agencyRecordId"),
            "brokerAgentAuthList": brokerAgentAuthList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state', state);
            
            var result = JSON.stringify(response.getReturnValue());
            console.log('result', result);
            
            if (state === "SUCCESS") {
                console.log('Response', response.getReturnValue());
                var response = response.getReturnValue();
                component.set('v.brokerAgentAuthList', response);
                var brokerAgentAuthList = component.get('v.brokerAgentAuthList');
                this.fetchRecordIDDocStatusAuthSigns(component,event,helper);
                for(var i = 0; i < brokerAgentAuthList.length; i++){
                    component.set('v.parentId', brokerAgentAuthList[i].Id);
                   // component.set("v.IsallrequiredFilesUploaded",false);//Added by mamta for file upload validation
                    console.log('parentId', component.get('v.parentId'));
                    component.set('v.brokerAgentName', brokerAgentAuthList[i].First_Name__c + ' ' + brokerAgentAuthList[i].Last_Name__c);
                }
            }
            component.set("v.disableBtn", false);

            
        });
        $A.enqueueAction(action);
        component.set("v.spinner", false); 
    },
    
    fetchRecordIDDocStatusRepAgents : function(component, event, helper) {
        var brokerProprietorsList = component.get("v.brokerProprietorsList");
        var brokerAgentRepresentativeList = component.get("v.brokerAgentRepresentativeList");
        var action = component.get("c.getrecIDDocStatusMap");

        action.setParams({
            "brokerProprietorsList" : brokerProprietorsList,
            "brokerAgentsList": brokerAgentRepresentativeList//brokerProprietorsList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('fetchRecordIDDocStatusRepAgents is '+ state);

            if (state === "SUCCESS") {
                /*var CheckedRecsMap = component.get("v.idDOCMap");
                var newMap= new Map();
                newMap.forEach((value,key)=>CheckedRecsMap.set(value,key));*/
                //alert(JSON.stringify(response.getReturnValue()));
                //component.set("v.idDOCMap",response.getReturnValue());
                var brokerDocMap = response.getReturnValue();
                var brokerReps=[];
                for(var i=0; i <brokerAgentRepresentativeList.length;i++){
                    var brokerAgent = new Object();
                    brokerAgent=brokerAgentRepresentativeList[i];
                    brokerAgent.DocUploadStatus = brokerDocMap[brokerAgent.Id];
                    brokerReps.push(brokerAgent);
                    
                }
                component.set('v.brokerAgentRepresentativeList',brokerReps );
                //alert(JSON.stringify(component.get('v.brokerAgentRepresentativeList')));

            }
        });
        $A.enqueueAction(action);
    },
    
    
    saveRepresentativeAgent : function(component, event, helper) {
        component.set("v.spinner", true); 
        var brokerAgentRepresentativeList = component.get("v.brokerAgentRepresentativeList");
        console.log('brokerAgentRepresentativeList', brokerAgentRepresentativeList);
        
        var action = component.get("c.createBrokerAgentsRepresentativeRecord");
        
        action.setParams({
            "agencyRecordId" : component.get("v.agencyRecordId"),
            "brokerAgentRepresentativeList": brokerAgentRepresentativeList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state', state);
            
            var result = JSON.stringify(response.getReturnValue());
            console.log('result', result);
            
            if (state === "SUCCESS") {
                console.log('Response', response.getReturnValue());
                var response = response.getReturnValue();
                component.set('v.brokerAgentRepresentativeList', response);
                this.fetchRecordIDDocStatusRepAgents(component,event,helper);
                var brokerAgentRepresentativeList = component.get('v.brokerAgentRepresentativeList');
                for(var i = 0; i < brokerAgentRepresentativeList.length; i++){
                    component.set('v.parentId', brokerAgentRepresentativeList[i].Id);
                    console.log('parentId', component.get('v.parentId'));
                    component.set('v.brokerAgentName', brokerAgentRepresentativeList[i].First_Name__c + ' ' + brokerAgentRepresentativeList[i].Last_Name__c);
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "type": "Success",
                    "message": 'Record is created successfully!'
                });
                toastEvent.fire();
            }
            
            component.set("v.disableBtn", false);

            
        });
        $A.enqueueAction(action);
        component.set("v.spinner", false); 
    },
    
    fetchRecordIDDocStatusContacts : function(component, event, helper) {
        var brokerProprietorsList = component.get("v.brokerProprietorsList");
        var brokerAgentContactsList = component.get("v.brokerAgentContactsList");
        var action = component.get("c.getrecIDDocStatusMap");

        action.setParams({
            "brokerProprietorsList" : brokerProprietorsList,
            "brokerAgentsList": brokerAgentContactsList//brokerProprietorsList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                /*var CheckedRecsMap = component.get("v.idDOCMap");
                var newMap= new Map();
                newMap.forEach((value,key)=>CheckedRecsMap.set(value,key));*/
                //alert(JSON.stringify(response.getReturnValue()));
                //component.set("v.idDOCMap",response.getReturnValue());
                var brokerDocMap = response.getReturnValue();
                var brokerReps=[];
                for(var i=0; i <brokerAgentContactsList.length;i++){
                    var brokerAgent = new Object();
                    brokerAgent=brokerAgentContactsList[i];
                    brokerAgent.DocUploadStatus = brokerDocMap[brokerAgent.Id];
                    brokerReps.push(brokerAgent);
                    
                }
                component.set('v.brokerAgentContactsList',brokerReps );
                //alert(JSON.stringify(component.get('v.brokerAgentContactsList')));

            }
        });
        $A.enqueueAction(action);
    },
    
    
    
    saveAdditionalContacts : function(component, event, helper) {
        component.set("v.spinner", true); 
        var brokerAgentContactsList = component.get("v.brokerAgentContactsList");
        console.log('brokerAgentContactsList', brokerAgentContactsList);
        
        var action = component.get("c.createBrokerAgentsAdditionalContactsRecord");
        
        action.setParams({
            "agencyRecordId" : component.get("v.agencyRecordId"),
            "brokerAgentContactsList": brokerAgentContactsList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state', state);
            
            var result = JSON.stringify(response.getReturnValue());
            console.log('result', result);
            
            if (state === "SUCCESS") {
                console.log('Response', response.getReturnValue());
                var response = response.getReturnValue();
                component.set('v.brokerAgentContactsList', response);
                this.fetchRecordIDDocStatusContacts(component, event, helper);
                var brokerAgentContactsList = component.get('v.brokerAgentContactsList');
                for(var i = 0; i < brokerAgentContactsList.length; i++){
                    component.set('v.parentId', brokerAgentContactsList[i].Id);
                    console.log('parentId', component.get('v.parentId'));
                    component.set('v.brokerAgentName', brokerAgentContactsList[i].First_Name__c + ' ' + brokerAgentContactsList[i].Last_Name__c);
                }
            }
            component.set("v.disableBtn", false);

            
        });
        $A.enqueueAction(action);
        component.set("v.spinner", false); 
    },
})