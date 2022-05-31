/*
*Author- Huzefa - CW
*Date - 13 Oct 2019
*Description - Generic utility to capture exception and log them in Log object
*/

public class DebugUtility{
    
    
    public static void logError(Exception e){
      Log__c error = new Log__c();
      error.info__c = e.getStackTraceString();
      error.Type__c = e.getTypeName();
      error.Message__c = e.getMessage();
      error.line__c = String.ValueOf(e.getLineNumber());
      insert error;
    }

}