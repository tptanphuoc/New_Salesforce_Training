/**
* トリガー名 : T01_StudentTrigger
* トリガー概要 : This trigger execute logic (before/after insert, update, delete) on Student__c records by calling T01_StudentTriggerHandler class.
* @created : 2024/10/16 Huynh Phuoc
* @modified :
*/
trigger T01_StudentTrigger on Student__c (before insert
                                        , after insert
                                        , before update
                                        , after update
                                        , before delete
                                        , after delete) {

    T01_StudentTriggerHandler handler = new T01_StudentTriggerHandler();

    // get custom settings
    StudentMeanageSetting__c settings = StudentMeanageSetting__c.getOrgDefaults();
    // if custom settings is exist and InActive_flg__c is true => stop trigger
    if (settings.T01_InActive_flg__c) {
        return;
    }

    // Check BEFORE trigger
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.handleBeforeUpdate(Trigger.new);
        } else if (Trigger.isDelete) {
            handler.handleBeforeDelete(Trigger.old);
        }
    }
    // Check AFTER trigger
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.handleAfterUpdate(Trigger.new, Trigger.old);
        } else if (Trigger.isDelete) {
            handler.handleAfterDelete(Trigger.old);
        }
    }
}