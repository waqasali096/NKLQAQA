/*
Class Name:                 SpecialOfferTriggerHandler
Class Description:          Trigger Handler for Special Offers
Author:                     Swapnil Mohite
Created Date:               12/19/2021
Updated by:
Last Update Date:
*/
public class SpecialOfferTriggerHandler {
    List<Special_Offer__c> recordNewList = new List<Special_Offer__c>();
    List<Special_Offer__c> recordOldList = new List<Special_Offer__c>();
    Map<Id, Special_Offer__c> recordNewMap = new Map<Id, Special_Offer__c>();
    Map<Id, Special_Offer__c> recordOldMap = new Map<Id, Special_Offer__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
 public SpecialOfferTriggerHandler(List<Special_Offer__c> newList, List<Special_Offer__c> oldList, Map<Id, Special_Offer__c> newMap, Map<Id, Special_Offer__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
        validateBeforeUpdate(recordNewList);
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
       GenericTriggerHandler.createDocRecord(recordNewList,'Special_Offer__c');
    }
    public void AfterUpdateEvent() {
      
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }
    /**
* This method is will validate the update
* @date   16/01/2022
* @author Swapnil Mohite
*/
    public static void validateBeforeUpdate(List<Special_Offer__c> newList){
        for(Special_Offer__c spOffer : newList){
            if(spOffer.Is_Document_Uploaded__c == false && spOffer.Approval_status__c == 'Pending 1st Level'){
                spOffer.addError('Please upload required documents');
            }
        }
    }
      /**
* This method is used to remove visibility for unit on Sales Event Unit deletion.
* @date   17/01/2022
* @author Swapnil Mohite
*/
   
}