/**
* @author : Ashams
* @createdDate : 07-Apr-202w
* @lastModifieddate : 
* @purpose : Initial Development
* @usage : Trigger on OfferApplied. 
*/
trigger OfferAppliedTrigger on Offer_Applied__c (before insert, before update, before delete, after insert, after update, after delete) {
    OfferAppliedTriggerHandler handler = new OfferAppliedTriggerHandler();
    SObjectType triggerType = trigger.isDelete ? trigger.old.getSObjectType():trigger.new.getSObjectType();
    Boolean disabled =  CommonUtility.isTriggerDisabled(triggerType);
    
    if(disabled){
        return;
    }else{
        if(trigger.isBefore){
            if(trigger.isInsert){
                
            }
            if(trigger.isUpdate){
                
            }
            if(trigger.isDelete){
                
            }
        }else if(trigger.isAfter){
            if(trigger.isInsert){
                handler.AfterInsertEvent(trigger.new, trigger.oldMap, trigger.newMap);
            }
            if(trigger.isUpdate){
               
            }
            if(trigger.isDelete){
                handler.AfterDeleteEvent(trigger.old, trigger.oldMap, trigger.newMap);
            }
        }
    }
}