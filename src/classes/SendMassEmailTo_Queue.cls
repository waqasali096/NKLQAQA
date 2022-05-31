/**************************************************************************************************
* Name               : SendMassEmailTo_Queue                                                      
* Description        : Send Email in Bulk
* Created Date       : 09/03/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      09/03/2022      Initial Draft.                                               
**************************************************************************************************/
public class SendMassEmailTo_Queue {
    
 
    public static void sendEmailNotice(List<sObject> sObjs, Group grp , EmailTemplate em, boolean saveAsActivity){
        Contact con =[Select id,email from Contact WHERE email!=null LIMIT 1 ];    
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        
        
      
        List<String> addresses = new List<String>();
        List<User> users = [select id,firstName,lastName, email from user where id in (select userorgroupid from groupmember 
                                                                                       where group.developername =:grp.developername)];
        system.debug('users are '+ users);
        for (User u : users) {
            addresses.add(u.Email);
        } 
       
        system.debug(' addresses is '+ addresses);
        OrgWideEmailAddress orgWideEmailAddress = new OrgWideEmailAddress();
        orgWideEmailAddress = [select id, Address, DisplayName from OrgWideEmailAddress Where DisplayName=:system.label.Org_Wide_Default_Address LIMIT 1 ];
        for(sObject obj : sObjs){  
            ID recID = (ID)(obj.get('Id'));
            String sObjName = recID.getSObjectType().getDescribe().getName();

            Messaging.SingleEmailMessage rmail ;
            if(sObjName!='Lead'){
               rmail = Messaging.renderStoredEmailTemplate(em.ID, null, recID);
            }
            else{
               rmail = Messaging.renderStoredEmailTemplate(em.ID, recID, null);
   
            }

            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(addresses);
            emailToSend.setHTMLBody(rmail.getHTMLBody());
            emailToSend.setSubject(rmail.getSubject());
            //emailToSend.FromAddress('');
            //emailToSend.setFileAttachments(email.getFileAttachments());
            if(sObjName!='Lead'){
              emailToSend.setWhatID(recID);
            }
            else{
              emailToSend.setTargetObjectId(recID);  
            }
            emailToSend.setSaveAsActivity(saveAsActivity);
            if(orgWideEmailAddress!=null){
                emailToSend.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
            }  
            messageList.add(emailToSend);
        } 
        
        Messaging.sendEmail(messageList);
      
    }
    
    

}