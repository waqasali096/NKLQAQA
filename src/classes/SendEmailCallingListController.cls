/**************************************************************************************************
* Name               : SendEmailCallingListController                                                      
* Description        : Send Email from Calling List with from Address as per business unit
* Created Date       : 15/04/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      15/05/2022      Initial Draft.                                               
**************************************************************************************************/

public class SendEmailCallingListController {
    public class SendEmailFromCallingList {        
        @InvocableVariable(label='Email template ID' description='API Name of Email alert' required=true)
        public String EmailTempID;
        
        @InvocableVariable(label='Record Id' description='Calling List ID' required=false)
        public Id RecordId;
        
        @InvocableVariable(label='Org Wide Default Address Label' description='Provide Org Wide Default Address for your business unit.' required=false)
        public String OrgWideDefaultAddressLabel;
        
        @InvocableVariable(label='queueName' description='Developer name of queue' required=false)
        public String GroupName;
    }
    
    @InvocableMethod(label='send mail notification Calling List' description='Send mail notification from Calling List' category='')
    public static void sendMailonCallingList(List<SendEmailFromCallingList> sendEmail){
        system.debug(' sendEmail is '+ sendEmail);
        if(sendEmail[0].RecordId!=null){
          Calling_List__c cl= [select id,Email_Sent_To_Customer__c ,Account__r.Primary_Email__C, Outcome__c,
                             Unit__r.Business_group__r.name from Calling_List__c WHERE ID=:sendEmail[0].RecordId];
        
        
        List<String> addresses = new List<String>();
        if(SendEmail[0].GroupName!='' && SendEmail[0].GroupName!=null){
            List<User> users = [select id,firstName,lastName, email from user where id in (select userorgroupid from groupmember 
                                                                                           where group.developername =:sendEmail[0].GroupName) LIMIT 1 ];
            system.debug('users are '+ users);
            for (User u : users) {
                addresses.add(u.Email);
            }
        }
        else{
            if(cl.Account__r.Primary_Email__C!=null){
                addresses.add(cl.Account__r.Primary_Email__C);
            }
        }
        
        
        String orgWideAdressId = [select id,Business_Group_Name__c ,Object_API_Name__c ,Org_Wide_Address_ID__c 
                                  FROM Org_Wide_Address_Settings__mdt WHERE Object_API_Name__c='Calling_List__c'
                                  AND Business_Group_Name__c=:cl.Unit__r.Business_group__r.name LIMIT 1 ]?.Org_Wide_Address_ID__c;
        if(orgWideAdressId!=''){
            try{ 
                sendEmail(addresses,orgWideAdressId ,sendEmail[0].EmailTempID, cl.ID); 
            }
            catch(Exception ex ){
                system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
                
            }
        }
        
        if(cl.Outcome__c==system.label.Proof_of_Transfer_Collections){
            List<Task> tsks =[select id, Status from Task where Call_Outcome__c=:system.label.Proof_of_Transfer_Collections AND WhatID=:cl.Id];
            system.debug('tsks are '+ tsks);
            for(Task tsk : tsks){
                tsk.Status ='Completed';
            }
            
            try{
                if(!tsks.isEmpty())
                    update tsks;
            }
            
            catch(Exception ex){
                system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
                
            }
            
        }
        else if(cl.Outcome__c==system.label.No_Response_Collections){
            cl.Email_Sent_To_Customer__c = 'Yes';
            try{
                update cl;
                
            } 
            catch(Exception ex ){
                system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
                
            }
        }
      }
        
    }
    
    public static void sendEmail(List<String> ToAdresses, String orgAdrId, String templateID, ID recID){
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage rmail = Messaging.renderStoredEmailTemplate(templateID, null, recID);
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        emailToSend.setToAddresses(ToAdresses);
        emailToSend.setHTMLBody(rmail.getHTMLBody());
        emailToSend.setSubject(rmail.getSubject());
        emailToSend.setWhatID(recID);
        
        emailToSend.setSaveAsActivity(true);
        emailToSend.setOrgWideEmailAddressId(orgAdrId);
        messageList.add(emailToSend);
        Messaging.sendEmail(messageList); 
    }
}