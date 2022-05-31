/**
* Class Name: LeadStatus7DaysBatch_Test
* class Description: test class for LeadStatus7DaysBatch
* @param: leadListToInsert - List of Lead record to insert
* @param: leadListToUpdate - List of Lead record to update
*/
@istest
public class LeadStatus7DaysBatch_Test {
    @isTest
    public static void testLead(){
        List<Lead> leadListToInsert = new list<Lead>();
        List<Lead> leadListToUpdate = new list<Lead>();
       
leadListToInsert = testDataFactory.createLead(5);        
        for(Lead lead: leadListToInsert)
        {	
            lead.Lead_Stand__c = TRUE;
         //  lead.CreatedDate= LAST_N_DAYS:30;
            leadListToUpdate.add(lead);
            
        }
        update leadListToUpdate;

       system.test.startTest();
        
        LeadStatus7DaysBatch leadBatchClass =new LeadStatus7DaysBatch();
        Database.executeBatch(leadBatchClass);
        
        system.Test.stopTest();
       
    }
}