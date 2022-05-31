/****************************************************************************************************************************
* @Name         RenewalSRUnitControllerTest
* @Author       Kaustubh Abhyankar
* @Date         25-April-2022
* @Description  Test Class for RenewalSRUnitController
****************************************************************************************************************************/

@isTest
public class RenewalSRUnitControllerTest {
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
        acc.Trade_License_End_Date__c = System.today();
        accList.add(acc);//0
        
        acc = new Account();
        acc.LastName = 'TestAccount1';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accPerRecType;
        acc.Passport_Expiry_Date__c = System.today();
        acc.Visa_Uploaded__c = true;
        acc.Visa_End_Date__c = System.today();
        accList.add(acc);//1
        
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
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.Project__c = pList[0].Id;
        opp.AccountId = accList[3].Id;
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
        //u.Active_Account__c = accList[0].Id;
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
        //u.Active_Account__c = accList[0].Id;
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
        //u.Active_Account__c = accList[0].Id;
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
        //u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//3
        
        insert uList;
        
        List<Unit_Plan__c> upList = new List<Unit_Plan__c>();
        Unit_Plan__c up = new Unit_Plan__c();
        up.Opportunity__c = oppList[2].Id;
        up.Unit__c = uList[2].Id;
        up.Base_Lease_Amount__c = 123;
        upList.add(up);
        
        up = new Unit_Plan__c();
        up.Opportunity__c = oppList[3].Id;
        up.Unit__c = uList[3].Id;
        up.Base_Lease_Amount__c = 123;
        upList.add(up);
        
        insert upList;
        
        List<Property__c> pList = new List<Property__c>();
        Property__c p = new Property__c();
        p.Deal__c = oppList[1].Id;
        p.Unit__c = uList[1].Id;
        p.Account__c = accList[1].Id;
        p.End_Date__c = System.today() + 15;
        p.Primary_Email__c = 'p@test.sf';
        p.Status__c = 'Leased';
        p.Active__c = true;
        pList.add(p);
        
        p = new Property__c();
        p.Deal__c = oppList[2].Id;
        p.Unit__c = uList[2].Id;
        p.Account__c = accList[2].Id;
        p.End_Date__c = System.today() + 15;
        p.Primary_Email__c = 'p@test.sf';
        p.Status__c = 'Leased';
        p.Active__c = true;
        pList.add(p);
        
        p = new Property__c();
        p.Deal__c = oppList[3].Id;
        p.Unit__c = uList[3].Id;
        p.Account__c = accList[3].Id;
        p.End_Date__c = System.today() + 15;
        p.Primary_Email__c = 'p@test.sf';
        p.Status__c = 'Leased';
        p.Active__c = true;
        pList.add(p);
        
        p = new Property__c();
        p.Deal__c = oppList[3].Id;
        p.Unit__c = uList[3].Id;
        p.Account__c = accList[3].Id;
        p.End_Date__c = System.today() + 15;
        p.Primary_Email__c = 'p@test.sf';
        p.Status__c = 'Leased';
        p.Active__c = true;
        pList.add(p);
        
        insert pList;
        
        Flag__c f = new Flag__c();
        f.Unit__c = uList[1].Id;
        f.Active__c = true;
        insert f;
        
        Test.stopTest();
    }
    
    //Testing Method - getUnits
    @isTest
    public static void getUnitsTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, name from Opportunity where Name = 'TestOpp0' limit 1];
        RenewalSRUnitController.ResultWrapper rWrap1 = RenewalSRUnitController.getUnits(opp.Id);
        
        opp = new Opportunity();
        opp = [select Id, name from Opportunity where Name = 'TestOpp1' limit 1];
        RenewalSRUnitController.ResultWrapper rWrap2 = RenewalSRUnitController.getUnits(opp.Id);
        
        opp = new Opportunity();
        opp = [select Id, name from Opportunity where Name = 'TestOpp2' limit 1];
        RenewalSRUnitController.ResultWrapper rWrap3 = RenewalSRUnitController.getUnits(opp.Id);
        
        opp = new Opportunity();
        opp = [select Id, name from Opportunity where Name = 'TestOpp3' limit 1];
        RenewalSRUnitController.ResultWrapper rWrap4 = RenewalSRUnitController.getUnits(opp.Id);
        
        Test.stopTest();
    }
}