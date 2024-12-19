({
    doInit : function(component, event, helper) {
        // Initialize the newStudent object
        var newStudent = {
            'sobjectType': 'Student__c',
            'Firstname__c': '',
            'Lastname__c': '',
            'Birthday__c': null,
            'Class_look__c': '',
            'Gender__c': '',
            'LearningStatus__c': ''
        };
        component.set("v.newStudent", newStudent);

        helper.getAllOptionsHelper(component, event, helper);
    },

    createStudent : function(component, event, helper) {
        // prevent reload the page when click button
        event.preventDefault();
        // call the helper method
        helper.createStudentHelper(component, event, helper);
    },

    closeModal : function(component, event, helper) {
        component.getEvent("cancelCreate").fire();
    }
})