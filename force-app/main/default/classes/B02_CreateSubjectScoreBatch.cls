public without sharing class B02_CreateSubjectScoreBatch implements Database.Batchable<sObject>, Database.Stateful {
    @TestVisible
    private static Boolean isThrownExceptionAtStart = false;

    @TestVisible
    private static Boolean isThrownExceptionAtFinish = false;

    @TestVisible
    private static Boolean isNumberOfErrors = false;

    private BatchLog__c batchLog;

    private static final List<String> EXAM_TYPES = 
        new List<String>{'Progress', 'Practical', 'Midterm Exam', 'FinalTerm Exam'};

    private static final Integer SEMESTERS_PER_STUDENT = 3;

    private static final Integer SUBJECTS_PER_SEMESTER = 5;

    private static final String SUCCESS_RESULT = 'Success';

    private static final String ERROR_RESULT = 'Error';

    // prepare the data for excecute() method by using Database.getQueryLocator
    public Database.QueryLocator start(Database.BatchableContext context) {
        try {
            // create new BatchLog record
            this.batchLog = new BatchLog__c(
                  Name = 'B02_科目得点作成バッチ'
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
        List<Semester__c> semesters = [
            SELECT Id 
            FROM Semester__c
        ];
        List<Subject__c> subjects = [
            SELECT Id 
            FROM Subject__c
        ];
        List<SubjectScore__c> subjectScores = new List<SubjectScore__c>();
    
        for (Student__c student : students) {
            // getRandomIds logic for semesters
            Set<Id> semesterIds = new Set<Id>();
            while (semesterIds.size() < SEMESTERS_PER_STUDENT) {
                Integer randomNumber = Integer.valueOf(Math.random() * semesters.size());
                Id randomId = semesters[randomNumber].Id;
                semesterIds.add(randomId);
            }

            // createSubjectScoresForStudent logic
            for (Id semesterId : semesterIds) {
                // getRandomIds logic for subjects
                Set<Id> randomSubjectIds = new Set<Id>();
                while (randomSubjectIds.size() < SUBJECTS_PER_SEMESTER) {
                    Integer randomNumber = Integer.valueOf(Math.random() * subjects.size());
                    Id randomId = subjects[randomNumber].Id;
                    randomSubjectIds.add(randomId);
                }
                
                for (Id subjectId : randomSubjectIds) {
                    subjectScores.add(new SubjectScore__c(
                        Student_look__c = student.Id,
                        Semester_look__c = semesterId,
                        Subject_look__c = subjectId
                    ));
                }
            }
        }
    
        if (!subjectScores.isEmpty()) {
            insert subjectScores;
            
            // createScoresForSubjectScores logic
            List<Score__c> scores = new List<Score__c>();
            for (SubjectScore__c subjectScore : subjectScores) {
                for (String examType : EXAM_TYPES) {
                    scores.add(new Score__c(
                        SubjectScore_look__c = subjectScore.Id,
                        ExamType__c = examType,
                        Score__c = Math.round((Math.random() * 9 + 1) * 4) / 4.0
                    ));
                }
            }
            
            if (!scores.isEmpty()) {
                insert scores;
            }
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
                // trigger the B03_StudentScoreUpdateBatch
                B03_UpdateStudentScoreBatch batch03 = new B03_UpdateStudentScoreBatch();
                Integer batchSize03 = Integer.valueOf(StudentMeanageSetting__c.getOrgDefaults().get('B03_BatchSize__c'));
                batchSize03 = batchSize03 > 0 ? batchSize03 : 200;
                Database.executeBatch(batch03, batchSize03);
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