/*
Class Name: UnitTrigger
Class Description: Trigger on Unit__c object
Author: Gaurav Malik
Created Date: 
Updated by: Gaurav Malik
Last Update Date: 24 Jan 2022
*/
trigger UnitTrigger on Unit__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    UnitTriggerHandler handler = new UnitTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert, 
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
            }else if(trigger.isUpdate && !GLOBALSTATICFLAG.BYPASSUNITBEFOREUPDATETRIGGER){
                handler.BeforeUpdateEvent();
                GLOBALSTATICFLAG.BYPASSUNITBEFOREUPDATETRIGGER = true;
            }else if(trigger.isDelete){
                handler.BeforeDeleteEvent();
            }
        }else if(trigger.isAfter){
            if(trigger.isInsert){
                handler.AfterInsertEvent();
            }else if(trigger.isUpdate && !GLOBALSTATICFLAG.BYPASSUNITAFTERUPDATETRIGGER){
                handler.AfterUpdateEvent();
                GLOBALSTATICFLAG.BYPASSUNITAFTERUPDATETRIGGER = true;
            }else if(trigger.isDelete){
                handler.AfterDeleteEvent();
            }else if(trigger.isUndelete){
                handler.AfterUndeleteEvent();
            }
        }
        
        /*if(trigger.isBefore){
            if(trigger.isInsert){
                //update Project Type from parent Project
                UnitTriggerHandler.updateUnitProjectType(trigger.new);
            }
        }*/
        // trigger to call sms api 
    /*  if(trigger.isAfter){
            if(Trigger.isUpdate){
            Unit_HandlerSMS.triggerSmsApi(trigger.new);        
        } 
        } */
    }
}