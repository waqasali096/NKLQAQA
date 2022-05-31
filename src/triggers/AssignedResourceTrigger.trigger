trigger AssignedResourceTrigger on Assignment_Resource__c (before insert,before update) {
    // To reset user workload to greatest of all resources on insertion and returning from leave
    if(Trigger.isBefore && (Trigger.isInsert||Trigger.isUpdate)){
        Map<ID,List<Assignment_Resource__c>> mapEngineIDAssignedResource = new Map<id,List<Assignment_Resource__c>>();
        List<Assignment_Resource__c> tempList;
        for(Assignment_Resource__c arLoop : Trigger.new){
            system.debug('here 1');
            if(arLoop.Adjust_Workload__c){
                if(mapEngineIDAssignedResource.containsKey(arLoop.Engine_Instance__c)){
                    mapEngineIDAssignedResource.get(arLoop.Engine_Instance__c).add(arLoop);
                }
                else{
                    tempList = new List<Assignment_Resource__c>();
                    tempList.add(arLoop);
                    mapEngineIDAssignedResource.put(arLoop.Engine_Instance__c,tempList);
                }
            }
        }
        List<Assignment_Resource__c> listActive = [Select id,Engine_Instance__c,workload__c from Assignment_Resource__c where Engine_Instance__c in :mapEngineIDAssignedResource.keySet() and isActive__c = true];
        Map<id,Decimal> mapEIIDHighestWorkload = new Map<Id,Decimal>();
        for(Assignment_Resource__c arLoop : listActive){
        
            if(mapEIIDHighestWorkload.containsKey(arLoop.Engine_Instance__c)){
                
                if(mapEIIDHighestWorkload.get(arLoop.Engine_Instance__c)<arLoop.Workload__c){
                    
                    mapEIIDHighestWorkload.put(arLoop.Engine_Instance__c, arLoop.Workload__c);
                }
            }
            else{
                
                mapEIIDHighestWorkload.put(arLoop.Engine_Instance__c, arLoop.Workload__c);
            }

        }
        for(ID idLoop :mapEngineIDAssignedResource.keySet() ){
            for(Assignment_Resource__c arLoop : mapEngineIDAssignedResource.get(idLoop)){
                    arLoop.Workload__c  = mapEIIDHighestWorkload.get(arLoop.Engine_Instance__c);
                    
                    arLoop.Adjust_Workload__c = false;
            }
        }
    }
}