public without sharing class DocumentTriggerHandler {
    List<Document__c> recordNewList = new List<Document__c>();
    List<Document__c> recordOldList = new List<Document__c>();
    Map<Id, Document__c> recordNewMap = new Map<Id, Document__c>();
    Map<Id, Document__c> recordOldMap = new Map<Id, Document__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    public DocumentTriggerHandler(List<Document__c> newList, List<Document__c> oldList, 
                                  Map<Id, Document__c> newMap, Map<Id, Document__c> oldMap, 
                                  boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
        callSharepointIntegrationHelper(this.recordNewMap);
    }
    public void AfterUpdateEvent() {
        syncDocumentDetailsToAccounts(recordNewList, recordOldMap);
        callSharepointIntegrationHelper(this.recordNewMap);
        insertContentVersionRecords(recordNewList, recordOldMap);
        triggerSMSSendToCustomer(recordNewList, recordOldMap);
        generatePublicLinkForPaymentReceiptDocument(recordNewList, recordOldMap);
        //Added by Monneeb for Isupplier callout fix on 07/feb/2022
        sendtoisupplier(recordNewList, recordOldMap);
         /*Start- Added By Mamta- 25 jan 2022*/
         Set<ID> oppIDS = new Set<ID>();
         for(Document__c doc : recordNewList){
             system.debug('doc.Is_Document_Uploaded__c  is '+ doc.Is_Document_Uploaded__c);
             system.debug('recordOldMap.get(doc.ID).Is_Document_Uploaded__c  is '+ recordOldMap.get(doc.ID).Is_Document_Uploaded__c);    
    
             if(doc.Object__c =='Opportunity' && doc.Is_Document_Uploaded__c && !recordOldMap.get(doc.ID).Is_Document_Uploaded__c && doc.Opportunity__c!=null){
                oppIDS.add(doc.Opportunity__c); 
             }
        }
        system.debug('doc.Object__c is '+ recordNewList[0].Object__c);
        system.debug('oppIDS is '+ oppIDS);
        
        if(!oppIDS.IsEmpty()){
           verifyDocumentsForOpportunities(oppIDS); 
        }
        //SendEmailToPartnerSupportExecutiveOnDocumentUpload(recordNewList, recordOldMap);
    }
    //Added by Monneeb for Isupplier callout fix on 07/feb/2022
    public static void sendtoisupplier(List<Document__c> recordNewList, Map<ID,Document__c> recordOldMap){
        Set<ID> accIDS = new Set<ID>();
        Set<ID> docIDS = new Set<ID>();
        for(Document__c doc : recordNewList){
            if(doc.Account__c != null && doc.Is_Isupplier_Callout__c && recordOldMap.get(doc.Id).Is_Isupplier_Callout__c != doc.Is_Isupplier_Callout__c){
                accIDS.add(doc.Account__c); 
                docIDS.add(doc.ID);
            }
        }
        system.debug('accIDS**' + accIDS.size());
        system.debug('docIDS**' + docIDS.size());
        if(accIDS.size() > 0 && docIDS.size() > 0){
            ISupplierRestAPICall.SendDocumentToiSupplier(accIDS,docIDS); 
        }
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }
    
        
     /**********************************************************************************************
    * Author        : Mamta Gupta
    * @Description  : check if all document types uploaded for particular opportunity
    * @Params       : List<Document__c> recordNewList => Trigger.new
    * @Params       : Map<Id, Document__c> recordOldMap => Trigger.oldMap
    * @Return       : void
    **********************************************************************************************/
    public  void verifyDocumentsForOpportunities(Set<ID> oppIDS){
        
     Map<ID, Set<String> > oppID_DocTypes_Map = new  Map<ID, Set<String> >();
     List<String> docsToVerifyLst =    (system.label.Document_Verification_Opp).split(',') ;
     Set<String> documentsVerify_Set = new Set<String>();
     for(String s :docsToVerifyLst ){
         documentsVerify_Set.add(s.trim());
     }
         
       
     system.debug('documentsVerify_Set is '+ documentsVerify_Set);   
     List<Document__c>  documents =[select id,Opportunity__c,Document_Type__c from Document__c WHERE Opportunity__c IN:oppIDS AND Is_Document_Uploaded__c=true] ;
     for(Document__c doc : documents){
         if(oppID_DocTypes_Map.containskey(doc.Opportunity__c)){
             Set<String> docTypesUploaded_Set  = oppID_DocTypes_Map.get(doc.Opportunity__c);
             docTypesUploaded_Set.add(doc.Document_Type__c);
             oppID_DocTypes_Map.put(doc.Opportunity__c  , docTypesUploaded_Set);
             
         }
         else{
             Set<String> docTypesUploaded_Set= new Set<String>();
             docTypesUploaded_Set.add(doc.Document_Type__c);
             oppID_DocTypes_Map.put(doc.Opportunity__c  , docTypesUploaded_Set);
             
         }
            
        } 
        
        system.debug('oppID_DocTypes_Map is '+ oppID_DocTypes_Map);
        List<Opportunity> oppsLst =[select id, Documents_Verified__c  from Opportunity WHERE ID IN :oppID_DocTypes_Map.keySet() ];
        
        for(Opportunity opp : oppsLst){
            if(oppID_DocTypes_Map.containsKey(opp.ID)){
                Set<String> docsToverify = oppID_DocTypes_Map.get(opp.ID);
                
                if(docsToverify.containsAll(documentsVerify_Set)){
                    opp.Documents_Verified__c = true;//Make it true if set contains all doc types needed to be uploaded
                }
            }
        }
        
        if(!oppsLst.isEmpty()){
            try{
                update oppsLst;
            }
            catch(Exception ex){
                system.debug('error is '+ ex.getMessage() + ' at line number ' + ex.getLineNumber()); 
            }
            
        }
        
    }

    /**********************************************************************************************
    * @Description  : Method to content version records for document
    * @Params       : List<Document__c> recordNewList => Trigger.new
    * @Params       : Map<Id, Document__c> recordOldMap => Trigger.oldMap
    * @Return       : void
    **********************************************************************************************/
    public static void insertContentVersionRecords(List<Document__c> recordNewList, Map<Id, Document__c> recordOldMap){
        
        Set< Id > setAttachmentIds                            = new Set< Id >();
        List< Document__c > docList                           = new List< Document__c >();
        Set< String > setDocumentTypes                        = new Set< String >();
        List< Account > lstAccountToUpdate                    = new List< Account >();
        List< Document__c > lstDocumentToUpdate               = new List< Document__c >();
        List<ContentVersion> lstCntVersionsToInsert           = new List<ContentVersion>();
        Map< String, String > mapConDocIdToConVerId           = new Map< String, String >();
        Map< String, String > mapConVerIdToConDocId           = new Map< String, String >();
        Map< Id, Attachment > mapConVerIdToAttachment         = new Map< Id, Attachment >();
        Map< Id, Attachment > mapAttachmentIdToAttachment     = new Map< Id, Attachment >();
        List< ContentDocumentLink > lstContentDocToInsert     = new List< ContentDocumentLink >();
        Map< Id, List< Document__c >> mapAccountIdToDocList   = new Map< Id, List< Document__c >>();
        Map< Id, ContentVersion > mapAttachmentIdToConVersion = new Map< Id, ContentVersion >();
        
        
        Savepoint sp = Database.setSavepoint();
        try{
            // Get the document types
            for( Broker_Documents__mdt metadataConfig : [ SELECT Id, MasterLabel FROM Broker_Documents__mdt ]){
                setDocumentTypes.add( metadataConfig.MasterLabel );
            }
            
            // Iterate through document to get the data to process
            for( Document__c doc : recordNewList ){
                if( doc.Attachment_Id__c !=  recordOldMap.get(doc.Id).Attachment_Id__c && doc.Attachment_Id__c != null &&  setDocumentTypes.contains( doc.Document_Type__c ) ){
                    docList.add( doc );
                    setAttachmentIds.add( doc.Attachment_Id__c );
                }
            }
            if( !setAttachmentIds.isEmpty() ){
                // Get the attachments to convert into files
                for( Attachment attach : [ SELECT Id, ParentId, Name, IsPrivate, Body, OwnerId, CreatedById, CreatedDate, Description 
                                            FROM Attachment 
                                            WHERE Id IN : setAttachmentIds] ){
                    mapAttachmentIdToAttachment.put( attach.Id, attach );
                }
                
                // Create Content versions
                for(Attachment attach : mapAttachmentIdToAttachment.values()) {
                    ContentVersion cVersion = new ContentVersion();
                    cVersion.ContentLocation = 'S'; 
                    cVersion.PathOnClient = attach.Name;
                    cVersion.Origin = 'H';
                    cVersion.SharingPrivacy = 'N';
                    //cVersion.OwnerId = attach.OwnerId;
                    cVersion.Title = attach.Name;
                    cVersion.VersionData = attach.Body;

                    mapAttachmentIdToConVersion.put( attach.Id, cVersion );
                }

                // Insert Content Version
                if(!mapAttachmentIdToConVersion.values().isEmpty()) {
                    insert mapAttachmentIdToConVersion.values();
                }

                

                // Create a map for Content Version Id to attachment 
                for( Id attachId : mapAttachmentIdToConVersion.keySet() ){
                    ContentVersion conVer = mapAttachmentIdToConVersion.get( attachId );
                    mapConVerIdToAttachment.put( conVer.Id, mapAttachmentIdToAttachment.get(attachId) );
                }

                //After saved the Content Verison, get the ContentDocumentId
                for( ContentVersion conVer :  [ SELECT Id, ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE Id IN :mapConVerIdToAttachment.keySet() ] ){
                    mapConDocIdToConVerId.put( conVer.ContentDocumentId, conVer.Id );
                    mapConVerIdToConDocId.put( conVer.Id, conVer.ContentDocumentId );
                }
                
                // Update Broker_Agreement_Id__c on Document object
                for( Document__c doc : docList ){
                    if( mapAttachmentIdToConVersion.containsKey( doc.Attachment_Id__c ) ){
                        Document__c docObj = new Document__c();
                        docObj.Id = doc.Id;
                        docObj.Broker_Agreement_Id__c = mapConVerIdToConDocId.get(mapAttachmentIdToConVersion.get( doc.Attachment_Id__c ).Id);
                        lstDocumentToUpdate.add( docObj );
                    }
                }

                // Update document with content version Id
                if( !lstDocumentToUpdate.isEmpty() ){
                    update lstDocumentToUpdate;
                } 

                //Create ContentDocumentLink
                for( String conDocId : mapConDocIdToConVerId.keySet() ){
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    // get the parent Id
                    Attachment attach = mapConVerIdToAttachment.get( mapConDocIdToConVerId.get(conDocId));
                    cDocLink.ContentDocumentId = conDocId;
                    cDocLink.LinkedEntityId = attach != null ? attach.ParentId : null;
                    cDocLink.ShareType = 'I';
                    cDocLink.Visibility = 'AllUsers';
                    lstContentDocToInsert.add( cDocLink );
                }
                
                //Insert ContentDocumentLink
                if( !lstContentDocToInsert.isEmpty() ){
                    insert lstContentDocToInsert;
                }

                for( Document__c doc : docList ){
                    if( !mapAccountIdToDocList.containsKey( doc.Account__c ) ){
                        mapAccountIdToDocList.put( doc.Account__c, new List< Document__c >() );
                    }
                    mapAccountIdToDocList.get( doc.Account__c ).add( doc );
                }

                // Update the documenet count on account
                for( Account acc : [ SELECT Id, Name, Document_Count__c FROM Account WHERE Id IN :mapAccountIdToDocList.keySet() ]  ){
                    Decimal docCount = acc.Document_Count__c != null ? acc.Document_Count__c : 0; 
                    docCount += mapAccountIdToDocList.get( acc.Id ).size();
                    acc.Document_Count__c = docCount;
                    lstAccountToUpdate.add( acc );
                }

                // update the account
                if( !lstAccountToUpdate.isEmpty() ){
                    update lstAccountToUpdate;
                }
            }
            
        }catch( Exception ex ){
            system.debug( ' Exception => '+ex.getMessage() + '--'+ex.getStackTraceString() );
            Database.rollback( sp );
        }
    }

    /**********************************************************************************************
    * @Description  : Method to send email to partner support queue for new revised upload
    * @Params       : List<Document__c> recordNewList => Trigger.new
    * @Params       : Map<Id, Document__c> recordOldMap => Trigger.oldMap
    * @Return       : void
    **********************************************************************************************/
   /* public static void SendEmailToPartnerSupportExecutiveOnDocumentUpload(List<Document__c> recordNewList, Map<Id, Document__c> recordOldMap){
  		List<Document__c> docList = new List<Document__c>();
        List<Document__c> uncheckDocList = new List<Document__c>();
        List<Document__c> checkDocList = new List<Document__c>();
        User usr = [select id, profile.name from user where id=:UserInfo.getUserId() LIMIt 1 ] ;
        system.debug('***User Profile  '+usr.profile.name);
        if(usr.Profile.name==ConstantUtility.PARNTERPROFILE_Agent||
           usr.Profile.name==ConstantUtility.PARNTERPROFILE_Admin || 
            usr.Profile.name == ConstantUtility.GUESTUSERPROFILE || usr.Profile.name == 'System Administrator '){   
                for(Document__c doc : recordNewList){
                    if(doc.Attachment_Id__c != null && doc.Attachment_Id__c != recordOldMap.get(doc.Id).Attachment_Id__c){
                        	sendEmail(doc);
                    } 
                }
        }   
    }
    
    public static List<String> getEmailAddresses() {
        List<String> mailToAddresses = new List<String>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        Set<Id> result=new Set<Id>();
        Set<Id> groupIdProxys = new Set<Id>();
        
        List<GroupMember> groupMembers = [SELECT UserOrGroupId
                              			FROM GroupMember
                              			WHERE Group.Name = :'Partner Support Executive' 
                                        AND (Group.Type = 'Regular' 
                                        OR Group.Type='Role' OR Group.Type='RoleAndSubordinates')];
        
        for(GroupMember gm : groupMembers){
            // If the user or group id is a user
            if(((String)gm.UserOrGroupId).startsWith(userType))
            {
                result.add(gm.UserOrGroupId);
            }else if (((String)gm.UserOrGroupId).startsWith(groupType))
            {
                // Call this function again but pass in the group found within this group
                groupIdProxys.add(gm.userOrGroupId);
                
            }
            
            if(groupIdProxys.size() > 0)
        	{    
                Set<id> groupId = new set<id>();
                Set<id> roleId = new set<id>();
                Set<id> roleAndSubId = new set<Id>();
                
                for(Group g2 : [Select Id, Type, relatedId From Group Where Id = :groupIdProxys]){
                    if(g2.Type == 'Role'){
                        roleId.add(g2.relatedId);    
                    }
                    else if(g2.Type== 'RoleAndSubordinates'){
                        roleAndSubId.add(g2.relatedId);    
                    }
                    else if(g2.Type== 'Regular'){
                        groupId.add(g2.id);    
                    }
                    system.debug(g2);
                }
                if(roleAndSubId.size()>0){
                    roleId.addAll(getAllSubRoleIds(roleAndSubId));
                }
                if(roleId.size()>0){
                    for(User u: [select id from user where UserRoleId IN: roleId]){
                        result.add(u.id);
                    }
                }
                if(groupId.size()>0){
                    for(GroupMember groupMember : [select id, UserOrGroupId from GroupMember where GroupId IN: groupId]){
                        result.add(groupMember.UserOrGroupId);        
                    }
                }
            }
        }

        List<User> users = [SELECT Email FROM User WHERE Id =: result];
    
        for(User u : users)
            mailToAddresses.add(u.email);
    
        return mailToAddresses;
	}
    
    public static void sendEmail(Document__c doc){
        Contact con=[SELECT id FROM Contact LIMIT 1 ];
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(con.id); 
        message.setSenderDisplayName('Nakheel Brokers');
        //message.setReplyTo('no-reply@nakheel.com');
        message.ccaddresses = new List<string>{'karisma.kotian@gmail.com'};
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        EmailTemplate emailTemplate = EmailNotificationHelper.getEmailTemplateByName(new set<string>{'VF_Document_Version_Upload'})[0];
        message.setTemplateID(emailTemplate.Id); 
        //message.setHtmlBody(emailTemplate.HtmlValue);
        message.setWhatId(doc.Id); //This is important for the merge fields in template to work
        message.toAddresses = getEmailAddresses();//new String[] { contact.email};
        messageList.add(message);
        //Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
      //Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        // create savepoint before executing statement
           Savepoint sp = Database.setSavepoint();
                
                // send the temporary email list
                Messaging.sendEmail(messageList);
                
                // rollback the transaction before commiting to database
                Database.rollback(sp);            
                // initialize the actual message list to be sent
                List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
        // loop through the previous message list and set the email fields
                for (Messaging.SingleEmailMessage email : messageList) {
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                    emailToSend.setToAddresses(email.getToAddresses());
                    emailToSend.setHTMLBody(email.getHTMLBody());
                    emailToSend.setSubject(email.getSubject());
                    emailToSend.setSaveAsActivity(true);
                    actualMessageList.add(emailToSend);
                }
                
                // send the actual message list
                Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);
        
        		// make sure the emails are sent successfully
                String errorMessage = '';
                for(Messaging.SendEmailResult ser : serList){
                    if(ser.isSuccess()){
                        system.debug('Email sent successfully!');
                    }
                    else if(!ser.isSuccess()){
                        for(Messaging.SendEmailError err : ser.getErrors()) {
                            errorMessage += err.getMessage() + '\n';
                        }
                    }
                }
        		system.debug('errorMessage :'+errorMessage);
                         
     }
    
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
    
        Set<ID> currentRoleIds = new Set<ID>();
    
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null limit 40000])
            currentRoleIds.add(userRole.Id);
    
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0)
          currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
    
        return currentRoleIds;
    
    }*/
    
    
    /**********************************************************************************************
    * Author        : Lakshaya Sharma
    * @Description  : check if upload to sharepoint is checked
    * @Params       : List<Document__c> recordNewMap => Trigger.newMap
    * @Return       : void
    **********************************************************************************************/
    
    public static void callSharepointIntegrationHelper(Map<ID,Document__c> docMap){
        List<Document__c> documentRecordsList = new List<Document__c>();
        Set<ID> keys =  docMap.keySet();
        List<Document__c> documentList = [SELECT Id, Name, Account__c, Agent_Email__c, Approval_Status__c, Attachment_Id__c, Contact__c, Document_Attached__c, Document_Expired__c, Document_ID_Number__c, Document_Type__c, Expiry_Date__c, File_Name__c, Upload_To_Sharepoint__c, Sharepoint_Url__c, Issue_Date__c, Error_Message__c, Is_Isupplier_Callout__c, Opportunity__c, ParentAPIName__c, Parent_Id__c, Place_of_Issue__c, Rejection_Reason__c, Remark__c, Required__c, View_File__c, Agency_Registration__c, Agent__c, Broker_Agreement_Id__c, Broker_Proprietor__c, Agency_Name__c, Broker_Name__c, Country__c, Isupplier_Callout_Status__c, Version_Uploaded__c, Is_Doc_Required__c, Broker_Proprietor_Agency_Name__c, Project__c, Cluster__c, Building__c, Master_Development__c, Unit__c, SPA_Agreement__c, Email_Alert_Date__c, Checkbox_Field_API_Name__c, Expiry_Date_Mandatory__c, Expiry_of_Set_Days__c, Is_Document_Uploaded__c, Issue_Date_Mandatory__c, Object_Status_Field_API_Name__c, Object_Status_Field_Value__c, Object__c, Primary_Email__c, Document_Name__c, Is_Account_Linked__c, Leads__c, Rejected_Date__c, Special_Offer__c, Contract__c, Floor__c FROM Document__c where id in :keys AND Upload_To_Sharepoint__c=true ];
        if(documentList.size()>0 && documentList != null){
            System.debug('Inside if block');
            String serializeDocumentList = JSON.serialize(documentList);
            SharePointIntegrationHelper.createFolderAndUploadFile(serializeDocumentList);
        }
        
        if(documentList.size()>0 && documentList != null){
        for(Document__c documentRecord : documentList){
            documentRecord.Upload_To_Sharepoint__c = false;
            documentRecordsList.add(documentRecord);
        }
        }
        
        if(documentRecordsList.size() > 0 && documentRecordsList != null){
            update documentRecordsList;
        }
    }

    /**********************************************************************************************
    * Author        : Karishma Kotian
    * @Description  : Update Passport,Visa and Emirate ID details to Individual Customer
    * @Params       : List<Document__c> newRecordList, Map<ID,Document__c> oldDocMap
    * @Return       : void
    **********************************************************************************************/
    public static void syncDocumentDetailsToAccounts(List<Document__c> newRecordList, Map<ID,Document__c> oldDocMap){
        set<Id> accountIds = new set<Id>();
        Map<Id,Account> accountUpdateMap = new Map<Id,Account>();
        Map<Id,Opportunity> opportunityUpdateMap = new Map<Id,Opportunity>();
        Map<Id,Account> accountDetailMap = new Map<Id,Account>();
        for(Document__c doc : newRecordList){
            if(doc.Account__c != null)accountIds.add(doc.Account__c);
        }
        accountDetailMap = new Map<Id,Account>([SELECT Id, Emirates_Ids__c,Visa_End_Date__c,Visa_Start_Date__c,
        Visa_Number__c, Passport_Expiry_Date__c, Passport_Issue_Date__c, Passport_Number__c, Trade_License_End_Date__c, 
        Trade_License_Expiry_Date__c,Trade_License_Start_Date__c, Trade_License_Number__c FROM Account WHERE Id =: accountIds]);
        for(Document__c doc : newRecordList){
            if(doc.Account__c != null){
                if(accountUpdateMap.containsKey(doc.Account__c)){
                    Account acc = accountUpdateMap.get(doc.Account__c);
                    if(doc.Document_Type__c == 'Emirates ID'){
                        acc.Emirates_Ids__c = doc.Document_ID_Number__c != null ? doc.Document_ID_Number__c : accountDetailMap.get(doc.Account__c).Emirates_Ids__c;
                    }else if(doc.Document_Type__c == 'VISA'){
                        acc.Visa_End_Date__c = doc.Expiry_Date__c != null ? doc.Expiry_Date__c : accountDetailMap.get(doc.Account__c).Visa_End_Date__c;
                        acc.Visa_Start_Date__c =  doc.Issue_Date__c != null ? doc.Issue_Date__c : accountDetailMap.get(doc.Account__c).Visa_Start_Date__c;
                        acc.Visa_Number__c = doc.Document_ID_Number__c != null ? doc.Document_ID_Number__c : accountDetailMap.get(doc.Account__c).Visa_Number__c;
                    }else if(doc.Document_Type__c == 'PASSPORT'){
                        acc.Passport_Expiry_Date__c = doc.Expiry_Date__c != null ? doc.Expiry_Date__c : accountDetailMap.get(doc.Account__c).Passport_Expiry_Date__c;
                        acc.Passport_Issue_Date__c =  doc.Issue_Date__c != null ? doc.Issue_Date__c : accountDetailMap.get(doc.Account__c).Passport_Issue_Date__c;
                        acc.Passport_Number__c = doc.Document_ID_Number__c != null ? doc.Document_ID_Number__c : accountDetailMap.get(doc.Account__c).Passport_Number__c;
                    }else if(doc.Document_Type__c == 'Trade License'){
                        acc.Trade_License_End_Date__c = doc.Expiry_Date__c != null ? doc.Expiry_Date__c : accountDetailMap.get(doc.Account__c).Trade_License_End_Date__c;
                        acc.Trade_License_Expiry_Date__c =  acc.Trade_License_End_Date__c != null ? String.valueOf(acc.Trade_License_End_Date__c): accountDetailMap.get(doc.Account__c).Trade_License_Expiry_Date__c;
                        acc.Trade_License_Start_Date__c =  doc.Issue_Date__c != null ? doc.Issue_Date__c : accountDetailMap.get(doc.Account__c).Trade_License_Start_Date__c;
                        acc.Trade_License_Number__c = doc.Document_ID_Number__c != null ? doc.Document_ID_Number__c : accountDetailMap.get(doc.Account__c).Trade_License_Number__c;
                    }
                    accountUpdateMap.put(acc.ID,acc);
                }else{
                    Account acc =  new Account(Id = doc.Account__c );
                    if(doc.Document_Type__c == 'Emirates ID'){
                        acc.Emirates_Ids__c = doc.Document_ID_Number__c != null ? doc.Document_ID_Number__c : accountDetailMap.get(doc.Account__c).Emirates_Ids__c;
                        acc.Emirates_ID_Uploaded__c = doc.Is_Document_Uploaded__c;
                    }else if(doc.Document_Type__c == 'VISA'){
                        acc.Visa_End_Date__c = doc.Expiry_Date__c != null ? doc.Expiry_Date__c : accountDetailMap.get(doc.Account__c).Visa_End_Date__c;
                        acc.Visa_Start_Date__c =  doc.Issue_Date__c != null ? doc.Issue_Date__c : accountDetailMap.get(doc.Account__c).Visa_Start_Date__c;
                        acc.Visa_Number__c = doc.Document_ID_Number__c != null ? doc.Document_ID_Number__c : accountDetailMap.get(doc.Account__c).Visa_Number__c;
                        acc.Visa_Uploaded__c = doc.Is_Document_Uploaded__c;
                    }else if(doc.Document_Type__c == 'PASSPORT'){
                        acc.Passport_Expiry_Date__c = doc.Expiry_Date__c != null ? doc.Expiry_Date__c : accountDetailMap.get(doc.Account__c).Passport_Expiry_Date__c;
                        acc.Passport_Issue_Date__c =  doc.Issue_Date__c != null ? doc.Issue_Date__c : accountDetailMap.get(doc.Account__c).Passport_Issue_Date__c;
                        acc.Passport_Number__c = doc.Document_ID_Number__c != null ? doc.Document_ID_Number__c : accountDetailMap.get(doc.Account__c).Passport_Number__c;
                        acc.Passport_Uploaded__c = doc.Is_Document_Uploaded__c;
                    }else if(doc.Document_Type__c == 'Trade License'){
                        acc.Trade_License_End_Date__c = doc.Expiry_Date__c != null ? doc.Expiry_Date__c : accountDetailMap.get(doc.Account__c).Trade_License_End_Date__c;
                        acc.Trade_License_Expiry_Date__c =  acc.Trade_License_End_Date__c != null ? String.valueOf(acc.Trade_License_End_Date__c): accountDetailMap.get(doc.Account__c).Trade_License_Expiry_Date__c;
                        acc.Trade_License_Start_Date__c =  doc.Issue_Date__c != null ? doc.Issue_Date__c : accountDetailMap.get(doc.Account__c).Trade_License_Start_Date__c;
                        acc.Trade_License_Number__c = doc.Document_ID_Number__c != null ? doc.Document_ID_Number__c : accountDetailMap.get(doc.Account__c).Trade_License_Number__c;
                        acc.Trade_License_Uploaded__c = doc.Is_Document_Uploaded__c;
                    }
                    accountUpdateMap.put(acc.ID,acc);
                }
            }
            /*if(doc.Opportunity__c != null && doc.Is_Document_Uploaded__c){
                if(opportunityUpdateMap.containsKey(doc.Opportunity__c)){
                    Opportunity opp = opportunityUpdateMap.get(doc.Opportunity__c);
                    if(doc.Document_Type__c == 'Emirates ID') opp.Emirates_Id_Uploaded__c = true;
                    if(doc.Document_Type__c == 'VISA') opp.Visa_Uploaded__c = true;
                    if(doc.Document_Type__c == 'PASSPORT') opp.Passport_Uploaded__c = true;
                    if(doc.Document_Type__c == 'Trade License') opp.Trading_License_Uploaded__c = true;
                    opportunityUpdateMap.put(opp.Id, opp);
                }else{
                    Opportunity opp = new Opportunity(Id = doc.Opportunity__c);
                    if(doc.Document_Type__c == 'Emirates ID') opp.Emirates_Id_Uploaded__c = true;
                    if(doc.Document_Type__c == 'VISA') opp.Visa_Uploaded__c = true;
                    if(doc.Document_Type__c == 'PASSPORT') opp.Passport_Uploaded__c = true;
                    if(doc.Document_Type__c == 'Trade License') opp.Trading_License_Uploaded__c = true;
                    opportunityUpdateMap.put(opp.Id, opp);
                }
                
            }*/
        }

        if(accountUpdateMap.values() != null){
            update accountUpdateMap.values();
        }

        /*if(opportunityUpdateMap.values() != null){
            update opportunityUpdateMap.values();
        }*/
    }
    
    //Addd by Karishma 09-05-2022 to trigger sms from the checkbox field
    public static void triggerSMSSendToCustomer(List<Document__c> newRecordList, Map<ID,Document__c> oldDocMap){
        List<Document__c> documentList =  new List<Document__c>();
        for(Document__c document : newRecordList){
            if(document.Is_Document_Uploaded__c && document.Attachment_Id__c != oldDocMap.get(document.Id).Attachment_Id__c && document.Document_Type__c == label.Print_Receipt){
                Document__c doc = new Document__c();
                doc.Id = document.Id;
                doc.Send_SMS_to_Customer__c = true;
                documentList.add(doc);
            }
        }
        if(!documentList.isEmpty()){
            update documentList;
        }
    }
    
    /*Method: Send SMS to Customer with the link for reciept download 
      Author: Karishma Kotian
      Date: 05-05-2022
    */
    public static void generatePublicLinkForPaymentReceiptDocument(List<Document__c> newRecordList, Map<ID,Document__c> oldDocMap){
        set<Id> documentIds = new set<Id>(); 
        set<Id> contentDocumentIds = new set<Id>();
        Map<Id,Document__c> documentMapToContent = new Map<Id,Document__c>();
        List<ContentDistribution> contentDistributionList =  new List<ContentDistribution>();
        Map<Id,Id> contentDocumentMapToContentVersion = new Map<Id,Id>();
        List<Document__c> documentList = new List<Document__c>();
        set<Id> docIDsToSendSMS = new set<Id>(); 
        for(Document__c document : newRecordList){
            if(document.Send_SMS_to_Customer__c && document.Send_SMS_to_Customer__c != oldDocMap.get(document.Id).Send_SMS_to_Customer__c){
                documentIds.add(document.Id);
                contentDocumentIds.add(document.Attachment_Id__c);
                documentMapToContent.put(document.Attachment_Id__c,document);
            }
        }

        List<ContentVersion> contentVersions = [Select Id, title, ContentDocumentId from ContentVersion where ContentDocumentId =: contentDocumentIds];

        for(ContentVersion cv : contentVersions){
            ContentDistribution cdl = new ContentDistribution();
            cdl.ContentVersionId = cv.Id;
            cdl.Name = 'Print_Receipt_'+cv.title;
            contentDistributionList.add(cdl);

            contentDocumentMapToContentVersion.put(cv.Id,cv.ContentDocumentId);
        }

        if(!contentDistributionList.isEmpty()){
            insert contentDistributionList;
        
            List<ContentDistribution> contentDistributionL = [SELECT Id,  Name, ContentVersionId, ContentDocumentId, 
                                            DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution 
                                            WHERE ContentVersionId =: contentDocumentMapToContentVersion.keySet()];
            
            for(ContentDistribution cdl : contentDistributionL){
                if(documentMapToContent.containsKey(cdl.ContentDocumentId)){
                    Document__c doc = new Document__c();
                    doc.Id = documentMapToContent.get(cdl.ContentDocumentId).Id;
                    doc.Content_Download_URL__c = cdl.ContentDownloadUrl;
                    doc.Distribution_Public_URL__c = cdl.DistributionPublicUrl;
                    doc.Send_SMS_to_Customer__c = false;
                    documentList.add(doc);
                }
            }
        }
        system.debug('@@@documentList :'+documentList);
        if(!documentList.isEmpty()){
            update documentList;
            for(Document__c doc : documentList){
                docIDsToSendSMS.add(doc.Id);
            }
            sendSMSToCustomerOnPrintReceipt(docIDsToSendSMS);
        }
    }

    public static void sendSMSToCustomerOnPrintReceipt(Set<Id> documentIds){
        List<Document__c> documentList = [SELECT Id, Object__c, Opportunity__c,Opportunity__r.Account.Primary_Country_Code__c,
                                            Opportunity__r.Account.Primary_Mobile__c, Distribution_Public_URL__c,Opportunity__r.Account.Name 
                                            FROM Document__c WHERE Id=: documentIds];
        for(Document__c doc : documentList){
            Unit_HandlerSMS.SMSWrapper wrapper = new Unit_HandlerSMS.SMSWrapper();
            wrapper.publicDistributionURL = doc.Distribution_Public_URL__c;
            wrapper.objId = doc.Opportunity__c;
            wrapper.SendSMSfor = 'Payment Receipt';
            wrapper.phoneNumberWithCountryCode = doc.Opportunity__r.Account.Primary_Mobile__c.startsWith('0') ? doc.Opportunity__r.Account.Primary_Country_Code__c+doc.Opportunity__r.Account.Primary_Mobile__c.substring(1) : doc.Opportunity__r.Account.Primary_Country_Code__c+doc.Opportunity__r.Account.Primary_Mobile__c;
            wrapper.objectName = doc.Object__c;
            wrapper.customerName = doc.Opportunity__r.Account.Name;
            Unit_HandlerSMS.callSmsApiGeneric(wrapper);
        }
    }
}