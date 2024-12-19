/**
 * クラス名       :	CMP_DetailStudentCtrl
 * クラス概要     :	A controller class to handle fetching the details of a Student__c record via a Lightning Component
 * @created      : 2024/09/30 Huynh Phuoc
 * @modified 	 :
 */
public with sharing class CMP_DetailStudentCtrl {
    
    /**
     * getStudentDetails
     * Retrieves the details of a Student__c record based on the provided student ID
     * @param studentId   The ID of the student to retrieve details for
     * @return Student__c  The Student__c record with the specified ID, or null if not found
     * @created: 2024/09/30 Huynh Phuoc
     * @modified: 
     */
    @AuraEnabled
    public static Student__c getStudentDetails(String studentId){
        try {
            List<Student__c> studentList = [
                SELECT Id
                       , StudentCode__c
                       , Firstname__c
                       , Lastname__c
                       , Birthday__c
                       , GPAScore__c
                       , TotalCredit__c
                       , Class_look__c
                       , Class_look__r.Name
                       , Gender__c
                       , LearningStatus__c
                FROM Student__c
                WHERE Id = :studentId
            ];

            if (!studentList.isEmpty()) {
                return studentList[0];
            } else {
                throw CustomException.create('Student record not found for the given ID.');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}