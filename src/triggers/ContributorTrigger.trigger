/**************************************************************************************************
* Name               : ContributorTrigger                                                     
* Description        : Trigger for Contributor
* Created Date       : 04/02/2022                                                                 
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     04/02/2022      Initial Draft.                                               
**************************************************************************************************/
trigger ContributorTrigger on Contributor__c ( before insert, before update, before delete, after insert, after update, after delete, after undelete ) {

    ContributorTriggerHandler handler = new ContributorTriggerHandler( trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert,
                                                                      trigger.isUpdate, trigger.isDelete, trigger.isUndelete, trigger.isBefore, trigger.isAfter);
    
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType() : trigger.new.getSObjectType();

    // Boolean disabled =  CommonUtility.isTriggerDisabled(triggerType);
    // system.debug('@@disabled :'+disabled);
    // if(disabled){
    //     return;
    // }else{
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
   // }
}