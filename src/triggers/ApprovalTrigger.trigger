/*
Class Name:                 ApprovalTrigger
Class Description:          Controller to handle operations for Approval
Author:                     Swapnil Mohite
Created Date:               1/20/2022
Updated by:
Last Update Date:
*/
trigger ApprovalTrigger on Approval__c(before insert, before update, before delete, after insert, after update, after delete, after undelete){
    ApprovalTriggerHandler handler = new ApprovalTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert, 
                                                                            trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
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