public with sharing class TransactionLogHandler {
    // Custom object for storing any exception
    public static void doHandleException(System.Exception ex, String processName) {

        // Create new instance of Error_Log__c object to store error
        Error_Log__c errorLog = new Error_Log__c(
            Log_Details__c = ex.getStackTraceString() + '<br/> <strong> Message is: </strong> ' + ex.getMessage()
            + '<br/> ' + ex.getCause() + ' <br/> ' + ex.getTypeName() + ' <br/> ' + ex.getLineNumber(),
            Lod_DateTime__c	= System.now(),
            Process_Name__c = processName
        );
        
        // Insert to DB
        insert errorLog;
    }


    public static void doHandleExceptionWithError(String errorMessage, String processName) {

        // Create new instance of Error_Log__c object to store error
        Error_Log__c errorLog = new Error_Log__c(
            Log_Details__c = errorMessage,
            Lod_DateTime__c	= System.now(),
            Process_Name__c = processName
        );
        
        // Insert to DB
        insert errorLog;
    }
}