/**************************************************************************************************
* Name               : LeadTriggerHandler                                                      
* Description        : 
* Created Date       : 31/10/2021                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Ankur      31/10/2021      Initial Draft.                                               
**************************************************************************************************/

public class LeadTriggerHandler {
    
    List<Lead> recordNewList = new List<Lead>();
    List<Lead> recordOldList = new List<Lead>();
    Map<Id, Lead> recordNewMap = new Map<Id, Lead>();
    Map<Id, Lead> recordOldMap = new Map<Id, Lead>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public LeadTriggerHandler(List<Lead> newList, List<Lead> oldList, Map<Id, Lead> newMap, Map<Id, Lead> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
        updateMobileNumber();
        updateRecordTypeName();
        checkLeadDuplication();// Added by jaskiran
        updateLeadIntegration();// Added by jaskiran
        updateDateFields('Insert');//Added By Sajid
        updateCallbackResponseDateTime('Insert');//Added By Sajid
        //decideToCheckDuplicate('Insert'); //Added By Sajid
    }
    public void BeforeUpdateEvent() {
        updateSLA(); // Added by jaskiran
        updateQualifiedSLA();//Added By Sajid
        UpdateCampaignMember();
        validateStatusChange();// Added by jaskiran
        ifLeadOwnerisChanged();//Added By Mamta 29 March
        updateLead();
        updateLeadIntegration();// Added by jaskiran
        //AssignRecordtoSales();
        tagLeadQualifier(); //Added by mamata
        updateDateFields('Update');//Added By Sajid
        updateCallbackResponseDateTime('Update');//Added By Sajid
        //decideToCheckDuplicate('Update'); 
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
        GenericTriggerHandler.createDocRecord(recordNewList , 'Lead');//Added by Sajid
        mapPicklistvaluesWithIDS();
        createCampaignMember();
        // AssignRecordtoSales();
        
        List<Lead> lds = new List<Lead>();
        List<Lead> leadsToCreateTsks = new List<Lead>();
        List<Lead> qualifiedTasklist = new List<Lead>();
        for(Lead ld : recordNewList){
            String ownerID = String.valueof(ld.OwnerID);
            if(ownerID.startsWith('00G')){
                lds.add(ld);
                
            }
            
            if(ld.LeadSource=='Website' && ld.Call_Back_Request_Time__c!=null){ 
                leadsToCreateTsks.add(ld);  
            }else if(ld.Interested_In__c != 'Sales' && ld.CreatedUserProfileName__c != 'API Profile'
                     && String.isEmpty(ld.Callback_Request_Slot__c) && ld.LeadSource !='Website'){//Added By Sajid
                qualifiedTasklist.add(ld);  
            }   
            
        }
        if(!qualifiedTasklist.isEmpty()){//added by Sajid
            createQualifiedTask(qualifiedTasklist);
        }
        //SendEmail(lds);
        if(!leadsToCreateTsks.isEmpty()){
            createCallbackTask(leadsToCreateTsks); 
        }
        
        callAssignmentEngineFr_Leasing();
        
    }
    public void AfterUpdateEvent() {
        
        //LeadSLA();
        // 
        syncConvertedAccountToERP();
        Boolean isLeadQualfied;
        
        ID leadID;
        Boolean callEngineBatch;
        String salesLeadRecTYpe = system.label.Sales_Lead_RecordType ;
        String WalkinsalesLeadRecTYpe = system.label.Lead_WalkIn_RecordType  ;
        Id salesleadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(salesLeadRecTYpe).getRecordTypeId();
        Id WalkInsalesleadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(WalkinsalesLeadRecTYpe).getRecordTypeId();
        
        
        List<String> recIDS = new List<String>{salesleadRecordTypeId,WalkInsalesleadRecordTypeId };
            system.debug('recIDS are '+ recIDS);    
        system.debug('salesleadRecordTypeId is '+ salesleadRecordTypeId);
        for(Lead ld : recordNewList){
            system.debug('status is '+ ld.Status);
            system.debug('ld recID is '+ ld.RecordTypeID);
            if(ld.Status=='Qualified' && (recordOldMap.get(ld.ID)).Status!=ld.Status && recIDS.contains(ld.RecordTypeID ) && ld.Sales_Executive__c  ==NULL){
                callEngineBatch = true;
            }
            
        }
        
        if(callEngineBatch==true){
            callAssignmentEngineBatch();
        }
        
        shareRecordWith_SalesExecutive();/*Added By Mamta 1 April*/
        // ifLeadOwnerisChangedtoQueue();/* Added By Mamta 5 April */ 
        // 
        
        // Added by sajid for document linking to account
        linkDocToAccount();
        
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }
    
    /*Added By Mamta 1 April*/
    public void shareRecordWith_SalesExecutive(){
        List<LeadShare> ldShareLst = new List<LeadShare>();
        for(Lead ld : recordNewList){
            system.debug('status is '+ ld.Status);
            if(ld.Sales_Executive__c !=null && (recordOldMap.get(ld.ID)).Sales_Executive__c !=ld.Sales_Executive__c){ 
                LeadShare ls = new LeadShare();
                ls.leadId   = ld.ID;
                ls.LeadAccessLevel='Edit';
                ls.UserOrGroupId = ld.Sales_Executive__c;
                ldShareLst.add(ls);
            }
        }
        if(!ldShareLst.isEmpty()){
            try{
                insert ldShareLst;
                system.debug('ldShareLst is '+ ldShareLst);
            }
            catch(Exception ex){
                system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
                
            }
            
        }
    }
    
    /* Added BY Mamta 5 April*/
    public void ifLeadOwnerisChangedtoQueue(){
        List<Lead> lds = new List<Lead>();
        for(Lead ld : recordNewList){
            String oldOwner = String.valueof((recordOldMap.get(ld.ID).OwnerID));
            system.debug('oldOwner is '+ oldOwner);
            system.debug('ownerID is '+ recordNewMap.get(ld.OwnerID));
            if(oldOwner!=null){
                String ownerID = String.valueof(ld.OwnerID);
                if(ld.OwnerID!= recordOldMap.get(ld.ID).OwnerID && ownerID.startsWith('00G')  ){
                    lds.add(ld);
                }
            }
        }
        
        Group gp = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Lead_Queue' LIMIT 1];
        
        EmailTemplate em = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate 
                            where DeveloperName =:'Lead_Queue_Email' ];
        //SendMassEmailTo_Queue.sendEmailNotice(lds, gp,  em, true);
        List<Task> tsks = [select id , ownerID from Task  WHERE WhoID IN :lds];
        system.debug('tsks are '+ tsks);
        for(Task tsk : tsks){
            tsk.ownerID = gp.ID;
            
        }
        try{
            update tsks;
        }
        catch(Exception ex){
            system.debug('error is '+ ex.getMessage() +' at '+ ex.getLineNumber());
        }
        
        
    }
    
    Public void createCallbackTask(List<Lead> leads){
        List<Task> tsks = new List<Task>();
        for(Lead ld :leads ){
            Task tsk = new Task();
            tsk.Subject='Review lead details and contact customer at mentioned time';  
            tsk.Priority='High';
            tsk.Status ='Open';
            tsk.ActivityDate = Date.valueof(ld.Call_Back_Request_Time__c);
            tsk.Time_Slot__c = ld.Call_Back_Request_Time__c;
            tsk.WhoID = ld.ID;
            tsk.OwnerId = system.label.Lead_Queue_ID;  
            tsks.add(tsk);  
            
        }
        
        if(!tsks.isEmpty()){
            try{
                insert tsks;
            }
            catch(Exception ex){
                system.debug('error is '+ ex.getMessage() + ' at Line '+ ex.getLineNumber());
                
            }
            
        }
    }
    
    
    /* Added BY Mamta 29 March*/
    public void ifLeadOwnerisChanged(){
        try{
            Map<ID, String> mapOFUserProfiles =new Map<ID, String>();
            String prflName = system.label.Lead_Executive ;
            Profile pID =[select id, Name from Profile where name=:prflName LIMIT 1 ];
            //List<Users> usrs =[select id, profile]
            List<Lead> lds = new List<Lead>();
            for(Lead ld : recordNewList){
                String oldOwner = String.valueof((recordOldMap.get(ld.ID).OwnerID));
                system.debug('oldOwner is '+ oldOwner);
                system.debug('ownerID is '+ ld.OwnerID);
                String ownerID = String.valueof(ld.OwnerID);
                if(oldOwner!=null){
                    if(ld.OwnerID!= recordOldMap.get(ld.ID).OwnerID && !oldOwner.startsWith('00G') && userInfo.getProfileId()==pID.ID ){
                        ld.addError('You can not change Owner.Only Lead Manager can change it');
                    }
                    if(ld.OwnerID!= recordOldMap.get(ld.ID).OwnerID && ownerID.startsWith('00G')  ){
                        lds.add(ld);
                    }
                }
                
                //SendEmail(lds);
                
                
            }
        }catch(Exception ex){
            
        }
    }
    
    public void SendEmail(List<Lead> lds){
        try{
            if(!lds.isEmpty()){
                Group gp = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Lead_Queue' LIMIT 1];
                
                EmailTemplate em = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate 
                                    where DeveloperName =:'Lead_Queue_Email' ];
                SendMassEmailTo_Queue.sendEmailNotice(lds, gp,  em, true);
                List<Task> tsks = [select id , ownerID from Task  WHERE WhoID IN :lds];
                system.debug('tsks are '+ tsks);
                for(Task tsk : tsks){
                    tsk.ownerID = gp.ID;
                    
                }
                
                //update tsks;
                
            } 
        }
        catch(Exception ex){
            system.debug('error is '+ ex.getMessage() +' at '+ ex.getLineNumber());
        }
        
    }
    
    public void CallLeadConvertMethod(ID leadId){
        
        try{
            
            LeadStatus CLeadStatus= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true Limit 1];
            Database.LeadConvert objLeadConvert = new Database.LeadConvert();    
            objLeadConvert.setLeadId(Id.valueOf(leadId));
            Lead objLead = new Lead(Id= Id.valueOf(leadId));
            Account objAccount = NakheelUtility_Ctrl.findMatchingAccount(objLead, '');
            if(objAccount != null){            
                objLeadConvert.setAccountId(objAccount.Id);  
            }
            objLeadConvert.setConvertedStatus(CleadStatus.MasterLabel);
            
            Database.LeadConvertResult objLeadConvertResult = Database.convertLead(objLeadConvert, false);
            String errMsg='';
            if (!objLeadConvertResult.isSuccess()) {
                errMsg += 'Conversion  ' + ' failed!';
                for (Database.Error er : objLeadConvertResult.getErrors()) {
                    errMsg += ' '+ er.getMessage();
                    errMsg += '\r\n';
                }
            }
            
            for(Lead ld: recordNewList){
                if(errMsg!=''){
                    ld.addError(errMsg);
                }
            }
            
            
            system.debug('objLeadConvertResult is '+ objLeadConvertResult);
            //Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Units Leasing').getRecordTypeId();
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Deal').getRecordTypeId();
            Opportunity objOpportunity = new Opportunity(Id= objLeadConvertResult.getOpportunityId(), RecordTypeId = oppRecordTypeId);
            // update objOpportunity;
            
            
            
        }
        catch(Exception e){
            system.debug('Error Msg => '+e.getMessage() + ' at '+ e.getLineNumber());
            /* for(Lead ld: recordNewList){
ld.addError(e.getMessage());
}*/
            
            //objResultWrapper.strMessage = e.getMessage();
        }
    }
    
    /*Method to map project name with Project ID for web to lead form*/
    //Added by Mamta
    public void mapPicklistvaluesWithIDS(){
        Set<String> prjctCodenames = new Set<String>();
        Map<String,ID> prjectNameIDMap = new Map<String,ID>(); 
        Set<String> spaceTypeNames = new Set<String>();
        Map<String,ID> spaceNameIDMap = new Map<String,ID>();    
        
        for(Lead lead : recordNewList){
            if(lead.Project__c  != Null ){
                prjctCodenames.add(lead.Project__c);
            }
            if(lead.Space_Type__c  != Null ){
                spaceTypeNames.add(lead.Space_Type__c);
            }
        }
        
        for(Project__c projct: [SELECT Id, Name FROM Project__c WHERE Name IN:prjctCodenames]){
            prjectNameIDMap.put(projct.Name, projct.ID);
        }
        
        for(Space_Type__c sp: [SELECT Id, Name FROM Space_Type__c WHERE Name IN:spaceTypeNames]){
            spaceNameIDMap.put(sp.Name, sp.ID);
        }  
        
        system.debug('prjectNameIDMap is '+ prjectNameIDMap);   
        List<Lead>  leadLst =[select id,Project__c,Inventory_Project__c ,Space_Type__c,Space_Types__c from Lead WHERE ID IN: recordNewList]  ;
        for(Lead ld: leadLst){
            if(ld.Project__c!=null && ld.Project__c!=''){
                if(prjectNameIDMap.containsKey(ld.Project__c)){
                    ld.Inventory_Project__c = prjectNameIDMap.get(ld.Project__c);
                    
                }
            }
            if(ld.Space_Type__c!=null && ld.Space_Type__c!=''){
                if(spaceNameIDMap.containsKey(ld.Space_Type__c)){
                    ld.Space_Types__c = spaceNameIDMap.get(ld.Space_Type__c);
                    
                }
            }
            
        } 
        if(leadLst.size()>0){
            try{
                update leadLst;
            }
            catch(Exception ex){
                system.debug('error is '+ ex.getMessage());
            }
        }
        
    }
    
    
    
    
    /**
* Method Name: createCampaignMember
* Method Description: Insert Lead as a CampaignMember on Campaign whenever the value of Campaign Number and Campaign Name on Lead
matched with value of Campaign Name and Campaign Number on Campaign
* @param: leadWithCamapaignName - List of Lead  records which have Campaign Number and Campaign Name both
* @param: campaignList- List of Campaign that have the Campaign Number in leadCampaignNumSet
* @param: leadCampaignNameSet - Set of all the Campaign number on Lead records
* @param: campMemberToInserted - List of new records of CampaignMembers to inserted
* @param: campaignMapWithCampName - Map of Campaign where Campaign Number as key and Campaign record as value
* @return: Void                                           
*/
    public void createCampaignMember(){
        List<Lead> leadWithCamapaignName = new List<Lead>();
        List<Campaign> campaignList = new List<Campaign>();
        List<CampaignMember> campMemberToInserted = new List<CampaignMember>();
        Set<String> leadCampaignNameSet = new Set<String>();
        Map<String, Campaign> campaignMapWithCampName =new Map<String, Campaign>();
        
        for(Lead lead : recordNewList){
            if(lead.Campaign__c != Null){
                CampaignMember campaignMember = New CampaignMember();
                campaignMember.campaignId = lead.Campaign__c;
                campaignMember.LeadId = lead.Id;
                campMemberToInserted.add(campaignMember);}
            else{
                if(lead.Campaign_Name__c != Null){
                    leadCampaignNameSet.add(lead.Campaign_Name__c);
                    leadWithCamapaignName.add(lead);             
                }
            }
        }
        for(Campaign campaign: [SELECT Id, Name FROM Campaign WHERE Name IN:leadCampaignNameSet]){
            campaignMapWithCampName.put(campaign.Name, campaign);
        }
        
        for(Lead lead :leadWithCamapaignName){
            if(campaignMapWithCampName.get(lead.Campaign_Name__c) != Null){
                CampaignMember campMember = New CampaignMember();
                campMember.CampaignId = campaignMapWithCampName.get(lead.Campaign_Name__c).Id; 
                campMember.LeadId = lead.Id;
                campMemberToInserted.add(campMember);
            }
        }
        
        if(!campMemberToInserted.isEmpty()){
            Insert campMemberToInserted;
        }
    }
    
    //Added for Leasing Engine      
    public void callAssignmentEngineFr_Leasing(){   
        Set<String> setRecordTypes= new Set<String>();
        
        List<String> leasingRecTypes = new List<String>{system.label.Lead_Commercial_Unit_Rec_Type  ,system.label.Lead_Res_Unit_Record_Type  };
            Boolean runEngine= false;    
        for(Lead leadLoop : recordNewList){ 
            system.debug('rec name is '+ leadLoop.Record_Type_Name__c); 
            //setRecordTypes.add(leadLoop.Record_Type_Name__c);
            System.debug(leadLoop.CreatedBy.Profile.Name);
            //Modify by Sajid leadLoop.CreatedUserProfileName__c != 'Leasing Executive(New Lease)'
            if(leasingRecTypes.contains(leadLoop.Record_Type_Name__c) && leadLoop.CreatedUserProfileName__c != 'Leasing Executive(New Lease)'){
                runEngine = true; 
            }
        }   
        
        system.debug('runEngine is '+ runEngine);
        if(runEngine==true){
            callEngineBatch_Leasing();  
            
        }   
    }
    
    public void callEngineBatch_Leasing(){
        String leasing_engineName = system.label.Lead_Leasing_Engine  ;  
        AssignmentEngineInstance engineInstance;  
        for(Assignment_Engine_Setting__mdt settings : [Select Engine_ID__c from Assignment_Engine_Setting__mdt where SObject__c = 'Lead'
                                                       AND developerName=:leasing_engineName]){ 
                                                           engineInstance = new AssignmentEngineInstance(settings.Engine_ID__c);    
                                                           database.executebatch(engineInstance);   
                                                           
                                                       }   
    }
    
    
    /**
* Method Name: callAssignmentEngineWebsite
* Method Description: Calls engine assignment batch to change owner when lead record is created for website lead source because default lead is getting assigned
* @param: instanceList - List of engine instance  records to pass instance id to batch class
* * @return: Void                                           
*/
    public void callAssignmentEngineBatch(){
        
        Set<String> setRecordTypes= new Set<String>();
        for(Lead leadLoop : recordNewList){
            setRecordTypes.add(leadLoop.Record_Type_Name__c);
        }
        AssignmentEngineInstance engineInstance;
        
        for(Assignment_Engine_Setting__mdt settings : [Select Engine_ID__c from Assignment_Engine_Setting__mdt where SObject__c = 'Lead' AND DeveloperName='Lead_Sales']){
            
            engineInstance = new AssignmentEngineInstance(settings.Engine_ID__c);
            //Parameters of ExecuteBatch(context,BatchSize)
            database.executebatch(engineInstance);
        }
        
        
        
        //commented by huzefa
        /*    List<Engine_Instance__c> instanceList = new List<Engine_Instance__c>();
String engine = '';
Id recordtypeidsales = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Sales Lead').getRecordTypeId();
List<Lead> leadListUpdate = new List<Lead>();
for(Lead l : recordNewList){
if((l.LeadSource == 'Website' || l.LeadSource == 'Employee Referral') && l.RecordTypeId == recordtypeidsales){
engine = 'Sales';  
}else if((l.LeadSource == 'Website' || l.LeadSource == 'Employee Referral') && l.RecordTypeId <> recordtypeidsales){
engine = 'Leasing'; 
}
system.debug('Leasing'+engine);
system.debug('l.Lead_Stand__c'+l.Lead_Stand__c);
if((l.LeadSource == 'Website' ||  l.LeadSource == 'Employee Referral') && l.Lead_Stand__c == False){
Lead lObj = new Lead();
lObj.Lead_Stand__c = true;
lObj.Id = l.id;
leadListUpdate.add(lObj);
}
}
instanceList = [select id,Engine__c from Engine_Instance__c where Engine__c =:engine];
if(leadListUpdate <> null && leadListUpdate.size() > 0){
update leadListUpdate;
system.debug('leadListUpdate'+leadListUpdate);
system.debug('leadListUpdate'+instanceList[0].Id);
AssignmentEngineController.assignOnwer(instanceList[0].Id, leadListUpdate);
}
*/
        
    }
    /**
* Method Name: callAssignmentEngineBatch
* Method Description: Calls engine assignment batch to change owner when lead record is created
* @param: instanceList - List of engine instance  records to pass instance id to batch class
* * @return: Void                                           
*/
    public void callAssignmentEngineBatchTst(){
        
        
        
        //commented by huzefa
        /*
Id recordtypeidsales = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Sales Lead').getRecordTypeId();

List<Engine_Instance__c> instanceList = new List<Engine_Instance__c>();
String engine = '';
for(Lead l : recordNewList){
if(l.LeadSource <>'Stands'&& l.LeadSource <>
'Salesman' && l.LeadSource <> 'Website' && l.LeadSource <> 'Employee Referral' && l.RecordTypeId == recordtypeidsales){
engine = 'Sales';  
}else if(l.LeadSource <>'Stands'&& l.LeadSource <>
'Salesman' && l.LeadSource <> 'Website' && l.LeadSource <> 'Employee Referral' && l.RecordTypeId <> recordtypeidsales){
engine = 'Leasing'; 
}

}
system.debug('engine'+engine);
instanceList = [select id,Engine__c from Engine_Instance__c where Engine__c =:engine];
system.debug('engine'+instanceList);
if(instanceList <> null && instanceList.size() > 0){
AssignmentEngineController.assignOnwer(instanceList[0].Id, recordNewList);
} */
    }
    
    /**
* Method Name: updateMobileNumber
* Method Description: This method is used for lead records getting from eistein bot,to spit comma from phone field.

* * @return: Void                                           
*/
    public void updateMobileNumber(){
        for(Lead l : recordNewList){
            if(l.Einstein_Bot__c == true){
                String mb = l.Phone;
                mb = mb.replaceAll(',','');
                system.debug('mb'+mb);
                l.MobilePhone = mb;
                l.Phone = '';
                
            }
        }
        
    }
    /**
* Method Name: UpdateCampaignMembers
* Method Description: Update Campaign Member when campaign gets changed
* @param: CampaignMemberListToDelete - List of campaign member to delete
* @param: CampaignMemberListToInsert - List of campaign member to insert
* @param: leadList - List of lead record to update campaign member
* * @return: Void                                           
*/
    public void UpdateCampaignMember(){
        Set<Id> leadIds = New Set<Id>();
        List<Lead> leadList = New List<Lead>();
        List<CampaignMember> CampaignMemberListToDelete = New List<CampaignMember>();
        List<CampaignMember> CampaignMemberListToInsert = New List<CampaignMember>();
        
        for(Lead lead:recordNewList){
            If(lead.Campaign__c != recordOldMap.get(lead.Id).Campaign__c){
                leadIds.add(lead.Id);
                if(lead.Campaign__c != Null){
                    leadList.add(lead);
                }
            }
        }
        CampaignMemberListToDelete = [SELECT Id, LeadId FROM CampaignMember WHERE LeadId IN:leadIds];
        if(!CampaignMemberListToDelete.isEmpty()){
            delete CampaignMemberListToDelete;
        }
        for(Lead lead:leadList){
            CampaignMember campMember = New CampaignMember();
            if(lead.Campaign__c != Null){
                campMember.CampaignId = lead.Campaign__c;
            }
            campMember.LeadId = lead.Id;
            system.debug('Campaign------>'+campMember);
            CampaignMemberListToInsert.add(campMember);
            system.debug('list--->'+CampaignMemberListToInsert);
        }
        If(!CampaignMemberListToInsert.isEmpty()){
            insert CampaignMemberListToInsert;
            system.debug('List after Insert----->'+CampaignMemberListToInsert);
        }
    }
    /* * Method Name: LeadSLA
* Method Description: Update Lead SLA time as SLA Expected Time 
* @param:  flagToCheckInBuisnessHour - To check the cCreated Date value whether it is in Business Hours
* @param: isWithInBusinessHour  - To check the callback request time value whether it is in Business Hours
* @param: nextBusinessDayForCallBackRequestTime  - 
* @param: leadList - List of lead record to update SLA Expected Time
* * @return: Void                                           
*/
    public void LeadSLA(){ 
        boolean flagToCheckInBuisnessHour;
        boolean isWithInBusinessHour;
        datetime nextBusinessDayForCallBackRequestTime;
        datetime nextBusinessDayForCreatedDate;
        List<lead> Leadlist =  new List<Lead>();
        BusinessHours busibessHour = [select id from businesshours where IsDefault=true];
        
        for(Lead lead : [SELECT Id,CreatedDate,SLA_Expected_Time__c,LeadSource, Call_Back_Request_Time__c From Lead Where Id IN: recordNewList]){
            if(lead.SLA_Expected_Time__c == Null){
                if( lead.Call_Back_Request_Time__c != Null && lead.LeadSource == 'Website' ){ 
                    isWithInBusinessHour = BusinessHours.isWithin(busibessHour.id, lead.Call_Back_Request_Time__c);
                    if(isWithInBusinessHour == true){
                        lead.SLA_Expected_Time__c = lead.Call_Back_Request_Time__c.addMinutes(60);
                    }
                    else{
                        nextBusinessDayForCallBackRequestTime =  BusinessHours.nextStartDate(busibessHour.id, lead.Call_Back_Request_Time__c);
                        lead.SLA_Expected_Time__c = nextBusinessDayForCallBackRequestTime.addMinutes(60);
                    }
                    Leadlist.add(lead);
                }
                else {
                    flagToCheckInBuisnessHour = BusinessHours.isWithin(busibessHour.id, lead.CreatedDate);
                    if(flagToCheckInBuisnessHour == true){
                        lead.SLA_Expected_Time__c = lead.CreatedDate.addMinutes(60);
                    }
                    else{
                        nextBusinessDayForCreatedDate =  BusinessHours.nextStartDate(busibessHour.id, lead.CreatedDate);
                        lead.SLA_Expected_Time__c = nextBusinessDayForCreatedDate.addMinutes(60);
                    }
                    Leadlist.add(lead);
                }
            }
        }
        if(Leadlist != null && Leadlist.size() > 0){
            update Leadlist;
        }
    }
    
    public void syncConvertedAccountToERP(){
        List<Account> accountList = new List<Account>();
        for(Lead lead : recordNewList){
            if(lead.IsConverted && lead.isConverted != recordOldMap.get(lead.Id).isConverted){
                if(lead.ConvertedAccountId != null){
                    Account acc = new Account(Id = lead.ConvertedAccountId, Send_Customer_to_ERP__c = true);
                    accountList.add(acc);
                }
            }
        }
        
        if(!accountList.isEmpty()){
            update accountList;
        }
    }
    
    /* Added BY Manish 28 April*/
    public void updateLead(){
       //Added By Sajid
        Boolean callLeasingEngineBatch = false;
        List<String> leasingRecTypes = new List<String>{system.label.Lead_Commercial_Unit_Rec_Type  ,system.label.Lead_Res_Unit_Record_Type  };
        for(Lead ld : recordNewList){
            if(recordOldMap.get(ld.Id).Status == 'New' && ld.Move_In_Date__c != null && ld.Budget__c != null && ld.How_much_time_lead_requires_for_decision__c != null){
                ld.Status = 'Contacted';
            }
            //Added By Sajid
            if((recordOldMap.get(ld.ID)).Inventory_Project__c !=ld.Inventory_Project__c  && leasingRecTypes.contains(ld.Record_Type_Name__c)){
                callLeasingEngineBatch = true;
                ld.Assigned_Resource__c = null;
                system.debug('callLeasingEngineBatch is '+ callLeasingEngineBatch);
            }
        }  
        //Added By Sajid
        if(callLeasingEngineBatch==true){
            system.debug('In condition');
            callEngineBatch_Leasing(); 
        }   
    }
    
    public void updateRecordTypeName(){
        //commented by Mamta-needs confirmation 
        /* for(Lead lead : recordNewList){
if(lead.Record_Type__c != Null){

Map<String, Schema.SObjectType> m = Schema.getGlobalDescribe() ;
Schema.SObjectType s = m.get('Lead') ;
Schema.DescribeSObjectResult cfrSchema = s.getDescribe() ;
Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
Id rtId = RecordTypeInfo.get(lead.Record_Type__c).getRecordTypeId();

//Id recordTypeId2 = Schema.SObjectType.Calling_List__c.getRecordTypeInfosByDeveloperName().get(lead.Record_Type__c).getRecordTypeId();

System.debug('@@>> '+ rtId);

if(rtId != Null){
lead.RecordTypeId = rtId;
}

}
}*/
    }
    
    //modified by jaskiran to update SLA
    //Update Lead SLA time as SLA Expected Time 
    public  void updateSLA(){
        boolean flagToCheckInBuisnessHour;
        boolean isWithInBusinessHour;
        datetime nextBusinessDayForCallBackRequestTime;
        datetime nextBusinessDayForCreatedDate;
        Integer slaBusinessMinutes = Integer.valueOf(System.Label.SalesExecutiveSLAHours);
        List<lead> Leadlist =  new List<Lead>();
        BusinessHours busibessHour = [select id from businesshours where IsDefault=true];
        Map<Id,String> mapOfUserProfile = new Map<ID,String>();
        for(User u : [Select Id,profile.Name FROM User where IsActive = true and profile.Name = 'Sales Executive']){
            mapOfUserProfile.put(u.Id,u.Profile.Name); 
        }
        Set<String> ownerIds = new Set<String>();
        for(Lead l : recordNewList){
            if(l.SLA_Expected_Time__c == null){
                Datetime slaDate;
                if( l.Call_Back_Request_Time__c != Null && l.LeadSource == 'Website' ){ 
                    isWithInBusinessHour = BusinessHours.isWithin(busibessHour.id, l.Call_Back_Request_Time__c);
                    nextBusinessDayForCallBackRequestTime =  BusinessHours.nextStartDate(busibessHour.id, l.Call_Back_Request_Time__c);
                    slaDate = l.Call_Back_Request_Time__c;
                    
                } else {
                    flagToCheckInBuisnessHour = BusinessHours.isWithin(busibessHour.id, l.CreatedDate);
                    nextBusinessDayForCreatedDate =  BusinessHours.nextStartDate(busibessHour.id, l.CreatedDate);
                    slaDate = l.CreatedDate;
                }
                if(isWithInBusinessHour == true){
                    l.SLA_Expected_Time__c = slaDate.addMinutes(60);
                } else {
                    l.SLA_Expected_Time__c = slaDate.addMinutes(60); //nextBusinessDayForCreatedDate.addMinutes(60); 
                }
            }   
            
            if(l.Status == 'Qualified' && l.OwnerId != recordOldMap.get(l.Id).OwnerId){
                if(mapOfUserProfile.size() > 0 && mapOfUserProfile != null){
                    if(mapOfUserProfile.containsKey(l.OwnerId)){
                        if(mapOfUserProfile.get(l.OwnerId) == 'Sales Executive'){
                            flagToCheckInBuisnessHour = BusinessHours.isWithin(busibessHour.id, system.now());  
                            if(flagToCheckInBuisnessHour){
                                l.SLA_Expected_Time__c = system.now().addMinutes(slaBusinessMinutes);
                                l.SLA_Response_Time__c = null;
                                
                            } else {
                                Datetime nextAvailBusinesStartDate = BusinessHours.nextStartDate(busibessHour.id, system.now());
                                l.SLA_Expected_Time__c = nextAvailBusinesStartDate.addMinutes(slaBusinessMinutes);
                                l.SLA_Response_Time__c = null;
                            }
                        }
                    }
                }
            }
            // system.debug('Integer.valueOf((l.SLA_Expected_Time__c).getTime() - system.now().getTime())'+Integer.valueOf((l.SLA_Expected_Time__c).getTime() - system.now().getTime()));
            if(Integer.valueOf((l.SLA_Expected_Time__c).getTime() - system.now().getTime()) < 0 && recordOldMap.get(l.Id).Status == 'Qualified' && l.Status == 'Qualified'){
                if(mapOfUserProfile.containsKey(l.OwnerId)){
                    if(mapOfUserProfile.get(l.OwnerId) == 'Sales Executive'){
                        for(Id userId : mapOfUserProfile.KeySet()){
                            if(l.OwnerId != userId && recordOldMap.get(l.Id).OwnerId != userId){
                                l.OwnerId = userId;
                                break;
                            }
                        } 
                    }
                }
            }
        }
    }
    
    public void AssignRecordtoSales(){
        List<Lead> updateLead = new List<Lead>();
        //Group gp = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Lead_Queue' LIMIT 1];
        String queueId = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Sales_Team_Queue' LIMIT 1].Id;   
        for(Lead l : recordNewList){
            lead lupdate = new Lead();
            lupdate.Id = l.Id;
            if(l.LeadSource == 'Employee Referral' && l.Interested_In__c == 'Sales' ){
                lupdate.OwnerId = queueId;
            }
            updateLead.add(lupdate);
        }
        if(updateLead.size() > 0){
            update updateLead;
        }
    }
    
    //modified by jaskiran as part of duplication logic
    public  void checkLeadDuplication(){
        Set<String> setOfEmails = new Set<String>();
        Set<String> setOfPhones = new Set<String>();
        for(Lead l : recordNewList){
            if(String.isNotBlank(l.Email)){
                setOfEmails.add(l.Email);
            }
            if(String.isNotBlank(l.MobilePhone)){
                setOfPhones.add(l.MobilePhone);
            }
        }
        // Group gp = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Lead_Queue' LIMIT 1];
        String queueId = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Sales_Team_Queue' LIMIT 1].Id;   
        
        Map<String,Lead> mapOfLeadWithSameProject = new Map<String,Lead>();
        Map<String,Lead> mapOfLeadProject = new Map<String,Lead>();
        if(setOfPhones.size() > 0 && setOfEmails.size() > 0){
            for(Lead l : [Select Id,MobilePhone,Email,Inventory_Project__c,Status,OwnerId,Record_Type_Name__c  FROM Lead where RecordType.DeveloperName = 'Sales_Lead' and IsConverted = false AND EMAIL IN: setOfEmails AND MobilePhone IN: setOfPhones]){
                mapOfLeadWithSameProject.put(l.MobilePhone+l.Email+l.Inventory_Project__c,l);
                mapOfLeadProject.put(l.MobilePhone+l.Email,l);
            }
            
            
            for(Lead l : recordNewList){
                if(l.LeadSource == 'Employee Referral' && l.Interested_In__c == 'Sales' ){
                    l.OwnerId = queueId;
                }
                if(l.Record_Type_Name__c == 'Sales_Lead'){
                    if(mapOfLeadWithSameProject.size() > 0 && mapOfLeadWithSameProject != null){
                        if(l.Inventory_Project__c != null ){
                            if(mapOfLeadWithSameProject.containsKey(l.MobilePhone+l.Email+l.Inventory_Project__c)){
                                if(mapOfLeadWithSameProject.get(l.MobilePhone+l.Email+l.Inventory_Project__c).Status != 'Disqualified'){
                                    l.Status = 'Disqualified';
                                    l.Disqualification_Reason__c = 'Old Leads';
                                } 
                                l.OwnerId = mapOfLeadWithSameProject.get(l.MobilePhone+l.Email+l.Inventory_Project__c).OwnerId;
                                l.Sales_Lead_Duplication__c  = true;
                            }    
                        }
                    }
                    if(mapOfLeadProject.size() > 0 && mapOfLeadProject != null){
                        if(mapOfLeadProject.containsKey(l.MobilePhone+l.Email)){
                            l.OwnerId = mapOfLeadProject.get(l.MobilePhone+l.Email).OwnerId;
                            l.Sales_Lead_Duplication__c  = true;
                        }     
                    }
                }
            }
        }
    }
    
    //modified by jaskiran
    public void validateStatusChange() {
        Set<Id> leadIds = new Set<Id>();
        for(Lead l : recordNewList){
            if(l.Profile_Name__c == 'Lead Qualifier' || l.Profile_Name__c == 'Sales Executive' || l.Profile_Name__c == 'System Administrator' ){
                if(recordOldMap.get(l.Id).status != l.Status && l.Record_Type_Name__c == 'Sales_Lead' && (!l.Follow_Up_Done__c) ){
                    // l.Lead_Sla__c = true;
                }
                // if(l.Status = 'No response'){
                leadIds.add(l.Id); 
                //}
            }
            
        }
        if(leadIds.size() > 0){
            Map<Id,List<Task>> mapOftasks = new Map<Id,List<Task>>();
            for(Task t : [Select Id,whoId FROM Task where  status = 'Open' AND whoId IN: leadIds]){
                if(mapOftasks.containsKey(t.whoId)){
                    mapOftasks.get(t.WhoId).add(t); 
                } else {
                    mapOftasks.put(t.WhoId, new List<task> {t});
                }
            }
            List<Task> createTasks = new List<Task>();
            for(Lead l : recordNewList){
                if(l.Status == 'No response' && l.Follow_Up_Remarks__c != recordOldMap.get(l.Id).Follow_Up_Remarks__c){
                    // system.debug('l.Status'+l.Status);
                    // system.debug('l.Follow_Up_Remarks__c'+l.Follow_Up_Remarks__c);
                    //system.debug('mapOftasks.get(l.Id).size()'+mapOftasks.get(l.Id).size());
                    if(mapOftasks.containsKey(l.Id)){
                        if(mapOftasks.get(l.Id).size()<3){
                            Task tsk = new Task();  
                            tsk.Subject='Review follow up remarks and contact the customer';    
                            tsk.Priority='High';    
                            tsk.Status ='Open'; 
                            tsk.ActivityDate = system.today().addDays(1);   
                            tsk.Time_Slot__c = l.Call_Back_Request_Time__c; 
                            tsk.WhoID = l.ID;  
                            if(l.Profile_Name__c == 'Lead Qualifier' || l.Profile_Name__c == 'System Administrator'){
                                tsk.OwnerId = l.OwnerId;  
                            } 
                            if(l.Profile_Name__c == 'Sales Executive'){
                                tsk.OwnerId = l.CreatedById;  
                            }
                            createTasks.add(tsk);  
                        }
                        if(mapOftasks.get(l.Id).size() == 3){
                            l.Status = 'Disqualified';
                            l.Disqualification_Reason__c = 'No Response';
                        }
                    }
                }
                
            }
            if(createTasks.size() > 0){
                insert createTasks;
            }
        }
    }
    
    //modified by jaskiran
    public void updateLeadIntegration(){
        Set<String> masterCommunityNames = new Set<String>();
        Set<String> setOfprojects = new Set<String>();
        Map<String,String> mapOfmasterCommunity = new Map<String,String>();
        Map<String,String> mapOfProjects = new Map<String,String>();
        for(Lead lead : recordNewList){
            if(recordOldMap != null ){
                if(lead.Record_Type__c != recordOldMap.get(lead.Id).Record_Type__c && String.isNotBlank(lead.Record_Type__c)){
                    if((lead.Record_Type__c).contains('Commercial Unit')){
                        lead.Interested_In__c = 'Commercial Unit';
                    }
                    if((lead.Record_Type__c).contains('Residential Leasing Unit')){
                        lead.Interested_In__c = 'Residential Leasing';
                    }
                    if((lead.Record_Type__c).contains('Sales Lead')){
                        lead.Interested_In__c = 'Sales';
                    }
                }
                if(String.isNotBlank(lead.Master_Community_Name__c) && lead.Master_Community_Name__c != recordOldMap.get(lead.Id).Master_Community_Name__c){
                    masterCommunityNames.add(lead.Master_Community_Name__c);
                }
                if(String.isNotBlank(lead.Project_Name__c) && lead.Project_Name__c != recordOldMap.get(lead.Id).Project_Name__c){
                    setOfprojects.add(lead.Project_Name__c);
                }
            } else{
                if(String.isNotBlank(lead.Master_Community_Name__c)) {
                    masterCommunityNames.add(lead.Master_Community_Name__c);
                }
                if(String.isNotBlank(lead.Project_Name__c) ) {
                    setOfprojects.add(lead.Project_Name__c);  
                }
                if(String.isNotBlank(lead.Record_Type__c)){
                    lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(lead.Record_Type__c).getRecordTypeId();
                }
            }
            
        }
        
        for(Project__c  proj : [Select Id,Name FROM Project__c where Name IN: setOfprojects]){
            mapOfProjects.put(proj.Name,proj.Id);
        }
        for(Master_Community2__c   mastercOm : [Select Id,Name FROM Master_Community2__c  where Name IN: masterCommunityNames]){
            mapOfmasterCommunity.put(mastercOm.Name,mastercOm.Id);
        }
        
        for(Lead lead : recordNewList){
            if(mapOfProjects.size() > 0 && mapOfProjects != null){
                lead.Inventory_Project__c = mapOfProjects.get(lead.Project_Name__c);
            }
            if(mapOfmasterCommunity.size() > 0 && mapOfmasterCommunity != null){
                lead.Master_Community_lookup__c = mapOfmasterCommunity.get(lead.Master_Community_Name__c);
            }
            
            if(recordOldMap != null){
                if((lead.Country_Code__c != recordOldMap.get(lead.Id).Country_Code__c) || (lead.MobilePhone != recordOldMap.get(lead.Id).MobilePhone)){
                    if(lead.MobilePhone!=null){
                      lead.Mobile_Number__c = String.isNotEmpty(String.valueOf(lead.Country_Code__c)) ? String.valueOf(lead.Country_Code__c) + String.valueOf(lead.MobilePhone) : ''  + String.valueOf(lead.MobilePhone);
                    }
                }
            }
            if(String.isBlank(lead.Mobile_Number__c)){
                if(lead.MobilePhone!=null){
                 lead.Mobile_Number__c = String.isNotEmpty(String.valueOf(lead.Country_Code__c)) ? String.valueOf(lead.Country_Code__c) + String.valueOf(lead.MobilePhone) : '' + String.valueOf(lead.MobilePhone); 
                }
            }
        }
        
        
    }
    
    /*Added BY Mamta 16 May */ 
    public void tagLeadQualifier(){
        for(lead ld : recordNewList){
            system.debug('inside tagLeadQualifier');
            system.debug('ld.OwnerId'+ld.OwnerId);
            system.debug('ld.Status'+ld.Status);
            system.debug('recordOldMap.get(ld.Id).Status'+recordOldMap.get(ld.Id).Status);
            if(ld.Status=='Qualified' && recordOldMap.get(ld.Id).Status!=ld.Status)
                ld.Qualified_By__c = ld.OwnerId;
        }    
    }
    
    /**
* Author: Sajid
* Method Name: updateDateFields
* Usage: This method is used to convert date fields to text for using in duplicate matching rules.
* * @return: Void                                           
*/
    public void updateDateFields(String callingContext){
        for(Lead l : recordNewList){
            if(l.Record_Type_Name__c == 'Residential_Leasing_Shop'){
                if(callingContext == 'Insert'){
                    
                    if(String.isNotEmpty(String.valueOf(l.Trade_License_Issue_Date__c))){
                        l.Value_of_Issue_Date__c = String.valueOf(l.Trade_License_Issue_Date__c);
                    }
                    if(String.isNotEmpty(String.valueOf(l.DOB_Date_of_Birth__c))){
                        l.Value_of_DOB__c = String.valueOf(l.DOB_Date_of_Birth__c);
                    }
                    
                }else if(callingContext == 'Update'){
                    
                    if(l.Trade_License_Issue_Date__c != recordOldMap.get(l.Id).Trade_License_Issue_Date__c){
                        l.Value_of_Issue_Date__c = String.valueOf(l.Trade_License_Issue_Date__c);
                    }
                    if(l.DOB_Date_of_Birth__c != recordOldMap.get(l.Id).DOB_Date_of_Birth__c){
                        l.Value_of_DOB__c = String.valueOf(l.DOB_Date_of_Birth__c);
                    }
                    
                }
            } 
        }  
    }
    
    /* * Author: Sajid
* Method Name: updateCallbackResponseDateTime
* Method Description: Update Call Back Request Time  
* * @return: Void                                           
*/
    public void updateCallbackResponseDateTime(String callingcontext){
        for(Lead l : recordNewList){
            if(CallingContext == 'Insert'){
                if(String.isNotEmpty(l.Callback_Request_Slot__c)){
                    Date todayDate = System.today();
                    String[] requestSlot = l.Callback_Request_Slot__c.split('-');
                    if(requestSlot[0].contains('9')){
                        l.Call_Back_Request_Time__c =  datetime.newInstance(todayDate.year(), todayDate.month(), todayDate.day() + 1, 9, 0, 0);
                    }else if(requestSlot[0].contains('12')){
                        l.Call_Back_Request_Time__c =  datetime.newInstance(todayDate.year(), todayDate.month(), todayDate.day() + 1, 12, 0, 0);
                    }
                }
            }else  if(CallingContext == 'Update'){
                if(l.Callback_Request_Slot__c != recordOldMap.get(l.Id).Callback_Request_Slot__c){
                    Date todayDate = System.today();
                    String[] requestSlot = l.Callback_Request_Slot__c.split('-');
                    if(requestSlot[0].contains('9')){
                        l.Call_Back_Request_Time__c =  datetime.newInstance(todayDate.year(), todayDate.month(), todayDate.day() + 1, 9, 0, 0);
                    }else if(requestSlot[0].contains('12')){
                        l.Call_Back_Request_Time__c =  datetime.newInstance(todayDate.year(), todayDate.month(), todayDate.day() + 1, 12, 0, 0);
                    }
                }
            }
            
        }
    }
    
    /* * Author: Sajid
* Method Name: decideToCheckDuplicate
* Method Description: Decide duplicate lead should be checked or not  
* * @return: Void                                           
*/
    public void decideToCheckDuplicate(String CallingContext){
        List<String> leasingRecTypes = new List<String>{system.label.Lead_Commercial_Unit_Rec_Type  ,system.label.Lead_Res_Unit_Record_Type  };
            for(Lead ld : recordNewList){
                if(ld.CreatedUserProfileName__c =='API Profile' && leasingRecTypes.contains(ld.Record_Type_Name__c)){ 
                    if(CallingContext == 'Insert'){
                        ld.Duplicate_Checbox__c = True; 
                    }else if(CallingContext == 'Update'){
                        ld.Duplicate_Checbox__c = False; 
                    }
                }  
            }
    }
    
     /* * Author: Sajid
     * Method Name: createQualifiedTask
    * Method Description: Create Qualified task for leasing 
    * * @return: Void                                           
    */
    public void createQualifiedTask(List<Lead> leadList){
        List<Task> taskList = new List<Task>();
        NakheelTaskSubject__mdt  taskSubject = [SELECT Subject__c FROM NakheelTaskSubject__mdt WHERE DeveloperName = 'Leasing_Lead_Qualified_Task' limit 1]; //Added by Sajid
        for(Lead ld : leadList){   
            Task task = new Task();  
            task.Subject= taskSubject.Subject__c;   
            task.Priority='High';    
            task.Status ='Open'; 
            task.ActivityDate = System.today();  
            task.Time_Slot__c = ld.Call_Back_Request_Time__c;    
            task.WhoID = ld.ID;  
            task.OwnerId = ld.OwnerId;
            task.Task_Type__c = 'Qualified';
            task.Parent_Flag_API_Name__c = 'SLA_Response_Time_For_Qualified__c';
            taskList.add(task);      
            
        }   
        
        if(!taskList.isEmpty()){    
            try{    
                insert taskList;    
            }   
            catch(Exception ex){    
                system.debug('error is '+ ex.getMessage() + ' at Line '+ ex.getLineNumber());   
                
            }   
            
        }     
    }
    
        //modified by jaskiran as part of sales lead SLA
    //Update Lead SLA time as SLA Expected Time added by manish
    public  void updateQualifiedSLA(){
        boolean flagToCheckInBuisnessHour;
        boolean isWithInBusinessHour;
        datetime nextBusinessDayForCallBackRequestTime;
        datetime nextBusinessDayForCreatedDate;
        Integer slaBusinessMinutes = Integer.valueOf(System.Label.SalesExecutiveSLAHours);
        List<lead> Leadlist =  new List<Lead>();
        BusinessHours busibessHour = [select id from businesshours where IsDefault=true];
        Map<Id,String> mapOfUserProfile = new Map<ID,String>();
        for(User u : [Select Id,profile.Name FROM User where IsActive = true and profile.Name = 'Sales Executive']){
            mapOfUserProfile.put(u.Id,u.Profile.Name); 
        }
        
        Set<String> ownerIds = new Set<String>();
        for(Lead l : recordNewList){
            if(l.SLA_Expected_Time_For_Qualified__c == Null){
                Datetime slaDate;
                if( l.Call_Back_Request_Time__c != Null && l.LeadSource == 'Website' ){ 
                    isWithInBusinessHour = BusinessHours.isWithin(busibessHour.id, l.Call_Back_Request_Time__c);
                    nextBusinessDayForCallBackRequestTime =  BusinessHours.nextStartDate(busibessHour.id, l.Call_Back_Request_Time__c);
                    slaDate = l.Call_Back_Request_Time__c;
                    
                } else {
                    flagToCheckInBuisnessHour = BusinessHours.isWithin(busibessHour.id, l.CreatedDate);
                    nextBusinessDayForCreatedDate =  BusinessHours.nextStartDate(busibessHour.id, l.CreatedDate);
                    slaDate = l.CreatedDate;
                }
                if(isWithInBusinessHour == true){
                    l.SLA_Expected_Time_For_Qualified__c = slaDate.addMinutes(180);
                } else {
                    l.SLA_Expected_Time_For_Qualified__c = slaDate.addMinutes(180); //nextBusinessDayForCreatedDate.addMinutes(180); 
                }
            }         
        }
    }
     /* Author: Sajid
     * Method Name: linkDocToAccount
     *  Method Description: Attach leasing documents to account at the time of lead conversion
     *  @return: Void                                           
     */
    public void linkDocToAccount(){
        try{ 
            
            List<String> leasingRecTypesList = new List<String>{system.label.Lead_Commercial_Unit_Rec_Type  ,system.label.Lead_Res_Unit_Record_Type  };
                Set<ID> leadIdSet = new Set<ID>();
            Map<Id, String> leadRecordTypeMap = new Map<Id, String>();
            for(Lead ld : recordNewList){
                if(ld.Status == 'Converted' && leasingRecTypesList.contains(ld.Record_Type_Name__c) && String.isNotEmpty(ld.Company) ){
                    leadIdSet.add(ld.Id); 
                    leadRecordTypeMap.put(ld.Id, ld.Record_Type_Name__c);
                }
            }
            
            if(leadIdSet.size() > 0){
                List<Document__c> docList = new List<Document__c>(); 
                for(Document__c doc: [select Id,Expiry_Date__c,Issue_Date__c,Account__c,Leads__r.Name,Leads__r.ConvertedAccountId , Document_Type__c,Name,Document_Name__c,Document_Number_Mandatory__c,
                                      Expiry_Date_Mandatory__c,Issue_Date_Mandatory__c ,Is_Document_Uploaded__c from Document__c 
                                      where Leads__c = :leadIdSet]){
                                          
                                          String recordTypeName = leadRecordTypeMap.get(doc.Leads__c);
                                          if(recordTypeName == system.label.Lead_Commercial_Unit_Rec_Type){
                                              if(doc.Document_Type__c == 'Trade License' && doc.Is_Document_Uploaded__c){
                                                  doc.Account__c = doc.Leads__r.ConvertedAccountId;
                                                  docList.add(doc);
                                              }else if(doc.Document_Type__c != 'Trade License'){
                                                  doc.Account__c = doc.Leads__r.ConvertedAccountId;
                                                  docList.add(doc);
                                              }  
                                          }else if(recordTypeName == system.label.Lead_Res_Unit_Record_Type){
                                              if(doc.Document_Type__c == 'Passport' && doc.Is_Document_Uploaded__c){
                                                  doc.Account__c = doc.Leads__r.ConvertedAccountId;
                                                  docList.add(doc);
                                              }else if(doc.Document_Type__c == 'Visa' && doc.Is_Document_Uploaded__c){
                                                  doc.Account__c = doc.Leads__r.ConvertedAccountId;
                                                  docList.add(doc);
                                              }else if(doc.Document_Type__c == 'Emirates Id' && doc.Is_Document_Uploaded__c){
                                                  doc.Account__c = doc.Leads__r.ConvertedAccountId;
                                                  docList.add(doc);
                                              }
                                          }
                                      }
                
                if(docList.size() > 0){
                    update docList;
                }
            }
            
            
        }Catch(Exception ex){
            System.debug('Error '+ex.getMessage() +' '+ex.getLineNumber());
        }
    }
}