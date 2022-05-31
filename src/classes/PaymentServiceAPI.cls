/****************************************************************************************************************************
* @Name         PaymentServiceAPI
* @Author       Hitesh Patel, Kitaracloud Techlabs
* @Date         04-May-2022
* @Description  Payment Advice and Payment Receipt integration
****************************************************************************************************************************/
@RestResource(urlMapping='/PaymentService')
global class PaymentServiceAPI{
    @httpPost
    global static PaymentWrapperResponse doPostMethod(){
        RestRequest request = RestContext.request;
        PaymentWrapperResponse objPWR = new PaymentWrapperResponse();
        objPWR.serviceOwnerId = '';
        objPWR.serviceId = '';
        objPWR.receiptNumber = '';
        objPWR.licenseKey = '';
        objPWR.amount = '';
        objPWR.rentalAmount = '';
        objPWR.SecurityDepositAmount = '';
        objPWR.totalAdditionalCharges = '';
        objPWR.totalAmount = '';
        RestContext.response.addHeader('Content-Type', 'application/json');
        
        PaymentWrapperRequest objPW = (PaymentWrapperRequest) System.JSON.deserialize(request.requestBody.toString(), PaymentWrapperRequest.class);
        if(objPW != null){
        
            List<Opportunity> oppList = [SELECT Id, Name, Final_Lease_Amount__c, Security_Deposit__c, Total_Charges_Amount__c, Project__r.Bank__r.Bank_Account_Number__c, Project__c, Project__r.Bank__c, (SELECT Id, ERP_Receipt_ID__c, Receipt_Method__r.Merchant_ID__c, Receipt_Method__r.Working_Key__c, Receipt_Method__r.Access_Code__c FROM OnlinePayments__r WHERE Payment_Mode__c = 'Online Payment' ORDER BY Lastmodifieddate DESC) FROM Opportunity WHERE Leasing_Number__c =:  objPW.leaseNumber];
            
            if(!oppList.isEmpty()){
                Decimal decTotalAmount = 0;
                if(oppList[0].Final_Lease_Amount__c != null){
                    objPWR.rentalAmount = String.valueOf(oppList[0].Final_Lease_Amount__c);
                    decTotalAmount = oppList[0].Final_Lease_Amount__c;
                }
                if(oppList[0].Security_Deposit__c != null){
                    objPWR.SecurityDepositAmount = String.valueOf(oppList[0].Security_Deposit__c);
                    decTotalAmount += oppList[0].Security_Deposit__c;
                }
                if(oppList[0].Total_Charges_Amount__c != null){
                    objPWR.totalAdditionalCharges = String.valueOf(oppList[0].Total_Charges_Amount__c);
                    decTotalAmount += oppList[0].Total_Charges_Amount__c;
                }
                if(decTotalAmount > 0){
                    objPWR.totalAmount = String.valueOf(decTotalAmount);
                }
                
                
                List<Document__c> documentList = [SELECT Id FROM Document__c WHERE Opportunity__c =: oppList[0].Id AND Document_Type__c =: objPW.templateName];
                
                if(!documentList.isEmpty()){
                    List<ContentDocumentLink> cdList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: documentList[0].Id];
                    if(!cdList.isEmpty()){
                        List<Contentversion> cvList = [SELECT Id, Title, FileType, FileExtension, VersionData FROM Contentversion WHERE ContentdocumentId =: cdList[0].ContentDocumentId];
                        objPWR.Status = 'Success';
                        objPWR.fileBody = EncodingUtil.base64Encode(cvList[0].VersionData);
                        objPWR.fileName = cvList[0].Title;
                        objPWR.fileType = cvList[0].FileType;
                        if(objPWR.fileType == 'PDF'){
                            objPWR.fileType = 'application/pdf';
                        }
                        if(objPWR.fileType == 'TEXT'){
                            objPWR.fileType = 'text/plain';
                        }
                    }else{
                        objPWR.Status = 'File not found';
                        objPWR.fileBody = '';
                        objPWR.fileName = '';
                        objPWR.fileType = '';
                    }
                }else{
                    objPWR.Status = 'Document not found';
                    objPWR.fileBody = '';
                    objPWR.fileName = '';
                    objPWR.fileType = '';
                }
                
                if(!oppList[0].OnlinePayments__r.isEmpty()){
                    String strReceiptNumber = '';
                    for(Receipt__c rc: oppList[0].OnlinePayments__r){
                        if(rc.ERP_Receipt_ID__c != null){
                            if(strReceiptNumber == ''){
                                strReceiptNumber = rc.ERP_Receipt_ID__c;
                            }else{
                                strReceiptNumber += ',' + rc.ERP_Receipt_ID__c;
                            }
                        }
                        
                    }
                    objPWR.receiptNumber = strReceiptNumber;
                    String strTotalLeaseAmount = '';
                    Decimal totalLeaseAmount = 0;
                    if(oppList[0].Final_Lease_Amount__c != null && oppList[0].Final_Lease_Amount__c > 0){
                        totalLeaseAmount = oppList[0].Final_Lease_Amount__c;
                    }
                    if(oppList[0].Security_Deposit__c != null && oppList[0].Security_Deposit__c > 0){
                        totalLeaseAmount += oppList[0].Security_Deposit__c;
                    }
                    if(oppList[0].Total_Charges_Amount__c != null && oppList[0].Total_Charges_Amount__c > 0){
                        totalLeaseAmount += oppList[0].Total_Charges_Amount__c;
                    }
                    if(totalLeaseAmount > 0){
                        strTotalLeaseAmount = String.valueOf(totalLeaseAmount);
                    }
                    objPWR.amount = strTotalLeaseAmount;
                    
                    
                }
				String strMerchantId = '';
				String strServiceId = '';
				String strLicenseKey = '';
				if(oppList[0].Project__c != null && oppList[0].Project__r.Bank__c != null && oppList[0].Project__r.Bank__r.Bank_Account_Number__c != null){
					String strOnline = '%Online%';
					List<Receipt_Method__c> receiptMethodList = [SELECT Id, Merchant_ID__c, Working_Key__c, Access_Code__c FROM Receipt_Method__c WHERE Name LIKE: strOnline AND Bank_Account_Number__c =: oppList[0].Project__r.Bank__r.Bank_Account_Number__c ORDER BY LASTMODIFIEDDATE DESC LIMIT 1];
					if(!receiptMethodList.isEmpty()){
						if(receiptMethodList[0].Merchant_ID__c != null){
							 strMerchantId = String.valueOf(receiptMethodList[0].Merchant_ID__c);
						}
						
						if(receiptMethodList[0].Working_Key__c != null){
							 strServiceId = receiptMethodList[0].Working_Key__c; 
						}
						if(receiptMethodList[0].Access_Code__c != null){
							 strLicenseKey = receiptMethodList[0].Access_Code__c;
						}
					}
				}
				objPWR.serviceOwnerId = strMerchantId;
				objPWR.serviceId = strServiceId;
				objPWR.licenseKey = strLicenseKey;
				
            }else{
                objPWR.Status = 'Lease doesn’t exist';
                objPWR.fileBody = '';
                objPWR.fileName = '';
                objPWR.fileType = '';
            }
        }
        return objPWR;
    }
    
    global class PaymentWrapperRequest{
        global String templateName;
        global String leaseNumber;
    }
    
    global class PaymentWrapperResponse{
        global String status;
        global String fileBody;
        global String fileName;
        global String fileType;
        
        global String serviceOwnerId;
        global String serviceId;
        global String licenseKey;
        global String amount;
        global String receiptNumber;
        
        global String rentalAmount;
        global String SecurityDepositAmount;
        global String totalAdditionalCharges;
        global String totalAmount;
            
    }
}