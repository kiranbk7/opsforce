public class OrderUpdateInvoker {

    public class OrderUpdateRequest {
        @InvocableVariable(required=true)
        public String user_prompt;
    }

    public class OrderUpdateResponse {
        @InvocableVariable(label='HTTP Status Code')
        public Integer statusCode;

        @InvocableVariable(label='Status')
        public String status;

        @InvocableVariable(label='Response Body')
        public String responseBody;

        @InvocableVariable(label='Error Message')
        public String errorMessage;
    }

    @InvocableMethod(label='Send Order Update' description='Send a user prompt to external order update service and capture response')
    public static List<OrderUpdateResponse> sendOrderUpdate(List<OrderUpdateRequest> requests) {
        List<OrderUpdateResponse> responses = new List<OrderUpdateResponse>();

        for (OrderUpdateRequest req : requests) {
            OrderUpdateResponse res = new OrderUpdateResponse();

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('http://65.1.38.179:8000/update-order');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');

            Map<String, String> payload = new Map<String, String>{
                'user_prompt' => req.user_prompt
            };
            request.setBody(JSON.serialize(payload));

            try {
                HttpResponse response = http.send(request);
                res.statusCode = response.getStatusCode();
                res.status = response.getStatus();
                res.responseBody = response.getBody();
            } catch (Exception e) {
                res.status = 'ERROR';
                res.errorMessage = e.getMessage();
            }

            responses.add(res);
        }

        return responses;
    }
}