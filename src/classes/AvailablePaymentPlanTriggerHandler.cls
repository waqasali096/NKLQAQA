/*
Class Name: AvailablePaymentPlanTriggerHandler
Class Description: Handler for AvailablePaymentPlanTrigger Class
Author: Sajid Hameed
Created Date: 02 March 2022
Updated by: 
Last Update Date:
*/
public class AvailablePaymentPlanTriggerHandler {
    
    List<Availabe_Payment_Plan__c> newList = new List<Availabe_Payment_Plan__c>();
    List<Availabe_Payment_Plan__c> oldList = new List<Availabe_Payment_Plan__c>();
    Map<Id, Availabe_Payment_Plan__c> newMap = new Map<Id, Availabe_Payment_Plan__c>();
    Map<Id, Availabe_Payment_Plan__c> oldMap = new Map<Id, Availabe_Payment_Plan__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    
    public AvailablePaymentPlanTriggerHandler(List<Availabe_Payment_Plan__c> newList, List<Availabe_Payment_Plan__c> oldList, 
                                              Map<Id, Availabe_Payment_Plan__c> newMap, Map<Id, Availabe_Payment_Plan__c> oldMap,
                                              boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) 
    {
        this.newList = newList;
        this.oldList = oldList;
        this.newMap = newMap;
        this.oldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void AfterUpdateEvent() {
        createHistoryRecord(newList,oldMap,'Availabe_Payment_Plan__c');
    }
    
    //Method used for History Tracking. 
    public static void createHistoryRecord(List<sObject> newList,Map<ID,sObject> oldMap ,String objectName){
        List<History_Management__mdt> hmList = [Select id,Field_API_Name__c,Field_Label_Name__c from History_Management__mdt 
                                                where Object_Name__c =: objectName];
        system.debug('hmList**' + hmList);
        List<History__c> historyObjectList = new List<History__c>();
        for(History_Management__mdt hm : hmList){
            for(sObject obj :newList){
                if(obj.get(hm.Field_API_Name__c) != oldMap.get(obj.ID).get(hm.Field_API_Name__c)){
                    History__c hist = new History__c ();
                    hist.Field_Name__c = hm.Field_Label_Name__c;
                    hist.New_Value__c = String.valueof(obj.get(hm.Field_API_Name__c));
                    hist.Old_Value__c = String.valueof(oldMap.get(obj.ID).get(hm.Field_API_Name__c));
                    hist.Availabe_Payment_Plan__c = obj.ID;
                    historyObjectList.add(hist);
                }
            }
        }
        system.debug('historyObjectList Size**' + historyObjectList.size());
        system.debug('historyObjectList **' + historyObjectList);
        if(historyObjectList.size() > 0){
            insert historyObjectList;   
        }
    }
}