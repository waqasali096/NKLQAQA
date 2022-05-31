@isTest
public class DocumentExpiryEmailBatch_Test {

        
    static TestMethod void TestcallExecute2(){
    
        List<Document_Expiry_Notification__mdt> customMetadata = [ Select ID, First_email_before_expiry__c ,Second_email_before_expiry__c ,
                                                                   Third_Email_Before_expiry__c ,Fourth_Email_Before_Expiry__c ,
                                                                   First_Email_After_Expiry__c ,Expiry_Notification_Template__c, Expired_Notification_Template__c 
                                                                   FROM Document_Expiry_Notification__mdt WHERE developername=:ConstantUtility.REC_DocumentExpireMetaName
                                                                   LIMIT 1 ]; 
        
            
         TestDataFactory.createAppSettings();

        List<Account> accList = TestDataFactory.createAccounts(2);
        List<Contact> conList = TestDataFactory.createContacts(2,accList);
        
        
        List<Document__c> tempdocuments = new List<Document__c>();
        List<Document__c> documents = TestDataFactory.createDocuments(TestDataFactory.createcontentVersions(2), '');
        
        for(Document__c docs : documents){
            docs.Expiry_Date__c = system.today();//.addDays(2);
            docs.Account__c= accList[0].Id;
            tempdocuments.add(docs);
        }
        update tempdocuments;
        
        system.debug('tempdocuments are '+ tempdocuments);
        
        Test.startTest();
        database.executeBatch(new DocumentExpiryEmailBatch());
        Test.stopTest();
    }
}