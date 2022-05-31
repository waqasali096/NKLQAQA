@isTest
public class Test_ContentVersionTrigger {
     @TestSetup
    static void createData(){
        List<Broker__c> brokers =TestDataFactory.createBrokers(1);
        List<ContentVersion> contentVersions=TestDataFactory.createcontentVersions(2);
    }
    
    static TestMethod void fileMethod1(){
     
      Broker__c broker =[select id from Broker__c LIMIt 1 ];

     
     List<contentVersion>  contentVersions=[select id,ContentDocumentId from contentVersion] ;
     LIst<Document__c>   documents=     TestDataFactory.returnDocuments(contentVersions,broker.id);
      
     contentDocument fl =[select id from contentDocument LIMIt 1];  
     ContentVersion contentVersion = new ContentVersion(
                    Title          = 'a picture',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true,
                    ContentDocumentId = fl.Id
     );

           // contentVersions.add(contentVersion);
   // }
    insert contentVersion;
    for(Document__c doc : documents){
         doc.Document_Type__c= 'DISTRICT ONE – FZ'; 
         doc.Approval_Status__c='Approved';
         doc.Attachment_Id__c= fl.id;
        }
     insert documents;      
          
     ContentVersionTriggerHandler.createTaskForReplacedNewVersion(contentVersions);
        
}
}