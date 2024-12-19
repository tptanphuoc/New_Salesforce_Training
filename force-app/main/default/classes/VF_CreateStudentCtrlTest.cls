@isTest
private class VF_CreateStudentCtrlTest {

    @isTest
    private static void testGetClassOptions() {
        // prepare test data
        CLass__c testClass = new Class__c();
        insert testClass;

        Test.startTest();
            VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
            List<SelectOption> classOptions = controller.getClassOptions();
        Test.stopTest();

        Assert.isFalse(classOptions.isEmpty());
        Assert.areEqual('--Select class--', classOptions[0].getLabel());
    }

    @isTest
    private static void testGetLearningStatusOptions() {
        // start test
        Test.startTest();
            VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
            List<SelectOption> learningStatusOptions = controller.getLearningStatusOptions();
        Test.stopTest();

        Assert.isFalse(learningStatusOptions.isEmpty());
        Assert.areEqual('--Select status--', learningStatusOptions[0].getLabel());
    }

    @isTest
    private static void testGetGenderOptions() {
        // start test
        Test.startTest();
            VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
            List<SelectOption> genderOptions = controller.getGenderOptions();
        Test.stopTest();

        Assert.isFalse(genderOptions.isEmpty());
    }

    @isTest
    private static void testCreateStudent_ValidateForm() {
        VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
        controller.student = createNewStudent(false);

        Test.startTest();
            PageReference result = controller.createStudent();
        Test.stopTest();

        Assert.isNull(result, 'Page reference should not be null if the student is created successfully.');
    }

    @isTest
    private static void testCreateStudent_Success() {
        VF_CreateStudentCtrl controller = setupController(
                                                        createNewStudent(false)
                                                        , 'Male'
                                                        , 'Enrolled'
    );

        Test.startTest();
            PageReference result = controller.createStudent();
        Test.stopTest();

        Assert.isNotNull(result, 'Page reference should not be null if the student is created successfully.');
    }

    @isTest
    private static void testCreateStudent_UnderageStudent() {
        VF_CreateStudentCtrl controller = setupController(
                                                        createNewStudent(true)
                                                        , 'Male'
                                                        , 'Enrolled'
    );

        Test.startTest();
            PageReference result = controller.createStudent();
        Test.stopTest();

        Assert.isNull(result, 'Page reference should be null if the student is underage.');
    }

    @isTest
    private static void testCreateStudent_ExceptionHandling() {
        // prepare test data
        Boolean isException = false;
        VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
        controller.student = createNewStudent(false);
        VF_CreateStudentCtrl.isThrownException = true;

        // start test
        Test.startTest();
            try {
                controller.createStudent();
            } catch (VisualforceException e) {
                isException = true;
            }
        Test.stopTest();

        // confirm the result
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    // test getClassOptions with exception
    @isTest
    private static void testGetClassOptions_Exception() {
        // prepare test data
        Boolean isException = false;
        VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
        VF_CreateStudentCtrl.isThrownException = true;
        
        // start test
        Test.startTest();
            try {
                controller.getClassOptions();
            } catch (VisualforceException e) {
                isException = true;
            }
        Test.stopTest();

        // confirm the result
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    // test getLearningStatusOptions with exception
    @isTest
    private static void testGetLearningStatusOptions_Exception() {
        // prepare test data
        Boolean isException = false;
        VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
        VF_CreateStudentCtrl.isThrownException = true;

        // start test
        Test.startTest();
            try {
                controller.getLearningStatusOptions();
            } catch (VisualforceException e) {
                isException = true;
            }
        Test.stopTest();

        // confirm the result
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    // test getGenderOptions with exception
    @isTest
    private static void testGetGenderOptions_Exception() {
        // prepare test data
        Boolean isException = false;
        VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
        VF_CreateStudentCtrl.isThrownException = true;

        // start test
        Test.startTest();
            try {
                controller.getGenderOptions();
            } catch (VisualforceException e) {
                isException = true;
            }
        Test.stopTest();

        // confirm the result
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    private static Student__c createNewStudent(Boolean isUnderage) {
        // Create Student__c records for testing
        Student__c newStudent = new Student__c();
        newStudent.FirstName__c = 'Test';
        newStudent.LastName__c = 'Student';
        newStudent.Birthday__c = isUnderage ? Date.today().addYears(-17) : Date.today().addYears(-20);

        return newStudent;
    }

    private static Class__c createNewClass() {
        // Create Class__c records for testing
        return new Class__c();

    }

    private static VF_CreateStudentCtrl setupController(
                                                        Student__c student
                                                        , String gender
                                                        , String status
    ) {
        VF_CreateStudentCtrl controller = new VF_CreateStudentCtrl();
        Class__c testClass = createNewClass();
        insert testClass;
        controller.student = student;
        controller.selectedClass = testClass.Id;
        controller.selectedGender = gender;
        controller.selectedStatus = status;
        
        return controller;
    }
}