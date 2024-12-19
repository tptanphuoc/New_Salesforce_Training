({
    fireDisableDeleteButtonEvent: function(component, isDisableDeleteBtn) {
        let disableDeleteBtnEvt = component.getEvent("disableDeleteButton");
        disableDeleteBtnEvt.setParams({ "isDisabled": isDisableDeleteBtn });
        disableDeleteBtnEvt.fire();
    },

    fireRecordActionsEvent: function(component, recordId, actionType) {
        let recordActionsEvt = component.getEvent("recordActions");
        recordActionsEvt.setParams({
            "recordId": recordId,
            "actionType": actionType
        });
        recordActionsEvt.fire();
    },
})