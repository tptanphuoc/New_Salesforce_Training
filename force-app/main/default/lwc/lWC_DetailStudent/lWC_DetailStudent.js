/**
 * クラス名 ：LWC_DetailStudent
 * クラス概要 ： A Lightning Web Component class for viewing detailed information about a Student__c record.
 * @created : 2024/10/13 Huynh Phuoc
 * @modified :
 */
import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getStudentDetails from '@salesforce/apex/LWC_DetailStudentCtrl.getStudentDetails';
import getSemesterOptions from '@salesforce/apex/LWC_DetailStudentCtrl.getSemesterOptions';
import getSubjectScoreForStudent from '@salesforce/apex/LWC_DetailStudentCtrl.getSubjectScoreForStudent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LWC_DetailStudent extends NavigationMixin(LightningElement) {
    @api studentId; // studentId passed from parent
    @api showModal; // show/hide detail modal
    @track studentDetails = {
        sobjectType: 'Student__c',
    };
    semesterOptions; // list of Semester options
    selectedSemester; // when user change Semester
    @track subjectScores = []; // load score data for a Student

    /**
     * connectedCallback
     * Lifecycle hook that is called when the component is inserted into the DOM.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    connectedCallback() {
        this.getSubjectScore();
        this.getStudentDetails();
        this.getSemesterOptions();
    }

    /**
     * getSemesterOptions
     * Get all available Semester options for selection.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    getSemesterOptions() {
        getSemesterOptions()
            .then(semesterOptions => {
                this.semesterOptions = semesterOptions;
            })
            .catch(error => {
                this.showToastMessage('Error', 'Failed to load semester', 'error');
            });
    }

    /**
     * getSubjectScore
     * Get subject scores for the selected semester and student.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    getSubjectScore() {
        getSubjectScoreForStudent({ studentId: this.studentId, semesterId: this.selectedSemester })
            .then((subjectScores) => {
                this.subjectScores = subjectScores;
            })
            .catch((error) => {
                this.showToastMessage('Info', 'Student do not have any Subject Score', 'info');
            });
    }

    /**
     * getStudentDetails
     * Get the details of the student with the given studentId.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    getStudentDetails() {
        getStudentDetails({ studentId: this.studentId })
            .then((studentDetails) => {
                this.studentDetails = studentDetails;
            })
            .catch((error) => {
                this.showToastMessage('Error', 'Failed to load Student', 'error');
            });
    }

    /**
     * handleSemesterChange
     * When the user select a different semester, updates the selectedSemester and reloads the subject scores.
     * @param : event
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    handleSemesterChange(event) {
        this.selectedSemester = event.detail.selectedSemester;
        this.getSubjectScore();
    }

    /**
     * closeDetailModal
     * Fire a custom event to close the Student Detail modal.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    closeDetailModal() {
        this.dispatchEvent(new CustomEvent("closedetailmodal", {
            detail: {
                modalName: "detailStudentModal",
            }
        }));
    }

    /**
     * showToastMessage
     * Shows a toast message to the user to indicate success or failure.
     * @param : title, message, variant
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    showToastMessage(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            duration: 2000,
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }

    /**
     * navigateToClassDetail
     * Uses the NavigationMixin to navigate to the Class__c detail page.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    navigateToClassDetail() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.studentDetails.Class_look__c,
                objectApiName: 'Class__c',
                actionName: 'view'
            }
        });
    }
}