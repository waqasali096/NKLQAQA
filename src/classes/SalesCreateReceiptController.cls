/* Name:SalesCreateReceiptController
* Description: Controller for Cashier Receipt Screen - SalesCreateReceipt
* Created Date: 01/01/2022
* LastModified Date: 26/05/2022
* Modified By: Ashams
*/
public class SalesCreateReceiptController {
    
    //Method to fetch Opportunity details
    @AuraEnabled
    public static OpportunityWrapper getBookingDetails(String OppId)
    {
        OpportunityWrapper oppWrap = new OpportunityWrapper();
        try
        {
            for (Opportunity opp: [Select ID, Name,Account.Name, Unit__r.Unit_Code__c, 
                                   Selling_Price__c, Unit__r.Unit_type__c,AccountId, 
                                   Unit__r.Name, Broker__r.Name from Opportunity where Id =: OppId])
            {
                oppWrap.LocationCode = opp.Unit__r.Unit_Code__c;
                oppWrap.price = opp.Selling_Price__c != null ? opp.Selling_Price__c: 0.0;
                oppWrap.customerName = opp.Account.Name;
                oppWrap.unitType = opp.Unit__r.Unit_type__c;
                oppWrap.building = opp.Unit__r.Name;
                oppWrap.brokerName = opp.Broker__r.Name;
                oppWrap.accountId = opp.AccountId;
            }  
            system.debug('oppWrap>>' + oppWrap);            
            return oppWrap;
        }
        catch(Exception ex)
        {
            return null;
        }         
        
    }
    //Method to fetch payment milestones under the opportunity
    @AuraEnabled
    public static List<PaymentMilestoneWrapper> getPaymentPlans(String OppId)
    {
        list<PaymentMilestoneWrapper> lstRecords = new list<PaymentMilestoneWrapper>();

        for(Payment_Milestone__c recList : [SELECT Id, Name, Amount__c, Amount_Percentage__c,Due_Date__c,CurrencyIsoCode
                                            FROM Payment_Milestone__c WHERE Opportunity__r.Id =: OppId])
        {
            PaymentMilestoneWrapper rec = new PaymentMilestoneWrapper();
            rec.estimatedDate = recList.Due_Date__c;
            rec.percentage = recList.Amount_Percentage__c;
            rec.amount = recList.Amount__c;
            rec.milestoneName = recList.Name;
            rec.currencyIsoCode = recList.CurrencyIsoCode;
            lstRecords.add(rec);
        }
        system.debug('plans>>'+ lstRecords);
        return lstRecords;
    }
    
    //Method to calculate total percentage, total milestone amount, total receipt amount
    @AuraEnabled
    public static List<decimal> calculation(String OppId) 
    {
        List<Decimal> calList = new List<Decimal>();
        list<PaymentMilestoneWrapper> pmList = getPaymentPlans(OppId);
        decimal percentage = 0;
            decimal pmamount = 0;
        decimal recamount = 0;
        for(PaymentMilestoneWrapper pm : pmList)
        {
            percentage = percentage + (pm.percentage == null ?0 : pm.percentage);
            pmamount = pmamount + pm.amount;
        }
        calList.add(pmamount);
        calList.add(percentage);
        List<Receipt__c> reclist = getReceipts(OppId);
        for(Receipt__c rc : reclist)
        {
            recamount = recamount + rc.amount__c;
        }
        calList.add(recamount);
        return calList;
    }
    //Method to fetch receipts under the opportunity
    @AuraEnabled
    public static List<Receipt__c> getReceipts(String OppId)
    {
        List<Receipt__c> recList = [SELECT Id, Name, Amount__c, CreatedBy.Name, CreatedDate, Receipt_Date__c, Unit__c,Business_Unit__c,
                                    Payment_Mode__c, Bank__c,Receipt_Number__c, Receipt_Comments__c,CurrencyIsoCode, 
                                    toLabel(Received_For__c), Installment_Type__c ,Receipt_Method__c,ERP_Receipt_ID__c
                                    FROM Receipt__c WHERE Opportunity__r.Id =: OppId];
        
        system.debug('receipts: '+ recList);
        return recList;
    }
    
    //Method to fetch picklist values
    @AuraEnabled
    public static map<string,string> getPicklistvalues(String objectName, String field_apiname,Boolean nullRequired){
        system.debug('Object: '+ objectName + ' Field: '+ field_apiname);
        map<string,string> optionlist = new map<string,string>();       
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();               
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.put(pv.getLabel(),pv.getValue());
        }
        system.debug('options: '+ optionlist);
        return optionlist;
    }
    
    //Method to fetch ReceivedFor picklist values
    @AuraEnabled
    public static map<string,string> getReceivedForValues(string objectName,String field_apiname,Boolean nullRequired){
        system.debug('Object: '+ objectName + ' Field: '+ field_apiname);
        map<string,string> optionlist = new map<string,string>();       
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();               
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.put(pv.getLabel(),pv.getValue());
        }
        system.debug('options: '+ optionlist);
        return optionlist;
    }
    
    //Method to fetch InstallmentType picklist values
    @AuraEnabled
    public static map<string,string> getInstallmentTypeValues(string objectName,String field_apiname,Boolean nullRequired){
        system.debug('Object: '+ objectName + ' Field: '+ field_apiname);
        map<string,string> optionlist = new map<string,string>();       
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();               
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.put(pv.getLabel(),pv.getValue());
        }
        system.debug('options: '+ optionlist);
        return optionlist;
    }
    
    //Method to save receipts from cashier screen
    @AuraEnabled
    public static list<Receipt__c> saveRec(String mode, string ReceivedFor, //string InstallmentType, 
                                           string OppId,Receipt__c receipt, String receivedFrom, String receiptMethodId)
    {   system.debug('@@receipt :'+receipt); 
        system.debug('@@mode :'+mode); 
        system.debug('@@ReceivedFor :'+ReceivedFor); 
        //system.debug('@@InstallmentType :'+InstallmentType); 
        system.debug('@@OppId :'+OppId); 
        system.debug('@@recevied from :'+receivedFrom);
        system.debug('@@receiptMethodId :'+receiptMethodId);
     try
     {
         Receipt__c insertRec = new Receipt__c();
         insertRec.Payment_Mode__c = mode;
         insertRec.Name = receipt.Name; //receiptNumber; //
         insertRec.Amount__c = receipt.Amount__c; //decimal.valueOf(amount);//
         insertRec.Amount_in_Words__c = receipt.Amount_in_Words__c; //amountWords; //
         insertRec.Receipt_Date__c = System.today(); //receiptDate;
         insertRec.Due_Date__c = receipt.Due_Date__c;
         insertRec.Received_For__c = ReceivedFor;            
         insertRec.Received_From__c = receivedFrom; 
         insertRec.Receipt_Comments__c = receipt.Receipt_Comments__c; //receiptComments;//
         //insertRec.Installment_Type__c = InstallmentType;
         insertRec.Receipt_Method__c  = receiptMethodId;
         insertRec.Opportunity__c = OppId;
         insertRec.Bank__c  = receipt.Bank__c;
         insertRec.Bank_Branch__c = receipt.Bank_Branch__c;
         insertRec.Account__c = receipt.Account__c;
         insertRec.Maturity_Date__c = receipt.Maturity_Date__c;
         if(mode == 'Cash'){
             insertRec.Payment_Status__c = 'Cleared';
         }else{
             insertRec.Payment_Status__c = 'Pending';
         }
         if(OppId != null){
             Opportunity oppty = [SELECT Id, Unit__c, Unit__r.Business_Unit__c,Agreement__c FROM Opportunity WHERE Id=: OppId];
             if(oppty.Unit__c != null){
                 insertRec.Unit__c = oppty.Unit__c;
                 if(oppty.Unit__r.Business_Unit__c != null){
                     insertRec.Business_Unit__c = oppty.Unit__r.Business_Unit__c;
                 }
             }
             insertRec.Agreement__c = oppty.Agreement__c;
         }
         system.debug('Receipt insertRec>> '+ insertRec);
         insert insertRec;
         
         List<Receipt__c> recList = [Select Id, Name, Amount__c, CreatedBy.Name, Unit__c,Business_Unit__c,
                                     CreatedDate, Receipt_Date__c, Payment_Mode__c, Bank__c,
                                     Receipt_Number__c, Receipt_Comments__c,CurrencyIsoCode, 
                                     toLabel(Received_For__c), Installment_Type__c, Receipt_Method__c ,ERP_Receipt_ID__c
                                     FROM Receipt__c WHERE Opportunity__r.Id =: OppId];
         system.debug('receipts>> '+ recList);
         return recList; 
         
     }
     catch(Exception ex)
     {
         system.debug('ex: '+ ex.getCause() + ', line number: '+ ex.getLineNumber() + ', message: '+ex.getMessage());
         return null;
     }              
    }
    
    //Method to fetch AdditionalCharges
    @AuraEnabled
    public static List<AdditionalChargesWrapper> getadditionalCharges(String OppId)
    {
        list<AdditionalChargesWrapper> lstRecords = new list<AdditionalChargesWrapper>();
        try{
            for(Opportunity_Charges__c  record : [SELECT Id, Name, Amount__c, //VAT__c , VAT_Amount__c ,
                                                  Payable_Amount__c FROM Opportunity_Charges__c  WHERE Opportunity__r.Id =: OppId])
            {
                AdditionalChargesWrapper rec = new AdditionalChargesWrapper();
                rec.Name = record.Name;
                rec.amount = record.Amount__c;
                // rec.vatPercentage = record.VAT__c;
                //rec.vatAmount = record.VAT_Amount__c;
                rec.payableAmount = record.Payable_Amount__c;
                lstRecords.add(rec);
            }
            system.debug('additional charges>>'+ lstRecords);
            return lstRecords;
        }
        catch(Exception ex)
        {
            system.debug('ex: '+ ex.getCause() + ', line number: '+ ex.getLineNumber() + ', message: '+ex.getMessage());
            return null;
        }     
    }
    
    //Method to fetch receipt methods
    @AuraEnabled
    public static List<Receipt_Method__c> getReceiptMethods(String oppId){
        //Map<String,String> optionlist = new Map<String,String>();
        List<Receipt_Method__c> receiptMethods = new List<Receipt_Method__c>();
        try{
            Opportunity opp = [SELECT Id, Unit__c, Unit__r.Business_Unit__c,Business_Unit__c  FROM Opportunity WHERE Id =: oppId];
            receiptMethods = [SELECT Id,Name,Payment_Mode__c FROM Receipt_Method__c 
                              WHERE Business_Unit__c =: opp.Business_Unit__c];
            /*for(Receipt_Method__c rm : receiptMethods){
optionlist.put(rm.Name,rm.Id);
}
system.debug('%%ReceiptMethods'+optionlist);*/
            return receiptMethods;
            
        }catch(Exception ex)
        {
            system.debug('ex: '+ ex.getCause() + ', line number: '+ ex.getLineNumber() + ', message: '+ex.getMessage());
            return receiptMethods;
        }     
    }
    
    //wrapper classes
    public class OpportunityWrapper
    {
        @AuraEnabled
        public string LocationCode {get;set;}
        @AuraEnabled
        public decimal price {get;set;}
        @AuraEnabled
        public string customerName {get;set;}
        @AuraEnabled
        public string unitType {get;set;}
        @AuraEnabled
        public string building {get;set;}
        @AuraEnabled
        public string brokerName {get;set;}
        @AuraEnabled
        public string accountId {get;set;}
    }

    public class PaymentMilestoneWrapper
    {
        @AuraEnabled
        public date estimatedDate {get;set;}
        @AuraEnabled
        public decimal percentage {get;set;}
        @AuraEnabled
        public decimal amount {get;set;}
        @AuraEnabled
        public string milestoneName {get;set;}   
        @AuraEnabled
        public string currencyIsoCode {get;set;}
    }

    public class AdditionalChargesWrapper
    {
        @AuraEnabled
        public string Name {get;set;}
        @AuraEnabled
        public decimal vatPercentage {get;set;}
        @AuraEnabled
        public decimal amount {get;set;}
        @AuraEnabled
        public decimal vatAmount {get;set;}   
        @AuraEnabled
        public decimal payableAmount {get;set;}
    }
}