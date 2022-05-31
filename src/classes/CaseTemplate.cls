/**
* @description      Fetch Contract data 
* @param            ConrtactId
* @return           List<Lease_Contract__c>
* @throws           NA
* @author Kshitij Tiwari
*/

public class CaseTemplate {
    
    
    public Id CaseId {get;set;}
 

    
    public List<Case> getServiceRequest(){
        List<Case> caseList = [SELECT Id,Unit__r.Unit_Code__c,Deal__r.Project__r.name,status,Deal__r.Lease_Start_Date__c,Deal__r.Lease_End_Date__c,Lease_Amount__c
                               from case 
                               where id =: CaseId];
     
        return caseList;
    }
    
    public List<Case_Unit__c> getCaseUnits(){
        List<Case_Unit__c> caseUnits = [SELECT Id, Unit__c,Case__c,Case__r.Lease_Start_Date__c,Case__r.Lease_End_Date__c,Case__r.Expected_Termination_Date__c,
                                        Case__r.Actual_Termination_Date__c, Unit__r.Unit_Code__c, Case__r.Deal__r.Project__r.name, Case__r.Status FROM Case_Unit__c WHERE Case__c =: CaseId];
        return caseUnits;
    }




}