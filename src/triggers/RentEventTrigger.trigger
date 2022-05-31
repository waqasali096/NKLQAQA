/*
Class Name: RentEventTrigger
Class Description: Trigger on Rent object
Author: Kshitij Tiwari
Created Date:16/3/2022
Updated by:
Last Update Date:
*/
trigger RentEventTrigger on Rent__c (after update, before insert) {
     RentEventTriggerHandler handler = new RentEventTriggerHandler(trigger.new, trigger.oldMap,trigger.isInsert,
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
            }
        }
      else if(trigger.isAfter){
            if(trigger.isUpdate){
                handler.AfterUpdateEvent();
            }
        }
    }
}