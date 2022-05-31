@isTest
public class ClockController_Test{
    @isTest  
    
    public static void getEndTime_Test() 
    {  
        list<lead> ledList = new list<Lead>();
        ledList= TestDataFactory.createLead(1);
        system.Test.startTest();
        clockController.getEndTime(ledList[0].id);
        clockController.getResponseTime(ledList[0].id);
        system.Test.stopTest();
        }



}