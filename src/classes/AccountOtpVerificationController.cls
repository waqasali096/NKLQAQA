/**
* 
* Controller class which used for verify customer identity by OTP
* @date    2021-06-07
* @author  hitesh saini
*/
public class AccountOtpVerificationController {

    @AuraEnabled
    public static Integer getTimeOutMinutes(String strHandlerName){
        Integer intMinutes = 1;
        List<SMS_Handler__mdt> listSMSHandler = [SELECT Id, Timeout_in_Minutes__c
                                                  FROM SMS_Handler__mdt 
                                                  WHERE DeveloperName =: strHandlerName LIMIT 1];
        
        if(!listSMSHandler.isEmpty()){
            if(listSMSHandler[0].Timeout_in_Minutes__c != null){
                intMinutes = Integer.valueOf(listSMSHandler[0].Timeout_in_Minutes__c);
            }
        }
        return intMinutes;
    }
   
    /**
     * This method is used to get account record by account id
     * @date    2021-06-07
     * @author  hitesh saini
     */
    @AuraEnabled
    public static List<Account> getAccount (Id AccountId){
        return new List<Account>([Select id, Name, Primary_Mobile__c, Primary_Email__c, Primary_Country_Code__c, Secondary_Mobile__c, IsPersonAccount,RecordType.Name, RecordType.DeveloperName
                                  From Account 
                                  Where Id =: AccountId ]);
    }
    /**
     * This method is used to update secondary mobile number on account
     * @date    2021-06-07
     * @author  hitesh saini
     */
    @AuraEnabled
    public static void updateAccount (Id AccountId, String secondaryMobile){
        system.debug('AccountId' + AccountId);
        system.debug('secondaryMobile' + secondaryMobile);
        Account acc = getAccount(AccountId)[0];
        acc.Secondary_Mobile__c = secondaryMobile;
        update acc;
    }
    /**
     * This method is used to genrate OTP and send it via SMS/Email
     * @date    2021-06-07
     * @author  hitesh saini
     */
    @AuraEnabled
    public static string getOpt(String AccountId, String customerName, String toMobileNumber){
        string str = string.valueof(Math.abs(Crypto.getRandomLong()));
        string otpString = str.substring(0, 6);
        string senderName = '';
        system.debug('otpString:'+otpString);
        system.debug('==AccountId=='+ AccountId);
        
        SendOTPSMS(AccountId, toMobileNumber, otpString, customerName);
        
        /*Account accountRecord = [SELECT Id, Name, Primary_Email__c 
                                 from account 
                                 where Id =: AccountId];
        
        if(accountRecord != null && accountRecord.Primary_Email__c != null){
           
            //call the SMS service 
        }*/
        
        return otpString;
    }
    
     @AuraEnabled
    public static void updateAccOtpVerifyFlag(String accId){
        
        try{
            Account a=new Account();
            a.id=accId;
            a.accOtpVerifiedFlag__c=true;
            update a;
        }
        catch(exception e){
            system.debug('ErrorOccured in updateAccOtpVerifyFlag'+e.getMessage());
            system.debug('line number '+e.getLineNumber());
        }
        
    }
    
     /* Send SMS to a mobile number with 6 digit- OTP */
    //public static void SendOTPSMS (String accountId, String toMobileNumber,String templateName,String otpString, string customerName){
    public static void SendOTPSMS (String accountId, String toMobileNumber, String otpString, string customerName){
      
     
        if(String.isNotBlank(toMobileNumber)){
            system.debug('Calling sendSMSNotification');
            //sendSMSNotification(toMobileNumber, smsText/*, senderName*/);
            
            Unit_HandlerSMS.SMSWrapper wrapper = new Unit_HandlerSMS.SMSWrapper();
            wrapper.publicDistributionURL = '';
            wrapper.objId = accountId;
            wrapper.SendSMSfor = 'OTP';
            wrapper.phoneNumberWithCountryCode = toMobileNumber;
            wrapper.objectName = 'Account';
            wrapper.customerName = customerName;
            wrapper.otp = otpString;            
            Unit_HandlerSMS.callSmsApiGeneric(wrapper);
        }
    }
    
    @Future(callout=true)
    private static void sendSMSNotification(String to, String text) {
        try {
            /*system.debug('Inside sendSMSNotification');
            system.debug('to >>>>'+to);
            system.debug('text>>>>'+text);
            SMS smsJson = new SMS();
            smsJson.to = formatMobile(to); //format mobile number before sending sms
            smsJson.text = text;
            String jsonBody = Json.serialize(smsJson);
             
            Map<String,SMS_Credential__mdt> credentials = SMS_Credential__mdt.getAll();
            String USERNAME = credentials.get('Username').Value__c;
            String PASSWORD = credentials.get('Password').Value__c;
            String BASE_URL = credentials.get('Endpoint').Url__c;
            String MSG = credentials.get('Message').Message__c;*/
            
            //createXMLDoc(String MSG, String username, String password, String ph_number){
           /* String xmlString = SMSHelper.createXMLDoc('Hello',USERNAME,PASSWORD , '+971547933854');
            xmlString=xmlString.replace('<MESSAGE>', '<!DOCTYPE MESSAGE SYSTEM "http://127.0.0.1:28080/psms/dtd/messagev12.dtd"><MESSAGE VER="1.2">');                
            // System.debug('XML String : '+xmlString);
            String ecodedXmlString = EncodingUtil.urlEncode(xmlString, 'ISO-8859-1');
            ecodedXmlString ='data='+ecodedXmlString+'&action=send';*/
            
            /*HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod('POST');
            //httpRequest.setHeader('Authorization', 'App '+SMSSetting[0].APIKey__c );
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setHeader('Accept', 'application/json');
            //httpRequest.setEndpoint('callout:Send_SMS_Endpoint');
            httpRequest.setEndpoint(BASE_URL);

            httpRequest.setBody(jsonBody);
            system.debug('******jsonBody= '+jsonBody);
            String response = '';

            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == 200) {
                response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                system.debug('******response= '+response);
            } else {
                throw new CalloutException(httpResponse.getBody());
            }*/

        } catch (System.Exception e) {
            system.debug('******sendSMSNotification exception= '+e.getMessage()+ 'at Line number '+ e.getLineNumber());
        }
    }
    
     public class SMS {
        public String to { get; set; }
        public String text { get; set; }
    }
     /**
     * Format mobile number - add prefix if missing
     * @param customerMobile
     * @return
     */
    private static String formatMobile(String customerMobile) {
        if (customerMobile != null && customerMobile.length() == 10 &&
                !(customerMobile.contains('+971') || customerMobile.contains('+971') || customerMobile.contains('0971'))) {
            customerMobile = customerMobile.replaceFirst('0', '+971');
        }
        return customerMobile;
    }
}