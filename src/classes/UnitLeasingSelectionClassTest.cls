/****************************************************************************************************************************
* @Name         UnitLeasingSelectionClassTest
* @Author       Kaustubh Abhyankar
* @Date         21-April-2022
* @Description  Test Class for UnitLeasingSelectionClass
****************************************************************************************************************************/

@isTest
public class UnitLeasingSelectionClassTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        Test.startTest();
        
        String accPerRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('PersonAccount').RecordTypeId;
        Account acc = new Account();
        acc.LastName = 'TestLName';
        acc.RecordTypeId = accPerRecType;
        insert acc;
        
        List<Business_Group__c> bgList = new List<Business_Group__c>();
        Business_Group__c bg = new Business_Group__c();
        bgList.add(bg);//0
        
        bg = new Business_Group__c();
        bgList.add(bg);//1
        
        insert bgList;
        
        List<Business_Unit__c> buList = new List<Business_Unit__c>();
        Business_Unit__c bu = new Business_Unit__c();
        buList.add(bu);//0
        
        bu = new Business_Unit__c();
        buList.add(bu);//1
        
        bu = new Business_Unit__c();
        bu.Business_Group__c = bgList[1].Id;
        buList.add(bu);//2
        
        insert buList;
        
        List<project__c> pList = new List<project__c>();
        project__c p = new project__c();
        p.Business_Unit__c = buList[0].Id;
        pList.add(p);//0
        
        p = new project__c();
        p.Business_Unit__c = buList[1].Id;
        pList.add(p);//1
        
        p = new project__c();
        p.Business_Unit__c = buList[2].Id;
        p.Business_Group__c = bgList[1].Id;
        pList.add(p);//2
        
        insert pList;
        
        String oppRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        String oppLRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Leasing_Records').RecordTypeId;
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
        opp.Project__c = pList[0].Id;
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        opp = new Opportunity();
        opp.Name = 'TestOpp1';
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
        opp.Project__c = pList[1].Id;
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//1
        
        opp = new Opportunity();
        opp.Name = 'TestOpp2';
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
        opp.Project__c = pList[2].Id;
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//2
        
        opp = new Opportunity();
        opp.Name = 'TestOpp3';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppLRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.Project__c = pList[2].Id;
        opp.AccountId = acc.Id;
        oppList.add(opp);//3
        
        insert oppList;
        
        List<Cluster__c> cList = new List<Cluster__c>();
        Cluster__c c = new Cluster__c();
        c.Project__c = pList[1].Id;
        cList.add(c);//0
        
        c = new Cluster__c();
        c.Project__c = pList[2].Id;
        c.Business_Group__c = bgList[1].Id;
        cList.add(c);//1
        
        insert cList;
        
        List<Building__c> bList = new List<Building__c>();
        Building__c b = new Building__c();
        b.Project__c = pList[1].Id;
        b.Cluster__c =  cList[0].Id;
        b.Address_Line1__c = 'TestAddress0';
        bList.add(b);//0
        
        b = new Building__c();
        //b.Project__c = pList[2].Id;
        b.Cluster__c =  cList[1].Id;
        b.Business_Group__c = bgList[1].Id;
        b.Building_Purpose__c = 'Leasing';
        b.Address_Line1__c = 'TestAddress1';
        bList.add(b);//1
        
        insert bList;
        
        System.debug('===============Building============' + bList[1].Business_Group__c + '--------' +bList[1].Building_Purpose__c);
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Project__c = oppList[0].Project__c;
        u.Business_Group__c = bgList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Vacant';
        u.Unit_Purpose__c = 'Leasing';
        System.debug('===============unit============'+ u.Business_Group__c + '----' + u.Unit_Purpose__c + '----' + u.Building__r.Building_Purpose__c + '----' + u.Building__r.Business_Group__c);
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[2].Id;
        u.Project__c = oppList[2].Project__c;
        u.Cluster__c = cList[1].Id;
        u.Building__c = bList[1].Id;
        u.Business_Group__c = bgList[1].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Vacant';
        u.No_of_Bedrooms__c = '1';
        u.Unit_Purpose__c = 'Leasing';
        System.debug('===============unit============'+ u.Business_Group__c + '----' + u.Unit_Purpose__c + '----' + u.Building__r.Building_Purpose__c + '----' + u.Building__r.Business_Group__c);
        uList.add(u);//1
        
        insert uList;
        
        System.debug('===============unit============');
        
        Test.stopTest();
    }
    
    //Testing Method - getFilters & getOptyRecord & OptyRecord
    @isTest
    public static void getFiltersTest() {
        Test.startTest();
        
        Opportunity opp1 = new Opportunity();
        opp1 = [select Id, Name from Opportunity where Name = 'TestOpp0' limit 1];
        UnitLeasingWrapperClass.filtersWrapper fWrap = UnitLeasingSelectionClass.getFilters(opp1.Id);
        
        Opportunity opp2 = UnitLeasingSelectionClass.getOptyRecord(opp1.Id);
        Opportunity opp3 = UnitLeasingSelectionClass.OptyRecord(opp1.Id);
        
        System.debug('===============getFiltersTest============');
        
        Test.stopTest();
    }
    
    //Testing Method - fetchCluster
    @isTest
    public static void fetchClusterTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name, Project__c from Opportunity where Name = 'TestOpp1' limit 1];
        Map<String, String> strMap = UnitLeasingSelectionClass.fetchCluster(opp.Project__c);
        
        System.debug('===============fetchClusterTest============');
        
        Test.stopTest();
    }
    
    //Testing Method - fetchBuilding
    @isTest
    public static void fetchBuildingTest() {
        Test.startTest();
        
        Building__c b = new Building__c();
        b = [select Id, Name, Cluster__c, Project__c from Building__c where Address_Line1__c = 'TestAddress0' limit 1];
        Map<String, String> strMap = UnitLeasingSelectionClass.fetchBuilding(b.Cluster__c, b.Project__c);
        strMap = UnitLeasingSelectionClass.fetchBuilding(null, b.Project__c);
        
        System.debug('===============fetchBuildingTest============');
        
        Test.stopTest();
    }
    
    //Testing Method - findUnitByName
    @isTest
    public static void findUnitByNameTest() {
        Test.startTest();
        
        List<Unit__c> uList1 = UnitLeasingSelectionClass.findUnitByName(null);
        List<Unit__c> uList2 = UnitLeasingSelectionClass.findUnitByName('null');
        
        System.debug('===============findUnitByNameTest============');
        
        Test.stopTest();
    }
    
    //Testing Method - searchUnit
    @isTest
    public static void searchUnitTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name, Project__c from Opportunity where Name = 'TestOpp2' limit 1];
        Cluster__c cl = new Cluster__c();
        cl = [select Id, Name from Cluster__c where Project__c =: opp.Project__c limit 1];
        Building__c b = new Building__c();
        b = [select Id, Name, Cluster__c, Project__c from Building__c where Address_Line1__c = 'TestAddress1' limit 1];
        UnitLeasingWrapperClass.filtersWrapper fWrap = UnitLeasingSelectionClass.searchUnit(cl.Id, opp.Project__c, b.Id, null, null, null, null, null, null, null, null, opp.Id, '1', null, null);
        
        System.debug('===============searchUnitTest============');
        
        Test.stopTest();
    }
    
    //Testing Method - addUnitstoOpp
    @isTest
    public static void addUnitstoOppTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name, Project__c from Opportunity where Name = 'TestOpp2' limit 1];
        List<Unit__c> uList = new List<Unit__c>([select Id, Name from Unit__c where Opportunity__c =: opp.Id limit 1]);
        List<Id> IdList = new List<Id>();
        IdList.add(uList[0].Id);
        UnitLeasingSelectionClass.addUnitstoOpp(opp.Id, IdList);
        
        Test.stopTest();
    }
    
    //Testing Method - checkTaggedUnits
    @isTest
    public static void checkTaggedUnitsTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name, Project__c from Opportunity where Name = 'TestOpp2' limit 1];
        Boolean result = UnitLeasingSelectionClass.checkTaggedUnits(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - fetchUnits
    @isTest
    public static void fetchUnitsTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name, Project__c from Opportunity where Name = 'TestOpp2' limit 1];
        List<Unit__c> uList = new List<Unit__c>([select Id, Name from Unit__c where Opportunity__c =: opp.Id limit 1]);
        List<UnitLeasingWrapperClass.unitwrapper> uWrap = UnitLeasingSelectionClass.fetchUnits(opp.Id);
        try {
            uWrap = UnitLeasingSelectionClass.fetchUnits(uList[0].Id);
        }catch(Exception e) {}
        
        Test.stopTest();
    }
    
    //Testing Method - propertyCheckOnCustomer
    @isTest
    public static void propertyCheckOnCustomerTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name, Project__c from Opportunity where Name = 'TestOpp3' limit 1];
        try {
            List<Property__c> pList = UnitLeasingSelectionClass.propertyCheckOnCustomer(opp.Id);
        }catch(Exception e) {}
        
        Test.stopTest();
    }
    
    //Testing Method - submitForApproval
    @isTest
    public static void submitForApprovalTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name, Project__c from Opportunity where Name = 'TestOpp2' limit 1];
        try {
            UnitLeasingSelectionClass.submitForApproval(opp.Id);
        }catch(Exception e) {}
        
        Test.stopTest();
    }
}