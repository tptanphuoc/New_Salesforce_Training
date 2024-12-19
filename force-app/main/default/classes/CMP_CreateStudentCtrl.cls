/**
 * クラス名       :	CMP_CreateStudentCtrl
 * クラス概要     :	A controller class to handle the logic for creating Student__c records via an Aura Component
 * @created      :  2024/10/01 Huynh Phuoc
 * @modified     :
 */
public with sharing class CMP_CreateStudentCtrl {
    @TestVisible
    private static Boolean isThrownException = false;

    /**
     * getAllOptions
     * Retrieves picklist options for Learning Status, Gender, and available Class__c records.
     * @param none
     * @return Map<String, List<CustomSelectOption>>   A map containing lists of picklist options for the Student__c record fields
     * @created: 2024/10/01 Huynh Phuoc
     * @modified: 
     */
    @AuraEnabled
    public static Map<String, List<CustomSelectOption>> getAllOptions() {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new AuraHandledException('Test Exception');
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
     * @param field           The SObjectField representing the picklist field
     * @return List<CustomSelectOption>  A list of picklist options
     * @created: 2024/10/01 Huynh Phuoc
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
     * @param newStudent       The Student__c object containing student details
     * @return void
     * @created: 2024/10/01 Huynh Phuoc
     * @modified: 
     */
    @AuraEnabled
    public static void createNewStudent(Student__c newStudent){
        try {
            insert newStudent;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}