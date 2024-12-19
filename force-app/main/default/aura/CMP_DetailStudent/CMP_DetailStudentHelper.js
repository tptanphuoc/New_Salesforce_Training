({
    getStudentDetailsHelper : function(component, event, helper) {
        let action = component.get("c.getStudentDetails");
        action.setParams({
            "studentId": component.get("v.studentId")
        });

        action.setCallback(this, (response) => {
            let state = response.getState();
            if (state === "SUCCESS") {
                let studentResponse = response.getReturnValue();
                // format the Birthday__c field
                if(studentResponse.Birthday__c){
                    let birthday = new Date(studentResponse.Birthday__c);
                    let formattedDate = $A.localizationService.formatDate(birthday, "DD/MM/YYYY");
                    component.set("v.formattedBirthday", formattedDate);
                } else {
                    component.set("v.formattedBirthday", "N/A");
                }
                component.set("v.studentDetails", studentResponse);
            } else {
                let errors = response.getError();
                let errorMessage = errors[0].message;
                this.showToastMessage("Error", errorMessage, "error");
                component.getEvent("closeDetailModal").fire();
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
})