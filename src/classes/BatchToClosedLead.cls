/**
 * Name:          BatchToClosedLead
 * Description:   After 90 days if not 
 * Author         Manish Goswami
 */
global class BatchToClosedLead implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query= 'SELECT Id,Status FROM Lead WHERE CreatedDate > LAST_90_DAYS';
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> scope)
    {
        for(Lead l: scope)
        {
            l.LeadSource ='Closed';
            system.debug(l);
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}