public with sharing class PredictionService {
    
    public class PredictionRequestBody {
        @InvocableVariable public String name;
        @InvocableVariable public String location;
        @InvocableVariable public String rest_type;
        @InvocableVariable public String approx_cost_for_two;
        @InvocableVariable public String rate;
        @InvocableVariable public Integer votes;
    
        // Optional: Method to serialize this to JSON
        public String toJson() {
            return JSON.serializePretty(this);
        }
	}

    public class PredictionResponse {
        @InvocableVariable public String restaurantName;
        @InvocableVariable public String segment;
        @InvocableVariable public String recommendedProductName;
        @InvocableVariable public String recommendedProductFamily;
        @InvocableVariable public Integer productUnitSize;
    
        // Optional: Method to serialize this to JSON
        public String toJson() {
            return JSON.serializePretty(this);
        }
	}
    
	public static PredictionResponse fromMap(Map<String, Object> raw) {
        PredictionResponse result = new PredictionResponse();
        result.restaurantName = (String) raw.get('Restaurant Name');
        result.segment = (String) raw.get('Segment');
        result.recommendedProductName = (String) raw.get('Recommended Product Name');
        result.recommendedProductFamily = (String) raw.get('Recommended Product Family');
        result.productUnitSize = (raw.containsKey('Product Unit Size')) ? Integer.valueOf(String.valueOf(raw.get('Product Unit Size'))) : null;
        return result;
    }
    
    // Main method to call SageMaker
    public static String invokeSageMaker(String payload) {
        try {
            HttpRequest req = new HttpRequest();
            // Named Credential callout
            req.setEndpoint('callout:SagemakerAPIKey');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-api-key', '{!$Credential.Password}');
            req.setTimeout(60000); // 60 seconds timeout

            req.setBody(payload);
            
            Http http = new Http();
            
            System.debug('SageMaker Request Header: ' + req.getHeader('x-api-key'));
            System.debug('SageMaker Request Body: ' + req.getBody());

            HTTPResponse res = http.send(req);
            
            Integer statusCode = res.getStatusCode();
            String responseBody = res.getBody();
            
            System.debug('SageMaker Response Status: ' + statusCode);
            System.debug('SageMaker Response Body: ' + responseBody);

            if (statusCode >= 200 && statusCode < 300) {
                // Success
                return responseBody;
            } else {
                // Error
                throw new CalloutException('SageMaker call failed. Status: ' + statusCode + ' Body: ' + responseBody);
            }
            
        } catch (Exception e) {
            System.debug('Error during SageMaker call: ' + e.getMessage());
            throw new CalloutException('SageMaker callout error: ' + e.getMessage());
        }
    }
    
    public static List<PredictionResponse> parseResponse(string responseBody){
        Map<String, Object> res = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        String rawBody = (String) res.get('body');
        List<Object> resultList = (List<Object>) JSON.deserializeUntyped(rawBody);
    
        List<PredictionResponse> parsedResults = new List<PredictionResponse>();
        for (Object o : resultList) {
            Map<String, Object> item = (Map<String, Object>) o;
            PredictionResponse parsed = PredictionResponse.fromMap(item);
            parsedResults.add(parsed);
        }
        return parsedResults;
    }
    
    @InvocableMethod(label='Make SageMakerAPI Callout' )
    public static List<PredictionResponse> makeApiCallout(List<PredictionRequestBody> requests) {
        List<PredictionResponse> responses = new List<PredictionResponse>();
        for (PredictionRequestBody req : requests) {
			system.debug('request from flow: '+JSON.serializePretty(req));
            String responseStr = invokeSageMaker(JSON.serialize(req));
            system.debug('responseStr '+responseStr);
            responses = parseResponse(responseStr);
            system.debug('response to flow: '+JSON.serializePretty(responses));
        }
        return responses;
    }
    
    //TEST
    /*PredictionService.PredictionRequestBody r = new PredictionService.PredictionRequestBody();
    r.name = 'luxury bites';
    r.location = 'Banshankari';
    r.rest_type = 'Cafe';
    r.approx_cost_for_two = '5000';
    r.rate = '5';
    r.votes = 1000;
    
    PredictionService.makeApiCallout(new list<PredictionService.PredictionRequestBody>{r});*/
}