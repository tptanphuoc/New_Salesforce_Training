public with sharing class PropertyController {

    // Get all the Property
    @AuraEnabled
    public static List<Property__c> getLastestProperty(){
        try {
            List<Property__c> allPropertyList = new List<Property__c>();
            allPropertyList = [SELECT Id,
                                        Additional_Room__c,
                                        Available_From__c,
                                        Carpet_area_sqft__c,
                                        Coverd_area_sqft__c,
                                        Electricity_Status__c,
                                        Facing__c,
                                        Floor__c,
                                        For_Bachellor__c,
                                        For_Family__c,
                                        Furnishning_Available__c,
                                        Furnished_Type__c,
                                        Geo_Map__c,
                                        LandMark__c,
                                        Location__c,
                                        Area__c,
                                        street__c,
                                        State__c,
                                        country__c,
                                        Maintainance_Charge__c,
                                        No_of_Balcony__c,
                                        No_of_Bath_Room__c,
                                        No_of_Bed_Room__c,
                                        Property_Description__c,
                                        Property_Main_Image__c,
                                        Property_Owner__c,
                                        Property_Video_URL__c,
                                        Name,
                                        Rent__c,
                                        Security_Deposit__c,
                                        Status__c,
                                        Verified__c,
                                        Water_Availability__c
                                FROM Property__c LIMIT 20];
            return allPropertyList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Get details of a Property
    @AuraEnabled
    public static Property__c getPropertyDetails(Id propertyId){
        try {
            Property__c prop = [SELECT Id,
                                        Additional_Room__c,
                                        Available_From__c,
                                        Carpet_area_sqft__c,
                                        Coverd_area_sqft__c,
                                        Electricity_Status__c,
                                        Facing__c,
                                        Floor__c,
                                        For_Bachellor__c,
                                        For_Family__c,
                                        Furnishning_Available__c,
                                        Furnished_Type__c,
                                        Geo_Map__c,
                                        LandMark__c,
                                        Location__c,
                                        Area__c,
                                        street__c,
                                        State__c,
                                        country__c,
                                        Maintainance_Charge__c,
                                        No_of_Balcony__c,
                                        No_of_Bath_Room__c,
                                        No_of_Bed_Room__c,
                                        Property_Description__c,
                                        Property_Main_Image__c,
                                        Property_Owner__c,
                                        Property_Video_URL__c,
                                        Name,
                                        Rent__c,
                                        Security_Deposit__c,
                                        Status__c,
                                        Verified__c,
                                        Water_Availability__c
                                FROM Property__c WHERE Id=:propertyId
                                LIMIT 1];
            return prop;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static List<Property__c> getFilteredProperties(String location, String bedroom, String bathroom, String maxbudget){
        try {
            List<Property__c> filteredProperties = new List<Property__c>();

            String propertyQuery = 'SELECT Id,Additional_Room__c,Available_From__c,Carpet_area_sqft__c,Coverd_area_sqft__c,Electricity_Status__c,';
            propertyQuery = propertyQuery+'Facing__c,Floor__c,For_Bachellor__c,For_Family__c,Furnished_Type__c,Furnishning_Available__c,Geo_Map__c,';
            propertyQuery = propertyQuery +'Landmark__c, Area__c,street__c,State__c,country__c,Location__c,Maintainance_Charge__c,No_of_Balcony__c,No_Of_Bath_Room__c,No_Of_Bed_Room__c,';
            propertyQuery = propertyQuery +' Property_Description__c,Property_Main_Image__c,Property_Video_URL__c,Name,Rent__c,Security_Deposit__c,Status__c,Verified__c,Water_Availability__c';
            propertyQuery = propertyQuery +' FROM Property__c ';
            String whereClause = 'WHERE Rent__c!=NULL';

            if(String.isNotBlank(location)) { // if user select Location option
                if(location !='ALL'){
                    whereClause = whereClause +' AND Area__c = :location';
                }
            }

            Integer bedroomCount;
            if(String.isNotBlank(bedroom)) { // if user select Bedroom option
                if(bedroom !='ALL'){
                    bedroomCount = Integer.valueOf(bedroom);
                    whereClause = whereClause +' AND No_Of_Bed_Room__c=:bedroomCount';
                }
            }

            integer bathroomCount;
            if(string.isNotBlank(bathroom)){ // if user select Bathroom option
                if(bathroom !='ALL'){
                    bathroomCount= Integer.valueOf(bathroom);
                    whereClause = whereClause +' AND No_Of_Bath_Room__c=:bathroomCount';
                }
            }

            double maxBudgetValue;
            if(string.isNotBlank(maxbudget)){ // if user enter MaxPrice option
                maxBudgetValue = Double.valueOf(maxbudget);
                whereClause = whereClause+ ' AND Rent__c<=:maxBudgetValue';
            }

            propertyQuery = propertyQuery +' '+ whereClause; // combine the completed query
            filteredProperties = Database.query(propertyQuery); // use completed query to query final result 
            return filteredProperties;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}