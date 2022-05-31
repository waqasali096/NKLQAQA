@isTest
public with sharing class EmailLeasingLeads_Test {
    @isTest  
    public static void testEmailLead() 
    {  
        TestDataFactory.createEmailLeasing();
            TestDataFactory.createLead(1);
           
        }



}