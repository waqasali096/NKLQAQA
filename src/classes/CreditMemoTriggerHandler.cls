/**************************************************************************************************
* Name               : CreditMemoTriggerHandler 
* Description        : Handler class for Credit Memo Trigger
* Created Date       : 09/03/2022                                                                 
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Cloudworks    09/03/2022      Initial Draft.                                               
**************************************************************************************************/
public class CreditMemoTriggerHandler {
    
    List<Credit_Memo__c> recordNewList = new List<Credit_Memo__c>();
    List<Credit_Memo__c> recordOldList = new List<Credit_Memo__c>();
    Map<Id, Credit_Memo__c> recordNewMap = new Map<Id, Credit_Memo__c>();
    Map<Id, Credit_Memo__c> recordOldMap = new Map<Id, Credit_Memo__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    public CreditMemoTriggerHandler(List<Credit_Memo__c> newList, List<Credit_Memo__c> oldList, Map<Id, Credit_Memo__c> newMap, Map<Id, Credit_Memo__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
        createCreditMemosERP();
    }
    
    public void AfterInsertEvent() {
       createCreditMemosERP();
    }

    public void AfterUpdateEvent() {
        
    }

    public void BeforeDeleteEvent() {
    }

    public void AfterDeleteEvent() {
    }

    public void AfterUndeleteEvent() {
    }
    
     /**********************************************************************************************
    * @Description  : Method to create Credit memo in ERP system
    * @Params       : List< Credit_Memo__c > newList
    * @Param        : Map< Id, Credit_Memo__c > oldMap
    * @Return       : void
    * @Author       : Vishal A
    **********************************************************************************************/
    public void createCreditMemosERP(){
        Set<Id> creditId = new Set<Id>();
        
        for(Credit_Memo__c creditMemo : recordNewList){
            if(creditMemo.Send_Credit_Memo_to_ERP__c && creditMemo.ERP_CreditMemo_Id__c  == null && (recordOldMap == null || creditMemo.Send_Credit_Memo_to_ERP__c != recordOldMap.get(creditMemo.Id).Send_Credit_Memo_to_ERP__c)){
                creditId.add(creditMemo.Id);
                if(recordOldMap != null) {
                    creditMemo.Send_Credit_Memo_to_ERP__c = false;
                }
            }
        }
        if(!creditId.isEmpty()){
            ERPIntegrationHelper.createCreditMemo(creditId);
        }
    }
}