/****************************************************************************************************************************
* @Name         PropertyEndLeaseNotificationBatchTest
* @Author       Kaustubh Abhyankar
* @Date         25-April-2022
* @Description  Test Class for PropertyEndLeaseNotificationBatch
****************************************************************************************************************************/

@isTest
public class PropertyEndLeaseNotificationBatchTest {
    @future
    public static void insertRecords() {
        EmailTemplate et = new EmailTemplate();
        et.isActive = true;
        et.Name = 'name';
        et.DeveloperName = 'Lease_renewal_email_alert';
        et.TemplateType = 'text';
        et.FolderId = UserInfo.getUserId();
        insert et;
    }
    
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        
        insertRecords();
        
        Test.startTest();
        
        String accBizRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Business_RecordType').RecordTypeId;//
        String accPerRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('PersonAccount').RecordTypeId;//Broker Account
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestAccount0';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accBizRecType;
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
        opp.Email__c = 'opp@test.sf';
        //opp.Project__c = pList[0].Id;
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
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
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//0
        
        insert uList;
        
        List<Property__c> pList = new List<Property__c>();
        Property__c p = new Property__c();
        p.Deal__c = oppList[0].Id;
        p.Unit__c = uList[0].Id;
        p.Account__c = accList[0].Id;
        p.End_Date__c = System.today() + 15;
        p.Primary_Email__c = 'p@test.sf';
        pList.add(p);
        
        p = new Property__c();
        p.Deal__c = oppList[0].Id;
        p.Unit__c = uList[0].Id;
        p.Account__c = accList[0].Id;
        p.End_Date__c = System.today() + 30;
        p.Primary_Email__c = 'p@test.sf';
        pList.add(p);
        
        p = new Property__c();
        p.Deal__c = oppList[0].Id;
        p.Unit__c = uList[0].Id;
        p.Account__c = accList[0].Id;
        p.End_Date__c = System.today() + 60;
        p.Primary_Email__c = 'p@test.sf';
        pList.add(p);
        
        p = new Property__c();
        p.Deal__c = oppList[0].Id;
        p.Unit__c = uList[0].Id;
        p.Account__c = accList[0].Id;
        p.End_Date__c = System.today() + 90;
        p.Primary_Email__c = 'p@test.sf';
        //pList.add(p);
        
        p = new Property__c();
        p.Deal__c = oppList[0].Id;
        p.Unit__c = uList[0].Id;
        p.Account__c = accList[0].Id;
        p.End_Date__c = System.today() - 15;
        p.Primary_Email__c = 'p@test.sf';
        pList.add(p);
        
        insert pList;
        
        Test.stopTest();
        EmailTemplate et2 = new EmailTemplate ();
        et2 = [select Id, Name from EmailTemplate where DeveloperName = 'Lease_renewal_email_alert' limit 1];
        List<Email_Alerts_Metadata__c> madList = new List<Email_Alerts_Metadata__c>();
        Email_Alerts_Metadata__c mad = new Email_Alerts_Metadata__c();
        mad.Email_Alert_Developer_Name__c = 'Lease_renewal_email_alert';
        mad.Email_Template__c = et2.Id;
        //mad.From_Address__c = 'kaustubh';
        mad.Query_Field_Data__c = 'Email__c';
        madList.add(mad);
        
        mad = new Email_Alerts_Metadata__c();
        mad.Email_Alert_Developer_Name__c = 'Lease_renewal_email_alert_60_days';
        mad.Email_Template__c = et2.Id;
        //mad.From_Address__c = 'kaustubh';
        mad.Query_Field_Data__c = 'Email__c';
        madList.add(mad);
        
        mad = new Email_Alerts_Metadata__c();
        mad.Email_Alert_Developer_Name__c = 'Lease_renewal_email_alert_30_days';
        mad.Email_Template__c = et2.Id;
        //mad.From_Address__c = 'kaustubh';
        mad.Query_Field_Data__c = 'Email__c';
        madList.add(mad);
        
        mad = new Email_Alerts_Metadata__c();
        mad.Email_Alert_Developer_Name__c = 'Lease_renewal_email_alert_15_days';
        mad.Email_Template__c = et2.Id;
        //mad.From_Address__c = 'kaustubh';
        mad.Query_Field_Data__c = 'Email__c';
        madList.add(mad);
        
        mad = new Email_Alerts_Metadata__c();
        mad.Email_Alert_Developer_Name__c = 'Lease_Expired_notification_15_days';
        mad.Email_Template__c = et2.Id;
        //mad.From_Address__c = 'kaustubh';
        mad.Query_Field_Data__c = 'Email__c';
        madList.add(mad);
        
        insert madList;
    }
    
    @isTest
    public static void callBatch1() {
        PropertyEndLeaseNotificationBatch peln = new PropertyEndLeaseNotificationBatch();
        Database.executeBatch(peln);
    }
}