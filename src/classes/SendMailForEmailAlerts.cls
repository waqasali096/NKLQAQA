/*
Name: SendMailForEmailAlerts
Purporse: Sending an email to customer.
Author: Jayesh Shewale
*/

global without sharing class SendMailForEmailAlerts {
    global class InvokeSendEmail {        
        @InvocableVariable(label='Email Alert Name' description='API Name of Email alert' required=true)
        global String EmailAlertAPIName;
        
        @InvocableVariable(label='Record Id' description='Contact/Lead ID required if you use this' required=false)
        global Id RecordId;
        
        //Added By Jayesh on 20 April.
        @InvocableVariable(label='Org Wide Default Address' description='Provide Org Wide Default Address for your email.' required=false)
        global String OrgWideDefaultAddress;
    }
    @InvocableMethod(label='Send Email for Email Alert' description='send email to customer with dynamic attachment')
    
    /*
Purpose: We are calling this method from Process Builder or flow.
*/
    
    Public static Void sendEmail(List<InvokeSendEmail> requests){
        
        List<String> emailalertList = New List<String>();
        for(InvokeSendEmail em : requests){
            emailalertList.add(em.EmailAlertAPIName);
        }
        System.debug('email alert name=== ' + emailalertList);
        //call future method
        sendtest(emailalertList,requests[0].RecordId, requests[0].OrgWideDefaultAddress);
    }
    
    /*Added By Jayesh on 20 April
     * Purpose: We wanted to pass the third parameter to this class so modifying this parameter.
    */
    public static void sendtest(List<String> emailalertList,Id recId){
        sendtest(emailalertList,recId,null);
    }
    
    //Added by Anshita, moved to Queueable 13-04-2022
    public static void sendtest(List<String> emailalertList,Id recId, String OrgWideDefaultAddress){
        SendMailForEmailAlertsQueueable smeaq = new SendMailForEmailAlertsQueueable(emailalertList,(String)recId, OrgWideDefaultAddress);
        System.enqueueJob(smeaq);
    }

    /*
Purpose: Send Email using below method. 
*/
    public static Messaging.SingleEmailMessage send(List<String> emailalertList,Id recordId, String OrgWideDefaultAddress){
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        try{
        //-----------------------------------------------------------------------------------------------------------------------------------------
        Id emtemplateid;
        Id Whatidfld;
        String[] recString = new List<String>();
        String sObjName = RecordId.getSObjectType().getDescribe().getName();
        String sessionId= UserInfo.getSessionID();
        String domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
        //Call is made to get the email alert record Id.
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(domainUrl+'/services/data/v47.0/tooling/query/?q=select+id,SenderType,templateId+from+WorkflowAlert+where+DeveloperName=\''+emailalertList[0]+'\'');
        req.setMethod('GET');
        system.debug('req is  ' + req);
        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug('@@@ res' + res);
        List<string> workflowEmailAlertIds= new List<string>();
        String response=res.getBody();
        System.debug('@@@ response' + response);
        JSONParser  parser = JSON.createParser(Response);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                String fieldValue=parser.getText();
                if(fieldName == 'Id') {
                    workflowEmailAlertIds.add(fieldValue);
                }
            }
        }
        system.debug('***workflowEmailAlertIds size:'+workflowEmailAlertIds.size());
        system.debug('***workflowEmailAlertIds size:'+workflowEmailAlertIds);
        
        string csvString='Workflow Email Alert Id,WorkFlow Email Alert Developer Name,Description,ccEmails,recipients,senderAddress,senderType,Email template Name,Email template Id\n';
        
        if(workflowEmailAlertIds.size()<90){
            for(string ss:workflowEmailAlertIds){
                system.debug('***workflowEmailAlertId :'+ss);
                //Lets Get the detailed info of your Email Alert.
                HttpRequest req1 = new HttpRequest();
                req1.setHeader('Authorization', 'Bearer ' +sessionId );
                req1.setHeader('Content-Type', 'application/json');
                req1.setEndPoint(domainUrl+'/services/data/v41.0/tooling/sobjects/WorkflowAlert/'+ss); 
                req1.setMethod('GET');
                Http h1 = new Http();
                HttpResponse res1 = h1.send(req1);
                system.debug(res1.getBody());
                String response1=res1.getBody();
                response1 = response1.replace('type', 'type_z');
                response1 = response1.replace('protected','protected_z');
                response1 = response1.replaceAll(',\r\n','\r\n');
                SK_EmailAlertJSONParser   emailAlertDetails=new SK_EmailAlertJSONParser();
                system.debug('res==='  + response1);
                
                try{
                    emailAlertDetails =(SK_EmailAlertJSONParser) System.JSON.deserialize(response1, SK_EmailAlertJSONParser.class);
                    system.debug('******emailAlertDetails:'+emailAlertDetails);
                    string ccEmails ='';
                    emtemplateid = emailAlertDetails.TemplateId;
                    if(emailAlertDetails.Metadata!=null){
                        if(emailAlertDetails.Metadata.ccEmails.size()>0){
                            ccEmails = string.join(emailAlertDetails.Metadata.ccEmails,',');
                        }
                        if(emailAlertDetails.Metadata.recipients!=null){
                            if(emailAlertDetails.Metadata.recipients.size()>0){
                                List<String> emailsid = New List<String>();
                                emailsid.addAll(CustomEmailSendHelper.FetchUserEmails(emailAlertDetails.Metadata.recipients,recordId));
                                system.debug('email===' + emailsid);
                                for(String emails :emailsid){
                                    recString.add(emails);
                                }
                            }
                        }
                        
                    }
                    
                }catch(exception ex){
                    system.debug('****exception for email alertid-'+ss);
                    
                }
            }
        }
        
        
        /*Start - Added By Mamta 5 April */
        OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress();
        //Start: Added by Jayesh on 20 April
        if(orgWideDefaultAddress != null){
            orgWideEmailAddress = [select id, Address, DisplayName from OrgWideEmailAddress Where DisplayName=: orgWideDefaultAddress LIMIT 1];
        }else{
            orgWideEmailAddress = [select id, Address, DisplayName from OrgWideEmailAddress Where DisplayName=:system.label.Org_Wide_Default_Address LIMIT 1 ];
        }
        //End: Added by Jayesh on 20 April
        System.debug('@@@ ' + String.valueOf(emtemplateid));
        Messaging.SingleEmailMessage objSingleEmailMessage = Messaging.renderStoredEmailTemplate(String.valueOf(emtemplateid), null, String.valueOf(recordId));
        /*End - Added By Mamta 5 April */
        
        //Get the related Template Id.
        EmailTemplate tempRec = [SELECT Id, Name, Subject,HtmlValue, Body FROM EmailTemplate  WHERE Id =:emtemplateid]; 
        system.debug('emailtemp=== ' + tempRec);
        string[] ccemailstosend = new List<String>();
        set<String> ccemails = new set<string>();
        Set<id> ids = new set<Id>();
        List<Group> grpname = new List<Group>();
       
        
        email.setSubject(tempRec.Subject);
        
        email.setToAddresses(recString);
        email.targetobjectid = System.Label.Dummy_Contact_Record_Id;
        email.setTemplateId(emtemplateid);
        email.setTargetObjectId(System.Label.Dummy_Contact_Record_Id);
        //email.setHtmlBody(tempRec.HtmlValue);//commented By Mamta
        /*Start - Added By Mamta 5 April */
        if(objSingleEmailMessage.getHtmlBody()!=null){
            email.setHtmlBody(objSingleEmailMessage.getHtmlBody());
        }
        else{
            email.setPlainTextBody(objSingleEmailMessage.getPlainTextBody()); 
        }
        
        if(sObjName!='Lead'){//Added if condition by Mamta Gupta as WhatID fails for Lead 
            email.setWhatId(recordId);
        }
        else{
            email.setTargetObjectId(recordId);//Added By Mamta.Email gets logged as activity for lead when target object id is recordid of lead
            
        }
        
        /*End - Added By Mamta 5 April */
        
        if(ccemails.size() > 0 && ccemails != Null){
            email.setCcAddresses(ccemailstosend);
        }
        email.setSaveAsActivity(true);
        email.setTreatBodiesAsTemplate(true);
        email.setTreatTargetObjectAsRecipient(false);
        system.debug('email=====' + email);
        
        if(orgWideEmailAddress!=null){
            email.setOrgWideEmailAddressId(orgWideEmailAddress.Id);//Added By Mmamta - 9 April
        }
        
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }); 
        }catch(exception ex){
                    system.debug('****exception for email alertid-'+ex);
        }
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
                List<String> listToAddressesCustom = new List<String>();
                String strObjectName;
                User objCurrentUser;
                
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
                    if(listEmailAlertsMetadata[0].Email_Alert_Developer_Name__c == ConstantUtility.LEASE_RENEWAL_EMAIL_ALERT && strObjectName == 'Unit__c'){
                        strQuery += ', Opportunity__r.AccountId  ';
                    }                
                    
                    if(listEmailAlertsMetadata[0].Query_Field_Data__c != null){
                        strQuery += ' , ' +  listEmailAlertsMetadata[0].Query_Field_Data__c;
                    }
                    
                    strQuery += ' FROM  '+ strObjectName + '  WHERE Id IN:setRecordId';
                    system.debug(strQuery);
                    Map<Id, sObject> mapRecordsById = new Map<Id, sObject>((List<sObject>)Database.query(strQuery));

                    if(listEmailAlertsMetadata[0].Email_Alert_Developer_Name__c == ConstantUtility.UNIT_CHANGE_EMAIL_ALERT && strObjectName == 'Case'){
                        objCurrentUser = [SELECT Id, Email, ManagerId, Manager.ManagerId, Manager.Manager.Email FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
                        listToAddressesCustom.add(objCurrentUser.Email);

                        if(objCurrentUser.ManagerId != null && objCurrentUser.Manager.ManagerId != null){
                            //listToAddressesCustom.add(objCurrentUser.Manager.Manager.Email);
                        }                        
                    } 
                    
                    EmailTemplate objEmailTemplate = [ SELECT Id, Name, Subject, HtmlValue, Body FROM EmailTemplate WHERE Id =: Id.valueOf(strEmailTemplateId)];
                    List<OrgWideEmailAddress> lstowa = new List<OrgWideEmailAddress>();
                    if(!listEmailAlertsMetadata.isEmpty() && listEmailAlertsMetadata[0].From_Address__c != null){
                        lstowa = [select id, Address, DisplayName from OrgWideEmailAddress WHERE Address =: listEmailAlertsMetadata[0].From_Address__c limit 1];
                    }
                    for(InvokeSendEmail objInvokeSendEmail : listInvokeSendEmail){
                        Id recordId = objInvokeSendEmail.RecordId;
                        Messaging.SingleEmailMessage objSingleEmailMessage = Messaging.renderStoredEmailTemplate(String.valueOf(strEmailTemplateId), null, String.valueOf(recordId));
                       
                        List<String> listToAddresses = new List<String>();
                        listToAddresses.addAll(listToAddressesDefault);
                        
                        if(!listToAddressesCustom.isEmpty()){
                            listToAddresses.addAll(listToAddressesCustom);
                        }
                        
                        if(mapRecordsById.get(recordId) != null && listEmailAlertsMetadata[0].Query_Field_Data__c != null && (String)mapRecordsById.get(recordId).get(listEmailAlertsMetadata[0].Query_Field_Data__c) != null){
                            listToAddresses.add((String)mapRecordsById.get(recordId).get(listEmailAlertsMetadata[0].Query_Field_Data__c));
                        }
                        
                        objSingleEmailMessage.setToAddresses(listToAddresses);  
                        if(!lstowa.isEmpty()){
                            objSingleEmailMessage.setOrgWideEmailAddressId(lstowa[0].id);
                        }
                        listSingleEmailMessage.add(objSingleEmailMessage);
                        
                        if(listEmailAlertsMetadata[0].Email_Alert_Developer_Name__c == ConstantUtility.LEASE_RENEWAL_EMAIL_ALERT && strObjectName == 'Unit__c'){
                            EmailMessage objEmailMessage = new EmailMessage();
                            objEmailMessage.Incoming = false;
                            if(!lstowa.isEmpty()){
                                objEmailMessage.FromAddress = lstowa[0].Address;
                                objEmailMessage.FromName = lstowa[0].DisplayName;
                            }
                            objEmailMessage.HtmlBody = objSingleEmailMessage.getHtmlBody();
                            objEmailMessage.Subject  = objEmailTemplate.Subject;
                            objEmailMessage.ToAddress = String.join(listToAddresses,',');
                            objEmailMessage.status = '3';
                            if((String)mapRecordsById.get(recordId).get(listEmailAlertsMetadata[0].Query_Field_Data__c) != null){
                                objEmailMessage.RelatedToId = (Id) mapRecordsById.get(recordId).getSObject('Opportunity__r').get('AccountId');
                            }
                            
                            listEmailMessage.add(objEmailMessage);
                        }
                    }
                    system.debug('######'+listSingleEmailMessage);
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
    
   /*Added By Husen 
     * Purpose: For sending email with attachment
    */
    //public static void sendEmailWithAttachment(list<Handover__c> handoverToSendEmailList, list<string> documentTypeList){
    public static void sendEmailWithAttachment(list<HandoverTriggerHandler.wrapperClass> wrapperClsList){
        System.debug('Inside sendEmailWithAttachment');
        map<Id, list<Messaging.EmailFileAttachment>> documentIdWithAttachmentListMap = new map<Id, list<Messaging.EmailFileAttachment>>();
        map<Id, Id> contentDocumentIdWithDocIdMap = new  map<Id, Id>();
        map<Id, Id> docIdWithHandOverIdMap = new  map<Id, Id>();
        list<Handover__c> handoverToSendEmailList = new list<Handover__c>();
        list<string> documentTypeList = new list<string>();
        list<string> emailTemplateList = new list<string>();
        map<Id, String> emailTempByHandover = new  map<Id, String>();
        System.debug('Inside wrapperClsList' + wrapperClsList);
        for(HandoverTriggerHandler.wrapperClass w : wrapperClsList){
            handoverToSendEmailList.add(w.handover);
            documentTypeList.add(w.documentType);
            emailTemplateList.add(w.emailTemplate);
            emailTempByHandover.put(w.handover.Id,w.emailTemplate);
        }
        System.debug('Inside emailTemplateList' + emailTemplateList);
        map<String,Id> emailTempByName = new  map<String,Id>();
        List<EmailTemplate> emailTemplate = [Select Id,DeveloperName,Body from EmailTemplate where DeveloperName IN: emailTemplateList]; 
        for(EmailTemplate e : emailTemplate){
            emailTempByName.put(e.DeveloperName, e.Id);
        }
        for(Document__c document : [SELECT Id, Document_Type__c, Handover__r.Unit__r.Unit_Code__c, Handover__r.Account_Email__c 
                                    from Document__c 
                                    where Document_Type__c in : documentTypeList AND Handover__c in : handoverToSendEmailList AND Handover__r.Account_Email__c != null]){
                                        docIdWithHandOverIdMap.put(document.Id, document.Handover__c);
                                    }
        
        if(docIdWithHandOverIdMap.isEmpty() == false){
            List<Id> contentVersionIds = new List<Id>();
            for(ContentDocumentLink contentDocumentLink : [SELECT LinkedEntityid, ContentDocumentid FROM contentDocumentLink WHERE LinkedEntityid in : docIdWithHandOverIdMap.keySet()]){
                contentDocumentIdWithDocIdMap.put(contentDocumentLink.ContentDocumentid, contentDocumentLink.LinkedEntityid);
                
            }
            
            for(ContentVersion cversion : [SELECT Id,title, PathOnClient, FileType, versiondata, ContentDocumentId 
                                           FROM contentversion 
                                           WHERE ContentDocumentId IN : contentDocumentIdWithDocIdMap.keySet()]){
                                               string docIdKey = contentDocumentIdWithDocIdMap.get(cversion.ContentDocumentId);
                                               string handOverId = docIdWithHandOverIdMap.get(docIdKey);
                                               contentVersionIds.add(cversion.Id);
                                               Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                                               //attach.setContentType(cversion.FileType);
                                               if(cversion.title.contains('.'))
                                                   attach.setFileName(cversion.title);
                                               else
                                                   attach.setFileName(cversion.title + '.' + cversion.FileType);
                                               attach.setInline(false);
                                               attach.Body = cversion.versiondata;
                                               
                                               if(documentIdWithAttachmentListMap.containsKey(handOverId)){
                                                   documentIdWithAttachmentListMap.get(handOverId).add(attach);
                                               }else{
                                                   documentIdWithAttachmentListMap.put(handOverId, new list<Messaging.EmailFileAttachment>{attach});
                                               }
                                           }
            
            list<Messaging.SingleEmailMessage> singleEmailMessageList = new list<Messaging.SingleEmailMessage>();
            //OrgWideEmailAddress orgWideEmailAddress = [select id, Address, DisplayName from OrgWideEmailAddress Where DisplayName =: system.label.Org_Wide_Default_Address LIMIT 1];
            
            for(Handover__c handover : handoverToSendEmailList){
                //Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, handover.Id);
                Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTempByName.get(emailTempByHandover.get(handover.Id)), null, handover.Id);
                message.setSenderDisplayName('Nakheel ');
                //message.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
                message.toAddresses = new list<String>{handover.Account_Email__c};
                //Added by Anshita
                //message.setFileAttachments(documentIdWithAttachmentListMap.get(handover.Id));//Set File Attachment
                message.setEntityAttachments(contentVersionIds);
                singleEmailMessageList.add(message);
            }
            System.debug('singleEmailMessageList:::' + singleEmailMessageList);
            if(singleEmailMessageList.isEmpty() == false){
                Messaging.sendEmail(singleEmailMessageList);//Send Email
            } 
        }
        //Added by Anshita for sending email from template but without attachment
        else{
            list<Messaging.SingleEmailMessage> singleEmailMessageList = new list<Messaging.SingleEmailMessage>();
            //OrgWideEmailAddress orgWideEmailAddress = [select id, Address, DisplayName from OrgWideEmailAddress Where DisplayName =: system.label.Org_Wide_Default_Address LIMIT 1];
            
            for(Handover__c handover : handoverToSendEmailList){
                //Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, null, handover.Id);
                if(handover.Account_Email__c != null){
                    Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTempByName.get(emailTempByHandover.get(handover.Id)), null, handover.Id);
                    message.setSenderDisplayName('Nakheel ');
                    //message.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
                    message.toAddresses = new list<String>{handover.Account_Email__c};
                    singleEmailMessageList.add(message);
                }
            }
            System.debug('singleEmailMessageList:::' + singleEmailMessageList);
            if(singleEmailMessageList.isEmpty() == false){
                Messaging.sendEmail(singleEmailMessageList);//Send Email
            } 
        }
    }
}