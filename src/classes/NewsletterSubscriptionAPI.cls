@RestResource(urlMapping='/Newperson/')
global with sharing class NewsletterSubscriptionAPI {
    
    @HttpPost
    global static JsonResponse doPost() {
        JsonResponse response = new JsonResponse();
        try {
            Map<String, Object> jsonMap = (Map<String, Object>) System.JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            String email = jsonMap.get('email').toString();
            String[] name = email.split('@');
            system.debug('name=='+name[0]);
            system.debug('email=='+email);
            boolean leadfound=false;
            boolean accountfound=false;
            List<Account> CheckAccounts = new List<Account>();
            List<Lead> CheckLead  = new List<Lead>();
            
            CheckLead = [SELECT Id, Name, Email, Company  FROM Lead WHERE Email =:email limit 1 ];
            CheckAccounts = [SELECT Id, Name FROM Account WHERE Email__c =:email limit 1 ];
            if (!CheckLead.isEmpty() ) {
                leadfound=true; 
            }
            if(!CheckAccounts.isEmpty()) {
                accountfound =true;
            }
            if(leadfound==true && accountfound==true) {
                Account acc = CheckAccounts[0];
                acc.Persona__c='Registered';
                acc.Name = name[0]; //jsonMap.get('name').toString();
                acc.email__c=jsonMap.get('email').toString();
                UPDATE acc;	
                response.Id = acc.id;
                response.status = 'Success';		
                //response.Message = ' Account Updated sucessfully!'; 
            }
            if(leadfound==false && accountfound==true) {
                Account acc = CheckAccounts[0];
                acc.Persona__c='Registered';
                acc.Name = name[0]; //jsonMap.get('name').toString();
                acc.email__c=jsonMap.get('email').toString();
                UPDATE acc;	
                
                response.Id = acc.id;
                response.status = 'Success';		
                //response.Message = ' Account Updated sucessfully!';
            }
            if(leadfound==true && accountfound==false) {
                Lead  led= CheckLead[0];
                led.Persona__c='Registered';
                UPDATE led;	
                response.Id = led.id;
                response.status = 'Success';		
                //response.Message = ' Lead updated successfully'; 
            }
            if(leadfound==false && accountfound==false) {
                Lead led = new Lead();
                led.Persona__c='Visitor';
                led.LastName = name[0] ; //jsonMap.get('name').toString();
                led.Email=jsonMap.get('email').toString();               
                Insert led;
                response.Id = led.id;
                //response.Message = 'Lead Created successfully!';
                response.status = 'Success';
            }  
        }
        
        catch (Exception e) {
            System.debug(e.getMessage());
            response.status = 'Failed! ';
            response.Message = e.getMessage();
            return response;
        }
        return response;
    }
    
    global class JsonResponse {
        public String Id;
        public String status;
        public String Message;
    }
}