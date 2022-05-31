public class AdditionalChargesController {
    @AuraEnabled
    public static Additional_Charges__c findUnitByName(String recordId) {
        Unit_Plan__c unit = [select id,Project__c from Unit_Plan__c where Id =: recordId];
        Additional_Charges__c charges = [Select id,Ejari__c,Security_Deposit__c,Swimming_Pool_Charges__c,Utility_Charges__c from Additional_Charges__c where Project__c  =: unit.Project__c];
        
        return charges;
    }
    @AuraEnabled
    public static String updateOppUnitRecord(String recordId,String selectedejari,String selecteddeposit,String selectedpoolCharges,String selectedutilityCharges) {
    List<Unit_Plan__c> updateOppUnitList = new List<Unit_Plan__c>();
        String message = '';
     Unit_Plan__c unitPlan = new Unit_Plan__c();
     unitPlan.Id = recordId;
     if(selectedejari <> null){
         unitPlan.Ejari__c = Decimal.valueOf(selectedejari);   
     }
     if(selecteddeposit <> null){
         unitPlan.Security_Deposit__c = Decimal.valueOf(selecteddeposit);   
     }
      if(selectedpoolCharges <> null){
         unitPlan.Swimming_Pool_Charges__c = Decimal.valueOf(selectedpoolCharges);   
     }
      if(selectedutilityCharges <> null){
         unitPlan.Utility_Charges__c = Decimal.valueOf(selectedutilityCharges);   
     }
      updateOppUnitList.add(unitPlan);  
        if(updateOppUnitList <> null && updateOppUnitList.size() > 0){
            update updateOppUnitList;
            message = 'success';
            return message;
        }
        return null;
        
    }

}