({
    
    doInit: function(component, event, helper) { 
        console.log('agencyID is '+ component.get("v.agencyID"));
        helper.fetchBrokerDetails(component,event);
        helper.fetchRealatedAttachment(component);
        helper.getDocumentType(component,event,helper);
        helper.loggedInUser(component,event,helper);
        
        // helper.getAccountPicklist(component, event);
        
        var documentType =  component.get('v.custDoc.Document_Type__c');
        component.set('v.defaultDocType',documentType);
        
        /*var userId = $A.get("$SObjectType.CurrentUser.Id");//Mamta
        component.set('v.currentUserID',userId);
        Console.log('userId is '+ userId);*/
        
    },
    
    doDelete: function(component, event, helper) {
        helper.deleteAttachment(component, event);
    },
    
    editRecord: function(component, event, helper) {
        console.log('Document Type'+event.currentTarget.Document_Type__c);
        component.set('v.recId',event.currentTarget.id);
        console.log('--->'+component.get('v.recId'));
        helper.getDocumenttoEdit(component,event,helper);
        component.set('v.isModalOpen',true);
    },
    handleOnSuccess : function(component, event, helper) {
        helper.saveEditedDocument(component,event,helper);

        helper.fetchRealatedAttachment(component);
        
        component.set("v.isModalOpen", false);	
        //$A.get('e.force:refreshView').fire();//commented by mamta
        helper.getDocumentType(component,event,helper);
    },
    //handle Account Picklist Selection
    handleCompanyOnChange : function(component, event, helper) {
        var account = component.get("v.custDoc.Account__c");
    },
    
    handleOnSubmit : function(component, event, helper) {
        console.log('---SUBMIT-----');
        var fields = event.getParam("fields");
        component.find('form').submit(fields);
        component.set("v.isModalOpen", false);  
    },
    stopModal : function(component, event, helper) {
        
        component.set("v.isModalOpen", false);
    },
    
    validateIssueDate: function(component, event, helper) {
        // helper.deleteAttachment(component, event);
        //alert('Validate Date' + component.get("v.custDoc.Issue_Date__c"));
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;

        if(component.get("v.custDoc.Issue_Date__c") != '' && component.get("v.custDoc.Issue_Date__c") > todayFormattedDate){
            component.set("v.issueDateValidationError" , true);
        }else{
            component.set("v.issueDateValidationError" , false);
        }
        
        
        
    },
    validateExpiryDate: function(component, event, helper) {
        // helper.deleteAttachment(component, event);
        //alert('Expiry Date' + component.get("v.custDoc.Expiry_Date__c"));
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
         var isExistingBroker= component.get("v.isExistingBroker");//Added for skipping validation for existing broker-By MAMTA

        if(component.get("v.custDoc.Expiry_Date__c") != '' && component.get("v.custDoc.Expiry_Date__c") <= todayFormattedDate  && isExistingBroker==false){
            component.set("v.expDateValidationError" , true);
        }else{
            component.set("v.expDateValidationError" , false);
        }
    },
    validateDateFields : function(component, event, helper){
        // alert("Please enter the Expiry date"+component.get("v.custDoc.Expiry_Date__c"));
        // console.log('v.custDoc.Expiry_Date__c'+v.custDoc.Expiry_Date__c);
        //   console.log('v.expDateMandatory'+v.expDateMandatory);
        var VATLabel = $A.get("$Label.c.VAT_certificate");

        if(component.get('v.custDoc.Document_Type__c')!=VATLabel){
            if(component.get("v.expDateMandatory") == true && component.get("v.custDoc.Expiry_Date__c") == null )
            {
                alert("Please enter the Expiry date");  
                event.preventDefault();  
            }
            else if(component.get("v.expDateValidationError")==true){
                    alert("Please enter the Expiry date in future");  
                    event.preventDefault();  
                    }
       }
        
        if(component.get("v.issueDateMandatory") == true && component.get("v.custDoc.Issue_Date__c") == null)
        {
            alert("Please enter the Issue date"); 
            event.preventDefault();   
        }
        // alert(component.get("v.custDoc.Document_Type__c"));
        if(component.get("v.custDoc.Document_Type__c") == '')
        {
            alert("Please select the Document type"); 
            event.preventDefault();   
        }
        if( component.get("v.DoccumentIDMandatory") == true && component.get("v.custDoc.Document_ID_Number__c") == null){
            alert("Please enter the Document ID/Number."); 
            event.preventDefault();
        }

        if( component.get("v.isEmiratesId") == true ){
            var emiratesIdPattern = new RegExp("[0-9]{3}-[0-9]{4}-[0-9]{7}-[0-9]{1}");
            if( !emiratesIdPattern.test(component.get("v.custDoc.Document_ID_Number__c")) ){
                alert("Please enter Emirates Id in correct format."); 
                event.preventDefault();
            }
        }else{
            if(component.get("v.custDoc.Document_ID_Number__c") != null){
                var docIdPattern = new RegExp("^[a-zA-Z0-9]*$");
                if(!docIdPattern.test(component.get("v.custDoc.Document_ID_Number__c")) ){
                    alert("Pelase enter Document ID/Number in correct format.");
                    event.preventDefault();
                }
            }
        }

        /*if(component.get("v.isEmirates") == true && component.get("v.custDoc.Emirates_ID__c") == null){
            alert("Please enter the Emirates ID."); 
            event.preventDefault();
        }
        if(component.get("v.isPassport") == true  && component.get("v.custDoc.Passport_Number__c") == null){
            alert("Please enter the Emirates ID."); 
            event.preventDefault();
        }*/
        
        
        
        
        return;   
    },
    uploadFinished : function(component, event, helper) {  
        var uploadedFiles = event.getParam("files");
        var documentIds=[];
        var documentId = uploadedFiles[0].documentId;
        
        //alert('in upload finished');
        helper.createDocumentRecords(component,event,documentId);
        
        
        var toastEvent = $A.get("e.force:showToast");       
        toastEvent.setParams({
            "title": "Success!",
            "message": "File uploaded successfully.",
            "type" :'success',
            
        });
        
        toastEvent.fire(); 
        
    },
    getSelected : function(component,event,helper){
        // display modle and set seletedDocumentId attribute with selected record Id   
        component.set("v.hasModalOpen" , true);
        component.set("v.selectedDocumentId" , event.currentTarget.getAttribute("data-Id")); 
        
    },
    closeModel: function(component, event, helper) {
        // for Close Model, set the "hasModalOpen" attribute to "FALSE"  
        component.set("v.hasModalOpen", false);
        component.set("v.selectedDocumentId" , null); 
    },
    checkDocumentType: function(component, event, helper) {
        helper.getDateMandatorySetting(component,event);
        // alert(component.get("v.expDateMandatory"));
        //alert(component.get("v.issueDateMandatory"));
        var documentType =  component.get('v.custDoc.Document_Type__c');
        component.set('v.defaultDocType',documentType);
        
        component.set('v.custDoc.Issue_Date__c',null);
        component.set('v.custDoc.Expiry_Date__c',null);
        component.set('v.custDoc.Place_of_Issue__c',null);
        component.set('v.custDoc.Remark__c',null);
        component.set('v.custDoc.Document_ID_Number__c',null);
        //component.set('v.custDoc.Emirates_ID__c',null);
        //component.set('v.custDoc.Passport_Number__c',null);
        //component.set("v.isEmirates",false);
        //component.set("v.isPassport",false);
        //if(component.get("v.custDoc.Document_Type__c") == 'Emirates ID'){
        //  component.set("v.isEmirates",true);
        //}else if(component.get("v.custDoc.Document_Type__c") == 'Customer’s Valid Passport Copy'){
        //    component.set("v.isPassport",true);
        //}
        
        //console.log('EMIRATES ID'+documentType);
        //console.log('EMIRATES ID'+v.isEmirates);
        //console.log('isPassport ID'+v.isPassport);
        console.log('v.custDoc.Expiry_Date__c'+v.custDoc.Expiry_Date__c);
        console.log('v.expDateMandatory'+v.expDateMandatory); 
    },

    handleEmiratesIdChange : function(component, event, helper) {
        let docRec = component.get('v.custDoc');
        if(docRec.Document_ID_Number__c.length == 3){
            docRec.Document_ID_Number__c = docRec.Document_ID_Number__c + '-';
        }else if(docRec.Document_ID_Number__c.length == 8){
            docRec.Document_ID_Number__c = docRec.Document_ID_Number__c + '-';
        }else if(docRec.Document_ID_Number__c.length == 16){
            docRec.Document_ID_Number__c = docRec.Document_ID_Number__c + '-';
        }
        component.set('v.custDoc',docRec);
    },
})