/**************************************************************************************************
* Name               : AgreementTriggerHandler                                                      
* Description        : Handler class for Agreement Trigger
* Created Date       : 31/01/2022                                                                 
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     31/01/2022      Initial Draft.                                               
**************************************************************************************************/
public class AgreementTriggerHandler {
    List<Agreement__c> recordNewList = new List<Agreement__c>();
    List<Agreement__c> recordOldList = new List<Agreement__c>();
    Map<Id, Agreement__c> recordNewMap = new Map<Id, Agreement__c>();
    Map<Id, Agreement__c> recordOldMap = new Map<Id, Agreement__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = false;
    
    public AgreementTriggerHandler( List<Agreement__c> newList, 
                                   List<Agreement__c> oldList, 
                                   Map<Id, Agreement__c> newMap, 
                                   Map<Id, Agreement__c> oldMap, 
                                   boolean isInsert, 
                                   boolean isUpdate, 
                                   Boolean isDelete, 
                                   Boolean isUndelete, 
                                   Boolean isBefore, 
                                   Boolean isAfter){
                                       this.recordNewList = newList;
                                       this.recordOldList = oldList;
                                       this.recordNewMap = newMap;
                                       this.recordOldMap = oldMap;
                                       this.isInsert = isInsert;
                                       this.isUpdate = isUpdate;
                                       this.isDelete = isDelete;
                                       this.isUndelete = isUndelete;
                                       this.isBefore = isBefore;
                                       this.isAfter = isAfter;        
                                   }
    
    public void AfterInsertEvent() {
        GenericTriggerHandler.createDocRecord(recordNewList,'Agreement__c'); //Generated Documents
        createDocVerificationTask();  // Task for Sales Admin
        updateAgreementLookupOnDeal(recordNewList);
        attachJointOwnertoAgreement(recordNewList);
        attachMilestonetoAgreement(recordNewList);
        erpSOCreation();
        updateAgreementLookupOnUnit(recordNewList);//Added by Mamta
    }
    public void AfterUpdateEvent() {
        dataFlowFromSpaToDeal();
        agreementAfterUpdateOperation();
        markUnitSold();
        createRegistration();
        terminateAgreementERP();
        attachJointOwnertoAgreement(recordNewList);
        attachMilestonetoAgreement(recordNewList);
                List<Agreement__c> agList = new List<Agreement__c>();
        for(Agreement__c ag : recordNewList){
            if(ag.Received_Customer_Copy_of_SPA__c && ag.Received_Customer_Copy_of_SPA__c != recordOldMap.get(ag.Id).Received_Customer_Copy_of_SPA__c){
                agList.add(ag);
            }
        }
        if(!agList.isEmpty()){
            completeComplianceChecklistAlert(agList); // Added by Rohit Sharma
        } 
    }
    public void BeforeInsertEvent() {
        updateCustomerEmail();
    }
    public void BeforeUpdateEvent() {
        GenericTriggerHandler.validateDocRecord(recordNewList,recordOldMap,recordNewMap,'Agreement__c');
        updateCustomerEmail();
        dispatchModeCustomerInOffice();
        erpSOCreation();
        updateSpaMilestones();// Added by Rohit Sharma
    }

    public void BeforeDeleteEvent() {
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }
    
    /******************************************************************************************************
    * @Description        : Update Agreement lookup on Deal Record                                                                                      
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void updateAgreementLookupOnDeal(List<Agreement__c> newList){
        List<Opportunity> oppList = new List<Opportunity>();
        for(Agreement__c ag: newList){
            if(ag.Opportunity__c != null){
                Opportunity opp = new Opportunity();
                opp.Id = ag.Opportunity__c;
                opp.Agreement__c = ag.Id;
                oppList.add(opp);
            }
        }
        if(!oppList.isEmpty()){
            update oppList;
        }
    }

    /******************************************************************************************************
    * @Description        : Update Customer Email on Agreement                                                                                       
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void updateCustomerEmail(){
        for(Agreement__c ag: recordNewList){
            if(ag.Customer_Primary_Email__c != null && (recordOldMap == null || ag.Customer_Primary_Email__c != recordOldMap.get(ag.Id).Customer_Primary_Email__c)){
                ag.Customer_Email__c = ag.Customer_Primary_Email__c;
            }
        }
    }

    /******************************************************************************************************
    * @Description        : Update SPA Milestone                                                                                      
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void dispatchModeCustomerInOffice(){
        for(Agreement__c ag: recordNewList){
            if(ag.Dispatch_Type__c == 'Customer in Office' && ag.Dispatch_Type__c != recordOldMap.get(ag.Id).Dispatch_Type__c){
                ag.Received_Customer_Copy_of_SPA__c = true;
                ag.Status__c = 'Signed by Customer and Ready for Execution';
            }
        }
    }
   /******************************************************************************************************
    * @Description        : Update Unit as Sold                                                                                     
    * @Return             : void                                                                         
    *******************************************************************************************************/
     public void markUnitSold(){ 
        Map<Id,Unit__c> agIdToUnitMap = new Map<Id,Unit__c>();
        Map< Id,Agreement__c > mapAgreementIdToAgreement = new Map< Id,Agreement__c >();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        List< Property__c > lstPropertyToInsert = new List< Property__c >();
        for(Agreement__c ag: recordNewList){
            if(ag.Unit__c != null && ag.Unit_Sold_Prerequisites__c &&  ag.Unit_Sold_Prerequisites__c != recordOldMap.get(ag.Id).Unit_Sold_Prerequisites__c){
                Unit__c un = new Unit__c();
                un.Id = ag.Unit__c;
                un.Unit_Status__c = 'Sold';
                agIdToUnitMap.put(ag.Id, un);
                mapAgreementIdToAgreement.put( ag.Id, ag );
            }
            if(ag.Opportunity__c != null && ag.Unit_Sold_Prerequisites__c &&  ag.Unit_Sold_Prerequisites__c != recordOldMap.get(ag.Id).Unit_Sold_Prerequisites__c){
                Opportunity op = new Opportunity();
                op.Id = ag.Opportunity__c;
                op.Sold_Date__c = Date.today();
                oppListUpdate.add(op);
            }
        }
        if(!oppListUpdate.isEmpty()){
            update oppListUpdate;
        }
        if(!agIdToUnitMap.isEmpty()){
            update agIdToUnitMap.values();
            
            Contact con;
            for( Contact conObj : [ SELECT Id, Name, Email FROM Contact WHERE LastName = 'DummyContact' AND Email = 'DummyContact@DummyContact.com' LIMIT 1] ){
                con = conObj;
            }
            if( con == null ){
                con = new Contact();
                con.LastName = 'DummyContact';
                con.Email = 'DummyContact@DummyContact.com';
                insert con;
            }
            // Get orgwide address
            List< OrgWideEmailAddress > orgAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :Label.NKL_Org_Wide_Email];
            Map<String,Id> templateIdMap = new Map<String,Id>();
            List<EmailTemplate> template = [ SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
                                    FROM EmailTemplate
                                    WHERE DeveloperName ='Unit_Status_Sold_Template'];
            List<EmailTemplate> customerTemplate = [ SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
                                    FROM EmailTemplate
                                    WHERE DeveloperName ='Customer_Unit_Sold_Template'];
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            for(Agreement__c ag: recordNewList){
                if(agIdToUnitMap.get(ag.Id).Unit_Status__c == 'Sold'){
                    NKLWrapperUtil.SendEmailWrapper input = new NKLWrapperUtil.SendEmailWrapper();
                    input.whoId                    = con.Id;
                    input.whatId                   = ag.Opportunity__c;
                    input.orgWideAddress           = orgAddress.size() > 0 ? orgAddress[0].Id : null;
                    input.emailTemplateId          = template.size() > 0 ? template[0].Id : null;
                    input.setTargetAsRecipient     = false;
                    input.senderDisplayName        = UserInfo.getName();
                    input.additionalEmailAddresses = new List< String >{ag.SPA_Owner_Email__c};
                        
                    Messaging.SingleEmailMessage message = CommonUtility.createEmail( input );
                    messageList.add( message );


                    NKLWrapperUtil.SendEmailWrapper input1 = new NKLWrapperUtil.SendEmailWrapper();
                    input1.whoId                    = con.Id;
                    input1.whatId                   = ag.Id;
                    input1.orgWideAddress           = orgAddress.size() > 0 ? orgAddress[0].Id : null;
                    input1.emailTemplateId          = customerTemplate.size() > 0 ? customerTemplate[0].Id : null;
                    input1.setTargetAsRecipient     = false;
                    input1.senderDisplayName        = UserInfo.getName();
                    input1.additionalEmailAddresses = new List< String >{ag.Customer_Email__c};
                        
                    Messaging.SingleEmailMessage message1 = CommonUtility.createEmail( input1 );
                    messageList.add( message1 );
                }
            }
            Messaging.SendEmailResult[] results;
            if( messageList != null && !messageList.isEmpty() ){
                results = Messaging.sendEmail( messageList );
            }
            if( results != null ){
                if (results[0].success ){
                    System.debug('The email was sent successfully.');
                }else{
                    System.debug( 'The email failed to send: ' +  results[0].errors[0].message );
                }
            }
            List<Agreement__c> agreementList = new List<Agreement__c>();
            for(Agreement__c ag : [SELECT Id,Create_Registration_Record__c,Unit_Status__c,Unit__c FROM Agreement__c WHERE Create_Registration_Record__c = false AND Id IN:agIdToUnitMap.keySet()]){
                if(agIdToUnitMap.get(ag.Id).Unit_Status__c == 'Sold'){
                    ag.Create_Registration_Record__c = true;
                    ag.Send_Sales_to_ERP__c = true;
                    agreementList.add(ag);
                }
            }
            if(!agreementList.isEmpty()){
                update agreementList;
            }

            for( Id agrId : mapAgreementIdToAgreement.keySet() ){
                Property__c property = new Property__c();
                property.Status__c = 'Sold';
                property.Unit__c = mapAgreementIdToAgreement.get( agrId ).Unit__c;
                property.Start_Date__c = System.today();
                property.Primary_Email__c = mapAgreementIdToAgreement.get( agrId ).Customer_Primary_Email__c;
                property.Account__c = mapAgreementIdToAgreement.get( agrId ).Account__c;
                property.Deal__c = mapAgreementIdToAgreement.get( agrId ).Opportunity__c;
                property.Active__c = true;
                lstPropertyToInsert.add( property );
            }

            if( !lstPropertyToInsert.isEmpty() ){
                insert lstPropertyToInsert;
            }
        }
    }

    /******************************************************************************************************
    * @Description        : Create Doc Varefication Task for Sales Admin 
                            and Update Deal StageName and SPA Generated Check                                                                                     
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void createDocVerificationTask(){
        List<Task> taskList = new List<Task>();
        Set<Id> oppIds = new Set<Id>();
        for(Agreement__c ag: recordNewList){
            if(ag.Opportunity__c != null){
                oppIds.add(ag.Opportunity__c);
            }
        }
        if(!oppIds.isEmpty()){
            Map<Id,Opportunity> oppIdMap = new Map<Id,Opportunity>([SELECT Id,Sales_Admin__c FROM Opportunity WHERE Id IN: oppIds]); 
            for(Agreement__c ag: recordNewList){
                if(oppIds.contains(ag.Opportunity__c)){
                    NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
                    input.relatedTo         =  ag.Opportunity__c;
                    input.currencyIsoCode   = 'AED'; //required
                    input.priority          = 'Normal'; //required
                    input.status            = 'Open'; //required
                    input.subject           = Label.SPA_Doc_Upload_Task_Subject + ' - ' + ag.Account_Name__c; //required
                    input.assignedTo        = oppIdMap.get(ag.Opportunity__c).Sales_Admin__c != null ? oppIdMap.get(ag.Opportunity__c).Sales_Admin__c : ag.OwnerId; //required
                    input.dueDate           = System.today() + 2;
                    input.description       = 'Verify and Upload Emirates Id and Passport Document.';
                    input.fieldUpdate       = 'Doc_Uploaded_By_Admin__c';
                    
                    Task tsk = CommonUtility.createTask( input );
                    taskList.add( tsk );
                }
            }
            if(!taskList.isEmpty()){
                insert taskList;
            }
        }
    }

    /******************************************************************************************************
    * @Description        : Update Agreement on Varoius Action and Task creation                                                                                    
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void agreementAfterUpdateOperation(){
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        List<Agreement__c> agListSendCustomerAlert = new List<Agreement__c>();
        List<Agreement__c> agListCourierUndelivered = new List<Agreement__c>();
        List<Agreement__c> agListCourierOnTransit = new List<Agreement__c>();

        for(Agreement__c ag: recordNewList){
            // Customer Alert SPA 'SPA Generated & Awaiting Customer Signature' OR 'SPA Sent to Customer'
            if(ag.SPA_Verified__c && (ag.Status__c == 'SPA Generated & Awaiting Customer Signature' || ag.Status__c == 'SPA Sent to Customer')){
                agListSendCustomerAlert.add(ag);  //Storing Agreement to create send Customer Alert
            }
            // Courier Undelivered
            if(ag.Dispatch_Type__c == 'Courier' && ag.Courier_Status__c == 'Returned to Office/Undelivered' && ag.Courier_Status__c != recordOldMap.get(ag.Id).Courier_Status__c){
                agListCourierUndelivered.add(ag); // Storing Agreement to create follow up task with customer -- Sales Team
            }
            // Courier On Transit
            if(ag.Dispatch_Type__c == 'Courier' && ag.Courier_Status__c == 'On Transit' && ag.Courier_Status__c != recordOldMap.get(ag.Id).Courier_Status__c){
                agListCourierOnTransit.add(ag); // Storing Agreement to create "Track SPA Courier Dispatch Status" -- Sales Team
            }
            // SPA Executed by Nakheel
            if(ag.Opportunity__c != null && ag.Status__c == 'SPA Executed By Nakheel' && ag.Status__c != recordOldMap.get(ag.Id).Status__c){
                Opportunity opp = new Opportunity();
                opp.Id = ag.Opportunity__c;
                opp.StageName = 'SPA Executed';
                oppListUpdate.add(opp);
            }

        }
        if(!oppListUpdate.isEmpty()){
            update oppListUpdate;
        }
        if(!agListCourierUndelivered.isEmpty()){
            followUpWithCustomer(agListCourierUndelivered); //"Follow up with Customer for SPA Undelivered" Task for Sales Team
        }
        if(!agListCourierOnTransit.isEmpty()){
            trackCourierStatusTask(agListCourierOnTransit); //"Track SPA Courier Dispatch Status" Task for Sales Team
        }
        if(!agListSendCustomerAlert.isEmpty()){
            sendCustomerAlert(agListSendCustomerAlert); //Send Customer Alert
        }
    }

    /******************************************************************************************************
    * @Description        : Create "Follow up with Customer for SPA Undelivered" Task for Sales Team
      @Parameters         : List<Agreement__c> agListCourierUndelivered                                                                                   
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void followUpWithCustomer(List<Agreement__c> newList){
        List<Task> taskList = new List<Task>();
        Set<Id> oppIdSet = new Set<Id>();
        for(Agreement__c ag: newList){
            oppIdSet.add(ag.Opportunity__c);
        }
        Map<Id,Opportunity> oppIdMap = new Map<Id,Opportunity>([SELECT Id, Sales_Admin__c FROM Opportunity WHERE Id IN:oppIdSet ]);
        //List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Sales_Team_Queue' LIMIT 1];
        for(Agreement__c ag: newList){
            NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
            input.relatedTo         =  ag.Opportunity__c;
            input.currencyIsoCode   = 'AED'; //required
            input.priority          = 'Normal'; //required
            input.status            = 'Open'; //required
            input.subject           = 'Follow up with Customer for SPA Undelivered'; //required
            input.assignedTo        = oppIdMap.get(ag.Opportunity__c).Sales_Admin__c != null ? oppIdMap.get(ag.Opportunity__c).Sales_Admin__c : ag.OwnerId; //required
            input.dueDate           = System.today() + 2;
            input.description       = null;
            input.fieldUpdate       = null;
            
            Task tsk = CommonUtility.createTask( input );
            taskList.add( tsk );
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }
    /******************************************************************************************************
    * @Description        : Create "Track SPA Courier Dispatch Status" Task for Sales Team
      @Parameters         : List<Agreement__c> agListCourierOnTransit                                                                                   
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void trackCourierStatusTask(List<Agreement__c> newList){
        List<Task> taskList = new List<Task>();
        Set<Id> oppIdSet = new Set<Id>();
        for(Agreement__c ag: newList){
            oppIdSet.add(ag.Opportunity__c);
        }
        Map<Id,Opportunity> oppIdMap = new Map<Id,Opportunity>([SELECT Id, Sales_Admin__c FROM Opportunity WHERE Id IN:oppIdSet ]);
        //List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Sales_Team_Queue' LIMIT 1];
        for(Agreement__c ag: newList){
            NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
            input.relatedTo         =  ag.Opportunity__c;
            input.currencyIsoCode   = 'AED'; //required
            input.priority          = 'Normal'; //required
            input.status            = 'Open'; //required
            input.subject           = 'Track SPA Courier Dispatch Status'; //required
            input.assignedTo        = oppIdMap.get(ag.Opportunity__c).Sales_Admin__c != null ? oppIdMap.get(ag.Opportunity__c).Sales_Admin__c : ag.OwnerId; //required
            input.dueDate           = null;
            input.description       = null;
            input.fieldUpdate       = null;
            
            Task tsk = CommonUtility.createTask( input );
            taskList.add( tsk );
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }

    /******************************************************************************************************
    * @Description        : Function to send Customer Alert for SPA Signature OR Issued SPA                                                                                        
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public  void sendCustomerAlert(List<Agreement__c> newList){
        List<Agreement__c> agreementList = new List<Agreement__c>();
        Map<Id,String> emailTemplateMap = new Map<Id,String>();
        for(Agreement__c ag: newList){
            if( ag.Business_Group__c != null && ag.Status__c != recordOldMap.get(ag.Id).Status__c && ag.Status__c == 'SPA Generated & Awaiting Customer Signature'){
                if(ag.Business_Group__c == 'Nakheel'){
                    emailTemplateMap.put(ag.Id, 'NAKHEEL_SPA_Reminder_Template');
                    agreementList.add(ag);
                }else if(ag.Business_Group__c == 'Meydan Group LLC'){
                    emailTemplateMap.put(ag.Id, 'Meydan_SPA_Reminder_Template');
                    agreementList.add(ag);
                }else if(ag.Business_Group__c == 'District One - FZ'){
                    emailTemplateMap.put(ag.Id, 'District_1_SPA_Reminder_Template');
                    agreementList.add(ag);
                }
            } else if(ag.Business_Group__c != null && ag.Status__c != recordOldMap.get(ag.Id).Status__c && ag.Status__c == 'SPA Sent to Customer'){
                if(ag.Business_Group__c == 'Nakheel'){
                    emailTemplateMap.put(ag.Id, 'NAKHEEL_SPA_Issued_Notification');
                    agreementList.add(ag);
                }else if(ag.Business_Group__c == 'Meydan Group LLC'){
                    emailTemplateMap.put(ag.Id, 'Meydan_SPA_Issued_Notification');
                    agreementList.add(ag);
                }else if(ag.Business_Group__c == 'District One - FZ'){
                    emailTemplateMap.put(ag.Id, 'District_1_SPA_Issued_Notification');
                    agreementList.add(ag);
                }
            }
        }
        if(!agreementList.isEmpty()){
            // Create contact to send the email
            Contact con;
            for( Contact conObj : [ SELECT Id, Name, Email FROM Contact WHERE LastName = 'DummyContact' AND Email = 'DummyContact@DummyContact.com' LIMIT 1] ){
                con = conObj;
            }
            if( con == null ){
                con = new Contact();
                con.LastName = 'DummyContact';
                con.Email = 'DummyContact@DummyContact.com';
                insert con;
            }
            // Get orgwide address
            List< OrgWideEmailAddress > orgAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :Label.NKL_Org_Wide_Email];
            Map<String,Id> templateIdMap = new Map<String,Id>();
            for( EmailTemplate temp : [ SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
                                       FROM EmailTemplate
                                       WHERE DeveloperName IN: emailTemplateMap.values()] ){
                                        templateIdMap.put(temp.DeveloperName , temp.Id);
                                       }
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            for( Agreement__c agree : agreementList){
                NKLWrapperUtil.SendEmailWrapper input = new NKLWrapperUtil.SendEmailWrapper();
                String emailTempateName        = emailTemplateMap.get(agree.Id);
                input.whoId                    = con.Id;
                input.whatId                   = agree.Id;
                input.orgWideAddress           = orgAddress.size() > 0 ? orgAddress[0].Id : null;
                input.emailTemplateId          = templateIdMap.get(emailTempateName) != null ? templateIdMap.get(emailTempateName) : null;
                input.setTargetAsRecipient     = false;
                input.senderDisplayName        = UserInfo.getName();
                input.additionalEmailAddresses = new List< String >{agree.Customer_Primary_Email__c};
                    
                Messaging.SingleEmailMessage message = CommonUtility.createEmail( input );
                messageList.add( message );
            }
            
            system.debug(messageList);
            Messaging.SendEmailResult[] results;
            if( messageList != null && !messageList.isEmpty() ){
                results = Messaging.sendEmail( messageList );
            }
            if( results != null ){
                if (results[0].success ){
                    System.debug('The email was sent successfully.');
                }else{
                    System.debug( 'The email failed to send: ' +  results[0].errors[0].message );
                }
            }
        }
    }

    /******************************************************************************************************
    * @Description        : Function to create relation with agreement to Joint buyer Record                                                                                        
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void attachJointOwnertoAgreement(List<Agreement__c> agList){
        Set<Id> setOppId = new Set<Id>();
        Map<Id, Id> mapOppAgreementId = new Map<Id, Id>();
        List<Joint_Buyer__c> listUpdateJointBuyer = new List<Joint_Buyer__c>();
        
        for(Agreement__c ag: agList){
            setOppId.add(ag.Opportunity__c);
            mapOppAgreementId.put(ag.Opportunity__c, ag.Id);
        }
        
        for(Joint_Buyer__c JO: [Select Id, Agreement__c, Opportunity__c from Joint_Buyer__c where Opportunity__c IN: setOppId])
        {
            JO.Agreement__c = mapOppAgreementId.get(JO.Opportunity__c);
            listUpdateJointBuyer.add(JO);
        }
        if(!listUpdateJointBuyer.isEmpty()){
            update listUpdateJointBuyer; 
        }
    }

    /******************************************************************************************************
    * @Description        : Function to create relation with agreement to payment milestone                                                                                        
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void attachMilestonetoAgreement(List<Agreement__c> agList){
        Set<Id> setOppId = new Set<Id>();
        Map<Id, Id> mapOppAgreementId = new Map<Id, Id>();
        List<Payment_Milestone__c> listUpdatePayment = new List<Payment_Milestone__c>();
        
        for(Agreement__c ag: agList){
            setOppId.add(ag.Opportunity__c);
            mapOppAgreementId.put(ag.Opportunity__c, ag.Id);
        }
        
        for(Payment_Milestone__c PM: [Select Id, Agreement__c, Opportunity__c from Payment_Milestone__c where Opportunity__c IN: setOppId])
        {
            PM.Agreement__c = mapOppAgreementId.get(PM.Opportunity__c);
            listUpdatePayment.add(PM);
        }
        if(!listUpdatePayment.isEmpty()){
            update listUpdatePayment; 
        }
    }
    
    /**********************************************************************************************
    * @Description  : Method to terminate agreement in ERP system
    * @Params       : List< Agreement__c > newList
    * @Param        : Map< Id, Agreement__c > oldMap
    * @Return       : void
    * @Author       : Karishma Kotian
    **********************************************************************************************/
    public void terminateAgreementERP(){
        Set<Id> agreementId = new Set<Id>();
        String SObjectName = 'Agreement__c';
        for(Agreement__c agreement : recordNewList){
            if(agreement.Sync_Agreement_Termination__c && (recordOldMap == null || agreement.Sync_Agreement_Termination__c != recordOldMap.get(agreement.Id).Sync_Agreement_Termination__c)){
                agreementId.add(agreement.Id);
            }
        }
        if(!agreementId.isEmpty()){
            //terminateAgreement(agreementId,SObjectName);
            ERPIntegrationHelper.spaTermination(agreementId);
        }
    }

    /********************************************************************************************** 
    * @Description  : Method to create Agreement in ERP system
    * @Params       : Agreement Ids - Set of Agreement Ids
    * @Return       : void
    * @Author       : Karishma Kotian
    **********************************************************************************************/
    /*public Static void terminateAgreement(Set<Id> agreementIds,String SObjectName) {
        terminateAgreementQueueable terminateAgreementNewObj = new terminateAgreementQueueable(agreementIds,SObjectName);
        system.enqueueJob(terminateAgreementNewObj);
    }*/

    /********************************************************************************************** 
    * @Description  : Queueable class to for callout to ERP system
    * @Params       : Agreement Ids - Set of Agreement Ids
    * @Return       : void
    * @Author       : Karishma Kotian
    **********************************************************************************************/
    /*public class terminateAgreementQueueable implements system.Queueable, Database.AllowsCallouts{
        Private  Set<Id> agreementIds;
        Private String SobjectName;
        public terminateAgreementQueueable(set<Id> agreementIds,String SobjectName){
            this.agreementIds=agreementIds;
            this.SobjectName = SobjectName;
        }
        public void execute(QueueableContext content){
            //ERPAPIIntegration.contractTermination(agreementIds,SobjectName);
        }
    }*/

    /******************************************************************************************************
    * @Description        : Function to create Registration Record                                                                                        
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void createRegistration(){
        Id mortgageId = Schema.SObjectType.Registration__c.getRecordTypeInfosByDeveloperName().get('Mortgage').getRecordTypeId();
        Id notMortgageId = Schema.SObjectType.Registration__c.getRecordTypeInfosByDeveloperName().get('Without_Mortgage').getRecordTypeId();
        List<Registration__c> regList = new List<Registration__c>();
        for(Agreement__c ag: recordNewList){
            if(ag.Create_Registration_Record__c && ag.Create_Registration_Record__c != recordOldMap.get(ag.Id).Create_Registration_Record__c){
                Registration__c reg = new Registration__c();
                reg.recordTypeId = ag.Unit_Mortgaged__c ? mortgageId : notMortgageId;
                reg.Unit__c = ag.Unit__c;
                reg.Opportunity__c = ag.Opportunity__c;
                reg.Account__c = ag.Account__c;
                reg.Floor__c = ag.Floor__c;
                reg.Building__c = ag.Building__c;
                reg.Project__c = ag.Project__c;
                reg.Business_Unit__c = ag.Business_Unit__c;
                reg.Agreement__c = ag.Id;
                reg.Status__c = 'Registration Initiated';
                regList.add(reg);
            }
        }
        if(!regList.isEmpty()){
            insert regList;
        }
    }
    
    /******************************************************************************************************
    * @Description        : Identify Sales Order call to ERP                                                                                      
    * @Return             : void         
    * @Author       : Vishal A                                                                
    *******************************************************************************************************/ 
    public void erpSOCreation() {
        Set<Id> agreementId = new Set<Id>();
        for(Agreement__c agre: recordNewList) {
            if(agre.Send_Sales_to_ERP__c && agre.ERP_Sales_ID__c ==null && (recordOldMap == null || agre.Send_Sales_to_ERP__c != recordOldMap.get(agre.Id).Send_Sales_to_ERP__c)) {
                agreementId.add(agre.Id);
                if(recordOldMap != null) {
                    agre.Send_Sales_to_ERP__c = false;
                }
            }
        }
        if(!agreementId.isEmpty()) {
            ERPIntegrationHelper.createSalesSO(agreementId);
        }
    }
    
    /********************************************************************************************** 
    * @Description  : Method to sync SO in ERP system
    * @Params       : Agreement Id - Set Id of Agreement 
    * @Return       : void
    * @Author       : Vishal A
    **********************************************************************************************/
    /*public Static void agreementSOCreation(Set<Id> agreementId) {
        syncAgreemetnSOQueuable syncSOAgr = new syncAgreemetnSOQueuable(agreementId);
        system.enqueueJob(syncSOAgr);
    }*/

    /********************************************************************************************** 
    * @Description  : Queueable class for callout to ERP system
    * @Params       : Agreement Id - Set Id of Agreement 
    * @Return       : void
    * @Author       : Vishal A
    **********************************************************************************************/
    /*public class syncAgreemetnSOQueuable implements system.Queueable, Database.AllowsCallouts{
        Private  Set<Id> agreementId;
        public syncAgreemetnSOQueuable(set<Id> agree){
            this.agreementId = agree;
        }
        public void execute(QueueableContext content){
            for(Id aId: agreementId){
                //ERPAPIIntegration.salesAgreementSOCreation(new set<Id>{aId});
            }
            
        }
    }*/
    /********************************************************************************************** 
    * @Description  : Method to update Checks On SPA
    * @Return       : void
    * @Author       : Rohit Sharma
    **********************************************************************************************/
    public void dataFlowFromSpaToDeal(){
        List<Opportunity> oppList = new List<Opportunity>();
        Map<String,String> spaMetaDataMap = new Map<String,String>();
        Map<Id,Agreement__c> oppIdToSpa = new Map<Id,Agreement__c>();

        for (Agreement_To_Deal_Mapping__mdt dealMeta: Agreement_To_Deal_Mapping__mdt.getAll().values()){
            spaMetaDataMap.put(dealMeta.Agreement_Field_API__c, dealMeta.Deal_Field_API__c);
        }

        for(Agreement__c spa : recordNewList){
            if(spa.Opportunity__c != null){
                for(String spaField : spaMetaDataMap.keySet()){
                    if(spa.get(spaField) != recordOldMap.get(spa.Id).get(spaField)){
                        oppIdToSpa.put(spa.Opportunity__c,spa);
                    }
                }
            }
        }

        if(!oppIdToSpa.isEmpty()){
            for(Opportunity opp : [SELECT Id FROM Opportunity WHERE Id IN:oppIdToSpa.keySet()]){
                Opportunity op = new Opportunity();
                op.Id = opp.Id;
                for(String spaField : spaMetaDataMap.keySet()){
                    op.put(spaMetaDataMap.get(spaField), oppIdToSpa.get(opp.Id).get(spaField));
                }
                oppList.add(op);
            }
            if(!oppList.isEmpty()){
                update oppList;
            }
        }
        
    }
    
        /******************************************************************************************************
    * @Description        : Update Active Agreement lookup on Unit Record 
    * Purpose             : Tag active agreement for SRs
    * Date                : 28 April 2022
    * Author              : Mamta Gupta                                                                   
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void updateAgreementLookupOnUnit(List<Agreement__c> newList){
        List<Unit__c> unitList = new List<Unit__c>();
        for(Agreement__c ag: newList){
            if(ag.Unit__c != null){
                Unit__c unit = new Unit__c();
                unit.Id = ag.Unit__c;
                unit.Active_Agreement__c = ag.Id;
                unitList.add(unit);
            }
        }
        if(!unitList.isEmpty()){
            try{
              update unitList;
            }
            catch(Exception ex ){
                system.debug('error is '+  ex.getMessage() + ' at' + ex.getLineNumber());
                
            }
        }
    }

    /******************************************************************************************************
    * @Description        : Send email alert to SPA owner to complete the compliance checklist                                                                                    
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void completeComplianceChecklistAlert(List<Agreement__c> newList){
        Contact con;
            for( Contact conObj : [ SELECT Id, Name, Email FROM Contact WHERE LastName = 'DummyContact' AND Email = 'DummyContact@DummyContact.com' LIMIT 1] ){
                con = conObj;
            }
            if( con == null ){
                con = new Contact();
                con.LastName = 'DummyContact';
                con.Email = 'DummyContact@DummyContact.com';
                insert con;
            }
            // Get orgwide address
            List< OrgWideEmailAddress > orgAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :Label.NKL_Org_Wide_Email];
            Map<String,Id> templateIdMap = new Map<String,Id>();
            List<EmailTemplate> template = [ SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
                                    FROM EmailTemplate
                                    WHERE DeveloperName ='Complete_Compliance_Checklist_Template'];
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            for(Agreement__c ag: newList){
                NKLWrapperUtil.SendEmailWrapper input = new NKLWrapperUtil.SendEmailWrapper();
                input.whoId                    = con.Id;
                input.whatId                   = ag.Id;
                input.orgWideAddress           = orgAddress.size() > 0 ? orgAddress[0].Id : null;
                input.emailTemplateId          = template.size() > 0 ? template[0].Id : null;
                input.setTargetAsRecipient     = false;
                input.senderDisplayName        = UserInfo.getName();
                input.additionalEmailAddresses = new List< String >{ag.SPA_Owner_Email__c};
                    
                Messaging.SingleEmailMessage message = CommonUtility.createEmail( input );
                messageList.add( message ); 
            }
            Messaging.SendEmailResult[] results;
            if( messageList != null && !messageList.isEmpty() ){
                results = Messaging.sendEmail( messageList );
            }
            if( results != null ){
                if (results[0].success ){
                    System.debug('The email was sent successfully.');
                }else{
                    System.debug( 'The email failed to send: ' +  results[0].errors[0].message );
                }
            }
    }

    /******************************************************************************************************
    * @Description        : Update SPA Milestone Status                                                                                       
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void updateSpaMilestones(){
        for(Agreement__c ag: recordNewList){
            if(ag.SPA_Generated__c && ag.SPA_Generated__c != recordOldMap.get(ag.Id).SPA_Generated__c){
                ag.Status__c = 'SPA Printed';
            }
            if(ag.Signed_SPA__c && ag.Signed_SPA__c != recordOldMap.get(ag.Id).Signed_SPA__c){
                ag.Status__c = 'SPA Executed By Nakheel';
                ag.SPA_Completion_Date__c = System.today();
            }
            if(ag.Compliance_Documents_Uploaded__c && ag.Received_Customer_Copy_of_SPA__c && (ag.Received_Customer_Copy_of_SPA__c != recordOldMap.get(ag.Id).Received_Customer_Copy_of_SPA__c || ag.Compliance_Documents_Uploaded__c != recordOldMap.get(ag.Id).Compliance_Documents_Uploaded__c)){
                ag.Status__c = 'Signed by Customer and Ready for Execution';
            }
        }
    }
}