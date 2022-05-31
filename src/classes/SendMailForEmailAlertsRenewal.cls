global class SendMailForEmailAlertsRenewal {
     global class InvokeSendEmail {
        
        @InvocableVariable(label='Email Alert Name' description='API Name of Email alert' required=true)
        global String EmailAlertAPIName;
        
        @InvocableVariable(label='Record Id' description='Contact/Lead ID required if you use this' required=false)
        global Id RecordId;
        
    }
    @InvocableMethod(label='Send Email for Email Alert' description='send email to customer with dynamic attachment')//Commented By Mamta
   // @InvocableMethod(label='Send Email for Email Alert Renewal' description='send email to customer with dynamic attachment')//Added By Mamta

    
    Public static Void sendEmail(List<InvokeSendEmail> requests){
        Contact con = new Contact();
        con.FirstName = 'temp';
        con.LastName = 'Contact';
        insert con;
        List<String> emailalertList = New List<String>();
        for(InvokeSendEmail em : requests){
            emailalertList.add(em.EmailAlertAPIName);
        }
        System.debug('email alert name=== ' + emailalertList);
        send(emailalertList,requests[0].RecordId,con.Id);
    }
    
    
    public static Messaging.SingleEmailMessage send(List<String> emailalertList,Id RecordId,String contactId){
        
        //-----------------------------------------------------------------------------------------------------------------------------------------
        Id emtemplateid;
        Id Whatidfld;
        string[] recString = new List<String>();
        String sObjName = RecordId.getSObjectType().getDescribe().getName();
        
        system.debug('sObjName'+sObjName);
        List<Email_Alerts_Metadata__c> lstEmail =[SELECT Email_Alert_Developer_Name__c,Email_Alert_ID__c,Email_Template__c,From_Address__c,
                                                  To_Address__c,Email_Template_Response__c,Query_Field_Data__c
                                                  FROM Email_Alerts_Metadata__c where Email_Alert_Developer_Name__c IN:emailalertList LIMIT 1];
        
      
        if(lstEmail.size()>0){
            string query='Select id,lstEmail[0].Query_Field_Data__c from sObjName where id=:RecordId';
            system.debug('query is '+ lstEmail[0].Query_Field_Data__c );
            
            emtemplateid = lstEmail[0].Email_Template__c;
            if(lstEmail[0].To_Address__c!=null){
                recString.add(lstEmail[0].To_Address__c);
            }
            //String response1=lstEmail[0].Email_Template_Response__c;
            // SK_EmailAlertJSONParser   emailAlertDetails=new SK_EmailAlertJSONParser();
            // system.debug('res==='  + response1);
            
            /* try{
emailAlertDetails =(SK_EmailAlertJSONParser) System.JSON.deserialize(response1, SK_EmailAlertJSONParser.class);
system.debug('******emailAlertDetails:'+emailAlertDetails);
string ccEmails ='';
//emtemplateid = emailAlertDetails.TemplateId;
if(emailAlertDetails.Metadata!=null){
if(emailAlertDetails.Metadata.ccEmails.size()>0){
ccEmails = string.join(emailAlertDetails.Metadata.ccEmails,',');
}
if(emailAlertDetails.Metadata.recipients!=null){
if(emailAlertDetails.Metadata.recipients.size()>0){
List<String> emailsid = New List<String>();
emailsid.addAll(CustomEmailSendHelper.FetchUserEmails(emailAlertDetails.Metadata.recipients,RecordId));
system.debug('email===' + emailsid);
for(String emails :emailsid){
recString.add(emails);
}

}
}

}

}catch(exception ex){
system.debug('****exception for email alertid-'+objEmail);

}*/
            
            // }
            
        }
        //List<sObject> listOfRecords = Database.query('SELECT Id, '+ lstEmail[0].Query_Field_Data__c + ' FROM '+ sObjName + ' WHERE Id =:RecordId LIMIT 1');
        String sObjQuery = 'SELECT Id  ';
        if(lstEmail[0].Query_Field_Data__c !=null){
            sObjQuery+= ' , ' +  lstEmail[0].Query_Field_Data__c;
        }
        
        sObjQuery+= ' FROM  '+ sObjName + '  WHERE Id =:RecordId LIMIT 1';
        
        List<sObject> listOfRecords = Database.query(sObjQuery);
        
        system.debug('sObjName is '+ sObjName);
        
        
        EmailTemplate invTemplate = [ SELECT Id, Name, Subject,HtmlValue, Body FROM EmailTemplate  WHERE Id =: emtemplateid]; 
        system.debug('emailtemp=== ' + invTemplate);
        /*List<Attachment>  link = new List<Attachment> ();
link = [Select Name,Id,ContentType, Body From Attachment where parentId = :invTemplate.Id];
List<Messaging.EmailFileAttachment> attachmentList = new List<Messaging.EmailFileAttachment>();
if(link.size() > 0 && link != Null){
for(Attachment attach : link){
Messaging.EmailFileAttachment attachment = New Messaging.EmailFileAttachment();
attachment.setFileName(attach.Name);
attachment.setBody(attach.Body);
attachment.contenttype = 'application/pdf';
attachmentList.add(attachment);
}


}*/  
       /*Start - Added By Mamta 5 April */
       OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress();
       orgWideEmailAddress = [select id, Address, DisplayName from OrgWideEmailAddress Where DisplayName=:system.label.Org_Wide_Default_Address LIMIT 1 ];
       Messaging.SingleEmailMessage objSingleEmailMessage = Messaging.renderStoredEmailTemplate(String.valueOf(emtemplateid), null, String.valueOf(recordId));
       /*End - Added By Mamta 5 April */
        
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        if((String)listOfRecords[0].get(lstEmail[0].Query_Field_Data__c)!=null){
            recString.add((String)listOfRecords[0].get(lstEmail[0].Query_Field_Data__c));
        }
        email.setSubject(invTemplate.Subject);
        email.setToAddresses(recString);
        
        email.setTemplateId(emtemplateid);
        email.setTargetObjectId(contactId);
        //email.setHtmlBody(invTemplate.HtmlValue); //commented by Mamta- 5 April
        email.setSaveAsActivity(true);
        email.setTreatBodiesAsTemplate(true);
        email.setTreatTargetObjectAsRecipient(false);
        /*Start - Added By Mamta 5 April */
        if(objSingleEmailMessage.getHtmlBody()!=null){
           email.setHtmlBody(objSingleEmailMessage.getHtmlBody());
          }
        else{
           email.setPlainTextBody(objSingleEmailMessage.getPlainTextBody()); 
        }
        
        if(sObjName!='Lead'){
            email.setWhatId(RecordId);
            email.targetobjectid = contactId;
        }
        else{
            email.targetobjectid = RecordId;
        }
        if(orgWideEmailAddress!=null){
           email.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
         }
         /*End - Added By Mamta 5 April */
        
        system.debug('email=====' + email);
        //email.setFileAttachments(attachmentList);
        // Messaging.sendEmail(new Messaging.SingleEmailMessage[] {  }); 
        Messaging.sendEmailResult[] sendEmailResults =  Messaging.sendEmail(new Messaging.Email[] { email }, true);
        Boolean deleteContact = false;
        for(Messaging.SendEmailResult sendEmailResult: 
            sendEmailResults){
                
                //if(!sendEmailResult.isSuccess()){
                //deleteContact = true;
                // }
            }
        //if(deleteContact){
        Contact delCon = new Contact();
        delCon.Id = contactId;
        delete delCon;
        //}
        return email;
        
    }
    
    public static void sendEmailBulk(List<InvokeSendEmail> listInvokeSendEmail){        
        if(!listInvokeSendEmail.isEmpty()){
            String strEmailAlertAPIName = listInvokeSendEmail[0].EmailAlertAPIName;
            
            List<Messaging.SingleEmailMessage> listSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
            List<EmailMessage> listEmailMessage = new List<EmailMessage>();
            
            List<Email_Alerts_Metadata__c> listEmailAlertsMetadata =[SELECT Email_Alert_Developer_Name__c,Email_Alert_ID__c,Email_Template__c,From_Address__c,
                                                                     To_Address__c,Email_Template_Response__c,Query_Field_Data__c
                                                                     FROM Email_Alerts_Metadata__c 
                                                                     WHERE Email_Alert_Developer_Name__c =: strEmailAlertAPIName LIMIT 1];
            
            if(!listEmailAlertsMetadata.isEmpty()){
                Set<Id> setRecordId = new Set<Id>();
                List<String> listToAddressesDefault = new List<String>();
                String strObjectName;
                
                for(InvokeSendEmail objInvokeSendEmail : listInvokeSendEmail){
                    setRecordId.add(objInvokeSendEmail.RecordId); 
                }
                
                if(!setRecordId.isEmpty()){                
                    strObjectName = new List<Id> (setRecordId).get(0).getSObjectType().getDescribe().getName();
                       
                    String strEmailTemplateId = listEmailAlertsMetadata[0].Email_Template__c;
                    
                    if(listEmailAlertsMetadata[0].To_Address__c!=null){
                        listToAddressesDefault.add(listEmailAlertsMetadata[0].To_Address__c);
                    }        
                    
                    String strQuery = 'SELECT Id  ';                    
                    if(listEmailAlertsMetadata[0].Email_Alert_Developer_Name__c == 'Rent_Renewal_Email_Alert' && strObjectName == 'Unit__c'){
                        strQuery += ', Opportunity__r.AccountId  ';
                    }                
                    
                    if(listEmailAlertsMetadata[0].Query_Field_Data__c != null){
                        strQuery += ' , ' +  listEmailAlertsMetadata[0].Query_Field_Data__c;
                    }
                    
                    strQuery += ' FROM  '+ strObjectName + '  WHERE Id IN:setRecordId';
                    system.debug(strQuery);
                    Map<Id, sObject> mapRecordsById = new Map<Id, sObject>((List<sObject>)Database.query(strQuery));
    
                    EmailTemplate objEmailTemplate = [ SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Id =: Id.valueOf(strEmailTemplateId)];
                    List<OrgWideEmailAddress> lstowa = [select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: listEmailAlertsMetadata[0].From_Address__c limit 1];
                                     
                    for(InvokeSendEmail objInvokeSendEmail : listInvokeSendEmail){
                        Id recordId = objInvokeSendEmail.RecordId;
                        Messaging.SingleEmailMessage objSingleEmailMessage = Messaging.renderStoredEmailTemplate(String.valueOf(strEmailTemplateId), null, String.valueOf(recordId));
                        List<String> listToAddresses = new List<String>();
                        listToAddresses.addAll(listToAddressesDefault);
                        
                        if((String)mapRecordsById.get(recordId).get(listEmailAlertsMetadata[0].Query_Field_Data__c) != null){
                            listToAddresses.add((String)mapRecordsById.get(recordId).get(listEmailAlertsMetadata[0].Query_Field_Data__c));
                        }
                        objSingleEmailMessage.setToAddresses(listToAddresses);  
                        if(!lstowa.isEmpty()){
                            objSingleEmailMessage.setOrgWideEmailAddressId(lstowa[0].id);
                        }
                        listSingleEmailMessage.add(objSingleEmailMessage);
                        
                        if(listEmailAlertsMetadata[0].Email_Alert_Developer_Name__c == 'Rent_Renewal_Email_Alert' && strObjectName == 'Unit__c'){
                            EmailMessage objEmailMessage = new EmailMessage();
                            objEmailMessage.Incoming = false;
                            objEmailMessage.FromAddress = lstowa[0].Address;
                            objEmailMessage.FromName = lstowa[0].DisplayName;
                            objEmailMessage.HtmlBody = objSingleEmailMessage.getHtmlBody();
                            objEmailMessage.Subject  = objEmailTemplate.Subject;
                            objEmailMessage.ToAddress = String.join(listToAddresses,',');
                            objEmailMessage.status = '3';
                            objEmailMessage.RelatedToId = (Id) mapRecordsById.get(recordId).getSObject('Opportunity__r').get('AccountId');
                            listEmailMessage.add(objEmailMessage);
                        }
                    }   
                    
                    if(!listSingleEmailMessage.isEmpty()){
                        Messaging.sendEmail(listSingleEmailMessage);
                        
                        if(!listEmailMessage.isEmpty()){
                            insert listEmailMessage;
                        } 
                    }  
                }
            }
        }
    } 

}