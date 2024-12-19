public without sharing class B01_DeleteSubjectScoreScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        B01_DeleteSubjectScoreBatch batch = new B01_DeleteSubjectScoreBatch();
        Integer batchSize01 = Integer.valueOf(StudentMeanageSetting__c.getOrgDefaults().get('B01_BatchSize__c'));
        batchSize01 = batchSize01 > 0 ? batchSize01 : 200;
        Database.executeBatch(batch, batchSize01);
    }
}