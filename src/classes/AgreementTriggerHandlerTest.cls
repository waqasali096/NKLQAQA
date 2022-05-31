/****************************************************************************************************************************
* @Name         AgreementTriggerHandlerTest
* @Author       Kaustubh Abhyankar
* @Date         05-May-2022
* @Description  Test Class for AgreementTriggerHandler
****************************************************************************************************************************/

@isTest
public class AgreementTriggerHandlerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');        
        Test.startTest();
        
        List<Business_Group__c> bgList = new List<Business_Group__c>();
        Business_Group__c bg = new Business_Group__c();
        bg.Name = 'Nakheel';
        bgList.add(bg);
        
        bg = new Business_Group__c();
        bg.Name = 'Meydan Group LLC';
        bgList.add(bg);
        
        bg = new Business_Group__c();
        bg.Name = 'District One - FZ';
        bgList.add(bg);
        
        insert bgList;
        
        List<Business_Unit__c> buList = new List<Business_Unit__c>();
        Business_Unit__c bu = new Business_Unit__c();
        bu.Business_Group__c = bgList[0].Id;
        buList.add(bu);
        
        bu = new Business_Unit__c();
        bu.Business_Group__c = bgList[1].Id;
        buList.add(bu);
        
        bu = new Business_Unit__c();
        bu.Business_Group__c = bgList[2].Id;
        buList.add(bu);
        
        insert buList;
        
        List<Project__c> pList = new List<Project__c>();
        Project__c p = new Project__c();
        p.Business_Unit__c = buList[0].Id;
        p.Business_Group__c = bgList[0].Id;
        p.Project_Purpose__c = 'Sales';
        pList.add(p);
        
        p = new Project__c();
        p.Business_Unit__c = buList[1].Id;
        p.Business_Group__c = bgList[1].Id;
        p.Project_Purpose__c = 'Sales';
        pList.add(p);
        
        p = new Project__c();
        p.Business_Unit__c = buList[2].Id;
        p.Business_Group__c = bgList[2].Id;
        p.Project_Purpose__c = 'Sales';
        pList.add(p);
        
        insert pList;
        
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
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
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
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        Joint_Buyer__c jb = new Joint_Buyer__c();
        jb.Opportunity__c = oppList[0].Id;
        jb.Primary_Account__c = accList[0].Id;
        insert jb;
        
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        Payment_Milestone__c pm = new Payment_Milestone__c();
        pm.Opportunity__c = oppList[0].Id;
        pmList.add(pm);
        
        insert pmList;
        
        List<Cluster__c> cList = new List<Cluster__c>();
        Cluster__c c = new Cluster__c();
        c.Business_Group__c = bgList[0].Id;
        c.Business_Unit__c = buList[0].Id;
        c.Project__c = pList[0].Id;
        c.Cluster_Purpose__c = 'Sales';
        cList.add(c);
        
        c = new Cluster__c();
        c.Business_Group__c = bgList[1].Id;
        c.Business_Unit__c = buList[1].Id;
        c.Project__c = pList[1].Id;
        c.Cluster_Purpose__c = 'Sales';
        cList.add(c);
        
        c = new Cluster__c();
        c.Business_Group__c = bgList[2].Id;
        c.Business_Unit__c = buList[2].Id;
        c.Project__c = pList[2].Id;
        c.Cluster_Purpose__c = 'Sales';
        cList.add(c);
        
        insert cList;
        
        List<Building__c> bList = new List<Building__c>();
        Building__c b = new Building__c();
        b.Business_Group__c = bgList[0].Id;
        b.Business_Unit__c = buList[0].Id;
        b.Project__c = pList[0].Id;
        b.Cluster__c = cList[0].Id;
        b.Building_Purpose__c = 'Sales';
        bList.add(b);
        
        b = new Building__c();
        b.Business_Group__c = bgList[1].Id;
        b.Business_Unit__c = buList[1].Id;
        b.Project__c = pList[1].Id;
        b.Cluster__c = cList[1].Id;
        b.Building_Purpose__c = 'Sales';
        bList.add(b);
        
        b = new Building__c();
        b.Business_Group__c = bgList[2].Id;
        b.Business_Unit__c = buList[2].Id;
        b.Project__c = pList[2].Id;
        b.Cluster__c = cList[2].Id;
        b.Building_Purpose__c = 'Sales';
        bList.add(b);
        
        insert bList;
        
        List<Floor__c> fList = new List<Floor__c>();
        Floor__c f = new Floor__c();
        f.Business_Group__c = bgList[0].Id;
        f.Business_Unit__c = buList[0].Id;
        f.Project__c = pList[0].Id;
        f.Cluster__c = cList[0].Id;
        f.Building__c = bList[0].Id;
        fList.add(f);
        
        f = new Floor__c();
        f.Business_Group__c = bgList[1].Id;
        f.Business_Unit__c = buList[1].Id;
        f.Project__c = pList[1].Id;
        f.Cluster__c = cList[1].Id;
        f.Building__c = bList[1].Id;
        fList.add(f);
        
        f = new Floor__c();
        f.Business_Group__c = bgList[2].Id;
        f.Business_Unit__c = buList[2].Id;
        f.Project__c = pList[2].Id;
        f.Cluster__c = cList[2].Id;
        f.Building__c = bList[2].Id;
        fList.add(f);
        
        insert fList;
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Business_Group__c = bgList[0].Id;
        u.Business_Unit__c = buList[0].Id;
        u.Project__c = pList[0].Id;
        u.Cluster__c = cList[0].Id;
        u.Building__c = bList[0].Id;
        u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Sold';
        u.Unit_Purpose__c = 'Sales';
        u.Unit_Code__c = 'U-123';
        uList.add(u);//1
        
        u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Business_Group__c = bgList[1].Id;
        u.Business_Unit__c = buList[1].Id;
        u.Project__c = pList[1].Id;
        u.Cluster__c = cList[1].Id;
        u.Building__c = bList[1].Id;
        u.Floor__c = fList[1].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Sold';
        u.Unit_Purpose__c = 'Sales';
        u.Unit_Code__c = 'U-124';
        uList.add(u);//2
        
        u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Business_Group__c = bgList[2].Id;
        u.Business_Unit__c = buList[2].Id;
        u.Project__c = pList[2].Id;
        u.Cluster__c = cList[2].Id;
        u.Building__c = bList[2].Id;
        u.Floor__c = fList[2].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Sold';
        u.Unit_Purpose__c = 'Sales';
        u.Unit_Code__c = 'U-125';
        uList.add(u);//3
        
        insert uList;
        
        List<Agreement__c> agList = new List<Agreement__c>();
        Agreement__c ag = new Agreement__c();
        ag.Account__c = accList[0].Id;
        ag.Opportunity__c = oppList[0].Id;
        ag.Unit__c = uList[0].Id;
        ag.Status__c = 'SPA Printed';
        ag.SPA_Generated__c = true;
        ag.SPA_Verified__c =  true;
        agList.add(ag);//0
        
        ag = new Agreement__c();
        ag.Comments__c = 'TestAg1';
        ag.Account__c = accList[0].Id;
        //ag.Opportunity__c = oppList[0].Id;
        //ag.Unit__c = uList[0].Id;
        ag.Status__c = 'SPA Printed';
        agList.add(ag);//1
        
        ag = new Agreement__c();
        ag.Comments__c = 'TestAg2';
        ag.Account__c = accList[0].Id;
        ag.SPA_Generated__c = true;
        ag.Unit__c = uList[1].Id;
        //ag.Opportunity__c = oppList[0].Id;
        //ag.Unit__c = uList[0].Id;
        ag.Status__c = 'SPA Printed';
        agList.add(ag);//2
        
        ag = new Agreement__c();
        ag.Comments__c = 'TestAg3';
        ag.Account__c = accList[0].Id;
        ag.SPA_Generated__c = true;
        ag.Unit__c = uList[2].Id;
        //ag.Opportunity__c = oppList[0].Id;
        //ag.Unit__c = uList[0].Id;
        ag.Status__c = 'SPA Printed';
        agList.add(ag);//3
        
        ag = new Agreement__c();
        ag.Comments__c = 'TestAg4';
        ag.Account__c = accList[0].Id;
        ag.SPA_Generated__c = true;
        ag.Unit__c = uList[3].Id;
        //ag.Opportunity__c = oppList[0].Id;
        //ag.Unit__c = uList[0].Id;
        ag.Status__c = 'SPA Printed';
        agList.add(ag);//4
        
        ag = new Agreement__c();
        ag.Comments__c = 'TestAg5';
        ag.Account__c = accList[0].Id;
        ag.Opportunity__c = oppList[1].Id;
        //ag.Unit__c = uList[0].Id;
        ag.Status__c = 'SPA Printed';
        agList.add(ag);//5
        
        ag = new Agreement__c();
        ag.Comments__c = 'TestAg6';
        ag.Account__c = accList[0].Id;
        ag.Opportunity__c = oppList[2].Id;
        //ag.Unit__c = uList[0].Id;
        ag.Status__c = 'SPA Printed';
        agList.add(ag);//6
        
        insert agList;
        
        Test.stopTest();
    }
    
    @isTest
    public static void method1() {
        Test.startTest();
        
        Agreement__c ag = [select Id, Name from Agreement__c where Opportunity__r.Name = 'TestOpp0' limit 1];
        ag.Received_Customer_Copy_of_SPA__c = true;
        ag.Dispatch_Type__c = 'Customer in Office';
        
        ag.Complete_Address_PO_Box_GCC__c = 'Not Applicable';
        update ag;
        
        Agreement__c ag1 = [select Id, Name, SPA_Generated__c, Signed_SPA__c, Compliance_Documents_Uploaded__c, Received_Customer_Copy_of_SPA__c, Status__c from Agreement__c where Comments__c = 'TestAg1' limit 1];
        ag1.SPA_Generated__c = true;
        ag1.SPA_Generated__c = true;
        ag1.Signed_SPA__c = true;
        ag1.Compliance_Documents_Uploaded__c = true;
        ag1.Received_Customer_Copy_of_SPA__c = true;
        ag1.Dispatch_Type__c = 'Customer in Office';
        ag1.Create_Registration_Record__c = true;
        update ag1;
        
        ag1.Status__c = 'Terminated';
        ag1.Termination_Reason__c = 'Reason';
        update ag1;
        
        Test.stopTest();
    }
    
    @isTest
    public static void method2() {
        Test.startTest();
        
        Agreement__c ag1 = [select Id, SPA_Verified__c, Status__c from Agreement__c where Comments__c = 'TestAg2' limit 1];
        ag1.SPA_Verified__c = true;
        ag1.Status__c = 'SPA Sent to Customer';
        update ag1;
        
        Agreement__c ag2 = [select Id, SPA_Verified__c, Status__c from Agreement__c where Comments__c = 'TestAg3' limit 1];
        ag2.SPA_Verified__c = true;
        ag2.Status__c = 'SPA Sent to Customer';
        update ag2;
        
        Agreement__c ag3 = [select Id, SPA_Verified__c, Status__c from Agreement__c where Comments__c = 'TestAg4' limit 1];
        ag3.SPA_Verified__c = true;
        ag3.Status__c = 'SPA Sent to Customer';
        update ag3;
        
        Test.stopTest();
    }
    
    @isTest
    public static void method3() {
        Test.startTest();
        
        Agreement__c ag1 = [select Id, SPA_Verified__c, Status__c from Agreement__c where Comments__c = 'TestAg5' limit 1];
        ag1.Dispatch_Type__c = 'Courier';
        ag1.Courier_Status__c = 'Returned to Office/Undelivered';
        ag1.Courier_Agency_Name__c = 'A101';
        ag1.Courier_Bill_Number__c = 'CB101';
        ag1.Courier_Date__c = System.today();
        ag1.SPA_Verified__c = true;
        //ag1.Status__c = 'SPA Sent to Customer';
        update ag1;
        
        Agreement__c ag2 = [select Id, SPA_Verified__c, Status__c from Agreement__c where Comments__c = 'TestAg6' limit 1];
        ag2.Dispatch_Type__c = 'Courier';
        ag2.Courier_Status__c = 'On Transit';
        ag2.Courier_Agency_Name__c = 'A102';
        ag2.Courier_Bill_Number__c = 'CB102';
        ag2.Courier_Date__c = System.today();
        ag2.SPA_Verified__c = true;
        //ag2.Status__c = 'SPA Sent to Customer';
        update ag2;
        
        Test.stopTest();
    }
}