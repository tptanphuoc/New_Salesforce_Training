/**
 * クラス名 ：LWC_CreateStudent
 * クラス概要 ： A LWC class for creating Student__c records.
 * @created : 2024/10/11 Huynh Phuoc
 * @modified :
 */
import { LightningElement, track } from 'lwc';
import createNewStudent from '@salesforce/apex/LWC_CreateStudentCtrl.createNewStudent';
import getAllOptions from '@salesforce/apex/LWC_CreateStudentCtrl.getAllOptions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LWC_CreateStudent extends LightningElement {
    @track newStudent = {
        sobjectType: 'Student__c',
        Firstname__c: '',
        Lastname__c: '',
        Birthday__c: null,
        Class_look__c: '',
        Gender__c: '',
        LearningStatus__c: ''
    };
    classOptions = [];
    genderOptions = [];
    learningStatusOptions = [];

    /**
     * connectedCallback
     * Lifecycle hook that is called when the component is inserted into the DOM.
     * @param : なし
     * @return : なし
     * @created: 2024/10/11 Huynh Phuoc
     * @modified:
     */
    connectedCallback() {
        this.getAllOptions();
    }

    /**
     * handleInputChange
     * When user change the inputs.
     * @param : event
     * @return : なし
     * @created: 2024/10/11 Huynh Phuoc
     * @modified:
     */
    handleInputChange(event) {
        this.newStudent[event.target.name] = event.target.value;
    }

    /**
     * handleCreateStudent
     * Calls the Apex method 'createNewStudent' to create a new student record.
     * @param : event
     * @return : なし
     * @created: 2024/10/11 Huynh Phuoc
     * @modified:
     */
    handleCreateStudent(event) {
        event.preventDefault();
        createNewStudent({ newStudent: this.newStudent })
            .then(() => {
                // create success => fire event to close modal and reset the list
                this.closeCreateModal();
                this.showToastMessage('Success', 'Student created successfully', 'success');
            })
            .catch((error) => {
                this.showToastMessage('Error', error.body.message, 'error');
            });
    }

    /**
     * closeCreateModal
     * Fire a custom event to close the Create Student modal.
     * @param : なし
     * @return : なし
     * @created: 2024/10/11 Huynh Phuoc
     * @modified:
     */
    closeCreateModal() {
        this.dispatchEvent(new CustomEvent("closecreatemodal", {
            detail: {
                modalName: "createStudentModal",
            }
        }));
    }

    /**
     * getAllOptions
     * Get all picklist options when the page load.
     * @param : なし
     * @return : なし
     * @created: 2024/10/11 Huynh Phuoc
     * @modified:
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
     * formatPicklistOptions
     * Formats the picklist options to match the required label-value format.
     * @param : options
     * @return : options
     * @created: 2024/10/11 Huynh Phuoc
     * @modified:
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
     * Translates picklist labels from Japanese to English.
     * @param : label
     * @return : translations
     * @created: 2024/10/11 Huynh Phuoc
     * @modified:
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
     * Show the popup message to notify user.
     * @param : title, message, variant
     * @return : なし
     * @created: 2024/10/11 Huynh Phuoc
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
}