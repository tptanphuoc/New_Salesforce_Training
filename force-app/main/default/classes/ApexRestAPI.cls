// Apex REST API class to perform CRUD operations on Attendee object
@RestResource(urlMapping='/v1/attendees/*') // Endpoint for the API
global class ApexRestAPI {
    // get all Attendees
    @HttpGet
    global static List<Attendee__c> getAttendees() {
        List<Attendee__c> attendees = new List<Attendee__c>();
        try {
            attendees = [SELECT Id, Name, Email__c, Phone__c, Company_Name__c 
                        FROM Attendee__c 
                        WITH SECURITY_ENFORCED];
            RestContext.response.statusCode = 200; // ok
        } catch (Exception e) {
            RestContext.response.statusCode = 500; // internal server error
            TransactionLogHandler.doHandleException(e, 'ApexRestAPI');
        }
        System.debug('varName >>: ' + attendees);
        return attendees;
        
    }

    // create Attendee
    @HttpPost
    global static String createAttendee(String name, String email, String phone, String companyName) {
        try {
            Attendee__c attendee = new Attendee__c();
            attendee.Name = name;
            attendee.Email__c = email;
            attendee.Phone__c = phone;
            attendee.Company_Name__c = companyName;
            insert attendee;
            RestContext.response.statusCode = 201; // created
            return 'Attendee created successfully';
        } catch (Exception e) {
            RestContext.response.statusCode = 500; // internal server error
            TransactionLogHandler.doHandleException(e, 'ApexRestAPI');
            return 'Error creating Attendee';
        }
    }

    // update Attendee
    @HttpPut
    global static String updateAttendee(String id, String name, String email, String phone, String companyName) {
        try {
            Attendee__c attendee = [SELECT Id, Name, Email__c, Phone__c, Company_Name__c 
                                    FROM Attendee__c 
                                    WHERE Id = :id
                                    WITH SECURITY_ENFORCED];
            attendee.Name = name;
            attendee.Email__c = email;
            attendee.Phone__c = phone;
            attendee.Company_Name__c = companyName;
            update attendee;
            RestContext.response.statusCode = 200; // ok
            return 'Attendee updated successfully';
        } catch (Exception e) {
            RestContext.response.statusCode = 500; // internal server error
            TransactionLogHandler.doHandleException(e, 'ApexRestAPI');
            return 'Error updating Attendee';
        }
    }

    // delete Attendee
    @HttpDelete
    global static String deleteAttendee() {
        RestRequest req = RestContext.request; // Get the request
        String attendeeId = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1); // Get the Attendee Id from the URI

        try {
            Attendee__c attendee = [SELECT Id FROM Attendee__c WHERE Id = :attendeeId WITH SECURITY_ENFORCED LIMIT 1];
            delete attendee;
            RestContext.response.statusCode = 204; // No Content
            return 'Attendee deleted successfully';
        } catch (QueryException e) {
            RestContext.response.statusCode = 404; // Not Found
            return 'Attendee not found';
        } catch (Exception e) {
            RestContext.response.statusCode = 500; // Internal Server Error
            TransactionLogHandler.doHandleException(e, 'ApexRestAPI');
            return 'Error deleting Attendee';
        }
    }
}