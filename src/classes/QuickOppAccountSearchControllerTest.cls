/****************************************************************************************************************************
* @Name         QuickOppAccountSearchControllerTest
* @Author       Kaustubh Abhyankar
* @Date         29-April-2022
* @Description  Test Class for QuickOppAccountSearchController
****************************************************************************************************************************/

@isTest
public class QuickOppAccountSearchControllerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        
        Test.startTest();
        
        String accBizRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Business_RecordType').RecordTypeId;//
        String accPerRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('PersonAccount').RecordTypeId;//Broker Account
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.LastName = 'TestAccount0';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accPerRecType;
        accList.add(acc);//0
        
        acc = new Account();
        acc.Name = 'TestAccount1';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accBizRecType;
        accList.add(acc);//0
        
        insert accList;
        
        List<Address__c> addList = new List<Address__c>();
        Address__c add = new Address__c();
        add.Account__c = accList[0].Id;
        addList.add(add);
        
        insert addList;
        
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
        opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        opp = new Opportunity();
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
        opp.AccountId = accList[1].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        QuickOppAccountSearchController.ResultWrapper rWrap = QuickOppAccountSearchController.checkAccountExists(oppList[0].Id);
        rWrap = QuickOppAccountSearchController.checkAccountExists(oppList[1].Id);
        
        Test.stopTest();
    }
    
    //Testing Method - checkBrokerAccountExists & createAccounts & removeAccounts & removeReferrals & createBrokerAccounts & getBrokerAccountValues & updateThirdParty
    @isTest
    public static void checkBrokerAccountExistsTest() {
        
        Test.startTest();
        
        String accBizRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Business_RecordType').RecordTypeId;//
        String accBrRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Broker_Account').RecordTypeId;//
        String accPerRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('PersonAccount').RecordTypeId;//
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestAccount0';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accBrRecType;
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
        opp.AccountId = accList[0].Id;
        opp.Employee_Name__c = accList[0].Name;
        opp.Broker__c = accList[0].Id;
        oppList.add(opp);//0
        
        opp = new Opportunity();
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
        opp.Employee_Name__c = accList[0].Name;
        opp.Broker__c = accList[0].Id;
        opp.Referred_Customer__c = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        //Testing Method - checkBrokerAccountExists
        QuickOppAccountSearchController.ResultWrapper rWrap = QuickOppAccountSearchController.checkBrokerAccountExists(oppList[0].Id);
        rWrap = QuickOppAccountSearchController.checkBrokerAccountExists(oppList[1].Id);
        //Testing Method - createAccounts
        rWrap = QuickOppAccountSearchController.createAccounts(accList, oppList[0].Id);
        //Testing Method - removeAccounts
        Boolean result = QuickOppAccountSearchController.removeAccounts(oppList[0].Id);
        //Testing Method - removeReferrals
        result = QuickOppAccountSearchController.removeReferrals(oppList[0].Id, 'broker');
        result = QuickOppAccountSearchController.removeReferrals(oppList[0].Id, 'referral');
        result = QuickOppAccountSearchController.removeReferrals(oppList[0].Id, 'CustomerReferral');
        //Testing Method - createBrokerAccounts
        String str = QuickOppAccountSearchController.createBrokerAccounts(accList, oppList[1].Id);
        //Testing Method - getBrokerAccountValues
        Map<String, Object> strObjMap = QuickOppAccountSearchController.getBrokerAccountValues(oppList[1].Id);
        //Testing Method - updateThirdParty
        rWrap = QuickOppAccountSearchController.updateThirdParty('0013M00000lXtAWQA9', oppList[0].Id);
        
        Test.stopTest();
    }
    
    //Testing Method - checkChildBookedOpportunity
    @isTest
    public static void checkChildBookedOpportunityTest() {
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
        //opp.Employee_Name__c = accList[0].Name;
        //opp.Broker__c = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        opp = new Opportunity();
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
        opp.Opportunity__c = oppList[0].Id;
        //opp.AccountId = accList[0].Id;
        //opp.Employee_Name__c = accList[0].Name;
        //opp.Broker__c = accList[0].Id;
        insert opp;
        
        Boolean result = QuickOppAccountSearchController.checkChildBookedOpportunity(oppList[0].Id);
        result = QuickOppAccountSearchController.checkChildBookedOpportunity(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - fetchAccounts
    @isTest
    public static void fetchAccountsTest() {
        Test.startTest();
        
        List<Account> accList = QuickOppAccountSearchController.fetchAccounts('accName', 'accNum', 'accEmail', 'accMob', 'accEID', 'accTDN', false);
        accList = QuickOppAccountSearchController.fetchAccounts('accName', 'accNum', 'accEmail', 'accMob', 'accEID', 'accTDN', true);
        
        Test.stopTest();
    }
    
    //Testing Method - fetchBrokerAccounts
    @isTest
    public static void fetchBrokerAccountsTest() {
        Test.startTest();
        
        List<Account> accList = QuickOppAccountSearchController.fetchBrokerAccounts('accName', 'accNum', 'accEmail');
        
        Test.stopTest();
    }
    
    //Testing Method - getSortedFieldSetFields & getCountryValues & getPicklistValues
    @isTest
    public static void getSortedFieldSetFieldsTest() {
        Test.startTest();
        
        List<QuickOppAccountSearchController.SObjectFieldWrapper> sofWrapList = QuickOppAccountSearchController.getSortedFieldSetFields('Account', 'branding_fieldset');
        Map<String, String> strMap = QuickOppAccountSearchController.getCountryValues();
        strMap = QuickOppAccountSearchController.getPicklistValues('Opportunity', 'StageName');
        
        Test.stopTest();
    }
    
    //Testing Method - checksAccountAndUnit
    @isTest
    public static void checksAccountAndUnitTest() {
        Test.startTest();
        
        String accBizRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Business_RecordType').RecordTypeId;//
        String accPerRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('PersonAccount').RecordTypeId;//Broker Account
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.LastName = 'TestAccount0';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accPerRecType;
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
        opp.AccountId = accList[0].Id;
        //opp.Employee_Name__c = accList[0].Name;
        //opp.Broker__c = accList[0].Id;
        oppList.add(opp);//0
        
        opp = new Opportunity();
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
        //opp.Employee_Name__c = accList[0].Name;
        //opp.Broker__c = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        opp = new Opportunity();
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
        opp.Opportunity__c = oppList[0].Id;
        opp.AccountId = accList[0].Id;
        //opp.Employee_Name__c = accList[0].Name;
        //opp.Broker__c = accList[0].Id;
        
        insert opp;
        
        Boolean result = QuickOppAccountSearchController.checksAccountAndUnit(opp.Id);
        result = QuickOppAccountSearchController.checksAccountAndUnit(oppList[0].Id);
        result = QuickOppAccountSearchController.checksAccountAndUnit(oppList[1].Id);
        result = QuickOppAccountSearchController.checksAccountAndUnit(null);
        
        Test.stopTest();
    }
    //Testing Method - addAccounts
    @isTest
    public static void addAccountsTest() {
        Test.startTest();
        
        String accBizRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Business_RecordType').RecordTypeId;//
        String accPerRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('PersonAccount').RecordTypeId;//Broker Account
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.LastName = 'TestAccount0';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accPerRecType;
        accList.add(acc);//0
        
        insert accList;
        
        List<Address__c> addList = new List<Address__c>();
        Address__c add = new Address__c();
        add.Account__c = accList[0].Id;
        addList.add(add);
        
        insert addList;
        
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
        opp.AccountId = accList[0].Id;
        //opp.Employee_Name__c = accList[0].Name;
        //opp.Broker__c = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        QuickOppAccountSearchController.ResultWrapper rWrap = QuickOppAccountSearchController.addAccounts(accList[0], addList[0], addList[0], false, oppList[0].Id, 'PersonAccount');
        rWrap = QuickOppAccountSearchController.addAccounts(accList[0], addList[0], addList[0], true, oppList[0].Id, 'PersonAccount');
        
        Test.stopTest();
        
        rWrap = QuickOppAccountSearchController.addAccounts(accList[0], addList[0], addList[0], false, oppList[0].Id, 'Business_RecordType');
        rWrap = QuickOppAccountSearchController.addAccounts(accList[0], addList[0], addList[0], true, oppList[0].Id, 'Business_RecordType');
    }
    
    //Testing Method - createNewAccounts
    @isTest
    public static void createNewAccountsTest() {
        Test.startTest();
        
        String accBizRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Business_RecordType').RecordTypeId;//
        String accPerRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('PersonAccount').RecordTypeId;//Broker Account
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.LastName = 'TestAccount0';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accPerRecType;
        accList.add(acc);//0
        
        insert accList;
        
        List<Address__c> addList = new List<Address__c>();
        Address__c add = new Address__c();
        add.Account__c = accList[0].Id;
        addList.add(add);
        
        insert addList;
        
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
        opp.AccountId = accList[0].Id;
        //opp.Employee_Name__c = accList[0].Name;
        //opp.Broker__c = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        String json = '{"Date_Of_Birth__c":"2000-05-21","FirstName":"Account","LastName":"Test","Account_Number__c":"99999"}';
        QuickOppAccountSearchController.ResultWrapper rWrap = QuickOppAccountSearchController.createNewAccounts(json, 'Account', oppList[0].Id, false, '', addList[0], addList[0]);
        
        Test.stopTest();
    }
}