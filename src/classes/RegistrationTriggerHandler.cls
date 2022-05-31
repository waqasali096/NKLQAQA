/**************************************************************************************************
* Name               : RegistrationTriggerHandler                                                      
* Description        : Handler class for Registration Trigger
* Created Date       : 14/02/2022                                                                 
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     14/02/2022      Initial Draft.                                               
**************************************************************************************************/
public class RegistrationTriggerHandler {
    List<Registration__c> recordNewList = new List<Registration__c>();
    List<Registration__c> recordOldList = new List<Registration__c>();
    Map<Id, Registration__c> recordNewMap = new Map<Id, Registration__c>();
    Map<Id, Registration__c> recordOldMap = new Map<Id, Registration__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = false;
    
    public RegistrationTriggerHandler( List<Registration__c> newList, 
                                   List<Registration__c> oldList, 
                                   Map<Id, Registration__c> newMap, 
                                   Map<Id, Registration__c> oldMap, 
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
    
    public void BeforeInsertEvent() {
        assignRecordToQueue();
    }
    public void BeforeUpdateEvent() {
        GenericTriggerHandler.validateDocRecord(recordNewList,recordOldMap,recordNewMap,'Registration__c');
    }
    public void BeforeDeleteEvent() {

    }
    public void AfterInsertEvent() {
        GenericTriggerHandler.createDocRecord(recordNewList,'Registration__c');
        alertToRegistrationManager();

        Id mortgageId = Schema.SObjectType.Registration__c.getRecordTypeInfosByDeveloperName().get('Mortgage').getRecordTypeId();
        Id notMortgageId = Schema.SObjectType.Registration__c.getRecordTypeInfosByDeveloperName().get('Without_Mortgage').getRecordTypeId();
        List<Registration__c> regPreRegMortgaged = new List<Registration__c>();
        List<Registration__c> notMortgageList = new List<Registration__c>();

        for(Registration__c reg : recordNewList){
            if(reg.RecordTypeId == mortgageId ){
                regPreRegMortgaged.add(reg);
            }else if(reg.RecordTypeId == notMortgageId){
                notMortgageList.add(reg);
            }
        }
        if(!regPreRegMortgaged.isEmpty()){
            preRegistrationMortgadge(regPreRegMortgaged); // Task for Registration Team - Mortgadge
        }
        if(!notMortgageList.isEmpty()){
            preRegistrationNotMortgadge(notMortgageList); // Task for Registration Team - Not Mortgadge
        }
        updateRegistrationLookupOnUnit(recordNewList);//Added By Mamta - 29 April
    }
    public void AfterUpdateEvent() {
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> unitIdSet = new Set<Id>();
        Set<Id> regForTaskCompletionIdSet = new Set<Id>();
        Set<Id> notMortgagePreRegTaskCompletedIdSet = new Set<Id>();
        Set<Id> mortgageRegCompleteTaskIdSet = new Set<Id>();
        Set<Id> notMortgageRegCompleteTaskIdSet = new Set<Id>();
        List<Registration__c> dldPayableTaskMortgadge = new List<Registration__c>();
        List<Registration__c> dldPayableTaskNotMortgadge = new List<Registration__c>();
        List<Registration__c> regToUpdate = new List<Registration__c>();
        List<Registration__c> regrecordForTaskCreationOffPlanList = new List<Registration__c>();
        List<Registration__c> regrecordForTaskCreationPlanReadyList = new List<Registration__c>();
        List<Registration__c> regTaskARCommercial = new List<Registration__c>();
        List<Registration__c> regTaskValidateDLD = new List<Registration__c>();
        List<Registration__c> regTaskARFinances = new List<Registration__c>();
        List<Registration__c> regPreRegMortgaged= new List<Registration__c>();
        List<Registration__c> regMortgadgedPayDLD = new List<Registration__c>();
        List<Registration__c> regDocChecklistUploaded = new List<Registration__c>();
        List<Registration__c> regTeamTaskDocUploadMortgage = new List<Registration__c>();

        for(Registration__c reg: recordNewList){
             // Mortgaged ==> Complete Task On Pre_Registration_Process_Initiated__c
             if(reg.Unit_Mortgaged__c && reg.Pre_Registration_Process_Initiated__c && reg.Pre_Registration_Process_Initiated__c != recordOldMap.get(reg.Id).Pre_Registration_Process_Initiated__c){
                regForTaskCompletionIdSet.add(reg.Id);
                dldPayableTaskMortgadge.add(reg);
                Registration__c registr = new Registration__c();
                registr.Id          = reg.Id;
                registr.Status__c   = 'Registration In Progress';
                regToUpdate.add(registr);
            }
            
             // Not Mortgaged ==> Eid/Passport Uploaded
             if(!reg.Unit_Mortgaged__c && reg.EID_Passport_Uploaded__c && reg.EID_Passport_Uploaded__c != recordOldMap.get(reg.Id).EID_Passport_Uploaded__c){
                dldPayableTaskNotMortgadge.add(reg);
                notMortgagePreRegTaskCompletedIdSet.add(reg.Id);
            }
            // Reviewed By AR - Commercial Team
            if(reg.Reviewed_by_AR_Commercial__c && reg.Reviewed_by_AR_Commercial__c != recordOldMap.get(reg.Id).Reviewed_by_AR_Commercial__c){
                regTaskARCommercial.add(reg);               
            }
            // Reviewed By Gl - Finances
            if(reg.Reviewed_by_GL_Finances__c && reg.Reviewed_by_GL_Finances__c != recordOldMap.get(reg.Id).Reviewed_by_GL_Finances__c){
                regTaskValidateDLD.add(reg);
            }
            // DLD_Payable_Amount_Validated__c
            if(reg.DLD_Payable_Amount_Validated__c && reg.DLD_Payable_Amount_Validated__c != recordOldMap.get(reg.Id).DLD_Payable_Amount_Validated__c){
                regTaskARFinances.add(reg);
            }
            // Mortgaged ==> Noqodi Wallet ToppedUp & Manager Cheque Cleared
            if(reg.Unit_Mortgaged__c && reg.Noqodi_Wallet_Topped_Up__c && reg.Manager_Cheque_Uploaded__c && (reg.Noqodi_Wallet_Topped_Up__c != recordOldMap.get(reg.Id).Noqodi_Wallet_Topped_Up__c || reg.Manager_Cheque_Uploaded__c != recordOldMap.get(reg.Id).Manager_Cheque_Uploaded__c)){
                regMortgadgedPayDLD.add(reg);
            }
            //Added by Ashams to update registration status on completion of naqodi wallet top up task completion
            if(!reg.Unit_Mortgaged__c && reg.Noqodi_Wallet_Topped_Up__c && reg.Noqodi_Wallet_Topped_Up__c != recordOldMap.get(reg.Id).Noqodi_Wallet_Topped_Up__c){
                Registration__c registr = new Registration__c();
                registr.Id          = reg.Id;
                registr.Status__c   = 'Registration In Progress';
                regToUpdate.add(registr);
            }
            // Not Mortgaged ===> Status = 'Registration In Progress'
            if( !reg.Unit_Mortgaged__c && reg.Status__c != recordOldMap.get(reg.Id).Status__c && reg.Status__c == 'Registration In Progress'){
                regDocChecklistUploaded.add(reg); // Pay DLD
            }
            // Not Mortgaged ===> DLD Payed task Completed
            if( !reg.Unit_Mortgaged__c && reg.Not_Mortgage_DLD_Paid__c && reg.Not_Mortgage_DLD_Paid__c  != recordOldMap.get(reg.Id).Not_Mortgage_DLD_Paid__c){
                if(reg.Unit_Plan_Status__c == 'Off Plan'){
                    regrecordForTaskCreationOffPlanList.add(reg); // Task To reg Team to Upload off Plan required doc
                }
                else if(reg.Unit_Plan_Status__c == 'Plan Ready'){
                    regrecordForTaskCreationPlanReadyList.add(reg); // Task To reg Team to Upload Plan ready required doc
                } 
                unitIdSet.add(reg.Unit__c); // Update Unit 'Registered'               
            }
            //Pre Registration Receipt Uploaded OR Title Deed Payment Receipt Uploaded
            if( (!reg.Unit_Mortgaged__c && reg.Pre_Registration_Receipt_Uploaded__c && reg.Pre_Registration_Receipt_Uploaded__c != recordOldMap.get(reg.Id).Pre_Registration_Receipt_Uploaded__c) || 
                    (!reg.Unit_Mortgaged__c && reg.Title_Deed_Payment_Receipt_Uploaded__c && reg.Title_Deed_Payment_Receipt_Uploaded__c != recordOldMap.get(reg.Id).Title_Deed_Payment_Receipt_Uploaded__c) ||
                    (!reg.Unit_Mortgaged__c && reg.Registration_Certificate_Uploaded__c && reg.Registration_Certificate_Uploaded__c != recordOldMap.get(reg.Id).Registration_Certificate_Uploaded__c) ){
                if(reg.Registration_Certificate_Uploaded__c && reg.Title_Deed_Payment_Receipt_Uploaded__c  && reg.Unit_Plan_Status__c == 'Plan Ready'){
                    mortgageRegCompleteTaskIdSet.add(reg.Id);
                    Registration__c registr = new Registration__c();
                    registr.Id          = reg.Id;
                    registr.Status__c   = 'Registration Complete';
                    regToUpdate.add(registr);
                }  
                if(reg.Registration_Certificate_Uploaded__c && reg.Pre_Registration_Receipt_Uploaded__c && reg.Unit_Plan_Status__c == 'Off Plan'){
                    notMortgageRegCompleteTaskIdSet.add(reg.Id);
                    Registration__c registr = new Registration__c();
                    registr.Id          = reg.Id;
                    registr.Status__c   = 'Registration Complete';
                    regToUpdate.add(registr);
                }
            }
            //  Mortgaged ==> DLD Paid
            if(reg.Unit__c != null && reg.Mortgage_DLD_Paid__c && reg.Mortgage_DLD_Paid__c != recordOldMap.get(reg.Id).Mortgage_DLD_Paid__c){
                unitIdSet.add(reg.Unit__c); // Update Unit 'Registered'
                regTeamTaskDocUploadMortgage.add(reg);
            }
            //  Mortgaged ==> Title Deed Payment Receipt Uploaded && Registration Certificate Uploaded
            if(reg.Opportunity__c != null && reg.Unit_Mortgaged__c && reg.Title_Deed_Payment_Receipt_Uploaded__c && reg.Registration_Certificate_Uploaded__c && (reg.Title_Deed_Payment_Receipt_Uploaded__c != recordOldMap.get(reg.Id).Title_Deed_Payment_Receipt_Uploaded__c || reg.Registration_Certificate_Uploaded__c != recordOldMap.get(reg.Id).Registration_Certificate_Uploaded__c)){
                mortgageRegCompleteTaskIdSet.add(reg.Id);
                oppIdSet.add(reg.Opportunity__c); // Update Deal 'Booking Confirmed'
                Registration__c registr = new Registration__c();
                registr.Id          = reg.Id;
                registr.Status__c   = 'Registration Complete';
                regToUpdate.add(registr);
            }
            // Mot Mortgaged Status ==> 'Registration Complete'
            if(!reg.Unit_Mortgaged__c && reg.Opportunity__c != null && reg.Unit__c != null && reg.Status__c != recordOldMap.get(reg.Id).Status__c && reg.Status__c == 'Registration Complete'){
                oppIdSet.add(reg.Opportunity__c); // Update Deal 'Booking Confirmed'
                
            }            
        }

        if(!dldPayableTaskMortgadge.isEmpty()){
            reviewDLDPayableAmountTaskAR(dldPayableTaskMortgadge);
        }
        if(!dldPayableTaskNotMortgadge.isEmpty()){
            reviewDLDPayableAmountTaskAR(dldPayableTaskNotMortgadge);
        }
        if(!regTaskARCommercial.isEmpty()){
            reviewDLDPayableAmountTaskGL(regTaskARCommercial);
        }
        if(!regTaskValidateDLD.isEmpty()){
            validateByAPValidationTeam(regTaskValidateDLD);
        }
        if(!regTaskARFinances.isEmpty()){
            topUpNoqodiWalletTask(regTaskARFinances);
        }
        if(!regMortgadgedPayDLD.isEmpty()){
            payDLD(regMortgadgedPayDLD);
        }
        if(!regTeamTaskDocUploadMortgage.isEmpty()){
            TaskToRegTeamToUploadRegCompleteDocLsit(regTeamTaskDocUploadMortgage);
        }
        if(!regrecordForTaskCreationPlanReadyList.isEmpty()){
            TaskToRegTeamToUploadRegCompleteDocLsit(regrecordForTaskCreationPlanReadyList);
        }
        if(!regrecordForTaskCreationOffPlanList.isEmpty()){
            TaskToRegTeamToUploadRegCompleteDocLsitOffPlan(regrecordForTaskCreationOffPlanList);
        }
        if(!regDocChecklistUploaded.isEmpty()){
            payDLD(regDocChecklistUploaded);
        }
        if(!regToUpdate.isEmpty()){
            update regToUpdate;
        }
        if(!oppIdSet.isEmpty()){
            updateDealStage(oppIdSet);
        }
        if(!unitIdSet.isEmpty()){
            unitStatusRegistered(unitIdSet);
        }
        if(!regForTaskCompletionIdSet.isEmpty()){
            List<Task> taskList = [SELECT Id,Status FROM Task WHERE WhatId In:regForTaskCompletionIdSet AND Subject =: Label.Pre_Registration_Process_Label];
            for(Task tk : taskList){
                tk.Status = 'Completed';
            }
            if(!taskList.isEmpty()){
                update taskList;
            }
        }
        if(!notMortgagePreRegTaskCompletedIdSet.isEmpty()){
            List<Task> taskList = [SELECT Id,Status FROM Task WHERE WhatId In:notMortgagePreRegTaskCompletedIdSet AND Subject ='Initiate pre-registration process'];
            for(Task tk : taskList){
                tk.Status = 'Completed';
            }
            if(!taskList.isEmpty()){
                update taskList;
            }
        }
        if(!mortgageRegCompleteTaskIdSet.isEmpty()){
            List<Task> taskList = [SELECT Id,Status FROM Task WHERE WhatId In:mortgageRegCompleteTaskIdSet AND Subject ='Upload Pre-Registration/Title Deed Payment Receipt and Registration Certificate'];
            for(Task tk : taskList){
                tk.Status = 'Completed';
            }
            if(!taskList.isEmpty()){
                update taskList;
            }
        }
        if(!notMortgageRegCompleteTaskIdSet.isEmpty()){
            List<Task> taskList = [SELECT Id,Status FROM Task WHERE WhatId In:notMortgageRegCompleteTaskIdSet AND Subject ='Upload Pre-Registration Receipt & Registration Certificate'];
            for(Task tk : taskList){
                tk.Status = 'Completed';
            }
            if(!taskList.isEmpty()){
                update taskList;
            }
        }
    }
    public void AfterDeleteEvent() {

    }
    public void AfterUndeleteEvent() {

    }

    /******************************************************************************************************
    * @Description        : Function to change Owner to Registration team Queue                                                                                            
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void assignRecordToQueue(){
        List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Registration_Team' LIMIT 1];
        if(!queueId.isEmpty()){
            for(Registration__c reg: recordNewList){
                reg.OwnerId = queueId[0].Id;
            }
        }
    }
    /******************************************************************************************************
    * @Description        : Email Alert To Registration Managers                                                                                            
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void alertToRegistrationManager(){
        List<String> emailList = System.Label.Registration_Manager_Email.split(',');
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
        List<EmailTemplate> template = [ SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
                                   FROM EmailTemplate
                                   WHERE DeveloperName ='Registration_Assigned_Template'];
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        for(Registration__c reg: recordNewList){
            NKLWrapperUtil.SendEmailWrapper input = new NKLWrapperUtil.SendEmailWrapper();
            input.whoId                    = con.Id;
            input.whatId                   = reg.Id;
            input.orgWideAddress           = orgAddress.size() > 0 ? orgAddress[0].Id : null;
            input.emailTemplateId          = template.size() > 0 ? template[0].Id : null;
            input.setTargetAsRecipient     = false;
            input.senderDisplayName        = UserInfo.getName();
            input.additionalEmailAddresses = emailList;
                
            Messaging.SingleEmailMessage message = CommonUtility.createEmail( input );
            messageList.add( message );
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
    * @Description        : Task To Registration Team To Upload Reg Certificate & Title Deed Payment Receipt                                                                                            
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void TaskToRegTeamToUploadRegCompleteDocLsit(List<Registration__c> newList){
        List<Task> taskList = new List<Task>();
        List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Registration_Team' LIMIT 1];
        for(Registration__c reg: newList){
            NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
            input.relatedTo         =  reg.Id;
            input.currencyIsoCode   = 'AED'; //required
            input.priority          = 'Normal'; //required
            input.status            = 'Open'; //required
            input.subject           = 'Upload Pre-Registration/Title Deed Payment Receipt and Registration Certificate'; //required
            input.assignedTo        = queueId.size() > 0 ? queueId[0].Id : reg.OwnerId; //required
            input.fieldUpdate       = null;
            input.dueDate           = null;
            input.description       = 'Upload Pre-Registration/Title Deed Payment Receipt and Registration Certificate';
            
            Task tsk = CommonUtility.createTask( input );
            taskList.add( tsk );
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }
    /******************************************************************************************************
    * @Description        : Task To Registration Team To Upload Reg Certificate & Pre-Registration Receipt                                                                                            
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void TaskToRegTeamToUploadRegCompleteDocLsitOffPlan(List<Registration__c> newList){
        List<Task> taskList = new List<Task>();
        List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Registration_Team' LIMIT 1];
        for(Registration__c reg: newList){
            NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
            input.relatedTo         =  reg.Id;
            input.currencyIsoCode   = 'AED'; //required
            input.priority          = 'Normal'; //required
            input.status            = 'Open'; //required
            input.subject           = 'Upload Pre-Registration Receipt & Registration Certificate'; //required
            input.assignedTo        = queueId.size() > 0 ? queueId[0].Id : reg.OwnerId; //required
            input.fieldUpdate       = null;
            input.dueDate           = null;
            input.description       = 'Upload Pre-Registration Receipt & Registration Certificate';
            
            Task tsk = CommonUtility.createTask( input );
            taskList.add( tsk );
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }

    /******************************************************************************************************
    * @Description        : Function to create "Initiate pre-registration process" Task - registration Team
    * @Parameters         : List<Registration> regPreRegMortgaged                                                                                               
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void preRegistrationMortgadge(List<Registration__c> newList){
        List<Task> taskList = new List<Task>();
        List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Registration_Team' LIMIT 1];
        for(Registration__c reg: newList){
            NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
            input.relatedTo         =  reg.Id;
            input.currencyIsoCode   = 'AED'; //required
            input.priority          = 'Normal'; //required
            input.status            = 'Open'; //required
            input.subject           = Label.Pre_Registration_Process_Label; //required
            input.assignedTo        = queueId.size() > 0 ? queueId[0].Id : reg.OwnerId; //required
            input.fieldUpdate       = null;
            input.dueDate           = null;
            input.description       = 'Please upload Bank Offer Letter, EID / Passport & Mortgage Contract in Registration record.';
            
            Task tsk = CommonUtility.createTask( input );
            taskList.add( tsk );
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }

    /******************************************************************************************************
    * @Description        : Function to create "Initiate pre-registration process" Task - registration Team
    * @Parameters         : List<Registration> regPreRegMortgaged                                                                                               
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void preRegistrationNotMortgadge(List<Registration__c> newList){
        List<Task> taskList = new List<Task>();
        List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Registration_Team' LIMIT 1];
        for(Registration__c reg: newList){
            NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
            input.relatedTo         =  reg.Id;
            input.currencyIsoCode   = 'AED'; //required
            input.priority          = 'Normal'; //required
            input.status            = 'Open'; //required
            input.subject           = 'Initiate pre-registration process'; //required
            input.assignedTo        = queueId.size() > 0 ? queueId[0].Id : reg.OwnerId; //required
            input.fieldUpdate       = null;
            input.dueDate           = null;
            input.description       = 'Please upload EID / Passport in Registration record';
            
            Task tsk = CommonUtility.createTask( input );
            taskList.add( tsk );
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }

    /******************************************************************************************************
    * @Description        : Function to create "Review DLD payable amount on Registration - AR Commercial team" Task - Finance Team                                                                                            
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void reviewDLDPayableAmountTaskAR(List<Registration__c> newList){
        List<Task> taskList = new List<Task>();
        List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'AR_Commercial_Team' LIMIT 1];
        for(Registration__c reg: newList){
            NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
            input.relatedTo         =  reg.Id;
            input.currencyIsoCode   = 'AED'; //required
            input.priority          = 'Normal'; //required
            input.status            = 'Open'; //required
            input.subject           = 'AR Commercial: Review of DLD Payable Amount for Registration'; //required
            input.assignedTo        = queueId.size() > 0 ? queueId[0].Id : reg.OwnerId; //required
            input.fieldUpdate       = 'Reviewed_by_AR_Commercial__c';
            input.dueDate           = null;
            input.description       = 'AR Commercial: Review of DLD Payable Amount for Registration';
            
            Task tsk = CommonUtility.createTask( input );
            taskList.add( tsk );
            system.debug('taskList==>'+taskList);
        }
        if(!taskList.isEmpty()){
            insert taskList;
            system.debug('taskList==>'+taskList);
        }
    }
    /******************************************************************************************************
    * @Description        : Function to create "Review DLD payable amount - GL Finance team" Task - Finance team
    * @Parameters         : List<Registration> regTaskARCommercial                                                                                               
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void reviewDLDPayableAmountTaskGL(List<Registration__c> newList){
        List<Task> taskList = new List<Task>();
        List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'GL_Finance_Team' LIMIT 1];
        for(Registration__c reg: newList){
            NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
            input.relatedTo         =  reg.Id;
            input.currencyIsoCode   = 'AED'; //required
            input.priority          = 'Normal'; //required
            input.status            = 'Open'; //required
            input.subject           = 'GL Finance: Review of DLD Payable Amount for Registration'; //required
            input.assignedTo        = queueId.size() > 0 ? queueId[0].Id : reg.OwnerId; //required
            input.fieldUpdate       = 'Reviewed_by_GL_Finances__c';
            input.dueDate           = null;
            input.description       = 'GL Finance: Review of DLD Payable Amount for Registration';
            
            Task tsk = CommonUtility.createTask( input );
            taskList.add( tsk );
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }
    /******************************************************************************************************
    * @Description        : Function to create "Validate DLD Payable Amount - AP Validation Team" Task - AP Validation Team
    * @Parameters         : List<Registration> regTaskValidateDLD                                                                                               
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void validateByAPValidationTeam(List<Registration__c> newList){
        List<Task> taskList = new List<Task>();
        List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'AP_Validation_Team' LIMIT 1];
        for(Registration__c reg: newList){
            NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
            input.relatedTo         =  reg.Id;
            input.currencyIsoCode   = 'AED'; //required
            input.priority          = 'Normal'; //required
            input.status            = 'Open'; //required
            input.subject           = 'AP validation:Review of DLD Payable Amount for Registration'; //required
            input.assignedTo        = queueId.size() > 0 ? queueId[0].Id : reg.OwnerId; //required
            input.fieldUpdate       = 'DLD_Payable_Amount_Validated__c';
            input.dueDate           = null;
            input.description       = 'AP validation:Review of DLD Payable Amount for Registration';
            
            Task tsk = CommonUtility.createTask( input );
            taskList.add( tsk );
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }
    /******************************************************************************************************
    * @Description        : Function to create "Top up Noqodi Wallet" Task - AP Payment team
    * @Parameters         : List<Registration> regTaskARFinances                                                                                               
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void topUpNoqodiWalletTask(List<Registration__c> newList){
        List<Task> taskList = new List<Task>();
        List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'AP_Payment_Team' LIMIT 1];
        for(Registration__c reg: newList){
            NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
            input.relatedTo         =  reg.Id;
            input.currencyIsoCode   = 'AED'; //required
            input.priority          = 'Normal'; //required
            input.status            = 'Open'; //required
            input.subject           = 'Top Up Noqodi Wallet: AP Payment- Top Up Noqodi Wallet with Validated DLD Payable Amount'; //required
            input.assignedTo        = queueId.size() > 0 ? queueId[0].Id : reg.OwnerId; //required
            input.fieldUpdate       = 'Noqodi_Wallet_Topped_Up__c';
            input.dueDate           = null;
            input.description       = 'Top Up Noqodi Wallet: AP Payment- Top Up Noqodi Wallet with Validated DLD Payable Amount';
            
            Task tsk = CommonUtility.createTask( input );
            taskList.add( tsk );
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }
    /******************************************************************************************************
    * @Description        : Function to create "Pay DLD through Noqoodi Wallet" Task - Registration Team
    * @Parameters         : List<Registration> regPreRegMortgaged  || regDocChecklistUploaded                                                                                             
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void payDLD(List<Registration__c> newList){
        Id mortgageId = Schema.SObjectType.Registration__c.getRecordTypeInfosByDeveloperName().get('Mortgage').getRecordTypeId();
        List<Task> taskList = new List<Task>();
        List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Registration_Team' LIMIT 1];
        for(Registration__c reg: newList){
            NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
            input.relatedTo         =  reg.Id;
            input.currencyIsoCode   = 'AED'; //required
            input.priority          = 'Normal'; //required
            input.status            = 'Open'; //required
            input.subject           = 'Pay DLD through Noqoodi Wallet'; //required
            input.assignedTo        = queueId.size() > 0 ? queueId[0].Id : reg.OwnerId; //required
            input.fieldUpdate       = reg.RecordTypeId == mortgageId  ? 'Mortgage_DLD_Paid__c': 'Not_Mortgage_DLD_Paid__c';
            input.dueDate           = null;
            input.description       = 'Pay DLD through Noqoodi Wallet';
            
            Task tsk = CommonUtility.createTask( input );
            taskList.add( tsk );
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }
    /******************************************************************************************************
    * @Description        : Function to Update Deal Stage => 'Booking Confirmed'    
    * @Parameters         : Set<Id> oppIdSet                                                                                      
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void updateDealStage(Set<Id> oppIdSet){
        List<Opportunity> oppList = [SELECT Id, StageName FROM Opportunity WHERE Id IN: oppIdSet];
        for(Opportunity opp: oppList){
            opp.StageName = 'Booking Confirmed';
        }
        if(!oppList.isEmpty()){
            update oppList;
        }
    }
    /******************************************************************************************************
    * @Description        : Function to Update Unit Stage => 'Registered'    
    * @Parameters         : Set<Id> unitIdSet                                                                                      
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void unitStatusRegistered(Set<Id> unitIdSet){
        List<Unit__c> unitList = [SELECT Id, Unit_Status__c FROM Unit__c WHERE Id IN: unitIdSet];
        for(Unit__c unit: unitList){
            unit.Unit_Status__c = 'Registered';
            unit.Unit_Sub_Status__c = 'Mortgage Initiated';
        }
        if(!unitList.isEmpty()){
            update unitList;
        }
    }

        /******************************************************************************************************
    * @Description        : Update Active Registration lookup on Unit Record 
    * Purpose             : Tag active Registration for SRs
    * Date                : 28 April 2022
    * Author              : Mamta Gupta                                                                   
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void updateRegistrationLookupOnUnit(List<Registration__c> newList){
        List<Unit__c> unitList = new List<Unit__c>();
        for(Registration__c ag: newList){
            if(ag.Unit__c != null){
                Unit__c unit = new Unit__c();
                unit.Id = ag.Unit__c;
                unit.Active_Registration__c = ag.Id;
                unitList.add(unit);
            }
        }
        if(!unitList.isEmpty()){
            try{
            update unitList;
            }
            catch(Exception ex ){
                
            }
        }
    }
}