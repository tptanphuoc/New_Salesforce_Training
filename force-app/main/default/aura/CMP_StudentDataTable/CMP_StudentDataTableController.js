({
    doInit : function(component, event, helper) {
        const columns = [
            { label: 'Student code', fieldName: 'StudentCode__c' },
            { label: 'First name', fieldName: 'Firstnam__c' },
            { label: 'Last name', fieldName: 'Lastname__c' },
            { label: 'Birthday', fieldName: 'Birthday__c', type: 'date' },
            { label: 'Gender', fieldName: 'Gender__c' },
            { label: 'Class', fieldName: 'ClassName' },
            { label: 'Actions' }
        ];
        component.set("v.studentColumns", columns);
    },

    handleSelectAll: function(component, event, helper) {
        let isSelectAll = event.getSource().get("v.checked");
        let studentList = component.get("v.studentListResult") || [];
        let allStudents = component.get("v.allStudent") || [];
        studentList.forEach(student => student.checked = isSelectAll);
        component.set("v.selectedRowsCount", allStudents.filter(student => student.checked).length);
        component.set("v.studentListResult", studentList);
        helper.fireDisableDeleteButtonEvent(component, isSelectAll && studentList.length > 0);
    },    

    handleRowSelect: function(component, event, helper) {
        let checkbox = event.getSource();
        let studentList = component.get("v.studentListResult");
        let allStudents = component.get("v.allStudent");
        let checkboxes = component.find("selectRowCheckbox");
        let clickedStudent = studentList.find(student => student.Id === checkbox.get("v.value"));
        if (clickedStudent) clickedStudent.checked = checkbox.get("v.checked");
        component.set("v.selectedRowsCount", allStudents.filter(student => student.checked).length);
        component.find("selectAllCheckbox").set("v.checked", checkboxes.every(cb => cb.get("v.checked")));
        helper.fireDisableDeleteButtonEvent(component, studentList.some(student => student.checked));
    },
    
    handleRowAction: function (component, event, helper) {
        let clickedButton = event.getSource();
        let action = clickedButton.getLocalId(); // View/Update/Delete (get by aura:id)
        let studentId = clickedButton.get("v.value"); // dynamic student.Id
 
        if (['View', 'Update', 'Delete'].includes(action)) {
            helper.fireRecordActionsEvent(component, studentId, action);
        }
    },

    // update selectAllCheckbox when go to other page
    handleUpdateCheckboxAll: function(component, event, helper) {
        let studentList = component.get("v.studentListResult");
        let allChecked = studentList.every(student => student.checked);
        component.find("selectAllCheckbox").set("v.checked", allChecked);
        helper.fireDisableDeleteButtonEvent(component, studentList.some(student => student.checked));
    }
})