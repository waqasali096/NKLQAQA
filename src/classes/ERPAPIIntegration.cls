/**
* Name:          ERPAPIIntegration
* Description:   All api call to ERP
* Author         Vishal Agrawal
*/
public class ERPAPIIntegration {
    
    /*Method: initGenericERPAPICall
* Desc: Common Handler Method for Common API to be called from BatchCommonERPAPI class
* Param: objName - SF Object API name
* Param: apiName - ERP API name
* Param: headerName - API req body header
* Param: record - SF Object record to process
* Param: apiMapping - Mapping list for API
* Return: WrpGenericAPIResponse - wrapper of Logger and object record
*/ 
    public Static WrpGenericAPIResponse initGenericERPAPICall(String objName, String apiName,String headerName, sObject sObj, List<API_Mapping__mdt> apiMapping) {
        WrpGenericAPIResponse wrpResponse;
        String requestBodyContainer;
        Logger__c log = null;
        sObject record = Schema.getGlobalDescribe().get(objName).newSObject() ;
        try{
            record.Id = sObj.Id;
            String reqBodyMain = '{"' + headerName + '":{"RESTHeader":{},"InputParameters":{';
            reqBodyMain += ERPUtilities.createReqBody(sObj,apiMapping);
            reqBodyMain = reqBodyMain.removeEnd(',');
            reqBodyMain += '}}}';
            System.debug('@@reqBodyMain : ' +reqBodyMain);
            requestBodyContainer = reqBodyMain;
            String strEndPoint = ERPUtilities.getEndPoint(apiName);
            String responseBody = ERPUtilities.makeHTTPRequest(reqBodyMain,strEndPoint, 'POST');
            System.debug('@@responseBody : ' +responseBody );
            ERPAPIResponse erpResponse = null;
            if(responseBody != null && responseBody != '' && String.isNotBlank(responseBody)){
                erpResponse = ERPAPIResponse.parse(responseBody);
            }else if(apiName != ERPUtilities.API_NAME_RECEIPT_REVERSAL && apiName != ERPUtilities.API_NAME_FLAG_UNIT && apiName != ERPUtilities.API_NAME_UNFLAG_UNIT && apiName != ERPUtilities.API_NAME_FLAG_CUSTOMER
                        && apiName != ERPUtilities.API_NAME_UNFLAG_CUSTOMER) {
                record.put('ERP_Status__c','E');
                record.put('ERP_Message__c','ERP Response Body is invalid or empty.');
            }
            if(erpResponse != null) {
                updateRecordERPIds(apiName,record,erpResponse.OutputParameters,erpResponse.ISGServiceFault);
            }else if(apiName != ERPUtilities.API_NAME_RECEIPT_REVERSAL && apiName != ERPUtilities.API_NAME_FLAG_UNIT && apiName != ERPUtilities.API_NAME_UNFLAG_UNIT && apiName != ERPUtilities.API_NAME_FLAG_CUSTOMER
                        && apiName != ERPUtilities.API_NAME_UNFLAG_CUSTOMER) {
                record.put('ERP_Status__c','E');
                record.put('ERP_Message__c','ERP Response Body is invalid or empty.');
            }
            updateSendToERPFlag(apiName,record,objName);
            
            log = LoggerUtility.logAPI('ERPAPIIntegration',apiName,'POST',reqBodyMain,responseBody,strEndPoint, '',false);
        }  catch(exception ex) {
            System.debug('@@@Error: ' + ex);
            if(apiName != ERPUtilities.API_NAME_RECEIPT_REVERSAL && apiName != ERPUtilities.API_NAME_FLAG_UNIT && apiName != ERPUtilities.API_NAME_UNFLAG_UNIT && apiName != ERPUtilities.API_NAME_FLAG_CUSTOMER
                        && apiName != ERPUtilities.API_NAME_UNFLAG_CUSTOMER) {
                record.put('ERP_Status__c','E');
                record.put('ERP_Message__c',ex.getMessage());
            }
            log = LoggerUtility.logExceptionWithNoDML('Exception',ex.getStackTraceString(),ex,requestBodyContainer,'','');
        }
        wrpResponse = new WrpGenericAPIResponse(record, log);
        return wrpResponse;
    }
    
    /*Method: updateRecordERPIds
* Desc: Update ERP Message, STatus and ERP External Id
* Param: apiName - ERP API name
* Param: record - SF Object record to process
* Param: outputParameters - Output response from API for Expected val
* Param: isgServiceFault - Output response from API for Exception val
* Return: None
*/ 
    public Static Void updateRecordERPIds(String apiName, sObject record, ERPAPIResponse.OutputParameters outputParameters, ERPAPIResponse.ISGServiceFault isgServiceFault){
        if(apiName != ERPUtilities.API_NAME_RECEIPT_REVERSAL && apiName != ERPUtilities.API_NAME_FLAG_UNIT && apiName != ERPUtilities.API_NAME_UNFLAG_UNIT && apiName != ERPUtilities.API_NAME_FLAG_CUSTOMER
                        && apiName != ERPUtilities.API_NAME_UNFLAG_CUSTOMER) {
            record.put('ERP_Message__c','');
        }
        if(outputParameters != null) {
            if(apiName != ERPUtilities.API_NAME_RECEIPT_REVERSAL && apiName != ERPUtilities.API_NAME_FLAG_UNIT && apiName != ERPUtilities.API_NAME_UNFLAG_UNIT && apiName != ERPUtilities.API_NAME_FLAG_CUSTOMER
                        && apiName != ERPUtilities.API_NAME_UNFLAG_CUSTOMER) {
                record.put('ERP_Status__c','S');
            }
            
            
            if(apiName == ERPUtilities.API_NAME_PROJECT_CREATION && String.isNotBlank(outputParameters.X_PROPERTY_ID)) {
                record.put('ERP_Project_Id__c',outputParameters.X_PROPERTY_ID);
            } else if(apiName == ERPUtilities.API_NAME_BUILDING_CREATION && String.isNotBlank(outputParameters.X_LOCATION_ID)) {
                record.put('ERP_Building_Id__c',outputParameters.X_LOCATION_ID);
            } else if(apiName == ERPUtilities.API_NAME_FLOOR_CREATION && String.isNotBlank(outputParameters.X_LOCATION_ID)) {
                record.put('ERP_Floor_Id__c',outputParameters.X_LOCATION_ID);
            } else if(apiName == ERPUtilities.API_NAME_MASTERCOMMUNITY_CREATION && String.isNotBlank(outputParameters.X_LOCATION_ID)) {
                //record.put('ERP_Master_Community_Id__c',outputParameters.X_LOCATION_ID);
            } else if(apiName == ERPUtilities.API_NAME_UNIT_CREATION && String.isNotBlank(outputParameters.X_LOCATION_ID)) {
                record.put('ERP_Unit_Id__c',outputParameters.X_LOCATION_ID);
            } else if(apiName == ERPUtilities.API_NAME_CUSTOMER_CREATION && String.isNotBlank(outputParameters.PX_CUST_ACCOUNT_ID)) {
                record.put('ERP_Account_ID__c',outputParameters.PX_CUST_ACCOUNT_ID);
                if(String.isNotBlank(outputParameters.PX_ACCOUNT_NUMBER)) {
                    record.put('ERP_Account_Number__c',outputParameters.PX_ACCOUNT_NUMBER);
                }
            }  else if(apiName == ERPUtilities.API_NAME_RECEIPT_CREATION && String.isNotBlank(outputParameters.P_CASH_RECEIPT_ID)) {
                record.put('ERP_Receipt_ID__c',outputParameters.P_CASH_RECEIPT_ID);
                
                if(String.isNotBlank(outputParameters.P_RECEIPT_NUMBER)) {
                    record.put('ERP_Receipt_Number__c',outputParameters.P_RECEIPT_NUMBER);
                }
                record.put('ERP_Document_Sequence__c',outputParameters.P_DOCUMENT_SEQUENCE);
            } else if(apiName == ERPUtilities.API_NAME_INVOICE_CREATION && String.isNotBlank(outputParameters.X_CUSTOMER_TRX_ID)) {
                record.put('ERP_Invoice_Id__c',outputParameters.X_CUSTOMER_TRX_ID);
            } else if(apiName == ERPUtilities.API_NAME_OPPORTUNITY_CREATION && String.isNotBlank(outputParameters.P_OPPORTUNITY_ID)) {
                record.put('ERP_Opportunity_ID__c',outputParameters.P_OPPORTUNITY_ID);
            } else if(apiName == ERPUtilities.API_NAME_USER_CREATION  && String.isNotBlank(outputParameters.X_USER_ID)) {
                record.put('ERP_User_Id__c',outputParameters.X_USER_ID);
            } else if(apiName == ERPUtilities.API_NAME_BILL_LINE_CREATION && String.isNotBlank(outputParameters.X_ATTRIBUTE1)) {
                record.put('ERP_Billing_Line_Id__c',outputParameters.X_ATTRIBUTE1);
            } else if(apiName == ERPUtilities.API_NAME_REFUND && String.isNotBlank(outputParameters.X_ATTRIBUTE1)) {
                record.put('ERP_Refund_Id__c',outputParameters.X_ATTRIBUTE1);
            } else if(apiName == ERPUtilities.API_NAME_UNAPPLIED_RECEIPT && String.isNotBlank(outputParameters.X_USER_ID)) {
                //record.put('Send_Billing_Line_to_ERP__c',outputParameters.X_USER_ID);
            } else if(apiName == ERPUtilities.API_NAME_CREDIT_MEMO_CREATION && String.isNotBlank(outputParameters.X_ATTRIBUTE1)) {
                record.put('ERP_CreditMemo_Id__c',outputParameters.X_ATTRIBUTE1);
            } else if(apiName == ERPUtilities.API_NAME_FLAG_UNIT && String.isNotBlank(outputParameters.P_FLAG_ID)) {
                record.put('ERP_Flag_Id__c',outputParameters.P_FLAG_ID);
            } else if(apiName == ERPUtilities.API_NAME_FLAG_CUSTOMER && String.isNotBlank(outputParameters.X_CODE_ASSIGNMENT_ID)) {
                record.put('ERP_Flag_Id__c',outputParameters.X_CODE_ASSIGNMENT_ID);
            } else if(apiName != ERPUtilities.API_NAME_RECEIPT_REVERSAL && apiName != ERPUtilities.API_NAME_FLAG_UNIT && apiName != ERPUtilities.API_NAME_UNFLAG_UNIT && apiName != ERPUtilities.API_NAME_FLAG_CUSTOMER
                        && apiName != ERPUtilities.API_NAME_UNFLAG_CUSTOMER) {
                record.put('ERP_Status__c','E');
            } 
            
            if(String.isNotBlank(outputParameters.X_RETURN_STATUS)) {
            
                if(apiName != ERPUtilities.API_NAME_RECEIPT_REVERSAL && apiName != ERPUtilities.API_NAME_FLAG_UNIT && apiName != ERPUtilities.API_NAME_UNFLAG_UNIT && apiName != ERPUtilities.API_NAME_FLAG_CUSTOMER
                        && apiName != ERPUtilities.API_NAME_UNFLAG_CUSTOMER) {
                    record.put('ERP_Message__c',outputParameters.X_MSG_DATA == null ? '' : outputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH));
                    record.put('ERP_Status__c',outputParameters.X_RETURN_STATUS);
                /*} else if(apiName == ERPUtilities.API_NAME_REFUND) {
                    record.put('ERP_Refund_Messages__c',outputParameters.X_MSG_DATA);
                    record.put('ERP_Refund_API_Status__c',outputParameters.X_RETURN_STATUS);*/
                } else if(apiName == ERPUtilities.API_NAME_RECEIPT_REVERSAL) {
                    record.put('ERP_Reversal_Messages__c',outputParameters.X_MSG_DATA == null ? '' : outputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH));
                    record.put('ERP_Reversal_API_Status__c',outputParameters.X_RETURN_STATUS);
                } else if(apiName == ERPUtilities.API_NAME_FLAG_UNIT) {
                    record.put('ERP_Unit_Flag_Message__c',outputParameters.X_MSG_DATA == null ? '' : outputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH));
                    record.put('ERP_Unit_Flag_Status__c',outputParameters.X_RETURN_STATUS);
                } else if(apiName == ERPUtilities.API_NAME_UNFLAG_UNIT) {
                    record.put('ERP_Unit_UnFlag_Message__c',outputParameters.X_MSG_DATA == null ? '' : outputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH));
                    record.put('ERP_Unit_UnFlag_Status__c',outputParameters.X_RETURN_STATUS);
                } else if(apiName == ERPUtilities.API_NAME_FLAG_CUSTOMER) {
                    record.put('ERP_Customer_Flag_Message__c',outputParameters.X_MSG_DATA == null ? '' : outputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH));
                    record.put('ERP_Customer_Flag_Status__c',outputParameters.X_RETURN_STATUS);
                } else if(apiName == ERPUtilities.API_NAME_UNFLAG_CUSTOMER) {
                    record.put('ERP_Customer_UnFlag_Message__c',outputParameters.X_MSG_DATA == null ? '' : outputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH));
                    record.put('ERP_Customer_UnFlag_Status__c',outputParameters.X_RETURN_STATUS);
                }
            }
        } else if (isgServiceFault != null ){
            if(apiName != ERPUtilities.API_NAME_RECEIPT_REVERSAL && apiName != ERPUtilities.API_NAME_FLAG_UNIT && apiName != ERPUtilities.API_NAME_UNFLAG_UNIT && apiName != ERPUtilities.API_NAME_FLAG_CUSTOMER
                        && apiName != ERPUtilities.API_NAME_UNFLAG_CUSTOMER) {
                record.put('ERP_Message__c',String.valueOf(isgServiceFault).left(ERPUtilities.ERROR_MESSAGE_LENGTH));
                record.put('ERP_Status__c','E');
            /*} else if(apiName == ERPUtilities.API_NAME_REFUND) {
                record.put('ERP_Refund_Messages__c',String.valueOf(isgServiceFault).left(ERPUtilities.ERROR_MESSAGE_LENGTH));
                record.put('ERP_Refund_API_Status__c','E');*/
            } else if(apiName == ERPUtilities.API_NAME_RECEIPT_REVERSAL) {
                record.put('ERP_Reversal_Messages__c',String.valueOf(isgServiceFault).left(ERPUtilities.ERROR_MESSAGE_LENGTH));
                record.put('ERP_Reversal_API_Status__c','E');
            }
        }
    }
    
    /*Method: updateSendToERPFlag
* Desc: Update Send to ERP flag
* Param: apiName - ERP API name
* Param: record - SF Object record to process
* Return: None
*/ 
    public Static Void updateSendToERPFlag(String apiName, sObject record,String objName){
        if(apiName == ERPUtilities.API_NAME_PROJECT_CREATION) {
            record.put('Send_Project_to_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_BUILDING_CREATION) {
            record.put('Send_Building_to_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_FLOOR_CREATION) {
            record.put('Send_Floor_to_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_MASTERCOMMUNITY_CREATION) {
            record.put('Send_Master_Community_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_UNIT_CREATION) {
            record.put('Send_Unit_to_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_CUSTOMER_CREATION) {
            record.put('Send_Customer_to_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_RECEIPT_CREATION) {
            record.put('Send_Receipt_to_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_INVOICE_CREATION) {
            record.put('Send_Invoice_to_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_OPPORTUNITY_CREATION) {
            record.put('Send_Opportunity_to_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_USER_CREATION) {
            record.put('Send_User_to_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_BILL_LINE_CREATION) {
            record.put('Send_Billing_Line_to_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_UNAPPLIED_RECEIPT) {
            //record.put('Send_Billing_Line_to_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_CREDIT_MEMO_CREATION) {
            record.put('Send_Credit_Memo_to_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_REFUND) {
            record.put('Send_Refund_to_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_RECEIPT_REVERSAL) {
            record.put('Send_Receipt_Reversal_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_FLAG_UNIT) {
            record.put('Send_Unit_Flag_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_UNFLAG_UNIT) {
            record.put('Send_Unit_UnFlag_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_FLAG_CUSTOMER) {
            record.put('Send_Customer_Flag_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_UNFLAG_CUSTOMER) {
            record.put('Send_Customer_UnFlag_ERP__c',false);
        } else if(apiName == ERPUtilities.API_NAME_SO_TERMINATION && objName == ERPUtilities.OBJECT_NAME_AGREEMENT) {
            record.put('Sync_Agreement_Termination__c',false);
        } else if(apiName == ERPUtilities.API_NAME_SO_TERMINATION && objName == ERPUtilities.OBJECT_NAME_LEASE_CONTRACT) {
            record.put('Sync_Contract_Termination__c',false);
        }
    }
    
    /*Method: getBUList
* Desc: ERP BU List API call handler
* Param: N/A 
* Return: None
*/ 
    public Static List<ERPAPIResponse.X_BU_TABLE_ITEM> getBUList() {
        String requestBodyContainer;
        List<ERPAPIResponse.X_BU_TABLE_ITEM> buList = new List<ERPAPIResponse.X_BU_TABLE_ITEM>();
        try{
            
            //ERP_Setting__c erpSet = ERPUtilities.getERPSetting('ERP');
            
            String strEndPoint = ERPUtilities.getEndPoint('Get BU LIST');
            
            String responseBody = ERPUtilities.makeHTTPRequest(LABEL.Get_BU_LIST_Body,strEndPoint, 'POST');
            System.debug('@@responseBody : ' +responseBody );
            
            ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
            if(erpResponse != null && erpResponse.OutputParameters != null && erpResponse.OutputParameters.X_BU_TABLE != null && erpResponse.OutputParameters.X_BU_TABLE.X_BU_TABLE_ITEM != null) {
                buList = erpResponse.OutputParameters.X_BU_TABLE.X_BU_TABLE_ITEM;
            }
            LoggerUtility.logAPI('BatchGETBUListeERP','getBUList','POST',LABEL.Get_BU_LIST_Body,responseBody,strEndPoint, '',true);
            
        } catch(exception ex) {
            System.debug('@@@Error: ' + ex);
            LoggerUtility.logException(ex,requestBodyContainer,'','');
        }
        return buList;
    }
    
    
    
    /*Method: createReceiptReversal
* Desc:  Create Receipt reversal in ERP Handler
* Param: Receipt - Set of receipt Ids
* Return: None
* Author: Vishal A
*/
    //todo - make it bulkified.
    /*public Static void createReceiptReversal(Set<Id> receiptIds) {
        String requestBodyContainer;
        try{
            String queryBuildFields = '';
            List<API_Mapping__mdt> erpMappingBuild = new List<API_Mapping__mdt>(); 
            
            for(API_Mapping__mdt erpMap : [Select Data_Type__c, ERP_Field__c, Salesforce_Field__c, SF_Object_Name__c,IsConstant__c, Constant_Value__c  FROM API_Mapping__mdt WHERE API_Header__c In (SELECT Id FROM API_Header__mdt where API_Name__c ='Receipt Reversal') Order By SF_Object_Name__c]) {
                if(erpMap.SF_Object_Name__c == 'Receipt__c') {
                    erpMappingBuild.add(erpMap);
                    if(!String.isBlank(erpMap.Salesforce_Field__c)) {
                        queryBuildFields += erpMap.Salesforce_Field__c + ',';
                    }
                }
            }
            
            queryBuildFields = queryBuildFields.removeEnd(',');
            
            String finalQry = 'Select ' + queryBuildFields + ' FROM Receipt__c Where Id In: receiptIds LIMIT 1';
            
            List<Receipt__c> receipts = Database.query(finalQry);
            if(receipts != null && !receipts.isEmpty()) {
                String reqBodyMain = '{"' + ERPUtilities.REVERSE_RECEIPT_JSON_HEAD + '":{"RESTHeader":{},"InputParameters":{';
                
                for(Receipt__c receipt : receipts) {
                    reqBodyMain += ERPUtilities.createReqBody(receipt,erpMappingBuild);
                }
                
                reqBodyMain = reqBodyMain.removeEnd(',');
                reqBodyMain += '}}}';
                System.debug('@@reqBodyMain : ' +reqBodyMain);
                requestBodyContainer = reqBodyMain;
                
                String strEndPoint = ERPUtilities.getEndPoint('Receipt Reversal');
                System.debug('@@Endpoint : '+strEndPoint);
                
                String responseBody = ERPUtilities.makeHTTPRequest(reqBodyMain,strEndPoint, 'POST');
                System.debug('@@responseBody : ' +responseBody );
                
                ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
                if(erpResponse != null && erpResponse.OutputParameters != null) {
                    Receipt__c payment = receipts[0];
                    payment.ERP_Reversal_API_Status__c = erpResponse.OutputParameters.X_RETURN_STATUS;
                    payment.ERP_Reversal_Messages__c = erpResponse.OutputParameters.X_MSG_DATA;
                    update payment;
                } else {
                    
                }
                LoggerUtility.logAPI('ReceiptTriggerHandler','createReceiptReversalCall','POST',reqBodyMain,responseBody,strEndPoint, '',true);
            }
        } catch(exception ex) {
            System.debug('@@@Error: ' + ex);
            System.debug('@@@Error line number: ' + ex.getLineNumber()+ 'Message :'+ex.getMessage());
            LoggerUtility.logException(ex,requestBodyContainer,'','');
        }
    }*/
    
    /*Method: createRefundERP
* Desc:  Create Refund in ERP Handler
* Param: Receipt - Set of receipt Ids
* Return: None
* Author: Vishal A
*/
    //todo - make it bulkified.
    /*public Static void createRefundERP(Set<Id> receiptIds) {
        String requestBodyContainer;
        try{
            String queryBuildFields = '';
            List<API_Mapping__mdt> erpMappingBuild = new List<API_Mapping__mdt>(); 
            
            for(API_Mapping__mdt erpMap : [Select Data_Type__c, ERP_Field__c, Salesforce_Field__c, SF_Object_Name__c,IsConstant__c, Constant_Value__c  FROM API_Mapping__mdt WHERE API_Header__c In (SELECT Id FROM API_Header__mdt where API_Name__c ='Refund Creation') Order By SF_Object_Name__c]) {
                if(erpMap.SF_Object_Name__c == 'Receipt__c') {
                    erpMappingBuild.add(erpMap);
                    if(!String.isBlank(erpMap.Salesforce_Field__c)) {
                        queryBuildFields += erpMap.Salesforce_Field__c + ',';
                    }
                }
            }
            
            queryBuildFields = queryBuildFields.removeEnd(',');
            
            String finalQry = 'Select ' + queryBuildFields + ' FROM Receipt__c Where Id In: receiptIds LIMIT 1';
            
            List<Receipt__c> receipts = Database.query(finalQry);
            if(receipts != null && !receipts.isEmpty()) {
                String reqBodyMain = '{"' + ERPUtilities.REFUND_CREATE_JSON_HEAD + '":{"RESTHeader":{},"InputParameters":{';
                
                for(Receipt__c receipt : receipts) {
                    reqBodyMain += ERPUtilities.createReqBody(receipt,erpMappingBuild);
                }
                
                reqBodyMain = reqBodyMain.removeEnd(',');
                reqBodyMain += '}}}';
                System.debug('@@reqBodyMain : ' +reqBodyMain);
                requestBodyContainer = reqBodyMain;
                
                String strEndPoint = ERPUtilities.getEndPoint('Refund Creation');
                System.debug('@@Endpoint : '+strEndPoint);
                
                String responseBody = ERPUtilities.makeHTTPRequest(reqBodyMain,strEndPoint, 'POST');
                System.debug('@@responseBody : ' +responseBody );
                
                ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
                if(erpResponse != null && erpResponse.OutputParameters != null) {
                    Receipt__c payment = receipts[0];
                    payment.ERP_Refund_API_Status__c = erpResponse.OutputParameters.X_RETURN_STATUS;
                    payment.ERP_Refund_Messages__c = erpResponse.OutputParameters.X_MSG_DATA;
                    update payment;
                } else {
                    
                }
                LoggerUtility.logAPI('ReceiptTriggerHandler','createRefundCall','POST',reqBodyMain,responseBody,strEndPoint, '',true);
            }
        } catch(exception ex) {
            System.debug('@@@Error: ' + ex);
            System.debug('@@@Error line number: ' + ex.getLineNumber()+ 'Message :'+ex.getMessage());
            LoggerUtility.logException(ex,requestBodyContainer,'','');
        }
    }*/
    
    /*Method: get Bank details from ERP
* Desc:  fetch bank details in ERP Handler
* Param: None
* Return: List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM>
* Author: Karishma Kotian
*/
    public Static List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM> getBankDetails(){
        String requestBodyContainer;
        List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM> bankList = new List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM>();
        try{
            String strEndPoint = ERPUtilities.getEndPoint(ERPUtilities.API_NAME_GET_BANK_LIST);
            String responseBody = ERPUtilities.makeHTTPRequest(LABEL.GET_BANK_DETAILS,strEndPoint, 'POST');
            System.debug('@@responseBody : ' +responseBody );
            
            ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
            if(erpResponse != null && erpResponse.OutputParameters != null && erpResponse.OutputParameters.X_HELPER_RESULT_TBL1 != null && erpResponse.OutputParameters.X_HELPER_RESULT_TBL1.X_HELPER_RESULT_TBL1_ITEM != null) {
                bankList = erpResponse.OutputParameters.X_HELPER_RESULT_TBL1.X_HELPER_RESULT_TBL1_ITEM;
            }
            system.debug('@@bankList :'+bankList);
            
        } catch(exception ex) {
            System.debug('@@@Error: ' + ex);
            LoggerUtility.logException(ex,requestBodyContainer,'','');
        }
        return bankList;
    }
    
    
    
    /*Method: get Receipt Method details from ERP
* Desc:  fetch Receipt Method details in ERP Handler
* Param: None
* Return: List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM>
* Author: Karishma Kotian 
*/
    public Static List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM> getReceiptMethodDetails(String businessUnitId){
        System.debug('@@ inside getReceipt :'+businessUnitId);
        String requestBodyContainer;
        List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM> receiptMethodList = new List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM>();
        try{
            String strEndPoint = ERPUtilities.getEndPoint('Helper Service');
            List<API_Mapping__mdt> erpMapList = [Select ERP_Field__c FROM API_Mapping__mdt 
                                                 WHERE API_Header__c IN
                                                 (SELECT Id FROM API_Header__mdt WHERE API_Name__c ='Helper Service')];
            String reqBodyMain = '{"' + ERPUtilities.HELPER_SERVICE_JSON_HEAD + '":{"RESTHeader":{},"InputParameters":{';
            for(API_Mapping__mdt erpMap : erpMapList){
                if(erpMap.ERP_Field__c == 'P_ATTRIBUTE_CATEGORY')
                    reqBodyMain += '"'+erpMap.ERP_Field__c+'": '+'"RECEIPT_METHOD",';
                if(erpMap.ERP_Field__c == 'P_ATTRIBUTE1')
                    reqBodyMain += '"'+erpMap.ERP_Field__c+'": '+'"'+businessUnitId+'",';
            }
            reqBodyMain = reqBodyMain.removeEnd(',');
            reqBodyMain += '}}}';
            String responseBody = ERPUtilities.makeHTTPRequest(reqBodyMain,strEndPoint, 'POST');
            System.debug('@@endpoint :'+strEndPoint);
            System.debug('@@request: '+reqBodyMain);
            System.debug('@@responseBody : ' +responseBody );
            
            ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
            if(erpResponse != null && erpResponse.OutputParameters != null && erpResponse.OutputParameters.X_HELPER_RESULT_TBL1 != null && erpResponse.OutputParameters.X_HELPER_RESULT_TBL1.X_HELPER_RESULT_TBL1_ITEM != null) {
                receiptMethodList = erpResponse.OutputParameters.X_HELPER_RESULT_TBL1.X_HELPER_RESULT_TBL1_ITEM;
            }
            system.debug('@@receiptMethodList :'+receiptMethodList);
            
        } catch(exception ex) {
            System.debug('@@@Error: ' + ex);
            LoggerUtility.logException(ex,requestBodyContainer,'','');
        }
        return receiptMethodList;
    }
    
    
    
    /*Method: Contract Termination info to be sent to ERP
* Desc:  Terminate Contract in ERP
* Param: Set of contract/agreement IDs
* Return: None
* Author: Karishma Kotian 
*/
    //todo - make it bulkified.
    public static void contractTermination(Set<Id> Ids, String sObjectName){
        String requestBodyContainer;
        try{
            String queryBuildFields = '';
            List<API_Mapping__mdt> erpMappingBuild = new List<API_Mapping__mdt>(); 
            List<Agreement__c> agreements = new List<Agreement__c>();
            List<Lease_Contract__c> leaseContracts = new List<Lease_Contract__c>(); 
            
            for(API_Mapping__mdt erpMap : [Select Data_Type__c, ERP_Field__c, Salesforce_Field__c, 
                                           SF_Object_Name__c,IsConstant__c, Constant_Value__c  
                                           FROM API_Mapping__mdt WHERE API_Header__c 
                                           IN (SELECT Id FROM API_Header__mdt where API_Name__c ='Contract Termination') AND 
                                           SF_Object_Name__c = : sObjectName
                                           Order By SF_Object_Name__c]) {
                                               erpMappingBuild.add(erpMap);
                                               if(!String.isBlank(erpMap.Salesforce_Field__c)) {
                                                   queryBuildFields += erpMap.Salesforce_Field__c + ',';
                                               }
                                           }
            queryBuildFields = queryBuildFields.removeEnd(',');
            
            String finalQry = 'SELECT ' + queryBuildFields + ' FROM '+sObjectName+' Where Id In: Ids LIMIT 1';
            String reqBodyMain = '{"' + ERPUtilities.TERMINATE_CONTRACT_JSON_HEAD + '":{"RESTHeader":{},"InputParameters":{';
            
            if(sObjectName == 'Agreement__c'){
                agreements = Database.query(finalQry);
                if(agreements != null && !agreements.isEmpty()){
                    for(Agreement__c agreement : agreements) {
                        reqBodyMain += ERPUtilities.createReqBody(agreement,erpMappingBuild);
                    }
                }
            }else if(sObjectName == 'Lease_Contract__c'){
                leaseContracts = Database.query(finalQry);
                if(leaseContracts != null && !leaseContracts.isEmpty()){
                    for(Lease_Contract__c contract : leaseContracts) {
                        reqBodyMain += ERPUtilities.createReqBody(contract,erpMappingBuild);
                    }
                }
            }
            reqBodyMain = reqBodyMain.removeEnd(',');
            reqBodyMain += '}}}';
            System.debug('@@reqBodyMain : ' +reqBodyMain);
            requestBodyContainer = reqBodyMain;
            
            String strEndPoint = ERPUtilities.getEndPoint('Contract Termination');
            System.debug('@@Endpoint : '+strEndPoint);
            
            String responseBody = ERPUtilities.makeHTTPRequest(reqBodyMain,strEndPoint, 'POST');
            System.debug('@@responseBody : ' +responseBody );
            
            ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
            if(erpResponse != null && erpResponse.OutputParameters != null) {
                if(sObjectName == 'Agreement__c'){
                    Agreement__c agreement = agreements[0];
                    if(erpResponse.OutputParameters.X_RETURN_STATUS != null && erpResponse.OutputParameters.X_RETURN_STATUS!= ''){
                        agreement.ERP_Status__c = erpResponse.OutputParameters.X_RETURN_STATUS;
                        agreement.ERP_Messages__c = erpResponse.OutputParameters.X_MSG_DATA == null ? '' : erpResponse.OutputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    }else{
                        agreement.ERP_Messages__c = String.valueOf(erpResponse.OutputParameters).left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    }
                    
                    agreement.Sync_Agreement_Termination__c = false;
                    update agreement;
                }else if(sObjectName == 'Lease_Contract__c'){
                    Lease_Contract__c leaseContract = leaseContracts[0];
                    if(erpResponse.OutputParameters.X_RETURN_STATUS != null && erpResponse.OutputParameters.X_RETURN_STATUS!= ''){
                        leaseContract.ERP_Status__c = erpResponse.OutputParameters.X_RETURN_STATUS;
                        leaseContract.ERP_Messages__c = erpResponse.OutputParameters.X_MSG_DATA == null ? '' : erpResponse.OutputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    }else{
                        leaseContract.ERP_Messages__c = String.valueOf(erpResponse.OutputParameters).left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    }
                    leaseContract.Sync_Contract_Termination__c = false;
                    update leaseContract;
                } 
                
                LoggerUtility.logAPI('contractTermination','contractTermination','POST',reqBodyMain,responseBody,strEndPoint, '',true);
            }
        } catch(exception ex) {
            System.debug('@@@Error: ' + ex);
            System.debug('@@@Error line number: ' + ex.getLineNumber()+ 'Message :'+ex.getMessage());
            LoggerUtility.logException(ex,requestBodyContainer,'','');
        }
    }
    
    
    
    
    /*Method: Create Credit Memo in ERP
* Desc:  Create Credit Memo
* Param: Set of Credit Memo IDs
* Return: None
* Author: Vishal A
*/
    //todo - make it bulkified.
    /*public static void createCreditMemo(Set<Id> creditIds){
        String requestBodyContainer;
        try{
            String queryCreditMemo = '';
            List<API_Mapping__mdt> erpMappingCreditMem = new List<API_Mapping__mdt>();
            Set<String> setFields = new Set<String>();
            
            for(API_Mapping__mdt erpMap : [Select Data_Type__c, ERP_Field__c, Salesforce_Field__c, 
                                           SF_Object_Name__c,IsConstant__c, Constant_Value__c  
                                           FROM API_Mapping__mdt WHERE API_Header__c 
                                           IN (SELECT Id FROM API_Header__mdt where API_Name__c ='Credit Memo Creation') 
                                           Order By SF_Object_Name__c]) {
                                               if(erpMap.SF_Object_Name__c == 'Credit_Memo__c') {
                                                   erpMappingCreditMem.add(erpMap);
                                                   if(!String.isBlank(erpMap.Salesforce_Field__c) && !setFields.contains(erpMap.Salesforce_Field__c)) {
                                                       queryCreditMemo += erpMap.Salesforce_Field__c + ',';
                                                       setFields.add(erpMap.Salesforce_Field__c);
                                                   }
                                               }
                                           }
            
            queryCreditMemo = queryCreditMemo.removeEnd(',');
            
            String finalQry = 'SELECT ' + queryCreditMemo + ' FROM Credit_Memo__c Where Id In: creditIds LIMIT 1';
            
            List<Credit_Memo__c> creditMs = Database.query(finalQry);
            if(creditMs != null && !creditMs.isEmpty()) {
                String reqBodyMain = '{"' + ERPUtilities.CREDITMEMO_CREATE_JSON_HEAD + '":{"RESTHeader":{},"InputParameters":{';
                
                for(Credit_Memo__c creditMemo : creditMs) {
                    reqBodyMain += ERPUtilities.createReqBody(creditMemo,erpMappingCreditMem);
                }
                
                reqBodyMain = reqBodyMain.removeEnd(',');
                reqBodyMain += '}}}';
                System.debug('@@reqBodyMain : ' +reqBodyMain);
                requestBodyContainer = reqBodyMain;
                
                String strEndPoint = ERPUtilities.getEndPoint('Credit Memo Creation');
                System.debug('@@Endpoint : '+strEndPoint);
                
                String responseBody = ERPUtilities.makeHTTPRequest(reqBodyMain,strEndPoint, 'POST');
                System.debug('@@responseBody : ' +responseBody );
                
                ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
                if(erpResponse != null && erpResponse.OutputParameters != null) {
                    Credit_Memo__c crMemo = creditMs[0];
                    if(String.isNotBlank(erpResponse.OutputParameters.X_ATTRIBUTE1)) {
                        crMemo.ERP_CreditMemo_Id__c = erpResponse.OutputParameters.X_ATTRIBUTE1;
                    }
                    if(String.isNotBlank(erpResponse.OutputParameters.X_RETURN_STATUS) && erpResponse.OutputParameters.X_RETURN_STATUS != null){
                        crMemo.ERP_Status__c = erpResponse.OutputParameters.X_RETURN_STATUS;
                        //crMemo.ERP_API_Message__c = erpResponse.OutputParameters.X_MSG_DATA;
                    }else if(erpResponse.OutputParameters.X_ATTRIBUTE1 == null){
                        //crMemo.ERP_API_Message__c = String.valueOf(erpResponse.OutputParameters).left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    }
                    crMemo.Send_Credit_Memo_to_ERP__c = false;
                    update crMemo;
                }else if (erpResponse != null && erpResponse.ISGServiceFault != null ){
                    Credit_Memo__c crMemo = creditMs[0];
                    //crMemo.ERP_API_Message__c = String.valueOf(erpResponse.ISGServiceFault).left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    crMemo.Send_Credit_Memo_to_ERP__c = false;
                    update crMemo;
                }
                
                LoggerUtility.logAPI('CreditMemoTriggerHandler','createCreditMemo','POST',reqBodyMain,responseBody,strEndPoint, '',true);
            }
        } catch(exception ex) {
            System.debug('@@@Error: ' + ex);
            LoggerUtility.logException(ex,requestBodyContainer,'','');
        }
    }*/
    
    /*Method: Generate Account statement by fetching details from ERP
* Desc:  Generate account statement 
* Param: Id of Opportunity
* Return: Customer Statment Id
* Author: Karishma Kotian 
*/
    public static Id generateAccountStatement(Id OpportunityID){
        Id custStatementId;
        String requestBodyContainer;
        try{
            Opportunity oppty = [SELECT Id, Agreement__c,ERP_Unit_ID__c, Unit__r.ERP_Business_Unit_Id__c, ERP_Cust_Account_ID__c, AccountId,Unit__c
                                 FROM Opportunity WHERE ID =: OpportunityID];
            String strEndPoint = ERPUtilities.getEndPoint(ERPUtilities.API_NAME_GET_ACCOUNT_STATEMENT);
            String reqBodyMain = '{"' + ERPUtilities.HELPER_SERVICE_JSON_HEAD + '":{"RESTHeader":{},"InputParameters":{';
            if(oppty.ERP_Unit_ID__c != null && oppty.Unit__r.ERP_Business_Unit_Id__c != null && oppty.ERP_Cust_Account_ID__c != null){
                reqBodyMain += '"P_CUST_ACCOUNT_ID" : '+'"'+oppty.ERP_Cust_Account_ID__c+'",';
                reqBodyMain += '"P_LOCATION_ID" : '+'"'+oppty.ERP_Unit_ID__c+'",';
                reqBodyMain += '"P_ORG_ID" : '+'"'+oppty.Unit__r.ERP_Business_Unit_Id__c+'"';
            }
            reqBodyMain += '}}}';
            String responseBody = ERPUtilities.makeHTTPRequest(reqBodyMain,strEndPoint, 'POST');
            
            ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
            if(erpResponse != null && erpResponse.OutputParameters != null) {
                if((erpResponse.OutputParameters.X_CUSTOMER_STATEMENT != null && erpResponse.OutputParameters.X_CUSTOMER_STATEMENT.X_CUSTOMER_STATEMENT_ITEM != null) || 
                   (erpResponse.OutputParameters.X_UNAPPLIED_RECEIPTS != null && erpResponse.OutputParameters.X_UNAPPLIED_RECEIPTS.X_UNAPPLIED_RECEIPTS_ITEM != null)) {
                       
                       String jointOwners = '';
                       for(Joint_Buyer__c jointBuy : [Select Id,Secondary_Account__r.Name,Secondary_Account__c FROM Joint_Buyer__c WHERE Opportunity__c =:oppty.Id AND Secondary_Account__c != null]) {
                           jointOwners += ' ' + jointBuy.Secondary_Account__r.Name + ',';
                       }
                       jointOwners = jointOwners.removeENd(',');
                       
                       Customer_Statement__c cusStat = new Customer_Statement__c();
                       cusStat.Account__c = oppty.AccountId;
                       cusStat.Opportunity__c = oppty.Id;
                       cusStat.Unit__c = oppty.Unit__c;
                       cusStat.Agreement__c = oppty.Agreement__c;
                       cusStat.Joint_Owner__c = jointOwners;
                       insert cusStat;
                       
                       custStatementId = cusStat.Id;
                       
                       List<SOA_Transaction__c> saoTransactions = new List<SOA_Transaction__c>();
                       
                       if(erpResponse.OutputParameters.X_CUSTOMER_STATEMENT != null && erpResponse.OutputParameters.X_CUSTOMER_STATEMENT.X_CUSTOMER_STATEMENT_ITEM != null) {
                           List<ERPAPIResponse.X_CUSTOMER_STATEMENT_ITEM> custStatmentList = erpResponse.OutputParameters.X_CUSTOMER_STATEMENT.X_CUSTOMER_STATEMENT_ITEM;
                           
                           for(ERPAPIResponse.X_CUSTOMER_STATEMENT_ITEM schItem : custStatmentList) {
                               SOA_Transaction__c saoTrans = new SOA_Transaction__c();
                               saoTrans.Table_Type__c = 'X_CUSTOMER_STATEMENT';
                               saoTrans.Customer_Statement__c = cusStat.Id;
                               saoTrans.Payment_Purpose__c = schItem.PAYMENT_PURPOSE;
                               saoTrans.ERP_Lease_Id__c = schItem.LEASE_ID;
                               
                               saoTrans.Invoice_Amount__c = schItem.ACTUAL_AMOUNT == null ? null : Decimal.valueOf(schItem.ACTUAL_AMOUNT);
                               saoTrans.Invoice_Date__c = schItem.TRX_DATE == null ? null : Date.valueOf(schItem.TRX_DATE.split('T')[0]);
                               saoTrans.Invoice_Number__c = schItem.TRX_NUMBER;
                               
                               saoTrans.Receipt_Amount__c = schItem.RECEIPT_AMOUNT == null ? null : Decimal.valueOf(schItem.RECEIPT_AMOUNT);
                               saoTrans.Receipt_Doc_Trans_Number__c = schItem.DOC_SEQUENCE_VALUE;
                               saoTrans.Receipt_Cheque_Number__c = schItem.RECEIPT;
                               saoTrans.Receipt_Date__c = schItem.RECEIPT_DATE == null ? null : Date.valueOf(schItem.RECEIPT_DATE.split('T')[0]);
                               
                               saoTrans.Sequence__c = schItem.SEQ;
                               
                               saoTransactions.add(saoTrans);
                           }
                       }
                       
                       
                       if(erpResponse.OutputParameters.X_UNAPPLIED_RECEIPTS != null && erpResponse.OutputParameters.X_UNAPPLIED_RECEIPTS.X_UNAPPLIED_RECEIPTS_ITEM != null) {
                           List<ERPAPIResponse.X_UNAPPLIED_RECEIPTS_ITEM> unappReceipItems = erpResponse.OutputParameters.X_UNAPPLIED_RECEIPTS.X_UNAPPLIED_RECEIPTS_ITEM;
                           Integer i=1;
                           for(ERPAPIResponse.X_UNAPPLIED_RECEIPTS_ITEM upRecItem : unappReceipItems) {
                               SOA_Transaction__c saoTrans = new SOA_Transaction__c();
                               saoTrans.Table_Type__c = 'X_UNAPPLIED_RECEIPTS';
                               saoTrans.Customer_Statement__c = cusStat.Id;
                               saoTrans.Payment_Purpose__c = upRecItem.PAYMENT_PURPOSE;
                               saoTrans.ERP_Cash_Receipt_ID__c = upRecItem.CASH_RECEIPT_ID;
                               saoTrans.ERP_Lease_Id__c = upRecItem.LEASE_ID;
                               
                               saoTrans.Invoice_Amount__c = upRecItem.ACTUAL_AMOUNT == null ? null : Decimal.valueOf(upRecItem.ACTUAL_AMOUNT);
                               saoTrans.Invoice_Currency__c = upRecItem.INV_CUR;
                               saoTrans.Invoice_Date__c = upRecItem.TRX_DATE == null ? null : Date.valueOf(upRecItem.TRX_DATE.split('T')[0]);
                               saoTrans.Invoice_Number__c = upRecItem.TRX_NUMBER;
                               
                               saoTrans.Receipt_Amount__c = upRecItem.RECEIPT_AMOUNT == null ? null : Decimal.valueOf(upRecItem.RECEIPT_AMOUNT);
                               saoTrans.Receipt_Doc_Trans_Number__c = upRecItem.DOC_SEQUENCE_VALUE;
                               saoTrans.Receipt_Cheque_Number__c = upRecItem.RECEIPT_NUMBER;
                               saoTrans.Receipt_Date__c = upRecItem.RECEIPT_DATE == null ? null : Date.valueOf(upRecItem.RECEIPT_DATE.split('T')[0]);
                               saoTrans.Receipt_Cheque_Date__c = upRecItem.DUE_DATE == null ? null : Date.valueOf(upRecItem.DUE_DATE.split('T')[0]);
                               
                               saoTrans.Sequence__c = String.valueOf(i);
                               
                               saoTransactions.add(saoTrans);
                               
                               i++;
                           }
                       }
                       
                       if(!saoTransactions.isEmpty()) {
                           insert saoTransactions;
                       }
                   }
            }
            
            LoggerUtility.logAPI('ERPAPIIntegration','generateAccountStatement','POST',reqBodyMain,responseBody,strEndPoint, '',true);
        } catch(exception ex) {
            System.debug('@@@Error: ' + ex);
            LoggerUtility.logException(ex,requestBodyContainer,'','');
        }
        //return scheduleItemList;
        return custStatementId;
    }
    
    /*Method: get Transaction Type details from ERP
* Desc:  fetch Transaction Type details in ERP Handler
* Param: None
* Return: List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM>
* Author: Karishma Kotian 
*/
    public Static List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM> getTransactionTypeDetails(String businessUnitId,String transacationType){
        System.debug('@@ inside transaction Type :'+businessUnitId);
        String requestBodyContainer;
        List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM> transactionTypeList = new List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM>();
        try{
            String strEndPoint = ERPUtilities.getEndPoint(ERPUtilities.API_NAME_HELPER_SERVICE);
            List<API_Mapping__mdt> erpMapList = [Select ERP_Field__c FROM API_Mapping__mdt 
                                                 WHERE API_Header__c IN
                                                 (SELECT Id FROM API_Header__mdt WHERE API_Name__c =:ERPUtilities.API_NAME_HELPER_SERVICE )];
            String reqBodyMain = '{"' + ERPUtilities.HELPER_SERVICE_JSON_HEAD + '":{"RESTHeader":{},"InputParameters":{';
            for(API_Mapping__mdt erpMap : erpMapList){
                if(erpMap.ERP_Field__c == 'P_ATTRIBUTE_CATEGORY')
                    //reqBodyMain += '"'+erpMap.ERP_Field__c+'": '+'"TRANSACTION_TYPE",';
                    reqBodyMain += '"'+erpMap.ERP_Field__c+'": '+'"' + transacationType + '",';
                if(erpMap.ERP_Field__c == 'P_ATTRIBUTE1')
                    reqBodyMain += '"'+erpMap.ERP_Field__c+'": '+'"'+businessUnitId+'",';
            }
            reqBodyMain = reqBodyMain.removeEnd(',');
            reqBodyMain += '}}}';
            String responseBody = ERPUtilities.makeHTTPRequest(reqBodyMain,strEndPoint, 'POST');
            System.debug('@@endpoint :'+strEndPoint);
            System.debug('@@request: '+reqBodyMain);
            System.debug('@@responseBody : ' +responseBody );
            
            ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
            if(erpResponse != null && erpResponse.OutputParameters != null && erpResponse.OutputParameters.X_HELPER_RESULT_TBL1 != null && erpResponse.OutputParameters.X_HELPER_RESULT_TBL1.X_HELPER_RESULT_TBL1_ITEM != null) {
                transactionTypeList = erpResponse.OutputParameters.X_HELPER_RESULT_TBL1.X_HELPER_RESULT_TBL1_ITEM;
            }
            system.debug('@@transactionTypeList :'+transactionTypeList);
            
        } catch(exception ex) {
            System.debug('@@@Error: ' + ex);
            LoggerUtility.logException(ex,requestBodyContainer,'','');
        }
        return transactionTypeList;
    }
    
    
    /*Method: leaseContracatSOCreation
* Desc: ERP Project Creation API call handler for leasing
* Param: erpMappingAgr - Field mapping for lease contract
* Param: erpMappingUnt - Field mapping for unit
* Param: erpMappingPayMile - Field mapping for payment milestone
* Param: erpMappingAddChrg - Field mapping for additional charges
* Return: wrpper object with lease contract and log
*/ 
    public Static WrpGenericAPIResponse leaseContracatSOCreation(Lease_Contract__c leaseContract, 
                                                                 List<API_Mapping__mdt> erpMappingAgr, 
                                                                 List<API_Mapping__mdt> erpMappingUnt, 
                                                                 List<API_Mapping__mdt> erpMappingPayMile,
                                                                 List<API_Mapping__mdt> erpMappingAddChrg, 
                                                                 List<Unit_Plan__c> unitPlans, 
                                                                 List<Payment_Milestone__c> mileStones,
                                                                 List<Opportunity_Charges__c> addCharges) 
    {
        String requestBodyContainer;
        Logger__c log = null;
        WrpGenericAPIResponse wrpResponse;
        try{
            if(leaseContract != null ) {
                Id oppId = leaseContract.Opportunity__c;
                String reqBodyMain = '{"' + ERPUtilities.SALE_LEAS_SO_CREATION_JSON_HEAD + '":{"RESTHeader":{},"InputParameters":{';
                reqBodyMain += ERPUtilities.createReqBody(leaseContract,erpMappingAgr);
                Unit_Plan__c untPlan = null;
                //Loop logic for Opp Unit request
                if(unitPlans != null && !unitPlans.isEmpty()) {
                    untPlan = unitPlans[0];
                    reqBodyMain += '"P_TENANT_TBL": {"P_TENANT_TBL_ITEM": [';
                    for(Unit_Plan__c unitSales : unitPlans) {
                        reqBodyMain += '{' + ERPUtilities.createReqBody(unitSales,erpMappingUnt);
                        reqBodyMain = reqBodyMain.removeEnd(',');
                        reqBodyMain += '},';
                    }
                    reqBodyMain = reqBodyMain.removeEnd(',');
                    reqBodyMain += ']},';
                }
                if((mileStones != null && !mileStones.isEmpty()) || (addCharges != null && !addCharges.isEmpty())) {
                    reqBodyMain += '"P_SCHEDULE_TBL": {"P_SCHEDULE_TBL_ITEM": [';
                    
                    //Loop logic for Payment milestone request
                    if(mileStones != null && !mileStones.isEmpty()) {
                        for(Payment_Milestone__c pMile : mileStones) {
                            if(pMile.Installment__c != null && (pMile.Installment__c.contains('1') || pMile.Installment__c.contains('2') || pMile.Installment__c.contains('JGE'))) {
                                pMile.Installment__c = 'BASE';
                            }
                            reqBodyMain += '{' + ERPUtilities.createReqBody(pMile,erpMappingPayMile);
                            reqBodyMain += '"ATTRIBUTE5":"' + (pMile.Unit_Plan__r != null ? pMile.Unit_Plan__r.Unit__r.ERP_Unit_Id__c : '') + '",';
                            reqBodyMain += '"ATTRIBUTE6":"' + (pMile.Unit_Plan__r != null ? pMile.Unit_Plan__r.Unit__r.Unit_Code__c : '') + '",';
                            reqBodyMain = reqBodyMain.removeEnd(',');
                            reqBodyMain += '},';
                        }
                        /*Payment_Milestone__c pMileMerged = new Payment_Milestone__c();
                        Double amounttoSum = 0;
                        for(Payment_Milestone__c pMile : mileStones) {
                            if(pMile.Installment__c != null && !pMile.Installment__c.contains('1') && !pMile.Installment__c.contains('2') && !pMile.Installment__c.contains('JGE')) {
                                reqBodyMain += '{' + ERPUtilities.createReqBody(pMile,erpMappingPayMile);
                                reqBodyMain += '"ATTRIBUTE5":"' + (pMile.Unit_Plan__r != null ? pMile.Unit_Plan__r.Unit__r.ERP_Unit_Id__c : '') + '",';
                                reqBodyMain += '"ATTRIBUTE6":"' + (pMile.Unit_Plan__r != null ? pMile.Unit_Plan__r.Unit__r.Unit_Code__c : '') + '",';
                                reqBodyMain = reqBodyMain.removeEnd(',');
                                reqBodyMain += '},';
                            } else {
                                pMileMerged = pMile;
                                amounttoSum += pMile.Amount__c;
                            }
                        }
                        if(pMileMerged.Id != null) {
                            pMileMerged.Amount__c = amounttoSum;
                            pMileMerged.Installment__c = 'BASE';
                            reqBodyMain += '{' + ERPUtilities.createReqBody(pMileMerged,erpMappingPayMile);
                            reqBodyMain += '"ATTRIBUTE5":"' + (pMileMerged.Unit_Plan__r != null ? pMileMerged.Unit_Plan__r.Unit__r.ERP_Unit_Id__c : '') + '",';
                            reqBodyMain += '"ATTRIBUTE6":"' + (pMileMerged.Unit_Plan__r != null ? pMileMerged.Unit_Plan__r.Unit__r.Unit_Code__c : '') + '",';
                            reqBodyMain = reqBodyMain.removeEnd(',');
                            reqBodyMain += '},';
                        }*/
                    }
                    //Loop logic for Additional charge request
                    if(addCharges != null && !addCharges.isEmpty()) {
                        //commeneted temp for Lease SO change mapping
                        for(Opportunity_Charges__c adChr : addCharges) {
                            reqBodyMain += '{' + ERPUtilities.createReqBody(adChr,erpMappingAddChrg);
                            reqBodyMain += '"ATTRIBUTE5":"' + (adChr.Unit__r != null ? adChr.Unit__r.ERP_Unit_Id__c : '') + '",';
                            reqBodyMain += '"ATTRIBUTE6":"' + (adChr.Unit__r != null ? adChr.Unit__r.Unit_Code__c : '') + '",';
                            reqBodyMain = reqBodyMain.removeEnd(',');
                            reqBodyMain += '},';
                        }
                    }
                    reqBodyMain = reqBodyMain.removeEnd(',');
                    reqBodyMain += ']},';
                }
                
                //replace logic for Unit used in leace opp, Pay milestone and Add charge req body
                if(untPlan != null) {
                    reqBodyMain = reqBodyMain.replace('"P_LOCATION_CODE":""', '"P_LOCATION_CODE":"' + (untPlan.Unit_Code__c == null ? '' : untPlan.Unit_Code__c) + '"');
                    reqBodyMain = reqBodyMain.replace('"P_LOCATION_ID":""', '"P_LOCATION_ID":"' + (untPlan.ERP_Unit_Id__c == null ? '' : untPlan.ERP_Unit_Id__c) + '"');
                    reqBodyMain = reqBodyMain.replace('"LOCATION_ID":""', '"LOCATION_ID":"' + (untPlan.ERP_Unit_Id__c == null ? '' : untPlan.ERP_Unit_Id__c) + '"');
                    reqBodyMain = reqBodyMain.replace('"LOCATION_CODE":""', '"LOCATION_CODE":"' + (untPlan.Unit_Code__c == null ? '' : untPlan.Unit_Code__c) + '"');
                    reqBodyMain = reqBodyMain.replace('"RENTABLE_AREA":""', '"RENTABLE_AREA":"' + (untPlan.Unit__r.Rentable_Area__c == null ? '' : String.valueOf(untPlan.Unit__r.Rentable_Area__c)) + '"');
                }
                
                reqBodyMain = reqBodyMain.removeEnd(',');
                reqBodyMain += '}}}';
                System.debug('@@reqBodyMain : ' +reqBodyMain);
                requestBodyContainer = reqBodyMain;
                String strEndPoint = ERPUtilities.getEndPoint(ERPUtilities.API_NAME_LEASING_SO_CREATION);
                String responseBody = ERPUtilities.makeHTTPRequest(reqBodyMain,strEndPoint, 'POST');
                System.debug('@@responseBody : ' +responseBody );
                
                ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
                if(erpResponse != null && erpResponse.OutputParameters != null) {
                    if(String.isNotBlank(erpResponse.OutputParameters.X_LEASE_NUMBER)) {
                        leaseContract.ERP_Lease_ID__c = erpResponse.OutputParameters.X_LEASE_NUMBER;
                    }
                    if(erpResponse.OutputParameters.X_RETURN_STATUS != null && erpResponse.OutputParameters.X_RETURN_STATUS != ''){
                        leaseContract.ERP_Status__c = erpResponse.OutputParameters.X_RETURN_STATUS;
                        leaseContract.ERP_Messages__c = erpResponse.OutputParameters.X_MSG_DATA == null ? '' : erpResponse.OutputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    }else if(erpResponse.OutputParameters.LEASE_ID == null){
                        leaseContract.ERP_Messages__c = responseBody == null ? '' : responseBody.left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    }
                    leaseContract.Send_Lease_to_ERP__c = false;
                }else if (erpResponse != null && erpResponse.ISGServiceFault != null ){
                    leaseContract.ERP_Messages__c = String.valueOf(erpResponse.ISGServiceFault).left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    leaseContract.Send_Lease_to_ERP__c = false;
                }
                log = LoggerUtility.logAPI('ContractTriggerHandler','leaseContractSOCreation','POST',reqBodyMain,responseBody,strEndPoint, '',false);
            }
        } catch(exception ex) {
            System.debug('@@@Error: ' + ex);
            log = LoggerUtility.logExceptionWithNoDML('Exception',ex.getStackTraceString(),ex,requestBodyContainer,'','');
        }
        
        wrpResponse = new WrpGenericAPIResponse(leaseContract, log);
        return wrpResponse;
        
    }
    
    
    /*Method: salesAgreementSOCreation
* Desc: ERP Project Creation API call handler - sales 
* Param: agrMt - agreement object
* Param: erpMappingAgr - mapping for agreement object
* Param: unitSales - unit object to be pushed
* Param: erpMappingUnt - mapping for unit object
* Param: addCharges - add charges list
* Param: erpMappingAddChrg - mapping for add charges
* Return: None
*/
    public Static WrpGenericAPIResponse salesAgreementSOCreation(Agreement__c agrMt, 
                                                                 List<API_Mapping__mdt> erpMappingAgr, 
                                                                 Unit__c unitSales, 
                                                                 List<API_Mapping__mdt> erpMappingUnt,
                                                                 List<Opportunity_Charges__c> addCharges,
                                                                 List<API_Mapping__mdt> erpMappingAddChrg) {
                                                                     String requestBodyContainer;
                                                                     WrpGenericAPIResponse wrpResponse;
                                                                     Logger__c log = null;
                                                                     try{
                                                                         
                                                                         
                                                                         String reqBodyMain = '{"' + ERPUtilities.SALE_LEAS_SO_CREATION_JSON_HEAD + '":{"RESTHeader":{},"InputParameters":{';
                                                                         
                                                                         //Loop logic for lease Agreement request
                                                                         reqBodyMain += ERPUtilities.createReqBody(agrMt,erpMappingAgr);
                                                                         
                                                                         //Loop logic for Unit request
                                                                         if(unitSales != null) {
                                                                             reqBodyMain += '"P_TENANT_TBL": {"P_TENANT_TBL_ITEM": [{';
                                                                             reqBodyMain += ERPUtilities.createReqBody(unitSales,erpMappingUnt);
                                                                             reqBodyMain = reqBodyMain.removeEnd(',');
                                                                             reqBodyMain += '}]},';
                                                                         }
                                                                         
                                                                         reqBodyMain += '"P_SCHEDULE_TBL": {"P_SCHEDULE_TBL_ITEM": [';
                                                                         
                                                                         /*if(addCharges != null && !addCharges.isEmpty()) {
                                                                             for(Opportunity_Charges__c adChr : addCharges) {
                                                                                 reqBodyMain += '{' + ERPUtilities.createReqBody(adChr,erpMappingAddChrg);
                                                                                 reqBodyMain = reqBodyMain.removeEnd(',');
                                                                                 reqBodyMain += '},';
                                                                             }
                                                                             reqBodyMain = reqBodyMain.removeEnd(',');
                                                                             reqBodyMain += ']},';
                                                                         }else {*/
                                                                             reqBodyMain += ']},';
                                                                        // }
                                                                         
                                                                         
                                                                         reqBodyMain = reqBodyMain.removeEnd(',');
                                                                         reqBodyMain += '}}}';
                                                                         
                                                                         System.debug('@@reqBodyMain : ' +reqBodyMain);
                                                                         requestBodyContainer = reqBodyMain;
                                                                         
                                                                         String strEndPoint = ERPUtilities.getEndPoint(ERPUtilities.API_NAME_SALES_SO_CREATION);
                                                                         
                                                                         String responseBody = ERPUtilities.makeHTTPRequest(reqBodyMain,strEndPoint, 'POST');
                                                                         System.debug('@@responseBody : ' +responseBody );
                                                                         
                                                                         ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
                                                                         if(erpResponse != null && erpResponse.OutputParameters != null) {
                                                                             if(erpResponse.OutputParameters.X_LEASE_NUMBER != null) {
                                                                                 agrMt.ERP_Sales_ID__c = erpResponse.OutputParameters.X_LEASE_NUMBER;
                                                                                 agrMt.ERP_Message__c = erpResponse.OutputParameters.X_MSG_DATA == null ? '' : erpResponse.OutputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                                                                                 agrMt.ERP_Status__c = 'S';
                                                                             } else {
                                                                                 agrMt.ERP_Status__c = 'E';
                                                                                 agrMt.ERP_Message__c = erpResponse.OutputParameters.X_MSG_DATA == null ? '' : erpResponse.OutputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                                                                             }
                                                                             
                                                                         }
                                                                         agrMt.Send_Sales_to_ERP__c = false;
                                                                         log = LoggerUtility.logAPI('AgreementTriggerHandler','agreementSOCreation','POST',reqBodyMain,responseBody,strEndPoint, '',false);
                                                                     } catch(exception ex) {
                                                                         log = LoggerUtility.logExceptionWithNoDML('Exception',ex.getStackTraceString(),ex,requestBodyContainer,'','');
                                                                     }
                                                                     wrpResponse = new WrpGenericAPIResponse(agrMt, log);
                                                                     return wrpResponse;
                                                                 }
    
    
    /*Method: leaseContracatSOCreation
* Desc: ERP Project Creation API call handler
* Param: leaseContrId - Set of Lease Contract Id 
* Return: None
*/ 
    // todo - make it bulkified
    // todo - to be deleted
    public Static void leaseContracatSOCreation(Set<Id> leaseContrId) {
        String requestBodyContainer;
        try{
            String queryLeasConFields = '';
            String queryUntFields = '';
            String queryPayMileFields = '';
            String queryAddChrgFields = '';
            List<API_Mapping__mdt> erpMappingAgr = new List<API_Mapping__mdt>();
            List<API_Mapping__mdt> erpMappingUnt = new List<API_Mapping__mdt>();
            List<API_Mapping__mdt> erpMappingPayMile = new List<API_Mapping__mdt>();
            List<API_Mapping__mdt> erpMappingAddChrg = new List<API_Mapping__mdt>();
            Set<String> setFIelds = new Set<String>();
            Set<String> setFIeldUnits = new Set<String>();
            Set<String> setFIeldPayMiles = new Set<String>();
            Set<String> setFIeldAddChrg = new Set<String>();
            
            for(API_Mapping__mdt erpMap : [Select Data_Type__c, ERP_Field__c, Salesforce_Field__c, SF_Object_Name__c,IsConstant__c, Constant_Value__c  FROM API_Mapping__mdt WHERE API_Header__c In (SELECT Id FROM API_Header__mdt where API_Name__c ='Sales Lease SO Creation') Order By SF_Object_Name__c]) {
                if(erpMap.SF_Object_Name__c == 'Lease_Contract__c') {
                    erpMappingAgr.add(erpMap);
                    if(!String.isBlank(erpMap.Salesforce_Field__c) && !setFIelds.contains(erpMap.Salesforce_Field__c)) {
                        queryLeasConFields += erpMap.Salesforce_Field__c + ',';
                        setFIelds.add(erpMap.Salesforce_Field__c);
                    }
                }
                if(erpMap.SF_Object_Name__c == 'Unit_Plan__c') {
                    erpMappingUnt.add(erpMap);
                    if(!String.isBlank(erpMap.Salesforce_Field__c) && !setFIeldUnits.contains(erpMap.Salesforce_Field__c)) {
                        queryUntFields += erpMap.Salesforce_Field__c + ',';
                        setFIeldUnits.add(erpMap.Salesforce_Field__c);
                    }
                }
                if(erpMap.SF_Object_Name__c == 'Payment_Milestone__c') {
                    erpMappingPayMile.add(erpMap);
                    if(!String.isBlank(erpMap.Salesforce_Field__c) && !setFIeldPayMiles.contains(erpMap.Salesforce_Field__c)) {
                        queryPayMileFields += erpMap.Salesforce_Field__c + ',';
                        setFIeldPayMiles.add(erpMap.Salesforce_Field__c);
                    }
                }
                if(erpMap.SF_Object_Name__c == 'Opportunity_Charges__c') {
                    erpMappingAddChrg.add(erpMap);
                    if(!String.isBlank(erpMap.Salesforce_Field__c) && !setFIeldAddChrg.contains(erpMap.Salesforce_Field__c)) {
                        queryAddChrgFields += erpMap.Salesforce_Field__c + ',';
                        setFIeldAddChrg.add(erpMap.Salesforce_Field__c);
                    }
                }
                
            }
            queryLeasConFields = queryLeasConFields.removeEnd(',');
            
            //Opportunity__r.Unit__c;
            String finalLeContrQry = 'Select ' + queryLeasConFields + ' ,Opportunity__c FROM Lease_Contract__c Where Id In: leaseContrId LIMIT 1';
            
            List<Lease_Contract__c> leaseContr = Database.query(finalLeContrQry);
            if(leaseContr != null && !leaseContr.isEmpty()) {
                Id oppId = leaseContr[0].Opportunity__c;
                
                queryUntFields = queryUntFields.removeEnd(',');
                //Id unitId = leaseContr[0].Opportunity__r.Unit__c;
                String finalUntQry = 'Select ' + queryUntFields + ' ,Unit__r.Rentable_Area__c FROM Unit_Plan__c Where Opportunity__c =: oppId';
                List<Unit_Plan__c> unnts = Database.query(finalUntQry);
                /*Unit__c unitSales = null;
if(unnts != null && !unnts.isEmpty()) {
unitSales = unnts[0];
}*/
                
                queryPayMileFields = queryPayMileFields.removeEnd(',');
                String finalPayMile = 'Select ' + queryPayMileFields + ' FROM Payment_Milestone__c Where Opportunity__c =: oppId';
                List<Payment_Milestone__c> mileStones = Database.query(finalPayMile);
                
                queryAddChrgFields = queryAddChrgFields.removeEnd(',');
                String finalAddChrg = 'Select ' + queryAddChrgFields + ' FROM Opportunity_Charges__c Where Opportunity__c =: oppId';
                List<Opportunity_Charges__c> addCharges = Database.query(finalAddChrg);
                
                String reqBodyMain = '{"' + ERPUtilities.SALE_LEAS_SO_CREATION_JSON_HEAD + '":{"RESTHeader":{},"InputParameters":{';
                
                //Loop logic for lease contracr request
                for(Lease_Contract__c agrMt : leaseContr) {
                    reqBodyMain += ERPUtilities.createReqBody(agrMt,erpMappingAgr);
                    
                    Unit_Plan__c untPlan = null;
                    //Loop logic for Opp Unit request
                    if(unnts != null && !unnts.isEmpty()) {
                        untPlan = unnts[0];
                        reqBodyMain += '"P_TENANT_TBL": {"P_TENANT_TBL_ITEM": [';
                        for(Unit_Plan__c unitSales : unnts) {
                            reqBodyMain += '{' + ERPUtilities.createReqBody(unitSales,erpMappingUnt);
                            reqBodyMain = reqBodyMain.removeEnd(',');
                            reqBodyMain += '},';
                        }
                        reqBodyMain = reqBodyMain.removeEnd(',');
                        reqBodyMain += ']},';
                    }
                    if((mileStones != null && !mileStones.isEmpty()) || (addCharges != null && !addCharges.isEmpty())) {
                        reqBodyMain += '"P_SCHEDULE_TBL": {"P_SCHEDULE_TBL_ITEM": [';
                        
                        //Loop logic for Payment milestone request
                        if(mileStones != null && !mileStones.isEmpty()) {
                            for(Payment_Milestone__c pMile : mileStones) {
                                reqBodyMain += '{' + ERPUtilities.createReqBody(pMile,erpMappingPayMile);
                                reqBodyMain = reqBodyMain.removeEnd(',');
                                reqBodyMain += '},';
                            }
                        }
                        //Loop logic for Additional charge request
                        if(addCharges != null && !addCharges.isEmpty()) {
                            for(Opportunity_Charges__c adChr : addCharges) {
                                reqBodyMain += '{' + ERPUtilities.createReqBody(adChr,erpMappingAddChrg);
                                reqBodyMain = reqBodyMain.removeEnd(',');
                                reqBodyMain += '},';
                            }
                        }
                        reqBodyMain = reqBodyMain.removeEnd(',');
                        reqBodyMain += ']},';
                    }
                    
                    //replace logic for Unit used in leace opp, Pay milestone and Add charge req body
                    if(untPlan != null) {
                        reqBodyMain = reqBodyMain.replace('"P_LOCATION_CODE":""', '"P_LOCATION_CODE":"' + (untPlan.Unit_Code__c == null ? '' : untPlan.Unit_Code__c) + '"');
                        reqBodyMain = reqBodyMain.replace('"P_LOCATION_ID":""', '"P_LOCATION_ID":"' + (untPlan.ERP_Unit_Id__c == null ? '' : untPlan.ERP_Unit_Id__c) + '"');
                        reqBodyMain = reqBodyMain.replace('"LOCATION_ID":""', '"LOCATION_ID":"' + (untPlan.ERP_Unit_Id__c == null ? '' : untPlan.ERP_Unit_Id__c) + '"');
                        reqBodyMain = reqBodyMain.replace('"LOCATION_CODE":""', '"LOCATION_CODE":"' + (untPlan.Unit_Code__c == null ? '' : untPlan.Unit_Code__c) + '"');
                        reqBodyMain = reqBodyMain.replace('"RENTABLE_AREA":""', '"RENTABLE_AREA":"' + (untPlan.Unit__r.Rentable_Area__c == null ? '' : String.valueOf(untPlan.Unit__r.Rentable_Area__c)) + '"');
                    }
                }
                reqBodyMain = reqBodyMain.removeEnd(',');
                reqBodyMain += '}}}';
                
                System.debug('@@reqBodyMain : ' +reqBodyMain);
                requestBodyContainer = reqBodyMain;
                
                String strEndPoint = ERPUtilities.getEndPoint('Sales Lease SO Creation');
                
                String responseBody = ERPUtilities.makeHTTPRequest(reqBodyMain,strEndPoint, 'POST');
                System.debug('@@responseBody : ' +responseBody );
                
                ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
                if(erpResponse != null && erpResponse.OutputParameters != null) {
                    Lease_Contract__c contract = leaseContr[0];
                    if(String.isNotBlank(erpResponse.OutputParameters.X_LEASE_NUMBER)) {
                        contract.ERP_Lease_ID__c = erpResponse.OutputParameters.X_LEASE_NUMBER;
                    }
                    if(erpResponse.OutputParameters.X_RETURN_STATUS != null && erpResponse.OutputParameters.X_RETURN_STATUS != ''){
                        contract.ERP_Status__c = erpResponse.OutputParameters.X_RETURN_STATUS;
                        contract.ERP_Messages__c = erpResponse.OutputParameters.X_MSG_DATA == null ? '' : erpResponse.OutputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    }else if(erpResponse.OutputParameters.LEASE_ID == null){
                        contract.ERP_Messages__c = responseBody == null ? '' : responseBody.left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    }
                    contract.Send_Lease_to_ERP__c = false;
                    update contract;
                }else if (erpResponse != null && erpResponse.ISGServiceFault != null ){
                    Lease_Contract__c contract = leaseContr[0];
                    contract.ERP_Messages__c = String.valueOf(erpResponse.ISGServiceFault).left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    contract.Send_Lease_to_ERP__c = false;
                    update contract;
                }
                LoggerUtility.logAPI('ContractTriggerHandler','leaseContractSOCreation','POST',reqBodyMain,responseBody,strEndPoint, '',true);
            }
        } catch(exception ex) {
            System.debug('@@@Error: ' + ex);
            LoggerUtility.logException(ex,requestBodyContainer,'','');
        }
    }
    
    /*Method: salesAgreementSOCreation
* Desc: ERP Project Creation API call handler
* Param: agreementId - Set of Agreement Id 
* Return: None
*/
    public Static WrpGenericAPIResponse salesAgreementSOCreation(Agreement__c agrMt, List<API_Mapping__mdt> erpMappingAgr, Unit__c unitSales, List<API_Mapping__mdt> erpMappingUnt) {
        String requestBodyContainer;
        WrpGenericAPIResponse wrpResponse;
        Logger__c log = null;
        try{
            
            
            String reqBodyMain = '{"' + ERPUtilities.SALE_LEAS_SO_CREATION_JSON_HEAD + '":{"RESTHeader":{},"InputParameters":{';
            
            //Loop logic for lease Agreement request
            reqBodyMain += ERPUtilities.createReqBody(agrMt,erpMappingAgr);
            
            //Loop logic for Unit request
            if(unitSales != null) {
                reqBodyMain += '"P_TENANT_TBL": {"P_TENANT_TBL_ITEM": [{';
                reqBodyMain += ERPUtilities.createReqBody(unitSales,erpMappingUnt);
                reqBodyMain = reqBodyMain.removeEnd(',');
                reqBodyMain += '}]},';
            }
            
            reqBodyMain += '"P_SCHEDULE_TBL": {"P_SCHEDULE_TBL_ITEM": [';
            
            reqBodyMain += ']},';
            reqBodyMain = reqBodyMain.removeEnd(',');
            reqBodyMain += '}}}';
            
            System.debug('@@reqBodyMain : ' +reqBodyMain);
            requestBodyContainer = reqBodyMain;
            
            String strEndPoint = ERPUtilities.getEndPoint(ERPUtilities.API_NAME_SALES_SO_CREATION);
            
            String responseBody = ERPUtilities.makeHTTPRequest(reqBodyMain,strEndPoint, 'POST');
            System.debug('@@responseBody : ' +responseBody );
            
            ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
            if(erpResponse != null && erpResponse.OutputParameters != null) {
                if(erpResponse.OutputParameters.X_LEASE_NUMBER != null) {
                    agrMt.ERP_Sales_ID__c = erpResponse.OutputParameters.X_LEASE_NUMBER;
                    agrMt.ERP_Message__c = erpResponse.OutputParameters.X_MSG_DATA == null ? '' : erpResponse.OutputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    agrMt.ERP_Status__c = 'S';
                } else {
                    agrMt.ERP_Status__c = 'E';
                    agrMt.ERP_Message__c = erpResponse.OutputParameters.X_MSG_DATA == null ? '' : erpResponse.OutputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                }
                
            }
            agrMt.Send_Sales_to_ERP__c = false;
            log = LoggerUtility.logAPI('AgreementTriggerHandler','agreementSOCreation','POST',reqBodyMain,responseBody,strEndPoint, '',false);
        } catch(exception ex) {
            log = LoggerUtility.logExceptionWithNoDML('Exception',ex.getStackTraceString(),ex,requestBodyContainer,'','');
        }
        wrpResponse = new WrpGenericAPIResponse(agrMt, log);
        return wrpResponse;
    }
    
    /*Method: opportunityCreation
    * Desc: ERP Opportunity Creation API call handler - sales 
    * Param: opptty - Opportunity object
    * Param: erpMappingOpp - mapping for opportunity object
    * Param: unitPlans - list of Opportunity Unit object
    * Param: erpMappingUnt - mapping for opportunity unit object
    * Return: WrpGenericAPIResponse - wrapper for Sobject and logger
    */
    public Static WrpGenericAPIResponse opportunityCreation(Opportunity opptty,
                                                                 List<API_Mapping__mdt> erpMappingOpp,
                                                                 List<Unit_Plan__c> unitPlans,
                                                                 List<API_Mapping__mdt> erpMappingOppUnit) {
        String requestBodyContainer;
        WrpGenericAPIResponse wrpResponse;
        Logger__c log = null;
        try{
            
            
            String reqBodyMain = '{"' + ERPUtilities.OPPORTUNITY_CREATION_JSON_HEAD + '":{"RESTHeader":{},"InputParameters":{';
            
            //Loop logic for opportunity request
            reqBodyMain += ERPUtilities.createReqBody(opptty,erpMappingOpp);
            reqBodyMain += '"P_OPPORTUNITY_LINES": { "P_OPPORTUNITY_LINES_ITEM": [';
            //Loop logic for Unit Plan
            if(unitPlans != null && !unitPlans.isEmpty()) {
                
                for(Unit_Plan__c unPl : unitPlans) {
                    reqBodyMain += '{' + ERPUtilities.createReqBody(unPl,erpMappingOppUnit);
                    reqBodyMain = reqBodyMain.removeEnd(',');
                    reqBodyMain += '},';
                }
                
                reqBodyMain = reqBodyMain.removeEnd(',');
            }
            reqBodyMain = reqBodyMain.removeEnd(',');
            reqBodyMain += ']}}}}';
            
            System.debug('@@reqBodyMain : ' +reqBodyMain);
            requestBodyContainer = reqBodyMain;
            
            String strEndPoint = ERPUtilities.getEndPoint(ERPUtilities.API_NAME_OPPORTUNITY_CREATION);
            
            String responseBody = ERPUtilities.makeHTTPRequest(reqBodyMain,strEndPoint, 'POST');
            System.debug('@@responseBody : ' +responseBody );
            
            ERPAPIResponse erpResponse = ERPAPIResponse.parse(responseBody);
            if(erpResponse != null && erpResponse.OutputParameters != null) {
                if(erpResponse.OutputParameters.P_OPPORTUNITY_ID != null) {
                    opptty.ERP_Opportunity_ID__c = erpResponse.OutputParameters.P_OPPORTUNITY_ID;
                    opptty.ERP_Message__c = erpResponse.OutputParameters.X_MSG_DATA == null ? '' : erpResponse.OutputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                    opptty.ERP_Status__c = 'S';
                } else {
                    opptty.ERP_Status__c = 'E';
                    opptty.ERP_Message__c = erpResponse.OutputParameters.X_MSG_DATA == null ? '' : erpResponse.OutputParameters.X_MSG_DATA.left(ERPUtilities.ERROR_MESSAGE_LENGTH);
                }
                
            }
            opptty.Send_Opportunity_to_ERP__c = false;
            log = LoggerUtility.logAPI('ERPAPIIntegration','Opportunity Creation','POST',reqBodyMain,responseBody,strEndPoint, '',false);
        } catch(exception ex) {
            log = LoggerUtility.logExceptionWithNoDML('Exception',ex.getStackTraceString(),ex,requestBodyContainer,'','');
        }
        wrpResponse = new WrpGenericAPIResponse(opptty, log);
        return wrpResponse;
    }
    
    public class WrpGenericAPIResponse {
        public Logger__c log;
        public sObject sobj;
        
        
        public WrpGenericAPIResponse(sObject sobj, Logger__c log) {
            this.sobj = sobj;
            this.log = log;
        }
    }
}