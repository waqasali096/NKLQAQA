/*
@Author : Swapnil Mohite
@CreatedDate: 16/01/2022
@ This apex class will handle all trigger related functionalities of Sales Event Unit
*/
public class SalesEventUnitTriggerHandler {
    List<Sales_Event_Unit__c> recordNewList = new List<Sales_Event_Unit__c>();
    List<Sales_Event_Unit__c> recordOldList = new List<Sales_Event_Unit__c>();
    Map<Id, Sales_Event_Unit__c> recordNewMap = new Map<Id, Sales_Event_Unit__c>();
    Map<Id, Sales_Event_Unit__c> recordOldMap = new Map<Id, Sales_Event_Unit__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public SalesEventUnitTriggerHandler(List<Sales_Event_Unit__c> newList, List<Sales_Event_Unit__c> oldList, Map<Id, Sales_Event_Unit__c> newMap, Map<Id, Sales_Event_Unit__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
        createUnitVisibility(recordNewList,null,isInsert);
    }
    public void AfterUpdateEvent() {
        Boolean isInsert = true;
        createUnitVisibility(recordNewList,null,isInsert);
    }
    public void AfterDeleteEvent(){
        removeUnitAccessOnDelete(recordOldList);
    }
    public void AfterUndeleteEvent() {
    }
    /**
* This method is used to create visibility for unit
* @date   16/01/2022
* @author Swapnil Mohite
*/
    public static void createUnitVisibility(List<Sales_Event_Unit__c> newList,Map<id,Sales_Event_Unit__c> oldMap,Boolean isInsert){
        Set<Id> salesEventIdSet = new Set<Id>();
        List<Sales_Event_Unit__c> salesEventUnitList = new List<Sales_Event_Unit__c>();
        for(Sales_Event_Unit__c salesEventUnit : newList){
            if(isInsert){
                salesEventIdSet.add(salesEventUnit.Sales_Event__c);
                salesEventUnitList.add(salesEventUnit);
            }else if(salesEventUnit.Access_given__c == true &&  oldMap.get(salesEventUnit.Id).Access_given__c == false){
                salesEventIdSet.add(salesEventUnit.Sales_Event__c);
                salesEventUnitList.add(salesEventUnit);
            }
        }
        List<Sales_Event_Executive__c> salesEventExecList = [SELECT Id,Name,Sales_Event__c,End_Date__c,Start_Date__c,User__c,Access_Given__c
                                                             FROM Sales_Event_Executive__c 
                                                             WHERE Sales_Event__c IN : salesEventIdSet AND Access_Given__c = True];
        
        UnitAllocationController.prepareData(salesEventExecList, salesEventUnitList,salesEventIdSet);
    }
    /**
* This method is used to remove visibility for unit on Sales Event Unit deletion.
* @date   17/01/2022
* @author Swapnil Mohite
*/
    public static void removeUnitAccessOnDelete(List<Sales_Event_Unit__c> oldList){
        Set<Id> salesEventIdSet = new Set<Id>();
        for(Sales_Event_Unit__c salesEventUnit : oldList){
            salesEventIdSet.add(salesEventUnit.Sales_Event__c);
        }
         List<Sales_Event_Executive__c> salesEventExecList = [SELECT Id,Name,Sales_Event__c,End_Date__c,Start_Date__c,User__c,Access_Given__c
                                                             FROM Sales_Event_Executive__c 
                                                             WHERE Sales_Event__c IN : salesEventIdSet AND Access_Given__c = True];
        
        UnitAllocationController.prepareData(salesEventExecList,oldList,salesEventIdSet);
    }
}