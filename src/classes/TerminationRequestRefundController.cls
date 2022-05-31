public class TerminationRequestRefundController {
   
    @AuraEnabled
    public static Case getCaseDetails(String recordId){
        try {
            Case cse = [SELECT Id, Subject, Termination_Type__c, Premature_Termination_Reason__c, No_of_Mths_Rent_Deduction__c,
                            End_Of_Lease_Termination_Reason__c, Lease_Start_Date__c, Lease_End_Date__c,Penalty_charges__c,
                            Expected_Termination_Date__c, Actual_Termination_Date__c, Lease_End_Date_w_o_Grace_days__c,Refund_Applicable__c
                              FROM Case WHERE Id=:recordId];
            return cse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}