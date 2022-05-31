public class CreateAccountSOACtrl {
    public Account acct{get;set;}
    //public List<ERPAPIResponse.X_SCHEDULES_ITEM> scheduleItems{get;set;}
    public Unit__c unit{get;set;}
    public Date fromDate{get;set;}
    public Date toDate{get;set;}
    
    public CreateAccountSOACtrl(ApexPages.StandardController stdController) {
        /*this.acct = (Account)stdController.getRecord();
        unit = new Unit__c();
        scheduleItems = new List<ERPAPIResponse.X_SCHEDULES_ITEM>();
        
        String oppid = apexpages.currentpage().getparameters().get('oppId');
        if(oppid != null) {
            List<Opportunity> opptys = new List<Opportunity>([Select Id, Name, Unit__c  FROM Opportunity WHERE Id =: oppid]);
            if(!opptys.isEmpty()) {
                Id unitId = opptys[0].Unit__c;
                if(unitId != null) {
                    List<Unit__c> units = new List<Unit__c>([Select Id, Name,Project__c,Project__r.Name,Unit_Code__c,Selling_Price__c,
                                                              Plot_Area_Sqft__c,Plot_Area_Sqmt__c,Built_Up_Area_Sqft__c,Built_Up_Area_Sqmt__c,
                                                              Unit_Theme__c,Unit_Theme__r.Name,Car_Park__c,CurrencyIsoCode
                                                              FROM Unit__c WHERE Id =: unitId]);
                    unit = units[0];
                }
                
            }
        }
        
        
        ERPAPIResponse.X_SCHEDULES_ITEM xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '1';
        xitem.PAYMENT_SCHEDULE_ID = '77423';
        xitem.CUSTOMER_TRX_ID = 'NOC for Land Department Resale Fee';
        xitem.AR_INVOICE_NUMBER = 'inv-001';
        xitem.INVOICE_TYPE = 'token';
        xitem.NET_OUTSTANDING = '11,000';
        xitem.INVOICE_DATE = '13-Dec-2006';
        xitem.SCHEDULE_DATE = '13-Dec-2006';
        xitem.AMOUNT_CREDITED = '9,000';
        xitem.ACTUAL_AMOUNT = '30,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '2';
        xitem.PAYMENT_SCHEDULE_ID = '88630';
        xitem.CUSTOMER_TRX_ID = 'CASH Admin Fee for Affection Plan';
        xitem.AR_INVOICE_NUMBER = 'inv-002';
        xitem.INVOICE_DATE = '16-Dec-2006';
        xitem.INVOICE_TYPE = 'booking';
        xitem.NET_OUTSTANDING = '50,000';
        xitem.SCHEDULE_DATE = '10-Dec-2007';
        xitem.AMOUNT_CREDITED = '30,000';
        xitem.ACTUAL_AMOUNT = '90,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '1';
        xitem.PAYMENT_SCHEDULE_ID = '77423';
        xitem.CUSTOMER_TRX_ID = 'NOC for Land Department Resale Fee';
        xitem.AR_INVOICE_NUMBER = 'inv-001';
        xitem.INVOICE_TYPE = 'token';
        xitem.NET_OUTSTANDING = '11,000';
        xitem.INVOICE_DATE = '13-Dec-2006';
        xitem.SCHEDULE_DATE = '13-Dec-2006';
        xitem.AMOUNT_CREDITED = '9,000';
        xitem.ACTUAL_AMOUNT = '30,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '2';
        xitem.PAYMENT_SCHEDULE_ID = '88630';
        xitem.CUSTOMER_TRX_ID = 'CASH Admin Fee for Affection Plan';
        xitem.AR_INVOICE_NUMBER = 'inv-002';
        xitem.INVOICE_DATE = '16-Dec-2006';
        xitem.INVOICE_TYPE = 'booking';
        xitem.NET_OUTSTANDING = '50,000';
        xitem.SCHEDULE_DATE = '10-Dec-2007';
        xitem.AMOUNT_CREDITED = '30,000';
        xitem.ACTUAL_AMOUNT = '90,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '1';
        xitem.PAYMENT_SCHEDULE_ID = '77423';
        xitem.CUSTOMER_TRX_ID = 'NOC for Land Department Resale Fee';
        xitem.AR_INVOICE_NUMBER = 'inv-001';
        xitem.INVOICE_TYPE = 'token';
        xitem.NET_OUTSTANDING = '11,000';
        xitem.INVOICE_DATE = '13-Dec-2006';
        xitem.SCHEDULE_DATE = '13-Dec-2006';
        xitem.AMOUNT_CREDITED = '9,000';
        xitem.ACTUAL_AMOUNT = '30,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '2';
        xitem.PAYMENT_SCHEDULE_ID = '88630';
        xitem.CUSTOMER_TRX_ID = 'CASH Admin Fee for Affection Plan';
        xitem.AR_INVOICE_NUMBER = 'inv-002';
        xitem.INVOICE_DATE = '16-Dec-2006';
        xitem.INVOICE_TYPE = 'booking';
        xitem.NET_OUTSTANDING = '50,000';
        xitem.SCHEDULE_DATE = '10-Dec-2007';
        xitem.AMOUNT_CREDITED = '30,000';
        xitem.ACTUAL_AMOUNT = '90,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '1';
        xitem.PAYMENT_SCHEDULE_ID = '77423';
        xitem.CUSTOMER_TRX_ID = 'NOC for Land Department Resale Fee';
        xitem.AR_INVOICE_NUMBER = 'inv-001';
        xitem.INVOICE_TYPE = 'token';
        xitem.NET_OUTSTANDING = '11,000';
        xitem.INVOICE_DATE = '13-Dec-2006';
        xitem.SCHEDULE_DATE = '13-Dec-2006';
        xitem.AMOUNT_CREDITED = '9,000';
        xitem.ACTUAL_AMOUNT = '30,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '2';
        xitem.PAYMENT_SCHEDULE_ID = '88630';
        xitem.CUSTOMER_TRX_ID = 'CASH Admin Fee for Affection Plan';
        xitem.AR_INVOICE_NUMBER = 'inv-002';
        xitem.INVOICE_DATE = '16-Dec-2006';
        xitem.INVOICE_TYPE = 'booking';
        xitem.NET_OUTSTANDING = '50,000';
        xitem.SCHEDULE_DATE = '10-Dec-2007';
        xitem.AMOUNT_CREDITED = '30,000';
        xitem.ACTUAL_AMOUNT = '90,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '1';
        xitem.PAYMENT_SCHEDULE_ID = '77423';
        xitem.CUSTOMER_TRX_ID = 'NOC for Land Department Resale Fee';
        xitem.AR_INVOICE_NUMBER = 'inv-001';
        xitem.INVOICE_TYPE = 'token';
        xitem.NET_OUTSTANDING = '11,000';
        xitem.INVOICE_DATE = '13-Dec-2006';
        xitem.SCHEDULE_DATE = '13-Dec-2006';
        xitem.AMOUNT_CREDITED = '9,000';
        xitem.ACTUAL_AMOUNT = '30,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '2';
        xitem.PAYMENT_SCHEDULE_ID = '88630';
        xitem.CUSTOMER_TRX_ID = 'CASH Admin Fee for Affection Plan';
        xitem.AR_INVOICE_NUMBER = 'inv-002';
        xitem.INVOICE_DATE = '16-Dec-2006';
        xitem.INVOICE_TYPE = 'booking';
        xitem.NET_OUTSTANDING = '50,000';
        xitem.SCHEDULE_DATE = '10-Dec-2007';
        xitem.AMOUNT_CREDITED = '30,000';
        xitem.ACTUAL_AMOUNT = '90,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '1';
        xitem.PAYMENT_SCHEDULE_ID = '77423';
        xitem.CUSTOMER_TRX_ID = 'NOC for Land Department Resale Fee';
        xitem.AR_INVOICE_NUMBER = 'inv-001';
        xitem.INVOICE_TYPE = 'token';
        xitem.NET_OUTSTANDING = '11,000';
        xitem.INVOICE_DATE = '13-Dec-2006';
        xitem.SCHEDULE_DATE = '13-Dec-2006';
        xitem.AMOUNT_CREDITED = '9,000';
        xitem.ACTUAL_AMOUNT = '30,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '2';
        xitem.PAYMENT_SCHEDULE_ID = '88630';
        xitem.CUSTOMER_TRX_ID = 'CASH Admin Fee for Affection Plan';
        xitem.AR_INVOICE_NUMBER = 'inv-002';
        xitem.INVOICE_DATE = '16-Dec-2006';
        xitem.INVOICE_TYPE = 'booking';
        xitem.NET_OUTSTANDING = '50,000';
        xitem.SCHEDULE_DATE = '10-Dec-2007';
        xitem.AMOUNT_CREDITED = '30,000';
        xitem.ACTUAL_AMOUNT = '90,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '1';
        xitem.PAYMENT_SCHEDULE_ID = '77423';
        xitem.CUSTOMER_TRX_ID = 'NOC for Land Department Resale Fee';
        xitem.AR_INVOICE_NUMBER = 'inv-001';
        xitem.INVOICE_TYPE = 'token';
        xitem.NET_OUTSTANDING = '11,000';
        xitem.INVOICE_DATE = '13-Dec-2006';
        xitem.SCHEDULE_DATE = '13-Dec-2006';
        xitem.AMOUNT_CREDITED = '9,000';
        xitem.ACTUAL_AMOUNT = '30,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '2';
        xitem.PAYMENT_SCHEDULE_ID = '88630';
        xitem.CUSTOMER_TRX_ID = 'CASH Admin Fee for Affection Plan';
        xitem.AR_INVOICE_NUMBER = 'inv-002';
        xitem.INVOICE_DATE = '16-Dec-2006';
        xitem.INVOICE_TYPE = 'booking';
        xitem.NET_OUTSTANDING = '50,000';
        xitem.SCHEDULE_DATE = '10-Dec-2007';
        xitem.AMOUNT_CREDITED = '30,000';
        xitem.ACTUAL_AMOUNT = '90,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '1';
        xitem.PAYMENT_SCHEDULE_ID = '77423';
        xitem.CUSTOMER_TRX_ID = 'NOC for Land Department Resale Fee';
        xitem.AR_INVOICE_NUMBER = 'inv-001';
        xitem.INVOICE_TYPE = 'token';
        xitem.NET_OUTSTANDING = '11,000';
        xitem.INVOICE_DATE = '13-Dec-2006';
        xitem.SCHEDULE_DATE = '13-Dec-2006';
        xitem.AMOUNT_CREDITED = '9,000';
        xitem.ACTUAL_AMOUNT = '30,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '2';
        xitem.PAYMENT_SCHEDULE_ID = '88630';
        xitem.CUSTOMER_TRX_ID = 'CASH Admin Fee for Affection Plan';
        xitem.AR_INVOICE_NUMBER = 'inv-002';
        xitem.INVOICE_DATE = '16-Dec-2006';
        xitem.INVOICE_TYPE = 'booking';
        xitem.NET_OUTSTANDING = '50,000';
        xitem.SCHEDULE_DATE = '10-Dec-2007';
        xitem.AMOUNT_CREDITED = '30,000';
        xitem.ACTUAL_AMOUNT = '90,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '1';
        xitem.PAYMENT_SCHEDULE_ID = '77423';
        xitem.CUSTOMER_TRX_ID = 'NOC for Land Department Resale Fee';
        xitem.AR_INVOICE_NUMBER = 'inv-001';
        xitem.INVOICE_TYPE = 'token';
        xitem.NET_OUTSTANDING = '11,000';
        xitem.INVOICE_DATE = '13-Dec-2006';
        xitem.SCHEDULE_DATE = '13-Dec-2006';
        xitem.AMOUNT_CREDITED = '9,000';
        xitem.ACTUAL_AMOUNT = '30,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);
        
        xitem = new ERPAPIResponse.X_SCHEDULES_ITEM();
        xitem.SEQ = '2';
        xitem.PAYMENT_SCHEDULE_ID = '88630';
        xitem.CUSTOMER_TRX_ID = 'CASH Admin Fee for Affection Plan';
        xitem.AR_INVOICE_NUMBER = 'inv-002';
        xitem.INVOICE_DATE = '16-Dec-2006';
        xitem.INVOICE_TYPE = 'booking';
        xitem.NET_OUTSTANDING = '50,000';
        xitem.SCHEDULE_DATE = '10-Dec-2007';
        xitem.AMOUNT_CREDITED = '30,000';
        xitem.ACTUAL_AMOUNT = '90,000';
        xitem.CURRENCY1 = 'AED';
        scheduleItems.add(xitem);*/
    }
    
    @AuraEnabled
    public Static List<Opportunity> fetchOpportunity(Id accountId) {
        return [Select Id, Name FROM Opportunity WHERE AccountId = : accountId Order By Name];
    }
    
    @AuraEnabled
    public Static Id generateAccountStatement(Id opportunityId) {
        //List<ERPAPIResponse.X_SCHEDULES_ITEM> scheduledItems = ERPAPIIntegration.generateAccountStatement(opportunityId);
        //System.debug('@@@@@: ' + scheduledItems);
        Id custStatementId = ERPAPIIntegration.generateAccountStatement(opportunityId);
        if(custStatementId != null) {
            
        }
        return custStatementId;
    }
}