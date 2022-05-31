trigger EmiratesIdPE on Emirates_Id__e (after insert) {
    
    SObjectType triggerType = trigger.isDelete ? 
                                trigger.old.getSObjectType() :
                                trigger.new.getSObjectType();
    Boolean disabled =  CommonUtility.isTriggerDisabled(triggerType);
    system.debug('@@disabled :'+disabled);
    if(disabled){
        return;
    }else{
        for(Emirates_Id__e e:trigger.new){
            System.debug('--->'+ e.Date_of_birth__c );
        }
    }

}