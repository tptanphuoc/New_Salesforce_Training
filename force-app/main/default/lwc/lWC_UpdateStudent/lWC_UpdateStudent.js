/**
 * クラス名 ：LWC_UpdateStudent
 * クラス概要 ： A LWC class for updating Student__c records.
 * @created : 2024/10/13 Huynh Phuoc
 * @modified :
 */
import { api, LightningElement, track } from 'lwc';
import getAllOptions from '@salesforce/apex/LWC_UpdateStudentCtrl.getAllOptions';
import getExistingStudent from '@salesforce/apex/LWC_UpdateStudentCtrl.getExistingStudent';
import updateExistingStudent from '@salesforce/apex/LWC_UpdateStudentCtrl.updateExistingStudent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LWC_UpdateStudent extends LightningElement {
    @api studentId = '';
    @track existingStudent = {
        sobjectType: 'Student__c',
        Firstname__c: '',
        Lastname__c: '',
        Birthday__c: null,
        Class_look__c: '',
        Gender__c: '',
        LearningStatus__c: ''
    };
    @track classOptions = [];
    @track genderOptions = [];
    @track learningStatusOptions = [];

    /**
     * connectedCallback
     * Lifecycle hook that is called when the component is inserted into the DOM.
     * @param : なし
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    connectedCallback() {
        this.getAllOptions();
        this.getExistingStudent();
    }

    /**
     * handleInputChange
     * Update the existing student data when user change input fields.
     * @param : event
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    handleInputChange(event) {
        this.existingStudent[event.target.name] = event.target.value;
    }

    /**
     * closeUpdateModal
     * Closes the update modal.
     * @param : なし
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    closeUpdateModal() {
        this.dispatchEvent(new CustomEvent("closeupdatemodal", {
            detail: {
                modalName: "updateStudentModal",
            }
        }));
    }

    /**
     * getAllOptions
     * Get all picklist options.
     * @param : なし
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    getAllOptions() {
        getAllOptions()
            .then((allOptions) => {
                this.learningStatusOptions = this.formatPicklistOptions(allOptions.learningStatusOptions);
                this.genderOptions = this.formatPicklistOptions(allOptions.genderOptions);
                this.classOptions = allOptions.classOptions;
            })
            .catch((error) => {
                this.showToastMessage('Error', 'Failed to load options', 'error');
            });
    }

    /**
     * getExistingStudent
     * Get details of the student based on studentId.
     * @param : なし
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    getExistingStudent() {
        getExistingStudent({ studentId: this.studentId })
            .then((existingStudent) => {
                this.existingStudent = existingStudent;
            })
            .catch((error) => {
                this.showToastMessage('Error', 'Failed to load Student', 'error');
            });
    }

    /**
     * handleUpdateStudent
     * Calls Apex controller to update student.
     * @param : event
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    handleUpdateStudent(event) {
        event.preventDefault();
        updateExistingStudent({ student: this.existingStudent })
            .then(() => {
                this.closeUpdateModal();
                this.showToastMessage('Success', 'Update Student successfully', 'success');
                this.dispatchEvent(new CustomEvent("updatesuccess"));
            })
            .catch((error) => {
                this.showToastMessage('Error', error.body.message, 'error');
            });
    }

    /**
     * formatPicklistOptions
     * Format picklist options (label-value).
     * @param : options
     * @return : options
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    formatPicklistOptions(options) {
        return options.map(option => ({
            label: this.translatePicklistValue(option.label),
            value: option.value,
            disabled: option.disabled
        }));
    }

    /**
     * translatePicklistValue
     * Translate picklist values (label) from Japanese to English.
     * @param : label
     * @return : translations
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    translatePicklistValue(label) {
        const translations = {
            // LearningStatus__c
            '在学中': '在学中 (Enrolled)',
            '退学': '退学 (Withdrawn)',
            '卒業済み': '卒業済み (Graduated)',
            // Gender__c
            '男性': '男性 (Male)',
            '女性': '女性 (Female)'
        };
        return translations[label] || label;
    }

    /**
     * showToastMessage
     * Displays a toast message to notify user.
     * @param : title, message, variant
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
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
}