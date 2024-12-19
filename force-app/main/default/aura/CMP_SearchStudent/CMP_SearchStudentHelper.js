({
    totalRecords: 0, // total records
    pageSize: 0, // page size
    totalPages: 0, // total pages
 
    getCustomSettingHelper : function(component, event, helper) {
        var action = component.get("c.getCustomSettings");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let pageSizeSetting = response.getReturnValue().pageSize;
                this.pageSize = pageSizeSetting;
            }
        });
        
        $A.enqueueAction(action);
    },
 
    fetchFilteredStudentHelper : function(component, event, helper) {
        let studentListResult = component.get("v.studentListResult");
        // call Apex method to query Student based on filters
        let action = component.get("c.searchStudents");
        let searchCriterias = {
            "searchStudentCode": event.getParam("studentCodeFilter"),
            "searchName": event.getParam("studentNameFilter"),
            "selectedClass": event.getParam("classFilter"),
            "selectedGender": event.getParam("genderFilter"),
            "searchBirthday": event.getParam("birthdayFilter"),
            "selectedDay": event.getParam("dayFilter"),
            "selectedMonth": event.getParam("monthFilter"),
            "selectedYear": event.getParam("yearFilter")
        };
        action.setParams({"searchCriterias": searchCriterias});
        action.setCallback(this, (response) => {
            let state = response.getState();
            if (state === "SUCCESS") {
                let responseValue = response.getReturnValue();
                // if have value from Apex
                if (responseValue) {
                    // loop every record to modify value
                    responseValue.forEach((student) => {
                        // format date to dd/MM/yyyy
                        student.Birthday__c = this.formatDate(student.Birthday__c);
                        if (student.Class_look__r) {
                            // create new property(ClassName), assign the value of Class_look__r.Name from Apex to it
                            student.ClassName = student.Class_look__r.Name;
                        }
                        // show the URL to that student
                        student.StudentURL = 'https://' + window.location.host + '/' + student.Id;
                    });
                }
                // reset all checkboxes
                component.set("v.selectedRowsCount", 0);
                // disable delete many button
                component.set("v.isDisableDeleteBtn", true);
                component.set("v.allStudent", responseValue);
 
                studentListResult = this.updatePagedResults(component.get("v.allStudent"), true, component);
                this.totalRecords = component.get("v.allStudent").length;
                this.totalPages = (this.totalRecords + this.pageSize - 1) / this.pageSize;
 
                component.set("v.totalRecords", this.totalRecords);
                component.set("v.studentListResult", studentListResult);
                component.set("v.pages", this.generatePageNumbers(this.totalPages, component.get("v.currentPage")));
                component.set("v.studentFound", true);
                // after search, re-update the selectAll checkbox and deleteMany button
                if (Array.isArray(studentListResult) && studentListResult.length > 0) {
                    this.updateSelectAllCheckbox(component);
                }
                //  else {
                //     component.find("selectAllCheckbox").set("v.checked", false);
                // }
            }
        })
        $A.enqueueAction(action);
    },

    updatePagedResults: function(students, reset, component) {
        let studentListResult = [];
        this.totalRecords = students.length;
        let pages = [];
 
        // If no Student__c found
        if (this.totalRecords <= 0) {
            this.totalRecords = 0;
            this.totalPages = 0;
            component.set("v.currentPage", 0);
            component.set("v.totalPages", 0);
            pages = [];
            return;
        }
 
        this.totalPages = parseInt((this.totalRecords + this.pageSize - 1) / this.pageSize);
        component.set("v.totalPages", this.totalPages);
 
        // If click Search => go to first page
        if (reset) {
            component.set("v.currentPage", 1);
        }
 
        let startIndex = (component.get("v.currentPage") - 1) * this.pageSize;
        let endIndex = Math.min(startIndex + this.pageSize, this.totalRecords);
 
        // Calculate the pages after deleting a student
        if (startIndex >= endIndex && component.get("v.currentPage") >= 2) {
            component.set("v.currentPage", this.totalPages);
            startIndex = (component.get("v.currentPage") - 1) * this.pageSize;
            component.set("v.pages", this.generatePageNumbers(this.totalPages, component.get("v.currentPage")));
        }
 
        // Add students within range to result list
        for (let i = startIndex; i < endIndex; i++) {
            studentListResult.push(students[i]);
        }
       
        return studentListResult;
    },
 
    generatePageNumbers: function(totalPages, currentPage) {
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
            pages.push(i);
        }
       
        return pages;
    },

    goToPage : function(component, pageNumber) {
        // Update current page
        component.set("v.currentPage", pageNumber);
        // Fetch data for the new page
        component.set("v.studentListResult", this.updatePagedResults(component.get("v.allStudent"), false, component));
        component.set("v.pages", this.generatePageNumbers(this.totalPages, component.get("v.currentPage")));

        // update selectAllCheckbox when go to other page
        this.updateSelectAllCheckbox(component);
    },

    // update selectAllCheckbox when go to other page
    updateSelectAllCheckbox: function(component) {
        let studentData = component.find("studentData");
        studentData.updateCheckboxAll();
    },

    deleteOneStudentHelper : function(component, event, helper) {
        let action = component.get("c.deleteOneStudent");
        let recordIdToDelete = component.get("v.recordIdToDelete");
        let allStudent = component.get("v.allStudent");
        let studentList = component.get("v.studentListResult") || [];
 
        action.setParam("studentId", recordIdToDelete);
        action.setCallback(this, (response) => {
            let state = response.getState();
            if (state === "SUCCESS") {
                // delete in the allStudent list in FE
                let indexToDelete = allStudent.findIndex(student => student.Id === recordIdToDelete);
                if (indexToDelete !== -1) {
                    // check if the student was checked before delete
                    if (allStudent[indexToDelete].checked) {
                        component.set("v.selectedRowsCount", component.get("v.selectedRowsCount") - 1);
                    }
                   
                    // delete the student from allStudent list
                    allStudent.splice(indexToDelete, 1);
                    this.totalRecords--;  // decrease total record count
                }

                // re-render the allStudent list to FE
                component.set("v.allStudent", allStudent);
                studentList = this.updatePagedResults(allStudent, false, component);
                component.set("v.studentListResult", studentList);
                component.set("v.pages", this.generatePageNumbers(this.totalPages, component.get("v.currentPage")));
                this.showToastMessage("Success", "Delete student successfully", "success");
                // hide delete modal after delete success
                component.set("v.openDeleteModal", false);
                // after delete success, re-update the selectAll checkbox and deleteMany button
                this.updateSelectAllCheckbox(component);
            } else {
                let errors = response.getError();
                let errorMessage = errors[0].message;
                this.showToastMessage("Error", errorMessage, "error");
            }
        });
       
        $A.enqueueAction(action);
    },

    deleteManyStudentHelper: function(component, recordsToDelete) {
        let action = component.get("c.deleteSelectedStudents");
        let allStudent = component.get("v.allStudent");
        let studentList = component.get("v.studentListResult");
 
        action.setParam("studentList", recordsToDelete);
        action.setCallback(this, (response) => {
            let state = response.getState();
            if (state === "SUCCESS") {
                // if the delete student is checked, minus selectedRowsCount
                studentList.forEach(student => {
                    if (student.checked) {
                        component.set("v.selectedRowsCount", component.get("v.selectedRowsCount") - 1);
                    }
                });
                // remove deleted students from the allStudent array
                allStudent = allStudent.filter(student => !recordsToDelete.includes(student.Id));
                // update totalRecords count
                this.totalRecords = allStudent.length;
   
                // re-render the allStudent list to FE
                studentList = this.updatePagedResults(allStudent, false, component);
                component.set("v.studentListResult", studentList);
                component.set("v.pages", this.generatePageNumbers(this.totalPages, component.get("v.currentPage")));
                this.showToastMessage("Success", "Selected students deleted successfully", "success");
               
                // hide delete modal after delete success
                component.set("v.openDeleteModal", false);
                component.set("v.allStudent", allStudent);
                // after delete success, re-update the selectAll checkbox and deleteMany button
                this.updateSelectAllCheckbox(component);
            } else {
                let errors = response.getError();
                let errorMessage = errors[0].message;
                this.showToastMessage("Error", errorMessage, "error");
            }
        });
       
        $A.enqueueAction(action);
    },

    showToastMessage: function(title, message, type) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
            "duration": 2000,
            "mode": "pester"
        });
        toastEvent.fire();
    },

    formatDate : function(dateString) {
        if (!dateString) return '';
        var date = new Date(dateString);
        var day = date.getDate().toString().padStart(2, '0');
        var month = (date.getMonth() + 1).toString().padStart(2, '0');
        var year = date.getFullYear();
        return `${day}/${month}/${year}`;
    },
})