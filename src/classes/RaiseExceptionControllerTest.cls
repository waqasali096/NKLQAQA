/****************************************************************************************************************************
* @Name         RaiseExceptionControllerTest
* @Author       Kaustubh Abhyankar
* @Date         04-May-2022
* @Description  Test Class for RaiseExceptionController
****************************************************************************************************************************/

@isTest
public class RaiseExceptionControllerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        
        Test.startTest();
        
        String oppRecType1 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        String oppRecType2 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Lease_Renewal').RecordTypeId;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp0';
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
        opp.Day_to_Day_Exception_Type__c = 'DLD Waiver';
        oppList.add(opp);//0
        
        insert oppList;
        
        Test.stopTest();
    }
    
    //Testing Method - getOppData
    @isTest
    public static void getOppDataTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'Test Opp0' limit 1];
        List<RaiseExceptionController.exceptionWrapper> rWrap = RaiseExceptionController.getOppData(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - createDocument
    @isTest
    public static void createDocumentTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'Test Opp0' limit 1];
        NKLResponse nkl = RaiseExceptionController.createDocument(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - saveFile
    @isTest
    public static void saveFileTest() {
        Test.startTest();
        
        List<String> strList = new List<String>{'DLD Waiver'};
        List<RaiseExceptionController.exceptionWrapper> exWrapList = new List<RaiseExceptionController.exceptionWrapper>();
        RaiseExceptionController.exceptionWrapper exWrap = new RaiseExceptionController.exceptionWrapper();
        exWrap.exceptionName = 'DLD Share Exception';
        exWrap.exceptionDLDPercentage = null;
        exWrap.unitDLDPercentage = null;
        exWrap.specialOfferDLDPercentage = null;
        exWrap.oppDLDPercentage = null;
        exWrap.DLDApplied = null;
        exWrap.isDLD = null;
        exWrap.selected = null;
        exWrap.longApproval = null;
        exWrap.exceptionStatus = null;
        exWrap.exceptionApproved = null;
        exWrap.exceptionPending = null;
        exWrapList.add(exWrap);
        
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'Test Opp0' limit 1];
        NKLResponse nkl = RaiseExceptionController.saveFile(opp.Id, exWrapList, null, false);
        
        Test.stopTest();
    }
}