/**
* トリガー名 : T02_ScoreTrigger
* トリガー概要 : This trigger calculate AVG score on Score__c records.
* @created : 2024/10/16 Huynh Phuoc
* @modified :
*/
trigger T02_ScoreTrigger on Score__c (before insert
                                    , after insert
                                    , before update
                                    , after update) {
    
    T02_ScoreTriggerHandler handler = new T02_ScoreTriggerHandler();

    // get custom settings
    StudentMeanageSetting__c settings = StudentMeanageSetting__c.getOrgDefaults();
    // if custom settings is exist and InActive_flg__c is true => stop trigger
    if (settings.T02_InActive_flg__c) {
        return;
    }

    // Check BEFORE trigger
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.handleBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.handleBeforeUpdate(Trigger.new);
        }
    } 
    // Check AFTER trigger
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.handleAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.handleAfterUpdate(Trigger.new);
        }
    }
}