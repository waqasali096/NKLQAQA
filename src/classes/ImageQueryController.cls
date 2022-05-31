public class ImageQueryController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> retriveFloorImages(String recordId){
        List<Document__c> documents = QueryDocumentObject(recordId);
        Set<Id> documentId  = new Set<Id>();
        Set<ID> captureDocumentIds = new Set<Id>();
        List<ID> contentVersionIds = new List<ID>();
        List<String> urlCollector = new List<String>();
        for(Document__c doc : documents){
            if(doc.Document_Type__c == 'Floor Plans'){
                documentId.add(doc.id);
            }
        }
        if(documentId.size() > 0){
            List<ContentDocumentLink> contentLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:documentId];
            
            for(ContentDocumentLink content : contentLink){
                captureDocumentIds.add(content.ContentDocumentId);
            }
            
            List<ContentVersion> contentVersionList = [Select Id,ContentDocumentId, ContentUrl from ContentVersion where ContentDocumentId in :captureDocumentIds ];
            System.debug('ContentVersionList : '+contentVersionList);
            for(ContentVersion c : contentVersionList){
                contentVersionIds.add(c.Id);
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                String formedUrl = baseUrl + '/sfc/servlet.shepherd/version/download/' + c.Id; //Added by Jayesh to get dynamic URL.
                urlCollector.add(formedUrl);
                formedUrl = null;
            }
            
            return urlCollector;
        }else{
            return null;
        }
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> retriveUnitImages(String recordId){
        List<Document__c>  documents = QueryDocumentObject(recordId);
        Set<Id> documentId  = new Set<Id>();
        Set<ID> captureDocumentIds = new Set<Id>();
        List<ID> contentVersionIds = new List<ID>();
        List<String> urlCollector = new List<String>();
        for(Document__c doc : documents){
            if(doc.Document_Type__c == 'Unit Plans'){
                documentId.add(doc.id);
            }
        }
        if(documentId.size() > 0){
            List<ContentDocumentLink> contentLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:documentId];
                        
            for(ContentDocumentLink content : contentLink){
                captureDocumentIds.add(content.ContentDocumentId);
            }
            
            List<ContentVersion> contentVersionList = [Select Id,ContentDocumentId, ContentUrl from ContentVersion where ContentDocumentId in :captureDocumentIds ];
            
            for(ContentVersion c : contentVersionList){
                contentVersionIds.add(c.Id);
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                String formedUrl = baseUrl + '/sfc/servlet.shepherd/version/download/' + c.Id; //Added by Jayesh to get dynamic URL.
                urlCollector.add(formedUrl);
                formedUrl = null;
            }
            
            return urlCollector;
            
        }else{
            return null;
        }
    }
    
    
    public static List<Document__c> QueryDocumentObject(String recordId){
        List<Document__c>  documents = [Select id, Document_Type__c from Document__c where Unit__c =:recordId];
        return documents;
    }
}