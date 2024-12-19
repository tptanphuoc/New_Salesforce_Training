/**
 * クラス名 ：LWC_ScoreTable
 * クラス概要 ： A LWC class for displaying the Student subject scores.
 * @created : 2024/10/13 Huynh Phuoc
 * @modified :
 */
import { api, LightningElement, track } from 'lwc';
import generateScoreTablePDF from '@salesforce/apex/LWC_DetailStudentCtrl.generateScoreTablePDF';

const COLUMNS = [
    { label: 'Subject Code' },
    { label: 'Subject Name' },
    { label: 'Credits' },
    { label: 'Progressive Score' },
    { label: 'Practical Score' },
    { label: 'Mid-term Score' },
    { label: 'Final-term Score' },
    { label: 'Subject AVG Score' }
];

export default class LWC_ScoreTable extends LightningElement {
    @api semesterOptions = []; // Semester options get from parent
    _subjectScores; // storing data to handle
    @api studentDetails;
    selectedSemester = ''; // current selected Semester
    scoreColumns = COLUMNS;
    scoreTableData = []; // storing data to display on UI
    totalSemesterCount = 0; // storing the total Semester for LoadMore button
    hasMoreSemesters; // if has more than 4 semester
    showLoadMore = true; // show/hide LoadMore button
    @track loadedSemesterCount = 4; // keep track of how many semesters are currently loaded

    /**
     * isLoadMore
     * DisplayLoadMore button if totalSemesterCount > 4.
     * @param : なし
     * @return : Boolean
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    get isLoadMore() {
        return this.totalSemesterCount > 1 && this.showLoadMore;
    }

    /**
     * subjectScores (getter)
     * Getter method to get subjectScores data passed from parent.
     * @param : なし
     * @return : _subjectScores
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    @api
    get subjectScores() {
        return this._subjectScores;
    }

    /**
     * subjectScores (setter)
     * Setter method to re-render the subjectScores when data changed.
     * @param : value
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    set subjectScores(value) {
        this._subjectScores = value;
        this.getScoreTableData();
    }

    /**
     * containsSubjectData
     * Show data table if contain any SubjectScore in the selected Semester.
     * @param : なし
     * @return : Boolean
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    get containsSubjectData() {
        return this.subjectScores.length > 0;
    }

    /**
     * handleLoadMore
     * Load more 4 Semester's SubjectScore record when user click LoadMore button.
     * @param : event
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    handleLoadMore() {
        // increase the number of loaded semesters by 4
        this.loadedSemesterCount += 4;
        // load more score data
        this.getScoreTableData();
    }

    /**
     * getScoreTableData
     * Handle the score data passed from parent.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    getScoreTableData() {
        // if subjectScores is empty => return
        if (!this._subjectScores) return;

        const groupedData = this.subjectScores.reduce((acc, scoreEntry) => {
            const score = scoreEntry.subjectScore;
            const semesterName = score.Semester_look__r.Name;
            const subjectCredit = score.Subject_look__r.CourseCredit__c;

            // if Semester does not exist => add it
            if (!acc[semesterName]) {
                acc[semesterName] = {
                    name: semesterName,
                    subjects: [],
                    totalCredit: 0,
                    totalWeightedScore: 0, // total sum of all Final_Score of all Subject
                    averageScore: 0
                };
                this.totalSemesterCount++;
            }

            // create Subject object with initial data
            const subject = {
                code: score.Subject_look__r.SubjectCode__c,
                name: score.Subject_look__r.Name,
                credit: subjectCredit,
                progress: null,
                practical: null,
                midterm: null,
                final: null,
                average: score.AverageScore__c,
                // if average is < 5 => red color
                averageClass: score.AverageScore__c < 5 ? 'slds-text-color_error slds-text-title_bold ' : ''
            };

            // loop through scores array in the new structure
            if (scoreEntry.scores && scoreEntry.scores.length > 0) {
                scoreEntry.scores.forEach(subScore => {
                    switch (subScore.ExamType__c) {
                        case 'Progress':
                            subject.progress = subScore.Score__c;
                            break;
                        case 'Practical':
                            subject.practical = subScore.Score__c;
                            break;
                        case 'Midterm Exam':
                            subject.midterm = subScore.Score__c;
                            break;
                        case 'FinalTerm Exam':
                            subject.final = subScore.Score__c;
                            break;
                    }
                });
            }

            // add Subject_Score data to that semester
            acc[semesterName].subjects.push(subject);

            // calculate the total credits and total score of that Semester
            acc[semesterName].totalCredit += subjectCredit;
            acc[semesterName].totalWeightedScore += score.AverageScore__c * subjectCredit;

            // calculate the AVG score for the semester
            acc[semesterName].averageScore = parseFloat(
                (acc[semesterName].totalWeightedScore / acc[semesterName].totalCredit).toFixed(1)
            );

            return acc;
        }, {});

        // convert object into array
        const allSemesters = Object.values(groupedData);
        // only take the first 4 semesters
        this.scoreTableData = allSemesters.slice(0, this.loadedSemesterCount);
        // set a flag to show/hide the LoadMore button
        this.hasMoreSemesters = allSemesters.length > this.loadedSemesterCount;
        this.showLoadMore = this.hasMoreSemesters;
    }

    /**
     * handleSemesterChange
     * Update the Score data when user change Semester.
     * @param : event
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    handleSemesterChange(event) {
        this.selectedSemester = event.target.value;
        // if user don't choose --All-- Semester option => hide LoadMore button
        this.showLoadMore = this.selectedSemester === "";
        // fire event to close modal
        this.dispatchEvent(new CustomEvent("semesterchange", {
            detail: {
                selectedSemester: this.selectedSemester,
            }
        }));
    }

    /**
     * handleExportPDF
     * Export the Score data to PDF file.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    handleExportPDF() {
        // call the generateScoreTablePDF method, pass the student Id and selected semester
        generateScoreTablePDF()
            .then(result => {
                // get the return url from the result and append the student Id, semester Id
                const url = `${result}?studentId=${this.studentDetails.Id}&semesterId=${this.selectedSemester}`;
                // open the PDF in a new tab
                window.open(url, '_blank');
                
            })
            .catch(error => {
                console.error('Error in exporting PDF', error.message);
            });
    }
}