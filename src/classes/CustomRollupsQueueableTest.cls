/****************************************************************************************************************************
* @Name         CustomRollupsQueueableTest
* @Author       Kaustubh Abhyankar
* @Date         27-April-2022
* @Description  Test Class for CustomRollupsQueueable
****************************************************************************************************************************/

@isTest
public class CustomRollupsQueueableTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        
        Test.startTest();
        
        Business_Group__c bg = new Business_Group__c();
        insert bg;
        
        List<Business_Unit__c> buList = new List<Business_Unit__c>();
        Business_Unit__c bu = new Business_Unit__c();
        bu.Business_Group__c = bg.Id;
        buList.add(bu);
        
        insert buList;
        
        System.debug('Business Group on Business Unit - ' + buList[0].Business_Group__c);
        
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
        
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.LastName = 'TestCon0';
        con.AccountId = accList[0].Id;
        con.Is_Primary__c = true;
        conList.add(con);//0
        
        insert conList;
        
        List<Project__c> pList = new List<Project__c>();
        Project__c p = new Project__c();
        p.Business_Unit__c = buList[0].Id;
        p.Business_Group__c = bg.Id;
        p.Project_Purpose__c = 'Leasing';
        pList.add(p);
        
        insert pList;
        
        System.debug('Business Group on Project - ' + pList[0].Business_Group__c);
        
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
        opp.Business_Unit__c = buList[0].Id;
        opp.Project__c = pList[0].Id;
        opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        List<Cluster__c> cList = new List<Cluster__c>();
        Cluster__c c = new Cluster__c();
        c.Business_Group__c = bg.Id;
        c.Business_Unit__c = buList[0].Id;
        c.Project__c = pList[0].Id;
        c.Cluster_Purpose__c = 'Leasing';
        cList.add(c);
        
        insert cList;
        
        System.debug('Business Group on Cluster - ' + cList[0].Business_Group__c);
        
        List<Building__c> bList = new List<Building__c>();
        Building__c b = new Building__c();
        b.Business_Group__c = bg.Id;
        b.Business_Unit__c = buList[0].Id;
        b.Project__c = pList[0].Id;
        b.Cluster__c = cList[0].Id;
        b.Building_Purpose__c = 'Leasing';
        bList.add(b);
        
        insert bList;
        
        System.debug('Business Group on Building - ' + bList[0].Business_Group__c);
        System.debug('Building Purpose - ' + bList[0].Building_Purpose__c);
        
        List<Floor__c> fList = new List<Floor__c>();
        Floor__c f = new Floor__c();
        f.Business_Group__c = bg.Id;
        f.Business_Unit__c = buList[0].Id;
        f.Project__c = pList[0].Id;
        f.Cluster__c = cList[0].Id;
        f.Building__c = bList[0].Id;
        
        fList.add(f);
        
        insert fList;
        
        System.debug('Business Group on Floor - ' + fList[0].Business_Group__c);
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Business_Group__c = bg.Id;
        u.Business_Unit__c = buList[0].Id;
        u.Project__c = pList[0].Id;
        u.Cluster__c = cList[0].Id;
        u.Building__c = bList[0].Id;
        u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Available';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[0].Id;
        u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Business_Group__c = bg.Id;
        u.Business_Unit__c = buList[0].Id;
        u.Project__c = pList[0].Id;
        u.Cluster__c = cList[0].Id;
        u.Building__c = bList[0].Id;
        u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Booked';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[0].Id;
        u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//1
        
        u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Business_Group__c = bg.Id;
        u.Business_Unit__c = buList[0].Id;
        u.Project__c = pList[0].Id;
        u.Cluster__c = cList[0].Id;
        u.Building__c = bList[0].Id;
        u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Leased';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[0].Id;
        u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//1
        
        u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Business_Group__c = bg.Id;
        u.Business_Unit__c = buList[0].Id;
        u.Project__c = pList[0].Id;
        u.Cluster__c = cList[0].Id;
        u.Building__c = bList[0].Id;
        u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Sold';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[0].Id;
        u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//1
        
        u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Business_Group__c = bg.Id;
        u.Business_Unit__c = buList[0].Id;
        u.Project__c = pList[0].Id;
        u.Cluster__c = cList[0].Id;
        u.Building__c = bList[0].Id;
        u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Reserved';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[0].Id;
        u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//1
        
        u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Business_Group__c = bg.Id;
        u.Business_Unit__c = buList[0].Id;
        u.Project__c = pList[0].Id;
        u.Cluster__c = cList[0].Id;
        u.Building__c = bList[0].Id;
        u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Vacant';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[0].Id;
        u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//2
        
        insert uList;
        
        System.debug('Unit - ' + uList[0].Business_Group__c);
        System.debug('Business Group on Unit - ' + uList[0].Business_Group__c);
        
        Test.stopTest();
    }
    
    @isTest
    public static void callQueueable() {
        Test.startTest();
        
        Set<Id> idList = new Set<Id>();
        List<Project__c> pList = new List<Project__c>();
        pList = [select Id, Name from Project__c limit 1];
        IdList.add(pList[0].Id);
        
        CustomRollupsQueueable crq = new CustomRollupsQueueable(IdList);
        ID jobID = System.enqueueJob(crq);
        
        Test.stopTest();
    }
}