/**
* @author : Muhammad Sajid
* @createdDate : 31-Jan-2022
* @lastModifieddate : 31-Jan-2022
* @usage : Test class to cover all functionality of StandScheduler. 
*/

@isTest
public class StandSchedulerTest {

    static testMethod void TestStandScheduler() {        
         test.starttest();
         StandScheduler myClass = new StandScheduler ();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         test.stopTest();
    }
}