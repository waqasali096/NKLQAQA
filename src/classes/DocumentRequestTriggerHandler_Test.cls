@isTest(seeAllData = true)
public class DocumentRequestTriggerHandler_Test {
    
    static TestMethod void TestUpdateDocumentAttachmentId(){        
        List<rsdoc__Document_Action__c> rsDocAction = TestDataFactory.create_rsdocDocumentAction(1);
        // rsDocAction[0].rsdoc__Base_object_API__c = 'Document__c';
        // upsert rsDocAction;

        // List<rsdoc__Document_Action__c> rsDocAction = new List<rsdoc__Document_Action__c>();

        // rsdoc__Document_Action__c rsDocActionRec = new rsdoc__Document_Action__c();
        // rsDocActionRec.rsdoc__Base_object_API__c = 'Document__c';
        // rsDocActionRec.rsdoc__Template_Name__c = 'Broker Agreement';
        // rsDocActionRec.rsdoc__Template_Document_ID__c ='asfsdasd12';
        // rsDocActionRec.rsdoc__Visibility__c = 'Public';
        // insert rsDocActionRec ;

        // rsDocAction.add( rsDocActionRec );
        
        List<Broker__c> brokerList = TestDataFactory.createBrokers(1);
        brokerList[0].Email_Address__c = 'test@test.com';
        update brokerList;

        List<Account> accList = TestDataFactory.createAccounts(1);
        List< Contact > lstCon = TestDataFactory.createContacts( 1,accList  );

        accList[0].Agency_Registration__c = brokerList[0].Id;
        update accList;

        List<rsdoc__Document_Request__c> rsDoc = TestDataFactory.create_rsdocDocumeRequest(1,rsDocAction,accList);

        List<Attachment> attachments = TestDataFactory.createAttachments(1, rsDoc[0].Id);

        
        rsDoc[0].rsdoc__Attachment_Id__c = attachments[0].Id;
        rsDoc[0].rsdoc__Status__c = 'Completed';
        
        
        Test.startTest();
        update rsDoc;
        
        Test.stopTest();
        
    }
    
     // static TestMethod void TestcreateAccountContact(){
        
        
    //     List<rsdoc__Document_Action__c> rsDocAction = TestDataFactory.create_rsdocDocumentAction(1);
        
    //     List<Broker__c> brokerList = TestDataFactory.createBrokers(1);
    //     brokerList[0].Email_Address__c = 'test@test.com';
    //     update brokerList;

    //     List<Account> accList = TestDataFactory.createAccounts(1);
    //     accList[0].Agency_Registration__c = brokerList[0].Id;
    //     update accList;

    //     List<rsdoc__Document_Request__c> rsDoc = TestDataFactory.create_rsdocDocumeRequest(1,rsDocAction,accList);

    //     List<Attachment> attachments = TestDataFactory.createAttachments(1, rsDoc[0].Id);

    //     rsDoc[0].rsdoc__Attachment_Id__c = attachments[0].Id;
    //     update rsDoc;
        
    //     Test.startTest();
    //     DocumentRequestTriggerHandler.sendEmailtoBrokerForAgreementSign(rsDoc);
    //     Test.stopTest();
        
    // }
}