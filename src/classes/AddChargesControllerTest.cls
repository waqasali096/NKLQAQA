/****************************************************************************************************************************
* @Name         AddChargesControllerTest
* @Author       Sanket Chaudhari
* @Date         06-May-2022
* @Description  Test Class for AddChargesController
****************************************************************************************************************************/


@isTest
public class AddChargesControllerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        
        Test.startTest();
        
        String oppRecType1 = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Residential Units Leasing').RecordTypeId;
        String oppRecType2 = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Lease Renewal').RecordTypeId;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp1';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType1;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        Additional_Charges__c ac = new Additional_Charges__c();
        ac.Name = 'TestCharge0';
        ac.Charge_Type__c = 'DLD_FEE';
        insert ac;
        
        Test.stopTest();
    }
    
    @isTest
    public static void getAdditionalChargesTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'Test Opp1' limit 1];
        NKLResponse nkl = AddChargesController.getAdditionalCharges(null, opp.Id);
        
        Test.stopTest();
    }
    
    @isTest
    public static void createOppChargesTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'Test Opp1' limit 1];
        List<Additional_Charges__c> acList = [select Id, Name, Charge_Type__c from Additional_Charges__c];
        
        NKLResponse nkl = AddChargesController.createOppCharges(acList, opp.Id);
        
        Test.stopTest();
    }
    
    /*
    @isTest
    public static void testSuccessCharge(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
       	Unit__c unit = new Unit__c();
        unit.Name = 'Test Unit';
        unit.Unit_Status__c = 'Available';
        insert unit;
        List<Additional_Charges__c> chargeList = TestDataFactory.createAdditionalCharge(false);
        chargeList[0].Unit__c = unit.Id;
        insert chargeList;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.Unit__c = unit.Id;
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.RecordTypeId = oppRecordTypeId;
        insert opp;
        
        //Test.startTest();
        //AddChargesController.getAdditionalCharges(unit.Id,opp.Id);
       // AddChargesController.createOppCharges(chargeList, opp.Id);
       // Test.stopTest();
        
    }*/
}