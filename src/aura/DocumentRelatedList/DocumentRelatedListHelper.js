({
	fetchRealatedAttachment: function(component) {
        
        component.set("v.showLoadingSpinner", true);
        var action1 = component.get("c.fetchAttachmentForTAG");
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
            }
                });
        // enqueue the action
        $A.enqueueAction(action1); 
            },
    
    deleteAttachment: function(component, event) {
        //alert('Delete Record Id' + event.currentTarget.id);
        var action1 = component.get("c.fetchAttachmentForTAG");
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
                //this.getRequiredDocuments(component,event,helper);
            }
        })
        $A.enqueueAction(action);
    },
    
    getRequiredDocuments : function(component,event,helper){
        var mdtList =component.get("v.mdtDocumentList");
        var newlst =[];
        
        for (var i=0; i < mdtList.length; i++) {
            var document = mdtList[i];
            
            if(document.TAG_Required__c)
            {
                newlst.push(document.Document_Label__c); 
               
            }
        }
        component.set("v.requiredDocumentList",newlst);
        console.log('required docs are '+JSON.stringify(component.get("v.requiredDocumentList")));
        //this.checkRequiredSubmittedDocs(component,event,helper);
        
        
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
})