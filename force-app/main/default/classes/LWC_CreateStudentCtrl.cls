/**
* クラス名       :	LWC_CreateStudentCtrl
* クラス概要     :	A controller class for handling create Student__c
* @created      : 2024/10/02 Huynh Phuoc
* @modified 	 :
*/
public with sharing class LWC_CreateStudentCtrl {

    @TestVisible
    private static Boolean isThrownException = false;

    /**
    * getAllOptions
    * Retrieves picklist options for Learning Status, Gender, and available Class__c records.
    * @param なし
    * @return Map<String, List<CustomSelectOption>>
    * @created: 2024/10/02 Huynh Phuoc
    * @modified:
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<CustomSelectOption>> getAllOptions() {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new AuraHandledException('Test exception');
            }

            Map<String, List<CustomSelectOption>> allOptions = new Map<String, List<CustomSelectOption>>();
            
            // Get Learning Status options
            allOptions.put('learningStatusOptions', getPicklistOptions(Student__c.LearningStatus__c));
            
            // Get Gender options
            allOptions.put('genderOptions', getPicklistOptions(Student__c.Gender__c));
            
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
    * getPicklistOptions
    * Retrieves picklist options for a given SObject field.
    * @param Schema.SObjectField
    * @return List<CustomSelectOption>
    * @created: 2024/10/02 Huynh Phuoc
    * @modified: 
    */
    private static List<CustomSelectOption> getPicklistOptions(Schema.SObjectField field) {
        List<CustomSelectOption> options = new List<CustomSelectOption>();
        options.add(new CustomSelectOption('', '--None--', false)); // Default option
        for(Schema.PicklistEntry picklist : field.getDescribe().getPicklistValues()) {
            options.add(new CustomSelectOption(picklist.getValue(), picklist.getLabel(), false));
        }
        return options;
    }

    /**
    * createNewStudent
    * Creates a new Student__c record with the provided details.
    * @param Student__c
    * @return なし
    * @created: 2024/10/02 Huynh Phuoc
    * @modified: 
    */
    @AuraEnabled
    public static void createNewStudent(Student__c newStudent){
        try {
            insert newStudent;
        } catch (Exception e) {
            // get the error message from trigger
            String errorMessage = e.getMessage();
            // remove the unnecessary part of the error message
            errorMessage = errorMessage.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ' , ': [');
            throw new AuraHandledException(errorMessage);
        }
    }
}