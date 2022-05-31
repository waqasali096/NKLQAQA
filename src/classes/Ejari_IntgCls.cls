/* 
Created By: Taha Hamid
Description: This class will be used as a controller for EjariCmp lightning component
*/

public class Ejari_IntgCls {
    
    // Method to display the available methods for Ejari Integration
    @AuraEnabled
    public static Map<String,String> getEjariIntegration(){
        
        Map<String,String> EjariIntgMap = new  Map<String,String>();
        try{
            EjariIntgMap.put('CreatePendingTenancyContractRequest','Create Draft Ejari Request');
            EjariIntgMap.put('PrintTcByContractNumberToStream','Create Draft Ejari PDF');
            EjariIntgMap.put('EditTenancyContract','Update Draft Ejari');
            EjariIntgMap.put('ActivateTcByContractNumber','Activate Ejari');
            EjariIntgMap.put('PrintCertificateByContractNumberToStream','Create activated Ejari PDF'); 
            //EjariIntgMap.put('TCGetByContractNumber','TCGetByContractNumber');
            EjariIntgMap.put('TerminateTcByContractNumber','Terminate Ejari');
            EjariIntgMap.put('RenewTenancyContract','Renew Ejari');
            return EjariIntgMap;
        }
        catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return EjariIntgMap;
        }
    }
    
    // Method to select desired Ejari Method and then make the callout
    @AuraEnabled
    public static boolean selectEjari(string recordId, String methodName){
        system.debug('Taha>>' + recordId);
        boolean statusCode = False;
        EjariWrapperUtil objReturnWrap = new EjariWrapperUtil();
        try{
            Ejari_Integration_Credential__mdt ejariDetails = [select URL__c, Password__c, User_Name__c from Ejari_Integration_Credential__mdt
                                                                      where DeveloperName = 'Ejari_Credentials' Limit 1];
            
            objReturnWrap = Ejari_ServiceSelectorUtil.getServiceBody(recordId,methodName);
            if(objReturnWrap.body != 'Error')
            {
                Http h = new Http();
                HttpRequest req = new HttpRequest();                          
                system.debug(objReturnWrap.soapAction);
                system.debug(objReturnWrap.body);
                //String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                req.setEndpoint(ejariDetails.URL__c);
                req.setMethod('POST');              
                //req.setHeader('Authorization', authorizationHeader);
                req.setHeader('Content-Type', 'text/xml; charset=utf-8');
                req.setHeader('SOAPAction', objReturnWrap.soapAction);
                req.setBody(objReturnWrap.body);
                req.setTimeout(120000);
                system.debug(req);
                HttpResponse res = null;
                res = h.send(req);  
                system.debug(res);               
                system.debug(res.getBody());               
                if(res.getStatusCode() == 200){                       
                    // call the respective xml decoder for the print ejari related callouts
                    if(methodName == 'PrintTcByContractNumberToStream' || methodName == 'PrintCertificateByContractNumberToStream')
                    {
                        Ejari_XMLDecoderUtil.xmlDecoderPrintCertificate(methodName,res.getBody(),recordId);
                    }
                    else
                    {
                        Ejari_XMLDecoderUtil.xmlDecoderEjari(methodName,res.getBody(),recordId);
                    }
                    LoggerUtility.logException( null, objReturnWrap.body, res.getBody());
                    statusCode = True;
                    return statusCode;
                }
                else{
                    Ejari_XMLDecoderUtil.updateRequestResponse(recordId, res.getBody());
                    LoggerUtility.logException( null, objReturnWrap.body, res.getBody());
                }
            }
            
            return statusCode;            
        }
        catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            Ejari_XMLDecoderUtil.updateRequestResponse(recordId, e.getMessage());
            LoggerUtility.logException( e, 'Error', 'Error');
            return statusCode;
        }

    }
     

}