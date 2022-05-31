/*
Class Name:                 ApprovalTriggerHandler
Class Description:          Controller to handle operations for ApprovalTrigger
Author:                     Swapnil Mohite
Created Date:               1/20/2022
Updated by:
Last Update Date:
*/
public class ApprovalTriggerHandler {
    List<Approval__c> recordNewList = new List<Approval__c>();
    List<Approval__c> recordOldList = new List<Approval__c>();
    Map<Id, Approval__c> recordNewMap = new Map<Id, Approval__c>();
    Map<Id, Approval__c> recordOldMap = new Map<Id, Approval__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = false;
    public ApprovalTriggerHandler(List<Approval__c> newList, List<Approval__c> oldList, Map<Id, Approval__c> newMap, Map<Id, Approval__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
        updateUnitStatus(recordNewList,recordOldMap);
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }
    /*Purpose : update Unit Values based on Approval line Item
	* Modified by Ashams on 03/04/2022
	* Changes : added logic to update Submitted_For_Release_Approval__c to false on Approval/Rejection
	*/
    public Static void updateUnitStatus(List<Approval__c> newList,Map<Id,Approval__c> oldMap){
        Set<Id> approvalIdSet = new Set<Id>();
        Set<Id> rejectedIdSet = new Set<Id>();
        Set<Id> pendingIdSet = new Set<Id>();
        List<Unit__c> unitList = new List<Unit__c>();
        for(Approval__c app : newList){
            if(app.Approval_Status__c == 'Approved' && oldMap.get(app.Id).Approval_Status__c != 'Approved'){
                approvalIdSet.add(app.Id);
            }
            if(app.Approval_Status__c == 'Rejected' && oldMap.get(app.Id).Approval_Status__c != 'Rejected'){
                rejectedIdSet.add(app.Id);
            }
            if(app.Approval_Status__c == 'Pending' && oldMap.get(app.Id).Approval_Status__c != 'Pending'){
                pendingIdSet.add(app.Id);
            }
        }
        if(approvalIdSet.size()>0){
            for(Approval_Line_Item__c approvalItem : [Select Id,name,unit__c
                                                      FROM Approval_Line_Item__c WHERE Approval__c IN : approvalIdSet]){
                                                          Unit__c unitObj = new Unit__c();
                                                          unitObj.Id = approvalItem.Unit__c;
                                                          unitObj.Unit_Status__c = 'Uploaded';
                                                          unitObj.Submitted_For_Release_Approval__c = False;
                                                          unitObj.Release_Status__c = 'Approved';
                                                          unitList.add(unitObj) ;
                                                      }
        }
        if(rejectedIdSet.size()>0){
            for(Approval_Line_Item__c approvalItem : [Select Id,name,unit__c
                                                      FROM Approval_Line_Item__c WHERE Approval__c IN : rejectedIdSet]){
                                                          Unit__c unitObj = new Unit__c();
                                                          unitObj.Id = approvalItem.Unit__c;
                                                          unitObj.Submitted_For_Release_Approval__c = False;
                                                          unitObj.Release_Status__c = 'Rejected';
                                                          unitList.add(unitObj) ;
                                                      }
        }
        if(pendingIdSet.size()>0){
            for(Approval_Line_Item__c approvalItem : [Select Id,name,unit__c
                                                      FROM Approval_Line_Item__c WHERE Approval__c IN : pendingIdSet]){
                                                          Unit__c unitObj = new Unit__c();
                                                          unitObj.Id = approvalItem.Unit__c;
                                                          unitObj.Submitted_For_Release_Approval__c = False;
                                                          unitObj.Release_Status__c = 'Pending';
                                                          unitList.add(unitObj) ;
                                                      }
        }
        if(!unitList.isEmpty()){
            Update unitList;
        }
    }
}