/**
* @author : Muhammad Sajid
* @createdDate : 31-Jan-2022
* @lastModifieddate : 31-Jan-2022
* @usage : Test class to cover all functionality of StandSchedulerLeasing. 
*/

@isTest
public class StandSchedulerLeasingTest {

    static testMethod void TestStandSchedulerLeasing() {        
         test.starttest();
         StandSchedulerLeasing myClass = new StandSchedulerLeasing();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         test.stopTest();
    }
    
}