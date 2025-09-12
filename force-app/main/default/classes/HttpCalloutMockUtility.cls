@IsTest
public with sharing class HttpCalloutMockUtility implements HttpCalloutMock {
    
    private List<ResponseMock> callouts = new List<ResponseMock>();

    public enum MatchingStrategy {
        EXACT,
        STARTS_WITH
        // future options: CONTAINS, REGEX, ENDS_WITH
    }
    
    public class ResponseMock {
        public String endpoint;
        public Integer statusCode;
        public String body;
        public MatchingStrategy endpointMatchingStrategy;
        
        public ResponseMock(String endpoint, Integer statusCode, String body) {
            this.endpoint = endpoint;
            this.statusCode = statusCode;
            this.body = body;
            this.endpointMatchingStrategy = MatchingStrategy.EXACT;
        }
        
        public ResponseMock withMatchingStrategy(MatchingStrategy endpointMatchingStrategy) {
            this.endpointMatchingStrategy = endpointMatchingStrategy;

            return this;
        }
    }
    
    public void add(ResponseMock callout) {
        this.callouts.add(callout);
    }
    
    public HttpResponse respond(HttpRequest request) {
        
        String requestEndpoint = request.getEndpoint();
        
        for(ResponseMock callout : callouts) {

            Boolean match = false;

            switch on callout.endpointMatchingStrategy {
                when EXACT {
                    match = requestEndpoint.equals(callout.endpoint);
                }
                when STARTS_WITH {
                    match = requestEndpoint.startsWith(callout.endpoint);
                }
            }
            
            if(match) {
                HttpResponse response = new HttpResponse();
                response.setStatusCode(callout.statusCode);
                response.setBody(callout.body);
                
                return response;
            }
        }
        
        throw new CallOutException('Endpoint not found: ' + requestEndpoint);
    }
}