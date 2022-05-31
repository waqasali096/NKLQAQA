/*
Class Name: PriceBookEntryTriggerHandler
Class Description: Trigger Handler for PriceBook_Entry__c object
Author: Karan Jain
Created Date: 25 Jan 2021
Updated by: 
Last Update Date:
*/
public class PriceBookEntryTriggerHandler {
    List<PriceBook_Entry__c> newList = new List<PriceBook_Entry__c>();
    List<PriceBook_Entry__c> oldList = new List<PriceBook_Entry__c>();
    Map<Id, PriceBook_Entry__c> newMap = new Map<Id, PriceBook_Entry__c>();
    Map<Id, PriceBook_Entry__c> oldMap = new Map<Id, PriceBook_Entry__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public PriceBookEntryTriggerHandler(List<PriceBook_Entry__c> newList, List<PriceBook_Entry__c> oldList, Map<Id, PriceBook_Entry__c> newMap, Map<Id, PriceBook_Entry__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.newList = newList;
        this.oldList = oldList;
        this.newMap = newMap;
        this.oldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent() {
        addUnitInLookupFromUnitCode(newList);
    }
    
    public void AfterInsertEvent() {}
    
    public void BeforeUpdateEvent() {}
    
    public void AfterUpdateEvent() {}
    
    public void BeforeDeleteEvent() {}
    
    public void AfterUndeleteEvent() {}
    
    public void AfterDeleteEvent() {}
    
    public void addUnitInLookupFromUnitCode(List<PriceBook_Entry__c> newList){
        Set<String> unitCodeSet = new Set<String>();
        for(PriceBook_Entry__c pbe: newList){
            if(pbe.Unit_Code__c!=null && pbe.Unit__c == null){
                unitCodeSet.add(pbe.Unit_Code__c);
            }
        }
        Map<String, Id> unitCodeToUnitIdMap = new Map<String, Id>();
        for(Unit__c unit: [SELECT Id, Name, Unit_Code__c FROM Unit__c WHERE Unit_Code__c IN:unitCodeSet]){
            if(!unitCodeToUnitIdMap.containsKey(unit.Unit_Code__c)){
                unitCodeToUnitIdMap.put(unit.Unit_Code__c, unit.Id);
            }
        }
        for(PriceBook_Entry__c pbe: newList){
            if(pbe.Unit_Code__c!=null && pbe.Unit__c == null){
                if(unitCodeToUnitIdMap.containsKey(pbe.Unit_Code__c)){
                    pbe.Unit__c = unitCodeToUnitIdMap.get(pbe.Unit_Code__c);
                }
            }
        }
    }

}