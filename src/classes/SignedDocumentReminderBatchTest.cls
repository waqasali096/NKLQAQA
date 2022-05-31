@isTest 
public class SignedDocumentReminderBatchTest {
    public static testMethod void testBatch(){
        TestDataFactory.createAppSettings();
        List<Document__c> documentListToUpdate = new List<Document__c>();
        List<Broker__c> brokersToupdate = new List<Broker__c>();
        List<Broker__c> brokers = TestDataFactory.createBrokers(2);
        for(Broker__c brkr : brokers){
            brkr.Email_Address__c = 'test@gmail.com';
            brokersToupdate.add(brkr);
        }
        update brokersToupdate;
        List<Account> accListToUpdate = new List<Account>();
        List<Account> accList = TestDataFactory.createAccounts(10);
        List<Contact> conList = TestDataFactory.createContacts(10,accList);
        List<ContentVersion> contentVerList = TestDataFactory.createcontentVersions(10);
        List<Document__c> documentList = TestDataFactory.createDocuments(contentVerList,accList[0].Id);
        List<Attachment> attachmentList = TestDataFactory.createAttachments(10,documentList[0].Id);
        for(Document__c doc : documentList){
            doc.Document_Type__c = 'Meydan Group L.L.C';
            doc.Attachment_Id__c = attachmentList[0].Id;
            doc.Account__c = accList[0].Id;
            documentListToUpdate.add(doc);
        }  
        update documentListToUpdate;
        
        for(Account acc : accList){
            //acc.Agency_Status__c = 'Registered- Active';
            acc.Document_Count__c = 3;
            acc.Agency_Registration__c = brokersToupdate[0].Id;
            accListToUpdate.add(acc);
        }
        update accListToUpdate;
    
        test.startTest();
        SignedDocumentReminderBatch b = new SignedDocumentReminderBatch(); 
        database.executebatch(b);
        test.stopTest();
    }

    public static testMethod void testScheduleBatch(){
        Test.startTest();

        SignedDocumentReminderBatch batchContext = new SignedDocumentReminderBatch(); 
        String sch ='0 48 * * * ?'; 
        System.schedule('Schedule to update Account Name', sch,batchContext);


        Test.stopTest();
    }
}