public with sharing class EventDetailsController {
    @AuraEnabled
    public static List<Event__c> getUpcomingEvents(){
        try {
            List<Event__c> eventList = [SELECT Id, Name, Name__c, Event_Detail__c, Location__c, Location__r.Name,
                                        Event_Organizer__c, Event_Organizer__r.Name 
                                        FROM Event__c
                                        WHERE Start_DateTime__c >= TODAY AND Live__c = true
                                        WITH SECURITY_ENFORCED];

            return eventList;
        } catch (Exception e) {
            TransactionLogHandler.doHandleException(e, 'EventDetailsController');
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<EventSpeakers__c> getSpeakers(String eventId){
        try {
            List<EventSpeakers__c> speakerList = [SELECT Id, Name, Speaker__c, 
            Speaker__r.Name, Speaker__r.Phone__c, Speaker__r.Email__c, Speaker__r.Company__c
            FROM EventSpeakers__c WHERE Event__c =: eventId WITH SECURITY_ENFORCED];
            return speakerList;
        } catch (Exception e) {
            TransactionLogHandler.doHandleException(e, 'EventDetailsController');
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Event__c getLocationDetails(String eventId){
        try {
            Event__c eventWithLocation = [SELECT Id, Name__c, Location__c, 
            Location__r.Name, Location__r.City__c, Location__r.Country__c, Location__r.Land_Mark__c, 
            Location__r.Postal_Code__c, Location__r.State__c, Location__r.Street__c 
            FROM Event__c WHERE Id =: eventId WITH SECURITY_ENFORCED];
            return eventWithLocation;
        } catch (Exception e) {
            TransactionLogHandler.doHandleException(e, 'EventDetailsController');
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Event_Attendee__c> getAttendees(String eventId){
        try {
            List<Event_Attendee__c> attendeeList = [SELECT Id, Name,
            Attendee__c, Attendee__r.Name, Attendee__r.Email__c, Attendee__r.Company_Name__c,
            Attendee__r.Location__c, Attendee__r.Location__r.Name 
            FROM Event_Attendee__c WHERE Event__c =: eventId WITH SECURITY_ENFORCED];
            System.debug('ATTENTDEELIST:  >>' + attendeeList);
            return attendeeList;
        } catch (Exception e) {
            TransactionLogHandler.doHandleException(e, 'EventDetailsController');
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Event_Attendee__c> getFutureEventsOfAttendee(String attendeeId){
        try {
            List<Event_Attendee__c> eventsOfAttendeeList = [SELECT Id, Name, Event__c,
                Event__r.Event_Organizer__c, Event__r.Event_Organizer__r.Name,
                Event__r.Name__c, Event__r.Start_DateTime__c, Event__r.Location__c, Event__r.Location__r.Name 
                FROM Event_Attendee__c
                WHERE Attendee__c =: attendeeId
                AND Event__r.Start_DateTime__c >= TODAY AND Event__r.Live__c = true
                WITH SECURITY_ENFORCED];
            return eventsOfAttendeeList;
        } catch (Exception e) {
            TransactionLogHandler.doHandleException(e, 'EventDetailsController');
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Event_Attendee__c> getPastEventsOfAttendee(String attendeeId){
        try {
            List<Event_Attendee__c> eventsOfAttendeeList = [SELECT Id, Name, Event__c,
                Event__r.Event_Organizer__c, Event__r.Event_Organizer__r.Name,
                Event__r.Name__c, Event__r.Start_DateTime__c, Event__r.Location__c, Event__r.Location__r.Name 
                FROM Event_Attendee__c
                WHERE Attendee__c =: attendeeId
                AND Event__r.Start_DateTime__c < TODAY
                WITH SECURITY_ENFORCED];
            return eventsOfAttendeeList;
        } catch (Exception e) {
            TransactionLogHandler.doHandleException(e, 'EventDetailsController');
            throw new AuraHandledException(e.getMessage());
        }
    }
}