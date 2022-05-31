public class UnitPlanTriggerHandler {

    List<Unit_Plan__c> recordNewList = new List<Unit_Plan__c>();
    List<Unit_Plan__c> recordOldList = new List<Unit_Plan__c>();
    Map<Id, Unit_Plan__c> recordNewMap = new Map<Id, Unit_Plan__c>();
    Map<Id, Unit_Plan__c> recordOldMap = new Map<Id, Unit_Plan__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public UnitPlanTriggerHandler(List<Unit_Plan__c> newList, List<Unit_Plan__c> oldList, Map<Id, Unit_Plan__c> newMap, Map<Id, Unit_Plan__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
    }
    
    public void AfterUpdateEvent() {
    }
    
    public void AfterDeleteEvent() {
    }
    
    public void AfterUndeleteEvent() {
    }
}