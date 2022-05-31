/*********************************
* Purpose :- To Automate the functionlity Related to Calling List and Calling List Line Item Object for collections.
* Created By :- Jayesh
* Date :- 19/04/2022
* Version : v1
* 
* ********************************/

public class CallingListLineItemTriggerHandler {
    
    public static boolean avoidrecussion = false;
    List<Calling_List_line_Item__c> recordNewList = new List<Calling_List_line_Item__c>();
    List<Calling_List_line_Item__c> recordOldList = new List<Calling_List_line_Item__c>();
    Map<Id, Calling_List_line_Item__c> recordNewMap = new Map<Id, Calling_List_line_Item__c>();
    Map<Id, Calling_List_line_Item__c> recordOldMap = new Map<Id, Calling_List_line_Item__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = false;
    public CallingListLineItemTriggerHandler(List<Calling_List_line_Item__c> newList, List<Calling_List_line_Item__c> oldList, Map<Id, Calling_List_line_Item__c> newMap, Map<Id, Calling_List_line_Item__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete,Boolean isBefore,Boolean isAfter) {
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
    
    public void BeforeInsertEvent() {
        
    }
    public void BeforeUpdateEvent() {
        
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
        
    }
    public void AfterUpdateEvent() {
        updateCallingList();
    }
    public void AfterDeleteEvent() {
        
    }
    public void AfterUndeleteEvent() {
        
    }
/*********************************
* Purpose :- Update calling list (paid).
* Created By :- Jayesh
* Date :- 19/04/2022
* Version : v1
* 
* ********************************/
    public void updateCallingList(){
        Set<Id> callingListIds= new Set<Id>(); 
        for(Calling_List_line_Item__c cli : recordNewList){
            if(cli.Payment_Status__c == 'Paid' && cli.Payment_Status__c != recordOldMap.get(cli.Id).Payment_Status__c){
                callingListIds.add(cli.Calling_List__c);
            } 
        }
        List <Calling_List__c> clList = new List<Calling_List__c>();
        if(callingListIds != null && callingListIds.size()>0){
            for(Calling_List__c Cl: [SELECT Id,Outcome__c,(SELECT Id,Payment_Status__c FROM Calling_List_line_Items__r WHERE Payment_Status__c!='Paid') FROM Calling_List__c WHERE ID IN : callingListIds]){
                if(cl.Calling_List_line_Items__r.size() == 0){
                    cl.Outcome__c = 'Paid';
                    cl.Remarks__c  = 'Case Closed.';
                    clList.add(cl);
                }
            }
        }
        
        if(clList != null && !clList.isEmpty()){
            try{
                Database.Update(clList,false);   
            }catch(Exception e){
                System.debug('Exception Occured : '+ e.getCause());
            }
        }
    }
}