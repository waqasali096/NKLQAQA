public without sharing class LoggerUtility {

    /**
     * log error, exception or debug logs.
     * @param logType - (EXCEPTION, DEBUG, ERROR)
     * @param stackTrace - stack trace of error
     * @param e - Exception object
     * @param input - input details
     * @param output - output details
     * @param details - other additional details
     * @return - exception number
     */
    private static String log(String logType, String stackTrace, Exception e, String input, String output, String details) {
        Logger__c fslLog = new Logger__c();
        fslLog.Input__c = input;
        fslLog.Output__c = output;
        fslLog.Log_Type__c = logType;
        fslLog.Details__c = details;
        if (stackTrace != null && stackTrace != '') {
            fslLog.Class_Name__c = getClassName(stackTrace);
            fslLog.Method_Name__c = getMethod(stackTrace);
            fslLog.Line_Number__c = getLineNumber(stackTrace);
        }
        if (e != null) {
            fslLog.Class_Name__c = getClassName(e.getStackTraceString());
            fslLog.Method_Name__c = getMethod(e.getStackTraceString());
            fslLog.Line_Number__c = '' + e.getLineNumber();
            fslLog.Message__c = e.getMessage();
            if (e.getCause() != null) {
                fslLog.Details__c = fslLog.Details__c + '\n Cause = ' + e.getCause();
            }
        }
        system.debug( 'LoggerUtility => Logs >> ' );
        return getExceptionNumber(insertException(fslLog));
    }
    public static String log(String stackTrace, String details) {
        /*if (System.Label.DEBUGGING == 'ENABLE') {
            return log('DEBUG', stackTrace, null, '', '', details);
        }*/
        return null;
    }
    public static String logException(Exception e, String input, String output, String details) {
        return log('EXCEPTION', '', e, input, output, details);
    }
    public static String logException(Exception e, String input, String output) {
        if( input != null && input.length() > 32000 ){
            input = input.substring( 0, 32000 );
        }

        if( output != null && output.length() > 32000 ){
            output = output.substring( 0, 32000 );
        }
        
        return logException(e, input, output, '');
    }
    public static String logException(Exception e, String details) {
        return logException(e, '', '', details);
    }
    public static String logException(Exception e) {
        return logException(e, '', '', '');
    }

    public static String logError(String stackTrace, String input, String output, String details) {
        return log('ERROR', stackTrace, null, input, output, details);
    }

    public static String logError(String stackTrace, String details) {
        return logError(stackTrace, '', '', details);
    }

    /**
     * Get exception number to send in APIs for later debugging
     *
     * @param exceptionId
     *
     * @return
     */
    public static String getExceptionNumber(Id exceptionId) {
        if (exceptionId != null) {
            try {
                return [SELECT Id, Name from Logger__c WHERE Id = :exceptionId].Name;
            } catch (Exception e) {
                system.debug( 'Exception => getExceptionNumber '+e.getMessage() );
            }
        }
        return null;
    }
    /**
     * Insert exception record & return Id
     *
     * @param fslException
     *
     * @return
     */
    public static Id insertException(Logger__c fslException) {
        if (fslException != null) {
            try {
                insert fslException;
                return fslException.Id;
            } catch (Exception e) {
                system.debug( 'Exception => insertException >> '+e.getMessage() );
            }
        }
        return null;
    }

    /**
     * Get Class name from stack trace string
     *
     * @param stackTrace
     *
     * @return
     */
    public static String getClassName(String stackTrace) {
        if (stackTrace.startsWith('Class.'))
            stackTrace = stackTrace.substringAfter('Class.');
        return stackTrace.substringBefore(':').substringBeforeLast('.');
    }
    /**
     * Get method name from stack trace string
     *
     * @param stackTrace
     *
     * @return
     */
    public static String getMethod(String stackTrace) {
        return stackTrace.substringBefore(':').substringAfterLast('.');
    }

    /**
     * Get line number from stack trace string
     *
     * @param stackTrace
     *
     * @return
     */
    public static String getLineNumber(String stackTrace) {
        return stackTrace.substringAfter('line').substringBefore(',').trim();
    }
    
     /**
     * create loggig records for API
     *
     * @params class,method,apiMethod,Request,response,endpoint,messagecode
     *
     * @return Logger
     */
    public static Logger__c logAPI(String className, String methodName, String apiMethodName, String reqBody, String resBody, String endPoint, String message, Boolean doDML) {
        Logger__c log = new Logger__c();
        log.Class_Name__c = className;
        log.Method_Name__c = methodName;
        log.Details__c = apiMethodName;
        log.Input__c = reqBody;
        log.Output__c = resBody;
        log.Log_Type__c = endPoint;
        log.Message__c = message;
        if(doDML) {
            insert log;
        }
        return log;
    }
    
    /**
     * create loggig records for API Exception
     *
     * @params Type,Stacktrace class,Exception,apiMethod,input,output, description
     *
     * @return Logger
     */
    public static Logger__c logExceptionWithNoDML(String logType, String stackTrace, Exception e, String input, String output, String details) {
        Logger__c fslLog = new Logger__c();
        fslLog.Input__c = input;
        fslLog.Output__c = output;
        fslLog.Log_Type__c = logType;
        fslLog.Details__c = details;
        if (stackTrace != null && stackTrace != '') {
            fslLog.Class_Name__c = getClassName(stackTrace);
            fslLog.Method_Name__c = getMethod(stackTrace);
            fslLog.Line_Number__c = getLineNumber(stackTrace);
        }
        if (e != null) {
            fslLog.Class_Name__c = getClassName(e.getStackTraceString());
            fslLog.Method_Name__c = getMethod(e.getStackTraceString());
            fslLog.Line_Number__c = '' + e.getLineNumber();
            fslLog.Message__c = e.getMessage();
            if (e.getCause() != null) {
                fslLog.Details__c = fslLog.Details__c + '\n Cause = ' + e.getCause();
            }
        }
        
        return fslLog;
    }
}