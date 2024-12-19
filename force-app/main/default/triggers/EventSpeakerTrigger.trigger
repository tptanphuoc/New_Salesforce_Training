// The trigger to check if Speaker is already booked for an Event at the same StartDate
trigger EventSpeakerTrigger on EventSpeakers__c (before insert, before update) {

    // Step1: Get the SpeakerId & EventId
    Set<Id> speakerIdsSet = new Set<Id>();
    Set<Id> eventIdsSet = new Set<Id>();

    for (EventSpeakers__c es : Trigger.New) {
        speakerIdsSet.add(es.Speaker__c);
        eventIdsSet.add(es.Event__c);
    }

    // Step2: SOQL on Event to get the StartDate and put them into a map
    Map<Id, Datetime> requestedEvents = new Map<Id, Datetime>();

    List<Event__c> relatedEventList = [SELECT Id, Start_DateTime__c FROM Event__c
                                       WHERE Id IN : eventIdsSet];

    for (Event__c evt : relatedEventList) {
        requestedEvents.put(evt.Id, evt.Start_DateTime__c);
    }

    // Step3: SOQL on Event-Speaker to get the related Speaker along with the Event StartDate
    List<EventSpeakers__c> relatedEventSpeakerList = [SELECT Id, Event__c, Speaker__c, Event__r.Start_DateTime__c
                                                      FROM EventSpeakers__c
                                                      WHERE Speaker__c IN : speakerIdsSet];

    // Step4: Check the condition and show error
    for (EventSpeakers__c es : Trigger.New) {
        // Get the DateTime for that Event which is associated with this new EventSpeaker record
        Datetime bookingTime = requestedEvents.get(es.Event__c);
        // Loop to check if Speaker__c and Start_DateTime__c of two list is equal
        for (EventSpeakers__c es1 : relatedEventSpeakerList) {
            if (es1.Speaker__c == es.Speaker__c && es1.Event__r.Start_DateTime__c == bookingTime) {
                // If equal then show the error
                es.Speaker__c.addError('The current Speaker is already booked for another Event');
            }
        }
    }
}