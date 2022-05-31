global class EmailAlertsMetaDataBatch implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    String query;
    Id emtemplateid;
    Id Whatidfld;
    
    string sessionId= UserInfo.getSessionID();
    string domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
    string agreement='';
    
    List<Email_Alerts_Metadata__c> lstEmail = new List<Email_Alerts_Metadata__c>();
    List<Email_Alerts_Metadata__c> lstEmailUpdate = new List<Email_Alerts_Metadata__c>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        query='SELECT Email_Alert_Developer_Name__c,Email_Alert_ID__c,Email_Template__c,From_Address__c,To_Address__c FROM Email_Alerts_Metadata__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<sObject> records){
        lstEmail=records;
        
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
        
        //req.setEndpoint(domainUrl+'/services/data/v47.0/tooling/query/?q=select+id,SenderType,templateId+from+WorkflowAlert+WHERE+Id=\'01W3M00000002tY\'+OR+Id=\'01W3M00000002rr\'+OR+Id=\'01W3M00000002rw\'+OR+Id=\'01W3M00000002s1\'+OR+Id=\'01W3M00000002pq\'+OR+Id=\'01W3M00000002uv\'');
        req.setEndpoint(domainUrl+'/services/data/v47.0/tooling/query/?q=select+id,SenderType,templateId+from+WorkflowAlert+WHERE+Id=\'01W3M0000004MpZ\'+OR+Id=\'01W3M0000004Mo2\'+OR+Id=\'01W3M0000004Mo3\'+OR+Id=\'01W3M0000004Mo4\'+OR+Id=\'01W3M0000004MmV\'+OR+Id=\'01W3M0000004Ms9\'');
        
        //req.setEndpoint(domainUrl+'/services/data/v47.0/tooling/query/?q=select+id,SenderType,templateId+from+WorkflowAlert+LIMIT+89');
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        system.debug('#####'+res.getBody());
        
        List<string> workflowEmailAlertIds= new List<string>();
        String response=res.getBody();
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
        //as there is limit of 100 callouts in single transaction, I am restricting it to 90. Assuming there will not be more than 
        //90 email alert on single object
        if(workflowEmailAlertIds.size()<90){
            for(string ss:workflowEmailAlertIds){
                String queryFields='';
                Email_Alerts_Metadata__c objEmail = new Email_Alerts_Metadata__c();
                system.debug('***workflowEmailAlertId :'+ss);
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
                //objEmail.Email_Template_Response__c=response1;
                //try{
                    
                    emailAlertDetails =(SK_EmailAlertJSONParser) System.JSON.deserialize(response1, SK_EmailAlertJSONParser.class);
                    system.debug('******emailAlertDetails:'+emailAlertDetails);
                    string ccEmails ='';
                    emtemplateid = emailAlertDetails.TemplateId;
                    objEmail.Email_Template__c=emailAlertDetails.TemplateId;
                    objEmail.Email_Alert_Developer_Name__c=emailAlertDetails.DeveloperName;
                    objEmail.Email_Alert_ID__c=emailAlertDetails.Id;
                    objEmail.Name=emailAlertDetails.DeveloperName;
                    
                system.debug('queryFields==>'+emailAlertDetails.Metadata.recipients);
                System.debug('@@@@@@ emailAlertDetails.Metadata.ccEmails '+ emailAlertDetails.Metadata.ccEmails);
                if(emailAlertDetails.Metadata!=null){
                    if(emailAlertDetails.Metadata.ccEmails.size()>0){
                        
                        
                        ccEmails = string.join(emailAlertDetails.Metadata.ccEmails,',');
                        
                        System.debug('@@@@@@ '+ emailAlertDetails.Metadata.ccEmails);
                        
                        objEmail.To_Address__c=string.join(emailAlertDetails.Metadata.ccEmails,',');
                        System.debug('objEmail.To_Address__c '+ objEmail.To_Address__c);
                        
                    }
                    
                    if(emailAlertDetails.Metadata.recipients!=null){
                        if(emailAlertDetails.Metadata.recipients.size()>0){
                            List<String> emailsid = New List<String>();
                            emailsid.addAll(CustomEmailSendHelper.FetchUserEmails(emailAlertDetails.Metadata.recipients,null));
                            system.debug('email===' + emailsid);
                            string[] recString = new List<String>();
                            for(String emails :emailsid){
                                recString.add(emails);
                                
                            }
                            if(recString.size() > 0 && recString != Null){
                                
                                if(recString[0] == Null){
                                    System.debug('inside if check');
                                    recString.remove(0);
                                }
                                System.debug('@@@ recString '+ recString);
                                String toemails;
                                toemails=String.valueof(recString).removeEnd(')');
                                System.debug('@@@ '+ toemails );
                                
                                if(objEmail.To_Address__c == Null){
                                    objEmail.To_Address__c = toemails.removeStart('(');
                                }else{
                                    objEmail.To_Address__c = objEmail.To_Address__c + ',' + toemails.removeStart('(');
                                    System.debug('@@@ objEmail.To_Address__c '+ objEmail.To_Address__c);
                                }
                                
                                
                                
                            }
                            for(SK_EmailAlertJSONParser.Recipients  rec: emailAlertDetails.Metadata.recipients){
                                
                                if(rec.type_Z == 'email')
                                    {
                                        queryFields = queryFields + rec.field + ',';
                                        
                                    }
                                    if(rec.type_Z == 'owner')
                                    {
                                        queryFields = queryFields + 'OwnerId,';
                                    }
                                    
                                    if(rec.type_Z == 'userLookup')
                                    {
                                        queryFields = queryFields + rec.field + ',';
                                    }
                                }
                                if(queryFields!=null && queryFields!=''){
                                    objEmail.Query_Field_Data__c=queryFields.removeEnd(',');
                                }
                                
                                lstEmailUpdate.add(objEmail);
                            }
                        }
                        
                    }
                    
               /* }catch(exception ex){
                    system.debug('****exception for email alertid-'+ss);
                    
                }*/
            }
            if(lstEmail.size()>0){
            delete lstEmail;
        }
            if(lstEmailUpdate.size()>0){
               insert lstEmailUpdate;
            }
        }  
    }    
    global void finish(Database.BatchableContext bc){
        
    }    
}