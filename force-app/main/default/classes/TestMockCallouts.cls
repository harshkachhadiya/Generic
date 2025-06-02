@IsTest
public with sharing class TestMockCallouts implements HttpCalloutMock {
    
    private List<ResponseMock> callouts = new List<ResponseMock>();
    
    public class ResponseMock {
        public String endpoint;
        public Integer statusCode;
        public String body;
        private Boolean endpointStartsWithEnabled = false;
        
        public ResponseMock(String endpoint, Integer statusCode, String body) {
            this.endpoint = endpoint;
            this.statusCode = statusCode;
            this.body = body;
        }
        
        public void setEndpointStartsWithEnabled(Boolean endpointStartsWithEnabled) {
            this.endpointStartsWithEnabled = endpointStartsWithEnabled;
        }
    }
    
    public void add(ResponseMock callout) {
        this.callouts.add(callout);
    }
    
    public HttpResponse respond(HttpRequest request) {
        
        String requestEndpoint = request.getEndpoint();
        
        HttpResponse response = new HttpResponse();
        
        for(ResponseMock callout : callouts) {
            
            if((callout.endpointStartsWithEnabled
                && requestEndpoint.startsWith(callout.endpoint))
               || requestEndpoint == callout.endpoint) 
            {
                response.setStatusCode(callout.statusCode);
                response.setBody(callout.body);
                
                return response;
            }
        }
        
        throw new CallOutException('Endpoint not found: ' + requestEndpoint);
    }
}