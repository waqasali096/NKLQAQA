public class CallingListTriggerHandler {
    List<Calling_List__c> newList = new List<Calling_List__c>();
    List<Calling_List__c> oldList = new List<Calling_List__c>();
    Map<Id, Calling_List__c> newMap = new Map<Id, Calling_List__c>();
    Map<Id, Calling_List__c> oldMap = new Map<Id, Calling_List__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public CallingListTriggerHandler(List<Calling_List__c> newList, List<Calling_List__c> oldList, Map<Id, 
                                     Calling_List__c> newMap, Map<Id, Calling_List__c> oldMap, boolean isInsert, 
                                     boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.newList = newList;
        this.oldList = oldList;
        this.newMap = newMap;
        this.oldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void AfterInsertEvent() {
        tagCollectionExective_onReceipts();//Added By Mamta 12 April
        GenericTriggerHandler.createDocRecord( newList, 'Calling_List__c'); //Added by Jayesh on 25 April.
        
    }
    
    public void BeforeUpdateEvent() {
    makeRecordReadOnlyAfterPaid();    
    }
    
    public void AfterUpdateEvent() {
        createHistoryRecord(newList,oldMap,'Calling_List__c');
        createTasks(newMap, oldMap);
        //tagCollectionExective_onReceipts();//Added By Mamta 12 April
        
        completeAllRelatedTasks();//added by Jayesh 19 April
       // sendNoResponseEmail();//Added By Mamta 15 May

    }
    
    
/******************************************************************************************************
* @Description        : Move Record Type to Read Only
* @Return             : void                                                                         
*******************************************************************************************************/    
    public  void makeRecordReadOnlyAfterPaid(){
        for (Calling_List__c cl : newList){
            if(oldMap.get(cl.Id).Outcome__c != cl.Outcome__c && cl.Outcome__c=='Paid'){
               cl.RecordTypeId =  Schema.SObjectType.Calling_List__c.getRecordTypeInfosByDeveloperName().get('Read_Only').getRecordTypeId(); 
            }
        }
    }
    
    
    /******************************************************************************************************
* @Description        : Create Tasks on Calling list
* @Return             : void                                                                         
*******************************************************************************************************/
    public static void createTasks(Map<Id, Calling_List__c> newCallListMap, Map<Id, Calling_List__c> oldCallingListMap){
        Group gp =[select id from Group where type='Queue' AND DeveloperName=:system.label.Front_Office_Queue ];
        List<Task> tskList = new List<Task>();
        List<Calling_List__c> docForMortageLst = new List<Calling_List__c>();
        for (Calling_List__c cl : newCallListMap.values()){
            if(oldCallingListMap.get(cl.Id).Outcome__c != cl.Outcome__c){
                String followupSubj = system.label.Follow_Up_task_subject ;
                List<String> outcomes = new List<String>{'Under Negotiation' ,'Unreachable/No Response'}; //
                    if (outcomes.contains(cl.Outcome__c)){
                        
                        Task t  = new Task();
                        if(cl.Outcome__c=='Unreachable/No Response'){
                            t.Subject= 'Customer not reachable/no response-  first followup action';
                        }
                        else{
                            t.Subject= followupSubj + cl.Name + '- '+ cl.Outcome__c ;
                        }
                        t.ActivityDate=Date.today()+2; 
                        t.WhatId=cl.Id;
                        t.OwnerId=cl.OwnerId;
                        t.Call_Outcome__c = cl.Outcome__c;
                        t.Description = followupSubj + cl.Name + '- '+ cl.Outcome__c + '  - first outcome followup';
                        t.Outcome_Task_Number__c =1;
                        tskList.add(t);
                    }
                
                
                
                if (cl.Outcome__c == 'Callback Request'){
                    Task t  = new Task();
                    t.Subject=followupSubj + cl.Name + '- '+ cl.Outcome__c + '  - first outcome followup';
                    t.ActivityDate=cl.Callback_Date__c+1; //as per shravya
                    t.WhatId=cl.Id;
                    t.OwnerId=cl.OwnerId;
                    t.Call_Outcome__c = cl.Outcome__c;
                    t.Outcome_Task_Number__c =1; 
                    t.Description = t.Subject;
                    
                    tskList.add(t);
                }
                
                if (cl.Outcome__c == 'Promised to pay'){
                    Task t  = new Task();
                    t.Subject=followupSubj + cl.Name + '- '+  cl.Outcome__c;
                    t.ActivityDate=cl.Promise_To_Pay_Date__c; 
                    t.WhatId=cl.Id;
                    t.OwnerId=cl.OwnerId;
                    t.Call_Outcome__c = cl.Outcome__c;
                    t.Outcome_Task_Number__c =1;
                    t.Description = t.Subject;
                    
                    tskList.add(t);
                }
                
                if (cl.Outcome__c == 'Requested For Cancellation'){
                    Task t  = new Task();
                    t.Subject='Needful action for customer cancellation request - '+ cl.Name;
                    t.ActivityDate=System.today(); 
                    t.WhatId=cl.Id;
                    t.Call_Outcome__c = cl.Outcome__c;
                    t.Description = t.Subject;
                    t.OwnerId=cl.OwnerId; //here we have to assign this to Manager. But not sure how to get the manager.
                    //tskList.add(t);
                }
                
                if (cl.Outcome__c == 'Mortgage Under Process'){
                    Task t  = new Task();
                    t.Subject= 'Please upload Pre Approval Document';
                    t.ActivityDate=Date.today()+2; 
                    t.WhatId=cl.Id;
                    t.OwnerId=gp.ID;
                    t.Call_Outcome__c = cl.Outcome__c;
                    t.Outcome_Task_Number__c =1;
                    t.Description = t.Subject;
                    
                    tskList.add(t);
                    docForMortageLst.add(cl);
                }
                /*Code Start: Added by Jayesh, Desc: Create new Task for Proof of Transfer Date: 22 April 2022*/
                if (cl.Outcome__c == 'Proof of Transfer'){
                    Task t  = new Task();
                    t.Subject= 'Kindly Upload Cash Deposit Receipt or Telex Transfer copy Documents';
                    t.ActivityDate=Date.today()+2; 
                    t.WhatId=cl.Id;
                    t.OwnerId=cl.OwnerId;
                    t.Call_Outcome__c = cl.Outcome__c;
                    t.Description = t.Subject;
                    
                    tskList.add(t);
                    
                }
                /*Code Ends: Jayesh*/
            }
        }
        //Modified below code Start: best Practice Check : Added by Jayesh Dated: 22 April 2022
        if (tskList.size()>0 && tskList != null){  
            try{
                insert tskList;
            }catch(Exception e){
                System.debug('Exception Occured: ' + e.getCause() + ' at '+ e.getLineNumber() + ' '+ e.getMessage());
            }
        }
        //Modification ENDS:Jayesh
        
        if(docForMortageLst.size()>0){
            //GenericTriggerHandler.createDocRecord(docForMortageLst , 'Calling_List__c');//Commented by Mamta- Not required as we are creating placeholders in insert only
            
            
        }
    }
    
    /******************************************************************************************************
* @Description        : Create History Record on Calling List                                                                                     
* @Return             : void                                                                         
*******************************************************************************************************/
    public static void createHistoryRecord(List<sObject> newList,Map<ID,sObject> oldMap ,String objectName){
        List<History_Management__mdt> hmList = [Select id,Field_API_Name__c,Field_Label_Name__c from History_Management__mdt 
                                                where Object_Name__c =: objectName];
        system.debug('hmList**' + hmList);
        List<History__c> historyObjectList = new List<History__c>();
        for(History_Management__mdt hm : hmList){
            for(sObject obj :newList){
                if(obj.get(hm.Field_API_Name__c) != oldMap.get(obj.ID).get(hm.Field_API_Name__c)){
                    History__c hist = new History__c ();
                    hist.Field_Name__c = hm.Field_Label_Name__c;
                    hist.New_Value__c = String.valueof(obj.get(hm.Field_API_Name__c));
                    hist.Old_Value__c = String.valueof(oldMap.get(obj.ID).get(hm.Field_API_Name__c));
                    hist.Calling_List__c = obj.ID;
                    historyObjectList.add(hist);
                }
            }
        }
        system.debug('historyObjectList Size**' + historyObjectList.size());
        if(historyObjectList.size() > 0){
            Database.insert(historyObjectList,false);
        }
    }
    
    /******************************************************************************************************
* @Description        : Tag collection executive to receipt 
* @Author             :  Mamta                                                                                     
* @Return             : void                                                                         
*******************************************************************************************************/
    
    public void tagCollectionExective_onReceipts(){
        List<Calling_List_line_Item__c> clItems = [select id, Payment_Milestone__c ,Calling_List__r.OwnerID from Calling_List_line_Item__c 
                                                   WHERE Calling_List__c IN :newList];
        Map<ID,ID> payMilestoneIDMap_OwnerIDMap = new Map<ID, ID>();
        for(Calling_List_line_Item__c cl : clItems){
            payMilestoneIDMap_OwnerIDMap.put(cl.Payment_Milestone__c , cl.Calling_List__r.OwnerID);
            
        }
        
        List<Payment_Milestone__c> pms =[select id,collection_Executive__c from Payment_Milestone__c WHERE ID IN:payMilestoneIDMap_OwnerIDMap.keySet()];
        for(Payment_Milestone__c pm : pms){
            pm.collection_Executive__c = payMilestoneIDMap_OwnerIDMap.get(pm.collection_Executive__c);
            
        }
        
        List<Receipt__c>  receipts =[select id , collection_Executive__c from Receipt__c WHERE Payment_Milestone__c IN: payMilestoneIDMap_OwnerIDMap.keySet()];
        for(Receipt__c rc : receipts ){
            rc.collection_Executive__c = payMilestoneIDMap_OwnerIDMap.get(rc.collection_Executive__c);
        }
        try{
            update pms;
            update receipts;
        }
        catch(Exception ex){
            system.debug('ex is '+ ex.getMessage() + ' at'+ ex.getLineNumber());
        }
        
        
        
        
    }
    
    
/*********************************
* Purpose :- Task update when calling list outcome is paid.
* Created By :- Jayesh
* Date :- 19/04/2022
* Version : v1
* 
* ********************************/
    public void completeAllRelatedTasks() {
        
        
        List<Id> callingListIds = new List<Id>(); 
        for(Calling_List__C cl : newList){
            
            if(cl.Outcome__c == 'Paid' && cl.Outcome__c != oldMap.get(cl.Id).Outcome__c){
                
                callingListIds.add(cl.Id);
                
            }
            
            List<Task> taskList = [SELECT Id,WhatId,Status FROM Task WHERE WhatId IN : callingListIds AND Status != 'Completed'];
            
            for(Task t : taskList){
                
                t.status = 'Completed';
            }
            if(taskList.size()>0){
                
                Database.Update(taskList,false);
            }
                        
        }
    }
}