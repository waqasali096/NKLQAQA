/****************************************************************************************************************************
* @Name         UnitControllerTest
* @Author       Kaustubh Abhyankar
* @Date         05-May-2022
* @Description  Test Class for UnitController
****************************************************************************************************************************/

@isTest
public class UnitControllerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        insert new Add_Unit_Status_Settings__c(Name = 'Quick_Book', Opportunity_Status__c = 'Choose Units');
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
        String oppQBRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Quick_Book').RecordTypeId;
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
        
        opp = new Opportunity();
        opp.Name = 'TestOpp1';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = true;
        opp.RecordTypeId = oppQBRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.Business_Unit__c = buList[0].Id;
        //opp.Project__c = pList[0].Id;
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//1
        
        insert oppList;
        
        Business_Group__c bg = new Business_Group__c();
        insert bg;
        
        List<Business_Unit__c> buList = new List<Business_Unit__c>();
        Business_Unit__c bu = new Business_Unit__c();
        bu.Business_Group__c = bg.Id;
        buList.add(bu);
        
        insert buList;
        
        List<Project__c> pList = new List<Project__c>();
        Project__c p = new Project__c();
        p.Business_Unit__c = buList[0].Id;
        p.Business_Group__c = bg.Id;
        p.Project_Purpose__c = 'Sales';
        pList.add(p);
        
        insert pList;
        
        List<Cluster__c> cList = new List<Cluster__c>();
        Cluster__c c = new Cluster__c();
        c.Business_Group__c = bg.Id;
        c.Business_Unit__c = buList[0].Id;
        c.Project__c = pList[0].Id;
        c.Cluster_Purpose__c = 'Sales';
        cList.add(c);
        
        insert cList;
        
        List<Building__c> bList = new List<Building__c>();
        Building__c b = new Building__c();
        b.Business_Group__c = bg.Id;
        b.Business_Unit__c = buList[0].Id;
        b.Project__c = pList[0].Id;
        b.Cluster__c = cList[0].Id;
        b.Building_Purpose__c = 'Sales';
        bList.add(b);
        
        insert bList;
        
        List<Floor__c> fList = new List<Floor__c>();
        Floor__c f = new Floor__c();
        f.Business_Group__c = bg.Id;
        f.Business_Unit__c = buList[0].Id;
        f.Project__c = pList[0].Id;
        f.Cluster__c = cList[0].Id;
        f.Building__c = bList[0].Id;
        fList.add(f);
        
        insert fList;
        
        Space_Type__c st = new Space_Type__c();
        
        insert st;
        
        Unit_Theme__c ut = new Unit_Theme__c();
        
        insert ut;
        
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
        u.Unit_Purpose__c = 'Sales';
        u.Unit_Code__c = 'U-123';
        u.Active_Deal__c = oppList[0].Id;
        //u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        u.Unit_Prebooked__c = false;
        u.Space_Types__c = st.Id;
        u.Space_Type__c = '1 BR';
        u.No_of_Bedrooms__c = '1';
        u.Architectural_Type__c = 'Type A';
        u.Property_Unit_View__c = 'Building View';
        u.Unit_type__c = 'Apartment';
        u.Unit_Theme__c = ut.Id;
        u.Unit_color_option__c = 'Dark';
        u.Selling_Price__c = 1234;
        u.Total_Saleable_Area_Sqft__c = 1342;
        u.Plot_Area_Sqft__c = 1234;
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[1].Id;
        u.Holding_Deposit_Amount__c = 100;
        u.RecordTypeId = uRecType;
        u.No_of_Bedrooms__c = '1';
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[1].Id;
        u.Holding_Deposit_Amount__c = 100;
        u.RecordTypeId = uRecType;
        u.No_of_Bedrooms__c = '1';
        uList.add(u);//0
        
        insert uList;
        
        Test.stopTest();
    }
    
    //Testing Method - getUnits
    @isTest
    public static void getUnitsTest() {
        Test.startTest();
        
        Unit__c u = [select Id, Business_Unit__c, Cluster__c, Project__c, Building__c, Architectural_Type__c, Property_Unit_View__c, Space_Types__c, Unit_type__c, Unit_Theme__c, Unit_color_option__c from Unit__c where Opportunity__r.Name = 'TestOpp0' limit 1];
        UnitController.UnitWrapper uWrap = UnitController.getUnits(1, 2002, u.Id, u.Business_Unit__c, u.Cluster__c, u.Project__c, u.Building__c, '1', u.Architectural_Type__c, u.Property_Unit_View__c, u.Space_Types__c, u.Unit_type__c, u.Unit_Theme__c, u.Unit_color_option__c, 1, 99999, 1, 99999, 1, 99999, 'YES');
        uWrap = UnitController.getUnits(1, 2002, 'u.Id', null, null, null, null, '1', null, null, null, null, null, null, 1, 99999, 1, 99999, 1, 99999, 'YES');
        
        Test.stopTest();
    }
    
    
    //Testing Method - getRecordTypeCriteria
    @isTest
    public static void getRecordTypeCriteriaTest() {
        Test.startTest();
        
        String leadSales = Schema.SObjectType.Lead.RecordTypeInfosByDeveloperName.get('Sales_Lead').RecordTypeId;
        String leadResSalesU = Schema.SObjectType.Lead.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit').RecordTypeId;
        //String leadResSalesS = Schema.SObjectType.Lead.RecordTypeInfosByName.get('Residential_Leasing_Shop').RecordTypeId;//Residential Leasing Shop
        
        List<Lead> lList = new List<Lead>();
        Lead l = new Lead();
        l.LastName = 'TestLead0';
        l.RecordTypeId = leadSales;
        lList.add(l);
        
        insert lList;
        
        String result = UnitController.getRecordTypeCriteria(lList[0].Id, '');
        
        Test.stopTest();
    }
    
    //Testing Method - addUnitstoOpp
    @isTest
    public static void addUnitstoOppTest() {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName  = 'TestLead1';
        insert l;
        
        Account acc = [select Id, Name from Account where Name = 'TestAccount0' limit 1];
        List<Unit__c> uList = [select Id, Name, Opportunity__c, No_of_Bedrooms__c, DLD_Customer_Share__c, Unit_Type__c, Unit_Theme__c, project__c, Cluster__c, Building__c, Master_Payment_Plan__c, Space_Types__c from Unit__c where Holding_Deposit_Amount__c = 100];
        NKLResponse nkl = UnitController.addUnitstoOpp(acc.Id, uList, 'Account');
        
        nkl = UnitController.addUnitstoOpp(uList[0].Opportunity__c, uList, 'Opportunity');
        nkl = UnitController.addUnitstoOpp(l.Id, uList, 'Lead');
        
        Test.stopTest();
    }
    
    //Testing Method - addUnitstoQuickBookingOpp
    @isTest
    public static void addUnitstoQuickBookingOppTest() {
        Test.startTest();
        
        List<Unit__c> uList = [select Id, Name, Opportunity__c, No_of_Bedrooms__c, DLD_Customer_Share__c, Unit_Type__c, Unit_Theme__c, Unit_Status__c, project__c, Cluster__c, Building__c, Master_Payment_Plan__c, Space_Types__c from Unit__c where Holding_Deposit_Amount__c = 100];        
        NKLResponse nkl = UnitController.addUnitstoQuickBookingOpp(uList[0].Opportunity__c, uList, 'Opportunity');
        
        Test.stopTest();
    }
    
    //Testing Method - removeSelectedUnits
    @isTest
    public static void removeSelectedUnitsTest() {
        Test.startTest();
        
        List<Unit__c> uList2 = [select Id, Name, Opportunity__c, No_of_Bedrooms__c, DLD_Customer_Share__c, Unit_Type__c, Unit_Theme__c, Unit_Status__c, project__c, Cluster__c, Building__c, Master_Payment_Plan__c, Space_Types__c from Unit__c where Holding_Deposit_Amount__c = 100];        
        Boolean result = UnitController.removeSelectedUnits(uList2, uList2[0].Opportunity__c);
        
        Test.stopTest();
    }
    
    //Testing Method - getExistingUnits
    @isTest
    public static void getExistingUnitsTest() {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName  = 'TestLead1';
        insert l;
        
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
        String oppQBRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Quick_Book').RecordTypeId;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp0';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = true;
        opp.RecordTypeId = oppQBRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.Business_Unit__c = buList[0].Id;
        //opp.Project__c = pList[0].Id;
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Holding_Deposit_Amount__c = 200;
        u.RecordTypeId = uRecType;
        u.No_of_Bedrooms__c = '1';
        uList.add(u);//0
        
        insert uList;
        
        Opportunity copp = new Opportunity();
        copp.Name = 'TestOpp0';
        copp.StageName = 'New';
        copp.CloseDate = System.today();
        copp.Booking_Amount__c = 100;
        copp.Booking_Mode__c = 'Reservation without token amount';
        copp.Security_Deposit_Recevied__c = true;
        copp.Booking_Form_Generated__c = true;
        copp.RecordTypeId = oppQBRecType;
        copp.Lease_End_Date__c = Date.today() + 5;
        copp.Leasing_Type__c = 'Residential Units';
        copp.Loss_Reason__c = 'Test Reason';
        copp.Opportunity__c = oppList[0].Id;
        copp.Unit__c = uList[0].Id;
        
        insert copp;
        
        UnitController.ResultWrapper rWrap = UnitController.getExistingUnits(acc.Id, 'Account');
        rWrap = UnitController.getExistingUnits(copp.Id, 'Opportunity');
        rWrap = UnitController.getExistingUnits(l.Id, 'Lead');
        
        Test.stopTest();
    }
    
    //Testing Method - getTypes
    @isTest
    public static void getTypesTest() {
        Test.startTest();
        
        Map<String, String> strMap = UnitController.getTypes();
        
        Test.stopTest();
    }
    
    //Testing Method - getUnitSalesStatus
    @isTest
    public static void getUnitSalesStatusTest() {
        Test.startTest();
        
        Map<String, String> strMap = UnitController.getUnitSalesStatus();
        
        Test.stopTest();
    }
    
    //Testing Method - getNumberofBedroomsOptions
    @isTest
    public static void getNumberofBedroomsOptionsTest() {
        Test.startTest();
        
        Map<String, String> strMap = UnitController.getNumberofBedroomsOptions();
        
        Test.stopTest();
    }
    
    //Testing Method - getSpaceType
    @isTest
    public static void getSpaceTypeTest() {
        Test.startTest();
        
        Map<String, String> strMap = UnitController.getSpaceType();
        
        Test.stopTest();
    }
    
    //Testing Method - getUnitType
    @isTest
    public static void getUnitTypeTest() {
        Test.startTest();
        
        Map<String, String> strMap = UnitController.getUnitType();
        
        Test.stopTest();
    }
    
    //Testing Method - getUnitColor
    @isTest
    public static void getUnitColorTest() {
        Test.startTest();
        
        Map<String, String> strMap = UnitController.getUnitColor();
        
        Test.stopTest();
    }
    
    //Testing Method - getUnitTheme
    @isTest
    public static void getUnitThemeTest() {
        Test.startTest();
        
        Map<String, String> strMap = UnitController.getUnitTheme();
        
        Test.stopTest();
    }
    
    //Testing Method - getUnitTypeGroupOptions
    @isTest
    public static void getUnitTypeGroupOptionsTest() {
        Test.startTest();
        
        Map<String, String> strMap = UnitController.getUnitTypeGroupOptions();
        
        Test.stopTest();
    }
    
    //Testing Method - getPropertyUnitViewOptions
    @isTest
    public static void getPropertyUnitViewOptionsTest() {
        Test.startTest();
        
        Map<String, String> strMap = UnitController.getPropertyUnitViewOptions();
        
        Test.stopTest();
    }
    
    //Testing Method - getPicklistValues
    @isTest
    public static void getPicklistValuesTest() {
        Test.startTest();
        
        Map<String, String> strMap = UnitController.getPicklistValues('Unit__c', 'Unit_Status__c');
        
        Test.stopTest();
    }
    
    //Testing Method - getProjects
    @isTest
    public static void getProjectsTest() {
        Test.startTest();
        
        Map<String, String> strMap = UnitController.getProjects();
        
        Test.stopTest();
    }
}