/*
@Author : Swapnil Mohite
@CreatedDate: 21/03/2022
@ This apex class will handle all trigger related functionalities of Space Type Trigger
*/
public class SpaceTypeTriggerHandler {
    List<Space_Type__c> recordNewList = new List<Space_Type__c>();
    List<Space_Type__c> recordOldList = new List<Space_Type__c>();
    Map<Id, Space_Type__c> recordNewMap = new Map<Id, Space_Type__c>();
    Map<Id, Space_Type__c> recordOldMap = new Map<Id, Space_Type__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public SpaceTypeTriggerHandler(List<Space_Type__c> newList, List<Space_Type__c> oldList, Map<Id, Space_Type__c> newMap, Map<Id, Space_Type__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
        updateSpaceTypeName(recordNewList);
    }
    public void BeforeUpdateEvent() {
        updateSpaceTypeName(recordNewList);
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
    }
    public void AfterUpdateEvent() {
		       
    }
    public void AfterDeleteEvent(){
      
    }
    public void AfterUndeleteEvent() {
    }
     /**
* This method is used to update the spacetype name.
* @date   21/03/2022
* @author Swapnil Mohite
*/
    public static void updateSpaceTypeName(List<Space_Type__c> newList){
        for(Space_Type__c spaceType : newList){
            if(spaceType.purpose__c == 'Leasing'){
                if(spaceType.leasing_type__c == 'Residential Unit'){
                    spaceType.name = spaceType.No_of_bedrooms__c  +'-'+spaceType.Property_Type__c ;
                         if(String.isNotBlank(spaceType.unit_type__c)){
                          spaceType.name = spaceType.name + '-'+ spaceType.unit_type__c;
                         }
                }else if(spaceType.leasing_type__c == 'Commercial Unit'){
                    if(String.isNotBlank(spaceType.unit_type__c)){
                        spaceType.name = spaceType.Property_Type__c +'-'+spaceType.unit_type__c ;
                    }else{
                        spaceType.name = spaceType.Property_Type__c ;
                    } 
                } 
            }
        }
        
    }
}