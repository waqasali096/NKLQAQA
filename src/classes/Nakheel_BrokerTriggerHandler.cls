public class Nakheel_BrokerTriggerHandler {
    
    List<Broker__c> recordNewList = new List<Broker__c>();
    List<Broker__c> recordOldList = new List<Broker__c>();
    Map<Id, Broker__c> recordNewMap = new Map<Id, Broker__c>();
    Map<Id, Broker__c> recordOldMap = new Map<Id, Broker__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    public Nakheel_BrokerTriggerHandler(List<Broker__c> newList, List<Broker__c> oldList, Map<Id, Broker__c> newMap, Map<Id, Broker__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
        Map<Integer, Id> rrNumAndUserIdMap = new Map<Integer, Id>();
        // Get executive users
        for(User execUser : [
            SELECT Id, Name, Profile_Name__c, Round_robin_ownership_number__c
              FROM User
             WHERE Profile_Name__c = 'Partner support executive'
               AND IsActive = TRUE
        ]) {
            rrNumAndUserIdMap.put(Integer.valueOf(execUser.Round_robin_ownership_number__c), execUser.Id);
        }

        // Calculate round robin number and assign owner
        Integer rrNum;
        List<Broker__c> brokersToUpdate = new List<Broker__c>();
        Broker__c recToUpdate;
        for(Broker__c broker : recordNewList) {
            recToUpdate = new Broker__c();
            recToUpdate.Id = broker.Id;

            rrNum = Math.mod(Integer.valueOf(broker.Broker_Number__c), rrNumAndUserIdMap.size()) + 1;

            if(rrNumAndUserIdMap.containsKey(rrNum)) {
                recToUpdate.OwnerId = rrNumAndUserIdMap.get(rrNum);
                brokersToUpdate.add(recToUpdate);
            }
        }
        update brokersToUpdate;
    }

    public void AfterUpdateEvent() {
        List<Broker__c> approvedList = new List<Broker__c>();
        List<Id> agencyApprovedIdSet = new List<Id>();
        for(Broker__c broker : recordNewList){
            if(broker.Agency_Approval_Status__c == 'Approved' && recordOldMap.get(broker.Id).Agency_Approval_Status__c != broker.Agency_Approval_Status__c){
                agencyApprovedIdSet.add(broker.Id);
            }
            if(broker.Admin_Approval_Status__c == 'Approved' && 
               recordOldMap.get(broker.Id).Admin_Approval_Status__c != broker.Admin_Approval_Status__c){
                   system.debug('<<<<<<<<<'+broker.Admin_Approval_Status__c+'>>>>>>>>>>>>>>>');
                   approvedList.add(broker);
                   system.debug('<<<<<<<<<'+approvedList);
               }
        }
        if(agencyApprovedIdSet.size() > 0){
        	approveDocuments(agencyApprovedIdSet);
        }
        if(!approvedList.isEmpty()){
            createAccountContact(approvedList);  
            //agreementGeneration(approvedList);   
            //bulkAgreementGeneration(approvedList);
        }
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }
    
    public static void approveDocuments(List<Id> agencyApprovedIdSet){
        List<Document__c> documentsToUpdate = new List<Document__c>();
        for(Document__c doc : [Select Id from Document__c where Agency_Registration__c IN : agencyApprovedIdSet]){
            doc.Approval_Status__c = 'Approved';
            documentsToUpdate.add(doc);
        }
        if(documentsToUpdate.size() > 0){
            update documentsToUpdate;
        }
    }
    
    public static void createAccountContact(List<Broker__c> activeBorkerlst){
        RecordType accRectype = [SELECT Id, Name FROM RecordType WHERE SobjectType='Account' AND Name = 'Broker Account'];
        List<Broker__c> borkerList = [SELECT Id,Exisiting_Broker__c ,Name, Source__c,(select id from Agents__r),Agency_Admin_Mobile__c,Mobile__c,
                                      Agency_Approval_Status__c,Email_Address__c ,Sales_Consultant__c,RecordType.Name,
                                      Bank_Account__c,Bank_Account_Name__c,Bank_Address__c,Bank_Branch__c,Postal_Code__c ,
                                      Bank_Currency_of_Account__c,Bank_SWIFT_Code__c,Bank_Name__c,Account_Number__c,
                                      Other_Bank_Name__c,Address_Line__c,Bank_IBAN_Number__c,City__c,State__c,Place_of_Incorporation__c
                                      FROM Broker__c WHERE Id In: activeBorkerlst];
        
        Set<String> docParentdIDS = new Set<String>();
        
        if(!borkerList.isEmpty()){
            List<Account> brokerAcc = new List<Account>();
            Map<Id, Id> brokerIdMap = new Map<Id,Id>();
            Set<Id> accountIds = new Set<Id>();
            Set<Id> nonexistingAccounts = new Set<Id>();
            for(Broker__c broker : borkerList){
                Account acc = new Account();
                acc.Name = broker.Name;
                acc.RecordTypeId = accRectype.Id;
                
                //added by husain - broker.RecordType.Name == 'TAG Agency'
                acc.Agency_Status__c = 'Agreement in Process';
                acc.Agency_Registration__c = broker.Id;
                if(broker.Source__c == 'Broker Portal'){ 
                    acc.AccountSource = 'Broker Portal';
                }
                
                acc.Account_Type__c = 'Broker';
                
                
                acc.Sales_Consultant__c = broker.Sales_Consultant__c;
                acc.Primary_Mobile__c = broker.Mobile__c;
                acc.Primary_Email__c = broker.Email_Address__c;
                acc.Country_Of_Residence__c = 'AE';
                acc.Customer_Nationality__c = 'AE';
                acc.Primary_Country_Code__c = '971';
                acc.BrokerId__c = broker.Id;
                
                //Added by Karishma
                acc.Bank_Account__c  = broker.Bank_Account__c;
                acc.Bank_Account_Name__c = broker.Bank_Account_Name__c;
                acc.Bank_Address__c = broker.Bank_Address__c;
                acc.Bank_Branch__c = broker.Bank_Branch__c;
                acc.Bank_Currency_of_Account__c = broker.Bank_Currency_of_Account__c;
                acc.Bank_SWIFT_Code__c = broker.Bank_SWIFT_Code__c;
                acc.Bank_Name__c = broker.Bank_Name__c;
                acc.Account_Number__c = broker.Account_Number__c;
                acc.Other_Bank_Name__c =broker.Other_Bank_Name__c;
                acc.BillingStreet = broker.Address_Line__c;
                acc.BillingCity = broker.City__c;
                acc.BillingState = broker.State__c;
                acc.BillingCountry = broker.Place_of_Incorporation__c;
                acc.Bank_IBAN_Number__c = broker.Bank_IBAN_Number__c;
                acc.BillingPostalCode = broker.Postal_Code__c;
                acc.Exisiting_Broker__c = broker.Exisiting_Broker__c;
                brokerAcc.add(acc);
                /*for(Broker_Agents__c  agent : broker.Agents__r){
docParentdIDS.add(agent.Id);
}
docParentdIDS.add(broker.id);*/
            }
            if(!brokerAcc.isEmpty()){
                system.debug('<<<<<<<<<<<brokerAcc>>>>>>>>>'+brokerAcc);
                
                try{
                    insert brokerAcc;
                }catch(DMLException ex){
                    system.debug('==Error Occured=='+ex.getDmlMessage(0));
                    // Added by Husain
                    // This will display your custom validation rule error messages
                    activeBorkerlst[0].addError(ex.getDmlMessage(0)); 
                }
                
                List<Contact> lstcon = new List<Contact>();
                for(Account acc: brokerAcc){
                    if(acc.Account_Type__c == 'Broker'){
                        brokerIdMap.put(acc.BrokerId__c,acc.id); 
                        accountIds.add(acc.id);
                        if(!acc.Exisiting_Broker__c){
                            nonexistingAccounts.add(acc.Id);
                        }  
                    }
                    
                    else{
                        Contact con = new Contact();
                        con.LastName = acc.Name;
                        con.MobilePhone = acc.Primary_Mobile__c;
                        con.Email = acc.Primary_Email__c;     
                        con.AccountId = acc.Id;
                        con.Designation__c = 'Ambassadors';
                        con.Country_Code__c = acc.Primary_Country_Code__c;
                        lstcon.add(con);
                    }
                    system.debug('<<<<<<<<<<<brokerIdMap>>>>>>>>>'+brokerIdMap);
                    // MAF_ContactTriggerHandler.disableTrigger = TRUE;
                    insert lstcon;
                }
            }
            if(brokerIdMap.size() > 0 && brokerIdMap != Null){
                tagDocumentstoAccountAndContacts(brokerIdMap,'Account');
                insertBrokerAgreementDocuments(nonexistingAccounts);
                
                /*List<Document__c> documentList = New List<Document__c>();
documentList = [Select Id,Name,Account__c,Parent_Id__c 
from Document__c where Parent_Id__c IN:brokerIdMap.keySet()];

if(documentList.size() > 0 && documentList != Null){
for(Document__c documents : documentList){
if(brokerIdMap.containsKey(documents.Parent_Id__c)){
documents.Account__c = brokerIdMap.get(documents.Parent_Id__c);
}             
}
try{
Update documentList;	
}catch(Exception e){
system.debug('Exception:' + e);
}
}*/
                
            }
            List<Contact> agentList = new List<Contact>();
            
            List<Contact> agentToCreatePortalUserList = new List<Contact>();
            //added Broker_Access_Type__c field in query
            for(Broker_Agents__c brokerAgent: [SELECT Id, First_Name__c, Last_Name__c,Country_Code__c , Mobile__c, Email__c, Agency_Registration__c,Designation__c, Agency_Registration__r.Source__c,Broker_Access_Type__c,RecordType.DeveloperName    FROM Broker_Agents__c WHERE Agency_Registration__c =: brokerIdMap.KeySet()]){
                Contact con = new Contact();
                con.AccountId = brokerIdMap.get(brokerAgent.Agency_Registration__c);
                con.FirstName  = brokerAgent.First_Name__c;
                con.LastName = brokerAgent.Last_Name__c;
                con.MobilePhone = brokerAgent.Mobile__c;
                con.Email = brokerAgent.Email__c;
                con.Designation__c = brokerAgent.Designation__c;
                con.Country_Code__c  =brokerAgent.Country_Code__c;
                //Added by husain
                con.Broker_Access_Type__c = brokerAgent.Broker_Access_Type__c;
                con.Agent__c = brokerAgent.Id;
                //
                agentList.add(con);
                system.debug('<<<<<<<<<<<agentList>>>>>>>>>'+agentList);
                
                //Added by Husain to create broker portal user on approval
                if(brokerAgent.Agency_Registration__r.Source__c == 'Broker Portal' && ( brokerAgent.RecordType.DeveloperName == 'Agent_Representative'  && (brokerAgent.Broker_Access_Type__c=='Admin'||brokerAgent.Broker_Access_Type__c=='Agents')/*|| brokerAgent.RecordType.DeveloperName == 'Authorized_Signatory'*/ )){
                    agentToCreatePortalUserList.add(con);
                }
                //END
            }
            if(!agentList.isEmpty()){
                //  MAF_ContactTriggerHandler.disableTrigger = TRUE;
                insert agentList;
                system.debug('<<<<<<<<<<<agentList insert>>>>>>>>>'+agentList);
            }
            
            
            //Added by Mamta for tagging documents to contacts
            Map<ID,ID> AgentIDContactIDMap = new Map<ID,ID> ();
            for(contact con : agentList){
                AgentIDContactIDMap.put(con.Agent__c,con.id);
            }
            
            if(!AgentIDContactIDMap.isEmpty()){
                tagDocumentstoAccountAndContacts(AgentIDContactIDMap,'Contact');
            }
            //Added by Husain to create broker portal user on approval
            if(agentToCreatePortalUserList.isEmpty() == false){
                // createPartnerPortalUser(agentToCreatePortalUserList); commented by hitarth as this method will be called from Account tirgger
            }
            //END
        }
    }
    
    Public static void tagDocumentstoAccountAndContacts(Map<ID,ID> brokerIdMap,String type){
        if(brokerIdMap.size() > 0 && brokerIdMap != Null){
            List<Document__c> documentList = New List<Document__c>();
            //documentList = [Select Id,Name,Account__c,Parent_Id__c from Document__c where Parent_Id__c IN:brokerIdMap.keySet()];
            documentList = [Select Id,Name,Account__c,Parent_Id__c from Document__c where Parent_Id__c IN:brokerIdMap.keySet()];
            
            if(documentList.size() > 0 && documentList != Null){
                for(Document__c documents : documentList){
                    if(brokerIdMap.containsKey(documents.Parent_Id__c)){
                        if(type=='Account'){
                            documents.Account__c = brokerIdMap.get(documents.Parent_Id__c);
                        }
                        else if(type=='Contact'){
                            documents.Contact__c = brokerIdMap.get(documents.Parent_Id__c);
                            
                        }
                    }             
                }
                try{
                    Update documentList;	
                }catch(Exception e){
                    system.debug('Exception:' + e);
                }
            }
            
        }
    }
    /**
* This method will used to create broker portal user on approval
* @date    2021-07-09
* @author  Husain Sayyed
*/
    public static void createPartnerPortalUser(List<Contact> contactList){
        system.debug('contact list=== ' + contactList);
        
        List<Profile> portalProfile = new List<Profile>();
        portalProfile = [select Id,Name from Profile where UserType = 'PowerPartner'];
        Id PartnerAdmin;
        id partnerAgent;
        for(Profile prf : portalProfile){
            if(prf.Name == 'Nakheel Broker Admin'){
                PartnerAdmin = prf.Id;
            }
            if(prf.Name == 'Nakheel Broker Agent'){
                partnerAgent = prf.Id;
            }
        }
        Organization organization = [SELECT Name, InstanceName FROM Organization limit 1];
        
        String orgId = organization.InstanceName;
        //UserInfo.getOrganizationId();  
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        //Added by karishma for nickname and username
        Counter_Setting__c cs = Counter_Setting__c.getValues('User_Count');
        Integer Count = Integer.valueOf(cs.Counter__c);
        
        list<User> UserToInsertList = new list<User>();
        
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = true;
        
        for(Contact contactRecord : contactList){
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
            String uniqueName = orgId + dateString + randomInt;  
            
            //Create User
            User theUser = new User();
            //theUser.Username = contactRecord.Email + uniqueName + '.partnerPortal';//commented by mamta for shortening name
            
            //theUser.Username = (contactRecord.Email + contactRecord.Account.name + '.partnerPortal').replaceAll( '\\s+', '');
            theUser.Username = contactRecord.Email+'.nkl'+string.valueOf(Count);
            System.debug('theUser.Username = '+ theUser.Username);
            // Username = contactRecord.Email  + '.partnerPortal',
            theUser.ContactId = contactRecord.Id;
            if(contactRecord.Broker_Access_Type__c == 'Admin'){
                theUser.ProfileId = PartnerAdmin;
            }
            if(contactRecord.Broker_Access_Type__c == 'Agents'){
                theUser.ProfileId = partnerAgent;
            }
            theUser.Alias = 'NKL'+string.valueOf(Count);
            theUser.Email = contactRecord.Email;
            theUser.EmailEncodingKey = 'UTF-8';
            theUser.FirstName = contactRecord.FirstName;
            theUser.LastName = contactRecord.LastName;
            String fullName = contactRecord.FirstName+ ' ' + contactRecord.LastName;
            String lastName = contactRecord.LastName;
            String nickName = '';
            if(fullName.length()>30){
                if(lastName.length()>30){
                    nickName = lastName.substring(0, 30);
                }else{
                    nickName = lastName;
                }
            }else{
                nickName = fullName;
            }
            theUser.CommunityNickname = nickName + '-NKL'+string.valueOf(Count);
            theUser.TimeZoneSidKey = 'Asia/Dubai';
            theUser.LocaleSidKey = 'en_GB';
            theUser.LanguageLocaleKey = 'en_US';
            // theUser.Org_Id__c = '696';
            
            theUser.setOptions(dlo);
            UserToInsertList.add(theUser);
            ++Count;
        }
        
        //added by karishma to update Counter setting
        Counter_Setting__c obj = Counter_Setting__c.getInstance('User_Count');
        obj.Counter__c = count;
        update obj;
        
        system.debug('==UserToInsertList=='+UserToInsertList);
        
        if(UserToInsertList.isEmpty() == false){
            database.insert(UserToInsertList);
            List<String> userIDS = new List<String>();
            for(User  user:UserToInsertList ){
                if(user.ProfileID==PartnerAdmin||user.ProfileID==partnerAgent){
                    userIDS.add(user.Id);
                }
            }
            if(userIDS.size()>0){
                addMembersInGroup(userIDS);
            }
        }
        
    }
    
    @future
    public static void addMembersInGroup(List<STring> userIDS){
        Group grp = [select id,name from Group where  DeveloperName='Broker_AdminAgents_Group' LIMIT 1 ];
        List<GroupMember> brokerAdminAgentGMlist = new List<GroupMember>();
        for(String  user:userIDS ){
            //if(user.ProfileID==PartnerAdmin||user.ProfileID==partnerAgent){
            GroupMember GM = new GroupMember();
            GM.GroupId = grp.Id;
            GM.UserOrGroupId = user;
            brokerAdminAgentGMlist.add(GM);
            //}
        }
        
        if(brokerAdminAgentGMlist.size()>0){
            insert brokerAdminAgentGMlist;
        }
        
    }
    
    /*This method generates agreement after approval 
* 23 Aug 2021
--Added by Mamta*/
    /*Public static void agreementGeneration(List<Broker__c> approvedbrokerList){
Map<String,Account> IdAccountMap =new  Map<String,Account> ([SELECT ID, Agency_Registration__c , Agency_Registration__r.Email_Address__c  from Account where Agency_Registration__c IN:approvedbrokerList ]); 
rsdoc__Document_Action__c  docAction=[SELECT ID , rsdoc__Template_Document_ID__c  FROM rsdoc__Document_Action__c WHERE rsdoc__Template_Name__c =:ConstantUtility.REC_DocumentActionName LIMIT 1 ];  
List<rsdoc__Document_Request__c> docRequests = new List<rsdoc__Document_Request__c>(); 
for(Account acc : IdAccountMap.values()){
rsdoc__Document_Request__c  docReq = new rsdoc__Document_Request__c ();
docReq.rsdoc__Document_Action__c =docAction.ID;
docReq.rsdoc__Record_Id__c =acc.id;
docReq.Email_Generated_Attachment_To_Broker__c  =true;
docRequests.add(docReq);
}  
if(docRequests.size()>0){
insert docRequests;

system.debug('docRequests are '+ docRequests);
}
}*/
    
    /*This method generates bulk agreement after approval 
* 07 Sept 2021
--Added by Karishma*/
    /*public static void bulkAgreementGeneration(List<Broker__c> approvedbrokerList){
system.debug('approved broker list are '+ approvedbrokerList);
Map<String,Account> IdAccountMap =new  Map<String,Account> ([SELECT ID, Agency_Registration__c , 
Agency_Registration__r.Email_Address__c  
FROM Account 
WHERE Agency_Registration__c IN:approvedbrokerList ]); 
List<Broker_Documents__mdt> brokerDocuments = getBrokerAgreementLabels();
set<String> brokerDocumentSet = new set<String>();
for(Broker_Documents__mdt mdt:  brokerDocuments){
brokerDocumentSet.add(mdt.MasterLabel);
}
List<rsdoc__Document_Action__c>  docActionList=[SELECT ID , rsdoc__Template_Document_ID__c  
FROM rsdoc__Document_Action__c 
WHERE rsdoc__Template_Name__c IN: brokerDocumentSet ];  
List<rsdoc__Document_Request__c> docRequests = new List<rsdoc__Document_Request__c>(); 


for(Account acc : IdAccountMap.values()){
for(rsdoc__Document_Action__c rsdocAction: docActionList){
rsdoc__Document_Request__c  docReq = new rsdoc__Document_Request__c ();
docReq.rsdoc__Document_Action__c =rsdocAction.ID;
docReq.rsdoc__Record_Id__c =acc.id;
docReq.Email_Generated_Attachment_To_Broker__c  =true;
docRequests.add(docReq);
}
}  
if(docRequests.size()>0){
insert docRequests;
//system.debug('***docRequests are '+ docRequests);
}
}*/
    
    /*This method generates broker agreement document record after approval 
* 08 Sept 2021
--Added by Karishma*/
    public static void insertBrokerAgreementDocuments(set<Id> accountIds){
        List<Document__c> documentList = new List<Document__c>();
        List<Broker_Documents__mdt> brokerDocuments = getBrokerAgreementLabels();
        Map<Id,String> documentMap = new Map<Id,String>();
        
        for(Id accId : accountIds){
            for(Broker_Documents__mdt mdt : brokerDocuments){
                Document__c doc = new Document__c();
                doc.Account__c = accId;
                doc.Document_Type__c = mdt.MasterLabel;
                doc.File_Name__c = mdt.MasterLabel;   
                documentList.add(doc);
            }
        }
        if(!documentList.isEmpty()){
            insert documentList;
            for(Document__c doc : documentList){
                if(doc.Id != null) documentMap.put(doc.Id,doc.Document_Type__c);
            }
            generateAgreement(documentMap);
        }
    }
    
    /*This method generates agreement on Document after approval 
* 23 Aug 2021
--Added by Karishma*/
    public static void generateAgreement(Map<Id,String> documentMap){
        set<String> brokerDocumentSet = new set<String>();
        List<Broker_Documents__mdt> brokerDocuments = getBrokerAgreementLabels();
        for(Broker_Documents__mdt mdt:  brokerDocuments){
            brokerDocumentSet.add(mdt.MasterLabel);
        }
        List<rsdoc__Document_Action__c>  docActionList=[SELECT ID , rsdoc__Template_Document_ID__c,rsdoc__Template_Name__c 
                                                        FROM rsdoc__Document_Action__c 
                                                        WHERE rsdoc__Template_Name__c IN: brokerDocumentSet ];  
        List<rsdoc__Document_Request__c> docRequests = new List<rsdoc__Document_Request__c>(); 
        for(Id docId : documentMap.keySet()){
            for(rsdoc__Document_Action__c rsdocAction: docActionList){
                if(documentMap.get(docId).equals(rsdocAction.rsdoc__Template_Name__c)){
                    rsdoc__Document_Request__c  docReq = new rsdoc__Document_Request__c ();
                    docReq.rsdoc__Document_Action__c =rsdocAction.ID;
                    docReq.rsdoc__Record_Id__c =docId;
                    //docReq.Email_Generated_Attachment_To_Broker__c  =true;
                    docRequests.add(docReq);
                }
            }            
        }
        if(docRequests.size()>0){
            insert docRequests;
            system.debug('***docRequests are '+ docRequests);
        }
    }
    
    public static List<Broker_Documents__mdt> getBrokerAgreementLabels(){
        List<Broker_Documents__mdt> brokerDocuments = [SELECT MasterLabel  FROM Broker_Documents__mdt];
        return brokerDocuments;
    }
    
}