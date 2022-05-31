@isTest
private class UpdateOpportunityFinancialsTest {
    
    @testsetup
    static void dataSetup() {
        //Create Accounts
        
        
        List<Account> accounts = TestDataFactory.createAccounts(2);
        List<Contact> conList = TestDataFactory.createContacts(1, accounts);
        
        
        //insert Custom setting records.
        AppSettings__c  cs = new AppSettings__c();
        cs.Name='OrgWideEmailAddressForSR ';
        cs.TextValue__c = 'Info@brokers.nakheel.com';
        insert cs;
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Unit_Opportunity').getRecordTypeId();
        List<Opportunity> oppList = new List<Opportunity>();
        
        for(integer i=0;i<5;i++){
            Opportunity opp = new Opportunity();
            opp.Name='Test-Opp'+i;
            opp.RecordTypeId = oppRecordTypeId;
            opp.StageName = 'Contract Generation';
            opp.PDC_Captured__c=true;
            opp.Unit_Status__c='Assigned';
            opp.Booking_Fee_gets_collected__c=true;
            opp.Booking_Mode__c='Reservation with token amount';
            opp.Booking_Amount__c=5000;
            opp.StageName = 'New';
            opp.CloseDate = System.today();
            opp.Interested_In__c='Residential Leasing';
            opp.Leasing_Type__c='Residential Units';
            opp.Booking_Reservation_Date__c=system.today();
            opp.AccountId=accounts[0].Id;
            opp.Grace_Period_Days__c = 2;
            opp.Lease_Start_Date__c = system.today();
            opp.Lease_End_Date__c = system.today()+5;
            opp.Time_to_Close_Quick_Book__c = system.today()+5;
            
            
            system.debug('Opp' +opp);
            oppList.add(opp);
        } 
        
        insert oppList;
        system.debug('list' +oppList);
        
        Receipt__c receiptRec = new Receipt__c(
            Name = 'Payment 1232',                   
            Amount__c = 10001,                      
            
            Due_Date__c = System.today(),  // Due Date
            
            Account__c = accounts[0].Id,            // Account
            Opportunity__c = oppList[0].Id      
            
            
        );
        insert receiptRec;
        
    }
    @isTest
    private static void testUpdateOpportunityFinancials(){
        Test.startTest();
        List<Receipt__c> receiptLst = new List<Receipt__c>();
        receiptLst = [SELECT Id FROM Receipt__c];
        update receiptLst;
        Test.stopTest();
    }
    
}