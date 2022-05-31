/****************************************************************************************************************************
* @Name         LookupControllertest
* @Author       Sanket Chaudhari
* @Date         
* @Description  Test Class for LookupController
****************************************************************************************************************************/





@istest
public class LookupControllertest {
    @istest
    public static void method(){
        
        
        
        Business_Group__c bg = new Business_Group__c();  
        insert bg;
        
        Business_Unit__c bu = new Business_Unit__c(); 
        bu.Business_Group__c=bg.Id;
        insert bu;
        
        Project__c bp = new Project__c(); 
        bp.Business_Unit__c=bu.Id;
        insert bp;
        
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
        //opp.AccountId = accList[0].Id;
        oppList.add(opp);//0
        insert oppList;
        
        String uRecType = Schema.SObjectType.Unit__c.RecordTypeInfosByName.get('Leasing').RecordTypeId;
        List<Unit__c> uList = new List<Unit__c>();
        Unit__c u = new Unit__c();
        u.Opportunity__c = oppList[0].Id;
        // u.Business_Group__c = bg.Id;
        u.Business_Unit__c = bu.Id;
        u.Project__c = bp.Id;
        // u.Cluster__c = cList[0].Id;
        //u.Building__c = bList[0].Id;
        // u.Floor__c = fList[0].Id;
        u.Leasing_Type__c = 'Residential Unit';
        u.Holding_Deposit_Amount__c = 123;
        //u.RecordTypeId = uRecType;
        u.Unit_Status__c = 'Available';
        u.Unit_Purpose__c = 'Leasing';
        //u.Active_Deal__c = oppList[0].Id;
        //u.Active_Account__c = accList[0].Id;
        u.Handover_Status__c = 'Handover Completed';
        // u.Master_Payment_Plan__c = mppList[0].Id;
        u.Unit_Prebooked__c = false;
        u.Selling_Price__c = 12313;
        uList.add(u);//0
        insert uList;
       string st=LookupController.getrecord('Unit__c','Unit_Status__c','Unit_Purpose__c',1,'Unit_Status__c','Available',bu.Id,null,bp.Id,null);
            
            
            
            }
}