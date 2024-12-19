@IsTest
private class CMP_DetailStudentCtrlTest {

    @IsTest
    private static void testGetStudentDetails_Success() {
        // Prepare test data
        Student__c student = createTestStudent();
        insert student;

        // Start the test
        Test.startTest();
            Student__c result = CMP_DetailStudentCtrl.getStudentDetails(student.Id);
        Test.stopTest();

        // Verify the results
        Assert.areNotEqual(null, result, 'The student record should not be null.');
        Assert.areEqual(student.Id, result.Id, 'The student ID should match the expected value.');
    }

    @IsTest
    private static void testGetStudentDetails_NullId() {
        // Prepare the data
        Boolean isException = false;

        // Start the test
        Test.startTest();
            try {
                CMP_DetailStudentCtrl.getStudentDetails(null);
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    private static Student__c createTestStudent() {
        // Create test class
        Class__c testClass = createTestClass();
        insert testClass;
        
        // Create and return test student
        Student__c student = new Student__c(
            FirstName__c = 'Test'
            , LastName__c = 'Student'
            , Birthday__c = Date.today().addYears(-20)
            , LearningStatus__c = 'Enrolled'
            , Gender__c = 'Male'
            , Class_look__c = testClass.Id
        );

        return student;
    }
    
    private static Class__c createTestClass() {
        return new Class__c();
    }
}