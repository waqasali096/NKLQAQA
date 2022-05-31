/**
 * Author: Karishma Kotian
 * Date: 
 */
public class CaseUnitTriggerHandler {
    List<Case_unit__c> newList = new List<Case_unit__c>();
    List<Case_unit__c> oldList = new List<Case_unit__c>();
    Map<Id, Case_unit__c> newMap = new Map<Id, Case_unit__c>();
    Map<Id, Case_unit__c> oldMap = new Map<Id, Case_unit__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;

    public CaseUnitTriggerHandler(List<Case_unit__c> newList, List<Case_unit__c> oldList, Map<Id, Case_unit__c> newMap, Map<Id, Case_unit__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.newList = newList;
        this.oldList = oldList;
        this.newMap = newMap;
        this.oldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent(){}
    
    public void AfterInsertEvent(){}
    
    public void BeforeUpdateEvent(){}
    
    public void AfterUpdateEvent(){
        refundCalculations(newList, oldMap);
    }
    
    public void BeforeDeleteEvent(){}
    
    public void AfterUndeleteEvent(){}
    
    public void AfterDeleteEvent(){}

    public static void refundCalculations(List<Case_unit__c> newList, Map<Id,Case_unit__c> oldMap){
        System.debug('new List :'+newList);
        Set<Id> caseUnitIds = new set<Id>();
        Set<Id> dealIds = new set<Id>();
        for(Case_unit__c caseUnit : newList){
            if(caseUnit.Maintenance_Charges__c != null && caseUnit.Maintenance_Charges__c != oldMap.get(caseUnit.Id).Maintenance_Charges__c){
                caseUnitIds.add(caseUnit.Id);
            }
        }
        if(caseUnitIds.size() > 0){
        List<Case_unit__c> caseUnitList = getCaseUnits(caseUnitIds);

        for(Case_unit__c cUnit: caseUnitList){
            dealIds.add(cUnit.Case__r.Deal__c);
        }
        upsertRefundsBasedOnCalculations(caseUnitList,dealIds);
        
        }
    }

    public static void upsertRefundsBasedOnCalculations(List<Case_unit__c> caseUnitList,Set<Id> dealIds){
        Map<String,Double> baseLeaseAmountOfUnit = new Map<String,Double>();
        Map<String,Double> finalLeaseAmountOfUnit = new Map<String,Double>();
        Map<String,Double> securityDepositInstallmentPerUnit = new Map<String,Double>();
        Map<String,Double> rentAmountInstallmentPerUnit = new Map<String,Double>();
        Map<String,Double> totalIntstallmentValuePerUnit = new Map<String,Double>();
        Set<Id> installmentIds = new Set<Id>();
        List<Refund__c> refunds = new List<Refund__c>();
        Map<String,Boolean> securityDepositReceived = new Map<String,Boolean>();
        Set<Id> masterDealIds = new Set<Id>();
        List<Opportunity> masterOppties = new List<Opportunity>();

        if(dealIds.size()> 0){
            List<Opportunity> oppties = getDeals(dealIds);
            for(Opportunity opportunity : oppties){
                if(opportunity.Master_Opportunity__c != null){
                    masterDealIds.add(opportunity.Master_Opportunity__c);
                }
            }
            if(masterDealIds.size() > 0){
                masterOppties = getMasterDeals(masterDealIds);
                for(Opportunity masterOppty : masterOppties){
                    if(masterOppty.Payment_Milestones__r.size() > 0){
                        for(Payment_Milestone__c installment : masterOppty.Payment_Milestones__r){
                            if(installment.Is_Reciept_Created__c){
                                installmentIds.add(installment.Id);
                                if(installment.Installment__c == 'SEC'){
                                    securityDepositInstallmentPerUnit.put(installment.Unit_Plan__r.Unit__c,installment.Total_Amount__c);
                                    totalIntstallmentValuePerUnit.put(installment.Unit_Plan__r.Unit__c,installment.Total_Amount__c);
                                }
                            }
                        }
                    }
                }
            }
        for(Opportunity oppty : oppties ){
            if(oppty.Unit_Plans__r.Size() > 0){
                for(Unit_Plan__c opptyUnit : oppty.Unit_Plans__r){
                    if(opptyUnit.Base_Lease_Amount__c != null)
                        baseLeaseAmountOfUnit.put(opptyUnit.Unit__c,opptyUnit.Base_Lease_Amount__c);
                    if(opptyUnit.Final_Lease_Amount__c != null)
                        finalLeaseAmountOfUnit.put(opptyUnit.Unit__c,opptyUnit.Final_Lease_Amount__c);
                }
            }
            if(oppty.Payment_Milestones__r.size()>0){
                for(Payment_Milestone__c installment : oppty.Payment_Milestones__r){
                    if(installment.Is_Reciept_Created__c){
                        installmentIds.add(installment.Id);
                        if(totalIntstallmentValuePerUnit.containsKey(installment.Unit_Plan__r.Unit__c)){
                            totalIntstallmentValuePerUnit.put(installment.Unit_Plan__r.Unit__c,totalIntstallmentValuePerUnit.get(installment.Unit_Plan__r.Unit__c)+installment.Total_Amount__c);
                        }else{
                            totalIntstallmentValuePerUnit.put(installment.Unit_Plan__r.Unit__c,installment.Total_Amount__c);
                        }
                        if(installment.Installment__c == 'SEC'){
                            securityDepositInstallmentPerUnit.put(installment.Unit_Plan__r.Unit__c,installment.Total_Amount__c);
                        }else{
                            if(rentAmountInstallmentPerUnit.containsKey(installment.Unit_Plan__r.Unit__c)){
                                rentAmountInstallmentPerUnit.put(installment.Unit_Plan__r.Unit__c,rentAmountInstallmentPerUnit.get(installment.Unit_Plan__r.Unit__c)+installment.Total_Amount__c);
                            }else{
                                rentAmountInstallmentPerUnit.put(installment.Unit_Plan__r.Unit__c,installment.Total_Amount__c);
                            }
                            
                        }
                    }
                }
            }
        }

        Map<Id,List<ReceiptWrapper>> unitsWithReceipts = fetchReceiptsForUnits(installmentIds);
        system.debug('@@@unitsWithReceipts :'+unitsWithReceipts);
        Map<Id,Double> securityDepositPerUnit = fetchSecurityDeposit(unitsWithReceipts);
        system.debug('@@@securityDepositPerUnit :'+securityDepositPerUnit);
        Map<Id,Double> amountRealizedPerUnit = fetchTotalAmountRealized(unitsWithReceipts);
        system.debug('@@@amountRealizedPerUnit :'+amountRealizedPerUnit);
        Map<Id,Double> holdingDepositPerUnit = fetchHoldingDeposit(unitsWithReceipts,oppties);
        system.debug('@@@holdingDepositPerUnit :'+holdingDepositPerUnit);

            for(Case_unit__c caseUnit: caseUnitList){
                Refund__c refund = new Refund__c();
                refund.Case_unit__c = caseUnit.Id;
                refund.Service_Request__c = caseUnit.Case__c;
                refund.Deal__c = caseUnit.Case__r.Deal__c;
                refund.Base_Lease_Amount__c = baseLeaseAmountOfUnit.containsKey(caseUnit.Unit__c) ? baseLeaseAmountOfUnit.get(caseUnit.Unit__c) : 0;
                refund.Final_Lease_Amount__c = finalLeaseAmountOfUnit.containsKey(caseUnit.Unit__c) ? finalLeaseAmountOfUnit.get(caseUnit.Unit__c) : 0;
                refund.Expected_Termination_Date__c = caseUnit.Case__r.Expected_Termination_Date__c;
                refund.Lease_Start_Date__c = caseUnit.Case__r.Deal__r.Lease_Start_Date__c;
                refund.Lease_End_Date__c = caseUnit.Case__r.Deal__r.Lease_End_Date__c;
                if(caseUnit.Case__r.Penalty_charges__c != null && caseUnit.Case__r.No_of_Mths_Rent_Deduction__c != null){
                    refund.Penalty_for_Early_Termination__c = caseUnit.Case__r.Penalty_charges__c + (30 * caseUnit.Case__r.No_of_Mths_Rent_Deduction__c * (refund.Base_Lease_Amount__c/365));
                }else if(caseUnit.Case__r.Penalty_charges__c == null && caseUnit.Case__r.No_of_Mths_Rent_Deduction__c != null){
                    refund.Penalty_for_Early_Termination__c = 30 * caseUnit.Case__r.No_of_Mths_Rent_Deduction__c * (refund.Base_Lease_Amount__c/365);
                }else if(caseUnit.Case__r.Penalty_charges__c != null && caseUnit.Case__r.No_of_Mths_Rent_Deduction__c == null){
                    refund.Penalty_for_Early_Termination__c = caseUnit.Case__r.Penalty_charges__c;
                }
                refund.Actual_Termination_Date__c = caseUnit.Case__r.Actual_Termination_Date__c;
                if(securityDepositPerUnit.containsKey(caseUnit.Unit__c)){
                    if(securityDepositInstallmentPerUnit.containsKey(caseUnit.Unit__c)){
                        if(securityDepositPerUnit.get(caseUnit.Unit__c) >= securityDepositInstallmentPerUnit.get(caseUnit.Unit__c)){
                            refund.Security_Deposit_Refund__c = securityDepositInstallmentPerUnit.get(caseUnit.Unit__c);
                        }else{
                            refund.Security_Deposit_Refund__c = 0;
                        }
                    }
                }
                refund.Security_Deposit_Installment_Amount__c = securityDepositInstallmentPerUnit.containsKey(caseUnit.Unit__c) ? securityDepositInstallmentPerUnit.get(caseUnit.Unit__c) : 0;
                //refund.Total_Amount_Realized__c = amountRealizedPerUnit.containsKey(caseUnit.Unit__c) ? amountRealizedPerUnit.get(caseUnit.Unit__c) : 0;
                if(amountRealizedPerUnit.containsKey(caseUnit.Unit__c)){
                    if(caseUnit.Case__r.Deal__r.Master_Opportunity__c != null){
                        refund.Total_Amount_Realized__c = securityDepositPerUnit.containsKey(caseUnit.Unit__c) ? (amountRealizedPerUnit.get(caseUnit.Unit__c) - securityDepositPerUnit.get(caseUnit.Unit__c) + refund.Security_Deposit_Refund__c): amountRealizedPerUnit.get(caseUnit.Unit__c);
                    }else{
                        if(totalIntstallmentValuePerUnit.containsKey(caseUnit.Unit__c)){
                        	if(amountRealizedPerUnit.get(caseUnit.Unit__c) >= totalIntstallmentValuePerUnit.get(caseUnit.Unit__c)){
                            	refund.Total_Amount_Realized__c = totalIntstallmentValuePerUnit.get(caseUnit.Unit__c);
                        	}else{
                            	refund.Total_Amount_Realized__c = amountRealizedPerUnit.get(caseUnit.Unit__c);
                        	}
                    	}
                    }
                }else{
                    refund.Total_Amount_Realized__c = 0;
                }
                if(holdingDepositPerUnit.containsKey(caseUnit.Unit__c)){
                    refund.Total_Amount_Realized__c = refund.Total_Amount_Realized__c + holdingDepositPerUnit.get(caseUnit.Unit__c);
                }
                refund.Rental_Installment_Value__c = rentAmountInstallmentPerUnit.containsKey(caseUnit.Unit__c)? rentAmountInstallmentPerUnit.get(caseUnit.Unit__c):0;
                refund.Cheques__c  = caseUnit.Case__r.Deal__r.No_Of_Cheques__c != null ? Integer.ValueOf(caseUnit.Case__r.Deal__r.No_Of_Cheques__c) : 0;
                refund.External_Id__c = caseUnit.Id+'_'+caseUnit.Case__c;
                refund.Maintenance_Charges__c = caseUnit.Maintenance_Charges__c;
                refund.Refund_Applicable__c = caseUnit.Case__r.Refund_Applicable__c;
                refunds.add(refund);
            }
            system.debug('@@@refunds :'+refunds);
            if(!refunds.isEmpty()){
                upsert refunds External_Id__c;
            }
            
        }
    }
    public static Map<Id,List<ReceiptWrapper>> fetchReceiptsForUnits(Set<Id> installmentIds){
        system.debug('@@@InstallmentIds :'+installmentIds);
        Map<Id,List<ReceiptWrapper>> UnitsWithListOfReceiptWraps =  new Map<Id,List<ReceiptWrapper>>();
            List<Receipt_Milestone__c> receiptMilestones = [SELECT Id,Receipt__c,Installments__c, Receipt__r.Received_for__c,
                                                            Receipt__r.Amount__c, Receipt__r.Payment_Mode__c, Receipt__r.Payment_Status__c,
                                                            Installments__r.Unit_Plan__r.Unit__c, Receipt__r.ReceivedForMapping__c
                                                            FROM Receipt_Milestone__c
                                                            WHERE Installments__c =: installmentIds];
            system.debug('@@@receiptMilestones :'+receiptMilestones);
            for(Receipt_Milestone__c receiptMilestone : receiptMilestones){
                ReceiptWrapper receiptWrap = new ReceiptWrapper();
                receiptWrap.Amount = receiptMilestone.Receipt__r.Amount__c;
                receiptWrap.paymentMode = receiptMilestone.Receipt__r.Payment_Mode__c;
                receiptWrap.paymentStatus = receiptMilestone.Receipt__r.Payment_Status__c;
                receiptWrap.receivedFor = receiptMilestone.Receipt__r.ReceivedForMapping__c; //receiptMilestone.Receipt__r.Received_for__c;
                if(UnitsWithListOfReceiptWraps.containsKey(receiptMilestone.Installments__r.Unit_Plan__r.Unit__c)){
                    UnitsWithListOfReceiptWraps.get(receiptMilestone.Installments__r.Unit_Plan__r.Unit__c).add(receiptWrap);
                }else{
                    UnitsWithListOfReceiptWraps.put(receiptMilestone.Installments__r.Unit_Plan__r.Unit__c,new List<ReceiptWrapper>{receiptWrap});
                }
            }
            system.debug('@@@UnitsWithListOfReceiptWraps'+UnitsWithListOfReceiptWraps);
        return UnitsWithListOfReceiptWraps;
    }

    public static Map<Id,Double> fetchSecurityDeposit(Map<Id,List<ReceiptWrapper>> UnitsWithReceipts){
        Map<Id,Double> SecurityDepositAmount = new Map<Id,Double>();
        Set<String> paymentStatus = new Set<String>{'Paid','Cleared'}; ///,'Confirmed'}; 

        if(!UnitsWithReceipts.isEmpty()){
            for(Id key : UnitsWithReceipts.keySet()){
                for(ReceiptWrapper receiptWrap : UnitsWithReceipts.get(key)){
                   // if(receiptWrap.receivedFor.contains('SEC') && receiptWrap.paymentMode == 'Cheque'){
                        //SecurityDepositAmount.put(key, receiptWrap.Amount);
                   /* }else */if(receiptWrap.receivedFor.contains('SEC') /*&& receiptWrap.paymentMode != 'Cheque'*/ && paymentStatus.contains(receiptWrap.paymentStatus)){
                        SecurityDepositAmount.put(key, receiptWrap.Amount);
                    }
                }
            }
        }
        return SecurityDepositAmount;
    }

    public static Map<Id,Double> fetchTotalAmountRealized(Map<Id,List<ReceiptWrapper>> UnitsWithReceipts){
        Map<Id,Double> totalAmountRealized = new Map<Id,Double>();
        Set<String> paymentStatus = new Set<String>{'Paid','Cleared'};//,'Confirmed'}; 
        if(!UnitsWithReceipts.isEmpty()){
            for(Id key : UnitsWithReceipts.keySet()){
                for(ReceiptWrapper receiptWrap : UnitsWithReceipts.get(key)){
                    /*if(receiptWrap.paymentMode == 'Cheque'){
                        if(totalAmountRealized.containsKey(key)){
                            totalAmountRealized.put(key, totalAmountRealized.get(key) + receiptWrap.Amount);
                        }else{
                            totalAmountRealized.put(key, receiptWrap.Amount);
                        }
                    }else*/ if(/*receiptWrap.paymentMode != 'Cheque' &&*/ paymentStatus.contains(receiptWrap.paymentStatus)){
                        if(totalAmountRealized.containsKey(key)){
                            totalAmountRealized.put(key, totalAmountRealized.get(key) + receiptWrap.Amount);
                        }else{
                            totalAmountRealized.put(key, receiptWrap.Amount);
                        }
                    }
                }
            }
        }
        return totalAmountRealized;
    }

    public static Map<Id,Double> fetchHoldingDeposit(Map<Id,List<ReceiptWrapper>> UnitsWithReceipts, List<Opportunity> oppties){
        Map<Id,Double> holdingDepositPerUnit = new Map<Id,Double>();
        Set<String> paymentStatus = new Set<String>{'Paid','Cleared'};//,'Confirmed'}; 
        Set<Id> unitIds = new Set<Id>();
        for(Opportunity oppty : oppties){
            if(oppty.Booking_Fee_gets_collected__c && oppty.Booking_Mode__c == 'Reservation with token amount' && oppty.Booking_Amount__c != null){
                for(Unit_Plan__c opptyUnits : oppty.Unit_Plans__r){
                    if(opptyUnits.Unit__r.Holding_Deposit_Amount__c != null){
                        holdingDepositPerUnit.put(opptyUnits.Unit__c, opptyUnits.Unit__r.Holding_Deposit_Amount__c);
                    }
                }
            }
        }
        return holdingDepositPerUnit;
    }

    public static List<Opportunity> getDeals(Set<Id> dealIds){
        List<Opportunity> oppties = [SELECT Id,Booking_Amount__c,Booking_Fee_gets_collected__c,Booking_Mode__c, Master_Opportunity__c,
                                            Security_Deposit_Recevied__c,(SELECT Id, Base_Lease_Amount__c,Final_Lease_Amount__c,
                                                Opportunity__c,Unit__c,Unit__r.Holding_Deposit_Amount__c FROM Unit_Plans__r),
                                            (SELECT Id, Name, Opportunity__c, Unit__c,Amount__c,Total_Amount__c,Is_Reciept_Created__c,
                                            Unit_Plan__c,	Unit_Plan__r.Unit__c, Installment__c FROM Payment_Milestones__r ) 
                                            FROM Opportunity WHERE Id=: dealIds];
                                            return oppties;
    }

    public static List<Case_Unit__c> getCaseUnits(Set<Id> caseUnitIds){
        List<Case_unit__c> caseUnitList = [SELECT Id,Maintenance_Charges__c,Case__c,Unit__c, Case__r.Actual_Termination_Date__c, Case__r.Expected_Termination_Date__c,
                                            Case__r.Deal__c, Case__r.Deal__r.Lease_Start_Date__c, Case__r.Penalty_charges__c, Case__r.Refund_Applicable__c,Case__r.Deal__r.Master_Opportunity__c,
                                            Case__r.Deal__r.Lease_End_Date__c, Case__r.No_of_Mths_Rent_Deduction__c, Case__r.Rental_Refund__c, Case__r.Deal__r.No_Of_Cheques__c
                                            FROM Case_unit__c WHERE Id=: caseUnitIds];
                                            return caseUnitList;
    }

    public static List<Opportunity> getMasterDeals(Set<Id> masterDealIds){
        List<Opportunity> oppties = [SELECT Id,Booking_Amount__c,Booking_Fee_gets_collected__c,Booking_Mode__c, Master_Opportunity__c,
                                            Security_Deposit_Recevied__c,(SELECT Id, Base_Lease_Amount__c,Final_Lease_Amount__c,
                                            Opportunity__c,Unit__c,Unit__r.Holding_Deposit_Amount__c FROM Unit_Plans__r),
                                            (SELECT Id, Name, Opportunity__c, Unit__c,Amount__c,Total_Amount__c,Is_Reciept_Created__c,
                                            Unit_Plan__c,Unit_Plan__r.Unit__c, Installment__c FROM Payment_Milestones__r WHERE Installment__c = 'SEC') 
                                            FROM Opportunity WHERE Id=: masterDealIds];
                                            return oppties;
    }

    public class ReceiptWrapper{
        public String receivedFor {get;set;}
        public Double Amount {get;set;}
        public String paymentMode {get;set;}
        public String paymentStatus {get;set;}
        public String installmentId {get;set;}
        public String receiptId {get;set;}
    }
}