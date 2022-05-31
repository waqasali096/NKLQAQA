/*
Class Name: HandoverTrigger
Class Description: Trigger for Handover__c object
Author: Gaurav Malik
Created Date: 31 Jan 2021
Updated by: 
Last Update Date:
*/
trigger HandoverTrigger on Handover__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    HandoverTriggerHandler handoverHandler = new HandoverTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert, 
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
                handoverHandler.BeforeInsertEvent();
            }else if(trigger.isUpdate){
                handoverHandler.BeforeUpdateEvent();
            }else if(trigger.isDelete){
                handoverHandler.BeforeDeleteEvent();
            }
        }else if(trigger.isAfter){
            if(trigger.isInsert){
                handoverHandler.AfterInsertEvent();
            }else if(trigger.isUpdate){
                handoverHandler.AfterUpdateEvent();
            }else if(trigger.isDelete){
                handoverHandler.AfterDeleteEvent();
            }else if(trigger.isUndelete){
                handoverHandler.AfterUndeleteEvent();
            }
        }
    }
}