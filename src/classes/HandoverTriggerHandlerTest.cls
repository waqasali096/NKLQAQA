/****************************************************************************************************************************
* @Name         HandoverTriggerHandlerTest
* @Author       Kaustubh Abhyankar
* @Date         17-May-2022
* @Description  Test Class for HandoverTriggerHandler
****************************************************************************************************************************/
@isTest
public class HandoverTriggerHandlerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');        
        //Test.setMock(HttpCalloutMock.class, new ContractTriggerHandlerMockClass());
        Test.startTest();
        
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
        acc.Trade_License_End_Date__c = System.today() + 10;
        acc.Primary_Country_Code__c = '971';
        accList.add(acc);//0
        
        insert accList;
        
        Contact con = new Contact();
        con.LastName = 'TsstCon0';
        con.Email = 'Test@con.sf';
        insert con;
        
        String oppRecType1 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        String oppRecType2 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Lease_Renewal').RecordTypeId;
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Sales_Opportunity').RecordTypeId;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp0';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.Unit__c = u.Id;
        opp.AccountId = accList[0].Id;
        opp.Interested_In__c = 'Residential Leasing';
        //opp.Project__c = pList[0].Id;
        //opp.Power_Of_Attorney__c = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        Id renewalContractRcdTyId = Schema.SObjectType.Lease_Contract__c.RecordTypeInfosByDeveloperName.get('Renewal_Contract').RecordTypeId;
        
        List<Lease_Contract__c> lcList = new List<Lease_Contract__c>();
        Lease_Contract__c lc = new Lease_Contract__c();
        lc.Opportunity__c = oppList[0].Id;
        lc.Contract_Stages__c = 'Draft';//Approved
        lc.Handover_Date__c = system.today();
        lc.Amount__c = 100;
        //lc.Send_Lease_to_ERP__c = true;
        lcList.add(lc);//0
        
        insert lcList;
        
        Id salesHandoverRecID = Schema.SObjectType.Handover__c.RecordTypeInfosByDeveloperName.get('Sales').RecordTypeId;
        Handover__c h = new Handover__c();
        h.Deal__c = oppList[0].Id;
        h.RecordTypeId = salesHandoverRecID;
        //h.Proposed_Handover_Executive__c = [select Id from User where Username = 'Test@user0.sf' limit 1].Id;
        insert h;
        
        Test.stopTest();
    }
    
    @isTest
    public static void test1() {
        Test.startTest();
        
        Id salesHandoverRecID = Schema.SObjectType.Handover__c.RecordTypeInfosByDeveloperName.get('Sales').RecordTypeId;
        List<Handover__c> hList = new List<Handover__c>();
        Handover__c h = new Handover__c();
        h.RecordTypeId = salesHandoverRecID;
        h.Home_Orientation_Date__c = System.today();
        hList.add(h);
        
        h = new Handover__c();
        h.RecordTypeId = salesHandoverRecID;
        h.Home_Orientation_Date__c = System.today();
        hList.add(h);
        
        h = new Handover__c();
        h.RecordTypeId = salesHandoverRecID;
        h.Home_Orientation_Date__c = System.today();
        hList.add(h);
        
        h = new Handover__c();
        h.RecordTypeId = salesHandoverRecID;
        h.Proposed_Handover_Executive__c = UserInfo.getUserId();
        h.Home_Orientation_Date__c = System.today();
        hList.add(h);
        
        h = new Handover__c();
        h.RecordTypeId = salesHandoverRecID;
        h.Home_Orientation_Date__c = System.today();
        hList.add(h);
        
        insert hList;
        
        hList[0].Home_Orientation_Checklist_Completed__c = true;
        hList[1].Status__c = 'Inspection Approved';
        hList[2].Status__c = 'Home Orientation Invite Sent';
        hList[3].HE_Acceptance_Status__c = 'Accept';
        hList[4].Internal_De_snagging_uploaded__c = true;
        update hList;
        
        Test.stopTest();
    }
    
    @isTest
    public static void test2() {
        Test.startTest();
        
        Id salesHandoverRecID = Schema.SObjectType.Handover__c.RecordTypeInfosByDeveloperName.get('Sales').RecordTypeId;
        List<Handover__c> hList = new List<Handover__c>();
        Handover__c h = new Handover__c();
        h.RecordTypeId = salesHandoverRecID;
        h.Status__c = 'Customer Rejected';
        hList.add(h);
        
        h = new Handover__c();
        h.RecordTypeId = salesHandoverRecID;
        h.Status__c = 'Inspection Rejected';
        hList.add(h);
        
        h = new Handover__c();
        h.RecordTypeId = salesHandoverRecID;
        h.Status__c = 'Inspection Approved';
        hList.add(h);
        
        insert hList;
        
        hList[0].Status__c = 'Inspection Approved';
        hList[1].Status__c = 'Customer Rejected';
        hList[2].Status__c = 'Handover Completed';
        try {
            update hList;
            
        }catch(Exception e) {
            
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void test3() {
        Test.startTest();
        
        String oppRecType1 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        String oppRecType2 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Lease_Renewal').RecordTypeId;
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Sales_Opportunity').RecordTypeId;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp0';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        opp.Handover_Date__c = System.today();
        //opp.Unit__c = u.Id;
        //opp.AccountId = accList[0].Id;
        opp.Interested_In__c = 'Residential Leasing';
        //opp.Project__c = pList[0].Id;
        //opp.Power_Of_Attorney__c = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        Id leasingUnitRecID = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Selling_Price__c = 123;
        u.RecordTypeId = leasingUnitRecID;
        uList.add(u);
        
        insert uList;
        
        List<Unit_Plan__c> upList = new List<Unit_Plan__c>();
        Unit_Plan__c up = new Unit_Plan__c();
        up.Opportunity__c = oppList[0].Id;
        up.Unit__c = UList[0].Id;
        upList.add(up);
        
        insert upList;
        
        Id renewalContractRcdTyId = Schema.SObjectType.Lease_Contract__c.RecordTypeInfosByDeveloperName.get('Renewal_Contract').RecordTypeId;
        
        List<Lease_Contract__c> lcList = new List<Lease_Contract__c>();
        Lease_Contract__c lc = new Lease_Contract__c();
        lc.Opportunity__c = oppList[0].Id;
        lc.Contract_Stages__c = 'Draft';//Approved
        lc.Handover_Date__c = system.today();
        lc.Amount__c = 100;
        //lc.Send_Lease_to_ERP__c = true;
        lcList.add(lc);//0
        
        insert lcList;
        
        Id salesHandoverRecID = Schema.SObjectType.Handover__c.RecordTypeInfosByDeveloperName.get('Sales').RecordTypeId;
        Id leasingHandoverRecID = Schema.SObjectType.Handover__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Handover__c> hList = new List<Handover__c>();
        Handover__c h = new Handover__c();
        h.Deal__c = oppList[0].Id;
        h.RecordTypeId = leasingHandoverRecID;
        hList.add(h);
        
        insert hList;
        
        hList[0].Status__c = 'Completed';
        
        update hList;
        
        Test.stopTest();
    }
    
    @isTest
    public static void test4() {
        Test.startTest();
        
        Id residentialCommercialRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get(system.label.Residential_Leasing_Commercial_Units).RecordTypeId;
        Id residentialShopRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get(system.label.Commercial_Units_Leasing).RecordTypeId; //Added by Sajid
        Id residentialUnitRecordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get(system.label.Residential_Leasing_Unit).RecordTypeId;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp0';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = residentialUnitRecordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        opp.Handover_Date__c = System.today();
        //opp.Unit__c = u.Id;
        //opp.AccountId = accList[0].Id;
        opp.Interested_In__c = 'Residential Leasing';
        //opp.Project__c = pList[0].Id;
        //opp.Power_Of_Attorney__c = accList[0].Id;
        oppList.add(opp);//0
        
        opp = new Opportunity();
        opp.Name = 'TestOpp0';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = residentialShopRecordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        opp.Handover_Date__c = System.today();
        //opp.Unit__c = u.Id;
        //opp.AccountId = accList[0].Id;
        opp.Interested_In__c = 'Residential Leasing';
        //opp.Project__c = pList[0].Id;
        //opp.Power_Of_Attorney__c = accList[0].Id;
        oppList.add(opp);//0
        
        opp = new Opportunity();
        opp.Name = 'TestOpp0';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = residentialCommercialRecordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        opp.Handover_Date__c = System.today();
        //opp.Unit__c = u.Id;
        //opp.AccountId = accList[0].Id;
        opp.Interested_In__c = 'Residential Leasing';
        //opp.Project__c = pList[0].Id;
        //opp.Power_Of_Attorney__c = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        Id leasingUnitRecID = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Selling_Price__c = 123;
        u.RecordTypeId = leasingUnitRecID;
        uList.add(u);
        
        u = new Unit__c();
        u.Opportunity__c = oppList[1].Id;
        u.Selling_Price__c = 123;
        u.RecordTypeId = leasingUnitRecID;
        uList.add(u);
        
        u = new Unit__c();
        u.Opportunity__c = oppList[2].Id;
        u.Selling_Price__c = 123;
        u.RecordTypeId = leasingUnitRecID;
        uList.add(u);
        
        insert uList;
        
        List<Unit_Plan__c> upList = new List<Unit_Plan__c>();
        Unit_Plan__c up = new Unit_Plan__c();
        up.Opportunity__c = oppList[0].Id;
        up.Unit__c = UList[0].Id;
        upList.add(up);
        
        up = new Unit_Plan__c();
        up.Opportunity__c = oppList[1].Id;
        up.Unit__c = UList[1].Id;
        upList.add(up);
        
        up = new Unit_Plan__c();
        up.Opportunity__c = oppList[2].Id;
        up.Unit__c = UList[2].Id;
        upList.add(up);
        
        insert upList;
        
        Id leasingHandoverRecID = Schema.SObjectType.Handover__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Handover__c> hList = new List<Handover__c>();
        Handover__c h = new Handover__c();
        h.Deal__c = oppList[0].Id;
        h.RecordTypeId = leasingHandoverRecID;
        hList.add(h);
        
        h = new Handover__c();
        h.Deal__c = oppList[1].Id;
        h.RecordTypeId = leasingHandoverRecID;
        hList.add(h);
        
        h = new Handover__c();
        h.Deal__c = oppList[2].Id;
        h.RecordTypeId = leasingHandoverRecID;
        hList.add(h);
        
        insert hList;
        
        List<Card__c> cList = new List<Card__c>();
        Card__c c = new Card__c();
        c.Handover__c = hList[0].Id;
        c.Unit__c = uList[0].Id;
        
        cList.add(c);
        
        c = new Card__c();
        c.Handover__c = hList[1].Id;
        c.Unit__c = uList[1].Id;
        cList.add(c);
        
        c = new Card__c();
        c.Handover__c = hList[2].Id;
        c.Unit__c = uList[2].Id;
        cList.add(c);
        
        insert cList;
        
        hList[0].Is_SR_Closed__c = true;
        hList[0].Key_Handover_Done__c = true;
        hList[0].Key_Handover_Date__c = System.today();
        hList[0].Key_Handover_Form_Uploaded__c = true;
        hList[0].Access_Card_Handover_Done__c = true;
        hList[0].Move_In_Form_Uploaded_Validation__c = true;
        
        hList[1].Is_SR_Closed__c = true;
        hList[1].Key_Handover_Done__c = true;
        hList[1].Key_Handover_Date__c = System.today();
        hList[1].Key_Handover_Form_Uploaded__c = true;
        hList[1].Access_Card_Handover_Done__c = true;
        hList[1].Move_In_Form_Uploaded_Validation__c = true;
        hList[1].Is_SR_Closed__c = true;
        
        hList[2].Is_SR_Closed__c = true;
        hList[2].Key_Handover_Done__c = true;
        hList[2].Key_Handover_Date__c = System.today();
        hList[2].Key_Handover_Form_Uploaded__c = true;
        hList[2].Access_Card_Handover_Done__c = true;
        hList[2].Move_In_Form_Uploaded_Validation__c = true;
        
        try {
            update hList;
        }catch(Exception e) {
            System.debug('==========' + e.getCause());
            System.debug('==========' + e.getLineNumber());
            System.debug('==========' + e.getMessage());
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void test5() {
        Test.startTest();
        
        Opportunity opp = [select Id, name from Opportunity where AccountId != null limit 1];
        Handover__c h = new Handover__c();
        h.Deal__c = opp.Id;
        insert h;
        
        Document__c d = new Document__c();
        d.Handover__c = h.Id;
        d.Document_Type__c = 'Move In Application';
        insert d;
        
        Object_Document__c od = new Object_Document__c();
        od.Handover__c = h.Id;
        od.Document__c = d.Id;
        insert od;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Move_In_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = h.Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        
        h.Move_In_Application_Uploaded__c = true;
        update h;
        
        Test.stopTest();
    }
}