public class UserTriggerHandler {
    List<User> recordNewList = new List<User>();
    List<User> recordOldList = new List<User>();
    Map<Id, User> recordNewMap = new Map<Id, User>();
    Map<Id, User> recordOldMap = new Map<Id, User>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    public UserTriggerHandler(List<User> newList, List<User> oldList, Map<Id, User> newMap, Map<Id, User> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
    public void AfterInsertEvent() {

    }
    public void BeforeUpdateEvent() {

    }
    public void AfterUpdateEvent() {
        syncUserToERP(recordNewList,recordOldMap);
    }
    public void beforeDeleteEvent(){

    }
    public void afterDeleteEvent(){
        
    }
    public void afterUnDeleteEvent(){ 
        
    }

    /********************************************************************************************** 
    * @Description  : Method to sync user in ERP system
    * @Params       : List<User>, Map<Id,User>
    * @Return       : void
    * @Author       : Karishma Kotian
    **********************************************************************************************/
    public void syncUserToERP(List<User> recordNewList, Map<Id, User> recordOldMap){
        system.debug('inside sync User to ERP Method'+recordNewList);
        set<Id> employeeUserSet = new set<Id>();
        for(User user : recordNewList){
            if(user.ERP_User_Id__c == null && user.Send_User_to_ERP__c && user.Send_User_to_ERP__c != recordOldMap.get(user.Id).Send_User_to_ERP__c /*&& user.EmployeeNumber != null*/){
                employeeUserSet.add(user.Id);
            }
        }
        if(!employeeUserSet.isEmpty()){
            ERPIntegrationHelper.getUserDetails(employeeUserSet);
        }
    }
}