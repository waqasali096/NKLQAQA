/*
Class Name:                 LeaseContract
Class Description:          To manage the Lease Contract level trigger automations.
Author:                     Shruti Khodabole
Created Date:               30/12/2022
Updated by:
Last Update Date:
*/
trigger LeaseContract on Lease_Contract__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    ContractTriggerHandler handler = new ContractTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert, 
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
            }
        }
        else if(trigger.isDelete){
            handler.AfterDeleteEvent();
        }
        else if(trigger.isUndelete){
            handler.AfterUndeleteEvent();
        }
    }
}