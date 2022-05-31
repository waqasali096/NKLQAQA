trigger CallingListTrigger on Calling_List__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    CallingListTriggerHandler handler = new CallingListTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert, 
                                                                      trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
    
    SObjectType triggerType = trigger.isDelete ? 
        trigger.old.getSObjectType() :
    trigger.new.getSObjectType();
    
    Boolean disabled =  CommonUtility.isTriggerDisabled(triggerType);
    
    if(disabled){
        return;
    }else{                                                                          
        if(trigger.isBefore){
            if(trigger.isInsert){
                
            }else if(trigger.isUpdate){
               handler.beforeUpdateEvent(); 
            }else if(trigger.isDelete){
                
            }
            
        }else if(trigger.isAfter){
            
            if(trigger.isInsert){
            handler.AfterInsertEvent();
                
            }else if(trigger.isUpdate && !GLOBALSTATICFLAG.BYPASSCALLINGLISTAFTERUPDATETRIGGER){
                handler.AfterUpdateEvent();
                GLOBALSTATICFLAG.BYPASSCALLINGLISTAFTERUPDATETRIGGER = true;
            }else if(trigger.isDelete){
                
            }else if(trigger.isUndelete){
                
            }
        }
    }
}