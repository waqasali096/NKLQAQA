/**
* @author : Muhammad Moneeb
* @createdDate : 23-Dec-2021
* @lastModifieddate : 23-Dec-2021
* @purpose : Initial Development
* @usage : Test class to cover functionality of 'LwcControllerForUpload' apex class. 
*/
@isTest
public class LwcControllerForUploadTest {
    @TestSetup
    Static void createData() {
        List<Master_Document__c> masterDocList = TestDataFactory.createMasterDoc(3,new list<string>{'Passport','Emirates Id','Others'});
        TestDataFactory.createDocConf(1,False,'Account','Person Account',new List<Document__c>(),'Account_Type__c',
                                      'Broker','Exisiting_Broker__c',masterDocList[0]);
        TestDataFactory.createDocConf(1,False,'Opportunity','Sales Opportunity',new List<Document__c>(),'StageName',
                                      'Booking Initiated','Documents_Verified__c',masterDocList[1]);
        TestDataFactory.createDocConf(1,False,'Case','none',new List<Document__c>(),'Status','Escalated','IsStopped',
                                      masterDocList[0]);
        
        TestDataFactory.createDocConf(1,True,'Opportunity','Sales Opportunity',new List<Document__c>(),'StageName',
                                      'Booking Initiated','Documents_Verified__c',masterDocList[2]);
        TestDataFactory.createDocConf(1,True,'Case','none',new List<Document__c>(),'Status','Escalated','IsStopped',
                                      masterDocList[2]);
        List<Account> accountList = TestDataFactory.createAccountWithRecordType(1, 'Person Account');
        List<Opportunity> oppList = TestDataFactory.createOpportunitiesWithRecordType(1, accountList,'Sales Opportunity');
        List<ContentVersion> contentVerList = TestDataFactory.createcontentVersionsWithDocument(oppList[0]);
        List<case> caseList = TestDataFactory.createCase(1);
        List<Document__c> documentList = TestDataFactory.createDocumentList(contentVerList, oppList[0].Id,caseList[0].Id);
    }
    
    /*@usage : Test_getDocRelatedToRec to cover functionality of 'getDocRelatedToRec' function.*/
    static TestMethod void Test_getDocRelatedToRec() {
        Opportunity oppId = [select id from opportunity];
        List<Document__c> docOppList = LwcControllerForUpload.getDocRelatedToRec(oppId.Id);
        Account acc = [select id from Account];
        List<Document__c> docAccList = LwcControllerForUpload.getDocRelatedToRec(acc.Id);
        Case cs = [Select id from case];
        List<Document__c> docCaseList = LwcControllerForUpload.getDocRelatedToRec(cs.Id);
        LwcControllerForUpload.getExpIssueDate(oppId.Id, 'Passport');
        LwcControllerForUpload.getExpIssueDate(cs.Id, 'Passport');
        System.assertEquals(1, docCaseList.size());
        System.assertEquals(1, docOppList.size());
    }
    
    /*@usage : Test_getDocRelatedToRec to cover functionality of 'uploadFile' function.*/
    static TestMethod void Test_createContentVersion() {
        ContentDocumentLink cdl = getContentDocumentLink();
        LwcControllerForUpload.uploadFile('Test', 'sales force', cdl.id);
    }
    
    /*@usage : Test_getDocRelatedToRec to cover functionality of 'getRelatedFilesByRecordId' function.*/
    static TestMethod void Test_getRelatedFilesByRecordId() {
        ContentDocumentLink cdl = getContentDocumentLink();
        LwcControllerForUpload.getRelatedFilesByRecordId(cdl.linkedentityid);
    }
    
    /*@usage : Test_createObjectDocumentForOpportunity to cover functionality of 'createObjectDocument' function for opportunity record.*/
    static TestMethod void Test_createObjectDocumentForOpportunity() {
        ID recID = [Select id from Opportunity][0].ID;
        String docID = String.valueOf([Select id from document__c][0].ID);
        ID id = LwcControllerForUpload.createObjectDocument(docID,recID);
    }
    
    /*@usage : Test_createObjectDocumentForCase to cover functionality of 'createObjectDocument' function for case record.*/
    static TestMethod void Test_createObjectDocumentForCase() {
        ID recID = [Select id from Case][0].ID;
        String docID = String.valueOf([Select id from document__c][0].ID);
        ID id = LwcControllerForUpload.createObjectDocument(docID,recID);
    }
    
    /*@usage : Test_createObjectDocumentForAccount to cover functionality of 'createObjectDocument' function for Account record.*/
    static TestMethod void Test_createObjectDocumentForAccount() {
        ID recID = [Select id from Account][0].ID;
        String docID = String.valueOf([Select id from document__c][0].ID);
        ID id = LwcControllerForUpload.createObjectDocument(docID,recID);
    }
    
    Static ContentDocumentLink getContentDocumentLink() {
        contentDocument fl = [select id from contentDocument LIMIt 1];
        ContentDocumentLink cdl = [select linkedentityid, contentdocumentid, contentdocument.title, contentdocument.filetype FROM ContentDocumentLink WHERE
                                   contentdocumentID =: fl.id LIMIT 1];
        return cdl;
    }
}