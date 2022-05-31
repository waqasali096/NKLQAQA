public class UnitChangeVfCmptController {
    
    public Id caseId {get;set;}
    public String strUnitType {get;set;}
    
    public List<Case_Unit__c> getCaseUnits(){ 
        List<Case_Unit__c> listCaseUnit = [SELECT Id, Name, Type__c, Unit__r.Unit_Code__c, Unit__r.Project__r.Name, Unit__r.Building__r.Name,
                                           Unit__r.Floor__r.Name, Unit__r.No_of_Bedrooms__c, Unit__r.Leasing_Property_Type__c, 
                                           Unit__r.Unit_space_Type__c, Unit__r.Base_Rent__c, Unit__r.Security_Deposit__c, 
                                           Unit__r.Total_Leasable_Area__c
                                           FROM Case_Unit__c
                                           where Case__c =: caseId AND Type__c =: strUnitType];
        //system.assertEquals(listCaseUnit.size(), 1);
        return listCaseUnit;
    } 
}