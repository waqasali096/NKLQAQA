/**
* @author Mamta Gupta
* @date 2 Sep 2021
* @purpose - Initial Development
* @usage -Common helper class for email
*/

public class EmailNotificationHelper {
    public static OrgWideEmailAddress getOrgWideEmailAddress(string address){
        return [SELECT Id, Address 
                from OrgWideEmailAddress 
                where Address =: address];
    }
    
    public static list<EmailTemplate> getEmailTemplateByName(set<string> emailTemplateName){
        return [Select Id, Subject, Description, HtmlValue, DeveloperName, Body 
                from EmailTemplate 
                where DeveloperName in: emailTemplateName];
    }
    
    public static Messaging.SingleEmailMessage buildEmailRequest(String[] toEmailList, string emailTemplateId, string targetObjectId, string orgWideEmailAddressId){
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplateId, null, targetObjectId);
        message.setWhatId(targetObjectId);
        if(orgWideEmailAddressId != null && orgWideEmailAddressId != null){
            message.setOrgWideEmailAddressId(orgWideEmailAddressId);
        }else{
            message.setSenderDisplayName(ConstantUtility.EMAIL_SUPPORT); 
        }
        
        message.toAddresses = toEmailList;
        
        return message;
    }
    
    public static void sendEmail(Messaging.SingleEmailMessage[] emailMessagesList){
        if(emailMessagesList.isEmpty() == false){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessagesList);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            }else {
                System.debug('The email failed to send:' +  results[0].errors[0].message);
            }
        }
    }

}