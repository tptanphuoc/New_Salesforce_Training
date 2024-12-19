@IsTest
private class LWC_UpdateStudentCtrlTest {

    @IsTest
    private static void testGetAllOptions() {
        // Prepare the data
        Class__c testClass = createClass();
        insert testClass;

        // Start the test
        Test.startTest();
            Map<String, List<CustomSelectOption>> optionsMap = LWC_UpdateStudentCtrl.getAllOptions();
        Test.stopTest();

        // Verify the results
        Assert.isFalse(optionsMap.isEmpty(), 'The map should not be empty.');
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
                LWC_UpdateStudentCtrl.isThrownException = true;
                LWC_UpdateStudentCtrl.getAllOptions();
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @IsTest
    private static void testGetExistingStudent() {
        // Prepare the data
        Student__c student = createStudent();
        insert student;
        
        // Start the test
        Test.startTest();
            Student__c result = LWC_UpdateStudentCtrl.getExistingStudent(student.Id);
        Test.stopTest();
        
        // Verify the results
        Assert.areEqual(student.Id, result.Id, 'The Id should be the same.');
    }

    @IsTest
    private static void testGetExistingStudent_Exception() {
        // Prepare the data
        Boolean isException = false;

        // Start the test
        Test.startTest();
            try {
                LWC_UpdateStudentCtrl.isThrownException = true;
                LWC_UpdateStudentCtrl.getExistingStudent(null);
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }
    
    @IsTest
    private static void testUpdateExistingStudent() {
        // Prepare the data
        Student__c student = createStudent();
        insert student;
        student.Firstname__c = 'Jane';
        
        // Start the test
        Test.startTest();
            LWC_UpdateStudentCtrl.updateExistingStudent(student);
        Test.stopTest();
        
        // Verify the results
        List<Student__c> result = [
            SELECT Id
                   , Firstname__c 
            FROM Student__c 
            WHERE Id = :student.Id];

        Student__c updatedStudent = result.size() > 0 ? result[0] : null;
        Assert.isNotNull(updatedStudent, 'The record should be found.');
        Assert.areEqual('Jane', updatedStudent.Firstname__c, 'The Firstname should be updated.');
    }

    @IsTest
    private static void testUpdateExistingStudent_Exception() {
        // Prepare the data
        Boolean isException = false;

        // Start the test
        Test.startTest();
            try {
                LWC_UpdateStudentCtrl.isThrownException = true;
                LWC_UpdateStudentCtrl.updateExistingStudent(null);
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    private static Student__c createStudent() {
        // Create test Class__c record
        Class__c testClass = createClass();
        insert testClass;
        
        // Create test Student__c record
        Student__c student = new Student__c(
              Firstname__c = 'John'
            , Lastname__c = 'Doe'
            , Gender__c = 'Male'
            , Birthday__c = Date.today().addYears(-20) // Student over 18
            , Class_look__c = testClass.Id
            , LearningStatus__c = 'Enrolled'
        );

        return student;
    }

    private static Class__c createClass() {
        // Create test Class__c record
        Class__c testClass = new Class__c();

        return testClass;
    }
}