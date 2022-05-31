@isTest 
public class BatchUpdateRentStructure_Test 
{
     /**
    * Method Name: testBatchUpdateRentStructure
    * Method Description: Using TestDataFactory class insert a RentEvent
    * @param: Rent - List of Rent records that was inserted with the help of TestDataFactory Classs
    * @return: Void  
    * @author Kshitij Tiwari                                         
    */
    static testMethod void testBatchUpdateRentStructure() 
    {
        List<Rent__c> RentEventList = TestDataFactory.createRentRecord();
      
        Test.startTest();
 		
           Id batchJobId = Database.executeBatch(new BatchUpdateRentStructure(), 200);
            
        Test.stopTest();
    }
}