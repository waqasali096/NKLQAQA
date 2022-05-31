/**
* Name:          ERPUtilities 
* Description:   All Common Variables and utility Methods
* Author         Vishal Agrawal
*/
public class ERPUtilities {
    public Static final String PROJECT_CREATION_JSON_HEAD = 'CREATE_PROJECT_Input';
    public Static final String BUILDING_CREATION_JSON_HEAD = 'CREATE_BUILDING_Input';
    public Static final String FLOOR_CREATION_JSON_HEAD = 'CREATE_FLOOR_Input';
    public Static final String UNIT_CREATION_JSON_HEAD = 'CREATE_UNIT_Input';
    public Static final String MASTCOMMUNITY_CREATION_JSON_HEAD = 'CREATE_MASTER_COMMUNITY_Input';
    public Static final String CUSTOMER_CREATION_JSON_HEAD = 'CREATE_UPDATE_CUSTOMER_Input';
    public Static final String VALID_STATUS_CODE = '200';
    public Static final String RECEIPT_CREATION_JSON_HEAD = 'CREATE_RECEIPT_Input';
    public Static final String SALES_ORDER_CREATION_JSON_HEAD = 'CREATE_LEASE_Input';
    public Static final String GET_USER_INFO_JSON_HEAD = 'GET_USER_INFO_Input';
    public Static final String HELPER_SERVICE_JSON_HEAD = 'HELPER_SERVICE_Input';
    public Static final String OPPORTUNITY_CREATION_JSON_HEAD = 'CREATE_OPPORTUNITY_Input';
    public Static final String TERMINATE_CONTRACT_JSON_HEAD = 'TERMINATE_CONTRACT_Input';
    public Static final String CREATE_INVOICE_JSON_HEAD = 'CREATE_INVOICE_Input';
    public Static final String SALE_LEAS_SO_CREATION_JSON_HEAD = 'CREATE_LEASE_V1_Input';
    public Static final String REVERSE_RECEIPT_JSON_HEAD = 'REVERSE_RECEIPT_Input';
    public Static final String REFUND_CREATE_JSON_HEAD = 'CREATE_REFUND_Input';
    public Static final String CREDITMEMO_CREATE_JSON_HEAD = 'CREATE_CM_Input';
    public Static final String BILLINGLINE_CREATE_JSON_HEAD = 'CREATE_UPDATE_BILLING_LINE_Input';
    public Static final String UNAPPLIED_RECEIPT_JSON_HEAD = 'UNAPPLY_RECEIPT_Input';
    public Static final String FLAG_UNIT_JSON_HEAD = 'FLAG_UNIT_Input';
    public Static final String UNFLAG_UNIT_JSON_HEAD = 'UNFLAG_UNIT_Input';
    public Static final String FLAG_CUSTOMER_JSON_HEAD = 'FLAG_CUSTOMER_Input';
    public Static final String UNFLAG_CUSTOMER_JSON_HEAD = 'UNFLAG_CUSTOMER_Input';
    
    public Static final Integer BATCH_SIZE_COMMON_APIS = 20;
    public Static final Integer ERROR_MESSAGE_LENGTH = 255;

    
    public Static final String API_NAME_PROJECT_CREATION = 'Project Creation';
    public Static final String OBJECT_NAME_PROJECT = 'Project__c';
    
    public Static final String API_NAME_BUILDING_CREATION = 'Building Creation';
    public Static final String OBJECT_NAME_BUILDING = 'Building__c';
    
    public Static final String API_NAME_FLOOR_CREATION = 'Floor Creation';
    public Static final String OBJECT_NAME_FLOOR = 'Floor__c';
    
    public Static final String API_NAME_UNIT_CREATION = 'Unit Creation';
    public Static final String OBJECT_NAME_UNIT = 'Unit__c';
    
    public Static final String API_NAME_MASTERCOMMUNITY_CREATION = 'Master Community Creation';
    public Static final String OBJECT_NAME_MASTERCOMMUNITY = 'Master_Community2__c';
    
    public Static final String API_NAME_CUSTOMER_CREATION = 'Customer Creation';
    public Static final String OBJECT_NAME_ACCOUNT = 'Account';
    
    public Static final String API_NAME_OPPORTUNITY_CREATION = 'Opportunity Creation';
    public Static final String OBJECT_NAME_OPPORTUNITY = 'Opportunity';
    
    public Static final String API_NAME_RECEIPT_CREATION = 'Receipt Creation';
    public Static final String OBJECT_NAME_RECEIPT = 'Receipt__c';
    
    public Static final String API_NAME_INVOICE_CREATION = 'Invoice Creation';
    public Static final String OBJECT_NAME_INVOICE = 'Invoice__c';
    
    public Static final String API_NAME_USER_CREATION = 'GET User Info';
    public Static final String OBJECT_NAME_USER = 'User';
    
    public Static final String API_NAME_SALES_SO_CREATION = 'SO Creation - Sales';
    public Static final String OBJECT_NAME_AGREEMENT = 'Agreement__c';
    
    public Static final String API_NAME_LEASING_SO_CREATION = 'SO Creation - Leasing';
    public Static final String OBJECT_NAME_LEASE_CONTRACT = 'Lease_Contract__c';
    
    
    public Static final String API_NAME_BILL_LINE_CREATION = 'Billing Line API';
    public Static final String OBJECT_NAME_PAYMENTMILESTONE = 'Payment_Milestone__c';
    
    public Static final String API_NAME_CREDIT_MEMO_CREATION = 'Credit Memo Creation';
    public Static final String OBJECT_NAME_CREDITMEMO = 'Credit_Memo__c';
    
    public Static final String API_NAME_REFUND = 'Refund Creation';
    public Static final String OBJECT_NAME_RECEIPTREFUND = 'Receipt_Refund__c';
    
    public Static final String API_NAME_UNAPPLIED_RECEIPT = 'Unapplied Receipt API';
    
    public Static final String API_NAME_GET_BANK_LIST = 'Get Bank List';
    public Static final String API_NAME_GET_ACCOUNT_STATEMENT = 'GET Account Statement';
    public Static final String API_NAME_HELPER_SERVICE = 'Helper Service';
    public Static final String API_NAME_RECEIPT_REVERSAL = 'Receipt Reversal';
    
    public Static final String API_NAME_FLAG_UNIT = 'Flag Unit';
    public Static final String API_NAME_UNFLAG_UNIT = 'Unflag Unit';
    public Static final String API_NAME_FLAG_CUSTOMER = 'Flag Customer';
    public Static final String API_NAME_UNFLAG_CUSTOMER = 'Unflag Customer';
    
    public Static final String OBJECT_NAME_UNIT_PLAN = 'Unit_Plan__c';
    public Static final String OBJECT_NAME_OPPORTUNITY_CHARGES = 'Opportunity_Charges__c';
    
    public Static final String OBJECT_NAME_FLAG = 'Flag__c';
    
    public Static final String API_NAME_SO_TERMINATION = 'Contract Termination';

    
    //Get End Point Settings
    public Static String getEndPoint(String apiName) {
        API_End_Point__c eep = API_End_Point__c.getValues(apiName);
        return eep?.END_Point_URL__c;
    }
    
    //Get ERP Settings
    /*public Static ERP_Setting__c getERPSetting(String apiName) {
        ERP_Setting__c erpSetting = ERP_Setting__c.getValues(apiName);
        return erpSetting;
    }*/
    
    //Format date for DD/MM/YYYY for ERP API
    public Static String formatDate(Date dt) {
        //return formatNumber(dt.day()) + '-' + formatNumber(dt.month()) + '-' + dt.year();
        return dt.year() + '-' + formatNumber(dt.day()) + '-' + formatNumber(dt.month());
    }

    //Format date for DD-MMM-YYYY for ERP API
    public Static String formatDateDDMMMYYY(Date dt) {
        String formattedDate  = DateTime.newInstance(dt.year(),dt.month(),dt.day()).format('dd-MMM-YYYY');
        return formattedDate;
    }
    
    //Format date time for YYYY-MM-DDTHH:mm:SSZ for Onsite API
    public Static String formatDateTime(DateTime dt) {
        string dateValue = String.valueOf(dt).replace(' ','T') + 'Z';
        system.debug('@@DateValue :'+dateValue);
        return String.valueOf(dt).replace(' ','T') + 'Z';
    }

    //Format date time for YYYY-MM-DDTHH:mm:SS.000+04:00 for Onsite API
    public Static String formatGMTDateTime(DateTime dt) {
        string dateValue = String.valueOf(dt).replace(' ','T') + '.000+04:00';
        system.debug('@@DateValue :'+dateValue);
        return dateValue;
    }
    
    public Static String formatNumber(Integer num) {
        return num < 10 ? ('0' + num) : String.valueOf(num);
    }
    
    //Make HTTP Callout
    public static String makeHTTPRequest(String body, String endPoint, String Action){
        if(String.isNotBlank(body) && String.isNotBlank(endPoint)){
            /*Blob headerValue = Blob.valueOf(username + ':' + password);
            // Base 64 Encode the blob and prepend "Basic "
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);*/
            
            HttpRequest req = new HttpRequest();
            //req.setHeader('Authorization', authorizationHeader);
            req.setEndpoint('callout:ERP_API/' + endPoint);
            req.setMethod(Action);
            req.setHeader('Content-type', 'application/json');
            req.setHeader('accept', 'application/json');
            req.setBody(body);
            req.setTimeout(120000);
            
            Http http = new Http();
            HTTPResponse response = http.send(req);
            system.debug('getBody2 '+response.getBody());
            system.debug('*****getBody2.getStatusCode '+response.getStatusCode());
            string responseText  = response.getBody();
            return response.getBody();
           //return '{"status":"'+response.getStatusCode()+'","responseText":'+response.getBody()+'}';
        } else{
            return '';
        }
    }
    
    //Make Request body
    public static String createReqBody(sObject sobj, List<API_Mapping__mdt> erpMapping){
        String reqBodyMain = '';
        //String quotes = '\" \"';
        
        for(API_Mapping__mdt erpMap : erpMapping) {
            if(erpMap.IsConstant__c == true){
                reqBodyMain += '"' + erpMap.ERP_Field__c + '":';
                String value = erpMap.Constant_Value__c;
                if(erpMap.Data_Type__c == 'Integer'){
                     reqBodyMain += (value == null ? 'null' : value) + ',';
                }else if(erpMap.Data_Type__c == 'String'){
                    reqBodyMain += '"' + (value == null ? '' : value) + '",';
                }else if(erpMap.Data_Type__c ==  null){
                    reqBodyMain += '"' + (value == null ? null : value) + '",';
                } else if(erpMap.Data_Type__c == 'Date') {
                    Date dt = value == null ? null : Date.valueOf(value);
                    reqBodyMain += '"' + (dt == null ? '' : (erpMap.SF_Object_Name__c == 'Account' ? formatDateDDMMMYYY(dt) : formatDate(dt))) + '",';
                } else if(erpMap.Data_Type__c == 'DateTime') {
                    DateTime dt = value == null ? null : (value == 'NOW' ? System.Now() : DateTime.valueOf(value));
                    reqBodyMain += '"' + (dt == null ? '' : (erpMap.SF_Object_Name__c == 'Account' ? formatGMTDateTime(dt) : formatGMTDateTime(dt))) + '",';
                }
            }
            if(erpMap.Salesforce_Field__c != null && erpMap.IsConstant__c == false){
                //sobj.get(erpMap.Salesforce_Field__c)!=null && sobj.get(erpMap.Salesforce_Field__c) != '' 
                
                reqBodyMain += '"' + erpMap.ERP_Field__c + '":';
                if(erpMap.Data_Type__c == 'Date') {
                    Date dt = Date.valueOf(sobj.get(erpMap.Salesforce_Field__c));
                    reqBodyMain += '"' + (dt == null ? '': (erpMap.SF_Object_Name__c == 'Account' ? formatDateDDMMMYYY(dt) : formatDate(dt))) + '",';
                } else if(erpMap.Data_Type__c == 'DateTime') {
                    //DateTime dt = DateTime.valueOf(sobj.get(erpMap.Salesforce_Field__c));
                    Date temp = Date.valueOf(sobj.get(erpMap.Salesforce_Field__c));
                    DateTime dt = null;
                    if(temp != null) {
                        dt = DateTime.newInstanceGMT(temp.year(), temp.month(), temp.day());
                    }
                    reqBodyMain += '"' + (dt == null ? '': ERPUtilities.formatGMTDateTime(dt)) + '",';
                } else if(erpMap.Data_Type__c == 'Integer') {
                    Integer intVal = Integer.valueOf(sobj.get(erpMap.Salesforce_Field__c));
                    reqBodyMain += (intVal == null ? 'null' : String.valueOf(intVal)) + ',';
                } else if(erpMap.Data_Type__c == 'Boolean') {
                    String flagCheck = Boolean.valueOf(sobj.get(erpMap.Salesforce_Field__c)) == true ? 'Y' : 'N';
                    reqBodyMain += '"'+(flagCheck == null ? '': flagCheck) + '",';
                } else if(erpMap.Data_Type__c == 'Double') {
                    Double dbVal = Double.valueOf(sobj.get(erpMap.Salesforce_Field__c));
                    reqBodyMain += (dbVal == null ? 'null' : String.valueOf(dbVal)) + ',';
                }/*else if(erpMap.Data_Type__c == 'Decimal'){
                    Decimal decVal = Decimal.valueOf(sobj.get(erpMap.Salesforce_Field__c));
                    reqBodyMain += (decVal == null ? 'null' : String.valueOf(decVal)) + ',';
                }*/ else {
                    reqBodyMain += '"' + (sobj.get(erpMap.Salesforce_Field__c) == null ? '': String.valueOf(sobj.get(erpMap.Salesforce_Field__c))) + '",';
                }
            }
        }
        return reqBodyMain;
    }
}