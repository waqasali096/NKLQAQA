/****************************************************************************************************************************
* @Name         unitdetailscontrollertest 
* @Author       Sanket Chaudhari
* @Date         28-Apr-2022
* @Description  Test Class for unitdetailscontroller
****************************************************************************************************************************/


@istest
public class unitdetailscontrollertest {
    @isTest
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        Test.startTest();
        
        List<Business_Unit__c> buList = new List<Business_Unit__c>();
        Business_Unit__c bu = new Business_Unit__c();
        //bu.Business_Group__c = bg.Id;
        buList.add(bu);
        
        insert buList;
        
        List<Project__c> pList = new List<Project__c>();
        Project__c p = new Project__c();
        p.Business_Unit__c = buList[0].Id;
        //p.Business_Group__c = bg.Id;
        p.Project_Purpose__c = 'Leasing';
        pList.add(p);
        
        insert pList;
        
        String oppRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Residential Units Leasing').RecordTypeId;
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
        //opp.Opportunity__c=opp.id;
        //opp.Sales_Sub_Type__c='Walk-In Registration';
        //opp.Project__c = pList[0].Id;
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        List<Master_Payment_Plan__c> mppList = new List<Master_Payment_Plan__c>();
        Master_Payment_Plan__c mpp = new Master_Payment_Plan__c();
        mppList.add(mpp);
        
        insert mppList;
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
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
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[0].Id;
        //u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        u.Master_Payment_Plan__c = mppList[0].Id;
        u.Unit_Prebooked__c = false;
        u.Selling_Price__c = 12313;
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        //u.Business_Group__c = bg.Id;
        //u.Business_Unit__c = buList[0].Id;
        u.Project__c = pList[0].Id;
        //u.Cluster__c = cList[0].Id;
        //u.Building__c = bList[0].Id;
        //u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Restricted';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[0].Id;
        //u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        u.Master_Payment_Plan__c = mppList[0].Id;
        u.DLD_Customer_Share__c = 21;
        //u.Unit_Prebooked__c = true;
        u.Selling_Price__c = 12313;
        uList.add(u);//1
        
        insert uList;
        
        List<Master_Payment_Milestone__c> mpmList = new List<Master_Payment_Milestone__c>();
        Master_Payment_Milestone__c mpm = new Master_Payment_Milestone__c();
        mpm.Master_Payment_Plan__c = mppList[0].Id;
        mpm.Amount_Percentage__c = 21;
        mpm.Due_In_Days__c = 12;
        mpm.Installment__c='01-JGE';
        mpm.Installment_No__c=1;
        mpmList.add(mpm);
        
        insert mpmList;
        
        List<Opportunity> coppList = new List<Opportunity>();
        Opportunity copp = new Opportunity();
        copp.Name = 'TestOpp0';
        copp.StageName = 'New';
        copp.CloseDate = System.today();
        copp.Booking_Amount__c = 100;
        copp.Booking_Mode__c = 'Reservation without token amount';
        copp.Security_Deposit_Recevied__c = true;
        copp.Booking_Form_Generated__c = true;
        copp.RecordTypeId = oppRecType;
        copp.Lease_End_Date__c = Date.today() + 5;
        copp.Leasing_Type__c = 'Residential Units';
        copp.Loss_Reason__c = 'Test Reason';
        //copp.Business_Unit__c = buList[0].Id;
        copp.Opportunity__c=oppList[0].id;
        copp.Unit__c = uList[1].Id;
        //copp.Sales_Sub_Type__c='Walk-In Registration';
        //copp.Project__c = pList[0].Id;
        //opp.AccountId = accList[0].Id;
        coppList.add(copp);//0
        
        insert coppList;
        
        Payment_Milestone__c pm = new Payment_Milestone__c();
        pm.Opportunity__c = coppList[0].Id;
        pm.Amount_Percentage__c = 21;
        insert pm;
        
        Tax_Configuration__c tc = new Tax_Configuration__c();
        tc.Tax_Rate__c = 12;
        insert tc;
        
        Additional_Charges__c ac = new Additional_Charges__c();
        ac.Default_Sales_Charge__c = true;
        ac.Type__c = 'Sales';
        ac.Charge_Type__c = 'DLD_FEE';
        ac.Project__c = uList[1].Project__c;
        ac.Tax_Configuration__c = tc.Id;
        insert ac;
        
        UnitDetailsController.ResultWrapper rWrap = UnitDetailsController.fetchUnitDetails(uList[0].Id, oppList[0].Id,'salesEventTab');
        rWrap = UnitDetailsController.fetchUnitDetails(uList[1].Id, oppList[0].Id,'');
        
        Test.stopTest();
    }
    
    @isTest
    public static void method1() {
        Test.startTest();
        
        String oppRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Residential Units Leasing').RecordTypeId;
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
        //opp.Opportunity__c=opp.id;
        //opp.Sales_Sub_Type__c='Walk-In Registration';
        //opp.Project__c = pList[0].Id;
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        List<Master_Payment_Plan__c> mppList = new List<Master_Payment_Plan__c>();
        Master_Payment_Plan__c mpp = new Master_Payment_Plan__c();
        mppList.add(mpp);
        
        insert mppList;
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        //u.Business_Group__c = bg.Id;
        //u.Business_Unit__c = buList[0].Id;
        //u.Project__c = pList[0].Id;
        //u.Cluster__c = cList[0].Id;
        //u.Building__c = bList[0].Id;
        //u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Restricted';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[0].Id;
        //u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        u.Master_Payment_Plan__c = mppList[0].Id;
        u.DLD_Customer_Share__c = 21;
        //u.Unit_Prebooked__c = true;
        u.Selling_Price__c = 12313;
        uList.add(u);//1
        
        insert uList;
        
        List<Master_Payment_Milestone__c> mpmList = new List<Master_Payment_Milestone__c>();
        Master_Payment_Milestone__c mpm = new Master_Payment_Milestone__c();
        mpm.Master_Payment_Plan__c = mppList[0].Id;
        mpm.Amount_Percentage__c = 21;
        mpm.Due_In_Days__c = 12;
        mpm.Installment__c='01-JGE';
        mpm.Installment_No__c=1;
        mpmList.add(mpm);
        
        insert mpmList;
        
        List<Opportunity> coppList = new List<Opportunity>();
        Opportunity copp = new Opportunity();
        copp.Name = 'TestOpp0';
        copp.StageName = 'New';
        copp.CloseDate = System.today();
        copp.Booking_Amount__c = 100;
        copp.Booking_Mode__c = 'Reservation without token amount';
        copp.Security_Deposit_Recevied__c = true;
        copp.Booking_Form_Generated__c = true;
        copp.RecordTypeId = oppRecType;
        copp.Lease_End_Date__c = Date.today() + 5;
        copp.Leasing_Type__c = 'Residential Units';
        copp.Loss_Reason__c = 'Test Reason';
        //copp.Business_Unit__c = buList[0].Id;
        copp.Opportunity__c=oppList[0].id;
        copp.Unit__c = uList[0].Id;
        //copp.Sales_Sub_Type__c='Walk-In Registration';
        //copp.Project__c = pList[0].Id;
        //opp.AccountId = accList[0].Id;
        coppList.add(copp);//0
        
        insert coppList;
        
        Payment_Milestone__c pm = new Payment_Milestone__c();
        pm.Opportunity__c = coppList[0].Id;
        pm.Amount_Percentage__c = 21;
        insert pm;
        
        UnitDetailsController.ResultWrapper rWrap = UnitDetailsController.fetchUnitDetails(uList[0].Id, oppList[0].Id,'');
        
        Test.stopTest();
    }
    
    
    
    
}