/****************************************************************************************************************************
* @Name         ContentDocumentLinkHandlerTest
* @Author       Kaustubh Abhyankar
* @Date         29-April-2022
* @Description  Test Class for ContentDocumentLinkHandler
****************************************************************************************************************************/

@isTest
public class ContentDocumentLinkHandlerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
    }
    
    //
    @isTest
    public static void opportunity() {
        Test.startTest();
        
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
        opp.Document_Type__c = 'Sales Booking Form';
        //opp.AccountId = accList[0].Id;
        //opp.Employee_Name__c = accList[0].Name;
        //opp.Broker__c = accList[0].Id;
        oppList.add(opp);//0
        
        opp = new Opportunity();
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
        opp.Document_Type__c = 'Sales SPA';
        //opp.AccountId = accList[0].Id;
        //opp.Employee_Name__c = accList[0].Name;
        //opp.Broker__c = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Leasing_Booking_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Payment_Advice),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = oppList[0].Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        
        ContentDocumentLink cdlopp2 = new ContentDocumentLink();
        cdlopp2.LinkedEntityId = oppList[1].Id;
        cdlopp2.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[1].Id].contentdocumentid;
        cdlopp2.ShareType = 'I';
        cdlopp2.Visibility = 'AllUsers';
        insert cdlopp2;
        
        Test.stopTest();
    }
    //
    @isTest
    public static void leaseContract() {
        Test.startTest();
        
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
        //opp.AccountId = accList[0].Id;
        //opp.Employee_Name__c = accList[0].Name;
        //opp.Broker__c = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        List<Lease_Contract__c> lcList = new List<Lease_Contract__c>();
        Lease_Contract__c lc = new Lease_Contract__c();
        lc.Opportunity__c = oppList[0].Id;
        lc.Contract_Stages__c = 'Draft';
        lc.Handover_Date__c = system.today();
        lc.Send_Lease_to_ERP__c = false;
        lcList.add(lc);//0
        
        insert lcList;
        
        //
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Payment_Receipt),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Contract),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Signed_Contract),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = oppList[0].Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = lcList[0].Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[1].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = lcList[0].Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[2].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        
        Test.stopTest();
    }
    
    //
    @isTest
    public static void project_AND_handover() {
        Test.startTest();
        
        List<Business_Unit__c> buList = new List<Business_Unit__c>();
        Business_Unit__c bu = new Business_Unit__c();
        buList.add(bu);//0
        
        insert buList;
        
        List<Project__c> pList = new List<Project__c>();
        Project__c p = new Project__c();
        p.Business_Unit__c = buList[0].Id;
        pList.add(p);//0
        
        insert pList;
        
        List<Handover__c> hList = new List<Handover__c>();
        Handover__c h = new Handover__c();
        hList.add(h);//0
        
        insert hList;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Move_In_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Landlord_Signature),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = hList[0].Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = pList[0].Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[1].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        
        Test.stopTest();
    }
    
    //
    @isTest
    public static void oppDocument() {
        Test.startTest();
        
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
        //opp.AccountId = accList[0].Id;
        //opp.Employee_Name__c = accList[0].Name;
        //opp.Broker__c = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        Document__c d = new Document__c();
        insert d;
        Object_Document__c od = new Object_Document__c();
        od.Document__c = d.Id;
        od.Opportunity__c = oppList[0].Id;
        od.Checkbox_Field_API_Name__c = 'Name';
        insert od;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Leasing_Booking_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = d.Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        delete cdlopp;
        
        Test.stopTest();
    }
    
    //
    @isTest
    public static void caseDocument() {
        Test.startTest();
        
        Case c = new Case();
        insert c;
        
        Document__c d = new Document__c();
        insert d;
        Object_Document__c od = new Object_Document__c();
        od.Document__c = d.Id;
        od.Case__c = c.Id;
        od.Checkbox_Field_API_Name__c = 'Name';
        insert od;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Leasing_Booking_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = d.Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        delete cdlopp;
        
        Test.stopTest();
    }
    
    //
    @isTest
    public static void specialofferDocument() {
        Test.startTest();
        
        special_offer__c so = new special_offer__c();
        so.Start_Date__c = System.today();
        so.End_Date__c = System.today() + 10;
        insert so;
        
        Document__c d = new Document__c();
        insert d;
        Object_Document__c od = new Object_Document__c();
        od.Document__c = d.Id;
        od.Special_Offer__c = so.Id;
        od.Checkbox_Field_API_Name__c = 'Name';
        insert od;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Leasing_Booking_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = d.Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        delete cdlopp;
        
        Test.stopTest();
    }
    
    //
    @isTest
    public static void registrationDocument() {
        Test.startTest();
        
        Registration__c r = new Registration__c();
        insert r;
        
        Document__c d = new Document__c();
        insert d;
        Object_Document__c od = new Object_Document__c();
        od.Document__c = d.Id;
        od.Registration__c = r.Id;
        od.Checkbox_Field_API_Name__c = 'Name';
        insert od;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Leasing_Booking_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = d.Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        delete cdlopp;
        
        Test.stopTest();
    }
    
    //
    @isTest
    public static void callinglistDocument() {
        Test.startTest();
        
        Calling_List__c cl = new Calling_List__c();
        insert cl;
        
        Document__c d = new Document__c();
        insert d;
        Object_Document__c od = new Object_Document__c();
        od.Document__c = d.Id;
        od.Calling_List__c = cl.Id;
        od.Checkbox_Field_API_Name__c = 'Name';
        insert od;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Leasing_Booking_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = d.Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        delete cdlopp;
        
        Test.stopTest();
    }
    
    //
    @isTest
    public static void projectDocument() {
        Test.startTest();
        
        Business_Unit__c bu = new Business_Unit__c();
        insert bu;
        Project__c p = new Project__c();
        p.Business_Unit__c = bu.Id;
        insert p;
        
        Document__c d = new Document__c();
        insert d;
        Object_Document__c od = new Object_Document__c();
        od.Document__c = d.Id;
        od.Project__c = p.Id;
        od.Checkbox_Field_API_Name__c = 'Name';
        insert od;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Leasing_Booking_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = d.Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        delete cdlopp;
        
        Test.stopTest();
    }
    
    //
    @isTest
    public static void handoverDocument() {
        Test.startTest();
        
        Handover__c h = new Handover__c();
        insert h;
        
        Document__c d = new Document__c();
        insert d;
        Object_Document__c od = new Object_Document__c();
        od.Document__c = d.Id;
        od.Handover__c = h.Id;
        od.Checkbox_Field_API_Name__c = 'Name';
        insert od;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Leasing_Booking_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = d.Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        delete cdlopp;
        
        Test.stopTest();
    }
    
    //
    @isTest
    public static void leasecontractDocument() {
        Test.startTest();
        
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
        //opp.AccountId = accList[0].Id;
        //opp.Employee_Name__c = accList[0].Name;
        //opp.Broker__c = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        Lease_Contract__c lc = new Lease_Contract__c();
        lc.Opportunity__c = oppList[0].Id;
        lc.Contract_Stages__c = 'Draft';
        lc.Handover_Date__c = system.today();
        lc.Send_Lease_to_ERP__c = false;
        insert lc;
        
        Document__c d = new Document__c();
        insert d;
        Object_Document__c od = new Object_Document__c();
        od.Document__c = d.Id;
        od.Contract__c = lc.Id;
        od.Checkbox_Field_API_Name__c = 'Name';
        insert od;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Leasing_Booking_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = d.Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        delete cdlopp;
        
        Test.stopTest();
    }
}