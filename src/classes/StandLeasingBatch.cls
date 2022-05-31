/**
    * Class Name: StandLeasingBatch
    * Class Description: To assign lead owner after 4 week of lead creation
    * @param: instanceList - List of engine instance  records to pass instance id to batch class
    * * @return: Void                                           
*/
global class StandLeasingBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(
            'SELECT ID,LeadSource,Interested_In__c,Status,RecordTypeId FROM Lead Where Lead_Stand__c = false');
    }
    global void execute(Database.BatchableContext bc, List<Lead> scope){
         String engine = '';
        List<Lead> leadLists = new List<Lead>();
         Id recordtypeidsales = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Sales Lead').getRecordTypeId(); 
        List<Engine_Instance__c> instanceList = new List<Engine_Instance__c>();
        for(Lead l : scope){
            if(l.LeadSource == 'Stands'  && l.Interested_In__c <> 'Sales'){
             engine = 'Stands Leasing'; 
                leadLists.add(l);
            }
            
        }
        system.debug('scope'+scope);
        instanceList = [select id,Engine__c from Engine_Instance__c where Engine__c =:engine];
        system.debug('instanceList'+instanceList);
        List<Lead> leadList = new List<Lead>();
        for(Lead le : leadLists){
            system.debug('le'+le);
            if(le.Status == 'Pre Qualified' || le.Status == 'New'){
                
                Lead leObj = new Lead();
                leObj.Lead_Stand__c = true;
                leObj.Id = le.Id;
                
              leadList.add(leObj);  
            }
        }
        system.debug('leadList'+leadList);
        if(leadList <> null && leadList.size() > 0){
            update leadList;
        }
        if(leadList <> null && leadList.size() > 0){
            system.debug('leadList'+leadList);
            system.debug('engine'+instanceList[0].Id);
            AssignmentEngineController.assignOnwer(instanceList[0].Id, leadList);
        }
        
    }
     global void finish(Database.BatchableContext bc){
    }

}