/****************************************************************************************************************************
* @Name         GeneratePaymentLinkCtlrTest
* @Author       Kaustubh Abhyankar
* @Date         29-April-2022
* @Description  Test Class for GeneratePaymentLinkCtlr
****************************************************************************************************************************/

@isTest
public class GeneratePaymentLinkCtlrTest {
    //This Method Creates Test Data....
    @isTest
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        
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
        oppList.add(opp);//0
        
        insert oppList;
        
        Opportunity opp2 = GeneratePaymentLinkCtlr.getTokenAmount(oppList[0].Id);
        
        String result = GeneratePaymentLinkCtlr.createReceipt(oppList[0].Id, 123);
        
        Test.stopTest();
    }
}