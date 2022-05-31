trigger unitOptionTrigger on Unit_Option__c (before insert,before update) {
	
    if(Trigger.isBefore){
        system.debug('line 4 in unit option trigger');
        //unitOptionTriggerHandler.process(trigger.new);
    }
}