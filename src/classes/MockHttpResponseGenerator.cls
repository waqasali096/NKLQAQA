@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"OutputParameters" : {"X_PROPERTY_ID" : null, "X_RETURN_STATUS" : "E", "X_MSG_COUNT" : "1", "X_MSG_DATA" : "Invalid Org ID passed"}}');
        res.setStatusCode(200);
        return res;
    }
}