public with sharing class Broker_Portal_FileUploadController {
    
    public static list<NKHL_Documentation_Template__mdt>MdtDocumentList=new list<NKHL_Documentation_Template__mdt> ();
    
     @AuraEnabled
    public static Document__c fetchDocument(Id docID) {
     Document__c  document=  AgencyRegistrationFormHelperCtrl.fetchDocument(docID);
     return  document;  
        
    }
    
    @AuraEnabled
    public static String fetchUser() {
     return  UserInfo.getUserId();  
        
    }
    @AuraEnabled
    public static Broker__c  getBrokerDetails(String recordId) {
    return  AgencyRegistrationFormHelperCtrl.getBrokerDetails(recordId);
        
    }
    
    
     @AuraEnabled
    public static Document__c saveDocument(Document__c document) {
    document =  AgencyRegistrationFormHelperCtrl.saveDocument(document);
    return document;    
        
    }
    
    
    
    @AuraEnabled
    public static List<Document__c> fetchAttachments(Id parentId, Id deleteRecord) {
        List<Document__c>  custdocWithAtt=AgencyRegistrationFormHelperCtrl.fetchAttachments( parentId,  deleteRecord);
        return custdocWithAtt;
    }
    

    @AuraEnabled
    public static void createPublicUrl(String recId,string fileId){
     AgencyRegistrationFormHelperCtrl.createPublicUrl(recId,fileId);  
    }
    
    @AuraEnabled
    public static void createDocumentRecords(String recId,Document__c newDoc,String fileId){        
      AgencyRegistrationFormHelperCtrl.createDocumentRecords(recId,newDoc,fileId);
    }
  
    @AuraEnabled
    public static List<NKHL_Documentation_Template__mdt>  getdocumentTypeValues( Id recordId) {
    MdtDocumentList =    AgencyRegistrationFormHelperCtrl.getdocumentTypeValues(recordId);
     return  MdtDocumentList;
    }
}