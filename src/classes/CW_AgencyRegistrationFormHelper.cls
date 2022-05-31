public without sharing class CW_AgencyRegistrationFormHelper {   
    
  public static list<NKHL_Documentation_Template__mdt >MdtDocumentList=new list<NKHL_Documentation_Template__mdt > ();
   
    public static Broker__c getBrokerDetails(string recordId){
       system.debug('User is '+ UserInfo.getUserId());

        system.debug([SELECT RecordId FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND HasReadAccess = true AND RecordId = :recordId ]);

        return [select Id, RecordType.name,Broker_Number__c,Exisiting_Broker__c,Agency_Location__c , Agency_Approval_Status__c, RecordTypeId, Company_Name__c,
                Trade_Licence_Number__c, Agency_Type__c, Mobile_Country_Code__c, Mobile__c, Rera_Registration_No__c,TRN_No__c ,
                Email_Address__c, Address_Line__c, Place_of_Incorporation__c, Emirate__c, City__c,State__c,
                Bank_Account_Name__c,Other_Bank_Name__c  , Bank_Name__c, Bank_Account__c, Bank_Address__c,Bank_IBAN_Number__c,Bank_SWIFT_Code__c,
                Bank_Branch__c,Bank_Currency_of_Account__c,Account_Number__c,(select id,Agreement_Status__c  from Accounts__r)  
                from Broker__c 
                where Id =: recordId];//added existing broker field -by mamta
    }
    public static Account updateAccount (Account account) {
        upsert account ;
        return account;    
    }
    
     public static list<Broker_Proprietor__c> getbrokerpropDetails(string recordId){
        return [select Id, Name, Agency_Registration__c, Shareholder_Passport_No__c, Shareholder_Percentage__c  
                from Broker_Proprietor__c 
                where Agency_Registration__c =: recordId];
    }
    
    public static list<Broker_Agents__c> getbrokerAgentAuthDetails(string recordId, string recordTypeName){
        return [select Id, Name, RecordTypeId, RecordType.DeveloperName, Agency_Registration__c, Branch_Location__c, Contact_Person__c, Country_Code__c, Designation__c, Email__c, First_Name__c, Last_Name__c, Member_of_Real_Estate_Agency_Association__c, Mobile__c, Operating_Since__c, CEP_Broker_Contact_ID__c, Broker_Access_Type__c
                from Broker_Agents__c
                where Agency_Registration__c =: recordId AND RecordType.DeveloperName =: recordTypeName AND Broker_Access_Type__c!=null];
    }
    
    public static list<Broker_Agents__c> getbrokerAdditionalContactDetails(string recordId, string recordTypeName){
        return [select Id, Name, RecordTypeId, RecordType.DeveloperName, Agency_Registration__c, Branch_Location__c, Contact_Person__c, Country_Code__c, Designation__c, Email__c, First_Name__c, Last_Name__c, Member_of_Real_Estate_Agency_Association__c, Mobile__c, Operating_Since__c, CEP_Broker_Contact_ID__c, Broker_Access_Type__c
                from Broker_Agents__c
                where Agency_Registration__c =: recordId AND RecordType.DeveloperName =: recordTypeName AND Broker_Access_Type__c=null];
    }
    
     public static Broker__c createAgencyRegistrationRecord (Broker__c AgencyDetails) {
        upsert AgencyDetails;
        system.debug('AgencyDetails=' +AgencyDetails);
        return getBrokerDetails(AgencyDetails.Id);
    }
    
    public static List<Broker_Proprietor__c> createBrokerProprietorsRecord (string agencyRecordId, List<Broker_Proprietor__c> brokerProprietorsList) {
       system.debug('brokerProprietorsList' + brokerProprietorsList);
        upsert brokerProprietorsList;
        return brokerProprietorsList;
    }
    
     public static Map<String, String> getAgreementStatus(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Account.Agreement_Status__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
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
    
     //Not required as managed from agencyREsgistrationFormHelperCtrl- Commented by Mamta

   /* public static List<Broker_Agents__c> createBrokerAgentsAdditionalContactsRecord (string agencyRecordId, List<Broker_Agents__c> brokerAgentContactsList) {
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
    }*/
    
    //Not required as managed from agencyREsgistrationFormHelperCtrl- Commented by Mamta
   /* public static List<String> createBrokerProprietorsAndAgentsRecord (string agencyRecordId, List<Broker_Proprietor__c> brokerProprietorsList, List<Broker_Agents__c> brokerAgentAuthList, List<Broker_Agents__c> brokerAgentRepresentativeList, List<Broker_Agents__c> brokerAgentContactsList){
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
        /*Start- Check All required files are uploaded for all individual broker Agents added by Mamta*/
        
       /* Map<String,STring> agentAndDocMap = new Map<String,String>();
        Map<String,STring> partnerAndDocMap = new Map<String,String>();
        Map<String,STring> agentAndDocMatrixIDMap = new Map<String,String>();
        List<Id> documentMatrixIdList=new list<Id>();
   
        for(Broker_Proprietor__c pr:[SELECT Id, Agency_Registration__r.Place_of_Incorporation__c ,Agency_Registration__r.Emirate__c
                                     from Broker_Proprietor__c WHERE ID IN:brokerProprietorsList]){
             String developerName='';

             String country=pr.Agency_Registration__r.Place_of_Incorporation__c ;
             String emirate=  pr.Agency_Registration__r.Emirate__c;
              if(country!='AE'){
               developerName='NKHL_Shareholder_International'; 
            }
            else if(country=='AE' && emirate!='Dubai'){
                developerName='NKHL_Shareholder_Local';
            }
            else if(country=='AE' && emirate=='Dubai'){
                
              developerName='NKHL_Shareholder_Local_Dubai';
            }
                                         
              partnerAndDocMap.put(pr.Id,developerName);                           
                           
                                         
          }
        
        for(Broker_Agents__c br : [SELECT Id,RecordType.Developername, Broker_Access_Type__c ,Agency_Registration__r.Place_of_Incorporation__c ,Agency_Registration__r.Emirate__c 
                                       FROM Broker_Agents__c where Id IN: brokerAgentsList])
            {
                String developerName='';
                String country=br.Agency_Registration__r.Place_of_Incorporation__c ;
                String emirate=  br.Agency_Registration__r.Emirate__c;
                String brokerAccessType=br.Broker_Access_Type__c;
                //placeOfIncorporation=br.Place_of_Incorporation__c;
                //recordTypeList.add(br.RecordType.Developername);
                 if((br.RecordType.Developername=='Agent_Representative') && country!='AE')
            {
                developerName='NKHL_Agent_International_representative';
                
            }
                else if((br.RecordType.Developername=='Authorized_Signatory') && country!='AE')
            {
                developerName='Agent_International_Authorized_Signatory';
                
            }
           else if((br.RecordType.Developername=='Agent_Representative') && country=='AE' && emirate != 'Dubai')
            {
                developerName='NKHL_Agent_Local_representative';        
            }
            
            else if((br.RecordType.Developername=='Agent_Representative') && country=='AE' && emirate == 'Dubai' && brokerAccessType!='Admin')
            {
                developerName='NKHL_Agent_Dubai_representative';        
            }
                else if((br.RecordType.Developername=='Agent_Representative') && country=='AE' && emirate == 'Dubai' && brokerAccessType=='Admin')
            {
                developerName='Admin_Dubai_representative';        
            }
            else if((br.RecordType.Developername=='Authorized_Signatory') && country=='AE'  && emirate != 'Dubai')
            {
                developerName='Agent_Local_Authorized_Signatory';        
            }
            
            else if((br.RecordType.Developername=='Authorized_Signatory') && country=='AE'  && emirate == 'Dubai')
            {
                developerName='Agent_Dubai_Authorized_Signatory';        
            }
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
      Map<String, Set<String>>  partnerIDDocumentSetMap =new  Map<String, Set<String>> (); //Map of Agent Id and set of all document types uploaded for it
   
      List<Document__c>  documents =[select id,Approval_Status__c ,Remark__c ,Document_Type__c ,Parent_Id__c  FROM Document__c WHERE 
                                     Parent_Id__c IN:agentAndDocMap.keySet() OR Parent_Id__c IN:partnerAndDocMap.keySet()]; 
        //i.getSObjectType().getDescribe().getName();
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
                        break;
                    }
                    else if(!documentTypesSet.contains(DocTemp.Document_Label__c)){//check if added document set contains all required documents or not
                        allRequiredFileUploaded= false;//mark it false , if not all files uploaded for particular agent to prevent submitting form
                        break;
                    }
                }
          }
        }
        
        //check if partner contains all required documents
        for(Broker_Agents__c agent :brokerAgentsList){
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
                        break;
                    }
                    else if(!documentTypesSet.contains(DocTemp.Document_Label__c)){//check if added document set contains all required documents or not
                        allRequiredFileUploaded= false;//mark it false , if not all files uploaded for particular agent to prevent submitting form
                        break;
                    }
                }
          }
        }
        system.debug('agentIDDocumentSetMap is '+ agentIDDocumentSetMap);
        system.debug('allRequiredFileUploaded is '+ allRequiredFileUploaded);
        
        if(allRequiredFileUploaded==false){
            isSuccess='false';
            message ='Upload all required documents before submitting the form';
            return isSUccessWithMsg(isSuccess,message);


       }
        /*End - Check All required files are uploaded for all individual broker Agents - added by Mamta*/
         /*End - File upload validation on submit*/
        
       
        
        
       /* try{
            OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress();
            Broker__c broker = getBroker(agencyRecordId);
            
            if(AppSettings__c.getValues('OrgWideEmailAddressForSR').TextValue__c != null){
                orgWideEmailAddress = EmailNotificationHelper.getOrgWideEmailAddress(AppSettings__c.getValues('OrgWideEmailAddressForSR').TextValue__c);
            }
            System.debug('come here in final stage');
            EmailTemplate emailTemplate = EmailNotificationHelper.getEmailTemplateByName(new set<string>{'Agency_Registration_Acknowledgement_Email'})[0];
            system.debug('email templatge==' + emailTemplate);
            Messaging.SingleEmailMessage[] emailMessagesList = new List<Messaging.SingleEmailMessage>();
            
            emailMessagesList.add(EmailNotificationHelper.buildEmailRequest(new list<string>{broker.Email_Address__c}, emailTemplate.Id, agencyRecordId, orgWideEmailAddress.Id));
            system.debug('email emailMessagesList==' + emailMessagesList);
            //Sending Email
            EmailNotificationHelper.sendEmail(emailMessagesList);
            
            // Create an approval request for Broker Registration        
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('Submitted for Agency registration Approval');        
            req.setObjectId(agencyRecordId);
            req.setSubmitterId(broker.CreatedById);
            req.setProcessDefinitionNameOrId('Broker_Registration_Broker_Portal');
            req.setSkipEntryCriteria(true);
            // Submit the approval request for Broker Registration       
            Approval.ProcessResult result = Approval.process(req);
            message = 'Record Created Successfully';
        }catch(Exception ex){
           isSuccess='false';

            message = 'Error: ' + ex.getMessage();
            return isSUccessWithMsg(isSuccess,message);
        }
        
          return isSUccessWithMsg(isSuccess,message);
    }
    */
    
    /*commented By mamta- 25 Sep- Not Required
    public static List<STring> isSUccessWithMsg(String isSuccess,String message){
        List<String> successInfo = new List<String>();
        successInfo.add(isSuccess);
        successInfo.add(message);
        return successInfo;

        
        
    }*/
    
    public static Broker__c getBroker(string recordId){
        return [SELECT Id, OwnerId, Name, Email_Address__c, Home_Phone__c, CreatedById
                FROM Broker__c 
                where Id =: recordId] ;
    }
    
     public static Document__c fetchDocument(Id docID) {
            Document__c document=  [select Id,name,Approval_Status__c ,Remark__c ,Document_Type__c,Issue_Date__c,Expiry_Date__c,Place_of_Issue__c from Document__c where Id =:docID LIMIT 1];
            system.debug('document is '+ document);
            return document;
    }
    
     public static Document__c saveDocument(Document__c document) {
      upsert document;
      return  document;  
        
    }
    
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
            //newDoc.Emirates_ID__c = newDoc.Emirates_ID__c;
            //newDoc.Passport_Number__c = newDoc.Passport_Number__c;
            
            
            try{  
                system.debug('newDoc >>'  +newDoc);
                system.debug('New Document is inserted');
                insert newDoc;
                createContentDocumentLinks(newDoc);
                if(parentId!=null && newDoc.Document_ID_Number__c!= null){//&& (newDoc.Emirates_ID__c!=null || newDoc.Passport_Number__c!=null)
                    Account accObj = new Account();
                    if(newDoc.Document_Type__c==ConstantUtility.EMIRATES_ID){
                        //accObj.Emirates_Id__c =newDoc.Document_ID_Number__c;  commented by hitarth
                    }
                    if(newDoc.Document_Type__c==ConstantUtility.VALID_PASSPORT){
                        //accObj.Passport_No__c = newDoc.Document_ID_Number__c;commented by hitarth
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
                   /* doc.Attachment_Id__c=fileId;
                    doc.Document_Type__c=newdoc.Document_Type__c;
                    doc.Document_Attached__c=true;
                    doc.Account__c=parentId;
                    doc.Expiry_Date__c=newDoc.Expiry_Date__c;
                    doc.Issue_Date__c=newDoc.Issue_Date__c;
                    doc.Remark__c=newDoc.Remark__c;
                    doc.Document_ID_Number__c = (newDoc.Document_ID_Number__c!=null)?newDoc.Document_ID_Number__c:doc.Document_ID_Number__c;
                    //doc.Passport_Number__c =(newDoc.Passport_Number__c!=null)?newDoc.Passport_Number__c:doc.Passport_Number__c;// newDoc.Passport_Number__c;
                    documentUpdateList.add(doc);
                    if(parentId!=null && newDoc.Document_ID_Number__c!= null){//&& (newDoc.Emirates_ID__c!=null || newDoc.Passport_Number__c!=null)
                        Account accObj = new Account();
                        if(newDoc.Document_Type__c==ConstantUtility.EMIRATES_ID){
                            //accObj.Emirates_Id__c =newDoc.Document_ID_Number__c;  commented by hitarth
                        }
                        if(newDoc.Document_Type__c==ConstantUtility.VALID_PASSPORT){
                            //accObj.Passport_No__c = newDoc.Document_ID_Number__c; commented by hitarth
                        }
                        accObj.id = parentId;
                        accList.add(accObj);
                    }*/ /* commented by mamta, nothing on opportunity till*/
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
                    //doc.Passport_Number__c =(newDoc.Passport_Number__c!=null)?newDoc.Passport_Number__c:doc.Passport_Number__c;// newDoc.Passport_Number__c;
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
    
    public static void  createContentDocumentLinks(Document__c document){ 
        List<ContentDocumentLink> ContentDocumentLinks = new List<ContentDocumentLink>();
        List<ContentDocumentLink> contentDocLinkstoDelete = new List<ContentDocumentLink>();
        for(ContentDocumentLink con:[SELECT ID, LinkedEntityId  from ContentDocumentLink WHERE ContentDocumentID=:document.Attachment_Id__c] ){
              system.debug('con.LinkedEntityId.getSObjectType() is '+ con.LinkedEntityId.getSObjectType() +' - '+ Document__c.SObjectType); 
            if(con.LinkedEntityId.getSObjectType()!=Document__c.SObjectType){
               // con.LinkedEntityId= document.Id;
               contentDocLinkstoDelete.add(con);
                
            }
        }
       // for(Document__c doc: documentUpdateList){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = document.Id;
            cdl.ContentDocumentId = document.Attachment_Id__c;
            cdl.shareType = 'I';
            ContentDocumentLinks.add(cdl); 
        //}
        
        system.debug('ContentDocumentLinks is '+ ContentDocumentLinks);
        if(ContentDocumentLinks.size()>0){
            insert ContentDocumentLinks;
         }
         //if(contentDocLinkstoDelete.size()>0){
            // delete  contentDocLinkstoDelete;
         // } 
            
                                                                                                  
                                                                         
        
    }
        
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
                custdocWithAtt = [select Name,Document_Type__c,Account__r.Name,Expiry_Date__c,Issue_Date__c,Opportunity__c,Document_ID_Number__c,
                                  Approval_Status__c ,Remark__c ,Attachment_ID__c,Parent_Id__c , Place_of_Issue__c  from Document__c where 
                                  Parent_Id__c =: parentId AND Attachment_ID__c!=null order by createdDate desc];
                
            }
            else 
            {
                //Documents uploaded on opty and linked to account
                custdocWithAtt = [select Name,Document_Type__c,Account__r.Name,Expiry_Date__c,Issue_Date__c,Opportunity__c,Document_ID_Number__c,
                                  Approval_Status__c ,Remark__c ,Attachment_ID__c,Parent_Id__c, Place_of_Issue__c  from Document__c where 
                                  Account__c =: parentId AND ParentAPIName__c='Account'
                                  AND Attachment_ID__c!=null order by createdDate desc];
            }      
            
        }
        else
        {
            custdocWithAtt = [select Name,Document_Type__c,Account__r.Name,Expiry_Date__c,Issue_Date__c,Opportunity__c,
                              Document_Attached__c ,Required__c,Document_ID_Number__c,
                              Approval_Status__c ,Remark__c ,Attachment_ID__c,Parent_Id__c, Place_of_Issue__c  from Document__c where 
                              Parent_Id__c =: parentId order by createdDate desc]; //AND Attachment_ID__c!=null
        }
        system.debug('custdocWithAtt  >>' +custdocWithAtt );
        return custdocWithAtt;
    }
    
    /* @AuraEnabled
    public static List<Document__c> fetchAttachment(Id parentId, Id deleteRecord) {
       system.debug('parentId is '+ parentId); 
        if(deleteRecord != null){
            Document__c c = [select Id from Document__c where Id =:deleteRecord];
            delete c;
        }
        
        String sObjName ='';
        string accountId = '';
        Case cs;
        if(parentId != null){
            sObjName =  parentId.getSObjectType().getDescribe().getName();
            system.debug('sObjName = '+sObjName) ;
            if(sObjName == 'Case'){
                 cs = [select Id, AccountId, RecordType.DeveloperName from Case where Id =: parentId];
                accountId = cs.AccountId;
            }
        }

        if(sObjName == 'Tenant_Registration__c'){
            return getDocumentList(parentId, '').values();
        }else if(sObjName == 'Case'){
            list<Document_SetUp__c> docSetList =  getDocumentType(cs.RecordType.DeveloperName);
            Map<String,Document__c> docMap =getDocumentList(parentId, accountId);
            List<Document__c> docList2 =new List<Document__c>();
            
                    for(Document_SetUp__c docSet :docSetList){  
                     if(docMap.containsKey(docSet.Document_List__r.Name) && (docMap.get(docSet.Document_List__r.Name).Parent_Id__c==parentId ||docSet.Is_fetch_from_Account__c==true)){
                        docList2.add(docMap.get(docSet.Document_List__r.Name));
                    }
                }
            return docList2;
        }
        else{
            return getDocumentList(parentId, '').values();
        }
    }*/
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

//Not needed- Mamta
  /* public static list<Document_SetUp__c> getDocumentType(String recordTypeDeveloperName){
        return [select Id, Name,Phase__c,Document_List__r.Name, Is_Required__c, Document_Type__c,Is_fetch_from_Account__c 
                FROM Document_SetUp__c 
                WHERE recordType.DeveloperName =: ConstantUtility.DOC_SET_UP_RT AND Record_Type_Name__c  =: recordTypeDeveloperName order by Name];
    }*/
        
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
    
    
    /*@AuraEnabled-- commented by mamta
    public static void createDocumentRecords(String recId,Document__c newDoc,String fileId){        
        
        newDoc.Parent_Id__c=recID;
        if(recId.startsWith(ConstantUtility.CASE_RECORD_ID_START)){
            newDoc.Opportunity__c=recId;
        }
        newDoc.Attachment_Id__c=fileId;
        try{
            system.debug('newDoc >>'  +newDoc);
            insert newDoc;
        }catch(exception e){
            system.debug('Error >> '  +e.getMessage());
        }
    }*/
    
    /*@AuraEnabled-- commented by mamta
    public static String checkDuplicateDocument(String recId,String DoctypeName){   
        String msg;
        Case cs = [select id, AccountId from Case where id=: recId];
        List<Document__c> docList = [SELECT id,Parent_Id__c,Account__c,Approval_Status__c ,Remark__c ,Document_Type__c from Document__c where Account__c =: cs.AccountId];
        for(Document__c doc: docList){
            if(doc.Document_Type__c==DoctypeName)
                 msg =ConstantUtility.DOC_DUPLICATION_ERROR;
        }
        return msg;
    }*/
    
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
        /*else if(objectName=='Opportunity')
        {
            Id accountId= [select id,accountId from opportunity where id =:recordId].accountId;
            list<Account> accList=[select RecordType.Developername,NationalityLookup__r.Code__c from account where id=: accountId];
            if(!accList.isEmpty())
            {
                accRecordType=accList[0].RecordType.Developername;
                Nationality=accList[0].NationalityLookup__r.Code__c;
            }
            
        }*/
        
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
                
//
            if((recordTypeList[0]=='Agent_Representative') && country!='AE')
            {
                developerName='NKHL_Agent_International_representative';
                
            }
           /* else if((recordTypeList[0]=='Owner_Partner_Shareholder') && country!='AE')
            {
                developerName='Agent_International_Owner_Partner';
                
            }*/
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
           /* else if((recordTypeList[0]=='Owner_Partner_Shareholder') && country=='AE')
            {
                developerName='Agent_Local_Owner_Partner';        
            }*/
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
    @AuraEnabled
    public static List<NKHL_Documentation_Template__mdt >  getdocumentTypeValues( Id recordId) {
        String developerName=getDocumentTemplates(recordId);
        list<Id> documentMatrixIdList=new list<Id>();
        system.debug('developerName is '+ developerName);
        for(NKHL_Documentation_Matrix__mdt  doc : [SELECT id FROM NKHL_Documentation_Matrix__mdt WHERE developerName =:developerName])
        {
            documentMatrixIdList.add(doc.id);
            
        } 
        
        for(NKHL_Documentation_Template__mdt  doc:[select id ,Document_Label__c,Is_Required_Expiry_Date__c,
                                                   Is_Required_Issue_Date__c,Required__c,
                                                   is_Document_ID_NumberRequired__c 
                                                   from NKHL_Documentation_Template__mdt  
                                                   where NKHL_Documentation_Matrix__c=:documentMatrixIdList[0]])
        {
            
            // documentTypes.add(doc.Document_Label__c);
            MdtDocumentList.add(doc);
        } 
        
        List<Document__c> documentList = new List<Document__c>();
            for(NKHL_Documentation_Template__mdt mdt : MdtDocumentList){
                Document__c doc = new Document__c();
                doc.Agency_Registration__c  = recordId;
                doc.Document_Type__c = mdt.Document_Label__c;
                doc.File_Name__c = mdt.Document_Label__c;   
                doc.Parent_Id__c = recordId;
                documentList.add(doc);
            }
        insert documentList;
        return MdtDocumentList;
    }
    
    @AuraEnabled
    public static Boolean checkDuplicateTradeLicenseNumber(String tradeLicenseNumber){
        Boolean flag = false;
        List<Broker__c> brokerList = [SELECT Id from Broker__c where Trade_Licence_Number__c =:tradeLicenseNumber];
            if(brokerList.size() > 0) flag = true;
        return flag;
    }
    
    public class documentWrapper{
        @AuraEnabled
        public document__c documentRecord { get; set; }
        @AuraEnabled
        public boolean isEdit { get; set; }
        @AuraEnabled
        public boolean isNew { get; set; }
        @AuraEnabled
        public boolean expDateMandatory { get; set; }
        @AuraEnabled
        public boolean issueDateMandatory { get; set; }
        @AuraEnabled
        public boolean DoccumentIDMandatory { get; set; }
        @AuraEnabled
        public boolean documentExpired { get; set; }
        @AuraEnabled
        public String documentApprovalStatus { get; set; }
        @AuraEnabled
        public String documentIdLabel { get; set; }
        @AuraEnabled
        public boolean showPlaceOfIssue { get; set; }
    }
    
     @AuraEnabled
    public static List<documentWrapper>  getDocumentWrapperList( Id recordId) {
        String developerName=getDocumentTemplates(recordId);
        list<Id> documentMatrixIdList=new list<Id>();
        Map<String,NKHL_Documentation_Template__mdt> docTemplateMap=new Map<String,NKHL_Documentation_Template__mdt>();
        system.debug('developerName is '+ developerName);
        List<documentWrapper> docListWrapper = new List<documentWrapper>();
        for(NKHL_Documentation_Matrix__mdt  doc : [SELECT id FROM NKHL_Documentation_Matrix__mdt 
                                                   WHERE developerName =:developerName])
        {
            documentMatrixIdList.add(doc.id);
            
        } 
        system.debug('documentMatrixIdList>>'+documentMatrixIdList);
        for(NKHL_Documentation_Template__mdt  doc:[select id ,Document_Label__c,Is_Required_Expiry_Date__c,Hide_Place_Of_Issue__c,
                                                   Is_Required_Issue_Date__c,Required__c,Document_Id_Label__c,
                                                   is_Document_ID_NumberRequired__c 
                                                   from NKHL_Documentation_Template__mdt  
                                                   where NKHL_Documentation_Matrix__c=:documentMatrixIdList[0]])
        {
            system.debug('inside>>'+doc);
            // documentTypes.add(doc.Document_Label__c);
            MdtDocumentList.add(doc);
            docTemplateMap.put(doc.Document_Label__c,doc);
        } 
        
        
        
        List<Document__c> documentList = new List<Document__c>();
        documentList = fetchAttachments(recordId,null);
        if(documentList.size() > 0){
           for(Document__c temp: documentList){
            documentWrapper docWrap = new documentWrapper();
            docWrap.documentRecord = temp;
               if(temp.Document_Attached__c){
                  docWrap.isNew = false;
                  docWrap.isEdit = false; 
               }else{
                   docWrap.isNew = true;
                   docWrap.isEdit = false;
               }
               system.debug('doc>>'+temp);
               system.debug('doc type>>'+temp.Document_Type__c);
               system.debug('docTemplateMap>>'+docTemplateMap);
               system.debug('docTemplateMap.get(temp.Document_Type__c)>>>>'+docTemplateMap.get(temp.Document_Type__c));
            docWrap.expDateMandatory = docTemplateMap.get(temp.Document_Type__c).Is_Required_Expiry_Date__c;
            docWrap.issueDateMandatory = docTemplateMap.get(temp.Document_Type__c).Is_Required_Issue_Date__c;
            docWrap.DoccumentIDMandatory = docTemplateMap.get(temp.Document_Type__c).is_Document_ID_NumberRequired__c;
            docWrap.documentIdLabel = docTemplateMap.get(temp.Document_Type__c).Document_Id_Label__c;
            docWrap.documentExpired =  temp.Expiry_Date__c < System.today() ? true : false;
            docWrap.documentApprovalStatus = temp.Approval_Status__c != null ? temp.Approval_Status__c : 'Draft';
            docWrap.showPlaceOfIssue = docTemplateMap.get(temp.Document_Type__c).Hide_Place_Of_Issue__c;
            docListWrapper.add(docWrap); 
        }
        }else{
            for(NKHL_Documentation_Template__mdt mdt : MdtDocumentList){
                Document__c doc = new Document__c();
                Id i =Id.valueOf(recordId);
                string objectName=i.getSObjectType().getDescribe().getName();
                if(objectName==ConstantUtility.SOBJ_AgencyRegistration)
                {
                     system.debug('objectName is '+ ConstantUtility.SOBJ_AgencyRegistration);
     
                    doc.Agency_Registration__c=recordId;
                }
            
                else if(objectName==ConstantUtility.SOBJ_Agent)
                {
                    doc.Agent__c =  recordId ;
                }
                doc.Agency_Registration__c  = recordId;
                doc.Document_Type__c = mdt.Document_Label__c;
                doc.File_Name__c = mdt.Document_Label__c;   
                doc.Parent_Id__c = recordId;
                doc.Is_Doc_Required__c= mdt.Required__c;
                documentList.add(doc);
            }
            insert documentList; 
            for(Document__c temp: documentList){
            documentWrapper docWrap = new documentWrapper();
            docWrap.documentRecord = temp;
            docWrap.isNew = true;
            docWrap.isEdit = false;
            docWrap.expDateMandatory = docTemplateMap.get(temp.Document_Type__c).Is_Required_Expiry_Date__c;
            docWrap.issueDateMandatory = docTemplateMap.get(temp.Document_Type__c).Is_Required_Issue_Date__c;
            docWrap.DoccumentIDMandatory = docTemplateMap.get(temp.Document_Type__c).is_Document_ID_NumberRequired__c;
            docWrap.documentIdLabel = docTemplateMap.get(temp.Document_Type__c).Document_Id_Label__c;
            docWrap.documentExpired =  temp.Expiry_Date__c < System.today() ? true : false;
            docWrap.documentApprovalStatus = temp.Approval_Status__c != null ? temp.Approval_Status__c : 'Draft';
            docWrap.showPlaceOfIssue = docTemplateMap.get(temp.Document_Type__c).Hide_Place_Of_Issue__c;
            docListWrapper.add(docWrap);
            }
        }
            
        
        system.debug('***docListWrapper is '+ docListWrapper);
        return docListWrapper;
    }
    
    public static void updateDocumentRecords(String recId,document__c newDoc,String fileId){   
        system.debug('** recId :'+recId+'new Doc: '+newDoc+'fileId :'+fileId);
        list<document__c> documentUpdateList=new list<document__c>();
        list<document__c> documentList=new list<document__c>();
        Id i =Id.valueOf(recId);
        Id parentId ;
        string objectName=i.getSObjectType().getDescribe().getName();
        
        
        documentList=[select id,parent_id__c,Is_Doc_Required__c ,Attachment_Id__c,Document_Attached__c ,Approval_Status__c ,Remark__c ,
                      Issue_Date__c,Expiry_Date__c,Document_ID_Number__c
                      from document__c where parent_id__c =: recId and 
                      File_Name__c =:newDoc.Document_Type__c LIMIT 1 ];
        
        system.debug(documentList);
        if(documentList.isEmpty())
        {
            //Document__c newDoc = new Document__c();
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
            
            
            try{  
                system.debug('newDoc >>'  +newDoc);
                system.debug('New Document is inserted');
                insert newDoc;
                createContentDocumentLinks(newDoc);
                if(parentId!=null && newDoc.Document_ID_Number__c!= null){//&& (newDoc.Emirates_ID__c!=null || newDoc.Passport_Number__c!=null)
                    Account accObj = new Account();
                    if(newDoc.Document_Type__c==ConstantUtility.EMIRATES_ID){
                        //accObj.Emirates_Id__c =newDoc.Document_ID_Number__c;  commented by hitarth
                    }
                    if(newDoc.Document_Type__c==ConstantUtility.VALID_PASSPORT){
                        //accObj.Passport_No__c = newDoc.Document_ID_Number__c;commented by hitarth
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
                    doc.Attachment_Id__c=fileId;
                    doc.Document_Type__c=newdoc.Document_Type__c;
                    doc.Document_Attached__c=true;
                    doc.Expiry_Date__c=newDoc.Expiry_Date__c;
                    doc.Issue_Date__c=newDoc.Issue_Date__c;
                    doc.Remark__c=newDoc.Remark__c;
                    doc.Place_of_Issue__c = newDoc.Place_of_Issue__c;
                    doc.Document_ID_Number__c = (newDoc.Document_ID_Number__c!=null)?newDoc.Document_ID_Number__c:doc.Document_ID_Number__c;
                    //doc.Passport_Number__c =(newDoc.Passport_Number__c!=null)?newDoc.Passport_Number__c:doc.Passport_Number__c;// newDoc.Passport_Number__c;
                    system.debug('***doc:'+doc);
                    createContentDocumentLinks(doc);
                    documentUpdateList.add(doc);
                
            }
            system.debug(documentUpdateList);
            update documentUpdateList;
              
       }
        
    }
    
   
   
}