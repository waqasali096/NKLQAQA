global class ISupplierRestAPICalloutMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'text/xml; charset=UTF-8');
        String xml = '<?xml version="1.0" encoding="UTF-8"?>'+
'<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsa="http://www.w3.org/2005/08/addressing">'+
   '<env:Header>'+
      '<wsa:Action>process</wsa:Action>'+
      '<wsa:MessageID>urn:c4739998-79e3-11ec-bc07-00aabb0032da</wsa:MessageID>'+
      '<wsa:ReplyTo>'+
         '<wsa:Address>http://www.w3.org/2005/08/addressing/anonymous</wsa:Address>'+
         '<wsa:ReferenceParameters>'+
            '<instra:tracking.ecid xmlns:instra="http://xmlns.oracle.com/sca/tracking/1.0">005pW74pqzN4Us25vr^AyX0005v5000LxY</instra:tracking.ecid>'+
            '<instra:tracking.FlowEventId xmlns:instra="http://xmlns.oracle.com/sca/tracking/1.0">4319854</instra:tracking.FlowEventId>'+
            '<instra:tracking.FlowId xmlns:instra="http://xmlns.oracle.com/sca/tracking/1.0">1501279</instra:tracking.FlowId>'+
            '<instra:tracking.CorrelationFlowId xmlns:instra="http://xmlns.oracle.com/sca/tracking/1.0">0000NtrFA6w4Us25vr^AyX1XtGDI00000b</instra:tracking.CorrelationFlowId>'+
            '<instra:tracking.quiescing.SCAEntityId xmlns:instra="http://xmlns.oracle.com/sca/tracking/1.0">90270</instra:tracking.quiescing.SCAEntityId>'+
         '</wsa:ReferenceParameters>'+
      '</wsa:ReplyTo>'+
      '<wsa:FaultTo>'+
         '<wsa:Address>http://www.w3.org/2005/08/addressing/anonymous</wsa:Address>'+
      '</wsa:FaultTo>'+
   '</env:Header>'+
   '<env:Body>'+
      '<OutputParameters xmlns="http://xmlns.oracle.com/apps/ap/soaprovider/plsql/xxims_salesforce_supplier_int_pkg/attach_file/" xmlns:client="http://xmlns.oracle.com/SalesforceAttachmentAPIv1/SalesforceAttachmentAPIv1/SalesforceAttachmentBPELProcess" xmlns:ns0="http://xmlns.oracle.com/apps/ap/soaprovider/plsql/xxims_salesforce_supplier_int_pkg/attach_file/" xmlns:plnk="http://docs.oasis-open.org/wsbpel/2.0/plnktype" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/">'+
         '<ns0:X_ATTACHMENT_ID>8983138</ns0:X_ATTACHMENT_ID>'+
         '<ns0:X_STATUS>S</ns0:X_STATUS>'+
         '<ns0:X_MESSAGE>:</ns0:X_MESSAGE>'+
      '</OutputParameters>'+
   '</env:Body>'+
'</env:Envelope>';
        response.setBody(xml);
        response.setStatusCode(200);
        return response;
    }
}