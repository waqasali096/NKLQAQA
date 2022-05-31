/**
* @author : Muhammad Moneeb
* @createdDate : 21-Dec-2021
* @lastModifieddate : 21-Dec-2021
* @purpose : Initial Development
* @usage : Trigger on Case. 
*/
trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete) {
    CaseTriggerHandler handler = new caseTriggerHandler();

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
                handler.BeforeInsertEvent(trigger.new, trigger.newMap);
            }
            if(trigger.isUpdate){
                handler.BeforeUpdateEvent(trigger.new,trigger.oldMap,trigger.newMap);
            }
        }else if(trigger.isAfter){
            if(trigger.isInsert){
                handler.AfterInsertEvent(trigger.new, trigger.oldMap, trigger.newMap);
            }
            //added after update by Gaurav
            if(trigger.isUpdate){
                handler.AfterUpdateEvent(trigger.new, trigger.oldMap, trigger.newMap);
            }
        }
    }
}