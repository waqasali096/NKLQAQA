/****************************************************************************************************************************
* @Name         AddOptionsControllerTest 
* @Author       Sanket Chaudhari
* @Date         10-May-2022
* @Description  Test Class for AddOptionsController
****************************************************************************************************************************/

@isTest
public class AddOptionsControllerTest {
    @isTest
    public static void testSuccessOptions(){
         String oppRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Residential Units Leasing').RecordTypeId;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp0';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = true;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.Business_Unit__c = buList[0].Id;
        //opp.Project__c = pList[0].Id;
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        insert oppList;
        
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Unit__c unit = new Unit__c();
        unit.Name = 'Test Unit';
        unit.Unit_Status__c = 'Available';
        unit.Opportunity__c=oppList[0].Id;
        insert unit;
        Master_Option__c masterOpt = new Master_Option__c();
        masterOpt.Name = 'Test Master';
        insert masterOpt;
        List<Unit_Option__c> optionList = new List<Unit_Option__c>();
        Unit_Option__c option = new Unit_Option__c();
        option.Master_Option__c = masterOpt.Id;
        option.Unit__c = unit.Id;
        optionList.add(option);
        insert optionList;
        
        
        
        Test.startTest();
        AddOptionsController.getUnitOptions(unit.Id,opp.id);
        AddOptionsController.createOppOptions(optionList,optionList,opp.Id);
        Test.stopTest();
        
    }
}