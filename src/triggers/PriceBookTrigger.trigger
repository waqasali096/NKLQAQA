trigger PriceBookTrigger on Price_Book__c (before insert, after insert, before Update) {
    
    SObjectType triggerType = trigger.isDelete ? 
        trigger.old.getSObjectType() :
    trigger.new.getSObjectType();
    Boolean disabled =  CommonUtility.isTriggerDisabled(triggerType);
    system.debug('@@disabled :'+disabled);
    if(disabled){
        return;
    }else{
        if(Trigger.isInsert && Trigger.isAfter){          
            PriceBookTriggerHandler.AfterInsertEvent(trigger.new);
        }else  if(Trigger.isUpdate && Trigger.isBefore){          
            PriceBookTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
        }
    }
}