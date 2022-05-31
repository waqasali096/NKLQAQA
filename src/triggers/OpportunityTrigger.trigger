/*
Class Name:                 OpportunityTrigger
Class Description:          Runs whenever DML operation occurs on Opportunity
Author:                     Lakshaya Sharma
Created Date:               12/20/2021
Updated by:
Last Update Date:
*/

trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    // trigger to call sms api
     OpportunityTriggerHandler handler = new OpportunityTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert,
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
        }else if(trigger.isUpdate){
            handler.BeforeUpdateEvent(trigger.new,trigger.oldMap,trigger.newMap);
        }else if(trigger.isDelete){
            handler.BeforeDeleteEvent();
        }
    }else if(trigger.isAfter){
        if(trigger.isInsert){
            handler.AfterInsertEvent(trigger.new);
        }else if(trigger.isUpdate){
            handler.AfterUpdateEvent();
        }else if(trigger.isDelete){
            handler.AfterDeleteEvent();
        }else if(trigger.isUndelete){
            handler.AfterUndeleteEvent();
        }
    }
    }
    // Commented by Rohit Sharma, added all the logic inside the TriggerHandler
    // if(trigger.isAfter){
    //     if(trigger.isUpdate){
    //         handler.updatestatus();
    //         handler.createSPARecord();
    //         handler.createOppPaymentMilestones();
    //         handler.updateUnitStatus();
    //         for(Opportunity oppRecord : trigger.new){
    //             if((trigger.oldMap.get(oppRecord.id).stageName != 'Booking Initiated' && trigger.newMap.get(oppRecord.id).stageName == 'Booking Initiated' ) || (trigger.oldMap.get(oppRecord.id).stageName != 'Booking Confirmed' && trigger.newMap.get(oppRecord.id).stageName == 'Booking Confirmed')){
    //                 Unit_HandlerSMS.callSmsApiFromOpportunity(trigger.new);
    //             }
    //         }  
    //     }
    // }
    // if(trigger.isAfter){
    //     if(trigger.isInsert){
    //         handler.createOppPaymentMilestones();
    //         handler.AfterInsertEvent(trigger.new);
    //     }
    // }
    // if(trigger.isBefore){
    //     if(trigger.isUpdate){
    //         handler.updateDiscount();
    //         handler.beforeUpdateEvent(trigger.new,trigger.oldMap,trigger.newMap);
    //     }
    // }
}