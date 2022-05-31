/****************************************************************************************************************************
* @Name         RevisedPaymentPlanCtrlTest
* @Author       Kaustubh Abhyankar
* @Date         04-May-2022
* @Description  Test Class for RevisedPaymentPlanCtrl
****************************************************************************************************************************/

@isTest
public class RevisedPaymentPlanCtrlTest {
    //This Method Creates Test Data....
    @testSetup
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        
        Test.startTest();
        
        String accRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Business_RecordType').RecordTypeId;
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestAccount1';
        acc.ERP_Account_Number__c = 'awdadasd123123';
        //acc.Account_Number__c = '44545454545';
        acc.Primary_Mobile__c = '1322313132';
        acc.Emirates_Ids__c = '784-1233-1267567-1';
        acc.Primary_Email__c = 'Nakheel122@gmail.com';
        acc.RecordTypeId = accRecType;
        acc.Signatory_Firstname__c = '';
        acc.Signatory_Lastname__c = 'TestAcc';
        acc.Signatory_Email__c = 'Nakheel122@gmail.com';
        acc.Signatory_Phone_Number__c = '21312312332';
        acc.Signatory_Country_Code__c = '91';
        accList.add(acc);//0
        
        insert accList;
        
        String oppRecType1 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        String oppRecType2 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Lease_Renewal').RecordTypeId;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp0';
        opp.StageName = 'New';
        opp.CloseDate = System.today();
        opp.Booking_Amount__c = 100;
        opp.Booking_Mode__c = 'Reservation without token amount';
        opp.Security_Deposit_Recevied__c = true;
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType1;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByDeveloperName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        u.Holding_Deposit_Amount__c = 123;
        u.RecordTypeId = uRecType;
        uList.add(u);//0
        
        insert uList;
        
        List<Opportunity> coppList = new List<Opportunity>();
        Opportunity copp = new Opportunity();
        copp.Name = 'Test cOpp0';
        copp.StageName = 'New';
        copp.CloseDate = System.today();
        copp.Booking_Amount__c = 100;
        copp.Booking_Mode__c = 'Reservation without token amount';
        copp.Security_Deposit_Recevied__c = true;
        copp.Booking_Form_Generated__c = false;
        copp.RecordTypeId = oppRecType1;
        copp.Lease_End_Date__c = Date.today() + 5;
        copp.Leasing_Type__c = 'Residential Units';
        copp.Loss_Reason__c = 'Test Reason';
        copp.AccountId = accList[0].Id;
        copp.Unit__c = uList[0].Id;
        coppList.add(copp);//0
        
        insert coppList;
        
        List<Master_Payment_Plan__c> mppList = new List<Master_Payment_Plan__c>();
        Master_Payment_Plan__c mpp = new Master_Payment_Plan__c();
        mppList.add(mpp);
        
        insert mppList;
        
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        Payment_Milestone__c pm = new Payment_Milestone__c();
        pm.Opportunity__c = coppList[0].Id;
        pm.Master_Payment_Plan__c = mppList[0].Id;
        pm.Amount_Percentage__c = 12;
        pmList.add(pm);
        
        insert pmList;
        
        List<Original_Milestone__c> omList = new List<Original_Milestone__c>();
        Original_Milestone__c om = new Original_Milestone__c();
        om.Opportunity__c = coppList[0].Id;
        om.Master_Payment_Plan__c = mppList[0].Id;
        om.Amount_Percentage__c = 21;
        omList.add(om);
        
        om = new Original_Milestone__c();
        om.Opportunity__c = coppList[0].Id;
        om.Master_Payment_Plan__c = mppList[0].Id;
        om.Amount_Percentage__c = 21;
        omList.add(om);
        
        insert omList;
        
        Test.stopTest();
    }
    
    //Testing Method - getUnitInfo
    @isTest
    public static void getUnitInfoTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'Test cOpp0' limit 1];
        RevisedPaymentPlanCtrl.ResultWrapper rWrap = RevisedPaymentPlanCtrl.getUnitInfo(opp.Id);
        
        Test.stopTest();
    }
    
    //Testing Method - saveRequestedMilestones
    @isTest
    public static void saveRequestedMilestonesTest() {
        Test.startTest();
        
        Opportunity opp = [select Id, Name from Opportunity where Name = 'Test cOpp0' limit 1];
        List<Original_Milestone__c> omList = [select Id, Name, Installment__c, Milestone_Trigger_Point__c, Due_Date__c, Due_In_Days__c, Amount_Percentage__c, Amount__c from Original_Milestone__c];
        List<Payment_Milestone__c> pmList = [select Id, Name, Installment__c, Milestone_Trigger_Point__c, Due_Date__c, Due_In_Days__c, Amount_Percentage__c, Amount__c from Payment_Milestone__c];
        List<String> strList = new List<String>();
        strList.add(pmList[0].Id);
        RevisedPaymentPlanCtrl.ResultWrapper rWrap = RevisedPaymentPlanCtrl.saveRequestedMilestones(opp.Id, omList, pmList, strList, null);
        
        Test.stopTest();
    }
    
    //Testing Method - checkPaymentMilestoneChanges
    @isTest
    public static void checkPaymentMilestoneChangesTest() {
        Test.startTest();
        
        String oppRecType1 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Residential_Leasing_Unit_Opportunity').RecordTypeId;
        String oppRecType2 = Schema.SObjectType.Opportunity.RecordTypeInfosByDeveloperName.get('Lease_Renewal').RecordTypeId;
        List<Opportunity> coppList = new List<Opportunity>();
        Opportunity copp = new Opportunity();
        copp.Name = 'Test cOpp0';
        copp.StageName = 'New';
        copp.CloseDate = System.today();
        copp.Booking_Amount__c = 100;
        copp.Booking_Mode__c = 'Reservation without token amount';
        copp.Security_Deposit_Recevied__c = true;
        copp.Booking_Form_Generated__c = false;
        copp.RecordTypeId = oppRecType1;
        copp.Lease_End_Date__c = Date.today() + 5;
        copp.Leasing_Type__c = 'Residential Units';
        copp.Loss_Reason__c = 'Test Reason';
        //copp.AccountId = accList[0].Id;
        //copp.Unit__c = uList[0].Id;
        coppList.add(copp);//0
        
        insert coppList;
        
        List<Master_Payment_Plan__c> mppList = new List<Master_Payment_Plan__c>();
        Master_Payment_Plan__c mpp = new Master_Payment_Plan__c();
        mppList.add(mpp);
        
        insert mppList;
        
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        Payment_Milestone__c pm = new Payment_Milestone__c();
        pm.Opportunity__c = coppList[0].Id;
        pm.Master_Payment_Plan__c = mppList[0].Id;
        pmList.add(pm);
        
        pm = new Payment_Milestone__c();
        pm.Opportunity__c = coppList[0].Id;
        pm.Master_Payment_Plan__c = mppList[0].Id;
        pm.Installment__c = 'ADV';
        pmList.add(pm);
        
        pm = new Payment_Milestone__c();
        pm.Opportunity__c = coppList[0].Id;
        pm.Master_Payment_Plan__c = mppList[0].Id;
        pm.Milestone_Trigger_Point__c = 'On Completion';
        pmList.add(pm);
        
        pm = new Payment_Milestone__c();
        pm.Opportunity__c = coppList[0].Id;
        pm.Master_Payment_Plan__c = mppList[0].Id;
        pm.Due_Date__c = System.today() + 15;
        pmList.add(pm);
        
        pm = new Payment_Milestone__c();
        pm.Opportunity__c = coppList[0].Id;
        pm.Master_Payment_Plan__c = mppList[0].Id;
        pm.Due_In_Days__c = 12;
        pmList.add(pm);
        
        pm = new Payment_Milestone__c();
        pm.Opportunity__c = coppList[0].Id;
        pm.Master_Payment_Plan__c = mppList[0].Id;
        pm.Amount_Percentage__c = 12;
        pmList.add(pm);
        
        pm = new Payment_Milestone__c();
        pm.Opportunity__c = coppList[0].Id;
        pm.Master_Payment_Plan__c = mppList[0].Id;
        pm.Amount__c = 122;
        pmList.add(pm);
        
        insert pmList;
        
        List<Original_Milestone__c> omList = new List<Original_Milestone__c>();
        Original_Milestone__c om = new Original_Milestone__c();
        om.Opportunity__c = coppList[0].Id;
        om.Master_Payment_Plan__c = mppList[0].Id;
        omList.add(om);
        
        om = new Original_Milestone__c();
        om.Opportunity__c = coppList[0].Id;
        om.Master_Payment_Plan__c = mppList[0].Id;
        omList.add(om);
        
        om = new Original_Milestone__c();
        om.Opportunity__c = coppList[0].Id;
        om.Master_Payment_Plan__c = mppList[0].Id;
        omList.add(om);
        
        om = new Original_Milestone__c();
        om.Opportunity__c = coppList[0].Id;
        om.Master_Payment_Plan__c = mppList[0].Id;
        omList.add(om);
        
        om = new Original_Milestone__c();
        om.Opportunity__c = coppList[0].Id;
        om.Master_Payment_Plan__c = mppList[0].Id;
        omList.add(om);
        
        om = new Original_Milestone__c();
        om.Opportunity__c = coppList[0].Id;
        om.Master_Payment_Plan__c = mppList[0].Id;
        omList.add(om);
        
        om = new Original_Milestone__c();
        om.Opportunity__c = coppList[0].Id;
        om.Master_Payment_Plan__c = mppList[0].Id;
        omList.add(om);
        
        insert omList;
        
        List<Payment_Milestone__c> pmList0 = new List<Payment_Milestone__c>();
        pmList0.add(pmList[0]);
        List<Payment_Milestone__c> pmList1 = new List<Payment_Milestone__c>();
        pmList1.add(pmList[1]);
        List<Payment_Milestone__c> pmList2 = new List<Payment_Milestone__c>();
        pmList2.add(pmList[2]);
        List<Payment_Milestone__c> pmList3 = new List<Payment_Milestone__c>();
        pmList3.add(pmList[3]);
        List<Payment_Milestone__c> pmList4 = new List<Payment_Milestone__c>();
        pmList4.add(pmList[4]);
        List<Payment_Milestone__c> pmList5 = new List<Payment_Milestone__c>();
        pmList5.add(pmList[5]);
        List<Payment_Milestone__c> pmList6 = new List<Payment_Milestone__c>();
        pmList6.add(pmList[6]);
        
        List<Original_Milestone__c> omList0 = new List<Original_Milestone__c>();
        omList0.add(omList[0]);
        List<Original_Milestone__c> omList1 = new List<Original_Milestone__c>();
        omList1.add(omList[1]);
        List<Original_Milestone__c> omList2 = new List<Original_Milestone__c>();
        omList2.add(omList[2]);
        List<Original_Milestone__c> omList3 = new List<Original_Milestone__c>();
        omList3.add(omList[3]);
        List<Original_Milestone__c> omList4 = new List<Original_Milestone__c>();
        omList4.add(omList[4]);
        List<Original_Milestone__c> omList5 = new List<Original_Milestone__c>();
        omList5.add(omList[5]);
        List<Original_Milestone__c> omList6 = new List<Original_Milestone__c>();
        omList6.add(omList[6]);
        
        Boolean result = RevisedPaymentPlanCtrl.checkPaymentMilestoneChanges(omList0, pmList0);
        result = RevisedPaymentPlanCtrl.checkPaymentMilestoneChanges(omList1, pmList1);
        result = RevisedPaymentPlanCtrl.checkPaymentMilestoneChanges(omList2, pmList2);
        result = RevisedPaymentPlanCtrl.checkPaymentMilestoneChanges(omList3, pmList3);
        result = RevisedPaymentPlanCtrl.checkPaymentMilestoneChanges(omList4, pmList4);
        result = RevisedPaymentPlanCtrl.checkPaymentMilestoneChanges(omList5, pmList5);
        result = RevisedPaymentPlanCtrl.checkPaymentMilestoneChanges(omList6, pmList6);
        
        Test.stopTest();
    }
    
    //Testing Method - deleteContentDoc
    @isTest
    public static void deleteContentDocTest() {
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
        opp.Booking_Form_Generated__c = false;
        opp.RecordTypeId = oppRecType;
        opp.Lease_End_Date__c = Date.today() + 5;
        opp.Leasing_Type__c = 'Residential Units';
        opp.Loss_Reason__c = 'Test Reason';
        //opp.AccountId = accList[0].Id;
        //opp.Employee_Name__c = accList[0].Name;
        //opp.Broker__c = accList[0].Id;
        oppList.add(opp);//0
        
        insert oppList;
        
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion(
            Title          = String.valueOf(system.Label.Leasing_Booking_Form),
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        cvList.add(cv);
        
        insert cvList;
        
        ContentDocumentLink cdlopp = new ContentDocumentLink();
        cdlopp.LinkedEntityId = oppList[0].Id;
        cdlopp.contentdocumentid = [select contentdocumentid from contentversion where id =:cvList[0].Id].contentdocumentid;
        cdlopp.ShareType = 'I';
        cdlopp.Visibility = 'AllUsers';
        insert cdlopp;
        
        RevisedPaymentPlanCtrl.deleteContentDoc(cdlopp.ContentDocumentId);
        
        Test.stopTest();
    }
    
    //Testing Method - getMilestonePoint
    @isTest
    public static void getMilestonePointTest() {
        Test.startTest();
        
        Map<String, String> strMap = RevisedPaymentPlanCtrl.getMilestonePoint();
        
        Test.stopTest();
    }
    
    //Testing Method - getInstallments
    @isTest
    public static void getInstallmentsTest() {
        Test.startTest();
        
        Map<String, String> strMap = RevisedPaymentPlanCtrl.getInstallments();
        
        Test.stopTest();
    }
}