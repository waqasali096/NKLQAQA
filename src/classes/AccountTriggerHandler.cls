/**
* @author Mamta Gupta
* @date 2 Sep 2021
* @purpose - Initial Development
* @usage -Trigger handler for AccountTrigger
*/

public class AccountTriggerHandler {
    //List<Account> recordNewList = new List<Account>();
    //    List<Account> recordNewList = new List<Account>();
    List<Account> recordNewList = new List<Account>();
    List<Account> recordOldList = new List<Account>();
    Map<Id, Account> recordNewMap = new Map<Id, Account>();
    Map<Id, Account> recordOldMap = new Map<Id, Account>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    public AccountTriggerHandler(List<Account> newList, List<Account> oldList, Map<Id, Account> newMap, Map<Id, Account> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
        for(Account acc : recordNewList){
            acc.Send_Customer_to_ERP__c = true;
        }
        updateAccount(this.recordNewList, this.recordOldMap);
    }
    /** 
        * @createdDate : 23 Dec 2021  
        * @author : Muhammad Moneeb
        * @Version : V1.1
        * @usage : This function invokes Before Update of Account. 
    **/
    public void BeforeUpdateEvent(List<Account> newOppList,Map<Id, Account> recordOldMap,Map<Id, Account> recordNewMap) {
         
        GenericTriggerHandler.validateDocRecord(newOppList,recordOldMap,recordNewMap,'Account');
        customerCreation();
        updateAccount(newOppList, recordOldMap);
        createOrUpdateContact(recordNewList, recordOldMap, 'Before Update'); // Added by Sajid
        
        /***** 
         * Authot: Sajid
         * Description: When business account is create from lead document should be populate from lead.
         *****/
        
        deleteCreatedDoc();
    }
    public void BeforeDeleteEvent() {
    }
    /** 
        * @createdDate : 23 Dec 2021  
        * @author : Muhammad Moneeb
        * @Version : V1.1
        * @usage : This function invokes After Insert of Account. 
    **/
    public void AfterInsertEvent(List<Account> newAccList) {
        GenericTriggerHandler.createDocRecord(newAccList , 'Account');
        customerCreation();
        deleteVisaDocument(recordNewList, recordOldMap);
    }
    public void AfterUpdateEvent() {
        Set<id> AccountIdSet = New Set<id>();
        List<Contact> contactList = New List<Contact>();
        for(Account act : recordNewList){
            if(act.Agency_Status__c == 'Registered- Active' && recordOldMap.get(act.id).Agency_Status__c != act.Agency_Status__c){
                AccountIdSet.add(act.id);
            }
        }
        Set<String> accessType = New Set<String>();
        accessType.add('Admin');
        accessType.add('Agents');
        if(AccountIdSet.size() > 0 && AccountIdSet != Null){
            contactList = [Select Id,Email,FirstName,LastName,Account.name,Broker_Access_Type__c from Contact 
                           where AccountId IN:AccountIdSet AND (Broker_Access_Type__c IN:accessType) 
                           AND Agent__r.RecordType.DeveloperName=:ConstantUtility.RT_AGENT_REP];//Added condition for agent representatives By Mamta
            system.debug('contactList is '+ contactList);
            if(contactList.size() > 0 && contactList != Null){
                Nakheel_BrokerTriggerHandler.createPartnerPortalUser(contactList);
                //;
                
            }
        } 
        sendEmailtoBrokerForAgreementSign( recordNewList, recordOldMap ); 
        terminatePortalUsersForAccount( recordNewList, recordOldMap );
        deleteVisaDocument(recordNewList, recordOldMap);
        createOrUpdateContact(recordNewList, recordOldMap, 'After Update'); // Added by Sajid
         
        if(!AccountIdSet.isEmpty()){
            system.debug('inside iSupplier call');
            ISupplierRestAPICall.SendAccountToiSupplier(AccountIdSet);
        }
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }
    
    /**********************************************************************************************
    * @Description  : Method to send Email to Broker For Agreement Sign
    * @Params       : List<Account> recordNewList => Trigger.new
    * @Params       : Map<Id, Account> recordOldMap => Trigger.oldMap
    * @Return       : void
    **********************************************************************************************/
    public static void sendEmailtoBrokerForAgreementSign( List< Account > recordNewList, Map< Id, Account > recordOldMap ){
        
        List< Account > lstAccToProceed = new List< Account >();
        Set< String > setAccountIds = new Set< String >(); 
        Set< String > setDocumentTypes = new Set< String >();
        Set< String > setAttachmentIds = new Set< String >();
        Map< Id, List<Id >> mapAccIdToAttachIdList = new Map< Id, List<Id >>();
        
        for( Account acc : recordNewList ){
            if( acc.Document_Count__c != recordOldMap.get( acc.Id ).Document_Count__c && acc.Document_Count__c == 3 && !acc.Exisiting_Broker__c  ){
                lstAccToProceed.add( acc );
                setAccountIds.add( acc.Id );
            }
        }
        
        // Get the document types
        for( Broker_Documents__mdt metadataConfig : [ SELECT Id, MasterLabel FROM Broker_Documents__mdt ]){
            setDocumentTypes.add( metadataConfig.MasterLabel );
        }
        
        Map< String,Account > IdAccountMap =new  Map<String,Account> ([SELECT ID,Agency_Status__c,Agreement_Status__c, Agency_Registration__c , Agency_Registration__r.Email_Address__c
                                                                       FROM Account 
                                                                       WHERE ID IN:setAccountIds ]); 
        
        for( Document__c doc : [ SELECT Id, Name, Attachment_Id__c, Account__c FROM Document__c WHERE Account__c IN : setAccountIds AND Document_Type__c IN :setDocumentTypes ] ){
            setAttachmentIds.add( doc.Attachment_Id__c );
            if( !mapAccIdToAttachIdList.containsKey( doc.Account__c ) ){
                mapAccIdToAttachIdList.put( doc.Account__c, new List< String >() );
            }
            mapAccIdToAttachIdList.get( doc.Account__c ).add( doc.Attachment_Id__c );
        }
        
        Map<String,Attachment> IdAttachmentMap = new  Map<String,Attachment>([SELECT Id,name,body FROM Attachment WHERE ID IN:setAttachmentIds]);
        
        // initialize temporary email list
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        
        EmailTemplate emailTemplate = [ SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate 
                                       WHERE name = : ConstantUtility.AGENCY_REGISTRATION_TEMPLATE];
        
        Contact con = [SELECT ID FROM Contact LIMIT 1 ];
        
        for(Id accId : mapAccIdToAttachIdList.keySet()){
            String agencyEmailId = IdAccountMap.get(accId).Agency_Registration__r.Email_Address__c;
            String brokerID = IdAccountMap.get(accId).Agency_Registration__c;
            List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
            // initialize one or more single emails as you need 
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            for(Id attachId : mapAccIdToAttachIdList.get(accId)){
                Attachment att = IdAttachmentMap.get(attachId);  
                Messaging.EmailFileAttachment efa = new Messaging.EmailfileAttachment();
                efa.setFileName(att.Name);
                efa.setBody(att.Body);
                efaList.add(efa);
            }
            // set the recipient email
            message.setToAddresses(new String[] {agencyEmailId });
            // set the email template id
            message.setTemplateId(emailTemplate.Id);
            // do not save email as activity
            message.setSaveAsActivity(true);
            // set the id for the object
            message.setWhatId(brokerID);
            // set target object id as your current user id
            message.setTargetObjectId( con.Id );
            message.setFileAttachments(efaList);
            // add current message to message list
            messageList.add(message);
        }
        
        // create savepoint before executing statement
        Savepoint sp = Database.setSavepoint();
        
        // send the temporary email list
        Messaging.sendEmail(messageList);
        
        // rollback the transaction before commiting to database
        Database.rollback(sp);            
        // initialize the actual message list to be sent
        List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
        /*Added By Mamta - 27 Sep*/
        OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress();
        if(!String.isBlank(AppSettings__c.getValues('OrgWideEmailAddressForSR').TextValue__c)){
            orgWideEmailAddress = EmailNotificationHelper.getOrgWideEmailAddress(AppSettings__c.getValues('OrgWideEmailAddressForSR').TextValue__c);
        }
        system.debug(orgWideEmailAddress.Id);
        // loop through the previous message list and set the email fields
        for (Messaging.SingleEmailMessage email : messageList) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());
            if(orgWideEmailAddress!=null){
                emailToSend.setOrgWideEmailAddressId(orgWideEmailAddress.Id);///*Added By Mamta - 27 Sep*/
            }   
            emailToSend.setFileAttachments(email.getFileAttachments());
            actualMessageList.add(emailToSend);
        }
        
        // send the actual message list
        Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);
        
        // make sure the emails are sent successfully
        String errorMessage = '';
        for(Messaging.SendEmailResult ser : serList){
            if(!ser.isSuccess()){
                for(Messaging.SendEmailError err : ser.getErrors()) {
                    errorMessage += err.getMessage() + '\n';
                }
            }
        }
        system.debug('errorMessage :'+errorMessage);
        
        if(serList.size()>0){
            for(Account acc: IdAccountMap.values()){
                acc.Agreement_Status__c  = ConstantUtility.SENT_FOR_SIGNATURE_TO_BROKER;
                acc.Agency_Status__c= ConstantUtility.AGREEMENT_IN_PROGRESS;
            }
            update IdAccountMap.values();
        }
    }
    
    /**********************************************************************************************
    * @Description  : Method to inactivate portals users for terminated account 
    * @Params       : List<Account> recordNewList => Trigger.new
    * @Params       : Map<Id, Account> recordOldMap => Trigger.oldMap
    * @Return       : void
    **********************************************************************************************/
    public static void terminatePortalUsersForAccount( List< Account > recordNewList, Map< Id, Account > recordOldMap ){

        Set<Id> accountIdSetForTermination = new Set<Id>();
        for(Account act : recordNewList){
            if(act.Agency_Status__c == 'Terminated' && recordOldMap.get(act.id).Agency_Status__c != act.Agency_Status__c){
                accountIdSetForTermination.add(act.id);
            }
        }
        if(!system.isFuture() && !system.isBatch()){
            inActivatePortalUser( accountIdSetForTermination );
        }
    }
    /**********************************************************************************************
    * @Description  : Method to Delete Visa Doc For United Arab Emirates 
    * @Params       : List<Account> recordNewList => Trigger.new
    * @Return       : void
    **********************************************************************************************/
    public static void deleteVisaDocument( List< Account > recordNewList, Map< Id, Account > recordOldMap ){

        Set<Id> accountIdSet = new Set<Id>();
        for(Account act : recordNewList){
            if(( recordOldMap == null || act.Customer_Nationality__c != recordOldMap.get( act.Id ).Customer_Nationality__c ) && act.Customer_Nationality__c != null && act.Customer_Nationality__c == 'AE'){
                accountIdSet.add(act.id);
            }
        }
        if(!accountIdSet.isEmpty()){
            List<Document__c> docToDelete = [SELECT Id FROM Document__c WHERE Account__c IN:accountIdSet AND Document_Type__c ='Visa'];
            if(!docToDelete.isEmpty()){
                delete docToDelete;
            }
        }
    }
    
    //Check for ERP criteria for Customer and call 
   public void customerCreation() {
        Set<Id> accId = new Set<Id>();
        
        for(Account acc : recordNewList){
            if(acc.Send_Customer_to_ERP__c && (recordOldMap == null || acc.Send_Customer_to_ERP__c != recordOldMap.get(acc.Id).Send_Customer_to_ERP__c)){
                accId.add(acc.Id);
                if(recordOldMap != null) {
                    acc.Send_Customer_to_ERP__c = false;
                }
            }
        }
        if(!accId.isEmpty()){
            ERPIntegrationHelper.createCustomer(accId);
        }
    }

    @future
    public static void inActivatePortalUser( Set< Id > accountIdSetForTermination ){
        List<User> userList = new List<User>();
        if( accountIdSetForTermination != null && accountIdSetForTermination.size() > 0 ){
            for(User usr : [SELECT Id, Name, Account.Name, IsActive FROM User WHERE User.AccountId IN: accountIdSetForTermination AND IsActive = true]){
                usr.IsActive = false;
                userList.add(usr);
            }
        }

        if( !userList.isEmpty() ){
            update userList;
        }
    }

    /**********************************************************************************************
    * @Description  : Method to create Or Update Contact
    * @Params       : List<Account> recordNewList => Trigger.new
    * @Params       : Map<Id, Account> recordOldMap => Trigger.oldMap
    * @Return       : void
    * @Author       : Sajid
    **********************************************************************************************/
    public static void createOrUpdateContact( List< Account > recordNewList, Map< Id, Account > recordOldMap, String callingContext ){
        
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id , Contact> contactMap = new Map<Id , Contact>();
        List<Contact> contactList = new List<Contact>();
        Contact signatoryContact;
        Map<Id , Address__c> addressMap = new Map<Id , Address__c>();
        List<Address__c> addressList = new List<Address__c>();
        
        for(Account act : recordNewList){
            accountIdSet.add(act.id);
        }
        
        if(accountIdSet != null && accountIdSet.size() > 0){
            for(Contact con: [Select Id,FirstName,LastName,Email,Phone,Country_Code__c,MobilePhone,AccountId   FROM Contact where AccountId IN: accountIdSet]){
                contactMap.put(con.AccountId, con);
            }
            
            for(Address__c address: [Select Id,Account__c FROM Address__c where Account__c IN: accountIdSet]){
                addressMap.put(address.Account__c, address);
            }
        }
        
        for( Account acc : recordNewList ){
            
            if(callingContext == 'After Update'){
                if( acc.Signatory_Firstname__c != recordOldMap.get( acc.Id ).Signatory_Firstname__c || 
                   acc.Signatory_Lastname__c != recordOldMap.get( acc.Id ).Signatory_Lastname__c ||
                   acc.Signatory_Email__c != recordOldMap.get( acc.Id ).Signatory_Email__c ||
                   acc.Signatory_Country_Code__c != recordOldMap.get( acc.Id ).Signatory_Country_Code__c ||
                   acc.Signatory_Phone_Number__c != recordOldMap.get( acc.Id ).Signatory_Phone_Number__c ){
                       signatoryContact = new Contact();
                       signatoryContact = contactMap.get(acc.Id);
                       
                       signatoryContact.FirstName = acc.Signatory_Firstname__c;
                       signatoryContact.LastName = acc.Signatory_Lastname__c;
                       signatoryContact.Email = acc.Signatory_Email__c;
                       signatoryContact.Country_Code__c = acc.Signatory_Country_Code__c;
                       signatoryContact.Phone = acc.Signatory_Phone_Number__c;
                       signatoryContact.AccountId = acc.Id;
                       
                       contactList.add(signatoryContact);
                       
                   }
                
                if(String.isNotEmpty(acc.Lead_Owner__c) && String.isEmpty(String.valueOf(addressMap.get(acc.Id)))
                  && ((acc.Interested_In__c == 'Commercial Unit') || (acc.Interested_In__c == 'Residential Leasing'))){
                      Address__c address = new Address__c();
                      address.City__c = acc.City__c;
                      address.Street__c = acc.Street_from_lead__c;
                      address.Postal_Code__c = acc.Postal_Code__c;
                      address.Country_New__c = acc.Country__c;
                      address.Arabic_Address__c = acc.Address_Line_4__c;
                      //if(acc.Interested_In__c == 'Commercial Unit'){
                          address.Primary__c = true;
                      //}
                      address.Account__c = acc.Id;
                      addressList.add(address);
                } 
            }else if(callingContext == 'Before Update'){
                System.debug('Calling From Before Update');
                System.debug('Acc Lead Owner '+acc.Lead_Owner__c);
                System.debug('Acc Signatory Field '+acc.Signatory_Lastname__c);
                System.debug('Acc Interested In '+acc.Interested_In__c);
                if(String.isNotEmpty(acc.Lead_Owner__c) && String.isEmpty(acc.Signatory_Lastname__c) 
                   && acc.Interested_In__c == 'Commercial Unit'){
                       signatoryContact = contactMap.get(acc.Id);
                       
                       acc.Signatory_Firstname__c = signatoryContact.FirstName;
                       acc.Signatory_Lastname__c = signatoryContact.LastName;
                       acc.Signatory_Email__c = signatoryContact.Email;
                       acc.Signatory_Country_Code__c = signatoryContact.Country_Code__c;
                       acc.Signatory_Phone_Number__c = signatoryContact.MobilePhone;
                       signatoryContact.Is_Primary__c = true;
                       signatoryContact.Phone = signatoryContact.MobilePhone;
                       contactList.add(signatoryContact);
                       System.debug('accSignatory '+acc.Signatory_Firstname__c);
                   }
                
                if(String.isNotEmpty(acc.Lead_Owner__c) && String.isEmpty(String.valueOf(addressMap.get(acc.Id)))
                  && ((acc.Interested_In__c == 'Commercial Unit') || (acc.Interested_In__c == 'Residential Leasing'))){
                      System.debug('Enter to update street '+acc.Street_from_lead__c);
                    acc.Address_Line_1__c = acc.Street_from_lead__c;
                }
            }
        }
        
        if(contactList.size() > 0){
            upsert contactList;
        }
        if(addressList.size() > 0 ){
            insert addressList;
        }
    }
    
    /** 
    * @createdDate : 20 May 2022 
    * @author : Husain Sayyed
    * @Version : V1.1
    * @usage : This function invokes before Insert and Update of Account to update country and nationality fields. 
    **/
    public void updateAccount(List<Account> newOppList, Map<Id, Account> recordOldMap){
        Map<String, String> countryFieldValueMap = new Map<String, String>();
        Map<String, String> countryOfResiFieldValueMap = new Map<String, String>();
        Map<String, String> nationalityFieldValueMap = new Map<String, String>();
        Map<String, String> customerNationalityFieldValueMap = new Map<String, String>();
        
        for(Country_and_Nationality_Mapping__mdt mapping : Country_and_Nationality_Mapping__mdt.getAll().values()){
        	countryFieldValueMap.put(mapping.Country__c, mapping.Country_Of_Residence__c);
            countryOfResiFieldValueMap.put(mapping.Country_Of_Residence__c, mapping.Country__c);
            nationalityFieldValueMap.put(mapping.Nationality__c, mapping.Customer_Nationality__c);
            customerNationalityFieldValueMap.put(mapping.Customer_Nationality__c, mapping.Nationality__c);            
        }
        
        for(Account accountRecord : newOppList){
            
            if(this.isInsert == false){
                if(accountRecord.Name != null && accountRecord.Name != recordOldMap.get(accountRecord.Id).Name){
                    accountRecord.Key_fields_Modified_Date_Time__c = system.now();
                }else if(accountRecord.IsPersonAccount && accountRecord.FirstName != null && accountRecord.FirstName != recordOldMap.get(accountRecord.Id).FirstName){
                    accountRecord.Key_fields_Modified_Date_Time__c = system.now();
                }else if(accountRecord.IsPersonAccount && accountRecord.LastName != null && accountRecord.LastName != recordOldMap.get(accountRecord.Id).LastName){
                    accountRecord.Key_fields_Modified_Date_Time__c = system.now();
                }else if(accountRecord.Primary_Email__c != null && accountRecord.Primary_Email__c != recordOldMap.get(accountRecord.Id).Primary_Email__c){
                    accountRecord.Key_fields_Modified_Date_Time__c = system.now();
                }if(accountRecord.Primary_Mobile__c != null && accountRecord.Primary_Mobile__c != recordOldMap.get(accountRecord.Id).Primary_Mobile__c){
                    accountRecord.Key_fields_Modified_Date_Time__c = system.now();
                }
            }
                
            if(accountRecord.Country__c != null && countryFieldValueMap.containsKey(accountRecord.Country__c) && (this.isInsert || (accountRecord.Country__c != recordOldMap.get(accountRecord.Id).Country__c))){
                accountRecord.Country_Of_Residence__c = countryFieldValueMap.get(accountRecord.Country__c);
            }else if(accountRecord.Country_Of_Residence__c != null && countryOfResiFieldValueMap.containsKey(accountRecord.Country_Of_Residence__c) && (this.isInsert || accountRecord.Country_Of_Residence__c != recordOldMap.get(accountRecord.Id).Country_Of_Residence__c)){
                accountRecord.Country__c = countryOfResiFieldValueMap.get(accountRecord.Country_Of_Residence__c);
            }
            
            if(accountRecord.Nationality__c != null && nationalityFieldValueMap.containsKey(accountRecord.Nationality__c) && (this.isInsert || accountRecord.Nationality__c != recordOldMap.get(accountRecord.Id).Nationality__c)){
                accountRecord.Customer_Nationality__c = nationalityFieldValueMap.get(accountRecord.Nationality__c);
            }else if(accountRecord.Customer_Nationality__c != null && customerNationalityFieldValueMap.containsKey(accountRecord.Customer_Nationality__c) && (this.isInsert || accountRecord.Customer_Nationality__c != recordOldMap.get(accountRecord.Id).Customer_Nationality__c)){
                accountRecord.Nationality__c = customerNationalityFieldValueMap.get(accountRecord.Customer_Nationality__c);
            }
        }
        
    }
    
    
    /**********************************************************************************************
* @Description  : Method to delete account generated trade license doc for business account created from lead
* @Params       : Set<Id> accountId 
* @Return       : void
* @Author       : Sajid
**********************************************************************************************/
    public void deleteCreatedDoc(){
        try{
            
            Set<ID> IdSet = new Set<ID>();
            Id CorporateCustomer = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_RecordType').getRecordTypeId();
            Id PersonAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            Map<ID, Account> accountMap = new Map<ID, Account>();
            for(Account account: recordNewList){
                if(String.isNotEmpty(account.Lead_Owner__c) && 
                   (account.RecordTypeId == CorporateCustomer || 
                    account.RecordTypeId == PersonAccount )&& 
                   account.Interested_In__c != 'Sales' &&
                   !account.IsDocAttachedFromLead__c){
                       account.IsDocAttachedFromLead__c = true;
                       accountMap.put(account.Id, account);
                       IdSet.add(account.Id);
                   }
            }
            
            if(IdSet.size() > 0){
                List<Document__c> docList = new List<Document__c>();
                Set<String> docTypeString = new Set<String>();
               for(Document__c doc: [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Leads__r.Name,Leads__r.ConvertedAccountId , Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                                                Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                                     where Account__c = :IdSet]){
                                         Account acc = accountMap.get(doc.Account__c);
                                         if(doc.Document_Type__c == 'Trade License' && !doc.Is_Document_Uploaded__c && acc.Trade_License_Uploaded__c){
                                             if(!docTypeString.contains(doc.Document_Type__c)){
                                                 docTypeString.add(doc.Document_Type__c);
                                                 docList.add(doc);
                                             }
                                         }else if(doc.Document_Type__c == 'Passport' && !doc.Is_Document_Uploaded__c && acc.Passport_Uploaded__c){
                                            if(!docTypeString.contains(doc.Document_Type__c)){
                                                docTypeString.add(doc.Document_Type__c);
                                                 docList.add(doc);
                                             }
                                         }else if(doc.Document_Type__c == 'Visa' && !doc.Is_Document_Uploaded__c && acc.Visa_Uploaded__c){
                                             if(!docTypeString.contains(doc.Document_Type__c)){
                                                 docTypeString.add(doc.Document_Type__c);
                                                 docList.add(doc);
                                             }
                                         }else if(doc.Document_Type__c == 'Emirates Id' && !doc.Is_Document_Uploaded__c && acc.Emirates_ID_Uploaded__c){
                                             if(!docTypeString.contains(doc.Document_Type__c)){
                                                 docTypeString.add(doc.Document_Type__c);
                                                 docList.add(doc);
                                             }
                                         }
                                     }

                if(docList.size() > 0){
                    delete docList;
                }
            }
            
            
        }Catch(Exception ex){
            System.debug('Error '+ex.getMessage() +' '+ex.getLineNumber());
        }
        
    }
}