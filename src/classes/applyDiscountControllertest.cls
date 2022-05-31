/****************************************************************************************************************************
* @Name         applyDiscountControllertest 
* @Author       Sanket Chaudhari
* @Date         18-May-2022
* @Description  Test Class for applyDiscountController
****************************************************************************************************************************/


@istest
public class applyDiscountControllertest {
    @istest
    public static void method1(){
        
       
        String oppRecType = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Sales Deal').RecordTypeId;
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
        opp.Discount_Type__c='Fixed';
        opp.Discount__c=300;
        
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
        // opp.Document__c= dcList[0].id;
        //opp.Business_Unit__c = buList[0].Id;
        //opp.Project__c = pList[0].Id;
        //opp.AccountId = accList[0].Id;
        
        oppList.add(opp);//0
        insert oppList;
        System.debug('opportunity' +oppList);
        
        applyDiscountController.getOppData(opplist[0].id);
        
        List<Document__c> dcList = new List<Document__c>();
        Document__c dc = new Document__c();
        dc.Is_Document_Uploaded__c= true;
        dc.Approval_Request_Id__c='ProcessInstanceId';
        dcList.add(dc);
        insert dc;
        System.debug('Document__c' +dcList);
        
        applyDiscountController.createDocument(opplist[0].id);
        
       
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(oppList[0].id);
        Approval.ProcessResult result = Approval.process(app);
        
        
        /*ProcessInstance pi = new ProcessInstance ();
        pi.TargetObjectId = opplist[0].id;
        pi.Status ='Approved';
        
         pi.ProcessDefinitionId=opplist[0].id;
        
        //pi.CurrentNodeId='';
        
        
        Insert pi;
        
        ProcessInstanceWorkitem pis = new ProcessInstanceWorkitem ();
        pis.ProcessInstanceId = pi.Id;
        Insert pis;*/
        
        
        
        System.debug('ProcessSubmitRequest' +result);
        
        
        
        
        
        applyDiscountController.saveFile(opplist[0].id,'Fixed','300',dcList[0].Id);
        
    }
    
    
}