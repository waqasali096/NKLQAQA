@isTest
public class TerminateAccountControllerTest {
 
    Static TestMethod void TerminateTest(){
        Account acc = new Account();
        acc.Name='Test-Account';
        insert acc;
        List<ContentVersion> contentVerList = TestDataFactory.createcontentVersions(10);
        List<Document__c> documentList = TestDataFactory.createDocuments(contentVerList,acc.Id);
        List<Attachment> attachmentList = TestDataFactory.createAttachments(10,documentList[0].Id);
        TerminateAccountController.createDocument(acc.Id);
        TerminateAccountController.saveFile(acc.Id,true,'test',documentList[0].Id,attachmentList[0].Id);
        TerminateAccountController.deleteDocument(documentList[0].Id);
        TerminateAccountController.ResultWrapper abc = new TerminateAccountController.ResultWrapper();
        abc.isUpdateSuccess = true;
        abc.terminationNotice = true;
        abc.terminationReason = 'test';
    }
}