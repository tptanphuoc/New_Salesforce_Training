({
    doInit : function(component, event, helper) {
        helper.getExistingStudentHelper(component, event, helper);
        helper.getAllOptionsHelper(component, event, helper);
    },

    updateStudent : function(component, event, helper) {
        // prevent reload the page when click button
        event.preventDefault();
        // call the helper method
        helper.updateStudentHelper(component, event, helper);
    },

    closeModal : function(component, event, helper) {
        component.getEvent("cancelUpdate").fire();
    }
})