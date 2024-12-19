@IsTest
private class LWC_DetailStudentCtrlTest {

    @IsTest
    private static void testGetStudentDetails_Success() {
        // Prepare the data
        setupTestData();
        List<Student__c> students = [
            SELECT Id 
            FROM Student__c
        ];
        Student__c student = students.size() > 0 ? students[0] : null;
        
        // Start the test
        Test.startTest();
            Student__c result = LWC_DetailStudentCtrl.getStudentDetails(student.Id);
        Test.stopTest();

        // Verify the results
        Assert.areNotEqual(null, result, 'The student record should not be null.');
        Assert.areEqual(student.Id, result.Id, 'The student ID should match the expected value.');
    }

    @IsTest
    private static void testGetStudentDetails_Exception() {
        // Prepare the data
        Boolean isException = false;

        // Start the test
        Test.startTest();
            try {
                LWC_DetailStudentCtrl.isThrownException = true;
                LWC_DetailStudentCtrl.getStudentDetails(null);
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @IsTest
    private static void testGetSemesterOptions() {
        // Prepare the data
        setupTestData();

        // Start the test
        Test.startTest();
            List<CustomSelectOption> result = LWC_DetailStudentCtrl.getSemesterOptions();
        Test.stopTest();

        // Verify the results
        Assert.areNotEqual(null, result, 'The result should not be null.');
        Assert.isFalse(result.isEmpty(), 'The result should contain at least one record.');
    }

    @IsTest
    private static void testGetSubjectScoreForStudent_Success() {
        // Prepare the data
        setupTestData();
        List<Student__c> students = [
            SELECT Id 
            FROM Student__c
        ];
        Student__c student = students.size() > 0 ? students[0] : null;
        List<Semester__c> semesters = [
            SELECT Id 
            FROM Semester__c
        ];
        Semester__c semester = semesters.size() > 0 ? semesters[0] : null;

        // Get the student and semester records
        Test.startTest();
            List<LWC_DetailStudentCtrl.SubjectScoreWrapper> result = 
                LWC_DetailStudentCtrl.getSubjectScoreForStudent(student.Id, semester.Id);
        Test.stopTest();

        // Verify the results
        Assert.areNotEqual(null, result, 'The result should not be null.');
        Assert.isFalse(result.isEmpty(), 'The result should contain at least one record.');
    }

    @IsTest
    private static void testGetSubjectScoreForStudent_Exception() {
        // Prepare the data
        Boolean isException = false;

        // Start the test
        Test.startTest();
            try {
                LWC_DetailStudentCtrl.isThrownException = true;
                LWC_DetailStudentCtrl.getSubjectScoreForStudent(null, null);
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @IsTest
    private static void testGenerateScoreTablePDF() {
        // Start the test
        Test.startTest();
            String url = LWC_DetailStudentCtrl.generateScoreTablePDF();
        Test.stopTest();

        // Verify the results
        Assert.areEqual(Page.VF_DetailStudentPDFRender.getUrl(), url);
    }

    @IsTest
    private static void testGenerateScoreTablePDF_Exception() {
        // Prepare the data
        Boolean isException = false;

        // Start the test
        Test.startTest();
            try {
                LWC_DetailStudentCtrl.isThrownException = true;
                LWC_DetailStudentCtrl.generateScoreTablePDF();
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    // setup all test data
    private static void setupTestData() {
        Class__c classRecord = createTestClass();
        insert classRecord;
        Semester__c semester = createTestSemester();
        insert semester;
        Student__c student = createTestStudent(classRecord.Id);
        insert student;
        List<SubjectScore__c> subjectScores = createTestSubjectScores(student.Id, semester.Id);
        insert subjectScores;
        List<Score__c> scores = createTestScores(subjectScores);
        insert scores;
    }
    
    // create a Class__c
    private static Class__c createTestClass() {
        return new Class__c();
    }
    
    // create Semester__c
    private static Semester__c createTestSemester() {
        return new Semester__c(
            Name = 'Test Semester'
            , StartDate__c = Date.today().addMonths(-3)
            , EndDate__c = Date.today().addMonths(3)
        );
        
    }
    
    // create Student__c
    private static Student__c createTestStudent(Id classId) {
        return new Student__c(
            FirstName__c = 'Test'
            , LastName__c = 'Student'
            , Birthday__c = Date.today().addYears(-20)
            , GPAScore__c = 3.8
            , TotalCredit__c = 20
            , Class_look__c = classId
            , Gender__c = 'Male'
            , LearningStatus__c = 'Enrolled'
        );
    }
    
    // create SubjectScore__c
    private static List<SubjectScore__c> createTestSubjectScores(Id studentId, Id semesterId) {
        List<SubjectScore__c> subjectScores = new List<SubjectScore__c>();
        for (Integer i = 0; i < 3; i++) {
            subjectScores.add(new SubjectScore__c(
                Student_look__c = studentId
                , Semester_look__c = semesterId
                , AverageScore__c = 8
                , Status__c = 'Passed'
            ));
        }

        return subjectScores;
    }
    
    // create Score__c
    private static List<Score__c> createTestScores(List<SubjectScore__c> subjectScores) {
        List<Score__c> scores = new List<Score__c>();
        for (SubjectScore__c subjectScore : subjectScores) {
            scores.add(new Score__c(
                SubjectScore_look__c = subjectScore.Id
                , ExamType__c = 'Progress'
                , Score__c = 8
            ));
        }

        return scores;
    }
}