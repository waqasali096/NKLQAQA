/*********************************
 * Purpose :- To Automate the functionlity Related to Calling List and Calling List Line Item Object for collections.
 * Created By :- Jayesh
 * Date :- 19/04/2022
 * Version : v1
 * 
 * ********************************/

trigger CallingListLineItemTrigger on Calling_List_line_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	CallingListLineItemTriggerHandler handler = new CallingListLineItemTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert,
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
}