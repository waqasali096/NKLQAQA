/**************************************************************************************************
* Name               : CreateInvoiceHandler
* Description        : Handler class for incoming request from erp to create/update Invoices
* Created Date       : 24/02/2022                                                                 
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Vishal A 24/02/2022      Initial Draft.                                               
**************************************************************************************************/
@RestResource(urlMapping='/createInvoices/')
global class CreateInvoiceHandler {
    
    @HttpPost
    global static InvoiceResponse createInvoicesRecord(List<Invoice> invoices){
        InvoiceResponse recResp = new InvoiceResponse();
        RestResponse res = RestContext.response;
        
        try{
            if(invoices != null && !invoices.isEmpty()) {
            
                Set<String> setSalesLeaseSOId = new Set<String>();
                Set<String> setOppId = new Set<String>();
                Set<String> setTransactionType = new Set<String>();
                Set<String> setBusUnit = new Set<String>();
                List<Invoice__c> invoicesToUpsert = new List<Invoice__c>();
                
                for(Invoice invReq : invoices) {
                    if(String.isNotBlank(invReq.agreement)) {
                        setSalesLeaseSOId.add(invReq.agreement);
                    }
                    if(String.isNotBlank(invReq.opportunity)) {
                        setOppId.add(invReq.opportunity);
                    }
                    if(String.isNotBlank(invReq.transactionType)) {
                        setTransactionType.add(invReq.transactionType);
                    }
                    if(String.isNotBlank(invReq.businessUnit)) {
                        setBusUnit.add(invReq.businessUnit);
                    }
                }
                Map<String,Id> mapLeaseContract = new Map<String,Id>();
                Map<String,Id> mapSalesAgreement = new Map<String,Id>();
                Map<String,Id> mapTransType = new Map<String,Id>();
                
                for(Lease_Contract__c lease : [SELECT Id,ERP_Lease_ID__c FROM Lease_Contract__c WHERE ERP_Lease_ID__c In: setSalesLeaseSOId AND Opportunity__r.ERP_Opportunity_Id__c In :setOppId]) {
                    mapLeaseContract.put(lease.ERP_Lease_ID__c,lease.Id);
                }
                for(Agreement__c agree : [SELECT Id,ERP_Sales_ID__c FROM Agreement__c WHERE ERP_Sales_ID__c In: setSalesLeaseSOId AND Opportunity__r.ERP_Opportunity_Id__c In :setOppId]) {
                    mapSalesAgreement.put(agree.ERP_Lease_ID__c,agree.Id);
                }
                
                for(Transaction_Type__C traType : [Select Id, Transaction_Type_Code__c, Transaction_Type_Id__c,External_Id__c FROM Transaction_Type__C where Transaction_Type_Id__c In:setTransactionType AND ERP_BU_ID__c IN :setBusUnit]) {
                    mapTransType.put(traType.Transaction_Type_Id__c,traType.Id);
                }
                
                for(Invoice invReq : invoices) {
                    
                    Invoice__c invoiceObj = new Invoice__c();
                    invoiceObj.ERP_Invoice_Id__c = invReq.erpInvoiceId;
                    invoiceObj.Payment_Mode__c = invReq.paymentMode;
                    invoiceObj.Payment_Date__c = String.isNotBlank(invReq.paymentDate) ? Date.valueOf(invReq.paymentDate) : null;
                    invoiceObj.Invoice_Status__c = invReq.invoiceStatus;
                    
                    invoiceObj.Amount__c = invReq.amount;
                    
                    invoiceObj.Invoice_Type__c = invReq.invoiceType;
                    if(String.isNotBlank(invReq.transactionType) && mapTransType.containsKey(invReq.transactionType)) {
                        invoiceObj.Transaction_Type__c = mapTransType.get(invReq.transactionType);
                    }
                    
                    invoiceObj.Item_Sales_Tax_Group__c = invReq.itemSalesTaxGroup;
                    invoiceObj.Payment_Status__c = invReq.paymentStatus;
                    invoiceObj.Reason__c = invReq.reason;
                    invoiceObj.Sales_Invoice_Number__c = invReq.salesInvoiceNumber;
                    
                    if(String.isNotBlank(invReq.opportunity)) {
                        Opportunity opp = new Opportunity(ERP_Opportunity_ID__c=invReq.opportunity);
                        invoiceObj.Opportunity__r = opp; //ERP OPp Id
                    }
                    if(String.isNotBlank(invReq.businessUnit)) {
                        Business_Unit__c bu = new Business_Unit__c(ERP_Business_Unit_Id__c=invReq.businessUnit);
                        invoiceObj.Business_Unit__r = bu; //ERP Business Unit ID
                    }
                    if(String.isNotBlank(invReq.agreement)) {
                        if(mapSalesAgreement.containsKey(invReq.agreement)) {
                            invoiceObj.Agreement__c = mapSalesAgreement.get(invReq.agreement);
                        }
                        if(mapLeaseContract.containsKey(invReq.agreement)) {
                            invoiceObj.Contract__c = mapLeaseContract.get(invReq.agreement);
                        }
                        /*Agreement__c agr = new Agreement__c(ERP_Sales_ID__c=invReq.agreement);
                        invoiceObj.Agreement__r = agr; // ERP Lease Id*/
                    }
                    invoicesToUpsert.add(invoiceObj);
                }
                
                if(!invoicesToUpsert.isEmpty()) {
                    upsert invoicesToUpsert ERP_Invoice_Id__c;
                    recResp.Status = 'Success';
                    recResp.Message = 'Invoice records Created/Updated sucessfully.';
                    List<InvoiceDetails> recDetails = new List<InvoiceDetails>();
                    for(Invoice__c inv : invoicesToUpsert) {
                        InvoiceDetails recOut = new InvoiceDetails(inv.Id,inv.Sales_Invoice_Number__c,inv.ERP_Invoice_Id__c);
                        recDetails.add(recOut);
                    }
                    recResp.invoicesResult = recDetails;
                    
                    
                    res.statuscode = 200;
                }
            }
        } catch(Exception ex) {
            recResp.Status = 'Failed';
            recResp.Message = 'Internal Error: ' + ex.getMessage();
            
            recResp.invoicesResult = new List<InvoiceDetails>();
            res.statuscode = 500;
        }
        return recResp;
    }
    
    //Main output wrapper class
    global class InvoiceResponse{
        global String Status{get; set;}
        global String Message{get; set;}
        global List<InvoiceDetails> invoicesResult{get; set;}
        
    }
    
    //Sub output wrapper class for receipt output details
    global class InvoiceDetails{
        global String salesforceId{get; set;}
        global Integer  salesInvoiceNumber{get; set;}
        global String erpInvoiceId{get; set;}
        
        global InvoiceDetails(String sfId, Decimal recNo, String erpId){
            this.salesforceId = sfId;
            if(recNo != null) {
                this.salesInvoiceNumber = Integer.valueOf(recNo);
            }
            this.erpInvoiceId = erpId;
        }
    }
    
    //Input wrapper class
    global class Invoice{
        global String agreement{get; set;}
        global Decimal amount{get; set;}
        global String businessUnit{get; set;}
        global String erpInvoiceId{get; set;}
        global String paymentDate{get; set;}
        global String invoiceStatus{get; set;}
        global String invoiceType{get; set;}
        global String itemSalesTaxGroup{get; set;}
        global String opportunity{get; set;}
        global String paymentMode{get; set;}
        global String paymentStatus{get; set;}
        global String reason{get; set;}
        global Integer salesInvoiceNumber{get; set;}
        global String transactionType{get; set;}
    }
}