public without sharing class ExistingAgencyRegistrationFormController {
	
    @AuraEnabled
    public static Broker__c getAgencyRecord(string email,String brokerNumber ){//string phoneCode, string phone){

        system.debug('email=====' + email);
        system.debug('brokerNumber=====' + brokerNumber);
        list<Broker__c> brokerList = [SELECT Id, Name, Email_Address__c, Home_Phone__c ,Mobile__c,Mobile_Country_Code__c
                                      FROM Broker__c
                                      WHERE Email_Address__c =: email AND Broker_Number__c =:brokerNumber]; //(Mobile__c =: phone AND Mobile_Country_Code__c =: phoneCode)];
        
        if(brokerList != null && brokerList.isEmpty() == false){
            system.debug('brokerList is '+ brokerList);
            return brokerList[0];
        }else{
            return null;
        }
    }
    /**
     * This method is used to genrate OTP and send it via SMS/Email
     * @date    2021-06-07
     * @author  Shraddha Patil
     */
    /*Not Required- Mamta*/
    /*
    @AuraEnabled
    public static string getOpts(string recordId, String toMobileNumber, String templateName, String emailAdd){
        string str = string.valueof(Math.abs(Crypto.getRandomLong()));
        string otpString = str.substring(0, 6);
        string senderName = '';
        system.debug('otpString:'+otpString);

        SMSTemplate__mdt smsTemplate = SMSNotificationHelper.getSMSTemplate(templateName);
        system.debug('==smsTemplate=='+smsTemplate);
        string smsText = '';
        String Name =[SELECT Id, Name, Email_Address__c, Home_Phone__c ,Mobile__c,Mobile_Country_Code__c
                                      FROM Broker__c where id=:recordId].Name;
        if(smsTemplate != null){
            smsText = smsTemplate.TemplateBody__c;
            smsText = smsText.replace('{!OTP}', otpString);
            smsText = smsText.replace('{!CustomerName}', 'User');
            senderName = smsTemplate.Sender__c;
        }
        
        if(String.isNotBlank(toMobileNumber) && String.isNotBlank(smsText) && String.isNotBlank(senderName)){
            SMSNotificationHelper.buildSMSRequest(toMobileNumber, smsText, senderName);
        }
        if( emailAdd != null){
            system.debug('==emailAdd=='+emailAdd);
            sendOptEmail(new List<String> {emailAdd}, 'User', recordId, otpString);
        }

        return otpString;
    }
    
    /**
     * This method is used to sending OTP to customer via Email
     * @date    2021-06-07
     * @author  Shraddha Patil
     */
/*    
    public static void sendOptEmail(List<String> recipientList, string customerName, string parentId, string otpString){
        
        EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body 
                                       from EmailTemplate 
                                       where DeveloperName =: ConstantUtility.CUSTOMER_VERIFICATION_BY_OTP];
        
        string emailBody = emailTemplate.Body.replace('{!Case.Account}', customerName);
        emailBody = emailBody.replace('{!OTP}', otpString);
        system.debug('==emailTemplate.Body='+emailTemplate.Body);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(recipientList);
        email.setSubject(emailTemplate.Subject);
        //email.setTargetObjectId(userInfo.getUserId());
        //email.setSaveAsActivity(false);
        email.setWhatId(parentId);
        email.setPlainTextBody(emailBody);
        //email.setTemplateId(emailTemplate.Id);
        system.debug('==email=='+email);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
*/    
}