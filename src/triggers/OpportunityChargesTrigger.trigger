/**************************************************************************************************
* Name               : OpportunityChargesTrigger                                                      
* Description        : Trigger for Opportunity Charges
* Created Date       : 03/02/2022                                                                 
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     03/02/2022      Initial Draft.                                               
**************************************************************************************************/
trigger OpportunityChargesTrigger on Opportunity_Charges__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
OpportunityChargesTriggerHandler handler = new OpportunityChargesTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert,
                                                                          trigger.isUpdate, trigger.isDelete, trigger.isUndelete, trigger.isBefore, trigger.isAfter);
    
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