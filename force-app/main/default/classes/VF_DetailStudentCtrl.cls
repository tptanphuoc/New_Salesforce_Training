/**
* クラス名       :	VF_DetailStudentCtrl
* クラス概要     :	A controller class to handle the logic of Student__c object used by VF_DetailStudent page
* @created      :  2024/09/12 Huynh Phuoc
* @modified 	:   
*/
public with sharing class VF_DetailStudentCtrl {

    @TestVisible
    private static Boolean isThrownException = false;

    // Student__ details
    public Student__c studentDetails { get; set; }

    /**
	* VF_DetailStudentCtrl
	* Constructor of VF_DetailStudentCtrl class
	* @param none
	* @return none
	* @created: 2024/09/12 Huynh Phuoc
	* @modified: 
	*/
    public VF_DetailStudentCtrl() {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new VisualforceException('Test exception');
            }
            
            studentDetails = new Student__c();
            String recordId = ApexPages.currentPage().getParameters().get('id');
            if (String.isNotBlank(recordId)) {
                List<Student__c> studentList = [
                    SELECT Id,
                            Birthday__c, 
                            Class_look__r.Name, 
                            Firstname__c, 
                            Gender__c, 
                            GPAScore__c, 
                            Lastname__c, 
                            LearningStatus__c, 
                            StudentCode__c, 
                            TotalCredit__c 
                    FROM Student__c 
                    WHERE Id = :recordId
                ];
                if (studentList.size() > 0) {
                    studentDetails = studentList[0];
                }
            }

            if (studentDetails.Id == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Cannot find the Student'));
                // not hard code the page name
                PageReference searchPage = Page.VF_SearchStudent;
                searchPage.setRedirect(true);
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
}