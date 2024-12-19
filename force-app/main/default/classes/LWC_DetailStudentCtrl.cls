/**
* クラス名 : LWC_DetailStudentCtrl
* クラス概要 : A controller class for handling Student__c object details and GPA.
* @created : 2024/10/02 Huynh Phuoc
* @modified :
*/
public with sharing class LWC_DetailStudentCtrl {

    @TestVisible
    private static Boolean isThrownException = false;

    /**
    * クラス名 : SubjectScoreWrapper
    * クラス概要 : A wrapper class to hold SubjectScore__c and related Score__c records.
    * @created : 2024/10/02 Huynh Phuoc
    * @modified :
    */
    public class SubjectScoreWrapper {
        @AuraEnabled
        public SubjectScore__c subjectScore;
        
        @AuraEnabled
        public List<Score__c> scores;
    
        // Constructor
        public SubjectScoreWrapper(SubjectScore__c subjectScore, List<Score__c> scores) {
            this.subjectScore = subjectScore;
            this.scores = scores;
        }
    }

    /**
    * getStudentDetails
    * Retrieves the details of a Student__c record based on the provided student ID.
    * @param String
    * @return Student__c
    * @created: 2024/10/02 Huynh Phuoc
    * @modified: 
    */
    @AuraEnabled
    public static Student__c getStudentDetails(String studentId){
        try {
            if (Test.isRunningTest() && isThrownException) {
                throw new AuraHandledException('Test exception');
            }
            
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

            return studentList.isEmpty() ? null : studentList[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * getSemesterOptions
    * Retrieves a list of Semester__c records as CustomSelectOption.
    * @param なし
    * @return List<CustomSelectOption>
    * @created: 2024/10/02 Huynh Phuoc
    * @modified:
    */
    @AuraEnabled(cacheable=true)
    public static List<CustomSelectOption> getSemesterOptions() {
        List<Semester__c> semesterList = [SELECT Id, Name FROM Semester__c ORDER BY EndDate__c DESC];
        List<CustomSelectOption> options = new List<CustomSelectOption>();
        options.add(new CustomSelectOption('', '--All--', false)); // Default option
        for (Semester__c sem : semesterList) {
            options.add(new CustomSelectOption(sem.Id, sem.Name, false));
        }
        return options;
    }

    /**
    * getSubjectScoreForStudent
    * Retrieves SubjectScore__c and related Score__c records for a given student and semester.
    * @param String, String
    * @return List<SubjectScoreWrapper>
    * @created: 2024/10/02 Huynh Phuoc
    * @modified:
    */
    @AuraEnabled
    public static List<SubjectScoreWrapper> getSubjectScoreForStudent(String studentId, String semesterId) {
        try {
            if (Test.isRunningTest() && isThrownException) {
                throw new AuraHandledException('Test exception');
            }
        
            List<SubjectScoreWrapper> subjectScoreWrapperList = new List<SubjectScoreWrapper>();
            List<SubjectScore__c> subjectScores = new List<SubjectScore__c>();
            List<Score__c> scores = new List<Score__c>();

            // baseQuery for SubjectScore records
            String baseQuery = 'SELECT Id' +
                                ', Subject_look__r.SubjectCode__c' +
                                ', Subject_look__r.Name' +
                                ', Subject_look__r.CourseCredit__c' +
                                ', Semester_look__r.Name' +
                                ', AverageScore__c' +
                                ', Status__c' +
                                ' FROM SubjectScore__c';

            List<String> conditions = new List<String>();

            if (String.isNotBlank(studentId)) {
                conditions.add('Student_look__c = :studentId');
            }

            if (String.isNotBlank(semesterId)) {
                conditions.add('Semester_look__c = :semesterId');
            }

            if (!conditions.isEmpty()) {
                baseQuery += ' WHERE ' + String.join(conditions, ' AND ');
            }

            baseQuery += ' ORDER BY Semester_look__r.EndDate__c DESC';

            // get all SubjectScore__c records
            subjectScores = Database.query(baseQuery);
            
            // collect Ids of subjectScores for second query
            List<Id> subjectScoreIds = new List<Id>();
            for (SubjectScore__c subjectScore : subjectScores) {
                subjectScoreIds.add(subjectScore.Id);
            }

            // get related Score__c based on SubjectScore__c IDs
            if (!subjectScoreIds.isEmpty()) {
                scores = [
                    SELECT Id
                        , Name
                        , ExamType__c
                        , Score__c
                        , SubjectScore_look__c
                    FROM Score__c
                    WHERE SubjectScore_look__c 
                    IN :subjectScoreIds
                ];
            } 

            // Create a map to relate Score__c records to their corresponding SubjectScore__c
            Map<Id, List<Score__c>> subjectScoreToScoresMap = new Map<Id, List<Score__c>>();

            for (Score__c score : scores) {
                if (!subjectScoreToScoresMap.containsKey(score.SubjectScore_look__c)) {
                    subjectScoreToScoresMap.put(score.SubjectScore_look__c, new List<Score__c>());
                }
                subjectScoreToScoresMap.get(score.SubjectScore_look__c).add(score);
            }

            // map the result to the wrapper class to return
            for (SubjectScore__c subjectScore : subjectScores) {
                List<Score__c> relatedScores = subjectScoreToScoresMap.get(subjectScore.Id);
                subjectScoreWrapperList.add(new SubjectScoreWrapper(subjectScore, relatedScores != null ? relatedScores : new List<Score__c>()));
            }

            return subjectScoreWrapperList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String generateScoreTablePDF() {
        try {
            if (Test.isRunningTest() && isThrownException) {
                throw new AuraHandledException('Test exception');
            }

            PageReference pageRef = Page.VF_DetailStudentPDFRender;
            return pageRef.getUrl();

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}