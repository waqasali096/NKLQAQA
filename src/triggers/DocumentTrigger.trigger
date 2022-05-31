/**
* @author Karishma Kotian
* @date  09/02/2021
* @purpose - Initial Development
* @usage -Trigger on rsdoc__Document_Request__c
*/
trigger DocumentTrigger on Document__c (before insert, before update, before delete, 
                                        after insert, after update, after delete, after undelete) {

 DocumentTriggerHandler handler = new DocumentTriggerHandler(trigger.new, trigger.old, trigger.newMap, 
                                                             trigger.oldMap, trigger.isInsert, 
                                                             trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
       SObjectType triggerType = trigger.isDelete ? 
                                trigger.old.getSObjectType() :
                                trigger.new.getSObjectType();
    Boolean disabled =  CommonUtility.isTriggerDisabled(triggerType);
    system.debug('@@disabled :'+disabled);
    if(disabled){
        return;
    }else{
        if (trigger.isBefore) {
            if (trigger.isInsert) {
                handler.BeforeInsertEvent();
            } else if (trigger.isUpdate) {
                handler.BeforeUpdateEvent();
            } else if (trigger.isDelete) {
                handler.BeforeDeleteEvent();
            }
        } else if (trigger.isAfter) {
            if (trigger.isInsert) {
                handler.AfterInsertEvent();
            } else if (trigger.isUpdate) {
                handler.AfterUpdateEvent();
            } else if (trigger.isDelete) {
                handler.AfterDeleteEvent();
            } else if (trigger.isUndelete) {
                handler.AfterUndeleteEvent();
            }
        }
    }


}