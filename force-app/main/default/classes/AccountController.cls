public with sharing class AccountController {
    @AuraEnabled
    public static List<Account> getAllAccounts(){
        try {
            List<Account> accountList = new List<Account>();
            accountList = [SELECT Id, Name FROM Account LIMIT 5];
            return accountList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}