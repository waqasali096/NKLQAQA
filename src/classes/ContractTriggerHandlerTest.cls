/****************************************************************************************************************************
* @Name         ContractTriggerHandlerTest
* @Author       Kaustubh Abhyankar
* @Date         21-April-2022
* @Description  Test Class for ContractTriggerHandler
****************************************************************************************************************************/

@isTest
public class ContractTriggerHandlerTest{
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        //insertRecords();
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        Test.setMock(HttpCalloutMock.class, new ContractTriggerHandlerMockClass());
        
        //Test.startTest();
        String accRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Business_RecordType').RecordTypeId;
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestAccount1';
        acc.ERP_Account_Number__c = 'awdadasd123123';
        //acc.Account_Number__c = '44545454545';
        acc.Primary_Mobile__c = '1322313132';
        acc.Emirates_Ids__c = '784-1233-1267567-1';
        acc.Primary_Email__c = 'Nakheel122@gmail.com';
        acc.RecordTypeId = accRecType;
        acc.Signatory_Firstname__c = '';
        acc.Signatory_Lastname__c = 'TestAcc';
        acc.Signatory_Email__c = 'Nakheel122@gmail.com';
        acc.Signatory_Phone_Number__c = '21312312332';
        acc.Signatory_Country_Code__c = '91';
        accList.add(acc);//0
        
        insert accList;
        
        Contact c = new Contact();
        c.LastName = 'TestCon0';
        c.AccountId = accList[0].Id;
        c.Email = 'Nakheel122@gmail.com';
        insert c;
        
        String oppRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp0';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Handover_Date__c = System.today();
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        opp = new Opportunity();
        opp.Name = 'TestOpp1';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Handover_Date__c = System.today();
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//1
        
        opp = new Opportunity();
        opp.Name = 'TestOpp2';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Handover_Date__c = System.today();
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//2
        
        opp = new Opportunity();
        opp.Name = 'TestOpp3';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Handover_Date__c = System.today();
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//3
        
        insert oppList;
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[1].Id;
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        uList.add(u);//1
        
        u = new Unit__c();
        u.Opportunity__c = oppList[2].Id;
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        uList.add(u);//2
        
        u = new Unit__c();
        u.Opportunity__c = oppList[3].Id;
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        uList.add(u);//3
        
        insert uList;
        
        List<Unit_Plan__c> upList = new List<Unit_Plan__c>();
        Unit_Plan__c up = new Unit_Plan__c();
        up.Opportunity__c = oppList[0].Id;
        up.Unit__c = uList[0].Id;
        upList.add(up);//0
        
        up = new Unit_Plan__c();
        up.Opportunity__c = oppList[1].Id;
        up.Unit__c = uList[1].Id;
        upList.add(up);//1
        
        up = new Unit_Plan__c();
        up.Opportunity__c = oppList[2].Id;
        up.Unit__c = uList[2].Id;
        upList.add(up);//2
        
        up = new Unit_Plan__c();
        up.Opportunity__c = oppList[3].Id;
        up.Unit__c = uList[3].Id;
        upList.add(up);//3
        
        insert upList;
        
        List<Property__c> prList = new List<Property__c>();
        Property__c pr = new Property__c();
        pr.Account__c = accList[0].Id;
        pr.Deal__c = oppList[0].id;
        pr.Unit__c = uList[0].Id;
        prList.add(pr);
        
        pr = new Property__c();
        pr.Account__c = accList[0].Id;
        pr.Deal__c = oppList[1].id;
        pr.Unit__c = uList[1].Id;
        prList.add(pr);
        
        pr = new Property__c();
        pr.Account__c = accList[0].Id;
        pr.Deal__c = oppList[2].id;
        pr.Unit__c = uList[2].Id;
        prList.add(pr);
        
        pr = new Property__c();
        pr.Account__c = accList[0].Id;
        pr.Deal__c = oppList[3].id;
        pr.Unit__c = uList[3].Id;
        prList.add(pr);
        
        insert prList;
        
        Id renewalContractRcdTyId = Schema.SObjectType.Lease_Contract__c.getRecordTypeInfosByDeveloperName().get('Renewal_Contract').getRecordTypeId();
        
        List<Lease_Contract__c> lcList = new List<Lease_Contract__c>();
        Lease_Contract__c lc = new Lease_Contract__c();
        lc.Opportunity__c = oppList[0].Id;
        lc.Contract_Stages__c = 'Draft';//Approved
        lc.Handover_Date__c = system.today();
        lc.Amount__c = 100;
        //lc.Send_Lease_to_ERP__c = true;
        lcList.add(lc);//0
        
        lc = new Lease_Contract__c();
        lc.Opportunity__c = oppList[1].Id;
        lc.Contract_Stages__c = 'Draft';//Approved
        lc.Handover_Date__c = system.today();
        lc.Amount__c = 200;
        //lc.Send_Lease_to_ERP__c = true;
        lcList.add(lc);//1
        
        lc = new Lease_Contract__c();
        lc.Opportunity__c = oppList[2].Id;
        lc.Contract_Stages__c = 'Draft';//Approved
        lc.Handover_Date__c = system.today();
        lc.Amount__c = 300;
        lc.Signed_Contract_Uploaded__c = true;
        lc.Account__c = accList[0].Id;
        //lc.Send_Lease_to_ERP__c = true;
        lcList.add(lc);//2
        
        lc = new Lease_Contract__c();
        lc.Opportunity__c = oppList[3].Id;
        lc.Contract_Stages__c = 'Draft';//Approved
        lc.Handover_Date__c = system.today();
        lc.Amount__c = 400;
        lc.Signed_Contract_Uploaded__c = true;
        lc.Account__c = accList[0].Id;
        //lc.Send_Lease_to_ERP__c = true;
        lcList.add(lc);//3
        
        
        //Test.setMock(HttpCalloutMock.class, new ContractTriggerHandlerMockClass());
        insert lcList;
        
        List<Document__c> docList = new List<Document__c>();
        Document__c doc = new Document__c();
        doc.Contract__c = lcList[2].Id;
        doc.Document_Type__c = 'Signed Contract';
        docList.add(doc);
        
        doc = new Document__c();
        doc.Contract__c = lcList[3].Id;
        doc.Document_Type__c = 'Signed Contract';
        docList.add(doc);
        
        insert docList;
        
        List<Object_Document__c> odocList = new List<Object_Document__c>();
        Object_Document__c odoc = new Object_Document__c();
        odoc.Contract__c = lcList[2].Id;
        odoc.Document__c = docList[0].Id;
        odocList.add(odoc);
        
        odoc = new Object_Document__c();
        odoc.Contract__c = lcList[3].Id;
        odoc.Document__c = docList[1].Id;
        odocList.add(odoc);
        
        insert odocList;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = 'Test Title1',//String.valueOf(system.Label.Leasing_Booking_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        cv = new ContentVersion(
            Title          = 'Test Title2',//String.valueOf(system.Label.Leasing_Booking_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = lcList[2].Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = lcList[3].Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[1].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        
        //Test.stopTest();
    }
    
    //Testing Method - BeforeUpdateEvent & AfterUpdateEvent
    @isTest
    public static void UpdateEventTest1() {
        Test.startTest();
        
        List<Lease_Contract__c> lcList = new List<Lease_Contract__c>();
        Lease_Contract__c lc1 = [select Id, name, Amount__c, Contract_Stages__c from Lease_Contract__c where Amount__c = 100 limit 1];
        lc1.Contract_Stages__c = 'Under handover';
        lc1.Handover_Status__c = 'In Progress';
        lcList.add(lc1);
        
        Lease_Contract__c lc2 = [select Id, name, Amount__c, Contract_Stages__c from Lease_Contract__c where Amount__c = 200 limit 1];
        lc2.Handover_Status__c = 'Completed';
        lc2.Handover_Date__c = System.today();
        lc2.Contract_Stages__c = 'Active';
        lcList.add(lc2);
        
        update lcList;
        
        Test.stopTest();
    }
    
    //Testing Method - BeforeUpdateEvent & AfterUpdateEvent
    @isTest
    public static void UpdateEventTest2() {
        Test.startTest();
        
        List<Lease_Contract__c> lcList = new List<Lease_Contract__c>();
        Lease_Contract__c lc1 = [select Id, name, Email__c, Opportunity__c, Amount__c, Contract_Stages__c from Lease_Contract__c where Amount__c = 300 limit 1];
        lc1.Contract_Stages__c = 'Expired';
        lc1.Contract_Document_Uploaded__c = true;
        lcList.add(lc1);
        
        Lease_Contract__c lc2 = [select Id, name, Email__c, Opportunity__c, Amount__c, Contract_Stages__c from Lease_Contract__c where Amount__c = 400 limit 1];
        lc2.Contract_Stages__c = 'Compliance';
        lc2.Signed_Contract_Uploaded__c = true;
        lcList.add(lc2);
        
        update lcList;
        
        ContractTriggerHandler.createDraftEjariOnApproval(lc2.Id, 'CreatePendingTenancyContractRequest');
        
        List<ContentVersion> conList = [select Id, VersionData, Title from ContentVersion where Title = 'Test Title1' limit 1];
        Map<Id, List<ContentVersion>> lcconMap = new Map<Id, List<ContentVersion>>();
        lcconMap.put(lc1.Id, conList);
        
        Map<Id, Lease_Contract__c> lcMap = new Map<Id, Lease_Contract__c>();
        lcMap.put(lc1.Id, lc1);//ConstantUtility.SIGNED_CONTRACT_EMAIL_TEMP
        
        ContractTriggerHandler con = new ContractTriggerHandler(null,null,null,null,null,null,null,null);
        con.sendEmailToCustomer(lcconMap, lcMap, ConstantUtility.SIGNED_CONTRACT_EMAIL_TEMP);
        
        Test.stopTest();
    }
    
    @future
    public static void insertRecords() {
        EmailTemplate et = new EmailTemplate();
        et.isActive = true;
        et.Name = ConstantUtility.SIGNED_CONTRACT_EMAIL_TEMP;
        et.DeveloperName = 'TestTemplate0';
        et.TemplateType = 'text';
        et.FolderId = UserInfo.getUserId();
        insert et;
    }
}