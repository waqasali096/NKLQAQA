public class LeaveTriggerHandler {
    List<Leave_Request__c> recordNewList = new List<Leave_Request__c>();
    List<Leave_Request__c> recordOldList = new List<Leave_Request__c>();
    Map<Id, Leave_Request__c> recordNewMap = new Map<Id, Leave_Request__c>();
    Map<Id, Leave_Request__c> recordOldMap = new Map<Id, Leave_Request__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public LeaveTriggerHandler(List<Leave_Request__c> newList, List<Leave_Request__c> oldList, Map<Id, Leave_Request__c> newMap, Map<Id, Leave_Request__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
       
    }
    public void BeforeUpdateEvent() {
       
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
       
    }
    public void AfterUpdateEvent() {
       	updateDates();	
       
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
        //DeleteDate();
    }
    public void updateDates(){
        
        List<Assignment_Resource__c> assingedResList = new List<Assignment_Resource__c>();
       
        for(Leave_Request__c leave : recordNewList){
            if(leave.Status__c == 'Approved'){
                Assignment_Resource__c res = new Assignment_Resource__c();
                res.Leave_Start_Date__c = leave.Leave_Start_Date__c;
                res.Leave_End_Date__c = leave.Leave_End_Date__c;
                res.Id = leave.Sales_Resource__c;
                assingedResList.add(res);
           
            }
           else if (leave.Status__c == 'Canceled'){
                Assignment_Resource__c AssignResource = new Assignment_Resource__c();
                AssignResource.Leave_Start_Date__c =null;
               AssignResource.Leave_End_Date__c =null;
               AssignResource.Id = leave.Sales_Resource__c;
               assingedResList.add(AssignResource);
           }
        }
        if(assingedResList <> null && assingedResList.size() > 0){
            update assingedResList;
        }
    }
    
 
    
    

}