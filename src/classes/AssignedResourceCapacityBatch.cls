/**
    * Class Name: AssignedResourceCapacityBatch
    * Class Description: To empty capcity field on daily basis.
    * @param: instanceList - List of engine instance  records to pass instance id to batch class
    * * @return: Void                                           
*/
global class AssignedResourceCapacityBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(
            'SELECT ID, Dev_Capacity__c FROM Assignment_Resource__c');
    }
    global void execute(Database.BatchableContext bc, List<Assignment_Resource__c> scope){
        List<Assignment_Resource__c> resourceUpdateList = new List<Assignment_Resource__c>();
        for(Assignment_Resource__c res : scope){
            Assignment_Resource__c resObj = new Assignment_Resource__c();
           resObj.Dev_Capacity__c = 0;
           resObj.Id = res.Id;
            resourceUpdateList.add(resObj);
        }
        if(resourceUpdateList <> null && resourceUpdateList.size() > 0){
            update resourceUpdateList;
        }
    }
     global void finish(Database.BatchableContext bc){
    }

}