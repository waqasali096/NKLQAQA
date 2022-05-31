trigger ProjectTrigger on Project__c (before insert,before Update,after insert, after update) {
    
    SObjectType triggerType = trigger.isDelete ? 
                                trigger.old.getSObjectType() :
                                trigger.new.getSObjectType();
    Boolean disabled =  CommonUtility.isTriggerDisabled(triggerType);
    system.debug('@@disabled :'+disabled);
    if(disabled){
        return;
    }else{
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate) )
        {
            List<Project__c> projectWithMasterPaymentPlan = new List<Project__c>();
            List<Id> masterPaymentPlanIdList = new List<Id>();
            for(Project__c p:trigger.new){
                if(p.Master_Payment_Plan__c !=null){
                    masterPaymentPlanIdList.add(p.Master_Payment_Plan__c);
                }
            }
            Map<Id, Master_Payment_Plan__c> idToMasterPaymentPlanMap = new Map<Id, Master_Payment_Plan__c>([SELECT Id, Name, Status__c FROM Master_Payment_Plan__c WHERE Id IN:masterPaymentPlanIdList]);
            for(Project__c p:trigger.new){
                if(p.Master_Payment_Plan__c!=null){
                    if(idToMasterPaymentPlanMap.get(p.Master_Payment_Plan__c).Status__c=='Inactive'){
                        p.addError('Project can only be tagged with Acitve Master Payment Plan');
                    }
                }
            }
            ProjectTriggerHandler.beforeInsertUpdate(trigger.new, trigger.oldMap);
        }
        if(Trigger.isAfter) {
            if(Trigger.isInsert) {
                ProjectTriggerHandler.afterInsert(trigger.new);
            }
            if(Trigger.isUpdate) {
                List<Project__c> pros = new List<Project__c>();
                for(Project__c p:trigger.new){
                    if(p.Send_Project_to_ERP__c == true){
                        pros.add(p);
                    }
                }
               // Commented by Sajid
               /* if(pros!=null && pros.size()>0){
                    Commented by Sajid, dont follow the trigger pattern, in update context calling afterInsert.
                    ProjectTriggerHandler.afterInsert(pros);
                } */

                ProjectTriggerHandler.afterUpdate(trigger.newMap, trigger.oldMap); //Added by Sajid
                
            }
        }
    }
}