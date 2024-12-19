/**
 * クラス名 ：LWC_SearchResultStudent
 * クラス概要 ： A LWC class for search results, pagination, and delete Student.
 * @created : 2024/10/13 Huynh Phuoc
 * @modified :
 */
import { LightningElement, track, wire } from 'lwc';
import getCustomSettings from '@salesforce/apex/LWC_SearchStudentCtrl.getCustomSettings';
import searchStudents from '@salesforce/apex/LWC_SearchStudentCtrl.searchStudents';
import deleteOneStudent from '@salesforce/apex/LWC_SearchStudentCtrl.deleteOneStudent';
import deleteSelectedStudents from '@salesforce/apex/LWC_SearchStudentCtrl.deleteSelectedStudents';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// lightning message service
import FILTER_MESSAGECHANNEL from '@salesforce/messageChannel/StudentFilter__c';
import TOGGLE_MODAL_MESSAGECHANNEL from '@salesforce/messageChannel/ToggleModal__c';
import TOGGLE_DELETE_BUTTON_MESSAGECHANNEL from '@salesforce/messageChannel/ToggleDeleteButton__c';
import { subscribe, MessageContext, publish } from 'lightning/messageService';

// datatable columns
const COLUMNS = [
    { label: 'Student code', fieldName: 'StudentCode__c' },
    { label: 'First name', fieldName: 'Firstnam__c' },
    { label: 'Last name', fieldName: 'Lastname__c' },
    { label: 'Birthday', fieldName: 'Birthday__c' },
    { label: 'Gender', fieldName: 'Gender__c' },
    { label: 'Class', fieldName: 'ClassName' },
    { label: 'Actions' }
];

export default class LWC_SearchResultStudent extends LightningElement {

    studentColumns = COLUMNS;
    allStudent;
    studentListResult;
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
    selectedStudentId = '';
    isDisableDeleteBtn = true;
    isDeleteMany = false;
    openCreateModal = false;
    openUpdateModal = false;
    openDetailModal = false;
    openDeleteModal = false;
    selectedRowsCount = 0;
    // properties for pagination
    pageSize;
    currentPage = 1;
    pages = [];
    totalPages = 1;
    hasPrevious = false;
    hasNext = false;
    totalRecords = 0;

    @wire(MessageContext)
    theMessageContext;

    /**
     * connectedCallback
     * Lifecycle hook that is called when the component is inserted into the DOM.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    connectedCallback() {
        this.getPageSizeSetting();
        subscribe(this.theMessageContext, FILTER_MESSAGECHANNEL, (message) => this.handleFilterChanges(message));
        subscribe(this.theMessageContext, TOGGLE_MODAL_MESSAGECHANNEL, (message) => this.handleToggleModal(message));
        this.fetchAllStudents();
    }

    /**
     * getPageSizeSetting
     * Get the page size from Custom Settings.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    getPageSizeSetting() {
        getCustomSettings().
            then(result => {
                this.pageSize = result.pageSize
            })
            .catch(error => {
                this.showToastMessage('Error', error, 'error');
            });
    }

    /**
     * handleFilterChanges
     * Get new criterias and re-search Student.
     * @param : message
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    handleFilterChanges(message) {
        this.searchCriterias = { ...message.filters };
        this.fetchAllStudents();
    }

    /**
     * handleToggleModal
     * Handles opening modals (Create/Delete) based on the LMS message received.
     * @param : message
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    handleToggleModal(message) {
        if (!message.isOpen) return;

        if (message.modalName === "createStudentModal") {
            this.openCreateModal = true;
        } else {
            this.openDeleteModal = true;
            this.isDeleteMany = true;
        }
    }

    /**
     * handleUpdateSuccess
     * Re-search student list after update success.
     * @param : なし
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    handleUpdateSuccess() {
        this.fetchAllStudents();
    }

    /**
     * handleRowAction
     * Handles actions (View, Update, Delete) on student record.
     * @param : event
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    handleRowAction(event) {
        const selectedStudentId = event.target.value;
        const rowAction = event.target.dataset.action;

        this.selectedStudentId = selectedStudentId;
        switch (rowAction) {
            case "View":
                this.openDetailModal = true;
                break;
            case "Update":
                this.openUpdateModal = true;
                break;
            case "Delete":
                this.openDeleteModal = true;
                break;
        }
    }

    /**
     * handleSelectRow
     * Handles row selection in the student list.
     * @param : event
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    handleSelectRow(event) {
        let { value: clickedStudentId, checked: isChecked } = event.target;
        let student = this.studentListResult.find(student => student.Id === clickedStudentId);
        if (student) {
            student.checked = isChecked;
        }
        // update total selected students in all page
        this.selectedRowsCount = this.allStudent.filter(student => student.checked).length;

        // check if all students on current page are selected
        const checkboxes = this.template.querySelectorAll('.checkboxOne');
        const allSelected = [...checkboxes].every(checkbox => checkbox.checked);
        // enable/disable delete button
        this.isDisableDeleteBtn = !(this.studentListResult.some(student => student.checked));
        this.toggleDeleteButton(this.isDisableDeleteBtn);
        // update the SELECT ALL checkbox status
        this.template.querySelector(".checkboxAll").checked = allSelected;
    }

    /**
     * handleSelectAll
     * Handles select all student records on the current page.
     * @param : event
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    handleSelectAll(event) {
        let isAllChecked = event.target.checked;
        if (Array.isArray(this.studentListResult) && this.studentListResult.length > 0) {
            this.studentListResult.forEach(student => {
                student.checked = isAllChecked;
            });

        }
        this.selectedRowsCount = this.allStudent.filter(student => student.checked).length;
        this.isDisableDeleteBtn = (isAllChecked && this.allStudent.length > 0) ? false : true;
        this.toggleDeleteButton(this.isDisableDeleteBtn);
    }

    /**
     * closeModal
     * Handles to close different modals.
     * @param : event
     * @return : なし
     * @created: 2024/10/13 Huynh Phuoc
     * @modified:
     */
    closeModal(event) {
        const modalName = event.detail.modalName;
        switch (modalName) {
            case "detailStudentModal":
                this.openDetailModal = false;
                break;
            case "updateStudentModal":
                this.openUpdateModal = false;
                break;
            case "createStudentModal":
                // close modal
                this.openCreateModal = false;
                // reset the list
                this.fetchAllStudents();
                break;
            default:
                // close modal & reset isDeleteMany to false
                this.openDeleteModal = false;
                this.isDeleteMany = false;
                break;
        }
    }

    /**
     * closeDeleteModal
     * Closes the delete modal.
     * @param : なし
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    closeDeleteModal() {
        this.openDeleteModal = false;
    }

    /**
     * confirmDelete
     * Handles delete one or many students. 
     * @param : なし
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    confirmDelete() {
        if (this.isDeleteMany) {
            let studentsToDelete = [];
            this.studentListResult.forEach(student => {
                if (student.checked) {
                    // add that student to delete
                    studentsToDelete.push(student.Id);
                    // minus total selected by 1
                    this.selectedRowsCount--;
                }
            });
            // remove deleted students from the allStudent array
            this.allStudent = this.allStudent.filter(student => !studentsToDelete.includes(student.Id));
            // update total student
            this.totalRecords = this.allStudent.length;
            // call Apex
            deleteSelectedStudents({ "studentList": studentsToDelete })
                .then(() => {
                    // reset isDeleteMany to false
                    this.isDeleteMany = false;
                    // update the result and close modal
                    this.studentListResult = this.updatePagedResults(this.allStudent, false);
                    this.pages = this.generatePageNumbers(this.totalPages, this.currentPage);
                    this.openDeleteModal = false;
                    this.showToastMessage("Success", "Delete student successfully", "success");
                    this.updateSelectAllCheckbox();
                })
                .catch((error) => {
                    this.showToastMessage("Error", error.message, "error");
                });
        } else {
            // call Apex
            deleteOneStudent({ studentId: this.selectedStudentId })
                .then(() => {
                    // find index of a deleted student 
                    let indexToDelete = this.allStudent.findIndex(student => student.Id === this.selectedStudentId);
                    if (indexToDelete !== -1) {
                        // if the student was checked before delete
                        if (this.allStudent[indexToDelete].checked) {
                            this.selectedRowsCount--;
                        }

                        // delete the student from allStudent list
                        this.allStudent.splice(indexToDelete, 1);
                        // decrease total record count
                        this.totalRecords--;
                    }

                    // update the result and close modal
                    this.studentListResult = this.updatePagedResults(this.allStudent, false);
                    this.pages = this.generatePageNumbers(this.totalPages, this.currentPage);
                    this.openDeleteModal = false;
                    this.showToastMessage("Success", "Delete student successfully", "success");
                    this.updateSelectAllCheckbox();
                })
                .catch((error) => {
                    this.showToastMessage("Error", error.message, "error");
                });
        }
    }

    /**
     * updatePagedResults
     * Handles pagination for the student list.
     * @param : studentList, isReset
     * @return : studentListResult
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    updatePagedResults(studentList, isReset) {
        let studentListResult = [];
        this.totalRecords = studentList.length;
        // If no Student found
        if (this.totalRecords <= 0) {
            this.totalRecords = 0;
            this.totalPages = 0;
            this.currentPage = 0;
            return;
        }
        this.totalPages = parseInt((this.totalRecords + this.pageSize - 1) / this.pageSize);
        // if click Search => go to first page
        if (isReset) {
            this.currentPage = 1;
        }

        let startIndex = (this.currentPage - 1) * this.pageSize;
        let endIndex = Math.min(startIndex + this.pageSize, this.totalRecords);

        // calculate the pages after deleting a student
        if (startIndex >= endIndex && this.currentPage >= 2) {
            this.currentPage = this.totalPages;
            startIndex = (this.currentPage - 1) * this.pageSize;
            this.pages = this.generatePageNumbers(this.totalPages, this.currentPage);
        }

        // Add students within range to result list
        for (let i = startIndex; i < endIndex; i++) {
            studentListResult.push(studentList[i]);
        }
        return studentListResult;
    }

    /**
     * generatePageNumbers
     * Generates an array of page numbers for pagination.
     * @param : totalPages, currentPage.
     * @return : pages.
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    generatePageNumbers(totalPages, currentPage) {
        let pages = [];
        let startPage, endPage;

        if (totalPages <= 5) {
            // If total pages <= 5, show all pages
            startPage = 1;
            endPage = totalPages;
        } else if (currentPage <= 3) {
            // currentPage near the beginning
            startPage = 1;
            endPage = 5;
        } else if (currentPage >= totalPages - 2) {
            // currentPage near the end
            startPage = totalPages - 4;
            endPage = totalPages;
        } else {
            // somewhere in the middle
            startPage = currentPage - 2;
            endPage = currentPage + 2;
        }
        // Add page numbers to the list
        for (let i = startPage; i <= endPage; i++) {
            pages.push({
                number: i, // label to display
                isCurrent: i === currentPage ? "brand" : "neutral" // highlight the current page
            });
        }

        return pages;
    }

    /**
     * fetchAllStudents
     * Get list students based on the current search criteria and updates the list for pagination.
     * @param : なし
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    fetchAllStudents() {
        searchStudents({ "searchCriterias": this.searchCriterias })
            .then((response) => {
                // can't edit data of (cacheable=true), need to create new variable
                this.allStudent = response.map(student => {
                    let newStudent = { ...student };
                    if (newStudent.Class_look__r) {
                        newStudent.ClassName = newStudent.Class_look__r.Name;
                    }
                    return newStudent;
                });

                this.studentListResult = this.updatePagedResults(this.allStudent, true);
                this.totalRecords = this.allStudent.length;
                this.pages = this.generatePageNumbers(this.totalPages, this.currentPage);
                this.updateSelectAllCheckbox();
                this.selectedRowsCount = 0;
            })
            .catch((error) => {
                this.showToastMessage('Error', error.message, 'error');
            });
    }

    /**
     * goToFirstPage
     * Go to the first page in the pagination list.
     * @param : なし
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    goToFirstPage() {
        this.goToPageHelper(1);
    }

    /**
     * goToFirstPage
     * Go to the previous page in the pagination list.
     * @param : なし
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    goToPreviousPage() {
        this.goToPageHelper(this.currentPage - 1);
    }

    /**
     * goToFirstPage
     * Go to the next page in the pagination list.
     * @param : なし
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    goToNextPage() {
        this.goToPageHelper(this.currentPage + 1);
    }

    /**
     * goToFirstPage
     * Go to the last page in the pagination list.
     * @param : なし
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    goToLastPage() {
        this.goToPageHelper(this.totalPages);
    }

    /**
     * goToFirstPage
     * Go to the specificed page in the pagination list.
     * @param : event
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    goToPage(event) {
        this.currentPage = parseInt(event.target.name, 10);
        this.goToPageHelper(this.currentPage);
    }

    /**
     * goToPageHelper
     * Go to a specific page.
     * @param : pageNumber
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    goToPageHelper(pageNumber) {
        this.currentPage = pageNumber;
        this.studentListResult = this.updatePagedResults(this.allStudent, false);
        this.pages = this.generatePageNumbers(this.totalPages, this.currentPage);
        // update checkboxAll checkbox when go to other page
        this.updateSelectAllCheckbox();
    }

    /**
     * updateSelectAllCheckbox
     * Updates 'Select All' checkbox and enable/disable Delete button based on selected students.
     * @param : なし
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    updateSelectAllCheckbox() {
        // if list is not empty
        if (this.studentListResult && this.studentListResult.length > 0) {
            let allChecked = this.studentListResult.every(student => student.checked);
            this.template.querySelector('.checkboxAll').checked = allChecked;

            let isAnyStudentChecked = this.studentListResult.some(student => student.checked);
            this.toggleDeleteButton(!isAnyStudentChecked);
        } else {
            // if list is empty => uncheck checkboxAll and disable Delete button
            this.template.querySelector('.checkboxAll').checked = false;
            this.toggleDeleteButton(true);
        }
    }

    /**
     * isFirstPage (getter)
     * Checks if the current page is the first page.
     * @param : なし
     * @return : Boolean
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    get isFirstPage() {
        return this.currentPage === 1 || this.currentPage === 0;
    }

    /**
     * isLastPage (getter)
     * Checks if the current page is the last page.
     * @param : なし
     * @return : Boolean
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    get isLastPage() {
        return this.currentPage === this.totalPages || this.totalRecords === 0;
    }

    /**
     * toggleDeleteButton
     * Publishe message to enable/disable Delete button using the LMS>.
     * @param : isDisable
     * @return : なし
     * @created : 2024/10/13 Huynh Phuoc
     * @modified :
     */
    toggleDeleteButton(isDisable) {
        publish(this.theMessageContext, TOGGLE_DELETE_BUTTON_MESSAGECHANNEL, {
            isDisable: isDisable
        });
    }

    /**
     * showToastMessage
     * Displays a toast message to the user.
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
            duration: 2000, // 2 seconds
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }
}