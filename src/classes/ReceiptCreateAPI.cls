/****************************************************************************************************************************
* @Name         ReceiptCreateAPI
* @Author       Hitesh Patel, Kitaracloud Techlabs
* @Date         21-May-2022
* @Description  Receipt API - NOS
****************************************************************************************************************************/
@RestResource(urlMapping='/ReceiptCreate')
global class ReceiptCreateAPI {
    @httpPost
    global static ReceiptCreateResponse doPostMethod(){
        RestRequest request = RestContext.request;
        ReceiptCreateResponse objRCR = new ReceiptCreateResponse();
        
        try{
            ReceiptCreateRequest objReq = (ReceiptCreateRequest) System.JSON.deserialize(request.requestBody.toString(), ReceiptCreateRequest.class);
            List<Opportunity> dealList = [SELECT Id, (SELECT Id, Account__c,Amount__c FROM OnlinePayments__r WHERE Payment_Mode__c = 'Online' LIMIT 1) FROM Opportunity WHERE Leasing_Number__c =: objReq.LeaseNumber LIMIT 1];
            if(!dealList.isEmpty()){
                if(objReq.PaymentMode == 'Online Transfer'){
                    if(!dealList[0].OnlinePayments__r.isEmpty()){
                        Receipt__c objRec = new Receipt__c(Id=dealList[0].OnlinePayments__r[0].Id);
                        if(objReq.Amount != null && objReq.Amount != ''){
                                objRec.Payment_Status__c = 'Paid';
                           // objRec.Amount__c = decimal.valueOf(objReq.Amount);
                        }
                        objRec.Source__c = 'NOS';
                        objRec.Transaction_Id__c = objReq.PaymentReference;
                        objRec.Invoice_ID__c = objReq.PaymentReference;
                        objRec.Receipt_Number__c = objReq.ReceiptNumber;
                        objRec.Due_Date__c = date.valueOf(objReq.ReceiptDate);
                        if(dealList[0].OnlinePayments__r[0].Account__c == null){
                            List<Account> accList = [SELECT Id FROM Account WHERE ERP_Account_ID__c =: objReq.CustomerNumber LIMIT 1];
                            if(!accList.isEmpty()){
                                objRec.Account__c = accList[0].Id;
                            }
                        }
                        update objRec;
                        
                        objRCR.Status = 'Success';
                        objRCR.Statuscode = '200';
                        objRCR.Message = ': Receipt updated successfully.';
                    }else{
                        objRCR.Status = 'Success';
                        objRCR.Statuscode = '200';
                        objRCR.Message = 'Receipt not found.';
                    }
                }else if(objReq.PaymentMode == 'Bank Transfer'){
                    
                    ScheduleAmendmentController.ParentWrapper objPW = ScheduleAmendmentController.getScheduleAmendments(dealList[0].Id);
                    objPW.source = 'NOS';
                    Boolean isSuccess = ScheduleAmendmentController.createReceipts(objPW, false);
                    
                    if(isSuccess != null && isSuccess){
                        objRCR.Status = 'Success';
                        objRCR.Statuscode = '200';
                        objRCR.Message = ': Receipt created successfully.';
                    }else{
                        objRCR.Status = 'Success';
                        objRCR.Statuscode = '400';
                        objRCR.Message = 'Error during Receipt Creation.';
                    }
                }
            }else{
                objRCR.Status = 'Success';
                objRCR.Statuscode = '200';
                objRCR.Message = 'Deal not found.';
            }
        }catch (Exception ex){
            objRCR.Status = 'Fail';
            objRCR.Statuscode = '400';
            objRCR.Message = 'Error during Receipt Creation: ' + ex.getMessage();
        }
        return objRCR;
    }
    
    global class ReceiptCreateRequest{
        global String Amount;
        global String Source;
        global String LeaseNumber;
        global String PaymentMode;
        global String PaymentReference;
        global String ReceiptNumber;
        global String CustomerNumber;
        global String ReceiptDate;
    }
    
    global class ReceiptCreateResponse{
        global String Status;
        global String Statuscode;
        global String Message;
        
    }
}