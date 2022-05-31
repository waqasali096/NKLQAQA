/**************************************************************************************************
* Name               : PaymentRemindertoCustomer_Batch                                                      
* Description        : Payment reminder to customer based on due date on calling List Item
* Created Date       : 10/03/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      10/03/2022      Initial Draft.                                               
**************************************************************************************************/

public class PaymentRemindertoCustomer_Batch implements Database.Batchable<sObject>, Schedulable {


    public Database.QueryLocator start(Database.BatchableContext BC)
        
    {

        Date daysAfter15 = system.today().addDays(15);
        Date daysAfter7= system.today().addDays(7);
        Date today =   system.today();
        Date yesterday =   system.today().addDays(-1);
        String query = ' select id, Payment_Status__c,calling_List__r.Unit__r.Business_group__r.name,Due_Date__c ,Email__c ,Calling_List__r.Account__r.Primary_Email__c   from Calling_List_line_Item__c  WHERE  Payment_Status__c = \'Pending\'  '
                     +  ' AND   (Due_Date__c=:daysAfter7 OR  Due_Date__c=:today OR  Due_Date__c=:yesterday OR Due_Date__c=:daysAfter15) ' ;
        return Database.getQueryLocator(query);
    }
    
    public void execute(SchedulableContext sc)
    {
       
        PaymentRemindertoCustomer_Batch b = new PaymentRemindertoCustomer_Batch ();
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
 
    public void execute(Database.BatchableContext BC, List<Calling_List_line_Item__c> clItems)
    {
      List<EmailTemplate> upcomgTmplts = [select id, developerName from EmailTemplate WHERE Developername='Payment_Reminder_to_customer'];
      List<EmailTemplate> overDueTmplts = [select id, developerName from EmailTemplate WHERE Developername='Overdue_Payment_Reminder_to_customer'];
  
      List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
      List<Org_Wide_Address_Settings__mdt>  orgWideAddressMetadata = [select id,Business_Group_Name__c ,Object_API_Name__c ,Org_Wide_Address_ID__c 
                                                                      FROM Org_Wide_Address_Settings__mdt WHERE Object_API_Name__c='Calling_List__c'];
        
      system.debug('orgWideAddressMetadata are '+ orgWideAddressMetadata);  
      Map<String,String> businessGroup_OrgIDMAp = new Map<String,String> ();
      for(Org_Wide_Address_Settings__mdt mdt: orgWideAddressMetadata){
            businessGroup_OrgIDMAp.put(mdt.Business_Group_Name__c , mdt.Org_Wide_Address_ID__c);
        } 
        
        for(Calling_List_line_Item__c cl : clItems){
           String tempID = '';
            if(cl.Due_Date__c<System.Today()){
               tempID =  upcomgTmplts[0].ID;
            } 
            else{
               tempID =  overDueTmplts[0].ID;
            }
            String businessGrpName = cl.calling_List__r.Unit__r.Business_group__r.name;
            if(!businessGroup_OrgIDMAp.isEmpty() ){
                ID orgAddressID =  businessGroup_OrgIDMAp.get(businessGrpName);
                if(orgAddressID!=null){
                    Messaging.SingleEmailMessage rmail = Messaging.renderStoredEmailTemplate(tempID, null, cl.ID);
                    List<String> addresses = new List<String>{cl.Calling_List__r.Account__r.Primary_Email__c};
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                    emailToSend.setToAddresses(addresses);
                    emailToSend.setHTMLBody(rmail.getHTMLBody());
                    emailToSend.setSubject(rmail.getSubject());
                    emailToSend.setOrgWideEmailAddressId(orgAddressID);
                    emailToSend.setWhatID(cl.ID);
                    emailToSend.setSaveAsActivity(true);
                    messageList.add(emailToSend);
                }
            }
            
        } 
        system.debug('messageList is '+ messageList);
      try{
          if(!messageList.isEmpty()){   
            Messaging.sendEmail(messageList);
          }
      }
      catch(Exception ex ){
          DebugUtility.logError(ex);
            
        }

        
                           
    }
    

    public void finish(Database.BatchableContext BC)
    {
    }
}