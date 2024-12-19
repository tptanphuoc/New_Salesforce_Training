public with sharing class ContactController {
    @AuraEnabled
    public static List<Contact> getAllContacts(Id recordId){
        try {
            List<Contact> contactList = new List<Contact>();
            contactList = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE AccountId =:recordId];
            return contactList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}