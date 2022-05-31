/*
Class Name:					CCAvenueResponse.apxc
Class Description:			Class is created to process CCAvenues' response
Author:						Lakshaya Sharma
Created Date:				12/20/2021
Updated by:
Last Update Date:
*/

@RestResource(urlMapping='/Payments/v1/*')
global class CCAvenueResponse {
	public static final String ENC_KEY;
    public static final String IV;
    public static String status;
    public static String reference_no;
    
    static{
        Map<String,CCAvenue__mdt> credentials = CCAvenue__mdt.getAll();
        ENC_KEY = credentials.get('Enc_Key').Value__c;
        IV = credentials.get('IV').Value__c;
    }
    
    @HttpPost
    global static void createPaymentResponse(){
        Map<String,String> resParams = RestContext.request.params;
        
        String invoiceNo = resParams.get('order_id');
        
        String value = Crypto.decrypt('AES128', 
                              Crypto.generateDigest('MD5', Blob.valueOf(ENC_KEY) ), 
                              EncodingUtil.convertFromHex(IV), 
                              EncodingUtil.convertFromHex(resParams.get('encResp'))).toString();

       List<String> params = value.split('&');
        for(String param : params){
            List<String> param1 = param.split('=');
            for(String subParam : param1){
                if(subParam == 'order_status'){
                    status = param1[1];
                    System.debug('Status ==> '+status);
                }
                if(subParam == 'tracking_id'){
                    reference_no = param1[1];
                    System.debug('reference_no ==> '+reference_no);
                }
            }
        }
        if(status == 'Success' && reference_no != null){
            
            Receipt__c payUpdate = [Select id,Payment_Status__c, Receipt_Number__c from Receipt__c where Invoice_ID__c = :invoiceNo];
        		System.debug('Payment Record ==> '+payUpdate);
            if(payUpdate != null){
                //Updated as cleared from paid by Ashams, as online payments will be cleared by default
            	payUpdate.Payment_Status__c = 'Cleared';
            	payUpdate.Receipt_Number__c = reference_no;
                payUpdate.Payment_Date__c = DateTime.now();
                
           	update payUpdate;
        } 
        }
    }
}