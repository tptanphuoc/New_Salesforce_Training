// A batch class that will delete any Event which is Organized and if that Event be held for 2 months
global class DeleteEventBatch implements Database.Batchable<SObject>{
    
    // Method used for preparing data by doing the Query
    global Database.QueryLocator start(Database.BatchableContext batchContext) {
        String query = 'SELECT Id, Name FROM Event__c WHERE Live__c = true AND End_Date_Time__c < LAST_N_MONTHS:2';
        return Database.getQueryLocator(query);
    }

    // Catch the datas return from start() method in eventList parameter and perform the logic
    global void execute(Database.BatchableContext batchContext, List<Event__c> eventList) {
        // Check the data return from start() method is not empty
        if (!eventList.isEmpty()) {
            // Delete the eventList
            List<Database.DeleteResult> deleteResult = Database.delete(eventList); 
            // Loop the result of the deletion
            for (Database.DeleteResult dr : deleteResult) { 
                // If the deletion is fail
                if (!dr.isSuccess()) { 
                    List<Database.Error> errors = dr.getErrors(); 
                    String errorString = String.join(errors, ',');
                    TransactionLogHandler.doHandleExceptionWithError(errorString, 'DeleteEventBatch');
                }
            }
        }
    }

    // Finish the batch job, send the notification email 
    global void finish(Database.BatchableContext batchContext) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> emailsTo = new List<String>();
        emailsTo.add('huynhphuoc2468@gmail.com');

        mail.setSubject('The DeleteEventBatch Batch Job');
        mail.setToAddresses(emailsTo);
        mail.setSenderDisplayName('Huynh Phuoc');
        mail.setHtmlBody('The DeleteEventBatch Batch Job Processing has been completed!');
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage> {mail};
        Messaging.sendEmail(emails);
    }
    
}