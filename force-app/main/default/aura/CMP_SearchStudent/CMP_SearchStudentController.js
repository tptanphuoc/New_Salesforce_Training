({
    fetchAllStudent : function(component, event, helper) {
        helper.getCustomSettingHelper(component, event, helper);
        helper.fetchFilteredStudentHelper(component, event, helper);
    },

    goToFirstPage : function(component, event, helper) {
        helper.goToPage(component, 1);
    },

    goToPreviousPage : function(component, event, helper) {
        let currentPage = component.get("v.currentPage");
        helper.goToPage(component, currentPage - 1);
    },

    goToNextPage : function(component, event, helper) {
        let currentPage = component.get("v.currentPage");
        helper.goToPage(component, currentPage + 1);
    },

    goToLastPage : function(component, event, helper) {
        let totalPages = component.get("v.totalPages");
        helper.goToPage(component, totalPages);
    },

    goToPage : function(component, event, helper) {
        let page = parseInt(event.getSource().get("v.name"));
        helper.goToPage(component, page);
    },

    handleRecordActions : function (component, event, helper) {
        let recordId = event.getParam("recordId");
        let actionType = event.getParam("actionType");

        switch (actionType) {
            case 'View':
                component.set("v.recordId", recordId);
                component.set("v.openDetailModal", true);
                break;
            case 'Update':
                component.set("v.recordId", recordId);
                component.set("v.openUpdateModal", true);
                break;
            case 'Delete':
                component.set("v.recordIdToDelete", recordId);
                component.set("v.openDeleteModal", true);
                break;
        }
    },
 
    callChildToSearch: function(component) { // resetInput
        // get the student filter component
        let studentFilter = component.find("studentFilter");
        // Call the getFilterValues method on the child component
        studentFilter.startSearchFromChild();
    },

    callChildToResetInputs: function(component) {
        // get the student filter component
        let studentFilter = component.find("studentFilter");
        // Call the getFilterValues method on the child component
        studentFilter.resetInput();
        component.set("v.isDisableResetBtn", true);
    },
 
    fetchFilteredStudent: function(component, event, helper) {
        helper.fetchFilteredStudentHelper(component, event, helper);
    },
 
    confirmDelete : function(component, event, helper) {
        // if delete many Student__c
        if (component.get("v.isDeleteMany")) {
            let curentStudents = component.get("v.studentListResult");
            let recordsToDelete = [];
 
            curentStudents.forEach((student) => {
                if (student.checked) {
                    recordsToDelete.push(student.Id);
                }
            });
           
            if (recordsToDelete.length > 0) {
                helper.deleteManyStudentHelper(component, recordsToDelete);
            } else {
                alert("Please select at least one row to delete.");
            }
            component.set("v.isDeleteMany", false);
        } else {
            helper.deleteOneStudentHelper(component, event, helper);
        }
    },
 
    // create modals
    openCreateModal : function(component, event, helper) {
        component.set("{!v.openCreateModal}", true);
    },
 
    closeCreateModal: function(component, event, helper) {
        component.set("v.openCreateModal", false);
    },
 
    handleCreateSuccess : function(component, event, helper) {
        component.set("v.openCreateModal", false);
        // clear search inputs
        $A.enqueueAction(component.get('c.callChildToResetInputs'));
        // re-fetch the student list
        helper.fetchFilteredStudentHelper(component, event, helper);
    },

    handleCancelCreate : function(component, event, helper) {
        component.set("v.openCreateModal", false);
    },
 
    // update modals
    closeUpdateModal : function(component, event, helper) {
        component.set("v.openUpdateModal", false);
    },
 
    handleUpdateSuccess : function(component, event, helper) {
        component.set("v.openUpdateModal", false);
        // clear search inputs
        $A.enqueueAction(component.get('c.callChildToResetInputs'));
        // re-fetch the student list
        helper.fetchFilteredStudentHelper(component, event, helper);
    },

    handleCancelUpdate : function(component, event, helper) {
        component.set("v.openUpdateModal", false);
    },
 
    // detail modal
    handleCloseDetailModal : function(component, event, helper) {
        component.set("v.openDetailModal", false);
    },
 
    // delete modal
    openDeleteModal : function(component, event, helper) {
        // if user click deleteManyBtn
        let source = event.getSource();
        let isDeleteMany = source && source.getLocalId() === 'deleteManyBtn';
 
        component.set("v.isDeleteMany", isDeleteMany);
        component.set("v.openDeleteModal", true);
    },
 
    closeDeleteModal : function(component, event, helper) {
        component.set("v.openDeleteModal", false);
        // if user click Cancel in DeleteModal
        component.set("v.isDeleteMany", false);
    },
 
    // reset button
    handleToggleResetButton : function(component, event, helper) {
        // get the boolean value from the event
        let isDisabled = event.getParam("isDisabled");
        if (isDisabled) {
            component.set("v.isDisableResetBtn", false);
        } else {
            component.set("v.isDisableResetBtn", true);
        }
    },

    // disable delete button
    handleDisableDeleteButton : function(component, event, helper) {
        let isDisabled = event.getParam("isDisabled");
        if (isDisabled) {
            component.set("v.isDisableDeleteBtn", false);
        } else {
            component.set("v.isDisableDeleteBtn", true);
        }
    }, 
})