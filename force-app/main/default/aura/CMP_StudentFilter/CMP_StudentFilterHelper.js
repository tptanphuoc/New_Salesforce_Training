({
    getAllOptionsHelper: function(component, event, helper) {
        let action = component.get("c.getAllOptions");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let allOptions = response.getReturnValue();
                
                // Set gender options
                component.set("v.genderOptions", this.formatGenderOptions(allOptions.genderOptions));
                
                // Set class options
                component.set("v.classOptions", allOptions.classOptions);
            }
        });
        $A.enqueueAction(action);
    },

    formatGenderOptions: function(options) {
        return options.map(option => ({
            label: this.translateGender(option.label),
            value: option.value,
            disabled: option.disabled
        }));
    },

    translateGender: function(label) {
        switch(label) {
            case "男性": return "男性 (Male)";
            case "女性": return "女性 (Female)";
            default: return label;
        }
    },

    getDayOptionHelper : function(component, event, helper) {
        // generate day from 1 to 31
        let dayList = [];
        dayList.push({ label: "--None--", value: "" });
        for (let i = 1; i <= 31; i++) {
            dayList.push({ label: i.toString(), value: i.toString() });
        }
        component.set("v.dayOptions", dayList);
    },

    getMonthOptionHelper : function(component, event, helper) {
        // generate month from 1 to 12
        let monthList = [];
        monthList.push({ label: "--None--", value: "" });
        for (let i = 1; i <= 12; i++) {
            monthList.push({ label: i.toString(), value: i.toString() });
        }
        component.set("v.monthOptions", monthList);
    },

    getYearOptionHelper : function(component, event, helper) {
        // generate year from 1900 to current year
        let yearList = [];
        yearList.push({ label: "--None--", value: "" });
        for (let i = new Date().getFullYear(); i >= 1990; i--) {
            yearList.push({ label: i.toString(), value: i.toString() });
        }
        component.set("v.yearOptions", yearList);
    },
})