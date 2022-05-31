/****************************************************************************************************************************
* @Name         QuickBookAddUnitControllerTest
* @Author       Kaustubh Abhyankar
* @Date         29-April-2022
* @Description  Test Class for QuickBookAddUnitController
****************************************************************************************************************************/

@isTest
public class QuickBookAddUnitControllerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        insert new Add_Unit_Status_Settings__c(Name = 'Residential_Leasing_Unit_Opportunity', Opportunity_Status__c = 'Booking Initiated');
        Test.startTest();
        
        Sales_Event__c sev = new Sales_Event__c();
        insert sev;
        
        Sales_Event_Executive__c se = new Sales_Event_Executive__c();
        se.User__c = UserInfo.getUserId();
        se.Sales_Event__c = sev.Id;
        insert se;
        
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
        p.Project_Purpose__c = 'Sales';
        pList.add(p);
        
        insert pList;
        
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
        opp.Business_Unit__c = buList[0].Id;
        //opp.Project__c = pList[0].Id;
        opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
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
        
        Unit_Style__c us = new Unit_Style__c();
        
        insert us;
        
        Unit_Theme__c ut = new Unit_Theme__c();
        
        insert ut;
        
        Space_Type__c st = new Space_Type__c();
        
        insert st;
        
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
        u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        u.Unit_Prebooked__c = false;
        u.Space_Types__c = st.Id;
        uList.add(u);//0
        
        insert uList;
        
        Sales_Event_Unit__c sevu = new Sales_Event_Unit__c();
        sevu.Sales_Event__c = sev.Id;
        sevu.Unit__c = uList[0].Id;
        insert sevu;
        
        QuickBookAddUnitController.ParentWrapper pWrap = QuickBookAddUnitController.getAvailableUnits();
        pWrap = QuickBookAddUnitController.getSearchUnits(uList[0].Project__c, uList[0].Unit_Code__c, sev.Id, uList[0].Unit_Type__c, uList[0].Building__c, st.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - checkFormGenerated
    @isTest
    public static void checkFormGeneratedTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'TestOpp0' limit 1];
        Boolean result = QuickBookAddUnitController.checkFormGenerated(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - resetUnitValues & getUnitList & getTypes & getNumberofBedroomsOptions & getSpaceType & getUnitType & getUnitColor & getUnitTheme & getUnitTypeGroupOptions & getPropertyUnitViewOptions & getProjects & fetchAccounts
    @isTest
    public static void resetUnitValuesTest() {
        Test.startTest();
        
        String oppRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        String oppQBRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Quick_Book').RecordTypeId;
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
        insert opp;
        
        Unit__c u = new Unit__c();
        u.Opportunity__c = opp.Id;
        //u.Business_Group__c = bg.Id;
        //u.Business_Unit__c = buList[0].Id;
        //u.Project__c = pList[0].Id;
        //u.Cluster__c = cList[0].Id;
        //u.Building__c = bList[0].Id;
        //u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Available';
        u.Unit_Purpose__c = 'Sales';
        u.Active_Deal__c = opp.Id;
        //u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        insert u;
        
        Opportunity copp = new Opportunity();
        copp.Name = 'TestOpp0';
        copp.StageName = 'New';
        copp.CloseDate = System.today();
        copp.Booking_Amount__c = 100;
        copp.Booking_Mode__c = 'Reservation without token amount';
        copp.Security_Deposit_Recevied__c = true;
        copp.Booking_Form_Generated__c = false;
        copp.RecordTypeId = oppQBRecType;
        copp.Lease_End_Date__c = Date.today() + 5;
        copp.Leasing_Type__c = 'Residential Units';
        copp.Loss_Reason__c = 'Test Reason';
        copp.Unit__c = u.Id;
        insert copp;
        
        QuickBookAddUnitController.ResultWrapper rWrap = QuickBookAddUnitController.resetUnitValues(u);
        Unit__c u2 = QuickBookAddUnitController.getUnitList(u.Id);
        Map<String, String> strMap = QuickBookAddUnitController.getTypes();
        strMap = QuickBookAddUnitController.getNumberofBedroomsOptions();
        strMap = QuickBookAddUnitController.getSpaceType();
        strMap = QuickBookAddUnitController.getUnitType();
        strMap = QuickBookAddUnitController.getUnitColor();
        strMap = QuickBookAddUnitController.getUnitTheme();
        strMap = QuickBookAddUnitController.getUnitTypeGroupOptions();
        strMap = QuickBookAddUnitController.getPropertyUnitViewOptions();
        strMap = QuickBookAddUnitController.getProjects();
        List<Opportunity> oppList = QuickBookAddUnitController.fetchAccounts();
        
        Test.stopTest();
    }
    
    //Testing Method - addUnitstoQuickBookingOpp
    @isTest
    public static void addUnitstoQuickBookingOppTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'TestOpp0' limit 1];
        List<Unit__c> uList = [select Id, Name, Unit_Prebooked__c, Prebooked_By__c, Time_to_Book_Unit__c, Space_Types__r.Name, DLD_Customer_Share__c, project__c, Cluster__c, Master_Payment_Plan__c from Unit__c where Opportunity__c =: opp.Id];
        QuickBookAddUnitController.ResultWrapper rWrap = QuickBookAddUnitController.addUnitstoQuickBookingOpp(opp.Id, uList, 'Opportunity');
        
        Test.stopTest();
    }
    //Testing Method - getExistingUnits
    @isTest
    public static void getExistingUnitsTest() {
        Test.startTest();
        
        String oppRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        String oppQBRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Quick_Book').RecordTypeId;
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
        insert opp;
        
        Unit__c u = new Unit__c();
        u.Opportunity__c = opp.Id;
        //u.Business_Group__c = bg.Id;
        //u.Business_Unit__c = buList[0].Id;
        //u.Project__c = pList[0].Id;
        //u.Cluster__c = cList[0].Id;
        //u.Building__c = bList[0].Id;
        //u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Available';
        u.Unit_Purpose__c = 'Sales';
        u.Active_Deal__c = opp.Id;
        //u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        insert u;
        
        Opportunity copp = new Opportunity();
        copp.Name = 'TestOpp0';
        copp.StageName = 'New';
        copp.CloseDate = System.today();
        copp.Booking_Amount__c = 100;
        copp.Booking_Mode__c = 'Reservation without token amount';
        copp.Security_Deposit_Recevied__c = true;
        copp.Booking_Form_Generated__c = false;
        copp.RecordTypeId = oppQBRecType;
        copp.Lease_End_Date__c = Date.today() + 5;
        copp.Leasing_Type__c = 'Residential Units';
        copp.Loss_Reason__c = 'Test Reason';
        copp.Unit__c = u.Id;
        insert copp;
        
        QuickBookAddUnitController.ResultWrapper rWrap = QuickBookAddUnitController.getExistingUnits(copp.Id, 'Opportunity');
        
        Test.stopTest();
    }
    
    //Testing Method - removeSelectedUnits
    @isTest
    public static void removeSelectedUnitsTest() {
        Test.startTest();
        
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
        oppList.add(opp);
        
        insert oppList;
        
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = opp.Id;
        //u.Business_Group__c = bg.Id;
        //u.Business_Unit__c = buList[0].Id;
        //u.Project__c = pList[0].Id;
        //u.Cluster__c = cList[0].Id;
        //u.Building__c = bList[0].Id;
        //u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Available';
        u.Unit_Purpose__c = 'Sales';
        u.Active_Deal__c = opp.Id;
        //u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);
        
        insert uList;
        
        Opportunity copp = new Opportunity();
        copp.Name = 'TestOpp0';
        copp.StageName = 'New';
        copp.CloseDate = System.today();
        copp.Booking_Amount__c = 100;
        copp.Booking_Mode__c = 'Reservation without token amount';
        copp.Security_Deposit_Recevied__c = true;
        copp.Booking_Form_Generated__c = false;
        copp.RecordTypeId = oppQBRecType;
        copp.Lease_End_Date__c = Date.today() + 5;
        copp.Leasing_Type__c = 'Residential Units';
        copp.Loss_Reason__c = 'Test Reason';
        copp.Unit__c = u.Id;
        insert copp;
        
        Boolean result = QuickBookAddUnitController.removeSelectedUnits(uList, oppList[0].Id);
        
        Test.stopTest();
    }
    
    //Testing Method - createSalesOffer
    @isTest
    public static void createSalesOfferTest() {
        Test.startTest();
        
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
        oppList.add(opp);
        
        insert oppList;
        
        Master_Payment_Plan__c mpp = new Master_Payment_Plan__c();
        insert mpp;
        
        Master_Payment_Milestone__c mpm = new Master_Payment_Milestone__c();
        mpm.Master_Payment_Plan__c = mpp.Id;
        mpm.Installment__c = '01-JGE';
        mpm.Due_In_Days__c = 12;
        mpm.Amount_Percentage__c = 12;
        insert mpm;
        
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = opp.Id;
        //u.Business_Group__c = bg.Id;
        //u.Business_Unit__c = buList[0].Id;
        //u.Project__c = pList[0].Id;
        //u.Cluster__c = cList[0].Id;
        //u.Building__c = bList[0].Id;
        //u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Available';
        u.Unit_Purpose__c = 'Sales';
        u.Active_Deal__c = opp.Id;
        //u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);
        
        insert uList;
        
        List<QuickBookAddUnitController.ResultWrapper> rWrapList = new List<QuickBookAddUnitController.ResultWrapper>();
        QuickBookAddUnitController.ResultWrapper rWrap = new QuickBookAddUnitController.ResultWrapper();
        rWrap.unitId = uList[0].Id;
        rWrap.unitName = uList[0].Name;
        rWrap.masterPaymentPlanId = mpp.Id;
        rWrapList.add(rWrap);
        
        QuickBookAddUnitController.ParentWrapper pWrap = QuickBookAddUnitController.createSalesOffer(String.valueOf(JSON.serialize(rWrapList)));
        
        Test.stopTest();
    }
}