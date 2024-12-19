// The trigger will call to external API to check the Location is valid or not
trigger LocationVerifyAPITrigger on Location__c (after insert) {
    // If Trigger action is After Insert
    if (Trigger.isAfter && Trigger.isInsert) {
        // Loop all the element in Trigger.new list
        for (Location__c loc : Trigger.new) {
            // Call the handler class to perform logic
            LocationVerifyAPITriggerHandler.verifyAddress(loc.Id);
        }
    }
}