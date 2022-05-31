@isTest
public class Test_Broker_Portal_FileUploadController {
    @TestSetup
    static void createData(){
        List<Broker__c> brokers =TestDataFactory.createBrokers(1);

        List<ContentVersion> contentVersions=TestDataFactory.createcontentVersions(2);
       // TestDataFactory.createDocuments(contentVersions,brokers[0].id);
    }
    static TestMethod void fileMethod1(){
      Broker__c broker =[select id from Broker__c LIMIt 1 ];

     /*Document__c document =[select id,Expiry_Date__c,Issue_Date__c,Remark__c,
                            Attachment_Id__c,Document_Type__c,Document_ID_Number__c from Document__c LIMIT 1 ];*/
     List<contentVersion>  contentVersions=[select id from contentVersion] ;
     LIst<Document__c>   documents=     TestDataFactory.returnDocuments(contentVersions,broker.id);
   
     contentDocument fl =[select id from contentDocument LIMIt 1];  
     system.debug('fl is '+ fl);    
    /* Document__c document1= new Document__c();
     document1.Attachment_Id__c= document.Attachment_Id__c;
     document1.Document_Type__c=document.Document_Type__c;
     document1.Document_ID_Number__c=document.Document_ID_Number__c;*/
     Broker_Portal_FileUploadController.createDocumentRecords(broker.id,documents[0],fl.id);
     Broker_Portal_FileUploadController.createDocumentRecords(broker.id,documents[0],fl.id);

  
     Broker_Portal_FileUploadController.fetchDocument(documents[0].id);
     Broker_Portal_FileUploadController.fetchUser();

     Broker_Portal_FileUploadController.saveDocument(documents[0]);
   
     //Broker_Portal_FileUploadController.fetchAttachment(broker.id,null);
     Broker_Portal_FileUploadController.fetchAttachments(broker.id,null);
    
     Broker_Portal_FileUploadController.getdocumentTypeValues(broker.id);
    
     //Broker_Portal_FileUploadController.createDocumentRecordsforTAG(broker.id,documents[0],fl.id);
        //createDocumentRecordsforTAG
    // AgencyRegistrationFormHelperCtrl.createContentDocumentLinks(document);
     ContentDocumentLink cdl = [select linkedentityid,contentdocumentid, contentdocument.title, contentdocument.filetype FROM ContentDocumentLink WHERE 
                                contentdocumentID=:fl.id LIMIT 1];
     system.debug('cdl is '+ cdl);
     Broker_Portal_FileUploadController.createPublicUrl(cdl.linkedentityid,cdl.contentdocumentid);
     
     // CW_BrokerPortalFileUpload.getdocumentTypeValues(broker.id);
    
     //Broker_Portal_FileUploadController.fetchAttachment(broker.id,documents[0].id);
   

               
    }

}