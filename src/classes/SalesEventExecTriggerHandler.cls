/*
@Author : Swapnil Mohite
@CreatedDate: 16/01/2022
@ This apex class will handle all trigger related functionalities of Sales Event Executive
*/
public class SalesEventExecTriggerHandler {
    List<Sales_Event_Executive__c> recordNewList = new List<Sales_Event_Executive__c>();
    List<Sales_Event_Executive__c> recordOldList = new List<Sales_Event_Executive__c>();
    Map<Id, Sales_Event_Executive__c> recordNewMap = new Map<Id, Sales_Event_Executive__c>();
    Map<Id, Sales_Event_Executive__c> recordOldMap = new Map<Id, Sales_Event_Executive__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public SalesEventExecTriggerHandler(List<Sales_Event_Executive__c> newList, List<Sales_Event_Executive__c> oldList, Map<Id, Sales_Event_Executive__c> newMap, Map<Id, Sales_Event_Executive__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.recordNewList = newList;
        this.recordOldList = oldList;
        this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent() {
    }
    public void BeforeUpdateEvent() {
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
        Boolean isInsert = true;
        // createUnitVisibility(recordNewList,recordOldMap,isInsert);
        createUnitVisibility(recordNewList,null,isInsert);
    }
    public void AfterUpdateEvent() {
        createUnitVisibility(recordNewList,recordOldMap,false);
    }
    public void AfterDeleteEvent() {
        removeUnitAccessOnDelete(recordOldList);
    }
    public void AfterUndeleteEvent() {
    }
    /**
* This method is used to create visibility for unit
* @date   16/01/2022
* @author Swapnil Mohite
*/
    public static void createUnitVisibility(List<Sales_Event_Executive__c> newList,Map<id,Sales_Event_Executive__c> oldMap,Boolean isInsert){
        Set<Id> salesEventIdSet = new Set<Id>();
        List<Sales_Event_Executive__c> salesEventExecList = new List<Sales_Event_Executive__c>();
        for(Sales_Event_Executive__c salesEventExec : newList){
            if(isInsert){
                salesEventIdSet.add(salesEventExec.Sales_Event__c);
                salesEventExecList.add(salesEventExec);
            }else if(salesEventExec.Access_given__c == true && oldMap.get(salesEventExec.Id).Access_given__c == false 
                     || salesEventExec.Access_given__c == false && oldMap.get(salesEventExec.Id).Access_given__c == true){
                         salesEventIdSet.add(salesEventExec.Sales_Event__c);
                         salesEventExecList.add(salesEventExec);
                     }
        }
        List<Sales_Event_Unit__c> salesEventUnitList = [SELECT Id,Name,Sales_Event__c,Access_Given__c,Unit__c
                                                        FROM Sales_Event_Unit__c 
                                                        WHERE Sales_Event__c IN : salesEventIdSet AND Access_Given__c = True];
        
        UnitAllocationController.prepareData(salesEventExecList, salesEventUnitList,salesEventIdSet);
        
    }
    /**
* This method is used to remove visibility for unit on Sales Event Unit deletion.
* @date   17/01/2022
* @author Swapnil Mohite
*/
    public static void removeUnitAccessOnDelete(List<Sales_Event_Executive__c> oldList){
        Set<Id> salesEventIdSet = new Set<Id>();
        for(Sales_Event_Executive__c salesEventExec : oldList){
            salesEventIdSet.add(salesEventExec.Sales_Event__c);
        }
        List<Sales_Event_Unit__c> salesEventUnitList = [SELECT Id,Name,Sales_Event__c,Access_Given__c,Unit__c
                                                        FROM Sales_Event_Unit__c 
                                                        WHERE Sales_Event__c IN : salesEventIdSet AND Access_Given__c = True];
        
        UnitAllocationController.prepareData(oldList,salesEventUnitList,salesEventIdSet);
    }
}