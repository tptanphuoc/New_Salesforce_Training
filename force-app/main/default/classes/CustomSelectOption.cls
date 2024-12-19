/**
 * クラス名       :	CustomSelectOption
 * クラス概要     :	A helper class to represent select options for dropdowns in Lightning Components
 * @created      :  2024/09/30 Huynh Phuoc
 * @modified 	:   
 */
public without sharing class CustomSelectOption {
    
    // The display label of the select option
    @AuraEnabled
    public String label { get; set; }
    
    // The value associated with the select option
    @AuraEnabled
    public String value { get; set; }
    
    // Indicates whether the select option is disabled
    @AuraEnabled
    public Boolean disabled { get; set; }

    /**
     * CustomSelectOption (Default Constructor)
     * Initializes a new instance of the CustomSelectOption class with default values
     * @created: 2024/09/30 Huynh Phuoc
     * @modified: 
     */
    public CustomSelectOption() {
        this.value = value;
        this.label = label;
        this.disabled = false;
    }

    /**
     * CustomSelectOption (Parameterized Constructor)
     * Initializes a new instance of the CustomSelectOption class with specified values
     * @param value        The value to be associated with the select option
     * @param label        The display label of the select option
     * @param isDisabled   Indicates whether the select option should be disabled
     * @created: 2024/09/30 Huynh Phuoc
     * @modified: 
     */
    public CustomSelectOption(String value, String label, Boolean isDisabled) {
        this.value = value;
        this.label = label;
        this.disabled = isDisabled;
    }
}