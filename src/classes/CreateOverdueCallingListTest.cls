@isTest
private class CreateOverdueCallingListTest {
    static List<Account> accounts = new List<Account>();
    
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
        
        
        List<Project__c> projectList = TestDataFactory.createProject();
        List<Floor__c> floorList = TestDataFactory.createFloor();
        List<Space_Type__c> spaceTypeList = TestDataFactory.createSpaceType();
        List<Unit__c> unitList = new List<Unit__c>();
        Unit__c unit = New Unit__c();
        unit.Name = 'Test Unit 1';
        unit.Unit_Code__c = 'Unit Code';
        unit.Date_when_Leasing_status_changes__c = system.today();
        unit.Unit_Status__c = 'Pre-Booking';
        unit.Floor__c = floorList[0].Id;
        unit.Project__c = projectList[0].Id;
        unit.Space_Types__c = spaceTypeList[0].Id;
        unit.Unit_Alias__c = 'Test';
        
        unitList.add(unit);
        
        insert unitList;
        
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
            opp.Unit__c = unitList[0].Id;
            
            system.debug('Opp' +opp);
            oppList.add(opp);
        } 
        
        insert oppList;
        system.debug('list' +oppList);
        
        
        
        List<Payment_Milestone__c> pmtList = TestDataFactory.createOppPaymentMilestone();
        
        
        Payment_Milestone__c pmtMilestone = new Payment_Milestone__c(
            Name = 'PM 5 Demo',                
            Due_Date__c = System.today()-1,
            
            Payment_Status__c = 'Pending',       
            Opportunity__c = oppList[0].Id,        
            Amount__c = 500,               
            Unit__c = unitList[0].Id               
           
        );
        insert pmtMilestone; 
        
        
        
    }
    
    @isTest
    private static void testBatch(){
        
        
        Test.startTest();
        ID batchprocessid = Database.executeBatch(new CreateOverdueCallingList());
        Test.stopTest();
        
        for(Payment_Milestone__c pmt : [SELECT Id, Overdue_Calling_List_Record_Created__c FROM Payment_Milestone__c WHERE Payment_Status__c = 'Pending']){
            
            System.assertEquals(true, pmt.Overdue_Calling_List_Record_Created__c);
        }
        
    }
}