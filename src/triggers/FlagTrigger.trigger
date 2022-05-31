/**************************************************************************************************
* Name               : FlagTrigger                                                      
* Description        : FlagTrigger
* Created Date       : 21/03/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      21/03/2022      Initial Draft.                                               
**************************************************************************************************/

trigger FlagTrigger on Flag__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    FlagTriggerHandler handler = new FlagTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert, 
                                                        trigger.isUpdate, trigger.isDelete, trigger.isUndelete,  trigger.isBefore, trigger.isAfter);
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
                if(RecursionController.isFirstTime){
                    RecursionController.isFirstTime = false;
                    handler.AfterUpdateEvent();
                }
            }else if(trigger.isDelete){
                handler.AfterDeleteEvent();
            }else if(trigger.isUndelete){
                handler.AfterUndeleteEvent();
            }
        }
    }
}