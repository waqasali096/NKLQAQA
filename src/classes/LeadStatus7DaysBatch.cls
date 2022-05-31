/**
* Class Name: LeadStatus7DaysBatch
* Class Description: it will send email alert to lead owner, when the status of lead has not been changed for 7 days. 
* @param: Query - It will hold the query of lead record.
* @param: leadIds - Id of all lead record whose status is other than disqualified or Converted.
* @param: mails - List of single email that are need to send to lead owner.
* * @return: Void                                           
*/
global class LeadStatus7DaysBatch implements Database.Batchable<Sobject>, Database.stateful {
    global  Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Owner.Email, OwnerId, Status FROM Lead Where Status != \'Converted\' AND Status != \'Disqualified\' ';
        system.debug('Query--->'+ query);
        system.debug('In Start Method');
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> leadList){
        System.debug('In Execute');
        Set<Id> leadIds = New Set<Id>();
        List<Lead> leadListToUpdate = New List<Lead>();
        List<messaging.SingleEmailMessage> mails = New List<messaging.SingleEmailMessage>();
        EmailTemplate emailtemplate = New EmailTemplate();
        emailtemplate = [select Id, Name, Subject, Body From EmailTemplate Where name = 'Lead: Status is not changed for 7 days'];
        String templateBody ;
        String templateSubject ;
        
        system.debug('LeadList--->'+leadList.Size());
        for(Lead lead:leadList){
            leadIds.add(lead.Id); 
        }
        system.debug('Id set Size'+ leadIds.Size());
        for(LeadHistory leadHistory : [SELECT Id, LeadId, CreatedDate, Field FROM LeadHistory where LeadId IN:leadIds AND (Field = 'Status' OR Field = 'Created') AND CreatedDate = Last_N_Days:7 ]){
            if(leadIds.contains(leadHistory.LeadId)){
                leadIds.remove(leadHistory.LeadId);
            }
        }
        for(Lead lead:[SELECT Id,Name, Owner.email, Owner.Name From Lead Where Id IN:leadIds]){
          
            messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
            templateBody = emailtemplate.Body;
            if(lead.Owner.Name != Null){
                templateBody = templateBody.replace('{!Lead.OwnerFullName}',lead.Owner.Name);
            }
            templateBody = templateBody.replace('{!Lead.Name}',lead.Name);
            templateSubject = emailtemplate.Subject;
            mail.setSubject(templateSubject);
            mail.setPlainTextBody(templateBody);
            mail.settemplateid(emailtemplate.id);
            mail.setTargetObjectId(lead.OwnerId);
            mail.setSaveAsActivity(false);
            mails.add(mail);
          
        }
      
        system.debug('Limit --->'+ limits.getDmlStatements());
        try {
            if(mails.size() > 0){
                Messaging.SendEmailResult[] results =Messaging.sendEmail(mails);
                System.debug(results);   
                if(results.size() > 0){
                    if(results.get(0).isSuccess()){
                        System.debug('Success'+results);
                    }
                }
                
            }
            
        }catch(Exception e) {
            system.debug('Email not sent'+e.getMessage());
        }
    }
    global void finish(Database.BatchableContext bc){
        system.debug('In Finish Method');
    }
    
    
}