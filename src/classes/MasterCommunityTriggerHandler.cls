/**
* Name:          MasterCommunityTriggerHandler
* Description:   Trigger Handler for Master Community Trigger
* Author         Vishal Agrawal
*/
public class MasterCommunityTriggerHandler {
    List<Master_Community2__c> recordNewList = new List<Master_Community2__c>();
    List<Master_Community2__c> recordOldList = new List<Master_Community2__c>();
    Map<Id, Master_Community2__c> recordNewMap = new Map<Id, Master_Community2__c>();
    Map<Id, Master_Community2__c> recordOldMap = new Map<Id, Master_Community2__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    
    Public Static Boolean blnRecursivPDCRC = false;
    
    public MasterCommunityTriggerHandler(List<Master_Community2__c> newList, List<Master_Community2__c> oldList, Map<Id, Master_Community2__c> newMap, Map<Id, Master_Community2__c> oldMap, 
                                 boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete, Boolean isBefore, Boolean isAfter){
        this.recordNewList = newList;
        this.recordOldList = oldList;
        this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
        this.isBefore = isBefore;
        this.isAfter = isAfter;        
    }
    
    public void BeforeInsertEvent() {
        for(Master_Community2__c mastCom : recordNewList){
            mastCom.Send_Master_Community_ERP__c = true;
        }
    }
    
    public void beforeUpdate() {
        createMasterCommInERP();
    }
    
    public void afterInsert() {
       createMasterCommInERP();
    }
    
    public void createMasterCommInERP(){
        Set<Id> mastCommId = new Set<Id>();
        
        for(Master_Community2__c mastCom : recordNewList){
            if(mastCom.Send_Master_Community_ERP__c && (recordOldMap == null || mastCom.Send_Master_Community_ERP__c != recordOldMap.get(mastCom.Id).Send_Master_Community_ERP__c)){
                mastCommId.add(mastCom.Id);
                if(recordOldMap != null) {
                    mastCom.Send_Master_Community_ERP__c = false;
                }
            }
        }
        if(!mastCommId.isEmpty()){
            createMasterCommunity(mastCommId);
        }
    }
    
    /*Method: createMasterCommunity
* Desc:  Create Master Community in ERP
* Param: Master Community - Set of MasterCommunity Ids
* Return: None
*/
    //@Future(Callout=true)
    public Static void createMasterCommunity(Set<Id> masterCommIds) {
        ERPIntegrationHelper.createMasterCommunity(masterCommIds);
    }
}