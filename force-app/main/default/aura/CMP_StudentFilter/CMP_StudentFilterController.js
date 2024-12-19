({
    initFilter : function(component, event, helper) {
        helper.getAllOptionsHelper(component, event, helper);
        helper.getDayOptionHelper(component, event, helper);
        helper.getMonthOptionHelper(component, event, helper);
        helper.getYearOptionHelper(component, event, helper);
    },

    handleStartSearchFromChild : function(component, event, helper) {
        // find the COMPONENT event
        let filterEvent = component.getEvent("filterEvent"); // get the event that already defined
        // set the values for that COMPONENT event
        filterEvent.setParams({
            // these are params that already defined in COMPONENT event
            "studentCodeFilter": component.get("v.studentCode"), 
            "studentNameFilter": component.get("v.studentName"),
            "classFilter": component.get("v.selectedClass"),
            "genderFilter": component.get("v.selectedGender"),
            "birthdayFilter": component.get("v.birthday"),
            "dayFilter": component.get("v.selectedDay"),
            "monthFilter": component.get("v.selectedMonth"),
            "yearFilter": component.get("v.selectedYear")
        });
        filterEvent.fire();
    },

    handleDisableResetBtn : function(component, event, helper) {
        let isNotBlank = false;
        // get filter values
        let filters = [
            component.get("v.studentCode"),
            component.get("v.studentName"),
            component.get("v.selectedClass"),
            component.get("v.selectedGender"),
            component.get("v.birthday"),
            component.get("v.selectedDay"),
            component.get("v.selectedMonth"),
            component.get("v.selectedYear")
        ];

        // check if all filters are empty or null
        for (let i = 0; i < filters.length; i++) {
            if (filters[i] != null && filters[i] != "") {
                isNotBlank = true;
                break;
            }
        }
        // fire the event with the boolean value
        let toggleResetEvent = component.getEvent("toggleResetButton");
        toggleResetEvent.setParams({ "isDisabled": isNotBlank }); // Pass the boolean value
        toggleResetEvent.fire();
    },

    handleResetInput: function(component, event, helper) {
        // Reset all input fields to default or empty values
        component.set("v.studentCode", undefined);
        component.set("v.studentName", undefined);
        component.set("v.selectedClass", undefined);
        component.set("v.selectedGender", undefined);
        component.set("v.birthday", null);
        component.set("v.selectedDay", undefined);
        component.set("v.selectedMonth", undefined);
        component.set("v.selectedYear", undefined);
    },
})