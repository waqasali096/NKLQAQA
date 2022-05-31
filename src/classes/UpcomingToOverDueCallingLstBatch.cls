/**************************************************************************************************
* Name               : OverDueToDueCallingLstBatch                                                      
* Description        : Move OverDue
* Created Date       : 19/05/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      19/05/2022       Initial Draft.                                               
**************************************************************************************************/
global class UpcomingToOverDueCallingLstBatch implements Database.Batchable<sObject>, Schedulable{ 

     global  Database.QueryLocator start(Database.BatchableContext BC){ 
        String query='select id from Calling_List_Line_Item__c WHERE Payment_Milestone__r.Due_Date__c =:Yesterday AND '+ 
                      '  Calling_List__r.RecordType.DeveloperName=\'Due\' ';
         
        return Database.getQueryLocator(query);
    }
    
        global  void execute(Database.BatchableContext BC, List<Calling_List_Line_Item__c> callingListItems){
            Set<ID> callingListIDS = new Set<ID>();
            for(Calling_List_Line_Item__c cl : callingListItems){
                callingListIDS.add(cl.Calling_List__c);
            }
            List<Calling_List__c> callingLsts =[select id, RecordType.DeveloperName from Calling_List__c WHERE ID IN: callingListIDS];
            for(Calling_List__c cl : callingLsts){
                cl.RecordType.DeveloperName = 'Overdue';
               } 
            
            try{
                update callingLsts;
            }
            catch(Exception ex ){
                  DebugUtility.logError(ex);
            }
            
        }
    
     global  void finish(Database.BatchableContext BC) {
        
    } 
    
     global void execute(SchedulableContext sc)
    {
      database.executeBatch(new UpcomingToOverDueCallingLstBatch(),200); 
         
    }
    

}