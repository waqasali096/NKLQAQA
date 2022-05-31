/**************************************************************************************************
* Name               : OpportunityTriggerHandler                                                      
* Description        : Handler class for Opportunity Trigger
* Created Date       : 09/01/2022                                                                 
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     09/01/2022      Initial Draft.                                               
**************************************************************************************************/
//Comment by Swapnil - neeed to use Business_Unit__c instead of master_community__c and use unit_Status__c instead of sales_status__c and leasing_status__c
public class OpportunityTriggerHandler {
    List<Opportunity> recordNewList = new List<Opportunity>();
    List<Opportunity> recordOldList = new List<Opportunity>();
    Map<Id, Opportunity> recordNewMap = new Map<Id, Opportunity>();
    Map<Id, Opportunity> recordOldMap = new Map<Id, Opportunity>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = true;
    public OpportunityTriggerHandler( List<Opportunity> newList, 
                                     List<Opportunity> oldList, 
                                     Map<Id, Opportunity> newMap, 
                                     Map<Id, Opportunity> oldMap, 
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
        //checkPOAAdded(recordNewList);
        populateSalesOppFileds();
        generateLeasingNumber(recordNewList,null);
        checkSendOpportunityToERP();
        populateLeaseEndData();
        popolateSalesEcecutive();
        updateEmail();
        populateProjectName('Insert'); // added by sajid
    }
    
    /* @version-V1 : Add AfterInsertEvent function to create document__c record after insert of opportunity record.*/
    public void AfterInsertEvent(List<Opportunity> newOppList) {
        System.debug('In After Insert Event of Opportunity');
        GenericTriggerHandler.createDocRecord(newOppList,'Opportunity');
        createOppPaymentMilestones();
        createAdditionalCharges();
        createDLDOfferSales();
        createOpportunityERP();
        //createSalesOrderERP();
        checkForPOA(newOppList,recordNewMap);
        //AddUpdateBookingMileStone();
        callAssignmentEngineBatchAfterInsert();
        
        //Added by Ashams for changing Opportunity Name after lead conversion in Sales
        generateOpportunityNameSales();
    }
    
    /* @version-V1 : Add BeforeUpdateEvent function to validate doc record before updation of opportunity record*/
    public void BeforeUpdateEvent(List<sObject> newOppList,Map<Id, sObject> recordOldMap,Map<Id, sObject> recordNewMap) {
        ownerChange();
        GenericTriggerHandler.validateDocRecord(newOppList,recordOldMap,recordNewMap,'Opportunity');
        
        updateDiscount();
        populateLeaseEndData();
        updateDLDStatusSales();
        lockOppRecord();
        generateLeasingNumber(newOppList,recordOldMap);
        unitReservationStageAutomations();
        createTaskSalesExecutive();
        //checkPOAAdded(newOppList);
        checkSendOpportunityToERP();
        updateEmail();
        populateProjectName('Update'); //Added by Sajid
    }
    
    public void BeforeDeleteEvent() {
    }
    
    public void AfterUpdateEvent(){
        
        //AddUpdateBookingMileStone(); Commented by Karishma as booking amount is not required under installments
        generateOpportunityName();
        System.debug('@@@@@ Phase 1 @@@@@');
        
        //GenericTriggerHandler.createDocRecord(recordNewList,'Opportunity');
        moveBookingFormToDocument(); 
       // updatestatus(); commented by dilip as part of SOQL error fix, as this method is not doing anything. 
        createSPARecord();
        contractGenerationStageAutomations();
        createAdminContributors();
        //createBrokerContributors();
        createOppPaymentMilestones();
        createAdditionalCharges();
        createDLDOfferSales();
        reviseMilestones();
        updatePaymentMilestoneSPP();
        updateUnitStatus();
        revisedPMRollback();
        SPAChecksUpdate();
        completeDocUploadTask();
        createTokenAmountReceipt();
        updateBookingReservation();
        //Kshitij Changes: Price per unit changes
        UpdateInstallmentAmount(recordNewList, recordOldMap);
        for(Opportunity oppRecord : recordNewList){//added check to remove Quick booking Opportunity by Ashams
            if(((recordOldMap.get(oppRecord.id).stageName != 'Booking Initiated' && recordNewMap.get(oppRecord.id).stageName == 'Booking Initiated' ) || (recordOldMap.get(oppRecord.id).stageName != 'Booking Confirmed' && recordNewMap.get(oppRecord.id).stageName == 'Booking Confirmed')) && recordNewMap.get(oppRecord.id).RecordType.DeveloperName!=null && recordNewMap.get(oppRecord.id).RecordType.DeveloperName!='Quick_Book'){
                Unit_HandlerSMS.callSmsApiFromOpportunity(recordNewList);
            }
        }
        createOpportunityERP();
        //createSalesOrderERP();
        System.debug('@@@');
        createLeasingProperty();
        System.debug('@@@');
        checkForPOA(recordNewList,recordNewMap);
        updateUnitStatusOnClosedLost( recordNewList, recordOldMap );
        makeSPAReadOnlyOnClosedLost( recordNewList, recordOldMap );
        makeSPAReadOnlyOnSPAExecuted( recordNewList, recordOldMap ); //added by rohith
        updateUnitStatusOnClosedWon( recordNewList,recordNewMap, recordOldMap );
        //drawloopDocumentGeneration();
        shareSalesDealRecord();
        rejectDealTaskCreation(recordNewList);//added by rohith
        closeCEOApprovalDocTask(recordNewList);//added by rohith
        alertToSalesExecutiveOnAdminAssignment(recordNewList);//added by rohith
        terminateSPARecord(); //added by husain
    }
    
    public void AfterDeleteEvent() {
    }
    
    public void AfterUndeleteEvent() {
    }
    
    /*
public void drawloopDocumentGeneration() {
try {
Loop.loopMessage lm = new Loop.loopMessage();
for(Opportunity bps : recordNewList) {
if(bps.Booking_Fee_gets_collected__c && recordNewMap.get(bps.id).Booking_Fee_gets_collected__c != true){
Map<string, string> variables; // MAIN RECORD ID - SAME OBJECT AS THE DDP RECORD TYPE SPECIFIES' // DDP ID
lm.requests.add(new Loop.loopMessage.loopMessageRequest( bps.Id, 'a1p3M000000CexNQAS', new Map<string, string> { 'deploy' => 'a1n3M000000CbD3QAK' } ));

}
}
// SEND ALL DDP RUN REQUESTS IN A SINGLE CALL OUT
lm.sendAllRequests();
}
catch(Exception e){
system.debug('--------e-----:'+e); 
}
}
*/
    
    /********************************************************************************************** 
* @Description  : populate lease end date when leasing getting created
* @Params       : 
* @Return       : void
* @Author       : Sajid Hameed
**********************************************************************************************/
    public void populateLeaseEndData(){
        Id oppRenewRecordType= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Lease Renewal').getRecordTypeId();
        Id oppCommRenewRcdTyp= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Lease Renewal').getRecordTypeId();
       
        
        for(opportunity opp :recordNewList ){
            if(opp.Lease_Start_Date__c == null && opp.RecordTypeId !=oppRenewRecordType && opp.RecordTypeId !=oppCommRenewRcdTyp && opp.Change_Unit__c ==false){
                opp.Lease_Start_Date__c = System.today();
            }
            if(opp.Lease_Start_Date__c != null && opp.RecordTypeId !=oppRenewRecordType && opp.RecordTypeId !=oppCommRenewRcdTyp && opp.Change_Unit__c ==false){
                system.debug('Inside>>>>>');
                opp.Lease_End_Date__c = (opp.Lease_Start_Date__c).addYears(1) - 1;  
            }
            if(opp.Grace_Period_Days__c != null){
                if(opp.Lease_End_Date__c != null){
                    opp.Lease_End_Date__c = (opp.Lease_End_Date__c).addDays(Integer.valueOf(opp.Grace_Period_Days__c));
                }
                if(opp.Leasing_Type__c == 'Commercial Units' && opp.Grace_Period_Days__c > 0){
                    opp.Grace_Start_Date__c = opp.Lease_Start_Date__c;
                    opp.Grace_End_Date__c = (opp.Lease_Start_Date__c).addDays(Integer.valueOf(opp.Grace_Period_Days__c));
                }else if(opp.Leasing_Type__c == 'Residential Units' && opp.Grace_Period_Days__c > 0){
                    opp.Grace_Start_Date__c = (opp.Lease_End_Date__c).addDays(Integer.valueOf(-opp.Grace_Period_Days__c));
                    opp.Grace_End_Date__c = opp.Lease_End_Date__c;
                }
            }
        }
    }
    public void popolateSalesEcecutive(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        for(opportunity opp :recordNewList ){
            if(opp.RecordTypeId == oppRecordTypeId){
                opp.Sales_Executive__c = opp.OwnerId;
            }
        }
    }
    public void updateEmail(){
        for(opportunity opp :recordNewList ){
            if(opp.Account_Email__c != null && (recordOldMap == null || opp.Account_Email__c != recordOldMap.get(opp.Id).Account_Email__c)){
                opp.Email__c = opp.Account_Email__c;
            }
        }
    }
    
    /********************************************************************************************** 
* @Description  : Propose Ownership to Sales Opp Records
* @Params       : 
* @Return       : void
* @Author       : Mamta Gupta
**********************************************************************************************/
    public void callAssignmentEngineBatchAfterInsert(){
        boolean runEngine = false;
        Set<String> setRecordTypes= new Set<String>();
        
        for(Opportunity opp: recordNewList){
            setRecordTypes.add(opp.Record_Type_Name__c);
            runEngine= true;
        }
        
        system.debug('runEngine is '+ runEngine);    
        if(runEngine== true){
            AssignmentEngineInstance engineInstance;
            for(Assignment_Engine_Setting__mdt settings : [Select Engine_ID__c from Assignment_Engine_Setting__mdt 
                                                           where SObject__c = 'Opportunity' and TriggerMatchParameter1__c in 
                                                           :setRecordTypes]){
                                                               engineInstance = new AssignmentEngineInstance(settings.Engine_ID__c);
                                                               //Parameters of ExecuteBatch(context,BatchSize)
                                                               database.executebatch(engineInstance);
                                                           }
        }      
    }
    
    
    //** Function to add booking amount in milestones ** //
    //** Created By Moneeb **//
    
    public void AddUpdateBookingMileStone (){
        
        List<Opportunity> OpportunitiesToPrcess = new List<Opportunity>();
        List<Payment_Milestone__c> paymentMilestonesToCreate = new List<Payment_Milestone__c>();
        List<Payment_Milestone__c> paymentMilestonesToUpdate = new List<Payment_Milestone__c>();
        Map<Id,Payment_Milestone__c> idPaymentMilestoneMap = new Map<Id, Payment_Milestone__c>();
        
        for(Opportunity opp: recordNewList){
            if(recordOldMap.get(opp.Id).Booking_Amount__c != recordNewMap.get(opp.Id).Booking_Amount__c
               || recordOldMap.get(opp.Id).Booking_Reservation_Date__c != recordNewMap.get(opp.Id).Booking_Reservation_Date__c){
                   OpportunitiesToPrcess.add(opp);
               }
            
        }
        System.debug(OpportunitiesToPrcess);
        for(Payment_Milestone__c pay:[SELECT Id,Installment__c,Due_Date__c,Amount__c,Name,Opportunity__c,
                                      Installment_No__c,Payment_Status__c FROM Payment_Milestone__c
                                      WHERE Installment__c = 'Booking Amount' AND Opportunity__c IN:OpportunitiesToPrcess]){
                                          
                                          if(pay.Installment__c == 'Booking Amount'){
                                              idPaymentMilestoneMap.put(pay.Opportunity__c, pay);
                                              
                                          }
                                      }
        System.debug(idPaymentMilestoneMap);
        
        for (Opportunity opp: OpportunitiesToPrcess){
            if(idPaymentMilestoneMap.containsKey(opp.Id)){
                Payment_Milestone__c milestone = idPaymentMilestoneMap.get(opp.Id);
                milestone.Amount__c = opp.Booking_Amount__c;
                milestone.Due_Date__c = opp.Booking_Reservation_Date__c;
                paymentMilestonesToUpdate.add(milestone);
                
            }else{
                Payment_Milestone__c milestone = new Payment_Milestone__c();
                milestone.Amount__c = opp.Booking_Amount__c;
                milestone.Due_Date__c = opp.Booking_Reservation_Date__c;
                milestone.Installment__c = 'Booking Amount';
                milestone.Name = 'Booking Amount';
                milestone.Opportunity__c = opp.Id;
                milestone.Payment_Status__c = 'Pending';
                paymentMilestonesToCreate.add(milestone);
                
                
            }
        }
        System.debug(paymentMilestonesToCreate);
        System.debug(paymentMilestonesToUpdate);
        if(paymentMilestonesToCreate.size() >0 ){
            INSERT paymentMilestonesToCreate;
        }
        if(paymentMilestonesToUpdate.size()>0 ){
            UPDATE paymentMilestonesToUpdate;
        }
        
    }
    
    /*******************************************
* Added by jaskiran :- To generate Leasing number from Business Unit
* 
* *************************************/
    public void generateLeasingNumber(List<sObject> newOppList,Map<Id,sObject> oldOptyMap){
        set<Id> projectIds = new Set<Id>();
        
        List<Business_Unit__c> businessUnitList = new List<Business_Unit__c>();
        Map<Id,Opportunity> mapOfOldopty = (Map<Id,Opportunity>)oldOptyMap;
        for(Opportunity opp : (List<Opportunity>)newOppList){
            if(opp.Interested_In__c == 'Residential Leasing'){
                if(oldOptyMap != null){
                    if((mapOfOldopty.get(opp.Id).project__c != opp.Project__c) || String.isEmpty(opp.Leasing_Number__c)){
                        projectIds.add(opp.Project__c); 
                    }
                } else {
                    projectIds.add(opp.Project__c);
                }
            }
        }
        if( !projectIds.isEmpty()){
            Map<Id,Project__c> projectMap=new Map<Id,Project__c>([Select Id,Business_Unit__r.Business_Unit_Code__c ,Business_Unit__r.ERP_Business_Unit_Id__c,Business_Unit__r.sequence__c,Business_Unit__c FROM Project__c where ID IN: projectIds]);
        if(!projectMap.isEmpty()){
            for(Opportunity opp : (List<Opportunity>)newOppList){
                if(projectMap.containsKey(opp.Project__c)){
                    Integer sequence;
                    Business_Unit__c buObj = new Business_Unit__c();
                    if(projectMap.get(opp.Project__c).Business_Unit__r.sequence__c == null){
                        sequence = 0;
                    } else {
                        sequence = Integer.valueOf(projectMap.get(opp.Project__c).Business_Unit__r.sequence__c);
                    }
                    if(projectMap.get(opp.Project__c).Business_Unit__r.Business_Unit_Code__c  != null){
                        opp.Leasing_Number__c = String.valueOf(projectMap.get(opp.Project__c).Business_Unit__r.Business_Unit_Code__c + '_'+ sequence);
                    }else {
                        opp.Leasing_Number__c = String.valueOf('_'+ sequence);
                    }
                    buObj.Id = projectMap.get(opp.Project__c).Business_Unit__c;
                    Integer updateSeq = sequence + 1;
                    buObj.sequence__c = decimal.valueOf(updateSeq);
                    businessUnitList.add(buObj);
                }
            }
            //String buildString = json.serialize(updateBuildlst);
            if(businessUnitList.size() > 0){
                update businessUnitList;
                
            }
        } 
        }
        
    }
    
    @future
    public static void updateBuilding(String buildString){
        List<Business_Unit__c> updateBuildList = (List<Business_Unit__c>)Json.deserialize(buildString,List<Business_Unit__c>.class);
        if(updateBuildList.size() > 0){
            update updateBuildList;
        }
    }
    
    /******************************************************************************************************
* @Description        : Function to create SPA records                                                                                             
* @Return             : void                                                                         
*******************************************************************************************************/
    public void createSPARecord(){
        Set<Id> opporutnityIds = new Set<Id>();
        List<Agreement__c > spaContractList = New List<Agreement__c >();
        for(opportunity oppourtunityRecord :recordNewList ){
            Id spaRecordTypeId = Schema.SObjectType.Agreement__c.getRecordTypeInfosByDeveloperName().get('SPA').getRecordTypeId();
            if(oppourtunityRecord.Unit_Reserved__c){
                Agreement__c  contractNewRecord = New Agreement__c ();
                contractNewRecord.RecordTypeId = spaRecordTypeId;
                contractNewRecord.Opportunity__c = oppourtunityRecord.Id;
                contractNewRecord.Status__c = 'SPA Not Generated';
                contractNewRecord.Account__c = oppourtunityRecord.AccountId;
                contractNewRecord.Unit__c = oppourtunityRecord.Unit__c;
                spaContractList.add(contractNewRecord);          
                opporutnityIds.add(oppourtunityRecord.id);
            }
        }
        List<Agreement__c> agreementRecords = New List<Agreement__c>();
        
        if(opporutnityIds.size() > 0){
            agreementRecords = [SELECT Id FROM Agreement__c WHERE Opportunity__c IN: opporutnityIds];
        }
        if(spaContractList.size() > 0 && spaContractList != null && agreementRecords.size() <= 0 && agreementRecords != null){
            insert spaContractList;
        }    
    }

        /******************************************************************************************************
* @Description        : Function to Lock Deal and other filed updates                                                                                            
* @Return             : void
* @Module             : Sales
*******************************************************************************************************/
public void lockOppRecord(){
    Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
    Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
    Id readOnlyUnitSold = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Unit_Sold').getRecordTypeId();
    for(opportunity opp :recordNewList ){
        if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal ) && opp.OwnerId != recordOldMap.get(opp.Id).OwnerId){
            opp.Sales_Admin__c = opp.OwnerId;
        }
        if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal ) && recordOldMap.get(opp.Id).Sales_Admin__c == null && opp.Sales_Admin__c != recordOldMap.get(opp.Id).Sales_Admin__c){
            opp.RecordTypeId = readOnlyDeal;
            opp.StageName = 'Reservation In Progress';
        }
        if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal ) && opp.StageName != recordOldMap.get(opp.Id).StageName && opp.StageName == 'SPA Executed' && opp.Unit_Status_Formula__c == 'Sold'){
            opp.RecordTypeId = readOnlyUnitSold;
        }
        if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal ) && opp.Approval_Doc_From_CEO_Uploaded__c &&  opp.Approval_Doc_From_CEO_Uploaded__c != recordOldMap.get(opp.Id).Approval_Doc_From_CEO_Uploaded__c && opp.Reject_Unit_Approval_Status__c == 'Approved'){
            opp.Reject_Unit__c = true;
        }
        if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal ) && opp.Reject_Unit__c &&  opp.Reject_Unit__c != recordOldMap.get(opp.Id).Reject_Unit__c){
            opp.StageName = 'Closed Lost';
        }
        if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal || opp.recordTypeId == readOnlyUnitSold ) && opp.StageName != recordOldMap.get(opp.Id).StageName && opp.StageName == 'Closed Lost'){
            opp.Loss_Reason__c = opp.Unit_Reject_Remarks__c != null ? opp.Unit_Reject_Remarks__c : 'Rejected' ;
            opp.RecordTypeId = readOnlyUnitSold;
        }
    } 
}

    /******************************************************************************************************
* @Description        : Function to Change Deal owner                                                                                      
* @Return             : void                                                                         
*******************************************************************************************************/
    public void ownerChange(){
        for(opportunity opp :recordNewList ){
            if(opp.Owner_Deal__c != null && opp.Owner_Deal__c != recordOldMap.get(opp.Id).Owner_Deal__c){
                opp.OwnerId = opp.Owner_Deal__c;
            }
        } 
    }
    /******************************************************************************************************
* @Description        : Function to Share Sales Deal Record with group                                                                                   
* @Return             : void                                                                         
*******************************************************************************************************/
    public void shareSalesDealRecord(){
        Set<Id> oppIdSet = new Set<Id>();
        List<Opportunity> oppExList = new List<Opportunity>();
        for(opportunity opp :recordNewList ){
            if(opp.Move_to_Advanced_Screen__c && opp.Move_to_Advanced_Screen__c != recordOldMap.get(opp.Id).Move_to_Advanced_Screen__c){
                if(opp.Sales_Executive__c != null){
                    oppExList.add(opp);
                }
                oppIdSet.add(opp.Id);
            }
        } 
        if(!oppIdSet.isEmpty()){
            shareSalesRecord(oppIdSet);
        }
        if(!oppExList.isEmpty()){
            createSalesExecutiveContributors(oppExList);
        }
    }
    @future
    public static void shareSalesRecord(Set<Id> oppIds){
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        List<Group> groupList = [SELECT Id,Name,DeveloperName FROM Group WHERE DeveloperName = 'Sales_Deal_Assignment_Group'];
        if(!groupList.isEmpty()){
            for(Id oppId : oppIds){
                OpportunityShare os = new OpportunityShare();
                os.OpportunityId = oppId; 
                os.OpportunityAccessLevel = 'Edit';
                os.UserOrGroupId = groupList[0].Id;
                os.RowCause = 'Manual';
                oppShares.add(os);
            }
            if(!oppShares.isEmpty()){
                Database.SaveResult[] result = Database.insert(oppShares, false);
            }
        }
    }    
    /******************************************************************************************************
* @Description        : Function to create Additional Charges                                                                                             
* @Return             : void        
* Modified by         : Ashams
* Changes             : Logic to add additionalcharges for sales                                                                         
*******************************************************************************************************/
    public void createAdditionalCharges(){
        Id salesDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        Id quickBookDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Quick_Book').getRecordTypeId();
        Set<Id> setOpptyIds = new Set<Id>();
        Set<Id> unitIds = new Set<Id>();
        Map<Id,Id> unitIdProjectIdMap = new Map<Id,Id>();
        Map<Id,Unit__c> unitMap = new Map<Id,Unit__c>();
        Map<Id,List<Additional_Charges__c>> projectIdAdditionalChargesMap = new Map<Id,List<Additional_Charges__c>>();
        List<Opportunity_Charges__c> oppChargeList = new List<Opportunity_Charges__c>();
        List<Opportunity_Charges__c> dldChargeList = new List<Opportunity_Charges__c>();
        List<Opportunity_Charges__c> dldChargeListtoUpdate = new List<Opportunity_Charges__c>();
        
        for(opportunity opp :recordNewList ){
            system.debug('**opp'+opp);
            if(isAfter && isUpdate){
                if(opp.Unit__c != null && (opp.recordTypeId == salesDeal || opp.recordTypeId == quickBookDeal) && 
                   recordOldMap.get(opp.Id).Unit__c != opp.Unit__c ){
                       unitIds.add(opp.Unit__c);
                   }
                if((opp.recordTypeId == salesDeal || opp.recordTypeId == quickBookDeal) && opp.DLD_Customer_Share__c!=null && opp.DLD_Customer_Share__c != recordOldMap.get(opp.Id).DLD_Customer_Share__c){
                    //setOpptyIds.add(opp.Id);
                }
            }
            else if(isAfter && isInsert){
                if(opp.Unit__c != null && (opp.recordTypeId == salesDeal || opp.recordTypeId == quickBookDeal || opp.recordTypeId == readOnlyDeal)){
                    unitIds.add(opp.Unit__c);
                }
            }
        }
        
        /*if(!setOpptyIds.isEmpty()){
            dldChargeList = [SELECT Id,Amount__c,Opportunity__r.DLD_Customer_Share__c,Opportunity__r.Unit__r.Selling_Price__c from Opportunity_Charges__c where Opportunity__c IN: setOpptyIds AND 
                             Master_Additional_Charges__r.Type__c  ='Sales' AND Master_Additional_Charges__r.Charge_Type__c ='DLD_FEE' ];
            if(!dldChargeList.isEmpty()){
                for(Opportunity_Charges__c charge:dldChargeList){
                    charge.Amount__c = (charge.Opportunity__r.DLD_Customer_Share__c/100) * charge.Opportunity__r.Unit__r.Selling_Price__c;
                    dldChargeListtoUpdate.add(charge);
                } 
            }
            if(!dldChargeListtoUpdate.isEmpty()){
                update dldChargeListtoUpdate;
            }
        }*/
        
        if(!unitIds.isEmpty()){
            for(Unit__c unit : [SELECT Id,Project__c,DLD_Customer_Share__c,Selling_Price__c FROM Unit__c WHERE Id IN: unitIds]){
                if(unit.Project__c != null ){
                    unitIdProjectIdMap.put(unit.Id,unit.Project__c);
                    unitMap.put(unit.Id,unit);
                }
            }
        }
        
        if(!unitIdProjectIdMap.isEmpty()){
            for(Additional_Charges__c mpm : [Select Id,Name,Type__c,Project__c,Charge_Type__c from Additional_Charges__c where Default_Sales_Charge__c = true
                                             AND Type__c =:'Sales' AND Charge_Type__c=:'DLD_FEE' AND Project__c IN: unitIdProjectIdMap.values()]){
                                                 if (!projectIdAdditionalChargesMap.containsKey(mpm.Project__c)){
                                                     projectIdAdditionalChargesMap.put(mpm.Project__c, new List<Additional_Charges__c>{mpm});
                                                 }else{
                                                     List<Additional_Charges__c> mpmTempList = projectIdAdditionalChargesMap.get(mpm.Project__c);
                                                     mpmTempList.add(mpm);
                                                     projectIdAdditionalChargesMap.put(mpm.Project__c, mpmTempList);
                                                 }
                                             }
        }
        if(!projectIdAdditionalChargesMap.isEmpty()){
            system.debug('**unitIdProjectIdMap'+unitIdProjectIdMap);
            for(opportunity opp :recordNewList){
                if(unitIdProjectIdMap.keySet().contains(opp.Unit__c) && unitIdProjectIdMap.get(opp.Unit__c) != null){
                    for(Additional_Charges__c adc : projectIdAdditionalChargesMap.get(unitIdProjectIdMap.get(opp.Unit__c))){
                        Opportunity_Charges__c oppCharge = new Opportunity_Charges__c();
                        oppCharge.Name = adc.Name;
                        oppCharge.Master_Additional_Charges__c = adc.Id;
                        oppCharge.Opportunity__c = opp.Id;
                        oppCharge.Charge_Type__c = adc.Charge_Type__c;
                        oppCharge.Project__c = unitMap.get(opp.Unit__c).Project__c;
                        oppCharge.Amount__c = (unitMap.get(opp.Unit__c).DLD_Customer_Share__c/100) * unitMap.get(opp.Unit__c).Selling_Price__c;
                        oppChargeList.add(oppCharge); 
                    }
                }
            }
            if(!oppChargeList.isEmpty()){
                insert oppChargeList;
            }
        }        
    }
    
    /******************************************************************************************************
    * @Description        : Function to populate fields on Deal                                                                                            
    * @Return             : void   
    * Module              : Sales - invokes in before Insert                                                                     
    *******************************************************************************************************/
    public void populateSalesOppFileds(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Set<Id> unitId = new Set<Id>();
        Set<Id> accId = new Set<Id>();
        for(opportunity opp :recordNewList ){
            if(opp.recordTypeId == oppRecordTypeId){
                if(opp.Unit__c != null){
                    unitId.add(opp.Unit__c);
                    accId.add(opp.AccountId);
                }else{
                    opp.StageName = 'Booking In Progress';// When Deal has no Unit linked
                    opp.Sales_Executive__c = opp.OwnerId;
                }
            }
        }
        if(!accId.isEmpty() && !unitId.isEmpty()){
            Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,Name FROM Account WHERE Id IN:accId ]);
            Map<Id,Unit__c> unitIdMap = new Map<Id,Unit__c>([SELECT Id,Name,Unit_Theme__c,Space_Type__c,Business_Unit__c,
                                                             Master_Payment_Plan__c,DLD_Customer_Share__c,DLD_Nakheel_Share__c,No_of_Bedrooms__c,project__c,Cluster__c 
                                                             FROM Unit__c WHERE Id IN:unitId ]); 
            List<Unit__c> unitList = new List<Unit__c>();
            if(!unitIdMap.IsEmpty() && !accMap.isEmpty()){
                for(opportunity opp :recordNewList){
                    Unit__c un = new Unit__c();
                    un.Id = opp.Unit__c;
                    un.Unit_Status__c = 'Booked';
                    unitList.add(un);
                    opp.StageName = 'Booked';
                    opp.Sales_Executive__c = opp.OwnerId;
                    opp.Master_Payment_Plan__c = unitIdMap.get(opp.Unit__c).Master_Payment_Plan__c;
                    opp.DLD_Customer_Share__c = unitIdMap.get(opp.Unit__c).DLD_Customer_Share__c;
                    opp.DLD_Nakheel_Share__c = unitIdMap.get(opp.Unit__c).DLD_Nakheel_Share__c;
                    opp.Name = accMap.get(opp.AccountId).Name + ' - ' + unitIdMap.get(opp.Unit__c).Name ;
                    opp.CloseDate = System.today() + 30;
                    opp.Space_Type__c = unitIdMap.get(opp.Unit__c).Space_Type__c;
                    opp.Project__c = unitIdMap.get(opp.Unit__c).project__c;
                    opp.Theme__c = unitIdMap.get(opp.Unit__c).Unit_Theme__c;
                    opp.Units_Cluster__c = unitIdMap.get(opp.Unit__c).Cluster__c;
                    opp.Business_Unit__c = unitIdMap.get(opp.Unit__c).Business_Unit__c;
                }
                if(!unitList.isEmpty()){
                    update unitList;
                }
            }
        }
    }
    /******************************************************************************************************
* @Description        : Function to create opportunity payment milestones                                                                                            
* @Return             : void    
* Module              : Sales - After Insert & After Update
* Purpose             : Add Payment Milestone on Deal when unit is added, unit is changed, Master payment Milestone is changed
*******************************************************************************************************/
    public void createOppPaymentMilestones(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id quickOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Quick_Book').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        Set<Id> unitIds = new Set<Id>();
        Set<Id> unitForSpecialOfferSet = new Set<Id>();
        Set<Id> unitForDirectPlan = new Set<Id>();
        Map<Id,Id> unitMPPMap = new Map<Id,Id>();
        List<Offer_Applied__c> offerAppliedList = new List<Offer_Applied__c>();
        //Map<Id,Special_Offer_Item__c> unitSpecialOfferMap = SpecialOfferController.getSpecialOffers(unitIds);
        Map<Id,List<Master_Payment_Milestone__c>> mpmMap = new Map<Id,List<Master_Payment_Milestone__c>>();
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        List<Original_Milestone__c> omList = new List<Original_Milestone__c>();
        List<opportunity> oppUpList = new List<opportunity>();
        Map<String, String> installmentMap = new Map<String, String>();
        
        for(opportunity opp :recordNewList ){
            if(isAfter && isUpdate){
                if(opp.Unit__c != null && (opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == quickOppRecordTypeId) && 
                   (recordOldMap.get(opp.Id).Unit__c != opp.Unit__c)){
                       unitIds.add(opp.Unit__c);
                   }
            }
            else if(isAfter && isInsert){
                if(opp.Unit__c != null && (opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == quickOppRecordTypeId || opp.recordTypeId == readOnlyDeal)){
                    unitIds.add(opp.Unit__c);
                }
            }
        }
        system.debug('**unitIds'+unitIds);
        
        if(!unitIds.isEmpty()){
            for(Unit__c unit : [SELECT Id,Master_Payment_Plan__c FROM Unit__c WHERE Id IN: unitIds]){
                if(unit.Master_Payment_Plan__c != null ){
                    unitMPPMap.put(unit.Id , unit.Master_Payment_Plan__c);
                }
            }
            
            if(!unitMPPMap.isEmpty()){
                for(Master_Payment_Milestone__c mpm : [SELECT Id, Name,Installment__c, CurrencyIsoCode, Installment_No__c, Master_Payment_Plan__c, 
                                                       Amount_Percentage__c, Milestone_Trigger_Point__c, Due_In_Days__c 
                                                       FROM Master_Payment_Milestone__c 
                                                       WHERE Master_Payment_Plan__c IN: unitMPPMap.values()]){
                                                           if (!mpmMap.containsKey(mpm.Master_Payment_Plan__c)){
                                                               mpmMap.put(mpm.Master_Payment_Plan__c, new List<Master_Payment_Milestone__c>{mpm});
                                                           }else{
                                                               List<Master_Payment_Milestone__c> mpmTempList = mpmMap.get(mpm.Master_Payment_Plan__c);
                                                               mpmTempList.add(mpm);
                                                               mpmMap.put(mpm.Master_Payment_Plan__c, mpmTempList);
                                                           }
                                                       }
            }
            
            if(!mpmMap.isEmpty()){
                system.debug('**unitMPPMap'+unitMPPMap);
                installmentMap = CommonUtility.getPicklistValues('Master_Payment_Milestone__c','Installment__c'); 
                for(opportunity opp :recordNewList){
                    if(unitMPPMap.keySet().contains(opp.Unit__c) && unitMPPMap.get(opp.Unit__c) != null){
                        for(Master_Payment_Milestone__c mpm : mpmMap.get(unitMPPMap.get(opp.Unit__c))){
                            Payment_Milestone__c pm = new Payment_Milestone__c();
                            pm.Name = installmentMap.get(mpm.Installment__c);
                            pm.Installment_No__c = mpm.Installment_No__c;
                            pm.Installment__c = mpm.Installment__c;
                            pm.CurrencyIsoCode = mpm.CurrencyIsoCode;
                            pm.Master_Payment_Milestone__c = mpm.Id;
                            pm.Unit__c = opp.Unit__c;
                            pm.Master_Payment_Plan__c = mpm.Master_Payment_Plan__c;
                            pm.Amount_Percentage__c = mpm.Amount_Percentage__c;
                            pm.Opportunity__c = opp.Id;
                            pm.Milestone_Trigger_Point__c = mpm.Milestone_Trigger_Point__c; 
                            if(opp.Booking_Reservation_Date__c != null && mpm.Due_In_Days__c != null){
                                pm.Due_Date__c = opp.Booking_Reservation_Date__c + Integer.valueOf(mpm.Due_In_Days__c);
                            }
                            pm.Due_In_Days__c = mpm.Due_In_Days__c;
                            pm.Amount__c = opp.Selling_Price__c -(opp.Selling_Price__c  * (1 - (mpm.Amount_Percentage__c)/100));
                            pmList.add(pm);
                            
                            Original_Milestone__c om = new Original_Milestone__c();
                            om.Name = installmentMap.get(mpm.Installment__c);
                            om.Installment_No__c = mpm.Installment_No__c;
                            om.Installment__c = mpm.Installment__c;
                            om.CurrencyIsoCode = mpm.CurrencyIsoCode;
                            om.Master_Payment_Milestone__c = mpm.Id;
                            om.Master_Payment_Plan__c = mpm.Master_Payment_Plan__c;
                            om.Amount_Percentage__c = mpm.Amount_Percentage__c;
                            om.Opportunity__c = opp.Id;
                            om.Milestone_Trigger_Point__c = mpm.Milestone_Trigger_Point__c;
                            om.Due_In_Days__c = mpm.Due_In_Days__c;
                            if(opp.Booking_Reservation_Date__c != null && mpm.Due_In_Days__c != null){
                                om.Due_Date__c = opp.Booking_Reservation_Date__c + Integer.valueOf(mpm.Due_In_Days__c);
                            }
                            om.Amount__c = opp.Selling_Price__c -(opp.Selling_Price__c  * (1 - (mpm.Amount_Percentage__c)/100));
                            omList.add(om);
                        }
                    }
                }
                if(!pmList.isEmpty() && !omList.isEmpty()){
                    insert pmList;
                    insert omList;
                }
                if(!oppUpList.isEmpty()){
                    update oppUpList;
                }
            }
        }
    }
    
    /******************************************************************************************************
    * @Description        : Auto Apply DLD offer applied on opp insert - sales module                                                                                        
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void createDLDOfferSales(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id quickOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Quick_Book').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        Set<Id> unitIds = new Set<Id>();
        Map<Id,Special_Offer_Item__c> unitSpecialOfferMap = new Map<Id,Special_Offer_Item__c>();
        List<Offer_Applied__c> offerAppliedList = new List<Offer_Applied__c>();
        
        for(opportunity opp :recordNewList){
            if(isAfter && isUpdate){
                if(opp.Unit__c != null && (opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == quickOppRecordTypeId) && 
                   (recordOldMap.get(opp.Id).Unit__c != opp.Unit__c)){
                       unitIds.add(opp.Unit__c);
                   }
            }else if(isAfter && isInsert){
                if(opp.Unit__c != null && (opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == quickOppRecordTypeId || opp.recordTypeId == readOnlyDeal)){
                    unitIds.add(opp.Unit__c);
                }
            }
        }
        system.debug('%%unitIds'+unitIds);
        if(!unitIds.isEmpty()){
            unitSpecialOfferMap = SpecialOfferController.getActiveDLDOffers(unitIds);
            if(unitSpecialOfferMap.size()>0){
                for(opportunity opp :recordNewList){
                    if(unitSpecialOfferMap.containsKey(opp.unit__c)){
                        Offer_Applied__c offerApplied = new Offer_Applied__c();
                        offerApplied.Opportunity__c = opp.Id;
                        offerApplied.Special_Offer__c = unitSpecialOfferMap.get(opp.Unit__c).Special_Offer__c;
                        offerAppliedList.add(offerApplied);
                    }
                }
            }
        }
        system.debug('%%offerAppliedList'+offerAppliedList);
        if(!offerAppliedList.isEmpty()){
           insert offerAppliedList; 
        }
    }
    
    /******************************************************************************************************
* @Description        : Function to update Payment Milestone on change of Net Selling price without charges                                                                                          
* @Return             : void                                                                         
*******************************************************************************************************/
    public void reviseMilestones(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        Id readOnlyUnitSold = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Unit_Sold').getRecordTypeId(); 
        Id quickBookRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Quick_Book').getRecordTypeId(); 
        
        Map<Id,Opportunity> IdToOppMap = new Map<Id,Opportunity>();
        for(opportunity opp :recordNewList ){
            if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal || opp.recordTypeId == readOnlyUnitSold || opp.recordTypeId == quickBookRT ) && opp.Milestone_Price_Adjustment__c != recordOldMap.get(opp.Id).Milestone_Price_Adjustment__c){
                IdToOppMap.put(opp.Id, opp);
            }
        }
        if(!IdToOppMap.isEmpty()){
            List<Payment_Milestone__c> pmToUpdate = new List<Payment_Milestone__c>();
            for(Payment_Milestone__c pm: [SELECT Id,Opportunity__c, Amount__c,Amount_Percentage__c FROM Payment_Milestone__c WHERE Opportunity__c IN:IdToOppMap.keySet()]){
                Payment_Milestone__c pmUp = new Payment_Milestone__c();
                pmUp.Id = pm.Id;
                Decimal calAmt = IdToOppMap.get(pm.Opportunity__c).Milestone_Price_Adjustment__c + IdToOppMap.get(pm.Opportunity__c).Selling_Price__c ;
                pmUp.Amount__c = calAmt -(calAmt  * (1 - (pm.Amount_Percentage__c)/100));
                pmToUpdate.add(pmUp);
            }
            if(!pmToUpdate.IsEmpty()){
                update pmToUpdate;
            }
        }
    }
    /******************************************************************************************************
* @Description        : Function to create Deal Contributor                                                                                           
* @Return             : void                                                                         
*******************************************************************************************************/
    public void createAdminContributors(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        
        Map<Id,Opportunity> IdToOppMap = new Map<Id,Opportunity>();
        Map<Id,Id> oppIdToSalesAdminId = new Map<Id,Id>();
        for(opportunity opp :recordNewList ){
            if( ( opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal ) && opp.Sales_Admin__c != recordOldMap.get(opp.Id).Sales_Admin__c){
                if(opp.Sales_Admin__c != null){
                    IdToOppMap.put(opp.Id, opp);
                }
                if(recordOldMap.get(opp.Id).Sales_Admin__c != null){
                    oppIdToSalesAdminId.put(opp.Id,recordOldMap.get(opp.Id).Sales_Admin__c);
                }
            }
        }
        if(!oppIdToSalesAdminId.isEmpty()){
            List<Contributor__c> deleteList = new List<Contributor__c>();
            for(Contributor__c cb : [SELECT Id FROM Contributor__c WHERE Opportunity__c IN:oppIdToSalesAdminId.keySet() AND User__c IN:oppIdToSalesAdminId.values()]){
                deleteList.add(cb);
            }
            if(!deleteList.isEmpty()){
                delete deleteList;
            }
        }
        if(!IdToOppMap.isEmpty()){
            List<Contributor__c> insertList = new List<Contributor__c>();
            for(Id oppId : IdToOppMap.keySet()){
                Contributor__c cb = new Contributor__c();
                cb.Opportunity__c = oppId;
                cb.User__c = IdToOppMap.get(oppId).Sales_Admin__c;
                cb.Role__c = 'Sales Admin';
                cb.Access__c = 'Edit';
                insertList.add(cb);
            }
            if(!insertList.isEmpty()){
                insert insertList;
            }
        }
        
    }
    /******************************************************************************************************
* @Description        : Function to create Deal Contributor                                                                                           
* @Return             : void                                                                         
*******************************************************************************************************/
    public void createBrokerContributors(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        List<Contributor__c> insertList = new List<Contributor__c>();
        
        for(opportunity opp :recordNewList ){
            if( ( opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal ) && opp.Broker__c != recordOldMap.get(opp.Id).Broker__c){
                Contributor__c cb = new Contributor__c();
                cb.Opportunity__c = opp.Id;
                cb.Account__c = opp.Broker__c;
                cb.Role__c = 'Broker';
                cb.Access__c = 'Read';
                insertList.add(cb);
            }
        }
        if(!insertList.isEmpty()){
            insert insertList;
        }
    }
    /******************************************************************************************************
    * @Description        : Function to create Deal Contributor                                                                                           
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void createSalesExecutiveContributors(List<Opportunity> oppList){
        List<Contributor__c> insertList = new List<Contributor__c>();
        for(opportunity opp :oppList ){
            Contributor__c cb = new Contributor__c();
            cb.Opportunity__c = opp.Id;
            cb.User__c = opp.Sales_Executive__c;
            cb.Role__c = 'Sales Executive';
            cb.Access__c = 'Edit';
            insertList.add(cb);
        }
        if(!insertList.isEmpty()){
            insert insertList;
        }
    }
    /******************************************************************************************************
* @Description        : Function to update discount on opportunity                                                                                           
* @Return             : void                                                                         
*******************************************************************************************************/
    public void updateDiscount(){
        system.debug( ' updateDiscount => =>  ' );
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        
        for(opportunity opp :recordNewList ){
            if(opp.Payment_Mode__c != null && (opp.recordTypeId == oppRecordTypeId  || opp.recordTypeId == readOnlyDeal ) && opp.Payment_Mode__c != recordOldMap.get(opp.Id).Payment_Mode__c  && !opp.Token_Amount_Payment_Created__c ){
                opp.Token_Amount_Payment_Created__c = true;
            }
            if(opp.Unit__c != null  && opp.Selling_Price__c != 0 && (opp.recordTypeId == oppRecordTypeId  || opp.recordTypeId == readOnlyDeal ) && opp.Discount_Type__c != null && opp.Discount__c != null){
                if(opp.Discount_Type__c == 'Fixed'){
                    opp.Discount_Amount__c = opp.Discount__c;
                    opp.Discount_Percentage__c = (opp.Discount__c/opp.Selling_Price__c)*100;
                }else if(opp.Discount_Type__c == 'Percentage'){
                    opp.Discount_Percentage__c = opp.Discount__c;
                    opp.Discount_Amount__c = opp.Selling_Price__c - (opp.Selling_Price__c  * (1 - (opp.Discount_Percentage__c)/100));
                }
            }
        }
    }

/******************************************************************************************************
* @Description        : Function to update DLD related fileds on opportunity for Sales                                                                                          
* @Return             : void                                                                         
*******************************************************************************************************/
    public void updateDLDStatusSales(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        Decimal sppExceptionDiscount = Decimal.valueOf( Label.Sales_Single_Payment_Plan_Discount );
        
        for(opportunity opp :recordNewList ){
            if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal) 
               && opp.Exception_Approval_Status__c != recordOldMap.get(opp.Id).Exception_Approval_Status__c){
                   if(opp.Exception_Approval_Status__c == 'Approved'){
                       opp.DLD_Customer_Share__c = opp.Exception_DLD_Share__c;
                       opp.DLD_Waiver_Applied__c = true;
                       opp.DLD_Paid__c = true;
                       opp.DLD_Waiver_Reason__c = 'Day to Day Exception';
                       opp.DLD_Nakheel_Share__c = opp.Unit_Total_DLD_Share__c -  opp.Exception_DLD_Share__c;
                   }
                   if(opp.Exception_Approval_Status__c == 'Rejected'){
                       opp.Exception_DLD_Share__c = 0;
                   }
               }
            if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal) 
               && opp.Single_Payment_Plan_Exception_Status__c != recordOldMap.get(opp.Id).Single_Payment_Plan_Exception_Status__c){
                   if(opp.Single_Payment_Plan_Exception_Status__c == 'Approved'){
                       opp.Exception_Discount_Amount__c = (sppExceptionDiscount * opp.Net_Selling_Price__c)/100;
                       opp.Exception_Discount__c = sppExceptionDiscount;
                       opp.Single_Payment_Plan_Selected__c = true;
                   }
                   if(opp.Single_Payment_Plan_Exception_Status__c == 'Rejected'){
                       opp.Single_Payment_Plan_Selected__c = false;
                       opp.Exception_Discount_Amount__c = 0;
                       opp.Exception_Discount__c = 0;
                   }
               }            
        }
    }
    /******************************************************************************************************
* @Description        : Function to update Payment Milestone with 1 Installment as 100%                                                                                          
* @Return             : void   
* @Modified By        : Ashams
* @Change             : Added logic to change milestones based on special offer apply/removal
*******************************************************************************************************/
    public void updatePaymentMilestoneSPP(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        Id quickOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Quick_Book').getRecordTypeId();
        Boolean specialOfferApplied = FALSE;
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        List<Payment_Milestone__c> milestoneToDelete = new List<Payment_Milestone__c>();
        List<Payment_Milestone__c> milestoneToInsert = new List<Payment_Milestone__c>();
        Map<Id,Id> oppMPPMap = new Map<Id,Id>();
        Map<Id,List<Master_Payment_Milestone__c>> mpmMap = new Map<Id,List<Master_Payment_Milestone__c>>();
        Map<String, String> installmentMap = new Map<String, String>();
        
        for(opportunity opp :recordNewList ){
            if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal || opp.recordTypeId == quickOppRecordTypeId) 
               && opp.Single_Payment_Plan_Selected__c && opp.Single_Payment_Plan_Selected__c != recordOldMap.get(opp.Id).Single_Payment_Plan_Selected__c){
                   oppMap.put(opp.Id,opp);
               }else if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal || opp.recordTypeId == quickOppRecordTypeId) 
                        && opp.Master_Payment_Plan__c!=null && opp.Special_Payment_Plan_Applied__c 
                        && opp.Special_Payment_Plan_Applied__c != recordOldMap.get(opp.Id).Special_Payment_Plan_Applied__c){
                            oppMap.put(opp.Id,opp);
                            specialOfferApplied = TRUE;
                            oppMPPMap.put(opp.Id,opp.Master_Payment_Plan__c);
                        }else if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal || opp.recordTypeId == quickOppRecordTypeId) && opp.unit__c!=null
                                 && ((opp.Special_Payment_Plan_Applied__c == FALSE && recordOldMap.get(opp.Id).Special_Payment_Plan_Applied__c == TRUE)
                                     || (opp.Single_Payment_Plan_Selected__c == FALSE && recordOldMap.get(opp.Id).Single_Payment_Plan_Selected__c == TRUE))){
                                         oppMap.put(opp.Id,opp);
                                         specialOfferApplied = TRUE;
                                         oppMPPMap.put(opp.Id,opp.Master_Payment_Plan__c);
                                     }
        }
        /*system.debug('%%specialOfferApplied'+specialOfferApplied);
        system.debug('%%oppMPPMap'+oppMPPMap);
        system.debug('%%oppMap'+oppMap);*/
        if(!oppMap.isEmpty()){
            for(Payment_Milestone__c pm : [SELECT Id,Installment__c,Amount__c,Amount_Percentage__c,Opportunity__c FROM Payment_Milestone__c WHERE opportunity__c IN: oppMap.keySet()]){
                milestoneToDelete.add(pm);
            }
            if(!milestoneToDelete.isEmpty()){
                delete milestoneToDelete;
            }
            
            if(specialOfferApplied == TRUE){
                if(oppMPPMap.size()>0){
                    for(Master_Payment_Milestone__c mpm : [SELECT Id, Name,Installment__c, CurrencyIsoCode, Installment_No__c, Master_Payment_Plan__c,Amount_Percentage__c, Milestone_Trigger_Point__c, Due_In_Days__c 
                                                           FROM Master_Payment_Milestone__c 
                                                           WHERE Master_Payment_Plan__c IN: oppMPPMap.values()]){
                                                               if (!mpmMap.containsKey(mpm.Master_Payment_Plan__c)){
                                                                   mpmMap.put(mpm.Master_Payment_Plan__c, new List<Master_Payment_Milestone__c>{mpm});
                                                               }else{
                                                                   List<Master_Payment_Milestone__c> mpmTempList = mpmMap.get(mpm.Master_Payment_Plan__c);
                                                                   mpmTempList.add(mpm);
                                                                   mpmMap.put(mpm.Master_Payment_Plan__c, mpmTempList);
                                                               }
                                                           }
                    //system.debug('%%mpmMap'+mpmMap);
                    if(!mpmMap.isEmpty()){
                        installmentMap = CommonUtility.getPicklistValues('Master_Payment_Milestone__c','Installment__c'); 
                        for(opportunity opp :recordNewList){
                            if(oppMPPMap.keySet().contains(opp.Id) && oppMPPMap.get(opp.Id) != null){
                                //system.debug('%%value'+mpmMap.get(oppMPPMap.get(opp.Id)));
                                for(Master_Payment_Milestone__c mpm : mpmMap.get(oppMPPMap.get(opp.Id))){
                                    Payment_Milestone__c pm = new Payment_Milestone__c();
                                    pm.Name = installmentMap.get(mpm.Installment__c);
                                    pm.Installment_No__c = mpm.Installment_No__c;
                                    pm.Installment__c = mpm.Installment__c;
                                    pm.CurrencyIsoCode = mpm.CurrencyIsoCode;
                                    pm.Master_Payment_Milestone__c = mpm.Id;
                                    pm.Unit__c = opp.Unit__c;
                                    pm.Master_Payment_Plan__c = mpm.Master_Payment_Plan__c;
                                    pm.Amount_Percentage__c = mpm.Amount_Percentage__c;
                                    pm.Opportunity__c = opp.Id;
                                    pm.Milestone_Trigger_Point__c = mpm.Milestone_Trigger_Point__c; 
                                    if(opp.Booking_Reservation_Date__c != null && mpm.Due_In_Days__c != null){
                                        pm.Due_Date__c = opp.Booking_Reservation_Date__c + Integer.valueOf(mpm.Due_In_Days__c);
                                    }
                                    pm.Due_In_Days__c = mpm.Due_In_Days__c;
                                    pm.Amount__c = opp.Selling_Price__c -(opp.Selling_Price__c  * (1 - (mpm.Amount_Percentage__c)/100));
                                    milestoneToInsert.add(pm);
                                }
                            }
                        }
                    }
                }
            }else{
                for(Id oppId : oppMap.keySet()){
                    Payment_Milestone__c pm = new Payment_Milestone__c();
                    pm.Name = 'First Installment';
                    pm.Installment__c = '01-JGE';
                    pm.Installment_No__c = 1;
                    pm.CurrencyIsoCode = 'AED';
                    pm.Master_Payment_Plan__c = oppMap.get(oppId).Master_Payment_Plan__c;
                    pm.Unit__c = oppMap.get(oppId).Unit__c;
                    pm.Amount_Percentage__c = 100;
                    pm.Opportunity__c = oppId;
                    if(oppMap.get(oppId).Booking_Reservation_Date__c != null){
                        pm.Due_Date__c = oppMap.get(oppId).Booking_Reservation_Date__c + Integer.valueOf('30');
                    }
                    pm.Due_In_Days__c = 30;
                    pm.Amount__c = oppMap.get(oppId).Selling_Price__c;
                    milestoneToInsert.add(pm);
                }
            }
            //system.debug('%%milestoneToInsert'+milestoneToInsert);
            if(!milestoneToInsert.isEmpty()){
                insert milestoneToInsert;
            }
        }
    }
    /******************************************************************************************************
* @Description        : Function to update unit status to reserved                                                                                       
* @Return             : void                                                                         
*******************************************************************************************************/
    public void updateUnitStatus(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        
        Set<Id> unitApprovedIds = new Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        for(opportunity opp :recordNewList ){
            if(opp.Unit__c != null && (opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal) && recordOldMap.get(opp.Id).Unit_Reserved__c != opp.Unit_Reserved__c && opp.Unit_Reserved__c){
                unitApprovedIds.add(opp.Unit__c);
                oppIdSet.add(opp.Id);
            }
        }
        List<Unit__c> updateUnitList = new List<Unit__c>();
        if(!unitApprovedIds.isEmpty()){
            for(Unit__c unit : [SELECT Id,Unit_Status__c FROM Unit__c WHERE Id In: unitApprovedIds]){
                unit.Unit_Status__c = 'Reserved';
                updateUnitList.add(unit);
            }
        }
        if(!updateUnitList.isEmpty()){
            update updateUnitList;
            List<Opportunity> oppList = [SELECT Id,Unit_Status__c,StageName FROM Opportunity WHERE Id In: oppIdSet];
            for(Opportunity opp : oppList){
                opp.stageName = 'SPA In Progress';
            }
            if(!oppList.isEmpty()){
                update oppList;
            }
        }
    }
    /******************************************************************************************************
* @Description        : Function to rollBack Revised Payment Milestone to Original PM                                                                                       
* @Return             : void                                                                         
*******************************************************************************************************/
    public void revisedPMRollback(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        
        Map<Id,Opportunity> oppIdMap = new Map<Id,Opportunity>();
        for(opportunity opp :recordNewList ){
            if(opp.Payment_Milestone_Approver_s_Status__c != null && (opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal) && recordOldMap.get(opp.Id).Payment_Milestone_Approver_s_Status__c != opp.Payment_Milestone_Approver_s_Status__c && opp.Payment_Milestone_Approver_s_Status__c == 'Rejected'){
                oppIdMap.put(opp.Id, opp);
            }
        }
        List<Payment_Milestone__c> pmListToInsert = new List<Payment_Milestone__c>();
        List<Payment_Milestone__c> pmListToDelete = new List<Payment_Milestone__c>();
        if(oppIdMap != null && !oppIdMap.isEmpty()){
            system.debug('inside OppIdMap @@@@');
            for(Payment_Milestone__c pm : [SELECT Id FROM Payment_Milestone__c WHERE Opportunity__c IN: oppIdMap.keySet()]){
            pmListToDelete.add(pm);
        }
        for(Original_Milestone__c om : [SELECT Id,Name, Installment_No__c, Installment__c, CurrencyIsoCode, Master_Payment_Milestone__c, 
                                        Master_Payment_Plan__c, Amount_Percentage__c, Opportunity__c, Milestone_Trigger_Point__c, 
                                        Due_In_Days__c, Due_Date__c, Amount__c 
                                        FROM Original_Milestone__c WHERE Opportunity__c IN: oppIdMap.keySet()]){
                                            Payment_Milestone__c pm = new Payment_Milestone__c();
                                            pm.Name = om.Name;
                                            pm.Installment_No__c = om.Installment_No__c;
                                            pm.Installment__c = om.Installment__c;
                                            pm.CurrencyIsoCode = om.CurrencyIsoCode;
                                            pm.Master_Payment_Milestone__c = om.Master_Payment_Milestone__c;
                                            pm.Master_Payment_Plan__c = om.Master_Payment_Plan__c;
                                            pm.Amount_Percentage__c = om.Amount_Percentage__c;
                                            pm.Opportunity__c = om.Opportunity__c;
                                            pm.Unit__c = oppIdMap.get(om.Opportunity__c).Unit__c;
                                            pm.Milestone_Trigger_Point__c = om.Milestone_Trigger_Point__c; 
                                            pm.Due_Date__c = om.Due_Date__c;
                                            pm.Due_In_Days__c = om.Due_In_Days__c;
                                            Decimal calAmt = oppIdMap.get(om.Opportunity__c).Milestone_Price_Adjustment__c + oppIdMap.get(om.Opportunity__c).Selling_Price__c ;
                                            pm.Amount__c = calAmt -(calAmt  * (1 - (om.Amount_Percentage__c)/100));
                                            pmListToInsert.add(pm);
                                        }
        if(!pmListToDelete.isEmpty()){
            delete pmListToDelete;
        }
        if(!pmListToInsert.isEmpty()){
            insert pmListToInsert;
        }
        }
        
    }
    /******************************************************************************************************
* @Description        : Function to update unit status to On Hold                                                                                       
* @Return             : void                                                                         
*******************************************************************************************************/
    public void updatestatus(){
        List<Opportunity> oppListUpdate = new  List<Opportunity>();
        List<Unit__c> unitListUpdate = new List<Unit__c>();
        Set<Id> oppId = new  Set<Id>();
        for(opportunity opp :recordNewList ){
            if(isAfter && isUpdate){
                if(opp.Booking_Amount__c <> null && opp.Booking_Mode__c == 'Reservation with token amount'
                   && opp.Unit_Status__c == 'On Hold'){
                       
                       oppId.add(opp.Id);  
                   } 
            }
        }
        //if(oppId <> null && !oppId.isEmpty()){
            List<Unit_Plan__c> unlist = [select unit__c,id,opportunity__c from Unit_Plan__c where opportunity__c IN :oppId];
            if(unlist <> null && unlist.size() > 0){
                for(Unit_Plan__c units : unlist){
                    Unit__c uniObj = new Unit__c();
                    uniObj.Unit_Status__c = 'Booked';
                    uniObj.Id = units.Unit__c;
                    unitListUpdate.add(uniObj);
                }
                
                for(Id opp : oppId){
                    Opportunity oppObj = new Opportunity();
                    oppObj.Unit_Status__c = 'Booked';
                    oppObj.Id = opp;
                    oppListUpdate.add(oppObj);
                }
                if(!unitListUpdate.isEmpty()){
                    system.debug('unit-101');
                    //update unitListUpdate;
                }
                if(!oppListUpdate.isEmpty()){
                    system.debug('opp-101');
                    //update oppListUpdate;
                }
                
            }
        //}
        
    }
    
    
    /******************************************************************************************************
    * @Description        : Function to move Booking Form to cusotom Document Object                                                                                       
    * @Return             : void   
    * @Author             : Lakshaya           
    * LastModified By     : Ashams
    * Changes             : Added checks using Booking_Form_Generated_Sales__c,SPA_Document_Generated__c for Sales Booking form process                                                        
    *******************************************************************************************************/
    
    public void moveBookingFormToDocument(){
        Set<ID> recordSet = recordNewMap.keySet();
        Set<ID> verifiedIds = new Set<ID>();
        Set<ID> captureContDocId = new Set<ID>();
        Set<ID> contentVersionId = new Set<ID>();
        Boolean hasRecord = false;
        
        for(ID recordId : recordSet){
            System.debug('RecordNewMapBooking: '+recordNewMap.get(recordId).Booking_Form_Generated__c);
            System.debug('RecordOldMapBooking: '+recordOldMap.get(recordId).Booking_Form_Generated__c);
            
            System.debug('RecordNewMapPaymentAdvice: '+recordNewMap.get(recordId).Payment_Advice_Uploaded__c);
            System.debug('RecordOldMapPaymentAdvice: '+recordOldMap.get(recordId).Payment_Advice_Uploaded__c);
            
            System.debug('RecordNewMapPaymentReceipt: '+recordNewMap.get(recordId).Payment_Receipt_Uploaded__c);
            System.debug('RecordOldMapPaymentReceipt: '+recordOldMap.get(recordId).Payment_Receipt_Uploaded__c);   
            
            if(((recordNewMap.get(recordId).Booking_Form_Generated__c  == true) && (recordOldMap.get(recordId).Booking_Form_Generated__c != true)) ||  
               ((recordNewMap.get(recordId).SPA_Document_Generated__c == true) && (recordOldMap.get(recordId).SPA_Document_Generated__c != true))  || 
               ((recordNewMap.get(recordId).Payment_Advice_Uploaded__c == true) && (recordOldMap.get(recordId).Payment_Advice_Uploaded__c != true)) ||
               ((recordNewMap.get(recordId).Payment_Receipt_Uploaded__c == true) && (recordOldMap.get(recordId).Payment_Receipt_Uploaded__c != true)) ||
               ((recordNewMap.get(recordId).Booking_Form_Generated_Sales__c == true) && (recordOldMap.get(recordId).Booking_Form_Generated_Sales__c != true))){
                   System.debug('@@@@@ Phase 2 @@@@@');
                   verifiedIds.add(recordId);
                   hasRecord = true;
               }
        }
        
        
        if(hasRecord){
            
            List<Opportunity> updatedOpportunityContatiner = new List<Opportunity>();
            List<Opportunity> updateOpportunityStage = [Select id, StageName, Booking_Form_Generated__c, Payment_Advice_Uploaded__c,Payment_Advice_Creation_Date__c,
                                                        SPA_Document_Generated__c,Payment_Receipt_Creation_Date__c, Payment_Receipt_Uploaded__c,Booking_Form_Generated_Sales__c 
                                                        from Opportunity where id in :verifiedIds];
            
            for(Opportunity updateOpportunity : updateOpportunityStage){
                if(updateOpportunity.Booking_Form_Generated__c == true){
                    updateOpportunity.Booking_Form_Generated__c = false;
                }else if(updateOpportunity.Payment_Advice_Uploaded__c){
                    updateOpportunity.Payment_Advice_Uploaded__c = false;
                    if(String.isEmpty(String.valueOf(updateOpportunity.Payment_Advice_Creation_Date__c))){
                        updateOpportunity.Payment_Advice_Creation_Date__c = System.today();
                    }
                }else if(updateOpportunity.Payment_Receipt_Uploaded__c){
                    updateOpportunity.Payment_Receipt_Uploaded__c = false;
                    if(String.isEmpty(String.valueOf(updateOpportunity.Payment_Receipt_Creation_Date__c))){
                        updateOpportunity.Payment_Receipt_Creation_Date__c = System.today();
                    }
                }else if(updateOpportunity.Booking_Form_Generated_Sales__c == true){
                    updateOpportunity.Booking_Form_Generated_Sales__c = false;
                }else if(updateOpportunity.SPA_Document_Generated__c == true){
                    updateOpportunity.SPA_Document_Generated__c = false;
                }
                updatedOpportunityContatiner.add(updateOpportunity);
            }
            
            Map<ID,ID> contentDocumentLinkMap = new Map<ID,ID>();
            List<ContentDocumentLink> allIds = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :verifiedIds];
            System.debug('ContentDocumentLink: '+JSON.serialize(allIds));
            for(ContentDocumentLink cl : allIds){
                contentDocumentLinkMap.put(cl.LinkedEntityId, cl.ContentDocumentId);
            } 
            
            System.debug('contentDocumentLinkMap: '+contentDocumentLinkMap);
            System.debug('[V] allIds '+allIds);
            
            for(ContentDocumentLink c : allIds){
                System.debug('Phase 3 ContentDocumentLink '+c);
                captureContDocId.add(c.ContentDocumentId);
            }
            System.debug('[V] captureContDocId '+captureContDocId);
            
            Map<ID,ContentVersion> contentVersionMap = new Map<ID,ContentVersion>();
            List<ContentVersion> contentVersionList = [Select Id,ContentDocumentId, ContentUrl,VersionData,Title,PathOnClient from ContentVersion where ContentDocumentId in :captureContDocId ];
            for(ContentVersion cv : contentVersionList){
                System.debug('Phase 4 ContentVersion '+cv);
                contentVersionMap.put(cv.ContentDocumentId, cv);
                contentVersionId.add(cv.id);
            }
            System.debug('[V] contentVersionMap '+contentVersionMap);
            
            List<Id> docList = new List<Id>();
            Map<ID,ID> obDocMap = new Map<ID,ID>();  
            List<Object_Document__c> objDocument = [Select id, Opportunity__c, Document__c from Object_Document__c where Opportunity__c in :verifiedIds];
            for(Object_Document__c obj : objDocument){
                obDocMap.put(obj.Document__c,obj.Opportunity__c);
                docList.add(obj.Document__c);
            }
            
            List<Document__c> documents = [Select id, Opportunity__c, Opportunity__r.Booking_Form_Generated__c,Purpose__c,
                                           Opportunity__r.SPA_Document_Generated__c, Opportunity__r.Payment_Advice_Uploaded__c,
                                           Opportunity__r.Payment_Receipt_Uploaded__c,Opportunity__r.Booking_Form_Generated_Sales__c, 
                                           Attachment_Id__c, Document_Type__c from Document__c where id in :docList];
            Map<Document__c,ID> documentOpportunityMap = new Map<Document__c,ID>();
            Set<ID> documentId = new Set<ID>();
            
            
            for(Document__c doc : documents){
                System.debug('Phase 5 Document '+doc);
                documentOpportunityMap.put(doc,doc.Opportunity__c);
            }
            List<Document__c> updateDocumentOperation = new List<Document__c>();
            List<ContentVersion> insertContentVersion = new List<ContentVersion>();
            List<ContentDocumentLink> insertContentDocumentLink = new List<ContentDocumentLink>();
            Set<Id> docId = new Set<Id>();
            
            Map<Id,Opportunity> oppDetails = new Map<Id,Opportunity>();
            Map<Id,List<ContentVersion>> contentVersionsToOpp = new Map<Id,List<ContentVersion>>();
            String emailTemplateName;
            
            for(Document__c doc : documents){
                if((doc.Document_Type__c == 'Booking Form' && doc.Opportunity__r.Booking_Form_Generated__c) || 
                   (doc.Document_Type__c == 'SPA' && doc.Opportunity__r.SPA_Document_Generated__c) || 
                   (doc.Document_Type__c == 'Payment Advice' && doc.Opportunity__r.Payment_Advice_Uploaded__c) ||
                   (doc.Document_Type__c == 'Payment Receipt' && doc.Opportunity__r.Payment_Receipt_Uploaded__c) ||
                   (doc.Document_Type__c == 'Booking Form' && doc.Opportunity__r.Booking_Form_Generated_Sales__c)){
                       System.debug('Phase 6 Document and Opportunity ===>'+doc);
                       oppDetails.put(doc.Opportunity__c, recordNewMap.get(doc.Opportunity__c));
                       Id contentDocumentId = contentDocumentLinkMap.get(doc.Opportunity__c);
                       ContentVersion contentVersionOpportunity = contentVersionMap.get(contentDocumentId);
                       ContentVersion contentVersionDocument = new ContentVersion();
                       contentVersionDocument.ContentDocumentId = contentDocumentId;
                       contentVersionDocument.Title = contentVersionOpportunity.Title;
                       contentVersionDocument.PathOnClient = contentVersionOpportunity.PathOnClient;
                       contentVersionDocument.VersionData = contentVersionOpportunity.VersionData;
                       insertContentVersion.add(contentVersionDocument);
                       contentVersionsToOpp.put(doc.Opportunity__c , insertContentVersion);

                       ContentDocumentLink cdLinkDocument = new ContentDocumentLink();
                       cdLinkDocument.LinkedEntityId = doc.Id;
                       cdLinkDocument.ContentDocumentId = contentDocumentId;
                       insertContentDocumentLink.add(cdLinkDocument);
                       
                       doc.Attachment_Id__c = contentDocumentId;
                       doc.Opportunity__c = obDocMap.get(doc.id);
                       updateDocumentOperation.add(doc);  
                       
                       if(doc.Document_Type__c == 'Booking Form' && doc.Purpose__c !='Sales'){
                           docId.add(doc.Id);
                           emailTemplateName = ConstantUtility.LEASING_BOOKING_FORM;
                       }else if(doc.Document_Type__c == 'Payment Advice'){
                           docId.add(doc.Id);
                           emailTemplateName = ConstantUtility.LEASING_PAYMENT_ADVICE;
                       }else if(doc.Document_Type__c == 'Payment Receipt'){
                           docId.add(doc.Id);
                           emailTemplateName = ConstantUtility.LEASING_PAYMENT_RECEIPT;
                       }
                       
                   }
            }  
            
            try{
                System.debug('@@@@@ Before Update: '+updatedOpportunityContatiner);
                update updatedOpportunityContatiner;
                update updateDocumentOperation;
                //insert insertContentVersion;
                insert insertContentDocumentLink;
                
                if(docId.size() > 0){
                    sendEmailToCustomer(contentVersionsToOpp, oppDetails, emailTemplateName);
                    
                    //List<ContentDocumentLink> cdLinkList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: docId];
                    //if(cdLinkList.size() > 0){
                    //     Delete cdLinkList;
                    // }
                    
                }
                
            }
            catch (Exception ex){
                system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
            }  
            
        }
    } 
    
       /**********************************************************************************************
        * @Description  : Method to send email to customer after new lease document creation.
        * @Params       : Map<Id,List<ContentVersion>> contentVersionsToOpp
        * @Param        : Map<Id,Opportunity> oppDetails
        * @Param        : String emailTemplateName
        * @Return       : void
        * @Author       : Sajid Hameed
        **********************************************************************************************/
    public void sendEmailToCustomer(Map<Id,List<ContentVersion>> contentVersionsToOpp, Map<Id,Opportunity> oppDetails, String emailTemplateName){
        // initialize temporary email list
        String accEmail = '';
        String conId = '';
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        
        EmailTemplate emailTemplate = [ SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate 
                                       WHERE name =: emailTemplateName];
        
        System.debug('emailTemplate:  '+ emailTemplate);
        Contact con = [SELECT ID FROM Contact WHERE Email != null LIMIT 1 ];
        
        for(Id oppId : contentVersionsToOpp.keySet()){
            if(oppDetails.containsKey(oppId)){
                accEmail = oppDetails.get(oppId).Email__c;
            }
            system.debug('@@conID :'+con.Id);
            System.debug('accEmail:  '+ accEmail);
            List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
            // initialize one or more single emails as you need 
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            for(ContentVersion cv : contentVersionsToOpp.get(oppId)){
                Blob fileData  = cv.VersionData;  
                Messaging.EmailFileAttachment efa = new Messaging.EmailfileAttachment();
                efa.setFileName(cv.Title);
                efa.setBody(fileData);
                efaList.add(efa);
            }
            // set the recipient email
            message.setToAddresses(new String[] {accEmail });
            // set the email template id
            message.setTemplateId(emailTemplate.Id);
            // do not save email as activity
            message.setSaveAsActivity(false);
            // set the id for the object
            message.setWhatId(oppId);
            // set target object id as your current user id
            message.setTargetObjectId( con.ID );
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
        
        OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress();
        if(!String.isBlank(AppSettings__c.getValues('OrgWideEmailAddressForLeasing').TextValue__c)){
            orgWideEmailAddress = EmailNotificationHelper.getOrgWideEmailAddress(AppSettings__c.getValues('OrgWideEmailAddressForLeasing').TextValue__c);
        }
        system.debug(orgWideEmailAddress.Id);
        // loop through the previous message list and set the email fields
        for (Messaging.SingleEmailMessage email : messageList) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());
            if(orgWideEmailAddress!=null){
                emailToSend.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
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
                system.debug('@@Error :'+errorMessage);
            }
        }
    }
    
    
    /*
//Queueable interface: Enqueue first method of Ejari_XMLConstructorUtil class and chain another queueable interface  
public class Ejari_QueueableHandler1 implements Queueable{
String userName;
String password;
public Ejari_QueueableHandler1(String userName, String password){
this.userName = userName;
this.password = password;
}
public void execute(QueueableContext context) {
try{
Ejari_XMLConstructorUtil.CreatePendingTenancyContractRequest(userName,password);
System.enqueueJob(new Ejari_QueueableHandler2(userName,password));
}catch(Exception e){
system.debug('error: '+e.getMessage()+' At line:'+e.getLineNumber());
}
}    

}

//Queueable interface: Enqueue second method of Ejari_XMLConstructorUtil class 
public class Ejari_QueueableHandler2 implements Queueable{
String userName;
String password;
public Ejari_QueueableHandler2(String userName, String password){
this.userName = userName;
this.password = password;
}
public void execute(QueueableContext context) {
Ejari_XMLConstructorUtil.PrintTcByContractNumber(userName,password);
}    

}

// Below method will help in enqueueing the Ejari_QueueableHandler1 interface
public static void executeEjariQueueble(String userName, String password){
try{
System.enqueueJob(new Ejari_QueueableHandler1(userName,password));
}catch(Exception e){
system.debug('error: '+e.getMessage()+' At line:'+e.getLineNumber());
}
}*/
    
    /**********************************************************************************************
* @Description  : Method to create sales order in ERP system
* @Params       : List< Opportunity > newList
* @Param        : Map< Id, Opportunity > oldMap
* @Return       : void
* @Author       : Karishma Kotian
**********************************************************************************************/
    /* public void createSalesOrderERP(){
Set<Id> opportunityId = new Set<Id>();

for(Opportunity oppty : recordNewList){
if(oppty.Send_Lease_to_ERP__c && (recordOldMap == null || oppty.Send_Lease_to_ERP__c != recordOldMap.get(oppty.Id).Send_Lease_to_ERP__c)){
opportunityId.add(oppty.Id);
}
}
if(!opportunityId.isEmpty()){
createOpportunitySalesOrder(opportunityId);
}
}


public Static void createOpportunitySalesOrder(Set<Id> opportunityIds) {
createOpportunitySalesOrderQueueable createOpptySONewObj = new createOpportunitySalesOrderQueueable(opportunityIds);
system.enqueueJob(createOpptySONewObj);
}


public class createOpportunitySalesOrderQueueable implements system.Queueable, Database.AllowsCallouts{
Private  Set<Id> opportunityIds;
public createOpportunitySalesOrderQueueable(set<Id> opportunityIds){
this.opportunityIds=opportunityIds;
}
public void execute(QueueableContext content){
ERPAPIIntegration.createSalesOrder(opportunityIds);
}
}
*/
    
    /**********************************************************************************************
* @Description  : Method to create Opportunity in ERP system
* @Params       : List< Opportunity > newList
* @Param        : Map< Id, Opportunity > oldMap
* @Return       : void
* @Author       : Karishma Kotian
**********************************************************************************************/
    public void createOpportunityERP(){
        system.debug('@@ recordNewList inside opptyERP method :'+recordNewList);
        Set<Id> opportunityId = new Set<Id>();
        
        for(Opportunity oppty : recordNewList){
            if(oppty.Send_Opportunity_to_ERP__c && oppty.ERP_Opportunity_ID__c == null && (recordOldMap == null || oppty.Send_Opportunity_to_ERP__c != recordOldMap.get(oppty.Id).Send_Opportunity_to_ERP__c)){
                opportunityId.add(oppty.Id);
            }
        }
        if(!opportunityId.isEmpty()){
            ERPIntegrationHelper.createOpportunities(opportunityId);
        }
    }
    
    /********************************************************************************************** 
* @Description  : Create Leasing Property records from Opportunity
* @Params       : NA
* @Return       : void
* @Author       : Jayesh Shewale
**********************************************************************************************/
    
    public void createLeasingProperty(){
        List<Property__c> leasingPropertyList = new List<Property__c>();
        Set<Id> updatedOpportunity = new Set<Id>();
        List<Unit__c> units = new List<Unit__c>();
        Id recordTypeId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Shop_Opportunity').getRecordTypeId();
        Id recordTypeId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Unit_Opportunity').getRecordTypeId();
        Id recordTypeId3 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Unit_Corporate').getRecordTypeId(); 
        //by hitesh on 21 May for lease renewal
        Id oppCommRenewRcdTyp= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Lease Renewal').getRecordTypeId();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Lease_Renewal').getRecordTypeId();
        
        
       try{
        for(Opportunity opp : recordNewList){
            if((opp.RecordTypeId == recordTypeId1) || (opp.RecordTypeId ==  recordTypeId2) || (opp.RecordTypeId ==  recordTypeId3) || (opp.RecordTypeId ==  oppCommRenewRcdTyp) || (opp.RecordTypeId ==  oppRecordTypeId)){
                if((opp.StageName == 'Leased'|| opp.StageName == 'Renewed') && (opp.StageName !=  recordOldMap.get(opp.Id).StageName)){
                    updatedOpportunity.add(opp.Id);
                }
            }
        }
        System.debug('@@@ updatedOpportunity '+ updatedOpportunity);
        if(!updatedOpportunity.isEmpty()){
        list<Unit_Plan__c > unitList = new List<Unit_Plan__c>([SELECT Id ,Unit__c, Opportunity__r.AccountId,
                                                               Opportunity__r.Lease_Start_Date__c,Final_Lease_Amount__c,Opportunity__r.Email__c,
                                                               Opportunity__r.Lease_End_Date__c,Opportunity__c, Name,Renewal_new_unit__c FROM Unit_Plan__c  
                                                               WHERE Opportunity__c IN : updatedOpportunity and Renewal_new_unit__c=true ]);
        System.debug('@@@ '+ unitList.size() );
        if(!unitList.isEmpty()){
            for(Unit_Plan__c u : unitList){
                Property__c propRec=new Property__c();
                propRec.Unit__c= u.Unit__c;
                propRec.Account__c =u.Opportunity__r.AccountId; 
                propRec.Deal__c =u.Opportunity__c;
                propRec.Start_Date__c=u.Opportunity__r.Lease_Start_Date__c;
                propRec.End_Date__c  =u.Opportunity__r.Lease_End_Date__c;
                propRec.Status__c = 'Leased';
                propRec.Active__c= true;
                propRec.Primary_Email__c=u.Opportunity__r.Email__c;
                leasingPropertyList.add(propRec);
                
                // Added by Karishma Kotian to link opportunity to unit
                Unit__c unit = new Unit__c();
                unit.Id = u.Unit__c;
                unit.Opportunity__c = u.Opportunity__c;
                unit.Current_Rent__c = u.Final_Lease_Amount__c;
                units.add(unit);
            }
            System.debug('@@@ '+  leasingPropertyList);
            Database.SaveResult[] srList = Database.insert(leasingPropertyList,false);
            
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Fields that affected this error: ' + err.getFields());
                    }
                }
            }
            
            if(!units.isEmpty()){
                update units;
            }
            
        }
        }    
        }
        catch(exception e){
            system.debug('Error Message >>>>>'+e.getMessage());
            system.debug('Error Line No. >>>>>'+e.getLineNumber());
            
        }
    }
    
    public static void getFields(List <Opportunity> listOpportunity){
        Set <Id> setOpportunityId = new Set <Id>();
        Opportunity opp;
        for(Opportunity op : listOpportunity){
            setOpportunityId.Add(op.Id);
        }
        for(Opportunity op : [SELECT Amount,Discount_Amount__c,Email__c,Bank__c,Discount_Type__c,Unit_Building__c,
                              Account.Address_Line__c,Account.Free_Zone_Client_Number__c,Account.Gender__c,
                              Account.Passport_Expiry_Date__c,Account.Passport_Issue_Date__c,
                              Account.Passport_Issue_Place__c,Account.Passport_Number__c,Account.Trade_License_Issuer__c,
                              Account.Trade_License_Number__c,Account.VAT_Registration_Number__c,Account.Visa_End_Date__c,
                              Account.Visa_Number__c,Account.Visa_Start_Date__c,Account.Website,Unit__r.Built_Up_Area__c,
                              Unit__r.DEWA_Number__c,Unit__r.DLD_Land_Number__c,Unit__r.Property_Unit_Type__c,
                              Unit__r.Unit_code__c,Unit__r.Security_Deposit__c,Contact__r.Birthdate,Contact__r.MailingCountry,
                              Contact__r.MobilePhone,Contact__r.Name FROM Opportunity WHERE Id IN:setOpportunityId]){
                                  
                                  opp = new Opportunity();
                                  opp = op;                      
                              }
    }
    
    /*added by Gaurav to check for POA*/
    public static void checkForPOA(List<Opportunity> newList, Map<Id, Opportunity> recordNewMap){
        System.debug('Heelo this opp module runs');
        Set<Id> poaAddedOppIdSet = new Set<Id>();
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        List<Document__c> documentList = new List<Document__c>();
        for(Opportunity opp: newList){
            if(opp.Power_Of_Attorney__c!=null && opp.POA_Added__c==false){
                poaAddedOppIdSet.add(opp.Id);
                Document__c documentPOA = new Document__c();
                documentPOA.Document_Type__c = 'POA(Power Of Attorney)';
                documentPOA.Opportunity__c = opp.Id;
                documentPOA.Object__c = 'Opportunity';
                documentPOA.Checkbox_Field_API_Name__c = 'POA_Document__c';
                documentList.add(documentPOA);
                
                Document__c documentPassport = new Document__c();
                documentPassport.Document_Type__c = 'POA - Passport';
                documentPassport.Opportunity__c = opp.Id;
                documentPassport.Object__c = 'Opportunity';
                documentPassport.Checkbox_Field_API_Name__c = 'POA_Passport__c';
                documentList.add(documentPassport);
                
                Document__c documentEmirates = new Document__c();
                documentEmirates.Document_Type__c = 'POA - Emirates ID';
                documentEmirates.Opportunity__c = opp.Id;
                documentEmirates.Checkbox_Field_API_Name__c = 'POA_Emirates_ID__c';
                documentEmirates.Object__c = 'Opportunity';
                
                documentList.add(documentEmirates);
                
                Document__c documentVisa = new Document__c();
                documentVisa.Document_Type__c = 'POA - Visa';
                documentVisa.Opportunity__c = opp.Id;
                documentVisa.Object__c = 'Opportunity';
                documentVisa.Checkbox_Field_API_Name__c = 'POA_Visa__c';
                documentList.add(documentVisa);
                
            }
        }
        if(documentList.size()>0){
            System.debug('document List>>>'+documentList);
            insert documentList;
            List<Object_Document__c> odList = new List<Object_Document__c>();
            for(Document__c doc: documentList){
                Object_Document__c od = new Object_Document__c();
                od.Opportunity__c = doc.Opportunity__c;
                od.Document__c = doc.Id;
                od.Checkbox_Field_API_Name__c = doc.Checkbox_Field_API_Name__c;
                odList.add(od);
            }
            if(odList.size()>0){
                insert odList;
            }
            for(id oppId : poaAddedOppIdSet){
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                opp.POA_Added__c = true;
                oppUpdateList.add(opp);
            }
            if(oppUpdateList.size()>0){
                update oppUpdateList;
            }
        }
    }
    
    public static void checkPOAAdded(List<Opportunity> newOppList){
        for(Opportunity opp: newOppList){
            if(opp.Power_Of_Attorney__c !=null && opp.POA_Added__c == false){
                opp.POA_Added__c = true;
            }
        }
    }
    /********************************************************************************************** 
* @Description  : Method to update unit status when oppty is closed lost
* @Params       : List<Opportunity> newList
* @Params       : Map<Id, Opportunity> oldMap
* @Return       : void
**********************************************************************************************/    
    public static void updateUnitStatusOnClosedWon( List<Opportunity> newList,Map<Id, Opportunity> recordNewMap, Map<Id, Opportunity> oldMap ){
         List< Unit__c > lstUnitToUpdate = new List< Unit__c >();
        Set<ID> setOppId=new Set<ID>();
        Set<ID> setUnitId=new Set<ID>();
        Id oppCommRenewRcdTyp= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Lease Renewal').getRecordTypeId();
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Lease_Renewal').getRecordTypeId();
        List<Unit_Plan__c> lstOppUnit=new List<Unit_Plan__c>();
        List<Unit__c> lstUpdateUnit=new  List<Unit__c>();
        List<Property__c> lstPropertyToUpdate = new List<Property__c>();
        Map<Id,Id> mapOldOppIdtoNewOppId=new Map<Id,Id>();
        List<Property__c> lstUpdatedProperty = new List<Property__c>();
        
        system.debug('@@@@Inside updateUnitStatusOnClosedWon@@@@');
        
        for( Opportunity opp : newList ){            
            if( opp.StageName != oldMap.get( opp.Id ).StageName && opp.StageName == 'Renewed' &&  (opp.RecordTypeId == oppRecordTypeId ||  opp.RecordTypeId == oppCommRenewRcdTyp) ){
                setOppId.add(opp.Id);
                mapOldOppIdtoNewOppId.put(opp.Opportunity__c,opp.Id);
            }
        }
        if(!setOppId.isEmpty()){
            lstOppUnit=[select id,Unit__c,Unit__r.Unit_Status__c,Unit__r.Base_Rent__c, Unit__r.Renewal_Rent__c,Renewal_new_unit__c ,Opportunity__c,final_lease_amount__c from Unit_Plan__c where Opportunity__c in:setOppId and Renewal_new_unit__c=false ];
            if(!lstOppUnit.isEmpty()){
                for(Unit_Plan__c up:lstOppUnit){
                    system.debug('new unit flag @@@@'+up.Renewal_new_unit__c);
                    Unit__c u=new Unit__c();
                    u.Id=up.Unit__c;
                    u.current_Rent__c= up.final_lease_amount__c;
                    setUnitId.add(up.Unit__c);
                    lstUpdateUnit.add(u);
                }
            }
            if(!lstUpdateUnit.isEmpty()){
                update lstUpdateUnit;
                if(!setUnitId.isEmpty()){
                    lstPropertyToUpdate=[select Id, Name, Account__c, Unit__c, Status__c, Start_Date__c, End_Date__c, Deal__c, Active__c, Unit_Code__c, Unit_Type__c, Primary_Email__c  from Property__c where unit__c in:setUnitId];
                    
                    if(!lstPropertyToUpdate.isEmpty()){
                        for(Property__c p:lstPropertyToUpdate){
                            if( mapOldOppIdtoNewOppId.containsKey(p.Deal__c) )  {
                                Id newOppId=mapOldOppIdtoNewOppId.get(p.Deal__c);
                                p.Deal__c=newOppId;
                                p.Start_Date__c=recordNewMap.get(newOppId).Lease_Start_Date__c;
                                p.End_Date__c=recordNewMap.get(newOppId).Lease_End_Date__c;
                                lstUpdatedProperty.add(p);
                            }
                        }
                        if(!lstUpdatedProperty.isEmpty()){
                            update lstUpdatedProperty;
                        }
                    }
                }
            }
            
            
        }
    }
    /********************************************************************************************** 
* @Description  : Method to update unit status when oppty is closed lost
* @Params       : List<Opportunity> newList
* @Params       : Map<Id, Opportunity> oldMap
* @Return       : void
**********************************************************************************************/
    public static void updateUnitStatusOnClosedLost( List<Opportunity> newList, Map<Id, Opportunity> oldMap ){
        
        List< Unit__c > lstUnitToUpdate = new List< Unit__c >();
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        Id readOnlyUnitSold = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Unit_Sold').getRecordTypeId();        
        
        for( Opportunity opp : newList ){            
            if( opp.StageName != oldMap.get( opp.Id ).StageName && opp.StageName == 'Closed Lost' && ( opp.RecordTypeId == oppRecordTypeId || opp.RecordTypeId == readOnlyDeal || opp.RecordTypeId == readOnlyUnitSold)  ){
                
                if( opp.Unit__c != null ){
                    Unit__c unit = new Unit__c();
                    unit.Id = opp.Unit__c; 
                    unit.Blocked_Status__c = 'Sales'; 
                    unit.Unit_Status__c = 'Blocked';
                    unit.Active_Deal__c = null;
                    if( opp.Unit_Status_Formula__c == 'Booked' ){
                        unit.Blocked_Sub_status__c = 'Booked Cancelled';
                    }else if( opp.Unit_Status_Formula__c == 'Reserved' ){
                        unit.Blocked_Sub_status__c = 'Reserved Cancelled';
                    }else if( opp.Unit_Status_Formula__c == 'Sold' ){
                        unit.Blocked_Sub_status__c = 'Sold Cancelled';
                    }
                    
                    lstUnitToUpdate.add( unit );
                }
            }
        }
        
        if( !lstUnitToUpdate.isEmpty() ){
            update lstUnitToUpdate;
        }
    }
    
    /********************************************************************************************** 
* @Description  : Method to update SPA RecordType to ready only
* @Params       : List<Opportunity> newList
* @Params       : Map<Id, Opportunity> oldMap
* @Return       : void
**********************************************************************************************/
    public static void makeSPAReadOnlyOnClosedLost( List<Opportunity> newList, Map<Id, Opportunity> oldMap ){
        
        List< Agreement__c > lstSPAToUpdate = new List< Agreement__c >();
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        Id readOnlyUnitSold = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Unit_Sold').getRecordTypeId();        
        Id spaReadOnly = Schema.SObjectType.Agreement__c.getRecordTypeInfosByDeveloperName().get('SPA_Read_Only').getRecordTypeId();
        for( Opportunity opp : newList ){            
            if( opp.StageName != oldMap.get( opp.Id ).StageName && opp.StageName == 'Closed Lost' && ( opp.RecordTypeId == oppRecordTypeId || opp.RecordTypeId == readOnlyDeal || opp.RecordTypeId == readOnlyUnitSold)  ){
                
                if( opp.Agreement__c != null ){
                    Agreement__c ag = new Agreement__c(); 
                    ag.Id = opp.Agreement__c;
                    ag.RecordTypeId = spaReadOnly;
                    lstSPAToUpdate.add(ag);
                }
            }
        }
        
        if( !lstSPAToUpdate.isEmpty() ){
            update lstSPAToUpdate;
        }
    }
    
    //Added by Karishma for unit reservation automations
    public void unitReservationStageAutomations(){
        List<Opportunity> newOppties = new List<Opportunity>();
        for(Opportunity deal : recordNewList){
            if(deal.StageName == 'Unit Reservation' && deal.StageName != recordOldMap.get(deal.Id).StageName){
                deal.Send_Opportunity_to_ERP__c = true;
                newOppties.add(deal);
            }
        }
        if(!newOppties.isEmpty()){
            GenericTriggerHandler.createDocRecord(newOppties,'Opportunity');
        }
    }
    //Added by Karishma for Contract Generation Automation
    public void contractGenerationStageAutomations(){
        Id contRecordTypeId = Schema.SObjectType.Lease_Contract__c.getRecordTypeInfosByDeveloperName().get('Renewal_Contract').getRecordTypeId();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Lease_Renewal').getRecordTypeId();
        Id commercialContractTypeId = Schema.SObjectType.lease_contract__c.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Shops_Contract').getRecordTypeId();
        Id residentialContractTypeId = Schema.SObjectType.Lease_Contract__c.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Unit_Contract').getRecordTypeId();
        Id oppCommRenewRcdTyp= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Lease Renewal').getRecordTypeId();

        List<Lease_Contract__c> contractList = new List<Lease_Contract__c>();
        
        for(Opportunity deal : recordNewList){
            system.debug('@@@deal.StageName'+deal.StageName);
            system.debug('@@@recordOldMap.get(deal.Id).StageName'+recordOldMap.get(deal.Id).StageName);
            system.debug('@@@booking fee'+deal.Booking_Fee_gets_collected__c);
            system.debug('@@@security deposit'+deal.Security_Deposit_Recevied__c);
            system.debug('@@@interested in'+deal.Interested_In__c);
            
            if(deal.StageName == 'Contract Generation' && deal.StageName != recordOldMap.get(deal.Id).StageName 
               && (deal.Booking_Fee_gets_collected__c || deal.Security_Deposit_Recevied__c) 
               && deal.Interested_In__c == 'Residential Leasing' && deal.RecordTypeId != oppRecordTypeId && deal.RecordTypeId != oppCommRenewRcdTyp){
                   Lease_Contract__c contract = new Lease_Contract__c();
                   contract.Account__c = deal.AccountId;
                   contract.Opportunity__c = deal.Id;
                   contract.Contract_Start__c = deal.Lease_Start_Date__c;
                   contract.Contract_End__c =  deal.Lease_End_Date__c;
                   contract.Contract_Stages__c = 'Draft';
                   contract.LeasingType__c =  deal.Leasing_Type__c;
                   contract.Account_Email__c = deal.Account_Email__c;
                   system.debug('renewal@@@'+deal.Renewal__c);
                   if(deal.Renewal__c==true){
                       contract.RecordTypeId= contRecordTypeId;
                   }else if(deal.Leasing_Type__c == 'Residential Units'){
                       contract.RecordTypeId= residentialContractTypeId;
                   }else if(deal.Leasing_Type__c == 'Commercial Units'){
                       contract.RecordTypeId= commercialContractTypeId;
                   }
                   contractList.add(contract);
                   
               }
        }
        if(!contractList.isEmpty()){
            insert contractList;
        }
    }
    /********************************************************************************************** 
* @Description  : Method to update Checks On SPA
* @Return       : void
**********************************************************************************************/
    public void SPAChecksUpdate(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        Id readOnlyUnitSold = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Unit_Sold').getRecordTypeId();
        List<Agreement__c> spaList = new List<Agreement__c>();
        Map<String,String> dealMetaDataMap = new Map<String,String>();
        Map<Id,Opportunity> spaIdOppMap = new Map<Id,Opportunity>();
        
        for (Deal_To_Agreement_Mapping__mdt dealMeta: Deal_To_Agreement_Mapping__mdt.getAll().values()){
            dealMetaDataMap.put(dealMeta.Deal_Field_API_Name__c, dealMeta.Agreement_Field_API_Name__c);
        }
        
        for(Opportunity deal : recordNewList){
                        if(deal.Agreement__c != null && (deal.recordTypeId == oppRecordTypeId || deal.recordTypeId == readOnlyDeal || deal.recordTypeId == readOnlyUnitSold )){
                for(String dealField : dealMetaDataMap.keySet()){
                    if(deal.get(dealField) != recordOldMap.get(deal.Id).get(dealField)){
                        spaIdOppMap.put(deal.Agreement__c,deal);
                    }
                }
            }
        }
        
        if(!spaIdOppMap.isEmpty()){
            for(Agreement__c agre : [SELECT Id FROM Agreement__c WHERE Id IN:spaIdOppMap.keySet()]){
                Agreement__c spa = new Agreement__c();
                spa.Id = agre.Id;
                for(String dealFields : dealMetaDataMap.keySet()){
                    spa.put(dealMetaDataMap.get(dealFields), spaIdOppMap.get(agre.Id).get(dealFields));
                }
                spaList.add(spa);
            }
            if(!spaList.isEmpty()){
                update spaList;
            }
        }
        
    }
    /********************************************************************************************** 
* @Description  : Method to Auto Complete Task On Doc Upload
* @Return       : void
**********************************************************************************************/
    public void completeDocUploadTask(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        Set<Id> dealForTaskCompletionIdSet = new Set<Id>();
        for(Opportunity deal : recordNewList){
            if((deal.recordTypeId == oppRecordTypeId || deal.recordTypeId == readOnlyDeal ) && deal.Doc_Uploaded_By_Admin__c && deal.Doc_Uploaded_By_Admin__c != recordOldMap.get(deal.Id).Doc_Uploaded_By_Admin__c){
                dealForTaskCompletionIdSet.add(deal.Id);
            }
        }
        if(!dealForTaskCompletionIdSet.isEmpty()){
            String taskSubject = '%'+ Label.SPA_Doc_Upload_Task_Subject +'%';
            List<Task> taskList = [SELECT Id,Status FROM Task WHERE WhatId In:dealForTaskCompletionIdSet AND Subject LIKE: taskSubject ];
            for(Task tk : taskList){
                tk.Status = 'Completed';
            }
            if(!taskList.isEmpty()){
              //  update taskList;
            }
        }
    }
    /********************************************************************************************** 
* @Description  : Method to Create Receipt Record for Token Amount
* @Return       : void
**********************************************************************************************/
    public void createTokenAmountReceipt(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        List<Receipt__c> receiptList = new List<Receipt__c>();
        for(Opportunity deal : recordNewList){
            if(deal.Token_Amount_Payment_Created__c && (deal.recordTypeId == oppRecordTypeId || deal.recordTypeId == readOnlyDeal ) && deal.Token_Amount_Payment_Created__c != recordOldMap.get(deal.Id).Token_Amount_Payment_Created__c){
                Receipt__c res = new Receipt__c();
                res.Account__c = deal.AccountId;
                res.Amount__c = deal.Token_Amount__c;
                res.Bank__c = deal.Bank__c;
                res.Installment_Type__c = 'Deposit';
                res.Name = 'Token Amount';
                res.Received_For__c = 'Token Amount';
                res.Payment_Status__c = 'Pending';
                res.Opportunity__c = deal.Id;
                res.Payment_Mode__c = deal.Payment_Mode__c;
                res.Receipt_Number__c = deal.Receipt_Number__c;
                receiptList.add(res);
            }
        }
        if(!receiptList.isEmpty()){
            insert receiptList;
        }
    }
    /********************************************************************************************** 
* @Description  : Method to Create Task for Sales Executive by Sales Admin
* @Return       : void
**********************************************************************************************/
    public void createTaskSalesExecutive(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        List<Task> taskList = new List<Task>();
        for(Opportunity deal : recordNewList){
            if(deal.Create_Task__c && (deal.recordTypeId == oppRecordTypeId || deal.recordTypeId == readOnlyDeal ) && deal.Create_Task__c != recordOldMap.get(deal.Id).Create_Task__c){
                NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
                input.relatedTo         =  deal.Id;
                input.currencyIsoCode   = 'AED'; //required
                input.priority          = 'Normal'; //required
                input.status            = 'Open'; //required
                input.subject           = deal.Task_Subject__c != null ? deal.Task_Subject__c : 'Task Created for you by Sales Admin'; //required
                input.assignedTo        = deal.Sales_Executive__c != null ? deal.Sales_Executive__c : deal.OwnerId; //required
                input.fieldUpdate       = null;
                input.dueDate           = null;
                input.description       = deal.Task_Description__c;
                
                Task tsk = CommonUtility.createTask( input );
                taskList.add( tsk );
                
                deal.Create_Task__c = false;
            }
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }
    
    /*******************************************
    * @Description  : Method to generate Opportunity name
    * @Return       : void
    * Added by Ashams :- To generate Opportunity name after lead conversion in sales
    * *************************************/
    public void generateOpportunityNameSales(){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Quick_Book').getRecordTypeId();
        List<Opportunity> oppsList =new List<Opportunity>();
        for(Opportunity opp:recordNewList){
            if(opp.Account_Name__c!=null && oppRecordTypeId == opp.RecordTypeId){
                Opportunity opps= new Opportunity();
                opps.Id = opp.Id;
                opps.Name = opp.Account_Name__c + '-' + opp.Opportunity_Number__c;
                oppsList.add(opps);
            }
        }  
        update oppsList;
    }
    
    /*******************************************

* @Description  : Method to generate Opportunity name
* @Return       : void
* Added by Shraddha :- To generate Opportunity name from units and customers name
* *************************************/
    public void generateOpportunityName(){
        
        if(RecursionController){
            RecursionController = false;
            set<String> oppId = new set<String>();
            for(Opportunity opp:recordNewList){
                if(opp.Account_Name__c!=null)
                    oppId.add(opp.Id);
            }
            List<Opportunity> oppsList =new List<Opportunity> ();
            List<Opportunity> oppList = [select id,RecordType.Name, Account_Name__c,Company_Name__c,
                                         Lease_Start_Date__c,(select unit__r.Unit_Code__c,id,opportunity__c from  Unit_Plans__r ORDER BY CreatedDate ASC) from Opportunity where Id IN:oppId];
            for(Opportunity op:oppList){
                if(System.label.Leasing_RecordTypes.contains(op.RecordType.Name)){
                    if((op.Unit_Plans__r).size()>0 && (op.Unit_Plans__r).size()==1 && op.Unit_Plans__r[0].unit__r.Unit_Code__c!=null && op.Lease_Start_Date__c!=null){
                        String oppName = op.Account_Name__c +'-'+op.Unit_Plans__r[0].unit__r.Unit_Code__c+'-'+(op.Lease_Start_Date__c).year();
                        Opportunity opps= new Opportunity();
                        opps.Name = oppName;
                        opps.Id = op.Id;
                        oppsList.add(opps);
                    }
                    else if((op.Unit_Plans__r).size()>1 && op.Unit_Plans__r[0].unit__r.Unit_Code__c!=null && op.Lease_Start_Date__c!=null){
                        String oppName = op.Account_Name__c +'-'+op.Unit_Plans__r[0].unit__r.Unit_Code__c+'-'+(op.Lease_Start_Date__c).year();          
                        Opportunity opps= new Opportunity();
                        opps.Name = oppName;
                        opps.Id = op.Id;
                        oppsList.add(opps);
                    }
                }
                
            }
            update oppsList;
        }
        
    }
    /*
@Author : Swapnil Mohite
@CreatedDate: 29/03/2022
@ This batch class will handle unit reservation based on reservation mode- this batch will run every 4 hours .
*/
    public void updateBookingReservation(){
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> unitIdSet = new Set<Id>();
        List<Unit_Booking_Reservation__c> ubrList = new List<Unit_Booking_Reservation__c>();
        for(Opportunity opp : recordNewList){
            if(opp.Extension_Days__c !=null && opp.Opportunity_Approval_Status__c == 'Approved' && recordOldMap.get(opp.Id).Opportunity_Approval_Status__c != 'Approved'
               && (opp.Leasing_Type__c == 'Residential Units' || opp.Leasing_Type__c == 'Commercial Units') && opp.Is_Payment_Extension__c == true){
                   oppIdSet.add(opp.Id);
               }
        }
        for(Unit_Plan__c oppUnit : [SELECT id,name,unit__c,Opportunity__c FROM Unit_Plan__c WHERE Opportunity__c IN: oppIdSet]){
            unitIdSet.add(oppUnit.Unit__c);
        }
        for(Unit_Booking_Reservation__c ubrObj : [SELECT Id,Reserved_User__c,Unit__c,Unit__r.Unit_status__c,Deal__r.Opportunity_Approval_Status__c,Deal__r.Booking_Mode__c,
                                                  Deal__r.Security_Deposit_Recevied__c,deal__r.Extension_Days__c,
                                                  Reservation_Date__c,Deal__c,Booking_Mode__c
                                                  FROM Unit_Booking_Reservation__c
                                                  WHERE deal__c IN: oppIdSet AND unit__c IN: unitIdSet]){
                                                      ubrObj.Reservation_Date__c = ubrObj.Reservation_Date__c.addDays(Integer.valueOf(ubrObj.deal__r.Extension_Days__c));
                                                      ubrList.add(ubrObj);
                                                  }
        
        update ubrList;
    }
    /*
@Author : Vishal A
@CreatedDate: 01/04/2022
@ Check checkbox, for Sedn Opportunity to ERP.
*/
public void checkSendOpportunityToERP(){
    for(Opportunity opp : recordNewList){
        Opportunity oldOpp = recordOldMap==null ? null : (Opportunity )recordOldMap.get(opp.Id);
        if(opp.AccountId != null && opp.Unit__c != null && opp.Move_to_Advanced_Screen__c && (oldOpp == null || oldOpp.AccountId == null || oldOpp.Unit__c == null || oldOpp.Move_to_Advanced_Screen__c == false)) {
            opp.Send_Opportunity_to_ERP__c = true;
        }
    }
}
/*
@Author : Kshitij Tiwari
@CreatedDate: 13/04/2022
@ Update Installment amount
*/
    public void UpdateInstallmentAmount(List<Opportunity> recordNewList ,Map<Id,Opportunity> recordOldMap){
        Id oppRecordTypeRLSId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Shop_Opportunity').getRecordTypeId();
        //Id oppRecordTypeRLUId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Unit_Corporate').getRecordTypeId();
        //Id oppRecordTypeRLUOId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Unit_Opportunity').getRecordTypeId();
        
        List<id> OpportId = new List<id>();
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        for(Opportunity opp : recordNewList){
            if((opp.recordTypeId ==oppRecordTypeRLSId) && recordOldMap.get(opp.id).Price_Approval_Status__c != 'Approved' &&
               opp.Price_Approval_Status__c == 'Approved'){
                OpportId.add(opp.id);     
            }
        }
        pmList =[SELECT  Id, name,Payable_Amount__c,Amount__c, New_Payable_Amount__c, Revised_amount__c,installment__c
                 FROM Payment_Milestone__c WHERE Opportunity__c in :OpportId];
        for(Payment_Milestone__c p:pmList){
            if(p.New_Payable_Amount__c !=NULL && p.installment__c!= 'SEC'){
                p.Payable_Amount__c = p.New_Payable_Amount__c;
                p.Amount__c = p.Revised_amount__c;
            }
        }
        update pmList;

       List<Unit_Plan__c> opptyUnitList = [SELECT Id, Final_Lease_Amount__c, Final_Lease_Amount_Calculated__c,Base_Lease_Amount__c,
                                            Base_Lease_Amount_Calculated__c, Discount_Amount_Calculated__c, Discount_Amount__c
                                            FROM Unit_Plan__c WHERE Opportunity__c =: OpportId];
        for(Unit_Plan__c opptyUnit : opptyUnitList){
            opptyUnit.Final_Lease_Amount__c = opptyUnit.Final_Lease_Amount_Calculated__c;
            opptyUnit.Base_Lease_Amount__c = opptyUnit.Base_Lease_Amount_Calculated__c;
            opptyUnit.Discount_Amount__c = opptyUnit.Discount_Amount_Calculated__c;
        }
        update opptyUnitList;

        List<Aggregated_Milestone__c> agregateMilestones = [SELECT Id,Installment__c ,IsAdditionalCharges__c, Amount__c,Calculated_Amount__c FROM Aggregated_Milestone__c WHERE Deal__c =: OpportId];
        for(Aggregated_Milestone__c aggr : agregateMilestones){
            if(!aggr.IsAdditionalCharges__c && aggr.Installment__c != 'SEC' ){
             aggr.Amount__c = aggr.Calculated_Amount__c;
            }
        }
        update agregateMilestones;
    }
       /********************************************************************************************** 
        * @Description  : Method to update SPA RecordType to ready only
        * @Params       : List<Opportunity> newList
        * @Params       : Map<Id, Opportunity> oldMap
        * @Return       : void
        **********************************************************************************************/
        public static void makeSPAReadOnlyOnSPAExecuted( List<Opportunity> newList, Map<Id, Opportunity> oldMap ){
                
            List< Agreement__c > lstSPAToUpdate = new List< Agreement__c >();
            
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
            Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
            Id readOnlyUnitSold = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Unit_Sold').getRecordTypeId();        
            Id spaReadOnly = Schema.SObjectType.Agreement__c.getRecordTypeInfosByDeveloperName().get('SPA_Read_Only').getRecordTypeId();
            for( Opportunity opp : newList ){            
                if( opp.StageName != oldMap.get( opp.Id ).StageName && opp.StageName == 'SPA Executed' && opp.Unit_Status_Formula__c == 'Sold'  && ( opp.RecordTypeId == oppRecordTypeId || opp.RecordTypeId == readOnlyDeal || opp.RecordTypeId == readOnlyUnitSold)  ){
                    
                    if( opp.Agreement__c != null ){
                        Agreement__c ag = new Agreement__c(); 
                        ag.Id = opp.Agreement__c;
                        ag.RecordTypeId = spaReadOnly;
                        lstSPAToUpdate.add(ag);
                    }
                }
            }
            
            if( !lstSPAToUpdate.isEmpty() ){
                update lstSPAToUpdate;
            }
        }
    
     /******************************************************************************************************
    * @Description        : Check if Reject Deal is Approved to create further tasks                                                                                             
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void rejectDealTaskCreation(List<Opportunity> newList){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        List<Opportunity> oppList = new List<Opportunity>();
        for(Opportunity opp : newList){
            if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal ) && opp.Reject_Deal_CEO_Form_Upload_Task__c &&  opp.Reject_Deal_CEO_Form_Upload_Task__c != recordOldMap.get(opp.Id).Reject_Deal_CEO_Form_Upload_Task__c){
                oppList.add(opp);
            }
        }
        if(!oppList.isEmpty()){
            TaskToSalesOperationHeadToUploadCEOApprovalDoc(oppList);
            taskToArFinanceTeamToInitiateRefund(oppList);
        }
    } 

       /******************************************************************************************************
    * @Description        : Task Sales Operation Head To Upload Approval Doc from CEO to Reject deal                                                                                            
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void TaskToSalesOperationHeadToUploadCEOApprovalDoc(List<Opportunity> newList){
        List<Task> taskList = new List<Task>();
        List<User> userList = [SELECT Id,Name FROM User WHERE Name =: Label.Sales_Operations_Head_User_Name AND IsActive = true];
        /*List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Registration_Team' LIMIT 1];*/
        for(Opportunity opp : newList){
            NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
            input.relatedTo         =  opp.Id;
            input.currencyIsoCode   = 'AED'; //required
            input.priority          = 'Normal'; //required
            input.status            = 'Open'; //required
            input.subject           = 'Please upload approval document from the CEO'; //required
            input.assignedTo        = userList.size() > 0 ? userList[0].Id : opp.OwnerId; //required
            input.fieldUpdate       = 'Approval_Doc_From_CEO_Uploaded__c';
            input.dueDate           = null;
            input.description       = 'Upload approval document from the CEO in document section.';
            
            Task tsk = CommonUtility.createTask( input );
            taskList.add( tsk );
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }

        /******************************************************************************************************
    * @Description        : Task AR_Finance_Team To Initiate Refund for Cleared receipts                                                                                            
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void taskToArFinanceTeamToInitiateRefund(List<Opportunity> newList){
        List<Task> taskList = new List<Task>();
        List<Group> queueId = [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'AR_Finance_Team' LIMIT 1];
        for(Opportunity opp : newList){
            NKLWrapperUtil.TaskWrapper input = new NKLWrapperUtil.TaskWrapper();
            input.relatedTo         =  opp.Id;
            input.currencyIsoCode   = 'AED'; //required
            input.priority          = 'Normal'; //required
            input.status            = 'Open'; //required
            input.subject           = 'Initiate the refund of the receipts values that have been cleared.'; //required
            input.assignedTo        = queueId.size() > 0 ? queueId[0].Id : opp.OwnerId; //required
            input.fieldUpdate       = null;
            input.dueDate           = null;
            input.description       = 'Initiate the refund of the receipts values that have been cleared.';
            
            Task tsk = CommonUtility.createTask( input );
            taskList.add( tsk );
        }
        if(!taskList.isEmpty()){
            insert taskList;
        }
    }

        /******************************************************************************************************
    * @Description        : Auto Close Approval Doc Upload from CEO Task                                                                                              
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void closeCEOApprovalDocTask(List<Opportunity> newList){
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        Id readOnlyUnitSold = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Unit_Sold').getRecordTypeId();
        Set<Id> oppIdSet = new Set<Id>();
        for(Opportunity opp : newList){
            if((opp.recordTypeId == oppRecordTypeId || opp.recordTypeId == readOnlyDeal || opp.recordTypeId == readOnlyUnitSold ) && opp.Approval_Doc_From_CEO_Uploaded__c &&  opp.Approval_Doc_From_CEO_Uploaded__c != recordOldMap.get(opp.Id).Approval_Doc_From_CEO_Uploaded__c){
                oppIdSet.add(opp.Id);
            }
        }
        if(!oppIdSet.isEmpty()){
            List<Task> taskList = [SELECT Id,Status FROM Task WHERE WhatId In:oppIdSet AND Subject ='Please upload approval document from the CEO'];
            for(Task tk : taskList){
                tk.Status = 'Completed';
            }
            if(!taskList.isEmpty()){
                update taskList;
            }
        }
    }

          /********************************************************************************************** 
* @Description  : populate project name when leasing getting updated
* @Params       : 
* @Return       : void
* @Author       : Sajid Hameed
**********************************************************************************************/
    public void populateProjectName(String callingContext){
        Id oppRenewRecordType= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Lease Renewal').getRecordTypeId();
        Id residentialCorporateTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Unit_Corporate').getRecordTypeId();
        Id residentialUnitTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Unit_Opportunity').getRecordTypeId();
        Id residentialShopTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Shop_Opportunity').getRecordTypeId();
        Id leasingRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Leasing_Records').getRecordTypeId();
        Id oppCommRenewRcdTyp= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Lease Renewal').getRecordTypeId();

        Set<ID> projectIdsSet = new Set<ID>();
        // opp for loop on recordnewlist -->
        // get project ids in set
        // then query project for project name
        // for loop on recordnewlist
        // check if project id is matching and project is not same in map
        for(opportunity opp :recordNewList){
            if(opp.Project__c != null){
                projectIdsSet.add(opp.Project__c);
            }
        }
        
        if(projectIdsSet.size() > 0){
            Map<Id, Project__c> projectMap = new Map<Id, Project__c>([Select Id, Name from Project__c where Id IN: projectIdsSet]);
            System.debug('projectMap '+ projectMap);
            for(opportunity opp :recordNewList){
                System.debug('project '+ opp.Project__c);
                if(opp.Project__c != null){
                    Project__c project = projectMap.get(opp.Project__c);
                    if(callingContext == 'Insert'){
                        if(opp.Project__c == project.Id && (opp.RecordTypeId == oppRenewRecordType
                            || opp.RecordTypeId == oppCommRenewRcdTyp
                           || opp.RecordTypeId == residentialShopTypeId
                           || opp.RecordTypeId == residentialUnitTypeId
                           || opp.RecordTypeId == residentialCorporateTypeId 
                           || opp.RecordTypeId == leasingRecordTypeId)){
                               
                                   opp.Project_Name_Text__c = project.Name;
                           }
                    }else if(callingContext == 'Update'){
                        if(opp.Project__c == project.Id && opp.Project__c != recordOldMap.get(opp.Id).Project__c 
                           && (opp.RecordTypeId == oppRenewRecordType
                           || opp.RecordTypeId == oppCommRenewRcdTyp
                           || opp.RecordTypeId == residentialShopTypeId
                           || opp.RecordTypeId == residentialUnitTypeId
                           || opp.RecordTypeId == residentialCorporateTypeId 
                           || opp.RecordTypeId == leasingRecordTypeId)){
                               
                                   opp.Project_Name_Text__c = project.Name;
                           }
                    }
                }
            }
        }
    }

        /******************************************************************************************************
    * @Description        : Function to send alert to Sales Executive when Sales Admin is assigned to a deal                                                                                          
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void alertToSalesExecutiveOnAdminAssignment(List<Opportunity> recList){
        Id readOnlyDeal = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Deal_Read_Only').getRecordTypeId();
        List<Opportunity> newOppList = new List<Opportunity>();
        for(Opportunity opp : recList){
            if(opp.recordTypeId == readOnlyDeal && opp.Sales_Admin__c != null && opp.Sales_Admin__c != recordOldMap.get(opp.Id).Sales_Admin__c){
                newOppList.add(opp);
            }
        }
        if(!newOppList.isEmpty()){
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
                                    WHERE DeveloperName ='Deal_Assignment_Email_Template'];
            List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
            for(Opportunity opp: newOppList){
                NKLWrapperUtil.SendEmailWrapper input = new NKLWrapperUtil.SendEmailWrapper();
                input.whoId                    = con.Id;
                input.whatId                   = opp.Id;
                input.orgWideAddress           = orgAddress.size() > 0 ? orgAddress[0].Id : null;
                input.emailTemplateId          = template.size() > 0 ? template[0].Id : null;
                input.setTargetAsRecipient     = false;
                input.senderDisplayName        = UserInfo.getName();
                input.additionalEmailAddresses = new List< String >{opp.Sales_Executive_Email__c};
                    
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
        
    }
    
    /**********************************************************************************************
    * @Description  : Method to terminate agreement in ERP system
    * @Param        : no
    * @Return       : void
    * @Author       : Husain Sayyed
    **********************************************************************************************/
    public void terminateSPARecord(){
        List<Agreement__c> agreementToUpdateList = New List<Agreement__c >();
        
        for(opportunity oppourtunityRecord : recordNewList){
            if(oppourtunityRecord.Agreement__c != null && oppourtunityRecord.Termination_Date__c != null && oppourtunityRecord.Termination_Date__c !=  recordOldMap.get(oppourtunityRecord.Id).Termination_Date__c){
                Agreement__c agreement = new Agreement__c();
                agreement.Id = oppourtunityRecord.Agreement__c;
                agreement.Termination_Date__c = oppourtunityRecord.Termination_Date__c;
                agreement.Termination_Reason__c = oppourtunityRecord.Termination_Reason__c;
                agreement.Sync_Agreement_Termination__c = true;
                agreement.SPA_Terminated__c = true;
                agreementToUpdateList.add(agreement);
            }
        }
        
        if(agreementToUpdateList.isEmpty() == false){
            update agreementToUpdateList;
        }
    
    }
}