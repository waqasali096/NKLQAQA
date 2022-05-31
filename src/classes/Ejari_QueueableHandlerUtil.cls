/*  Description: Utility class to call Ejari Service from trigger context
Created Date: 06-02-2021
*/

public class Ejari_QueueableHandlerUtil {

    public class Ejari_QueueableCreateEjari implements Queueable, Database.AllowsCallouts {

        String recordId;
        String methodName;
        public Ejari_QueueableCreateEjari(String recordId, String methodName) {
            this.recordId = recordId;
            this.methodName = methodName;
        }

        public void execute(QueueableContext context) {
            try {

                Ejari_Integration_Credential__mdt ejariDetails = [select URL__c, Password__c, User_Name__c from Ejari_Integration_Credential__mdt
                    where DeveloperName = 'Ejari_Credentials'
                    Limit 1
                ];
                EjariWrapperUtil objReturnWrap = new EjariWrapperUtil();
                objReturnWrap = Ejari_ServiceSelectorUtil.getServiceBody(recordId, methodName);
                system.debug('objReturnWrap :'+objReturnWrap);
                if (objReturnWrap.body != 'Error') {
                    Http h = new Http();
                    HttpRequest req = new HttpRequest();                         
                    req.setEndpoint(ejariDetails.URL__c);
                    req.setMethod('POST');                 
                    req.setHeader('Content-Type', 'text/xml; charset=utf-8');
                    req.setHeader('SOAPAction', objReturnWrap.soapAction);
                    req.setBody(objReturnWrap.body);
                    req.setTimeout(120000);
                    system.debug(req);
                    HttpResponse res = null;
                    res = h.send(req);
                    system.debug(res);
                    system.debug(res.getBody());
                    if (res.getStatusCode() == 200) {
                        Ejari_XMLDecoderUtil.updateContractTriggerCheckboxes(recordId, '');    
                        if(methodName == 'PrintTcByContractNumberToStream') Ejari_XMLDecoderUtil.xmlDecoderPrintCertificate(methodName,res.getBody(),recordId);
                            //System.enqueueJob(new Ejari_QueueableHandlerUtil.Ejari_QueueablePrintTC(recordId));
                        else if(methodName == 'PrintCertificateByContractNumberToStream') Ejari_XMLDecoderUtil.xmlDecoderPrintCertificate(methodName,res.getBody(),recordId);
                           // System.enqueueJob(new Ejari_QueueableHandlerUtil.Ejari_QueueablePrintCertificate(recordId));          
                        else {
                            Ejari_XMLDecoderUtil.xmlDecoderEjari(methodName,res.getBody(),recordId);
                        }
                        LoggerUtility.logException( null, objReturnWrap.body, res.getBody());
                    } else {
                        Ejari_XMLDecoderUtil.xmlDecoderEjari(methodName,res.getBody(),recordId);
                        Ejari_XMLDecoderUtil.updateContractTriggerCheckboxes(recordId, res.getBody());
                        LoggerUtility.logException( null, objReturnWrap.body, res.getBody());
                    }
                }
            } catch (Exception e) {
                system.debug('error: ' + e.getMessage() + ' At line:' + e.getLineNumber());
                LoggerUtility.logException( e, 'Error', 'Error');
            }
        }
    }

    //Queueable Class for PrintTcByContractNumber Ejari Service Method
    public class Ejari_QueueablePrintTC implements Queueable, Database.AllowsCallouts {

        String recordId;

        public Ejari_QueueablePrintTC(String recordId) {
            this.recordId = recordId;
        }
        public void execute(QueueableContext context) {
            try {

                Lease_Contract__c contRec = new Lease_Contract__c();
                Opportunity oppRec = new Opportunity();

                // get the data queried
                contRec = Database.query(Ejari_ServiceSelectorUtil.getQuery('Lease_Contract__c', recordId, null));
                oppRec = Database.query(Ejari_ServiceSelectorUtil.getQuery('Opportunity', contRec.Opportunity__c, null));

                Ejari_Integration_Credential__mdt ejariDetails = [select URL__c, Password__c, User_Name__c from Ejari_Integration_Credential__mdt
                    where DeveloperName = 'Ejari_Credentials'
                    Limit 1
                ];

                HTTPResponse resp;
                string body = Ejari_XMLConstructorUtil.PrintTcByContractNumber(oppRec,contRec,ejariDetails);

                // make the callout
                HTTP h = new HTTP();
                HTTPRequest req = new HTTPRequest();
                req.setEndpoint(ejariDetails.URL__c);
                //Blob headerValue = Blob.valueOf(username + ':' + password);
                //String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                //r.setHeader('Authorization', authorizationHeader);
                req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
                req.setHeader('SOAPAction', 'http://tempuri.org/IEjariProxy/PrintTcByContractNumberToStream');
                req.setBody(body);
                req.setMethod('POST');
                req.setTimeout(120000);
                resp = h.send(req);
                system.debug('response-->' + resp.getBody());
                if (resp.getStatusCode() == 200) {
                    Ejari_XMLDecoderUtil.xmlDecoderPrintCertificate('PrintTcByContractNumberToStream', resp.getBody(), recordId);                    
                    Ejari_XMLDecoderUtil.updateContractTriggerCheckboxes(recordId, resp.getBody());
                    LoggerUtility.logException( null, body, resp.getBody());
                } else {
                    Ejari_XMLDecoderUtil.updateRequestResponse(recordId, resp.getBody());
                    LoggerUtility.logException( null, body, resp.getBody());
                }

            } catch (Exception e) {
                system.debug('error: ' + e.getMessage() + ' At line:' + e.getLineNumber());
                LoggerUtility.logException( null, 'Error','Error');
            }

        }
    }

    //Queueable Class for PrintCertificateByContractNumberToStream Ejari Service Method
    public class Ejari_QueueablePrintCertificate implements Queueable, Database.AllowsCallouts {
        String recordId;

        public Ejari_QueueablePrintCertificate(String recordId) {
            this.recordId = recordId;
        }
        public void execute(QueueableContext context) {
            try {

                Lease_Contract__c contRec = new Lease_Contract__c();
                Opportunity oppRec = new Opportunity();

                // get the data queried
                contRec = Database.query(Ejari_ServiceSelectorUtil.getQuery('Lease_Contract__c', recordId, null));
                oppRec = Database.query(Ejari_ServiceSelectorUtil.getQuery('Opportunity', contRec.Opportunity__c, null));

                Ejari_Integration_Credential__mdt ejariDetails = [select URL__c, Password__c, User_Name__c from Ejari_Integration_Credential__mdt
                    where DeveloperName = 'Ejari_Credentials'
                    Limit 1
                ];

                HTTPResponse resp;
                string body = Ejari_XMLConstructorUtil.PrintCertificateByContractNumberToStream(oppRec,contRec,ejariDetails);

                // make the callout
                HTTP h = new HTTP();
                HTTPRequest req = new HTTPRequest();
                req.setEndpoint(ejariDetails.URL__c);
                //Blob headerValue = Blob.valueOf(username + ':' + password);
                //String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                //r.setHeader('Authorization', authorizationHeader);
                req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
                req.setHeader('SOAPAction', 'http://tempuri.org/IEjariProxy/PrintCertificateByContractNumberToStream');
                req.setBody(body);
                req.setMethod('POST');
                req.setTimeout(120000);
                resp = h.send(req);
                system.debug('response-->' + resp.getBody());
                if (resp.getStatusCode() == 200) {
                    Ejari_XMLDecoderUtil.xmlDecoderPrintCertificate('PrintCertificateByContractNumberToStream', resp.getBody(), recordId);
                    Ejari_XMLDecoderUtil.updateContractTriggerCheckboxes(recordId, resp.getBody());
                    LoggerUtility.logException( null, body, resp.getBody());
                } else {
                    Ejari_XMLDecoderUtil.updateRequestResponse(recordId, resp.getBody());
                    LoggerUtility.logException( null, body, resp.getBody());
                }

            } catch (Exception e) {
                system.debug('error: ' + e.getMessage() + ' At line:' + e.getLineNumber());
                LoggerUtility.logException( e, 'Error', 'Error');
            }
        }
    }

}