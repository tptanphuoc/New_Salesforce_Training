public without sharing class B03_UpdateStudentScoreBatch implements Database.Batchable<sObject>, Database.Stateful {
    @TestVisible
    private static Boolean isThrownExceptionAtStart = false;

    @TestVisible
    private static Boolean isThrownExceptionAtFinish = false;

    @TestVisible
    private static Boolean isNumberOfErrors = false;

    private BatchLog__c batchLog;

    private static final String SUCCESS_RESULT = 'Success';

    private static final String ERROR_RESULT = 'Error';

    // prepare the data for excecute() method by using Database.getQueryLocator
    public Database.QueryLocator start(Database.BatchableContext context) {
        try {
            // create new BatchLog record
            this.batchLog = new BatchLog__c(
                  Name = 'B03_学生得点更新バッチ'
                , StartTime__c = Datetime.now()
            );
            insert this.batchLog;

            if (Test.isRunningTest() && isThrownExceptionAtStart) {
                throw new CustomException('Test exception');
            }

            // query all Student__c have a Class and LearningStatus = 'Enrolled'
            return Database.getQueryLocator([
                SELECT Id 
                FROM Student__c 
                WHERE LearningStatus__c = 'Enrolled'
                AND Class_look__c != NULL
            ]);
        } catch (Exception ex) {
            updateBatchLog(ERROR_RESULT, 'start', ex);
            // stop batch if exception
            System.abortJob(context.getJobId());
            return null;
        }
    }

    // process the data from the start() method
    public void execute(Database.BatchableContext context, List<Student__c> students) {
        // check student with subject
        Set<String> studentSubjectSet = new Set<String>();
        Map<Id, Decimal> totalCreditsMap = new Map<Id, Decimal>();
        Map<Id, Decimal> weightedScoreSumMap = new Map<Id, Decimal>();

        // Get all student IDs
        Set<Id> studentIds = new Map<Id, Student__c>(students).keySet();
        for (Student__c student : students) {
            totalCreditsMap.put(student.Id, 0);
            weightedScoreSumMap.put(student.Id, 0);
        }
        
        // get all subject scores related to the students
        List<SubjectScore__c> allSubjectScores = [
            SELECT Id
                   , Student_look__c
                   , Subject_look__c
                   , Subject_look__r.CourseCredit__c
                   , AverageScore__c
            FROM SubjectScore__c
            WHERE Student_look__c IN :studentIds
            ORDER BY Student_look__c, Subject_look__c, AverageScore__c DESC
        ];

        // loop through all subject scores
        for (SubjectScore__c score : allSubjectScores) {
            Id studentId = score.Student_look__c;
            Id subjectId = score.Subject_look__c;

            // if the student not have the subject
            if (!studentSubjectSet.contains(studentId + '_' + subjectId)) {
                studentSubjectSet.add(studentId + '_' + subjectId);

                Decimal courseCredit = score.Subject_look__r.CourseCredit__c;
                Decimal averageScore = score.AverageScore__c;

                totalCreditsMap.put(studentId, totalCreditsMap.get(studentId) + courseCredit);
                weightedScoreSumMap.put(studentId, weightedScoreSumMap.get(studentId) + (averageScore * courseCredit));
            }
        }
        
        List<Student__c> studentsToUpdate = new List<Student__c>();

        for (Student__c student : students) {
            Decimal totalCredits = totalCreditsMap.get(student.Id);
            Decimal weightedScoreSum = weightedScoreSumMap.get(student.Id);
    
            Decimal gpa = (totalCredits > 0) ? (weightedScoreSum / totalCredits) : 0;
            student.GPAScore__c = gpa.setScale(1, RoundingMode.HALF_UP);
            student.TotalCredit__c = totalCredits;
            studentsToUpdate.add(student);
        }
    
        // update students with the GPA and total credits
        if (!studentsToUpdate.isEmpty()) {
            update studentsToUpdate;
        }
    }

    public void finish(Database.BatchableContext context) {
        try {
            if (Test.isRunningTest() && isThrownExceptionAtFinish) {
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