@isTest
public class Test_CW_BrokerPortalFileUpload {
    @TestSetup
    static void createData(){
        List<Broker__c> brokers =TestDataFactory.createBrokers(1);

        List<ContentVersion> contentVersions=TestDataFactory.createcontentVersions(2);
       // TestDataFactory.createDocuments(contentVersions,brokers[0].id);
    }
   
    static TestMethod void fileMethod1(){
      Broker__c broker =[select id from Broker__c LIMIt 1 ];

     
     List<contentVersion>  contentVersions=[select id from contentVersion] ;
     LIst<Document__c>   documents=     TestDataFactory.returnDocuments(contentVersions,broker.id);
     List<Document__c> createdDocuments= TestDataFactory.createDocuments(contentVersions,broker.id);
     contentDocument fl =[select id from contentDocument LIMIt 1];  
     system.debug('fl is '+ fl); 
     //CW_BrokerPortalFileUpload.getDocumentWrapperList(broker.id);
     CW_BrokerPortalFileUpload.updateDocumentRecords(broker.id,createdDocuments[0],fl.id);
    
     CW_BrokerPortalFileUpload.updateDocumentRecords(broker.id,documents[0],fl.id);
    
     CW_BrokerPortalFileUpload.createDocumentRecords(broker.id,documents[0],fl.id);
        
   
    // CW_BrokerPortalFileUpload.createDocumentRecords(broker.id,documents[0],fl.id);
     CW_BrokerPortalFileUpload.fetchDocument(documents[0].id);
     CW_BrokerPortalFileUpload.fetchUser();

     CW_BrokerPortalFileUpload.saveDocument(documents[0]);
     //CW_BrokerPortalFileUpload.updateDocumentRecords(broker.id,documents[0],fl.id);

    
     CW_BrokerPortalFileUpload.fetchAttachments(broker.id,null);
    
     CW_BrokerPortalFileUpload.getdocumentTypeValues(broker.id);
    
     ContentDocumentLink cdl = [select linkedentityid,contentdocumentid, contentdocument.title, contentdocument.filetype FROM ContentDocumentLink WHERE 
                                contentdocumentID=:fl.id LIMIT 1];
     system.debug('cdl is '+ cdl);
     CW_BrokerPortalFileUpload.createPublicUrl(cdl.linkedentityid,cdl.contentdocumentid);
     AgencyRegistrationFormHelperCtrl.deletePreviousDocuments('BH','',broker.Id);  

     CW_BrokerPortalFileUpload.getDocumentWrapperList(broker.id);
    
               
    }
    
     static TestMethod void fileMethod2(){
      Broker__c broker =[select id from Broker__c LIMIt 1 ];

     
     List<contentVersion>  contentVersions=[select id from contentVersion] ;
     LIst<Document__c>   documents=     TestDataFactory.returnDocuments(contentVersions,broker.id);
     contentDocument fl =[select id from contentDocument LIMIt 1];  
     system.debug('fl is '+ fl); 
     
     CW_BrokerPortalFileUpload.createDocumentRecords(broker.id,documents[0],fl.id);
        
   
    // CW_BrokerPortalFileUpload.createDocumentRecords(broker.id,documents[0],fl.id);
     CW_BrokerPortalFileUpload.fetchDocument(documents[0].id);
     CW_BrokerPortalFileUpload.fetchUser();

     CW_BrokerPortalFileUpload.saveDocument(documents[0]);
     //CW_BrokerPortalFileUpload.updateDocumentRecords(broker.id,documents[0],fl.id);

    
     CW_BrokerPortalFileUpload.fetchAttachments(broker.id,null);
    
     CW_BrokerPortalFileUpload.getdocumentTypeValues(broker.id);
    
     ContentDocumentLink cdl = [select linkedentityid,contentdocumentid, contentdocument.title, contentdocument.filetype FROM ContentDocumentLink WHERE 
                                contentdocumentID=:fl.id LIMIT 1];
     system.debug('cdl is '+ cdl);
     CW_BrokerPortalFileUpload.createPublicUrl(cdl.linkedentityid,cdl.contentdocumentid);
     AgencyRegistrationFormHelperCtrl.deletePreviousDocuments('BH','',broker.Id);  

     CW_BrokerPortalFileUpload.getDocumentWrapperList(broker.id);
    
               
    }


}