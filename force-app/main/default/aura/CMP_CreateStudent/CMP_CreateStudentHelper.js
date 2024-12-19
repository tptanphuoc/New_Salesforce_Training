({
    createStudentHelper: function(component, event, helper) {
        let studentObject = {
            'sobjectType': 'Student__c',
            'Firstname__c': component.get("v.newStudent.Firstname__c"),
            'Lastname__c': component.get("v.newStudent.Lastname__c"),
            'Birthday__c': component.get("v.newStudent.Birthday__c"),
            'Class_look__c': component.get("v.selectedClass"),
            'Gender__c': component.get("v.selectedGender"),
            'LearningStatus__c': component.get("v.selectedLearningStatus")
        };

        let action = component.get("c.createNewStudent");
        action.setParams({
            "newStudent": studentObject
        });
    
        action.setCallback(this, (response) => {
            let state = response.getState();
            if (state === "SUCCESS") {
                this.showToastMessage("Success", "Create student successfully", "success");
                // fire event to close create modal
                component.getEvent("createSuccess").fire();
            } else {
                let errors = response.getError();
                let errorMessage = errors[0].message;
                this.showToastMessage("Error", errorMessage, "error");
            }
        });
    
        $A.enqueueAction(action);
    },

    getAllOptionsHelper: function(component, event, helper) {
        let action = component.get("c.getAllOptions");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let allOptions = response.getReturnValue();
                
                // Set learning status options
                component.set("v.learningStatusOptions", this.formatLearningStatusOptions(allOptions.learningStatusOptions));
                
                // Set gender options
                component.set("v.genderOptions", this.formatGenderOptions(allOptions.genderOptions));
                
                // Set class options
                component.set("v.classOptions", allOptions.classOptions);
            }
        });
        $A.enqueueAction(action);
    },

    formatLearningStatusOptions: function(options) {
        return options.map(option => ({
            label: this.translateLearningStatus(option.label),
            value: option.value,
            disabled: option.disabled
        }));
    },

    formatGenderOptions: function(options) {
        return options.map(option => ({
            label: this.translateGender(option.label),
            value: option.value,
            disabled: option.disabled
        }));
    },

    translateLearningStatus: function(label) {
        switch(label) {
            case "在学中": return "在学中 (Enrolled)";
            case "退学": return "退学 (Withdrawn)";
            case "卒業済み": return "卒業済み (Graduated)";
            default: return label;
        }
    },

    translateGender: function(label) {
        switch(label) {
            case "男性": return "男性 (Male)";
            case "女性": return "女性 (Female)";
            default: return label;
        }
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