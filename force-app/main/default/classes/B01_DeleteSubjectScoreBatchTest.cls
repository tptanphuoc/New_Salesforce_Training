@IsTest
private class B01_DeleteSubjectScoreBatchTest {

    @IsTest
    private static void testSuccessScenario() {
        // Prepare data
        List<SubjectScore__c> subjectScore = createSubjectScore();
        insert subjectScore;

        // Start the test
        Test.startTest();
            B01_DeleteSubjectScoreBatch batch = new B01_DeleteSubjectScoreBatch();
            Database.executeBatch(batch);
        Test.stopTest();

        // Verify results
        List<BatchLog__c> logs = getBatchLogs();
        Assert.isFalse(logs.isEmpty(), 'Should not have created any batch logs');
        Assert.areEqual('Success', logs[0].Result__c, 'Should have success result');
    }
    
    @IsTest
    private static void testFinishWithErrors() {
        // Start the test
        Test.startTest();
            B01_DeleteSubjectScoreBatch batch = new B01_DeleteSubjectScoreBatch();
            B01_DeleteSubjectScoreBatch.isNumberOfErrors = true;
            Database.executeBatch(batch);
        Test.stopTest();

        // Verify results
        List<BatchLog__c> logs = getBatchLogs();
        Assert.isFalse(logs.isEmpty(), 'Should not have created any batch logs');
        Assert.areEqual('Error', logs[0].Result__c, 'Should have error result');
    }

    @IsTest
    private static void testExceptionsStart() {
        // Start the test
        Test.startTest();
            B01_DeleteSubjectScoreBatch batch = new B01_DeleteSubjectScoreBatch();
            B01_DeleteSubjectScoreBatch.isThrownExceptionAtStart = true;
            Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify results
        List<BatchLog__c> logs = getBatchLogs();
        Assert.isFalse(logs.isEmpty(), 'Should not have created any batch logs');
        Assert.areEqual('Error', logs[0].Result__c, 'Should have error result');
    }

    @IsTest
    private static void testExceptionsFinish() {
        // Start the test
        Test.startTest();
            B01_DeleteSubjectScoreBatch batch = new B01_DeleteSubjectScoreBatch();
            B01_DeleteSubjectScoreBatch.isThrownExceptionAtFinish = true;
            Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify results
        List<BatchLog__c> logs = getBatchLogs();
        Assert.isFalse(logs.isEmpty(), 'Should not have created any batch logs');
        Assert.areEqual('Error', logs[0].Result__c, 'Should have error result');
    }

    @IsTest
    private static void testSchedulerSuccess() {
        // Prepare data
        String jobName = 'TestDeleteSubjectScoreJob';
        String cronExp = '0 0 0 * * ?';

        // Start the test
        Test.startTest();
        String jobId = System.schedule(jobName, cronExp, new B01_DeleteSubjectScoreScheduler());
        Test.stopTest();

        // Verify results
        List<CronTrigger> ct = [
            SELECT Id 
            FROM CronTrigger 
            WHERE Id = :jobId];
        Assert.isFalse(ct.isEmpty(), 'Should have created a cron trigger');
    }

    // Helper method to query batch logs
    private static List<BatchLog__c> getBatchLogs() {
        return [
            SELECT Id
                   , Result__c
            FROM BatchLog__c 
            WHERE Name = 'B01_科目得点削除バッチ'
            LIMIT 1
        ];
    }

    // Helper method to create subject scores
    private static List<SubjectScore__c> createSubjectScore() {
        // Prepare data
        List<SubjectScore__c> scores = new List<SubjectScore__c>();
        for(Integer i = 0; i < 20; i++) {
            scores.add(new SubjectScore__c(
                Name = 'Test' + i
            ));
        }

        return scores;
    }
}