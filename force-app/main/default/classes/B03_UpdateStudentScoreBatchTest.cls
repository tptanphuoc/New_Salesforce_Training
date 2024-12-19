@IsTest
private class B03_UpdateStudentScoreBatchTest {

    @IsTest
    private static void testSuccessScenario() {
        // Prepare data
        Class__c testClass = createTestClass();
        insert testClass;
        List<Student__c> students = createTestStudents(testClass.Id, 3);
        insert students;
        List<Subject__c> subjects = createTestSubjects();
        insert subjects;
        List<Semester__c> semesters = createTestSemesters();
        insert semesters;
        List<SubjectScore__c> subjectsScores = createTestSubjectScores(students, subjects, semesters);
        insert subjectsScores;

        // Start the test
        Test.startTest();
            B03_UpdateStudentScoreBatch batch = new B03_UpdateStudentScoreBatch();
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
            B03_UpdateStudentScoreBatch batch = new B03_UpdateStudentScoreBatch();
            B03_UpdateStudentScoreBatch.isThrownExceptionAtStart = true;
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
            B03_UpdateStudentScoreBatch batch = new B03_UpdateStudentScoreBatch();
            B03_UpdateStudentScoreBatch.isThrownExceptionAtFinish = true;
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
            B03_UpdateStudentScoreBatch batch = new B03_UpdateStudentScoreBatch();
            B03_UpdateStudentScoreBatch.isNumberOfErrors = true;
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
            WHERE Name = 'B03_学生得点更新バッチ'
            LIMIT 1
        ];
    }

    // Helper method to create Class__c
    private static Class__c createTestClass() {
        Class__c testClass = new Class__c();
        
        return testClass;
    }

    // Helper method to create Students
    private static List<Student__c> createTestStudents(Id classId, Integer count) {
        List<Student__c> students = new List<Student__c>();
        for (Integer i = 0; i < count; i++) {
            students.add(new Student__c(
                  FirstName__c = 'Test'
                  , LastName__c = 'Student ' + i
                  , Birthday__c = Date.newInstance(2000, 10, 20)
                  , LearningStatus__c = 'Enrolled'
                  , Gender__c = 'Male'
                  , Class_look__c = classId
            ));
        }
        
        return students;
    }

    // Helper method to create Subjects
    private static List<Subject__c> createTestSubjects() {
        List<Subject__c> subjects = new List<Subject__c>();
        subjects.add(createSubjectTemplate('Math', 3));
        subjects.add(createSubjectTemplate('Science', 4));
        subjects.add(createSubjectTemplate('English', 2));

        return subjects;
    }

    // Helper method to create Semesters
    private static List<Semester__c> createTestSemesters() {
        List<Semester__c> semesters = new List<Semester__c>();
        semesters.add(createSemesterTemplate('Semester 1'));
        semesters.add(createSemesterTemplate('Semester 2'));
        
        return semesters;
    }

    // Helper method to create Subject Scores
    private static List<SubjectScore__c> createTestSubjectScores(List<Student__c> students, List<Subject__c> subjects, List<Semester__c> semesters) {
        List<SubjectScore__c> subjectScores = new List<SubjectScore__c>();

        subjectScores.add(createSubjectScoreTemplate(students[0].Id, subjects[0].Id, semesters[0].Id, 4));
        subjectScores.add(createSubjectScoreTemplate(students[0].Id, subjects[1].Id, semesters[0].Id, 9));
        subjectScores.add(createSubjectScoreTemplate(students[1].Id, subjects[0].Id, semesters[0].Id, 6));
        subjectScores.add(createSubjectScoreTemplate(students[1].Id, subjects[0].Id, semesters[1].Id, 7));
        
        return subjectScores;
    }

    private static SubjectScore__c createSubjectScoreTemplate(Id studentId, Id subjectId, Id semesterId, Decimal averageScore) {
        return new SubjectScore__c(
            Student_look__c = studentId
            , Subject_look__c = subjectId
            , Semester_look__c = semesterId
            , AverageScore__c = averageScore
        );
    }

    private static Semester__c createSemesterTemplate(String name) {
        return new Semester__c(Name = name);
    }

    private static Subject__c createSubjectTemplate(String name, Integer courseCredit) {
        return new Subject__c(
            Name = name
            , CourseCredit__c = courseCredit
        );
    }
}