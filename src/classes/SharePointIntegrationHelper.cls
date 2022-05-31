public class SharePointIntegrationHelper {
	
    public static List<Sharepoint_Credential__mdt> SharePointCredential;
    public static String getAccessToken(){
        try{
        SharePointCredential = retrieveSharePointSettings();
        if(!SharePointCredential.isEmpty()){
            	String key = EncodingUtil.urlEncode(SharePointCredential[0]?.Client_ID__c,'UTF-8');
                String secret = EncodingUtil.urlEncode(SharePointCredential[0]?.Client_Secret__c,'UTF-8');
                String grant_type = SharePointCredential[0]?.Grant_Type__c;
                
                String messageBody='client_id='+key+
                '&client_secret='+secret+ 
                '&resource='+SharePointCredential[0].Resource__c+ 
                '&grant_type='+grant_type;
    
                system.debug('*****messageBody= '+messageBody);
                Http httpToken = new Http();
                HttpRequest req = new HttpRequest();
                req.setBody(messageBody);
                req.setHeader('content-type', 'application/x-www-form-urlencoded');
                req.setHeader('Content-length', String.valueOf(messageBody.length()));
                req.setHeader('Accept', 'application/json');
                req.setMethod('POST'); 
                req.setEndpoint(SharePointCredential[0].AuthEndpoint__c);

    
                String responseText;
                HttpResponse response = httpToken.send(req);
                
                if(response.getStatusCode()==200){            
                    responseText = response.getBody();
                    System.debug('Response Text : '+responseText);
                    Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(responseText);  
                    string token=String.valueOf(responseMap.get('access_token'));
                    System.debug('Token : '+token);
                    system.debug('responseMap:' + responseMap);
                    return token;
                }
        }
        	return '';
    }
        catch(Exception ex){
            system.debug('********getAccessToken exception = '+ex.getMessage());
            return '';
        }
    }
    
    @future(callout=true)
    public static void createFolderAndUploadFile(String serializeDocumentList){
        List<Document__c> documents = (List<Document__c>)JSON.deserialize(serializeDocumentList,List<Document__c>.class);
        String token = getAccessToken();
       	String folderPath = createPathForFolders(documents);
        Map<ID,ContentVersion> contentVersionMap = getFilesFromDocumentObject(documents);
        System.debug('Folder Path : '+folderPath);
        callSharepointEndpointToCreateFolder(token,folderPath,contentVersionMap);
    }
    
    public static Map<ID,ContentVersion> getFilesFromDocumentObject(List<Document__c> documents){
        Set<ID> docIdSet = new Set<ID>();
        set<ID> contentDocId = new Set<ID>();
        Map<ID,ID> linkConDocID = new Map<ID,ID>();
        Map<ID,ContentVersion> mapLinkEntityContentVersion = new Map<ID,ContentVersion>();
        for(Document__c doc : documents){
            docIdSet.add(doc.Id);
        }
        List<ContentDocumentLink> contentDoc = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :docIdSet];
        for(ContentDocumentLink conDocLink : contentDoc){
           // contentDocId.add(conDocLink.ContentDocumentId);
            linkConDocID.put(conDocLink.ContentDocumentId,conDocLink.LinkedEntityId);
        }
        List<ContentVersion> contentVersionList = [Select Id,ContentDocumentId, ContentUrl,VersionData,Title,PathOnClient,FileExtension from ContentVersion where ContentDocumentId in :linkConDocID.keySet()];
        for(ContentVersion cv :contentVersionList){
            mapLinkEntityContentVersion.put(linkConDocID.get(cv.ContentDocumentId),cv);
        }
        return mapLinkEntityContentVersion;
    }
    
    public static void callSharepointEndpointToCreateFolder(String token, String folderPath, Map<ID,ContentVersion> data1){
        Boolean folderCreatedFlag = false;
        Set<ID> docKeys = data1.keyset();
        List<ContentVersion> cvRecord = data1.values();
        ContentVersion data = cvRecord[0];
        ID docRecord;
        for(ID key : docKeys){
            if(data1.get(key) == data){
                docRecord = key;
                break;
            }
        }
        
        List<URLWrapper> URLWrapperList = new List<URLWrapper>();
        

        String messageBody = '{"__metadata":{"type": "SP.Folder"},"ServerRelativeUrl":"SSFDocuments';
        String baseUrl;
       	List<String> StringFolderPathSplit = folderPath.split('/');
        System.debug('After Path Split : '+StringFolderPathSplit);
        StringFolderPathSplit.remove(0);
        System.debug('After removing SSFDocument '+StringFolderPathSplit);
        Integer count = StringFolderPathSplit.size();
        Integer index = 0;
        System.debug('Count is : '+count);
        for(String splitValues : StringFolderPathSplit){
            
            if(splitValues != 'SSFDocuments'){
               messageBody = messageBody.removeEnd('"}');
                System.debug('String Remove method : '+messageBody);
            messageBody = messageBody + '/' +splitValues+'"}';
            System.debug('Message Formed : '+messageBody);
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization','Bearer ' + token);
            req.setEndpoint('https://nakheelofficial.sharepoint.com/sites/SSF/_api/web/folders');
            req.setHeader('Content-Encoding', 'UTF-8');
            req.setHeader('Content-type', 'application/json;odata=verbose');
            req.setHeader('accept', 'application/json;odata=verbose');
            req.setBody(messageBody);
            Http http = new Http();
            HTTPResponse response = http.send(req);
            if(response.getStatusCode() == 201){
                URLWrapper wrapClass = new URLWrapper();
                Map<String,String> urlAndRecordName = new Map<String,String>();
                System.debug('Successful');
                System.debug('Folder creation relative url : '+response.getBody());
                Map<String,Object> folderCreationResponseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                String ServerRelativeUrl = JSON.serialize(folderCreationResponseMap.get('d'));
                Map<String,Object> responseRelativeUrl = (Map<String,Object>)JSON.deserializeUntyped(ServerRelativeUrl);
                String folderRelativeUrl = String.valueOf(responseRelativeUrl.get('ServerRelativeUrl'));
                
                System.debug('Folder Relative Url '+folderRelativeUrl);
                
                Map<String, Sharepoint_Credential__mdt> mapSc = Sharepoint_Credential__mdt.getAll();
            	for(String nameCredential : mapSc.keySet()){
                baseUrl = mapSc.get(nameCredential).SharepointBase_URL__c;
            }
            
            	String completeUrl = baseUrl + folderRelativeUrl;
                urlAndRecordName.put(splitValues,completeUrl);
                	wrapClass.indexValue = index;      
                    wrapClass.urlRecordName = urlAndRecordName;
                    wrapClass.totalValues = count; 
                    URLWrapperList.add(wrapClass);
                
                System.debug('URL Wrapper List Values : '+URLWrapperList);
                System.debug('URLWrapperList size : '+URLWrapperList.size());
                index += 1;
                
                
                folderCreatedFlag = true;
                
            }else{
                System.debug('Failed : '+response.getStatus());
            }
            }
        }
        
       /* if(URLWrapperList.size()>0){
            for(URLWrapper urlWrap : URLWrapperList){
                if(urlWrap.totalValues == 3){
                   updateProjectAndRelatedObjects(urlWrap);
                }
            }
        } */
        
        if(folderCreatedFlag){
            	callSharepointFileCreationEndpoint(docRecord, data, token, folderPath, URLWrapperList);
               // System.debug('File Creation Flag : '+fileCreationFlag);
        }
    }
    
    public class URLWrapper{
        public Map<String,String> urlRecordName;
        public Integer totalValues;
        public Integer indexValue;
    }
    
    public static void updateSharePointEndpointForAllObjects(URLWrapper urlWrap){
        List<Business_Group__c> businessGroupList = new List<Business_Group__c>();
        List<Business_Unit__c> businessUnitList = new List<Business_Unit__c>();
        List<Project__c> projectList = new List<Project__c>();
        List<Cluster__c> clusterList = new List<Cluster__c>();
        List<Building__c> buildingList = new List<Building__c>();
        List<Floor__c> floorList = new List<Floor__c>();
        List<Unit__c> unitList = new List<Unit__c>();
        List<Account> accountList = new List<Account>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<Case> caseList = new List<Case>();
        List<Agreement__c> agreementList = new List<Agreement__c>(); 
        
        Set<String> recNameKeys = urlWrap.urlRecordName.keyset();
        System.debug('Record Name Values :'+recNameKeys);
        for(String recordName :recNameKeys){
            System.debug('Record Name '+recordName);
            String url = urlWrap.urlRecordName.get(recordName);
            if(urlWrap.indexValue == 0){
                System.debug('Before bg');
           businessGroupList = [Select id,name, Sharepoint_Endpoint__c from Business_Group__c where name =:recordName Limit 1];
                System.debug('After bg');
                if(businessGroupList != null && businessGroupList.size()>0){
                    	businessGroupList[0].Sharepoint_Endpoint__c = url;
                    
                     	//businessGroupList.add(bg[0]);
                }else{
                    System.debug('Bg is null');
                }
            
           System.debug('Bypassed the if and else');
        }
        if(urlWrap.indexValue == 1){
            System.debug('Index Value is 1');
            businessUnitList = [Select id, name, Sharepoint_Endpoint__c from Business_Unit__c where name =:recordName Limit 1];
            if(businessUnitList != null && businessUnitList.size()>0){
                businessUnitList[0].Sharepoint_Endpoint__c = url;
            	//businessUnitList.add(bu[0]);
            }else{
              accountList = [Select id, Sharepoint_Endpoint__c from Account where name =:recordName Limit 1];
                accountList[0].Sharepoint_Endpoint__c = url;
            /*    try{
                    update ac;
                }
                catch(Exception e){
                    System.debug('Updated Failed '+e.getMessage());
                } */
               // accountList.add(ac[0]);
            }    
        }
        if(urlWrap.indexValue == 2){
            projectList = [Select id, name, Sharepoint_Endpoint__c from Project__c where name =:recordName Limit 1];
            if(projectList != null && projectList.size()>0){
                projectList[0].Sharepoint_Endpoint__c = url;
            	//projectList.add(proj[0]);
            }else{
              opportunityList = [Select id, name, Sharepoint_Endpoint__c from Opportunity where name=:recordName Limit 1];
                if(opportunityList != null && opportunityList.size()>0){
                    opportunityList[0].Sharepoint_Endpoint__c = url;
                  //  opportunityList.add(op[0]);
                }else{
                 caseList = [Select id, CaseNumber, Sharepoint_Endpoint__c  from Case Where CaseNumber=:recordName Limit 1];
                    if(caseList != null && caseList.size()>0){
                        caseList[0].Sharepoint_Endpoint__c = url;
                     //   caseList.add(ca[0]);
                    }else{
                        agreementList = [Select id, Sharepoint_Endpoint__c from Agreement__c where Name=:recordName Limit 1];
                        if(agreementList != null && agreementList.size()>0){
                            agreementList[0].Sharepoint_Endpoint__c = url;
                         //   update ag;
                         //   agreementList.add(ag[0]);
                        }
                    }
                }
            }
            
        }
        if(urlWrap.indexValue == 3){
            clusterList = [Select id, name, Sharepoint_Endpoint__c from Cluster__c where name =:recordName Limit 1];
            clusterList[0].Sharepoint_Endpoint__c = url;
           // clusterList.add(clust);
        }
   		if(urlWrap.indexValue == 4){
           buildingList = [Select id, name, Sharepoint_Endpoint__c from Building__c where name =:recordName Limit 1];
            buildingList[0].Sharepoint_Endpoint__c = url;
           // buildingList.add(build);
        }
        if(urlWrap.indexValue == 5){
            floorList = [Select id, name, Sharepoint_Endpoint__c from Floor__c where name =:recordName Limit 1];
            floorList[0].Sharepoint_Endpoint__c = url;
           // floorList.add(floor);
        }
        if(urlWrap.indexValue == 4){
            unitList = [Select id, name, Sharepoint_Endpoint__c from Unit__c where name =:recordName Limit 1];
            unitList[0].Sharepoint_Endpoint__c = url;
           // unitList.add(uni);
        }
        }
        
        
        
        if(businessGroupList.size()>0){
            update businessGroupList;
        }
        if(businessUnitList.size()>0){
            update businessUnitList;
        }
        if(projectList.size()>0){
            update projectList;
        }
        if(clusterList.size()>0){
            update clusterList;
        }
        if(buildingList.size()>0){
            update buildingList;
        }
        if(floorList.size()>0){
            update floorList;
        }
        if(unitList.size()>0){
            update unitList;
        } 
        if(accountList.size() > 0){
            update accountList	;
        }
        if(opportunityList.size() > 0){
            update opportunityList;
        }
        if(agreementList.size() > 0){
            update agreementList;
        }
        if(caseList.size() > 0){
            update caseList;
        }
    }
    
    public static void callSharepointFileCreationEndpoint(ID documentId, ContentVersion data, String token, String folderPath, List<URLWrapper> URLWrapperList){
        String fileName = data.Title.replace(' ','%20');
        List<Document__c> documentObjectList = new List<Document__c>();
        String extn = data.FileExtension;
        string contentType = ContentType(extn);
		String folderPathValue = folderPath.replace(' ', '%20');
		List<String> StringFolderPathSplit = folderPath.split('/');        
        	HttpRequest req = new HttpRequest(); 
            
            req.setEndpoint('https://nakheelofficial.sharepoint.com/sites/SSF/_api/web'+'/GetFolderByServerRelativeUrl(\'/sites/SSF/'+folderPathValue+'\')/Files/add(url=\''+fileName+'.'+extn+'\',overwrite=true)');
        	//req.setEndpoint('https://nakheelofficial.sharepoint.com/sites/SSF/_api/web/GetFolderByServerRelativeUrl(\'/sites/SSF/'+folderPath+'\')/Files/add(url=\'test.txt\',overwrite=true)');
       		// req.setEndpoint('https://nakheelofficial.sharepoint.com/sites/SSF/_api/web/GetFolderByServerRelativeUrl(\'/sites/SSF/SSFDocuments/District%20One/Gardens%20Portfolio\')/Files/add(url=\''+fileName+'.'+extn+'\',overwrite=true)');
            req.setMethod('POST'); 
            req.setHeader('Authorization','Bearer ' + token);

            //req.setHeader('Content-Encoding', 'UTF-8');
            req.setHeader('Content-type', contentType);
            req.setHeader('accept', 'application/json;odata=verbose');
            Http http = new Http();
            system.debug('getBody1 '+req);
           //req.setBody('This is test body');
           req.setBodyAsBlob(data.versionData);
           // req.setTimeout(120000);
            
            HTTPResponse response = http.send(req);
        if(response.getStatusCode() == 200){
            
            String baseUrl;
            System.debug('File Created Successfully');
            System.debug('Body '+response.getBody());
            Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(response.getBody());
            //obtain ServerRelativeUrl value from the respons
            String ServerRelativeUrl = JSON.serialize(responseMap.get('d'));
            
            Map<String,Object> responseRelativeUrl = (Map<String,Object>)JSON.deserializeUntyped(ServerRelativeUrl);
            Map<String, Sharepoint_Credential__mdt> mapSc = Sharepoint_Credential__mdt.getAll();
            for(String nameCredential : mapSc.keySet()){
                baseUrl = mapSc.get(nameCredential).SharepointBase_URL__c;
            }
            
            String completeUrl = baseUrl + String.valueOf(responseRelativeUrl.get('ServerRelativeUrl'));
            
            Document__c docObject = new Document__c();
                docObject.Id = documentId;
                docObject.Sharepoint_Url__c  = completeUrl;
            documentObjectList.add(docObject);
            System.debug('@@@@@ Document Object List @@@@@ '+documentObjectList);
            
            
           // System.debug('Server Relative Url : '+ServerRelativeUrl);
           
        }else{
            System.debug('File Creation Failed : '+response.getBody());
            
        }
        
        if(documentObjectList.size()>0){
            System.Debug('Size is greater than 0 '+documentObjectList.size());
            update documentObjectList;
        }
        
       if(URLWrapperList.size()>0){
            for(URLWrapper urlWrap : URLWrapperList){
                if(urlWrap.totalValues == 3){
                    System.debug('I am in this block');
                   updateSharePointEndpointForAllObjects(urlWrap);
                }
                if(urlWrap.totalValues == 4){
                   updateSharePointEndpointForAllObjects(urlWrap);
                }
                if(urlWrap.totalValues == 5){
                   updateSharePointEndpointForAllObjects(urlWrap);
                }
                if(urlWrap.totalValues == 6){
                   updateSharePointEndpointForAllObjects(urlWrap);
                }
                if(urlWrap.totalValues == 7){
                    System.debug('I am running');
                   updateSharePointEndpointForAllObjects(urlWrap);
                }
            }
        } 
        
    }
    
    public static String createPathForFolders(List<Document__c> scope){
        
        String pathToBeCreated = 'SSFDocuments';
        if(!scope.isEmpty()){
            if(scope[0].get('Project__c') != null){
             	String proj_query = 'Select id, name, Sharepoint_Url__c, Business_Unit__c, Business_Unit__r.Name, Business_Unit__r.Sharepoint_Url__c, Business_Group__c, Business_Group__r.Name, Business_Group__r.Sharepoint_Url__c from Project__c where ID =\''+scope[0].get('Project__c')+'\'';
               	Project__c proj = Database.query(proj_query);
                if(proj.Sharepoint_Url__c == null || proj.Sharepoint_Url__c == ''){
                    if(proj.Business_Unit__r.Sharepoint_Url__c == null || proj.Business_Unit__r.Sharepoint_Url__c == ''){
                        if(proj.Business_Group__r.Sharepoint_url__c == null || proj.Business_Group__r.Sharepoint_url__c == ''){
                            pathToBeCreated = pathToBeCreated+'/'+proj.Business_Group__r.Name+'/'+proj.Business_Unit__r.Name+'/'+proj.Name;
                        }else{
                            pathToBeCreated = pathToBeCreated+'/'+proj.Business_Group__r.Sharepoint_url__c+'/'+proj.Business_Unit__r.Name+'/'+proj.Name;
                        }
                    }else{
                        pathToBeCreated = pathToBeCreated+'/'+proj.Business_Unit__r.Sharepoint_Url__c+'/'+proj.Name;
                    }
                    
                }else{
                    
                }
                return pathToBeCreated;
            }
            
            if(scope[0].get('Cluster__c') != null){
                
                String cluster_query = 'Select id, name, Sharepoint_Url__c, Business_Unit__c, Business_Unit__r.Name, Business_Unit__r.Sharepoint_Url__c, Business_Group__c, Business_Group__r.Name, Business_Group__r.Sharepoint_Url__c, Project__c, Project__r.Name, Project__r.Sharepoint_Url__c  from Cluster__c where ID =\''+scope[0].get('Cluster__c')+'\'';
               	Cluster__c cluster = Database.query(cluster_query);
                if(cluster.Sharepoint_Url__c == null || cluster.Sharepoint_Url__c == ''){
                    if(cluster.Project__r.Sharepoint_Url__c == null || cluster.Project__r.Sharepoint_Url__c == ''){
                        if(cluster.Business_Unit__r.Sharepoint_Url__c == null || cluster.Business_Unit__r.Sharepoint_Url__c == ''){
                            if(cluster.Business_Group__r.Sharepoint_url__c == null || cluster.Business_Group__r.Sharepoint_url__c == ''){
                                pathToBeCreated = pathToBeCreated+'/'+cluster.Business_Group__r.Name+'/'+cluster.Business_Unit__r.Name+'/'+cluster.Project__r.Name+'/'+cluster.Name;
                            }else{
                                pathToBeCreated = pathToBeCreated+'/'+cluster.Business_Group__r.Sharepoint_url__c+'/'+cluster.Business_Unit__r.Name+'/'+cluster.Project__r.Name+'/'+cluster.Name;
                            }
                        }else{
                            pathToBeCreated = pathToBeCreated+'/'+cluster.Business_Unit__r.Sharepoint_Url__c+'/'+cluster.Project__r.Name+'/'+cluster.Name;
                        }
                    
                }else{
                    pathToBeCreated = pathToBeCreated+'/'+cluster.Project__r.Sharepoint_Url__c+'/'+cluster.Name;
                }
                }else{
                    
                }
                return pathToBeCreated;
            }
            
            if(scope[0].get('Building__c') != null){
                
                String building_query = 'Select id, name, Sharepoint_Url__c, Business_Unit__c, Business_Unit__r.Name, Business_Unit__r.Sharepoint_Url__c, Business_Group__c, Business_Group__r.Name, Business_Group__r.Sharepoint_Url__c, Project__c, Project__r.Name, Project__r.Sharepoint_Url__c, Cluster__c, Cluster__r.Name, Cluster__r.Sharepoint_Url__c  from Building__c where ID =\''+scope[0].get('Building__c')+'\'';
               	Building__c building = Database.query(building_query);
                if(building.Sharepoint_Url__c == null || building.Sharepoint_Url__c == ''){
                    if(building.Cluster__r.Sharepoint_Url__c == null || building.Cluster__r.Sharepoint_url__c == ''){
                        if(building.Project__r.Sharepoint_Url__c == null || building.Project__r.Sharepoint_Url__c == ''){
                            if(building.Business_Unit__r.Sharepoint_Url__c == null || building.Business_Unit__r.Sharepoint_Url__c == ''){
                                if(building.Business_Group__r.Sharepoint_url__c == null || building.Business_Group__r.Sharepoint_url__c == ''){
                                    pathToBeCreated = pathToBeCreated+'/'+building.Business_Group__r.Name+'/'+building.Business_Unit__r.Name+'/'+building.Project__r.Name+'/'+building.Cluster__r.Name+'/'+building.Name;
                                }else{
                                    pathToBeCreated = pathToBeCreated+'/'+building.Business_Group__r.Sharepoint_url__c+'/'+building.Business_Unit__r.Name+'/'+building.Project__r.Name+'/'+building.Cluster__r.Name+'/'+building.Name;
                                }
                            }else{
                                pathToBeCreated = pathToBeCreated+'/'+building.Business_Unit__r.Sharepoint_Url__c+'/'+building.Project__r.Name+'/'+building.Cluster__r.Name+'/'+building.Name;
                            }
                        
                }else{
                    pathToBeCreated = pathToBeCreated+'/'+building.Project__r.Sharepoint_Url__c+'/'+building.Cluster__r.Name+'/'+building.Name;
                }
                }else{
                    pathToBeCreated = pathToBeCreated+'/'+building.Cluster__r.Sharepoint_Url__c+'/'+building.Name;
                }

                }else{
                    
                }
                return pathToBeCreated;
            }
            
            if(scope[0].get('Floor__c') != null){
                 String floor_query = 'Select id, name, Sharepoint_Url__c, Business_Unit__c, Business_Unit__r.Name, Business_Unit__r.Sharepoint_Url__c, Business_Group__c, Business_Group__r.Name, Business_Group__r.Sharepoint_Url__c, Project__c, Project__r.Name, Project__r.Sharepoint_Url__c, Cluster__c, Cluster__r.Name, Cluster__r.Sharepoint_Url__c, Building__c, Building__r.Name, Building__r.Sharepoint_Url__c  from Floor__c where ID =\''+scope[0].get('Floor__c')+'\'';
               	Floor__c floor = Database.query(floor_query);
                if(floor.Sharepoint_Url__c == null || floor.Sharepoint_Url__c == ''){
                    if(floor.Building__r.Sharepoint_Url__c == null || floor.Building__r.Sharepoint_Url__c == ''){
                    if(floor.Cluster__r.Sharepoint_Url__c == null || floor.Cluster__r.Sharepoint_url__c == ''){
                        if(floor.Project__r.Sharepoint_Url__c == null || floor.Project__r.Sharepoint_Url__c == ''){
                            if(floor.Business_Unit__r.Sharepoint_Url__c == null || floor.Business_Unit__r.Sharepoint_Url__c == ''){
                                if(floor.Business_Group__r.Sharepoint_url__c == null || floor.Business_Group__r.Sharepoint_url__c == ''){
                                    pathToBeCreated = pathToBeCreated+'/'+floor.Business_Group__r.Name+'/'+floor.Business_Unit__r.Name+'/'+floor.Project__r.Name+'/'+floor.Cluster__r.Name+'/'+floor.Building__r.Name+'/'+floor.Name;
                                }else{
                                    pathToBeCreated = pathToBeCreated+'/'+floor.Business_Group__r.Sharepoint_url__c+'/'+floor.Business_Unit__r.Name+'/'+floor.Project__r.Name+'/'+floor.Cluster__r.Name+'/'+floor.Building__r.Name+'/'+floor.Name;
                                }
                            }else{
                                pathToBeCreated = pathToBeCreated+'/'+floor.Business_Unit__r.Sharepoint_Url__c+'/'+floor.Project__r.Name+'/'+floor.Cluster__r.Name+'/'+floor.Building__r.Name+'/'+floor.Name;
                            }
                        
                }else{
                    pathToBeCreated = pathToBeCreated+'/'+floor.Project__r.Sharepoint_Url__c+'/'+floor.Cluster__r.Name+'/'+floor.Building__r.Name+'/'+floor.Name;
                }
                }else{
                    pathToBeCreated = pathToBeCreated+'/'+floor.Cluster__r.Sharepoint_Url__c+'/'+floor.Building__r.Name+'/'+floor.Name;
                }
                }
                else{
                        pathToBeCreated = pathToBeCreated+'/'+floor.Building__r.Sharepoint_Url__c+'/'+floor.Name;
                    }
                }else{
                    
                }
                return pathToBeCreated;
            }
            
            if(scope[0].get('Unit__c') != null){
               String unit_query = 'Select id, name, Sharepoint_Url__c, Business_Unit__c, Business_Unit__r.Name, Business_Unit__r.Sharepoint_Url__c, Business_Group__c, Business_Group__r.Name, Business_Group__r.Sharepoint_Url__c, Project__c, Project__r.Name, Project__r.Sharepoint_Url__c, Cluster__c, Cluster__r.Name, Cluster__r.Sharepoint_Url__c, Building__c, Building__r.Name, Building__r.Sharepoint_Url__c, Floor__c, Floor__r.Name, Floor__r.Sharepoint_Url__c  from Unit__c where ID =\''+scope[0].get('Unit__c')+'\'';
               	Unit__c unit = Database.query(unit_query);
                if(unit.Sharepoint_Url__c == null || unit.Sharepoint_Url__c == ''){
                    if(unit.Floor__r.Sharepoint_Url__c == null || unit.Floor__r.Sharepoint_Url__c == ''){
                    if(unit.Building__r.Sharepoint_Url__c == null || unit.Building__r.Sharepoint_Url__c == ''){
                    if(unit.Cluster__r.Sharepoint_Url__c == null || unit.Cluster__r.Sharepoint_url__c == ''){
                        if(unit.Project__r.Sharepoint_Url__c == null || unit.Project__r.Sharepoint_Url__c == ''){
                            if(unit.Business_Unit__r.Sharepoint_Url__c == null || unit.Business_Unit__r.Sharepoint_Url__c == ''){
                                if(unit.Business_Group__r.Sharepoint_url__c == null || unit.Business_Group__r.Sharepoint_url__c == ''){
                                    pathToBeCreated = pathToBeCreated+'/'+unit.Business_Group__r.Name+'/'+unit.Business_Unit__r.Name+'/'+unit.Project__r.Name+'/'+unit.Cluster__r.Name+'/'+unit.Building__r.Name+'/'+unit.Floor__r.Name+'/'+unit.Name;
                                }else{
                                    pathToBeCreated = pathToBeCreated+'/'+unit.Business_Group__r.Sharepoint_url__c+'/'+unit.Business_Unit__r.Name+'/'+unit.Project__r.Name+'/'+unit.Cluster__r.Name+'/'+unit.Building__r.Name+'/'+unit.Floor__r.Name;
                                }
                            }else{
                                pathToBeCreated = pathToBeCreated+'/'+unit.Business_Unit__r.Sharepoint_Url__c+'/'+unit.Project__r.Name+'/'+unit.Cluster__r.Name+'/'+unit.Building__r.Name+'/'+unit.Floor__r.Name+'/'+unit.Name;
                            }
                        
                }else{
                    pathToBeCreated = pathToBeCreated+'/'+unit.Project__r.Sharepoint_Url__c+'/'+unit.Cluster__r.Name+'/'+unit.Building__r.Name+'/'+unit.Floor__r.Name;
                }
                }else{
                    pathToBeCreated = pathToBeCreated+'/'+unit.Cluster__r.Sharepoint_Url__c+'/'+unit.Building__r.Name+'/'+unit.Floor__r.Name+'/'+unit.Name;
                }
                }
                else{
                        pathToBeCreated = pathToBeCreated+'/'+unit.Building__r.Sharepoint_Url__c+'/'+unit.Floor__r.Name+'/'+unit.Name;
                    }
                }else{
                    	pathToBeCreated = pathToBeCreated+'/'+unit.Floor__r.Sharepoint_Url__c+'/'+unit.Name;
                }
                }else{
                    
                }
                return pathToBeCreated;
            }
            
            if(scope[0].get('Account__c') != null){
               // pathToBeCreated = 'Customer Document';
                String accountQuery = 'Select id, Name, Sharepoint_Url__c, Sharepoint_Endpoint__c from Account where id =\''+scope[0].get('Account__c')+'\'';
                Account accountData = Database.query(accountQuery);
                if(accountData.Sharepoint_Url__c == null || accountData.Sharepoint_Url__c == ''){
                    pathToBeCreated = pathToBeCreated+'/'+'Customer Document'+'/'+accountData.Name;
                }else{
                    return accountData.Sharepoint_Url__c;
                }
                return pathToBeCreated;
            }
            
            if(scope[0].get('Opportunity__c') != null){
               // pathToBeCreated = 'Customer Document';
                String opportunityQuery = 'Select id, name, Sharepoint_Url__c, Sharepoint_Endpoint__c, AccountID, Account.Name, Account.Sharepoint_Url__c from Opportunity where Id =\''+scope[0].get('Opportunity__c')+'\'';
               	Opportunity opportunityData = Database.query(opportunityQuery);
                if(opportunityData.Sharepoint_Url__c == null || opportunityData.Sharepoint_Url__c == ''){
                    if(opportunityData.Account.Sharepoint_Url__c == null || opportunityData.Account.Sharepoint_Url__c == ''){
                        pathToBeCreated = pathToBeCreated+'/'+'Customer Document'+'/'+opportunityData.Account.Name+'/'+opportunityData.Name;
                    }else{
                        pathToBeCreated = opportunityData.Account.Sharepoint_Url__c+'/'+opportunityData.Name;
                    }
                }else{
                    	pathToBeCreated = opportunityData.Sharepoint_Url__c;
                }
                return pathToBeCreated;
            }
            
            if(scope[0].get('Case__c') != null){
                String caseQuery = 'Select id, name, CaseNumber, Sharepoint_Url__c, Sharepoint_Endpoint__c, Account.Name, Account.Sharepoint_Url from Case__c where Id =\''+scope[0].get('Case__c')+'\'';
                Case caseData = Database.query(caseQuery);
                
                if(caseData.Sharepoint_Url__c == null || caseData.Sharepoint_Url__c == ''){
                    if(caseData.Account.Sharepoint_Url__c == null || caseData.Account.Sharepoint_Url__c == ''){
                        pathToBeCreated = pathToBeCreated+'/'+'Customer Document'+'/'+caseData.Account.Name+'/'+caseData.CaseNumber;
                    }else{
                        pathToBeCreated =caseData.Account.Sharepoint_Url__c+'/'+caseData.CaseNumber;
                    }
                }else{
                    pathToBeCreated = caseData.Sharepoint_Url__c;
                }
                return pathToBeCreated;
            }
            
            if(scope[0].get('SPA_Agreement__c') != null){
                String agreementQuery = 'Select id, Name, Sharepoint_Url__c, Sharepoint_Endpoint__c, Account__r.Sharepoint_Url__c, Account__r.Name from Agreement__c where Id =\''+scope[0].get('SPA_Agreement__c')+'\'';
                Agreement__c agreementData = Database.query(agreementQuery);
                if(agreementData.Sharepoint_Url__c == null || agreementData.Sharepoint_Url__c == ''){
                    if(agreementData.Account__r.Sharepoint_Url__c == null || agreementData.Account__r.Sharepoint_Url__c == ''){
                        System.debug('first if');
                        pathToBeCreated = pathToBeCreated+'/'+'Customer Document'+'/'+agreementData.Account__r.Name+'/'+agreementData.Name;
                    }else{
                        System.debug('first else');
                        pathToBeCreated = agreementData.Account__r.Sharepoint_Url__c+'/'+agreementData.Name;
                    }
                }else{
                    System.debug('second else');
                    pathToBeCreated = agreementData.Sharepoint_Url__c;
                }
                return pathToBeCreated;
            }
           
    	}
        return '';
    }
    
      //Content Type based on Content Version
    /**
     * @description retrieve Content Type based on Content Version
     *
     * @param fileType {string} extension of the file
     * @returns {string} content type that will be used in API request as header
     */
    public static string ContentType(string fileType)
    {
        switch on fileType.toLowerCase()
        {
            when 'docx'
            {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'csv'
            {
                return 'application/vnd.ms-excel';
            }
            when 'wav'
            {
                return 'audio/wav';
            }
            when 'wmv'
            {
                return 'video/x-ms-wmv';
            }
            when 'mp3'
            {
                return 'audio/mpeg';
            }
            when 'mp4'
            {
                return 'video/mp4';
            }
            when 'png'
            {
                return 'image/png';
                
            }
            when 'pdf'
            {
                return 'application/pdf';
                
            }
            when 'txt'
            {
                return 'text/plain';
                
            }
            when else {
                return 'image/jpeg';
            }
        }
    }
  	  	public static List<Sharepoint_Credential__mdt> retrieveSharePointSettings(){
        return  [SELECT MasterLabel, DeveloperName, AuthEndpoint__c, Client_ID__c, Client_Secret__c, Resource__c, Grant_Type__c, SharepointBase_URL__c  FROM Sharepoint_Credential__mdt where DeveloperName = 'Default'];
    }
}