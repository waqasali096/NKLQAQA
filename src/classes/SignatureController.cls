/*
* Description: This Class is to upload signature captured at component level
* Author: Swapnil Mohite
* Created Date: 11/11/2021
* Name: SignatureController
*/
public class SignatureController {
/**
* This method is used upload signature
* @date   11/11/2021
* @author  Swapnil Mohite
*/    
     @AuraEnabled
    public static void saveSignature(String base64Data,String parentId){
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');   O
        ContentVersion contentVersion = new ContentVersion(
            Title= 'LANDLORD_SIGNATURE ' + system.now(), 
            PathOnClient ='LANDLORD_SIGNATURE' + system.now()+'.png',
            VersionData = EncodingUtil.base64Decode(base64Data), 
            origin = 'H'
        );
        insert contentVersion;
        
        ContentVersion tempContentVersion = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = parentId;
        contentlink.contentdocumentid = tempContentVersion.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        //Commented by Sajid, not being used now, Landlord_Signature__c is updated by ContentDocumentLinkHandler
        /*
        ContentDistribution cdl = new ContentDistribution();
        cdl.ContentVersionId = contentVersion.Id;
        cdl.Name = 'OWNER_SIGNATURE';
        insert cdl;
       
        
        ContentDistribution cdURL=[Select Id,  Name, ContentVersionId, ContentDocumentId, DistributionPublicUrl, ContentDownloadUrl from ContentDistribution where ContentVersionId=: tempContentVersion.Id Limit 1];
        Project__c project = new Project__c();
        project.Landlord_Signature__c = cdURL.ContentDownloadUrl;
        project.id = parentId;
        update project;
       
        if(Id.valueOf(parentId).getsobjecttype() == Case.sobjecttype){
            //closeCase(parentId);
        }
 	*/
    }
    
    
     @AuraEnabled
    public static void tenantSaveSignature(String base64Data,String parentId){
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');   O
        ContentVersion contentVersion = new ContentVersion(
            Title= 'TENANT_SIGNATURE' + system.now(), 
            PathOnClient ='TENANT_SIGNATURE' + system.now()+'.png',
            VersionData = EncodingUtil.base64Decode(base64Data), 
            origin = 'H'
        );
        insert contentVersion;
        
        ContentVersion tempContentVersion = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = parentId;
        contentlink.contentdocumentid = tempContentVersion.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
		
        ContentDistribution cdl = new ContentDistribution();
        cdl.ContentVersionId = contentVersion.Id;
        cdl.Name = 'TENANT_SIGNATURE';
        insert cdl;
        
        ContentDistribution cdURL = [Select Id,  Name, ContentVersionId, ContentDocumentId, DistributionPublicUrl, ContentDownloadUrl from ContentDistribution where ContentVersionId =: tempContentVersion.Id Limit 1];
        
        Lease_Contract__c cont = new Lease_Contract__c();
        cont.Tenant_Signature_URL__c = cdURL.ContentDownloadUrl;
        cont.id = parentId;
        update cont;
        
        
        
        if(Id.valueOf(parentId).getsobjecttype() == Case.sobjecttype){
            //closeCase(parentId);
        }
    }
/**
* This method is used Close case after signature captured - for vehicle and building pass for now.
* @date   11/11/2021
* @author  Swapnil Mohite
*/    
    
    /*public static void closeCase(String parentId){
        //Case caseObj = CaseService.getCaseRecord(parentId);
        Id vehicleRecId = CommonUtility.recordTypeIdByDevName(Case.SObjectType,ConstantUtility.CS_RT_VEHICLE_ACCESS_CARD);
        Id buildingRecId = CommonUtility.recordTypeIdByDevName(Case.SObjectType,ConstantUtility.CS_RT_BLDING_ACCESS_CARD);
        //if(caseObj.RecordTypeId == vehicleRecId || caseObj.RecordTypeId == buildingRecId){
         //   caseObj.Status = ConstantUtility.CASE_STATUS_CLOSED;
        //}
        //CaseService.updateCase(new List<Case>{caseObj});
    }   */ 
    
}