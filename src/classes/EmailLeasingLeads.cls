/**
* Class Name: handleInboundEmail
* Class Description: Creates Lead records as Lead Source Email with FirstName and LastName from Email for Leasing also create the EmailMessage
Record to display the Email Thread on Activity Timeline.
*                                      
* CreatedBy - Rahul Shukla

*/

global class EmailLeasingLeads  implements Messaging.InboundEmailHandler {
    /**
* Method Name: handleInboundEmail
* Method Description: Insert email for inbound email.
* @param: leadList - List of lead records,
* 
* @return: InboundEmailResult                                           
*/
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
       /* Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try{
            list<lead> leadsToinsert = new list<lead>(); 
            lead led =new Lead();
            led.FirstName = email.fromName.substring(0,email.fromname.indexOf(' '));
            led.LastName = email.fromName.substring(email.fromName.indexOf(' '));
            led.Email =envelope.fromAddress;
            led.Description = email.plainTextBody;
            led.LeadSource= 'Email';
            led.Duplicate_Checbox__c = true;
            led.Interested_In__c='Residential Leasing';
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
            insert em;
            System.debug('ToAddress : '+email.toAddresses[0]);
            System.debug('ToAddress from Evelop : '+envelope.toAddress);
            
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.emailMessageId = em.Id; //Email Message Id
            emr.relationId = led.Id; //Lead Id, .....
            emr.relationType = 'FromAddress'; 
            insert emr;
            
            
            
        }catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
        
        return result;*/
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try{
            list<lead> leadsToinsert = new list<lead>(); 
            list<lead> ExistingleadsList = new list<lead>();
            Id residentialUnit = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Unit').getRecordTypeId();
            Id commercialUnit = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Shop').getRecordTypeId();
            Boolean keywordMatch = false;
            ExistingleadsList = [Select id from Lead where email =: envelope.fromAddress];
            System.debug('Existing Lead : '+ExistingleadsList);
            lead led =new Lead();
            led.FirstName = email.fromName.substring(0,email.fromname.indexOf(' '));
            led.LastName = email.fromName.substring(email.fromName.indexOf(' '));
            led.Email =envelope.fromAddress;
            led.Description = email.plainTextBody;
            led.LeadSource= 'Email'; 
            led.Duplicate_Checbox__c = true;
            List<String> ResidentialKeywords = System.label.Residential_Email_Leads.split(',');
            List<String> CommercialKeywords = System.label.Commercial_Email_Leads.split(',');
            
            String subjectAndDesc = email.subject +' '+ email.plainTextBody;
            
            for(String description: subjectAndDesc.split(' ')){
                if(CommercialKeywords.contains(description.toUpperCase())){
                    led.Interested_In__c='Commercial Unit';
                    led.RecordTypeId = commercialUnit;
                    keywordMatch = true;
                    break;
                }else if(ResidentialKeywords.contains(description.toUpperCase())){
                    led.Interested_In__c='Residential Leasing';
                    led.RecordTypeId = residentialUnit;
                    keywordMatch = true;
                    break;
                }
            }
            
            if(!keywordMatch){
                led.Interested_In__c='Residential Leasing';
                led.RecordTypeId = residentialUnit;
            }            
            leadsToinsert.add(led);
            System.debug('Before Lead Insertion');
            insert leadsToinsert;     
            System.debug('After Lead Insertion');
        
  
             //update leadsToupdate
           // system.debug('created lead' +led.Id);
            
            EmailMessage em = new EmailMessage();
            em.FromAddress = envelope.fromAddress;
            em.FromName = email.fromName;
            em.Subject = email.Subject;
            em.Incoming = true;
            em.Status = '3';
            em.TextBody = email.plainTextBody;
            em.ToAddress = email.toAddresses[0];
            em.BccAddress = 'info@brokers.nakheel.com'; //'rahul.shukla@cloudworks.ae';
           // em.RelatedToId = led.id;
           System.debug('Before EmailMessage Insertion');
            insert em;
            System.debug('After EmailMessage Insertion');
            
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.emailMessageId = em.Id; //Email Message Id
            emr.relationId = led.Id; //Lead Id, .....
            emr.relationType = 'FromAddress'; 
            System.debug('Before EmailMessageRelation Insertion');
            insert emr;
            System.debug('After EmailMessageRelation Insertion');
            
            
            
        }catch(Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
        }
        
        return result;
    }
    
}