trigger BuildingTrigger on Building__c (before insert, before update, after insert) {
    BuildingTriggerHandler handler = new BuildingTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert,
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
            }else if(trigger.isUpdate && !GLOBALSTATICFLAG.BYPASSBUIDLINGBEFOREUPDATETRIGGER){
                handler.BeforeUpdateEvent();
                GLOBALSTATICFLAG.BYPASSBUIDLINGBEFOREUPDATETRIGGER = true;
            }else if(trigger.isDelete){
                handler.BeforeDeleteEvent();
            }
        }else if(trigger.isAfter){
            if(trigger.isInsert){
                handler.AfterInsertEvent();
            }else if(trigger.isUpdate && !GLOBALSTATICFLAG.BYPASSBUILDINGAFTERUPDATETRIGGER){
                handler.AfterUpdateEvent();
                GLOBALSTATICFLAG.BYPASSBUILDINGAFTERUPDATETRIGGER = true;
            }else if(trigger.isDelete){
                handler.AfterDeleteEvent();
            }else if(trigger.isUndelete){
                handler.AfterUndeleteEvent();
            }
        }
    }
}