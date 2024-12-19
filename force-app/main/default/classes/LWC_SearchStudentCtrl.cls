/**
* クラス名 : LWC_SearchStudentCtrl
* クラス概要 : A controller class for handling Student__c object search operations.
* @created : 2024/09/30 Huynh Phuoc
* @modified :
*/
public with sharing class LWC_SearchStudentCtrl {

    @TestVisible
    private static Boolean isThrownException = false;
    
    /**
    * クラス名 : SearchCriterias
    * クラス概要 : A helper inner class to encapsulate search criteria for querying Student__c records.
    * @created : 2024/09/30 Huynh Phuoc
    * @modified :
    */
    public class SearchCriterias {
        
        // The student code to search
        @AuraEnabled
        public String searchStudentCode {get;set;}
        
        // The first or last name to search
        @AuraEnabled
        public String searchName {get;set;}
        
        // The Class__c ID selected
        @AuraEnabled
        public String selectedClass {get;set;}
        
        // The gender selected
        @AuraEnabled
        public String selectedGender {get;set;}
        
        // The exact birthday
        @AuraEnabled
        public Date searchBirthday {get;set;}
        
        // The day part of the birthday
        @AuraEnabled
        public String selectedDay {get;set;}
        
        // The month part of the birthday 
        @AuraEnabled
        public String selectedMonth {get;set;}
        
        // The year part of the birthday
        @AuraEnabled
        public String selectedYear {get;set;}
    }

    /**
    * getAllOptions
    * Retrieves picklist options for Learning Status, Gender, and available Class__c records.
    * @param なし
    * @return Map<String, List<CustomSelectOption>>
    * @created: 2024/09/30 Huynh Phuoc
    * @modified: 
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<CustomSelectOption>> getAllOptions() {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new AuraHandledException('Test exception');
            }
            
            Map<String, List<CustomSelectOption>> allOptions = new Map<String, List<CustomSelectOption>>();

            // Get Gender options
            List<CustomSelectOption> genderOptions = new List<CustomSelectOption>();
            genderOptions.add(new CustomSelectOption('', '--None--', false)); // Default option
            for(Schema.PicklistEntry picklist : Student__c.Gender__c.getDescribe().getPicklistValues()) {
                genderOptions.add(new CustomSelectOption(picklist.getValue(), picklist.getLabel(), false));
            }

            allOptions.put('genderOptions', genderOptions);

            // Get Class options
            List<Class__c> classList = [SELECT Id, Name FROM Class__c];
            List<CustomSelectOption> classOptions = new List<CustomSelectOption>();
            classOptions.add(new CustomSelectOption('', '--None--', false)); // Default option
            for (Class__c aClass : classList) {
                classOptions.add(new CustomSelectOption(aClass.Id, aClass.Name, false));
            }

            allOptions.put('classOptions', classOptions);
            
            return allOptions;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * getCustomSettings
    * Retrieves Salesforce's Custom Settings for page size and maximum records.
    * @param なし
    * @return Map<String, Integer>
    * @created: 2024/09/30 Huynh Phuoc
    * @modified: 
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getCustomSettings() {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new AuraHandledException('Test exception');
            }

            Map<String, Integer> settingsMap = new Map<String, Integer>();
            StudentMeanageSetting__c settings = StudentMeanageSetting__c.getOrgDefaults();
            
            // Check if the custom setting exists
            if (settings != null && String.isNotBlank(settings.Id)) {
                Integer pageSize = settings.S_RecordPerPage__c != null && settings.S_RecordPerPage__c > 0 ? (Integer)settings.S_RecordPerPage__c : 5;
                Integer maxRecords = settings.S_MaxRecord__c != null && settings.S_MaxRecord__c > 0 ? (Integer)settings.S_MaxRecord__c : 2000;
                settingsMap.put('pageSize', pageSize);
                settingsMap.put('maxRecords', maxRecords);
            } else {
                settingsMap.put('pageSize', 5);
                settingsMap.put('maxRecords', 2000);
            }

            return settingsMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * searchStudents
    * Retrieves a list of Student__c records based on the provided search criteria.
    * @param SearchCriterias
    * @return List<Student__c>
    * @created: 2024/09/30 Huynh Phuoc
    * @modified:
    */
    @AuraEnabled
    public static List<Student__c> searchStudents(SearchCriterias searchCriterias) {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new AuraHandledException('Test exception');
            }

            Integer maxRecords = getCustomSettings().get('maxRecords');
            List<String> conditions = new List<String>();
            List<Student__c> allStudents = new List<Student__c>();
            String baseQuery = 
                'SELECT Id' +
                ', Birthday__c' +
                ', Class_look__c' +
                ', Class_look__r.Name' +
                ', Firstname__c' +
                ', Gender__c' +
                ', GPAScore__c' +
                ', Lastname__c' +
                ', LearningStatus__c' +
                ', StudentCode__c ' +
                'FROM Student__c';

            // Add search filters
            if (String.isNotBlank(searchCriterias.searchStudentCode)) {
                String studentCodeCondition = 'StudentCode__c LIKE \'%' + String.escapeSingleQuotes(searchCriterias.searchStudentCode.trim()) + '%\'';
                conditions.add(studentCodeCondition);
            }

            if (String.isNotBlank(searchCriterias.searchName)) {
                String nameCondition = 
                    '(Firstname__c LIKE \'%' + String.escapeSingleQuotes(searchCriterias.searchName.trim()) + '%\' ' +
                    'OR Lastname__c LIKE \'%' + String.escapeSingleQuotes(searchCriterias.searchName.trim()) + '%\')';
                conditions.add(nameCondition);
            }

            if (String.isNotBlank(searchCriterias.selectedClass)) {
                String searchClass = String.escapeSingleQuotes(searchCriterias.selectedClass);
                conditions.add('Class_look__c = :searchClass');
            }
            
            if (String.isNotBlank(searchCriterias.selectedGender)) {
                String searchGender = String.escapeSingleQuotes(searchCriterias.selectedGender);
                conditions.add('Gender__c = :searchGender');
            }

            // Add date-related conditions
            if (searchCriterias.searchBirthday != null) {
                Date birthday = Date.valueOf(searchCriterias.searchBirthday);
                conditions.add('Birthday__c = :birthday');
            } else {
                if (String.isNotBlank(searchCriterias.selectedDay)) {
                    Integer selectedDay = Integer.valueOf(searchCriterias.selectedDay);
                    conditions.add('DAY_IN_MONTH(Birthday__c) = :selectedDay');
                }
                if (String.isNotBlank(searchCriterias.selectedMonth)) {
                    Integer selectedMonth = Integer.valueOf(searchCriterias.selectedMonth);
                    conditions.add('CALENDAR_MONTH(Birthday__c) = :selectedMonth');
                }
                if (String.isNotBlank(searchCriterias.selectedYear)) {
                    Integer selectedYear = Integer.valueOf(searchCriterias.selectedYear);
                    conditions.add('CALENDAR_YEAR(Birthday__c) = :selectedYear');
                }
            }

            // Append WHERE clause if conditions exist
            if (!conditions.isEmpty()) {
                baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
            }

            // Add ORDER BY clause
            baseQuery += ' ORDER BY Lastname__c, Firstname__c LIMIT :maxRecords';
            allStudents = Database.query(baseQuery);

            return allStudents;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * deleteOneStudent
    * Deletes a single Student__c record based on the provided student ID.
    * @param String
    * @return なし
    * @created: 2024/09/30 Huynh Phuoc
    * @modified: 
    */
    @AuraEnabled
    public static void deleteOneStudent(String studentId) {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new AuraHandledException('Test exception');
            }

            Student__c studentToDelete = new Student__c(Id = studentId);
            delete studentToDelete;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * deleteSelectedStudents
    * Deletes multiple Student__c records based on the provided list of student IDs.
    * @param String[]
    * @return なし
    * @created: 2024/09/30 Huynh Phuoc
    * @modified: 
    */
    @AuraEnabled
    public static void deleteSelectedStudents(String[] studentList) {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new AuraHandledException('Test exception');
            }

            List<Student__c> studentsToDelete = new List<Student__c>();
            // check if the studentList is not empty
            if (studentList != null && studentList.size() > 0) {
                for (String studentId : studentList) {
                    studentsToDelete.add(new Student__c(Id = studentId));
                }
            }
            
            delete studentsToDelete;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}