/*
Class Name: ProjectTriggerHandler.
Class Description: Updating Payment Plan on Units while adding or updaitng Payment on Project.
Author: Karan Jain
Created Date: 12/05/2021
Updated by: Vishal Agrawal
Last Update Date: 12/01/2022
*/

public class ProjectTriggerHandler {
     
    static Set<Id> projectIdsHavingPaymentPlan = new Set<Id>();
    static Map<Id, String> projectPaymentPlanMap = new Map<Id,String>();
    static List<Unit__c> units =new List<Unit__c>();
    
    public static void beforeInsertUpdate(List<Project__c> newProjectList, Map<Id,Project__c> oldMap) {
        //Commented by Husain to fix CPU time limit error
        for(project__c ins: newProjectList){
            if(oldMap == null) {
                ins.Send_Project_to_ERP__c = true;
            }
        }
        
        if(oldMap != null) {
            erpProjectCreation(newProjectList,oldMap);
        }
        
        updateProjectDetails(newProjectList,oldMap); //Added by Shivani - 6th April 2022
        
    }
    
    public static void afterInsert(List<Project__c> newProjectList) {
        erpProjectCreation(newProjectList,null);
        
        GenericTriggerHandler.createDocRecord(newProjectList, 'Project__c');
        
        Group financeTeamQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Finance_Team'];
        list<Task> taskToInsertList = new list<Task>();
        
        for(Project__c projectRecord : newProjectList){
            if(projectRecord.Project_Purpose__c == 'Sales'){
                Task task = createTask('Update the bank and master payment plan on project', projectRecord.Id, financeTeamQueue.Id);
                taskToInsertList.add(task);
            }            
        }
        
        if(taskToInsertList.isEmpty() == false){
            insert taskToInsertList;
        }
        
    }
    
    /***** @Author: Sajid H *****/
    public static void afterUpdate(Map<Id,Project__c> newProjectMap, Map<Id,Project__c> oldProjectMap) {
        attachLandlordSignatureToDocument(newProjectMap, oldProjectMap);
        updateUnits(newProjectMap, oldProjectMap);
    }
    
    public static void erpProjectCreation(List<Project__c> newProjectList, Map<Id,Project__c> oldProjectMap) {
        Set<Id> projIds = new Set<Id>();
        for(project__c proj: newProjectList) {
            if(proj.Send_Project_to_ERP__c && (oldProjectMap == null || proj.Send_Project_to_ERP__c != oldProjectMap.get(proj.Id).Send_Project_to_ERP__c )) {
                projIds.add(proj.Id);
                if(oldProjectMap != null) {
                    proj.Send_Project_to_ERP__c = false;
                }
            }
        }
        if(!projIds.isEmpty()) {
            createProject(projIds);
        }
    }
    
     /*Method: updateERPInvoice
     * Desc:  Create Project in ERP
     * Param: Project - Set of Project Ids
     * Return: None
     */
     //@Future(Callout=true)
    public Static void createProject(Set<Id> projectId) {
        ERPIntegrationHelper.projectCreation(projectId);
    }
    /**
    * This method is used to update bussiness details on in Unit Record.
    * @date   06/06/2022
    * @author Shivani Rathi
    */
    public static void updateProjectDetails(List<Project__c> newList, Map<Id,Project__c> oldMap){
        Set<String> bussinessUnitIds = new Set<String>();
        for(Project__c objProjects : newList){
            if(String.isNotBlank(objProjects.Business_Unit__c) || (oldMap != null && oldMap.get(objProjects.Id).Business_Unit__c != objProjects.Business_Unit__c)){
                bussinessUnitIds.add(objProjects.Business_Unit__c);
            }
        }
        Map<Id,Business_Unit__c> mapProject = new Map<Id,Business_Unit__c>([SELECT ID,Business_Group__c, Business_Unit_Purpose__c FROM Business_Unit__c WHERE ID IN : bussinessUnitIds]);
        for(Project__c objProjects : newList){
            if(String.isNotBlank(objProjects.Business_Unit__c) && mapProject.containsKey(objProjects.Business_Unit__c)){
                objProjects.Business_Group__c = mapProject.get(objProjects.Business_Unit__c).Business_Group__c;
                objProjects.Project_Purpose__c = mapProject.get(objProjects.Business_Unit__c).Business_Unit_Purpose__c;
            }
        }
    }
    
    /********************************************************************************************** 
    * @Description  : Method to attach landlord signature to document object.
    * @Return       : void
    * @Author       : Sajid 21-04-2022
    **********************************************************************************************/
    
    public static void attachLandlordSignatureToDocument(Map<Id, Project__c> newMap, Map<Id, Project__c> oldMap){
        Set<ID> recordSet = newMap.keySet();
        Set<ID> verifiedIds = new Set<ID>();
        Boolean hasRecord = false;
        Set<ID> captureContDocId = new Set<ID>();
        Set<ID> contentVersionId = new Set<ID>();
        
        for(ID recordId : recordSet){
            System.debug('RecordNewMapMoneIn: '+newMap.get(recordId).Landlord_Signature_Uploaded__c);
            System.debug('RecordOldMapMoveIn: '+oldMap.get(recordId).Landlord_Signature_Uploaded__c);

            if(((newMap.get(recordId).Landlord_Signature_Uploaded__c  == true) && (oldMap.get(recordId).Landlord_Signature_Uploaded__c != true))){
                   System.debug('@@@@@ Phase 2 @@@@@');
                   verifiedIds.add(recordId);
                   hasRecord = true;
               }
        }
        
        if(hasRecord){
            
            List<Project__c> updatedProjectContatiner = new List<Project__c>();
            List<Project__c> updateProject = [Select id, Landlord_Signature_Uploaded__c from Project__c where id in :verifiedIds];
            
            for(Project__c project : updateProject){
                if(project.Landlord_Signature_Uploaded__c == true){
                    project.Landlord_Signature_Uploaded__c = false;
                }
                updatedProjectContatiner.add(project);
            }
            
            Map<ID,ID> contentDocumentLinkMap = new Map<ID,ID>();
            List<ContentDocumentLink> allIds = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :verifiedIds];
            System.debug('ContentDocumentLink: '+JSON.serialize(allIds));
            for(ContentDocumentLink cl : allIds){
                contentDocumentLinkMap.put(cl.LinkedEntityId, cl.ContentDocumentId);
            } 
            
            System.debug('contentDocumentLinkMap: '+contentDocumentLinkMap);
            System.debug('[V] allIds '+allIds);
            
            for(ContentDocumentLink c : allIds){
                System.debug('Phase 3 ContentDocumentLink '+c);
                captureContDocId.add(c.ContentDocumentId);
                
            }
            System.debug('[V] captureContDocId '+captureContDocId);
            
            Map<ID,ContentVersion> contentVersionMap = new Map<ID,ContentVersion>();
            List<ContentVersion> contentVersionList = [Select Id,ContentDocumentId, ContentUrl,VersionData,Title,PathOnClient from ContentVersion where ContentDocumentId in :captureContDocId ];
            for(ContentVersion cv : contentVersionList){
                System.debug('Phase 4 ContentVersion '+cv);
                contentVersionMap.put(cv.ContentDocumentId, cv);
                contentVersionId.add(cv.id);
            }
            System.debug('[V] contentVersionMap '+contentVersionMap);
            
            List<Id> docList = new List<Id>();
            Map<ID,ID> obDocMap = new Map<ID,ID>();  
            List<Object_Document__c> objDocument = [Select id, Project__c, Document__c from Object_Document__c where Project__c in :verifiedIds];
            for(Object_Document__c obj : objDocument){
                obDocMap.put(obj.Document__c,obj.Project__c);
                docList.add(obj.Document__c);
            }
            
            
            List<Document__c> documents = [Select id, Project__c, Project__r.Landlord_Signature_Uploaded__c,
                                            Attachment_Id__c, Document_Type__c from Document__c where id in :docList];
            Map<Document__c,ID> documentHandoverMap = new Map<Document__c,ID>();
            Set<ID> documentId = new Set<ID>();
            
            
            for(Document__c doc : documents){
                System.debug('Phase 5 Document '+doc);
                documentHandoverMap.put(doc,doc.Project__c);
            }
            List<Document__c> updateDocumentOperation = new List<Document__c>();
            List<ContentVersion> insertContentVersion = new List<ContentVersion>();
            List<ContentDocumentLink> insertContentDocumentLink = new List<ContentDocumentLink>();
            Set<Id> docId = new Set<Id>();
            
            Map<Id,Project__c> projectDetails = new Map<Id,Project__c>();
            Map<Id,List<ContentVersion>> contentVersionsToproject = new Map<Id,List<ContentVersion>>();
            String emailTemplateName;
            
            for(Document__c doc : documents){
                if((doc.Document_Type__c == 'Landlord Signature' && doc.Project__r.Landlord_Signature_Uploaded__c)){
                       
                       
                       System.debug('Phase 6 Document and Handover ===>'+doc);
                       
                       projectDetails.put(doc.Project__c, newMap.get(doc.Project__c));
                       
                       Id contentDocumentId = contentDocumentLinkMap.get(doc.Project__c);
                       
                       ContentVersion contentVersionProject = contentVersionMap.get(contentDocumentId);
                       
                       ContentVersion contentVersionDocument = new ContentVersion();
                       contentVersionDocument.ContentDocumentId = contentDocumentId;
                       contentVersionDocument.Title = contentVersionProject.Title;
                       contentVersionDocument.PathOnClient = contentVersionProject.PathOnClient;
                       contentVersionDocument.VersionData = contentVersionProject.VersionData;
                       insertContentVersion.add(contentVersionDocument);
                       
                       
                       contentVersionsToproject.put(doc.Project__c , insertContentVersion);
                       
                       
                       ContentDocumentLink cdLinkDocument = new ContentDocumentLink();
                       cdLinkDocument.LinkedEntityId = doc.Id;
                       cdLinkDocument.ContentDocumentId = contentDocumentId;
                       insertContentDocumentLink.add(cdLinkDocument);
                       
                       doc.Attachment_Id__c = contentDocumentId;
                       doc.Project__c = obDocMap.get(doc.id);
                       updateDocumentOperation.add(doc);  
                    
                   }
            }  
            
            try{
                System.debug('@@@@@ Before Update: '+updatedProjectContatiner);
                update updatedProjectContatiner;
                update updateDocumentOperation;
                //insert insertContentVersion;
                insert insertContentDocumentLink;  
            }
            catch (Exception ex){
                system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
            }  
            
        }
    }
    
    /** 
    * @createdDate : 19 May 2022  
    * @author : Husain Sayyed
    * @Version : V1
    * @usage : update units fields on Project fields change
    **/
    public static void updateUnits(Map<Id, Project__c> newMap, Map<Id, Project__c> oldMap){
        map<string, string> fieldMaping = new map<string, string>{
            'DLD_Area_Name__c' => 'DLD_Area_Name__c',
            'DLD_Nakheel_Share__c' => 'DLD_Nakheel_Share__c',
            'DLD_Customer_Share__c' => 'DLD_Customer_Share__c',
            'Master_Payment_Plan__c' => 'Master_Payment_Plan__c'
        }; 
            
        map<Id, Project__c> projectMap = new map<Id, Project__c>();
        list<Unit__c> unitToUpdateList = new list<Unit__c>();
        
        for(Project__c project : newMap.values()){
            for(string sourceFieldName : fieldMaping.keySet()){
                if(project.get(sourceFieldName) != oldMap.get(project.Id).get(sourceFieldName)){
                    projectMap.put(project.Id, project);
                }
            }
        }
        
        if(projectMap.isEmpty() == false){
            for(Unit__c unitRecord : [select Id,Project__c from Unit__c where Project__c in : projectMap.keySet()]){
                if(projectMap.containsKey(unitRecord.Project__c)){
                    boolean isFieldChange = false;
                    for(string sourceFieldName : fieldMaping.keySet()){
                        string targerFieldName = fieldMaping.get(sourceFieldName);
                        unitRecord.put(targerFieldName, projectMap.get(unitRecord.Project__c).get(sourceFieldName));
                        isFieldChange = true;
                    }
                    if(isFieldChange){
                        unitToUpdateList.add(unitRecord);
                    }                
                }
            }
        }
        
         
        if(unitToUpdateList.isEmpty() == false){
            update unitToUpdateList;
        }
    }
    
    /** 
    * @createdDate : 22 May 2022  
    * @author : Husain Sayyed
    * @Version : V1
    * @usage : Create Task on Project creation
    **/
    public static Task createTask(String subject, Id whatId, Id ownerId){
        Task taskObj = new Task();
        taskObj.Subject= subject;
        taskObj.WhatId = whatId;
        taskObj.OwnerId= ownerId;
        taskObj.Priority = 'Normal';
        taskObj.Status = 'Open';
        taskObj.ActivityDate = System.today() + 2;
        return taskObj;
    }
    
}