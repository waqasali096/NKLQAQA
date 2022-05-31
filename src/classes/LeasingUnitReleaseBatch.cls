/*
@Author : Swapnil Mohite
@CreatedDate: 28/03/2022
@ This batch class will handle unit reservation based on reservation mode- this batch will run every 4 hours .
*/
Global class LeasingUnitReleaseBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String formatedDt = DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        string soql =  'Select Id,Reserved_User__c,Unit__c,Unit__r.Unit_status__c,ProcessRecords__c,Deal__r.Opportunity_Approval_Status__c,Deal__r.Booking_Mode__c,Deal__r.Security_Deposit_Recevied__c,Deal__r.Booking_Fee_gets_collected__c,Reservation_Date__c,Unit_Reservation_Start_date__c,Deal__c,Booking_Mode__c FROM Unit_Booking_Reservation__c WHERE Unit__r.Unit_status__c = \'On Hold\' and Reservation_Date__c <='+formatedDt;
        system.debug('-->'+ Database.getQueryLocator(soql));//and Reservation_Date__c <='+formatedDt;
        return Database.getQueryLocator(soql);
    }
    global void execute(Database.BatchableContext bc, List<Unit_Booking_Reservation__c> scope){
        List<Unit__c> unlistUpdate = new List<Unit__c>();
        List<Opportunity> OppList = new List<Opportunity>();
        Set<Id> unitId = new Set<Id>();
        Set<Id> oppId = new Set<Id>();
        List<Unit_Booking_Reservation__c> updateUBReservation = new List<Unit_Booking_Reservation__c>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        
        for(Unit_Booking_Reservation__c ubreservation : scope){
            Unit__c unitObj = new Unit__c();
            unitObj.Id = ubreservation.Unit__c;
            system.debug('ubreservation-->'+ubreservation.Reservation_Date__c);
            Opportunity opp = new Opportunity();
            if(ubreservation.deal__r.Booking_Mode__c == 'Reservation without token amount'){
                if(ubreservation.deal__r.Security_Deposit_Recevied__c == true){
                    /*
                    unitObj.Unit_Status__c = 'Booked';
                    opp.Id = ubreservation.Deal__c;
                    opp.StageName = 'Booking';
                    oppList.add(opp);*/
                }else{
                    unitObj.Unit_Status__c = 'Vacant';
                    ubreservation.Reservation_Date__c = ubreservation.Reservation_Date__c.addHours(48);
                    opp.Id = ubreservation.Deal__c;
                    opp.StageName = 'Closed Lost';
                    opp.Loss_Reason__c = 'No Decision / Non-Responsive';
                    oppList.add(opp);
                }
                ubreservation.ProcessRecords__c  = true; // put condition so that it will not take this records again and not add the hours again
            }else if(ubreservation.deal__r.Booking_Mode__c == 'Reservation with token amount'){
                if(ubreservation.deal__r.Booking_Fee_gets_collected__c == true && ubreservation.Deal__r.Security_Deposit_Recevied__c == false){
                    if(ubreservation.ProcessRecords__c == false){
                        ubreservation.Reservation_Date__c = ubreservation.Reservation_Date__c.addDays(7); //. this condition is executed when booking fee is collected - additional 7 days
                        ubreservation.ProcessRecords__c  = true;
                    }else if(ubreservation.deal__r.Opportunity_Approval_Status__c != 'Pending' ){
                        unitObj.Unit_Status__c = 'Vacant'; // after 7 days if security deposit is not collected 
                        opp.Id = ubreservation.Deal__c;
                        opp.StageName = 'Closed Lost';
                        opp.Loss_Reason__c = 'No Decision / Non-Responsive';
                        oppList.add(opp);
                    }
                }else if(ubreservation.deal__r.Booking_Fee_gets_collected__c == true && ubreservation.Deal__r.Security_Deposit_Recevied__c == true){
                 /*   unitObj.Unit_Status__c = 'Booked'; // every fee is collected so booked
                    opp.Id = ubreservation.Deal__c;
                    opp.StageName = 'Booking';
                    oppList.add(opp);*/
                }
                else{
                    unitObj.Unit_Status__c = 'Vacant'; //. this condition will be executed when no holding deposit payment is made within 4 hours
                    opp.Id = ubreservation.Deal__c;
                    opp.StageName = 'Closed Lost';
                    opp.Loss_Reason__c = 'No Decision / Non-Responsive';
                    oppList.add(opp);
                }  
            } 
            unlistUpdate.add(unitObj); 
        }
        if(unlistUpdate.size() > 0){
            update unlistUpdate;
        }
        if(oppList.size() > 0){
            update oppList;
        }
        update scope;
    }
    global void finish(Database.BatchableContext bc){
    }
}