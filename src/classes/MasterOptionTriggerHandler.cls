/**************************************************************************************************
* Name               : MasterOptionTriggerHandler                                                      
* Description        : Handler class for MasterOptionTrigger
* Created Date       : 10/05/2022                                                                  
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     10/05/2022      Initial Draft.                                               
**************************************************************************************************/
public class MasterOptionTriggerHandler {
    List<Master_Option__c> recordNewList = new List<Master_Option__c>();
    List<Master_Option__c> recordOldList = new List<Master_Option__c>();
    Map<Id, Master_Option__c> recordNewMap = new Map<Id, Master_Option__c>();
    Map<Id, Master_Option__c> recordOldMap = new Map<Id, Master_Option__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = false;
    
    public MasterOptionTriggerHandler( List<Master_Option__c> newList, 
                                   List<Master_Option__c> oldList, 
                                   Map<Id, Master_Option__c> newMap, 
                                   Map<Id, Master_Option__c> oldMap, 
                                   boolean isInsert, 
                                   boolean isUpdate, 
                                   Boolean isDelete, 
                                   Boolean isUndelete, 
                                   Boolean isBefore, 
                                   Boolean isAfter){
                                       this.recordNewList = newList;
                                       this.recordOldList = oldList;
                                       this.recordNewMap = newMap;
                                       this.recordOldMap = oldMap;
                                       this.isInsert = isInsert;
                                       this.isUpdate = isUpdate;
                                       this.isDelete = isDelete;
                                       this.isUndelete = isUndelete;
                                       this.isBefore = isBefore;
                                       this.isAfter = isAfter;        
                                   }
    
    public void AfterInsertEvent() {
    }
    public void AfterUpdateEvent() {
    }
    public void BeforeInsertEvent() {
        populateMasterOptionName();
    }
    public void BeforeUpdateEvent() {
        populateMasterOptionName();
    }

    public void BeforeDeleteEvent() {
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }


    /******************************************************************************************************
    * @Description        : Update Master Option Name  
    * Date                : 10/05/2022
    * Author              : Rhoit Sharma                                                                   
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void populateMasterOptionName(){
        for(Master_Option__c mo : recordNewList){
            if(mo.Option_Name__c != null){
                mo.Name = mo.Option_Name__c;
            }
        }
    }
}