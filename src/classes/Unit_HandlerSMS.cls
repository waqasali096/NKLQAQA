/*
Class Name:                 Unit_HandlerSMS.apxc
Class Description:          Class is used to send SMS to customers
Author:                     Lakshaya Sharma
Created Date:               12/06/2021
Updated by:
Last Update Date:
*/
//Comment by Swapnil - neeed to use Business_Unit__c instead of master_community__c and use unit_Status__c instead of sales_status__c and leasing_status__c
public class Unit_HandlerSMS {
    public static String BASE_URL;
    public static String USERNAME;
    public static String PASSWORD; 
    public static String MSG;
    
    
    public static void fetchCredentials(){
        
        Map<String,SMS_Credential__mdt> credentials = SMS_Credential__mdt.getAll();
            USERNAME = credentials.get('Username').Value__c;
            PASSWORD = credentials.get('Password').Value__c;
            BASE_URL = credentials.get('Endpoint').Url__c;
            MSG = credentials.get('Message').Message__c;
        
    }
    
    public static void callSmsApiFromOpportunity(List<Opportunity> opportunities){
        Unit_HandlerSMS.fetchCredentials();
        System.debug('url from method ==> '+BASE_URL);
        for(Opportunity op : opportunities){
            if(op.stageName == 'Booking Initiated' || op.stageName == 'Booking Confirmed'){
                String xmlString = Unit_HandlerSMS.createXMLDoc(op.id,null,USERNAME,PASSWORD,op.stageName);
                xmlString=xmlString.replace('<MESSAGE>', '<!DOCTYPE MESSAGE SYSTEM "http://127.0.0.1:28080/psms/dtd/messagev12.dtd"><MESSAGE VER="1.2">');                
               // System.debug('XML String : '+xmlString);
                String ecodedXmlString = EncodingUtil.urlEncode(xmlString, 'ISO-8859-1');
                 ecodedXmlString ='data='+ecodedXmlString+'&action=send';
                 Unit_HandlerSMS.callSmsApi(ecodedXmlString,op.id,BASE_URL);
            }
        }
    }
    
    public static void triggerSmsApi(List<Unit__c> units){
        
            Unit_HandlerSMS.fetchCredentials();

        for(Unit__c u : units){            
            
            if(u.Unit_Status__c == 'Booked' || u.Unit_Status__c == 'Reserved' || u.Unit_Status__c == 'Sold')  {
                
                String xmlString = Unit_HandlerSMS.createXMLDoc(u.Opportunity__c,u.Unit_code__c,USERNAME,PASSWORD, u.Unit_Status__c);
                xmlString=xmlString.replace('<MESSAGE>', '<!DOCTYPE MESSAGE SYSTEM "http://127.0.0.1:28080/psms/dtd/messagev12.dtd"><MESSAGE VER="1.2">');                
               
                String ecodedXmlString = EncodingUtil.urlEncode(xmlString, 'ISO-8859-1');
                 ecodedXmlString ='data='+ecodedXmlString+'&action=send';
           Unit_HandlerSMS.callSmsApi(ecodedXmlString,u.id,BASE_URL);
            
            }
            
        }
    }
    
    
    public static String callSmsApiForPayment(String sms, String invoice_Id, String id, String paymentType){
        
        Unit_HandlerSMS.fetchCredentials();
        String xmlString = Unit_HandlerSMS.createXMLDoc(id,sms,USERNAME,PASSWORD, paymentType);
        xmlString=xmlString.replace('<MESSAGE>', '<!DOCTYPE MESSAGE SYSTEM "http://127.0.0.1:28080/psms/dtd/messagev12.dtd"><MESSAGE VER="1.2">');
        String ecodedXmlString = EncodingUtil.urlEncode(xmlString, 'ISO-8859-1');
        ecodedXmlString ='data='+ecodedXmlString+'&action=send';
        
        return ecodedXmlString;
    }
    
    @future(callout=true)
    public static void callSmsApi(String value, String id, String url){
       
        Boolean flag = false;
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(url);
                request.setBody(value);
                request.setMethod('POST');
                try{
                    HttpResponse response = http.send(request);
                    
                    if(response.getStatusCode() == 200 && id != null){
                        
                        
                    
                        String body = response.getBody();
                        system.debug('body is '+ body);
                        DOM.Document doc = new DOM.Document();
                        doc.load(body);
                        
                        DOM.XMLNode root = doc.getRootElement();
                        List<DOM.XMLNode> children = root.getChildElements();
                        if(children.size()>0){
                            for(DOM.XMLNode child : children){
                                if(child.getChildElements().size() < 1 && child.getName() == 'ERROR'){
                                    flag = true;
                                    break;
                                }else if(child.getChildElements().size()>0){
                                    for(Dom.XmlNode subchild : child.getChildElements()){
                                        if(subchild.getChildElements().size() < 1 && subchild.getName() == 'ERROR'){
                                            flag = true;
                                            break;
                                        }
                                    }
                                }else{
                            if(flag == false){
                                String message;
                                List<SMS_History__c> smsList = new List<SMS_History__c>();
                                SMS_History__c createSms = new SMS_History__c();
                                
                                String decodeXml = EncodingUtil.urlDecode(value,'ISO-8859-1');
                                System.debug('decodeXml ==> '+decodeXml);
                                decodeXml = decodeXml.replace('data=','');
                                decodeXml = decodeXml.replace('&action=send', '');
                                Dom.Document doc1 = new Dom.Document();
                                doc1.load(decodeXml);
                                Dom.XmlNode root1 = doc1.getRootElement();
                                List<Dom.XmlNode> children1 = root1.getChildElements();
                                
                                for(Dom.XmlNode child1 : children1){
                                    if(child1.getName() == 'SMS'){
                                        message = child1.getAttributeValue('TEXT', null); 
                                    }
                                }
                                if(id.substring(0, 3) == '006'){
                                    createSms.Opportunity__c = id;
                                    createSms.Message__c = message;
                                    smsList.add(createSms);
                                }else{
                                    createSms.Unit__c = id;
                                    createSms.Message__c = message;
                                    smsList.add(createSms);
                                }
                                Database.insert(smsList,true);
                            }
                        }
                            }
                        
                        } 
                        
                    }else{
                        System.debug('Error Occurred');
                    }
                }catch(Exception e){
                    System.debug('Exception : '+e.getMessage());
                }
            }
        
    
    public static String createXMLDoc(String ids, String unit_number,String username, String password, String status){
        
        
        
        String message = MSG;
        Account acc = [Select id, name, Primary_Country_Code__c, Primary_Mobile__c from Account where Id in (Select AccountID from Opportunity where id = : ids)];
        String ph_number = acc.Primary_Country_Code__c + acc.Primary_Mobile__c;
        if(status == 'Booked'){
           
        
            message = message.replace('{}', acc.name);
            message = message + 'We have '+status+' the '+unit_number+' with us.';
            
        }else if(status == 'Reserved'){
            
          
            message = message.replace('{}', acc.name);
            message = message + 'We have '+status+' the '+unit_number+' with us.';
            
        }else if(status == 'Sold'){
            
            
            message = message.replace('{}', acc.name);
            message = message + 'Thanks you for puchasing the unit '+unit_number+'.';
        
        }else if(status == 'Booking Initiated'){
            

            message = message.replace('{}', acc.name);
            message = message + 'We have created an opportunity for you under '+status+'.';
            
        }else if(status == 'Booking Confirmed'){
            
           
            message = message.replace('{}', acc.name);
            message = message + 'We have created an opportunity for you under '+status+'.';
        }else if(status == 'Online Payment'){
            
            message = unit_number;
        }
        
        Dom.Document doc = new Dom.Document();
        Dom.XmlNode root = doc.createRootElement('MESSAGE',null,null);
        Dom.XmlNode user = root.addChildElement('USER',null,null);
            user.setAttribute('USERNAME', username);
            user.setAttribute('PASSWORD', password);
        DOM.XmlNode sms = root.addChildElement('SMS',null,null);
            sms.setAttribute('UDH', '0');
            sms.setAttribute('CODING', '1');
            sms.setAttribute('TEXT', message);
            sms.setAttribute('PROPERTY', '0');
            sms.setAttribute('ID', '1');
        DOM.XmlNode address = sms.addChildElement('ADDRESS',null,null);
            address.setAttribute('FROM', 'ValueFirst');
            address.setAttribute('TO', ph_number);
            address.setAttribute('SEQ', '1');
            address.setAttribute('TAG','random data');
        
        return doc.toXmlString(); 
            
    }

    //Added by Karishma to call the SMS APIs - 06-05-2022
    public static void callSmsApiGeneric(Unit_HandlerSMS.SMSWrapper smsWrap){
        system.debug('@@@smsWrap :'+smsWrap);
        Unit_HandlerSMS.fetchCredentials();
        SMS_Handler__mdt smsHandler = [SELECT Id, SObject_Name__c, Send_SMS_for__c, Message_Body__c FROM SMS_Handler__mdt 
                                             WHERE SObject_Name__c =: smsWrap.objectName AND Send_SMS_for__c=: smsWrap.SendSMSfor LIMIT 1];
        smsWrap.message = smsHandler.Message_Body__c;
        if(smsWrap.message.contains('{receiptLink}')) smsWrap.message = smsWrap.message.replace('{receiptLink}',smsWrap.publicDistributionURL);
        if(smsWrap.message.contains('{!CustomerName}')) smsWrap.message = smsWrap.message.replace('{!CustomerName}',smsWrap.customerName);
        if(smsWrap.message.contains('{!OTP}')) smsWrap.message = smsWrap.message.replace('{!OTP}',smsWrap.otp);
        String xmlString = Unit_HandlerSMS.generateXMLDoc(smsWrap,USERNAME,PASSWORD);
        xmlString=xmlString.replace('<MESSAGE>', '<!DOCTYPE MESSAGE SYSTEM "http://127.0.0.1:28080/psms/dtd/messagev12.dtd"><MESSAGE VER="1.2">');
        system.debug('##########'+xmlString); 
        String ecodedXmlString = EncodingUtil.urlEncode(xmlString, 'ISO-8859-1');
        
        ecodedXmlString ='data='+ecodedXmlString+'&action=send';
        String smsWrapStr = JSON.serialize(smsWrap);
        Unit_HandlerSMS.SMSAPICallout(ecodedXmlString,smsWrapStr,BASE_URL);
        
    }

    //Added by Karishma to generateXML - 06-05-2022
    public static String generateXMLDoc(SMSWrapper smsWrap, String username, String password){
        Dom.Document doc = new Dom.Document();
        Dom.XmlNode root = doc.createRootElement('MESSAGE',null,null);
        Dom.XmlNode user = root.addChildElement('USER',null,null);
            user.setAttribute('USERNAME', username);
            user.setAttribute('PASSWORD', password);
        DOM.XmlNode sms = root.addChildElement('SMS',null,null);
            sms.setAttribute('UDH', '0');
            sms.setAttribute('CODING', '1');
            sms.setAttribute('TEXT', smsWrap.message);
            sms.setAttribute('PROPERTY', '0');
            sms.setAttribute('ID', '1');
        DOM.XmlNode address = sms.addChildElement('ADDRESS',null,null);
            address.setAttribute('FROM', 'ValueFirst');
            address.setAttribute('TO', smsWrap.phoneNumberWithCountryCode);
            address.setAttribute('SEQ', '1');
            address.setAttribute('TAG','random data');
        
        return doc.toXmlString(); 
    }

    //Added by Karishma to callout the SMS APIs and save the response in SMS history- 06-05-2022
    @future(callout=true)
    public static void SMSAPICallout(String value, String smsWrapStr, String url){
        Logger__c log = null;
        SMSWrapper smsWrap = (SMSWrapper)JSON.deserialize(smsWrapStr,SMSWrapper.class);
        Boolean flag = false;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        system.debug('###########url='+url);
        request.setEndpoint(url);
        system.debug('###########value='+value);
        request.setBody(value);
        request.setMethod('POST');
        try{
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200 && smsWrap.objId != null){
                String body = response.getBody();
                system.debug('body is '+ body);
                DOM.Document doc = new DOM.Document();
                doc.load(body);
                DOM.XMLNode root = doc.getRootElement();
                List<DOM.XMLNode> children = root.getChildElements();
                if(children.size()>0){
                    for(DOM.XMLNode child : children){
                        if(child.getChildElements().size() < 1 && child.getName() == 'ERROR'){
                            flag = true;
                            break;
                        }else if(child.getChildElements().size()>0){
                            for(Dom.XmlNode subchild : child.getChildElements()){
                                if(subchild.getChildElements().size() < 1 && subchild.getName() == 'ERROR'){
                                    flag = true;
                                    break;
                                }
                            }
                        }else{
                            if(flag == false){
                                String message;
                                List<SMS_History__c> smsList = new List<SMS_History__c>();
                                SMS_History__c createSms = new SMS_History__c();
                                String decodeXml = EncodingUtil.urlDecode(value,'ISO-8859-1');
                                System.debug('decodeXml ==> '+decodeXml);
                                decodeXml = decodeXml.replace('data=','');
                                decodeXml = decodeXml.replace('&action=send', '');
                                Dom.Document doc1 = new Dom.Document();
                                doc1.load(decodeXml);
                                Dom.XmlNode root1 = doc1.getRootElement();
                                List<Dom.XmlNode> children1 = root1.getChildElements();
                                for(Dom.XmlNode child1 : children1){
                                    if(child1.getName() == 'SMS'){
                                        message = child1.getAttributeValue('TEXT', null); 
                                    }
                                }
                                if(String.ValueOf(smsWrap.objId.getsobjecttype()) == 'Opportunity'){
                                    createSms.Opportunity__c = smsWrap.objId;
                                    createSms.Message__c = smsWrap.message;
                                    smsList.add(createSms);
                                }else if(String.ValueOf(smsWrap.objId.getsobjecttype()) == 'Unit__c'){
                                    createSms.Unit__c = smsWrap.objId;
                                    createSms.Message__c = smsWrap.message;
                                    smsList.add(createSms);
                                }else if(String.ValueOf(smsWrap.objId.getsobjecttype()) == 'Account'){
                                    createSms.Account__c = smsWrap.objId;
                                    createSms.Message__c = smsWrap.message;
                                    smsList.add(createSms);
                                }
                                Database.insert(smsList,true);
                                
                            }
                        }
                    }
                } 
            }else{
                System.debug('Error Occurred');
                log = LoggerUtility.logAPI('Unit_HandlerSMS','SMSAPICallout','POST',value,response.getBody(),url, '',true);
            }
        }catch(Exception ex){
            System.debug('Exception : '+ex.getMessage());
            log = LoggerUtility.logExceptionWithNoDML('Exception',ex.getStackTraceString(),ex,value,'','');
        }
    }

    //Added by Karishma SMS Wrapper Class - 06-05-2022
    public class SMSWrapper{
        public String message {get;set;}
        public String publicDistributionURL {get;set;}
        public Id objId {get;set;}
        public String SendSMSfor {get;set;}
        public String phoneNumberWithCountryCode {get;set;}
        public String objectName {get;set;}
        public String customerName {get;set;}
        public String otp {get;set;}
    }
}