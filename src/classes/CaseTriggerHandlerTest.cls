/****************************************************************************************************************************
* @Name         CaseTriggerHandlerTest
* @Author       Kaustubh Abhyankar
* @Date         22-April-2022
* @Description  Test Class for CaseTriggerHandler
****************************************************************************************************************************/

@isTest
public class CaseTriggerHandlerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        Test.startTest();
        
        String accBizRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Business_RecordType').RecordTypeId;//
        String accPerRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('PersonAccount').RecordTypeId;//Broker Account
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestAccount0';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accBizRecType;
        accList.add(acc);//0
        
        acc = new Account();
        acc.Name = 'TestAccount1';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accBizRecType;
        accList.add(acc);//0
        
        acc = new Account();
        acc.Name = 'TestAccount2';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accBizRecType;
        accList.add(acc);//2
        
        acc = new Account();
        acc.Name = 'TestAccount3';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accBizRecType;
        accList.add(acc);//3
        
        insert accList;
        
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.LastName = 'TestCon0';
        con.AccountId = accList[0].Id;
        con.Is_Primary__c = true;
        conList.add(con);//0
        
        con = new Contact();
        con.LastName = 'TestCon1';
        con.AccountId = accList[1].Id;
        con.Is_Primary__c = true;
        conList.add(con);//1
        
        con = new Contact();
        con.LastName = 'TestCon2';
        con.AccountId = accList[2].Id;
        con.Is_Primary__c = true;
        conList.add(con);//2
        
        con = new Contact();
        con.LastName = 'TestCon3';
        con.AccountId = accList[3].Id;
        con.Is_Primary__c = true;
        conList.add(con);//3
        
        insert conList;
        
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
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.Project__c = pList[0].Id;
        opp.AccountId = accList[0].Id;
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
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.Project__c = pList[0].Id;
        opp.AccountId = accList[1].Id;
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
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.Project__c = pList[0].Id;
        opp.AccountId = accList[2].Id;
        opp.Lease_Start_Date__c = System.today();
        oppList.add(opp);//2
        
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
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.Project__c = pList[0].Id;
        opp.AccountId = accList[3].Id;
        opp.Lease_Start_Date__c = System.today();
        oppList.add(opp);//3
        
        insert oppList;
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        //u.Project__c = oppList[0].Project__c;
        //u.Building__c = bList[0].Id;
        //u.Business_Group__c = bgList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Vacant';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[0].Id;
        u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[1].Id;
        //u.Project__c = oppList[0].Project__c;
        //u.Building__c = bList[0].Id;
        //u.Business_Group__c = bgList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Vacant';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[1].Id;
        u.Active_Account__c = accList[1].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//1
        
        u = new Unit__c();
        u.Opportunity__c = oppList[2].Id;
        //u.Project__c = oppList[0].Project__c;
        //u.Building__c = bList[0].Id;
        //u.Business_Group__c = bgList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Vacant';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[2].Id;
        u.Active_Account__c = accList[2].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//2
        
        u = new Unit__c();
        u.Opportunity__c = oppList[3].Id;
        //u.Project__c = oppList[0].Project__c;
        //u.Building__c = bList[0].Id;
        //u.Business_Group__c = bgList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Vacant';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[3].Id;
        u.Active_Account__c = accList[3].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//3
        
        insert uList;
        
        List<Unit_Plan__c> upList = new List<Unit_Plan__c>();
        Unit_Plan__c up = new Unit_Plan__c();
        up.Opportunity__c = oppList[0].Id;
        upList.add(up);//0
        
        up = new Unit_Plan__c();
        up.Opportunity__c = oppList[1].Id;
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
        
        List<Handover__c> hList = new List<Handover__c>();
        Handover__c h = new Handover__c();
        h.Deal__c = oppList[0].Id;
        hList.add(h);//0
        
        h = new Handover__c();
        h.Deal__c = oppList[1].Id;
        hList.add(h);//1
        
        h = new Handover__c();
        h.Deal__c = oppList[2].Id;
        hList.add(h);//2
        
        h = new Handover__c();
        h.Deal__c = oppList[3].Id;
        hList.add(h);//3
        
        insert hList;
        
        List<Registration__c> rList = new List<Registration__c>();
        Registration__c r = new Registration__c();
        //r.Status__c = 'Registration Complete';
        r.Opportunity__c = oppList[0].Id;
        rList.add(r);//0
        
        r = new Registration__c();
        //r.Status__c = 'Registration Complete';
        r.Opportunity__c = oppList[1].Id;
        rList.add(r);//1
        
        r = new Registration__c();
        r.Status__c = 'Registration Complete';
        r.Opportunity__c = oppList[2].Id;
        rList.add(r);//2
        
        r = new Registration__c();
        r.Status__c = 'Registration Complete';
        r.Opportunity__c = oppList[3].Id;
        rList.add(r);//3
        
        insert rList;
        
        String csTDRecType = Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('Title_Deed').RecordTypeId;
        Id csHRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Handover').getRecordTypeId();
        Id csSCRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales_Cancellation').getRecordTypeId();
        Id csTRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Termination').getRecordTypeId();
        List<Case> csList1 = new List<Case>();
        Case cs = new Case();
        cs.status = 'New';
        cs.Type = 'Handover - End of Lease';
        cs.Handover__c = hList[0].Id;
        cs.RecordTypeId = csTDRecType;
        cs.Bulk_Add_Units__c = false;
        cs.Unit__c = uList[0].Id;
        cs.Registration__c = rList[0].Id;
        csList1.add(cs);//0
        
        cs = new Case();
        cs.status = 'New';
        cs.Type = 'Handover - Auto Refurbishment';
        cs.Handover__c = hList[1].Id;
        cs.RecordTypeId = csTDRecType;
        cs.Bulk_Add_Units__c = false;
        cs.Unit__c = uList[1].Id;
        cs.Registration__c = rList[1].Id;
        csList1.add(cs);//1
        
        try {
        insert csList1;
        }catch(Exception e) {
            
        }
        
        List<Case> csList2 = new List<Case>();
        Case c = new Case();
        c.status = 'New';
        c.Type = 'Handover - End of Lease';
        c.Handover__c = hList[2].Id;
        c.RecordTypeId = csHRecType;
        c.Bulk_Add_Units__c = false;
        c.Unit__c = uList[2].Id;
        c.Registration__c = rList[2].Id;
        c.Deal__c = oppList[2].Id;
        c.AccountId = accList[2].Id;
        csList2.add(c);//0
        
        c = new Case();
        c.status = 'New';
        c.Type = 'Handover - Move In';
        c.Handover__c = hList[2].Id;
        c.RecordTypeId = csHRecType;
        c.Bulk_Add_Units__c = false;
        c.Unit__c = uList[2].Id;
        c.Registration__c = rList[2].Id;
        c.Deal__c = oppList[2].Id;
        c.AccountId = accList[2].Id;
        csList2.add(c);//1
        
        c = new Case();
        c.status = 'New';
        c.Type = 'Handover - Move In';
        c.Handover__c = hList[3].Id;
        c.RecordTypeId = csHRecType;
        c.Bulk_Add_Units__c = false;
        c.Unit__c = uList[3].Id;
        c.Registration__c = rList[3].Id;
        c.Deal__c = oppList[3].Id;
        c.AccountId = accList[3].Id;
        csList2.add(c);//2
        
        c = new Case();
        c.status = 'New';
        c.Type = 'Termination';
        c.Handover__c = hList[3].Id;
        c.RecordTypeId = csTRecType;
        c.Bulk_Add_Units__c = false;
        c.Unit__c = uList[3].Id;
        c.Registration__c = rList[3].Id;
        c.Deal__c = oppList[3].Id;
        c.AccountId = accList[3].Id;
        csList2.add(c);//3
        
        insert csList2;
        
        Test.stopTest();
        
        String documentType = system.label.End_of_Lease_Application;
        Document__c d = new Document__c();
        d.Document_Type__c = documentType;
        insert d;
        Object_Document__c od = new Object_Document__c();
        od.Case__c = csList2[3].Id;
        od.Document__c = d.Id;
        insert od;
        
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        contentVersions.add(contentVersion);
        if(contentVersions.size()>0){
            insert contentVersions;
        }
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=csList2[3].Id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =:contentVersions[0].Id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;
        
        Set<Id> idSet = new Set<Id>();
        idset.add(csList2[3].Id);
        
        Map<Id, Id> agreementIdsMappedToCase = new Map<Id, Id>();
        agreementIdsMappedToCase.put(csList2[3].Id, csList2[3].Id);
        
        CaseTriggerHandler.attachFilesToDocument(idset, documentType, agreementIdsMappedToCase);
        
        
    }
    
    //Testing Method - BeforeUpdateEvent & AfterUpdateEvent
    @isTest
    public static void updateCase() {
        Test.startTest();
        
        List<Case> csList = new List<Case>();
        csList = [select Id, Handover__c, status from Case where Account.Name = 'TestAccount3'];
        
        
        csList[0].Status = 'Closed';
        csList[1].Status = 'Closed';
        
        try{
            update csList;
        }catch(Exception e) {
            
        }
        
        Test.stopTest();
    }
    
    //Testing Method - handoverUpdateForClosedHandoverCases
    @isTest
    public static void handoverUpdateForClosedHandoverCasesEvent(){
        Test.startTest();
        
        String oppRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpph';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.Project__c = pList[0].Id;
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        Handover__c h = new Handover__c();
        h.Deal__c = oppList[0].Id;
        h.Key_Handover_Done__c = true;
        insert h;
        
        Id csHRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Handover').getRecordTypeId();
        Case cs = new Case();
        cs.Status = 'New';
        cs.Handover__c = h.Id;
        cs.RecordTypeId = csHRecType;
        insert cs;
        
        List<Case> CaseList = new List<Case>();
        caseList = [select Id, Status, Handover__c from Case where Handover__r.Deal__r.Name = 'TestOpph' limit 1];
        
        Map<Id, Case> csMap = new Map<Id, Case>();
        csMap.put(cs.Id, cs);
        
        caseList[0].status = 'Closed';
        try {
            update caseList;
            CaseTriggerHandler.handoverUpdateForClosedHandoverCases(caseList, csMap);
        } catch(Exception e) {
            
        }
        
        
        Test.stopTest();
    }
    
    @isTest
    public static void updateRelatedUnitStatusAfterCompleted(){
        Test.startTest();
        
        String oppRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpph';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.Project__c = pList[0].Id;
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        Handover__c h = new Handover__c();
        h.Deal__c = oppList[0].Id;
        h.Key_Handover_Done__c = true;
        insert h;
        
        Id csHRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Handover').getRecordTypeId();
        Case cs = new Case();
        cs.Status = 'New';
        cs.Handover__c = h.Id;
        cs.RecordTypeId = csHRecType;
        insert cs;
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        //u.Project__c = oppList[0].Project__c;
        //u.Building__c = bList[0].Id;
        //u.Business_Group__c = bgList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Vacant';
        u.Unit_Purpose__c = 'Leasing';
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//0
        
        insert uList;
        
        Case_Unit__c cu = new Case_Unit__c();
        cu.Case__c = cs.Id;
        cu.Unit__c = uList[0].Id;
        insert cu;
        
        Map<Id, Case> csMap = new Map<Id, Case>();
        csMap.put(cs.Id, cs);
        
        List<Case> CaseList = new List<Case>();
        caseList = [select Id, Type, Status, Handover__c from Case where Handover__r.Deal__r.Name = 'TestOpph' limit 1];
        caseList[0].Type = 'Handover - Auto Refurbishment';
        caseList[0].Status = 'Closed';
        
        CaseTriggerHandler.updateRelatedUnitStatusAfterCompleted(caseList, csMap, null);
        
        Test.stopTest();
    }
    
    @isTest
    public static void sendMailTest() {
        Test.startTest();
        
        Account acc = [select Id from Account limit 1];
        Contact con = new Contact();
        con.LastName = 'Testcon0';
        con.Email = 'Test@con.sf';
        insert con;
        
        Case c = new Case();
        c.Customer_Email__c = 'Temp@cs.sf';
        insert c;
        
        Document__c d = new Document__c();
        d.Case__c = c.Id;
        d.Document_Type__c = 'Move Out Form Application';
        insert d;
        
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        contentVersions.add(contentVersion);
        if(contentVersions.size()>0){
            insert contentVersions;
        }
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=d.Id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =:contentVersions[0].Id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;
        
        c.Status = 'Documents Verification';
        update c;
        
        Test.stopTest();
    }
}