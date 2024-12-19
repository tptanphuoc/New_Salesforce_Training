@IsTest
private class CMP_CreateStudentCtrlTest {

    @IsTest
    private static void testGetAllOptions() {
        // Prepare the data
        Class__c testClass = createClassTemplate();
        insert testClass;

        // Start the test
        Test.startTest();
            Map<String, List<CustomSelectOption>> optionsMap = CMP_CreateStudentCtrl.getAllOptions();
        Test.stopTest();

        // Verify the results
        Assert.isFalse(optionsMap.isEmpty(), 'Options map should not be empty.');
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
                CMP_CreateStudentCtrl.isThrownException = true;
                CMP_CreateStudentCtrl.getAllOptions();
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
            CMP_CreateStudentCtrl.createNewStudent(overAgeStudent);
        Test.stopTest();

        // Verify the results
        List<Student__c> students = [SELECT Id FROM Student__c];
        Assert.isFalse(students.isEmpty(), 'Student record should have been created.');
    }

    @IsTest
    private static void testCreateNewStudentUnderage() {
        // Prepare the data
        Boolean isException = false;
        Student__c underAgeStudent = createBaseStudent(true);

        // Start the test
        Test.startTest();
            try {
                CMP_CreateStudentCtrl.createNewStudent(underAgeStudent);
            } catch (Exception ex) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    // Factory method to create a base student record
    private static Student__c createBaseStudent(Boolean isUnderage) {
        // create class first
        Class__c testClass = createClassTemplate();
        insert testClass;

        Date birthday = isUnderage ? 
            Date.today().addYears(-17) : // Underage
            Date.today().addYears(-20);  // Adult
            
        Student__c student = new Student__c(
            FirstName__c = 'Test'
            , LastName__c = 'Student'
            , Birthday__c = birthday
            , LearningStatus__c = 'Enrolled'
            , Gender__c = 'Male'
            , Class_look__c = testClass.Id
        );
        
        return student;
    }

    private static Class__c createClassTemplate() {
        return new Class__c();
    }
}