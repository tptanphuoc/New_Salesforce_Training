trigger EventAttendeeTrigger on Event_Attendee__c (before insert, after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        EventAttendeeTriggerHandler.sendConfirmationEmail(Trigger.new);
    }
    // before insert to prevent duplicates on Event Attendee
    if (Trigger.isBefore && Trigger.isInsert) {
        EventAttendeeTriggerHandler.checkForDuplicates(Trigger.new);
    }
}