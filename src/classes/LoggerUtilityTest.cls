@isTest
public class LoggerUtilityTest {
    static TestMethod void testLogs(){
        LoggerUtility.logException( null, 'test input', 'test output' );
    }
    
    static TestMethod void testLogs1(){
        try{
            LoggerUtility.logError( 'test1', 'test2' );
            LoggerUtility.logError( 'test1', 'test2', 'test3', 'test4' );
            Account acc = [ SELECT ID FROM Account ];
            acc.Name = 'test';
            update acc;
        }catch( Exception e ){
            LoggerUtility.logException( e, 'test input', 'test output' );
            LoggerUtility.logException(e);
        }   
    }
}