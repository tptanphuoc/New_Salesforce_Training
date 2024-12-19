/**
* クラス名 : T02_ScoreTriggerHandler
* クラス概要 : A trigger handler class to handle all logic of T02_ScoreTrigger trigger.
* @created : 2024/10/18
* @modified :
*/
public without sharing class T02_ScoreTriggerHandler {

    @TestVisible
    private static Boolean isThrownException = false;

    // store the % of each ExamType
    private Map<String, Decimal> scorePercentages = new Map<String, Decimal>{
        'Progress' => 0.1,
        'Practical' => 0.2,
        'Midterm Exam' => 0.2,
        'FinalTerm Exam' => 0.5
    };

    /**
    * handleBeforeInsert
    * Validate scores before inserting them into the DB.
    * @param List<Score__c>
    * @return なし
    * @created : 2024/10/16
    * @modified :
    */
    public void handleBeforeInsert(List<Score__c> newScores) {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new DmlException('Test exception');
            }

            checkDuplicateScore(newScores);
        } catch (Exception ex) {
            throw new DmlException(ex.getMessage());
        }
    }
    
    /**
    * handleAfterInsert
    * Update the subject scores after scores are inserted.
    * @param List<Score__c>
    * @return なし
    * @created : 2024/10/16
    * @modified :
    */
    public void handleAfterInsert(List<Score__c> newScores) {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new DmlException('Test exception');
            }

            updateSubjectScore(newScores);
        } catch (Exception ex) {
            throw new DmlException(ex.getMessage());
        }
    }

    /**
    * handleBeforeUpdate
    * Validate scores before updating them into the DB.
    * @param List<Score__c>
    * @return なし
    * @created : 2024/10/16
    * @modified :
    */
    public void handleBeforeUpdate(List<Score__c> newScores) {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new DmlException('Test exception');
            }

            checkDuplicateScore(newScores);
        } catch (Exception ex) {
            throw new DmlException(ex.getMessage());
        }
    }

    /**
    * handleAfterUpdate
    * Update the subject scores after scores are updated.
    * @param List<Score__c>
    * @return なし
    * @created : 2024/10/16
    * @modified :
    */
    public void handleAfterUpdate(List<Score__c> newScores) {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new DmlException('Test exception');
            }
            
            updateSubjectScore(newScores);
        } catch (Exception ex) {
            throw new DmlException(ex.getMessage());
        }
    }

    /**
    * checkDuplicateScore
    * Check for duplicate scores based on the subject and exam type.
    * @param List<Score__c>
    * @return なし
    * @created : 2024/10/18
    * @modified :
    */
    private void checkDuplicateScore(List<Score__c> newScores) {
        // add all subject score Ids to a Set
        Set<Id> subjectScoreIdSet = new Set<Id>();
        for (Score__c score : newScores) {
            subjectScoreIdSet.add(score.SubjectScore_look__c);
        }
        // get all Score__c in subjectScoreIdSet
        List<Score__c> duplicateScores = [
            SELECT Id
                   , SubjectScore_look__c
                   , ExamType__c
                   , Score__c 
            FROM Score__c 
            WHERE SubjectScore_look__c IN :subjectScoreIdSet
        ];

        // create map to store existing scores
        Map<String, Score__c> existingScoresMap = new Map<String, Score__c>();
        for (Score__c score : duplicateScores) {
            // custom key, ex: a0HIS000001HS232AG:Progress
            String key = score.SubjectScore_look__c + ':' + score.ExamType__c;
            if (!existingScoresMap.containsKey(key)) {
                existingScoresMap.put(key, score);
            }
        }

        // if scores in Trigger.New is duplicate, add error
        for (Score__c newScore : newScores) {
            // custom key, ex: a0HIS000001HS232AG:Progress
            String key = newScore.SubjectScore_look__c + ':' + newScore.ExamType__c;
            if (existingScoresMap.containsKey(key) && existingScoresMap.get(key).Id != newScore.Id) {
                newScore.addError('Duplicate score for this exam type!');
            } else {
                existingScoresMap.put(key, newScore);
            }
        }
    }

    /**
    * updateSubjectScore
    * Update the average score and status for subject scores.
    * @param List<Score__c>
    * @return なし
    * @created : 2024/10/18
    * @modified :
    */
    private void updateSubjectScore(List<Score__c> scoreList) {
        // add all subject score Ids to a Set
        Set<Id> subjectScoreIdSet = new Set<Id>();
        for (Score__c score : scoreList) {
            subjectScoreIdSet.add(score.SubjectScore_look__c);
        }

        // query for all related Score__c records
        List<Score__c> allRelatedScores = [
            SELECT Id
                   , SubjectScore_look__c
                   , ExamType__c
                   , Score__c 
            FROM Score__c 
            WHERE SubjectScore_look__c IN :subjectScoreIdSet
        ];
        // create a map to store all related scores
        Map<Id, List<Score__c>> subjectScoreMap = new Map<Id, List<Score__c>>();
    
        for (Score__c score : allRelatedScores) {
            Id subjectScoreId = score.SubjectScore_look__c;
            if (!subjectScoreMap.containsKey(subjectScoreId)) {
                subjectScoreMap.put(subjectScoreId, new List<Score__c>());
            }
            subjectScoreMap.get(subjectScoreId).add(score);
        }
        // create SubjectScore__c list to update
        List<SubjectScore__c> subjectScoresToUpdate = new List<SubjectScore__c>();

        for (Id subjectScoreId : subjectScoreIdSet) {
            List<Score__c> scores = subjectScoreMap.get(subjectScoreId);
            // if enough 4 scores => calculate the AVG score
            if (scores != null && scores.size() == 4) {
                Decimal avgScore = 0;
                // loop all scores to calculate the AVG score
                for (Score__c score : scores) {
                    String examType = score.ExamType__c;
                    if (scorePercentages.containsKey(examType)) {
                        avgScore += (score.Score__c * scorePercentages.get(examType).setScale(2, RoundingMode.HALF_UP));
                    }
                }
                // add the AVG score to the subjectScoresToUpdate list
                subjectScoresToUpdate.add(new SubjectScore__c(
                    Id = subjectScoreId,
                    AverageScore__c = avgScore,
                    Status__c = avgScore >= 5 ? 'Passed' : 'Not Passed'
                ));
            }
        }
        // update the final SubjectScore__c records
        if (!subjectScoresToUpdate.isEmpty()) {
            update subjectScoresToUpdate;
        }
    }
}