/*
Class Name: AvailablePaymentPlanTrigger
Class Description: Trigger on Availabe_Payment_Plan__c object
Author: Sajid Hameed
Created Date: 02 March 2022
Updated by: 
Last Update Date: 
*/
trigger AvailablePaymentPlanTrigger on Availabe_Payment_Plan__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    AvailablePaymentPlanTriggerHandler handler = new AvailablePaymentPlanTriggerHandler(trigger.new, trigger.old, 
                                                                                        trigger.newMap, trigger.oldMap,
                                                                                        trigger.isInsert, trigger.isUpdate, 
                                                                                        trigger.isDelete, trigger.isUndelete);
    
    if(trigger.isBefore){
        if(trigger.isInsert){
            
        }else if(trigger.isUpdate){
            
        }else if(trigger.isDelete){
            
        }
    }else if(trigger.isAfter){
        if(trigger.isInsert){
            
        }else if(trigger.isUpdate){
            handler.AfterUpdateEvent();
        }else if(trigger.isDelete){
            
        }else if(trigger.isUndelete){
            
        }
    }
    
}