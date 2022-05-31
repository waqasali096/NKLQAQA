({
    
    doInit: function(component, event, helper) { 
        
        
        //helper.getDocumentType(component,event,helper);
        //
        helper.fetchDocumentRelatedList(component,event,helper);
        helper.loggedInUser(component,event,helper);
        helper.fetchAgencyDetails(component,event,helper);
        
        //helper.fetchRealatedAttachment(component);
        
        // helper.getAccountPicklist(component, event);
        
        //var documentType =  component.get('v.custDoc.Document_Type__c');
        //component.set('v.defaultDocType',documentType);
        
        // var userId = $A.get("$SObjectType.CurrentUser.Id");//Mamta
        // component.set('v.currentUserID',userId);
        //Console.log('userId is '+ userId);
        
    },
    
    doDelete: function(component, event, helper) {
        helper.deleteAttachment(component, event);
    },
    
    editRecord: function(component, event, helper) {
        component.set('v.recId',event.currentTarget.id);
        console.log('--->'+component.get('v.recId'));
        var documentList = component.get("v.DocumentList");
        for(var i=0;i<documentList.length;i++){
            console.log('DocumentList[i].documentRecord.Id is '+ documentList[i].documentRecord.Id);
            if(documentList[i].documentRecord.Id === component.get('v.recId')){
                var isEdit = true; 
                documentList[i].isEdit = isEdit;
                documentList[i].isNew = false;
                
                console.log('component.get("v.DocumentList")[i].isEdit '+documentList[i].isEdit);
                
            }
        }
        
        component.set("v.DocumentList",documentList);
        
        //helper.getDocumenttoEdit(component,event,helper);
        //component.set('v.isModalOpen',true);
    },
    handleOnSuccess : function(component, event, helper) {
        if(!component.get("v.expDateValidationError")){
            var docId = event.currentTarget.id;
            console.log('docId: '+docId);
            for(var i=0;i<component.get("v.DocumentList").length;i++){
                console.log('DocumentList[i].documentRecord.Id is '+ component.get("v.DocumentList")[i].documentRecord.Id);
                if(component.get("v.DocumentList")[i].documentRecord.Id === docId){
                    var editedDoc = component.get("v.DocumentList")[i].documentRecord;           
                }
                if(component.get("v.DocumentList")[i].documentRecord.Document_ID_Number__c!= null){
                    var docIdPattern = new RegExp("^[a-zA-Z0-9]*$");
                    if(!docIdPattern.test(component.get("v.DocumentList")[i].documentRecord.Document_ID_Number__c) ){
                        alert("Pelase enter ID/Number in correct format.");
                        component.set("v.isError", true);
                    }
                }
            }
            if(!component.get("v.isError")){
                helper.saveEditedDocument(component,event,editedDoc);
                
                var toastEvent = $A.get("e.force:showToast");       
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Record updated successfully",
                    "type" :'success',
                    
                });
                
                toastEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Error while updating",
                    "type": 'error',
                });
                
                toastEvent.fire();
            }
        }
        //helper.fetchRealatedAttachment(component);
        
        //component.set("v.isModalOpen", false);	
        //$A.get('e.force:refreshView').fire();//commented by mamta
        //helper.getDocumentType(component,event,helper);
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
        
        var selectedItem = event.currentTarget.id;
        console.log('index '+selectedItem);
        for(var i=0;i<component.get("v.DocumentList").length;i++){
            console.log('DocumentList[i].documentRecord.Id is '+ component.get("v.DocumentList")[i].documentRecord.Id);
            if(component.get("v.DocumentList")[i].documentRecord.Id === selectedItem){
                var issueDate = component.get("v.DocumentList")[i].documentRecord.Issue_Date__c;           }
        }
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
        if(issueDate != '' && issueDate > todayFormattedDate){
            component.set("v.issueDateValidationError" , true);
        }else{
            component.set("v.issueDateValidationError" , false);
        }
        
        
        
    },
    validateExpiryDate: function(component, event, helper) {
        // helper.deleteAttachment(component, event);
        //alert('Expiry Date' + component.get("v.custDoc.Expiry_Date__c"));
        var selectedItem = event.currentTarget.id;
        console.log('index '+selectedItem);
        for(var i=0;i<component.get("v.DocumentList").length;i++){
            console.log('DocumentList[i].documentRecord.Id is '+ component.get("v.DocumentList")[i].documentRecord.Id);
            if(component.get("v.DocumentList")[i].documentRecord.Id === selectedItem){
                var expiryDate = component.get("v.DocumentList")[i].documentRecord.Expiry_Date__c;           }
        }
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
        if(expiryDate != '' && expiryDate <= todayFormattedDate && isExistingBroker==false){//Added for skipping validation for existing broker-By MAMTA
            component.set("v.expDateValidationError" , true);
        }else{
            component.set("v.expDateValidationError" , false);
        }
    },
    validateDateFields : function(component, event, helper){
        // alert("Please enter the Expiry date"+component.get("v.custDoc.Expiry_Date__c"));
        // console.log('v.custDoc.Expiry_Date__c'+v.custDoc.Expiry_Date__c);
        //   console.log('v.expDateMandatory'+v.expDateMandatory);
        var documentRecordId = event.getSource().get('v.name');
        console.log('documentRecordId :'+documentRecordId);
        for(var i=0;i<component.get("v.DocumentList").length;i++){
            console.log('DocumentList[i].documentRecord.Id is '+ component.get("v.DocumentList")[i].documentRecord.Id);
            if(component.get("v.DocumentList")[i].documentRecord.Id === documentRecordId){
                var newDoc = component.get("v.DocumentList")[i].documentRecord;  
                var expDateReq = component.get("v.DocumentList")[i].expDateMandatory;
                var issueDateReq = component.get("v.DocumentList")[i].issueDateMandatory;
                var docReuired = component.get("v.DocumentList")[i].DoccumentIDMandatory;
            }
        }
        var VATLabel = $A.get("$Label.c.VAT_certificate");
        var toast = $A.get("e.force:showToast");
        
        
        if(newDoc.Document_Type__c != VATLabel){
            if(expDateReq && !newDoc.Expiry_Date__c)
            {
                //alert("Please enter the Expiry date");  
                //event.preventDefault(); 
                toast.setParams({
                    "title": "Error",
                    "type": "Error",
                    "message": 'Please enter the Expiry date'
                });
                toast.fire(); 
            }
            else if(component.get("v.expDateValidationError")){
                //alert("Please enter the Expiry date in future");  
                //event.preventDefault();  
                toast.setParams({
                    "title": "Error",
                    "type": "Error",
                    "message": 'Please enter the Expiry date in future'
                });
                toast.fire(); 
            }
        }
        
        if(issueDateReq && !newDoc.Issue_Date__c )
        {
            //alert("Please enter the Issue date"); 
            //event.preventDefault(); 
            toast.setParams({
                "title": "Error",
                "type": "Error",
                "message": 'Please enter the Issue date'
            });
            toast.fire();   
        }
        // alert(component.get("v.custDoc.Document_Type__c"));
        if(newDoc.Document_Type__c == '')
        {
            //alert("Please select the Document type"); 
            //event.preventDefault();   
            
        }
        if( docReuired && !newDoc.Document_ID_Number__c){
            //alert("Please enter the Document ID/Number."); 
            //event.preventDefault();
            console.log('Please enter the Document ID/Number.');
            toast.setParams({
                "title": "Error",
                "type": "Error",
                "message": 'Please enter the Document ID/Number.'
            });
            toast.fire();  
        }
        //return;   
    },
    uploadFinished : function(component, event, helper) {  
        var uploadedFiles = event.getParam("files");
        var documentIds=[];
        var documentId = uploadedFiles[0].documentId;
        var documentRecordId = event.getSource().get('v.name');
        console.log('documentRecordId '+documentRecordId);        
        helper.updateDocumentRecords(component,event,documentId,documentRecordId);
        
        
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
})