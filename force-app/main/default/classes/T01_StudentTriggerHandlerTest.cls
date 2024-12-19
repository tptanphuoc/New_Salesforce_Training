@isTest
private class T01_StudentTriggerHandlerTest {

    @isTest
    private static void testHandleBeforeInsert_ValidData() {
        // Create a valid new student list
        List<Student__c> newStudents = new List<Student__c>();
        newStudents.add(createBeforeStudents(false));

        Test.startTest();
            insert newStudents;
        Test.stopTest();

        // Verify no errors were added
        Assert.isFalse(newStudents[0].hasErrors(), 'No errors should have been added.');
    }

    @isTest
    private static void testHandleBeforeInsert_BlankFields() {
        // prepare test data
        Boolean isException = false;
        List<Student__c> newStudents = new List<Student__c>{
            new Student__c()
        };

        Test.startTest();
            try {
                insert newStudents;
            } catch (Exception ex) {
                isException = true;
            }
        Test.stopTest();

        // Verify the error for age restriction
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @isTest
    private static void testHandleBeforeInsert_InvalidBirthday() {
        //  Prepare test data
        Boolean isException = false;
        List<Student__c> newStudents = new List<Student__c>();
        newStudents.add(createBeforeStudents(true));

        Test.startTest();
            try {
                insert newStudents;
            } catch (Exception ex) {
                isException = true;
            }
        Test.stopTest();

        // Verify the error for age restriction
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @isTest
    private static void testHandleAfterInsert() {
        // prepare test data
        Student__c newStudent = createAfterStudents(false);
        List<Student__c> newStudents = new List<Student__c>{
            new Student__c(
                Firstname__c = 'Charlie'
                , Lastname__c = 'Clark'
                , Birthday__c = Date.today().addYears(-19)
                , Class_look__c = newStudent.Class_look__c
                , Gender__c = 'Male'
                , LearningStatus__c = 'Enrolled'
            )
        };

        // Run after insert handler
        Test.startTest();
            insert newStudents;
        Test.stopTest();

        // Verify the results
        List<Class__c> updatedClasses = [
            SELECT Id
                   , NumberOfStudent__c 
            FROM Class__c 
            WHERE Id = :newStudent.Class_look__c
        ];
        Decimal expectedStudentCount = updatedClasses.size() > 0 ? updatedClasses[0].NumberOfStudent__c : 0;
        Assert.areEqual(2, Integer.valueOf(expectedStudentCount));
    }

    @isTest
    private static void testHandleBeforeUpdateUnder18() {
        // Prepare test data
        Boolean isException = false;
        Student__c existingStudent = createAfterStudents(false);
        existingStudent.Birthday__c = Date.today().addYears(-17);
        List<Student__c> oldStudents = new List<Student__c>{ existingStudent };

        // Run before update handler
        Test.startTest();
            try {
                update oldStudents;
            } catch (Exception ex) {
                isException = true;
            }
        Test.stopTest();

        // Verify the error for age restriction
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @isTest
    private static void testHandleAfterUpdate() {
        // Prepare test data
        Student__c existingStudent = createAfterStudents(false);
        String oldClassId = existingStudent.Class_look__c;
        List<Student__c> oldStudents = new List<Student__c>{ existingStudent };
        Class__c newClass = createClass();
        insert newClass;
        existingStudent.Class_look__c = newClass.Id;
        List<Student__c> newStudents = new List<Student__c>{ existingStudent };

        // Run after update handler
        Test.startTest();
            update newStudents;
        Test.stopTest();

        // Verify the results
        List<Class__c> updatedClasses = [
            SELECT Id
                   , NumberOfStudent__c 
            FROM Class__c 
            WHERE Id = :newClass.Id
        ];
        Decimal newCount = updatedClasses.size() > 0 ? updatedClasses[0].NumberOfStudent__c : 0;
        Assert.areEqual(1, Integer.valueOf(newCount));
    }

    @isTest
    private static void testHandleBeforeDelete() {
        // Prepare test data
        Student__c existingStudent = createAfterStudents(false);
        SubjectScore__c subjectScore = new SubjectScore__c(Student_look__c = existingStudent.Id);
        insert subjectScore;
        List<Student__c> oldStudents = new List<Student__c>{ existingStudent };

        // Run before delete handler
        Test.startTest();
            delete oldStudents;
        Test.stopTest();

        // Verify the results
        List<SubjectScore__c> subjectScores = [
            SELECT Id
            FROM SubjectScore__c
            WHERE Student_look__c = :existingStudent.Id
        ];

        Assert.isTrue(subjectScores.isEmpty(), 'The subject score should not have been deleted.');
    }

    @isTest
    private static void testHandleAfterDelete() {
        // Prepare test data
        Student__c existingStudent = createAfterStudents(false);
        List<Student__c> oldStudents = new List<Student__c>{ existingStudent };

        // Run after delete handler
        Test.startTest();
            delete oldStudents;
        Test.stopTest();

        // Verify the results
        List<Class__c> updatedClasses = [
            SELECT Id
                   , NumberOfStudent__c 
            FROM Class__c 
            WHERE Id = :existingStudent.Class_look__c
        ];

        Decimal newCount = updatedClasses.size() > 0 ? updatedClasses[0].NumberOfStudent__c : 0;
        Assert.areEqual(0, Integer.valueOf(newCount));
    }

    @isTest
    private static void testHandleBeforeInsert_Exception() {
        // Prepare test data
        Boolean isException = false;
        List<Student__c> newStudents = new List<Student__c>{
            new Student__c()
        };

        // Run before insert handler
        Test.startTest();
            try {
                T01_StudentTriggerHandler.isThrownException = true;
                insert newStudents;
            } catch (Exception ex) {
                isException = true;
            }
        Test.stopTest();

        // Verify the error for age restriction
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @isTest
    private static void testHandleAfterInsert_Exception() {
        // Prepare test data
        Boolean isException = false;
        Student__c newStudent = createAfterStudents(false);
        List<Student__c> newStudents = new List<Student__c>{
            new Student__c(
                Firstname__c = 'Charlie'
                , Lastname__c = 'Clark'
                , Birthday__c = Date.today().addYears(-19)
                , Class_look__c = newStudent.Class_look__c
                , Gender__c = 'Male'
                , LearningStatus__c = 'Enrolled'
            )
        };

        // Run before insert handler
        Test.startTest();
            try {
                T01_StudentTriggerHandler.isThrownException = true;
                T01_StudentTriggerHandler handler = new T01_StudentTriggerHandler();
                handler.handleAfterInsert(newStudents);
            } catch (Exception ex) {
                isException = true;
            }
        Test.stopTest();

        // Verify the error for age restriction
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @isTest
    private static void testHandleBeforeUpdate_Exception() {
        // Prepare test data
        Boolean isException = false;
        Student__c existingStudent = createAfterStudents(false);
        existingStudent.Birthday__c = Date.today().addYears(-17);
        List<Student__c> oldStudents = new List<Student__c>{ existingStudent };

        // Run before update handler
        Test.startTest();
            try {
                T01_StudentTriggerHandler.isThrownException = true;
                update oldStudents;
            } catch (Exception ex) {
                isException = true;
            }
        Test.stopTest();

        // Verify the error for age restriction
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @isTest
    private static void testHandleAfterUpdate_Exception() {
        // Prepare test data
        Boolean isException = false;
        
        // Run after update handler
        Test.startTest();
            try {
                T01_StudentTriggerHandler.isThrownException = true;
                T01_StudentTriggerHandler handler = new T01_StudentTriggerHandler();
                handler.handleAfterUpdate(new List<Student__c>(), new List<Student__c>());
            } catch (Exception ex) {
                isException = true;
            }
        Test.stopTest();

        // Verify the error for age restriction
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @isTest
    private static void testHandleBeforeDelete_Exception() {
        // Prepare test data
        Boolean isException = false;
        Student__c existingStudent = createAfterStudents(false);
        List<Student__c> oldStudents = new List<Student__c>{ existingStudent };

        // Run before delete handler
        Test.startTest();
            try {
                T01_StudentTriggerHandler.isThrownException = true;
                delete oldStudents;
            } catch (Exception ex) {
                isException = true;
            }
        Test.stopTest();

        // Verify the error for age restriction
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @isTest
    private static void testHandleAfterDelete_Exception() {
        // Prepare test data
        Boolean isException = false;
        Student__c existingStudent = createAfterStudents(false);
        List<Student__c> oldStudents = new List<Student__c>{ existingStudent };

        // Run after delete handler
        Test.startTest();
            try {
                T01_StudentTriggerHandler.isThrownException = true;
                T01_StudentTriggerHandler handler = new T01_StudentTriggerHandler();
                handler.handleAfterDelete(oldStudents);
            } catch (Exception ex) {
                isException = true;
            }
        Test.stopTest();

        // Verify the error for age restriction
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @isTest
    private static void testReturnAtGetCustomSetting() {
        // Prepare test data
        
        // Run before insert handler
        Test.startTest();
            StudentMeanageSetting__c settings = StudentMeanageSetting__c.getOrgDefaults();
            settings.T01_InActive_flg__c = true;
            insert settings;
            
            Student__c newStudent = createAfterStudents(false);
        Test.stopTest();

        // verify the results
        List<Student__c> students = [
            SELECT Id
            FROM Student__c
            WHERE Id = :newStudent.Id
        ];
        Assert.isFalse(students.isEmpty(), 'The student should have been inserted.');
    }

    // Method to set up test data for Class__c and Student__c
    private static Class__c createClass() {
        // Insert a test Class__c record
        return new Class__c();
    }

    private static Student__c createBeforeStudents(Boolean isUnderAge) {
        Class__c testClass = createClass();
        insert testClass;
        return createStudentRecord(testClass.Id, isUnderAge);
    }
    
    private static Student__c createAfterStudents(Boolean isUnderAge) {
        Class__c testClass = createClass();
        insert testClass;
        Student__c student = createStudentRecord(testClass.Id, isUnderAge);
        insert student;
        return student;
    }
    
    private static Student__c createStudentRecord(Id classId, Boolean isUnderAge) {
        Student__c testStudent = new Student__c(
            Firstname__c = 'Alice'
            , Lastname__c = 'Smith'
            , Birthday__c = isUnderAge ? Date.today().addYears(-17) : Date.today().addYears(-19)
            , Class_look__c = classId
            , Gender__c = 'Female'
            , LearningStatus__c = 'Enrolled'
        );

        return testStudent;
    }
}