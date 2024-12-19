@isTest
private class VF_DetailStudentCtrlTest {

    @isTest
    private static void testConstructor_StudentFound() {
        // Create a student record
        Student__c student = createStudent();
        String pageRef = Page.VF_DetailStudent.getUrl() + '?id=' + student.Id;
        Test.setCurrentPageReference(new PageReference(pageRef));

        Test.startTest();
            VF_DetailStudentCtrl controller = new VF_DetailStudentCtrl();
        Test.stopTest();

        // Assert that the student details were loaded
        Assert.areEqual(student.Firstname__c, controller.studentDetails.Firstname__c);
    }

    @isTest
    private static void testConstructor_StudentNotFound() {
        String studentId = null;
        String pageRef = Page.VF_DetailStudent.getUrl() + '?id=' + studentId;
        Test.setCurrentPageReference(new PageReference(pageRef));

        Test.startTest();
            VF_DetailStudentCtrl controller = new VF_DetailStudentCtrl();
        Test.stopTest();

        // Assert that the student details were not loaded
        Assert.isNull(controller.studentDetails.Id, 'The student details should not be loaded.');
    }

    @isTest
    private static void testGetStudentDetails_ExceptionHandling() {
        // Verify that the controller handles the missing ID gracefully
        Student__c student = createStudent();
        VF_DetailStudentCtrl.isThrownException = true;

        Test.startTest();
            VF_DetailStudentCtrl controller = new VF_DetailStudentCtrl();
        Test.stopTest();

        // Confirm that an exception was thrown
        Assert.isNull(controller.studentDetails, 'The student details should not be loaded.');
    }

    private static Student__c createStudent() {
        Class__c testClass = new Class__c();
        insert testClass;

        Student__c testStudent = new Student__c(
            Firstname__c = 'John'
            , Lastname__c = 'Doe'
            , Birthday__c = Date.today().addYears(-20)
            , Class_look__c = testClass.Id
            , Gender__c = 'Male'
            , LearningStatus__c = 'Enrolled'
        );
        insert testStudent;

        // Set the parameter for the test
        Test.setCurrentPageReference(new PageReference(Page.VF_DetailStudent.getUrl() + '?id=' + testStudent.Id));

        return testStudent;
    }
}