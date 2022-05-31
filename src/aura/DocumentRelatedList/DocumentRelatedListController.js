({
	 doInit: function(component, event, helper) { 
        helper.fetchRealatedAttachment(component);
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
    getSelected : function(component,event,helper){
        // display modle and set seletedDocumentId attribute with selected record Id   
        component.set("v.hasModalOpen" , true);
        component.set("v.selectedDocumentId" , event.currentTarget.getAttribute("data-Id")); 
        
    },
    handleOnSuccess : function(component, event, helper) {
        helper.saveEditedDocument(component,event,helper);

        helper.fetchRealatedAttachment(component);
        
        component.set("v.isModalOpen", false);	
        //$A.get('e.force:refreshView').fire();
        helper.getDocumentType(component,event,helper);
    },
    stopModal : function(component, event, helper) {
        
        component.set("v.isModalOpen", false);
    },
    closeModel: function(component, event, helper) {
        // for Close Model, set the "hasModalOpen" attribute to "FALSE"  
        component.set("v.hasModalOpen", false);
        component.set("v.selectedDocumentId" , null); 
    },
})