@isTest
private class B02_CreateSubjectScoreBatchTest {
    
    @IsTest
    private static void testSuccessScenario() {
        // Prepare test data
        List<Class__c> classes = createTestClasses(2);
        insert classes;
        List<Student__c> students = createTestStudents(5, classes);
        insert students;
        List<Semester__c> semesters = createTestSemesters(3);
        insert semesters;
        List<Subject__c> subjects = createTestSubjects(5);
        insert subjects;

        // Start the test
        Test.startTest();
            B02_CreateSubjectScoreBatch batch = new B02_CreateSubjectScoreBatch();
            Database.executeBatch(batch);
        Test.stopTest();

        // Verify the results
        List<BatchLog__c> logs = getBatchLogs();
        Assert.isFalse(logs.isEmpty(), 'Should not have created any batch logs');
        Assert.areEqual('Success', logs[0].Result__c, 'Batch should have succeeded');
    }
    
    @IsTest
    private static void testExceptionsAtStart() {
        // Start the test
        Test.startTest();
            B02_CreateSubjectScoreBatch batch = new B02_CreateSubjectScoreBatch();
            B02_CreateSubjectScoreBatch.isThrownExceptionAtStart = true;
            Database.executeBatch(batch);
        Test.stopTest();

        // Verify the results
        List<BatchLog__c> logs = getBatchLogs();
        Assert.isFalse(logs.isEmpty(), 'Should not have created any batch logs');
        Assert.areEqual('Error', logs[0].Result__c, 'Batch should have failed');
    }

    @IsTest
    private static void testExceptionsAtFinish() {
        // Start the test
        Test.startTest();
            B02_CreateSubjectScoreBatch batch = new B02_CreateSubjectScoreBatch();
            B02_CreateSubjectScoreBatch.isThrownExceptionAtFinish = true;
            Database.executeBatch(batch);
        Test.stopTest();

        // Verify the results
        List<BatchLog__c> logs = getBatchLogs();
        Assert.isFalse(logs.isEmpty(), 'Should not have created any batch logs');
        Assert.areEqual('Error', logs[0].Result__c, 'Batch should have failed');
    }

    @IsTest
    private static void testFinishWithErrors() {
        // Start the test
        Test.startTest();
            B02_CreateSubjectScoreBatch batch = new B02_CreateSubjectScoreBatch();
            B02_CreateSubjectScoreBatch.isNumberOfErrors = true;
            Database.executeBatch(batch);
        Test.stopTest();

        // Verify the results
        List<BatchLog__c> logs = getBatchLogs();
        Assert.isFalse(logs.isEmpty(), 'Should not have created any batch logs');
        Assert.areEqual('Error', logs[0].Result__c, 'Batch should have failed');
    }

    // Helper method to query batch logs
    private static List<BatchLog__c> getBatchLogs() {
        return [
            SELECT Id
                   , Result__c
            FROM BatchLog__c 
            WHERE Name = 'B02_科目得点作成バッチ'
            LIMIT 1
        ];
    }

    private static List<Class__c> createTestClasses(Integer count) {
        List<Class__c> classes = new List<Class__c>();
        for(Integer i = 0; i < count; i++) {
            classes.add(new Class__c());
        }
        
        return classes;
    }
    
    private static List<Student__c> createTestStudents(Integer count, List<Class__c> classes) {
        List<Student__c> students = new List<Student__c>();
        for(Integer i = 0; i < count; i++) {
            students.add(createStudentTemplate('Test'
                                                , 'Student ' + i
                                                , Date.newInstance(2000, 10, 20)
                                                , 'Enrolled'
                                                , 'Male'
                                                , classes[Math.mod(i, classes.size())].Id));
        }

        return students;
    }
    
    private static List<Semester__c> createTestSemesters(Integer count) {
        List<Semester__c> semesters = new List<Semester__c>();
        for(Integer i = 0; i < count; i++) {
            semesters.add(createSemesterTemplate('Test Semester ' + i));
        }

        return semesters;
    }
    
    private static List<Subject__c> createTestSubjects(Integer count) {
        List<Subject__c> subjects = new List<Subject__c>();
        for(Integer i = 0; i < count; i++) {
            subjects.add(createSubjectTemplate('Test Subject ' + i, 2));
        }

        return subjects;
    }

    private static Student__c createStudentTemplate(String firstName
                                                    , String lastName
                                                    , Date birthday
                                                    , String learning
                                                    , String gender
                                                    , Id classId) {
        return new Student__c(
            FirstName__c = firstName
            , LastName__c = lastName
            , Birthday__c = birthday
            , LearningStatus__c = learning
            , Gender__c = gender
            , Class_look__c = classId
        );
    }

    private static Semester__c createSemesterTemplate(String name) {
        return new Semester__c(
            Name = name
        );
    }

    private static Subject__c createSubjectTemplate(String name, Integer credit) {
        return new Subject__c(
            Name = name
            , CourseCredit__c = credit
        );
    }
}