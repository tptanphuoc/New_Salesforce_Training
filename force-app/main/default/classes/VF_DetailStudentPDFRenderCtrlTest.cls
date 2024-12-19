@isTest
private class VF_DetailStudentPDFRenderCtrlTest {
    
    @isTest
    private static void testSuccessScenario() {
        // Prepare test data
        Class__c aClass = createTestClass();
        insert aClass;
        Student__c student = createTestStudent(aClass.Id);
        insert student;
        Semester__c semester = createTestSemester();
        insert semester;
        Subject__c subject = createTestSubject();
        insert subject;
        SubjectScore__c subjectScore = createTestSubjectScore(student.Id, semester.Id, subject.Id);
        insert subjectScore;
        List<Score__c> scores = createTestScoreList(subjectScore.Id);
        insert scores;

        // Start the test
        Test.startTest();
            PageReference pageRef = Page.VF_DetailStudentPDFRender;
            pageRef.getParameters().put('studentId', student.Id);
            pageRef.getParameters().put('semesterId', semester.Id);
            Test.setCurrentPage(pageRef);
            VF_DetailStudentPDFRenderCtrl ctrl = new VF_DetailStudentPDFRenderCtrl();
        Test.stopTest();

        // Verify the result
        Assert.isNotNull(ctrl.semesterSubjectScores);
    }

    @isTest
    private static void testExceptionScenario() {
        // Prepare test data
        Boolean isException = false;

        // Start the test
        Test.startTest();
            try {
                PageReference pageRef = Page.VF_DetailStudentPDFRender;
                Test.setCurrentPage(pageRef);
                VF_DetailStudentPDFRenderCtrl ctrl = new VF_DetailStudentPDFRenderCtrl();
            } catch (Exception ex) {
                isException = true;
            }
        Test.stopTest();

        // Verify the result
        Assert.isTrue(isException);
    }
    
    @isTest
    private static void testInsertWhiteSpace() {
        // Prepare test data
        Class__c aClass = createTestClass();
        insert aClass;
        Student__c student = createTestStudent(aClass.Id);
        student.FirstName__c = 'TheStudentFirstNameWithVeryLongNameThatExceedsTheMaxLengthOfTheField';
        insert student;

        // Start the test
        Test.startTest();
            PageReference pageRef = Page.VF_DetailStudentPDFRender;
            pageRef.getParameters().put('studentId', student.Id);
            Test.setCurrentPage(pageRef);
            VF_DetailStudentPDFRenderCtrl ctrl = new VF_DetailStudentPDFRenderCtrl();
        Test.stopTest();

        // Verify the result
        Assert.areNotEqual(student.FirstName__c, ctrl.student.FirstName__c);
    }


    private static Class__c createTestClass() {
        return new Class__c();
    }
    
    private static Student__c createTestStudent(String classId) {
        return new Student__c(
            FirstName__c = 'Test'
            , LastName__c = 'Student'
            , Birthday__c = Date.newInstance(2000, 10, 20)
            , LearningStatus__c = 'Enrolled'
            , Gender__c = 'Male'
            , Class_look__c = classId);
    }
    
    private static Semester__c createTestSemester() {
        return new Semester__c(Name = 'Test Semester');
    }

    private static Subject__c createTestSubject() {
        return new Subject__c(Name = ' ', CourseCredit__c = 3);
    }

    private static SubjectScore__c createTestSubjectScore(String studentId, String semesterId, String subjectId) {
        return new SubjectScore__c(
            Name = 'Test Subject Score'
            , Student_look__c = studentId
            , Semester_look__c = semesterId
            , Subject_look__c = subjectId
        );
    }

    private static List<Score__c> createTestScoreList(String subjectScoreId) {
        List<Score__c> scores = new List<Score__c>();
        scores.add(createTestScore('Test Score 1', subjectScoreId, 8, 'Progress'));
        scores.add(createTestScore('Test Score 2', subjectScoreId, 9, 'Practical'));
        scores.add(createTestScore('Test Score 3', subjectScoreId, 5, 'Midterm Exam'));
        scores.add(createTestScore('Test Score 4', subjectScoreId, 6, 'FinalTerm Exam'));

        return scores;
    }

    private static Score__c createTestScore(String scoreName, String subjectScoreId, Integer score, String examType) {
        return new Score__c(
            Name = scoreName
            , SubjectScore_look__c = subjectScoreId
            , Score__c = score
            , ExamType__c = examType
        );
    }
}