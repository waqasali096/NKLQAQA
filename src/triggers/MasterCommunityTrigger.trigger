trigger MasterCommunityTrigger on Master_Community2__c (before insert,before update, after insert) {
    MasterCommunityTriggerHandler handler = new MasterCommunityTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert,
                                                              trigger.isUpdate, trigger.isDelete, trigger.isUndelete, trigger.isBefore, trigger.isAfter);

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
            }
            if(trigger.isUpdate){
                handler.beforeUpdate();
            }
        }
        if(trigger.isAfter){
            if(trigger.isInsert){
                handler.afterInsert();
            }
        }
    }
}