/****************************************************************************************************************************
* @Name         AssignAgencyControllerTest
* @Author       Kaustubh Abhyankar
* @Date         19-April-2022
* @Description  Test Class for AssignAgencyController
****************************************************************************************************************************/
@isTest
public class AssignAgencyControllerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        
        Test.startTest();
        
        String accRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Broker_Account').RecordTypeId;
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestAccount0';
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
        accList.add(acc);//1
        
        acc = new Account();
        acc.Name = 'TestAccount2';
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
        accList.add(acc);//2
        
        acc = new Account();
        acc.Name = 'TestAccount3';
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
        accList.add(acc);//3
        
        insert accList;
        
        String oppRecType1 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        String oppRecType2 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Lease_Renewal').RecordTypeId;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp0';
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
        opp.AccountId = accList[0].Id;
        opp.Broker__c = accList[0].Id;
        opp.Employee_Name__c = 'TestEmp';
        oppList.add(opp);//0
        
        opp = new Opportunity();
        opp.Name = 'TestOpp1';
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
        opp.AccountId = accList[1].Id;
        opp.Broker__c = accList[1].Id;
        opp.Employee_Name__c = 'TestEmp';
        oppList.add(opp);//1
        
        opp = new Opportunity();
        opp.Name = 'TestOpp2';
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
        opp.AccountId = accList[2].Id;
        opp.Broker__c = accList[2].Id;
        opp.Employee_Name__c = 'TestEmp';
        opp.Agency_Name__c = accList[2].Id;
        oppList.add(opp);//2
        
        opp = new Opportunity();
        opp.Name = 'TestOpp3';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType2;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        opp.AccountId = accList[3].Id;
        opp.Broker__c = accList[3].Id;
        opp.Employee_Name__c = 'TestEmp';
        opp.Agency_Name__c = accList[3].Id;
        oppList.add(opp);//3
        
        insert oppList;
        
        Test.stopTest();
    }
    
    //Testing Method - fetchAccounts
    @isTest
    public static void fetchAccountsTest() {
        Test.startTest();
        
        List<Account> accList1 = AssignAgencyController.fetchAccounts('TestAccount0','3129921','test0@Account.SF','1293993931','784-1234-1234569-8','',true);
        
        Test.stopTest();
    }
    
    //Testing Method - fetchBrokerAccounts
    @isTest
    public static void fetchBrokerAccountsTest() {
        Test.startTest();
        
        List<Account> accList = AssignAgencyController.fetchBrokerAccounts('TempName');
        
        Test.stopTest();
    }
    
    //Testing Method - checkAccountExists
    @isTest
    public static void checkAccountExistsTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'TestOpp0' limit 1];
        String accId = AssignAgencyController.checkAccountExists(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - checkBrokerAccountExists
    @isTest
    public static void checkBrokerAccountExistsTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'TestOpp0' limit 1];
        AssignAgencyController.ResultWrapper rWrap = AssignAgencyController.checkBrokerAccountExists(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - createAccounts
    @isTest
    public static void createAccountsTest() {
        Test.startTest();
        
        List<Account> accList = new List<Account>();
        accList = [select Id, Name from Account where Name = 'TestAccount0' limit 1];
        Opportunity opp = [select Id, Name from Opportunity where Name = 'TestOpp0' limit 1];
        String accId = AssignAgencyController.createAccounts(accList, opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - removeAgencyFromOpportunity
    @isTest
    public static void removeAgencyFromOpportunityTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'TestOpp1' limit 1];
        Boolean result = AssignAgencyController.removeAgencyFromOpportunity(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - removeAccounts
    @isTest
    public static void removeAccountsTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'TestOpp2' limit 1];
        Boolean result = AssignAgencyController.removeAccounts(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - fetchBrokerAccountDetails
    @isTest
    public static void fetchBrokerAccountDetailsTest() {
        Test.startTest();
        
        Opportunity opp1 = [select Id, Name from Opportunity where Name = 'TestOpp2' limit 1];
        Opportunity opp2 = AssignAgencyController.fetchBrokerAccountDetails(opp1.Id);
        Opportunity opp3 = AssignAgencyController.fetchBrokerAccountDetails('0063M98597651JmQAI');
        
        Test.stopTest();
    }
    
    //Testing Method - createBrokerAccounts
    @isTest
    public static void createBrokerAccountsTest() {
        Test.startTest();
        
        List<Account> accList = new List<Account>();
        accList = [select Id, Name from Account where Name = 'TestAccount2' limit 1];
        Opportunity opp = [select Id, Name from Opportunity where Name = 'TestOpp2' limit 1];
        String accId = AssignAgencyController.createBrokerAccounts(accList, opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - getAccountValues
    @isTest
    public static void getAccountValuesTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'TestOpp2' limit 1];
        Map<String, Object> soMap = AssignAgencyController.getAccountValues(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - getBrokerAccountValues
    @isTest
    public static void getBrokerAccountValuesTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'TestOpp2' limit 1];
        Map<String, Object> soMap = AssignAgencyController.getBrokerAccountValues(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - fetchExistingAccount
    @isTest
    public static void fetchExistingAccountTest() {
        Test.startTest();
        
        String recordJSON = '{"FirstName":"TestFName", "LastName":"TestLName"}';
        
        Test.stopTest();
    }
    
    //Testing Method - getSortedFieldSetFields
    @isTest
    public static void getSortedFieldSetFieldsTest() {
        Test.startTest();
        
        List<AssignAgencyController.SObjectFieldWrapper> sofWrapList = AssignAgencyController.getSortedFieldSetFields('Account', 'branding_fieldset');
        
        Test.stopTest();
    }
}