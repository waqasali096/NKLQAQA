@isTest
public class ContractStartEndSchedule_Test {

    @isTest
    public static void testContractSchedule(){
        ContractStartEndDateSchedule sh1 = new ContractStartEndDateSchedule();
        String sch = '0 0 2 * * ?'; 
		system.schedule('Test Schedule', sch, sh1); 

    }
}