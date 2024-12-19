/**
* クラス名       :	VF_SearchStudentCtrl
* クラス概要     :	A controller class to handle the logic of Student__c object used by VF_SearchStudent page
* @created      :  2024/09/15 Huynh Phuoc
* @modified 	:   
*/
public with sharing class VF_SearchStudentCtrl {

    @TestVisible
    private static Boolean isThrownException = false;

    // List of conditions for filtering
    List<String> conditions = new List<String>();

    // List of all Student__c records
    public List<Student__c> allStudents { get; private set; }

    // The final list of students
    public List<Student__c> studentListResult { get; set; }

    // Search parameter for the Student__c name
    public String searchName { get; set; }

    // Search parameter for the Student__c code
    public String searchStudentCode { get; set; }

    // Search parameter for the selected Class__c
    public String selectedClass { get; set; }

    // Search parameter for the selected Gender__c
    public String selectedGender { get; set; }

    // Search parameter for the Student__c birthday (exact date)
    public Date searchBirthday { get; set; }

    // Search filter for the selected date (day part of the birthday)
    public Integer selectedDate { get; set; }

    // Search filter for the selected month (month part of the birthday)
    public Integer selectedMonth { get; set; }

    // Search filter for the selected year (year part of the birthday)
    public Integer selectedYear { get; set; }

    // The record ID of Student__c to delete
    public Id recordIdToDelete { get; set; }

    // List of Class__c records loaded from the database
    public List<Class__c> classList { get; set; }

    // The current page number for pagination
    public Integer currentPage { get; set; }

    // The number of records to display per page
    public Integer pageSize { get; set; }

    // The total number of records
    public Integer totalRecords { get; set; }

    // The total number of pages
    public Integer totalPages { get; set; }

    // The maximum number of records can be loaded
    public Integer maxRecords { get; set; }

    // A list of page numbers for displaying pagination
    public List<Integer> pages { get; private set; }

    // A map to track which student records are selected for deletion
    public Map<Id, Boolean> checkDelete { get; set; }

    /**
	* VF_SearchStudentCtrl
	* Constructor of VF_SearchStudentCtrl class
	* @param none
	* @return none
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public VF_SearchStudentCtrl() {
        currentPage = 1; // First page of pagination
        allStudents = new List<Student__c>();
        StudentMeanageSetting__c mc = StudentMeanageSetting__c.getOrgDefaults(); // get Custom setting
        if(!String.isBlank(mc.Id)) {
            pageSize = (Integer)mc.S_RecordPerPage__c;
            if (pageSize == null || pageSize <= 0) {
                pageSize = 5;
            }
            maxRecords = (Integer)mc.S_MaxRecord__c;
            if (maxRecords == null || maxRecords <= 0) {
                maxRecords = 2000;
            }
        }
    }

    /**
	* searchStudent
	* Search Student
	* @param none
	* @return void
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public void searchStudent() {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new QueryException('Test exception');
            }

            // clear the previous search conditions
            conditions.clear();
            String baseQuery = 'SELECT Id, ' +
                    'Birthday__c, ' +
                    'Class_look__r.Name, ' +
                    'Firstname__c, ' +
                    'Gender__c, ' +
                    'GPAScore__c, ' +
                    'Lastname__c, ' +
                    'LearningStatus__c, ' +
                    'StudentCode__c ' +
                    'FROM Student__c';

            // Add search filters
            if (String.isNotBlank(searchName)) {
                String nameCondition = '(Firstname__c LIKE \'%' + String.escapeSingleQuotes(searchName.trim()) + '%\' ' + 
                                    'OR Lastname__c LIKE \'%' + String.escapeSingleQuotes(searchName.trim()) + '%\')';
                conditions.add(nameCondition);
            }
            
            if (String.isNotBlank(searchStudentCode)) {
                String studentCodeCondition = 'StudentCode__c LIKE \'%' + String.escapeSingleQuotes(searchStudentCode.trim()) + '%\'';
                conditions.add(studentCodeCondition);
            }

            if (String.isNotBlank(selectedClass)) {
                conditions.add('Class_look__c = :selectedClass');
            }
            
            if (String.isNotBlank(selectedGender)) {
                conditions.add('Gender__c = :selectedGender');
            }
            
            // Add date-related conditions
            if (searchBirthday != null) {
                conditions.add('Birthday__c = :searchBirthday');
            } else {
                if (selectedDate != null) {
                    conditions.add('DAY_IN_MONTH(Birthday__c) = :selectedDate');
                }
                if (selectedMonth != null) {
                    conditions.add('CALENDAR_MONTH(Birthday__c) = :selectedMonth');
                }
                if (selectedYear != null) {
                    conditions.add('CALENDAR_YEAR(Birthday__c) = :selectedYear');
                }
            }

            // Append WHERE clause if conditions exist
            if (!conditions.isEmpty()) {
                baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
            }

            // Add ORDER BY clause
            baseQuery += ' ORDER BY Lastname__c, Firstname__c';

            // Add LIMIT(maxRecords) from CustomSetting__c
            if (maxRecords != null && maxRecords > 0) {
                baseQuery += ' LIMIT :maxRecords';
            }

            allStudents = Database.query(baseQuery);
            checkDelete = addId(allStudents);
            studentListResult = updatePagedResults(allStudents, true);
            pages = generatePageNumbers(totalPages, currentPage);

        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Search Student failed: ' + ex.getMessage()));
            throw new VisualforceException(ex.getMessage());
        }
    }

    /**
	* updatePagedResults
	* Update the pagination after searching
	* @param Boolean
	* @return void
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    private List<Student__c> updatePagedResults(List<Student__c> students, Boolean reset) {
        List<Student__c> studentListResult = new List<Student__c>();
        // if no Student__c found
        if (students.size() <= 0) {
            totalRecords = 0;
            totalPages = 0; 
            currentPage = 0;
            pages.clear();
        }
        totalRecords = students.size();
        totalPages = (totalRecords + pageSize - 1) / pageSize; // 54:5 = 10.8 (11)
        // if click Search => go to first page
        if (reset) {
            currentPage = 1;
        }
        Integer startIndex = (currentPage - 1) * pageSize;
        Integer endIndex = Math.min(startIndex + pageSize, totalRecords);
        // calculate the pages after delete student
        if (startIndex >= endIndex && currentPage >= 2) {
            currentPage = totalPages;
            startIndex = (currentPage - 1 ) * pageSize;
            pages = generatePageNumbers(totalPages, currentPage);
        }
        
        for (Integer i = startIndex; i < endIndex; i++) {
            studentListResult.add(students[i]);
        }

        return studentListResult;
    }

    /**
	* generatePageNumbers
	* Generate the list of page after pagination
	* @param none
	* @return void
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    private List<Integer> generatePageNumbers(Integer totalPages, Integer currentPage) {
        List<Integer> pages = new List<Integer>();
        Integer startPage;
        Integer endPage;
    
        if (totalPages <= 5) {
            // If total pages <=5, show all pages
            startPage = 1;
            endPage = totalPages;
        } else if (currentPage <= 3) {
            // currentPage near the beginning
            startPage = 1;
            endPage = 5;
        } else if (currentPage >= totalPages - 2) {
            // currentPage near the end
            startPage = totalPages - 4;
            endPage = totalPages;
        } else {
            // somewhere in the middle
            startPage = currentPage - 2;
            endPage = currentPage + 2;
        }
    
        // add page numbers to the list
        for (Integer i = startPage; i <= endPage; i++) {
            pages.add(i);
        }
        return pages;
    }

    /**
	* deleteStudent
	* Delete a Student__c
	* @param none
	* @return void
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public void deleteStudent() {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new DmlException('Test exception');
            }

            Student__c studentToDelete = new Student__c(Id = recordIdToDelete);
            Integer startIndex = (currentPage - 1) * pageSize;
            Integer endIndex = Math.min(startIndex + pageSize, totalRecords);
            for (Integer i = startIndex; i < endIndex; i++) {
                if (allStudents[i].Id == studentToDelete.Id) {
                    delete studentToDelete;
                    allStudents.remove(allStudents.indexOf(allStudents[i]));
                    studentListResult = updatePagedResults(allStudents, false);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Delete successfully'));
                    break;
                }
            }
            
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Delete failed: ' + ex.getMessage()));
            throw new VisualforceException(ex.getMessage());
        }
    }

    /**
	* deleteSelectedStudent
	* Delete multiple Student__c
	* @param none
	* @return void
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public void deleteSelectedStudent() {
        try {
            List<Student__c> studentsToDelete = new List<Student__c>();
            for (Integer i = 0; i < allStudents.size(); i++) {
                if (checkDelete.get(allStudents[i].Id)) {
                    studentsToDelete.add(allStudents[i]);
                }
            }
            if (!studentsToDelete.isEmpty()) {
                for (Integer i = 0; i < studentsToDelete.size(); i++) {
                    allStudents.remove(allStudents.indexOf(studentsToDelete[i]));
                }
                delete studentsToDelete;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Delete successfully'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please select at least one student to delete'));
            }
            studentListResult = updatePagedResults(allStudents, false);
            pages = generatePageNumbers(totalPages, currentPage);

        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Delete failed: ' + ex.getMessage()));
            throw new VisualforceException(ex.getMessage());
        }
    }

    /**
	* addId
	* Add Student__c Id for delete multiple Student__c
	* @param List<Student__c>
	* @return Map<Id,Boolean>
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public Map<Id,Boolean> addId(List<Student__c> students) {
        Map<Id,Boolean> checkDelete = new Map<Id,Boolean>();
        for (Student__c s : students) {
            checkDelete.put(s.Id, false);
        }
        return checkDelete;
    }

    /**
	* goToPage
	* Go to the specified page of result
	* @param none
	* @return void
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public void goToPage() {
        studentListResult = updatePagedResults(allStudents, false);
        pages = generatePageNumbers(totalPages, currentPage);
    }

    /**
	* getHasNext
	* Go to the next page of result
	* @param none
	* @return Boolean
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public Boolean getHasNext() {
        return currentPage < totalPages;
    }

    /**
	* getHasPrevious
	* Go to the previous page of result
	* @param none
	* @return Boolean
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public Boolean getHasPrevious() {
        return currentPage > 1;
    }

    /**
	* first
	* Go to the first page of result
	* @param none
	* @return void
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public void first() {
        currentPage = 1;
        studentListResult = updatePagedResults(allStudents, false);
        pages = generatePageNumbers(totalPages, currentPage);
    }
    
    /**
	* next
	* Go to the next page of result
	* @param none
	* @return void
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public void next() {
        if (currentPage < totalPages) {
            currentPage++;
            studentListResult = updatePagedResults(allStudents, false);
            pages = generatePageNumbers(totalPages, currentPage);
        }
    }

    /**
	* previous
	* Go to the previous page of result
	* @param none
	* @return void
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public void previous() {
        if (currentPage > 1) {
            currentPage--;
            studentListResult = updatePagedResults(allStudents, false);
            pages = generatePageNumbers(totalPages, currentPage);
        }
    }

    /**
	* last
	* Go to the last page of result
	* @param none
	* @return void
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public void last() {
        currentPage = totalPages;
        studentListResult = updatePagedResults(allStudents, false);
        pages = generatePageNumbers(totalPages, currentPage);
    }

    /**
	* getClassOptions
	* Load the list of Class__c
	* @param none
	* @return List<SelectOption>
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public List<SelectOption> getClassOptions() {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new QueryException('Test exception');
            }
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select class--')); // Default option when the page is loaded
            classList = [SELECT Id, Name FROM Class__c];

            for (Class__c c : classList) {
                options.add(new SelectOption(c.Id, c.Name));
            }

            return options;
        } catch (Exception ex) {
            System.debug('Error at VF_SearchStudentCtrl: ' + ex.getMessage());
            throw new VisualforceException(ex.getMessage());
        }
    }

    /**
	* getLearningStatusOptions
	* Get picklist values of LearningStatus__c
	* @param none
	* @return List<SelectOption>
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public List<SelectOption> getLearningStatusOptions() {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new QueryException('Test exception');
            }

            List<SelectOption> options = new List<SelectOption>(); 
            List<Schema.PicklistEntry> statusOptions = Student__c.LearningStatus__c.getDescribe().getPicklistValues();
            options.add(new SelectOption('', '--Select status--'));
            
            for (Schema.PicklistEntry f : statusOptions) {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            }
            
            return options;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            throw new VisualforceException(ex.getMessage());
        }
    }

    /**
	* getGenderOptions
	* Get picklist values of Gender__c
	* @param none
	* @return List<SelectOption>
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public List<SelectOption> getGenderOptions() {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new QueryException('Test exception');
            }
            
            List<SelectOption> options = new List<SelectOption>(); 
            List<Schema.PicklistEntry> genderOptions = Student__c.Gender__c.getDescribe().getPicklistValues();
            options.add(new SelectOption('', '--Select gender--'));
            
            for (Schema.PicklistEntry f : genderOptions) {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            }
            
            return options;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            throw new VisualforceException(ex.getMessage());
        }
    }

    /**
	* getDateRange
	* Get the range of date
	* @param none
	* @return List<SelectOption>
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public List<SelectOption> getDateRange() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select date--'));
        for (Integer i = 1; i <= 31; i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }

    /**
	* getMonthRange
	* Get the range of month
	* @param none
	* @return List<SelectOption>
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public List<SelectOption> getMonthRange() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select month--'));
        for (Integer i = 1; i <= 12; i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }

    /**
	* getYearRange
	* Get the range of year
	* @param none
	* @return List<SelectOption>
	* @created: 2024/09/15 Huynh Phuoc
	* @modified: 
	*/
    public List<SelectOption> getYearRange() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--Select year--'));
        for (Integer i = Datetime.now().year(); i >= 1999; i--) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        return options;
    }
}