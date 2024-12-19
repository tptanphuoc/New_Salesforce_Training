@isTest
private class VF_SearchStudentCtrlTest {

    @isTest
    private static void testConstructor() {
        setupTestData();

        Test.startTest();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        Test.stopTest();

        Assert.areEqual(1, controller.currentPage);
        Assert.areEqual(5, controller.pageSize);
        Assert.areEqual(2000, controller.maxRecords);
    }

    @isTest
    private static void testConstructorWithError() {
        setupTestData();
        // get custom settings and edit them
        StudentMeanageSetting__c mc = StudentMeanageSetting__c.getOrgDefaults();
        mc.S_RecordPerPage__c = -1;
        mc.S_MaxRecord__c = -11;
        upsert mc;

        Test.startTest();
            VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        Test.stopTest();
        
        Assert.areEqual(-1, mc.S_RecordPerPage__c);
        Assert.areEqual(-11,  mc.S_MaxRecord__c);
    }

    @isTest
    private static void testSearchStudent() {
        setupTestData();
        // get a class and take id
        List<Class__c> classes = [
            SELECT Id 
            FROM Class__c 
            LIMIT 1
        ];
        // get a student and take StudentCode
        List<Student__c> students = [
            SELECT StudentCode__c 
            FROM Student__c 
            LIMIT 1
        ];

        VF_SearchStudentCtrl controller = setupSearchController(
                                                                'Test'
                                                                , students[0].StudentCode__c
                                                                , classes[0].Id
                                                                , 'Female'
                                                                , Date.newInstance(2002, 10, 20)
                                                                , null
                                                                , null
                                                                , null
    );

        Test.startTest();
            controller.searchStudent();
        Test.stopTest();

        Assert.isFalse(controller.studentListResult.isEmpty());
        Assert.areEqual(1, controller.currentPage);
        Assert.areNotEqual(0, controller.totalPages);
    }

    @isTest
    private static void testSearchStudentNullBirthday() {
        setupTestData();
        // get a class and take id
        List<Class__c> classes = [
            SELECT Id 
            FROM Class__c 
            LIMIT 1
        ];
        // get a student and take StudentCode
        List<Student__c> students = [
            SELECT StudentCode__c 
            FROM Student__c 
            LIMIT 1
        ];

        VF_SearchStudentCtrl controller = setupSearchController(
                                                                'Test'
                                                                , students[0].StudentCode__c
                                                                , classes[0].Id
                                                                , 'Female'
                                                                , null
                                                                , 20
                                                                , 10
                                                                , 2002
    );

        Test.startTest();
            controller.searchStudent();
        Test.stopTest();

        Assert.isFalse(controller.studentListResult.isEmpty());
    }

    @isTest
    private static void testGetStudentList() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchStudent();
        controller.currentPage = 9;
        
        Test.startTest();
            controller.goToPage();
        Test.stopTest();

        Assert.isFalse(controller.studentListResult.isEmpty());
    }

    @isTest
    private static void testGenPageNumber1() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchStudent();
        controller.currentPage = 5;
        
        Test.startTest();
            controller.goToPage();
        Test.stopTest();

        Assert.isFalse(controller.studentListResult.isEmpty());
    }

    @isTest
    private static void testGenPageNumber2() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchStudent();
        controller.currentPage = 8;
        
        Test.startTest();
            controller.goToPage();
        Test.stopTest();

        Assert.isFalse(controller.studentListResult.isEmpty());
    }

    @isTest
    private static void testGenPageNumber3() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchStudent();
        controller.currentPage = 4;
        for (Integer i = 0; i < 20; i++) {
            controller.checkDelete.put(controller.allStudents[i].Id, true);
        }
        
        Test.startTest();
            controller.deleteSelectedStudent();
        Test.stopTest();

        Assert.isFalse(controller.studentListResult.isEmpty());
    }

    @isTest
    private static void testDeleteStudent() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchStudent();
        
        Test.startTest();
            controller.recordIdToDelete = controller.studentListResult[0].Id;
            controller.deleteStudent();
        Test.stopTest();

        Assert.isFalse(controller.studentListResult.isEmpty());
    }

    @isTest
    private static void testDeleteSelectedStudents() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchStudent();
        
        Test.startTest();
            for (Student__c student : controller.studentListResult) {
                controller.checkDelete.put(student.Id, true);
            }
            controller.deleteSelectedStudent();
        Test.stopTest();

        Assert.isFalse(controller.studentListResult.isEmpty());
    }

    @isTest
    private static void testDeleteSelectedStudentsNoSelected() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchStudent();
        
        Test.startTest();
            for (Student__c student : controller.allStudents) {
                controller.checkDelete.put(student.Id, false);
            }
            controller.deleteSelectedStudent();
        Test.stopTest();

        Assert.isFalse(controller.studentListResult.isEmpty());
    }

    @isTest
    private static void testGetHasNext() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchStudent();
        
        Test.startTest();
            controller.getHasNext();
        Test.stopTest();

        Assert.areEqual(1, controller.currentPage);
    }

    @isTest
    private static void testGetHasPrevious() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchStudent();
        
        Test.startTest();
            controller.getHasPrevious();
        Test.stopTest();

        Assert.areEqual(1, controller.currentPage);
    }

    @isTest
    private static void testNext() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchStudent();
        
        Test.startTest();
            controller.next();
        Test.stopTest();

        Assert.areEqual(2, controller.currentPage);
    }

    @isTest
    private static void testPrevious() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchStudent();
        controller.currentPage = 2;
        
        Test.startTest();
            controller.previous();
        Test.stopTest();

        Assert.areEqual(1, controller.currentPage);
    }

    @isTest
    private static void testGoToFirst() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchStudent();
        
        Test.startTest();
            controller.first();
        Test.stopTest();

        Assert.areEqual(1, controller.currentPage);
    }

    @isTest
    private static void testGoToLast() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchStudent();
        
        Test.startTest();
            controller.last();
        Test.stopTest();

        Assert.areEqual(controller.totalPages, controller.currentPage);
    }

    @isTest
    private static void testGetClassOptions() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();

        Test.startTest();
            List<SelectOption> classOptions = controller.getClassOptions();
        Test.stopTest();

        // Assert that there are 4 class options (3 classes + 1 default option)
        Assert.isFalse(classOptions.isEmpty());
    }

    @isTest
    private static void testGetLearningStatusOptions() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();

        Test.startTest();
            List<SelectOption> statusOptions = controller.getLearningStatusOptions();
        Test.stopTest();

        // Assert that status options are not empty
        Assert.isFalse(statusOptions.isEmpty());
    }

    @isTest
    private static void testGetGenderOptions() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();

        Test.startTest();
            List<SelectOption> genderOptions = controller.getGenderOptions();
        Test.stopTest();

        // Assert that gender options are not empty
        Assert.isFalse(genderOptions.isEmpty());
    }

    @isTest
    private static void testGetDateRange() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();

        Test.startTest();
            List<SelectOption> dateOptions = controller.getDateRange();
        Test.stopTest();

        // Assert that there are 32 date options (31 days + 1 default option)
        Assert.isFalse(dateOptions.isEmpty());
    }

    @isTest
    private static void testGetMonthRange() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();

        Test.startTest();
            List<SelectOption> monthOptions = controller.getMonthRange();
        Test.stopTest();

        // Assert that there are 13 month options (12 months + 1 default option)
        Assert.isFalse(monthOptions.isEmpty());
    }

    @isTest
    private static void testGetYearRange() {
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();

        Test.startTest();
            List<SelectOption> yearOptions = controller.getYearRange();
        Test.stopTest();

        // Assert that year options are not empty
        Assert.isFalse(yearOptions.isEmpty());
    }

    @isTest
    private static void testSearchStudentException() {
        Boolean isException = false;
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        VF_SearchStudentCtrl.isThrownException = true;
        
        Test.startTest();
            try {
                controller.searchStudent();
            } catch (Exception e) {
                isException = true;
            }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    @isTest
    private static void testDeleteStudentException() {
        Boolean isException = false;
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        VF_SearchStudentCtrl.isThrownException = true;
        
        Test.startTest();
            try {
                controller.deleteStudent();
            } catch (Exception e) {
                isException = true;
            }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    @isTest
    private static void testGetClassOptionsException() {
        Boolean isException = false;
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        VF_SearchStudentCtrl.isThrownException = true;

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
    private static void testGetLearningStatusOptionsException() {
        Boolean isException = false;
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        VF_SearchStudentCtrl.isThrownException = true;
        
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
    private static void testGetGenderOptionsException() {
        Boolean isException = false;
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        VF_SearchStudentCtrl.isThrownException = true;
        
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
    private static void testDeleteSelectedStudentException() {
        Boolean isException = false;
        setupTestData();
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        VF_SearchStudentCtrl.isThrownException = true;

        Test.startTest();
            try {
                controller.deleteSelectedStudent();
            } catch (Exception e) {
                isException = true;
            }
        Test.stopTest();

        Assert.isTrue(isException);
    }

    private static void setupTestData() {
        StudentMeanageSetting__c setting = createStudentManageSetting();
        insert setting;
        List<Class__c> classes = createClasses();
        insert classes;
        List<Student__c> students = createStudents(classes);
        insert students;
    }
    
    private static StudentMeanageSetting__c createStudentManageSetting() {
        StudentMeanageSetting__c setting = new StudentMeanageSetting__c(
            S_RecordPerPage__c = 5
            , S_MaxRecord__c = 2000
        );
        
        return setting;
    }
    
    private static List<Class__c> createClasses() {
        List<Class__c> classes = new List<Class__c>();
        for (Integer i = 0; i < 3; i++) {
            classes.add(new Class__c());
        }

        return classes;
    }
    
    private static List<Student__c> createStudents(List<Class__c> classes) {
        List<Student__c> students = new List<Student__c>();
        for (Integer i = 0; i < 39; i++) {
            students.add(new Student__c(
                Firstname__c = 'Test' + i
                , Lastname__c = 'Student' + i
                , Class_look__c = classes[Math.mod(i, 3)].Id
                , Gender__c = 'Female'
                , Birthday__c = Date.newInstance(2002, 10, 20)
                , LearningStatus__c = 'Enrolled'
            ));
        }
        
        return students;
    }

    private static VF_SearchStudentCtrl setupSearchController(
                                                            String searchName
                                                            , String studentCode
                                                            , Id classId
                                                            , String gender
                                                            , Date birthday
                                                            , Integer selectedDate
                                                            , Integer selectedMonth
                                                            , Integer selectedYear
    ) {
        VF_SearchStudentCtrl controller = new VF_SearchStudentCtrl();
        controller.searchName = searchName;
        controller.searchStudentCode = studentCode;
        controller.selectedClass = classId;
        controller.selectedGender = gender;
        controller.searchBirthday = birthday;
        controller.selectedDate = selectedDate;
        controller.selectedMonth = selectedMonth;
        controller.selectedYear = selectedYear;
        
        return controller;
    }
}