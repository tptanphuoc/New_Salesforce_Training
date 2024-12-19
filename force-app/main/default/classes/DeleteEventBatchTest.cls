// A Test Class for testing DeleteEventBatch class, need to be 90% code coverage
@isTest
public class DeleteEventBatchTest {
    // A method to prepare sample data for testing
    @TestSetup
    public static void setupData(){
        Event_Organizer__c org = new Event_Organizer__c(
            Name = 'Organizer Test',
            Phone__c = '0123456789',
            Email__c = 'huynhphuoc2468@gmail.com',
            Alternative_Phone__c = '0123456789',
            Alternative_Email__c = 'huynhphuoc2468@gmail.com'
        );
        insert org;
        
        Event__c event = new Event__c(
            Name__c = 'Event Test',
            Event_Organizer__c = org.Id, // take the Id of above org(Event_Organizer__c)
            Event_Type__c = 'Virtual',
            Frequency__c = 'Weekly',
            Max_Seats__c = 123,
            Recurring__c = true,
            Live__c = true,
            Start_DateTime__c = System.now().addMonths(-4),
            End_Date_Time__c = System.now().addDays(3).addMonths(-4)
        );
        insert event;
    }

    @isTest
    static void deleteEventTest() {
        Test.startTest();
            // Execute the Batch
            String batchJobId = Database.executeBatch(new DeleteEventBatch(), 250);
        Test.stopTest();
    }
}