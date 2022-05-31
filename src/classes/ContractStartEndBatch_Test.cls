/**
* @author Rahul Shukla
* Class Name: ContractStartEndBatch_Test
* class Description: test class for Contract Stages
* Method Name: testContractStartEndBatchInsertEvent
* @param: Listcontr - List of Lead record to insert
*/
@isTest
public class ContractStartEndBatch_Test {
    
    @testsetup
    public static void testContractStartEndBatchInsertEvent(){
     List<Lease_Contract__c> Listcontr = new List<Lease_Contract__c>();
      
            Lease_Contract__c contr = new Lease_Contract__c();
            contr.Contract_Number__c = '0000';
            contr.Contract_Stages__c='Expired';
            contr.Contract_Start__c= system.today() - 20;
        	
            Listcontr.add(contr);
        if(!Listcontr.isEmpty()){
            insert Listcontr;
        }
    }
    /**
* Class Name: ContractStartEndBatch_Test
* class Description: test class for Contract Stages
* Method Name: testExecuteContract
* @param: executeBatch - Test the Execute Method of Batch
*/
    @isTest
    public static void testExecuteContract(){
           
        test.startTest();
        ContractStartEndBatch Cb =new ContractStartEndBatch();
        Database.executeBatch(Cb,1);
        test.stopTest();
    }
}