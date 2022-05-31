public class TaskTriggerHandler {
  
    
    List<Task> recordNewList = new List<Task>();
    List<Task> recordOldList = new List<Task>();
    Map<Id, Task> recordNewMap = new Map<Id, Task>();
    Map<Id, Task> recordOldMap = new Map<Id,Task>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public TaskTriggerHandler(List<Task> newList, List<Task> oldList, Map<Id, Task> newMap, Map<Id, Task> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
        validateFieldonCallingList();//Added By Mamta
        validateFieldonHandoverSales();//Added By Anshita
        validationForDealTasksComplition();//Added By Rohit
        validationForTitleDeedSRTaskCompletion();//Added by Anshita on 23-05-2022
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
        
    }
    public void AfterUpdateEvent() {
        updateRelatedRecordField();
        updateTask();
        UpdateFollowupOnTaskCompleted();
        updateTitleDeedCaseOnTaskComplete();
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }




    /******************************************************************************************************
    * @Description        : Function to update Checkbox of Registration on Task updation                                                                                           
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void updateRelatedRecordField(){        
        Map<Id,String> objIdFieldMap = new Map<Id,String>();
        Map<Id,String> objIdFieldMapAgreement = new Map<Id,String>();
        for(Task ts :recordNewList ){
            if(ts.WhatId != null && ts.WhatId.getSObjectType().getDescribe().getName() == 'Registration__c' && ts.Parent_Flag_API_Name__c != null && ts.Status != recordOldMap.get(ts.Id).Status && ts.Status == 'Completed'){
                objIdFieldMap.put(ts.WhatId, ts.Parent_Flag_API_Name__c);
            }else if(ts.WhatId != null && ts.WhatId.getSObjectType().getDescribe().getName() == 'Agreement__c' && ts.Parent_Flag_API_Name__c != null && ts.Status != recordOldMap.get(ts.Id).Status && ts.Status == 'Completed'){
                objIdFieldMapAgreement.put(ts.WhatId, ts.Parent_Flag_API_Name__c);
            }
        }
        if(!objIdFieldMap.isEmpty()){
            List<sObject> objList = new List<sObject>();
            for(Id objId : objIdFieldMap.keySet()){
                Registration__c obj = new Registration__c();
                obj.Id = objId;
                obj.put(objIdFieldMap.get(objId),true);
                objList.add(obj);
            }
            if(!objList.isEmpty()){
                update objList;
            }
        }
        if(!objIdFieldMapAgreement.isEmpty()){
            List<sObject> objList = new List<sObject>();
            for(Id objId : objIdFieldMapAgreement.keySet()){
                Agreement__c obj = new Agreement__c();
                obj.Id = objId;
                obj.put(objIdFieldMapAgreement.get(objId),true);
                objList.add(obj);
            }
            if(!objList.isEmpty()){
                update objList;
            }
        }
    }
    
       /**
    * Method Name: UpdateFollowupOnTaskCompleted
    * Method Description: Update the Checkbox field on Parent Object once Task will be completed
    * @param: recordNewList - List of Task  records which have Campaign Number and Campaign Name both
    * @param: GenericList- List of generic Object
    * @param: genericMethod - Used to query the record from Sobject
    * @return: Sobject                                           
*/
    Public void UpdateFollowupOnTaskCompleted()
      
    {
        Set<String> whoIDs = new Set<String>();
        Set<Id> leadId = new Set<Id>();
        
        for (Task t : this.recordNewList) {
            whoIDs.add(t.whoID);
        }
        
        Map<String, Task> taskMap = new Map<String, Task>();
        
        for (Task t : this.recordNewList){
            
            if (t.Status.equals('Completed')&& t.Parent_Flag_API_Name__c!=null) {
                if(t.WhoId != null && t.WhoId.getSObjectType().getDescribe().getName()== 'Lead' )
                {
                    leadId.add(t.WhoId);
                }
                taskMap.put(t.whoID, t);
            }                
        }
        
        
        List<SObject> GenericList = new List<SObject>();
        if(leadId.size()>0)
        {
            GenericList =genericMethod('Lead',leadId);
        }
        
        if(GenericList.size()>0)
        {
            for (SObject g : GenericList) {
                Task task = taskMap.get((ID) g.get('Id'));//Added by Sajid
               // DateTime now = system.now();
                if(String.isNotEmpty(task.Task_Type__c) &&  task.Task_Type__c == 'Qualified'){//Added by Sajid
                    g.put('SLA_Response_Time_For_Qualified__c', System.now());
                }else{
                    g.put('Follow_Up_Done__c', true);
                }
             /*   if(g.get('SLA_Response_Time__c') == Null){
                   g.put('SLA_Response_Time__c', now); 
                }*/
                
                
            }
            update GenericList;
        }
    }
    
    public List<SObject> genericMethod(string Sobjectame,set<id> ids)
    {
        string query='Select Id from '+Sobjectame+' Where Id IN:ids';
        List<SObject> nsobject = database.query(query);
        return nsobject;
    }
    
         /**
    * Method Name: updateTask
    * Method Description: Update the Checkbox field of Task Object once Task will be completed
    * @param: leadId - LSet of all Lead Ids
    * @param: leadOpenTaskId- Set of all open task Ids
    * @return: Sobject                                           
*/
     public void updateTask() {
        Set<id> leadId = new Set<id>();
        Set<Id> leadOpenTaskId = New Set<Id>();
        List<Lead> leadList = New List<Lead>();
        For(Task task : recordNewList){
            if(task.whoId != null && task.WhatId == Null){
                leadId.add(task.WhoId);
            }
        }
        For(Task task: [Select id, WhoId, Status From Task Where Status = 'Open' AND WhoId IN:leadId]){
            leadOpenTaskId.add(task.WhoId);
        }
        for(Lead lead : [Select Id, Open_Task__c From Lead Where Id IN:leadOpenTaskId]){
            lead.Open_Task__c = False;
            leadList.add(lead);
        }
        leadId.removeAll(leadOpenTaskId);
        for(Lead lead : [Select Id, Open_Task__c From Lead Where Id IN:leadId]){
            lead.Open_Task__c = True;
            leadList.add(lead);
        }
         try{
        If(!leadList.isEmpty()){
            Update leadList;
        }
         }catch(Exception ex){
             
         }
    }
    
      /******************************************************************************************************
    * @Description        : Function to validate fields on related record    
    * @Author             : Mamta Gupts                                                                                       
    * @Return             : void                                                                         
    *******************************************************************************************************/  
    public void validateFieldonCallingList(){
        Map<Id, ID> taskID_CallingLstIDMap = new Map<Id, ID> ();
        for(Task ts :recordNewList ){
            if(ts.WhatId != null && ts.WhatId.getSObjectType().getDescribe().getName() == 'Calling_List__c'&&
              recordNewMap.get(ts.ID).Status!=recordOldMap.get(ts.ID).Status && recordNewMap.get(ts.ID).Status=='Completed' && 
               (ts.Call_Outcome__c=='Refused to pay'||ts.Call_Outcome__c=='Requested For Cancellation')){
               taskID_CallingLstIDMap.put(ts.ID,ts.WhatID); 
            }
        }
        
        Map<ID, Calling_List__c> ID_callMap = new Map<ID,Calling_List__c>([select id, Cancellation_Request_Action__c ,Refused_To_Pay_Action__c  from Calling_List__c 
                                                                           WHERE ID IN:taskID_CallingLstIDMap.values()]);
        for(Task ts :recordNewList ){
            if(taskID_CallingLstIDMap.containsKey(ts.ID)){
                if(ID_callMap.get(taskID_CallingLstIDMap.get(ts.ID)).Refused_To_Pay_Action__c==null && ts.Call_Outcome__c=='Refused to pay'){
                   ts.addError('Please update refuse to pay action on calling list before completing the task'); 
                    
                }
                if(ID_callMap.get(taskID_CallingLstIDMap.get(ts.ID)).Cancellation_Request_Action__c ==null && ts.Call_Outcome__c=='Requested For Cancellation'){
               // if(ID_callMap.get(taskID_CallingLstIDMap.get(ts.ID)).Refused_To_Pay_Action__c==null && ts.Call_Outcome__c=='Requested For Cancellation'){ changed by mamta 21 may for collection
                   ts.addError('Please update Cancellation Request Action  on calling list before completing the task'); 
                    
                }
                
            }
            
        } 
    }

   /******************************************************************************************************
    * @Description        : Function to validate fields on related Handover record    
    * @Author             : Anshita Mittal                                                                                       
    * @Return             : void                                                                         
    *******************************************************************************************************/  
    public void validateFieldonHandoverSales(){
        Map<Id, ID> taskID_HandoverIDMap = new Map<Id, ID> ();
        try{
            for(Task ts :recordNewList ){
                if(ts.WhatId != null && ts.WhatId.getSObjectType().getDescribe().getName() == 'Handover__c'&&
                   recordNewMap.get(ts.ID).Status != recordOldMap.get(ts.ID).Status && recordNewMap.get(ts.ID).Status=='Completed' &&
                   (recordNewMap.get(ts.ID).Subject == NakheelTaskSubject__mdt.getInstance('HandoverTask8').Subject__c || 
                    recordNewMap.get(ts.ID).Subject == NakheelTaskSubject__mdt.getInstance('HandoverTask5').Subject__c ||
                    recordNewMap.get(ts.ID).Subject == NakheelTaskSubject__mdt.getInstance('HandoverTask3').Subject__c ||
                    recordNewMap.get(ts.ID).Subject == NakheelTaskSubject__mdt.getInstance('HandoverTask7').Subject__c)){
                        taskID_HandoverIDMap.put(ts.ID,ts.WhatID); 
                    }
                if(ts.WhatId != null && ts.WhatId.getSObjectType().getDescribe().getName() == 'Handover__c'&&
                   recordNewMap.get(ts.ID).Status != recordOldMap.get(ts.ID).Status && recordNewMap.get(ts.ID).Status=='Completed' &&
                   String.valueOf(recordNewMap.get(ts.ID).OwnerId).startsWith('00G') && recordNewMap.get(ts.ID).Subject == NakheelTaskSubject__mdt.getInstance('HandoverTask9').Subject__c){
                       ts.addError('You do not have access to complete this task'); 
                   }
            }
            if (!taskID_HandoverIDMap.isEmpty()) {
                Map<ID, Handover__c> ID_handoverMap = new Map<ID,Handover__c>([select id, Home_Orientation_Checklist_Completed__c, Bank_NOC_Uploaded__c, 
                                                                               Proof_of_Payment_Uploaded__c, Key_Handover_Form_Uploaded__c  from Handover__c 
                                                                               WHERE ID IN:taskID_HandoverIDMap.values()]);
                for(Task ts :recordNewList ){
                    if(taskID_HandoverIDMap.containsKey(ts.ID)){
                        if(ID_handoverMap.get(taskID_HandoverIDMap.get(ts.ID)).Home_Orientation_Checklist_Completed__c == false &&
                           ts.Subject == NakheelTaskSubject__mdt.getInstance('HandoverTask8').Subject__c){
                               ts.addError('Please upload Home Orientation Checklist document on Handover before completing the task'); 
                           }
                        if(ID_handoverMap.get(taskID_HandoverIDMap.get(ts.ID)).Bank_NOC_Uploaded__c == false &&
                           ts.Subject == NakheelTaskSubject__mdt.getInstance('HandoverTask5').Subject__c){
                               ts.addError('Please upload Bank NOC document on Handover before completing the task'); 
                           }
                        if(ID_handoverMap.get(taskID_HandoverIDMap.get(ts.ID)).Proof_of_Payment_Uploaded__c == false &&
                           ts.Subject == NakheelTaskSubject__mdt.getInstance('HandoverTask3').Subject__c){
                               ts.addError('Please upload Proof of Payment for pending payments on Handover before completing the task'); 
                           }
                        if(ID_handoverMap.get(taskID_HandoverIDMap.get(ts.ID)).Key_Handover_Form_Uploaded__c == false &&
                           ts.Subject == NakheelTaskSubject__mdt.getInstance('HandoverTask7').Subject__c){
                               ts.addError('Please upload Key Handover Form on Handover before completing the task'); 
                           }
                    }
                }
            }
        }
        catch(Exception e){
            System.debug('Exception on Line Number :'+ e.getLineNumber() + ', Error message :' + e.getMessage());
        }
    }

    /******************************************************************************************************
    * @Description        : Function to Add Error For Task Complition if Doc not uploaded on deal                                                                                        
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void validationForDealTasksComplition(){
        Set<Id> dealIdSet = new Set<Id>();
        //Set<Id> dealIdSetCEO = new Set<Id>();
        List<Task> taskList = new List<Task>();
        // List<Task> taskListCEO = new List<Task>();
        for(Task tsk : recordNewList){
            if(tsk.WhatID != null && tsk.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity' && tsk.Status == 'Completed' && (tsk.Parent_Flag_API_Name__c == 'Doc_Uploaded_By_Admin__c' || tsk.Parent_Flag_API_Name__c == 'Approval_Doc_From_CEO_Uploaded__c')){
                dealIdSet.add(tsk.WhatID);
                taskList.add(tsk);
            }
            // else if(tsk.WhatID != null && tsk.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity' && tsk.Status == 'Completed' && tsk.Parent_Flag_API_Name__c == 'Approval_Doc_From_CEO_Uploaded__c'){
            //     dealIdSetCEO.add(tsk.WhatID);
            //     taskListCEO.add(tsk);
            // }
        }  
        if(!dealIdSet.isEmpty()){
            Map<Id,Opportunity> oppIdMap = new Map<Id,Opportunity>([SELECT Id,Doc_Uploaded_By_Admin__c, Approval_Doc_From_CEO_Uploaded__c FROM Opportunity WHERE Id IN:dealIdSet]);
            if(!oppIdMap.isEmpty()){
                for(Task tsk : taskList){
                    if(!oppIdMap.get(tsk.WhatID).Doc_Uploaded_By_Admin__c && tsk.Parent_Flag_API_Name__c == 'Doc_Uploaded_By_Admin__c'){
                        tsk.addError('Please upload required documents.');
                    }
                    if( !oppIdMap.get(tsk.WhatID).Approval_Doc_From_CEO_Uploaded__c && tsk.Parent_Flag_API_Name__c == 'Approval_Doc_From_CEO_Uploaded__c'){
                        tsk.addError('Please upload required documents.');
                    }
                }
            }
        }  
        // if(!dealIdSetCEO.isEmpty()){
        //     Map<Id,Opportunity> oppIdMap = new Map<Id,Opportunity>([SELECT Id,Approval_Doc_From_CEO_Uploaded__c FROM Opportunity WHERE Id IN:dealIdSetCEO]);
        //     if(!oppIdMap.isEmpty()){
        //         for(Task tsk : taskListCEO){
        //             if(!oppIdMap.get(tsk.WhatID).Approval_Doc_From_CEO_Uploaded__c){
        //                 tsk.addError('Please upload required documents.');
        //             }
        //         }
        //     }
        // }  
    }

        /******************************************************************************************************
    * @Description        : Function to validate fields on related Title Deed SR record    
    * @Author             : Anshita Mittal                                                                                       
    * @Return             : void                                                                         
    *******************************************************************************************************/  
  public void validationForTitleDeedSRTaskCompletion(){
        Map<Id, ID> taskID_CaseIDMap = new Map<Id, ID> ();
        try{
            
        
            for(Task ts :recordNewList ){
                if(ts.WhatId != null && ts.WhatId.getSObjectType().getDescribe().getName() == 'Case'&&
                   recordNewMap.get(ts.ID).Status != recordOldMap.get(ts.ID).Status && recordNewMap.get(ts.ID).Status=='Completed' &&
                   recordNewMap.get(ts.ID).Subject == NakheelTaskSubject__mdt.getInstance('CaseTitleDeedTask1').Subject__c){
                       taskID_CaseIDMap.put(ts.ID,ts.WhatID); 
                   }
            }
            if (!taskID_CaseIDMap.isEmpty()) {
                Map<ID, Case> ID_CaseMap = new Map<ID,Case>([Select Id, Title_Deed_doc_sent_to_Customer__c from Case 
                                                             WHERE ID IN:taskID_CaseIDMap.values() and 
                                                             Title_Deed_doc_sent_to_Customer__c = false]);
                if(!ID_CaseMap.isEmpty()){
                    for(Task ts :recordNewList ){
                        if(taskID_CaseIDMap.containsKey(ts.ID)){
                            if(ID_CaseMap.get(taskID_CaseIDMap.get(ts.ID)).Title_Deed_doc_sent_to_Customer__c == false &&
                               ts.Subject == NakheelTaskSubject__mdt.getInstance('CaseTitleDeedTask1').Subject__c){
                                   ts.addError('Please send the Title Deed Document to customer, before completing the task.'); 
                               }
                        }
                    }
                }
                
            }
            
        }
        catch(Exception e){
            System.debug('Exception on Line Number :'+ e.getLineNumber() + ', Error message :' + e.getMessage());
        }
    }

       /******************************************************************************************************
    * @Description        : Function to update status of related Title Deed SR record after Task completion   
    * @Author             : Anshita Mittal                                                                                       
    * @Return             : void   
    * Date				  : 30-05-2022                                                                      
    *******************************************************************************************************/  
    public void updateTitleDeedCaseOnTaskComplete(){
        Set<Id> caseIds = new Set<Id>();
        try{
            for(Task ts :recordNewList ){
                if(ts.WhatId != null && ts.WhatId.getSObjectType().getDescribe().getName() == 'Case'&&
                   recordNewMap.get(ts.ID).Status != recordOldMap.get(ts.ID).Status && recordNewMap.get(ts.ID).Status=='Completed' &&
                   (recordNewMap.get(ts.ID).Subject == NakheelTaskSubject__mdt.getInstance('CaseTitleDeedTask2').Subject__c ||
                   recordNewMap.get(ts.ID).Subject == NakheelTaskSubject__mdt.getInstance('CaseTitleDeedTask3').Subject__c ||
                   recordNewMap.get(ts.ID).Subject == NakheelTaskSubject__mdt.getInstance('CaseTitleDeedTask4').Subject__c)){
                       caseIds.add(ts.WhatID); 
                   }
            }
            if (caseIds.size() > 0) {
                List<Case> caseList = [Select Id, Status from Case WHERE ID IN:caseIds and Status = 'New'];
                for(Case c : caseList){
                    c.Status = 'In Progress';
                }
                if(caseList.size() > 0){
                    update caseList;
                }
            }
        }
        catch(Exception e){
            System.debug('Exception on Line Number :'+ e.getLineNumber() + ', Error message :' + e.getMessage());
        }
    }
}