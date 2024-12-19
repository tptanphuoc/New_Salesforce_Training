/**
* クラス名       :	VF_UpdateStudentCtrl
* クラス概要     :	A controller class to handle the logic of Student__c object used by VF_UpdateStudent page
* @created      :  2024/09/12 Huynh Phuoc
* @modified 	:   
*/
public with sharing class VF_UpdateStudentCtrl {

    @TestVisible
    private static Boolean isThrownException = false;
    
    // RecordId from URL
    public String recordId { get; set; }

    // Existing Student__c
    public Student__c student  { get; set; }

    // List of Class__c load from DB
    public List<CLass__c> classList { get; set; }

    // The selected Class__c from user
    public String selectedClass { get; set; }

    // The selected Gender__c from user
    public String selectedGender { get; set; }

    // The selected LearningStatus__c from user
    public String selectedStatus { get; set; }

    // Error infor of Class__c
    public String classError { get; set; }

    // Error infor of Gender__c
    public String genderError { get; set; }
    
    // Error infor of LearningStatus__c
    public String statusError { get; set; }

    /**
	* VF_UpdateStudentCtrl
	* Constructor of VF_UpdateStudentCtrl class
	* @param none
	* @return none
	* @created: 2024/09/12 Huynh Phuoc
	* @modified: 
	*/
    public VF_UpdateStudentCtrl() {
        student = new Student__c();
        getStudentDetail();
    }

    /**
	* getStudentDetail
	* Get the details of Student__c
	* @param none
	* @return PageReference
	* @created: 2024/09/12 Huynh Phuoc
	* @modified: 
	*/
    public PageReference getStudentDetail() {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new VisualforceException('Test exception');
            }

            recordId = ApexPages.currentPage().getParameters().get('id');
            if (recordId == null || String.isBlank(recordId)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Cannot find the Student'));
                return redirectToSearchPage();
            }
            List<Student__c> studentList = [
                        SELECT Id, 
                                Firstname__c, 
                                Lastname__c, 
                                Birthday__c, 
                                GPAScore__c, 
                                TotalCredit__c, 
                                Class_look__r.Id, 
                                Gender__c,
                                LearningStatus__c 
                        FROM Student__c 
                        WHERE Id =:recordId LIMIT 1];

            if (studentList.size() <= 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Cannot find the Student'));
                return redirectToSearchPage();
            } else {
                student = studentList[0];
                selectedClass = student.Class_look__r.Id;
                selectedGender = student.Gender__c;
                selectedStatus = student.LearningStatus__c;
                return null;
            }
        } catch (Exception ex) {
            throw new VisualforceException(ex.getMessage());
        }
    }

    /**
	* getClassOptions
	* Get the list of Class__c
	* @param none
	* @return List<SelectOption>
	* @created: 2024/09/12 Huynh Phuoc
	* @modified: 
	*/
    public List<SelectOption> getClassOptions() {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new VisualforceException('Test exception');
            }

            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select class--')); // Default option when the page is loaded
            classList = [SELECT Id, Name FROM Class__c];

            for (Class__c c : classList) {
                options.add(new SelectOption(c.Id, c.Name));
            }

            return options;
        } catch (Exception ex) {
            throw new VisualforceException(ex.getMessage());
        } 
    }

    /**
	* getLearningStatusOptions
	* Get the list of LearningStatus__c
	* @param none
	* @return List<SelectOption>
	* @created: 2024/09/12 Huynh Phuoc
	* @modified: 
	*/
    public List<Selectoption> getLearningStatusOptions(){
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new VisualforceException('Test exception');
            }
            
            List<SelectOption> options = new List<SelectOption>(); 
            List<Schema.Picklistentry> stautsOptions = Student__c.LearningStatus__c.getDescribe().getPicklistValues();
            options.add(new SelectOption('', '--Select status--'));

            for(Schema.PicklistEntry f : stautsOptions) {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            }

            return options;
        } catch (Exception ex) {
            throw new VisualforceException(ex.getMessage());
        }
    }

    /**
	* getGenderOptions
	* Get the list of Gender__c
	* @param none
	* @return List<SelectOption>
	* @created: 2024/09/12 Huynh Phuoc
	* @modified: 
	*/
    public List<Selectoption> getGenderOptions(){
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new VisualforceException('Test exception');
            }

            List<SelectOption> options = new List<SelectOption>(); 
            List<Schema.Picklistentry> genderOptions = Student__c.Gender__c.getDescribe().getPicklistValues();
            options.add(new SelectOption('', '--Select gender--'));
            
            for(Schema.PicklistEntry f : genderOptions) {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            }

            return options;
        } catch (Exception ex) {
            throw new VisualforceException(ex.getMessage());
        }
    }

    /**
	* updateStudent
	* Update the Student__c
	* @param none
	* @return PageReference
	* @created: 2024/09/12 Huynh Phuoc
	* @modified: 
	*/
    public PageReference updateStudent() {
        try {
            if (isThrownException && Test.isRunningTest()) {
                throw new VisualforceException('Test exception');
            }

            if (validateForm()) {
                return null;
            }

            if (validateBirthday()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Student must be over 18'));
                return null;
            }

            student.Class_look__c = selectedClass;
            student.Gender__c = selectedGender;
            student.LearningStatus__c = selectedStatus;
            update student;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Update successfully!'));
            
            return redirectToSearchPage();
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            throw new VisualforceException(ex.getMessage());
        }
    }

    /**
	* validateForm
	* Validate the form inputed by user
	* @param none
	* @return Boolean
	* @created: 2024/09/12 Huynh Phuoc
	* @modified: 
	*/
    public Boolean validateForm() {
        classError = String.isBlank(selectedClass) ? 'Please select class.' : null;
        genderError = String.isBlank(selectedGender) ? 'Please select gender.' : null;
        statusError = String.isBlank(selectedStatus) ? 'Please select status.' : null;

        return (classError != null || genderError != null || statusError != null);
    }

    /**
	* validateBirthday
	* Validate the birthday of Student__c
	* @param none
	* @return Boolean
	* @created: 2024/09/12 Huynh Phuoc
	* @modified: 
	*/
    public Boolean validateBirthday() {
        Date currentDate = Date.today();
        Date birthDate = student.Birthday__c;
        Date eighteenYearsAgo = currentDate.addYears(-18).addDays(-1);

        return birthDate > eighteenYearsAgo;
    }

    /**
	* redirectToSearchPage
	* Redirect to VF_SearchStudent page
	* @param none
	* @return PageReference
	* @created: 2024/09/12 Huynh Phuoc
	* @modified: 
	*/
    public PageReference redirectToSearchPage() {
        PageReference pageRef = Page.VF_SearchStudent;
        pageRef.setRedirect(true);
        return pageRef;
    }
}