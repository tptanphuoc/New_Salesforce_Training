/**
* クラス名 : T01_StudentTriggerHandler
* クラス概要 : A trigger handler class to handle all logic of T01_StudentTrigger trigger.
* @created : 2024/10/16 Huynh Phuoc
* @modified :
*/
public without sharing class T01_StudentTriggerHandler {

    @TestVisible
    private static Boolean isThrownException = false;

    /**
    * handleBeforeInsert
    * Validate students before insert them to DB. 
    * @param List<Student__c>
    * @return なし
    * @created: 2024/10/16 Huynh Phuoc
    * @modified:
    */
    public void handleBeforeInsert(List<Student__c> newStudents) {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new DmlException('Test exception');
            }

            for (Student__c student : newStudents) {
                // if all fields are not blank => check birthday
                if (isAllFieldNotBlank(student)) {
                    isValidBirthday(student);
                }
            }
        } catch (Exception ex) {
            throw new DmlException(ex.getMessage());
        }
    }

    /**
    * handleAfterInsert
    * Update student count of Class__c after a student inserted to DB.
    * @param List<Student__c>
    * @return なし
    * @created: 2024/10/16 Huynh Phuoc
    * @modified:
    */
    public void handleAfterInsert(List<Student__c> newStudents) {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new DmlException('Test exception');
            }

            updateClassStudentCount(newStudents);
        } catch (Exception ex) {
            throw new DmlException(ex.getMessage());
        }
    }

    /**
    * handleBeforeUpdate
    * Validate student records before update to DB.
    * @param List<Student__c>
    * @return なし
    * @created: 2024/10/16 Huynh Phuoc
    * @modified:
    */
    public void handleBeforeUpdate(List<Student__c> newStudents) {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new DmlException('Test exception');
            }
            
            for (Student__c student : newStudents) {
                // if all fields are not blank => check birthday
                if (isAllFieldNotBlank(student)) {
                    isValidBirthday(student);
                }
            }
        } catch (Exception ex) {
            throw new DmlException(ex.getMessage());
        }
    }

    /**
    * handleAfterUpdate
    * Update student count of Class__c after a student is updated.
    * @param List<Student__c>, List<Student__c>
    * @return なし
    * @created: 2024/10/16 Huynh Phuoc
    * @modified:
    */
    public void handleAfterUpdate(List<Student__c> newStudents, List<Student__c> oldStudents) {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new DmlException('Test exception');
            }
            // merge new and old students and update once
            List<Student__c> allStudents = new List<Student__c>();
            allStudents.addAll(newStudents);
            allStudents.addAll(oldStudents);

            updateClassStudentCount(allStudents);
        } catch (Exception ex) {
            throw new DmlException(ex.getMessage());
        }
    }

    /**
    * handleBeforeDelete
    * Handle delete all SubjectScore__c and all Score__c before delete a student.
    * @param List<Student__c>
    * @return なし
    * @created: 2024/10/16 Huynh Phuoc
    * @modified:
    */
    public void handleBeforeDelete(List<Student__c> oldStudents) {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new DmlException('Test exception');
            }

            // add all Student Id to Set
            Set<Id> studentIds = new Set<Id>();
            for (Student__c student : oldStudents) {
                studentIds.add(student.Id);
            }
            
            // get all SubjectScore__c of that Student
            if (!studentIds.isEmpty()) {
                List<SubjectScore__c> subjectScoresToDelete = [
                    SELECT Id
                    FROM SubjectScore__c
                    WHERE Student_look__c IN :studentIds
                ];
                
                if (!subjectScoresToDelete.isEmpty()) {
                    delete subjectScoresToDelete;
                }
            }
        } catch (Exception ex) {
            throw new DmlException(ex.getMessage());
        }
    }

    /**
    * handleAfterDelete
    * Update student count of Class__c after a student is deleted.
    * @param List<Student__c>
    * @return なし
    * @created: 2024/10/16 Huynh Phuoc
    * @modified:
    */
    public void handleAfterDelete(List<Student__c> oldStudents) {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new DmlException('Test exception');
            }

            updateClassStudentCount(oldStudents);
        } catch (Exception ex) {
            throw new DmlException(ex.getMessage());
        }
    }

    /**
    * isValidBirthday
    * Check if student's birthday is > 18 years old => valid
    * @param Student__c
    * @return なし
    * @created: 2024/10/16 Huynh Phuoc
    * @modified:
    */
    private void isValidBirthday(Student__c student) {
        Date currentDate = Date.today();
        Date eighteenYearsAgo = currentDate.addYears(-18).addDays(-1);

        if (student.Birthday__c > eighteenYearsAgo) {
            student.addError('Student must be over 18 years old.');
        }
    }

    /**
    * isAllFieldNotBlank
    * Check if all fields of Student are filled before insert/update to DB.
    * @param Student__c
    * @return Boolean
    * @created: 2024/10/16 Huynh Phuoc
    * @modified:
    */
    private Boolean isAllFieldNotBlank(Student__c student) {
        List<String> blankFields = new List<String>();

        if (String.isBlank(student.FirstName__c)) {
            blankFields.add('FirstName__c');
        }
        if (String.isBlank(student.LastName__c)) {
            blankFields.add('LastName__c');
        }
        if (student.Birthday__c == null) {
            blankFields.add('Birthday__c');
        }
        if (String.isBlank(student.Class_look__c)) {
            blankFields.add('Class_look__c');
        }
        if (String.isBlank(student.Gender__c)) {
            blankFields.add('Gender__c');
        }
        
        if (!blankFields.isEmpty()) {
            String errorMessage = 'Please enter value for: {0}';
            String formattedErrorMessage = String.format(errorMessage, new List<String>{ String.join(blankFields, ', ') });
            student.addError(formattedErrorMessage);
            return false;
        } else {
            return true;
        }
    }

    /**
    * updateClassStudentCount
    * Update student count of class (update the NumberOfStudent__c field in Class__c).
    * @param List<Student__c>
    * @return なし
    * @created: 2024/10/16 Huynh Phuoc
    * @modified:
    */
    private void updateClassStudentCount(List<Student__c> students) {
        // Collect Class IDs from students
        Set<Id> classIds = new Set<Id>();
        for (Student__c student : students) {
            classIds.add(student.Class_look__c);
        }
        
        // get classes
        List<Class__c> classesToUpdate = [
            SELECT Id, NumberOfStudent__c
            FROM Class__c
            WHERE Id IN :classIds
        ];
        
        // map to store class ID and totalStudent
        Map<Id, Integer> classStudentCountMap = new Map<Id, Integer>();
        
        // get all enrolled students in the classes
        List<Student__c> enrolledStudents = [
            SELECT Id, Class_look__c
            FROM Student__c
            WHERE Class_look__c IN :classIds
            AND LearningStatus__c = 'Enrolled'
        ];
        
        // count total student in each class
        for (Student__c student : enrolledStudents) {
            if (classStudentCountMap.containsKey(student.Class_look__c)) {
                classStudentCountMap.put(student.Class_look__c, classStudentCountMap.get(student.Class_look__c) + 1);
            } else {
                classStudentCountMap.put(student.Class_look__c, 1);
            }
        }
        
        // update the NumberOfStudent__c field in Class__c
        if (!classesToUpdate.isEmpty()) {
            for (Class__c classToUpdate : classesToUpdate) {
                // if there are enrolled students, use the count, otherwise set to 0
                classToUpdate.NumberOfStudent__c = classStudentCountMap.containsKey(classToUpdate.Id) 
                    ? classStudentCountMap.get(classToUpdate.Id) : 0;
            }
            update classesToUpdate;
        }
    }
}