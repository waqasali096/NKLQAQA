/****************************************************************************************************************************
* @Name         QuickBookTimerControllerTest
* @Author       Kaustubh Abhyankar
* @Date         27-April-2022
* @Description  Test Class for QuickBookTimerController
****************************************************************************************************************************/

@isTest
public class QuickBookTimerControllerTest {
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
        
        acc = new Account();
        acc.Name = 'TestAccount1';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accBizRecType;
        accList.add(acc);//1
        
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
        
        String oppRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
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
        
        opp = new Opportunity();
        opp.Name = 'ParentOpp';
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
        oppList.add(opp);//1
        
        opp = new Opportunity();
        opp.Name = 'TestOpp1';
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
        opp.AccountId = accList[1].Id;
        oppList.add(opp);//2
        
        insert oppList;
        
        List<Cluster__c> cList = new List<Cluster__c>();
        Cluster__c c = new Cluster__c();
        c.Business_Group__c = bg.Id;
        c.Business_Unit__c = buList[0].Id;
        c.Project__c = pList[0].Id;
        c.Cluster_Purpose__c = 'Leasing';
        cList.add(c);
        
        insert cList;
        
        List<Building__c> bList = new List<Building__c>();
        Building__c b = new Building__c();
        b.Business_Group__c = bg.Id;
        b.Business_Unit__c = buList[0].Id;
        b.Project__c = pList[0].Id;
        b.Cluster__c = cList[0].Id;
        b.Building_Purpose__c = 'Leasing';
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
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[0].Id;
        u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[1].Id;
        u.Business_Group__c = bg.Id;
        u.Business_Unit__c = buList[0].Id;
        u.Project__c = pList[0].Id;
        u.Cluster__c = cList[0].Id;
        u.Building__c = bList[0].Id;
        u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Booked';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[1].Id;
        u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        u.Unit_Style__c = us.Id;
        u.Unit_Theme__c = ut.Id;
        u.Space_Types__c = st.Id;
        u.Selling_Price__c = 12312;
        uList.add(u);//1
        
        insert uList;
        
        List<Opportunity> childOpp = new List<Opportunity>();
        opp = new Opportunity();
        opp.Name = 'ChildOpp1';
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
        opp.Opportunity__c = oppList[0].Id;
        opp.Unit__c = uList[0].Id;
        opp.Token_Amount__c = 123;
        childOpp.add(opp);
        
        opp = new Opportunity();
        opp.Name = 'ChildOpp2';
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
        opp.Opportunity__c = oppList[1].Id;
        opp.Unit__c = uList[1].Id;
        opp.Token_Amount__c = 123;
        childOpp.add(opp);
        
        insert childOpp;
        
        List<Opportunity_Charges__c> opcList = new List<Opportunity_Charges__c>();
        Opportunity_Charges__c opc = new Opportunity_Charges__c();
        opc.Opportunity__c = childOpp[0].Id;
        opc.Amount__c = 123;
        opcList.add(opc);
        
        opc = new Opportunity_Charges__c();
        opc.Opportunity__c = childOpp[1].Id;
        opc.Amount__c = 123;
        opcList.add(opc);
        
        insert opcList;
        
        Joint_Buyer__c jb = new Joint_Buyer__c();
        jb.Primary_Account__c = accList[1].Id;
        jb.Opportunity__c = oppList[2].Id;
        jb.Unit__c = uList[0].Id;
        insert jb;
        
        Test.stopTest();
    }
    
    //Testing Methods - fetchQuickBookCloseDate & fetchCheckBookingFormGenerated & checkAccountExists
    @isTest
    public static void MethodsTest1() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name from Opportunity where Name = 'TestOpp0' limit 1];
        DateTime result1 = QuickBookTimerController.fetchQuickBookCloseDate(opp.Id);
        Boolean result2 = QuickBookTimerController.fetchCheckBookingFormGenerated(opp.Id);
        String result3 = QuickBookTimerController.checkAccountExists(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - getExistingUnits
    @isTest
    public static void getExistingUnitsTest() {
        Test.startTest();
        
        String oppRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
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
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        Unit__c u = new Unit__c();
        u.Opportunity__c = opp.Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Available';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = opp.Id;
        u.Handover_Status__c = 'Handover Completed';
        
        insert u;
        
        QuickBookTimerController.ResultWrapper rWrap = QuickBookTimerController.getExistingUnits(opp.Id);
        
        opp.Unit__c = u.Id;
        update opp;
        
        rWrap = QuickBookTimerController.getExistingUnits(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - createChildOpps
    @isTest
    public static void createChildOppsTest() {
        Test.startTest();
        
        Unit__c u = new Unit__c();
        u = [select Id, Name, Opportunity__c, Opportunity__r.Name from Unit__c where Opportunity__r.Name = 'TestOpp0' limit 1];
        
        List<QuickBookTimerController.ResultWrapper> rWrapList = new List<QuickBookTimerController.ResultWrapper>();
        QuickBookTimerController.ResultWrapper rWrap = new QuickBookTimerController.ResultWrapper();
        rWrap.oppName = null;
        rWrap.oppId = null;
        rWrap.hasUnit = false;
        rWrap.isBooked = false;
        rWrap.unitAdded = false;
        rWrap.preBooked = false;
        rWrap.preBookedBy = null;
        rWrap.prebookingTime = null;
        rWrap.recordTypeName = null;
        rWrap.unitId = u.Id;
        rWrap.oppStatus = null;
        rWrap.unitName = 'null';
        rWrap.unitThemeId = null;
        rWrap.locationCode = null;
        rWrap.building = null;
        rWrap.unitType = null;
        rWrap.unitStyle = null;
        rWrap.unitTheme = null;
        rWrap.usableArea = null;
        rWrap.unitStatus = null;
        rWrap.bedroom = null;
        rWrap.bedroomId = null;
        rWrap.project = null;
        rWrap.cluster = null;
        rWrap.masterPaymentPlanId = null;
        rWrap.masterPaymentPlanName = null;
        rWrap.sellingPrice = 12;
        rWrap.optionsPrice = 12;
        rWrap.chargesPrice = 12;
        rWrap.netPrice = 12;
        rWrap.tokenAmount = 12;
        rWrap.tokenStatus = null;
        rWrap.salesType = null;
        rWrap.dldShare = 12;
        rWrap.clusterId = null;
        rWrap.businessUnit = null;
        rWrap.businessUnitId = null;
        rWrap.ownerId = null;
        rWrap.primaryAccId = null;
        rWrap.joCount = 12;
        rWrap.addressList = null;
        rWrap.accId = null;
        rWrap.accounts = null;
        rWrapList.add(rWrap);
        
        QuickBookTimerController.ParentWrapper pWrap = QuickBookTimerController.createChildOpps(u.Opportunity__c, rWrapList);
        
        Test.stopTest();
    }
    
    //Testing Method - getChildOpps
    @isTest
    public static void getChildOppsTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name from Opportunity where Name = 'ParentOpp' limit 1];
        QuickBookTimerController.ParentWrapper pWrap = QuickBookTimerController.getChildOpps(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - bookUnits & removeChildOpps & addtoSalesOffer & updateSalesType & getOptionsPrice & getAccountDetails
    @isTest
    public static void MethodsTest2() {
        Test.startTest();
        
        Joint_Buyer__c jb = new Joint_Buyer__c();
        jb = [select Id, Name, Opportunity__c, Opportunity__r.Name, Opportunity__r.AccountId, Unit__c, Unit__r.Name from Joint_Buyer__c limit 1];
        
        List<QuickBookTimerController.ResultWrapper> rWrapList = new List<QuickBookTimerController.ResultWrapper>();
        QuickBookTimerController.ResultWrapper rWrap = new QuickBookTimerController.ResultWrapper();
        rWrap.oppId = jb.Opportunity__c;
        rWrap.unitId = jb.Unit__c;
        rWrap.unitName = jb.Unit__r.Name;
        rWrap.salesType = null;
        rWrapList.add(rWrap);
        
        QuickBookTimerController.ParentWrapper pWrap = QuickBookTimerController.bookUnits(jb.Opportunity__c, rWrapList);
        Boolean result = QuickBookTimerController.removeChildOpps(rWrapList);
        result = QuickBookTimerController.addtoSalesOffer(rWrapList);
        result = QuickBookTimerController.updateSalesType(rWrap);
        Decimal res = QuickBookTimerController.getOptionsPrice(jb.Opportunity__c, false);
        Map<String, String> strMap = QuickBookTimerController.getPicklistValues('Unit__c', 'Unit_Status__c');
        
        Opportunity opp = new Opportunity();
        opp = [select Id, AccountId from Opportunity where Name = 'ChildOpp2' limit 1];
        QuickBookTimerController.ResultWrapper rWrap2 = QuickBookTimerController.getAccountDetails(opp.AccountId, null);
        rWrap2 = QuickBookTimerController.getAccountDetails(null, opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - getBookingForm
    @isTest
    public static void getBookingFormTest() {
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
        
        insert oppList;
        
        List<Document__c> dList = new List<Document__c>();
        Document__c d = new Document__c();
        d.Opportunity__c = oppList[0].Id;
        d.Attachment_Id__c = 'TestATT';
        d.Document_Type__c = 'Booking Form';
        dList.add(d);
        
        d = new Document__c();
        d.Opportunity__c = oppList[1].Id;
        d.Document_Type__c = 'Booking Form';
        dList.add(d);
        
        insert dList;
        
        QuickBookTimerController.ParentWrapper pWrap = QuickBookTimerController.getBookingForm(oppList[0].Id);
        pWrap = QuickBookTimerController.getBookingForm(oppList[1].Id);
        
        Test.stopTest();
    }
}