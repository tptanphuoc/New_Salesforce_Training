({
    doInit : function(component, event, helper) {
        helper.getStudentDetailsHelper(component, event, helper);
    },

    closeDetailModal : function(component, event, helper) {
        // fire an event to close detail modal
        component.getEvent("closeDetailModal").fire();
    },

    navigateToClassDetail : function(component, event, helper) {
        let navService = component.find("navService");
        let classId = component.get("v.studentDetails.Class_look__c");
        let pageReference = {
            type: "standard__recordPage",
            attributes: {
                recordId: classId,
                objectApiName: "Class__c",
                actionName: "view"
            }
        };
        navService.generateUrl(pageReference).then($A.getCallback(function(url) {
            window.open(url, '_blank');
        }));
    }
})