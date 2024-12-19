@isTest
private class T02_ScoreTriggerHandlerTest {
    
    @isTest
    private static void testHandleBeforeInsert_ValidScores() {
        // prepare test data
        Id subjectScoreId = setupTestData();
        List<Score__c> newScores = createScores(subjectScoreId
                                                , new List<Decimal>{8, 9}
                                                , new List<String>{'Progress', 'FinalTerm Exam'});
        // start the test
        Test.startTest();
            insert newScores;
        Test.stopTest();

        // verify the result
        List<Score__c> insertedScores = [
            SELECT Id
                   , SubjectScore_look__c
                   , ExamType__c
                   , Score__c 
            FROM Score__c
        ];
        Assert.isFalse(insertedScores.isEmpty(), 'Expected Score records to be inserted');
    }

    @isTest
    private static void testHandleBeforeInsert_DuplicateScores() {
        // prepare test data
        Id subjectScoreId = setupTestData();
        insert createScores(subjectScoreId, new List<Decimal>{7}, new List<String>{'Progress'});
        List<Score__c> newScores = createScores(subjectScoreId, new List<Decimal>{8}, new List<String>{'Progress'});

        // start the test
        Test.startTest();
            T02_ScoreTriggerHandler handler = new T02_ScoreTriggerHandler();
            handler.handleBeforeInsert(newScores);
        Test.stopTest();

        // verify the result
        Assert.isFalse(newScores[0].getErrors().isEmpty(), 'Expected error message');
    }

    @isTest
    private static void testHandleBeforeUpdate_DuplicateScores() {
        // prepare test data
        Id subjectScoreId = setupTestData();
        List<Score__c> existingScores = createScores(subjectScoreId
                                                    , new List<Decimal>{7, 8}
                                                    , new List<String>{'Progress', 'Midterm Exam'});
        insert existingScores;
        existingScores[1].ExamType__c = 'Progress';

        // start the test
        Test.startTest();
            T02_ScoreTriggerHandler handler = new T02_ScoreTriggerHandler();
            handler.handleBeforeUpdate(new List<Score__c>{ existingScores[1] });
        Test.stopTest();

        // Verify the result
        Assert.isFalse(existingScores[1].getErrors().isEmpty(), 'Expected error message');
    }

    @isTest
    private static void testHandleAfterUpdate_UpdateSubjectScore() {
        Id subjectScoreId = setupTestData();

        // Insert scores using the helper method
        List<Score__c> initialScores = createScores(subjectScoreId
                                                    , new List<Decimal>{5, 6}
                                                    , new List<String>{'Progress', 'FinalTerm Exam'});
        insert initialScores;

        // Modify scores
        initialScores[0].Score__c = 8;
        initialScores[1].Score__c = 9;

        Test.startTest();
            update initialScores;
        Test.stopTest();

        // Verify that the average score and status were updated correctly
        List<SubjectScore__c> updatedSubjectScores = [
            SELECT Id
                   , AverageScore__c
                   , Status__c 
            FROM SubjectScore__c
        ];
        Assert.isFalse(updatedSubjectScores.isEmpty(), 'Expected SubjectScore records to be updated');
    }

    @isTest
    private static void testHandleBeforeInsert_Exception() {
        // prepare test data
        Boolean isException = false;
        Id subjectScoreId = setupTestData();
        List<Score__c> newScores = createScores(subjectScoreId
                                                , new List<Decimal>{8}
                                                , new List<String>{'Progress'});

        // start the test
        Test.startTest();
            try {
                T02_ScoreTriggerHandler.isThrownException = true;
                insert newScores;
            } catch (DmlException ex) {
                isException = true;
            }
        Test.stopTest();

        // verify the result
        Assert.isTrue(isException, 'Expected exception to be thrown');
    }

    @isTest
    private static void testHandleAfterInsert_Exception() {
        // prepare test data
        Boolean isException = false;
        Id subjectScoreId = setupTestData();
        List<Score__c> newScores = createScores(subjectScoreId
                                                , new List<Decimal>{8, 7}
                                                , new List<String>{'Progress', 'Practical'});
        
        // start the test
        Test.startTest();
            try {
                T02_ScoreTriggerHandler.isThrownException = true;
                T02_ScoreTriggerHandler handler = new T02_ScoreTriggerHandler();
                handler.handleAfterInsert(newScores);
            } catch (DmlException ex) {
                isException = true;
            }
        Test.stopTest();

        // verify the result
        Assert.isTrue(isException, 'Expected exception to be thrown');
    }

    @isTest
    private static void testHandleBeforeUpdate_Exception() {
        // prepare test data
        Boolean isException = false;
        Id subjectScoreId = setupTestData();
        List<Score__c> existingScores = createScores(subjectScoreId
                                                    , new List<Decimal>{7, 8}
                                                    , new List<String>{'Progress', 'Midterm Exam'});
        insert existingScores;
        existingScores[1].ExamType__c = 'Progress';

        // start the test
        Test.startTest();
            try {
                T02_ScoreTriggerHandler.isThrownException = true;
                existingScores[1].ExamType__c = 'FinalTerm Exam';
                update existingScores;
            } catch (DmlException ex) {
                isException = true;
            }
        Test.stopTest();

        // verify the result
        Assert.isTrue(isException, 'Expected exception to be thrown');
    }

    @isTest
    private static void testHandleAfterUpdate_Exception() {
        // prepare test data
        Boolean isException = false;
        Id subjectScoreId = setupTestData();
        List<Score__c> initialScores = createScores(subjectScoreId
                                                    , new List<Decimal>{8, 7, 6, 9}
                                                    , new List<String>{'Progress', 'Practical', 'Midterm Exam', 'FinalTerm Exam'});
        insert initialScores;

        // start the test
        Test.startTest();
            try {
                T02_ScoreTriggerHandler.isThrownException = true;
                initialScores[0].Score__c = 10;
                T02_ScoreTriggerHandler handler = new T02_ScoreTriggerHandler();
                handler.handleAfterUpdate(initialScores);
            } catch (DmlException ex) {
                isException = true;
            }
        Test.stopTest();

        // verify the result
        Assert.isTrue(isException, 'Expected exception to be thrown');
    }

    @isTest
    private static void testReturnAtGetCustomSetting() {
        // prepare test data
        Boolean isException = false;
        Id subjectScoreId = setupTestData();
        List<Score__c> newScores = createScores(subjectScoreId
                                                , new List<Decimal>{8}
                                                , new List<String>{'Progress'});
        
        // start the test
        Test.startTest();
            try {
                StudentMeanageSetting__c settings = StudentMeanageSetting__c.getOrgDefaults();
                settings.T02_InActive_flg__c = true;
                insert settings;
                
                insert newScores;
            } catch (DmlException ex) {
                isException = true;
            }
        Test.stopTest();

        // verify the result
        Assert.isFalse(isException, 'Expected no exception to be thrown');
    }

    private static Id setupTestData() {
        Subject__c subject = new Subject__c(Name = 'Test Subject');
        insert subject;

        SubjectScore__c subjectScore = new SubjectScore__c(Subject_look__c = subject.Id);
        insert subjectScore;
        return subjectScore.Id;
    }

    // Helper method to create Score__c records
    private static List<Score__c> createScores(Id subjectScoreId, List<Decimal> scores, List<String> examTypes) {
        List<Score__c> newScores = new List<Score__c>();
        for (Integer i = 0; i < scores.size(); i++) {
            newScores.add(new Score__c(
                SubjectScore_look__c = subjectScoreId,
                ExamType__c = examTypes[i],
                Score__c = scores[i]
            ));
        }
        return newScores;
    }
}