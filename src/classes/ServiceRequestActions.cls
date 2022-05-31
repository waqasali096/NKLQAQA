/**
* @author : Ashams
* @createdDate : 30-Jan-2022
* @lastModifieddate : 30-Jan-2022
* @purpose : Payment Amendment Service Request in Sales Process
* @usage : invoked in Case TriggerHandler
*/
public class ServiceRequestActions {
    
    
    public static void PaymentTermsAmendmentAtions(List<Case> newCaseList){
        List<Case> casewithExistingPPlans = new List<Case>();
        Id paymentAmendmentRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Payment_Terms_Amendment').getRecordTypeId();
        Id paymentDefermentRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Payment_Terms_Deferment').getRecordTypeId();
        for(Case cs: newCaseList){
            if(cs.Deal__c != null && (cs.RecordTypeId == paymentAmendmentRecTypeID || cs.RecordTypeId == paymentDefermentRecTypeID)){
                casewithExistingPPlans.add(cs);
            }
        }
        
        if(casewithExistingPPlans.size() > 0) {
            createExistingPM(casewithExistingPPlans);
        }
    }
    
    
    /* Author Mamta
* CreatedDAte 4 Feb 2022
* Purpose create Joint  Owners for Add /Remove Joint Onwer SR*/
    public static void AddRemoveJointOwnerActions (List<Case> newCases){
        Id JointOwnerRecId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Add_Remove_Joint_Owner').getRecordTypeId();
        Set<ID> oppIDS = new Set<ID>();
        List<Case> jointOwnRecID_CaseLst = new List<Case>();
        for(Case cs :newCases ){
            if(cs.Deal__c!=null && cs.RecordTypeId == JointOwnerRecId){
                oppIDS.add(cs.Deal__c);
                jointOwnRecID_CaseLst.add(cs); 
            }
        }
        if(!oppIDS.isEmpty()){
            createJointOnwers(oppIDS ,jointOwnRecID_CaseLst );
        }
        
    }
    
    /* Author Hitesh Saini
* CreatedDAte 6 Feb 2022
* Purpose Method added for the Premature termination SR*/
    public static void preMatureTerminationActions (List<Case> newCaseList,Map<Id, Case> recordOldMap,Map<Id, Case> recordNewMap){
        Id preMatureTerRecordType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Termination').getRecordTypeId();
        Id masterCaseRecordType=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email-To-Case SR').getRecordTypeId();
        Set<Case> setCasePDCOnHold = new Set<Case>();
        Set<Id> setOpportunity=new Set<Id>();
        Set<Case> setCaseRefundCal=new Set<Case>();
        Map<Id,Case> mapCasePDCOnHold=new Map<Id,Case>();
        Map<Id,Case> mapCaseRefundCal=new Map<Id,Case>();
        Set<Id> caseIds = new Set<Id>();
        Set<Id> caseIdsForRefunds = new Set<Id>();
        system.debug('rtId PMT>>>>'+preMatureTerRecordType);
        For(Case c: newCaseList){
            //condition to check if the record type is changed only once
            /*if(c.Type !=recordOldMap.get(c.Id).Type/* && c.RecordTypeId!=recordOldMap.get(c.Id).RecordTypeId && recordOldMap.get(c.Id).RecordTypeId !=masterCaseRecordType ){
c.addError(ConstantUtility.ERRORMSG_CASE_TYPE_CHANGE_ALLOW_ONCE);
}*/
            
            if(c.RecordTypeId==preMatureTerRecordType){
                if(recordOldMap != null){
                    if(c.Approval_Status__c !=recordOldMap.get(c.Id).Approval_Status__c 
                       && c.Approval_Status__c==ConstantUtility.APPROVAL_STATUS_APPROVED 
                       && recordOldMap.get(c.Id).Approval_Status__c ==ConstantUtility.APPROVAL_STATUS_SUBMITTED ){
                           setCasePDCOnHold.add(c);
                           mapCasePDCOnHold.put(c.id,c);
                       } 
                    if(c.Status!=recordOldMap.get(c.Id).status && c.Status==ConstantUtility.STATUS_IN_DOC_VERF){
                        //setOpportunity.add(c.Deal__c);
                        //setCaseRefundCal.add(c);
                        //mapCaseRefundCal.put(c.id,c);
                        /*List<Payment_Milestone__c> listInstalments=new List<Payment_Milestone__c>();
listInstalments=[select Id, OwnerId,  Name, Installment_No__c, Amount_Percentage__c, Milestone_Trigger_Point__c, Due_In_Days__c, Opportunity__c, 
Master_Payment_Milestone__c, Due_Date__c, Amount__c, Master_Payment_Plan__c, Installment__c, Case__c, Unit__c, Lead__c, Purpose__c, 
Description__c  from Payment_Milestone__c where Opportunity__c ='0063M0000064lgsQAA' order by Due_Date__c desc];*/
                    }
                }
                if((recordOldMap == null || recordOldMap.get(c.Id).Expected_Termination_Date__c != c.Expected_Termination_Date__c || recordOldMap.get(c.Id).Actual_Termination_Date__c != c.Actual_Termination_Date__c || c.RecordTypeId != recordOldMap.get(c.Id).RecordTypeId) && c.RecordTypeId == preMatureTerRecordType && (c.Expected_Termination_Date__c != null || c.Actual_Termination_Date__c != null)){
                    caseIds.add(c.Id);
                }
                
                
                /*if(recordOldMap != null &&( (recordOldMap.get(c.Id).Actual_Termination_Date__c != c.Actual_Termination_Date__c) ||
                                           (recordOldMap.get(c.Id).No_of_Mths_Rent_Deduction__c != c.No_of_Mths_Rent_Deduction__c) ||
                                           (recordOldMap.get(c.Id).Penalty_charges__c != c.Penalty_charges__c)  ||
                                           (recordOldMap.get(c.Id).Refund_Applicable__c != recordOldMap.get(c.Id).Refund_Applicable__c))){
                                               caseIdsForRefunds.add(c.Id);
                                           }*/
            }
        }
        system.debug('setCasePDCOnHold size >>>>'+setCasePDCOnHold.size());
        //Update the PDC/reciept status to on hold
        if(setCasePDCOnHold.size()>0){
            updatePDCStatusOnHold(setCasePDCOnHold,recordOldMap,mapCasePDCOnHold);
        }
        /*if(setCaseRefundCal.size()>0){
            //caseRefundCalculation(setOpportunity,mapCaseRefundCal) ;
        }*/
        
        if(caseIds.size() > 0){
            updateRentalRentOnCase(caseIds);
        }
        
        /*if(caseIdsForRefunds.size() > 0){
            calculateTerminatonRefund(caseIdsForRefunds);
        }*/
        
        
        
    }
    //Validate case type change validation 
    public static void validateCaseTypeChange(List<Case> newCaseList,Map<Id, Case> recordOldMap,Map<Id, Case> recordNewMap){
        Id masterCaseRecordType=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Email-To-Case SR').getRecordTypeId();
        //condition to check if the record type is changed only once
        For(Case c: newCaseList){
            if(c.Type !=recordOldMap.get(c.Id).Type /*&& c.RecordTypeId!=recordOldMap.get(c.Id).RecordTypeId*/ && recordOldMap.get(c.Id).RecordTypeId !=masterCaseRecordType && recordOldMap.get(c.Id).Type != null){ // changed by jaskiran as type was required and this was showing error
                if(c.RecordTypeId==recordOldMap.get(c.Id).RecordTypeId){
                    c.addError(ConstantUtility.ERRORMSG_CASE_TYPE_CHANGE_ALLOW_ONCE); 
                }
                
            }
            
        }
    }
    
    public static void updatePDCStatusOnHold (Set<Case> caseList,Map<Id, Case> recordOldMap,Map<Id, Case> caseNewMap){
        Set<Id> setOppId =new Set<Id>();
        List<Receipt__c> listReceipt= new List<Receipt__c>();
        List<Receipt__c> listSDReceipt= new List<Receipt__c>();
        Map<id,id> mapOppIdToCaseId=new Map<id,id>();
        List<Case> listCaseToUpdate=new List<Case>();
        
        For(Case c:caseList){
            setOppId.add(c.Deal__c);
            mapOppIdToCaseId.put(c.Deal__c,c.Id);
        }
        
        system.debug('setOppId >>>>'+setOppId);
        if(setOppId.size()>0){
            listReceipt=[select Id, Name,  Payment_Mode__c, Invoice_ID__c, Payment_URL__c, Amount__c, Opportunity__c,
                         Account__c, Payment_Date__c, Payment_Status__c,  Payment_Type__c, Receipt_Method__c, Business_Unit__c,
                         Receipt_Number__c, Due_Date__c, Installment_Type__c from Receipt__c where Payment_Mode__c = 'Cheque' and Opportunity__c in:setOppId and Payment_Status__c='Pending' ];            
            listSDReceipt=[select Id, Name,  Payment_Mode__c, Invoice_ID__c, Payment_URL__c, Amount__c, Opportunity__c,
                           Account__c, Payment_Date__c, Payment_Status__c,  Payment_Type__c, Receipt_Method__c, Business_Unit__c,
                           Receipt_Number__c, Due_Date__c, Installment_Type__c from Receipt__c where Opportunity__c in:setOppId and Installment_Type__c= 'Deposit' ];
            if(listReceipt.size()>0){
                for(Receipt__c r:listReceipt){
                    r.Payment_Status__c='On Hold';
                    
                }
                update listReceipt;
            }
        }
        
    }
    
    public static void validateCaseUnit (List<Case> newCaseList,Map<Id, Case> recordOldMap,Map<Id, Case> recordNewMap){
        Id preMatureTerRecordType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Termination').getRecordTypeId();
        system.debug('rtId PMT>>>>'+preMatureTerRecordType);
        Map<Id,Case> mapValidateCase = new Map<Id,Case>();
        Set<Id> setCaseId=new Set<Id>();
        List<Case_unit__c> listCaseUnit=new List<Case_unit__c>();
        Map<Id,List<Case_unit__c>> mapCaseIdToCaseUnitList= new Map<Id,List<Case_unit__c>>();
        for(Case c: newCaseList){
            if(c.RecordTypeId==preMatureTerRecordType && c.Status!=recordOldMap.get(c.Id).Status && c.Status== ConstantUtility.STATUS_IN_PROGRESS 
               && recordOldMap.get(c.Id).Status== ConstantUtility.STATUS_NEW ){
                   mapValidateCase.put(c.Id, c);
                   setCaseId.add(c.id);   
               }
        }
        if(mapValidateCase.size() >0){
            listCaseUnit=[select Id, Name,  Unit__c, Case__c  from Case_unit__c where Case__c  in:setCaseId ];
            system.debug('listCaseUnit.size >>>>'+listCaseUnit.size());
            if(listCaseUnit.size()>0){
                for(Case_unit__c cu:listCaseUnit){
                    if(mapCaseIdToCaseUnitList.containsKey(cu.Case__c) == true){
                        List<Case_unit__c> listTempCaseUnit= mapCaseIdToCaseUnitList.get(cu.Case__c);
                        listTempCaseUnit.add(cu);
                    }
                    else{
                        mapCaseIdToCaseUnitList.put(cu.Case__c,new List<Case_unit__c>{cu});
                    }
                }
            }
            system.debug('mapCaseIdToCaseUnitList.size'+mapCaseIdToCaseUnitList.size());
            //if(mapCaseIdToCaseUnitList.size()>0){
            for(Id i:setCaseId){
                system.debug('case Id>>>>'+i);
                system.debug('case unit list size>>>>'+mapCaseIdToCaseUnitList.containsKey(i));
                if((mapCaseIdToCaseUnitList.containsKey(i) && mapCaseIdToCaseUnitList.get(i).size()==0) || mapCaseIdToCaseUnitList.containsKey(i)==false  ){
                    
                    recordNewMap.get(i).addError(ConstantUtility.ERRORMSG_CASE_NO_UNIT_SEL_PM_TER);
                }
                
            }
            //}
            //}
        }
        
        
    }
    
    //Method to identify the refund Installments
    public static void caseRefundCalculation(Set<Id> setOppId, MAP<id,Case>caseNewMap){
        List<Payment_Milestone__c> listInstalments=new List<Payment_Milestone__c>();
        Map<Id,List<Payment_Milestone__c>> mapOppIdToListInstalments = new Map<Id,List<Payment_Milestone__c>>();
        List<Case> listCaseUpdate=new List<Case>();
        
        listInstalments=[select Id, OwnerId,  Name, Installment_No__c, Amount_Percentage__c, Milestone_Trigger_Point__c,
                         Due_In_Days__c, Opportunity__c, Master_Payment_Milestone__c, Due_Date__c, Amount__c, Master_Payment_Plan__c,
                         Installment__c, Case__c, Unit__c, Lead__c, Purpose__c, Description__c  from Payment_Milestone__c where Opportunity__c in:setOppId order by Due_Date__c asc];
        if(listInstalments.size()>0){
            for(Payment_Milestone__c pm:listInstalments){
                List<Payment_Milestone__c> tempList=new List<Payment_Milestone__c>();
                if(mapOppIdToListInstalments.containsKey(pm.Opportunity__c)){
                    tempList=mapOppIdToListInstalments.get(pm.Opportunity__c);
                    tempList.add(pm);
                }
                else{                   
                    tempList.add(pm);
                    mapOppIdToListInstalments.put(pm.Opportunity__c,tempList);
                }
                
            }
            
            for(Id i:caseNewMap.keySet()){
                Case c=caseNewMap.get(i);
                String instalmentNames;
                Map<Id,Payment_Milestone__c> mapRemainingPM=new Map<Id,Payment_Milestone__c>();
                Integer diff=0;
                Decimal tempTotalAmount=c.Security_Deposit__c-c.Penalty_charges__c;
                Payment_Milestone__c lastPM=new Payment_Milestone__c();
                
                if(c.Security_Deposit__c != 0.00){
                    instalmentNames='Security Deposit';
                }
                else{
                    instalmentNames='';
                }
                
                for(Payment_Milestone__c pm:mapOppIdToListInstalments.get(c.Deal__c)){
                    if(pm.Due_Date__c>c.Actual_Termination_Date__c && pm.Installment__c !='Deposit'){
                        if(!String.isBlank(instalmentNames)){
                            instalmentNames=instalmentNames+','+pm.Name;
                        }
                        else{
                            instalmentNames=pm.Name;
                        }
                        tempTotalAmount+=pm.Amount__c;
                        
                    }
                    else{
                        if(pm.Installment__c !='Deposit'){
                            mapRemainingPM.put(pm.id,pm); 
                        }
                        
                    }
                    
                }
                if(c.Refund_Amount__c >tempTotalAmount){
                    for(Id p:mapRemainingPM.keyset()){
                        Payment_Milestone__c ptemp=mapRemainingPM.get(p);
                        Integer tempDiff=c.Actual_Termination_Date__c.daysBetween(ptemp.Due_Date__c);
                        if(diff!=0){
                            if(diff>tempDiff){
                                diff=tempDiff;
                                lastPM=mapRemainingPM.get(p);
                            }     
                        }
                        else{
                            diff=tempDiff;
                            lastPM=mapRemainingPM.get(p);
                        }
                    }
                    if(lastPM !=null){
                        if(!String.isBlank(instalmentNames)){
                            instalmentNames=instalmentNames+','+lastPM.Name;
                        }
                        else{
                            instalmentNames=lastPM.Name;
                        } 
                    }
                }
                if(!String.isBlank(instalmentNames)){
                    Case cNew=new Case();
                    cNew.id=c.Id;
                    cNew.Instalments_part_of_refund__c=instalmentNames;
                    listCaseUpdate.add(cNew);
                    
                }
                
                
                
            }
            if(listCaseUpdate.size()>0){
                update listCaseUpdate;
            }
        }
        
    }
    
    public static void createJointOnwers(Set<ID> oppIDS, List<Case> jointOwnRecID_CaseLst){
        List<Opportunity> opps = [select id,(select id,Primary_Account__c ,Relationship_with_Owner__c ,Secondary_Account__c ,
                                             Share_Percentage__c ,Unit__c  from Joint_Buyers__r ) from opportunity where ID IN:oppIDS];
        
        Map<ID , List<Joint_Buyer__c>> opID_JointBuyrsLst_Map = new Map<ID , List<Joint_Buyer__c>> ();
        for(Opportunity opp : opps){
            opID_JointBuyrsLst_Map.put(opp.ID, opp.Joint_Buyers__r);
        }
        
        List<Joint_Buyer__c> new_JointOwners = new List<Joint_Buyer__c>();//Joint owners to be tagged on case same as opportunity
        
        for(Case cs : jointOwnRecID_CaseLst){
            if(opID_JointBuyrsLst_Map.containsKey(cs.Deal__c) ){
                
                if(opID_JointBuyrsLst_Map.get(cs.Deal__c)!=null){ 
                    List<Joint_Buyer__c>  existing_OwnrLst = opID_JointBuyrsLst_Map.get(cs.Deal__c);
                    
                    for(Joint_Buyer__c jb : existing_OwnrLst){
                        Joint_Buyer__c newJB = jb.clone(false);
                        newJB.Case__c =  cs.ID;
                        newJB.Opportunity__c = null;
                        new_JointOwners.add(newJB);
                        //jb.clone(true);
                    }  
                }  
            }
        }
        
        if(!(new_JointOwners.isEmpty())){
            try{
                insert new_JointOwners;
            }
            catch(Exception ex){
                system.debug('new_JointOwners are '+ new_JointOwners);
                system.debug('error is '+ ex.getMessage() +'at '+ ex.getLineNumber()); 
            }
        }
    }
    
    //Method to add payment milestones to case from Opp
    //Author: Ashams
    public static void createExistingPM(List<Case>lstcase) { 
        List<Payment_Milestone__c> clonedPPMS = new List<Payment_Milestone__c>();
        set<Id> OppIds = new set<Id>();
        MAP<Id,Id> OppIdCaseIdMap = new MAP<Id,Id>();
        MAP<Id,List<Payment_Milestone__c>> oppPMlistMap = new MAP<Id,List<Payment_Milestone__c>>();
        
        for(case c:lstcase){
            if(c.Deal__c!=null){
                OppIds.add(c.Deal__c);
                OppIdCaseIdMap.put(c.Deal__c,c.Id);
            } 
        }
        if(OppIds!=null){
            List<Payment_Milestone__c> oppPaymentMilestones = [select Id, Name,Amount__c ,Due_Date__c,Master_Payment_Milestone__c ,opportunity__c,Master_Payment_Plan__c,
                                                               Due_In_Days__c, Case__c,Installment_No__c,Installment__c from Payment_Milestone__c
                                                               where  Opportunity__c IN: OppIds]; 
            if(oppPaymentMilestones.size()>0){
                for(Payment_Milestone__c pm:oppPaymentMilestones){
                    if(oppPMlistMap.containsKey(pm.opportunity__c)) {
                        List<Payment_milestone__c> pmlist = oppPMlistMap.get(pm.opportunity__c);
                        pmlist.add(pm);
                        oppPMlistMap.put(pm.opportunity__c, pmlist);
                    }else{
                        oppPMlistMap.put(pm.opportunity__c, new List<Payment_milestone__c>{pm});
                    }
                } 
            }
            
            if(oppPMlistMap.size()>0){
                for(Id oppId: oppPMlistMap.keyset()){
                    for(Payment_Milestone__c objPPM: oppPMlistMap.get(oppId)){
                        Payment_Milestone__c clonePM = new Payment_Milestone__c();
                        clonePM.Name = objPPM.Name;
                        clonePM.Amount__c = objPPM.Amount__c;
                        clonePM.Due_Date__c = objPPM.Due_Date__c;
                        clonePM.Installment__c = objPPM.Installment__c;
                        clonePM.Due_In_Days__c = objPPM.Due_In_Days__c;
                        clonePM.Master_Payment_Plan__c = objPPM.Master_Payment_Plan__c;
                        clonePM.Case__c = OppIdCaseIdMap.get(oppId);
                        clonedPPMS.add(clonePM);
                    }
                }
            }
            if(clonedPPMS.size() > 0){
                insert clonedPPMS;
            }
            
        }
        
        /*if(lstcase.size()>0){
Case cs = [SELECT Id,Deal__c FROM Case WHERE Id = :lstcase[0].Id];
List<Payment_Milestone__c> lstPaymentMilestones = [select Id, Name,Amount__c ,Due_Date__c,Master_Payment_Milestone__c ,
Due_In_Days__c, Case__c,Installment_No__c,Installment__c   from Payment_Milestone__c
where  Opportunity__c=:cs.Deal__c];

if(lstPaymentMilestones.size()>0){
for(Payment_Milestone__c objPPM :lstPaymentMilestones ) {
Payment_Milestone__c clonePM = new Payment_Milestone__c();
clonePM.Name = objPPM.Name;
clonePM.Amount__c = objPPM.Amount__c;
clonePM.Due_Date__c = objPPM.Due_Date__c;
clonePM.Installment__c = objPPM.Installment__c;
clonePM.Due_In_Days__c = objPPM.Due_In_Days__c;
clonePM.Case__c = cs.Id;
clonedPPMS.add(clonePM);
} 
}
if(clonedPPMS.size() > 0){
upsert clonedPPMS;
}
}*/
        
    }
    
    /**
* @author : Swapnil Mohite
* @createdDate : 31-Jan-2022
* @lastModifieddate : 31-Jan-2022
* @purpose : Unit Upgrade/Downgrade after Insert/Update SR in Leasing Process
* @usage : invoked in Case TriggerHandler
*/
    public static void unitUpgDowngradeAfterActions(List<Case> newCaseList){
        
        
    }
    /**
* @author : Swapnil Mohite
* @createdDate : 31-Jan-2022
* @lastModifieddate : 31-Jan-2022
* @purpose : Unit Upgrade/Downgrade  before Insert/Update SR in Leasing Process
* @usage : invoked in Case TriggerHandler
*/
    /* public static void unitUpgDowngradeBeforeActions(List<Case> newCaseList,Map<Id,Case> oldCaseMap,Boolean isUpdate){
Id unitRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unit Change').getRecordTypeId();
Set<Id> accIdSet = new Set<Id>();
for(Case cs : newCaseList){
accIdSet.add(cs.AccountId);
}
Map<Id,Opportunity> accOppMap = getRelatedOppUnits(accIdSet);
// before update logic

for(Case caseObj : newCaseList){
if(isUpdate){
if(caseObj.RecordTypeId == unitRecId && caseObj.new_unit__c != null &&
caseObj.new_unit__c != oldCaseMap.get(caseObj.Id).new_unit__c && caseObj.Status != 'Closed'){
caseObj.Status  = 'In Progress';
}
if(caseObj.AccountId != oldCaseMap.get(caseObj.Id).AccountId){
caseObj.Unit__c = accOppMap.get(caseObj.AccountId).unit__c;
caseObj.Deal__c = accOppMap.get(caseObj.AccountId).Id;
}
}else{// before insert logic
if(caseObj.AccountId != null){
caseObj.Unit__c = accOppMap.get(caseObj.AccountId).unit__c;
caseObj.Deal__c = accOppMap.get(caseObj.AccountId).Id;
}
}
}
}*/
    /**
* @author : Swapnil Mohite
* @createdDate : 31-Jan-2022
* @lastModifieddate : 31-Jan-2022
* @purpose : Get related opp and unit of account on case
* @usage : invoked in Case TriggerHandler
*/
    /*public static Map<Id,Opportunity> getRelatedOppUnits(Set<Id> accountIdSet){
Map<Id,Opportunity> accOppMap = new Map<Id,Opportunity>();
List<Opportunity> oppList = [SELECT id,name,unit__c 
FROM Opportunity 
WHERE AccountId IN : accountIdSet and Is_Recently_Closed__c = true];
for(Opportunity opp : oppList){
accOppMap.put(opp.AccountId,opp);
}
return accOppMap;
}*/
    
    /**
* @author : Swapnil Mohite
* @createdDate : 08-Jan-2022
* @lastModifieddate : 08-Jan-2022
* @purpose : Actions for renewal SR
* @usage : Validation of the renewal sr when case status is changes from new to inprogress
*/
    public static void renewalActions(List<Case> newCaseList,Map<Id,Case> oldCaseMap,Map<Id, Case> recordNewMap){
        Id renewalRecordType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> setOppId = new Set<ID>();
        List<Case> listCaseUpdate= new List<Case>();
        Map<Id,Id> mapCaseIdToOppId=new Map<Id,Id>();
        List<Id> listCaseIdForEmail=new list<ID>();
        
        //added for Email logger
        EmailTemplate emailTemplate = [Select Id, Name, DeveloperName, IsActive,Description  from EmailTemplate where name = 'Notify Tenant active flag on acc' Limit 1];
        
        for(Case caseObj : newCaseList){
            if(caseObj.RecordTypeId == renewalRecordType && caseObj.Status!=oldCaseMap.get(caseObj.id).Status  && caseObj.Status=='In Progress'){
                accountIdSet.add(caseObj.AccountId);
                caseIdSet.add(caseObj.Id);
                if(caseObj.Deal__c != null){
                    setOppId.add(caseObj.Deal__c);
                    mapCaseIdToOppId.put(caseObj.id,caseObj.Deal__c);
                }
            }
        }
        if(caseIdSet.size()>0){
            validateDocsForRenewal(newCaseList,accountIdSet,caseIdSet); // validate docs if they are not expired
        }
        
        if(setOppId.size()>0){
            validateOutstandingAmtRenewSR(setOppId,mapCaseIdToOppId,recordNewMap,oldCaseMap); 
        }
        Map<Id, List<String>> accountFlagMap = CheckFlags.checkAccountFlags(accountIdSet,false, true, false);
        system.debug('flag-->'+accountFlagMap);
        for(Case caseObj : newCaseList){
            if(accountFlagMap.containsKey(caseObj.AccountId) && caseObj.Status != oldCaseMap.get(caseObj.Id).Status && caseObj.RecordTypeId == renewalRecordType && caseObj.Status=='In Progress'){
                if(accountFlagMap.get(caseObj.AccountId).size() > 0){
                    caseObj.addError('Associated account has active flags.Please check account view for more details.');
                    listCaseIdForEmail.add(caseObj.Id);//added for Email logger
                }
                /*else{
//auto update stage for renewal SR
caseObj.Status='In Progress';
listCaseUpdate.add(caseObj);
}*/
            }
        }
        //added for Email logger
        if(listCaseIdForEmail.size()>0){
            //sendEmail(listCaseIdForEmail, emailTemplate.DeveloperName);
        }
        /*if(listCaseUpdate.size()>0){
update listCaseUpdate;
}*/
        
    }
    
    public static void validateOutstandingAmtRenewSR(Set<ID> setOppId, Map<Id,Id> mapCaseIdToOppId,Map<Id, Case> recordNewMap,Map<Id,Case> oldCaseMap){
        List<Receipt__c> listReceipt=new List<Receipt__c>();
        Map<Id,Id> mapOppIdToReceiptId=new Map<Id,Id>();
        List<ID> listCaseIdEmail=new List<Id>();
        
        EmailTemplate emailTemplate = [Select Id, Name, DeveloperName, IsActive,Description  from EmailTemplate where name = 'Outstanding amt in Renew SR to cust' Limit 1];
        listReceipt=[select Id, Name, Payment_Mode__c,Amount__c, Opportunity__c, Account__c, Payment_Date__c,Payment_Status__c from Receipt__c  where Opportunity__c in:setOppId and Payment_Status__c='Pending' ];
        
        if(listReceipt.size()>0){
            for(Receipt__c r:listReceipt){
                
                mapOppIdToReceiptId.put(r.Opportunity__c,r.Id); 
                
                
            }
            if(mapOppIdToReceiptId.size()>0){
                for(Id i:mapCaseIdToOppId.KeySet()){
                    if(mapOppIdToReceiptId.containskey(mapCaseIdToOppId.get(i)) && recordNewMap.get(i).Deal__c ==oldCaseMap.get(i).Deal__c ){
                        recordNewMap.get(i).addError('Associated account has outstanding payments to be cleared before renewal');
                        listCaseIdEmail.add(i);
                    }
                }
            }
            if(listCaseIdEmail.size()>0){
                //sendEmail(listCaseIdEmail, emailTemplate.DeveloperName);//Email logger is failing 
            }
            
        }
    }
    
    /**
* @author : Hitesh
* @createdDate : 23-Feb-2022
* @lastModifieddate : 08-Jan-2022
* @purpose : auto update renewal SR status
* @usage : invoked in Case TriggerHandler
*/
    //Not in use due to process change for Renewal SR -- hitesh
    /* public static void autoUpdStatusReSR(List<Case> newCaseList,Map<Id,Case> oldCaseMap){
Id renewalRecordType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
List<Case> listCaseUpdate= new List<Case>();

for(Case caseObj : newCaseList){
if(caseObj.Lease_renewal_date__c != oldCaseMap.get(caseObj.Id).Lease_renewal_date__c && caseObj.RecordTypeId == renewalRecordType){
{
//auto update stage for renewal SR

listCaseUpdate.add(new Case(id=caseObj.id,Status='In Progress'));
}
}
}
if(listCaseUpdate.size()>0){
update listCaseUpdate;
}
}*/
    
    /**
* @author : Swapnil Mohite
* @createdDate : 12-Jan-2022
* @lastModifieddate : 12-Jan-2022
* @purpose : Validate documents for Renewal
*/    
    public static void validateDocsForRenewal(List<Case> newList,Set<Id> accIds,Set<Id> caseIdSet){
        Set<String> expirySet = new Set<String>(); 
        Map<String,List<String>> accErrorMap = new Map<String,List<String>>(); 
        expirySet.add('PASSPORT');
        expirySet.add('Emirates ID');
        expirySet.add('Visa');
        List<Object_Document__c> documentList = [SELECT id,name,document__r.Document_Type__c,document__r.expiry_Date__c,document__r.account__c
                                                 FROM Object_document__c
                                                 WHERE document__r.Account__c IN: accIds and case__c IN: caseIdSet and document__r.Document_Type__c IN: expirySet and (document__r.expiry_Date__c < TODAY or document__r.expiry_Date__c = null)];
        For(Object_Document__c objDoc : documentList){
            if(accErrorMap.containsKey(objDoc.document__r.Account__c)){
                if(objDoc.document__r.Document_Type__c == 'PASSPORT'){
                    accErrorMap.get(objDoc.document__r.Account__c).add('Passport is expired,please upload valid passport');
                }else if(objDoc.document__r.Document_Type__c == 'Emirates Id'){
                    accErrorMap.get(objDoc.document__r.Account__c).add('Emirates Id is expired,please upload valid emirates id');
                }else if(objDoc.document__r.Document_Type__c == 'Visa'){
                    accErrorMap.get(objDoc.document__r.Account__c).add('Visa is expired,please upload valid visa');
                }
            }else{
                if(objDoc.document__r.Document_Type__c == 'PASSPORT'){
                    accErrorMap.put(objDoc.document__r.Account__c,new List<String>{'Passport is expired,please upload valid passport'});
                }else if(objDoc.document__r.Document_Type__c == 'Emirates Id'){
                    accErrorMap.put(objDoc.document__r.Account__c,new List<String>{'Emirates Id is expired,please upload valid emirates id'});
                }else if(objDoc.document__r.Document_Type__c == 'Visa'){
                    accErrorMap.put(objDoc.document__r.Account__c,new List<String>{'Visa is expired,please upload valid visa'});
                }
            }
            
        }
        
        for(Case caseObj : newList){
            if(accErrorMap.containsKey(caseObj.AccountId) && caseObj.Lease_renewal_date__c != null){
                caseObj.addError(String.join(accErrorMap.get(caseObj.AccountId),', '));
            }  
        }
        
        
    }
    /**
* @author : Swapnil Mohite
* @createdDate : 19-Feb-2022
* @lastModifieddate : 19-Feb-2022
* @purpose : Create leasing opp after approval of renewal case
* @usage : invoked in Case TriggerHandler
*/
    public static void createCaseAndOppPostApprovalRenewal(List<Case> newCaseList,Map<Id,Case> recordOldMap,Map<Id,Case> recordNewMap){
        
        
        
        
        
        
    }    
    /**
* @author : Hitesh Saini
* @createdDate : 08-Feb-2022
* @lastModifieddate : 08-Feb-2022
* @purpose : Create PMT case and Leasing Opportunity post U/D SR Case Approval
* @usage : invoked in Case TriggerHandler
*/
    public static void createCaseAndOppPostApproval(List<Case> newCaseList,Map<Id,Case> recordOldMap,Map<Id,Case> recordNewMap){
        Map<Id,Case> mapIdToCase =new Map<Id,Case>();
        Set<Id> setCaseId = new Set<Id>();
        List<Case_unit__c> listCaseUnit=new List<Case_unit__c>();
        Map<Id,List<Case_unit__c>> mapCaseIdToCUnit=new  Map<Id,List<Case_unit__c>>();
        Id UDRecordType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unit Change').getRecordTypeId();
        Id preMatureTerRecordType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Termination').getRecordTypeId();
        List<Case> listPMTCaseInsert=new List<Case>();
        List<Case_unit__c> listInsertCUnit=new List<Case_unit__c>();
        Id leaseOppRT= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Units Leasing').getRecordTypeId();
        List<Opportunity> listOppInsert=new List<Opportunity>();
        Map<Id,Id> mapOppIdToCaseId=new Map<Id,Id>();
        List<Unit_Plan__c> listUnitPlanInsert=New List<Unit_Plan__c>();
        Map<Id,Id> mapCaseIdToNewUnitId= New Map<Id,Id>();
        Id renewalRecordType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        Set<Id> setOppId=new Set<ID>();
        Map<Id,Id> mapCaseIdToOppId=new  Map<Id,Id>();
        Map<Id,Opportunity> mapOppIdToOpp=new Map<ID,Opportunity>();
        Map<ID,String> mapUDCaseToUnitName=New Map<ID,String>();
        Id oppRenewRecordType= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Lease Renewal').getRecordTypeId();
        Map<Id, List<Case_unit__c>> mapNewCaseUnitsByCaseId = new  Map<Id, List<Case_unit__c>>();
        Map<Id, List<Case_unit__c>> mapExistingCaseUnitsByCaseId = new  Map<Id, List<Case_unit__c>>();
        
        Group suppQueue=[select Id,DeveloperName  from Group where Type = 'Queue' and DeveloperName= 'Nakheel_Customer_Support_Queue' Limit 1];
        
        for(Case c:newCaseList){
            if(c.RecordTypeId ==UDRecordType && c.Approval_Status__c !=recordOldMap.get(c.Id).Approval_Status__c 
               && c.Approval_Status__c == ConstantUtility.APPROVAL_STATUS_APPROVED){
                    setCaseId.add(c.Id);
                   system.debug('c.No_of_Case_Units__c>>>>>'+c.No_of_Case_Units__c);
                   //condition added for the Bulk scenario - no opportunity units to be created for Bulk
                   /*if(c.No_of_Case_Units__c==1){
                       mapCaseIdToNewUnitId.put(c.id,c.New_Unit__c); 
                   }*/
                   
                   setOppId.add(c.Deal__c);
                   mapCaseIdToOppId.put(c.Id,c.Deal__c);
               }
            else if(c.RecordTypeId ==renewalRecordType && c.Approval_Status__c !=recordOldMap.get(c.Id).Approval_Status__c 
                    && c.Approval_Status__c == ConstantUtility.APPROVAL_STATUS_APPROVED){
                        setCaseId.add(c.Id);
                        setOppId.add(c.Deal__c);
                        mapCaseIdToOppId.put(c.Id,c.Deal__c);
                        //mapCaseIdToNewUnitId.put(c.id,c.Unit__c);
                    }
        }
        system.debug('setOppId>>>>'+setOppId);
        system.debug('mapCaseIdToOppId>>>>'+mapCaseIdToOppId);
        system.debug('setCaseId>>>>'+setCaseId);

        mapOppIdToOpp = new Map<Id, Opportunity>([SELECT id, Project__c, Account.Name, Lease_End_Date__c, RecordTypeId, StageName, name FROM Opportunity WHERE ID IN : setOppId]);

        /*if(setOppId.size()>0){            
            List<Opportunity> oppList = [SELECT id,RecordTypeId,StageName,name
                                         FROM Opportunity 
                                         WHERE ID IN : setOppId];
            system.debug('oppList>>>>'+oppList);
            if(oppList.size()>0){
                for(Opportunity o:oppList){
                    mapOppIdToOpp.put(o.Id,o);
                }
                system.debug('mapOppIdToOpp>>>>'+mapOppIdToOpp);
            }
        }*/
        
        if(setCaseId.size()>0){

            /*listCaseUnit = [select Id,Name,Unit__c, Case__c,Unit__r.Name from Case_unit__c where Case__c in:listCaseId];
            if(listCaseUnit.size()>0){
                for(Case_unit__c cu : listCaseUnit){
                    if(mapCaseIdToCUnit.containsKey(cu.Case__c)==True){
                        List<Case_unit__c> listTemp=new List<Case_unit__c>();
                        listTemp=mapCaseIdToCUnit.get(cu.Case__c);
                        listTemp.add(cu);
                    }
                    else{
                        List<Case_unit__c> listTemp=new List<Case_unit__c>();
                        listTemp.add(cu);
                        mapCaseIdToCUnit.put(cu.Case__c,listTemp);
                    }
                }
                system.debug('mapCaseIdToCUnit>>>>'+mapCaseIdToCUnit);
            }*/

            for(Case_Unit__c objCaseUnit : [SELECT Id,Name,Unit__c, Case__c,Unit__r.Name, Unit__r.Unit_Code__c, Type__c FROM Case_unit__c WHERE Case__c in:setCaseId]){
                List<Case_Unit__c> listTempCaseUnit = new List<Case_Unit__c>();
                if(objCaseUnit.Type__c == 'New'){                
                    if(mapNewCaseUnitsByCaseId.containsKey(objCaseUnit.Case__c)){
                        listTempCaseUnit = mapNewCaseUnitsByCaseId.get(objCaseUnit.Case__c);
                    }
                    listTempCaseUnit.add(objCaseUnit);
                    mapNewCaseUnitsByCaseId.put(objCaseUnit.Case__c, listTempCaseUnit);
                }
                
                if(objCaseUnit.Type__c == 'Existing'){                
                    if(mapExistingCaseUnitsByCaseId.containsKey(objCaseUnit.Case__c)){
                        listTempCaseUnit = mapExistingCaseUnitsByCaseId.get(objCaseUnit.Case__c);
                    }
                    listTempCaseUnit.add(objCaseUnit);
                    mapExistingCaseUnitsByCaseId.put(objCaseUnit.Case__c, listTempCaseUnit);
                }
            }
            
            for(Id i:mapCaseIdToCUnit.KeySet()){
                if(mapCaseIdToCUnit.get(i).size()==1){
                    mapUDCaseToUnitName.put(i,mapCaseIdToCUnit.get(i)[0].Unit__r.Name);
                }
            }
            
            for(Id c:setCaseId){
                Case udCase=recordNewMap.get(c);
                if(udCase.RecordTypeId ==UDRecordType){
                    
                    Case pmtCase=new Case();
                    pmtCase.AccountId=udCase.AccountId;
                    pmtCase.RecordTypeId=preMatureTerRecordType;
                    pmtCase.Type='Premature termination';
                    pmtCase.OwnerId=suppQueue.Id;
                    pmtcase.ParentId=c;
                    pmtcase.Origin=udCase.Origin;
                    pmtCase.Subject=' for Unit(s)'+''+udCase.Subject;
                    pmtCase.Do_you_want_to_be_treated_as_new_tenant__c=udCase.Do_you_want_to_be_treated_as_new_tenant__c;
                    //if(mapUDCaseToUnitName.containsKey(udCase.Id)){
                        if(udCase.No_of_Case_Units__c == 1){
                            pmtCase.Subject='Termination request for Unit(s) - ' + mapNewCaseUnitsByCaseId.get(udCase.Id) + ' - ' + udCase.Subject;
                        }
                        if(udCase.No_of_Case_Units__c >1){
                            pmtCase.Subject='Termination request for Unit(s) - Multiple Units - '+udCase.Subject;                        
                        }
                        
                    //}
                    pmtCase.Premature_Termination_Reason__c = 'Unit Change';
                    pmtCase.Actual_Termination_Date__c = udCase.Unit_change_date__c;
                    pmtCase.Security_Deposit__c=udCase.Security_Deposit__c;                    
                    pmtCase.Lease_Start_Date__c = udCase.Lease_Start_Date__c;
                    pmtCase.Expected_Termination_Date__c = udCase.Lease_Start_Date__c.adddays(-1);
                    pmtCase.Deal__c =udCase.Deal__c; 
                    listPMTCaseInsert.add(pmtCase);
                }
                
                
                Opportunity opp=new Opportunity();
                //opp.Name=udCase.CaseNumber+'-Leasing Opportunity';
                String strUnitCode = '';

                if(mapNewCaseUnitsByCaseId.size() > 0){
                    strUnitCode = mapNewCaseUnitsByCaseId.get(udCase.Id)[0].Unit__r.Unit_Code__c;
                }

                opp.Name = mapOppIdToOpp.get(udCase.Deal__c).Account.Name + ' - ' + strUnitCode + ' - ' + udCase.Lease_Start_Date__c.Year() + ' - '+ udCase.CaseNumber;
                opp.CloseDate=System.today().addMonths(1);
                opp.Interested_In__c='Residential Leasing';
                opp.Leasing_Type__c='Residential Units';
                opp.AccountId=udcase.AccountId;
                opp.RecordTypeId=mapOppIdToOpp.get(mapCaseIdToOppId.get(c)).RecordTypeId;
                opp.Project__c = mapOppIdToOpp.get(udCase.Deal__c).Project__c;
                opp.Do_you_want_to_be_treated_as_new_tenant__c=udCase.Do_you_want_to_be_treated_as_new_tenant__c;
                opp.Send_Lease_to_ERP__c = true;
                opp.Change_Unit__c = true;
                //opp.Lease_Start_Date__c = system.today();
                opp.StageName='Unit Reservation';
                opp.Lease_Start_Date__c = udCase.Lease_Start_Date__c;
                opp.Lease_End_Date__c = mapOppIdToOpp.get(udCase.Deal__c).Lease_End_Date__c;
                if(udCase.RecordTypeId ==renewalRecordType){
                    opp.RecordTypeId=oppRenewRecordType;
                    if(mapOppIdToOpp.containsKey(udCase.Deal__c)){
                        opp.Name='Renewal- '+mapOppIdToOpp.get(udCase.Deal__c).Name;
                    }
                    
                }
                opp.Booking_Mode__c='Reservation without token amount';
                opp.Case__c=c;
                opp.OwnerId=udCase.OwnerId;
                opp.Opportunity__c=udcase.Deal__c;
                if(udCase.Lease_Commission_Applied__c==true && udCase.No_of_Case_Units__c==1){
                    opp.Lease_Commission_Applied__c=True;//create a new field to update check box
                }
                if(udCase.type=='Renewal'){
                    
                    opp.StageName='New';
                    opp.Renewal__c=True;//create a new field to update check box
                    if(udcase.Renewal_Type__c=='Extension'){
                        opp.Lease_Start_Date__c=udCase.Lease_End_Date__c;
                        //opp.Lease_End_Date__c=udCase.Lease_End_Date__c.addMonths(udCase.noOfMonths__c);
                        date mydate=udCase.Lease_End_Date__c;
                        Integer noOfMonths=(Integer)udCase.noOfMonths__c;
                        opp.Lease_End_Date__c=mydate.addMonths(noOfMonths);
                        //opp.Final_Unit_Price__c=udCase.Rent_Amount_Per_Day__c*(365/30)*udCase.noOfMonths__c;//base lease amount
                    }
                    if(udcase.Renewal_Type__c=='Full'){
                        opp.Lease_Start_Date__c=udCase.Lease_End_Date__c;
                        opp.Lease_End_Date__c=udCase.Lease_End_Date__c.addDays(364);
                        
                    }
                    
                }
                if(udCase.Financial_adjustment_needed__c == true && udCase.No_of_Case_Units__c==1){
                    opp.Refund_Amount__c=udCase.Refund_Amount_Change_Unit_SR__c;
                    Refund__c r=new Refund__c();
                    
                }
                listOppInsert.add(opp); 
                
            }
            if(listPMTCaseInsert.size()>0){
                system.debug('listPMTCaseInsert.size>>>>'+listPMTCaseInsert.size());
                insert listPMTCaseInsert;
                for(case c:listPMTCaseInsert){
                    for(Case_unit__c cu : mapExistingCaseUnitsByCaseId.get(c.ParentId)){
                        Case_unit__c cUnit = new Case_unit__c();
                        cUnit.Case__c = c.id;
                        cUnit.Unit__c = cu.Unit__c;
                        cUnit.Type__c = 'Existing';
                        listInsertCUnit.add(cUnit);
                    }
                    
                }
                if(listInsertCUnit.size()>0){
                    system.debug('listInsertCUnit.size>>>>'+listInsertCUnit.size());
                    insert listInsertCUnit;
                }
            }
            if(listOppInsert.size()>0){
                system.debug('listOppInsert.size()>>>>'+listOppInsert.size());
                insert listOppInsert;

                List<Unit__c> listUnit = new List<Unit__c>(); 

                for(Opportunity o:listOppInsert){
                    system.debug('o.case__c>>>>'+o.case__c);
                    If(mapNewCaseUnitsByCaseId.containsKey(o.case__c) && recordNewMap.get(o.case__c).type=='Unit Change'){//check for case type if u/D then only enter this block
                        system.debug('mapCaseIdToNewUnitId.containsKey>>>>'+mapNewCaseUnitsByCaseId.containsKey(o.case__c));
                        for(Case_unit__c cu : mapNewCaseUnitsByCaseId.get(o.case__c)){
                            Unit_Plan__c up=new Unit_Plan__c();
                            up.Name='Opportunity Unit -'+o.Name;
                            up.Opportunity__c=o.Id;
                            up.Unit__c=cu.Unit__c;
                            listUnitPlanInsert.add(up);

                            listUnit.add(new Unit__c(Id=cu.Unit__c, Unit_Status__c = 'On Hold'));
                        }
                    }
                    else if(mapCaseIdToCUnit.containskey(o.case__c)&& recordNewMap.get(o.case__c).type=='Renewal'){//check for case type if renewal then only enter this block
                        system.debug('mapCaseIdToCUnit.containskey(o.case__c)>>>>'+mapCaseIdToCUnit.containskey(o.case__c));
                        
                        for(Case_unit__c cu:mapCaseIdToCUnit.get(o.case__c))  {
                            Unit_Plan__c up=new Unit_Plan__c();
                            up.Name='Opportunity Unit -'+o.Name;
                            up.Opportunity__c=o.Id;
                            up.Unit__c=cu.Unit__c;
                            listUnitPlanInsert.add(up);
                        }  
                    }
                    
                }
                if(listUnitPlanInsert.size()>0){
                    system.debug('listUnitPlanInsert.size'+listUnitPlanInsert.size());
                    insert listUnitPlanInsert;
                }
                
                if(!listUnit.isEmpty()){
                    update listUnit;
                }
            }
        }
        
    }
    /**
* @author : Hitesh Saini
* @createdDate : 08-Feb-2022
* @lastModifieddate : 08-Feb-2022
* @purpose : In PMT and U/D SR id Single Lease Unit Account Autopopulate the Case unit
* @usage : invoked in Case TriggerHandler
*/
    Public static void singleUnitAccUpdated(List<Case> newCaseList,Map<Id,Case> recordOldMap){
        Map<Id,Case> mapAccIdToCase=new Map<Id,Case>();
        Id UDRecordType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unit Change').getRecordTypeId();
        Id preMatureTerRecordType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Termination').getRecordTypeId();
        List<Id> listCaseIdCUDelete=new List<Id>();
        List<Case_unit__c>listCaseUnit=new List<Case_unit__c>();
        Id renewalRecordType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        
        
        for(Case c:newCaseList){
            if((c.RecordTypeId==UDRecordType || c.RecordTypeId==preMatureTerRecordType || c.RecordTypeId==renewalRecordType ) && (c.AccountId!=recordOldMap.get(c.Id).AccountId || c.RecordTypeId!=recordOldMap.get(c.Id).RecordTypeId)){
                if(c.AccountId!= null){
                    mapAccIdToCase.put(c.AccountId,c);
                    listCaseIdCUDelete.add(c.id);
                }
                else If(c.AccountId== null){
                    listCaseIdCUDelete.add(c.id);                    
                }
                
            }
        }
        if(listCaseIdCUDelete.size()>0){
            listCaseUnit=[select Id,Name,Unit__c, Case__c from Case_unit__c where Case__c in:listCaseIdCUDelete]; 
            if(listCaseUnit.size()>0){
                delete listCaseUnit;
            }
        }
        if(mapAccIdToCase.size()>0){
            singleUnitAccountAuto(mapAccIdToCase);
        }
        
    }
    /**
* @author : Hitesh Saini
* @createdDate : 08-Feb-2022
* @lastModifieddate : 08-Feb-2022
* @purpose : In PMT and U/D SR after insert Case unit Create
* @usage : invoked in Case TriggerHandler
*/
    //New Case inserted 
    public static void singleUnitAccInsert(List<Case> newCaseList){
        system.debug('>>>Inside singleUnitAccInsert<<<');
        Map<Id,Case> mapAccIdToCase=new Map<Id,Case>();
        Id UDRecordType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unit Change').getRecordTypeId();
        //Id preMatureTerRecordType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Termination').getRecordTypeId();
        Id renewalRecordType= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        
        for(Case c:newCaseList){
            if((c.RecordTypeId==UDRecordType /*|| c.RecordTypeId==preMatureTerRecordType*/ || c.RecordTypeId==renewalRecordType) && c.AccountId!= null && c.Flag_UnitAddedOnCase__c == false){
                mapAccIdToCase.put(c.AccountId,c);
            }
        }
        if(mapAccIdToCase.size()>0){
            singleUnitAccountAuto(mapAccIdToCase);
        }
        
    }
    /**
* @author : Hitesh Saini
* @createdDate : 08-Feb-2022
* @lastModifieddate : 08-Feb-2022
* @purpose : In PMT and U/D SR id Single Lease Unit Account Autopopulate the Case unit
* @usage : invoked in Case TriggerHandler
*/
    public static void singleUnitAccountAuto(Map<Id,Case> mapAccIdToCase){
        
        Map<Id,List<Property__c>> mapAccIdToListProperty=new Map<Id,List<Property__c>>();
        List<Property__c> listProperty=new List<Property__c>();
        List<Case_unit__c> listCaseUnitInsert=new list<Case_unit__c>();
        List<Id> listOppId=new list<Id>();
        List<Opportunity> listOpp=new list<Opportunity>();
        List<Case> listCaseUpdate=new list<Case>();
        Set<ID> setOppId=new Set<ID>();
        Map<ID,Opportunity> mapOppIdToOpp=new Map<ID,Opportunity>();
        
        listProperty=[select Id,Name,Account__c, Unit__c, Status__c, Start_Date__c, End_Date__c, Deal__c, Active__c   from Property__c where Account__c in:mapAccIdToCase.keySet() and Status__c='Leased'and Active__c=true];
        
        if(listProperty.size()>0){
            for(Property__c p:listProperty){
                List<Property__c> tempListProp=new list<Property__c>();
                if(mapAccIdToListProperty.containsKey(p.Account__c)){
                    tempListProp=mapAccIdToListProperty.get(p.Account__c);
                    tempListProp.add(p);
                }
                else{
                    tempListProp.add(p);
                    mapAccIdToListProperty.put(p.Account__c,tempListProp);
                }
                setOppId.add(p.Deal__c);
            }
            if(setOppId.size()>0){
                listOpp=[select id,/*Final_Unit_Price__c,*/Lease_Start_Date__c, Lease_End_Date__c,Base_Lease_Amount__c  from opportunity where id in:setOppId];
                for(Opportunity o:listOpp){
                    mapOppIdToOpp.put(o.Id,o);
                }
            }
            
            if(mapAccIdToListProperty.size()>0){
                
                for(Id i:mapAccIdToListProperty.keySet()){
                    if(mapAccIdToListProperty.get(i).size()==1){
                        Case_unit__c cu=new Case_unit__c();
                        cu.Case__c=mapAccIdToCase.get(i).Id;
                        cu.Unit__c=mapAccIdToListProperty.get(i)[0].Unit__c;
                        listCaseUnitInsert.add(cu);
                        listOppId.add(mapAccIdToListProperty.get(i)[0].Deal__c);
                        Date startdate=mapOppIdToOpp.get(mapAccIdToListProperty.get(i)[0].Deal__c).Lease_Start_Date__c;
                        Date endDate=mapOppIdToOpp.get(mapAccIdToListProperty.get(i)[0].Deal__c).Lease_End_Date__c;
                        if(mapAccIdToCase.get(i).type=='Renewal'){                            
                            listCaseUpdate.add(new Case(id=mapAccIdToCase.get(i).Id,Status='New',Flag_UnitAddedOnCase__c=true,deal__c=mapAccIdToListProperty.get(i)[0].Deal__c,Lease_renewal_date__c=endDate.addDays(1),Lease_Start_Date__c=mapOppIdToOpp.get(mapAccIdToListProperty.get(i)[0].Deal__c).Lease_Start_Date__c,Lease_End_Date__c=mapOppIdToOpp.get(mapAccIdToListProperty.get(i)[0].Deal__c).Lease_End_Date__c,Lease_Amount__c=mapOppIdToOpp.get(mapAccIdToListProperty.get(i)[0].Deal__c).Base_Lease_Amount__c));
                            
                        }
                        else{
                            listCaseUpdate.add(new Case(id=mapAccIdToCase.get(i).Id,Status='In Progress',Flag_UnitAddedOnCase__c=true,deal__c=mapAccIdToListProperty.get(i)[0].Deal__c,Lease_Start_Date__c=mapOppIdToOpp.get(mapAccIdToListProperty.get(i)[0].Deal__c).Lease_Start_Date__c,Lease_End_Date__c=mapOppIdToOpp.get(mapAccIdToListProperty.get(i)[0].Deal__c).Lease_End_Date__c,Lease_Amount__c=mapOppIdToOpp.get(mapAccIdToListProperty.get(i)[0].Deal__c).Base_Lease_Amount__c));
                            
                        }
                        
                    }
                }
                if(listCaseUnitInsert.size()>0){
                    insert listCaseUnitInsert;
                    if(listCaseUpdate.size()>0){
                        update listCaseUpdate;
                    }
                    if(listOppId.size()>0){
                        listOpp=[select id/*,Final_Unit_Price__c*/,Lease_Start_Date__c, Lease_End_Date__c from opportunity where id in:listOppId];
                    }
                }
                
            }
            
        }
        
    }
    
    public static void sendEmail(List<ID> listRecId,String emailTemplateName){
        List<SendMailForEmailAlerts.InvokeSendEmail> requests = new List<SendMailForEmailAlerts.InvokeSendEmail>();
        for(Id recId:listRecId){
            SendMailForEmailAlerts.InvokeSendEmail sendEmailObj = new SendMailForEmailAlerts.InvokeSendEmail();
            sendEmailObj.EmailAlertAPIName = emailTemplateName;
            sendEmailObj.RecordId = recId;
            
            requests.add(sendEmailObj);
        }
        
        SendMailForEmailAlerts.sendEmail(requests);
    }
    
    public static void updateRentalRentOnCase(set<Id> caseIds){
        List<Case> caseList = [SELECT Id, Expected_Termination_Date__c,Termination_Type__c, Deal__r.Lease_Start_Date__c,
                               End_of_Lease_Termination_Reason__c,Deal__r.Lease_End_Date__c, Premature_Termination_Reason__c,
                               Deal__r.Grace_Period_Days__c, Actual_Termination_Date__c, Rental_Refund__c, Refund_Applicable__c
                               FROM Case WHERE Id=: caseIds];
        system.debug('@@@ CaseList :'+caseList);
        if(!caseList.isEmpty()){
            for(Case sr : caseList){
                Date leaseEndDateWithOrWithoutoutGracePeriod = sr.Deal__r.Grace_Period_Days__c != null ? (sr.Deal__r.Lease_End_Date__c).addDays(-Integer.valueOf(sr.Deal__r.Grace_Period_Days__c)): sr.Deal__r.Lease_End_Date__c;
                if(sr.Termination_Type__c == 'Premature Termination'){
                    if(sr.Expected_Termination_Date__c.daysBetween(leaseEndDateWithOrWithoutoutGracePeriod) > 60){
                        sr.Rental_Refund__c = true;
                    }else if(sr.Expected_Termination_Date__c.daysBetween(leaseEndDateWithOrWithoutoutGracePeriod) <= 60){
                        sr.Rental_Refund__c = false;
                        sr.Refund_Applicable__c = 'No';
                    }
                }else if(sr.Termination_Type__c == 'End of Lease Termination' && sr.End_of_Lease_Termination_Reason__c == 'Legal Eviction' && sr.Actual_Termination_Date__c != null){
                    if(sr.Actual_Termination_Date__c.daysBetween(leaseEndDateWithOrWithoutoutGracePeriod) > 60){
                        sr.Rental_Refund__c = true;
                    }else{
                        sr.Rental_Refund__c = false;
                        sr.Refund_Applicable__c = 'No';
                    }
                }else{
                    sr.Rental_Refund__c = false;
                    sr.Refund_Applicable__c = 'No';
                }
                sr.Lease_End_Date_w_o_Grace_days__c = leaseEndDateWithOrWithoutoutGracePeriod;
            }
            system.debug('@@@ CaseList with rental refund:'+caseList);
            update caseList;
        }
    }
    
    public static void calculateTerminatonRefund(set<Id> caseIds){
        Set<Id> dealIds = new Set<Id>();
        if(caseIds.size() > 0){
            List<Case_unit__c> caseUnitList = getCaseUnits(caseIds);
            
            for(Case_unit__c cUnit: caseUnitList){
                dealIds.add(cUnit.Case__r.Deal__c);
            }
            CaseUnitTriggerHandler.upsertRefundsBasedOnCalculations(caseUnitList,dealIds);
            
        }
    }
    
    public static List<Case_Unit__c> getCaseUnits(Set<Id> caseIds){
        List<Case_unit__c> caseUnitList = [SELECT Id,Maintenance_Charges__c,Case__c,Unit__c, Case__r.Actual_Termination_Date__c, Case__r.Expected_Termination_Date__c,
                                           Case__r.Deal__c, Case__r.Deal__r.Lease_Start_Date__c, Case__r.Penalty_charges__c, Case__r.Refund_Applicable__c,
                                           Case__r.Deal__r.Lease_End_Date__c, Case__r.No_of_Mths_Rent_Deduction__c, Case__r.Rental_Refund__c,Case__r.Deal__r.No_Of_Cheques__c
                                           FROM Case_unit__c WHERE Case__c =: caseIds];
        return caseUnitList;
    }
    
    public static void execApprovalforUpgradeandDowngrade(String strCaseId){
        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
        approvalRequest.setComments('Case Unit Upgrade/Downgrade');
        approvalRequest.setObjectId(strCaseId);
        Approval.ProcessResult approvalResult = Approval.process(approvalRequest);
        
        List<SendMailForEmailAlerts.InvokeSendEmail> listInvokeSendEmail = new List<SendMailForEmailAlerts.InvokeSendEmail>();
        SendMailForEmailAlerts.InvokeSendEmail objInvokeSendEmail = new SendMailForEmailAlerts.InvokeSendEmail();
        objInvokeSendEmail.EmailAlertAPIName = ConstantUtility.UNIT_CHANGE_EMAIL_ALERT;
        objInvokeSendEmail.RecordId = Id.valueOf(strCaseId);
        listInvokeSendEmail.add(objInvokeSendEmail);

        if(!listInvokeSendEmail.isEmpty()){
            SendMailForEmailAlerts.sendEmailBulk(listInvokeSendEmail);
        }
    }
}