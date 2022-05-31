public class AssignmentResourceTriggerHandler {
List<Assignment_Resource__c> recordNewList = new List<Assignment_Resource__c>();
    List<Assignment_Resource__c> recordOldList = new List<Assignment_Resource__c>();
    Map<Id, Assignment_Resource__c> recordNewMap = new Map<Id, Assignment_Resource__c>();
    Map<Id, Assignment_Resource__c> recordOldMap = new Map<Id, Assignment_Resource__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    
    
    public AssignmentResourceTriggerHandler(List<Assignment_Resource__c> newList, List<Assignment_Resource__c> oldList, Map<Id, Assignment_Resource__c> newMap, Map<Id, Assignment_Resource__c> oldMap, 
                                     boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        
        this.recordNewList = newList;
        this.recordOldList = oldList;
        this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent() {
        
        updatestatus();
    }
    public void BeforeUpdateEvent() {
        
        //test();
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
       updateType();
    }
    public void AfterUpdateEvent() {
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }
     public void updateType(){
         Set<Id> assgnedId = new Set<Id>();
         Map<Id,String> assIdVsUserId = new Map<Id,String>();
          List<Assignment_Resource__c> assignedResListUpdate  = new List<Assignment_Resource__c>();
        for(Assignment_Resource__c res : recordNewList){
            assgnedId.add(res.Id);
        } 
       List<Assignment_Resource__c> assignedResList  = [select Engine_Instance__c,Engine_Instance__r.Engine__c,id from Assignment_Resource__c where id IN : assgnedId];
          if(assignedResList <> null && assignedResList.size() > 0){
              for(Assignment_Resource__c assi : assignedResList){
                  assIdVsUserId.put(assi.Id,assi.Engine_Instance__r.Engine__c);
              }
              for(Assignment_Resource__c resObj : recordNewList){
                    if(assIdVsUserId.containsKey(resObj.Id)){
                        Assignment_Resource__c res = new Assignment_Resource__c();
                        res.Engine_Type__c = assIdVsUserId.get(resObj.Id);
                        res.Id = resObj.Id;
                        assignedResListUpdate.add(res);
                        
                    }
              }
              if(assignedResListUpdate <> null && assignedResListUpdate.size() > 0){
            update assignedResListUpdate;
        }
          }
         
     }
    public void updatestatus(){
        Set<Id> assgnedId = new Set<Id>();
      	Map<Id,Assignment_Resource__c> assIdVsUserId = new Map<Id,Assignment_Resource__c>();
        List<Assignment_Resource__c> assignedResList  = [select Nationality__c,Language__c,User__c,id from Assignment_Resource__c];
        List<Assignment_Resource__c> assignedResListUpdate  = new List<Assignment_Resource__c>();
        for(Assignment_Resource__c res : assignedResList){
            assgnedId.add(res.Id);
            assIdVsUserId.put(res.User__c, res);
        }
      system.debug('assIdVsUserId'+assIdVsUserId);
        if(assignedResList <> null && assignedResList.size() > 0){
            for(Assignment_Resource__c resObj : recordNewList){
                //Assignment_Resource__c resObj = new Assignment_Resource__c();
                if(assIdVsUserId.containsKey(resObj.User__c)){
                    Assignment_Resource__c ress = assIdVsUserId.get(resObj.User__c);
                    system.debug('ress'+ress);
                   //resObj.id = res.Id;
                   resObj.Nationality__c = ress.Nationality__c;
                   resObj.Language__c =  ress.Language__c;
                    assignedResListUpdate.add(resObj);
                }
            }
        }
        /*if(assignedResListUpdate <> null && assignedResListUpdate.size() > 0){
            update assignedResListUpdate;
        }*/
        
    }
}