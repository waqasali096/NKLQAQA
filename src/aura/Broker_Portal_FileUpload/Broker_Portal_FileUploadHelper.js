({
    
    fetchRealatedAttachment: function(component) {
        
        component.set("v.showLoadingSpinner", true);
        var action1 = component.get("c.fetchAttachments");
        action1.setParams({
            parentId: component.get("v.recordId"),
            deleteRecord: null
        });
        
        
        action1.setCallback(this, function(response) {
            // store the response / Attachment Id   
            //attachId = response.getReturnValue();
            var state = response.getState();
            console.log('Fetch 1 '+state);
            console.log('<---->'+JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {
                //alert('your File is uploaded successfully');
                component.set("v.cusRecList", response.getReturnValue());
                component.set("v.showLoadingSpinner", false);
                /*Added by mamta*/
                var addedDocList = component.get("v.cusRecList");
                console.log('addedDocList length is '+ addedDocList.length);
                console.log('addedDocList is '+ JSON.stringify(addedDocList));
                var lisofAddedOdc=[];
                for(var i=0;i<addedDocList.length;i++){
                    if(addedDocList[i].Document_Type__c!=null && addedDocList[i].Document_Type__c!=''){
                    lisofAddedOdc.push(addedDocList[i].Document_Type__c);
                    }
                    console.log('list is '+ JSON.stringify(lisofAddedOdc));

                    
                }
                 component.set('v.documentsUploadedLst',lisofAddedOdc);
                 console.log('set is '+ JSON.stringify(lisofAddedOdc));
                 let setofAddedDoc = new Set(lisofAddedOdc);
                 console.log('setofAddedDoc is '+ JSON.stringify(setofAddedDoc)); 
                 component.set('v.documentsUploadedSet',setofAddedDoc);
                // this.checkRequiredSubmittedDocs(component,event,helper);
               // console.log('set is '+ JSON.stringify(setofAddedDoc));
                

                
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action1); 
    },
    //check if all required documents are submitted before moving to next page
    checkRequiredSubmittedDocs: function(component, event,helper) {
     console.log('check required');   
     var requiredDocLst =  component.get("v.requiredDocumentList");
     var submittedDocs =   component.get("v.documentsUploadedLst");
     console.log('requiredDocLst is '+ JSON.stringify(requiredDocLst));   
     console.log('submittedDocs is '+ JSON.stringify(submittedDocs));    

    //  requiredDocLst = requiredDocLst.map(name => name.toUpperCase());
    //  submittedDocs = submittedDocs.map(name => name.toUpperCase());

    //  console.log('Post requiredDocLst is '+ JSON.stringify(requiredDocLst));   
    //  console.log('Post submittedDocs is '+ JSON.stringify(submittedDocs));  

    
      var newDocAddMap = new Map();
      //component.set('v.docRequireMap',DocAdddedMap);  
     // var newDocAddMap = component.get("v.docRequireMap");
     var lstofRequiredDocs = new Object(); 
     var requiredDocumentsLst =[];   
        
        for(var i=0;i<requiredDocLst.length;i++){
            console.log('requiredDocLst[i] is '+ requiredDocLst[i]);
            var requireDoc = {};

            if(submittedDocs.includes(requiredDocLst[i])){
                console.log('requiredDocLst[i] is '+ requiredDocLst[i]);
                newDocAddMap.set(requiredDocLst[i],true)
                requireDoc['name'] = requiredDocLst[i];
                requireDoc['value']=  true;
                requiredDocumentsLst.push(requireDoc);
                
            }
            else{
                 console.log('false is '+ requiredDocLst[i]);

                newDocAddMap.set(requiredDocLst[i],false) 
                 requireDoc['name'] = requiredDocLst[i];
                 requireDoc['value']=  false;
                requiredDocumentsLst.push(requireDoc);

                //lstofRequiredDocs.name =requiredDocLst[i];
                //lstofRequiredDocs.value= true;
                
            }
            
        }
        console.log('requiredDocumentsLst is '+ JSON.stringify(requiredDocumentsLst));
        component.set('v.requiredDocList',requiredDocumentsLst);
        //var 
        var checkUpload = component.get('v.allrequiredFilesUploaded');
        for(var i = 0; i < requiredDocumentsLst.length; i++) {
            if (requiredDocumentsLst[i].value == false) {
                component.set('v.IsallrequiredFilesUploaded', false);
                break;
            }
            else if (requiredDocumentsLst[i].value == true) {
                component.set('v.IsallrequiredFilesUploaded', true);
               // break;
            }
        }
       console.log('All files uploaded '+  component.get('v.IsallrequiredFilesUploaded')); 
       console.log('lstofRequiredDocs is '+ JSON.stringify(lstofRequiredDocs));
       console.log('values are '+ newDocAddMap.values());
       console.log('keys are '+ newDocAddMap.keys());


        component.set('v.docRequireMap',newDocAddMap);   
//
        
    },
    //get mandatory setting for Issue date and Expiry date
    getDateMandatorySetting: function(component, event) {
        
        var docTypeName = component.get("v.custDoc.Document_Type__c");
        var mdtList =component.get("v.mdtDocumentList");
        
        //alert('Hi' + mdtList[0].Document_Label__c);
        // alert(docTypeName);
        let newrec = mdtList.find(ele => ele.Document_Label__c == docTypeName);
        //alert(newrec);
        if(newrec != null && newrec != undefined) 
        {
            component.set('v.expDateMandatory', newrec.Is_Required_Expiry_Date__c);
            component.set('v.issueDateMandatory', newrec.Is_Required_Issue_Date__c);  
            component.set('v.DoccumentIDMandatory', newrec.is_Document_ID_NumberRequired__c);  
            component.set('v.isEmiratesId', newrec.Is_Emirates_ID__c);  
        }
        
    },
    
    
     //get Broker details
    fetchBrokerDetails: function(component, event) {
        var action = component.get("c.getBrokerDetails");
        action.setParams({
            recordId : component.get("v.agencyID")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('broker' ,result);
                console.log('Agency_Approval_Status__c',result.Agency_Approval_Status__c);
                if(result!=null)
                {        
                    component.set("v.isExistingBroker", result.Exisiting_Broker__c);//Added By Mamta
                    console.log('existing broker ',component.get("v.isExistingBroker"));
                    var approvalStatus= result.Agency_Approval_Status__c
                    if(approvalStatus=='Pending 1st level'||
                       approvalStatus=='Pending 2nd level'||
                       approvalStatus=='Rejected 1st level'||
                       approvalStatus=='Approved'||
                       approvalStatus=="Pending"){
                        
                        component.set("v.editDisabled", true);
                        
                           }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    //get Account Picklist Value
    validateDocType: function(component, event) {
        var action = component.get("c.validateDocTypeSelected");
        action.setParams({
            DoctypeName : component.get("v.custDoc.Document_Type__c"),
            parentId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result==true)
                {
                    component.set("v.docTypeValidationError" , true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    //get user  Value
    loggedInUser: function(component, event,helper) {
        var action = component.get("c.fetchUser");
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('State is '+ state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
               // alert('result is '+ result)
                //if(result==true)
               // {
                    component.set("v.currentUserID" , result);
               // }
            }
        });
        $A.enqueueAction(action);
    },
    
    deleteAttachment: function(component, event) {
        //alert('Delete Record Id' + event.currentTarget.id);
        var action1 = component.get("c.fetchAttachments");
        action1.setParams({
            parentId: component.get("v.recordId"),
            deleteRecord: event.currentTarget.id
        });
        
        
        action1.setCallback(this, function(response) {
            // store the response / Attachment Id   
            //attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert('your File is uploaded successfully');
                component.set("v.cusRecList", response.getReturnValue());
                component.set("v.showLoadingSpinner", false);
                
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action1); 
        
    },
    
    getDocumentType : function(component,event,helper){
        var action = component.get("c.getdocumentTypeValues");
        console.log('==recordId==',component.get("v.recordId"));
        action.setParams({
            recordId: component.get("v.recordId")
        })
        action.setCallback(this,function(response){
            var documentTypes = response.getReturnValue();
            console.log('==documentTypes==',documentTypes);
            if(documentTypes != null){
                var newlst =[];
                for (var i=0; i < documentTypes.length; i++) {
                    newlst.push(documentTypes[i].Document_Label__c);
                }
                // console.log('locationpic'+locationpic);
                component.set("v.docType", newlst); 
                component.set("v.mdtDocumentList",documentTypes);
                this.getRequiredDocuments(component,event,helper);
            }
        })
        $A.enqueueAction(action);
    },
    /*Get document to edit*/
    getDocumenttoEdit : function(component,event,helper){
        var action = component.get("c.fetchDocument");
        //console.log('==recordId==',component.get("v.recordId"));
        action.setParams({
            docID: component.get('v.recId')
        })
        action.setCallback(this,function(response){
            var document = response.getReturnValue();
            console.log('==document==',document);
            if(document != null){
               component.set('v.docEdit',document);
            }
        })
        $A.enqueueAction(action);
    },
    /*save edited document */
    saveEditedDocument : function(component,event,helper){
        var action = component.get("c.saveDocument");
        //console.log('==recordId==',component.get("v.recordId"));
        action.setParams({
            document: component.get('v.docEdit')
        })
        action.setCallback(this,function(response){
            var document = response.getReturnValue();
            console.log('==document==',document);
            if(document != null){
               //component.set('v.docEdit',document);
            }
        })
        $A.enqueueAction(action);
    },
    
    
    getRequiredDocuments : function(component,event,helper){
        var mdtList =component.get("v.mdtDocumentList");
        var newlst =[];
        
        for (var i=0; i < mdtList.length; i++) {
            var document = mdtList[i];
            
            if(document.Required__c)
            {
                newlst.push(document.Document_Label__c); 
               
            }
        }
        component.set("v.requiredDocumentList",newlst);
        console.log('required docs are '+JSON.stringify(component.get("v.requiredDocumentList")));
        this.checkRequiredSubmittedDocs(component,event,helper);
        
        
    },
    
    createDocumentRecords : function(component,event,documentId){
        
        var action = component.get("c.createDocumentRecords");
        action.setParams({
            recId: component.get("v.recordId"),
            newDoc: component.get("v.custDoc"),
            fileId:documentId
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                this.fetchRealatedAttachment(component);
                component.set('v.custDoc.Document_Type__c',null);
                component.set('v.custDoc.Issue_Date__c',null);
                component.set('v.custDoc.Document_ID_Number__c',null);
                component.set('v.custDoc.Expiry_Date__c',null);
                component.set('v.custDoc.Place_of_Issue__c',null);
                component.set('v.custDoc.Remark__c',null);
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action); 
        
    },
    
})