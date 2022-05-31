/**
* @author : Jayesh Shewale
* @createdDate : 9-Feb-2022
* @lastModifieddate : 15-Mar-2022
* @purpose : Initial Development
* @usage : Trigger Handler on Invoice. 
*/
public class InvoiceTriggerHandler {
    
    List<Invoice__c> recordNewList = new List<Invoice__c>();
    List<Invoice__c> recordOldList = new List<Invoice__c>();
    Map<Id, Invoice__c> recordNewMap = new Map<Id, Invoice__c>();
    Map<Id, Invoice__c> recordOldMap = new Map<Id, Invoice__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    
    List<Id> oppId = new List<Id>();
    List<Opportunity> oppList =new List<Opportunity>();
    Map<Id,Double> oppAmountMap =new Map<Id,Double>();
    
    
    public InvoiceTriggerHandler(List<Invoice__c> newList, List<Invoice__c> oldList, Map<Id, Invoice__c> newMap, Map<Id, Invoice__c> oldMap, 
                                 boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete, Boolean isBefore, Boolean isAfter){
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
        paymentStatusUpdate(recordNewList);
        for(Invoice__c inv : recordNewList){
            inv.Send_Invoice_to_ERP__c = true;
        }
    }
    public void BeforeUpdateEvent() {
        paymentStatusUpdate(recordNewList);
    }
    public void handlerAfterUpdate(){
        
        calcTotalInvAmount();
        createInvoiceERP();
        calculateTotalInvoicedAmountOnPM(recordNewList);
        
    }
    
    public void handleAfterInsert(){
        attachInvoiceToMilestone();
        attachInvoiceToReceipt();
        calcTotalInvAmount();
        createInvoiceERP();
        calculateTotalInvoicedAmountOnPM(recordNewList);
        
    }
    
    public void handleAfterDelete(){
        calcTotalInvAmount();
        calculateTotalInvoicedAmountOnPM(recordOldList);
    }
    
    public void handleAfterUndelete(){
        calcTotalInvAmount();
        calculateTotalInvoicedAmountOnPM(recordNewList);
    }
    
    /**********************************************************************************************
* @Description  : Method to calculate total invoiced amount on Opportunity 
* @Params       : NA
* @Param        : NA
* @Return       : void
* @Author       : Jayesh Shewale
**********************************************************************************************/
    public void calcTotalInvAmount(){
            
            List<Id> oppIds = new List<Id>();
            
            //AfterUpdate
            if(isUpdate && isAfter){
                calculateTotalInvoicedAmount(recordNewList);
            }
            //AfterInsert & AfterUndelete
            if(isAfter && (isInsert || isUndelete)){
                
                calculateTotalInvoicedAmount(recordNewList);
            }
            
            //AfterDelete
            if(isDelete && isAfter){
                calculateTotalInvoicedAmount(recordOldList);
                
            }
    }
    /**********************************************************************************************
* @Description  : Method to create Invoice in ERP system
* @Params       : List< Invoice__c > newList
* @Param        : Map< Id, Invoice__c > oldMap
* @Return       : void
* @Author       : Karishma Kotian
**********************************************************************************************/
    public void createInvoiceERP(){
        Set<Id> invoiceId = new Set<Id>();
        for(Invoice__c invoice : recordNewList){
            if(invoice.Send_Invoice_to_ERP__c && (recordOldMap == null || invoice.Send_Invoice_to_ERP__c != recordOldMap.get(invoice.Id).Send_Invoice_to_ERP__c)){
                invoiceId.add(invoice.Id);
            }
            
        }
        if(!invoiceId.isEmpty()){
            ERPIntegrationHelper.createInvoices(invoiceId);
        }
    }
    
    /********************************************************************************************** 
* @Description  : Calculate total Amount on Opportunity 
* @Params       : Opportunity Id
* @Return       : void
* @Author       : Jayesh Shewale
**********************************************************************************************/
    
    private void calculateTotalInvoicedAmount(List<Invoice__c> invList){
        List<Id> oppId = new List<Id>();
        for(Invoice__c inv :invList){
            if(isAfter && isUpdate){
                if(inv.Amount__c != recordOldMap.get(inv.Id).Amount__c){
                    oppId.add(inv.Opportunity__c);
                }
            }else{
                oppId.add(inv.Opportunity__c);
            }
            
        }
        if(!oppId.isEmpty()){
            List<Opportunity> oppList = new List<Opportunity>();
            if(oppId.size() > 0){
                AggregateResult[] agrResult= [SELECT Opportunity__c ,SUM(Amount__c)amt FROM Invoice__c WHERE Opportunity__c IN: oppId group by Opportunity__c];
                for(AggregateResult ag : agrResult){
                    
                    Opportunity opp = new Opportunity();
                    opp.Total_Invoiced_Amount__c = (Decimal)ag.get('amt');
                    opp.Id = (Id)ag.get('Opportunity__c');
                    
                    oppList.add(opp);
                    
                }
                
                Database.update(oppList, false);
            }
        }
    }
    /********************************************************************************************** 
    * @Description  : Calculate Total Invoiced Amount on Payment Milestone 
    * @Params       : List<Invoice__c> invList
    * @Return       : void
    * @Author       : Rohit Sharma
    **********************************************************************************************/
    
    private void calculateTotalInvoicedAmountOnPM(List<Invoice__c> invList){
        List<Id> pmIdSet = new List<Id>();
        for(Invoice__c inv :invList){
            if(inv.Payment_Milestone__c != null){
                if(isAfter && isUpdate){
                    if(inv.Amount__c != recordOldMap.get(inv.Id).Amount__c){
                        pmIdSet.add(inv.Payment_Milestone__c);
                    }
                }else{
                    pmIdSet.add(inv.Payment_Milestone__c);
                }
            }
        }
        if(!pmIdSet.isEmpty()){
            List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
            for(AggregateResult ag : [SELECT Payment_Milestone__c ,SUM(Amount__c)amt FROM Invoice__c WHERE Payment_Milestone__c IN: pmIdSet group by Payment_Milestone__c]){
                Payment_Milestone__c pm = new Payment_Milestone__c();
                pm.Total_Invoiced_Amount__c = (Decimal)ag.get('amt');
                pm.Id = (Id)ag.get('Payment_Milestone__c');
                pmList.add(pm);
            }
            if(!pmList.isEmpty()){
                Database.update(pmList, false);
            }
        }
    }
    /******************************************************************************************************
    * @Description        : Function to set Payment Status
    * @Params             : List< Invoice__c > newList                                                                                             
    * @Return             : void       
    * @Author             : Rohit Sharma                                                                  
    *******************************************************************************************************/
    public static void paymentStatusUpdate(List<Invoice__c> newList){
        for(Invoice__c invoice : newList){
            if(invoice.Outstanding_Amount__c == 0){
                invoice.Payment_Status__c = 'Paid';
            }else{
                invoice.Payment_Status__c = 'Pending';
            }
        }
    }

    /********************************************************************************************** 
    * @Description  : Attach Invoice to Payment Milestone
    * @Return       : void
    * @Author       : Rohit Sharma
    **********************************************************************************************/
        
    public void attachInvoiceToMilestone(){
        Set<Id> invIdSet = new Set<Id>();
        Map< Id, Map< String, Id >> mapOppIdToMapInstallmentToMilestoneId = new Map< Id, Map< String, Id >>();
        Set<Id> oppIdSet = new Set<Id>();
        for(Invoice__c rec :recordNewList){
            if(rec.Opportunity__c != null && rec.Received_For__c != null){
                oppIdSet.add(rec.Opportunity__c);
                invIdSet.add(rec.Id);
            } 
        }
        if(!oppIdSet.isEmpty()){
            for(Payment_Milestone__c milestone : [SELECT Id,Installment__c,Opportunity__c FROM Payment_Milestone__c WHERE Opportunity__c IN: oppIdSet AND Installment__c != null]){
                if ( !mapOppIdToMapInstallmentToMilestoneId.containsKey(milestone.Opportunity__c )) {
                    mapOppIdToMapInstallmentToMilestoneId.put(milestone.Opportunity__c , new Map< String, Id >{milestone.Installment__c => milestone.Id});
                } else {
                    Map< String, Id >  tempMap = mapOppIdToMapInstallmentToMilestoneId.get(milestone.Opportunity__c);
                    tempMap.put(milestone.Installment__c, milestone.Id);
                    mapOppIdToMapInstallmentToMilestoneId.put(milestone.Opportunity__c , tempMap );
                }    
            }
            if(!mapOppIdToMapInstallmentToMilestoneId.isEmpty()){
                List<Invoice__c> lstInvoiceToUpdate = new List<Invoice__c>();
                for( Id recId : invIdSet){
                    for( String installment : mapOppIdToMapInstallmentToMilestoneId.get( recordNewMap.get(recId).Opportunity__c).keySet()){
                        String receivedFor = recordNewMap.get(recId).Received_For__c;
                        if(receivedFor == 'Token Amount'){
                            receivedFor = 'Deposit';
                        }
                        if(installment == receivedFor){
                            Invoice__c invoice = new Invoice__c();
                            invoice.Id = recId;
                            invoice.Payment_Milestone__c = mapOppIdToMapInstallmentToMilestoneId.get( recordNewMap.get(recId).Opportunity__c).get(installment);
                            lstInvoiceToUpdate.add( invoice );
                        }
                    }
                }
                if(!lstInvoiceToUpdate.isEmpty()){
                    update lstInvoiceToUpdate;
                }
            } 
        }
    }

    /********************************************************************************************** 
    * @Description  : Attach Invoice to Receipt
    * @Return       : void
    * @Author       : Rohit Sharma
    **********************************************************************************************/
        
    public void attachInvoiceToReceipt(){
        Set<Id> invIdSet = new Set<Id>();
        Map< Id, Map< String, Id >> mapOppIdToMapReceivedForToReceiptId = new Map< Id, Map< String, Id >>();
        Set<Id> oppIdSet = new Set<Id>();
        for(Invoice__c rec :recordNewList){
            if(rec.Opportunity__c != null && rec.Received_For__c != null){
                oppIdSet.add(rec.Opportunity__c);
                invIdSet.add(rec.Id);
            } 
        }
        if(!oppIdSet.isEmpty()){
            for(Receipt__c receipt : [SELECT Id, Received_For__c, Opportunity__c FROM Receipt__c WHERE Opportunity__c IN: oppIdSet AND Received_For__c != null]){
                if ( !mapOppIdToMapReceivedForToReceiptId.containsKey(receipt.Opportunity__c )) {
                    mapOppIdToMapReceivedForToReceiptId.put(receipt.Opportunity__c , new Map< String, Id >{receipt.Received_For__c => receipt.Id});
                } else {
                    Map< String, Id >  tempMap = mapOppIdToMapReceivedForToReceiptId.get(receipt.Opportunity__c);
                    tempMap.put(receipt.Received_For__c, receipt.Id);
                    mapOppIdToMapReceivedForToReceiptId.put(receipt.Opportunity__c , tempMap );
                }    
            }
            if(!mapOppIdToMapReceivedForToReceiptId.isEmpty()){
                List<Receipt__c> lstReceiptToUpdate = new List<Receipt__c>();
                for( Id recId : invIdSet){
                    for( String receiptReceivedFor : mapOppIdToMapReceivedForToReceiptId.get( recordNewMap.get(recId).Opportunity__c).keySet()){
                        if(receiptReceivedFor == recordNewMap.get(recId).Received_For__c){
                            Receipt__c receipt = new Receipt__c();
                            receipt.Id = mapOppIdToMapReceivedForToReceiptId.get( recordNewMap.get(recId).Opportunity__c).get(receiptReceivedFor);
                            receipt.Invoice__c = recId;
                            lstReceiptToUpdate.add( receipt );
                        }
                    }
                }
                if(!lstReceiptToUpdate.isEmpty()){
                    update lstReceiptToUpdate;
                }
            }  
        }
    }

}