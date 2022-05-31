@isTest
public class ContractTemplate_Test {
    
    
    @isTest
    public static void testGetContract(){
        List<Lease_Contract__c> contractList = TestDataFactory.createContract(1);
        ContractTemplate ct = new ContractTemplate();
        ct.Amount =1000;
        ct.Unitcode ='test';
        ct.getContracts();
    }

}