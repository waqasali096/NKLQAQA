/*
Name: SendMailForEmailAlertsQueueable
Purporse: Sending an email using Queueable
Author: Jayesh Shewale
*/

public without sharing class SendMailForEmailAlertsQueueable implements Queueable, Database.AllowsCallouts {
    
    List<String> emailalertList;//API Names of Email Alert
    String recordId; 
    String OrgWideDefaultAddress;
    
    public SendMailForEmailAlertsQueueable(List<String> emailalertList, String recordId, String OrgWideDefaultAddress){
        this.emailalertList = emailalertList;
        this.recordId = recordId;
        this.OrgWideDefaultAddress= OrgWideDefaultAddress;
    }
    public void execute(QueueableContext context){
        List<Messaging.SingleEmailMessage> singleemaillist = new List<Messaging.SingleEmailMessage>();
        singleemaillist.add(SendMailForEmailAlerts.send(emailalertList,recordId, OrgWideDefaultAddress));     
    }
}