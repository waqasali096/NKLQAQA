/****************************************************************************************************************************
* @Name         LeasingOppAccountSearchCtrlTest
* @Author       Kaustubh Abhyankar
* @Date         18-April-2022
* @Description  Test Class for LeasingOppAccountSearchCtrl
****************************************************************************************************************************/

@isTest
public class LeasingOppAccountSearchCtrlTest {
    //This Method Creates Test Data....
    @testSetup
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
        accList.add(acc);//1
        
        insert accList;
        
        String oppRecType1 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        String oppRecType2 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Lease_Renewal').RecordTypeId;
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
        opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        opp = new Opportunity();
        opp.Name = 'Test Opp2';
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
        opp.AccountId = accList[0].Id;
        oppList.add(opp);//1
        
        opp = new Opportunity();
        opp.Name = 'Test Opp3';
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
        opp.AccountId = accList[1].Id;
        oppList.add(opp);//2
        
        insert oppList;
        
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.LastName = 'TestContact0';
        con.AccountId = accList[0].Id;
        conList.add(con);//0
        
        insert conList;
        
        List<Address__c> addrList = new List<Address__c>();
        Address__c add = new Address__c();
        add.Primary__c = true;
        add.Status__c = 'Active';
        add.Account__c = accList[1].Id;
        add.Country__c = 'IN';
        addrList.add(add);
        
        insert addrList;
        
        System.debug('===============End Of Data Setup===============');
        
        Test.stopTest();
    }
    
    //Testing Method - getFieldSet
    @isTest
    public static void getFieldSetTest() {
        Test.startTest();
        
        List<LeasingOppAccountSearchCtrl.fieldsWrapper> fWrap = LeasingOppAccountSearchCtrl.getFieldSet();
        
        Test.stopTest();
    }
    
    //Testing Methods - oppRecord & addressRecord
    @isTest
    public static void oppRecordTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name from Opportunity where Name = 'Test Opp1' limit 1];
        Opportunity opp2 = LeasingOppAccountSearchCtrl.oppRecord(opp.Id);
        List<Address__c> addList = LeasingOppAccountSearchCtrl.addressRecord(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - fetchAccountList
    @isTest
    public static void fetchAccountListTest() {
        Test.startTest();
        
        Account acc = new Account();
        acc = [select Id, Name, ERP_Account_Number__c, Emirates_Ids__c, Primary_Mobile__c, Trade_Licence_Number__c, Primary_Email__c from Account where Name = 'TestAccount1' limit 1];
        LeasingOppAccountSearchCtrl.AccountWrapper accWrap = LeasingOppAccountSearchCtrl.fetchAccountList(acc.Name, acc.ERP_Account_Number__c, acc.Emirates_Ids__c, acc.Primary_Mobile__c, acc.Trade_Licence_Number__c, false, acc.Primary_Email__c);
        
        Test.stopTest();
    }
    
    //Testing Method - createAccounts
    @isTest
    public static void createAccountsTest() {
        Test.startTest();
        
        List<Account> accList = new List<Account>();
        accList = [select Id, Name from Account];
        Opportunity opp = new Opportunity();
        opp = [select Id, Name from Opportunity where Name = 'Test Opp1' limit 1];
        LeasingOppAccountSearchCtrl.ResultWrapper resWrap = LeasingOppAccountSearchCtrl.createAccounts(accList, opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - checkAccountExists & removeAccounts & getCountryValues
    @isTest
    public static void MethodsTest1() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name from Opportunity where Name = 'Test Opp1' limit 1];
        LeasingOppAccountSearchCtrl.ResultWrapper resWrap = LeasingOppAccountSearchCtrl.checkAccountExists(opp.Id);
        
        boolean result = LeasingOppAccountSearchCtrl.removeAccounts(opp.Id);
        
        Map<String, String> strMap = LeasingOppAccountSearchCtrl.getCountryValues();
        
        Test.stopTest();
    }
    
    //Testing Method - createRecords
    @isTest
    public static void createRecordsTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name, AccountId from Opportunity where Name = 'Test Opp2' limit 1];
        String accJson = '{"attributes":{"type":"Account"},"Name":"TestAccount2","Send_Customer_to_ERP__c":true,"Country_Of_Residence__c":"IN","CurrencyIsoCode":"AED","Passport_Number__c":"P112123","Signatory_Lastname__c":"TestAccount1"}';
        String addrJson = '{"attributes":{"type":"Address__c"},"Primary__c":true,"Status__c":"Active","Country__c":"IN"}';
        String otherAddrJson = '[{"attributes":{"type":"Address__c"},"Primary__c":true,"Status__c":"Active","Country__c":"IN"},{"attributes":{"type":"Address__c"},"Primary__c":true,"Status__c":"Active","Country__c":"IN"}]';
        //LeasingOppAccountSearchCtrl.ResultWrapper resWrap1 = LeasingOppAccountSearchCtrl.createRecords(accJson, true, opp.Id, opp.AccountId, false, addrJson, otherAddrJson, otherAddrJson);
        LeasingOppAccountSearchCtrl.ResultWrapper resWrap2 = LeasingOppAccountSearchCtrl.createRecords(accJson, true, opp.Id, opp.AccountId, false, addrJson, otherAddrJson, otherAddrJson);
        
        Test.stopTest();
    }
    //Testing Method - createRecords
    @isTest
    public static void createRecordsTest2() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name, AccountId from Opportunity where Name = 'Test Opp2' limit 1];
        Account acc = new Account();
        acc = [select Id, name, Send_Customer_to_ERP__c, Country_Of_Residence__c, CurrencyIsoCode, Passport_Number__c, Signatory_Lastname__c from Account where Id =: opp.AccountId limit 1];
        String accJson = '{"attributes":{"type":"Account"},"Name":"TestAccount2","Send_Customer_to_ERP__c":true,"Country_Of_Residence__c":"IN","CurrencyIsoCode":"AED","Passport_Number__c":"P112123","Signatory_Lastname__c":"TestAccount1"}';
        String addrJson = '{"attributes":{"type":"Address__c"},"Primary__c":true,"Status__c":"Active","Country__c":"IN"}';
        String otherAddrJson = '[{"attributes":{"type":"Address__c"},"Primary__c":true,"Status__c":"Active","Country__c":"IN"},{"attributes":{"type":"Address__c"},"Primary__c":true,"Status__c":"Active","Country__c":"IN"}]';
        LeasingOppAccountSearchCtrl.ResultWrapper resWrap1 = LeasingOppAccountSearchCtrl.createRecords(json.serialize(acc), false, opp.Id, opp.AccountId, false, addrJson, otherAddrJson, otherAddrJson);
        //LeasingOppAccountSearchCtrl.ResultWrapper resWrap2 = LeasingOppAccountSearchCtrl.createRecords(accJson, false, opp.Id, opp.AccountId, false, addrJson, otherAddrJson, otherAddrJson);
        Opportunity opp2 = new Opportunity();
        opp2 = [select Id, Name, AccountId from Opportunity where Name = 'Test Opp3' limit 1];
        Account acc2 = new Account();
        acc2 = [select Id, name, Send_Customer_to_ERP__c, Country_Of_Residence__c, CurrencyIsoCode, Passport_Number__c, Signatory_Lastname__c from Account where Id =: opp2.AccountId limit 1];
        String accJson2 = '{"attributes":{"type":"Account"},"Name":"TestAccount2","Send_Customer_to_ERP__c":true,"Country_Of_Residence__c":"IN","CurrencyIsoCode":"AED","Passport_Number__c":"P112123","Signatory_Lastname__c":"TestAccount1"}';
        String addrJson2 = '{"attributes":{"type":"Address__c"},"Primary__c":true,"Status__c":"Active","Country__c":"IN"}';
        String otherAddrJson2 = '[{"attributes":{"type":"Address__c"},"Primary__c":true,"Status__c":"Active","Country__c":"IN"},{"attributes":{"type":"Address__c"},"Primary__c":true,"Status__c":"Active","Country__c":"IN"}]';
        LeasingOppAccountSearchCtrl.ResultWrapper resWrap12 = LeasingOppAccountSearchCtrl.createRecords(json.serialize(acc2), false, opp2.Id, opp2.AccountId, false, addrJson2, otherAddrJson2, otherAddrJson2);
        
        Test.stopTest();
    }
    
    //Testing Method - createRecords
    @isTest
    public static void createRecordsTes() {
        Test.startTest();
        
        LeasingOppAccountSearchCtrl.ResultWrapper res = new LeasingOppAccountSearchCtrl.ResultWrapper();
        res.brokerExist = false;
        
        
        Test.stopTest();
    }
    
    //Testing Method - fetchExistingAccount
    @isTest
    public static void fetchExistingAccountTest() {
        Test.startTest();
        
        Map<String, Object> payload = new Map<String, Object>();
        payload.put('Emirates_Id_Number__c','784-1233-1267567-1');
        
        Map<String, Object> data = new Map<String, Object>();
        data.put('payload',payload);
        
        Map<String, Object> results = new Map<String, Object>();
        results.put('channel', 'c');
        results.put('data', data);
        
        String strJson = JSON.serialize(results);
        try {
            LeasingOppAccountSearchCtrl.fetchExistingAccount(strJson, null, null);
        }catch(Exception e) {
            
        }
        
        Test.stopTest();
    }
}