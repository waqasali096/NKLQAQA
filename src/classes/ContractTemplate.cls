/**
* @description      Fetch Contract data 
* @param            ConrtactId
* @return           List<Lease_Contract__c>
* @throws           NA
* @author Kshitij Tiwari
*/

public class ContractTemplate {
    
    
    public Id ContractId {get;set;}
    public Decimal Amount {get;set;}
    public string unitCode {get;set;}
   

    public List<Lease_Contract__c> getContracts(){
        List<Lease_Contract__c> contractList = [SELECT Id,Name,Contract_Stages__c,Opportunity__r.Project__r.Name, Contract_Start_Date__c, Contract_End_Date__c,Opportunity__r.Amount 
                                                ,(Select Unit__r.Unit_Code__c, Final_Lease_Amount__c from Opportunity_Units__r)
                                                FROM Lease_Contract__c
                                                where id =:ContractId];
        if(!contractList.isEmpty() && !contractList[0].Opportunity_Units__r.isEmpty()){
       //  List<Unit_plan__c> upList =[Select id, Final_Lease_Amount__c from Unit_Plan__c where Opportunity__c =:contractList[0].Opportunity__c];
        Amount =contractList[0].Opportunity_Units__r[0].Final_Lease_Amount__c;
            unitCode = contractList[0].Opportunity_Units__r[0].Unit__r.Unit_Code__c;
        }
        return contractList;
    }
    


}