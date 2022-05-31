/****************************************************************************************************************************
* @Name         LeasingUnitReleaseBatchTest
* @Author       Kaustubh Abhyankar
* @Date         18-April-2022
* @Description  Test Class for LeasingUnitReleaseBatch
****************************************************************************************************************************/

@isTest
public class LeasingUnitReleaseBatchTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        Test.startTest();
        
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
        oppList.add(opp);//0
        
        opp = new Opportunity();
        opp.Name = 'Test-Opp-Res';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = false;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        oppList.add(opp);//1
        
        opp = new Opportunity();
        opp.Name = 'Test-Opp-Res';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Fee_gets_collected__c = true;
        opp.Security_Deposit_Recevied__c = false;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        oppList.add(opp);//2
        
        opp = new Opportunity();
        opp.Name = 'Test-Opp-Res';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Fee_gets_collected__c = true;
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        oppList.add(opp);//3
        
        opp = new Opportunity();
        opp.Name = 'Test-Opp-Res';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Fee_gets_collected__c = false;
        opp.Security_Deposit_Recevied__c = false;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        oppList.add(opp);//4
        
        opp = new Opportunity();
        opp.Name = 'Test-Opp-Res';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Fee_gets_collected__c = true;
        opp.Security_Deposit_Recevied__c = false;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        oppList.add(opp);//5
        
        insert oppList;
        
        String unitRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;        
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.RecordTypeId = unitRecType;
        u.Unit_Status__c = 'On Hold';
        uList.add(u);//0
        
        u = new Unit__c();
        u.RecordTypeId = unitRecType;
        u.Unit_Status__c = 'On Hold';
        uList.add(u);//1
        
        u = new Unit__c();
        u.RecordTypeId = unitRecType;
        u.Unit_Status__c = 'On Hold';
        uList.add(u);//2
        
        u = new Unit__c();
        u.RecordTypeId = unitRecType;
        u.Unit_Status__c = 'On Hold';
        uList.add(u);//3
        
        u = new Unit__c();
        u.RecordTypeId = unitRecType;
        u.Unit_Status__c = 'On Hold';
        uList.add(u);//4
        
        u = new Unit__c();
        u.RecordTypeId = unitRecType;
        u.Unit_Status__c = 'On Hold';
        uList.add(u);//5
        
        insert uList;
        
        List<Unit_Booking_Reservation__c> ubrList = new List<Unit_Booking_Reservation__c>();
        Unit_Booking_Reservation__c ubr = new Unit_Booking_Reservation__c();
        ubr.Deal__c = oppList[0].Id;
        ubr.Unit__c = uList[0].Id;
        ubr.ProcessRecords__c = true;
        ubr.Reservation_Date__c = System.today() - 10;
        ubrList.add(ubr);//0
        
        ubr = new Unit_Booking_Reservation__c();
        ubr.Deal__c = oppList[1].Id;
        ubr.Unit__c = uList[1].Id;
        ubr.ProcessRecords__c = true;
        ubr.Reservation_Date__c = System.today() - 10;
        ubrList.add(ubr);//1
        
        ubr = new Unit_Booking_Reservation__c();
        ubr.Deal__c = oppList[2].Id;
        ubr.Unit__c = uList[2].Id;
        ubr.ProcessRecords__c = false;
        ubr.Reservation_Date__c = System.today() - 10;
        ubrList.add(ubr);//2
        
        ubr = new Unit_Booking_Reservation__c();
        ubr.Deal__c = oppList[3].Id;
        ubr.Unit__c = uList[3].Id;
        ubr.ProcessRecords__c = true;
        ubr.Reservation_Date__c = System.today() - 10;
        ubrList.add(ubr);//3
        
        ubr = new Unit_Booking_Reservation__c();
        ubr.Deal__c = oppList[4].Id;
        ubr.Unit__c = uList[4].Id;
        ubr.ProcessRecords__c = true;
        ubr.Reservation_Date__c = System.today() - 10;
        ubrList.add(ubr);//4
        
        ubr = new Unit_Booking_Reservation__c();
        ubr.Deal__c = oppList[5].Id;
        ubr.Unit__c = uList[5].Id;
        ubr.ProcessRecords__c = true;
        ubr.Reservation_Date__c = System.today() - 10;
        ubrList.add(ubr);//5
        
        insert ubrList;
        
        System.debug('===============End Of Data Setup===============');
        
        Test.stopTest();
    }
    
    //Calling batch class
    @isTest
    public static void callBatchTest() {
        Test.startTest();
        
        List<Unit_Booking_Reservation__c> ubrList = new List<Unit_Booking_Reservation__c>();
        ubrList = [select Id, Name from Unit_Booking_Reservation__c];
        LeasingUnitReleaseBatch lurb = new LeasingUnitReleaseBatch();
        Database.executeBatch(lurb);
        
        Test.stopTest();
    }
}