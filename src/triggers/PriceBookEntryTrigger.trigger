/*
Class Name: PriceBookEntryTrigger
Class Description: Trigger for PriceBook_Entry__c object
Author: Karan Jain
Created Date: 25 Jan 2021
Updated by: 
Last Update Date:
*/
trigger PriceBookEntryTrigger on PriceBook_Entry__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
	PriceBookEntryTriggerHandler pbeHandler = new PriceBookEntryTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert, 
                                                                              trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
    
    SObjectType triggerType = trigger.isDelete ? 
                                trigger.old.getSObjectType() :
                                trigger.new.getSObjectType();
    Boolean disabled =  CommonUtility.isTriggerDisabled(triggerType);
    system.debug('@@disabled :'+disabled);
    if(disabled){
        return;
    }else{                                                                         
        if(trigger.isBefore){
            if(trigger.isInsert){
                pbeHandler.BeforeInsertEvent();
            }else if(trigger.isUpdate){
                pbeHandler.BeforeUpdateEvent();
            }else if(trigger.isDelete){
                pbeHandler.BeforeDeleteEvent();
            }
        }else if(trigger.isAfter){
            if(trigger.isInsert){
                pbeHandler.AfterInsertEvent();
            }else if(trigger.isUpdate){
                pbeHandler.AfterUpdateEvent();
            }else if(trigger.isDelete){
                pbeHandler.AfterDeleteEvent();
            }else if(trigger.isUndelete){
                pbeHandler.AfterUndeleteEvent();
            }
        }
    }
}