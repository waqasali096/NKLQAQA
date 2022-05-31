/****************************************************************************************************************************
* @Name         LeasingInventoryWizardController_Test
* @Author       Kaustubh Abhyankar
* @Date         22-April-2022
* @Description  Test Class for LeasingInventoryWizardController
****************************************************************************************************************************/

@isTest
public class LeasingInventoryWizardControllerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        Test.startTest();
        
        List<Business_Group__c> bgList = new List<Business_Group__c>();
        Business_Group__c bg = new Business_Group__c();
        bgList.add(bg);//0
        
        bg = new Business_Group__c();
        bgList.add(bg);//1
        
        bg = new Business_Group__c();
        bgList.add(bg);//2
        
        insert bgList;
        
        List<Business_Unit__c> buList = new List<Business_Unit__c>();
        Business_Unit__c bu = new Business_Unit__c();
        buList.add(bu);//0
        
        bu = new Business_Unit__c();
        buList.add(bu);//1
        
        bu = new Business_Unit__c();
        bu.Business_Group__c = bgList[2].Id;
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
        p.Business_Group__c = bgList[2].Id;
        pList.add(p);//2
        
        insert pList;
        
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
        //opp.AccountId = accList[1].Id;
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
        //opp.AccountId = accList[2].Id;
        oppList.add(opp);//2
        
        insert oppList;
        
        List<Cluster__c> cList = new List<Cluster__c>();
        Cluster__c c = new Cluster__c();
        c.Project__c = pList[0].Id;
        cList.add(c);//0
        
        c = new Cluster__c();
        c.Project__c = pList[1].Id;
        c.Business_Group__c = bgList[1].Id;
        cList.add(c);//1
        
        c = new Cluster__c();
        c.Project__c = pList[2].Id;
        c.Business_Group__c = bgList[2].Id;
        cList.add(c);//2
        
        insert cList;
        
        List<Building__c> bList = new List<Building__c>();
        Building__c b = new Building__c();
        b.Project__c = pList[0].Id;
        b.Cluster__c =  cList[0].Id;
        b.Address_Line1__c = 'TestAddress0';
        bList.add(b);//0
        
        b = new Building__c();
        b.Project__c = pList[1].Id;
        b.Cluster__c =  cList[1].Id;
        b.Business_Group__c = bgList[1].Id;
        b.Building_Purpose__c = 'Leasing';
        b.Address_Line1__c = 'TestAddress1';
        bList.add(b);//1
        
        b = new Building__c();
        b.Project__c = pList[2].Id;
        b.Cluster__c =  cList[2].Id;
        b.Business_Group__c = bgList[2].Id;
        b.Building_Purpose__c = 'Leasing';
        b.Address_Line1__c = 'TestAddress1';
        bList.add(b);//2
        
        insert bList;
        
        List<Floor__c> fList = new List<Floor__c>();
        Floor__c f = new Floor__c();
        fList.add(f);//0
        
        f = new Floor__c();
        fList.add(f);//1
        
        f = new Floor__c();
        fList.add(f);//2
        
        insert fList;
        
        System.debug('===============Building============' + bList[1].Business_Group__c + '--------' +bList[1].Building_Purpose__c);
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Project__c = oppList[0].Project__c;
        //u.Building__c = bList[0].Id;
        u.Business_Group__c = bgList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Vacant';
        u.Unit_Purpose__c = 'Leasing';
        System.debug('===============unit============'+ u.Business_Group__c + '----' + u.Unit_Purpose__c + '----' + u.Building__r.Building_Purpose__c + '----' + u.Building__r.Business_Group__c);
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[1].Id;
        u.Project__c = oppList[1].Project__c;
        u.Cluster__c = cList[1].Id;
        //u.Building__c = bList[1].Id;
        u.Business_Group__c = bgList[1].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Vacant';
        u.No_of_Bedrooms__c = '1';
        u.Unit_Purpose__c = 'Leasing';
        u.Leasing_Property_Type__c = 'Villa';
        u.Unit_space_Type__c = 'High';
        System.debug('===============unit============'+ u.Business_Group__c + '----' + u.Unit_Purpose__c + '----' + u.Building__r.Building_Purpose__c + '----' + u.Building__r.Business_Group__c);
        uList.add(u);//1
        
        u = new Unit__c();
        u.Opportunity__c = oppList[2].Id;
        u.Project__c = oppList[2].Project__c;
        u.Cluster__c = cList[2].Id;
        //u.Building__c = bList[2].Id;
        u.Floor__c = fList[0].Id;
        u.Business_Group__c = bgList[2].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Vacant';
        u.No_of_Bedrooms__c = '1';
        u.Unit_Purpose__c = 'Leasing';
        u.Leasing_Property_Type__c = 'Villa';
        u.Unit_space_Type__c = 'High';
        System.debug('===============unit============'+ u.Business_Group__c + '----' + u.Unit_Purpose__c + '----' + u.Building__r.Building_Purpose__c + '----' + u.Building__r.Business_Group__c);
        uList.add(u);//2
        
        insert uList;
        
        Test.stopTest();
    }
    
    //Testing Method - fetchLeasingInventoryWizardSetting
    @isTest
    public static void fetchLeasingInventoryWizardSettingTest() {
        Test.startTest();
        
        List<Leasing_Inventory_Wizard_Setting__mdt> liwsList = LeasingInventoryWizardController.fetchLeasingInventoryWizardSetting();
        
        Test.stopTest();
    }
    
    //Testing Method - fetchProjectNames
    @isTest
    public static void fetchProjectNamesTest() {
        Test.startTest();
        
        List<Project__c> pList = LeasingInventoryWizardController.fetchProjectNames();
        
        Test.stopTest();
    }
    
    //Testing Method - fetchUnits
    @isTest
    public static void fetchUnitsTest() {
        Test.startTest();
        
        Unit__c u = new Unit__c();
        u = [select Id, Project__c, No_of_Bedrooms__c, Unit_space_Type__c, Leasing_Property_Type__c, Cluster__c from Unit__c where Opportunity__r.Name = 'TestOpp2' limit 1];
        List<Unit__c> uList = LeasingInventoryWizardController.fetchUnits('resedential', u.Project__c, u.No_of_Bedrooms__c, u.Unit_space_Type__c, u.Leasing_Property_Type__c, u.Cluster__c, u.Cluster__c, u.Cluster__c);
        
        Test.stopTest();
    }
    
    //Testing Method - clusterPicklistValues
    @isTest
    public static void clusterPicklistValuesTest() {
        Test.startTest();
        
        Unit__c u = new Unit__c();
        u = [select Id, Project__c from Unit__c where Opportunity__r.Name = 'TestOpp2' limit 1];
        List<Cluster__c> uList = LeasingInventoryWizardController.clusterPicklistValues(u.Project__c);
        uList = LeasingInventoryWizardController.clusterPicklistValues('u  Project__c');
        
        Test.stopTest();
    }
    
    //Testing Method - buildingPicklistValues
    @isTest
    public static void buildingPicklistValuesTest() {
        Test.startTest();
        
        Unit__c u = new Unit__c();
        u = [select Id, Project__c, Cluster__c from Unit__c where Opportunity__r.Name = 'TestOpp2' limit 1];
        List<Building__c> bList = LeasingInventoryWizardController.buildingPicklistValues(u.Project__c, u.Cluster__c);
        
        Test.stopTest();
    }
    
    //Testing Method - floorPicklistValues
    @isTest
    public static void floorPicklistValuesTest() {
        Test.startTest();
        
        Unit__c u = new Unit__c();
        u = [select Id, Project__c, Cluster__c, Floor__c from Unit__c where Opportunity__r.Name = 'TestOpp2' limit 1];
        List<Floor__c> fList = LeasingInventoryWizardController.floorPicklistValues(u.Project__c, u.Cluster__c, null);
        
        Test.stopTest();
    }
    
    //Testing Method - generateBookingForSelectedUnits
    @isTest
    public static void generateBookingForSelectedUnitsTest() {
        Test.startTest();
        
        try{
        Unit__c u = new Unit__c();
        u = [select Id, Name, Project__c, Cluster__c, Floor__c from Unit__c where Opportunity__r.Name = 'TestOpp2' limit 1];
        List<LeasingInventoryWizardController.UnitDetailsWrapper> uWrapList = new List<LeasingInventoryWizardController.UnitDetailsWrapper>();
        LeasingInventoryWizardController.UnitDetailsWrapper uWrap = new LeasingInventoryWizardController.UnitDetailsWrapper();
        uWrap.Id = u.Id;
        uWrap.Name = u.Name;
        uWrapList.add(uWrap);
        String wrapJson = json.serialize(uWrapList);
        String result = LeasingInventoryWizardController.generateBookingForSelectedUnits(wrapJson,u.Project__c,'resedential',String.valueOf(System.today()));
        } catch(Exception e){}
        
        Test.stopTest();
    }
    
    //Testing Method - createLeaseOfferRecords
    @isTest
    public static void createLeaseOfferRecordsTest() {
        Test.startTest();
        
        Unit__c u = new Unit__c();
        u = [select Id, Name, Project__c, Cluster__c, Floor__c from Unit__c where Opportunity__r.Name = 'TestOpp2' limit 1];
        List<LeasingInventoryWizardController.UnitDetailsWrapper> uWrapList = new List<LeasingInventoryWizardController.UnitDetailsWrapper>();
        LeasingInventoryWizardController.UnitDetailsWrapper uWrap = new LeasingInventoryWizardController.UnitDetailsWrapper();
        uWrap.Id = u.Id;
        uWrap.Name = u.Name;
        uWrapList.add(uWrap);
        String wrapJson = json.serialize(uWrapList);
        String emailList = '["test0@email.sf","test1@email.sf"]';
        String result = LeasingInventoryWizardController.createLeaseOfferRecords(wrapJson,emailList);
        
        emailList = '{["test0@email.sf","test1@email.sf"]}';
        result = LeasingInventoryWizardController.createLeaseOfferRecords(wrapJson,emailList);
        
        Test.stopTest();
    }
}