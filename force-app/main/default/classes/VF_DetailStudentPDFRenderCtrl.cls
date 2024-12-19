/**
 * VF_DetailStudentPDFRenderCtrl
 * VF_DetailStudentPDFRenderのためのコントローラークラス
 * @created: 2024/11/05 Huynh Phuoc
 * @modified: 
 */
public with sharing class VF_DetailStudentPDFRenderCtrl {

    // Student details
    public Student__c student { get; private set; }

    // Map of Semester name to list of SubjectScore
    public Map<String, SemesterWrapper> semesterSubjectScores { get; private set; }

    // Constant for base limit of characters
    private static final Integer BASE_LIMIT = 20;

    /**
	 * VF_DetailStudentPDFRenderCtrl
	 * VF_DetailStudentPDFRenderCtrl クラスのコンストラクター
	 * @param none
     * @return none
     * @created: 2024/11/05 Huynh Phuoc
     * @modified:
     */
    public VF_DetailStudentPDFRenderCtrl() {
        try {
            // get studentId and semesterId from URL
            String studentId = ApexPages.currentPage().getParameters().get('studentId');
            String semesterId = ApexPages.currentPage().getParameters().get('semesterId');

            student = getStudentDetails(studentId);

            // Insert white space to long Student name
            student.Firstname__c = wrapText(student.Firstname__c);
            student.Lastname__c = wrapText(student.Lastname__c);

            // Get all SubjectScore records
            semesterSubjectScores = getSubjectScoreForStudent(studentId, semesterId);
        } catch (Exception ex) {
            throw new CustomException('Student or Subject score not found');
        }
    }

    /**
     * getStudentDetails
     * 学生の詳細情報を取得
     * @param String studentId
     * @return Student__c
     * @created: 2024/11/05 Huynh Phuoc
     * @modified: 
     */
    private Student__c getStudentDetails(String studentId) {
        List<Student__c> students = [
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

        return students.isEmpty() ? null : students.get(0);
    }

    /**
     * getSubjectScoreForStudent
     * 学生の成績情報を取得
     * @param String studentId, String semesterId
     * @return Map<String, List<SubjectScoreWrapper>>
     * @created: 2024/11/05 Huynh Phuoc
     * @modified: 
     */
    private Map<String, SemesterWrapper> getSubjectScoreForStudent(String studentId, String semesterId) {
        Map<String, SemesterWrapper> semesterSubjectScoresMap = new Map<String, SemesterWrapper>();
        List<SubjectScore__c> subjectScores = new List<SubjectScore__c>();

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

        Map<Id, List<Score__c>> subjectScoreToScoresMap = new Map<Id, List<Score__c>>();
        List<Score__c> scores = [
            SELECT Id
                   , Name
                   , ExamType__c
                   , Score__c
                   , SubjectScore_look__c
            FROM Score__c
            WHERE SubjectScore_look__c 
            IN :subjectScores
        ];

        for (Score__c score : scores) {
            if (!subjectScoreToScoresMap.containsKey(score.SubjectScore_look__c)) {
                subjectScoreToScoresMap.put(score.SubjectScore_look__c, new List<Score__c>());
            }
            subjectScoreToScoresMap.get(score.SubjectScore_look__c).add(score);
        }

        for (SubjectScore__c subjectScore : subjectScores) {
            List<Score__c> relatedScores = subjectScoreToScoresMap.get(subjectScore.Id);
            SubjectScoreWrapper wrapper = new SubjectScoreWrapper(subjectScore, relatedScores != null ? relatedScores : new List<Score__c>());
            String semesterName = subjectScore.Semester_look__r.Name;
    
            if (!semesterSubjectScoresMap.containsKey(semesterName)) {
                semesterSubjectScoresMap.put(semesterName, new SemesterWrapper(semesterName));
            }
    
            SemesterWrapper semesterWrapper = semesterSubjectScoresMap.get(semesterName);
            semesterWrapper.subjectScores.add(wrapper);
            Decimal courseCredit = subjectScore.Subject_look__r.CourseCredit__c;
            semesterWrapper.totalCredits += courseCredit;
            semesterWrapper.totalWeightedScore += subjectScore.AverageScore__c * courseCredit;
            semesterWrapper.semesterAVGScore = (semesterWrapper.totalWeightedScore / semesterWrapper.totalCredits).setScale(2);
        }
    
        return semesterSubjectScoresMap;
    }

    /**
     * SemesterWrapper
     * Semester のラッパー クラス。名前、SubjectScore、totalCredits、totalWeightedScore のリストが含まれます。
     * @created: 2024/11/06 Huynh Phuoc
     * @modified:
     */
    public class SemesterWrapper {
        // Semester name
        public String semesterName { get; private set; }

        // List of SubjectScore
        public List<SubjectScoreWrapper> subjectScores { get; private set; }

        // Total credits of the semester
        public Decimal totalCredits { get; private set; }

        // Total weighted score of the semester
        public Decimal totalWeightedScore { get; private set; }

        // Semester average score
        public Decimal semesterAVGScore { get; private set; }

        /**
         * SemesterWrapper
         * SemesterWrapper クラスのコンストラクター
         * @param String semesterName
         * @return none
         * @created: 2024/11/05 Huynh Phuoc
         * @modified: 
         */
        public SemesterWrapper(String semesterName) {
            this.semesterName = semesterName;
            this.subjectScores = new List<SubjectScoreWrapper>();
            this.totalCredits = 0;
            this.totalWeightedScore = 0;
        }
    }

    /**
     * SubjectScoreWrapper
     * SubjectScore のラッパー クラス
     * @created: 2024/11/05 Huynh Phuoc
     * @modified: 
     */
    public class SubjectScoreWrapper {
        // SubjectScore
        public SubjectScore__c subjectScore { get; private set; }

        // Progress score
        public Decimal progress { get; private set; }

        // Practical score
        public Decimal practical { get; private set; }

        // Midterm score
        public Decimal midterm { get; private set; }

        // Final exam score
        public Decimal finalExam { get; private set; }

        /**
         * SubjectScoreWrapper
         * SubjectScoreWrapper クラスのコンストラクター
         * @param SubjectScore__c subjectScore, List<Score__c> scores
         * @return none
         * @created: 2024/11/05 Huynh Phuoc
         * @modified: 
         */
        public SubjectScoreWrapper(SubjectScore__c subjectScore, List<Score__c> scores) {
            subjectScore.Subject_look__r.Name = wrapText(subjectScore.Subject_look__r.Name);
            // Round AverageScore__c to 1 decimal, ex: 8.75 -> 8.8
            subjectScore.AverageScore__c = subjectScore.AverageScore__c.setScale(2, RoundingMode.HALF_UP);
            this.subjectScore = subjectScore;
            
            for (Score__c score : scores) {
                // Round Score__c to 1 decimal, ex: 8.75 -> 8.8
                Decimal roundedScore = score.Score__c != null ? score.Score__c.setScale(2, RoundingMode.HALF_UP) : 0;
                
                switch on score.ExamType__c {
                    when 'Progress' {
                        this.progress = roundedScore;
                    }
                    when 'Practical' {
                        this.practical = roundedScore;
                    }
                    when 'Midterm Exam' {
                        this.midterm = roundedScore;
                    }
                    when 'FinalTerm Exam' {
                        this.finalExam = roundedScore;
                    }
                }
            }
        }
    }

    /**
     * limitCharacters
     * 入力文字列の文字数を制限する
     * @param String word
     * @return Integer
     * @created: 2024/12/03 Huynh Phuoc
     * @modified:
     */
    private static Integer limitCharacters(String word) {
        return Pattern.matches('^[\\p{ASCII}]+$', word) ? BASE_LIMIT : BASE_LIMIT / 2;
    }

    /**
     * wrapText
     * 入力文字列を指定された文字数で折り返す
     * @param String inputText
     * @return String
     * @created: 2024/11/05 Huynh Phuoc
     * @modified: 
     */
    private static String wrapText(String inputText) {
        List<String> wrappedWords = new List<String>();
        String[] words = inputText.trim().split('\\s+');

        for (String word : words) {
            Integer charLimit = limitCharacters(word);

            if (word.length() > charLimit) {
                Integer startIndex = 0;
                while (startIndex < word.length()) {
                    Integer endIndex = Math.min(startIndex + charLimit, word.length());
                    wrappedWords.add(word.substring(startIndex, endIndex));
                    startIndex = endIndex;
                }
            } else {
                wrappedWords.add(word);
            }
        }

        return String.join(wrappedWords, ' ');
    }

    /**
     * CustomException
     * カスタム例外クラス
     * @created: 2024/11/05 Huynh Phuoc
     * @modified: 
     */
    private class CustomException extends Exception {}
}