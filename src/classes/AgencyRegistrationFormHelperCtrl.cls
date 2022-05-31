/**
* @author Mamta Gupta
* @date 16/08/2021
* @purpose - Initial Development
* @usage -AgencyRegistrationForm Aura Bundle
*/


public without sharing class AgencyRegistrationFormHelperCtrl {   
    
  //public static list<NKHL_Documentation_Template__mdt >MdtDocumentList=new list<NKHL_Documentation_Template__mdt > ();
  public static Map<Id, String> recordtypemap {get;set;}
  
    
    /* @param - recordId (Broker ID)
    * @return - (Broker Agency Details)*/
   
    public static Broker__c getBrokerDetails(string recordId){
       system.debug('User is '+ UserInfo.getUserId());

        system.debug([SELECT RecordId FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND HasReadAccess = true AND RecordId = :recordId ]);

        return [select Id, RecordType.name,Exisiting_Broker__c ,Broker_Number__c,Agency_Location__c , Agency_Approval_Status__c, RecordTypeId, Company_Name__c,
                Trade_Licence_Number__c, Agency_Type__c, Mobile_Country_Code__c, Mobile__c, Rera_Registration_No__c,TRN_No__c ,
                Email_Address__c, Address_Line__c, Place_of_Incorporation__c,Postal_Code__c , Emirate__c, City__c,State__c,
                Bank_Account_Name__c,Other_Bank_Name__c  , Bank_Name__c, Bank_Account__c, Bank_Address__c,Bank_IBAN_Number__c,Bank_SWIFT_Code__c,
                Bank_Branch__c,Bank_Currency_of_Account__c,Account_Number__c,(select id,Agreement_Status__c  from Accounts__r)  
                from Broker__c 
                where Id =: recordId];
    }
    public static Account updateAccount (Account account) {
        upsert account ;
        return account;    
    }
    
    
    /* @param - recordId (Broker ID)
    * @return - (Broker Proprietor Details)*/
     public static list<Broker_Proprietor__c> getbrokerpropDetails(string recordId){
        return [select Id, Name, Agency_Registration__c, Emirates_Id__c ,Shareholder_Passport_No__c, Shareholder_Percentage__c, Nationality__c
                from Broker_Proprietor__c 
                where Agency_Registration__c =: recordId];
    }
    
    @AuraEnabled
    public static void deleteBrokerPartners(List<Broker_Proprietor__c> bokerPartnerLst){
      system.debug('bokerPartnerLst is '+ bokerPartnerLst);  
      if(bokerPartnerLst.size()>0){
         delete  bokerPartnerLst;  
        }    
    }
    
    @AuraEnabled
    public static void deleteBrokerAgents(List<Broker_Agents__c> bokerAgentLst){
      system.debug('bokerAgentLst is '+ bokerAgentLst);  
  
      if(bokerAgentLst.size()>0){
         delete  bokerAgentLst;  
        }    
    }
    
    
    
    /* @param - recordId (Broker ID)
    *           recordTypeName(record type of Agent)
    * @return - Broker Agent Details*/
    public static list<Broker_Agents__c> getbrokerAgentAuthDetails(string recordId, string recordTypeName){
        return [select Id, Name, RecordTypeId, RecordType.DeveloperName, Agency_Registration__c, Branch_Location__c, Contact_Person__c, Country_Code__c, Designation__c, Email__c, First_Name__c, Last_Name__c,Nationality__c, Member_of_Real_Estate_Agency_Association__c, Mobile__c, Operating_Since__c, CEP_Broker_Contact_ID__c, Broker_Access_Type__c
                from Broker_Agents__c
                where Agency_Registration__c =: recordId AND RecordType.DeveloperName =: recordTypeName AND Broker_Access_Type__c!=null];
    }
    
    
    /* @param - recordId (Broker ID)
    *           recordTypeName(record type of Agent)
    * @return - Broker Agent Details*/
    public static list<Broker_Agents__c> getbrokerAdditionalContactDetails(string recordId, string recordTypeName){
        return [select Id, Name, RecordTypeId, RecordType.DeveloperName, Agency_Registration__c, Branch_Location__c, Contact_Person__c, Country_Code__c, Designation__c, Email__c, First_Name__c, Last_Name__c,Nationality__c, Member_of_Real_Estate_Agency_Association__c, Mobile__c, Operating_Since__c, CEP_Broker_Contact_ID__c, Broker_Access_Type__c
                from Broker_Agents__c
                where Agency_Registration__c =: recordId AND RecordType.DeveloperName =: recordTypeName AND Broker_Access_Type__c=null];
    }
    
    
    /* @param - AgencyDetails (Broker details captured from AgencyRegistrationForm Aura Bundle)
    * @return - return created record of broker*/
     public static Broker__c createAgencyRegistrationRecord (Broker__c AgencyDetails,Boolean saveAsDraft) {
       
         /* Added By Mamta 24 Sep*/
         if(AgencyDetails.Id!=null){
             deletePreviousDocuments(AgencyDetails.Place_of_Incorporation__c, AgencyDetails.Emirate__c,AgencyDetails.Id);
         } 
             
        upsert AgencyDetails;
        system.debug('AgencyDetails=' +AgencyDetails);
         
         
        if(saveAsDraft==true){
           sendEmailtoAgency(AgencyDetails.Id,'Draft_registration_of_Agency');  
         } 
        return getBrokerDetails(AgencyDetails.Id);
    }
    
    
    /* @param - agencyRecordId- Broker ID
                brokerProprietorsList-  List of Broker Proprietors 
    * @return - return created records of Broker Proprietors */

    public static List<Broker_Proprietor__c> createBrokerProprietorsRecord (string agencyRecordId, List<Broker_Proprietor__c> brokerProprietorsList) {
       system.debug('brokerProprietorsList' + brokerProprietorsList);
        upsert brokerProprietorsList;
        return brokerProprietorsList;
    }
    
    public static boolean checkIfAllBrokerFilesUploaded(String recordId){
    boolean isAllFilesUploaded = true;    
     List<Document__c > documents =[SELECT ID, Document_Attached__c  from Document__c WHERE Agency_Registration__c  =:recordId AND  Is_Doc_Required__c=true] ;
                                   
     for(Document__c doc: documents){
         if(doc.Document_Attached__c==false){
             isAllFilesUploaded = false;
             break;
           }
        }
        
        system.debug('isAllFilesUploaded is '+ isAllFilesUploaded);
        
        return isAllFilesUploaded;
        
    }
    
     @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Broker__c.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master'  && rt.getName() != 'Company' && rt.getName() != 'Individual' ){
                recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }
        }        
        return recordtypemap.values();
    }
    
    //Map of Agreement status picklist label and values
     public static Map<String, String> getAgreementStatus(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Account.Agreement_Status__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    public static Map<String, String> getNationalityPicVal(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Broker_Agents__c.Nationality__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
     /* @param - agencyRecordId- Broker ID
                brokerAgentAuthList-  List of Broker Agents  of record type Authorized_Signatory
    * @return - return created records of Broker Agents */
    public static List<Broker_Agents__c> createBrokerAgentsAuthorisedSignatoryRecord (string agencyRecordId, List<Broker_Agents__c> brokerAgentAuthList) {
       system.debug('brokerAgentAuthList' + brokerAgentAuthList);
        string message = '';
        if(brokerAgentAuthList.isEmpty() == false){
            try{
                
                Id brokerAgentRecordTypeId = CommonUtility.recordTypeIdByDevName(Broker_Agents__c.sObjectType, 'Authorized_Signatory');
                for(Broker_Agents__c brokerAgents : brokerAgentAuthList){
                    brokerAgents.RecordTypeId = brokerAgentRecordTypeId;
                }
                
                upsert brokerAgentAuthList;
                return brokerAgentAuthList;
                
                //message = 'Record Created Successfully';
            }catch(Exception ex){
                message = 'Error: ' + ex.getMessage();
                //return message;
            }
        }
        return brokerAgentAuthList;
    }
   
    
      
    /* @param - agencyRecordId- Broker ID
                brokerAgentAuthList-  List of Broker Agents of record type Agent_Representative
    * @return - return created records of Broker Agents */
    public static List<Broker_Agents__c> createBrokerAgentsRepresentativeRecord (string agencyRecordId, List<Broker_Agents__c> brokerAgentRepresentativeList) {
       system.debug('brokerAgentRepresentativeList' + brokerAgentRepresentativeList);
        string message = '';
        if(brokerAgentRepresentativeList.isEmpty() == false){
            try{
                
                Id brokerAgentRecordTypeId = CommonUtility.recordTypeIdByDevName(Broker_Agents__c.sObjectType, 'Agent_Representative');
                for(Broker_Agents__c brokerAgents : brokerAgentRepresentativeList){
                    brokerAgents.RecordTypeId = brokerAgentRecordTypeId;
                }
                
                upsert brokerAgentRepresentativeList;
                return brokerAgentRepresentativeList;
                //message = 'Record Created Successfully';
            }catch(Exception ex){
                message = 'Error: ' + ex.getMessage();
                //return message;
            }
        }
        return brokerAgentRepresentativeList;
    }
    
    /* @param - agencyRecordId- Broker ID
                brokerAgentContactsList-  List of Broker Agents of record type Agent_Representative with no broker access type
    * @return - return created records of Broker Agents */
    public static List<Broker_Agents__c> createBrokerAgentsAdditionalContactsRecord (string agencyRecordId, List<Broker_Agents__c> brokerAgentContactsList) {
       system.debug('brokerAgentContactsList' + brokerAgentContactsList);
        string message = '';
        if(brokerAgentContactsList.isEmpty() == false){
            try{
                
                Id brokerAgentRecordTypeId = CommonUtility.recordTypeIdByDevName(Broker_Agents__c.sObjectType, 'Agent_Representative');
                for(Broker_Agents__c brokerAgents : brokerAgentContactsList){
                    brokerAgents.RecordTypeId = brokerAgentRecordTypeId;
                }
                
                upsert brokerAgentContactsList;
                return brokerAgentContactsList;
                //message = 'Record Created Successfully';
            }catch(Exception ex){
                message = 'Error: ' + ex.getMessage();
                //return message;
            }
        }
        return brokerAgentContactsList;
    }
   
    
    
    /* @param - agencyRecordId- Broker ID
                brokerProprietorsList-   Broker Proprietors
                brokerAgentAuthList - List of Broker Agents of record type Agent_Representative
                brokerAgentContactsList - List of Broker Agents of record type Agent_Representative with no broker access type
    * @return - return isSuccess/isError with error detail */
     @AuraEnabled
    public static List<String> createBrokerProprietorsAndAgentsRecord (string agencyRecordId, List<Broker_Proprietor__c> brokerProprietorsList, List<Broker_Agents__c> brokerAgentAuthList, List<Broker_Agents__c> brokerAgentRepresentativeList, List<Broker_Agents__c> brokerAgentContactsList,boolean saveAsDraft){
        system.debug('brokerProprietorsList' + brokerProprietorsList);
        system.debug('brokerAgentAuthList' + brokerAgentAuthList);
        system.debug('brokerAgentRepresentativeList' + brokerAgentRepresentativeList);
        system.debug('brokerAgentContactsList' + brokerAgentContactsList);
        system.debug('User' + userinfo.getLastName());
        string message = '';
        string isSuccess='true';
        List<Broker_Proprietor__c> brokerprop = new List<Broker_Proprietor__c>();
        List<Broker_Agents__c> brokerAgentAuth = new List<Broker_Agents__c>();
        List<Broker_Agents__c> brokerAgentsList = new List<Broker_Agents__c>();
        
        if(saveAsDraft==true){
            Broker__c broker= [select id, status__c from Broker__c WHERE ID=:agencyRecordId];
            broker.status__c = 'Draft';
            upsert broker;
            
        }
        
        else{
            Broker__c broker= [select id, status__c from Broker__c WHERE ID=:agencyRecordId];
            broker.status__c = 'Under Review';
            upsert broker;
            
        }
        
        if(brokerProprietorsList.isEmpty() == false){
            try{
                upsert brokerProprietorsList;
                message = 'Record Created Successfully';
            }catch(Exception ex){
                isSuccess='false';
                message = 'Error: ' + ex.getMessage();
                return isSUccessWithMsg(isSuccess,message);
            }
        }
        
        if(brokerAgentAuthList.isEmpty() == false){
            brokerAgentsList.addAll(brokerAgentAuthList);

            try{
                

                
                Id brokerAgentRecordTypeId = CommonUtility.recordTypeIdByDevName(Broker_Agents__c.sObjectType, 'Authorized_Signatory');
                for(Broker_Agents__c brokerAgents : brokerAgentAuthList){
                    brokerAgents.RecordTypeId = brokerAgentRecordTypeId;
                }
                
                upsert brokerAgentAuthList;
                
                message = 'Record Created Successfully';
            }catch(Exception ex){
                isSuccess='false';

                message = 'Error: ' + ex.getMessage();
                return isSUccessWithMsg(isSuccess,message);
            }
        }
        
        if(brokerAgentRepresentativeList.isEmpty() == false){
            try{
                 brokerAgentsList.addAll(brokerAgentRepresentativeList);

                Id brokerAgentRecordTypeId = CommonUtility.recordTypeIdByDevName(Broker_Agents__c.sObjectType, 'Agent_Representative');
                for(Broker_Agents__c brokerAgents : brokerAgentRepresentativeList){
                    brokerAgents.RecordTypeId = brokerAgentRecordTypeId;
                }
                
                upsert brokerAgentRepresentativeList;
                
                message = 'Record Created Successfully';
            }catch(Exception ex){
                isSuccess='false';

                message = 'Error: ' + ex.getMessage();
                return isSUccessWithMsg(isSuccess,message);
            }
        }
        
        system.debug('brokerAgentContactsList is'+ brokerAgentContactsList);
        system.debug('brokerAgentContactsList.isEmpty() is '+ brokerAgentContactsList.isEmpty());
        if(brokerAgentContactsList.isEmpty() == false && brokerAgentContactsList[0].First_Name__c !=null&& brokerAgentContactsList[0].First_Name__c!='' ){
            try{
                
                 brokerAgentsList.addAll(brokerAgentContactsList);

                
                Id brokerAgentRecordTypeId = CommonUtility.recordTypeIdByDevName(Broker_Agents__c.sObjectType, 'Agent_Representative');
                for(Broker_Agents__c brokerAgents : brokerAgentContactsList){
                    brokerAgents.RecordTypeId = brokerAgentRecordTypeId;
                }
                
                upsert brokerAgentContactsList;
                
                message = 'Record Created Successfully';
            }catch(Exception ex){
                isSuccess='false';
                message = 'Error: ' + ex.getMessage();
                return isSUccessWithMsg(isSuccess,message);
            }
        }
       
        
       if(saveAsDraft==true){
           sendEmailtoAgency(agencyRecordId,'Draft_registration_of_Agency');  
         } 
        
      system.debug('saveAsDraft is '+ saveAsDraft);  
        
      if(saveAsDraft==false){
       Map<String,String> recIDDocSttausMap = getrecIDDocStatusMap(brokerProprietorsList, brokerAgentsList);
       if(recIDDocSttausMap.values().contains('Pending')){
           isSuccess='false';
           message ='Upload all required documents before submitting the form';
           return isSUccessWithMsg(isSuccess,message);   
        }  
            
        
        try{
            
            Broker__c broker= sendEmailtoAgency(agencyRecordId,'Agency_Registration_Acknowledgement_Email');
            
            if(broker.Agency_Approval_Status__c	!= 'Pending 1st level' && broker.Agency_Approval_Status__c	!= 'Pending 2nd level'){
                // Create an approval request for Broker Registration        
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
                req.setComments('Submitted for Agency registration Approval');        
                req.setObjectId(agencyRecordId);
                req.setSubmitterId(broker.CreatedById);
                req.setProcessDefinitionNameOrId('Broker_Registration_Broker_Portal');
                req.setSkipEntryCriteria(true);
                // Submit the approval request for Broker Registration       
                    Approval.ProcessResult result = Approval.process(req);
            }
            message = 'Record Created Successfully';
        }catch(Exception ex){
           isSuccess='false';

            message = 'Error: ' + ex.getMessage();
            return isSUccessWithMsg(isSuccess,message);
        }
       }
        
          return isSUccessWithMsg(isSuccess,message);
    }
    @AuraEnabled
    public static Map<String,String> getrecIDDocStatusMap(List<Broker_Proprietor__c> brokerProprietorsList,List<Broker_Agents__c> brokerAgentsList){
     Map<String,String> recIDDocumentStatusMap= DocumentStatusHelperCtrl.checkDocumentUploadStatus(brokerProprietorsList,brokerAgentsList); 
     return recIDDocumentStatusMap;    
    }
    
    //Send Welcome Email Notification on registration
    Public static Broker__c sendEmailtoAgency(String agencyRecordId,String TemplateName){
       OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress();
            Broker__c broker = getBroker(agencyRecordId);
            
            if(AppSettings__c.getValues('OrgWideEmailAddressForSR').TextValue__c != null){
                orgWideEmailAddress = EmailNotificationHelper.getOrgWideEmailAddress(AppSettings__c.getValues('OrgWideEmailAddressForSR').TextValue__c);
            }
            System.debug('come here in final stage');
            EmailTemplate emailTemplate = EmailNotificationHelper.getEmailTemplateByName(new set<string>{TemplateName})[0];
            system.debug('email templatge==' + emailTemplate);
            Messaging.SingleEmailMessage[] emailMessagesList = new List<Messaging.SingleEmailMessage>();
            
            emailMessagesList.add(EmailNotificationHelper.buildEmailRequest(new list<string>{broker.Email_Address__c}, emailTemplate.Id, agencyRecordId, orgWideEmailAddress.Id));
            system.debug('email emailMessagesList==' + emailMessagesList);
            //Sending Email
            EmailNotificationHelper.sendEmail(emailMessagesList); 
            return broker;
    }
    
    //get isSucess/isError along with message
    public static List<STring> isSUccessWithMsg(String isSuccess,String message){
        List<String> successInfo = new List<String>();
        successInfo.add(isSuccess);
        successInfo.add(message);
        return successInfo;

        
        
    }
   //get broker details 
    public static Broker__c getBroker(string recordId){
        return [SELECT Id, OwnerId, Name, Email_Address__c, Home_Phone__c, CreatedById,Agency_Approval_Status__c
                FROM Broker__c 
                where Id =: recordId] ;
    }
    //fetch document record
     public static Document__c fetchDocument(Id docID) {
            Document__c document=  [select Id,name,Approval_Status__c ,Remark__c ,Document_Type__c,Issue_Date__c,Expiry_Date__c,Place_of_Issue__c from Document__c where Id =:docID LIMIT 1];
            system.debug('document is '+ document);
            return document;
    }
    //Save document
     public static Document__c saveDocument(Document__c document) {
      upsert document;
      return  document;  
        
    }
    
    /* @param - recId - parentID
                newDoc - Document record
                fileId- File ID  
       @purpose- Creation of document Records*/
     public static void createDocumentRecords(String recId,Document__c newDoc,String fileId){        
        list<document__c> documentUpdateList=new list<document__c>();
        list<document__c> documentList=new list<document__c>();
        list<opportunity> oppList=new list<opportunity>();
        List<Account> accList = new List<Account>();
        Id i =Id.valueOf(recId);
        Id parentId ;
        string objectName=i.getSObjectType().getDescribe().getName();
        system.debug('Update Documents');
        system.debug(newDoc.Document_Type__c);
        //system.debug(newDoc.File_Name__c);
        if(objectName==ConstantUtility.SOBJ_OPPORTUNITY)
        {
            oppList=[select id,account.Id from opportunity where id =:i];
            parentId=oppList[0].account.Id;
        }
        
        
        
        
        documentList=[select id,parent_id__c,Attachment_Id__c,Document_Attached__c ,Approval_Status__c ,Remark__c ,
                      Issue_Date__c,Expiry_Date__c,Document_ID_Number__c
                      from document__c where parent_id__c =: recId and 
                      File_Name__c=:newDoc.Document_Type__c LIMIT 1 ];
        
        system.debug(documentList);
        if(documentList.isEmpty())
        {
            newDoc.parent_id__c=recId;
            newDoc.Attachment_Id__c=fileId;
            newDoc.Document_Attached__c=true;
            newDoc.File_Name__c=newDoc.Document_Type__c;
            newDoc.Document_ID_Number__c = newDoc.Document_ID_Number__c;
            system.debug('objectName is '+ objectName);
            if(objectName==ConstantUtility.SOBJ_AgencyRegistration)
            {
            system.debug('objectName is '+ ConstantUtility.SOBJ_AgencyRegistration);
     
              newDoc.Agency_Registration__c=recId;
            }
            
            else if(objectName==ConstantUtility.SOBJ_Agent)
            {
             newDoc.Agent__c =  recId ;
            }
            
            else if(objectName==ConstantUtility.SOBJ_BrokerProprietor)
            {
             newDoc.Broker_Proprietor__c  =  recId ;
            }
           
            try{  
                system.debug('newDoc >>'  +newDoc);
                system.debug('New Document is inserted');
                insert newDoc;
                createContentDocumentLinks(newDoc);
                if(parentId!=null && newDoc.Document_ID_Number__c!= null){//&& (newDoc.Emirates_ID__c!=null || newDoc.Passport_Number__c!=null)
                    Account accObj = new Account();
                    if(newDoc.Document_Type__c==ConstantUtility.EMIRATES_ID){
                    }
                    if(newDoc.Document_Type__c==ConstantUtility.VALID_PASSPORT){
                    }
                    accObj.id = parentId;
                    
                    //AccountTriggerHandler.TriggerDisabled  = true;commented by hitarth
                    update accObj;
                    //AccountTriggerHandler.TriggerDisabled  = false;commented by hitarth
                }
            }catch(exception e){
                system.debug('Error >> '  +e.getMessage());
            }
            
        }
        else
        {
            
            for (Document__c doc :documentList)
            {
                if(objectName==ConstantUtility.SOBJ_OPPORTUNITY)
                {
                    system.debug('Inside opportunity');
                   
                }
                else
                {
                    doc.Attachment_Id__c=fileId;
                    doc.Document_Type__c=newdoc.Document_Type__c;
                    doc.Document_Attached__c=true;
                    doc.Expiry_Date__c=newDoc.Expiry_Date__c;
                    doc.Issue_Date__c=newDoc.Issue_Date__c;
                    doc.Remark__c=newDoc.Remark__c;
                    doc.Document_ID_Number__c = (newDoc.Document_ID_Number__c!=null)?newDoc.Document_ID_Number__c:doc.Document_ID_Number__c;
                    documentUpdateList.add(doc);
                }
            }
            system.debug(documentUpdateList);
            update documentUpdateList;
            if(accList.size()>0){
                
                //AccountTriggerHandler.TriggerDisabled  = true;commented by hitarth
                update accList;
                //AccountTriggerHandler.TriggerDisabled  = false;commented by hitarth
            }
        }
        
    }
    
    //Create content Document links between document and file created
    public static void  createContentDocumentLinks(Document__c document){ 
        List<ContentDocumentLink> ContentDocumentLinks = new List<ContentDocumentLink>();
        List<ContentDocumentLink> contentDocLinkstoDelete = new List<ContentDocumentLink>();
        for(ContentDocumentLink con:[SELECT ID, LinkedEntityId  from ContentDocumentLink WHERE ContentDocumentID=:document.Attachment_Id__c] ){
              system.debug('con.LinkedEntityId.getSObjectType() is '+ con.LinkedEntityId.getSObjectType()); 
            if(con.LinkedEntityId.getSObjectType()!=Document__c.SObjectType){
               // con.LinkedEntityId= document.Id;
               contentDocLinkstoDelete.add(con);
                
            }
        }
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = document.Id;
            cdl.ContentDocumentId = document.Attachment_Id__c;
            cdl.shareType = 'I';
            ContentDocumentLinks.add(cdl); 
        
        system.debug('ContentDocumentLinks is '+ ContentDocumentLinks);
        if(ContentDocumentLinks.size()>0){
            insert ContentDocumentLinks;
         }
         if(contentDocLinkstoDelete.size()>0){
             delete  contentDocLinkstoDelete;
          } 
            
                                                                                                  
                                                                         
        
    }
   
    /* @param - parentId -parent ID of Document
                deleteRecord - Id of contentDocument
    * @return - Document Details*/ 
    public static List<Document__c> fetchAttachments(Id parentId, Id deleteRecord) {
        system.debug('parentId :'+parentId);
        system.debug('deleteRecord :'+deleteRecord);
        List<Document__c> custdocWithAtt=new list<Document__c>();
        if(deleteRecord != null)
        {
            Document__c doc = [select Id,Attachment_ID__c from Document__c where Id =:deleteRecord];
            ContentDocument con =[SELECT ID from contentDocument WHERE ID=:doc.Attachment_ID__c];
            delete con;

            doc.Attachment_ID__c = null;
            //update c;
            delete doc;
        }
        string sObjName=parentId.getSObjectType().getDescribe().getName();
        List<Document__c> custdoc = new List<Document__c>();
        if(sObjName=='Account')
        {
            string recordType=[SELECT RecordType.Developername  FROM Account where Id =: parentId].RecordType.Developername;
            if (recordType=='Broker_Account' || recordType=='Business_Account')
            {
                custdocWithAtt = [select Name,Document_Type__c,Account__r.Name,Expiry_Date__c,Issue_Date__c,Opportunity__c,
                                  Approval_Status__c ,Remark__c ,Attachment_ID__c,Parent_Id__c , Place_of_Issue__c  from Document__c where 
                                  Parent_Id__c =: parentId AND Attachment_ID__c!=null order by createdDate desc];
                
            }
            else 
            {
                //Documents uploaded on opty and linked to account
                custdocWithAtt = [select Name,Document_Type__c,Account__r.Name,Expiry_Date__c,Issue_Date__c,Opportunity__c,
                                  Approval_Status__c ,Remark__c ,Attachment_ID__c,Parent_Id__c, Place_of_Issue__c  from Document__c where 
                                  Account__c =: parentId AND ParentAPIName__c='Account'
                                  AND Attachment_ID__c!=null order by createdDate desc];
            }      
            
        }
        else
        {
            custdocWithAtt = [select Name,Document_Type__c,Account__r.Name,Expiry_Date__c,Issue_Date__c,Opportunity__c,
                              Approval_Status__c ,Remark__c ,Attachment_ID__c,Parent_Id__c, Place_of_Issue__c  from Document__c where 
                              Parent_Id__c =: parentId AND Attachment_ID__c!=null order by createdDate desc];
        }
        system.debug('custdocWithAtt  >>' +custdocWithAtt );
        return custdocWithAtt;
    }
    
    
    /**
    * This method is used to fetch List of Document record based on case id and account id
    * @date    2021-07-05
    * @author  Husain Sayyed
    */
    @AuraEnabled
    public static Map<String,Document__c> getDocumentList(String parentId, String accountId){
        Map<String,Document__c> docMap = new Map<String,Document__c>();
        if(String.isBlank(accountId)){
            List<Document__c> docList=[select Name,Document_Type__c,Account__r.Name,Expiry_Date__c,Issue_Date__c,Opportunity__c,Approval_Status__c ,Remark__c ,Attachment_ID__c,Parent_Id__c 
                    from Document__c 
                    where (Parent_Id__c =: parentId) AND Attachment_ID__c!=null order by createdDate desc];
            for(Document__c doc: docList){
                docMap.put(doc.Document_Type__c,doc);
            }
        }else{
            List<Document__c> docList= [select Name,Document_Type__c,Account__r.Name,Expiry_Date__c,Issue_Date__c,Opportunity__c,Approval_Status__c ,Remark__c ,Attachment_ID__c,Parent_Id__c 
                    from Document__c 
                    where (Parent_Id__c =: parentId OR Account__c =: accountId) AND Attachment_ID__c!=null order by createdDate desc];
            for(Document__c doc: docList){
                docMap.put(doc.Document_Type__c,doc);
            }
        }
        system.debug('docMap is '+ docMap);
        return docMap;
    }


    @AuraEnabled
    public static void createPublicUrl(String recId,string fileId){
        try{
            ContentDocumentLink cdl = [select contentdocument.id, contentdocument.title, contentdocument.filetype from contentdocumentlink where linkedentityid =:recID and ContentDocument.Id=:fileId];
            ContentVersion cv = [select id from contentversion where contentdocumentid = :fileId];//cdl.contentdocument.id];
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'Test';
            cd.ContentVersionId = cv.id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            cd.RelatedRecordId = recId;
            insert cd;
            ContentDistribution content = [SELECT DistributionPublicUrl FROM ContentDistribution where RelatedRecordId=:recId and ContentDocumentId=:fileId];
            
        }
        catch(exception e){
            system.debug('Error >> '  +e.getMessage());
        }
    }
    
    
   
    
    public static String getDocumentTemplates(Id recordId){
        system.debug('==recordId='+recordId);
        list<string> documentTypes=new list<string>();
        list<string> recordTypeList=new list<string>();
        list<string> recordTypeAccList=new list<string>();
        set<Id> accountIds=new set<Id>();
        List<opportunity> oppList=new list<opportunity>();
        string developerName='';
        string country='';
        string placeOfIncorporation='';
        string emirate='';
        string accRecordType='';
        string Nationality='';
        String agencyLocation='';
        String brokerAccessType='';
        string objectName=recordId.getSObjectType().getDescribe().getName();
        system.debug(objectName);
        if(objectName=='Broker__c')
        {
            for(Broker__c br : [SELECT RecordType.Developername,Emirate__c,Place_of_Incorporation__c, Agency_Location__c   
                                FROM broker__c where Id =: recordId])
            {
                agencyLocation = br.Agency_Location__c;
                placeOfIncorporation=br.Place_of_Incorporation__c;
                emirate= br.Emirate__c ;
                recordTypeList.add(br.RecordType.Developername);
            }
        }
        else if(objectName=='Account')
        {
            for(Account acc : [SELECT RecordType.Developername  
                               FROM Account where Id =: recordId])
            {
                recordTypeAccList.add(acc.RecordType.Developername);
            }
        }
        else if(objectName=='Broker_Agents__c')
        {
            for(Broker_Agents__c br : [SELECT RecordType.Developername, Broker_Access_Type__c ,Agency_Registration__r.Place_of_Incorporation__c,Agency_Registration__r.Emirate__c  
                                       FROM Broker_Agents__c where Id =: recordId])
            {
                country=br.Agency_Registration__r.Place_of_Incorporation__c ;
                //placeOfIncorporation=br.Place_of_Incorporation__c;
                emirate= br.Agency_Registration__r.Emirate__c ;
                brokerAccessType = br.Broker_Access_Type__c;

                //placeOfIncorporation=br.Place_of_Incorporation__c;
                recordTypeList.add(br.RecordType.Developername);
            }
        }
        
        else if(objectName=='Broker_Proprietor__c')
        {
            for(Broker_Proprietor__c  br : [SELECT  Agency_Registration__r.Place_of_Incorporation__c,Agency_Registration__r.Emirate__c  
                                       FROM Broker_Proprietor__c where Id =: recordId])
            {
                country=br.Agency_Registration__r.Place_of_Incorporation__c ;
                //placeOfIncorporation=br.Place_of_Incorporation__c;
                emirate= br.Agency_Registration__r.Emirate__c ;

                //placeOfIncorporation=br.Place_of_Incorporation__c;
              //  recordTypeList.add(br.RecordType.Developername);
            }
        }
        
        
        system.debug('==recordTypeList=='+recordTypeList);
        system.debug('==placeOfIncorporation=='+placeOfIncorporation);
        system.debug('agencyLocation==' + agencyLocation);
        if(!recordTypeList.isEmpty())
        {
            if(agencyLocation == 'Local'){
                developerName='NKHL_Broker_Local';
            }
            if(agencyLocation == 'International'){
                developerName='NKHL_Broker_International';
            } 
            
            if(emirate == 'Dubai'){
                developerName='NKHL_Broker_Local_Dubai';
            } 
                

            if((recordTypeList[0]=='Agent_Representative') && country!='AE')
            {
                developerName='NKHL_Agent_International_representative';
                
            }
           
            else if((recordTypeList[0]=='Authorized_Signatory') && country!='AE')
            {
                developerName='Agent_International_Authorized_Signatory';
                
            }
            else if((recordTypeList[0]=='Agent_Representative') && country=='AE' && emirate != 'Dubai')
            {
                developerName='NKHL_Agent_Local_representative';        
            }
            
            else if((recordTypeList[0]=='Agent_Representative') && country=='AE' && emirate == 'Dubai' && brokerAccessType!='Admin')
            {
                developerName='NKHL_Agent_Dubai_representative';        
            }
             else if((recordTypeList[0]=='Agent_Representative') && country=='AE' && emirate == 'Dubai' && brokerAccessType=='Admin')
            {
                developerName='Admin_Dubai_representative';        
            }
           
            else if((recordTypeList[0]=='Authorized_Signatory') && country=='AE'  && emirate != 'Dubai')
            {
                developerName='Agent_Local_Authorized_Signatory';        
            }
            
            else if((recordTypeList[0]=='Authorized_Signatory') && country=='AE'  && emirate == 'Dubai')
            {
                developerName='Agent_Dubai_Authorized_Signatory';        
            }
        }
       
        else if(objectName=='Broker_Proprietor__c')
        {
               
            if(country!='AE'){
               developerName='NKHL_Shareholder_International'; 
            }
            else if(country=='AE' && emirate!='Dubai'){
                developerName='NKHL_Shareholder_Local';
            }
            else if(country=='AE' && emirate=='Dubai'){
                
              developerName='NKHL_Shareholder_Local_Dubai';
            }
                    
        }
        
         else if(objectName=='Account')

     system.debug('developerName is'+ developerName);  
     system.debug('emirate  is'+ emirate);   
    
     return developerName;
    }
    
    /* @param - recordId - record id of object of which document type values needs to be returned
       @purpose -get all the document  type values for the record    */
   
    @AuraEnabled
    public static List<NKHL_Documentation_Template__mdt >  getdocumentTypeValues( Id recordId) {
        list<NKHL_Documentation_Template__mdt >MdtDocumentList=new list<NKHL_Documentation_Template__mdt > ();
        String developerName=getDocumentTemplates(recordId);
        list<Id> documentMatrixIdList=new list<Id>();
        system.debug('developerName is '+ developerName);
        for(NKHL_Documentation_Matrix__mdt  doc : [SELECT id FROM NKHL_Documentation_Matrix__mdt WHERE developerName =:developerName])
        {
            documentMatrixIdList.add(doc.id);
            
        } 
        
        for(NKHL_Documentation_Template__mdt  doc:[select id ,Document_Label__c,Is_Required_Expiry_Date__c,Is_Required_Issue_Date__c,Required__c,is_Document_ID_NumberRequired__c, Is_Emirates_ID__c from NKHL_Documentation_Template__mdt  where NKHL_Documentation_Matrix__c=:documentMatrixIdList[0]])
        {
            
            MdtDocumentList.add(doc);
        } 
        
        
        return MdtDocumentList;
    }
        
    
    
    //check if duplicate TRN number exists in system 

    @AuraEnabled
    public static Boolean checkDuplicateTradeLicenseNumber(String tradeLicenseNumber, Id brokerId){
        Boolean flag = false;
        List<Broker__c> brokerList = [SELECT Id from Broker__c where Trade_Licence_Number__c =:tradeLicenseNumber AND Id !=: brokerId];
            if(brokerList.size() > 0) flag = true;
        return flag;
    }
    
    @AuraEnabled
    public static Boolean checkDuplicateEmail(String brokerEmail,Id brokerId){
        system.debug('----duplicate Email called---'+brokerEmail);
        Boolean flag = false;
        List<Broker__c> brokerList = [SELECT Id, Email_Address__c  from Broker__c where Email_Address__c  =:brokerEmail AND Id !=: brokerId];
        
            if(brokerList.size() > 0){
                flag = true;
            }
            else{
                flag = false;
            }
            
            system.debug('>>>>'+flag);
             
        return flag;
    }
    
    
    
    
 
     //Added By Mamta
    //When there is change in country or emirates the previous documents record are deleted along with files
     @AuraEnabled
    public static void deletePreviousDocuments(String country, String Emirates,String agencyID){
      system.debug('country is '+ country); 
      system.debug('Emirates is '+ Emirates);   
      system.debug('agencyID is '+ agencyID);   
      Set<String> docParentIDS = new Set<String>();
      Broker__c  broker  = [Select id, Place_of_Incorporation__c,Emirate__c FROM Broker__c   Where id=:agencyID];
      docParentIDS.add(broker.Id);  
      List<Broker_Proprietor__c> PartnerLst =[select id from Broker_Proprietor__c WHERE Agency_Registration__c  =:broker.Id];
      List<Broker_Agents__c >    brokerAgents = [select id from Broker_Agents__c WHERE Agency_Registration__c=:broker.Id];
        
      for(Broker_Proprietor__c bp: PartnerLst){
          docParentIDS.add(bp.Id); 
        }
        
      for(Broker_Agents__c ba: brokerAgents){
          docParentIDS.add(ba.Id); 
        }
        
      boolean deleteDocs = false;  
        if(( country!=broker.Place_of_Incorporation__c)|| ( Emirates!= broker.Emirate__c)){
            deleteDocs= true;
        }  
        
        system.debug('deleteDocs is '+ deleteDocs);
        if(deleteDocs== true){
            List<Document__c  > documents =[select id, Attachment_Id__c from Document__c where Parent_ID__c IN :docParentIDS];
            Set<String> contentdocIDS = new Set<String>();
            for(Document__c doc :documents ){
                contentdocIDS.add(doc.Attachment_Id__c);
             }
            List<contentDocument> contentDocuments = [select id from contentDocument WHERE ID IN :contentdocIDS];
            if(documents.size()>0){
                delete documents;
            }
    
            if(contentDocuments.size()>0){
                delete contentDocuments;
            }
        }
    }

    /*Public static list<AgencyRegistrationFormController.BrokerWithUploadStatusWrapper> checkDocumentUploadStatus(List<Broker_Proprietor__c> brokerProprietorsList,List<Broker_Agents__c> brokerAgentsList){
     /*Start- Check All required files are uploaded for all individual broker Agents added by Mamta*/
        //string objectName=i.getSObjectType().getDescribe().getName(); 
        //
        //
       /* List<AgencyRegistrationFormController.BrokerWithUploadStatusWrapper> brokerdocWrpLst = new  List<AgencyRegistrationFormController.BrokerWithUploadStatusWrapper>();
        
        Map<String,String> IDDocUploadStatusMap = new Map<String,String>();
        Map<String,STring> agentAndDocMap = new Map<String,String>();
        Map<String,STring> partnerAndDocMap = new Map<String,String>();
        Map<String,STring> agentAndDocMatrixIDMap = new Map<String,String>();
        List<Id> documentMatrixIdList=new list<Id>();
   
        for(Broker_Proprietor__c pr:[SELECT Id, Agency_Registration__r.Place_of_Incorporation__c ,Agency_Registration__r.Emirate__c
                                     from Broker_Proprietor__c WHERE ID IN:brokerProprietorsList]){
             String developerName='';
                                         
             String country=pr.Agency_Registration__r.Place_of_Incorporation__c ;
             String emirate=  pr.Agency_Registration__r.Emirate__c;
             developerName=  getDocMatrixDeveloperName('',pr.Id, Country,  Emirate,'');
             partnerAndDocMap.put(pr.Id,developerName);                           
                                         
                                         
          }
        
        for(Broker_Agents__c br : [SELECT Id,RecordType.Developername, Broker_Access_Type__c ,Agency_Registration__r.Place_of_Incorporation__c ,Agency_Registration__r.Emirate__c 
                                       FROM Broker_Agents__c where Id IN: brokerAgentsList])
            {
                String developerName='';
                String country=br.Agency_Registration__r.Place_of_Incorporation__c ;
                String emirate=  br.Agency_Registration__r.Emirate__c;
                String brokerAccessType=br.Broker_Access_Type__c;
                String recTypeName = br.RecordType.Developername;
                developerName=  getDocMatrixDeveloperName(recTypeName,br.Id, Country,  Emirate,brokerAccessType);

             agentAndDocMap.put(br.Id,developerName);
            }
        
         for(NKHL_Documentation_Matrix__mdt  doc : [SELECT id,developerName FROM NKHL_Documentation_Matrix__mdt  WHERE developerName IN :agentAndDocMap.values() OR developerName IN : partnerAndDocMap.values()])
        {
            documentMatrixIdList.add(doc.id);
            agentAndDocMatrixIDMap.put(doc.developerName ,doc.id);
            
        } 
        
        Map<String,List<NKHL_Documentation_Template__mdt >> docandTemplatesLstMap = new Map<String,List<NKHL_Documentation_Template__mdt >>();
        for(NKHL_Documentation_Template__mdt  doc:[select id ,NKHL_Documentation_Matrix__r.DeveloperName,Document_Label__c,Is_Required_Expiry_Date__c,
                                                 Is_Required_Issue_Date__c,Required__c,is_Document_ID_NumberRequired__c 
                                                 from NKHL_Documentation_Template__mdt  where 
                                                 (NKHL_Documentation_Matrix__r.developername=:agentAndDocMap.values() OR NKHL_Documentation_Matrix__r.developername=:partnerAndDocMap.values() )AND Required__c=true ])//Get required templates
        {
          if(docandTemplatesLstMap.containskey(doc.NKHL_Documentation_Matrix__r.developername)){
              List<NKHL_Documentation_Template__mdt  > documentTemplateValues = docandTemplatesLstMap.get(doc.NKHL_Documentation_Matrix__r.developername);
              documentTemplateValues.add(doc);
              docandTemplatesLstMap.put(doc.NKHL_Documentation_Matrix__r.developername,documentTemplateValues);//Map of developerName of matrix and Required templates
          } 
          else{
              List<NKHL_Documentation_Template__mdt > documentTemplateValues = new List<NKHL_Documentation_Template__mdt >();
              documentTemplateValues.add(doc);
              docandTemplatesLstMap.put(doc.NKHL_Documentation_Matrix__r.developername,documentTemplateValues);//Map of developerName of matrix and Required templates
          }  
          
        } 
       system.debug('docandTemplatesLstMap is '+ docandTemplatesLstMap); 
      
      Map<String, Set<String>>  agentIDDocumentSetMap =new  Map<String, Set<String>> (); //Map of Agent Id and set of all document types uploaded for it
      Map<String, Set<String>>  partnerIDDocumentSetMap =new  Map<String, Set<String>> (); //Map of Partner  Id and set of all document types uploaded for it
   
      List<Document__c>  documents =[select id,Approval_Status__c ,Remark__c ,Document_Type__c ,Parent_Id__c  FROM Document__c WHERE 
                                     Parent_Id__c IN:agentAndDocMap.keySet() OR Parent_Id__c IN:partnerAndDocMap.keySet()]; 
      for(Document__c doc :documents){
          String sObjectName= Id.valueof((doc.Parent_Id__c)).getSObjectType().getDescribe().getName();
          if(sObjectName=='Broker_Agents__c'){//check added documents in broker agent sObject
          if(agentIDDocumentSetMap.containskey(doc.Parent_Id__c)){
              Set<String> documentValues = agentIDDocumentSetMap.get(doc.Parent_Id__c);
              documentValues.add(doc.Document_Type__c);
              agentIDDocumentSetMap.put(doc.Parent_Id__c,documentValues);
          }
          else{
              Set<String> documentValues = new Set<String>();
              documentValues.add(doc.Document_Type__c);
              agentIDDocumentSetMap.put(doc.Parent_Id__c,documentValues);
          }
          }
          else if(sObjectName=='Broker_Proprietor__c'){//check added documents in broker partner sObject
          if(partnerIDDocumentSetMap.containskey(doc.Parent_Id__c)){
              Set<String> documentValues = partnerIDDocumentSetMap.get(doc.Parent_Id__c);
              documentValues.add(doc.Document_Type__c);
              partnerIDDocumentSetMap.put(doc.Parent_Id__c,documentValues);
          }
          else{
              Set<String> documentValues = new Set<String>();
              documentValues.add(doc.Document_Type__c);
              partnerIDDocumentSetMap.put(doc.Parent_Id__c,documentValues);
          }
          }
            
        }  
        
        boolean allRequiredFileUploaded = true;
        for(Broker_Proprietor__c partner :brokerProprietorsList){
            AgencyRegistrationFormController.BrokerWithUploadStatusWrapper wrp = new AgencyRegistrationFormController.BrokerWithUploadStatusWrapper();
            if(partnerAndDocMap.containskey(partner.Id)){
                String developerName = partnerAndDocMap.get(partner.Id);//get developer name of templateMatrix based on agent
                List<NKHL_Documentation_Template__mdt> requireDocLst = docandTemplatesLstMap.get(developerName);//get all required doc templates for particular developer name
                system.debug('requireDocLst is '+ requireDocLst);
                system.debug('partner is '+ partner);
                for(NKHL_Documentation_Template__mdt  DocTemp: requireDocLst){
                    Set<String> documentTypesSet = partnerIDDocumentSetMap.get(partner.Id);
                    system.debug('documentTypesSet is '+ documentTypesSet);
                    if(documentTypesSet==null){
                        allRequiredFileUploaded = false;
                        
                       
                    }
                    else if(!documentTypesSet.contains(DocTemp.Document_Label__c)){//check if added document set contains all required documents or not
                        allRequiredFileUploaded= false;//mark it false , if not all files uploaded for particular agent to prevent submitting form

                    }
                    
                }
          }
            if(allRequiredFileUploaded==false){
                wrp.brokerprop= partner;
                wrp.DocUploadStatus='Pending';
            }
            else if(allRequiredFileUploaded==true){
                wrp.brokerprop= partner;
                wrp.DocUploadStatus='Completed';
            }
            brokerdocWrpLst.add(wrp);
        }
        
        //check if partner contains all required documents
        for(Broker_Agents__c agent :brokerAgentsList){
            String recTypeName = agent.RecordType.Developername;
            String brokerAccessType=agent.Broker_Access_Type__c;
            AgencyRegistrationFormController.BrokerWithUploadStatusWrapper agentWrp = new AgencyRegistrationFormController.BrokerWithUploadStatusWrapper();


            if(agentAndDocMap.containskey(agent.Id)){
                String developerName = agentAndDocMap.get(agent.Id);//get developer name of templateMatrix based on agent
                List<NKHL_Documentation_Template__mdt> requireDocLst = docandTemplatesLstMap.get(developerName);//get all required doc templates for particular developer name
                system.debug('requireDocLst is '+ requireDocLst);
                system.debug('agent is '+ agent);
                for(NKHL_Documentation_Template__mdt  DocTemp: requireDocLst){
                    Set<String> documentTypesSet = agentIDDocumentSetMap.get(agent.Id);
                    system.debug('documentTypesSet is '+ documentTypesSet);
                    if(documentTypesSet==null){
                        allRequiredFileUploaded = false;
                       
                    }
                    else if(!documentTypesSet.contains(DocTemp.Document_Label__c)){//check if added document set contains all required documents or not
                        allRequiredFileUploaded= false;//mark it false , if not all files uploaded for particular agent to prevent submitting form
                      
                    }
               
          }
            if(recTypeName==ConstantUtility.RT_AGENT_REP && brokerAccessType=='Admin'){   
             if(allRequiredFileUploaded==false){
                agentWrp.brokerAgentRepresentativeList= agent;
                agentWrp.DocUploadStatus='Pending';
            }
            else if(allRequiredFileUploaded==true){
                agentWrp.brokerAgentRepresentativeList= agent;
                agentWrp.DocUploadStatus='Completed';
            }
                }
                
                else if(recTypeName==ConstantUtility.DN_AUTHO_SIGN){
                    if(allRequiredFileUploaded==false){
                        agentWrp.brokerAgentAuth= agent;
                        agentWrp.DocUploadStatus='Pending';
                    }
                    else if(allRequiredFileUploaded==true){
                        agentWrp.brokerAgentAuth= agent;
                        agentWrp.DocUploadStatus='Completed';
                    }
                }
                brokerdocWrpLst.add(agentWrp);
                }
        }
        system.debug('agentIDDocumentSetMap is '+ agentIDDocumentSetMap);
        system.debug('allRequiredFileUploaded is '+ allRequiredFileUploaded);
        
      
         return brokerdocWrpLst;  
    }*/

    
    
   
}