trigger InvoiceTrigger on Invoice__c (After Insert, After Update, After Delete, After Undelete) {
    InvoiceTriggerHandler handler = new InvoiceTriggerHandler(trigger.new, trigger.old, trigger.newMap, trigger.oldMap, trigger.isInsert,
                                                              trigger.isUpdate, trigger.isDelete, trigger.isUndelete, trigger.isBefore, trigger.isAfter);
    
    SObjectType triggerType = trigger.isDelete ? 
        trigger.old.getSObjectType() :
    trigger.new.getSObjectType();
    
    Boolean disabled =  CommonUtility.isTriggerDisabled(triggerType);
    
    if(disabled){
        return;
    }else{
        if(trigger.isBefore){
            if(trigger.isInsert){
                handler.BeforeInsertEvent();
            }else if(trigger.isUpdate){
                
            }else if(trigger.isDelete){
                
            }
            
        }else if(trigger.isAfter){
            if(trigger.isInsert){
            handler.handleAfterInsert();
                
            }else if(trigger.isUpdate){
                
                if(!GLOBALSTATICFLAG.BYPASSINVOICEAFTERUPDATETRIGGER){
                    handler.handlerAfterUpdate();
                    GLOBALSTATICFLAG.BYPASSINVOICEAFTERUPDATETRIGGER = true;
                }
                
            }else if(trigger.isDelete){
                handler.handleAfterDelete();
            }else if(trigger.isUndelete){
                handler.handleAfterUndelete();
            }
            
        }
        
    }
    
    
}