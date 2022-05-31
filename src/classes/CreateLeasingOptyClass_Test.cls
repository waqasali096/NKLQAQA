/****************************************************************************************************************************
* @Name         CreateLeasingOptyClass_Test
* @Author       Kaustubh Abhyankar
* @Date         18-April-2022
* @Description  Test Class for CreateLeasingOptyClass
****************************************************************************************************************************/

@isTest
public class CreateLeasingOptyClass_Test {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        Test.startTest();
        
        List<Business_Unit__c> buList = new List<Business_Unit__c>();
        Business_Unit__c bu = new Business_Unit__c();
        buList.add(bu);
        
        insert buList;
        
        List<Project__c> pList = new List<Project__c>();
        Project__c p = New Project__c();
        p.Business_Unit__c = buList[0].Id;
        p.Name = 'Test Project 1';
        //p.Project_Type__c = 'New';
        p.Project_Purpose__c = 'Leasing';
        pList.add(p);//0
        
        insert pList;
        
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
        acc.LastName = 'TestAccount1';
        acc.Primary_Email__c = 'test1@account.com';
        acc.Account_Number__c = '9999999991';
        acc.RecordTypeId = accPerRecType;
        accList.add(acc);//1
        
        acc = new Account();
        acc.Name = 'TestAccount2';
        acc.Primary_Email__c = 'test2@account.com';
        acc.Account_Number__c = '9999999992';
        acc.RecordTypeId = accBizRecType;
        accList.add(acc);//2
        
        insert accList;
        
        String oppRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test-Opp-Res';
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
        opp.Name = 'New Opp';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = System.label.Units_Leasing_type;
        opp.Loss_Reason__c = 'Test Reason';
        opp.AccountId = accList[0].Id;
        oppList.add(opp);//1
        
        opp = new Opportunity();
        opp.Name = 'New Opp';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = System.label.Units_Leasing_type;
        opp.Loss_Reason__c = 'Test Reason';
        opp.AccountId = accList[1].Id;
        oppList.add(opp);//2
        
        opp = new Opportunity();
        opp.Name = 'New Opp';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';//Reservation with token amount
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = System.label.Shop_Leasing_type;
        opp.Loss_Reason__c = 'Test Reason';
        opp.AccountId = accList[2].Id;
        oppList.add(opp);//3
        
        insert oppList;
        
        String unitRecT = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = unitRecT;
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[1].Id;
        u.Holding_Deposit_Amount__c = 21001;
        u.RecordTypeId = unitRecT;
        uList.add(u);//1
        
        u = new Unit__c();
        u.Opportunity__c = oppList[2].Id;
        u.Holding_Deposit_Amount__c = 21002;
        u.RecordTypeId = unitRecT;
        uList.add(u);//2
        
        u = new Unit__c();
        u.Opportunity__c = oppList[3].Id;
        u.Holding_Deposit_Amount__c = 21003;
        u.RecordTypeId = unitRecT;
        uList.add(u);//3
        
        insert uList ;
        
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
        
        System.debug('===============End Of Data Setup===============');
        
        Test.stopTest();
    }
    
    //Testing Method - fetchProjects
    @isTest
    public static void fetchProjectsTest() {
        Test.startTest();
        
        Map<String, String> pMap = CreateLeasingOptyClass.fetchProjects();
        
        Test.stopTest();
    }
    
    //Testing Method - fetchHoldingDepositAmount
    @isTest
    public static void fetchHoldingDepositAmountTest() {
        Test.startTest();
        
        Unit_Plan__c up = new Unit_Plan__c();
        up = [select Id, Name, Opportunity__c,Unit__r.Holding_Deposit_Amount__c from Unit_Plan__c where Unit__r.Holding_Deposit_Amount__c = 123 limit 1];
        Decimal result = CreateLeasingOptyClass.fetchHoldingDepositAmount(up.Opportunity__c);
        
        Test.stopTest();
    }
    
    //Testing Method - mandatoryCheck
    @isTest
    public static void mandatoryCheckTest() {
        Test.startTest();
        
        Unit_Plan__c up = new Unit_Plan__c();
        up = [select Id, Name, Opportunity__c,Unit__r.Holding_Deposit_Amount__c from Unit_Plan__c where Unit__r.Holding_Deposit_Amount__c = 123 limit 1];
        CreateLeasingOptyClass.wrapperClass wrap = CreateLeasingOptyClass.mandatoryCheck(up.Opportunity__c);
        
        Test.stopTest();
    }
    
    //Testing Method - convertRecordType
    @isTest
    public static void convertRecordTypeTest() {
        Test.startTest();
        
        Unit_Plan__c up = new Unit_Plan__c();
        up = [select Id, Name, Opportunity__c,Unit__r.Holding_Deposit_Amount__c from Unit_Plan__c where Unit__r.Holding_Deposit_Amount__c = 21001 limit 1];
        String result = CreateLeasingOptyClass.convertRecordType(up.Opportunity__c, 'Reservation with token amount', 'Cash', 123123, System.today());
        
        up = new Unit_Plan__c();
        up = [select Id, Name, Opportunity__c,Unit__r.Holding_Deposit_Amount__c from Unit_Plan__c where Unit__r.Holding_Deposit_Amount__c = 21002 limit 1];
        result = CreateLeasingOptyClass.convertRecordType(up.Opportunity__c, 'Reservation with token amount', 'Cash', 123123, System.today());
        
        up = new Unit_Plan__c();
        up = [select Id, Name, Opportunity__c,Unit__r.Holding_Deposit_Amount__c from Unit_Plan__c where Unit__r.Holding_Deposit_Amount__c = 21003 limit 1];
        result = CreateLeasingOptyClass.convertRecordType(up.Opportunity__c, 'Reservation with token amount', 'Cash', 123123, System.today());
        
        Test.stopTest();
    }
}