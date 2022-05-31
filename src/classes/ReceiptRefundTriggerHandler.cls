/**
* Name:          ReceiptRefundTriggerHandler
* Description:   Trigger Handler for Receipt_Refund Trigger
* Author         Vishal Agrawal
*/
public class ReceiptRefundTriggerHandler {
    List<Receipt_Refund__c> recordNewList = new List<Receipt_Refund__c>();
    List<Receipt_Refund__c> recordOldList = new List<Receipt_Refund__c>();
    Map<Id, Receipt_Refund__c> recordNewMap = new Map<Id, Receipt_Refund__c>();
    Map<Id, Receipt_Refund__c> recordOldMap = new Map<Id, Receipt_Refund__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    
    public static Boolean isRefundRecursive = false;
    
    public ReceiptRefundTriggerHandler(List<Receipt_Refund__c> newList, List<Receipt_Refund__c> oldList, Map<Id, Receipt_Refund__c> newMap, Map<Id, Receipt_Refund__c> oldMap, 
                                  boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete, Boolean isBefore, Boolean isAfter){
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
    
    
    public void beforeInsertEvent(){
        
    }
    
    public void AfterInsertEvent() {
        createRefundERP();
    }
    
    public void BeforeUpdateEvent() {
        if(isRefundRecursive == false) {
            createRefundERP();
        }
    }
    
    public void AfterUpdateEvent() {
        
    }
    
    public void BeforeDeleteEvent() {  
        
    }
    
    public void AfterUndeleteEvent() {
        
    }
    
    public void AfterDeleteEvent() {
       
    }
    
     /**
    * This method is used to check checkbox criteria to Send Refund to ERP.
    * @author Vishal A
    */
    public void createRefundERP(){
        Set<Id> recRefIds = new Set<Id>();
        
        for(Receipt_Refund__c recRef : recordNewList){
            if(recRef.Send_Refund_to_ERP__c && recRef.ERP_Refund_Id__c == null && (recordOldMap == null || recRef.Send_Refund_to_ERP__c != recordOldMap.get(recRef.Id).Send_Refund_to_ERP__c)){
                recRefIds.add(recRef.Id);
                if(recordOldMap != null) {
                    recRef.Send_Refund_to_ERP__c = false;
                }
            }
        }
        if(!recRefIds.isEmpty()){
            isRefundRecursive = true;
            ERPIntegrationHelper.createRefundERP(recRefIds);
        }
    } 
}