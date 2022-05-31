/*
Class Name: SalesEventTrigger
Class Description: Trigger on Sales Event object
Author: Gaurav Malik
Created Date:
Updated by:
Last Update Date:
*/
trigger SalesEventTrigger on Sales_Event__c (before insert, after update) {
    if(trigger.isAfter){
        if(trigger.isUpdate){
            SalesEventTriggerHandler.updateSalesStatusUnit(trigger.new, trigger.OldMap);
        }
    }
}