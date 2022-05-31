/*
Class Name:                 RefundTriggerHandler
Class Description:          To manage the refund level trigger automations. this handler will be called from RefundTrigger
Author:                     Taha Hamid
Created Date:               27/04/2022
Updated by:
Last Update Date:
*/

public class RefundTriggerHandler {
    List<Refund__c> recordNewList = new List<Refund__c>();
    List<Refund__c> recordOldList = new List<Refund__c>();
    Map<Id, Refund__c> recordNewMap = new Map<Id, Refund__c>();
    Map<Id, Refund__c> recordOldMap = new Map<Id, Refund__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public RefundTriggerHandler(List<Refund__c> newList, List<Refund__c> oldList, Map<Id, Refund__c> newMap, Map<Id, Refund__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
        initiateRefundTransactions();   
    }
    public void AfterUpdateEvent() {
        initiateRefundTransactions();
        triggerAPICalls();
    }
    public void AfterDeleteEvent() {
    }

    public void AfterUndeleteEvent() {
    }
    
    public void triggerAPICalls(){
        set<Id> receiptReversalRefundId = new set<Id>();
        set<Id> receiptRefund_RefundId = new set<Id>();
        set<Id> invoiceCreationRefundId = new set<Id>();
        set<Id> creditMemoRefundId = new set<Id>();
        system.debug('test :');
        for(Refund__c refund : recordNewList){
            if(!refund.Trigger_Receipt_Reversal__c && refund.Trigger_Receipt_Reversal__c != recordOldMap.get(refund.Id).Trigger_Receipt_Reversal__c){
                receiptReversalRefundId.add(refund.Id);
            }
            if(!refund.Trigger_Credit_Memo_Creation__c && refund.Trigger_Credit_Memo_Creation__c != recordOldMap.get(refund.Id).Trigger_Credit_Memo_Creation__c){
                creditMemoRefundId.add(refund.Id);
            }
            if(!refund.Trigger_Invoice_Creation__c && refund.Trigger_Invoice_Creation__c != recordOldMap.get(refund.Id).Trigger_Invoice_Creation__c){
                invoiceCreationRefundId.add(refund.Id);
            }
            if(!refund.Trigger_Receipt_Refund_Creation__c && refund.Trigger_Receipt_Refund_Creation__c != recordOldMap.get(refund.Id).Trigger_Receipt_Refund_Creation__c){
                receiptRefund_RefundId.add(refund.Id);
            }
        }
        
        if(receiptReversalRefundId.size() >0){
            List<Refund__c> refundL = fetchRefundRecords(receiptReversalRefundId);
            List<Payment_Milestone__c> installments = processRefundDetails(refundL);
            boolean receiptReversalTrigger = sendReceiptsForReversal(installments);
            if(receiptReversalTrigger) updateRefundTriggerChecks(true,false,false,false,refundL);
        }
        if(receiptRefund_RefundId.size() >0){
            List<Refund__c> refundL = fetchRefundRecords(receiptRefund_RefundId);
            system.debug('test :'+refundL);
            boolean createRefundTrigger = createRefunds(refundL);
            system.debug('test :'+createRefundTrigger);
            if(createRefundTrigger) updateRefundTriggerChecks(false,false,true,false,refundL);
        }
        if(invoiceCreationRefundId.size() >0){
            set<String> erpBusinessIds = new set<String>();
            List<Refund__c> refundL = fetchRefundRecords(invoiceCreationRefundId);
            for(Refund__c refund : refundL){
                erpBusinessIds.add(refund.Case_Unit__r.Unit__r.ERP_Business_Unit_Id__c);
            }
            List<Transaction_Type__c> transactionList = fetchTransactionTypeBasedOnBusinessId(erpBusinessIds);
            boolean createInvoiceTrigger = createInvoice(refundL,transactionList);
            if(createInvoiceTrigger) updateRefundTriggerChecks(false,true,false,false,refundL);
        }
        if(creditMemoRefundId.size() >0){
            set<String> erpBusinessIds = new set<String>();
            List<Refund__c> refundL = fetchRefundRecords(creditMemoRefundId);
            for(Refund__c refund : refundL){
                erpBusinessIds.add(refund.Case_Unit__r.Unit__r.ERP_Business_Unit_Id__c);
            }
            List<Transaction_Type__c> transactionList = fetchTransactionTypeBasedOnBusinessId(erpBusinessIds);
            boolean createRefundTrigger = createCreditMemo(refundL,transactionList);
            if(createRefundTrigger) updateRefundTriggerChecks(false,false,false,true,refundL);
        }
    }

    public void updateRefundTriggerChecks(Boolean receiptReversalTrigger,Boolean createInvoiceTrigger, Boolean createRefundTrigger, Boolean createCreditMemoTrigger, List<Refund__c> refundL ){
         List<Refund__c> refundList = new List<Refund__c>();
        if(receiptReversalTrigger || createInvoiceTrigger || createRefundTrigger || createCreditMemoTrigger){
                for(Refund__c refund : refundL){
                    Refund__c temp = new Refund__c();
                    temp.Id = refund.Id;
                    if(receiptReversalTrigger) temp.Trigger_Receipt_Reversal__c = receiptReversalTrigger;
                    if(createInvoiceTrigger) temp.Trigger_Invoice_Creation__c  = createInvoiceTrigger;
                    if(createRefundTrigger) temp.Trigger_Receipt_Refund_Creation__c	 = createRefundTrigger;
                    if(createCreditMemoTrigger) temp.Trigger_Credit_Memo_Creation__c  = createCreditMemoTrigger;
                    refundList.add(temp);
                }
            }
        if(!refundList.isEmpty()){
            update refundList;
        }
    }
    
    // Created By: Karishma Kotian
    // Method to be used for rent receipt reversal, to fetch the respective receipts and reverse
    public void initiateRefundTransactions(){
        system.debug('New List :'+recordNewList);
        Set<Refund__c> refunds = new Set<Refund__c>();
        List<Refund__c> refundList = new List<Refund__c>();
        set<Id> refundIds = new set<Id>();
        set<String> erpBusinessIds = new set<String>();
        boolean createInvoiceTrigger,createRefundTrigger, createCreditMemoTrigger,receiptReversalTrigger = false;
        for(Refund__c refund : recordNewList){
            if(refund.Actual_Termination_Date__c != null && refund.Maintenance_Charges__c != null 
               && (!refund.Trigger_Receipt_Reversal__c && !refund.Trigger_Credit_Memo_Creation__c 
                   && !refund.Trigger_Invoice_Creation__c && !refund.Trigger_Receipt_Refund_Creation__c)){
                refunds.add(refund);
            }
        }
        if(refunds.size() >0){
            for(Refund__c refund : refunds){
                refundIds.add(refund.Id);
            }
            List<Refund__c> refundL = fetchRefundRecords(refundIds);
            for(Refund__c refund : refundL){
                erpBusinessIds.add(refund.Case_Unit__r.Unit__r.ERP_Business_Unit_Id__c);
            }
            List<Transaction_Type__c> transactionList = fetchTransactionTypeBasedOnBusinessId(erpBusinessIds);
              createInvoiceTrigger = createInvoice(refundL,transactionList); // called method will create Invoice__c records
              createRefundTrigger = createRefunds(refundL);  // called method will create Receipt Refund records
              createCreditMemoTrigger = createCreditMemo(refundL,transactionList); // called method will create Credit_Memo__c records
            
            
            List<Payment_Milestone__c> installments = processRefundDetails(refundL);
            receiptReversalTrigger = sendReceiptsForReversal(installments);
            system.debug('@@flags :'+receiptReversalTrigger+ 'invoice :'+createInvoiceTrigger+ 'CM :'+createCreditMemoTrigger+'refund: '+createRefundTrigger);
            
            if(receiptReversalTrigger || createInvoiceTrigger || createRefundTrigger || createCreditMemoTrigger){
                for(Refund__c refund : refundL){
                    Refund__c temp = new Refund__c();
                    temp.Id = refund.Id;
                    temp.Trigger_Receipt_Reversal__c = receiptReversalTrigger;
                    temp.Trigger_Invoice_Creation__c  = createInvoiceTrigger;
                    temp.Trigger_Receipt_Refund_Creation__c	 = createRefundTrigger;
                    temp.Trigger_Credit_Memo_Creation__c  = createCreditMemoTrigger;
                    refundList.add(temp);
                }
            }
        }
        if(!refundList.isEmpty()){
            update refundList;
        }
    }

    public List<Payment_Milestone__c> processRefundDetails(List<Refund__c> refunds){
        system.debug('refunds :'+refunds);
        set<Id> opptyIds = new set<Id>();
        set<Id> unitIds = new set<Id>();
        set<Id> refundIds = new set<Id>();
        set<Id> masterOpptyIds = new set<Id>();

        boolean flag = false;
        List<Payment_Milestone__c> installments = new List<Payment_Milestone__c>();
        List<Payment_Milestone__c> masterInstallments = new List<Payment_Milestone__c>();
        try{
            for(Refund__c ref : refunds){
                unitIds.add(ref.Case_Unit__r.Unit__c);
                opptyIds.add(ref.Service_Request__r.Deal__c);
                if(ref.Deal__r.Master_Opportunity__c != null){
                    masterOpptyIds.add(ref.Deal__r.Master_Opportunity__c);
                }
            }
            installments = getInstallmentDetails(opptyIds,unitIds);
            if(masterOpptyIds.size()>0){
                masterInstallments = getInstallmentsFromMaster(masterOpptyIds,unitIds);
                installments.addAll(masterInstallments);
            }
            return installments;
        }catch(Exception ex){
            system.debug('ex message:'+ex.getMessage()+'Line number :'+ex.getLineNumber());
            return null;
        }
    }

    public boolean sendReceiptsForReversal(List<Payment_Milestone__c> installments){
        boolean flag = false;
        Set<Id> receiptIdsForSecurityDeposit = new Set<Id>();
        Set<Id> receiptIdsForRent = new Set<Id>();
        List<Receipt__c> allReceipts = new List<Receipt__c>();
        try{
            for(Payment_Milestone__c installment : installments){
                if(installment.Name == 'Security Deposit' && installment.Receipt_Milestones__r.size() > 0){
                    for(Receipt_Milestone__c receiptMilestone : installment.Receipt_Milestones__r){
                        receiptIdsForSecurityDeposit.add(receiptMilestone.Receipt__c);
                    }
                }else if(installment.Name != 'Security Deposit' && installment.Receipt_Milestones__r.size() > 0){
                    for(Receipt_Milestone__c receiptMilestone : installment.Receipt_Milestones__r){
                        receiptIdsForRent.add(receiptMilestone.Receipt__c);
                    }
                }
            }
            if(receiptIdsForSecurityDeposit.size()>0){
                List<Receipt__c> securityDepositReceipts = getReceipts(receiptIdsForSecurityDeposit, 'securityDepositReceipts');
                if(!securityDepositReceipts.isEmpty()){
                    for(Receipt__c receipt : securityDepositReceipts){
                            receipt.Send_Receipt_Reversal_ERP__c = true;
                            allReceipts.add(receipt);
                    }
                }
            }
            if(receiptIdsForRent.size()>0){
                List<Receipt__c> rentReceipts = getReceipts(receiptIdsForRent, 'pendingReceipts');
                if(!rentReceipts.isEmpty()){
                    for(Receipt__c receipt : rentReceipts){
                            receipt.Send_Receipt_Reversal_ERP__c = true;
                            allReceipts.add(receipt);
                    }
                }
            }
            system.debug('@@allReceipts :'+allReceipts);
            if(!allReceipts.isEmpty()){
                update allReceipts;
            }
            flag = true;
            return flag;
        }catch(Exception ex){
            system.debug('ex message:'+ex.getMessage()+'Line number :'+ex.getLineNumber());
            flag = false;
            return flag;
        }
    }

    public List<Case> getCaseDetails(Set<Id> Ids){
        List<Case> caseList = [SELECT Id, Deal__c, (SELECT Id, Case__c, Unit__c,
                                Type__c,Maintenance_Charges__c FROM Case_units__r)  
                                FROM Case WHERE Id=: Ids];
        return caseList;
    }

    public List<Payment_Milestone__c> getInstallmentDetails(Set<Id> opptyIds, Set<Id> unitIds){
        
        List<Payment_Milestone__c> installments = new List<Payment_Milestone__c>();
            installments = [SELECT Id,Name, (SELECT Id, Installments__c,
                            Receipt__c FROM Receipt_Milestones__r)
                            FROM Payment_Milestone__c WHERE Opportunity__c=: opptyIds AND Unit_Plan__r.Unit__c =: unitIds];
        
        return installments;
    }

    public List<Payment_Milestone__c> getInstallmentsFromMaster(Set<Id> opptyIds, Set<Id> unitIds){
        
        List<Payment_Milestone__c> installments = new List<Payment_Milestone__c>();
            installments = [SELECT Id,Name,Installment__c, (SELECT Id, Installments__c,
                            Receipt__c FROM Receipt_Milestones__r)
                            FROM Payment_Milestone__c WHERE Opportunity__c=: opptyIds 
                            AND Unit_Plan__r.Unit__c =: unitIds AND Installment__c = 'SEC'];
        
        return installments;
    }

    public List<Receipt__c> getReceipts(Set<Id> receiptIds, String receiptCheck){

        List<Receipt__c> receipts = new list<Receipt__c>();

        if(receiptCheck == 'securityDepositReceipts')
        {
            receipts = [SELECT Id, Payment_Mode__c, Payment_Status__c, Received_For__c, 
                                        ReceivedForMapping__c, Amount__c, Cheque_No__c, Send_Receipt_Reversal_ERP__c
                                        FROM Receipt__c WHERE Id=:receiptIds AND Payment_Status__c IN ('Paid','Cleared')];
        }

        else if(receiptCheck == 'pendingReceipts')
        {
            receipts = [SELECT Id, Payment_Mode__c, Payment_Status__c, Received_For__c, 
                                        ReceivedForMapping__c, Amount__c, Cheque_No__c, Send_Receipt_Reversal_ERP__c
                                        FROM Receipt__c WHERE Id=:receiptIds AND Payment_Status__c IN ('Pending','On Hold')];
        }
        return receipts;
    }
    /*
    Method Description: below mthod will take list of refund records as a parameter
    and create the recoords of invoice
    */
    public static boolean createInvoice(List<Refund__c> lstRefund, List<Transaction_Type__c> transactionList){
        boolean flag = false;
        List<Invoice__c> lstInvoice = new List<Invoice__c>();
        Invoice__c invoice; 
        try{
            for(Refund__c refund:lstRefund){
                if(refund.Maintenance_Charges__c > 0){
                    invoice = new Invoice__c();
                	invoice.Opportunity__c =  refund.Service_Request__r.Deal__c;
                	invoice.Invoice_Type__c = 'Adhoc'; 
                	invoice.Payment_Date__c = Date.today();
                	invoice.Service_Request__c = refund.Service_Request__c;
                	invoice.Invoice_Status__c = 'Pending';
                	invoice.Payment_Status__c = 'Pending';
                	invoice.Send_Invoice_to_ERP__c = True;
                	invoice.Amount__c = refund.Maintenance_Charges__c+refund.VAT_on_Maintenance_Charges__c;
                	for(Transaction_Type__c transactionType : transactionList){
                    	if(transactionType.Transaction_Category__c == 'TRANSACTION_TYPE' && transactionType.Transaction_Type_Code__c == 'INVOICE'
                        	&& transactionType.ERP_BU_ID__c == refund.Case_Unit__r.Unit__r.ERP_Business_Unit_Id__c){
                        	invoice.Transaction_Type__c = transactionType.Id;
                       	 	break;
                    	}
                	}
                	invoice.Unit__c = refund.Case_Unit__r.Unit__c;
                	invoice.Description__c = 'Invoice for Maintenance charges';
                	lstInvoice.add(invoice);
                }
                if(refund.Penalty_for_Early_Termination__c > 0){
                    invoice = new Invoice__c();
                	invoice.Opportunity__c =  refund.Service_Request__r.Deal__c;
                	invoice.Invoice_Type__c = 'Adhoc'; 
                	invoice.Payment_Date__c = Date.today();
                	invoice.Service_Request__c = refund.Service_Request__c;
                	invoice.Invoice_Status__c = 'Pending';
                	invoice.Payment_Status__c = 'Pending';
                	invoice.Send_Invoice_to_ERP__c = True;
                	invoice.Amount__c = refund.Penalty_for_Early_Termination__c;
                	for(Transaction_Type__c transactionType : transactionList){
                    	if(transactionType.Transaction_Category__c == 'TRANSACTION_TYPE' && transactionType.Transaction_Type_Code__c == 'INVOICE'
                        	&& transactionType.ERP_BU_ID__c == refund.Case_Unit__r.Unit__r.ERP_Business_Unit_Id__c){
                        	invoice.Transaction_Type__c = transactionType.Id;
                        	break;
                    	}
                	}
                	invoice.Unit__c = refund.Case_Unit__r.Unit__c;
                	invoice.Description__c = 'Invoice for early termination';
                	lstInvoice.add(invoice);
                }
            }
            if(lstInvoice.size()>0)
                insert lstInvoice;
        	flag = true;
            return flag;
        }catch(Exception ex){
            system.debug('ex message:'+ex.getMessage()+'Line number :'+ex.getLineNumber());
            flag = false;
            return flag;
        }
        
    }
    /*
    Method Description: below mthod will take list of refund records as a parameter
    and create the recoords of CreditMemo
    */
    public static boolean createCreditMemo(List<Refund__c> lstRefund, List<Transaction_Type__c> transactionList){
        boolean flag = false;
        List<Credit_Memo__c> lstCreditMemo = new List<Credit_Memo__c>();
        Set<Id> dealIds = new Set<Id>();
        Set<Id> refundIds = new Set<Id>();
        Map<Id,Id> opptyToRefundMap = new Map<Id,Id>();
        Map<Id,List<Invoice__c>> opptyToInvoiceMap = new Map<Id,List<Invoice__c>>();
        try{
            for(Refund__c refund : lstRefund){
                dealIds.add(refund.Service_Request__r.Deal__c);
                if(refund.Deal__r.Master_Opportunity__c != null){
                    dealIds.add(refund.Deal__r.Master_Opportunity__c);
                }
            }
            List<Invoice__c> invoiceList = [SELECT Id,Opportunity__c,Invoice_Type__c FROM Invoice__c 
                                                WHERE Opportunity__c=: dealIds];
            if(invoiceList.size()>0){
                for(Invoice__c invoice: invoiceList){
                    opptyToRefundMap.put(invoice.Opportunity__c,invoice.Id);
                    if(opptyToInvoiceMap.containsKey(invoice.Opportunity__c)){
                        opptyToInvoiceMap.get(invoice.Opportunity__c).add(invoice);
                    }else{
                        opptyToInvoiceMap.put(invoice.Opportunity__c,new List<Invoice__c>{invoice});
                    }
                }
                Credit_Memo__c creditMemo; 
                for(Refund__c refund:lstRefund){
                    if(refund.Refund_Applicable__c == 'Yes'){
                        if(refund.Security_Deposit_Refund__c != null && refund.Security_Deposit_Refund__c > 0){
                            creditMemo = new Credit_Memo__c();
                            creditMemo.Service_Request__c = refund.Service_Request__c;
                            creditMemo.Credit_Memo_Date__c = Date.today();
                            if(opptyToInvoiceMap.containsKey(refund.Service_Request__r.Deal__c)){
                                for(Invoice__c invoice : opptyToInvoiceMap.get(refund.Service_Request__r.Deal__c)){
                                    if(invoice.Invoice_Type__c == 'SEC'){
                                        creditMemo.Invoice__c = invoice.Id;
                                        break;
                                    }
                                }
                            }else if(opptyToInvoiceMap.containsKey(refund.Deal__r.Master_Opportunity__c)){
                                for(Invoice__c invoice : opptyToInvoiceMap.get(refund.Deal__r.Master_Opportunity__c)){
                                    if(invoice.Invoice_Type__c == 'SEC'){
                                        creditMemo.Invoice__c = invoice.Id;
                                        break;
                                    }
                                }
                            }
                            creditMemo.Invoice_Description__c = 'Credit note for security deposit';
                            creditMemo.Send_Credit_Memo_to_ERP__c = True;
                            creditMemo.Amount__c = -refund.Security_Deposit_Refund__c;
                            creditMemo.Unit__c = refund.Case_Unit__r.Unit__c;
                            creditMemo.Account__c = refund.Service_Request__r.AccountId;
                            for(Transaction_Type__c transactionType : transactionList){
                                if(transactionType.Transaction_Category__c == 'CREDIT_MEMO' && transactionType.Transaction_Type_Code__c == 'TERMINATION - CM'
                                    && transactionType.ERP_BU_ID__c == refund.Case_Unit__r.Unit__r.ERP_Business_Unit_Id__c){
                                        creditMemo.Transaction_Type__c = transactionType.Id;
                                    break;
                                }
                            }
                            lstCreditMemo.add(creditMemo);
                        }
                        if(refund.Rent_Refund_Amount__c != null && refund.Rent_Refund_Amount__c >0){
                            creditMemo = new Credit_Memo__c();
                            creditMemo.Service_Request__c = refund.Service_Request__c;
                            creditMemo.Credit_Memo_Date__c = Date.today();
                            if(opptyToInvoiceMap.containsKey(refund.Service_Request__r.Deal__c)){
                                for(Invoice__c invoice : opptyToInvoiceMap.get(refund.Service_Request__r.Deal__c)){
                                    if(invoice.Invoice_Type__c == 'BASE'){
                                        creditMemo.Invoice__c = invoice.Id;
                                        break;
                                    }
                                }
                            }
                            creditMemo.Invoice_Description__c = 'Credit note for rent refund amount';
                            creditMemo.Send_Credit_Memo_to_ERP__c = True;
                            creditMemo.Amount__c = -refund.Rent_Refund_Amount__c;
                            creditMemo.Unit__c = refund.Case_Unit__r.Unit__c;
                            creditMemo.Account__c = refund.Service_Request__r.AccountId;
                            for(Transaction_Type__c transactionType : transactionList){
                                if(transactionType.Transaction_Category__c == 'CREDIT_MEMO' && transactionType.Transaction_Type_Code__c == 'TERMINATION - CM'
                                    && transactionType.ERP_BU_ID__c == refund.Case_Unit__r.Unit__r.ERP_Business_Unit_Id__c){
                                        creditMemo.Transaction_Type__c = transactionType.Id;
                                    break;
                                }
                            }
                            lstCreditMemo.add(creditMemo);
                        }
                    }else if(refund.Refund_Applicable__c == 'No'){
                        creditMemo = new Credit_Memo__c();
                        creditMemo.Service_Request__c = refund.Service_Request__c;
                        creditMemo.Credit_Memo_Date__c = Date.today();
                        if(opptyToInvoiceMap.containsKey(refund.Service_Request__r.Deal__c)){
                            for(Invoice__c invoice : opptyToInvoiceMap.get(refund.Service_Request__r.Deal__c)){
                                if(invoice.Invoice_Type__c == 'SEC'){
                                    creditMemo.Invoice__c = invoice.Id;
                                    break;
                                }
                            }
                        }else if(opptyToInvoiceMap.containsKey(refund.Deal__r.Master_Opportunity__c)){
                            for(Invoice__c invoice : opptyToInvoiceMap.get(refund.Deal__r.Master_Opportunity__c)){
                                if(invoice.Invoice_Type__c == 'SEC'){
                                    creditMemo.Invoice__c = invoice.Id;
                                    break;
                                }
                            }
                        }
                        creditMemo.Invoice_Description__c = 'Credit note for Security deposit';
                        creditMemo.Send_Credit_Memo_to_ERP__c = True;
                        creditMemo.Amount__c = refund.Total_Refund__c > 0 ? (-refund.Total_Refund__c) : (-refund.Security_Deposit_Refund__c);
                        creditMemo.Unit__c = refund.Case_Unit__r.Unit__c;
                        creditMemo.Account__c = refund.Service_Request__r.AccountId;
                        for(Transaction_Type__c transactionType : transactionList){
                            if(transactionType.Transaction_Category__c == 'CREDIT_MEMO' && transactionType.Transaction_Type_Code__c == 'TERMINATION - CM'
                                && transactionType.ERP_BU_ID__c == refund.Case_Unit__r.Unit__r.ERP_Business_Unit_Id__c){
                                    creditMemo.Transaction_Type__c = transactionType.Id;
                                break;
                            }
                        }
                        lstCreditMemo.add(creditMemo);
                    }
                    
                }
                if(lstCreditMemo.size()>0)
                    insert lstCreditMemo;
            }
        	flag = true;
            return flag;
        }catch(Exception ex){
            system.debug('ex message:'+ex.getMessage()+'Line number :'+ex.getLineNumber());
            flag = false;
            return flag;
        }
        
    }

    /*
    Method Description: This method takes refund records as parameters 
    and creates receipt refund records for giving a call to ERP for refund API
    Author: Karishma Kotian
    Created Date: 02-05-2022
    */
    public static boolean createRefunds(List<Refund__c> refunds){
        boolean flag = false;
        set<Id> refundIds = new set<Id>();
        set<Id> unitIds = new set<Id>();
        List<Receipt_Refund__c> receiptRefundList = new List<Receipt_Refund__c>();
        try{
            for(Refund__c refund : refunds){
            refundIds.add(refund.Id);
            unitIds.add(refund.Case_Unit__r.Unit__c);
        	}
        	Map<Id,List<Receipt__c>> unitIdMapWithReceipts = fetchReceiptsBasedOnUnitIds(unitIds);
        	Map<Id,Receipt__c> securityDepositReceiptPerUnit = fetchSecurityDepositReceipt(unitIdMapWithReceipts);
        	system.debug('@@@refundList :'+refunds);
        	for(Refund__c refund : refunds){
            	if(refund.Refund_Applicable__c == 'Yes'){
                	if(refund.Security_Deposit_Refund__c != null && refund.Security_Deposit_Refund__c > 0){
                    	system.debug('inside security deposit refund');
                    	Receipt_Refund__c receiptRefund = new Receipt_Refund__c();
                    	receiptRefund.Opportunity__c = refund.Service_Request__r.Deal__c;
                    	receiptRefund.Send_Refund_to_ERP__c = true;
                    	receiptRefund.Service_Request__c = refund.Service_Request__c;
                    	receiptRefund.Receipt__c = securityDepositReceiptPerUnit.get(refund.Case_Unit__r.Unit__c).Id;
                    	receiptRefund.Unit__c = refund.Case_Unit__r.Unit__c;
                    	receiptRefund.Refund_Amount__c = refund.Security_Deposit_Refund__c;
                    	receiptRefundList.add(receiptRefund);
                	}
                	if(refund.Rent_Refund_Amount__c != null && refund.Rent_Refund_Amount__c >0){
                    	system.debug('inside installment refund');
                    	Receipt_Refund__c receiptRefund = new Receipt_Refund__c();
                    	receiptRefund.Opportunity__c = refund.Service_Request__r.Deal__c;
                    	receiptRefund.Send_Refund_to_ERP__c = true;
                    	receiptRefund.Service_Request__c = refund.Service_Request__c;
                    	system.debug('@@@installmentReceipt :'+unitIdMapWithReceipts.get(refund.Case_Unit__r.Unit__c)[0].Id);
                    	receiptRefund.Receipt__c = unitIdMapWithReceipts.get(refund.Case_Unit__r.Unit__c)[0].Id;
                    	receiptRefund.Unit__c = refund.Case_Unit__r.Unit__c;
                    	receiptRefund.Refund_Amount__c = refund.Rent_Refund_Amount__c;
                    	receiptRefundList.add(receiptRefund);
                	}
            	}else if(refund.Refund_Applicable__c == 'No'){
                    system.debug('inside installment refund');
                    Receipt_Refund__c receiptRefund = new Receipt_Refund__c();
                    receiptRefund.Opportunity__c = refund.Service_Request__r.Deal__c;
                    receiptRefund.Send_Refund_to_ERP__c = true;
                    receiptRefund.Service_Request__c = refund.Service_Request__c;
                    system.debug('@@@installmentReceipt :'+unitIdMapWithReceipts.get(refund.Case_Unit__r.Unit__c)[0].Id);
                    receiptRefund.Receipt__c = unitIdMapWithReceipts.get(refund.Case_Unit__r.Unit__c)[0].Id;
                    receiptRefund.Unit__c = refund.Case_Unit__r.Unit__c;
                    receiptRefund.Refund_Amount__c = refund.Total_Refund__c > 0 ? refund.Total_Refund__c : refund.Security_Deposit_Refund__c;
                    receiptRefundList.add(receiptRefund);
            	}
        	}
        	system.debug('@@@receipt refund :'+receiptRefundList);
        	if(!receiptRefundList.isEmpty()){
            	insert receiptRefundList;
        	}

            flag = true;
            return flag;
        }catch(Exception ex){
            system.debug('ex message:'+ex.getMessage()+'Line number :'+ex.getLineNumber());
            flag = false;
            return flag;
        }
        
    }
	//Added by Karishma to fetch transaction type details - 13-05-2022
    public static List<Transaction_Type__c> fetchTransactionTypeBasedOnBusinessId(Set<String> buIDs){
        List<Transaction_Type__c> transactionTypeList = [SELECT Id,Transaction_Type_Id__c,Batch_Source_Id__c,ERP_BU_ID__c,Transaction_Category__c,Transaction_Type_Code__c FROM Transaction_Type__c 
                                                            WHERE ERP_BU_ID__c =: buIDs AND Transaction_Category__c IN ('CREDIT_MEMO','TRANSACTION_TYPE')
                                                            AND Transaction_Type_Code__c IN ('TERMINATION - CM','INVOICE')];
        return transactionTypeList;
    }

    //Added by Karishma to fetch refundDetails - 02-05-2022
    public static List<Refund__c> fetchRefundRecords(Set<Id> refundIds){
        List<Refund__c> refundList = [SELECT Id, Case_Unit__r.Unit__c, Service_Request__c, Security_Deposit_Refund__c,Service_Request__r.Deal__c,Case_Unit__r.Unit__r.ERP_Business_Unit_Id__c,
                                        Rent_Refund_Amount__c, Total_Refund__c, Refund_Applicable__c, Service_Request__r.AccountId,Deal__c,Deal__r.Master_Opportunity__c,
                                        Maintenance_Charges__c,VAT_on_Maintenance_Charges__c,Penalty_for_Early_Termination__c FROM Refund__c
                                        WHERE Id =: refundIds];
        return refundList;
    }

    //Added by Karishma to fetch receipts based on unit - 02-05-2022
    public static Map<Id,List<Receipt__c>> fetchReceiptsBasedOnUnitIds(Set<Id> unitIds){
        Map<Id,List<Receipt__c>> unitIdMapWithReceipts =  new Map<Id,List<Receipt__c>>();
        List<Receipt__c> receipts = [SELECT Id, Payment_Mode__c, Payment_Status__c, Received_For__c, 
                    ReceivedForMapping__c, Amount__c, Cheque_No__c, Send_Receipt_Reversal_ERP__c, Unit__c
                    FROM Receipt__c WHERE Payment_Status__c IN ('Paid','Cleared') AND Unit__c =: unitIds ORDER BY Sequence_Number__c DESC, Due_Date__c DESC];
        for(Receipt__c receipt: receipts){
            if(unitIdMapWithReceipts.containsKey(receipt.Unit__c)){
                unitIdMapWithReceipts.get(receipt.Unit__c).add(receipt);
            }else{
                unitIdMapWithReceipts.put(receipt.Unit__c, new List<Receipt__c>{receipt});
            }
        }
        system.debug('@@@fetchReceiptsBasedOnUnitIds :'+unitIdMapWithReceipts);
        return unitIdMapWithReceipts;
    }

    //Added by Karishma to fetch security deposit receipt based on unit - 02-05-2022
    public static Map<Id,Receipt__c> fetchSecurityDepositReceipt(Map<Id,List<Receipt__c>> unitIdMapToReceipts){
        Map<Id,Receipt__c> securityDepositReceiptPerUnit =  new Map<Id,Receipt__c>();
        for(Id key : unitIdMapToReceipts.keySet()){
            for(Receipt__c receipt : unitIdMapToReceipts.get(key)){
                if(receipt.ReceivedForMapping__c.Contains('SEC')){
                    securityDepositReceiptPerUnit.put(key, receipt);
                    break;
                }
            }
        }
        return securityDepositReceiptPerUnit;
    }
}