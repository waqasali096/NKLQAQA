@isTest
public class ContentVersionTrigger_Test {

    static TestMethod void TestcreateTaskForReplacedNewVersion(){
        List<Account> accList = TestDataFactory.createAccounts(2);
        List<Contact> conList = TestDataFactory.createContacts(2,accList);
        Profile p = [SELECT Id FROM Profile WHERE Name='Nakheel Broker Admin']; 
        User u = new User(Alias = 'standt', Email='nakheelbroker@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, contactId = conList[0].Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='nakheelbro@testorg.com');
        
        
        // insert u;
         Test.startTest();
        // System.runAs(u) {
        //     List<contentVersion> CVVersions = TestDataFactory.createcontentVersions(2);
        // }
        
            
        
        
        // List<Account> accList = TestDataFactory.createAccounts(2);
        // List<Contact> conList = TestDataFactory.createContacts(2,accList);
        // List<contentVersion> CVVersions = TestDataFactory.createcontentVersions(2);
        // List<Document__c> docList = TestDataFactory.createDocuments(CVVersions, accList[0].Id);
        // List<Task> reviewDocsTasks = new  List<Task>();
        
        // Task tsk = new Task();
        // tsk.subject ='Review replaced document';
        // tsk.WhatId= docList[0].Id;
        // tsk.ActivityDate=  system.today()+3;
        // reviewDocsTasks.add(tsk);
        // insert reviewDocsTasks;
        
        
        
        
        //ContentVersionTriggerHandler var = new ContentVersionTriggerHandler();
        List<ContentVersion> contentVerList = TestDataFactory.createcontentVersions(10);
        List<Document__c> documentList = TestDataFactory.createDocuments(contentVerList,accList[0].Id);
        List<Attachment> attachmentList = TestDataFactory.createAttachments(10,documentList[0].Id);
        
        ContentVersion conVer = [ SELECT Id, Title, ContentDocumentId, VersionData, PathOnClient  FROM ContentVersion WHERE Id =: contentVerList[0].Id ];
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        
        
        documentList[0].Attachment_Id__c = conVer.ContentDocumentId;
        update documentList;

        
        ContentVersion conVer1 = conVer.clone();
        conVer1.ContentBodyId = null;
        insert conVer1;
        contentVerList.add(conVer1);

        ContentVersionTriggerHandler.createTaskForReplacedNewVersion(contentVerList); 
        Test.stopTest();
    }
}