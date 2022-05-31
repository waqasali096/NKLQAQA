global class PropertyEndLeaseNotificationBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName = 'Property'];
    list<Opportunity> lstOppUpdate = new list<Opportunity>();
    set<Id> setOppIDUpdate = new set<Id>();
    global database.querylocator start(Database.BatchableContext BC) {
        System.debug('Hello from batch');
         return Database.getQueryLocator([SELECT Id, Name, Unit__c, Deal__c, Deal__r.Email__c,Deal__r.Enable_renewal_contract_button__c, Unit__r.Unit_Code__c, 
                                         End_Date__c, Primary_Email__c, CreatedById FROM Property__c WHERE 
                                         End_Date__c <=: System.today()+90 AND End_Date__c >=: System.today()-15]);
        /*return Database.getQueryLocator([SELECT Id, Name, Unit__c, Deal__c, Deal__r.Email__c,Deal__r.Enable_renewal_contract_button__c, Unit__r.Unit_Code__c, 
                                         End_Date__c, Primary_Email__c, CreatedById FROM Property__c WHERE 
                                         End_Date__c =: System.today()+15 OR End_Date__c =: System.today()+30 OR
                                        	End_Date__c	=: System.today()+60 OR End_Date__c =: System.today()+90 OR End_Date__c =: System.today()-15]);*/
    }
   
    global void execute(Database.BatchableContext BC, Sobject[] scope) {
        //List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
        set<Id> setOppId90Days=new set<Id>();
        set<Id> setOppId60Days=new set<Id>();
        set<Id> setOppId30Days=new set<Id>();
        set<Id> setOppId15Days=new set<Id>();
        set<Id> setOppIdExp15Days=new set<Id>();
        system.debug('scope.size'+scope.size());
        for(Property__c property :(List<Property__c>) scope) {
            //if(property.Primary_Email__c!= null){
            System.debug('Property Name >>>'+property);
            
                if(property.End_Date__c==System.today()+90 && property.Deal__r.Email__c!=null){
                    setOppId90Days.add(property.Deal__c);
                }
                else if(property.End_Date__c==System.today()+60 && property.Deal__r.Email__c!=null){
                    setOppId60Days.add(property.Deal__c);
                }
                else if(property.End_Date__c==System.today()+30 && property.Deal__r.Email__c!=null){
                    setOppId30Days.add(property.Deal__c);
                }
                else if(property.End_Date__c==System.today()+15 && property.Deal__r.Email__c!=null){
                    setOppId15Days.add(property.Deal__c);
                }
                else if(property.End_Date__c==System.today()-15 && property.Deal__r.Email__c!=null){
                    setOppIdExp15Days.add(property.Deal__c);
                }
            
            if(/*property.End_Date__c==System.today()+90 &&*/property.Deal__r.Enable_renewal_contract_button__c==false && !setOppIDUpdate.contains(property.Deal__c)){
                Opportunity opp=new opportunity();
                opp.id=property.Deal__c;
                opp.Enable_renewal_contract_button__c=true;
                setOppIDUpdate.add(property.Deal__c);
                lstOppUpdate.add(opp);
            }
          // }
    }
        if(!lstOppUpdate.isEmpty()){
            database.update(lstOppUpdate,false);
        }
        if(!setOppId90Days.isEmpty()){
            for(Id o: setOppId90Days){
                SendMailForEmailAlertsRenewal.InvokeSendEmail sendEmailObj = new SendMailForEmailAlertsRenewal.InvokeSendEmail();
            sendEmailObj.EmailAlertAPIName = 'Lease_renewal_email_alert';
                sendEmailObj.RecordId = o;
            List<SendMailForEmailAlertsRenewal.InvokeSendEmail> requests = new List<SendMailForEmailAlertsRenewal.InvokeSendEmail>();
            requests.add(sendEmailObj);
            SendMailForEmailAlertsRenewal.sendEmail(requests);    
            SendMailForEmailAlertsRenewal.InvokeSendEmail sendEmailObj1 = new SendMailForEmailAlertsRenewal.InvokeSendEmail();
            sendEmailObj1.EmailAlertAPIName = 'Renewal_notice';
            sendEmailObj1.RecordId = o;
            List<SendMailForEmailAlertsRenewal.InvokeSendEmail> requests1 = new List<SendMailForEmailAlertsRenewal.InvokeSendEmail>();
            requests1.add(sendEmailObj1);
            SendMailForEmailAlertsRenewal.sendEmail(requests1);
                
            }
        }
        if(!setOppId60Days.isEmpty()){
            for(Id o: setOppId60Days){
                SendMailForEmailAlertsRenewal.InvokeSendEmail sendEmailObj = new SendMailForEmailAlertsRenewal.InvokeSendEmail();
            sendEmailObj.EmailAlertAPIName = 'Lease_renewal_email_alert_60_days';
                sendEmailObj.RecordId = o;
            List<SendMailForEmailAlertsRenewal.InvokeSendEmail> requests = new List<SendMailForEmailAlertsRenewal.InvokeSendEmail>();
            requests.add(sendEmailObj);
            SendMailForEmailAlertsRenewal.sendEmail(requests);
                
            }
        }
        if(!setOppId30Days.isEmpty()){
            for(Id o: setOppId30Days){
                SendMailForEmailAlertsRenewal.InvokeSendEmail sendEmailObj = new SendMailForEmailAlertsRenewal.InvokeSendEmail();
            sendEmailObj.EmailAlertAPIName = 'Lease_renewal_email_alert_30_days';
                sendEmailObj.RecordId = o;
            List<SendMailForEmailAlertsRenewal.InvokeSendEmail> requests = new List<SendMailForEmailAlertsRenewal.InvokeSendEmail>();
            requests.add(sendEmailObj);
            SendMailForEmailAlertsRenewal.sendEmail(requests);
                
            }
        }
        if(!setOppId15Days.isEmpty()){
            for(Id o: setOppId15Days){
                SendMailForEmailAlertsRenewal.InvokeSendEmail sendEmailObj = new SendMailForEmailAlertsRenewal.InvokeSendEmail();
            sendEmailObj.EmailAlertAPIName = 'Lease_renewal_email_alert_15_days';
                sendEmailObj.RecordId = o;
            List<SendMailForEmailAlertsRenewal.InvokeSendEmail> requests = new List<SendMailForEmailAlertsRenewal.InvokeSendEmail>();
            requests.add(sendEmailObj);
            SendMailForEmailAlertsRenewal.sendEmail(requests);
                
            }
        }
        
        if(!setOppIdExp15Days.isEmpty()){
            for(Id o: setOppIdExp15Days){
                SendMailForEmailAlertsRenewal.InvokeSendEmail sendEmailObj = new SendMailForEmailAlertsRenewal.InvokeSendEmail();
            sendEmailObj.EmailAlertAPIName = 'Lease_Expired_notification_15_days';
                sendEmailObj.RecordId = o;
            List<SendMailForEmailAlertsRenewal.InvokeSendEmail> requests = new List<SendMailForEmailAlertsRenewal.InvokeSendEmail>();
            requests.add(sendEmailObj);
            SendMailForEmailAlertsRenewal.sendEmail(requests);
                
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }

}