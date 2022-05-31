/**
* @author : Muhammad Moneeb
* @createdDate : 21-Dec-2021
* @lastModifieddate : 21-Dec-2021
* @purpose : Initial Development
* @usage : TriggerHandler for Case. 
*/
public class CaseTriggerHandler {
    
    public void BeforeInsertEvent(List<Case> newCaseList, Map<Id, Case> recordNewMap){
        addSubjectToHandoverEndOfLeaseCase(newCaseList, recordNewMap);
        //Commented by Anshita on 24-05-2022 as it is covered in Validation Rule
       // blockCaseCreationIfRegistrationNotCompleted(newCaseList,new Map<Id,Case>(),'BEFORE_INSERT');
        tagActiveAccntDealAgreementonCase(newCaseList);//Added BY Mamta 21 may
    }
    
    public void BeforeUpdateEvent(List<Case> newCaseList,Map<Id, Case> recordOldMap,Map<Id, Case> recordNewMap) {
        GenericTriggerHandler.validateDocRecord(newCaseList,recordOldMap,recordNewMap,'Case');
        ServiceRequestActions.validateCaseTypeChange(newCaseList,recordOldMap,recordNewMap);
        //ServiceRequestActions.validateCaseUnit(newCaseList,recordOldMap,recordNewMap); Commented by Karishma as this error is not in use
        checkIfHandoverCaseTenantAgreementUpdloaded(newCaseList, recordOldMap);
        //ServiceRequestActions.renewalActions(newCaseList, recordOldMap,recordNewMap); Commented by Karishma 9th April as there is no renewal recordtype for case in QA
        alertonApproval(newCaseList, recordOldMap , recordNewMap);
       //Commented by Anshita on 24-05-2022 as it is covered in Validation Rule
       // blockCaseCreationIfRegistrationNotCompleted(newCaseList,recordOldMap,'BEFORE_UPDATE');
    }
    
    public void AfterInsertEvent(List<Case> newCaseList, Map<Id, Case> recordOldMap, Map<Id, Case> recordNewMap) {
        GenericTriggerHandler.createDocRecord(newCaseList , 'Case');
        //ServiceRequestActions.PaymentTermsAmendmentAtions(newCaseList); //commented by Ashams as Payment Amendment process is not in QA
        ServiceRequestActions.AddRemoveJointOwnerActions(newCaseList);   //Added By Mamta 4 Feb 2022 
        //addCaseUnits(newCaseList, recordOldMap);
        ServiceRequestActions.singleUnitAccInsert(newCaseList);
        addCaseUnitsAndSubjectToHandoverMoveInCase(newCaseList, recordOldMap);
        updateContactDetails(newCaseList);
        deactivateAccessCard(newCaseList,recordOldMap);
        ServiceRequestActions.preMatureTerminationActions(newCaseList,recordOldMap,recordNewMap);
    }
    
    public void AfterUpdateEvent(List<Case> newCaseList,Map<Id, Case> recordOldMap,Map<Id, Case> recordNewMap){
        //ServiceRequestActions.autoUpdStatusReSR(newCaseList, recordOldMap);
        //handoverUpdateForClosedHandoverCases(newCaseList, recordOldMap);
        ServiceRequestActions.singleUnitAccUpdated(newCaseList,recordOldMap);
        ServiceRequestActions.preMatureTerminationActions(newCaseList,recordOldMap,recordNewMap);
        updateRelatedUnitStatusAfterCompleted(newCaseList, recordOldMap, recordNewMap);
        ServiceRequestActions.createCaseAndOppPostApproval(newCaseList,recordOldMap,recordNewMap);
        moveSPAFormToDocument(newCaseList,recordOldMap,recordNewMap);
        serviceRequestClosureAutomations(newCaseList,recordOldMap);
        updateContactDetails(newCaseList);
        deactivateAccessCard(newCaseList,recordOldMap);
        moveOutFormToDocument(newCaseList,recordOldMap,recordNewMap);
        endOfLeaseFormToDocument(newCaseList,recordOldMap,recordNewMap);
        sendEmailOnDocumentVerificationStage(newCaseList,recordOldMap,recordNewMap);
        //Added by Ashok
        createHistoryRecord(newCaseList,recordOldMap,'Case');
        //Added by VISHAL
        sendFinancialDetailERP(newCaseList,recordOldMap);
        displayErrorOnLeasingManagerApproval(newCaseList, recordOldMap);
        markTitleDeedComplete(newCaseList, recordOldMap);//Added by Anshita on 23-05-2022 for Title Deed SR
    }
/******************************************************************************************************
* @Description        : Function to track the Case modification history into the History__c object                                                                                      
* @Return             : void   
* @Author             : Ashok                                                                     
*******************************************************************************************************/ 
public static void createHistoryRecord(List<sObject> newList,Map<ID,sObject> oldMap ,String objectName){
    List<History_Management__mdt> hmList = [Select id,Field_API_Name__c,Field_Label_Name__c from History_Management__mdt 
                                            where Object_Name__c =: objectName];
    List<History__c> historyObjectList = new List<History__c>();
    for(History_Management__mdt hm : hmList){
        for(sObject obj :newList){
            if(obj.get(hm.Field_API_Name__c) != oldMap.get(obj.ID).get(hm.Field_API_Name__c)){
                History__c hist = new History__c ();
                hist.Field_Name__c = hm.Field_Label_Name__c;
                hist.New_Value__c = String.valueof(obj.get(hm.Field_API_Name__c));
                hist.Old_Value__c = String.valueof(oldMap.get(obj.ID).get(hm.Field_API_Name__c));
                hist.Case__c = obj.ID;
                historyObjectList.add(hist);
            }
        }
    }
    if(historyObjectList.size() > 0){
        insert historyObjectList;   
    }
}  
/******************************************************************************************************
* @Description        : Function to block Case Creation If Registration Not Completed                                                                                       
* @Return             : void   
* @Author             : Ashok                                                                     
*******************************************************************************************************/
/*public static void blockCaseCreationIfRegistrationNotCompleted(List<Case> newCaseList,Map<Id, Case> recordOldMap,String triggerContext){
    Set<Id> applicableCaseRecordTypes = new Set<Id>{
        getSchemaInstance().getRecordTypeInfosByName().get('Title Deed').getRecordTypeId()
                                                    }; //Add more record type api names to extend
    Map<Id,Boolean> dealIdRegistrationCompleteStatusMap = new Map<Id,Boolean>();
    Map<Id,Id> unitVsOpptyIdMap = new Map<Id,Id>();
    Set<Id> affetedDealId = new Set<Id>();
    Set<Id> affetedUnitId = new Set<Id>();
    
    for(Case cse : newCaseList){
        if(applicableCaseRecordTypes.contains(cse.recordTypeId)){
            if(cse.Deal__c <> Null && (triggerContext == 'BEFORE_INSERT' || (triggerContext == 'BEFORE_UPDATE' && cse.Deal__c <> recordOldMap.get(cse.Id).Deal__c))) {
                affetedDealId.add(cse.Deal__c);
            }
            if(cse.Unit__c <> Null && (triggerContext == 'BEFORE_INSERT' || (triggerContext == 'BEFORE_UPDATE' && cse.Unit__c <> recordOldMap.get(cse.Id).Unit__c))) {
                affetedUnitId.add(cse.Deal__c);
            }
        }       
    }
    for(Unit__c unit : [SELECT Id,Active_Deal__c from Unit__c WHERE Id IN :affetedUnitId]){
        affetedDealId.add(unit.Active_Deal__c);
        unitVsOpptyIdMap.put(unit.Id,unit.Active_Deal__c);
    }
    //Assumption : Though Registration object has a lookup to Opportunity, there will be one registration for an opportunity, to track the status of registration
    for(Registration__c reg : [SELECT Opportunity__c,Status__c from Registration__c WHERE Opportunity__c IN :affetedDealId]) {
        if(reg.Status__c == 'Registration Complete'){
            dealIdRegistrationCompleteStatusMap.put(reg.Opportunity__c,true);
        }
        else{
            dealIdRegistrationCompleteStatusMap.put(reg.Opportunity__c,false);
        }
    }
    for(Case cse : newCaseList){
        if(cse.unit__c <> Null && unitVsOpptyIdMap.containsKey(cse.unit__c) && dealIdRegistrationCompleteStatusMap.containsKey(unitVsOpptyIdMap.get(cse.unit__c)) && !dealIdRegistrationCompleteStatusMap.get(unitVsOpptyIdMap.get(cse.unit__c))){
             cse.addError('Registration team clearance must be provided before submitting for approval.');
        }
        if(cse.Deal__c <> Null && dealIdRegistrationCompleteStatusMap.containsKey(cse.Deal__c) && !dealIdRegistrationCompleteStatusMap.get(cse.Deal__c)) {
            cse.addError('Registration team clearance must be provided before submitting for approval.');
        }
    }
} */
/******************************************************************************************************
* @Description        : Single-ton Function approach to make Schema Describe calls                                                                                       
* @Return             : Map<String, Schema.SObjectType>   
* @Author             : Ashok                                                                     
*******************************************************************************************************/
private static Schema.DescribeSObjectResult schemaInst = null;
public static Schema.DescribeSObjectResult getSchemaInstance() {
    if (schemaInst == null) 
            schemaInst = Schema.SObjectType.Case;
        return schemaInst;
}     

 /******************************************************************************************************
* @Description        : Function to move SPA generated with joint owners  Form to custom Document Object                                                                                       
* @Return             : void   
* @Author             : Mamta         
* @Modified By        : Karishma 
* @Modifiation        : to reuse the code for other documents                                                             
*******************************************************************************************************/    
    public static void moveSPAFormToDocument(List<Case> newCaseList,Map<Id, Case> recordOldMap,Map<Id, Case> recordNewMap){
        Set<ID> verifiedIds = new Set<ID>();
        Map<ID,ID> agreementIdsMappedToCase = new Map<ID,ID> ();
        String documentType= system.label.SPA_DOC_SR;
        for(Case cs : recordNewMap.values()){
            if(recordNewMap.get(cs.ID).SPA_Generated__c && !recordOldMap.get(cs.ID).SPA_Generated__c ){
                System.debug('@@@@@ Phase 2 @@@@@');
                verifiedIds.add(cs.ID);
                agreementIdsMappedToCase.put(cs.ID, cs.Agreement__c);
            }
        }
        attachFilesToDocument(verifiedIds,documentType,agreementIdsMappedToCase);
    }
    
    /*Added BY Mamta- Throw error if approved/rejected without comments*/
    public static void alertonApproval(List<Case> newCaseList,Map<Id, Case> recordOldMap,Map<Id, Case> recordNewMap){
      Id salesCancelRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sales_Cancellation').getRecordTypeId();
      //Added by Ashok to solve : https://emakinatr.atlassian.net/browse/NAK-1483
      Id JointOwnerSR_RecTypeID = getSchemaInstance().getRecordTypeInfosByName().get('Add / Remove Joint Owner').getRecordTypeId();
        Set<ID> caseIDS = new Set<ID>();
        for(Case cs : newCaseList){
            system.debug('recordNewMap.get(cs.ID).Approval_Status__c is '+ recordNewMap.get(cs.ID).Approval_Status__c); 
            List<String> approvalStatuses = new List<String>{'Rejected', 'Approved','First Level Approved'};
            String newApprovalStatus =   (recordNewMap.get(cs.ID)).Approval_Status__c ; 
            if(approvalStatuses.contains(newApprovalStatus) && (cs.RecordTypeID==salesCancelRecTypeID || cs.RecordTypeID == JointOwnerSR_RecTypeID) && 
              recordOldMap.get(cs.ID).Approval_Status__c!= recordNewMap.get(cs.ID).Approval_Status__c ){
              caseIDS.add(cs.ID);    
            }
          }
        
        system.debug('caseIDS are '+ caseIDS);
        if(!caseIDS.isEmpty()){
            throwErrorIfCommentsEmpty(caseIDS, newCaseList );
        }

         }

    
        /*Added BY Mamta- Throw error if approved/rejected without comments for Sales cancellation SR*/
        public static void throwErrorIfCommentsEmpty(Set<ID> caseIDS, List<Case> newCaseList){
            List<ProcessInstanceStep> pInsSteps = [select id, comments , StepStatus ,ProcessInstance.TargetObjectID from ProcessInstanceStep 
                                                   WHERE ProcessInstance.TargetObjectID IN : caseIDS ORDER By CreatedDate ASC] ;
            system.debug('pInsSteps are '+ pInsSteps);
            
            
            Map<Id, ProcessInstanceStep> caseID_PInstanceStepMap = new Map<ID ,ProcessInstanceStep>();
            for(ProcessInstanceStep step : pInsSteps){
                caseID_PInstanceStepMap.put(step.ProcessInstance.TargetObjectID ,step );
                
            }
            
            for(Case cs : newCaseList){
                ProcessInstanceStep step = caseID_PInstanceStepMap.get(cs.Id);
                system.debug('step is '+ step);
                if(step!=null){ 
                    system.debug('step.Comments are '+ step.Comments); 
                    if(step.StepStatus=='Rejected' && step.Comments==null){ 
                        cs.addError('Please add rejection reason in comments before rejecting it');
                    } 
                    else if((step.StepStatus=='Approved' /*|| step.StepStatus=='Started'*/)&& step.Comments==null) { 
                        cs.addError('Please add approval reason in comments  before approving it');
                    } 
                }  
            }
   
        
    }
    
    /*added by Gaurav to add subject to case of type Handover - End of Lease*/
    public static void addSubjectToHandoverEndOfLeaseCase(List<Case> newList, Map<Id, Case> recordNewMap){
        Set<Id> handoverIdSet = new Set<Id>();
        Map<Id, Id> handoverToCaseIdMap = new Map<Id, Id>();
        Map<Id, Set<Id>> caseToUnitListMap = new Map<Id, Set<Id>>();
        List<Case_Unit__c> caseUnitList = new List<Case_Unit__c>();
        for(Case cs: newList){
            System.debug('caseId >>>'+cs);
            System.debug('case Handover >>>'+cs.Handover__c);
            System.debug('case Type >>>'+cs.Type);
            if(cs.Handover__c != null && (cs.Type == 'Handover - End of Lease'|| cs.Type=='Handover - Auto Refurbishment')){
                handoverIdSet.add(cs.Handover__c);
                if(!handoverToCaseIdMap.containsKey(cs.Id)){
                    handoverToCaseIdMap.put(cs.Handover__c, cs.Id);
                }
            }
        }
        System.debug('handoverToCaseIdMap >>>'+handoverToCaseIdMap);
        Set<Id> dealIdSet = new Set<Id>();
        Map<Id, Id> dealToHandoverIdMap = new Map<Id, Id>();
        if(handoverIdSet.size() > 0){
        for(Handover__c handover: [SELECT Id, Deal__c FROM Handover__c WHERE Id IN: handoverIdSet]){
            if(handover.Deal__c!=null){
                dealIdSet.add(handover.Deal__c);
                if(!dealToHandoverIdMap.containsKey(handover.Id)){
                    dealToHandoverIdMap.put(handover.Deal__c, handover.Id);
                }
            }
        }
        System.debug('dealToHandoverIdMap >>>'+dealToHandoverIdMap);
        Map<Id, String> caseToUnitNameMap = new Map<Id, String>();
        Set<Id> unitIdSet = new Set<Id>();
        List<Unit_Plan__c> unitPlanList = [SELECT Id, Opportunity__c, Unit__c, Name FROM Unit_Plan__c WHERE Opportunity__c IN: dealIdSet];
        for(Unit_Plan__c unitPlan: unitPlanList){
            unitIdSet.add(unitPlan.Unit__c);
        }
        for(Unit_Plan__c unitPlan: unitPlanList){
            Id caseId = handoverToCaseIdMap.get(dealToHandoverIdMap.get(unitPlan.Opportunity__c));
            System.debug('@@@'+caseId);
            
            if(dealToHandoverIdMap.containsKey(unitPlan.Opportunity__c)){
                
                if(!caseToUnitNameMap.containsKey(caseId)){
                    String unitName = unitPlan.Name;
                    caseToUnitNameMap.put(caseId, unitName);
                }else{
                    String updateUnitName = caseToUnitNameMap.get(caseId);
                    updateUnitName += ', '+unitPlan.Name;
                    caseToUnitNameMap.put(caseId, updateUnitName);
                }
            }
        }
        for(Case cs: newList){
            if(caseToUnitNameMap.containsKey(cs.Id)){
                if(cs.Type=='Handover - End of Lease'){
                    cs.Subject = 'Initiate End of Lease inspection for Unit(s): '+caseToUnitNameMap.get(cs.Id);                    
                }else if(cs.Type == 'Handover - Auto Refurbishment'){
                    cs.Subject = 'Initiate Auto Refurbishment for Unit(s): ' + caseToUnitNameMap.get(cs.Id);
                }
                cs.Origin = 'Salesforce';
            }
        }
    }
        
    }
    
    public static void addCaseUnits(List<Case> newList, Map<Id, Case> recordOldMap){
        Set<Id> handoverIdSet = new Set<Id>();
        Map<Id, Id> handoverToCaseIdMap = new Map<Id, Id>();
        Map<Id, Set<Id>> caseToUnitListMap = new Map<Id, Set<Id>>();
        List<Case_Unit__c> caseUnitList = new List<Case_Unit__c>();
        for(Case cs: newList){
            System.debug('caseId >>>'+cs);
            System.debug('case Handover >>>'+cs.Handover__c);
            System.debug('case Type >>>'+cs.Type);
            if(cs.Handover__c != null && (cs.Type == 'Handover - End of Lease'|| cs.Type=='Handover - Auto Refurbishment')){
                handoverIdSet.add(cs.Handover__c);
                if(!handoverToCaseIdMap.containsKey(cs.Id)){
                    handoverToCaseIdMap.put(cs.Handover__c, cs.Id);
                }
            }
        }
        System.debug('handoverToCaseIdMap >>>'+handoverToCaseIdMap);
        Set<Id> dealIdSet = new Set<Id>();
        Map<Id, Id> dealToHandoverIdMap = new Map<Id, Id>();
        for(Handover__c handover: [SELECT Id, Deal__c FROM Handover__c WHERE Id IN: handoverIdSet]){
            if(handover.Deal__c!=null){
                dealIdSet.add(handover.Deal__c);
                if(!dealToHandoverIdMap.containsKey(handover.Id)){
                    dealToHandoverIdMap.put(handover.Deal__c, handover.Id);
                }
            }
        }
        System.debug('dealToHandoverIdMap >>>'+dealToHandoverIdMap);
        Map<Id, String> caseToUnitNameMap = new Map<Id, String>();
        List<Unit_Plan__c> unitPlanList = [SELECT Id, Opportunity__c, Unit__c, Name FROM Unit_Plan__c WHERE Opportunity__c IN: dealIdSet];
        for(Unit_Plan__c unitPlan: unitPlanList){
            Id caseId = handoverToCaseIdMap.get(dealToHandoverIdMap.get(unitPlan.Opportunity__c));
            System.debug('@@@'+caseId);
            if(caseId!=null){
                Case_Unit__c caseUnit = new Case_Unit__c();
                caseUnit.Case__c = caseId;
                caseUnit.Unit__c = unitPlan.Unit__c;
                caseUnitList.add(caseUnit);
            }
        }
        
        if(caseUnitList.size()>0){
            insert caseUnitList;
        }
    }
    
    /*added by Gaurav to close the case if Tenant Agreement document is uploaded to the case of record type - Handover
    Modified by : Karishma to accomodate the change. Case to be closed only for type Handover - End of Lease
    and if Total Damages > 0
    */
    public static void checkIfHandoverCaseTenantAgreementUpdloaded(List<Case> newList, Map<Id, Case>recordOldMap){
        List<Case> closeCaseList = new List<Case>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Handover').getRecordTypeId();
        for(Case cs: newList){
            if((cs.RecordTypeID == recordTypeId) && cs.Type == 'Handover - End of Lease'){
                if((cs.Tenant_Agreement_Uploaded__c == true && recordOldMap.get(cs.Id).Tenant_Agreement_Uploaded__c == false && cs.Total_Damages__c > 0)
                    || (cs.Total_Damages__c > 0 && recordOldMap.get(cs.Id).Total_Damages__c != cs.Total_Damages__c && cs.Tenant_Agreement_Uploaded__c == true)){
                    cs.Status = 'Closed';
                }
            }
            
        }
        
    }
    
    /*added by Gaurav to mark the Handover related to Case as 'Completed' as soon as the case is closed'*/
    public static void handoverUpdateForClosedHandoverCases(List<Case> newList, Map<Id, Case> recordOldMap){
        Set<Id> handoverIdSet = new Set<Id>();
        for(Case cs: newList){
            if(cs.Status=='Closed' && recordOldMap.get(cs.Id).Status!=cs.Status){
                if(cs.Handover__c!=null){
                    handoverIdSet.add(cs.Handover__c);
                }
            }
        }
        if(handoverIdSet.size()>0){
            List<Handover__c> handoverList = [SELECT Id FROM Handover__c WHERE Id IN: handoverIdSet];
            List<Handover__c> handoverUpdateList = new List<Handover__c>();
            for(Handover__c handover: handoverList){
                handover.Status__c = 'Completed';
                handoverUpdateList.add(handover);
            }
            if(handoverUpdateList.size()>0){
                update handoverUpdateList;
            }
        }
    }
   
    /*added by Gaurav to update the Unit status to Available as soon as the case is marked Completed*/
    public static void updateRelatedUnitStatusAfterCompleted(List<Case> newList, Map<Id, Case> recordOldMap, Map<Id, Case> recordNewMap){
        System.debug('Helllllo');
        List<Case> caseToUpdateUnitStatusList = new List<Case>();
        Set<Id> caseIdSet = new Set<Id>();
        for(Case cs: newList){
            System.debug(cs);
            if(cs.Type=='Handover - Auto Refurbishment' && cs.Status == 'Closed'){
                System.debug(cs.Status + '<<<' + recordOldMap.get(cs.Id).Status);
                caseIdSet.add(cs.Id);
            }
        }
        System.debug('caseIdSet >>>'+caseIdSet);
        if(caseIdSet.size() > 0){
            List<Case_Unit__c> caseUnitList = [SELECT Id, Unit__c, Case__c FROM Case_Unit__c WHERE Case__c IN: caseIdSet];
            List<Unit__c> unitList = new List<Unit__c>();
            for(Case_Unit__c caseUnit: caseUnitList){
                Unit__c unit = new Unit__c();
                unit.Id = caseUnit.Unit__c;
                unit.Unit_Status__c = 'Vacant';
                unitList.add(unit);
            }
            System.debug('unitList >>>'+unitList);
            if(unitList.size()>0){
                update unitList;
            }
        }
        
    }

    /*added by Karishma Kotian to add case units for handover move in and Termination*/
    public static void addCaseUnitsAndSubjectToHandoverMoveInCase(List<Case> newCaseList, Map<Id,Case> recordOldMap){
        set<Id> caseIds = new set<Id>();
        set<Id> opptyIds = new set<Id>();
        Map<Id,Id> mapCasetoOppty = new Map<Id,Id>();
        Map<Id,List<Unit_Plan__c>> mapOpptyUnitsToOppty = new Map<Id,List<Unit_Plan__c>>();
        List<Case_Unit__c> caseUnitList = new List<Case_Unit__c>();
        Map<Id, String> caseToUnitNameMap = new Map<Id, String>();
        Map<Id,Date> caseToLeaseStartDate = new Map<Id,Date>();
        List<Case> caseList = new List<Case>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Handover').getRecordTypeId();
        try {
            for(Case cse : newCaseList){
                if((cse.RecordTypeID == recordTypeId) && cse.Type == 'Handover - Move In'){
                    if(cse.Deal__c != null){
                        opptyIds.add(cse.Deal__c);
                        mapCasetoOppty.put(cse.ID,cse.Deal__c);
                    }
                }
            }

            if(opptyIds.size() > 0){
            List<Unit_Plan__c> opptyUnits = [SELECT ID, Name, Unit__c, Opportunity__c,Contract__r.Contract_Start_Date__c, 
                                            Unit__r.Unit_Code__c,Opportunity__r.Lease_Start_Date__c,
                                            Opportunity__r.Lease_End_Date__c,Renewal_new_unit__c
                                            FROM Unit_Plan__c WHERE Opportunity__c =: opptyIds];
            for(Unit_Plan__c opptyUnit : opptyUnits){
                if(opptyUnit.Renewal_new_unit__c ==true){
                   if(mapOpptyUnitsToOppty.containsKey(opptyUnit.Opportunity__c)){
                    mapOpptyUnitsToOppty.get(opptyUnit.Opportunity__c).add(opptyUnit);
                }else{
                    mapOpptyUnitsToOppty.put(opptyUnit.Opportunity__c, new List<Unit_Plan__c>{opptyUnit});
                } 
                }
                
            }

            for(Id caseId : mapCasetoOppty.keySet()){
                if(mapOpptyUnitsToOppty.containsKey(mapCasetoOppty.get(caseId))){
                    for(Unit_Plan__c opptyUnit : mapOpptyUnitsToOppty.get(mapCasetoOppty.get(caseId))){
                        Case_Unit__c caseUnit = new Case_Unit__c();
                        caseUnit.Case__c = caseId;
                        caseUnit.Unit__c = opptyUnit.Unit__c;
                        caseUnit.Type__c = 'Existing';
                        caseUnitList.add(caseUnit);

                        //added to capture unit name and lease start date for the subject line
                        if(!caseToUnitNameMap.containsKey(caseId)){
                            String unitName = opptyUnit.Unit__r.Unit_Code__c + '-' +CommonUtility.formatDate(opptyUnit.Opportunity__r.Lease_Start_Date__c);
                            caseToUnitNameMap.put(caseId, unitName);
                        }else{
                            String updateUnitName = caseToUnitNameMap.get(caseId);
                            updateUnitName += ', '+opptyUnit.Unit__r.Unit_Code__c + '-' +CommonUtility.formatDate(opptyUnit.Opportunity__r.Lease_Start_Date__c);
                            caseToUnitNameMap.put(caseId, updateUnitName);
                        }

                        //added by Karishma 30th March 2022 as per handover feedback to add lease start date on move-in SR
                        caseToLeaseStartDate.put(caseId,opptyUnit.Opportunity__r.Lease_Start_Date__c);
                    }
                    system.debug('@@caseUnitList :'+caseUnitList);
                    system.debug('@@caseToUnitNameMap :'+caseToUnitNameMap);
                    if(caseToUnitNameMap.containsKey(caseId)){
                        Case cse = new Case();
                        cse.Id = caseId;
                        cse.Subject = 'Move in request for Unit(s) '+caseToUnitNameMap.get(caseId);
                        cse.Lease_Start_Date__c = caseToLeaseStartDate.get(caseId);
                        caseList.add(cse);
                    }
                    
                }
            }
        }
            if(!caseUnitList.isEmpty()){
                insert caseUnitList;
            }

            if(!caseList.isEmpty()){
                update caseList;
            }
        } catch (Exception ex) {
            system.debug('Message :'+ ex.getMessage()+ 'Line Number :'+ex.getLineNumber() + 'Stack trace :'+ex.getStackTraceString());
        }

    }

    /*added by Karishma Kotian to mark handover as SR Closed on case closure for handover move in*/
    public static void serviceRequestClosureAutomations(List<Case> newCaseList, Map<Id,Case> recordOldMap){
        Set<Id> handoverIds = new Set<Id>();
        Set<Id> dealIds = new Set<Id>();
        Set<Id> caseIds =  new Set<Id>();
        Set<Id> unitIds = new Set<Id>();
        List<Unit__c> unitList = new List<Unit__c>();
        List<Handover__c> handoverList = new List<Handover__c>();
        List<Unit_Plan__c> unitPlanList = new List<Unit_Plan__c>();
        Id handoverRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Handover').getRecordTypeId();
        Id terminationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Termination').getRecordTypeId();
        try {
            for(Case cse : newCaseList){
                if((cse.RecordTypeID == handoverRecordTypeId) && cse.Type == 'Handover - Move In'){
                    if(cse.IsClosed && cse.Handover__c != null && cse.IsClosed != recordOldMap.get(cse.Id).IsClosed){
                        handoverIds.add(cse.Handover__c);
                    }
                }else if((cse.RecordTypeID == terminationRecordTypeId) && cse.Type == 'Termination'){
                    if(cse.IsClosed && cse.Deal__c != null && cse.IsClosed != recordOldMap.get(cse.Id).IsClosed){
                        dealIds.add(cse.Deal__c);
                        caseIds.add(cse.Id);
                    }
                }
            }

            if(handoverIds.Size() > 0){
                for(Id handoverId : handoverIds){
                    Handover__c hd =  new Handover__c();
                    hd.Is_SR_Closed__c = true;
                    hd.Id = handoverId;
                    hd.Status__c = 'In Progress';
                    handoverList.add(hd);
                }
                if(!handoverList.isEmpty()){
                    update handoverList;
                }
            }

            if(dealIds.size() > 0){
                List<Lease_Contract__c> leaseContracts = [SELECT Id,Contract_Stages__c,Opportunity__c FROM Lease_Contract__c 
                                                            WHERE Opportunity__c =: dealIds];
                for(Lease_Contract__c contract : leaseContracts){
                    contract.Contract_Stages__c = 'Terminated';
                }
                update leaseContracts;
            }

            if(caseIds.size() > 0){
                List<Case_Unit__c> caseUnits = [SELECT Id, Unit__c, Case__c FROM Case_Unit__c WHERE Case__c =: caseIds];
                for(Case_Unit__c caseUnit : caseUnits){
                    unitIds.add(caseUnit.Unit__c);
                    Unit__c unit = new Unit__c();
                    unit.Id = caseUnit.Unit__c;
                    unit.Unit_Status__c = 'Refurbishment';
                    unitList.add(unit);
                }
                if(!unitList.isEmpty()){
                    update unitList;
                }
            }

            if(unitIds.size() > 0 && dealIds.size() > 0){
                List<Unit_Plan__c> opptyUnits = [SELECT Id, Opportunity__c, Is_Terminated__c, Unit__c FROM Unit_Plan__c WHERE Opportunity__c =:dealIds 
                                                    AND Unit__c =: unitIds];
                for(Unit_Plan__c unitPlan : opptyUnits){
                    unitPlan.Is_Terminated__c = true;
                    unitPlanList.add(unitPlan);
                }
                if(!unitPlanList.isEmpty()){
                    update unitPlanList;
                }
            }
            
        }catch(Exception ex){
            system.debug('Message :'+ ex.getMessage()+ 'Line Number :'+ex.getLineNumber() + 'Stack trace :'+ex.getStackTraceString());
        }
    }


    /*added by Karishma Kotian to update contact lookup on case*/
    public static void updateContactDetails(List<Case> newCaseList){
        
        Map<Id,List<Case>> casesToAccount = new Map<Id,List<Case>>();
        List<Case> caseList = new List<Case>();
        try{
            if(RecursionController.isFirstTime) {
                RecursionController.isFirstTime = false;
            for(Case cse : newCaseList){
                if(cse.AccountId != null){
                    if(casesToAccount.containsKey(cse.AccountId)){
                        casesToAccount.get(cse.AccountId).add(cse);
                    }else{
                        casesToAccount.put(cse.AccountId,new List<Case>{cse});
                    }
                }
            }
            if(!casesToAccount.isEmpty()){
            List<Account> accountList = [SELECT Id, PersonContactId, Primary_Email__c,Primary_Mobile__c,Primary_Country_Code__c,
                                            (SELECT Id FROM Contacts WHERE Is_Primary__c = true) 
                                              FROM Account WHERE Id=: casesToAccount.keySet()];
            for(Account account : accountList){
                if(casesToAccount.containsKey(account.Id)){
                    for(Case sr : casesToAccount.get(account.Id)){
                        if(account.PersonContactId != null){
                            case temp = new case(Id = sr.Id, ContactId = account.PersonContactId, Customer_Email__c = account.Primary_Email__c, Customer_Mobile__c=account.Primary_Mobile__c,Customer_Country_Code__c=account.Primary_Country_Code__c);
                            caseList.add(temp);
                        }else{
                            if(account.Contacts.size() >  0){
                                case temp = new case(Id = sr.Id, ContactId = account.Contacts[0].Id, Customer_Email__c = account.Primary_Email__c,Customer_Mobile__c=account.Primary_Mobile__c,Customer_Country_Code__c=account.Primary_Country_Code__c);
                                caseList.add(temp);
                            }else{
                                case temp = new case(Id = sr.Id, Customer_Email__c = account.Primary_Email__c, Customer_Mobile__c=account.Primary_Mobile__c,Customer_Country_Code__c=account.Primary_Country_Code__c);
                                caseList.add(temp);
                            }
                        }
                    }
                }
            }
            }
            if(!caseList.isEmpty()){
                update caseList;
                }
            }
        }catch(Exception ex){
            system.debug('Message :'+ ex.getMessage()+ 'Line Number :'+ex.getLineNumber() + 'Stack trace :'+ex.getStackTraceString());
        }
    }

    /* Added by karishma to deactivate the cards on termination*/
    public void deactivateAccessCard(List<Case> newCaseList, Map<Id,Case> recordOldMap){
        Set<Id> unitIds = new Set<Id>(); 
        Set<Id> caseIds = new Set<Id>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Termination').getRecordTypeId();
        try{
            for(Case cse : newCaseList){
                if(cse.RecordTypeID == recordTypeId && cse.Access_Card__c == true && recordOldMap.get(cse.Id).Access_Card__c != cse.Access_Card__c){
                    caseIds.add(cse.Id);
                }
            }
            List<Case_Unit__c> caseUnits = [SELECT Id, Unit__c, Case__c FROM Case_Unit__c WHERE Case__c =: caseIds];
            for(Case_Unit__c cUnit: caseUnits){
                if(cUnit.Unit__c != null)
                unitIds.add(cUnit.Unit__c);
            }
            List<Card__c> cards = [SELECT Id, Status__c from Card__c WHERE Unit__c =: unitIds];
            if(cards.size()>0){
                for(Card__c card :cards ){
                    card.Status__c = 'InActive';
                }
                update cards;
            }
            

        }catch(Exception ex){
            system.debug('Message :'+ ex.getMessage()+ 'Line Number :'+ex.getLineNumber() + 'Stack trace :'+ex.getStackTraceString());
        }
    }

    //Added by Karishma for transfering the Move-out form for termination from files to Document Record
    public static void moveOutFormToDocument(List<Case> newCaseList,Map<Id, Case> recordOldMap,Map<Id, Case> recordNewMap){
        Set<ID> verifiedIds = new Set<ID>();
        String documentType = system.label.Move_Out_Form_Application;
        for(Case cs : recordNewMap.values()){
            if(recordNewMap.get(cs.ID).Flag_Move_out_form_generated__c && !recordOldMap.get(cs.ID).Flag_Move_out_form_generated__c ){
                verifiedIds.add(cs.ID);
            }
        }
        attachFilesToDocument(verifiedIds,documentType,null);
    }

    //Added by Karishma for transfering the End of Lease form for termination from files to Document Record
    public static void endOfLeaseFormToDocument(List<Case> newCaseList,Map<Id, Case> recordOldMap,Map<Id, Case> recordNewMap){
        Set<ID> verifiedIds = new Set<ID>();
        String documentType = system.label.End_of_Lease_Application;
        for(Case cs : recordNewMap.values()){
            if(recordNewMap.get(cs.ID).Flag_End_Of_Lease_Form_generated__c && !recordOldMap.get(cs.ID).Flag_End_Of_Lease_Form_generated__c ){
                verifiedIds.add(cs.ID);
            }
        }
        attachFilesToDocument(verifiedIds,documentType,null);
    }

    public static void attachFilesToDocument(Set<Id> verifiedIds, String documentType, Map<Id,Id> agreementIdsMappedToCase){
        Set<ID> captureContDocId = new Set<ID>();
        if(verifiedIds.Size() > 0){
            Map<ID,ID> contentDocumentLinkMap = new Map<ID,ID>();
            List<ContentDocumentLink> allIds = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in :verifiedIds];
            
            for(ContentDocumentLink cl : allIds){
                contentDocumentLinkMap.put(cl.LinkedEntityId, cl.ContentDocumentId);
            }
            
            for(ContentDocumentLink c : allIds){
                System.debug('Phase 3 ContentDocumentLink '+c);
                captureContDocId.add(c.ContentDocumentId);
                
            }
            Map<ID,ContentVersion> contentVersionMap = new Map<ID,ContentVersion>();
            List<ContentVersion> contentVersionList = [Select Id,ContentDocumentId, ContentUrl,VersionData,Title,PathOnClient from ContentVersion where ContentDocumentId in :captureContDocId ];
            for(ContentVersion cv : contentVersionList){
                System.debug('Phase 4 ContentVersion '+cv);
                contentVersionMap.put(cv.ContentDocumentId, cv);
            }
            List<Id> docList = new List<Id>();
            Map<ID,ID> obDocMap = new Map<ID,ID>();  
            List<Object_Document__c> objDocument = [Select id, Case__c, Document__c from Object_Document__c where Case__c in :verifiedIds];
            for(Object_Document__c obj : objDocument){
                obDocMap.put(obj.Document__c,obj.Case__c);
                docList.add(obj.Document__c);
            }
            
            
            List<Document__c> documents = [Select id, Case__c, Document_Type__c from Document__c where id in :docList];

            List<Document__c> updateDocumentOperation = new List<Document__c>();
            List<ContentVersion> insertContentVersion = new List<ContentVersion>();
            List<ContentDocumentLink> insertContentDocumentLink = new List<ContentDocumentLink>();
            
            for(Document__c doc : documents){
                if(doc.Document_Type__c == documentType){
                    doc.Case__c = obDocMap.get(doc.id);
                    updateDocumentOperation.add(doc);
                    
                    System.debug('Phase 6 Document and Opportunity ===>'+doc);
                    Id contentDocumentId = contentDocumentLinkMap.get(doc.Case__c);
                    
                    ContentVersion contentVersionOpportunity = contentVersionMap.get(contentDocumentId);
                     
                    ContentVersion contentVersionDocument = new ContentVersion();
                    contentVersionDocument.ContentDocumentId = contentDocumentId;
                    contentVersionDocument.Title = contentVersionOpportunity.Title;
                    contentVersionDocument.PathOnClient = contentVersionOpportunity.PathOnClient;
                    contentVersionDocument.VersionData = contentVersionOpportunity.VersionData;
                    insertContentVersion.add(contentVersionDocument);
                    
                    
                    ContentDocumentLink cdLinkDocument = new ContentDocumentLink();
                    cdLinkDocument.LinkedEntityId = doc.Id;
                    cdLinkDocument.ContentDocumentId = contentDocumentId;
                    insertContentDocumentLink.add(cdLinkDocument);

                    if(agreementIdsMappedToCase != null){
                        ContentVersion contentVersion_Agreement = contentVersionMap.get(contentDocumentId);

                        ContentVersion contentVersionDocument1 = new ContentVersion();
                        contentVersionDocument1.ContentDocumentId = contentDocumentId;
                        contentVersionDocument1.Title = contentVersion_Agreement.Title;
                        contentVersionDocument1.PathOnClient = contentVersion_Agreement.PathOnClient;
                        contentVersionDocument1.VersionData = contentVersion_Agreement.VersionData;
                        insertContentVersion.add(contentVersionDocument1);
                    
                        ContentDocumentLink cdLinkDocument1 = new ContentDocumentLink();
                        cdLinkDocument1.LinkedEntityId = agreementIdsMappedToCase.get(doc.Case__c);
                        cdLinkDocument1.ContentDocumentId = contentDocumentId;
                        insertContentDocumentLink.add(cdLinkDocument1);
                    }
                }
            }  
            
            try{
                update updateDocumentOperation;
                insert insertContentVersion;
                insert insertContentDocumentLink;
            }
            catch (Exception ex){
                system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
            }
        }
    }

    //By Karishma Kotian to send email to customer on stage change
    public static void sendEmailOnDocumentVerificationStage(List<Case> newCaseList,Map<Id, Case> recordOldMap,Map<Id, Case> recordNewMap){
        Set<ID> caseIds = new Set<ID>();
        Map<Id,List<Document__c>> mapDocToCase = new Map<Id,List<Document__c>>();
        Set<Id> docIds = new Set<Id>();
        set<Id> contentDocumentIds = new Set<Id>();
        Map<Id,Id> docIdMapContentDocumentId = new Map<Id,Id>();
        Map<Id,ContentVersion> contentVersionToContentDoc = new Map<Id,ContentVersion>();
        Map<Id,List<ContentVersion>> contentVersionsToCase = new Map<Id,List<ContentVersion>>();
        Map<Id,Case> CaseDetails = new Map<Id,Case>();
        for(Case cse : newCaseList){
            if(cse.Status == 'Documents Verification' && recordOldMap.get(cse.Id).Status != cse.Status){
                caseIds.add(cse.Id);
                CaseDetails.put(cse.Id,cse);
            }
            List<Document__c> docList = [SELECT Id,Case__c FROM Document__c WHERE Case__c =: caseIds
                                         AND Document_Type__c IN ('Move Out Form Application','End of Lease Application')];
            for(Document__c doc : docList){
                docIds.add(doc.Id);
                if(mapDocToCase.containsKey(cse.Id)){
                    mapDocToCase.get(cse.Id).add(doc);
                }else{
                    mapDocToCase.put(cse.Id,new List<Document__c>{doc});
                }
            }
            if(docIds.size() > 0){
            List<ContentDocumentLink> files = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: (docIds)];
            for(ContentDocumentLink cdLink : files){
                contentDocumentIds.add(cdLink.ContentDocumentId);
                docIdMapContentDocumentId.put(cdLink.LinkedEntityId,cdLink.ContentDocumentId);
            }
            List<ContentVersion> cvList = [SELECT VersionData, FileExtension, ContentDocumentId, Title FROM ContentVersion 
                                            WHERE ContentDocumentId = :contentDocumentIds AND IsLatest = true];
            for(ContentVersion cv : cvList){
                contentVersionToContentDoc.put(cv.ContentDocumentId,cv);
            }
            
            for(Id caseId : mapDocToCase.keySet()){
                for(Document__c doc : mapDocToCase.get(caseId)){
                    if(docIdMapContentDocumentId.containsKey(doc.Id)){
                        if(contentVersionToContentDoc.containsKey(docIdMapContentDocumentId.get(doc.Id))){
                            if(contentVersionsToCase.containsKey(caseId)){
                                contentVersionsToCase.get(caseId).add(contentVersionToContentDoc.get(docIdMapContentDocumentId.get(doc.Id)));
                            }else{
                                contentVersionsToCase.put(caseId,new List<ContentVersion>{contentVersionToContentDoc.get(docIdMapContentDocumentId.get(doc.Id))});
                            }
                        }
                    }
                }
            }
            sendEmailToCustomer(contentVersionsToCase,CaseDetails);
            }
        }
    }
    public static void sendEmailToCustomer(Map<Id,List<ContentVersion>> contentVersionsToCase, Map<Id,Case> caseDetails){
        // initialize temporary email list
        String caseEmail = '';
        String conId = '';
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        
        EmailTemplate emailTemplate = [ SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                       FROM EmailTemplate 
                                       WHERE name = : ConstantUtility.LEASING_TERMINATION_TEMPLATE];
        
        Contact con = [SELECT ID FROM Contact WHERE Email != null LIMIT 1 ];
        
        for(Id caseId : contentVersionsToCase.keySet()){
            if(caseDetails.containsKey(caseId)){
                 caseEmail = caseDetails.get(caseId).Customer_Email__c;
                 //conId = //caseDetails.get(caseId).ContactId != null ? caseDetails.get(caseId).ContactId : [SELECT ID FROM Contact LIMIT 1 ].Id;
            }
            system.debug('@@conID :'+conId);
            List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
            // initialize one or more single emails as you need 
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            for(ContentVersion cv : contentVersionsToCase.get(caseId)){
                Blob fileData  = cv.VersionData;  
                Messaging.EmailFileAttachment efa = new Messaging.EmailfileAttachment();
                efa.setFileName(cv.Title);
                efa.setBody(fileData);
                efaList.add(efa);
            }
            // set the recipient email
            message.setToAddresses(new String[] {caseEmail });
            // set the email template id
            message.setTemplateId(emailTemplate.Id);
            // do not save email as activity
            message.setSaveAsActivity(false);
            // set the id for the object
            message.setWhatId(caseId);
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

     /******************************************************************************************************
    * @Description        : Method to Send Financial transaction details to ERP
    * @Return             : void   
    * @Author             : Vishal
    *******************************************************************************************************/ 
    public void sendFinancialDetailERP(List<Case> newList,Map<ID,Case> oldMap){
        Set<Id> caseIds = new Set<Id>();
        for(Case cs : newList) {
            System.debug('@@@1111111111111');
            if(cs.Send_Financials_to_ERP__c && oldMap.get(cs.Id).Send_Financials_to_ERP__c == false) {
                caseIds.add(cs.Id);
            }
        }
        
        if(!caseIds.isEmpty()) {
            List<Receipt__c> receiptsToUpdate = new List<Receipt__c>();
            List<Receipt_Refund__c> receiptRefundToUpdate = new List<Receipt_Refund__c>();
            List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();
            List<Credit_Memo__c> creditMemoToUpdate = new List<Credit_Memo__c>();
            
            for(Service_Request_Receipt__c servReqRec : [Select Id,Receipt_Action_Type__c,Receipt__c,Forfeit_Amount__c,Refund_Amount__c,
                                                         (Select Id FROM Invoices__r)
                                                         ,(Select Id FROM Receipt_Refund__r),(Select Id FROM Credit_Memos__r)
                                                         FROM Service_Request_Receipt__c Where Service_Request__c In :caseIds]) {
                if(servReqRec.Receipt_Action_Type__c == 'Reversal' && servReqRec.Receipt__c != null) {
                    Receipt__c rec = new Receipt__c(Id=servReqRec.Receipt__c);
                    rec.Send_Receipt_Reversal_ERP__c = true;
                    receiptsToUpdate.add(rec);
                } else if(/*(servReqRec.Receipt_Action_Type__c == 'Full Forfeit' || servReqRec.Receipt_Action_Type__c == 'Partial Forfeit')*/ servReqRec.Forfeit_Amount__c != null && servReqRec.Invoices__r != null) {
                    for(Invoice__c inv : servReqRec.Invoices__r) {
                        inv.Send_Invoice_to_ERP__c = true;
                        invoicesToUpdate.add(inv);
                    }
                }
                if(/*(servReqRec.Receipt_Action_Type__c == 'Full Refund' || servReqRec.Receipt_Action_Type__c == 'Partial Refund')*/servReqRec.Refund_Amount__c != null && servReqRec.Receipt_Refund__r != null) {
                    for(Receipt_Refund__c recRefund : servReqRec.Receipt_Refund__r) {
                        recRefund.Send_Refund_to_ERP__c = true;
                        receiptRefundToUpdate.add(recRefund);
                    }
                } else if(servReqRec.Refund_Amount__c == null && servReqRec.Credit_Memos__r != null) {
                    for(Credit_Memo__c credComp : servReqRec.Credit_Memos__r) {
                        credComp.Send_Credit_Memo_to_ERP__c = true;
                        creditMemoToUpdate.add(credComp);
                    }
                }
            }
            
            try{
                if(!receiptsToUpdate.isEmpty()) {
                    update receiptsToUpdate;
                }
                if(!receiptRefundToUpdate.isEmpty()) {
                    update receiptRefundToUpdate;
                }
                
                if(!invoicesToUpdate.isEmpty()) {
                    update invoicesToUpdate;
                }
                if(!creditMemoToUpdate.isEmpty()) {
                    update creditMemoToUpdate;
                }
            }catch(Exception ex){
                system.debug('Message :'+ ex.getMessage()+ 'Line Number :'+ex.getLineNumber() + 'Stack trace :'+ex.getStackTraceString());
            }
        }
    }
    
    /******************************************************************************************************
    * @Description        : Method to throw error if leasing manager approves termination SR without Refund
                            Check
    * @Return             : void   
    * @Author             : Karishma
    *******************************************************************************************************/ 
    public void displayErrorOnLeasingManagerApproval(List<Case> newList,Map<ID,Case> oldMap){
        Id terminationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Termination').getRecordTypeId();
        for(Case cse : newList){
            if(cse.Approval_Status__c == 'First Level Approved' && cse.Approval_Status__c != oldMap.get(cse.Id).Approval_Status__c && cse.RecordTypeId == terminationRecordType){
                if(cse.Refund_Applicable__c == null || String.isBlank(cse.Refund_Applicable__c)){
                    cse.addError(system.label.Refund_Applicable_Error_Message);
                }
            }
        }
    }
    
    /******************************************************************************************************
    * @Description        : Create Case, Opportunity, Case Unit on Case approval                                                                                      
    * @Return             : void   
    * @Author             : Mamta Gupta
    * @Purpose            : Tag Account, Deal ,Agreement ,Regsitration from Unit to Case
    * @Date               :20 May 2022//Earlier flow was there was for same,but error handling was not possible so moving logic here                                                                      
    *******************************************************************************************************/ 
public static void tagActiveAccntDealAgreementonCase(List<Case> newList){
try{
    List<RecordType> recordTypes=[SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Case'];
    Map<ID,String> recID_DevMap = new Map<ID,String>();
    
    //added mamdta 23 may    
    List<String> recTypesLst = (system.label.SR_RecordType_Names).trim().split(',');
    List<String> recTypesWithSpacesTrimmed = new List<String>();
    for(String s: recTypesLst){
        recTypesWithSpacesTrimmed.add(s.trim());
    }
    
    
    
    
     
    for(RecordType rc : recordTypes){
        recID_DevMap.put(rc.ID, rc.DeveloperName);
    }
   
    Set<Id> unitIDSSet = new Set<ID>();
    for(Case cs :newList ){
        String rectypeDevName = recID_DevMap.get(cs.RecordTypeID);
        system.debug('rectypeDevName is '+ rectypeDevName);
        if(cs.Unit__c!=null && recTypesWithSpacesTrimmed.contains(rectypeDevName)){
            unitIDSSet.add(cs.Unit__c);
        }
    }
    if(!unitIDSSet.isEmpty()){
    Map<Id,Unit__c> unitIDUnitMap = new Map<Id,Unit__c>([select id, Active_Account__c,Active_Deal__c,Active_Agreement__c,
                                                        Active_Account__r.Primary_Email__c,Active_Registration__c from Unit__c WHERE ID IN:unitIDSSet]);
    system.debug('unitIDUnitMap is '+ unitIDUnitMap);
    for(Case cs :newList ){
        Unit__c unit = unitIDUnitMap.get(cs.Unit__c);
        system.debug('unit is '+ unit);
        cs.AccountID = unit.Active_Account__c;
        cs.Deal__c =  unit.Active_Deal__c;
        cs.Registration__c = unit.Active_Registration__c;
        cs.Agreement__c = unit.Active_Agreement__c;
        if(unit.Active_Account__c!=null){
           cs.Customer_Email__c = unit.Active_Account__r.Primary_Email__c;
        }
    }
    }
    }
    catch(Exception e){
        system.debug(e.getMessage());
        //DebugUtility.log(e);
    }
}
       /******************************************************************************************************
* @Description        : Function to close Title Deed Case                                                                                   
* @Return             : void   
* @Author             : Anshita
* @Date               : 23 May 2022
*******************************************************************************************************/
    public void markTitleDeedComplete(List<Case> newList,Map<ID,Case> oldMap){
        Id titleDeedRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Deed').getRecordTypeId();
        Map<Id,String> closeTaskByCase = new Map<Id,String>(); 
        List<Case> caseToClose = new List<Case>();
        try{
            for(Case cs : newList){
                if(cs.RecordTypeID == titleDeedRecTypeId && cs.Title_Deed_doc_sent_to_Customer__c &&
                   cs.Title_Deed_doc_sent_to_Customer__c != oldMap.get(cs.Id).Title_Deed_doc_sent_to_Customer__c){
                       //close task
                       closeTaskByCase.put(cs.Id, NakheelTaskSubject__mdt.getInstance('CaseTitleDeedTask1').Subject__c);
                       Case c = new Case( Id = cs.Id);
                       c.Status = 'Closed';
                       caseToClose.add(c);
                   }
            }
            if(closeTaskByCase.isEmpty() == false){
                List<Task> taskToClose = new List<Task>();
                List<Task> taskList = [Select Id, Subject, Status, WhatId from Task where WhatId IN: closeTaskByCase.keySet()];
                for(Task t: taskList){
                    if(t.Subject == closeTaskByCase.get(t.WhatId)){
                        t.Status = 'Completed';
                        taskToClose.add(t);
                    }
                }
                if(taskToClose.size() > 0){
                    update taskToClose;
                }
            }
            if(caseToClose.size() > 0){
                 update caseToClose;
            }
        }
        catch(Exception e){
            System.debug('Exception on Line Number :'+ e.getLineNumber() + ', Error message :' + e.getMessage());
        }
    }
}