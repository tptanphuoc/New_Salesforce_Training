@isTest
private class VF_UpdateStudentCtrlTest {

    @isTest
    private static void testGetStudentDetail() {
        setupTestData();
        VF_UpdateStudentCtrl ctrl = new VF_UpdateStudentCtrl();

        Test.startTest();
            PageReference result = ctrl.getStudentDetail();
        Test.stopTest();

        // Assert that student details were correctly loaded
        Assert.areEqual('John', ctrl.student.Firstname__c);
    }

    @isTest
    private static void testGetStudentDetail_EmptyId() {
        VF_UpdateStudentCtrl ctrl = new VF_UpdateStudentCtrl();
        Test.setCurrentPage(Page.VF_UpdateStudent);
        ApexPages.currentPage().getParameters().put('id', 'empty');
        
        Test.startTest();
            PageReference result = ctrl.getStudentDetail();
        Test.stopTest();

        // Assert that redirect occurred
        PageReference expected = Page.VF_SearchStudent;
        Assert.areEqual(expected.getUrl(), result.getUrl());
    }

    @isTest
    private static void testGetClassOptions() {
        VF_UpdateStudentCtrl ctrl = new VF_UpdateStudentCtrl();
        insert new Class__c();

        Test.startTest();
            List<SelectOption> classOptions = ctrl.getClassOptions();
        Test.stopTest();
        
        // Assert that class options are not empty
        Assert.isFalse(classOptions.isEmpty());
    }

    @isTest
    private static void testGetGenderOptions() {
        VF_UpdateStudentCtrl ctrl = new VF_UpdateStudentCtrl();
        
        Test.startTest();
            List<SelectOption> genderOptions = ctrl.getGenderOptions();
        Test.stopTest();
        
        // Assert that gender options are not empty
        Assert.isFalse(genderOptions.isEmpty());
    }

    @isTest
    private static void testGetLearningStatusOptions() {
        VF_UpdateStudentCtrl ctrl = new VF_UpdateStudentCtrl();
        
        Test.startTest();
            List<SelectOption> statusOptions = ctrl.getLearningStatusOptions();
        Test.stopTest();
        
        // Assert that status options are not empty
        Assert.isFalse(statusOptions.isEmpty());
    }


    @isTest
    private static void testValidateForm() {
        setupTestData();
        VF_UpdateStudentCtrl ctrl = setupUpdateController(
                                                        ''
                                                        , ''
                                                        , ''
                                                        , null
        );


        Test.startTest();
            Boolean hasErrors = ctrl.validateForm();
        Test.stopTest();

        // Assert errors are captured for missing fields
        Assert.isTrue(hasErrors, 'Form validation should fail for missing fields');
    }

    @isTest
    private static void testValidateBirthday_Over18() {
        // call the setupTestData method to get the current page reference
        setupTestData();

        Test.startTest();
            VF_UpdateStudentCtrl ctrl = new VF_UpdateStudentCtrl();
            Boolean isInvalid = ctrl.validateBirthday();
        Test.stopTest();

        // Assert student is over 18
        Assert.isFalse(isInvalid, 'Student should be over 18');
    }

    @isTest
    private static void testUpdateStudent_Success() {
        setupTestData();
        VF_UpdateStudentCtrl ctrl = new VF_UpdateStudentCtrl();
        ctrl = setupUpdateController(
                                    ctrl.student.Class_look__c
                                    , ctrl.student.Gender__c
                                    , ctrl.student.LearningStatus__c
                                    , null
        );

        Test.startTest();
            PageReference result = ctrl.updateStudent();
        Test.stopTest();

        // Assert update was successful
        PageReference expected = Page.VF_SearchStudent;
        Assert.areEqual(expected.getUrl(), result.getUrl());
    }

    @isTest
    private static void testUpdateStudent_ValidateForm() {
        VF_UpdateStudentCtrl ctrl = setupUpdateController(
                                                        null
                                                        , null
                                                        , null
                                                        , null
    );

        Test.startTest();
            PageReference result = ctrl.updateStudent();
        Test.stopTest();

        // Assert update was successful
        Assert.isNull(result);
    }

    @isTest
    private static void testUpdateStudent_Under18() {
        // get the current page reference
        setupTestData();
        VF_UpdateStudentCtrl ctrl = new VF_UpdateStudentCtrl();
        ctrl = setupUpdateController(
                                    ctrl.student.Class_look__c
                                    , ctrl.student.Gender__c
                                    , ctrl.student.LearningStatus__c
                                    , Date.today().addYears(-17)
        );

        Test.startTest();
            PageReference result = ctrl.updateStudent();
        Test.stopTest();

        Assert.isNull(result);
    }

    @isTest
    private static void testRedirectToSearchPage() {
        Test.startTest();
            VF_UpdateStudentCtrl ctrl = new VF_UpdateStudentCtrl();
            PageReference result = ctrl.redirectToSearchPage();
        Test.stopTest();

        // Assert redirection to search page
        PageReference expected = Page.VF_SearchStudent;
        Assert.areEqual(expected.getUrl(), result.getUrl());
    }

    @isTest
    private static void testGetStudentDetail_Exception() {
        Boolean isException = false;
        VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
        VF_UpdateStudentCtrl.isThrownException = true;
        
        Test.startTest();
            try {
                controller.getStudentDetail();
            } catch (Exception e) {
                isException = true;
            }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    @isTest
    private static void testGetClassOptions_Exception() {
        Boolean isException = false;
        VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
        VF_UpdateStudentCtrl.isThrownException = true;
        
        Test.startTest();
            try {
                controller.getClassOptions();
            } catch (Exception e) {
                isException = true;
            }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    @isTest
    private static void testGetLearningStatusOptions_Exception() {
        Boolean isException = false;
        VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
        VF_UpdateStudentCtrl.isThrownException = true;
        
        Test.startTest();
            try {
                controller.getLearningStatusOptions();
            } catch (Exception e) {
                isException = true;
            }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    @isTest
    private static void testGetGenderOptions_Exception() {
        Boolean isException = false;
        VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
        VF_UpdateStudentCtrl.isThrownException = true;
        
        Test.startTest();
            try {
                controller.getGenderOptions();
            } catch (Exception e) {
                isException = true;
            }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    @isTest
    private static void testUpdateStudent_Exception() {
        Boolean isException = false;
        VF_UpdateStudentCtrl controller = new VF_UpdateStudentCtrl();
        VF_UpdateStudentCtrl.isThrownException = true;
        
        Test.startTest();
            try {
                controller.updateStudent();
            } catch (Exception e) {
                isException = true;
            }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    private static void setupTestData() {
        // Create a test Class__c record
        insert new Class__c();

        List<Class__c> classList = [
            SELECT Id 
            FROM Class__c
        ];
        Class__c testClass = new Class__c();
        if (classList.size() > 0) {
            testClass = classList[0];
        }
        // Create a test Student__c record linked to the class
        Student__c testStudent = new Student__c(
            Firstname__c = 'John'
            , Lastname__c = 'Doe'
            , Birthday__c = Date.today().addYears(-20)
            , Class_look__c = testClass.Id
            , Gender__c = 'Male'
            , LearningStatus__c = 'Enrolled'
        );
        insert testStudent;

        Test.setCurrentPage(Page.VF_UpdateStudent);
        ApexPages.currentPage().getParameters().put('id', testStudent.Id);
    }

    private static VF_UpdateStudentCtrl setupUpdateController(
                                                            String classId
                                                            , String gender
                                                            , String status
                                                            , Date birthday
    ) {
        VF_UpdateStudentCtrl ctrl = new VF_UpdateStudentCtrl();
        ctrl.selectedClass = classId;
        ctrl.selectedGender = gender;
        ctrl.selectedStatus = status;
        
        if (birthday != null) {
            ctrl.student.Birthday__c = birthday;
        }
        
        return ctrl;
    }
}