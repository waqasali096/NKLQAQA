/**
* @author Mamta Gupta
* @date 24 Aug 2021
* @purpose - Initial Development
* @usage -Trigger handler for DocumentRequestTrigger
*/

public class DocumentRequestTriggerHandler {
    
    List<rsdoc__Document_Request__c> recordNewList = new List<rsdoc__Document_Request__c>();
    List<rsdoc__Document_Request__c> recordOldList = new List<rsdoc__Document_Request__c>();
    Map<Id, rsdoc__Document_Request__c> recordNewMap = new Map<Id, rsdoc__Document_Request__c>();
    Map<Id, rsdoc__Document_Request__c> recordOldMap = new Map<Id, rsdoc__Document_Request__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    public DocumentRequestTriggerHandler(List<rsdoc__Document_Request__c> newList, List<rsdoc__Document_Request__c> oldList, Map<Id, rsdoc__Document_Request__c> newMap, Map<Id, rsdoc__Document_Request__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.recordNewList = newList;
        this.recordOldList = oldList;
        this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    public void BeforeInsertEvent() {
    }
    public void BeforeUpdateEvent() {
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
    }
    public void AfterUpdateEvent() {
        List<rsdoc__Document_Request__c> docRequests = new  List<rsdoc__Document_Request__c>();
        set<Id> documentRequestIds = new set<Id>();
        set<Id> quickBookDocRequestIds = new set<Id>();
        for(rsdoc__Document_Request__c request : recordNewList){
            if(request.rsdoc__Status__c=='Completed'  && recordOldMap.get(request.Id).rsdoc__Status__c != request.rsdoc__Status__c && 
               request.rsdoc__Attachment_Id__c!=null) {//&& request.Email_Generated_Attachment_To_Broker__c  ==true){}
                   docRequests.add(request);
                   documentRequestIds.add(request.Id);
                   system.debug('docRequeststoEmail are '+ docRequests);
                   if(request.Quick_Booking_Request__c == TRUE){
                      quickBookDocRequestIds.add(request.Id); 
                   }
                   system.debug('%%quickBookDocRequestIds'+ quickBookDocRequestIds);
               }  
        }
        if(documentRequestIds.size()>0){
            // sendEmailtoBrokerForAgreementSign(docRequests);   
            updateDocumentAttachmentId(documentRequestIds);
        } 
        if(quickBookDocRequestIds.size()>0){
            updateBokingFormCheckforQuickBooking(quickBookDocRequestIds);
        } 
    }
    public void AfterDeleteEvent() {
    }
    public void AfterUndeleteEvent() {
    }

    
    public static void updateBokingFormCheckforQuickBooking(set<Id> docRequestIds){
        Set<Id> oppIds = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id,rsdoc__Document_Request__c> docRequestMap = new Map<Id,rsdoc__Document_Request__c>([SELECT ID ,rsdoc__Record_Id__c,
                                                                                                 rsdoc__Document_Action__r.rsdoc__Base_object_API__c,
                                                                                                 rsdoc__Attachment_Id__c
                                                                                                 FROM rsdoc__Document_Request__c 
                                                                                                 WHERE Id IN:docRequestIds AND rsdoc__Document_Action__r.rsdoc__Base_object_API__c 
                                                                                                 = 'Opportunity' ]);
        
        for(rsdoc__Document_Request__c rsDoc : docRequestMap.values()){
           oppIds.add(rsDoc.rsdoc__Record_Id__c); 
        }
        if(oppIds.size()>0){
           oppList = [Select Id,Booking_Form_Generated__c from Opportunity where Id IN:oppIds]; 
        }
        system.debug('%%oppIds'+oppIds);
        system.debug('%%oppList'+oppList);
        try{
            if(oppList.size()>0){
                for(Opportunity opp:oppList){
                    opp.Booking_Form_Generated__c = true;
                } 
                update oppList;
            } 
        }catch(Exception e){
            System.debug('%%Quick Opp Form Error'+e);
        }
        
    }
    
    /*Purpose- This method sends agreement generated pdf as attachment in email for signature to broker after approval
   * @param - documentRequests - List of document request which has status as completed with Email_Generated_Attachment_To_Broker__c marked as true*/
    /*public static void sendEmailtoBrokerForAgreementSign(List<rsdoc__Document_Request__c> documentRequests){
        system.debug('***documentRequests :'+documentRequests);
    Set<String> accountIDS = new Set<String>();
    Set<String> attachmentIDS = new Set<String>();
    Map<Id, Set<Id>> accountWithAttachments = new Map<Id, Set<Id>>();
    
     for(rsdoc__Document_Request__c req : documentRequests ){
         accountIDS.add(req.rsdoc__Record_Id__c);
         attachmentIDS.add(req.rsdoc__Attachment_Id__c);
         if(accountWithAttachments.containsKey(req.rsdoc__Record_Id__c)){
             accountWithAttachments.get(req.rsdoc__Record_Id__c).add(req.rsdoc__Attachment_Id__c);
         }else{
             accountWithAttachments.put(req.rsdoc__Record_Id__c, new set<Id>{req.rsdoc__Attachment_Id__c});
         }
   }
   Map<String,Account> IdAccountMap =new  Map<String,Account> ([SELECT ID,Agency_Status__c,Agreement_Status__c, 
                                                                Agency_Registration__c , Agency_Registration__r.Email_Address__c
                                                                from Account where ID IN:accountIDS ]); 
   Map<String,Attachment> IdAttachmentMap = new  Map<String,Attachment>([SELECT id,name,body from Attachment WHERE ID IN:attachmentIDS]);
        
   // initialize temporary email list
     
    List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
    
     EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body 
                                    FROM EmailTemplate 
                                    WHERE name = 'Agency Registration Acknowledgement Approval Email'];
    
     Contact con=[SELECT ID FROM Contact LIMIT 1 ];
        
        for(Id accId : accountWithAttachments.keySet()){
            String agencyEmailId = IdAccountMap.get(accId).Agency_Registration__r.Email_Address__c;
            String brokerID = IdAccountMap.get(accId).Agency_Registration__c;
            List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
            // initialize one or more single emails as you need 
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            for(Id attachId : accountWithAttachments.get(accId)){
              Attachment att = IdAttachmentMap.get(attachId);  
                Messaging.EmailFileAttachment efa = new Messaging.EmailfileAttachment();
                efa.setFileName(att.Name);
                efa.setBody(att.Body);
                efaList.add(efa);
            }
            // set the recipient email
            message.setToAddresses(new String[] {agencyEmailId });
            // set the email template id
            message.setTemplateId(emailTemplate.Id);
            // do not save email as activity
            message.setSaveAsActivity(true);
            // set the id for the object
            message.setWhatId(brokerID);
            // set target object id as your current user id
            message.setTargetObjectId( con.Id );
            message.setFileAttachments(efaList);
            // add current message to message list
            messageList.add(message);
        }
        
        /*for(rsdoc__Document_Request__c req : documentRequests){
            String accID = req.rsdoc__Record_Id__c;
            system.debug('accID is '+ accID);

            if(IdAccountMap.containsKey(accID)){
                if(IdAccountMap.get(accID).Agency_Registration__c!=null){
                    String agencyEmailId = IdAccountMap.get(accID).Agency_Registration__r.Email_Address__c;
                    String brokerID = IdAccountMap.get(accID).Agency_Registration__c;
                    
                    // initialize one or more single emails as you need 
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    Attachment att = IdAttachmentMap.get(req.rsdoc__Attachment_Id__c);
                    //AccountIDAttachmentIDMap.put(accID,req.rsdoc__Attachment_Id__c);
                    Messaging.EmailFileAttachment efa = new Messaging.EmailfileAttachment();
                    efa.setFileName(att.Name);
                    efa.setBody(att.Body);
                    //efa.add();
                    // set the sender email
                    //message.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE Address = 'do_not_reply@example.com' LIMIT 1].Id);
                    
                    // set the recipient email
                    message.setToAddresses(new String[] {agencyEmailId });
                  
                    // set the email template id
                    message.setTemplateId(emailTemplate.Id);     
                    
                    // do not save email as activity
                    message.setSaveAsActivity(true);
                
                    // set the id for the object
                    message.setWhatId(brokerID);
                
                    // set target object id as your current user id
                    message.setTargetObjectId( con.Id );
                    message.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

                    // add current message to message list
                    messageList.add(message);
                
                  }
                }   
               }*/
                
                // create savepoint before executing statement
               /* Savepoint sp = Database.setSavepoint();
                
                // send the temporary email list
                Messaging.sendEmail(messageList);
                
                // rollback the transaction before commiting to database
                Database.rollback(sp);            
                // initialize the actual message list to be sent
                List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
                
                // loop through the previous message list and set the email fields
                for (Messaging.SingleEmailMessage email : messageList) {
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                    emailToSend.setToAddresses(email.getToAddresses());
                    emailToSend.setHTMLBody(email.getHTMLBody());
                    emailToSend.setSubject(email.getSubject());
                    //emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
                    emailToSend.setFileAttachments(email.getFileAttachments());
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
                        }
                    }
                }
        		system.debug('errorMessage :'+errorMessage);
        
               if(serList.size()>0){
                    for(Account acc: IdAccountMap.values()){
                        acc.Agreement_Status__c	 = 'Sent for signature to broker';
                        acc.Agency_Status__c= 'Agreement in Process';
                    }
                 update  IdAccountMap.values();
               }
        } */
    
    public static void updateDocumentAttachmentId(set<Id> docRequestIds){
        
        Map<Id,rsdoc__Document_Request__c> docRequestMap=new Map<Id,rsdoc__Document_Request__c>([SELECT ID ,rsdoc__Record_Id__c,
                                                                                                 rsdoc__Document_Action__r.rsdoc__Base_object_API__c,
                                                                                                 rsdoc__Attachment_Id__c
                                                                                                 FROM rsdoc__Document_Request__c 
                                                                                                 WHERE Id IN:docRequestIds AND rsdoc__Document_Action__r.rsdoc__Base_object_API__c 
                                                                                                 = 'Document__c' ]);
        List<Document__c> documents = new List<Document__c>();
        for(rsdoc__Document_Request__c rsDoc : docRequestMap.values()){
            //if(rsDoc.rsdoc__Record_Id__c.startsWith('a0B')){
            Document__c doc = new Document__c();
            doc.Id = rsDoc.rsdoc__Record_Id__c;
            doc.Attachment_Id__c = rsDoc.rsdoc__Attachment_Id__c;
            documents.add(doc);
            //}
            
        }
        system.debug('***documents'+documents);
        if(!documents.isEmpty()){
            update documents;
        }
        system.debug('*** after update documents'+documents);
    }

}