/**************************************************************************************************
* Name               : CCAvenueCallout                                                      
* Description        : Class is used to generate payment link for Online Transactions
* Module			 : Sales, Leasing
* Created Date       : 01/01/2022                                                                
* Created By         : Cloudworks                                                                       
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Ashams    30/05/2022     Removed Hardcoding, SMS & Email Contents changed                                             
**************************************************************************************************/

public class CCAvenueCallout{
    //attributes for default values from CC Avenue Metadata
    public static String name;
    public static String locationCode;
    public static String amount;
    public static String primary_contact_number;
    public static String primary_email_id;
    public static String body;
    public static String encryptedRequest;
    public static String emailSubject;
    public static String invDescription;
    public static String billDeliveryType;
    public static String currencyType;
    public static String validType;
    public static String validFor;
    public static String vatValue;
    
    //attributes for api names from CC Avenue Metadata
    public static final String ENC_KEY;
    public static final String MERCHANT_ID;
    public static final String ACCESS_CODE;
    public static final String IV;
    public static final String ENDPOINT;
    
    public static final String CUST_NAME;
    public static final String M_REF;
    public static final String BILL_DEL_TYPE;
    public static final String CUST_EMAIL;
    public static final String EMAIL_SUB;
    public static final String CUST_MOB;
    public static final String INV_DESC;
    public static final String CURRENCY_TYPE;
    public static final String VALID_FOR;
    public static final String VALID_TYPE;
    public static final String AMT;
    public static final String VAT;
    
    //fetching values from CC Avenue Metadata
    static{
        Map<String,CCAvenue__mdt> credentials = CCAvenue__mdt.getAll();
        ENC_KEY = credentials.get('Enc_Key').Value__c;
        MERCHANT_ID = credentials.get('Merchant_Id').Value__c;
        ACCESS_CODE = credentials.get('Access_code').Value__c;
        IV = credentials.get('IV').Value__c;
        ENDPOINT = credentials.get('Endpoint').Url__c;
        
        CUST_NAME = credentials.get('Customer_Name').Value__c;
        M_REF	=	credentials.get('Merchant_No').Value__c;
        BILL_DEL_TYPE =	credentials.get('Bill_Delivery_Type').Value__c;
        CUST_EMAIL	= credentials.get('Customer_Email_ID').Value__c;
        EMAIL_SUB	= credentials.get('Email_Subject').Value__c;
        CUST_MOB = 	credentials.get('Mobile_No').Value__c;
        INV_DESC =	credentials.get('Invoice_Description').Value__c;
        CURRENCY_TYPE =	credentials.get('Currency').Value__c;
        VALID_FOR =	credentials.get('Validity').Value__c;
        VALID_TYPE = credentials.get('Validity_Type').Value__c;
        AMT = credentials.get('Amount').Value__c;
        VAT = credentials.get('VAT').Value__c;
        
        emailSubject = credentials.get('Email_Subject').Default_Value__c;
        invDescription = credentials.get('Invoice_Description').Default_Value__c;
        billDeliveryType = credentials.get('Bill_Delivery_Type').Default_Value__c;
        currencyType = credentials.get('Currency').Default_Value__c;
        validType = credentials.get('Validity_Type').Default_Value__c;
        validFor = credentials.get('Validity').Default_Value__c;
        vatValue = credentials.get('VAT').Default_Value__c;
    } 
    
    /*
	@Author : Ashams
	@CreatedDate: 01/01/2022
	@Usage : This method will construct the request body for online payments
	@params : id - receipt recordId
	*/
    @AuraEnabled
    public static void calloutPrepration(String id){
        Set<string> salesRecordTypes = new Set<string>{'Deal_Unit_Sold','Deal_Read_Only','Quick_Book','Sales_Opportunity'};
        Set<string> leasingRecordTypes = new Set<string>{'Commercial_Lease_Renewal','Residential_Leasing_Shop_Opportunity','Residential_Shops_Quick_Leasing','Lease_Renewal','Residential_Leasing_Unit_Corporate','Residential_Leasing_Unit_Opportunity','Leasing_Records'};
                
       	Receipt__c receiptRecord = [Select Id,Amount__c,
                                    Unit__c,unit__r.unit_code__c,
                                    Account__c,Account__r.Name,Account__r.Primary_Mobile__c, Account__r.Primary_Email__c,Account__r.Primary_Country_Code__c,
                                    Opportunity__c,Opportunity__r.RecordTypeDeveloperName__c 
                                    FROM Receipt__c WHERE Id =:id];
        
        if(receiptRecord.Opportunity__r.RecordTypeDeveloperName__c != null && salesRecordTypes.contains(receiptRecord.Opportunity__r.RecordTypeDeveloperName__c)){
            body = getcredentialsSales(receiptRecord);
        }else if(receiptRecord.Opportunity__r.RecordTypeDeveloperName__c != null && leasingRecordTypes.contains(receiptRecord.Opportunity__r.RecordTypeDeveloperName__c)){
            body = getcredentialsLeasing(receiptRecord);
        }
        
        encryptedRequest = CCAvenueCallout.encryptRequest(body);
        String url = ENDPOINT+'?access_code='+ACCESS_CODE+'&command=generateQuickInvoice&request_type=JSON&version=1.1&enc_request='+encryptedRequest;
        system.debug('[V] amount :'+ amount +' id :'+ id +' url :'+ url);
        
        CCAvenueCallout.callCCAvenue(url,id,amount);
    } 
    
    /*
	@Author : Ashams
	@CreatedDate: 01/01/2022
	@Usage : This method handles ccavenue response, invokes SMS handler
	@params : id(receipt recordId), url, amount
	*/
    @future(Callout=true)    
    public static void callCCAvenue(String url,String id,String amount){
        
        List<Payment_Milestone__c> paymentMilestoneList = new List<Payment_Milestone__c>();
        List<Receipt_Milestone__c> receiptMilestoneList = new List<Receipt_Milestone__c>();
        List<Receipt__c> paymentList = new List<Receipt__c>();
        
        HTTP http = new HTTP();
        HTTPRequest request = new HTTPRequest();
        HttpResponse response;
        request.setEndpoint(url);
        request.setMethod('POST');
        try{
            response = http.send(request);
            /*System.debug(' Response '+response.getBody());
            System.debug(' Response getStatusCode '+response.getStatusCode());*/
        }catch(Exception e){
            System.debug(' CCAvenue error '+ e.getMessage());
        }        
        
        if(response.getStatusCode() == 200){
            String message;
            String tinyUrl;
            String invoice_Id;
            String encResponse = response.getBody();
            encResponse = encResponse.replace('status=0&enc_response=','').trim();
            String decryptedResponse = CCAvenueCallout.decryptResponse(encResponse);
            /*System.debug('Encrypted Value ==> '+encResponse);
            System.debug('Decrypted Value :'+decryptedResponse);*/
            
            System.JSONParser jp = JSON.createParser(decryptedResponse);
            
            while(jp.nextToken() != null){
                if(jp.getText() == 'tiny_url'){
                    jp.nextToken();
                    tinyUrl = jp.getText();
                }
                if(jp.getText() == 'invoice_id'){
                    jp.nextToken();
                    invoice_Id = jp.getText();
                }
            }

            Id idToProccess = id;              
            String sobjectType = idToProccess.getSObjectType().getDescribe().getName();
            //system.debug('%%sobjectType'+sobjectType);
            
            if(sobjectType == 'Receipt__c'){
                Receipt__c updatePayment = [Select id,Account__r.Name,Invoice_ID__c, Payment_URL__c,Opportunity__c, Payment_Mode__c, Amount__c from Receipt__c where Id=:id];
                SMS_Handler__mdt smsHandler = [SELECT Id, SObject_Name__c, Send_SMS_for__c, Message_Body__c FROM SMS_Handler__mdt 
                                             WHERE SObject_Name__c =: 'Receipt__c' AND Send_SMS_for__c=: 'Online Payments' LIMIT 1];
                if(smsHandler!=null){
                    message = smsHandler.Message_Body__c;
                    if(message.contains('{!CustomerName}')) message = message.replace('{!CustomerName}',updatePayment.Account__r.Name );
                    if(message.contains('{!Amount}')) message = message.replace('{!Amount}',string.valueof(updatePayment.Amount__c));
                    if(message.contains('{!Invoice_number}')) message = message.replace('{!Invoice_number}',invoice_Id);
                    if(message.contains('{link}')) message = message.replace('{link}',tinyUrl);
                }
                system.debug('%%CCAvenue SMS Message'+message);
                
                String encodedXmlString = Unit_HandlerSMS.callSmsApiForPayment(message,invoice_Id,updatePayment.Opportunity__c,updatePayment.Payment_Mode__c);
                request.setEndpoint(Unit_HandlerSMS.BASE_URL);
                request.setBody(encodedXmlString);
                http.send(request);
                
                updatePayment.Invoice_ID__c = invoice_Id;
                updatePayment.Payment_URL__c = tinyUrl;
                paymentList.add(updatePayment);   
            }
            if(sobjectType == 'Opportunity'){
                Opportunity opportunityRecord = [Select id,Name,(Select id, Name, Receipt__c from Payment_Milestones__r), AccountID from Opportunity where id =:id];
                
                Receipt__c receiptRecord = new Receipt__c();
                receiptRecord.Name = opportunityRecord.name+' Receipt';
                receiptRecord.Invoice_ID__c = invoice_Id;
                receiptRecord.Payment_URL__c = tinyUrl;
                receiptRecord.Account__c = opportunityRecord.AccountId;
                receiptRecord.Opportunity__c = opportunityRecord.id;
                receiptRecord.Payment_Link_Sent__c = true;
                receiptRecord.Amount__c = Decimal.valueOf(amount);
                insert receiptRecord;
                
                for(Payment_Milestone__c pMile : opportunityRecord.Payment_Milestones__r){
                    Receipt_Milestone__c receiptMilestoneRecord = new Receipt_Milestone__c();
                    receiptMilestoneRecord.Installments__c = pMile.id;
                    receiptMilestoneRecord.Receipt__c = receiptRecord.id;
                    receiptMilestoneList.add(receiptMilestoneRecord);
                }
            }
        }
        
        if(paymentList.size()>0 && paymentList != null){
            upsert paymentList;
        }
        if(paymentMilestoneList.size() >0 && paymentMilestoneList != null){
            update  paymentMilestoneList;
        }
        if(receiptMilestoneList.size() >0 && receiptMilestoneList != null){
            insert receiptMilestoneList;
        }
    }
    
    /*
	@Author : Ashams
	@CreatedDate: 01/01/2022
	@Usage : create resquest body for sales 
	@params : receipt record
	*/
    public static string getcredentialsSales(Receipt__c receiptRecord){
        string requestBody;
        if(receiptRecord!=null){
            amount = String.valueOf(receiptRecord.Amount__c);
            locationCode = String.valueOf(receiptRecord.unit__r.unit_code__c);
            primary_contact_number = receiptRecord.Account__r.Primary_Country_Code__c + receiptRecord.Account__r.Primary_Mobile__c;
            primary_contact_number = primary_contact_number.replace('+','');
            if(primary_contact_number.length()<10){
                primary_contact_number = null;
            }
            primary_email_id = receiptRecord.Account__r.Primary_Email__c;
            name = receiptRecord.Account__r.name;
            invDescription = invDescription.replace('<Amt>',amount).replace('<LocationCode>',locationCode);
            
            requestBody = '{"'+CUST_NAME+'":"'+name+'","'+M_REF+'":"'+MERCHANT_ID+'","'+BILL_DEL_TYPE+'":"'+billDeliveryType+'","'
                +CUST_EMAIL+'":"'+primary_email_id+'","'+EMAIL_SUB+'":"'+emailSubject+'","'
                +CUST_MOB+'":"'+primary_contact_number+'","'+INV_DESC+'":"'+invDescription+'","'
                +CURRENCY_TYPE+'":"'+currencyType+'","'+VALID_FOR+'":"'+validFor+'","'
                +VALID_TYPE+'":"'+validType+'","'+AMT+'":"'+amount+'","'+VAT+'":"'+vatValue+'"}';
        }
        return requestBody;
    }
    
    /*
	@Author : Ashams
	@CreatedDate: 01/01/2022
	@Usage : create resquest body for leasing 
	@params : receipt record
	*/
    public static string getcredentialsLeasing(Receipt__c receiptRecord){
        string requestBody;
        if(receiptRecord!=null){
            amount = String.valueOf(receiptRecord.Amount__c);
            locationCode = String.valueOf(receiptRecord.unit__r.unit_code__c);
            primary_contact_number = receiptRecord.Account__r.Primary_Country_Code__c + receiptRecord.Account__r.Primary_Mobile__c;
            primary_contact_number = primary_contact_number.replace('+','');
            if(primary_contact_number.length()<10){
                primary_contact_number = null;
            }
            primary_email_id = receiptRecord.Account__r.Primary_Email__c;
            name = receiptRecord.Account__r.name;
            invDescription = invDescription.replace('<Amt>',amount).replace('<LocationCode>',locationCode);
            
            requestBody = '{"'+CUST_NAME+'":"'+name+'","'+M_REF+'":"'+MERCHANT_ID+'","'+BILL_DEL_TYPE+'":"'+billDeliveryType+'","'
                +CUST_EMAIL+'":"'+primary_email_id+'","'+EMAIL_SUB+'":"'+emailSubject+'","'
                +CUST_MOB+'":"'+primary_contact_number+'","'+INV_DESC+'":"'+invDescription+'","'
                +CURRENCY_TYPE+'":"'+currencyType+'","'+VALID_FOR+'":"'+validFor+'","'
                +VALID_TYPE+'":"'+validType+'","'+AMT+'":"'+amount+'","'+VAT+'":"'+vatValue+'"}';
        }
        return requestBody;
    }
    
    @AuraEnabled(Cacheable = true)  
    public static Receipt__c controlComponentVisibility(String id){
        Boolean isOnline = false;
        Receipt__c pay = [Select id, Payment_Mode__c, Amount__c, Description__c from Receipt__c where id =:id];
        return pay;
    }
    
    public static String encryptRequest(String data){
        return EncodingUtil.convertToHex(
            Crypto.encrypt('AES128', 
                           Crypto.generateDigest('MD5', Blob.valueOf(ENC_KEY) ), 
                           EncodingUtil.convertFromHex(IV), 
                           Blob.valueOf(data))
        );
    } 
    
    public static String decryptResponse(String encryptedResponse){
        String value = Crypto.decrypt('AES128', 
                                      Crypto.generateDigest('MD5', Blob.valueOf(ENC_KEY) ), 
                                      EncodingUtil.convertFromHex(IV), 
                                      EncodingUtil.convertFromHex(encryptedResponse)).toString();
        System.debug('Value ===>'+value);
        return value;
    } 
}