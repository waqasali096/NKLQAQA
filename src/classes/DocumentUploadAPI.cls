/*
Name: DocumentUploadAPI
Purporse: Upload Documents using API
Author: Husain Sayyed
*/
@RestResource(urlMapping='/DocumentUpload')
global class DocumentUploadAPI {
    @HttpPost
    global static ResponseBody uploadDodument(){
        try{
            ResponseBody responseBody = new ResponseBody();
            string requestBody = RestContext.request.requestBody.toString();
            system.debug('==requestBody=='+requestBody);
            
            //list<RequestBody> requestData = (list<RequestBody>)JSON.deserialize(requestBody, list<RequestBody>.class);
            RequestBody requestData = (RequestBody)JSON.deserialize(requestBody, RequestBody.class);
            system.debug('==requestData=='+requestData);
            
            map<string, list<RequestBody>> locationCodeWithRequestMap = new map<string, list<RequestBody>>();
            set<string> locationCodeSet = new set<string>();
            set<string> documentTypeSet = new set<string>();
            map<string, string> documentNameWithDocumentIdMap = new map<string, string>();
            
            //for(RequestBody request : requestData){
            if(string.isNotEmpty(requestData.LocationCode)){
                locationCodeSet.add(requestData.LocationCode);          
            }
            if(string.isNotEmpty(requestData.FileName)){
                documentTypeSet.add(requestData.FileName);          
            }
            //}
            
            //getting documents list base on type and location Id
            if(locationCodeSet.isEmpty() == false){
                for(Document__c document : [SELECT Id, Document_Type__c, Handover__r.Unit__r.Unit_Code__c 
                                            from Document__c 
                                            where Document_Type__c in : documentTypeSet AND Handover__c in (SELECT Id from Handover__c where Unit__r.Unit_Code__c in : locationCodeSet)]){
                                                documentNameWithDocumentIdMap.put(document.Handover__r.Unit__r.Unit_Code__c + '_' + document.Document_Type__c, document.Id);
                                            }
            }
            
            if(documentNameWithDocumentIdMap.isEmpty() == false){
                //Deleting Existing documents
                deleteContentDocumentLink(documentNameWithDocumentIdMap.values());
                
                
                map<string, list<ContentVersion>> contentVersionMap = new map<string, list<ContentVersion>>();
                list<ContentVersion> contentVersionToInsertList = new list<ContentVersion>();
                RequestBody request = requestData;
                //for(RequestBody request : requestData){
                    if(string.isNotEmpty(request.LocationCode) && documentNameWithDocumentIdMap.containsKey(request.LocationCode + '_' + request.FileName)){
                        ContentVersion contentVersion = createContentVersion(request.FileBlob, request.FileName + '.' + request.FileType);
                        if(contentVersionMap.containsKey(request.LocationCode + '_' + request.FileName)){
                            contentVersionMap.get(request.LocationCode + '_' + request.FileName).add(contentVersion);
                        }else{
                            contentVersionMap.put(request.LocationCode + '_' + request.FileName, new list<ContentVersion>{contentVersion});
                        }  
                        contentVersionToInsertList.add(contentVersion);
                    }
                //}
                
                if(contentVersionToInsertList.isEmpty() == false){
                    system.debug('==contentVersionToInsertList=='+contentVersionToInsertList);
                    insert contentVersionToInsertList;
                    createContentDocumentLink(contentVersionToInsertList, contentVersionMap, documentNameWithDocumentIdMap);
                }
                
                responseBody.Status = 'Success';
                responseBody.Message = '';
                return responseBody;
            }else{
                responseBody.Status = 'Failed';
                responseBody.Message = 'No handover record exists for this unit code';
                return responseBody;
            }
        }catch(Exception ex){
            ResponseBody responseBody = new ResponseBody();
            responseBody.Status = 'Failed';
            responseBody.Message = ex.getMessage();
            return responseBody;
        }
    }
        
        
    /* @usage : deleteContentDocumentLink function used to delete ContentDocumentLink records.*/
    private static void deleteContentDocumentLink(list<string> contentDocumentLinkIdList){
        List<ContentDocumentLink> cdLinkList = [SELECT ContentDocumentId 
                                                FROM ContentDocumentLink 
                                                WHERE LinkedEntityId in : contentDocumentLinkIdList];
        
        if(cdLinkList != null && cdLinkList.isEmpty() == false){
            Delete cdLinkList;
        }
    }
    
    /* @usage : createContentDocumentLink function used to create ContentDocumentLink records.*/
    private static void createContentDocumentLink(list<ContentVersion> contentVersionToInsertList, map<string, list<ContentVersion>> contentVersionMap, map<string, string> documentNameWithDocumentIdMap){
        List<ContentDocumentLink> contentDocumentLinkToInsertList = new List<ContentDocumentLink>();
        map<Id, Id> contentVersionIdDocIdMap = new map<Id, Id>();
        
        for(ContentVersion contentVersion : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id in : contentVersionToInsertList]){
            contentVersionIdDocIdMap.put(contentVersion.Id, contentVersion.ContentDocumentId);
        }
        
        for(string locationCode : contentVersionMap.keySet()){
            for(ContentVersion contentVersion : contentVersionMap.get(locationCode)){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentVersionIdDocIdMap.get(contentVersion.Id);
                cdl.LinkedEntityId = documentNameWithDocumentIdMap.get(locationCode);
                cdl.ShareType = 'V';
                contentDocumentLinkToInsertList.add(cdl);
            }
        }
        
        if(contentDocumentLinkToInsertList.isEmpty() == false){
            system.debug('==contentDocumentLinkToInsertList=='+contentDocumentLinkToInsertList);
            insert contentDocumentLinkToInsertList;
        }
    }
    
    /* @usage : createContentVersion function used to create ContentVersion records.*/
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        return cv;
    }
    
    global class RequestBody {
        public string FileBlob;
        public string Description;
        public string FileName;
        public string FileType;
        public string LocationCode;
    }
    
    global class ResponseBody {
        public string Status;
        public string Message;
    }
}