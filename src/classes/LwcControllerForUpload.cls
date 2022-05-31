/**
* @author : Muhammad Moneeb
* @createdDate : 22-Dec-2021
* @lastModifieddate : 22-Dec-2021
* @purpose : Initial Development
* @usage : Apex class for 'uploadButton' LWC. 
*/
public class LwcControllerForUpload {
    
    /* @usage : getDocRelatedToRec function calls from LWC 'uploadButton' used to get all document__c record with respect to record Id.*/
    @AuraEnabled(cacheable=true)
    public static List<Document__c> getDocRelatedToRec(Id recId) {
        String objectName = (recId).getSObjectType().getDescribe().getName();
        List<Document__c> docList = new List<Document__c>();
        List<Object_Document__c> docObjectList = new List<Object_Document__c>();
        Set<ID> idSet = new Set<ID>();
        if(objectName == 'Account'){
            docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Account__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                       Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                       where Account__r.Id = :recId];
        }else if(objectName == 'Special_Offer__c'){
            docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Account__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                       Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                       where Special_Offer__c = :recId];
        }else if(objectName == 'Lease_Contract__c'){
            docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Account__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                       Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                       where Contract__c = :recId];
        }else if(objectName == 'Project__c'){
            docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Account__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                       Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                       where Project__c = :recId];
        }else if(objectName == 'Agreement__c'){
            docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,SPA_Agreement__c,Account__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                       Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                       where SPA_Agreement__c = :recId];
        }else if(objectName == 'Registration__c'){
            docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,SPA_Agreement__c,Registration__c,Account__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                       Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                       where Registration__c = :recId];
        }else if(objectName == 'Unit__c'){
              //Edit By Vipul 10/05/2022 For Leasing
           Set<Id> documentIdSet = new Set<Id>();
            For( Object_Document__c obj : [Select Id,Document__c,Unit__c from Object_Document__c where Unit__c = :recId]){
                documentIdSet.add(obj.Document__c);
            }
            docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Account__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                       Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                       where Unit__c = :recId OR Id IN: documentIdSet];
            
        }else if(objectName == 'Handover__c'){
            docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Account__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                       Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                       where Handover__c = :recId];
        }else if(objectName == 'ProcessInstanceWorkitem'){ // Added By Rohit
                       //Added By Sajid p.ProcessInstance.TargetObjectId
            List<ProcessInstanceWorkitem> approvalReq = [Select p.Id, p.ProcessInstanceId, p.ProcessInstance.TargetObjectId from ProcessInstanceWorkitem p where p.Id =: recId order by createdDate Desc LIMIT 1];
           if(!approvalReq.isEmpty()){
                docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Account__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                       Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                       where Approval_Request_Id__c = :approvalReq[0].ProcessInstanceId];

                                       //Added By Sajid
                if(docList.isEmpty()){
                    docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Leads__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                               Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                               where Leads__r.Id = :approvalReq[0].ProcessInstance.TargetObjectId];
                }
            }
        }
        else if(objectName == 'Calling_List__c'){//Added By Mamta
                docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Account__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                           Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                           where Calling_List__c = :recId];
        }
        //Added by Ashok - for Document upload feature on Price_book__c
        else if(objectName == 'Price_book__c'){
            docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Account__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                       Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                       where Price_book__c = :recId];
        }
        else if(objectName == 'Opportunity' || objectName == 'Case'){
            if(objectName == 'Opportunity'){
                docObjectList = [Select Id,Name,Document__r.Id , Issue_Date_Mandatory__c ,Expiry_Date_Mandatory__c,Is_Doc_Required__c,Object_Status_Field_API_Name__c,Object_Status_Field_Value__c,Document_Number_Mandatory__c,Document__r.Document_Type__c
                                 from Object_Document__c where Opportunity__c = :recId];
            }else{
                docObjectList = [Select Id,Name,Document__r.Id , Issue_Date_Mandatory__c , Expiry_Date_Mandatory__c,Is_Doc_Required__c,Object_Status_Field_API_Name__c,Object_Status_Field_Value__c,Document_Number_Mandatory__c,Document__r.Document_Type__c
                                 from Object_Document__c where Case__c = :recId];
            }
            
            for(Object_Document__c objDoc : docObjectList){
                idSet.add(objDoc.Document__r.ID);
            }
            docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Account__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                       Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                       where Id = :idSet];
        }else if(objectName == 'Lead'){//Lead condition added by sajid
            docList = [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Leads__r.Name,Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                       Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                       where Leads__r.Id = :recId];
        }
        system.debug('docList >>'+ docList);
        return docList;
    }
    
    /* @usage : getExpIssueDate function calls from LWC 'uploadButton' used to get Issue_Date_Mandatory__c & Expiry_Date_Mandatory__c field .*/
    @AuraEnabled(cacheable=true)
    public static List<sObject> getExpIssueDate(Id objectRecID, String docName) {   
        String objectName = (objectRecID).getSObjectType().getDescribe().getName();
        if(objectName == 'Account'){
            return [SELECT Id,Name , Issue_Date_Mandatory__c ,Expiry_Date_Mandatory__c,Document_Number_Mandatory__c,Document_Type__c,Document_Number__c FROM Document__c
                    WHERE Account__c = :objectRecID AND Name= : docName];
        }
        else if(objectName == 'Opportunity' || objectName == 'Case'){
            if(objectName == 'Opportunity'){
                return [SELECT Id,Name,Document__r.Id , Document__r.Name, Issue_Date_Mandatory__c ,Expiry_Date_Mandatory__c,Document_Number_Mandatory__c,Document__r.Document_Type__c,Document__r.Document_Number__c
                        FROM Object_Document__c WHERE Opportunity__c = :objectRecID AND Document__r.Name= : docName];
            }else{
                return [SELECT Id,Name,Document__r.Id , Document__r.Name, Issue_Date_Mandatory__c ,Expiry_Date_Mandatory__c,Document_Number_Mandatory__c,Document__r.Document_Type__c,Document__r.Document_Number__c
                        FROM Object_Document__c WHERE Case__c = :objectRecID AND Document__r.Name= : docName];
            }
        }
        return null;
    }
    
    /* @usage : getRelatedFilesByRecordId function calls from LWC 'uploadButton' used to preview File with respect to document__c record Id.*/
    @AuraEnabled
    public static ID getRelatedFilesByRecordId(String docID) {
        system.debug('Inside apex ------' + docID);
        // Get record file IDs        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :docID];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        
        //Modified By Sajid ---> order by CreatedDate desc
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                                     FROM ContentVersion WHERE ContentDocumentId IN : fileIDs order by CreatedDate desc];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        system.debug('mapIdTitle >>'+ mapIdTitle);
        return docs[0].ContentDocumentId;
    } 
    
    /* @usage : uploadFile function calls from LWC 'uploadButton' used to upload File with respect to document__c record Id.*/
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId) {
        ContentVersion cv = createContentVersion(base64, filename);
        system.debug('content version created');
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
    }
    
    /* @usage : createContentVersion function used to create ContentVersion records.*/
    private static ContentVersion createContentVersion(String base64, String filename) {
        system.debug('inside cv creation');
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    /* @usage : createContentLink function used to create ContentDocumentLink records.*/
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
         system.debug('inside cdl creation');
        if (contentVersionId == null || recordId == null) { return null; }
        List<Document__c> docList = new List<Document__c>(); // Added by Sajid
        List<ContentDocumentLink> cdLinkList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
        if(cdLinkList.size() > 0){
            Delete cdLinkList;
        }
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        
        /*********** Added by Sajid ************/
        Document__c doc = new Document__c();
        
        doc.Id = recordId;
        doc.Attachment_Id__c = cdl.ContentDocumentId;
        docList.add(doc);
        /*********** Added by Sajid ************/
        try {
            insert cdl;
            system.debug('content link->'+cdl);
            if(!docList.isEmpty()){
                update docList; // Added by Sajid
            }
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    @AuraEnabled
    public static ID createObjectDocument(String documentId , Id recordIdObj , Boolean checkRelatedUnitUpload)
    {
        system.debug('###documentId-'+documentId); system.debug('###recordIdObj-'+recordIdObj);
        String objectName = (recordIdObj).getSObjectType().getDescribe().getName();
        Object_Document__c objDoc = new Object_Document__c();
        Document__c doc = [Select id,Is_Account_Linked__c from document__c where ID =: documentId];
        objDoc.Document__c = documentId;
        if(objectName != 'Account'){
            if(objectName == 'Opportunity'){
                Opportunity opp = [Select id,AccountId,RecordType.name from opportunity where ID =: recordIdObj][0];
                String recType = opp.RecordType.name;
                objDoc.Opportunity__c = recordIdObj;
                if(doc.Is_Account_Linked__c){
                    doc.Account__c = opp.AccountID;
                }
                else{
                    doc.Opportunity__c = opp.ID; //Added by Mamta 25 Jan22
                }
                
                
            }else if(objectName == 'Case') {
                Case cs = [Select id,AccountId from Case where ID =: recordIdObj][0];
                objDoc.Case__c = recordIdObj;
                if(doc.Is_Account_Linked__c){
                    doc.Account__c = cs.AccountID;
                }
            }
            else if(objectName == 'Unit__c') {
                system.debug('Inside unit');
                //Unit__c cs = [Select id from Unit__c where ID =: recordIdObj][0];
                objDoc.Unit__c = recordIdObj;
                doc.Unit__c=recordIdObj;
                
            }
            else if(objectName == 'Project__c') {
                system.debug('Inside Project');
                objDoc.Project__c = recordIdObj;
                doc.Project__c=recordIdObj;
                
            }
            else if(objectName == 'Registration__c') {
                system.debug('Inside Registration');
                objDoc.Registration__c = recordIdObj;
                doc.Registration__c=recordIdObj;
                
            }
            else if(objectName == 'Special_Offer__c') {
                system.debug('Inside Special offer');
                objDoc.Special_Offer__c = recordIdObj;
                doc.Special_Offer__c=recordIdObj;
                
            }
            else if(objectName == 'Lease_Contract__c') {
                system.debug('Inside Lease Contract');
                objDoc.Contract__c = recordIdObj;
                doc.Contract__c=recordIdObj;
                
            }
            
             else if(objectName == 'Calling_List__c') {
                system.debug('Inside calling List');
                objDoc.Calling_List__c = recordIdObj;
                doc.Calling_List__c=recordIdObj;
                
            }
            //Added by Ashok - for Document upload feature on Price_book__c
            else if(objectName == 'Price_Book__c') {
                system.debug('Inside price book');
                objDoc.Price_Book__c = recordIdObj;
                doc.Price_Book__c=recordIdObj;
                
            }//Added By Ashams - For Updating Handover lookup on Document when other files are uploaded
            else if(objectName == 'Handover__c') {
                objDoc.Handover__c = recordIdObj;
                doc.Handover__c = recordIdObj;
            }
            
            insert objDoc;
        }else{
            doc.Account__c = recordIdObj;
        }
        doc.Id = documentId;
        doc.Document_Type__c = 'Others';
        if(objectName == 'ProcessInstanceWorkitem'){ // Added By Rohit
            List<ProcessInstanceWorkitem> approvalReq = [Select p.Id, p.ProcessInstanceId, p.ProcessInstance.TargetObjectId from ProcessInstanceWorkitem p where p.Id =: recordIdObj order by createdDate Desc LIMIT 1];
            if(!approvalReq.isEmpty()){
                doc.Approval_Request_Id__c = approvalReq[0].ProcessInstanceId;
            }
        }
        update doc;
        if(checkRelatedUnitUpload){   //Edit By Vipul 10/05/2022 For Leasing
            relatedUnitUpload(documentId , recordIdObj);
        }
        return doc.ID;
    }
      //Edit By Vipul 10/05/2022 For Leasing
    private static void relatedUnitUpload(String documentId , Id recordIdObj){
        List <Unit__c> unitList = new List<Unit__c>();
        List<Object_Document__c> objectDocumentList = new List<Object_Document__c>();
        String objectName = (recordIdObj).getSObjectType().getDescribe().getName();
        
        if(objectName == 'Building__c'){
            unitList =[Select Id,Building__c,Floor__c,Project__c from Unit__c Where Building__c =: recordIdObj];  
        }
        else if(objectName == 'Floor__c'){
            unitList =[Select Id,Building__c,Floor__c,Project__c from Unit__c Where Floor__c =: recordIdObj];  
        }
        else if(objectName == 'Project__c'){
            unitList =[Select Id,Building__c,Floor__c,Project__c from Unit__c Where Project__c =: recordIdObj];  
        }
        For(Unit__c un : unitList){
            Object_Document__c objDoc = new Object_Document__c();
            objDoc.Unit__c = un.Id;
            objDoc.Document__c = documentId;
            objectDocumentList.add(objDoc);
        }
        if(objectDocumentList.size() > 0){
            Insert objectDocumentList;
        }
    }
}