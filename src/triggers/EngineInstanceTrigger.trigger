/*
* Author - Huzefa Tarwala
* Date - 20 Oct 2019
* Description - Trigger to create fields, activate/deactivate engine. Validation to avoid deletion of engine.
*/

trigger EngineInstanceTrigger on Engine_Instance__c (after insert,before update,before delete) {
    //Create fields required for functioning of the engine
    if(Trigger.isAfter && Trigger.isInsert){
        EngineInstanceHelper helper = new EngineInstanceHelper();
        
        List<Id> listEIID = new List<Id>();
        for(Engine_Instance__c eiLoop : Trigger.new){

            listEIID.add(eiLoop.id);

        }
        
        helper.listEIID = listEIID; 
        System.enqueueJob(helper);
    }

    if(Trigger.isBefore && Trigger.isUpdate){
        for(Engine_Instance__c eiLoop : Trigger.new){
            //Check if engine was started but got stuck due to some issue
            if(eiLoop.Active__c && !Trigger.oldMap.get(eiLoop.id).Active__c && !String.isBlank(eiLoop.Scheduled_Job_ID__c)){
                eiLoop.AddError('An existing job seems to be active for this engine. Please delete the Job and clear Job ID before activating.');
            }

            //If engine being started normally
            if(eiLoop.Active__c && !Trigger.oldMap.get(eiLoop.id).Active__c && String.isBlank(eiLoop.Scheduled_Job_ID__c)){

                AssignmentEngineScheduler scheduleEngine = new AssignmentEngineScheduler(eiLoop.id);
                eiLoop.Scheduled_Job_ID__c =  System.schedule(eiLoop.SObject__c +' Assignment Engine', '0 0 * * * ?' , scheduleEngine);
                eiLoop.status__c='RUNNING'; 
       
            }

            //If engine is being stopped
            if(!eiLoop.Active__c && Trigger.oldMap.get(eiLoop.id).Active__c && !String.isBlank(eiLoop.Scheduled_Job_ID__c)){
                System.abortJob(eiLoop.Scheduled_Job_Id__c);
                eiLoop.Scheduled_Job_ID__c = '';
                eiLoop.status__c='STOPPED';
            }

            if(eiLoop.Run_Once__c && !Trigger.oldMap.get(eiLoop.id).Run_Once__c ){
                AssignmentEngineInstance engineInstance = new AssignmentEngineInstance(eiLoop.id);
                //Parameters of ExecuteBatch(context,BatchSize)
                database.executebatch(engineInstance);
                eiLoop.Run_Once__c = false;
            }


        }

    }
    // Validation to avoid deletion of engine
    if(Trigger.isBefore && Trigger.isDelete){
        /*for(Engine_Instance__c eiLoop : Trigger.new){
            eiLoop.addError('Engine Instance cannot be deleted, please deactivate the instance if its not needed');
        }*/
    }
}