public with sharing class CustomSearchController {
    
    @AuraEnabled
    public static String searchRecords(String objName, String fieldName, String searchKey){
        String searchKeyword = searchKey + '*';
        String returningQuery = objName+' ( Id, '+fieldName+')';
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 200';
        List<List<sObject>> sobjectList = Search.query(query);
        return JSON.serialize(sobjectList);
    }
}