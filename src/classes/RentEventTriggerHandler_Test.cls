@isTest
public class RentEventTriggerHandler_Test {
    /**
    * Method Name: testRentEventUnitTriggerHandlerInsertEvent
    * Method Description: Using TestDataFactory class insert a RentEvent
    * @param: Rent - List of Rent records that was inserted with the help of TestDataFactory Classs
       * @return: Void                                           
    */
     @isTest
    public static void testRentEventUnitTriggerHandlerInsertEvent(){
        
        List<Rent__c> RentEventList = TestDataFactory.createRentRecord();
        system.debug('RentEventList' +RentEventList);
       
        RentEventTriggerHandler RentEventUnith=new RentEventTriggerHandler(RentEventList,null,null,null,null,null);
        RentEventUnith.AfterUpdateEvent();
        RentEventUnith.BeforeInsertEvent();
        RentEventTriggerHandler.InsertNewRentValues(RentEventList);
        RentEventTriggerHandler.updateOldRentStatus(RentEventList, null);
       
    }
  
}