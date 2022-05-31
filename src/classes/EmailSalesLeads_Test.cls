@isTest
public with sharing class EmailSalesLeads_Test {
    @isTest  
    public static void testEmailLead() 
    {  
        TestDataFactory.createEmailSales();
        TestDataFactory.createLead(1);
    }
}