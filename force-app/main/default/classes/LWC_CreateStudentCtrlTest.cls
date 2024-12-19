@IsTest
private class LWC_CreateStudentCtrlTest {
    
    @IsTest
    private static void testGetAllOptions() {
        // Prepare the data
        Class__c testClass = createClass();
        insert testClass;

        // Start the test
        Test.startTest();
            Map<String, List<CustomSelectOption>> optionsMap = LWC_CreateStudentCtrl.getAllOptions();
        Test.stopTest();

        // Verify the results
        Assert.isFalse(optionsMap.isEmpty(), 'The options map should not be empty.');
        Assert.isTrue(optionsMap.containsKey('learningStatusOptions'));
        Assert.isTrue(optionsMap.containsKey('genderOptions'));
        Assert.isTrue(optionsMap.containsKey('classOptions'));
    }

    @IsTest
    private static void testGetAllOptions_Exception() {
        // Prepare the data
        Boolean isException = false;

        // Start the test
        Test.startTest();
            try {
                LWC_CreateStudentCtrl.isThrownException = true;
                LWC_CreateStudentCtrl.getAllOptions();
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @IsTest
    private static void testCreateNewStudentSuccess() {
        // Prepare the data
        Student__c overAgeStudent = createBaseStudent(false);

        // Start the test
        Test.startTest();
            LWC_CreateStudentCtrl.createNewStudent(overAgeStudent);
        Test.stopTest();

        // Verify the results
        List<Student__c> students = [SELECT Id FROM Student__c];
        Assert.isFalse(students.isEmpty(), 'The student should have been created.');
    }

    @IsTest
    private static void testCreateNewStudentUnderage() {
        // Prepare the data
        Boolean isException = false;

        // Start the test
        Test.startTest();
            try {
                Student__c underageStudent = createBaseStudent(true);
                LWC_CreateStudentCtrl.createNewStudent(underageStudent);
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    // Factory method to create a base student record
    private static Student__c createBaseStudent(Boolean isUnderage) {
        // create class first
        Class__c testClass = createClass();
        insert testClass;

        Date birthday = isUnderage ? 
            Date.today().addYears(-17) : // Underage
            Date.today().addYears(-20);  // Adult
            
        Student__c student = new Student__c(
            FirstName__c = 'Test',
            LastName__c = 'Student',
            Birthday__c = birthday,
            LearningStatus__c = 'Enrolled',
            Gender__c = 'Male',
            Class_look__c = testClass.Id
        );
        
        return student;
    }

    // Helper method to create Class__c record
    private static Class__c createClass() {
        return new Class__c();
    }
}