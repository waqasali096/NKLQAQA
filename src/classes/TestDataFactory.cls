/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public class TestDataFactory {
    
    public static List<Assignment_Resource__c> AssignementResourceStandFactory (Integer numAssign, String EngineInstance){
        List<Assignment_Resource__c> listAssignResource = new List<Assignment_Resource__c>();
        for(integer i=0;i<numAssign;i++){
            Assignment_Resource__c AssignResource = new Assignment_Resource__c();
            AssignResource.Capacity__c = 10;
            AssignResource.Engine_Instance__c=EngineInstance;
            AssignResource.User__c=Userinfo.getUserId();
            AssignResource.Workload__c=1;
            listAssignResource.add(AssignResource);
        }
        if(listAssignResource.size()>0){
            insert listAssignResource;
        }
        
        return listAssignResource;
    }
    
    public static List<Engine_Instance__c>  EngineIntanceFactory (Integer numEngine){
        List <Engine_Instance__c> listEngineInstance =new list<Engine_Instance__c>();
        for(integer i=0; i< numEngine; i++){
            Engine_Instance__c EngineInstance = new Engine_Instance__c();
            EngineInstance.Assignment_Field_Name__c='Assigned Resource';
            EngineInstance.Matching_Rule_Field__c='Matching Rule';
            EngineInstance.Closing_Criteria_Field_Value__c='Qualified';
            EngineInstance.Closing_Criteria_Field__c='Status';
            EngineInstance.Status__c=' NOT STARTED';
            EngineInstance.SObject__c='Lead';
            EngineInstance.MATCHING_RULE__c=2;
            
            listEngineInstance.add(EngineInstance);
        }
        if(listEngineInstance.size()>0){
            insert listEngineInstance;
        }
        
        return listEngineInstance;
    }
    
    public static List<Broker__c> createBrokers(Integer numBrokers) {
        List<Broker__c> brokers = new List<Broker__c>();
        for(integer i=0;i<numBrokers;i++){
            Broker__c broker = new Broker__c();
            broker.Agency_Location__c='International';
            broker.Company_Name__c='Test';
            broker.Bank_Name__c='PNB';
            broker.Bank_IBAN_Number__c='11111111111111111111111';
            broker.Bank_SWIFT_Code__c='123';
            broker.Account_Number__c ='12334';
            broker.Email_Address__c='test@gmail.com';
            brokers.add(broker);
        } 
        if(brokers.size()>0){
            insert brokers;
        }
        
        return brokers;
    }
    
    public static List<Broker_Proprietor__c> createBrokerProprietors(List<Broker__c> brokers) {
        List<Broker_Proprietor__c> brokersProprietors = new List<Broker_Proprietor__c>();
        for(integer i=0;i<brokers.size();i++){
            Broker_Proprietor__c brokerP = new Broker_Proprietor__c();
            brokerP.Agency_Registration__c=brokers[i].Id;
            brokerP.Shareholder_Passport_No__c='Test';
            brokerP.Shareholder_Percentage__c=100;
            
            brokersProprietors.add(brokerP);
        } 
        if(brokersProprietors.size()>0){
            insert brokersProprietors;
        }
        
        return brokersProprietors;
    }
    
    public static List<Broker_Agents__c> createBrokerAgentsAuths(List<Broker__c> brokers) {
        List<Broker_Agents__c> brokersAgentAuths = new List<Broker_Agents__c>();
        for(integer i=0;i<brokers.size();i++){
            Broker_Agents__c brokerP = new Broker_Agents__c();
            brokerP.Agency_Registration__c=brokers[i].Id;
            brokerP.Branch_Location__c='FBD';
            brokerP.Designation__c='Dev';
            brokerP.Broker_Access_Type__c='Agents';
            brokerP.First_Name__c ='Test1';
            // brokerP.L
            brokerP.RecordTYpeId=CommonUtility.recordTypeIdByDevName(Broker_Agents__c.sObjectType, 'Agent_Representative');
            
            
            brokersAgentAuths.add(brokerP);
        } 
        if(brokersAgentAuths.size()>0){
            insert brokersAgentAuths;
        }
        system.debug('brokersAgentAuths is '+ brokersAgentAuths);
        return brokersAgentAuths;
    }
    
    
    public static List<Broker_Agents__c> createAdditionlaContactAgents(List<Broker__c> brokers) {
        List<Broker_Agents__c> brokersAgentAuths = new List<Broker_Agents__c>();
        for(integer i=0;i<brokers.size();i++){
            Broker_Agents__c brokerP = new Broker_Agents__c();
            brokerP.Agency_Registration__c=brokers[i].Id;
            brokerP.Branch_Location__c='FBD';
            brokerP.Designation__c='Dev';
            //brokerP.Broker_Access_Type__c='Agents';
            brokerP.First_Name__c ='Test1';
            // brokerP.L
            brokerP.RecordTYpeId=CommonUtility.recordTypeIdByDevName(Broker_Agents__c.sObjectType, 'Agent_Representative');
            
            
            brokersAgentAuths.add(brokerP);
        } 
        if(brokersAgentAuths.size()>0){
            insert brokersAgentAuths;
        }
        system.debug('brokersAgentAuths is '+ brokersAgentAuths);
        return brokersAgentAuths;
    }
    
    
    public static List<Broker_Agents__c> createBrokerAgentsSignatories(List<Broker__c> brokers) {
        List<Broker_Agents__c> brokersAgentSignatories = new List<Broker_Agents__c>();
        for(integer i=0;i<brokers.size();i++){
            Broker_Agents__c brokerP = new Broker_Agents__c();
            brokerP.First_Name__c='Test2';
            brokerP.Agency_Registration__c=brokers[i].Id;
            brokerP.Branch_Location__c='FBD';
            brokerP.Designation__c='Dev';
            brokerP.RecordTypeID=CommonUtility.recordTypeIdByDevName(Broker_Agents__c.sObjectType, 'Authorized_Signatory');
            
            brokersAgentSignatories.add(brokerP);
        } 
        if(brokersAgentSignatories.size()>0){
            insert brokersAgentSignatories;
        }
        
        return brokersAgentSignatories;
    }
    
    public static List<ContentVersion> createcontentVersions(integer numContentVers){
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for(integer i=0;i<numContentVers;i++){
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'a picture',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            
            contentVersions.add(contentVersion);
        }
        
        if(contentVersions.size()>0){
            insert contentVersions;
        }
        
        return contentVersions;
        
    }
    
    
    public static List<Document__c> createDocuments(List<ContentVersion> contentVersions, STring parentID){
        List<Document__c> documents = new List<Document__c> ();
        for(integer i=0;i<contentVersions.size();i++){
            Document__c doc = new Document__c();
            doc.Document_Type__c  ='Test'+i;
            doc.Parent_Id__c=parentID;
            doc.Attachment_Id__c = contentVersions[i].id;
            documents.add(doc);
        }
        if(documents.size()>0){
            insert documents;
        }
        return documents;
    }
    
    public static List<Document__c> returnDocuments(List<ContentVersion> contentVersions, STring parentID){
        List<Document__c> documents = new List<Document__c> ();
        for(integer i=0;i<contentVersions.size();i++){
            Document__c doc = new Document__c();
            doc.Document_Type__c  ='Test'+i;
            doc.Parent_Id__c=parentID;
            doc.Attachment_Id__c = contentVersions[i].id;
            doc.Document_ID_Number__c = '1234';
            documents.add(doc);
        }
        if(documents.size()>0){
            //
        }
        return documents;
    }
    
    public static List<Account> createAccounts(Integer numAccounts) {
        List<Account> accList = new List<Account>();
        for(integer i=0;i<numAccounts;i++){
            Account acc = new Account();
            acc.Name='Test-Account'+i;
            acc.Primary_Email__c='Nakheel122@gmail.com';
            acc.Account_Number__c = '44545454545';
            accList.add(acc);
        } 
        if(accList.size()>0){
            insert accList;
        }
        
        return accList;
    }
    
    public static List<Contact> createContacts(Integer numContacts, List<Account> accList) {
        List<Contact> conList = new List<Contact>();
        for(integer i=0;i<numContacts;i++){
            Contact con = new Contact();
            con.LastName='Test'+i;
            con.Email='Nakheel_Example'+i+'@gmail.com';
            con.Broker_Access_Type__c = 'Admin';
            con.AccountId = accList[0].Id;
            conList.add(con);
        } 
        if(conList.size()>0){
            insert conList;
        }
        
        return conList;
    }
    
    public static List<Opportunity> createOpportunities(Integer numOpps, List<Account> accList) {
        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=0;i<numOpps;i++){
            Opportunity opp = new Opportunity();
            opp.Name='Test-Opp'+i;
            opp.AccountId=accList[0].Id;
            opp.StageName = 'Need Analysis';
            opp.CloseDate = System.today();
            
            oppList.add(opp);
        } 
        //if(oppList.size()>0){
        //insert oppList;
        
        insert oppList;
        return oppList;
    }
    
    public static List<User> createUsers(Integer numUser, Id profileId) {
        List<User> userList = new List<User>();
        for(integer i=0;i<numUser;i++){
            User u = new User(Alias = 'standt', Email='standarduser'+i+'@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing'+i, LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = profileId, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='standarduser'+i+'@testorg.com');
            
        } 
        if(userList.size()>0){
            insert userList;
        }
        
        return userList;
    }   
    public static List<UserRole> createRoles() {
    List<UserRole> userrolelist = new List<UserRole>();
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
       userrolelist.add(r);
        insert userrolelist;
        return userrolelist;
    }    
    
    public static List<rsdoc__Document_Action__c> create_rsdocDocumentAction(Integer numDocActionrequest) {
        List<rsdoc__Document_Action__c> rsdocDocumeActionRequestList = new List<rsdoc__Document_Action__c>();
        
        for(integer i=0;i<numDocActionrequest;i++){
            rsdoc__Document_Action__c rsDocAction = new rsdoc__Document_Action__c();
            rsDocAction.rsdoc__Base_object_API__c = 'Account';
            rsDocAction.rsdoc__Template_Name__c = 'Broker Agreement';
            rsDocAction.rsdoc__Template_Document_ID__c ='asfsdasd12';
            rsDocAction.rsdoc__Visibility__c = 'Public';
            //rsDocAction.rsdoc__Access__c = 'Can edit';
            //rsDocAction.rsdoc__Output_format__c = 'pdf';
            //rsDocAction.rsdoc__Redirect_To__c = 'Record';
            //rsDocAction.rsdoc__Attach_File__c = true;
            //rsDocAction.rsdoc__Download_File__c = true;
            rsdocDocumeActionRequestList.add(rsDocAction);
            
        }
        try{
            if(rsdocDocumeActionRequestList.size()>0){
                insert rsdocDocumeActionRequestList;
            }
        }
        catch(Exception e){
            system.debug('--->'+e.getMessage());
        }
        
        return rsdocDocumeActionRequestList;
    }
    
    
    public static List<rsdoc__Document_Request__c> create_rsdocDocumeRequest(Integer numDocrequest,List<rsdoc__Document_Action__c> rsdocDocumeActionRequestList, List<Account> accList) {
        List<rsdoc__Document_Request__c> rsdocDocumeRequestList = new List<rsdoc__Document_Request__c>();
        
        for(integer i=0;i<numDocrequest;i++){
            rsdoc__Document_Request__c rsDoc = new rsdoc__Document_Request__c();
            rsDoc.rsdoc__Record_Id__c = accList[0].Id;
            rsDoc.rsdoc__Document_Action__c = rsdocDocumeActionRequestList[0].Id;
            rsDoc.rsdoc__Status__c = 'New';
            
            rsdocDocumeRequestList.add(rsDoc);
        } 
        if(rsdocDocumeRequestList.size()>0){
            insert rsdocDocumeRequestList;
        }
        
        return rsdocDocumeRequestList;
    }
    
    
    public static List<Attachment> createAttachments( Integer numberOfAttachmentsToInsert, String parentID){
        List<Attachment> attachments = new List<Attachment>();
        
        for(integer i=0;i<numberOfAttachmentsToInsert;i++){
            Attachment attach=new Attachment();     
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=parentID;
            
            attachments.add(attach);
        }
        
        if(attachments.size()>0){
            insert attachments;
        }
        
        return attachments;
    }
    
    public static List<AppSettings__c > createAppSettings(){
        OrgWideEmailAddress[] addresses = [SELECT Id,Address FROM OrgWideEmailAddress LIMIT 1];
        system.debug('addresses is '+ addresses);  
        System.assertEquals(1, addresses.size());   
        List<AppSettings__c> appSettings = new List<AppSettings__c> ();
        AppSettings__c app = new AppSettings__c();
        app.Name= 'OrgWideEmailAddressForSR';  
        app.TextValue__c  =addresses[0].Address;
        appSettings.add(app);
        
        if(appSettings.size()>0){
            insert appSettings;
        }
        
        return appSettings;
    }
    Public static void createEmailSales()
    {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        EmailMessageRelation emr = new EmailMessageRelation();
        List<EmailMessage> emailMessageList = TestDataFactory.createEmailMessage();
        List<Lead> leadList = new List<Lead>();
        email.subject = 'Test Property Applicant';
        email.fromname = 'FirstName LastName';
        env.fromAddress = 'someaddress@email.com';
        emr.RelationType='someaddress@cloudworks.ae';  
        emr.RelationId=leadList[0].Id;
        emr.EmailMessageId=emailMessageList[0].Id;
        EmailSalesLeads  emailInbound = new EmailSalesLeads();
        emailInbound.handleInboundEmail(email,env);
    }
    Public static void createEmailLeasing()
    {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        List<EmailMessage> emailMessageList = TestDataFactory.createEmailMessage();
        EmailMessageRelation emr = new EmailMessageRelation();
        List<Lead> leadList = new List<Lead>();
        email.subject = 'Test Property Applicant';
        email.fromname = 'FirstName LastName';
        env.fromAddress = 'someaddress@email.com';
        
        
        emr.RelationType='someaddress@cloudworks.ae';  
        //emr.RelationId=leadList[0].Id;
        emr.EmailMessageId=emailMessageList[0].Id;
        emr.Id=leadList[0].Id;
        EmailLeasingLeads  emailInbound = new EmailLeasingLeads();
        emailInbound.handleInboundEmail(email,env);
    }
    
    public static List<EmailMessage> createEmailMessage(){
        List<EmailMessage> EmailMessageList = new List<EmailMessage>();
        EmailMessage em = new EmailMessage();
        
        em.BccAddress='someaddress@cloudworks.ae';
        em.FromAddress='someaddress@cloudworks.ae';
        em.Status='3';
        em.FromName='Nakheel';
        em.TextBody='Welcome to nakheel';
        em.ToAddress='someaddress@cloudworks.ae';
        EmailMessageList.add(em);
        insert EmailMessageList;
        return EmailMessageList;
    }
    public static List<Lead> createLead(Integer numLeads){
        List<Lead> leadList = new List<Lead>();
        List<Campaign> camp = createCampaign(1);
        List<Campaign>  campaign = [SELECT id, Name, Campaign_Number__C FROM Campaign WHERE Name =:camp[0].Name];
        for(Integer i=0; i<numLeads; i++){
            Lead lead = new Lead();
            lead.FirstName = 'Test';
            lead.LastName = 'Lead'+ i;
            lead.Company = 'Nakheel';
            lead.Email = 'nakheel@gmail.com';
            lead.Description = 'This is email generated lead';
            lead.Interested_In__c = 'Residential Leasing';
            lead.SLA_Response_Time__c=system.today();
            Lead.LeadSource='Email';
            lead.Open_Task__c=false;
            lead.SLA_Expected_Time__c=system.today();
            lead.OwnerId = '0053M000000PEEqQAO';
            lead.Project__c='Garden';
            lead.Project_Code__c='2';
            
            Integer y= Math.mod(i, 2);
            if(y==0)
            {
                lead.Campaign__c = camp[0].id;
            }
            else
            {
                lead.Campaign_Name__c = camp[0].Name;
            }
            lead.Follow_Up_Done__c=true;
            leadList.add(lead);
        }
        if(!leadList.isEmpty()){
            insert leadList;
        }
        return leadList;
    }
    public static List< Lease_Contract__c> createContract(integer numContract){
        List<Lease_Contract__c> Listcontr = new List<Lease_Contract__c>();
        for(Integer i=0; i<numContract; i++){
            Lease_Contract__c contr = new Lease_Contract__c();
            contr.Contract_Number__c = '0000';
            contr.Contract_Stages__c='Expired';
            contr.Contract_Start__c= system.today();
            Listcontr.add(contr);
            
        }
        if(!Listcontr.isEmpty()){
            insert Listcontr;
        }
        return Listcontr;
        
    }
    
    public static List<Campaign> createCampaign(integer numCampaigns){
        List<Campaign> campaignList = new List<Campaign>();
        for(Integer i=0; i<numCampaigns; i++){
            Campaign campaign = new Campaign();
            campaign.Name =  'Test Campaign'+i;
            campaignList.add(campaign);
        }
        if(!campaignList.isEmpty()){
            insert campaignList;
        }
        return campaignList;
    }
    
    public static List<Task> createTask(integer numTasks,Id whoId){
        list<Task> tasklist = new list<Task>();
        for(Integer i=0; i<numTasks; i++){
            Task t = new Task();
            t.Status='Completed';
            t.WhoId= whoId;
            
            
            t.Parent_Flag_API_Name__c='Follow_Up_Done__c';
            tasklist.add(t);
        }
        if(!tasklist.isEmpty()){
            insert tasklist;
        }
        return tasklist;         
        
    }
    public static List<campaignMember> CreateCampMember(){
        List<Lead> leadList = createLead(2);
        List<Campaign> camp = createCampaign(1);
        List<CampaignMember> camMemberList = New List<CampaignMember>();
        for(Lead l: leadList){
            CampaignMember campMem = new CampaignMember();
            campMem.LeadId = l.id;
            campMem.CampaignId = camp[0].Id;
            camMemberList.add(campMem);
        }
        return camMemberList; 
    }
    
    public static List<Master_Document__c>  createMasterDoc(Integer numMasterDoc,list<string>docNameList){
        list<Master_Document__c> docConfigList= new list<Master_Document__c>();
        for(Integer i=0; i<numMasterDoc; i++){
            Master_Document__c doc = new Master_Document__c();
            doc.name=docNameList[i];
            docConfigList.add(doc);
        }
        if(!docConfigList.isEmpty()){
            insert docConfigList;
        }
        return docConfigList; 
        
    }
    
    public static List<Document_Configuration__c> createDocConf(Integer numDocConfg,Boolean Linked_with_Account,String soBjectName,String recordType,List<Document__c> docList,String fieldApiname,String fieldval,String checkBoxFieldApi,Master_Document__c masterDoc){
        list<Document_Configuration__c> docConfigList= new list<Document_Configuration__c>();
        for(Integer i=0; i<numDocConfg; i++){
            Document_Configuration__c docConfg = new Document_Configuration__c();
            docConfg.Object__c=soBjectName;
            docConfg.Object_RecordType__c= recordType;
            docConfg.Issue_Date_Mandatory__c=true;
            docConfg.Expiry_Date_Mandatory__c=true;
            docConfg.Object_Status_Field_API_Name__c=fieldApiname;
            docConfg.Object_Status_Field_Value__c=fieldval;
            docConfg.IsRequired__c = true;
            docConfg.Checkbox_Field_API_Name__c = checkBoxFieldApi;
            docConfg.Master_Document__c = masterDoc.Id;
            docConfg.Linked_with_Account__c = Linked_with_Account;
            docConfigList.add(docConfg);
        }
        if(!docConfigList.isEmpty()){
            insert docConfigList;
        }
        return docConfigList; 
    }
    
    /** 
* @createdDate : 22 Dec 2021  
* @author : Muhammad Moneeb
* @Version : V1.1
* @usage : This function create Opportunity with respect to record Type.
**/
    public static List<Opportunity> createOpportunitiesWithRecordType(Integer numOpps, List<Account> accList,String recordTypeName) {
        List<Opportunity> oppList = new List<Opportunity>();
        recordtype recrdTypeobj=[select id ,name from recordtype where name=:recordTypeName];
        for(integer i=0;i<numOpps;i++){
            Opportunity opp = new Opportunity();
            opp.Name='Test-Opp'+i;
            opp.AccountId=accList[i].Id;
            opp.StageName = 'New';
            opp.CloseDate = System.today();
            opp.RecordTYpeId=recrdTypeobj.id;
            oppList.add(opp);
        } 
        if(oppList.size()>0){
            insert oppList;
        }
        return oppList;
    }
    
    
    /** 
* @createdDate : 22 Dec 2021  
* @author : Muhammad Moneeb
* @Version : V1.1
* @usage : This function create Account with respect to record Type.
**/
    public static List<Account> createAccountWithRecordType(Integer numAccounts, String recordTypeName) {
        recordtype recrdTypeobj=[select id ,name from recordtype  where name=:recordTypeName ];
        List<Account> accList = new List<Account>();
        for(integer i=0;i<numAccounts;i++){
            Account acc = new Account();
            acc.lastName='Test-Account'+i;
            acc.Primary_Email__c='testaccount1@gmail.com';
            acc.recordTypeId=recrdTypeobj.id;
            accList.add(acc);
        } 
        if(accList.size()>0){
            insert accList;
        }
        return accList;
    }
    
    /** 
* @createdDate : 26 Dec 2021  
* @author : Muhammad Moneeb
* @Version : V1.1
* @usage : This function create contentVersions and contentDocumentLink data with respect to opportunity.
**/
    public static List<ContentVersion> createcontentVersionsWithDocument(Opportunity opp){
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        contentVersions.add(contentVersion);
        if(contentVersions.size()>0){
            insert contentVersions;
        }
        Quote Q = New Quote(Name='Test Quote', OpportunityId=opp.Id);
        insert Q;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=q.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =:contentVersions[0].Id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        contentlink.LinkedEntityId = opp.Id;
        insert contentlink;
        return contentVersions;
    }
    
    /** 
* @createdDate : 25 Dec 2021  
* @author : Muhammad Moneeb
* @Version : V1.1
* @usage : This function create case data.
**/
    public static List<case> createCase(Integer numOpps) {
        List<Case> caseList = new List<Case>();
        for(integer i=0;i<numOpps;i++){
            Case cs = new Case();
            cs.status = 'New';
            caseList.add(cs);
        } 
        if(caseList.size()>0){
            insert caseList;
        }
        return caseList;
    }
    /** 
* @createdDate : 28 Dec 2021  
* @author : Muhammad Moneeb
* @Version : V1.1
* @usage : This function create Document__c data with file attach
**/
    public static List<Document__c> createDocumentList(List<ContentVersion> contentVersions, String oppId,String caseId){
        List<Document__c> documents = new List<Document__c> ();
        for(integer i=0;i<contentVersions.size();i++){
            Document__c doc = new Document__c();
            doc.Document_Type__c  ='Test'+i;
            doc.Attachment_Id__c = contentVersions[i].id;
            
            documents.add(doc);
        }
        if(documents.size()>0){
            insert documents;
        }
        return documents;
    }
    
    public static List<Opportunity> createOpportunity(Integer numOpps) {
        List<Opportunity> oppList = new List<Opportunity>();
        //Account acc = new Account();
        //acc.Name='Nakheel';
        //insert acc;
        for(integer i=0;i<numOpps;i++){
            Opportunity opp = new Opportunity();
            opp.Name='Test-Opp'+i;
            opp.StageName = 'Contract Generation';
            opp.PDC_Captured__c=true;
            opp.Unit_Status__c='Assigned';
            opp.Booking_Fee_gets_collected__c=true;
            opp.Booking_Mode__c='Reservation with token amount';
            opp.Booking_Amount__c=5000;
            opp.StageName = 'New';
            opp.CloseDate = System.today();
            opp.Interested_In__c='Residential Leasing';
            opp.Leasing_Type__c='Residential Units';
            opp.Booking_Reservation_Date__c=system.today();
            //opp.AccountId=acc.Id;
            opp.Grace_Period_Days__c = 2;
            opp.Lease_Start_Date__c = system.today();
            opp.Lease_End_Date__c = system.today()+5;
            opp.Time_to_Close_Quick_Book__c = system.today()+5;
            
            
            system.debug('Opp' +opp);
            oppList.add(opp);
        } 
        if(oppList.size()>0){
            insert oppList;
            system.debug('list' +oppList);
        }
        return oppList;
    }
    /*Added by Gaurav*/
    public static List<Sales_Event__c> createSalesEvent(){
        List<Sales_Event__c> salesEventList = new List<Sales_Event__c>();
        Sales_Event__c salesEvent = new Sales_Event__c();
        salesEvent.Name = 'Test Sales Event';
        salesEvent.Start_Date__c = system.today();
        salesEvent.Status__c = 'Inactive';
        salesEventList.add(salesEvent);
        insert salesEventList;
        return salesEventList;
    }
    
    /*Added by Gaurav*/
    public static List<Sales_Event_Executive__c> createSalesEventExecutives(String salesEventId){
        List<Sales_Event_Executive__c> salesEventExecList = new List<Sales_Event_Executive__c>();
        Sales_Event_Executive__c salesEventExec = new Sales_Event_Executive__c();
        salesEventExec.Name = 'Test Sales Exec';
        salesEventExec.Start_Date__c = system.today();
        salesEventExec.Sales_Event__c = salesEventId;
        salesEventExecList.add(salesEventExec);
        
        Sales_Event_Executive__c salesEventExec2 = new Sales_Event_Executive__c();
        salesEventExec2.Name = 'Test Sales Exec';
        salesEventExec2.Start_Date__c = system.today()-2;
        salesEventExec2.End_Date__c = system.today()-1;
        salesEventExec2.Sales_Event__c = salesEventId;
        salesEventExecList.add(salesEventExec2);
        Sales_Event_Executive__c salesEventExec3 = new Sales_Event_Executive__c();
        salesEventExec3.Name = 'Test Sales Exec';
        salesEventExec3.Start_Date__c = system.today()-2;
        salesEventExec3.End_Date__c = system.today()-1;
        salesEventExec3.Sales_Event__c = salesEventId;
        salesEventExecList.add(salesEventExec3);
        Sales_Event_Executive__c salesEventExec4 = new Sales_Event_Executive__c();
        salesEventExec4.Name = 'Test Sales Exec';
        salesEventExec4.Start_Date__c = system.today()-2;
        salesEventExec4.End_Date__c = system.today()-1;
        salesEventExec4.Sales_Event__c = salesEventId;
        salesEventExecList.add(salesEventExec4);
        
        insert salesEventExecList;
        return salesEventExecList;
    }
    
    public static List<Sales_Event_Unit__c> createSalesEventUnit(String salesEventId, String unitId){
        List<Sales_Event_Unit__c> salesEventUnitList = new List<Sales_Event_Unit__c>();
        Sales_Event_Unit__c salesEventUnit = new Sales_Event_Unit__c();
        salesEventUnit.Unit__c = unitId;
        salesEventUnit.Sales_Event__c = salesEventId;
        salesEventUnitList.add(salesEventUnit);
        insert salesEventUnitList;
        return salesEventUnitList;
    }
    
    /*Added by Gaurav*/
    public static List<Unit__c> createUnit(){
        List<Project__c> projectList = TestDataFactory.createProject();
        List<Floor__c> floorList = TestDataFactory.createFloor();
        List<Space_Type__c> spaceTypeList = TestDataFactory.createSpaceType();
        List<Building__c> buildingList= TestDataFactory.createBuilding();
        List<Unit__c> unitList = new List<Unit__c>();
        Unit__c unit = New Unit__c();
        unit.Name = 'Test Unit 1';
        unit.Unit_Code__c = 'Unit Code';
        unit.Date_when_Leasing_status_changes__c = system.today();
        unit.Unit_Status__c = 'Pre-Booking';
        unit.Floor__c = floorList[0].Id;
        unit.Project__c = projectList[0].Id;
        unit.Space_Types__c = spaceTypeList[0].Id;
        unit.Building__c = buildingList[0].Id;
        unit.Unit_Alias__c = 'Test 1';
        unit.Unit_type__c = 'Building';
        unit.No_of_Bedrooms__c = '2';
        unit.Current_Rent__c = 10000;
        unitList.add(unit);
        
        
        Unit__c unit2 = New Unit__c();
        unit2.Name = 'Test Unit 2';
        unit2.Date_when_Leasing_status_changes__c = system.today();
        unit2.Unit_Status__c = 'Available';
        unit2.Floor__c = floorList[0].Id;
        unit2.Project__c = projectList[0].Id;
        unit2.Space_Types__c = spaceTypeList[0].Id;
        unit2.Unit_Alias__c = 'Test 2';
        unit2.Unit_type__c = 'Apartment';
        unit2.No_of_Bedrooms__c = '2';
        unit2.Current_Rent__c = 10000;
        unitList.add(unit2);
        
        Unit__c unit3 = New Unit__c();
        unit3.Name = 'Test Unit 3';
        unit3.Date_when_Leasing_status_changes__c = system.today();
        unit3.Unit_Status__c = 'Reserved';
        unit3.Floor__c = floorList[0].Id;
        unit3.Project__c = projectList[0].Id;
        unit3.Space_Types__c = spaceTypeList[0].Id;
        unit3.Unit_Alias__c = 'Test 3';
        unit3.Unit_type__c = 'Apartment';
        unit3.No_of_Bedrooms__c = '2';
        unit3.Current_Rent__c = 10000;
        unitList.add(unit3);
        
        Unit__c unit4 = New Unit__c();
        unit4.Name = 'Test Unit 4';
        unit4.Date_when_Leasing_status_changes__c = system.today();
        unit4.Unit_Status__c = 'Booked';
        unit4.Floor__c = floorList[0].Id;
        unit4.Project__c = projectList[0].Id;
        unit4.Space_Types__c = spaceTypeList[0].Id;
        unit4.Unit_Alias__c = 'Test 4';
        unit4.Unit_type__c = 'Apartment';
        unit4.No_of_Bedrooms__c = '2';
        unit4.Current_Rent__c = 10000;
        unitList.add(unit4);
        
        Unit__c unit5 = New Unit__c();
        unit5.Name = 'Test Unit 5';
        unit5.Date_when_Leasing_status_changes__c = system.today();
        unit5.Unit_Status__c = 'Sold';
        unit5.Floor__c = floorList[0].Id;
        unit5.Project__c = projectList[0].Id;
        unit5.Space_Types__c = spaceTypeList[0].Id;
        unit5.Unit_Alias__c = 'Test 5';
        unit5.Unit_type__c = 'Apartment';
        unit5.No_of_Bedrooms__c = '2';
        unit5.Current_Rent__c = 10000;
        unitList.add(unit5);
        
        Unit__c unit6 = New Unit__c();
        unit6.Name = 'Test Unit 6';
        unit6.Date_when_Leasing_status_changes__c = system.today();
        unit6.Unit_Status__c = 'Blocked';
        unit6.Floor__c = floorList[0].Id;
        unit6.Project__c = projectList[0].Id;
        unit6.Space_Types__c = spaceTypeList[0].Id;
        unit6.Unit_Alias__c = 'Test 6';
        unit6.Unit_type__c = 'Apartment';
        unit6.No_of_Bedrooms__c = '2';
        unit6.Current_Rent__c = 10000;
        unitList.add(unit6);
        
        insert unitList;
        return unitList;
    }
    
    public static List<Floor__c> createFloor(){
        List<Floor__c> floorList = new List<Floor__c>();
        Floor__c fl = new Floor__c();
        fl.Name = 'Test Floor 1';
        fl.Leased_Units__c = 3;
        fl.Available_Units__c = 8;
        fl.Sold_Units__c = 1;
        fl.Reserved_Units__c = 2;
        fl.Booked_Units__c = 3;
        fl.Total_Units__c = 8;
        fl.Floor_Code__c = 'FL';
        floorList.add(fl);
        insert floorList;
        return floorList;
    }
    
    public static List<Floor__c> createnewFloor(){
        List<Floor__c> floorList = new List<Floor__c>();
        List<Building__c> buildingList= TestDataFactory.createBuilding();
        Floor__c fl = new Floor__c();
        fl.Name = 'Test Floor 1';
        fl.Leased_Units__c = 3;
        fl.Available_Units__c = 8;
        fl.Sold_Units__c = 1;
        fl.Reserved_Units__c = 2;
        fl.Booked_Units__c = 3;
        fl.Total_Units__c = 8;
        fl.Building__c = buildingList[0].id;
        floorList.add(fl);
        insert floorList;
        return floorList;
    }
    
    public static List<Space_Type__c> createSpaceType(){
        List<Space_Type__c> spaceTypeList = new List<Space_Type__c>();
        Space_Type__c spaceType = new Space_Type__c();
        spaceType.Name = 'Test Space Type 1';
        spaceTypeList.add(spaceType);
        insert spaceTypeList;
        return spaceTypeList;
    }
    
    public static List<Project__c> createProject(){
        List<Business_Unit__c> businessUnitList = TestDataFactory.createBusinessUnit();
        
        List<Project__c> projectList = new List<Project__c>();
        Project__c project = New Project__c();
        project.Business_Unit__c = businessUnitList[0].Id;
        project.Name = 'Test Project 1';
        //project.Project_Type__c = 'New';
        project.Project_Purpose__c = 'Leasing';
        projectList.add(project);
        insert projectList;
        return projectList;
    }
    
    public static List<Business_Unit__c> createBusinessUnit(){
        List<Business_Unit__c> businessUnitList = new List<Business_Unit__c>();
        Business_Unit__c businessUnit = new Business_Unit__c();
        businessUnit.Name = 'Gardens Portfolio';
        businessUnitList.add(businessUnit);
        insert businessUnitList;
        return businessUnitList;
    }
    	
        public static List<Business_Group__c> createBusinessGroup(){
        List<Business_Group__c> businessGroupList = new List<Business_Group__c>();
        Business_Group__c businessGroup = new Business_Group__c();
        businessGroup.Name = 'Nakheel';
        businessGroupList.add(businessGroup);
        insert businessGroupList;
        return businessGroupList;
    }
    public static List<Additional_Charges__c> createAdditionalCharge(Boolean isInsert){
        List<Additional_Charges__c> chargeList = new List<Additional_Charges__c>();
        Additional_Charges__c charge = new Additional_Charges__c();
        charge.Name = 'Test Charge 1';
        charge.VAT__c = 5;
        charge.VAT_Amount__c = 34342;
        charge.VAT_Code__c = 'TX';
        chargeList.add(charge);
        if(isInsert){
            insert chargeList;
        }
        return chargeList;
    }
    /*Added by Rahul Shukla*/
    public static List<Leave_Request__c> createLeaveRequest(String SalesResource){
        List<Leave_Request__c> leaveRequestList = new List<Leave_Request__c>();
        Leave_Request__c leaverequest = new Leave_Request__c();
        leaverequest.Leave_Start_Date__c=system.today();
        leaverequest.Leave_End_Date__c= system.today();
        leaverequest.Status__c='Approved';
        leaverequest.Sales_Resource__c = SalesResource;
        leaveRequestList.add(leaverequest);
        insert leaveRequestList;
        return leaveRequestList;
    }
    
    public static List<special_offer_Item__c> createSpecialOfferItem(String unitId){
        List<special_offer_Item__c> specialOfferItemList = new List<special_offer_Item__c>();
        
        
        Special_Offer__c specialOffer = new Special_Offer__c();
        specialOffer.Name = 'Test';
        specialOffer.Type__c = 'DLD';
        specialOffer.end_date__c = system.today()+4;
        specialOffer.start_date__c = system.today()+2;
        specialOffer.Active__c = true;
        
        insert specialOffer;
        
        special_offer_Item__c specialOfferItem = new special_offer_Item__c();
        specialOfferItem.unit__c = unitId;
        
        specialOfferItem.special_offer__c = specialOffer.Id;
        specialOfferItemList.add(specialOfferItem);
        
        insert specialOfferItemList;
        
        return specialOfferItemList;
    }
    
    /*Added by Rahul Shukla. String oppList*/
    public static List<Payment_Milestone__c> createPaymentMilestone(){
        List<Payment_Milestone__c> paymentmilestoneList = new List<Payment_Milestone__c>();
        List<Master_Payment_Milestone__c> mastermilestoneList= TestDataFactory.createmastermilestone();
        Payment_Milestone__c paymentmilestone = new Payment_Milestone__c();
        List<Master_Payment_Plan__c> masterpaymentplanList = TestDataFactory.createmasterPaymentplan();
        paymentmilestone.CurrencyIsoCode = 'AED';
        Paymentmilestone.Master_Payment_Plan__c = masterpaymentplanList[0].Id;
        paymentmilestone.Name='Test Payment';
        paymentmilestone.Due_Date__c=system.today();
        paymentmilestone.Master_Payment_Plan__c= masterpaymentplanList[0].Id;      
        paymentmilestone.Due_In_Days__c=10;
        paymentmilestone.Amount__c=2000;
        paymentmilestone.Amount_Percentage__c= 20;
        paymentmilestone.Milestone_Trigger_Point__c='Immediate';
        paymentmilestone.Installment__c='15th Installment';
        paymentmilestoneList.add(paymentmilestone);
        insert paymentmilestoneList;
        return paymentmilestoneList;
    }
    /*Added by Rahul Shukla*/
    public static List<Master_Amenity__c> createMasterAmenity(){
        List<Master_Amenity__c> masterAmenityList = new List<Master_Amenity__c>();
        Master_Amenity__c masterAmenity = new Master_Amenity__c();
        masterAmenity.Name=' Test Master Amenity';
        masterAmenityList.add(masterAmenity);
        insert masterAmenityList;
        return masterAmenityList;
    }
    /*Added by Rahul Shukla*/
    public static List<special_offer__c> createSpecialOffer(){
        List<special_offer__c> specialOfferList = new List<special_offer__c>();  
        Special_Offer__c specialOffer = new Special_Offer__c();
        specialOffer.Name = 'Test';
        specialOffer.Type__c = 'DLD';
        specialOffer.end_date__c = system.today()+4;
        specialOffer.start_date__c = system.today()+2;
        specialOffer.Active__c = true;
        specialOfferList.add(specialOffer);
        insert specialOfferList;
        return specialOfferList;
        
    }
    /*Added by Rahul Shukla*/
    public static List<Master_Option__c> createMasterOption(){
        List<Master_Option__c> masterOptionList = new List<Master_Option__c>();
        Master_Option__c masteroption= new Master_Option__c();
        masteroption.Name= 'Master Test';
        masteroption.Type__c='TBD';
        masteroption.Option_Id__c='2';
        masterOptionList.add(masteroption);
        insert masterOptionList;
        return masterOptionList;
    }
    /*Added by Rahul Shukla*/
    public static List<Price_Book__c> createPriceBook(){
        
        List<Project__c> ProjectList = TestDataFactory.createProject();
        List<Price_Book__c> priceBookList = new List<Price_Book__c>();
        Price_Book__c  priceBook= new Price_Book__c();
        priceBook.Type__c='Sales';
        priceBook.Approval_Status__c='Pending';
        priceBook.Name='Test PriceBook';
        PriceBook.Project__c= ProjectList[0].id;
        PriceBook.Is_Available__c = true;
        
        priceBookList.add(priceBook);
        insert priceBookList;
        return priceBookList;
    }
    /*Added by Rahul Shukla*/
    public static List<Building__c> createBuilding(){
       List<Cluster__c> ClusterList = TestDataFactory.createcluster();
        List<Project__c> ProjectList = TestDataFactory.createProject();
        List<Business_Unit__c> businessUnitList = TestDataFactory.createBusinessUnit(); 
        List<Building__c> buildingList = new List<Building__c>();
        Building__c build = New Building__c();
        build.Name ='Building 1';
        build.Cluster__c = ClusterList[0].id;
        build.Business_Unit__c =  businessUnitList[0].id;
        build.Project__c = ProjectList[0].id;
        build.Building_Purpose__c = 'Sales';
        build.No_of_Floors__c = 15;
        build.Leased_Units__c = 3;
        build.Available_Units__c = 8;
        build.Sold_Units__c = 1;
        build.Reserved_Units__c = 2;
        build.Booked_Units__c = 3;
       // build.Total_Units__c = 8;
        buildingList.add(build);
        insert buildingList;
        return buildingList;
    }
    
    /*Added by Rahul Shukla*/
    public static List<Building__c> createnewBuilding(string Cluster,string project){
      //  List<Cluster__c> ClusterList = TestDataFactory.createcluster();
        
        List<Building__c> buildingList = new List<Building__c>();
        Building__c b = New Building__c();
        b.Name ='A3';
       // building.Cluster__c = ClusterList[0].id;
       b.Project__c= project;
        b.No_of_Floors__c = 3;
        b.No_of_Floors__c = 15;
        b.Leased_Units__c = 3;
        b.Available_Units__c = 8;
        b.Sold_Units__c = 1;
        b.Reserved_Units__c = 2;
        b.Booked_Units__c = 3;
        b.Cluster__c = cluster;
        buildingList.add(b);
        insert buildingList;
        return buildingList;
    }
    /*Added by Rahul Shukla*/
    public static List<Cluster__c> createcluster(){
        List<Cluster__c> clusterList = new List<Cluster__c>();
        List<Project__c> ProjectList = TestDataFactory.createProject();
        Cluster__c clust = New Cluster__c();
        clust.Name = 'Gardens Furnished Apartments';
        clust.Project__c = ProjectList[0].id;
        clusterList.add(clust);
        insert clusterList;
        return clusterList;
    }
      /*Added by Rahul Shukla*/
    public static List<Cluster__c> createnewcluster(String project){
        List<Cluster__c> clusterList = new List<Cluster__c>();
        //List<Project__c> ProjectList = TestDataFactory.createProject();
        Cluster__c clust = New Cluster__c();
        clust.Name = 'AL Furjan Phase 1';
        clust.Project__c = project;
        clusterList.add(clust);
        insert clusterList;
        return clusterList;
    }
    /*Added by Rahul Shukla*/
    public static List<Master_Payment_Plan__c> createmasterPaymentplan(){
        List<Master_Payment_Plan__c> masterpaymentplanList = new List<Master_Payment_Plan__c>();
        
        Master_Payment_Plan__c masterpaymentplan = new Master_Payment_Plan__c();
        masterpaymentplan.Name = 'AL-FURJAN-2022PLAN';
        masterpaymentplan.Status__c='Inactive';
        masterpaymentplan.Line_Of_Business__c = 'Sales';
        masterpaymentplan.Type__c ='Time based';
        masterpaymentplanList.add(masterpaymentplan);
        insert masterpaymentplanList;
        return masterpaymentplanList;
    }
    /*Added by Rahul Shukla*/
    public static List<Original_Milestone__c> createoriginalmilestone(){
        List<Original_Milestone__c> originalmilestoneList = new List<Original_Milestone__c>();
        List<Opportunity> oppList = TestDataFactory.createOpportunity(1);
        List<Master_Payment_Plan__c> masterpaymentplanlist=TestDataFactory.createmasterPaymentplan();
        Original_Milestone__c originalmilestone = new Original_Milestone__c();
        originalmilestone.Name = 'Original Milestone Name';
        originalmilestone.Due_Date__c = system.today();
        originalmilestone.Due_In_Days__c=3;
        originalmilestone.Milestone_Trigger_Point__c = 'Immediate';
        originalmilestone.Master_Payment_Plan__c = masterpaymentplanlist[0].Id;
        originalmilestone.Amount__c =2000;
        originalmilestone.Amount_Percentage__c= 20;
        originalmilestone.Opportunity__c = oppList[0].Id;
        originalmilestone.Installment__c ='15th Installment';
        originalmilestoneList.add(originalmilestone);
        insert originalmilestoneList;
        return originalmilestoneList;
    }
    
    /*Added by Rahul Shukla*/
    public static List<Original_Milestone__c> createoriginalmilestoneNew(String oppList){
        List<Original_Milestone__c> originalmilestoneList = new List<Original_Milestone__c>();
        //List<Opportunity> oppList = TestDataFactory.createOpportunity(1);
        List<Master_Payment_Plan__c> masterpaymentplanlist=TestDataFactory.createmasterPaymentplan();
        Original_Milestone__c originalmilestone = new Original_Milestone__c();
        originalmilestone.Name = 'Original Milestone Name';
        originalmilestone.Due_Date__c = system.today();
        originalmilestone.Due_In_Days__c=3;
        originalmilestone.Milestone_Trigger_Point__c = 'Immediate';
        originalmilestone.Master_Payment_Plan__c = masterpaymentplanlist[0].Id;
        originalmilestone.Amount__c =2000;
        originalmilestone.Amount_Percentage__c= 20;
        originalmilestone.Opportunity__c = oppList;
        originalmilestone.Installment__c ='15th Installment';
        originalmilestoneList.add(originalmilestone);
        insert originalmilestoneList;
        return originalmilestoneList;
    }
    
    /*Added by Rahul Shukla*/
    public static List<Master_Payment_Milestone__c> createmastermilestone(){
        List<Master_Payment_Milestone__c>mastermilestoneList = new List<Master_Payment_Milestone__c>();
        List<Master_Payment_Plan__c> masterpaymentplanlist=TestDataFactory.createmasterPaymentplan();
        Master_Payment_Milestone__c mastermilestone = new Master_Payment_Milestone__c();
        mastermilestone.Master_Payment_Plan__c= masterpaymentplanlist[0].Id;
        mastermilestone.Due_In_Days__c= 3;
        mastermilestone.Installment__c='15th Installment';
        mastermilestoneList.add(mastermilestone);
        insert mastermilestoneList;
        return mastermilestoneList;
    }
        /*Added by Rahul Shukla*/
    public static List<Approval__c> createapproval(){
        List<Approval__c> approvalList = new List<Approval__c>();
        
        Approval__c approval = new Approval__c();
        approval.Approval_Status__c = 'Pending';
        approval.Approval_Type__c ='Inventory Onboarding';
        approval.Line_of_Business__c = 'Direct Sales';
        approvalList.add(approval);
        insert approvalList;
        return approvalList;
    }
        /*Added by Rahul Shukla*/
    public static List<Approval_Line_Item__c> createApprovalLineList(String ApprovalList){
        List<Approval_Line_Item__c> approvalLineList = new List<Approval_Line_Item__c>();
        Approval_Line_Item__c approvalLine = new Approval_Line_Item__c();
        approvalLine.Approval__c = ApprovalList;
        approvalLineList.add(approvalLine);
        insert approvalLineList;
        return approvalLineList;
    }    
     
    /*Added by Rahul Shukla*/
    public static List<Payment_Milestone__c> createOppPaymentMilestone(){
        List<Payment_Milestone__c> OppPaymentMilestoneList = new List<Payment_Milestone__c>();
        Payment_Milestone__c OppPaymentMilestone = new Payment_Milestone__c();
        OppPaymentMilestone.Amount__c = 2000;
        OppPaymentMilestone.Amount__c= 1000;
        OppPaymentMilestone.Due_Date__c = system.today();
        OppPaymentMilestone.Name = 'Test Opp Milestone';
       // OppPaymentMilestone.Installment_Number__c=3;
        OppPaymentMilestoneList.add(OppPaymentMilestone);
        insert OppPaymentMilestoneList;
        return OppPaymentMilestoneList;
    }    
    /** 
       	* @createdDate : 26 Jan 2022  
		* @author : Muhammad Moneeb
		* @Version : V1.2
		* @usage : This function create Unit__c object data.
	**/
    public static Unit__c createUnitRecord(){
        Unit__c u1 = new Unit__c();
        u1.Name = 'Test Unit 1';
        u1.Remarks__c = 'Testing 1';
        insert u1;
        return u1;
    }
    
    /** 
       	* @createdDate : 17 March 2022  
		* @author : Ashok Kumar Nayak
		* @Version : V1
		* @usage : This function create Master_Option__c object data.
	**/
    public static List<Master_Option__c> createBulkMasterOption(Map<String,Integer> typeAndNumOfRecordsToCreateMap, Boolean performDML){
        
        List<Master_Option__c> masterOptionList = new List<Master_Option__c>();
        Integer lastSequenceOrder = 0;
        if(!typeAndNumOfRecordsToCreateMap.isEmpty()) {
            for(String masterOptionType : typeAndNumOfRecordsToCreateMap.keySet()){
                if(masterOptionType == 'Free') {
                    lastSequenceOrder = typeAndNumOfRecordsToCreateMap.get(masterOptionType) + 1;
                    for(Integer i=0;i<typeAndNumOfRecordsToCreateMap.get(masterOptionType);i++){
                        Master_Option__c masteroption = new Master_Option__c();
                        masteroption.Name = 'Master Test Data -'+masterOptionType+'-'+i;
                        masteroption.Type__c = masterOptionType;
                        masteroption.Is_Active__c = true;
                        masteroption.Sequence_Order__c = i+1;
                        masteroption.Additional_Area_Required__c = false;
                        masterOptionList.add(masteroption);
                    }
                }
                if(masterOptionType == 'Paid') {
                    for(Integer i=0;i<typeAndNumOfRecordsToCreateMap.get(masterOptionType);i++){
                        Master_Option__c masteroption = new Master_Option__c();
                        masteroption.Name = 'Master Test Data -'+masterOptionType+'-'+i;
                        masteroption.Type__c = masterOptionType;
                        masteroption.Is_Active__c = true;
                        masteroption.Sequence_Order__c = lastSequenceOrder + i;
                        masteroption.Additional_Area_Required__c = true;
                        masterOptionList.add(masteroption);
                    }
                }
            }
        }
        if(performDML && masterOptionList.size() > 0) {
            insert masterOptionList;
        }       
        return masterOptionList;
    }
    
     /** 
       	* @createdDate : 5 April 2022  
		* @author : Kshitij Tiwari
		* @Version : V1.2
		* @usage : This function create Availabe_Payment_Plan__c object data.
	**/
    public static List<Availabe_Payment_Plan__c> createAvaiPaymentRecord(){
        List<Availabe_Payment_Plan__c> availPaymentList1 = new List<Availabe_Payment_Plan__c>();
        List<Project__c> projectList = TestDataFactory.createProject();
        List<Space_Type__c> spaceTypeList = TestDataFactory.createSpaceType();
        List<Unit__c> UnittList = TestDataFactory.createUnit();
         for (Space_Type__c s:spaceTypeList){
            s.Purpose__c = 'Leasing';
            
        }
        update spaceTypeList;
        for(unit__c u :UnittList)
        {
            u.Unit_Leasing_Type__c =spaceTypeList[0].id;
            u.Project__c = projectList[0].id;
            
        }
        update UnittList;
        Availabe_Payment_Plan__c ap1 = new Availabe_Payment_Plan__c();
        ap1.Project__c = projectList[0].Id;
        ap1.Space_Type__c = spaceTypeList[0].Id;
        ap1.Base_Lease_Amount__c =100;
        ap1.Price_per_sqft__c = 500;
      	availPaymentList1.add(ap1);
        insert availPaymentList1;
        return availPaymentList1;
    }
     /** 
       	* @createdDate : 5 April 2022  
		* @author : Kshitij Tiwari 
		* @Version : V1.2
		* @usage : This function create Rent__c object data.
	**/
    public static List<Rent__c> createRentRecord(){
        List<Availabe_Payment_Plan__c> availPaymentList= TestDataFactory.createAvaiPaymentRecord();
        List<Rent__c> rentList1 = new List<Rent__c>();
        Rent__c r1 = new Rent__c();
        r1.Availabe_Payment_Plan__c = availPaymentList[0].id;
        r1.Active__c = False;
        r1.Is_Processed__c =False;
        r1.Approval_Status__c ='Approved';
        r1.Start_Date__c = system.today();
      	rentList1.add(r1); insert rentList1;
        return rentList1;
    }
}