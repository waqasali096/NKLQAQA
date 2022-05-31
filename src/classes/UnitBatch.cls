/**
    * Class Name: UnitBatch
    * Class Description: Change Unit status
    * @param: instanceList - If payment is not received update unit and opportunity status to available
    * * @return: Void                                           
*/

global class UnitBatch implements Database.Batchable<sObject> {
     global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String status = 'On Hold';
        string soql =  'SELECT ID,Unit_Status__c,Master_Payment_Plan__c FROM Unit__c where Date_when_Leasing_status_changes__c < LAST_N_DAYS:1';
        return Database.getQueryLocator(soql);
    }
     global void execute(Database.BatchableContext bc, List<Unit__c> scope){
         List<Unit__c> unlistUpdate = new List<Unit__c>();
         Set<Id> unitId = new Set<Id>();
         Set<Id> oppId = new Set<Id>();
         List<Opportunity> oppListUpdate = new List<Opportunity>();
         
         
         system.debug('scope'+scope);
         if(scope <> null && scope.size() > 0){
         for(Unit__c unitObj : scope){
             if(unitObj.Unit_Status__c == 'On Hold'){
            unitId.add(unitObj.Id);
             }
         }
        
         List<Unit_Plan__c> unlist = [select unit__c,id,opportunity__c from Unit_Plan__c where Unit__c IN :unitId];
          for(Unit_Plan__c unitPlan : unlist){
              oppId.add(unitPlan.opportunity__c);
          }
          
          for(Unit__c unitObj : scope){
              Unit__c uni = new Unit__c();
              uni.Id = unitObj.Id;
              uni.Unit_Status__c = 'Available';
              unlistUpdate.add(uni);
          }
         
        
          
         List<Opportunity> opplist = [select id,stageName from Opportunity where id IN : oppId AND Booking_Mode__c = 'Reservation without token amount' AND Receipt_Generated__c = false];
         if(opplist <> null && opplist.size() > 0){
         for(Opportunity oppIds : opplist){
             Opportunity oppObj = new Opportunity();
             oppObj.Id = oppIds.Id;
             oppObj.Unit_Status__c = 'Unassigned';
             oppObj.StageName = 'Closed Lost';
             oppObj.Loss_Reason__c = 'Other';
             oppObj.Other_Reason__c = 'Booking amount not received';
             oppListUpdate.add(oppObj);
         }
         }
         
         
         
         
         system.debug('opplist'+opplist);
         if(opplist <> null && opplist.size() > 0){
         if(unlistUpdate <> null && unlistUpdate.size() > 0){
             update unlistUpdate;
         }
         
        
         if(oppListUpdate <> null && oppListUpdate.size() > 0){
             update oppListUpdate;
         }
         }
         }
     }
    global void finish(Database.BatchableContext bc){
    }
}