@isTest
public class DocumentTriggerHandler_Test {
    
    static TestMethod void TestDocumentTriggerHandler(){
        List<Document__c> documentListToUpdate = new List<Document__c>();
        List<Account> accList = TestDataFactory.createAccounts(1);
        List<ContentVersion> contentVerList = TestDataFactory.createcontentVersions(10);
        List<Document__c> documentList = TestDataFactory.createDocuments(contentVerList,accList[0].Id);
        List<Attachment> attachmentList = TestDataFactory.createAttachments(10,documentList[0].Id);
        for(Document__c doc : documentList){
            doc.Document_Type__c = 'Meydan Group L.L.C';
            doc.Attachment_Id__c = attachmentList[0].Id;
            documentListToUpdate.add(doc);
        }  
        update documentListToUpdate;
        delete documentList[0];
    }
}