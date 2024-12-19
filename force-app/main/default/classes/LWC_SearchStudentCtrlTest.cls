@IsTest
private class LWC_SearchStudentCtrlTest {
    
    @IsTest
    private static void testGetAllOptions() {
        // Prepare the data
        Class__c testClass = new Class__c();
        insert testClass;

        // Start the test
        Test.startTest();
            Map<String, List<CustomSelectOption>> optionsMap = LWC_SearchStudentCtrl.getAllOptions();
        Test.stopTest();

        // Verify the results
        Assert.isFalse(optionsMap.isEmpty(), 'The map should not be empty.');
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
                LWC_SearchStudentCtrl.isThrownException = true;
                LWC_SearchStudentCtrl.getAllOptions();
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @IsTest
    private static void testSearchStudentsWithExactBirthday() {
        // Prepare the data
        List<Student__c> students = createStudents();
        insert students;
        Student__c student = getStudent();

        LWC_SearchStudentCtrl.SearchCriterias criteria = createSearchCriteria(
                                                                            'Test'
                                                                            , student.StudentCode__c
                                                                            , student.Class_look__c
                                                                            , 'Male'
                                                                            , Date.newInstance(2000, 1, 15)
                                                                            , null
                                                                            , null
                                                                            , null
    );

        // Start the test
        Test.startTest();
            List<Student__c> result = LWC_SearchStudentCtrl.searchStudents(criteria);
        Test.stopTest();

        // Verify the results
        Assert.isFalse(result.isEmpty(), 'The list should not be empty.');
    }

    @IsTest
    private static void testSearchStudentsWithPartialBirthday() {
        // Prepare the data
        List<Student__c> students = createStudents();
        insert students;
        Student__c student = getStudent();
        LWC_SearchStudentCtrl.SearchCriterias criteria = createSearchCriteria(
                                                                            'Test'
                                                                            , student.StudentCode__c
                                                                            , student.Class_look__c
                                                                            , 'Male'
                                                                            , null
                                                                            , '15'
                                                                            , '1'
                                                                            , '2000'
    );

        // Start the test
        Test.startTest();
            List<Student__c> result = LWC_SearchStudentCtrl.searchStudents(criteria);
        Test.stopTest();

        // Verify the results
        Assert.isFalse(result.isEmpty(), 'The list should not be empty.');
    }

    @IsTest
    private static void testSearchStudents_Exception() {
        // Prepare the data
        Boolean isException = false;

        // Start the test
        Test.startTest();
            try {
                LWC_SearchStudentCtrl.isThrownException = true;
                LWC_SearchStudentCtrl.searchStudents(null);
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @IsTest
    private static void testDeleteOneStudent_Exception() {
        // Prepare the data
        Boolean isException = false;

        // Start the test
        Test.startTest();
            try {
                LWC_SearchStudentCtrl.isThrownException = true;
                LWC_SearchStudentCtrl.deleteOneStudent(null);
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @IsTest
    private static void testDeleteSelectedStudents_Exception() {
        // Prepare the data
        Boolean isException = false;

        // Start the test
        Test.startTest();
            try {
                LWC_SearchStudentCtrl.isThrownException = true;
                LWC_SearchStudentCtrl.deleteSelectedStudents(null);
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    @IsTest
    private static void testDeleteOneStudent() {
        // Prepare the data
        List<Student__c> students = createStudents();
        insert students;
        Student__c student = getStudent();
        
        // Start the test
        Test.startTest();
            LWC_SearchStudentCtrl.deleteOneStudent(student.Id);
        Test.stopTest();

        // Verify the results
        List<Student__c> remainingStudents = [
            SELECT Id 
            FROM Student__c
            WHERE Id = :student.Id
        ];

        Assert.isTrue(remainingStudents.isEmpty(), 'The student should not have been deleted.');
    }

    @IsTest
    private static void testDeleteSelectedStudents() {
        // Prepare the data
        List<Student__c> students = createStudents();
        insert students;
        List<String> studentIds = new List<String>();
        for(Student__c student : students) {
            studentIds.add(student.Id);
        }

        // Start the test
        Test.startTest();
            LWC_SearchStudentCtrl.deleteSelectedStudents(studentIds);
        Test.stopTest();

        // Verify the results
        List<Student__c> remainingStudents = [
            SELECT Id 
            FROM Student__c
            WHERE Id IN :studentIds
        ];

        Assert.isTrue(remainingStudents.isEmpty(), 'The students should not have been deleted.');
    }

    @IsTest
    private static void testGetCustomSetting() {
        // Prepare the data
        StudentMeanageSetting__c settings = new StudentMeanageSetting__c(
            S_RecordPerPage__c = 10,
            S_MaxRecord__c = 1000
        );
        insert settings;

        // Start the test
        Test.startTest();
            Map<String, Integer> settingMap = LWC_SearchStudentCtrl.getCustomSettings();
        Test.stopTest();

        // Verify the results
        Assert.isFalse(settingMap.isEmpty(), 'The map should not be empty.');
    }

    @IsTest
    private static void testGetCustomSetting_Exception() {
        // Prepare the data
        Boolean isException = false;

        // Start the test
        Test.startTest();
            try {
                LWC_SearchStudentCtrl.isThrownException = true;
                LWC_SearchStudentCtrl.getCustomSettings();
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    private static List<Student__c> createStudents() {
        // Create test Class__c record
        Class__c testClass = new Class__c();
        insert testClass;
        // Create test Student__c records
        List<Student__c> students = new List<Student__c>();
        for(Integer i = 0; i < 20; i++) {
            Student__c student = new Student__c(
                FirstName__c = 'Test' + i
                , LastName__c = 'Student' + i
                , Birthday__c = Date.newInstance(2000, 1, 15)
                , LearningStatus__c = 'Enrolled'
                , Gender__c = 'Male'
                , Class_look__c = testClass.Id
            );
            students.add(student);
        }

        return students;
    }

    private static Student__c getStudent() {
        List<Student__c> students = [
            SELECT Id
                   , StudentCode__c
                   , Class_look__c
            FROM Student__c
            LIMIT 1
        ];
        Student__c student = new Student__c();
        if(!students.isEmpty()) {
            student = students[0];
        }
        
        return student;
    }

    private static LWC_SearchStudentCtrl.SearchCriterias createSearchCriteria(
                                                                            String searchName
                                                                            , String searchStudentCode
                                                                            , Id selectedClass
                                                                            , String selectedGender
                                                                            , Date searchBirthday
                                                                            , String selectedDay
                                                                            , String selectedMonth
                                                                            , String selectedYear
    ) {
        LWC_SearchStudentCtrl.SearchCriterias criteria = new LWC_SearchStudentCtrl.SearchCriterias();
        criteria.searchName = searchName;
        criteria.searchStudentCode = searchStudentCode;
        criteria.selectedClass = selectedClass;
        criteria.selectedGender = selectedGender;
        criteria.searchBirthday = searchBirthday;
        criteria.selectedDay = selectedDay;
        criteria.selectedMonth = selectedMonth;
        criteria.selectedYear = selectedYear;
        
        return criteria;
    }
}