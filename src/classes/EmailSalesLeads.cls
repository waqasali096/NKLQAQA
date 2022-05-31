/**
* Class Name: handleInboundEmail
* Class Description: Creates Lead records as Lead Source Email with FirstName and LastName from Email for Leasing also create the EmailMessage
Record to display the Email Thread on Activity Timeline.
* CreatedBy - Rahul Shukla

*/
global class EmailSalesLeads  implements Messaging.InboundEmailHandler {
    /**
* Method Name: handleInboundEmail
* Method Description: Insert email for inbound email.
* @param: leadList - List of lead records,
* 
* @return: InboundEmailResult                                           
*/
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try{
            Group gp = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Lead_Queue' LIMIT 1];
            list<lead> leadsToinsert = new list<lead>(); 
            lead led =new Lead();
            led.FirstName = email.fromName.substring(0,email.fromname.indexOf(' '));
            led.LastName = email.fromName.substring(email.fromName.indexOf(' '));
            led.Email =envelope.fromAddress;
            led.Description = email.plainTextBody;
            led.LeadSource= 'Email'; 
            led.Duplicate_Checbox__c = true;
            led.Interested_In__c='Sales';
            led.OwnerID = gp.ID;
            led.Country_Code__c = null;

            leadsToinsert.add(led);
            insert leadsToinsert;                             
            system.debug('created lead' +led.Id);
            
            
            EmailMessage em = new EmailMessage();
            em.FromAddress = envelope.fromAddress;
            em.FromName = email.fromName;
            em.Subject = email.Subject;
            em.Incoming = false;
            em.Status = '3';
            em.TextBody = email.plainTextBody;
            em.ToAddress = email.toAddresses[0];
            em.BccAddress = 'info@brokers.nakheel.com';
           // em.ValidatedFromAddress = email.toAddresses[0];
            insert em;
            
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.emailMessageId = em.Id; //Email Message Id,
            emr.relationId = led.Id; //Lead Id, .....
            emr.relationType = 'FromAddress'; 
            insert emr;
            //New Code End...
            
        }catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
        return result;
    }
    
}