/*
    Description: This class will be used to decode XML received from Ejari Server as a response
*/
public class Ejari_XMLDecoderUtil {
    
    // Method to decode the XML for print certificate methods
    public static void xmlDecoderPrintCertificate(string methodName, string xmlBody,String leasingContractId)
    {   system.debug('@@Inside Print Certificate: xml'+xmlBody);
        system.debug('@@Inside Print Certificate: methodName'+methodName); 
        try
        {
            map<string,string> mapXML = new map<string,string>();
            mapXML = generateXMLIdentifier();
            Boolean returnVal = false; 
            Dom.Document doc = new Dom.Document();
            doc.load(xmlBody);
            Dom.XMLNode rootElement = doc.getRootElement();
            
            for (Dom.XMLNode childElement: rootElement.getChildElements()) 
            {
                system.debug('@@Child Element:'+childElement);
                for (Dom.XMLNode detailElement: childElement.getChildElements()) 
                {
                    for (Dom.XMLNode detailElementLvlOne: detailElement.getChildElements()) 
                    {
                    
                        system.debug('@@Detail Node :'+detailElementLvlOne);
                        system.debug('@@Detail Node Name :'+detailElementLvlOne.getName());
                        if (detailElementLvlOne.getName() == mapXML.get(methodName)) 
                        {
                            system.debug('@@detailElementLVOne :'+detailElementLvlOne.getText());
                            if(detailElementLvlOne.getName() == 'PrintTcByContractNumberToStreamResult'){
                                createDraftEjariDocument(detailElementLvlOne.getText(),leasingContractId);
                            }else if(detailElementLvlOne.getName() == 'PrintCertificateByContractNumberToStreamResult'){
                                createActiveEjariDocument(detailElementLvlOne.getText(),leasingContractId);
                            }
                            
                        }
                    }    
                }
            }
        
        }

        catch(exception e)
        {
            system.debug('error: ' + e.getMessage() + ' At line:' + e.getLineNumber());           
        }
    }

    // Method to decode the XML for Create, Edit & Renew Ejari Services
    public static void xmlDecoderEjari(string methodName, string xmlBody,String leasingContractId)
    {
        try
        {
            map<string,string> mapXML = new map<string,string>();
            map<string,string> statusMap = new map<string,string>();
            mapXML = generateXMLIdentifier();
            statusMap = generateEjariStatusIdentifier();
            Boolean returnVal = false; 
            Dom.Document doc = new Dom.Document();
            doc.load(xmlBody);
            Dom.XMLNode rootElement = doc.getRootElement();
            ResponseWrapper responseWrap = new ResponseWrapper();
            responseWrap.ContractId = leasingContractId;  
            for (Dom.XMLNode childElement: rootElement.getChildElements()) 
            {
                system.debug('@@Child Element :'+childElement);
                for (Dom.XMLNode detailElement: childElement.getChildElements()) 
                {
                    for (Dom.XMLNode detailElementLvlOne: detailElement.getChildElements()) 
                    {                        
                        system.debug(detailElementLvlOne);
                        system.debug(detailElementLvlOne.getName());
                        if (detailElementLvlOne.getName() == mapXML.get(methodName)){
                            system.debug('@@@'+detailElementLvlOne.getText());
                            responseWrap.Message = detailElementLvlOne.getText();
                            if(responseWrap.Message == 'NoErrors')responseWrap.Status = statusMap.get(methodName);
                        }else if(detailElementLvlOne.getName() == 'ContractNumber'){
                            responseWrap.ContractNumber = detailElementLvlOne.getText();
                        }else if(detailElementLvlOne.getName() == 'TenantNumber'){
                            responseWrap.TenantNumber = detailElementLvlOne.getText();
                        }
                    }    
                }
            }
            responseWrap.Response = JSON.serialize(responseWrap);
            system.debug('@@Response Wrapper'+responseWrap);
            updateContract(responseWrap);
            
        }
    
        catch(exception e)
        {
            system.debug('error: ' + e.getMessage() + ' At line:' + e.getLineNumber());           
        }
    }

    /* Method to get the mapping for the child tag which will be received as a response from Ejari 
       and then in Salesforce, need to parse it and do the desired action
    */   
    public static map<string,string> generateXMLIdentifier()
    {
        map<string,string> mapXML = new map<string,string>();
        mapXML.put('PrintCertificateByContractNumberToStream','PrintCertificateByContractNumberToStreamResult');
        mapXML.put('PrintTcByContractNumberToStream','PrintTcByContractNumberToStreamResult');       
        mapXML.put('RenewTenancyContract','RenewPendingTenancyContractResult');       
        mapXML.put('CreatePendingTenancyContractRequest','CreatePendingTenancyContractRequestResult');       
        mapXML.put('EditTenancyContract','EditTenancyContractResult');   
        mapXML.put('ActivateTcByContractNumber','ActivateTcByContractNumberResult'); 
        mapXML.put('TerminateTcByContractNumber','TerminateTcByContractNumberResult');   
        
        return mapXML;
    }

    /* Method to get the mapping for the child tag which will be received as a response from Ejari 
       and then in Salesforce, need to parse it and do the desired action
    */   
    public static map<string,string> generateEjariStatusIdentifier()
    {
        map<string,string> mapXML = new map<string,string>();
        mapXML.put('PrintCertificateByContractNumberToStream','Activated Ejari PDF Created');
        mapXML.put('PrintTcByContractNumberToStream','Draft Ejari Document Created');       
        mapXML.put('RenewTenancyContract','Ejari Renewed');       
        mapXML.put('CreatePendingTenancyContractRequest','Draft Ejari Created');       
        mapXML.put('EditTenancyContract','Draft Ejari Updated');  
        mapXML.put('ActivateTcByContractNumber','Ejari Activated'); 
        mapXML.put('TerminateTcByContractNumber','Ejari Terminated');       
        
        return mapXML;
    }
    
    // Method to create Draft Ejari Certificate and store it in Salesforce
    public static void createDraftEjariDocument(String pdfString, String leasingContractId){

        try
        {   
            Object_Document__c ejariObjDoc = new Object_Document__c();

            Document__c doc =  [SELECT id FROM Document__c WHERE Document_Type__c = 'Draft Ejari Contract'
                                  and Object__c = 'Lease_Contract__c' and Contract__c =:leasingContractId limit 1];
            
             /*
                * Creating-Content version for Content-Document
            */
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Draft Ejari Document.pdf';
            cv.PathOnClient = 'DraftEjariDocument.pdf';
            cv.VersionData = EncodingUtil.base64Decode(pdfString);
            cv.IsMajorVersion = true;
            insert cv;
    
            /*
             * Getting Content-Document ID
            */
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            /*
             * Creating Content Document Link
            */
            system.debug('@@EjariConId'+conDocId);
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = doc.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            insert cdl;
        }

        catch(exception ex)
        {
            system.debug(ex.getMessage());
        }
      
       
    }

    // Method to create Active Ejari Certificate and store it in Salesforce
    public static void createActiveEjariDocument(String pdfString, String leasingContractId){

        try
        {   
            Object_Document__c ejariObjDoc = new Object_Document__c();

            Document__c doc =  [SELECT id FROM Document__c WHERE Document_Type__c = 'Activated Ejari Contract'
                                  and Object__c = 'Lease_Contract__c' and Contract__c =:leasingContractId limit 1];
            
             /*
                * Creating-Content version for Content-Document
            */
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Activated Ejari Contract.pdf';
            cv.PathOnClient = 'ActivatedEjariContract.pdf';
            cv.VersionData = EncodingUtil.base64Decode(pdfString);
            cv.IsMajorVersion = true;
            insert cv;
    
            /*
             * Getting Content-Document ID
            */
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            /*
             * Creating Content Document Link
            */
            system.debug('@@EjariConId'+conDocId);
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = doc.Id;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            insert cdl;
        }

        catch(exception ex)
        {
            system.debug(ex.getMessage());
        }
      
       
    }

    /**********************************************************************************************
    * @Description  : Method to update checkboxes or Ejari Response.
    * @Return       : void
     * @Author       : Sajid Hameed
    **********************************************************************************************/
    public static void updateContractTriggerCheckboxes(String recordId, String response) {
      
        List < Lease_Contract__c > updateContract = new List < Lease_Contract__c > ();
        List < Lease_Contract__c > Contract = [Select Id, Trigger_Activate_Ejari_Contract__c, Trigger_Create_Draft_Ejari__c,
            Trigger_Download_Draft_Ejari_Document__c, Trigger_Download_Final_Ejari_certificate__c,
            Trigger_Edit_Draft_Ejari_Document__c, Trigger_Renew_Ejari_Contract__c, Trigger_Terminate_Ejari_Contract__c,
            Ejari_Response__c from Lease_Contract__c where Id =: recordId
        ];

        for (Lease_Contract__c Cont: Contract) {

            Cont.Trigger_Activate_Ejari_Contract__c = false;
            Cont.Trigger_Create_Draft_Ejari__c = false;
            Cont.Trigger_Download_Draft_Ejari_Document__c = false;
            Cont.Trigger_Download_Final_Ejari_certificate__c = false;
            Cont.Trigger_Edit_Draft_Ejari_Document__c = false;
            Cont.Trigger_Renew_Ejari_Contract__c = false;
            Cont.Trigger_Terminate_Ejari_Contract__c = false;
            Cont.Ejari_Response__c = response;


            updateContract.add(Cont);
        }

        if (updateContract.size() > 0) {
            update updateContract;
        }
    }  
    
    /**********************************************************************************************
    * @Description  : Method to update Ejari Response on contract
    * @Return       : void
    * @Author       : Karishma Kotian
    **********************************************************************************************/
    @AuraEnabled
    public static void updateContract(ResponseWrapper responseWrap){
        if(responseWrap.ContractId != null){
            Lease_Contract__c contract = [SELECT Id, Account__c, Account__r.Tenant_Number__c, Ejari_Response__c, Contract_Number__c,Ejari_Status__c,Ejari_Message__c
                                             FROM Lease_Contract__c WHERE Id=: responseWrap.ContractId];
            contract.Id = responseWrap.ContractId;
            contract.Ejari_Response__c = responseWrap.Response;
            contract.Ejari_Message__c = responseWrap.Message;
            contract.Ejari_Status__c = responseWrap.Status;
            contract.Contract_Number__c = responseWrap.ContractNumber != null ? responseWrap.ContractNumber : contract.Contract_Number__c;
            system.debug('@@@Ejari Contract update :'+contract);
            update contract;

            if(responseWrap.TenantNumber != null){
               Account account = new Account();
               account.Id = contract.Account__c;
               account.Tenant_Number__c =  responseWrap.TenantNumber;
               system.debug('@@@Ejari Account Tenancy update :'+account);
               update account;
            }
        }
        
    }

    /**********************************************************************************************
    * @Description  : Method to update Ejari Response.
    * @Return       : void
    * @Author       : Sajid Hameed
    * @Modified by  : Karishma Kotian
    * @Modification : params updated from String Reponse, String Record Id to ResponseWrapper 
                        & accordingly changed the method 
    **********************************************************************************************/
    @AuraEnabled
    public static void updateRequestResponse(String recordId, String response){
        if(recordId != null){
            Lease_Contract__c contract = [SELECT Id, Ejari_Response__c
                                             FROM Lease_Contract__c WHERE Id=: recordId];
            contract.Id = recordId;
            contract.Ejari_Response__c = response;
            update contract;
        }
        
    }
    
    public class ResponseWrapper{
        public String Code {get;set;}
        public String Message {get;set;}
        public String ContractNumber {get; set;}
        public String TenantNumber {get;set;}
        public String Response {get;set;}
        public String ContractId {get;set;}
        public String Status {get;set;}
    }

}