public class TestWorkOrderCallout {
    
   		public static string title;
		public static string description;
		public static string externalReference;
		public static Account account;
    	public static String body;
	//	public static Property property;
	//	public static JobTemplate jobtemplate;
	//	
	public static void calloutPrepration(){
        title ='Urbanise API Test 3';
        description ='Creating work orders programmatically test 3';
        externalReference ='NAK_ORACLE-WO-BDD2';
        Account acc = new Account();
        acc.name ='SALESFORCEACC-1';
        insert acc;
        Property__c p = new Property__c();
        p.id ='SALESFORCEACC-1';
        insert p;
        body = '{"title" :'+title+',"description": '+description+',"externalReference": '+externalReference+',"account": {	"externalReference": "SALESFORCEACC-1"},"property": {"externalReference": "SALESFORCE1-UNIT		},"jobTemplate":	{	"priority": "ROUTINE",	"jobTemplate":{		"reference": "JT-00000001"		}	}}';
        
    }

    
    Public static void testCallOut(){
        string token ='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjYWxlbmRhciI6bnVsbCwiY2FwYWJpbGl0aWVzIjpbIkFQUE9JTlRNRU5UX1RSQUNLSU5HX01BUF9FTkFCTEVEIiwiQVJFQV9ISUVSQVJDSFkiLCJBU1NFVFMiLCJBU1lOQ19BUEkiLCJCT09LSU5HUyIsIkJVREdFVFMiLCJDT05UUkFDVCIsIkNVU1RPTUVSX0NBTl9VU0VfQ1JFRElUIiwiRE9DVU1FTlRfVVBMT0FEIiwiRkFDSUxJVFlfQk9PS0lOR1MiLCJGQVNUX1RSQUNLX1JFR0lTVFJBVElPTiIsIkZPUkNFX0NSRUFURV9BU1NFVF9UWVBFUyIsIkdPT0dMRV9BTkFMWVRJQ1NfRU5BQkxFRCIsIklOVkVOVE9SWSIsIkpPQl9QVVJDSEFTRV9PUkRFUlMiLCJORVhUX0FDVElPTlMiLCJPUEVSQVRPUl9RVU9UQUJMRSIsIlBBVVNFX1NVQlNDUklQVElPTiIsIlBBWV9JTlZPSUNFX01BTlVBTExZIiwiUE9XRVJFRF9CWV9VUkJBTklTRSIsIlBSSU1BUllfU1VQUExJRVJfQ09OVEFDVCIsIlBVU0hfTk9USUZJQ0FUSU9OUyIsIlFVT1RBQkxFX0pPQlMiLCJSRUdJU1RFUl9PTl9QVVJDSEFTRSIsIlNFU19FTUFJTFMiLCJTVFJBVEFfQ0xJRU5UIiwiU1VQUExJRVJfQUdFTlRTIiwiU1VQUExJRVJfUkVTVUJNSVRfUVVPVEVfSU5WT0lDRSIsIlNVUlZFWVMiLCJUQVhfRVhDTFVTSVZFX09OTFkiLCJWQVJJQUJMRV9NQVJHSU5fT05fUkFURVMiXSwidXNlcl9uYW1lIjoic2FsZXNmb3JjZSIsImF1dGhvcml0aWVzIjpbIlJPTEVfRVhURVJOQUxfU1lTVEVNIl0sImNsaWVudF9pZCI6InVibm13YXJlIiwiYXVkIjpbInBsYXphIl0sImZ1bGxfbmFtZSI6InNhbGVzZm9yY2UiLCJ1c2VyX2lkIjpudWxsLCJwZXJtaXNzaW9ucyI6WyJleHRlcm5hbF9hY2Nlc3NfdG9fc3VwcG9ydF9yZXF1ZXN0cyIsImV4dGVybmFsX2FjY2Vzc190b19wcm9wZXJ0eSIsImV4dGVybmFsX2FjY2Vzc190b19jdXN0b21lcl9jYXJlIiwiZXh0ZXJuYWxfYWNjZXNzX3RvX3Byb2R1Y3Rfc3BlYyJdLCJzY29wZSI6WyJ3cml0ZSIsInJlYWQiXSwiZXhwIjoxNjQ2Nzg3NDE3LCJqdGkiOiJmNDk5NDIzYS03ZmI2LTRlYmItODY5Yy04MzZjZWJjNjE0MmEiLCJ0ZW5hbnQiOiJuYWtoZWVsc2IiLCJjcmVkZW50aWFsX2lkIjoiMTAyMTU1NSJ9.Jvr9FGOmMQP3yHYDxIiH7ITsOhTIJ_2DCAUWhpOF230';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://nakheel.sandbox.urbanise.com/plaza-api/v1/external/workorder');
        request.setHeader('Authorization','Bearer '+token);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Set the body as a JSON object
        request.setBody(body);
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if(response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
    }
    
    
    
}