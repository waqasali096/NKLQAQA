/****************************************************************************************************************************
* @Name         QuickOppJointOwnerControllertest 
* @Author       Sanket Chaudhari
* @Date         04-May-2022
* @Description  Test Class for QuickOppJointOwnerController
****************************************************************************************************************************/



@istest
public class QuickOppJointOwnerControllertest {
    @istest
    public static void method(){
         String opRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Residential Units Leasing').RecordTypeId;
        List<Opportunity> opList = new List<Opportunity>();
        Opportunity op = new Opportunity();
        op.Name = 'TestOpp0';
        op.StageName = 'New';
        op.CloseDate = System.today();
        op.Booking_Amount__c = 100;
        op.Booking_Mode__c = 'Reservation without token amount';
        op.Security_Deposit_Recevied__c = true;
        op.Booking_Form_Generated__c = true;
        op.RecordTypeId = opRecType;
        op.Lease_End_Date__c = Date.today() + 5;
        op.Leasing_Type__c = 'Residential Units';
        op.Loss_Reason__c = 'Test Reason';
        //opp.Business_Unit__c = buList[0].Id;
        //opp.Project__c = pList[0].Id;
      //  opp.AccountId = accList[0].Id;
        opList.add(op);//0
        
        op = new Opportunity();
        op.Name = 'TestOpp0';
        op.StageName = 'New';
        op.CloseDate = System.today();
        op.Booking_Amount__c = 100;
        op.Booking_Mode__c = 'Reservation without token amount';
        op.Security_Deposit_Recevied__c = true;
        op.Booking_Form_Generated__c = true;
        op.RecordTypeId = opRecType;
        op.Lease_End_Date__c = Date.today() + 5;
        op.Leasing_Type__c = 'Residential Units';
        op.Loss_Reason__c = 'Test Reason';
        //opp.Business_Unit__c = buList[0].Id;
        //opp.Project__c = pList[0].Id;
        //opp.AccountId = accList[0].Id;
        opList.add(op);//0
        insert opList;
        
        
        
        case cs = new case();
        cs.Deal__c=opList[0].id;
        insert cs;
        String accBizRecType = Schema.SObjectType.Account.RecordTypeInfosByName.get('Business Customer Account').RecordTypeId;
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestAccount0';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.Primary_Country_Code__c='91';
        acc.Emirates_Ids__c = '784-1233-1267567-1';
        acc.Trade_License_Number__c='1234';
        acc.Primary_Mobile__c='123';
        
        
        acc.RecordTypeId = accBizRecType;
        accList.add(acc);//0
        acc = new Account();
        acc.Name = 'TestAccount0';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.Primary_Country_Code__c='91';
        acc.Emirates_Ids__c = '784-1233-1267567-1';
        acc.Trade_License_Number__c='1234';
        acc.Primary_Mobile__c='123';
        
        
        acc.RecordTypeId = accBizRecType;
        accList.add(acc);
        
        insert accList;
        List<Account>cslist=QuickOppJointOwnerController.searchAccounts(acclist[0].name,acclist[0].Account_Number__c,acclist[0].Primary_Email__c,acclist[0].Primary_Mobile__c,acclist[0].Emirates_Ids__c,acclist[0].Trade_License_Number__c,true,cs.id);
        
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
        //opp.Project__c = pList[0].Id;
        opp.AccountId = accList[0].Id;
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
        opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        insert oppList;
        joint_buyer__c jb = new joint_buyer__c();
        jb.Opportunity__c=oppList[0].id;
        jb.Primary_Account__c=accList[0].id;
        insert jb;
        QuickOppJointOwnerController.ResultWrapper rw= QuickOppJointOwnerController.getJointOwners(cs.id);
        QuickOppJointOwnerController.ResultWrapper rc= QuickOppJointOwnerController.getJointOwners(oppList[0].id);
        
        List<Joint_Buyer__c> joList=new list<Joint_Buyer__c>();
        
        joint_buyer__c jo = new joint_buyer__c();
        jo.Opportunity__c=oppList[1].id;
        jo.Primary_Account__c=accList[1].id;
        
        joList.add(jo);
        
        insert joList;
        
        QuickOppJointOwnerController.ResultWrapper ro= QuickOppJointOwnerController.removeJointOwners(joList,oppList[1].id);
        
        
        QuickOppJointOwnerController.ResultWrapper rl= QuickOppJointOwnerController.createJointOwners(accList,oppList[1].id);
                QuickOppJointOwnerController.ResultWrapper rb= QuickOppJointOwnerController.createJointOwners(accList,cs.id);

        
        List<Address__c> adList=new list<Address__c>();
        
        Address__c ad = new Address__c();
        ad.Account__c=accList[0].id;
        insert ad;
        
        QuickOppJointOwnerController.ResultWrapper rh= QuickOppJointOwnerController.createAccounts(acclist[0],ad,ad,oppList[1].id,'PersonAccount');

        
        QuickOppJointOwnerController.ResultWrapper rp= QuickOppJointOwnerController.getAccountDetails(oppList[1].id);
        
        // QuickOppJointOwnerController.Boolean bo= QuickOppJointOwnerController.checksAccountAndUnit(oppList[1].id);
        
        map<string,string> csmap=QuickOppJointOwnerController.getRelationshipValues();
        
        csmap=QuickOppJointOwnerController.getCountryValues();
    }   
    @istest
    public static void method2(){
        String accBizRecType = Schema.SObjectType.Account.RecordTypeInfosByName.get('Business Customer Account').RecordTypeId;
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestAccount0';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.Primary_Country_Code__c='91';
        acc.Emirates_Ids__c = '784-1233-1267567-1';
        acc.Trade_License_Number__c='1234';
        acc.Primary_Mobile__c='123';
        
        
        acc.RecordTypeId = accBizRecType;
        accList.add(acc);//0
        insert accList;
        
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
        //opp.Project__c = pList[0].Id;
        opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        insert oppList;
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        // u.Business_Group__c = bg.Id;
        // u.Business_Unit__c = buList[0].Id;
        //u.Project__c = pList[0].Id;
        // u.Cluster__c = cList[0].Id;
        //u.Building__c = bList[0].Id;
        // u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Available';
        u.Unit_Purpose__c = 'Leasing';
        u.Active_Deal__c = oppList[0].Id;
        u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        // u.Master_Payment_Plan__c = mppList[0].Id;
        u.Unit_Prebooked__c = false;
        u.Selling_Price__c = 12313;
        uList.add(u);//0
        insert uList;
        
        
        case cs = new case();
        cs.AccountId=accList[0].Id;
        cs.Unit__c=uList[0].Id;
        insert cs;
        Boolean bo= QuickOppJointOwnerController.checksAccountAndUnit(oppList[0].id);
        Boolean bp= QuickOppJointOwnerController.checksAccountAndUnit(cs.id);
        
    }
    
    @istest
    public static void method3(){
        
          String accBizRecType = Schema.SObjectType.Account.RecordTypeInfosByName.get('Business Customer Account').RecordTypeId;
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestAccount0';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.Primary_Country_Code__c='91';
        acc.Emirates_Ids__c = '784-1233-1267567-1';
        acc.Trade_License_Number__c='1234';
        acc.Primary_Mobile__c='123';
        
        
        acc.RecordTypeId = accBizRecType;
        accList.add(acc);//0
        insert accList;
        
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
        //opp.Project__c = pList[0].Id;
        opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        insert oppList;
       
                List<joint_buyer__c> jkList = new List<joint_buyer__c>();

          joint_buyer__c jk = new joint_buyer__c();
        jk.First_Name__c='avb';
        jk.Last_Name__c='abc';
        jk.Opportunity__c=oppList[0].id;
        jk.Primary_Account__c=accList[0].id;
        
        jkList.add(jk);
        insert jkList;
        
        List<Address__c> acList=new list<Address__c>();
        
        Address__c ac = new Address__c();
        ac.Account__c=accList[0].id;
        ac.Primary__c=true;
        
       acList.add(ac);
        insert acList;
        
        QuickOppJointOwnerController.ResultWrapper rh= QuickOppJointOwnerController.createAccounts(acclist[0],ac,ac,oppList[0].id,'Business_RecordType');

               // QuickOppJointOwnerController.ResultWrapper rq= QuickOppJointOwnerController.createAccounts(acclist[0],ac,ac,oppList[0].id,'null');

    } 
        
    }