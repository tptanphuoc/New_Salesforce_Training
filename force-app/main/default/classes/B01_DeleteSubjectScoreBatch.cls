public without sharing class B01_DeleteSubjectScoreBatch implements Database.Batchable<sObject>, Database.Stateful {
    @TestVisible
    private static Boolean isThrownExceptionAtStart = false;

    @TestVisible
    private static Boolean isThrownExceptionAtFinish = false;

    @TestVisible
    private static Boolean isNumberOfErrors = false;

    private BatchLog__c batchLog;

    private static final String SUCCESS_RESULT = 'Success';

    private static final String ERROR_RESULT = 'Error';


    public Database.QueryLocator start(Database.BatchableContext context) {
        try {
            this.batchLog = new BatchLog__c(
                  Name = 'B01_科目得点削除バッチ'
                , StartTime__c = Datetime.now()
            );
            insert this.batchLog;

            if (isThrownExceptionAtStart && Test.isRunningTest()) {
                throw new CustomException('Test exception');
            }

            return Database.getQueryLocator([
                SELECT Id
                FROM SubjectScore__c
            ]);
        } catch (Exception ex) {
            updateBatchLog(ERROR_RESULT, 'start', ex);
            // stop batch if exception
            System.abortJob(context.getJobId());
            return null;
        }
    }

    public void execute(Database.BatchableContext context, List<SubjectScore__c> subjectScores) {
        delete subjectScores;
    }

    public void finish(Database.BatchableContext context) {
        try {
            if (isThrownExceptionAtFinish && Test.isRunningTest()) {
                throw new CustomException('Test exception');
            }

            AsyncApexJob job = new AsyncApexJob();
            List<AsyncApexJob> jobs = [
                SELECT Id
                       , NumberOfErrors
                FROM AsyncApexJob
                WHERE Id = :context.getJobId()
            ];

            if (!jobs.isEmpty()) {
                job = jobs[0];
            }
            
            // update batchLog base on the NumberOfErrors
            if (job.NumberOfErrors > 0 || (Test.isRunningTest() && isNumberOfErrors)) {
                updateBatchLog(ERROR_RESULT, 'finish', new CustomException('Number of errors: ' + job.NumberOfErrors));
            } else {
                updateBatchLog(SUCCESS_RESULT, 'finish', null);
                // trigger the B02_CreateSubjectScoreBatch
                B02_CreateSubjectScoreBatch batch02 = new B02_CreateSubjectScoreBatch();
                Integer batchsize02 = Integer.valueOf(StudentMeanageSetting__c.getOrgDefaults().get('B02_BatchSize__c'));
                batchsize02 = batchsize02 > 0 ? batchsize02 : 200;
                Database.executeBatch(batch02, batchsize02);
            }
        } catch (Exception ex) {
            updateBatchLog(ERROR_RESULT, 'finish', ex);
        }
    }

    private void updateBatchLog(String result, String methodName, Exception ex) {
        this.batchLog.EndTime__c = Datetime.now();
        this.batchLog.Result__c = result;
        if (result == ERROR_RESULT) {
            this.batchLog.ErrorMessage__c = 'Exception at ' + methodName + '(): ' + ex.getMessage();
        }
        update this.batchLog;
    }

    private class CustomException extends Exception {}
}