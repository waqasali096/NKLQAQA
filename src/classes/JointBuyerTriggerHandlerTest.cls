/****************************************************************************************************************************
* @Name         JointBuyerTriggerHandlerTest
* @Author       Kaustubh Abhyankar
* @Date         04-May-2022
* @Description  Test Class for JointBuyerTriggerHandler
****************************************************************************************************************************/

@isTest
public class JointBuyerTriggerHandlerTest {
    //This Method Creates Test Data....
    @isTest
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
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
        accList.add(acc);//0
        
        acc = new Account();
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
        
        insert oppList;
        
        List<Agreement__c> agList = new List<Agreement__c>();
        Agreement__c ag = new Agreement__c();
        ag.Account__c = accList[0].Id;
        ag.Opportunity__c = oppList[0].Id;
        agList.add(ag);
        
        insert agList;
        
        List<Joint_Buyer__c> jbList = new List<Joint_Buyer__c>();
        Joint_Buyer__c jb = new Joint_Buyer__c();
        jb.Secondary_Account__c = accList[1].Id;
        jb.Opportunity__c = oppList[0].Id;
        jb.Share_Percentage__c = 12;
        jbList.add(jb);
        
        jb = new Joint_Buyer__c();
        jb.Primary_Account__c = accList[0].Id;
        jb.Opportunity__c = oppList[0].Id;
        jb.Share_Percentage__c = 12;
        jbList.add(jb);
        
        insert jbList;
        
        jbList[0].Share_Percentage__c = 21;
        update jbList;
        
        delete jbList;
        
        Test.stopTest();
    }
}