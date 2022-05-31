/**
* @author Mamta Gupta
* @date  28/08/2021
* @purpose - Initial Development
* @usage - Trigger handler for ContentVersionTrigger
*/
public class ContentVersionTriggerHandler {
    
    List<ContentVersion> recordNewList = new List<ContentVersion>();
    List<ContentVersion> recordOldList = new List<ContentVersion>();
    Map<Id, ContentVersion> recordNewMap = new Map<Id, ContentVersion>();
    Map<Id, ContentVersion> recordOldMap = new Map<Id, ContentVersion>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    public ContentVersionTriggerHandler(List<ContentVersion> newList, List<ContentVersion> oldList, Map<Id, ContentVersion> newMap, Map<Id, ContentVersion> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete){ 
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
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
        system.debug('***inside after insert of content version :'+UserInfo.getUserId());
        errorOnApprovedDocument(recordNewMap);
        validationForNakheelBrokerAgents(recordNewMap);
        User usr = [select id, profile.name from user where id=:UserInfo.getUserId() LIMIt 1 ] ;
        if(usr.Profile.name==ConstantUtility.PARNTERPROFILE_Agent||
           usr.Profile.name==ConstantUtility.PARNTERPROFILE_Admin){     
           createTaskForReplacedNewVersion(recordNewList);
        }
        updateFlagOnDocument(recordNewMap);
    }
    public void AfterUpdateEvent() {
      
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }
    
	/**********************************************************************************************
    * @Description  : Method to stop Nakheel Broker Agent users to upload files
    * @Params       : Map<Id, ContentVersion> recordNewMap
    * @Return       : void 
    **********************************************************************************************/
    public static void validationForNakheelBrokerAgents(Map<Id, ContentVersion> recordNewMap){
        Id profileId = userinfo.getProfileId();
        String profileName;
        for( Profile p : [SELECT Id,Name FROM Profile WHERE Id=:profileId] ){
            profileName = p.Name;
        }

        for(ContentVersion cv : recordNewMap.values()){
            if( profileName == 'Nakheel Broker Agent' ){
                cv.addError( 'Nakheel Broker Agents are not allowed to upload the files.' );
            }
        }
    }
    
    public static void errorOnApprovedDocument(Map<Id, ContentVersion> recordNewMap){
        Set<Id> contentDocumentIdSet = new Set<Id>();
        Map<Id,List<ContentVersion>> contentDocIdConVersionListMap = new Map<Id,List<ContentVersion>>();
        Set<Id> documentToProcessSet = new Set<Id>();
        Set<Id> contentDocumentToProcess = new Set<Id>();
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get('Document__c') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        String keyPrefix = r.getKeyPrefix();
        Map<Id,Id> cd = new Map<Id,Id>();
        
        for(ContentVersion cv : recordNewMap.values()){
            contentDocumentIdSet.add(cv.ContentDocumentId);
            cd.put(cv.ContentDocumentId,cv.Id);
        }
        system.debug('contentDocumentIdSet>>>'+contentDocumentIdSet);
        system.debug('cd>>>'+cd);
        map<Id,Id> linkedEntityIdToContentVersion = new Map<Id,Id>();
        /*for(ContentVersion cv : [Select Id, ContentDocumentId from contentVersion where ContentDocumentId IN : contentDocumentIdSet]){
            contentDocumentToProcess.add(cv.ContentDocumentId);
            //contentDocIdConVersionId
        }*/
        system.debug('contentDocumentToProcess>>>>'+contentDocumentToProcess);
        for(ContentDocumentLink cdl : [Select Id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where ContentDocumentId IN :cd.keyset()]){
            system.debug('inside');
            if(String.valueOf(cdl.LinkedEntityId).startsWith(keyPrefix)){
                system.debug('inside again');
                    system.debug('doc');
                    documentToProcessSet.add(cdl.LinkedEntityId);
            }
            linkedEntityIdToContentVersion.put(cdl.LinkedEntityId,cd.get(cdl.ContentDocumentId));
        } 
        system.debug('documentToProcessSet>>>'+documentToProcessSet);
        system.debug('linkedEntityIdToContentVersion>>>'+linkedEntityIdToContentVersion);

        for(Document__c doc : [Select id,Approval_Status__c,Expiry_Date__c from Document__c where Id IN :documentToProcessSet]){
            if((doc.Approval_Status__c == 'Approved') && doc.Expiry_Date__c >= System.today()){
                system.debug('linkedEntityIdToContentVersion.get(doc.Id)>>>>'+linkedEntityIdToContentVersion.get(doc.Id));
                recordNewMap.get(linkedEntityIdToContentVersion.get(doc.Id)).addError('Cannot add new version of the document if it is not rejected.');
            }else if( doc.Approval_Status__c == 'Pending' ){
                recordNewMap.get(linkedEntityIdToContentVersion.get(doc.Id)).addError('Cannot add new version of the document if it is not rejected.');
            }
        } 
    }
    public static void updateFlagOnDocument(Map<Id, ContentVersion> recordNewMap){
        Set<Id> contentDocumentIdSet = new Set<Id>();
        Set< String > setDocumentTypes = new Set< String >();
        Map<Id,List<ContentVersion>> contentDocIdConVersionListMap = new Map<Id,List<ContentVersion>>();
        Set<Id> documentToProcessSet = new Set<Id>();
        Set<Id> contentDocumentToProcess = new Set<Id>();
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        Schema.SObjectType s = m.get('Document__c') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        String keyPrefix = r.getKeyPrefix();
        for( Broker_Documents__mdt metadataConfig : [ SELECT Id, MasterLabel FROM Broker_Documents__mdt ]){
            setDocumentTypes.add( metadataConfig.MasterLabel );
        }
        for(ContentVersion cv : recordNewMap.values()){
            contentDocumentIdSet.add(cv.ContentDocumentId);
        }
        for(ContentVersion cv : [Select Id, ContentDocumentId from contentVersion where ContentDocumentId IN : contentDocumentIdSet]){
            if (contentDocIdConVersionListMap.containsKey(cv.ContentDocumentId)) {
                contentDocIdConVersionListMap.get(cv.ContentDocumentId).add(cv);
                contentDocumentToProcess.add(cv.ContentDocumentId);
            }
            else {
                contentDocIdConVersionListMap.put(cv.ContentDocumentId, new List<ContentVersion>{ cv });
            }
        }
        for(ContentDocumentLink cdl : [Select Id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where ContentDocumentId IN :contentDocumentIdSet]){
            if(String.valueOf(cdl.LinkedEntityId).startsWith(keyPrefix)){
                if(contentDocumentToProcess.contains(cdl.ContentDocumentId)){
                    documentToProcessSet.add(cdl.LinkedEntityId);
                }
            }
        }
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        for(Document__c doc : [Select id,Account__c,Document_Type__c from Document__c where Id IN :documentToProcessSet AND Document_Type__c IN : setDocumentTypes]){
                if(doc.Document_Type__c == 'DISTRICT ONE – FZ'){
                    Account acc = new Account(Id = doc.Account__c,DISTRICT_ONE_FZ_Flag__c = True);
                    accMap.put(doc.Account__c,acc);
                } else if(doc.Document_Type__c == 'Meydan Group L.L.C'){
                    Account acc = new Account(Id = doc.Account__c,Meydan_Group_L_L_C_Flag__c = True);
                    accMap.put(doc.Account__c,acc);
                } else if(doc.Document_Type__c == 'Nakheel PJSC'){
                    Account acc = new Account(Id = doc.Account__c,Nakheel_PJSC_Flag__c   = True);
                    accMap.put(doc.Account__c,acc);
                } 
        }
        if(accMap.values().size() > 0){
            update accMap.values();
        }    
    }
    
    /*Purpose- Creates tasks for Tasks_Partner_Support_Executive Queue if new version of document has been uploaded
   * @param - contentVersions - List of new content version uploaded for already existing contentDocument*/
    
     public static void createTaskForReplacedNewVersion(List<contentVersion> contentVersions){
        Set<String> contentdocumentIds= new  Set<String>();
         for(contentVersion version:contentVersions ){
             contentdocumentIds.add(version.contentdocumentID);
           } 
         
         List<contentdocument> contentdocuments= [select id,(select id,contentdocumentId from contentVersions )from contentdocument 
                                                  WHERE ID IN:contentdocumentIds ];
        Set<String> attIDS = new Set<String>();
         for(contentdocument doc:contentdocuments ){
             system.debug('----'+doc.contentVersions.size());
             if(doc.contentVersions.size()>1){
                 attIDS.add(doc.id);
             }
        }
         
        List<Document__c> documents =[select id, Attachment_Id__c  FROM Document__c WHERE Attachment_Id__c IN:attIDS]; 
        Group qu =[select id from  Group where Type = 'Queue' AND  developername='Tasks_Partner_Support_Executive']; 
        List<Task> reviewDocsTasks = new  List<Task> ();
         for(Document__c doc: documents) {
             Task tsk = new Task();
             tsk.subject ='Review replaced document';
             tsk.WhatId= doc.Id;
             tsk.OwnerId  = qu.Id;
             
             tsk.ActivityDate=  system.today()+3;
             reviewDocsTasks.add(tsk);
         }
         
         if(reviewDocsTasks.size()>0){
             insert reviewDocsTasks;
         }
     }

}