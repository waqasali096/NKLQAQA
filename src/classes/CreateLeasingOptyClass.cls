/***************************************
* CreateLeasingOptyClass : Created by jaskiran as part of leasing flow
* Creation Date :19th Jan,2022
* Version : 1
* purpose : Class is used to create 
* ************************************/
public class CreateLeasingOptyClass {
    
    // Method to get the Project List 
    @AuraEnabled
    public static map<string,string> fetchProjects(){
        map<string,string> mapProjects = new map<string,string>();
        for(Project__c proj :[select Id,Name from Project__c where Project_Purpose__c = 'Leasing' order by name])
        { mapProjects.put(proj.Id,proj.Name);
        }       
        return mapProjects;
    }
    
    @AuraEnabled
    public static decimal fetchHoldingDepositAmount(String recordId){
        decimal holdingDeposit = 0.00;
        for(Unit_Plan__c unitPlan :[select Id,Unit__r.Holding_Deposit_Amount__c from Unit_Plan__c where Opportunity__c =: recordId])
        { 
            if(String.isNotEmpty(String.valueOf(unitPlan.Unit__r.Holding_Deposit_Amount__c))){
                holdingDeposit = holdingDeposit + unitPlan.Unit__r.Holding_Deposit_Amount__c;
            } 
        }       
        return holdingDeposit;
    }
    
     @AuraEnabled
    public static wrapperClass mandatoryCheck(String recordId){
        
        wrapperClass wc = new wrapperClass();
        wc.isAgencyAttached = false;
        Opportunity opp = [Select Id,AccountId, Agency_Name__c FROM Opportunity where Id =: recordId];
        List<Unit_Plan__c> uplist = [Select Id FROM Unit_Plan__c where opportunity__c =: recordId];
        if(String.isNotBlank(opp.AccountId) && uplist.size() > 0){
            if(String.isNotBlank(opp.Agency_Name__c)){
                wc.isAgencyAttached = true;
            }
            wc.mandateCheck = false;
        } else {
            wc.mandateCheck = true;
        }
        
        return wc;
    }
    
    @AuraEnabled
    public static String convertRecordType(String recordId,String BookingMode,String paymentMode,Decimal TokenAmount,Date leasingStartDate){
        String successMessage;Boolean restrictConversionwithBookingAmount;Boolean restrictConversionwithoutBookingAmount;
        Opportunity oppRecord = new Opportunity();
        Set<String> unitIds = new Set<String>();
        List<Unit_Booking_Reservation__c> updateReserveRecords = new List<Unit_Booking_Reservation__c>();
        List<Unit_Booking_Reservation__c> insertReservationList = new List<Unit_Booking_Reservation__c>();
        if(String.isNotBlank(recordId)){
            ID projectId; // Added by Sajid
            oppRecord = [Select Id,Leasing_Type__c,StageName,PersqReason__c,Per_sqft_Price__c,Account.RecordType.DeveloperName FROM Opportunity where Id =: recordId limit 1];
                        List<Unit_Plan__c> unitPlanList = [Select Id,Unit__c, Unit__r.Project__c FROM Unit_Plan__c where opportunity__c =: recordId]; //Modified by sajid
            for(Unit_Plan__c unitPlan : unitPlanList){
                unitIds.add(unitPlan.Unit__c); 
                Unit_Booking_Reservation__c unitReserveObj = new Unit_Booking_Reservation__c();
                unitReserveObj.Reserved_User__c = userInfo.getUserId();
                unitReserveObj.Deal__c = recordId;
                unitReserveObj.Reservation_Date__c = system.now().addHours(4);
                unitReserveObj.Unit__c = unitPlan.unit__c;
                insertReservationList.add(unitReserveObj);
                projectId = unitPlan.Unit__r.Project__c; //Added by Sajid
            }
            if(insertReservationList.size() > 0){
                insert insertReservationList;
            }
             RecordType recType;
            if(!validateSubmitDeal(oppRecord,unitIds)){
                if(oppRecord.Leasing_Type__c == System.label.Units_Leasing_type && oppRecord.Account.RecordType.DeveloperName == 'Business_RecordType'){
                     recType = [Select ID,Name,DeveloperName FROM Recordtype where SobjectType = 'Opportunity' and DeveloperName = 'Residential_Leasing_Unit_Corporate'];
                    oppRecord.RecordTypeId = recType.Id;                
                }
                if(oppRecord.Leasing_Type__c == System.label.Shop_Leasing_type && oppRecord.Account.RecordType.DeveloperName == 'Business_RecordType'){
                     recType = [Select ID,Name,DeveloperName FROM Recordtype where SobjectType = 'Opportunity' and DeveloperName = 'Residential_Leasing_Shop_Opportunity'];
                    oppRecord.RecordTypeId = recType.Id;    
                }else if(oppRecord.Leasing_Type__c == System.label.Units_Leasing_type && oppRecord.Account.RecordType.DeveloperName == 'PersonAccount'){
                    recType = [Select ID,Name,DeveloperName FROM Recordtype where SobjectType = 'Opportunity' and DeveloperName = 'Residential_Leasing_Unit_Opportunity'];
                    oppRecord.RecordTypeId = recType.Id;   
                }
                oppRecord.Booking_Mode__c = BookingMode;
                //oppRecord.Payment_Mode__c = paymentMode;
                oppRecord.StageName = System.Label.UnitReservationLabel;
                oppRecord.Booking_Amount__c = TokenAmount;
                oppRecord.Project__c = projectId;//Added by Sajid
                update oppRecord;
                successMessage = 'Record Updated Successfully';
            } else {
                List<unit__c> unitList = new List<unit__c>();
                successMessage = 'You cannot re-book this unit for next 48 hours';
                for(Unit_Plan__c uPlan : unitPlanList){
                    Unit__c unitObj = new Unit__c();
                    unitObj.Id = uPlan.unit__c;
                    unitObj.Unit_Status__c = 'Vacant';
                    unitList.add(unitObj);
                }
                if(unitList.size() > 0){
                    update unitList;
                }
                if(unitPlanList.size() > 0){
                    delete unitPlanList;
                }
            }
        }
        
        return successMessage;
    }
/*
@Author : Swapnil Mohite
@CreatedDate: 28/03/2022
@ This method will validate if Leasing exec can book the unit or not.
*/
     public static Boolean validateSubmitDeal(Opportunity oppRecord,Set<String> unitIds){
         Boolean flag = false;
         List<Unit_Booking_Reservation__c> ubrList = [SELECT id,name,Booking_Mode__c,Reservation_Date__c,deal__r.Booking_Mode__c
                                                      FROM Unit_Booking_Reservation__c
                                                      WHERE Unit__c IN : unitIds and reserved_user__c =: userInfo.getUserId()];
         for(Unit_Booking_Reservation__c ubrObj : ubrList){
             if(ubrObj.deal__r.Booking_Mode__c == 'Reservation without token amount' && system.now() <  ubrObj.Reservation_Date__c){
                flag = true; 
             }
         }
         
         return flag;
    }
    /*
@Author : Sajid
@CreatedDate: 16/04/2022
@ This wrapper retrun in mandatorymethod;.
*/
    public class wrapperClass{
        @AuraEnabled
        public Boolean mandateCheck{get;set;}
        @AuraEnabled
        public Boolean isAgencyAttached{get;set;}
        
    }
    
}