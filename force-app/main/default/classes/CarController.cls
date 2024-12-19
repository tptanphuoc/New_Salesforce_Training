public with sharing class CarController {

    public class SearchCriterias {
        @AuraEnabled
        public String name {get;set;}

        @AuraEnabled
        public Decimal maxPrice {get;set;}

        @AuraEnabled
        public String[] carCategories {get;set;}

        @AuraEnabled
        public String[] carMakes {get;set;}
    }    

    @AuraEnabled(cacheable=true)
    public static List<Car__c> getAllCars(SearchCriterias searchCriterias) {
        String carName, whereClause = '';
        Decimal maxPrice;
        String[] carCategories, carMakes, criterias = new List<String>();

        if (searchCriterias != null) {
            maxPrice = searchCriterias.maxPrice ?? maxPrice; ///
            carCategories = searchCriterias.carCategories ?? carCategories;
            carMakes = searchCriterias.carMakes ?? carMakes;
            if (!String.isEmpty(searchCriterias.name)) {
                carName = '%' + searchCriterias.name + '%';
                criterias.add('Name LIKE: carName');
            }
            if (searchCriterias.maxPrice > 0) {
                criterias.add('MSRP__c <= :maxPrice');
            }
            if (searchCriterias.carCategories != null) {
                criterias.add('Category__c IN :carCategories');
            }
            if (searchCriterias.carMakes != null) {
                criterias.add('Make__c IN :carMakes');
            } 
            if (criterias.size() > 0) {
                whereClause = 'WHERE ' + String.join(criterias, ' AND '); ///
            }
        }

        String query = 'SELECT Id, Name, MSRP__c, Description__c, Category__c, Picture_URL__c FROM Car__c '
                    + whereClause // append the dynamic WHERE clause
                    + ' WITH SECURITY_ENFORCED' // apply security query
                    + ' ORDER BY Name'; // sort car by name

        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static Car__c[] getSimilarCars(Id carId, String[] makeTypes){
        try {
            return [SELECT Id, Name, MSRP__c, Description__c, Category__c, Picture_URL__c, Make__c FROM Car__c WHERE Make__c IN :makeTypes AND Id != :carId]; // Get all similar Cars by MakeType except the current Car
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}