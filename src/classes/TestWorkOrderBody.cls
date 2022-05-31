/*
Class Name:					TestWorkOrderBody.apxc
Class Description:			Class is used to create workorder for urbanise using integration
Author:						Kshitij Tiwari
Created Date:				03/29/2022
Updated by:
Last Update Date:
*/
public class TestWorkOrderBody {
    
    public static String jsonRequestBody;
    
    public class PropertyDetails {
        public string title;
        public string description;
        public string externalReference;
        public Account1 account;
        public Property property;
        public JobTemplate jobtemplate;
        
    }
    Public class Account1
    {
        public string externalReference;
        
    }
    
    Public class Property
    {
        public string externalReference;
    }
    
    Public class JobTemplate 
    {
        public string priority;
        public JobTemplate1 jobTemplate1;
    }
    
    Public	class JobTemplate1 
    {
        public string reference;
    }
    /**
@description Creates an instance of the InnerClass class
Uses JSON.serialize to transform the InnerClass instance into a JSON formatted String
*/
    public static String getJsonRequestBody(){
        //Create the Request Body using an Inner Class
        Map<String,Urbanise__mdt> credentials = Urbanise__mdt.getAll();
        string jobTemplate =credentials.get('jobTemplate').Value__c;
        PropertyDetails pd = new PropertyDetails();
        pd.title ='test';
        pd.description ='test desc';
        pd.externalReference = 'test er';
        Account1 act = new Account1();
        act.externalReference ='test';
        pd.account = act;
        Property pr = new Property();
        pr.externalReference ='testpr';
        pd.property = pr;
        JobTemplate jt = new JobTemplate();
        jt.priority ='medium';
        pd.jobtemplate = jt;
        JobTemplate1 jt1 = new JobTemplate1();
        jt1.reference =jobTemplate;
        jt.jobTemplate1 = jt1;
        
        
        //use JSON.serialize to turn the inner class into a json formatted string
        jsonRequestBody = JSON.serialize(pd);
        system.debug('jsonRequestBody'+jsonRequestBody);
        return jsonRequestBody;
    }
    
    //Method to make a callout to Urbanise endpoint and push WorkOrder data
    public static void createWorkOrderCallout() {
        
        //Call a method to create the request body, this keeps our code nice and clean
        Map<String,Urbanise_Configuration__mdt> credentials = Urbanise_Configuration__mdt.getAll();
        String endPoint =credentials.get('WorkOrder_Creation').URL__c;
        system.debug('endPoint'+endPoint);
        String jsonRequestBody =   getJsonRequestBody();     
        if(String.isNotBlank(jsonRequestBody)) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod('post');
            
            //Add the json we created as the request body
            request.setBody(jsonRequestBody);
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                //Do something
            }
        }
    }
    
    
}