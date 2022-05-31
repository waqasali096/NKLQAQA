/*
Class Name: RentEventTrigger
Class Description: Trigger on Rent Event object
Author: Kshitij Tiwari
Created Date: 17/3/2022
Updated by:
Last Update Date:
*/


public class RentEventTriggerHandler {
    List<Rent__c> recordNewList = new List<Rent__c>();
    // List<Sales_Event_Unit__c> recordOldList = new List<Sales_Event_Unit__c>();
    //  Map<Id, Sales_Event_Unit__c> recordNewMap = new Map<Id, Sales_Event_Unit__c>();
    Map<Id, Rent__c> recordOldMap = new Map<Id, Rent__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public RentEventTriggerHandler(List<Rent__c> newList, Map<Id, Rent__c> oldMap,boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.recordNewList = newList;
        // this.recordOldList = oldList;
        //  this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent() {
        //Boolean isInsert = true;
        InsertNewRentValues(recordNewList);
    }
    
    
    public void AfterUpdateEvent() {
        Boolean isInsert = true;
        updateOldRentStatus(recordNewList,recordOldMap);
    }
    
       /**
* This method is used to insert values in new rent records
* @date   11/04/2022
* @author Kshitij Tiwari
*/
    public static void InsertNewRentValues(List<Rent__c> triggerNew){
        List<Availabe_Payment_Plan__c> availList = new List<Availabe_Payment_Plan__c>();
        Set<id> availPaymentId = new  Set<id>();
        
        
        for(Rent__c r:triggerNew)
        {
            availPaymentId.add(r.Availabe_Payment_Plan__c);
            
        }
        
        Map<string, Availabe_Payment_Plan__c> availPaymentMap = new Map<String, Availabe_Payment_Plan__c>([select id,Security_Deposit__c,Holding_Deposit_Amount__c,Discount__c,Markup_Percent__c from Availabe_Payment_Plan__c where id in :availPaymentId]);
        
        for(Rent__c r:triggerNew)
        {
            if(r.Security_Deposit__c ==null)
            {
                
                r.Security_Deposit__c = availPaymentMap.get(r.Availabe_Payment_Plan__c).Security_Deposit__c;
            }
            if(r.Holding_Deposit_Amount__c ==null)
            {
                r.Holding_Deposit_Amount__c =availPaymentMap.get(r.Availabe_Payment_Plan__c).Holding_Deposit_Amount__c;
            }
            if(r.Discount__c ==null)
            {
                r.Discount__c = availPaymentMap.get(r.Availabe_Payment_Plan__c).Discount__c;
            }
            if(r.Markup_Percent__c ==null)
            {
                r.Markup_Percent__c =availPaymentMap.get(r.Availabe_Payment_Plan__c).Markup_Percent__c;
            }
            
        }
        
    }
    
    /**
* This method is used to update old rent records to inactive
* @date   17/03/2022
* @author Kshitij Tiwari
*/
    public static void updateOldRentStatus(List<Rent__c> triggerNew, Map<Id, Rent__c> triggerOldMap){
        List<Rent__c> rentList =new List<Rent__c>();
        List<Id> activeRentId = new List<Id>();
        List<Id> availpaymentId = new List<Id>();
        Map<id,Rent__c> mapAvailRent= new Map<id,Rent__c>();
        for (Rent__c r :triggerNew)
        {
            if(r.Active__c==True && triggerOldMap.get(r.Id).Active__c==False)
            {
                availpaymentId.add(r.Availabe_Payment_Plan__c);
                mapAvailRent.put(r.Availabe_Payment_Plan__c,r);
                //r.Active__c = False;
                activeRentId.add(r.id);
            }
        }
        List<Availabe_Payment_Plan__c> availList = [Select Id, name,Price_per_sqft__c,Base_Lease_Amount__c,Security_Deposit__c,Holding_Deposit_Amount__c
                                                    from Availabe_Payment_Plan__c where id in :availpaymentId];
        for(Availabe_Payment_Plan__c ap :availList)
        {
            ap.Price_per_sqft__c =mapAvailRent.get(ap.Id).Price_Per_SQ_FT__c;
            ap.Base_Lease_Amount__c =mapAvailRent.get(ap.Id).Base_Rent__c;
            ap.Security_Deposit__c =mapAvailRent.get(ap.Id).Security_Deposit__c;
            ap.Holding_Deposit_Amount__c = mapAvailRent.get(ap.Id).Holding_Deposit_Amount__c;
            ap.Discount__c = mapAvailRent.get(ap.Id).Discount__c;
            ap.Markup_value__c = mapAvailRent.get(ap.Id).Markup_Percent__c;
            
        }
        if(availList.size()>0)
        {
            update availList;
        }
        List<Rent__c> inactiveList= [select id ,name, Availabe_Payment_Plan__c from rent__c
                                     where Availabe_Payment_Plan__c IN :availpaymentId
                                     And id Not In :activeRentId];
        
        for(Rent__c r :inactiveList)
        {
            r.Active__c = False;
        }
        if(inactiveList.size()>0)
        {
            update inactiveList;
        }
        
    }
    
    
}