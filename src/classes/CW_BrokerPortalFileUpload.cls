public with sharing class CW_BrokerPortalFileUpload {
    
    public static list<NKHL_Documentation_Template__mdt>MdtDocumentList=new list<NKHL_Documentation_Template__mdt> ();
    
     @AuraEnabled
    public static Document__c fetchDocument(Id docID) {
     Document__c  document=  CW_AgencyRegistrationFormHelper.fetchDocument(docID);
     return  document;  
        
    }
    
    @AuraEnabled
    public static String fetchUser() {
     return  UserInfo.getUserId();  
        
    }
    
     @AuraEnabled
    public static Document__c saveDocument(Document__c document) {
    document =  CW_AgencyRegistrationFormHelper.saveDocument(document);
    return document;    
        
    }
    
    
    
    @AuraEnabled
    public static List<Document__c> fetchAttachments(Id parentId, Id deleteRecord) {
        List<Document__c>  custdocWithAtt=CW_AgencyRegistrationFormHelper.fetchAttachments( parentId,  deleteRecord);
        return custdocWithAtt;
    }
    

    @AuraEnabled
    public static void createPublicUrl(String recId,string fileId){
     CW_AgencyRegistrationFormHelper.createPublicUrl(recId,fileId);  
    }
    
    @AuraEnabled
    public static void createDocumentRecords(String recId,Document__c newDoc,String fileId){        
      CW_AgencyRegistrationFormHelper.createDocumentRecords(recId,newDoc,fileId);
    }
  
    @AuraEnabled
    public static List<NKHL_Documentation_Template__mdt>  getdocumentTypeValues( Id recordId) {
    MdtDocumentList =    CW_AgencyRegistrationFormHelper.getdocumentTypeValues(recordId);
     return  MdtDocumentList;
    }
    
    @AuraEnabled
    public static List<CW_AgencyRegistrationFormHelper.documentWrapper>  getDocumentWrapperList(Id recordId) {
        system.debug('hi i am here :'+recordId);
    List<CW_AgencyRegistrationFormHelper.documentWrapper> documentWrapperList = CW_AgencyRegistrationFormHelper.getDocumentWrapperList(recordId);
     system.debug('###documentWrapperList'+documentWrapperList);
        return  documentWrapperList;
    }
    
    @AuraEnabled
    public static void updateDocumentRecords(String recId,document__c newDoc,String fileId){        
      CW_AgencyRegistrationFormHelper.updateDocumentRecords(recId,newDoc,fileId);
    }
    
    @AuraEnabled
    public static Broker__c fetchBrokerDetails(String recordId){
      Broker__c broker = CW_AgencyRegistrationFormHelper.getBrokerDetails(recordId);
      return broker;
    }
}