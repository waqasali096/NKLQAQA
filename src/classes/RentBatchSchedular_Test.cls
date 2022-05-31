@isTest 
public class RentBatchSchedular_Test {
    
    
    static testMethod void testBatchUpdateRentStructure() 
    {
        Test.startTest();
        RentBatchSchedular sh1 = new RentBatchSchedular();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
    }
}