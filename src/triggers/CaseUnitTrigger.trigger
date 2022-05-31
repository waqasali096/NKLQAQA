/*
Class Name: CaseUnitTrigger
Class Description: Trigger for Case_unit__c object
Author: Karishma Kotian
Created Date: 04th Mar 2022
Updated by: 
Last Update Date:
*/
trigger CaseUnitTrigger on Case_unit__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    CaseUnitTriggerHandler handler = new CaseUnitTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert, 
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
                handler.BeforeInsertEvent();
            }else if(trigger.isUpdate){
                handler.BeforeUpdateEvent();
            }else if(trigger.isDelete){
                handler.BeforeDeleteEvent();
            }
        }else if(trigger.isAfter){
            if(trigger.isInsert){
                handler.AfterInsertEvent();
            }else if(trigger.isUpdate){
                handler.AfterUpdateEvent();
            }else if(trigger.isDelete){
                handler.AfterDeleteEvent();
            }else if(trigger.isUndelete){
                handler.AfterUndeleteEvent();
            }
        }
    }
}