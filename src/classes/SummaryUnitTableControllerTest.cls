/****************************************************************************************************************************
* @Name         SummaryUnitTableControllerTest
* @Author       Kaustubh Abhyankar
* @Date         26-April-2022
* @Description  Test Class for SummaryUnitTableController
****************************************************************************************************************************/

@isTest
public class SummaryUnitTableControllerTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        
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
        
        Business_Unit__c bu = new Business_Unit__c();
        insert bu;
        Project__c p = new Project__c();
        p.Business_Unit__c = bu.Id;
        insert p;
        
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
        opp.Lease_Start_Date__c = Date.today();
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        opp.Email__c = 'opp@test.sf';
        //opp.Project__c = pList[0].Id;
        opp.AccountId = accList[0].Id;
        opp.Project__c = p.Id;
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
        opp.Lease_Start_Date__c = Date.today();
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        opp.Email__c = 'opp@test.sf';
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
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_Start_Date__c = Date.today();
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Commercial Units';
        opp.Loss_Reason__c = 'Test Reason';
        opp.Email__c = 'opp@test.sf';
        //opp.Project__c = pList[0].Id;
        opp.AccountId = accList[0].Id;
        oppList.add(opp);//2
        
        insert oppList;
        
        Tax_Configuration__c tc = new Tax_Configuration__c();
        tc.Tax_Rate__c = 12;
        insert tc;
        Additional_Charges__c ac = new Additional_Charges__c();
        ac.Project__c = p.Id;
        ac.Required__c = true;
        ac.Applicable_for_renewal__c = true;
        ac.Amount__c = 123123;
        ac.Fixed_Amount__c = 12312;
        ac.Tax_Configuration__c = tc.Id;
        insert ac;
        
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
        u.Security_Deposit__c = 123;
        u.Unit_Code__c = 'U-123132';
        u.Discount__c = 21;
        u.Price_Per_SQ_FT__c = 120;
        u.Renewal_Rent__c = 1233;
        u.Market_Rent__c = 123;
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[1].Id;
        //u.Project__c = oppList[0].Project__c;
        //u.Building__c = bList[0].Id;
        //u.Business_Group__c = bgList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Vacant';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[1].Id;
        u.Handover_Status__c = 'Handover Completed';
        u.Security_Deposit__c = 123;
        u.Unit_Code__c = 'U-123132';
        //u.Discount__c = 21;
        //u.Price_Per_SQ_FT__c = 120;
        u.Renewal_Rent__c = 1233;
        //u.Market_Rent__c = 123;
        uList.add(u);//0
        
        u = new Unit__c();
        u.Opportunity__c = oppList[2].Id;
        //u.Project__c = oppList[0].Project__c;
        //u.Building__c = bList[0].Id;
        //u.Business_Group__c = bgList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Vacant';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[2].Id;
        u.Handover_Status__c = 'Handover Completed';
        u.Security_Deposit__c = 123;
        u.Unit_Code__c = 'U-123132';
        //u.Discount__c = 21;
        //u.Price_Per_SQ_FT__c = 120;
        u.Renewal_Rent__c = 1233;
        //u.Market_Rent__c = 123;
        uList.add(u);//0
        
        insert uList;
        
        List<Unit_Plan__c> upList = new List<Unit_Plan__c>();
        Unit_Plan__c up = new Unit_Plan__c();
        up.Opportunity__c = oppList[0].Id;
        up.Unit__c = uList[0].Id;
        upList.add(up);
        
        up = new Unit_Plan__c();
        up.Opportunity__c = oppList[1].Id;
        up.Unit__c = uList[1].Id;
        upList.add(up);
        
        up = new Unit_Plan__c();
        up.Opportunity__c = oppList[2].Id;
        up.Unit__c = uList[2].Id;
        upList.add(up);
        
        insert upList;
        
        Test.stopTest();
    }
    //Testing Method - createOpp
    @isTest
    public static void createOppTest1() {
        Test.startTest();
        
        Unit__c u = [select Id, Name, Opportunity__c, Opportunity__r.Name from Unit__c where Opportunity__r.Name = 'TestOpp0' limit 1];
        Opportunity opp = [select Id, Account_Name__c, Interested_In__c, Leasing_Type__c, AccountId, Email__c, Project__c, Master_Opportunity__c,
                           Lease_End_Date__c, Lease_Start_Date__c
                           from Opportunity where Name =: u.Opportunity__r.Name limit 1];
        
        List<RenewalSRUnitController.PropWrapper> pWrapList = new List<RenewalSRUnitController.PropWrapper>();
        RenewalSRUnitController.PropWrapper pWrap = new RenewalSRUnitController.PropWrapper();
        pWrap.oppObj = opp;
        pWrap.unitId = u.Id;
        pWrap.unitName = u.Name;
        pWrap.dealId = null;
        pWrap.dealName = null;
        pWrap.startDate = null;
        pWrap.endDate = null;
        pWrap.propFlag = null;
        pWrap.building_Floor = null;
        pWrap.noOfBedrooms = null;
        pWrap.propertyType = null;
        pWrap.unitType = null;
        pWrap.rent = null;
        pWrap.securityDeposit = null;
        pWrap.newUnit = true;
        pWrap.isExisting = null;
        pWrap.pricePerSqft = null;
        pWrap.leasableArea = null;
        pWrap.leasingType = null;
        pWrap.buildingId = null;
        pWrap.buildingName = null;
        
        pWrapList.add(pWrap);
        
        Id result1 = SummaryUnitTableController.createOpp1(pWrapList, pWrapList, System.today(), 'Full', System.today()+10, '1', false, 'Cash', true);
        
        Test.stopTest();
    }
}