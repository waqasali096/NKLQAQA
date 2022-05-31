/**
* Name:          CreateDueCallingListBatch
* Description:   Pick the Payment Milestones with Due date falls in next 15 days.
* Author         Jayesh Shewale
*/

public class CreateDueCallingListBatch implements Database.Batchable<sObject> , Schedulable{
    public Database.QueryLocator start(Database.BatchableContext BC){ 
        /*Original Query*/
        Date nxt15Days = system.today().addDays(15);
        Date Today = system.today();
        String query = 'SELECT Id, AccountId, RecordTypeId, Account.Primary_Email__c,(SELECT Id,  Opportunity__r.Account.Primary_Email__c, Payment_Status__c, '
            + ' Due_Date__c, Opportunity__c, Amount__c, Opportunity__r.AccountId FROM Payment_Milestones__r WHERE Payment_Status__c = \'Pending\' AND  Opportunity__r.Unit__r.Unit_Status__c  =\'Sold\''
            + ' AND Due_Calling_List_Record_Created__c = false AND Due_Date__c <=:nxt15Days AND Due_Date__c >=:Today) FROM Opportunity WHERE Id '
            + ' IN (SELECT Opportunity__c FROM Payment_Milestone__c WHERE Payment_Status__c = \'Pending\' AND Opportunity__r.Unit__r.Unit_Status__c  =\'Sold\' '
            + ' AND Due_Calling_List_Record_Created__c = false AND Due_Date__c <=:nxt15Days AND Due_Date__c >=:Today)'; //Query Modified by Jayesh on 25 April for Collection Enhancements.
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> OpportunityRecs){
        system.debug('OpportunityRecs are '+ OpportunityRecs);
        
       try{
            Map<Id,List<Payment_Milestone__c>> oppoPmtMilestoneMap = new Map<Id,List<Payment_Milestone__c>>();    //key : Opportunity Id, Values: Related Invoices
            
            List<Calling_List__c> successCLRecs = new List<Calling_List__c>(); //This variable holds the calling List Successfully inserted records.
            List<Id> successCallingListIds = new List<Id>(); //This variable holds the successful list of Ids of Calling list.
            
            List<Payment_Milestone__c> pmtForCLI= new List<Payment_Milestone__c>();			
            
            for(Opportunity opp : OpportunityRecs){
                system.debug('Milestons are '+ opp.Payment_Milestones__r);
                oppoPmtMilestoneMap.put(opp.Id, opp.Payment_Milestones__r);
                for(Payment_Milestone__c pmtList : opp.Payment_Milestones__r){
                    pmtForCLI.add(pmtList);
                }
                
                
            }       
            
            Group gp = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Collection_Queue' LIMIT 1];
            Id recordTypeId = Schema.SObjectType.Calling_List__c.getRecordTypeInfosByDeveloperName().get('Due').getRecordTypeId();
            //============================================
            //Lets Create the Calling List Records related to Each Opportunity.
            
            List<Calling_List__c> callingList = new List<Calling_List__c>();
            
            List<Opportunity> oppoList = new List<Opportunity>();
            oppoList = [SELECT Id, AccountId,Account.Primary_Email__c, RecordTypeId, Name, StageName, Amount, Unit__c FROM Opportunity WHERE Id IN: oppoPmtMilestoneMap.keySet() LIMIT 49999];
            
            
            for(Opportunity opp : oppoList){ 
                system.debug('milestones are '+ opp.Payment_Milestones__r);
              IF(oppoPmtMilestoneMap.get(opp.ID)!=null&& !oppoPmtMilestoneMap.get(opp.ID).isEmpty()){
                Calling_List__c cl = new Calling_List__c(RecordTypeId = recordTypeId, 
                                                         Account__c = opp.AccountId,
                                                         Unit__c  = opp.Unit__c , 
                                                         Deal__c  = opp.Id, 
                                                         ownerID = gp.Id,
                                                         Calling_List_Type__c = 'Upcoming',
                                                         Primary_Email__c = opp.Account.Primary_Email__c    //Added by Jayesh on 20 April to get the account Email on Calling List.
                                                        ); 
                
                callingList.add(cl);
              }
            }
            
            system.debug('callingList are '+ callingList);
            System.debug('inside execute method');
            
            Database.SaveResult[] srList = Database.insert(callingList, false);
            
            
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted Calling List with Record ID: ' + sr.getId());
                    
                    successCallingListIds.add(sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        
                        // DebugUtility.logError(err);
                        
                    }
                }
            }
            
            if(successCallingListIds != null && !successCallingListIds.isEmpty()){
                
                successCLRecs =  [SELECT Id, Deal__c FROM Calling_List__c WHERE Id IN: successCallingListIds];
                
                //Map<Opportunity, Calling_List__c> callingListOppComb = new Map<Opportunity, Calling_List__c>();
                
                Map<Id, Id> callingListOppComb = new Map<Id, Id>();
                
                for(Calling_List__c cl : successCLRecs){
                    callingListOppComb.put(cl.Deal__c, cl.Id);
                }
                
                
                //Lets create the Calling List line Item records.
                Map<Id, Calling_List_Line_Item__c> pmtCLIMap = new Map<Id, Calling_List_Line_Item__c>();
                List<Payment_Milestone__c> pmtWithCLiList = new List<Payment_Milestone__c>();
                
                if(pmtForCLI.size() > 0){
                    pmtWithCLiList = [SELECT Id, (SELECT ID, Outcome__c FROM Calling_List_Line_Items__r 
                                                  Order By CreatedDate DESC LIMIT 1) FROM Payment_Milestone__c WHERE Id IN: pmtForCLI];
                }
                
                for(Payment_Milestone__c pmt : pmtWithCLiList){
                    List<Calling_List_Line_Item__c> CLI = new List<Calling_List_Line_Item__c>();
                    CLI.addAll(pmt.Calling_List_Line_Items__r);
                    if(!CLI.isEmpty() && CLI != null){ //Added by Jayesh to Avoid violation of Best Practices.
                        // if(CLI[0].Outcome__c != 'Paid' || CLI[0].Outcome_Bounced__c != 'Paid' || CLI[0].Outcome_Presettlement__c != 'Paid' || CLI[0].Outcome_Settlement__c != 'Paid'){
                        
                        pmtCLIMap.put(pmt.Id, pmt.Calling_List_Line_Items__r);      
                    }
                }
                
                
                
                List<Calling_List_Line_Item__c> clItems = new List<Calling_List_Line_Item__c>();
                
                List<Payment_Milestone__c> pmtMilestoneList = new List<Payment_Milestone__c>();
                
                for(Id ids : oppoPmtMilestoneMap.keySet()){   
                    
                    if(oppoPmtMilestoneMap.containsKey(ids)){
                        
                        for(Payment_Milestone__c pmt : oppoPmtMilestoneMap.get(ids)){ //we will modify this later to avoid violation of best practices.
                            if(callingListOppComb.get(pmt.Opportunity__c) != Null){
                                Calling_List_line_Item__c cli = new Calling_List_line_Item__c ();
                                
                                /* if(pmtCLIMap.containsKey(pmt.Id)){
Calling_List_Line_Item__c previousCLI = pmtCLIMap.get(pmt.Id);
cli.Previous_Calling_List_Line_Item__c = previousCLI.Id;
}*/
                                
                                cli.Account__c = pmt.Opportunity__r.AccountId; //Added By Jayesh on 20 April
                                cli.Calling_List__c = callingListOppComb.get(pmt.Opportunity__c);
                                cli.Outstanding_Amount__c  = pmt.Amount__c;
                                cli.Payment_Milestone__c = pmt.Id;
                                cli.Customer_Email__c = pmt.Opportunity__r.Account.Primary_Email__c;
                                cli.X1st_Reminder_Date__c = pmt.Due_Date__c -15;
                                cli.X2nd_Reminder_Date__c = pmt.Due_Date__c -7;
                                cli.X3rd_Reminder_Dare__c = pmt.Due_Date__c;
                                cli.Payment_Status__c = pmt.Payment_Status__c;
                                cli.Amount_to_be_Paid__c =  pmt.Amount__c;//Added By Mamta 27 May

                                
                                clItems.add(cli);
                                
                                pmt.Due_Calling_List_Record_Created__c = true;
                                
                                pmtMilestoneList.add(pmt);
                                
                                System.debug('Hi I am inside for loop');
                            }
                            
                        }
                        
                    }
                    
                }
                
                Database.SaveResult[] srListPMT =  Database.update(pmtMilestoneList, false);
                
                Database.SaveResult[] srListCLItems =  Database.insert(clItems, false);
                EmailTemplate em = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate 
                                          where DeveloperName ='Collection_Executive_Reminders_15_Days1'];
                SendMassEmailTo_Queue.sendEmailNotice(clItems, gp,  em,true);
                
                /*List<EmailTemplate> tmplts = [select id, developerName from EmailTemplate WHERE Developername='Payment_Reminder_to_customer'];
                List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
                List<Calling_List_line_Item__c> clItemsLst =[select id, Calling_List__r.Account__r.Primary_Email__c from Calling_List_line_Item__c WHERE ID IN:clItems];

                for(Calling_List_line_Item__c cl : clItemsLst){
                    Messaging.SingleEmailMessage rmail = Messaging.renderStoredEmailTemplate(tmplts[0].ID, null, cl.ID);
                    List<String> addresses = new List<String>{cl.Calling_List__r.Account__r.Primary_Email__c };
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                    emailToSend.setToAddresses(addresses);
                    emailToSend.setHTMLBody(rmail.getHTMLBody());
                    emailToSend.setSubject(rmail.getSubject());
                    //emailToSend.setFileAttachments(email.getFileAttachments());
                    emailToSend.setWhatID(cl.ID);
                    emailToSend.setSaveAsActivity(true);
                    messageList.add(emailToSend);
                    
        }  
        
       Messaging.sendEmail(messageList);*/

                        
            } 
            
       }
        catch(System.Exception ex){
            Debugutility.logError(ex);
            system.debug(ex.getMessage()); 
        }
    }  
    public void finish(Database.BatchableContext BC) {
        System.debug('Finish Method Completed.');
        
    } 
    
    public void execute(SchedulableContext sc)
    {
      database.executeBatch(new CreateDueCallingListBatch(),200); 
         
    }
    
    
}