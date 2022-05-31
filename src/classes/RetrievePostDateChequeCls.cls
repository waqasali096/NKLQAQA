/*
@Author : Taha Hamid
@CreatedDate: 09/05/2022
@ This class will be called by the 3rd party system to get the postdatedcheque details (Receipts)
*/
@RestResource(urlMapping='/getPostDateChequeDetails/*')
global class RetrievePostDateChequeCls {
    @HttpPost
    global static postDatedOutputWrapper getDetails(){
        postDatedInputWrapper postDateIns = new postDatedInputWrapper(); 
        postDatedOutputWrapper postDateResp = new postDatedOutputWrapper();       
        List<PaymentMethods> lstPaymentMethods = new list<PaymentMethods>();
        PaymentMethods insPayRecord = new PaymentMethods();
        Boolean IsRecordExistFlag = false;
        RestRequest request = RestContext.request;      
        RestContext.response.addHeader('Content-Type', 'application/json');

        string buildingCodeStr = '';
        string buildingNameStr = '';
        string locationCodeStr = '';
        string spaceTypeStr = '';
        string bankAccountNumber = '';
        string merchantIdStr = '';
        string workingKeyStr = '';
        string accessCodeStr = ''; 
        try {
            postDateIns = (postDatedInputWrapper)System.JSON.deserialize(RestContext.request.requestBody.toString(),postDatedInputWrapper.class);      
               
        	if(postDateIns.dueInDays != null && postDateIns.dueInDays != ''){
                
                integer dueDateDays = integer.valueOf(postDateIns.dueInDays);
            
                Date insFutureDate = Date.today().addDays(dueDateDays);
                Date insPastDate = Date.today().addDays(dueDateDays - (dueDateDays*2));
    
                system.debug('Taha>>insFutureDate' + insFutureDate);
                system.debug('Taha>>insPastDate' + insPastDate);
    
                //Unit_Plan__c insUnitPlan = new Unit_Plan__c();
                List<String> lstLeaseNumber = new List<String>();
                if(postDateIns.leaseNumber != null && postDateIns.leaseNumber != ''){
                    lstLeaseNumber = postDateIns.leaseNumber.split(',');
                    for(Opportunity opp : [select id,(select id,Unit__c,Unit__r.Building__c,Unit__r.Building_Code__c,Unit__r.Building_Name__c,
                                            Unit__r.Unit_Code__c,Unit__r.Leasing_Type__c,Unit__r.Project__r.Bank__r.Bank_Account_Number__c
                                            from Unit_Plans__r) from Opportunity where Leasing_Number__c IN: lstLeaseNumber or Lease_Number__c IN: lstLeaseNumber])
                    {
                        for(Unit_Plan__c unitRec: opp.Unit_Plans__r)
                        {
                            system.debug('Taha');
                            buildingCodeStr = unitRec.Unit__r.Building_Code__c;
                            buildingNameStr = unitRec.Unit__r.Building_Name__c;
                            locationCodeStr = locationCodeStr + unitRec.Unit__r.Unit_Code__c;
                            spaceTypeStr = unitRec.Unit__r.Leasing_Type__c;
                            bankAccountNumber = unitRec.Unit__r.Project__r.Bank__r.Bank_Account_Number__c;
                            //insUnitPlan.Unit__c = unitRec.Unit__c;
                            //insUnit.Building__c = unitRec.Building__c;
                            //insUnit.Unit_Code__c = unitRec.Unit_Code__c;
                        }
                    }
        
                    if(locationCodeStr != '' && locationCodeStr.contains(','))
                    {
                        locationCodeStr = locationCodeStr.removeEnd(',');                
                    }
        
                    // query receipt method
                    for(Receipt_Method__c rmRec : [select id,Merchant_ID__c,Working_Key__c,Access_Code__c from Receipt_Method__c where name LIKE '%Online%'
                                                       and Bank_Account_Number__c =: bankAccountNumber])
                    {
                        merchantIdStr = string.valueOf(rmRec.Merchant_ID__c);
                        workingKeyStr = rmRec.Working_Key__c;
                        accessCodeStr = rmRec.Access_Code__c;
                    }                                               
                    // query recipt method based on bank account
                    for(Receipt__c recp: [select id,Amount__c,ERP_Receipt_Number__c,Receipt_Comments__c,
                                          Opportunity__r.Account.Name, Opportunity__r.Account.ERP_Account_Number__c,
                                          Opportunity__r.Leasing_Number__c,Opportunity__r.ERP_Opportunity_ID__c,
                                          ERP_Document_Sequence__c,Opportunity__r.Opportunity_Number__c,
                                          Due_Date__c,Opportunity__r.Project__r.Business_Unit__c,Payment_Status__c,
                                          ERP_Receipt_ID__c,Opportunity__r.Project__r.Business_Unit__r.Business_Unit_Code__c
                                          from Receipt__c
                                          where (Due_Date__c <=:insFutureDate AND 
                                          Due_Date__c >=: Date.today()) and (Opportunity__r.Leasing_Number__c IN: lstLeaseNumber or Opportunity__r.Lease_Number__c IN: lstLeaseNumber)
                                          and Payment_Mode__c = 'Cheque'])
                    {
                        IsRecordExistFlag = true;
                        PaymentMethods objRec = new PaymentMethods();
                        objRec.amountApplied = ((recp.Payment_Status__c == 'Paid' || recp.Payment_Status__c == 'Cleared') ? recp.Amount__c : 0);
                        objRec.amountPending = ((recp.Payment_Status__c != 'Paid' && recp.Payment_Status__c != 'Cleared') ? recp.Amount__c : 0);
                        objRec.receiptNumber = recp.ERP_Receipt_Number__c;
                        objRec.comments = recp.Receipt_Comments__c;
                        objRec.customerName = recp.Opportunity__r.Account.Name;
                        objRec.customerNumber = recp.Opportunity__r.Account.ERP_Account_Number__c;
                        objRec.docNumber = recp.ERP_Document_Sequence__c;
                        objRec.leaseId = recp.Opportunity__r.Opportunity_Number__c;
                        objRec.BATCH_ID = recp.Opportunity__r.ERP_Opportunity_ID__c;
                        objRec.leaseNumber = recp.Opportunity__r.Leasing_Number__c;//postDateIns.leaseNumber;
                        objRec.maturityDate = recp.Due_Date__c;
                        objRec.orgId = recp.Opportunity__r.Project__r.Business_Unit__r.Business_Unit_Code__c;
                        objRec.buildingCode = buildingCodeStr;
                        objRec.buildingName = buildingNameStr;
                        objRec.locationCode = locationCodeStr;
                        objRec.spaceType = spaceTypeStr;
                        objRec.receiptStatus = recp.Payment_Status__c;
                        objRec.cashReceiptId = recp.ERP_Receipt_ID__c;
                        objRec.receiptAmount = recp.Amount__c;
                        objRec.merchantId = merchantIdStr;
                        objRec.workingKey = workingKeyStr;
                        objRec.accessCode = accessCodeStr;
                        objRec.message = 'Success';
                        objRec.statusCode = 200;
                        lstPaymentMethods.add(objRec);
        
                    }     
                    
                    if(!IsRecordExistFlag)
                    {
                        insPayRecord.message = 'No Record Found';
                        insPayRecord.statusCode = 204;
                        lstPaymentMethods.add(insPayRecord);
                    }
                    
                    postDateResp.PaymentMethods = lstPaymentMethods;
                    return postDateResp;
                }else{
                    insPayRecord.message = 'Please provide leaseNumber.';
                    insPayRecord.statusCode = 200;
                    lstPaymentMethods.add(insPayRecord);
        
                    postDateResp.PaymentMethods = lstPaymentMethods;
                    return postDateResp;
                }
            }else{
                insPayRecord.message = 'Please provide dueInDays.';
                insPayRecord.statusCode = 200;
                lstPaymentMethods.add(insPayRecord);
    
                postDateResp.PaymentMethods = lstPaymentMethods;
                return postDateResp;
            }
        }catch (Exception ex) {
            insPayRecord.message = ex.getMessage();
            insPayRecord.statusCode = 400;
            lstPaymentMethods.add(insPayRecord);

            postDateResp.PaymentMethods = lstPaymentMethods;
            return postDateResp;
        }
    }

    // Wrapper to be used to get the input from the callout made by external system
    global class postDatedInputWrapper {
        global String leaseNumber;
        global String customerNumber;
        global String dueInDays;      
    }    

    global class postDatedOutputWrapper {
        global List<PaymentMethods> PaymentMethods;      
    }

	global class PaymentMethods {
		global decimal amountApplied;
		global decimal amountPending;
		global String buildingCode;
		global String buildingName;
		global String receiptNumber;
		global String comments;
		global String customerName;
		global String customerNumber;
		global String docNumber;
		global String leaseId;
		global String leaseNumber;
		global String locationCode;
		global Date maturityDate;
		global String orgId;
        global string message;
        global integer statusCode;
        global string spaceType;
        global string receiptStatus;
        global string cashReceiptId;
        global decimal receiptAmount;
        global string merchantId;
        global string workingKey;
        global string accessCode;
        global string BATCH_ID;
	}
}