/*
Class Name: FloorTrigger
Class Description: Trigger for Floor__c object
Author: Gaurav Malik
Created Date: 14 Jan 2021
Updated by: 
Last Update  Date:
*/
trigger FloorTrigger on Floor__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	FloorTriggerHandler floorHandler = new FloorTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert, 
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
                floorHandler.BeforeInsertEvent();
            }else if(trigger.isUpdate && !GLOBALSTATICFLAG.BYPASSFLOORBEFOREUPDATETRIGGER){
                floorHandler.BeforeUpdateEvent();
                GLOBALSTATICFLAG.BYPASSFLOORBEFOREUPDATETRIGGER = true;
            }else if(trigger.isDelete){
                floorHandler.BeforeDeleteEvent();
            }
        }else if(trigger.isAfter){
            if(trigger.isInsert){
                floorHandler.AfterInsertEvent();
            }else if(trigger.isUpdate && !GLOBALSTATICFLAG.BYPASSFLOORAFTERUPDATETRIGGER){
                floorHandler.AfterUpdateEvent();
                GLOBALSTATICFLAG.BYPASSFLOORAFTERUPDATETRIGGER = true;
            }else if(trigger.isDelete){
                floorHandler.AfterDeleteEvent();
            }else if(trigger.isUndelete){
                floorHandler.AfterUndeleteEvent();
            }
        }
    }
    
}