/**************************************************************************************************
* Name               : CreateReceiptHandler
* Description        : Handler class for incoming request from erp to create/update Receipts
* Created Date       : 22/02/2022                                                                 
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Vishal A 22/02/2022      Initial Draft.                                               
**************************************************************************************************/
@RestResource(urlMapping='/createReceipts/')
global class CreateReceiptHandler {
    
    @HttpPost
    global static ReceiptResponse createReceiptsRecord(List<Receipt> reciepts){
        ReceiptResponse recResp = new ReceiptResponse();
        RestResponse res = RestContext.response;
        
        try{
            if(reciepts != null && !reciepts.isEmpty()) {
                List<Receipt__c> receiptsToUpsert = new List<Receipt__c>();
                for(Receipt recReq : reciepts) {
                    
                    Receipt__c receiptObj = new Receipt__c();
                    receiptObj.ERP_Receipt_ID__c = recReq.eRPReceiptId;
                    receiptObj.Payment_Mode__c = recReq.paymentMode;
                   // receiptObj.Name = recReq.receiptNumber; Commented by Moneeb 
                    receiptObj.Receipt_Date__c = String.isNotBlank(recReq.receiptDate) ? Date.valueOf(recReq.receiptDate) : null;
                    receiptObj.Received_For__c = recReq.receivedfor;
                    receiptObj.Maturity_Date__c = String.isNotBlank(recReq.maturitydate) ? Date.valueOf(recReq.maturitydate) : null;
                    receiptObj.Bank__c = recReq.bankName;
                    receiptObj.Bank_Branch__c = recReq.bankBranch;
                    
                    if(String.isNotBlank(recReq.businessUnit)) {
                        Business_Unit__c bu = new Business_Unit__c(ERP_Business_Unit_Id__c=recReq.businessUnit);
                        receiptObj.Business_Unit__r = bu; //ERP Business Unit ID
                    }
                    
                    receiptObj.Amount__c = recReq.amount;
                    receiptObj.Amount_in_Words__c = recReq.amountinWords;
                    
                    if(String.isNotBlank(recReq.account)) {
                        Account acc = new Account(ERP_Account_ID__c=recReq.account);
                        receiptObj.Account__r = acc; //ERP Cust Acc ID
                    }
                    
                    if(String.isNotBlank(recReq.agreement)) {
                        Agreement__c agr = new Agreement__c(ERP_Sales_ID__c=recReq.agreement);
                        receiptObj.Agreement__r = agr; // ERP Lease Id
                    }
                    
                    if(String.isNotBlank(recReq.receivedFrom)) {
                        Account recFrm = new Account(ERP_Account_ID__c=recReq.receivedFrom);
                        receiptObj.Received_From__r = recFrm;  //ERP Cust Acc ID
                    }
                    
                    receiptObj.Receipt_Comments__c = recReq.receiptComments;
                    receiptObj.Payment_Status__c = recReq.receiptStatus;
                    
                    if(String.isNotBlank(recReq.opportunity)) {
                        Opportunity opp = new Opportunity(ERP_Opportunity_ID__c=recReq.opportunity);
                        receiptObj.Opportunity__r = opp; //ERP OPp Id
                    }
                    
                    if(String.isNotBlank(recReq.invoice)) {
                        Invoice__c inv = new Invoice__c(ERP_Invoice_Id__c=recReq.invoice);
                        receiptObj.Invoice__r = inv; // ERP Invoice Id
                    }
                    if(String.isNotBlank(recReq.receiptMethod)) {
                        Receipt_Method__c recMeth = new Receipt_Method__c(ERP_Receipt_Method_Id__c= recReq.receiptMethod);
                        receiptObj.Receipt_Method__r = recMeth;
                    }
                    
                    receiptObj.ERP_Receipt_Number__c = recReq.eRPReceiptNumber;
                    receiptObj.ERP_Document_Sequence__c = recReq.eRPDocumentSequence;
                    receiptsToUpsert.add(receiptObj);
                }
                
                if(!receiptsToUpsert.isEmpty()) {
                    upsert receiptsToUpsert ERP_Receipt_ID__c;
                    recResp.Status = 'Sucess';
                    recResp.Message = 'Receipt records Created/Updated sucessfully.';
                    List<ReceiptDetails> recDetails = new List<ReceiptDetails>();
                    for(Receipt__c recep : receiptsToUpsert) {
                        ReceiptDetails recOut = new ReceiptDetails(recep.Id,recep.ERP_Receipt_Number__c,recep.ERP_Receipt_ID__c);
                        recDetails.add(recOut);
                    }
                    recResp.recieptsResult = recDetails;
                    
                    
                    res.statuscode = 200;
                }
            }
        } catch(Exception ex) {
            recResp.Status = 'Failed';
            recResp.Message = 'Internal Error: ' + ex.getMessage();
            
            recResp.recieptsResult = new List<ReceiptDetails>();
            res.statuscode = 500;
        }
        return recResp;
    }
    
    //Main output wrapper class
    global class ReceiptResponse{
        global String Status{get; set;}
        global String Message{get; set;}
        global List<ReceiptDetails> recieptsResult{get; set;}
        
    }
    
    //Sub output wrapper class for receipt output details
    global class ReceiptDetails{
        global String salesforceId{get; set;}
        global String receiptNumber{get; set;}
        global String erpReceiptId{get; set;}
        
        global ReceiptDetails(String Name, String recNo, String erpId){
            this.salesforceId = Name;
            this.receiptNumber = recNo;
            this.erpReceiptId = erpId;
        }
    }
    
    //Input wrapper class
    global class Receipt{
        global String paymentMode{get; set;}
        global String receiptMethod{get; set;}
        global String receiptNumber{get; set;}
        global String receiptDate{get; set;}
        global String receivedfor{get; set;}
        global String maturitydate{get; set;}
        global String bankName{get; set;}
        global String bankBranch{get; set;}
        global String businessUnit{get; set;}
        global Decimal amount{get; set;}
        global String amountinWords{get; set;}
        global String account{get; set;}
        global String agreement{get; set;}
        global String receivedFrom{get; set;}
        global String receiptComments{get; set;}
        global String receiptStatus{get; set;}
        global String opportunity{get; set;}
        global String invoice{get; set;}
        global String eRPReceiptNumber{get; set;}
        global String eRPReceiptId{get; set;}
        global String eRPDocumentSequence{get; set;}
    }
    /*
	@HttpPost
    global static InvoiceResponse createInvoicesRecord(List<Invoice> invoices){
        InvoiceResponse recResp = new InvoiceResponse();
        RestResponse res = RestContext.response;
        
        try{
            if(invoices != null && !invoices.isEmpty()) {
                List<Invoice__c> invoicesToUpsert = new List<Invoice__c>();
                for(Invoice invReq : invoices) {
                    
                    Invoice__c invoiceObj = new Invoice__c();
                    invoiceObj.ERP_Invoice_Id__c = invReq.erpInvoiceId;
                    invoiceObj.Payment_Mode__c = invReq.paymentMode;
                    invoiceObj.Payment_Date__c = String.isNotBlank(invReq.paymentDate) ? Date.valueOf(invReq.paymentDate) : null;
                    invoiceObj.Invoice_Status__c = invReq.invoiceStatus;
                    
                    invoiceObj.Amount__c = invReq.amount;
                    
                    invoiceObj.Invoice_Type__c = invReq.invoiceType;
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
                        Agreement__c agr = new Agreement__c(ERP_Sales_ID__c=invReq.agreement);
                        invoiceObj.Agreement__r = agr; // ERP Lease Id
                    }
                    invoicesToUpsert.add(invoiceObj);
                }
                
                if(!invoicesToUpsert.isEmpty()) {
                    upsert invoicesToUpsert ERP_Invoice_Id__c;
                    recResp.Status = 'Sucess';
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
    }*/
}