// The handler class for the LocationVerifyAPITrigger
// Will call an external API (https://www.smarty.com/products/apis/us-street-api) to verify the Location is valid or not
// If valid, auto check the Verified checkbox in Location object
public with sharing class LocationVerifyAPITriggerHandler {
    // The async method to call the external API
    @future(callout=true)
    public static void verifyAddress(String recordId) {
        // SELECT a Location base on recordId
        Location__c loc = [SELECT Id, Name, Street__c, City__c, Postal_Code__c, State__c, Verified__c 
                           FROM Location__c WHERE Id =: recordId];

        //https://us-street.api.smarty.com/street-address?auth-id=a4922ca4-b849-3b2a-e9e0-a8f3054bd8a6&auth-token=6uc3ldX0trNfrWROu473&street=&city=&state=&zipcode=&match=invalid
        String baseURL = 'https://us-street.api.smarty.com/street-address?auth-id=a4922ca4-b849-3b2a-e9e0-a8f3054bd8a6&auth-token=6uc3ldX0trNfrWROu473';
        baseURL+= '&street='+EncodingUtil.urlEncode(loc.Street__c, 'UTF-8')
                 +'&city='+EncodingUtil.urlEncode(loc.City__c, 'UTF-8')
                 +'&state='+EncodingUtil.urlEncode(loc.State__c, 'UTF-8')
                 +'&zipcode='+EncodingUtil.urlEncode(loc.Postal_Code__c, 'UTF-8')
                 +'&match=invalid&license=us-core-cloud';
        // Prepare the HttpRequest
        HttpRequest request = new HttpRequest();
        request.setMethod('GET'); // Set Http method to GET
        request.setHeader('Content-Type', 'application/json'); // Set header of request as JSON
        request.setEndpoint(baseURL); // Access to this dynamic endpoint
        // Create Http object to send the HttpRequest
        Http http = new Http();
        // Prepare the response
        HttpResponse response = new HttpResponse();
        
        try {
            // Send request and catch the response result
            response = http.send(request);
            System.debug('ResponseBOdy: ' + response.getBody());
            // If request is SUCCESS (StatusCode is 200)
            if (response.getStatusCode() == 200 && response.getStatus() == 'OK') {
                String responseBody = response.getBody();
                // If responseBody is not blank
                if (!String.isBlank(responseBody) && responseBody.length() > 2) { // [] is the default response
                    loc.Verified__c = true; // true => check the Verified checkbox of Location object
                } else {
                    loc.Verified__c = false;
                }
                update loc; // Update the Location object (loc)
            } else {
                TransactionLogHandler.doHandleExceptionWithError(response.getBody(), 'LocationVerifyAPITriggerHandler');
            }
        } catch (CalloutException ex) {
            System.debug('Exception: ' + ex.getStackTraceString());
            TransactionLogHandler.doHandleException(ex, 'LocationVerifyAPITriggerHandler');
        }
    }
}