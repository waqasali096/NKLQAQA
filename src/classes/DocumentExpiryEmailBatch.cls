global class DocumentExpiryEmailBatch implements Database.Batchable<sObject>, Schedulable 
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id ,Expiry_Date__c,Account__r.Primary_Email__c ,Contact__r.Email,Agency_Registration__c from Document__c WHERE Expiry_Date__c!=null AND(Account__c !=null OR Contact__c!=null)  ';
         query+='AND (Expiry_Date__c> = NEXT_N_DAYS:30 OR  Expiry_Date__c<= LAST_N_DAYS:30) ' ;
        return Database.getQueryLocator(query);
    }
    
    global void execute(SchedulableContext sc)
    {
       
        DocumentExpiryEmailBatch b = new DocumentExpiryEmailBatch ();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
 
    global void execute(Database.BatchableContext BC, List<Document__c> documents)
    {
      List<Document_Expiry_Notification__mdt > documentsMeta = [SELECT ID, First_email_before_expiry__c ,Second_email_before_expiry__c ,
                                                               Third_Email_Before_expiry__c ,Fourth_Email_Before_Expiry__c ,
                                                               First_Email_After_Expiry__c ,Expiry_Notification_Template__c, Expired_Notification_Template__c 
                                                               FROM Document_Expiry_Notification__mdt WHERE developername=:ConstantUtility.REC_DocumentExpireMetaName
                                                               LIMIT 1 ];
        
    Contact con =[Select id from Contact LIMIT 1 ];    
    List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
    List<Task> expiryfollowupTasks = new List<Task>();  
      
        
     EmailTemplate expiredTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =:documentsMeta[0].Expired_Notification_Template__c]; 
     EmailTemplate expiryTemplate= [select id from  EmailTemplate where DeveloperName =:documentsMeta[0].Expiry_Notification_Template__c];
     Group qu =[select id from  Group where Type = 'Queue' AND  developername='Tasks_Partner_Support_Executive']; 
   
        for(Document__c doc: documents) {
              Date documentExpireDay;
              String templateID='';
              if(doc.Expiry_Date__c>system.Today()){//Document is going to expire
                  templateID=expiryTemplate.id;
              }
            else if(doc.Expiry_Date__c<=system.Today()){//Document is   expired
                templateID=expiredTemplate.id;
            }

            /*create task if expiry is today*/
            if(doc.Expiry_Date__c==system.today()){
                documentExpireDay = doc.Expiry_Date__c;
                Task tsk = new Task();
                tsk.Subject='Document expiry Followup';
                tsk.Status='New';
                tsk.WhatId =doc.id;
                tsk.ownerID = qu.Id;
                tsk.ActivityDate= system.today()+3;
                tsk.Description='Please followup with new document replacement';
                expiryfollowupTasks.add(tsk);
            }
                if(documentsMeta[0].First_email_before_expiry__c!=null && documentExpireDay!=doc.Expiry_Date__c){
                    documentExpireDay= system.Today().adddays(Integer.valueof(documentsMeta[0].First_email_before_expiry__c)) ;
                }
                 if(documentsMeta[0].Second_email_before_expiry__c!=null && documentExpireDay!=doc.Expiry_Date__c){
                    documentExpireDay= system.Today().adddays(Integer.valueof(documentsMeta[0].Second_email_before_expiry__c)) ;
                }
                 if(documentsMeta[0].Third_Email_Before_expiry__c!=null && documentExpireDay!=doc.Expiry_Date__c){
                    documentExpireDay= system.Today().adddays(Integer.valueof(documentsMeta[0].Third_Email_Before_expiry__c)) ;
                }
                 if(documentsMeta[0].Fourth_Email_Before_Expiry__c!=null && documentExpireDay!=doc.Expiry_Date__c){
                    documentExpireDay= system.Today().adddays(Integer.valueof(documentsMeta[0].Fourth_Email_Before_Expiry__c)) ;
                }
                 if(documentsMeta[0].First_Email_After_Expiry__c!=null && documentExpireDay!=doc.Expiry_Date__c){
                    documentExpireDay= system.Today().adddays(Integer.valueof(documentsMeta[0].First_Email_After_Expiry__c)) ;
                }
                

            //}
            system.debug('documentExpireDay is '+ documentExpireDay);
            system.debug('doc.Expiry_Date__c is '+ doc.Expiry_Date__c);
            if(documentExpireDay==doc.Expiry_Date__c){
                    system.debug('doc is '+ doc); 
                    //system.debug();
                 // initialize one or more single emails as you need 
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    // set the sender email
                    //message.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE Address = 'do_not_reply@example.com' LIMIT 1].Id);
                    // set the recipient email
                    String ToAddreess='';
                    if(doc.Contact__r.Email!=null){
                        ToAddreess=doc.Contact__r.Email;
                    }
                    else if(doc.Account__r.Primary_Email__c!=null){
                         ToAddreess=doc.Account__r.Primary_Email__c;

                    }
                    message.setToAddresses(new String[] {ToAddreess });
                    // set the email template id
                    message.setTemplateId(templateID);     
                    // do not save email as activity
                    message.setSaveAsActivity(true);
                    // set the id for the object
                    message.setWhatId(doc.Id);
                    // set target object id as your current user id
                    message.setTargetObjectId( con.Id );
                    // add current message to message list
                    messageList.add(message);
                
                
            }
            
        } 
        if(messageList.size()>0){
           sendDocumentExpireNotificationEmail(messageList);
          }
        
        if(expiryfollowupTasks.size()>0){
            insert expiryfollowupTasks;
        }                                   
        
    } 
    
    public static void sendDocumentExpireNotificationEmail(List<Messaging.SingleEmailMessage> messageList){
        
         // create savepoint before executing statement
                Savepoint sp = Database.setSavepoint();
                
                // send the temporary email list
                Messaging.sendEmail(messageList);
                
                // rollback the transaction before commiting to database
                Database.rollback(sp);            
                // initialize the actual message list to be sent
                List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
                /*Added By Mamta - 28 Sep*/
                OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress();
                if(AppSettings__c.getValues('OrgWideEmailAddressForSR').TextValue__c != null){
                    orgWideEmailAddress = EmailNotificationHelper.getOrgWideEmailAddress(AppSettings__c.getValues('OrgWideEmailAddressForSR').TextValue__c);
                }
                system.debug(orgWideEmailAddress.Id);
                // loop through the previous message list and set the email fields
                for (Messaging.SingleEmailMessage email : messageList) {
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                    emailToSend.setToAddresses(email.getToAddresses());
                    emailToSend.setHTMLBody(email.getHTMLBody());
                    emailToSend.setSubject(email.getSubject());
                    if(orgWideEmailAddress!=null){
                        emailToSend.setOrgWideEmailAddressId(orgWideEmailAddress.Id);///*Added By Mamta - 28 Sep*/
                    }   
                    //emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
                    actualMessageList.add(emailToSend);
                }
                
                // send the actual message list
                Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);

                // make sure the emails are sent successfully
                String errorMessage = '';
                for(Messaging.SendEmailResult ser : serList){
                    if(!ser.isSuccess()){
                        for(Messaging.SendEmailError err : ser.getErrors()) {
                            errorMessage += err.getMessage() + '\n';
                            system.debug('errorMessage is '+ errorMessage);
                        }
                    }
                }

                           
    }
    

    global void finish(Database.BatchableContext BC)
    {
    }
}