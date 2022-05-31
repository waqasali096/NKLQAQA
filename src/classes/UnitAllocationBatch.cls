/*
@Author : Swapnil Mohite
@CreatedDate: 16/01/2022
@ This batch class will handle unit share record creation and giving access to sales team.
*/
Global class UnitAllocationBatch implements Database.Batchable<sObject>, schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        date today = system.today();
        String query = 'SELECT Id,Name,Sales_Event__c,End_Date__c,Start_Date__c,User__c,Access_Given__c'+                               
            ' FROM Sales_Event_Executive__c where (Start_Date__c = today OR End_Date__c <= today)';        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Sales_Event_Executive__c> records){
        // code to update the checkbox
        system.debug('records ->'+records);
        List<Sales_Event_Executive__c> updateList = new List<Sales_Event_Executive__c>();
        for(Sales_Event_Executive__c salesEventExec : records){
            Sales_Event_Executive__c execObj = new Sales_Event_Executive__c();
            execObj.Id = salesEventExec.Id;
            if(salesEventExec.End_Date__c < system.today()){
                execObj.Access_Given__c = false;
            }else{
                execObj.Access_Given__c = true;
            }
            updateList.add(execObj);
        }
        update updateList;
    }   
    global void execute(SchedulableContext SC) {
        database.executebatch(new UnitAllocationBatch());
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}