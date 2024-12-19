/**
 * クラス名 ：LWC_SearchConditionStudent
 * クラス概要 ： A LWC class for managing student search filter.
 * @created : 2024/10/13 Huynh Phuoc
 * @modified :
 */
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllOptions from '@salesforce/apex/LWC_SearchStudentCtrl.getAllOptions';
// LMS
import FILTER_MESSAGECHANNEL from '@salesforce/messageChannel/StudentFilter__c';
import TOGGLE_MODAL_MESSAGECHANNEL from '@salesforce/messageChannel/ToggleModal__c';
import TOGGLE_DELETE_BUTTON_MESSAGECHANNEL from '@salesforce/messageChannel/ToggleDeleteButton__c';
import { publish, MessageContext, subscribe } from 'lightning/messageService';

export default class LWC_SearchConditionStudent extends LightningElement {
    // inputs object to search
    @track searchCriterias = {
        searchStudentCode: '',
        searchName: '',
        selectedClass: '',
        selectedGender: '',
        searchBirthday: null,
        selectedDay: '',
        selectedMonth: '',
        selectedYear: '',
    };

    // use the LMS
    @wire(MessageContext)
    theMessageContext;

    // all options to search
    @track classOptions = [];
    @track genderOptions = [];
    @track dayOptions = [];
    @track monthOptions = [];
    @track yearOptions = [];

    /**
     * connectedCallback
     * Lifecycle hook that is called when the component is inserted into the DOM.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    connectedCallback() {
        this.getAllOptions();
        this.initializeDateOptions();
        subscribe(this.theMessageContext, TOGGLE_DELETE_BUTTON_MESSAGECHANNEL, (message) => this.toggleDeleteButton(message));
    }

    /**
     * handleInputChange
     * Updates search criteria when a user changes the input values.
     * @param : event
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    handleInputChange(event) {
        this.searchCriterias[event.target.name] = event.target.value;
        let isAnyFieldFilled = Object.values(this.searchCriterias).some(value => value !== '' && value !== null);
        this.template.querySelector(".resetBtn").disabled = !isAnyFieldFilled;
    }

    /**
     * sendFiltersToSearch
     * Publishes the search criteria to other components using LMS.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    sendFiltersToSearch() {
        publish(this.theMessageContext, FILTER_MESSAGECHANNEL, {
            filters: this.searchCriterias
        });
    }

    /**
     * toggleCreateModal
     * Publishes a message to open the "Create Student" modal.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    toggleCreateModal() {
        publish(this.theMessageContext, TOGGLE_MODAL_MESSAGECHANNEL, {
            modalName: "createStudentModal",
            isOpen: true
        });
    }

    /**
     * toggleDeleteButton
     * Enable/disable delete button based on the message received from the LMS.
     * @param : message
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    toggleDeleteButton(message) {
        this.template.querySelector(".deleteBtn").disabled = message.isDisable;
    }

    /**
     * toggleDeleteModal
     * Publishes a message to open the "Delete Student" modal.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    toggleDeleteModal() {
        publish(this.theMessageContext, TOGGLE_MODAL_MESSAGECHANNEL, {
            modalName: "deleteStudentModal",
            isOpen: true
        });
    }

    /**
     * clearFilterInputs
     * Clears all the search inputs and disable Reset button if no field are filled.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    clearFilterInputs() {
        this.searchCriterias = {
            searchStudentCode: '',
            searchName: '',
            selectedClass: '',
            selectedGender: '',
            searchBirthday: null,
            selectedDay: '',
            selectedMonth: '',
            selectedYear: '',
        };
        // if all inputs are blank => disable Reset button
        let isAnyFieldFilled = Object.values(this.searchCriterias).some(value => value !== '' && value !== null);
        this.template.querySelector(".resetBtn").disabled = !isAnyFieldFilled;
    }

    /**
     * getAllOptions
     * Get all picklist options when the page load.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    getAllOptions() {
        getAllOptions()
            .then((allOptions) => {
                this.classOptions = allOptions.classOptions;
                this.genderOptions = this.formatPicklistOptions(allOptions.genderOptions);
            })
            .catch((error) => {
                this.showToastMessage('Error', 'Failed to load options', 'error');
            });
    }

    /**
     * formatPicklistOptions
     * Format the picklist options label.
     * @param : options
     * @return : options
     * @created: 2024/10/13 Huynh Phuoc
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
     * @created: 2024/10/13 Huynh Phuoc
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
     * initializeDateOptions
     * Generate day, month, and year options for filter inputs.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    initializeDateOptions() {
        // Generate Day Options (1 to 31)
        this.dayOptions = [{ label: '--None--', value: '' }];
        for (let i = 1; i <= 31; i++) {
            this.dayOptions.push({ label: i.toString(), value: i.toString() });
        }

        // Generate Month Options (1 to 12)
        this.monthOptions = [{ label: '--None--', value: '' }];
        for (let i = 1; i <= 12; i++) {
            this.monthOptions.push({ label: i.toString(), value: i.toString() });
        }

        // Generate Year Options (1900 to Current Year)
        this.yearOptions = [{ label: '--None--', value: '' }];
        for (let i = new Date().getFullYear(); i >= 1990; i--) {
            this.yearOptions.push({ label: i.toString(), value: i.toString() });
        }
    }

    /**
     * showToastMessage
     * Displays a toast message to user.
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
}