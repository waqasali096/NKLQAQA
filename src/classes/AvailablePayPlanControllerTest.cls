/****************************************************************************************************************************
* @Name         AvailablePayPlanControllerTest
* @Author       Kaustubh Abhyankar
* @Date         13-April-2022
* @Description  Test Class for AvailablePayPlanController
****************************************************************************************************************************/

@isTest
public class AvailablePayPlanControllerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        Test.startTest();
        
        Business_Unit__c bu = new Business_Unit__c();
        bu.Name = 'Test Business unit';
        insert bu;
        
        Space_Type__c st = new Space_Type__c();
        insert st;
        
        Tax_Configuration__c tc = new Tax_Configuration__c();
        tc.Tax_Rate__c = 21;
        insert tc;
        
        Billing_Configuration__c bc = new Billing_Configuration__c();
        bc.Tax_Configuration__c = tc.Id;
        insert bc;
        
        List<Charges_Configuration__c> ccList = new List<Charges_Configuration__c>();
        Charges_Configuration__c cc = new Charges_Configuration__c();
        cc.Business_Unit__c = bu.Id;
        cc.Space_Type__c = st.Id;
        cc.Type__c = 'VILLA';
        cc.Description__c = 'Rent';
        cc.Billing_Configuration__c = bc.Id;
        ccList.add(cc);//0
        
        cc = new Charges_Configuration__c();
        cc.Business_Unit__c = bu.Id;
        cc.Space_Type__c = st.Id;
        cc.Type__c = 'VILLA';
        cc.Description__c = 'SD';
        cc.Billing_Configuration__c = bc.Id;
        ccList.add(cc);//1
        
        cc = new Charges_Configuration__c();
        cc.Business_Unit__c = bu.Id;
        cc.Space_Type__c = st.Id;
        cc.Type__c = 'VILLA';
        cc.Description__c = 'abcdefgh';
        cc.Billing_Configuration__c = bc.Id;
        ccList.add(cc);//2
        
        insert ccList;
        
        Project__c p = new Project__c();
        p.Business_Unit__c = bu.Id;
        insert p;
        
        String recordTypeId = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test-Opp-Res';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = recordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        oppList.add(opp);//0
        
        opp = new Opportunity();
        opp.Name = 'Test-Opp-Com';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = recordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Commercial Units';
        oppList.add(opp);//1
        
        opp = new Opportunity();
        opp.Name = 'OppWithPM';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = recordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Commercial Units';
        oppList.add(opp);//2
        
        opp = new Opportunity();
        opp.Name = 'TestOppNew';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation with token amount';
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = recordTypeId;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Commercial Units';
        opp.Project__c = p.Id;
        opp.Lease_Start_Date__c = System.today();
        //opp.Change_Unit__c = true;
        //opp.Do_you_want_to_be_treated_as_new_tenant__c = 'Yes';
        oppList.add(opp);//3
        
        insert oppList;
        
        Additional_Charges__c ac = new Additional_Charges__c();
        ac.Project__c = p.Id;
        ac.Type_Leasing__c = 'Charges';
        ac.Required__c = true;
        ac.Active__c = true;
        ac.Sub_Type__c = 'Leasing Commission';
        insert ac;
        
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Security_Deposit__c = 1313;
        u.Discount__c = 123;
        u.Price_Per_SQ_FT__c = 21313;
        u.Total_Leasable_Area__c = 123;
        
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Security_Deposit__c = 1313;
        u.Price_Per_SQ_FT__c = 21313;
        u.Total_Leasable_Area__c = 123;
        uList.add(u);//1
        
        u = new Unit__c();
        u.Opportunity__c = oppList[1].Id;
        u.Security_Deposit__c = 1313;
        u.Base_Rent__c = 1312;
        u.Price_Per_SQ_FT__c = 21313;
        u.Total_Leasable_Area__c = 123;
        uList.add(u);//2
        
        u = new Unit__c();
        u.Opportunity__c = oppList[3].Id;
        u.Security_Deposit__c = 1313;
        u.Price_Per_SQ_FT__c = 21313;
        u.Total_Leasable_Area__c = 123;
        uList.add(u);//3
        
        insert uList;
        
        Payment_Milestone__c pm = new Payment_Milestone__c();
        pm.Opportunity__c = oppList[2].Id;
        insert pm;
        
        List<Unit_Plan__c> upList = new List<Unit_Plan__c>();
        Unit_Plan__c up = new Unit_Plan__c();
        up.Opportunity__c = oppList[0].Id;
        up.Unit__c = uList[0].Id;
        upList.add(up);//0
        
        up = new Unit_Plan__c();
        up.Opportunity__c = oppList[0].Id;
        up.Unit__c = uList[1].Id;
        upList.add(up);//1
        
        up = new Unit_Plan__c();
        up.Opportunity__c = oppList[1].Id;
        up.Unit__c = uList[2].Id;
        upList.add(up);//2
        
        up = new Unit_Plan__c();
        up.Opportunity__c = oppList[3].Id;
        up.Unit__c = uList[3].Id;
        upList.add(up);//3
        
        insert upList;
                
        System.debug('===============End Of Data Setup===============');
        
        Test.stopTest();
    }
    
    //Testing method - calculateAmount
    @isTest
    public static void calculateAmountTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name from Opportunity where Name = 'Test-Opp-Res' limit 1];
        
        AvailablePayPlanController.calculateAmount(opp.Id, 1, 'Cheque', 21, 21);
        AvailablePayPlanController.calculateAmount(opp.Id, 1, 'Cheque', 0, 21);
        AvailablePayPlanController.calculateAmount(opp.Id, 12, 'Cheque', 0, 21);
        AvailablePayPlanController.calculateAmount(opp.Id, 0, 'Cheque', 0, 21);
        
        opp = new Opportunity();
        opp = [select Id, Name from Opportunity where Name = 'Test-Opp-Com' limit 1];
        
        AvailablePayPlanController.calculateAmount(opp.Id, 1, 'Cheque', 21, 21);
        
        Test.stopTest();
    }
    
    //Testing method - createInstallmentAndCharges
    @isTest
    public static void createInstallmentAndChargesTest() {
        Test.startTest();
        
        Opportunity opp = new Opportunity();
        opp = [select Id, Name, Project__c, Project__r.Business_Unit__c, Lease_Start_Date__c, Leasing_type__c, Unit__c,
               change_unit__c, Lease_End_Date__c, Do_you_want_to_be_treated_as_new_tenant__c, Agency_name__c
               from Opportunity where Name = 'TestOppNew' limit 1];
        
        Unit__c u = new Unit__c();
        u = [select Id, Name from Unit__c where Opportunity__c =: opp.Id limit 1];
        
        Unit_Plan__c up = new Unit_Plan__c();
        up = [select Id, Name, Unit__c from Unit_Plan__c where Opportunity__c =: opp.Id limit 1];
        
        Space_Type__c st = new Space_Type__c();
        st = [select Id, Name from Space_Type__c limit 1];
        
        List<Additional_Charges__c> chList = new List<Additional_Charges__c>();
        
        List<AvailablePayPlanController.InstallmentWrapper> insWrapList = new List<AvailablePayPlanController.InstallmentWrapper>();
        AvailablePayPlanController.InstallmentWrapper insWrap = new AvailablePayPlanController.InstallmentWrapper();
        insWrap.oppUnitId = up.Id;
        insWrap.unitId = u.Id;
        insWrap.unitType = 'VILLA';
        insWrap.spaceTypeId = st.Id;
        insWrap.deposit = 13123;
        insWrap.spaceType = 'adwd';
        insWrap.unitCode = 'adwd';
        insWrap.paymentMode = 'adwd';
        insWrap.numberOfCheques = '2';
        insWrap.employeeDiscountAmount = 123;
        insWrap.availableDiscount = 123;
        insWrap.discount = 123;
        insWrap.discountAmount = 123;
        insWrap.totalLeasableArea = 123;
        insWrap.baseLeaseAmount = 123;
        insWrap.finalBaseAmount = 123;
        insWrap.finalLeaseAmount = 123;
        insWrap.markupAmount = 123;
        insWrap.pricePerSqft = 123;
        insWrap.chargesList = chList;
        insWrap.originalFinalLeaseAmount = 123;
        insWrapList.add(insWrap);
        
        List<String> spaceTypeIdSet = new List<String>();
        spaceTypeIdSet.add(st.Id);
        
        List<String> unitTypeSet = new List<String>{'NA','VILLA', 'Terrace Home	', 'Apartment'};
        
        AvailablePayPlanController.ParentWrapper pWrap = new AvailablePayPlanController.ParentWrapper();
        pWrap.oppObj = opp;
        pWrap.installWrapperList = insWrapList;
        pWrap.totalLeaseAmount = 1212;
        pWrap.totalBaseAmount = 1312;
        pWrap.totalDiscountAmount = 211;
        pWrap.isInsCreated = false;
        pWrap.totalDepositAmount = 12;
        pWrap.spaceTypeIdSet = spaceTypeIdSet;
        pWrap.unitTypeSet = unitTypeSet;
        AvailablePayPlanController.createInstallmentAndCharges(pWrap, '1', 'Cheque', 123);
        
        Test.stopTest();
    }
    
    //Testing method - reviseInstallments
    @isTest
    public static void reviseInstallmentsTest() {
        Test.startTest();
        
        Opportunity Opp = new Opportunity();
        opp = [select Id, Name from Opportunity where Name = 'OppWithPM' limit 1];
        AvailablePayPlanController.reviseInstallments(opp.Id);
        
        Test.stopTest();
    }
}