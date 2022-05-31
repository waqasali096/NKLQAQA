/****************************************************************************************************************************
* @Name         ScheduleAmendmentControllerTest
* @Author       Kaustubh Abhyankar
* @Date         14-April-2022
* @Description  Test Class for ScheduleAmendmentController
****************************************************************************************************************************/
@isTest
public class ScheduleAmendmentControllerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        Test.startTest();
        
        String recordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp1';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = recordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Booking_Fee_gets_collected__c = false;
        oppList.add(opp);//0
        
        opp = new Opportunity();
        opp.Name = 'TestOpp2';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = recordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Booking_Fee_gets_collected__c = true;
        oppList.add(opp);//1
        
        opp = new Opportunity();
        opp.Name = 'TestOpp3';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = recordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Booking_Fee_gets_collected__c = true;
        oppList.add(opp);//2
        
        opp = new Opportunity();
        opp.Name = 'TestOpp4';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = recordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Booking_Fee_gets_collected__c = false;
        oppList.add(opp);//3
        
        insert oppList;
        
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Security_Deposit__c = 1313;
        u.Discount__c = 123;
        u.Price_Per_SQ_FT__c = 21313;
        u.Total_Leasable_Area__c = 123;
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[1].Id;
        u.Security_Deposit__c = 1313;
        u.Discount__c = 123;
        u.Price_Per_SQ_FT__c = 21313;
        u.Total_Leasable_Area__c = 123;
        uList.add(u);//1
        
        u = new Unit__c();
        u.Opportunity__c = oppList[3].Id;
        u.Security_Deposit__c = 1313;
        u.Discount__c = 123;
        u.Price_Per_SQ_FT__c = 21313;
        u.Total_Leasable_Area__c = 123;
        uList.add(u);//2
        
        insert uList;
        
        Unit_Plan__c up = new Unit_Plan__c();
        up.Opportunity__c = oppList[1].Id;
        insert up;
        
        List<Additional_Charges__c> acList = new List<Additional_Charges__c>();
        Additional_Charges__c ac = new Additional_Charges__c();
        ac.Unit__c = uList[0].Id;
        acList.add(ac);//0
        
        ac = new Additional_Charges__c();
        ac.Unit__c = uList[1].Id;
        acList.add(ac);//1
        
        ac = new Additional_Charges__c();
        ac.Unit__c = uList[2].Id;
        acList.add(ac);//2
        
        insert acList;
        
        List<Opportunity_Charges__c> ocList = new List<Opportunity_Charges__c>();
        Opportunity_Charges__c oc = new Opportunity_Charges__c();
        oc.Opportunity__c = oppList[0].Id;
        oc.Payable_Amount__c = 122;
        ocList.add(oc);//0
        
        oc = new Opportunity_Charges__c();
        oc.Opportunity__c = oppList[1].Id;
        oc.Payable_Amount__c = 122;
        ocList.add(oc);//1
        
        oc = new Opportunity_Charges__c();
        oc.Opportunity__c = oppList[3].Id;
        oc.Payable_Amount__c = 122;
        ocList.add(oc);//1
        
        insert ocList;
        
        List<Schedule_Amendment__c> saList = new List<Schedule_Amendment__c>();
        Schedule_Amendment__c sa = new Schedule_Amendment__c();
        sa.Opportunity__c = oppList[0].Id;
        sa.Additional_Charges__c = ocList[0].Id;
        sa.Payment_Mode__c = 'cash';
        sa.Proposed_Amount__c = 321;
        sa.Installment__c = 'Holding Deposit';
        saList.add(sa);//0
        
        sa = new Schedule_Amendment__c();
        sa.Opportunity__c = oppList[0].Id;
        sa.Additional_Charges__c = ocList[0].Id;
        sa.Payment_Mode__c = 'cash';
        sa.Proposed_Amount__c = 321;
        sa.Installment__c = 'Holding Deposit';
        saList.add(sa);//1
        
        insert saList;
        
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        Payment_Milestone__c pm = new Payment_Milestone__c();
        pm.Opportunity__c = oppList[0].Id;
        pm.Unit__c = uList[0].Id;
        pm.Payable_Amount__c = 12;
        pmList.add(pm);//0
        
        pm = new Payment_Milestone__c();
        pm.Opportunity__c = oppList[1].Id;
        pm.Unit__c = uList[1].Id;
        pm.Payable_Amount__c = 12;
        pmList.add(pm);//1
        
        pm = new Payment_Milestone__c();
        pm.Opportunity__c = oppList[3].Id;
        pm.Unit__c = uList[2].Id;
        pm.Payable_Amount__c = 12;
        pmList.add(pm);//2
        
        insert pmList;
        
        Business_Unit__c bu = new Business_Unit__c();
        insert bu;
        
        Receipt_Method__c rm = new Receipt_Method__c();
        rm.Business_Unit__c = bu.Id;
        rm.Bank_Branch_ID__c  = 'TestBank1';
        insert rm;
        
        System.debug('===============End Of Data Setup===============');
        
        Test.stopTest();
    }
    
    //Testing method - getInstallments
    @isTest
    public static void getInstallmentsTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name from Opportunity where Name = 'TestOpp2' limit 1];
        ScheduleAmendmentController.ParentWrapper pWrap = ScheduleAmendmentController.getInstallments(opp.Id);
        
        opp = new Opportunity();
        opp = [select Id, Name from Opportunity where Name = 'TestOpp3' limit 1];
        
        List<Aggregated_Milestone__c> amList = new List<Aggregated_Milestone__c>();
        Aggregated_Milestone__c am = new Aggregated_Milestone__c();
        am.Deal__c = opp.Id;
        am.IsAdditionalCharges__c = true;
        am.Installment__c = '01-JGE';
        am.Amount__c = 123;
        amList.add(am);
        
        am = new Aggregated_Milestone__c();
        am.Deal__c = opp.Id;
        am.IsAdditionalCharges__c = false;
        am.Amount__c = 123;
        amList.add(am);
        
        insert amList;
        pWrap = ScheduleAmendmentController.getInstallments(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing method - getScheduleAmendments
    @isTest
    public static void getScheduleAmendmentsTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name from Opportunity where Name = 'TestOpp1' limit 1];
        ScheduleAmendmentController.ParentWrapper pWrap = ScheduleAmendmentController.getScheduleAmendments(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing method - createScheduleAmendments
    @isTest
    public static void createScheduleAmendmentsTest() {
        Test.startTest();
        
        Id opp1, opp2, opp4, u1, u2, u3, pm1, pm2, pm3, ac1, ac2, ac3, oc1, oc2, oc3;
        
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        pmList = [select Id, Name, Opportunity__c, Opportunity__r.Name, Unit__c from Payment_Milestone__c];
        for(Payment_Milestone__c pm : pmList) {
            if(pm.Opportunity__r.Name == 'TestOpp1') {
                pm1 = pm.Id;
                opp1 = pm.Opportunity__c;
                u1 = pm.Unit__c;
            }
            if(pm.Opportunity__r.Name == 'TestOpp2') {
                pm2 = pm.Id;
                opp2 = pm.Opportunity__c;
                u2 = pm.Unit__c;
            }
            if(pm.Opportunity__r.Name == 'TestOpp4') {
                pm3 = pm.Id;
                opp4 = pm.Opportunity__c;
                u3 = pm.Unit__c;
            }
        }
        
        List<Additional_Charges__c> acList = new List<Additional_Charges__c>();
        acList = [select Id, Name, Unit__r.Opportunity__r.Name from Additional_Charges__c];
        for(Additional_Charges__c ac : acList) {
            if(ac.Unit__r.Opportunity__r.Name == 'TestOpp1') {
                ac1 = ac.Id;
            }
            if(ac.Unit__r.Opportunity__r.Name == 'TestOpp2') {
                ac2 = ac.Id;
            }
            if(ac.Unit__r.Opportunity__r.Name == 'TestOpp4') {
                ac3 = ac.Id;
            }
        }
        
        List<Opportunity_Charges__c> ocList = new List<Opportunity_Charges__c>();
        ocList = [select Id, Name, Opportunity__r.Name from Opportunity_Charges__c];
        for(Opportunity_Charges__c oc : ocList) {
            if(oc.Opportunity__r.Name == 'TestOpp1') {
                oc1 = oc.Id;
            }
            if(oc.Opportunity__r.Name == 'TestOpp2') {
                oc2 = oc.Id;
            }
            if(oc.Opportunity__r.Name == 'TestOpp4') {
                oc3 = oc.Id;
            }
        }
        
        List<ScheduleAmendmentController.AdjustmentWrapper> adWrapList = new List<ScheduleAmendmentController.AdjustmentWrapper>();
        ScheduleAmendmentController.AdjustmentWrapper adWrap = new ScheduleAmendmentController.AdjustmentWrapper();
        adWrap.id = '';
        adWrap.value = '';
        adWrapList.add(adWrap);
        
        List<ScheduleAmendmentController.ResultWrapper> resWrapList = new List<ScheduleAmendmentController.ResultWrapper>();
        ScheduleAmendmentController.ResultWrapper resWrap = new ScheduleAmendmentController.ResultWrapper();
        resWrap.adjustedTo = 'Test';
        resWrap.chequeNo = '';
        resWrap.ischarges = true;
        resWrap.isSecurityDeposit = '';
        resWrap.itemDesValue = '';
        resWrap.paymentTermType = '';
        resWrap.isReceiptCreated = true;
        resWrap.itemDescription = '';
        resWrap.paymentMode = '';
        resWrap.dueDate = System.today() + 5;
        resWrap.amount = 21;
        resWrap.vatAmount = 21;
        resWrap.totalAmount = 21;
        resWrap.proposedAmount = 21;
        resWrap.proposedDate = System.today();
        resWrap.allocate = true;
        resWrap.allocateComments = '';
        resWrap.isSplit = true;
        resWrap.oppId = opp1;
        resWrap.paymentMilestoneId = pm1;
        resWrap.additionalChargesId = oc1;
        resWrap.recordId = '';
        resWrap.isRemove = '';
        resWrap.bankName = '';
        resWrap.bankCity = '';
        resWrap.bankBranch = '';
        resWrap.bankCountry = '';
        resWrap.isBank = true;
        resWrap.businessUnit = '';
        resWrap.unitCode = '';
        resWrap.unitId = u1;
        resWrap.allocatedInstallmentId = '';
        resWrap.proposedThresholdDate = System.today();
        resWrap.isDisableProposedDate = true;
        resWrap.remarks = '';
        resWrap.collectedAmount = '';
        resWrapList.add(resWrap);
        
        
        Map<String,String> bankMap = new Map<String,String>();
        Map<String,String> paymentOptions = new Map<String,String>();
        
        
        ScheduleAmendmentController.ParentWrapper pWrap  = new ScheduleAmendmentController.ParentWrapper();
        pWrap.oppId = opp1;
        pWrap.bankBranchId = '';
        pWrap.buId = '';
        pWrap.totalAmount = 0;
        pWrap.isEdit = true;
        pWrap.resultWrapperList = resWrapList;
        pWrap.proposedThresholdDays = 123;
        pWrap.isBooking = true;
        pWrap.bookingWrapper = resWrap;
        pWrap.adjustmentList = adWrapList;
        pWrap.bankMap = bankMap;
        pWrap.paymentOptions = paymentOptions;
        
        ScheduleAmendmentController.createScheduleAmendments(pWrap, true, false);
        pWrap.isBooking = false;
        ScheduleAmendmentController.createScheduleAmendments(pWrap, true, false);
        
        
        resWrapList = new List<ScheduleAmendmentController.ResultWrapper>();
        resWrap = new ScheduleAmendmentController.ResultWrapper();
        resWrap.adjustedTo = 'Test';
        resWrap.chequeNo = '';
        resWrap.ischarges = true;
        resWrap.isSecurityDeposit = '';
        resWrap.itemDesValue = '';
        resWrap.paymentTermType = '';
        resWrap.isReceiptCreated = true;
        resWrap.itemDescription = '';
        resWrap.paymentMode = '';
        resWrap.dueDate = System.today() + 5;
        resWrap.amount = 21;
        resWrap.vatAmount = 21;
        resWrap.totalAmount = 21;
        resWrap.proposedAmount = 21;
        resWrap.proposedDate = System.today();
        resWrap.allocate = true;
        resWrap.allocateComments = '';
        resWrap.isSplit = true;
        resWrap.oppId = opp2;
        resWrap.paymentMilestoneId = pm2;
        resWrap.additionalChargesId = oc2;
        resWrap.recordId = '';
        resWrap.isRemove = '';
        resWrap.bankName = '';
        resWrap.bankCity = '';
        resWrap.bankBranch = '';
        resWrap.bankCountry = '';
        resWrap.isBank = true;
        resWrap.businessUnit = '';
        resWrap.unitCode = '';
        resWrap.unitId = u2;
        resWrap.allocatedInstallmentId = '';
        resWrap.proposedThresholdDate = System.today();
        resWrap.isDisableProposedDate = true;
        resWrap.remarks = '';
        resWrap.collectedAmount = '';
        resWrapList.add(resWrap);
        
        pWrap  = new ScheduleAmendmentController.ParentWrapper();
        pWrap.oppId = opp2;
        pWrap.bankBranchId = '';
        pWrap.buId = '';
        pWrap.totalAmount = 0;
        pWrap.isEdit = true;
        pWrap.resultWrapperList = resWrapList;
        pWrap.proposedThresholdDays = 123;
        pWrap.isBooking = true;
        pWrap.bookingWrapper = resWrap;
        pWrap.adjustmentList = adWrapList;
        pWrap.bankMap = bankMap;
        pWrap.paymentOptions = paymentOptions;
        
        ScheduleAmendmentController.createScheduleAmendments(pWrap, true, false);
        
        resWrapList = new List<ScheduleAmendmentController.ResultWrapper>();
        resWrap = new ScheduleAmendmentController.ResultWrapper();
        resWrap.adjustedTo = 'Test';
        resWrap.chequeNo = '';
        resWrap.ischarges = true;
        resWrap.isSecurityDeposit = '';
        resWrap.itemDesValue = '';
        resWrap.paymentTermType = '';
        resWrap.isReceiptCreated = true;
        resWrap.itemDescription = '';
        resWrap.paymentMode = '';
        resWrap.dueDate = System.today() + 5;
        resWrap.amount = 21;
        resWrap.vatAmount = 21;
        resWrap.totalAmount = 21;
        resWrap.proposedAmount = 21;
        resWrap.proposedDate = System.today();
        resWrap.allocate = true;
        resWrap.allocateComments = '';
        resWrap.isSplit = true;
        resWrap.oppId = opp4;
        resWrap.paymentMilestoneId = pm3;
        resWrap.additionalChargesId = oc3;
        resWrap.recordId = '';
        resWrap.isRemove = '';
        resWrap.bankName = '';
        resWrap.bankCity = '';
        resWrap.bankBranch = '';
        resWrap.bankCountry = '';
        resWrap.isBank = true;
        resWrap.businessUnit = '';
        resWrap.unitCode = '';
        resWrap.unitId = u3;
        resWrap.allocatedInstallmentId = '';
        resWrap.proposedThresholdDate = System.today();
        resWrap.isDisableProposedDate = true;
        resWrap.remarks = '';
        resWrap.collectedAmount = '';
        resWrapList.add(resWrap);
        
        pWrap  = new ScheduleAmendmentController.ParentWrapper();
        pWrap.oppId = opp4;
        pWrap.bankBranchId = '';
        pWrap.buId = '';
        pWrap.totalAmount = 0;
        pWrap.isEdit = true;
        pWrap.resultWrapperList = resWrapList;
        pWrap.proposedThresholdDays = 123;
        pWrap.isBooking = true;
        pWrap.bookingWrapper = resWrap;
        pWrap.adjustmentList = adWrapList;
        pWrap.bankMap = bankMap;
        pWrap.paymentOptions = paymentOptions;
        
        ScheduleAmendmentController.createScheduleAmendments(pWrap, true, false);
        
        Test.stopTest();
    }
    /*
        oppList.add(opp);//0*/
    
    @isTest
    public static void createReceiptsTest1() {
        Test.startTest();
        
        Business_Unit__c bu = new Business_Unit__c();
        insert bu;
        String recordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp1';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = recordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Booking_Fee_gets_collected__c = false;
        insert opp;
        
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = opp.Id;
        u.Security_Deposit__c = 1313;
        u.Discount__c = 123;
        u.Price_Per_SQ_FT__c = 21313;
        u.Total_Leasable_Area__c = 123;
        u.Holding_Deposit_Amount__c = 1231;
        uList.add(u);
        
        u = new Unit__c();
        u.Opportunity__c = opp.Id;
        u.Security_Deposit__c = 1313;
        u.Discount__c = 123;
        u.Price_Per_SQ_FT__c = 21313;
        u.Total_Leasable_Area__c = 123;
        u.Holding_Deposit_Amount__c = 1231;
        uList.add(u);
        
        insert uList;
        
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        Payment_Milestone__c pm = new Payment_Milestone__c();
        pm.Opportunity__c = opp.Id;
        pm.Unit__c = uList[0].Id;
        pm.Payable_Amount__c = 123123;
        pmList.add(pm);
        
        pm = new Payment_Milestone__c();
        pm.Opportunity__c = opp.Id;
        pm.Unit__c = uList[1].Id;
        pm.Payable_Amount__c = 123123;
        pmList.add(pm);
        
        insert pmList;
        
        List<Opportunity_Charges__c> ocList = new List<Opportunity_Charges__c>();
        Opportunity_Charges__c oc = new Opportunity_Charges__c();
        oc.Opportunity__c = opp.Id;
        oc.Payable_Amount__c = 122;
        ocList.add(oc);//0
        
        oc = new Opportunity_Charges__c();
        oc.Opportunity__c = opp.Id;
        oc.Payable_Amount__c = 122;
        ocList.add(oc);//1
        
        insert ocList;
        
        List<Unit_Plan__c> upList = new List<Unit_Plan__c>();
        Unit_Plan__c up = new Unit_Plan__c();
        up.Opportunity__c = opp.Id;
        up.Unit__c = uList[0].Id;
        upList.add(up);
        
        up = new Unit_Plan__c();
        up.Opportunity__c = opp.Id;
        up.Unit__c = uList[1].Id;
        //upList.add(up);
        
        insert upList;
        
        Receipt_Method__c rm = new Receipt_Method__c();
        rm.Business_Unit__c = bu.Id;
        rm.Bank_Account_Number__c = 'A101203213';
        rm.Payment_Mode__c = 'Online';
        insert rm;
        
        List<ScheduleAmendmentController.ResultWrapper> resWrapList = new List<ScheduleAmendmentController.ResultWrapper>();
        ScheduleAmendmentController.ResultWrapper resWrap = new ScheduleAmendmentController.ResultWrapper();
        resWrap.adjustedTo = 'Test';
        resWrap.chequeNo = '';
        resWrap.ischarges = true;
        resWrap.isSecurityDeposit = '';
        resWrap.itemDesValue = '';
        resWrap.paymentTermType = '';
        resWrap.isReceiptCreated = false;
        resWrap.itemDescription = '';
        resWrap.paymentMode = 'Online';
        resWrap.dueDate = System.today() + 5;
        resWrap.amount = 21;
        resWrap.vatAmount = 21;
        resWrap.totalAmount = 21;
        resWrap.proposedAmount = 21;
        resWrap.proposedDate = System.today();
        resWrap.allocate = true;
        resWrap.allocateComments = '';
        resWrap.isSplit = true;
        resWrap.oppId = opp.Id;
        //resWrap.paymentMilestoneId = '';
        //resWrap.additionalChargesId = '';
        resWrap.recordId = opp.Id;
        resWrap.isRemove = '';
        resWrap.bankName = '';
        resWrap.bankCity = '';
        resWrap.bankBranch = '';
        resWrap.bankCountry = '';
        resWrap.isBank = true;
        resWrap.businessUnit = '';
        resWrap.unitCode = '';
        resWrap.unitId = uList[0].Id;
        resWrap.allocatedInstallmentId = '';
        resWrap.proposedThresholdDate = System.today();
        resWrap.isDisableProposedDate = true;
        resWrap.remarks = '';
        resWrap.collectedAmount = '';
        resWrapList.add(resWrap);
        
        Map<String,String> bankMap = new Map<String,String>();
        Map<String,String> paymentOptions = new Map<String,String>();
        
        ScheduleAmendmentController.ParentWrapper pWrap  = new ScheduleAmendmentController.ParentWrapper();
        pWrap.oppId = opp.Id;
        pWrap.bankBranchId = 'A101203213';
        pWrap.buId = bu.Id;
        pWrap.totalAmount = 0;
        pWrap.isEdit = true;
        pWrap.resultWrapperList = resWrapList;
        pWrap.proposedThresholdDays = 123;
        pWrap.isBooking = true;
        pWrap.bookingWrapper = resWrap;
        //pWrap.adjustmentList = adWrapList;
        pWrap.bankMap = bankMap;
        pWrap.paymentOptions = paymentOptions;
        
        System.debug('===========' + resWrapList[0].isReceiptCreated);
        System.debug('===========' + resWrapList[0].paymentMode);
        System.debug('===========');
        
        Boolean result = ScheduleAmendmentController.createReceipts(pWrap, true);
        
        Test.stopTest();
    }
    
    @isTest
    public static void createReceiptsTest2() {
        Test.startTest();
        
        Business_Unit__c bu = new Business_Unit__c();
        insert bu;
        String recordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp1';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = recordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Booking_Fee_gets_collected__c = false;
        insert opp;
        
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = opp.Id;
        u.Security_Deposit__c = 1313;
        u.Discount__c = 123;
        u.Price_Per_SQ_FT__c = 21313;
        u.Total_Leasable_Area__c = 123;
        u.Holding_Deposit_Amount__c = 1231;
        uList.add(u);
        
        u = new Unit__c();
        u.Opportunity__c = opp.Id;
        u.Security_Deposit__c = 1313;
        u.Discount__c = 123;
        u.Price_Per_SQ_FT__c = 21313;
        u.Total_Leasable_Area__c = 123;
        u.Holding_Deposit_Amount__c = 1231;
        uList.add(u);
        
        insert uList;
        
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        Payment_Milestone__c pm = new Payment_Milestone__c();
        pm.Opportunity__c = opp.Id;
        pm.Unit__c = uList[0].Id;
        pm.Payable_Amount__c = 123123;
        pmList.add(pm);
        
        pm = new Payment_Milestone__c();
        pm.Opportunity__c = opp.Id;
        pm.Unit__c = uList[1].Id;
        pm.Payable_Amount__c = 123123;
        pmList.add(pm);
        
        insert pmList;
        
        List<Opportunity_Charges__c> ocList = new List<Opportunity_Charges__c>();
        Opportunity_Charges__c oc = new Opportunity_Charges__c();
        oc.Opportunity__c = opp.Id;
        oc.Payable_Amount__c = 122;
        ocList.add(oc);//0
        
        oc = new Opportunity_Charges__c();
        oc.Opportunity__c = opp.Id;
        oc.Payable_Amount__c = 122;
        ocList.add(oc);//1
        
        insert ocList;
        
        List<Unit_Plan__c> upList = new List<Unit_Plan__c>();
        Unit_Plan__c up = new Unit_Plan__c();
        up.Opportunity__c = opp.Id;
        up.Unit__c = uList[0].Id;
        upList.add(up);
        
        up = new Unit_Plan__c();
        up.Opportunity__c = opp.Id;
        up.Unit__c = uList[1].Id;
        upList.add(up);
        
        insert upList;
        
        Receipt_Method__c rm = new Receipt_Method__c();
        rm.Business_Unit__c = bu.Id;
        rm.Bank_Account_Number__c = 'A101203213';
        rm.Payment_Mode__c = 'Online';
        insert rm;
        
        List<ScheduleAmendmentController.ResultWrapper> resWrapList = new List<ScheduleAmendmentController.ResultWrapper>();
        ScheduleAmendmentController.ResultWrapper resWrap = new ScheduleAmendmentController.ResultWrapper();
        resWrap.adjustedTo = 'Test';
        resWrap.chequeNo = '';
        resWrap.ischarges = true;
        resWrap.isSecurityDeposit = '';
        resWrap.itemDesValue = '';
        resWrap.paymentTermType = '';
        resWrap.isReceiptCreated = false;
        resWrap.itemDescription = '';
        resWrap.paymentMode = 'Online';
        resWrap.dueDate = System.today() + 5;
        resWrap.amount = 21;
        resWrap.vatAmount = 21;
        resWrap.totalAmount = 21;
        resWrap.proposedAmount = 21;
        resWrap.proposedDate = System.today();
        resWrap.allocate = true;
        resWrap.allocateComments = '';
        resWrap.isSplit = true;
        resWrap.oppId = opp.Id;
        //resWrap.paymentMilestoneId = '';
        //resWrap.additionalChargesId = '';
        resWrap.recordId = opp.Id;
        resWrap.isRemove = '';
        resWrap.bankName = '';
        resWrap.bankCity = '';
        resWrap.bankBranch = '';
        resWrap.bankCountry = '';
        resWrap.isBank = true;
        resWrap.businessUnit = '';
        resWrap.unitCode = '';
        resWrap.unitId = uList[0].Id;
        resWrap.allocatedInstallmentId = '';
        resWrap.proposedThresholdDate = System.today();
        resWrap.isDisableProposedDate = true;
        resWrap.remarks = '';
        resWrap.collectedAmount = '';
        resWrapList.add(resWrap);
        
        Map<String,String> bankMap = new Map<String,String>();
        Map<String,String> paymentOptions = new Map<String,String>();
        
        ScheduleAmendmentController.ParentWrapper pWrap  = new ScheduleAmendmentController.ParentWrapper();
        pWrap.oppId = opp.Id;
        pWrap.bankBranchId = 'A101203213';
        pWrap.buId = bu.Id;
        pWrap.totalAmount = 0;
        pWrap.isEdit = true;
        pWrap.resultWrapperList = resWrapList;
        pWrap.proposedThresholdDays = 123;
        pWrap.isBooking = true;
        pWrap.bookingWrapper = resWrap;
        //pWrap.adjustmentList = adWrapList;
        pWrap.bankMap = bankMap;
        pWrap.paymentOptions = paymentOptions;
        
        System.debug('===========' + resWrapList[0].isReceiptCreated);
        System.debug('===========' + resWrapList[0].paymentMode);
        System.debug('===========');
        
        Boolean result = ScheduleAmendmentController.createReceipts(pWrap, true);
        
        Test.stopTest();
    }
}