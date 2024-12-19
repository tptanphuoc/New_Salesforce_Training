@IsTest
private class CMP_SearchStudentCtrlTest {
    
    @IsTest
    private static void testGetAllOptions() {
        // Prepare the data
        Class__c testClass = createClass();
        insert testClass;

        // Start the test
        Test.startTest();
            Map<String, List<CustomSelectOption>> optionsMap = CMP_SearchStudentCtrl.getAllOptions();
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
                CMP_SearchStudentCtrl.isThrownException = true;
                CMP_SearchStudentCtrl.getAllOptions();
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
        CMP_SearchStudentCtrl.SearchCriterias criteria = createSearchCriteria(
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
            List<Student__c> result = CMP_SearchStudentCtrl.searchStudents(criteria);
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
        CMP_SearchStudentCtrl.SearchCriterias criteria = createSearchCriteria(
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
            List<Student__c> result = CMP_SearchStudentCtrl.searchStudents(criteria);
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
                CMP_SearchStudentCtrl.isThrownException = true;
                CMP_SearchStudentCtrl.searchStudents(null);
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
                CMP_SearchStudentCtrl.isThrownException = true;
                CMP_SearchStudentCtrl.deleteOneStudent(null);
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
                CMP_SearchStudentCtrl.isThrownException = true;
                CMP_SearchStudentCtrl.deleteSelectedStudents(null);
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
            CMP_SearchStudentCtrl.deleteOneStudent(student.Id);
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
            CMP_SearchStudentCtrl.deleteSelectedStudents(studentIds);
        Test.stopTest();

        // Verify the results
        List<Student__c> remainingStudents = [
            SELECT Id 
            FROM Student__c
            WHERE Id IN :studentIds
        ];

        Assert.isTrue(remainingStudents.isEmpty(), 'The students should have been deleted.');
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
            Map<String, Integer> settingMap = CMP_SearchStudentCtrl.getCustomSettings();
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
                CMP_SearchStudentCtrl.isThrownException = true;
                CMP_SearchStudentCtrl.getCustomSettings();
            } catch (AuraHandledException e) {
                isException = true;
            }
        Test.stopTest();

        // Verify the results
        Assert.isTrue(isException, 'An exception should have been thrown.');
    }

    private static List<Student__c> createStudents() {
        // Create test Class__c record
        Class__c testClass = createClass();
        insert testClass;

        // Create test Student__c records
        List<Student__c> students = new List<Student__c>();
        for(Integer i = 0; i < 20; i++) {
            students.add(createStudentTemplate('Test' + i, 'Student' + i, Date.newInstance(2000, 1, 15), 'Enrolled', 'Male', testClass.Id));
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

        return students.isEmpty() ? new Student__c() : students[0];
    }

    // create student template
    private static Student__c createStudentTemplate(String firstName
                                                    , String lastName
                                                    , Date birthday
                                                    , String learningStatus
                                                    , String gender
                                                    , Id classId) {
                                                        
        return new Student__c(
            FirstName__c = firstName
            , LastName__c = lastName
            , Birthday__c = birthday
            , LearningStatus__c = learningStatus
            , Gender__c = gender
            , Class_look__c = classId
        );
    }

    // create class
    private static Class__c createClass() {
        return new Class__c();
    }

    private static CMP_SearchStudentCtrl.SearchCriterias createSearchCriteria(
                                                                            String searchName
                                                                            , String searchStudentCode
                                                                            , Id selectedClass
                                                                            , String selectedGender
                                                                            , Date searchBirthday
                                                                            , String selectedDay
                                                                            , String selectedMonth
                                                                            , String selectedYear
    ) {

        CMP_SearchStudentCtrl.SearchCriterias criteria = new CMP_SearchStudentCtrl.SearchCriterias();
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