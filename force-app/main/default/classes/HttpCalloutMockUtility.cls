@IsTest
public with sharing class HttpCalloutMockUtility implements HttpCalloutMock {

    /**
     * Utility class for mocking HTTP callouts in Apex tests.
     * 
     * BASIC USAGE:
     * 
     *   HttpCalloutMockUtility mock = new HttpCalloutMockUtility()
     *       .add('https://api.example.com/users', 200, '{"ok":true}');
     * 
     *   Test.setMock(HttpCalloutMock.class, mock);
     *   Test.startTest();
     *       MyClass.doCallout();
     *   Test.stopTest();
     * 
     * MULTIPLE ENDPOINTS:
     * 
     *   HttpCalloutMockUtility mock = new HttpCalloutMockUtility()
     *       .add('https://api.example.com/users', 200, '{"ok":true}')
     *       .add('https://api.example.com/orders', 404, '{"error":"not found"}');
     * 
     * STARTS_WITH MATCHING (useful for endpoints with dynamic segments):
     * 
     *   HttpCalloutMockUtility mock = new HttpCalloutMockUtility()
     *       .add(new HttpCalloutMockUtility.ResponseMock('https://api.example.com/users', 200, '{"ok":true}')
     *           .withMatchingStrategy(HttpCalloutMockUtility.MatchingStrategy.STARTS_WITH));
     * 
     * HTTP METHOD MATCHING (same endpoint, different methods):
     * 
     *   HttpCalloutMockUtility mock = new HttpCalloutMockUtility()
     *       .add(new HttpCalloutMockUtility.ResponseMock('https://api.example.com/users', 200, '{"ok":true}')
     *           .withHttpMethod('GET'))
     *       .add(new HttpCalloutMockUtility.ResponseMock('https://api.example.com/users', 201, '{"created":true}')
     *           .withHttpMethod('POST'));
     */

    private List<ResponseMock> callouts = new List<ResponseMock>();

    public enum MatchingStrategy {
        EXACT,
        STARTS_WITH
        // future options: CONTAINS, REGEX, ENDS_WITH
    }

    public class ResponseMock {

        private String endpoint;
        private Integer statusCode;
        private String body;
        private String httpMethod;
        private MatchingStrategy endpointMatchingStrategy;

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

        public ResponseMock withHttpMethod(String httpMethod) {
            this.httpMethod = httpMethod;
            return this;
        }
    }

    public HttpCalloutMockUtility add(ResponseMock callout) {
        this.callouts.add(callout);
        return this;
    }

    public HttpCalloutMockUtility add(String endpoint, Integer statusCode, String body) {
        this.callouts.add(new ResponseMock(endpoint, statusCode, body));
        return this;
    }

    public HttpResponse respond(HttpRequest request) {

        String requestEndpoint = request.getEndpoint();
        String requestMethod = request.getMethod();

        for (ResponseMock callout : callouts) {

            Boolean endpointMatch = false;

            switch on callout.endpointMatchingStrategy {
                when EXACT {
                    endpointMatch = requestEndpoint.equals(callout.endpoint);
                }
                when STARTS_WITH {
                    endpointMatch = requestEndpoint.startsWith(callout.endpoint);
                }
            }

            Boolean methodMatch = callout.httpMethod == null
                || callout.httpMethod.equalsIgnoreCase(requestMethod);

            if (endpointMatch && methodMatch) {
                HttpResponse response = new HttpResponse();
                response.setStatusCode(callout.statusCode);
                response.setBody(callout.body);
                return response;
            }
        }

        throw new CalloutException('Endpoint not found: ' + requestEndpoint);
    }
}