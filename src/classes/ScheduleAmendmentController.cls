/*
@Author : Swapnil Mohite
@CreatedDate: 20/02/2022
@ This apex class will handle all cashier related functionalities
*/
public class ScheduleAmendmentController {
    
    /*
@Author : Swapnil Mohite
@CreatedDate: 20/02/2022
@ This method will fetch the installments
*/
    @AuraEnabled
    public static parentWrapper getInstallments(String oppId){
        List<ResultWrapper> resultList = new List<ResultWrapper>();
        parentWrapper parentWrapper = new parentWrapper();
        Map<String, String> pickLabelApiMap = getPicklistValues('Payment_Milestone__c','Installment__c');
        Map<String, String> bankMap = getPicklistValues('Receipt__c','Bank__c');
        Map<String, String> paymentOptions = getPickListValues('Receipt__c','Payment_Mode__c');
        List<Schedule_Amendment__c> amendsmentList = new List<Schedule_Amendment__c>();
        List<AdjustmentWrapper> adjustmentList = new List<AdjustmentWrapper>();
        decimal d = 0.00;
        Opportunity opp = [SELECT id,Booking_Mode__c,createddate, Booking_Fee_gets_collected__c, Payment_Mode__c,Booking_Amount__c,Receipt_Generated__c,
                           project__r.bank__r.Bank_Account_Number__c,project__r.business_unit__c,project__r.business_unit__r.Business_Unit_Code__c,(select id,name from Unit_Plans__r)
                           FROM Opportunity
                           WHERE Id =: oppId];
        
        List<Schedule_Amendment__c> bookingAmendment = [SELECT Id,Name,Agreement__c,Payment_Mode__c,remarks__c ,Amount__c,Amount_Percentage__c,Due_Date__c,Installment__c,Installment_No__c,unit__r.unit_code__c,
                                                        Opportunity__c,transaction_id__c,Leasing_Remarks__c,Payment_Milestone__c,cheque_No__c,Is_Split__c,Adjusted_To__c,bank_branch__c,bank_city__c,bank__c,Proposed_Amount__c,Proposed_Date__c,Total_Amount__c,VAT_Amount__c,additional_charges__c,unit__c,Is_Reciept_Created__c
                                                        FROM Schedule_Amendment__c
                                                        WHERE Opportunity__c = : oppId AND Installment__c = 'Holding Deposit'];
        if(opp.Booking_Mode__c =='Reservation with token amount' && opp.Booking_Fee_gets_collected__c == false){
            ResultWrapper bookingWrapper = new ResultWrapper();
            if(bookingAmendment.size() > 0){
                parentWrapper.isEdit = true;
                bookingWrapper.paymentTermType = 'Holding Deposit';
                bookingWrapper.itemDescription = 'Holding Deposit';
                bookingWrapper.dueDate = Date.valueOf(opp.CreatedDate);
                bookingWrapper.amount = bookingAmendment[0].Proposed_Amount__c ;
                bookingWrapper.proposedAmount = bookingAmendment[0].Proposed_Amount__c ;
                bookingWrapper.oppId = oppId; 
                bookingWrapper.isReceiptCreated = bookingAmendment[0].Is_Reciept_Created__c;
                bookingWrapper.paymentMode = bookingAmendment[0].Payment_Mode__c;
                bookingWrapper.recordId = bookingAmendment[0].Id;
                bookingWrapper.bankname = bookingAmendment[0].bank__c;
                bookingWrapper.bankCity = bookingAmendment[0].bank_city__c;
                bookingWrapper.bankBranch = bookingAmendment[0].bank_branch__c;
                bookingWrapper.chequeNo = bookingAmendment[0].cheque_no__c;
                bookingWrapper.remarks =  bookingAmendment[0].remarks__c;
                bookingWrapper.execRemarks =  bookingAmendment[0].Leasing_Remarks__c;
                bookingWrapper.remarks =  bookingAmendment[0].remarks__c;
                bookingWrapper.transactionId =  bookingAmendment[0].transaction_id__c;
                parentWrapper.isBooking = true;
                parentWrapper.oppId = oppId;
            }else{
                parentWrapper.isEdit = false;
                bookingWrapper.paymentTermType = 'Holding Deposit';
                bookingWrapper.itemDescription = 'Holding Deposit';
                bookingWrapper.dueDate = Date.valueOf(opp.CreatedDate);
                bookingWrapper.amount = opp.Booking_Amount__c ;
                bookingWrapper.proposedAmount = opp.Booking_Amount__c;
                bookingWrapper.oppId = oppId; 
                bookingWrapper.paymentMode = 'Cash';
                bookingWrapper.isReceiptCreated = opp.Receipt_Generated__c; 
                bookingWrapper.bankName = '';
                bookingWrapper.bankCity = 'Dubai';
                bookingWrapper.bankBranch = 'Dubai';
                parentWrapper.isBooking = true;
                parentWrapper.oppId = oppId;
            }
            parentWrapper.bookingWrapper = bookingWrapper;
            resultList.add(bookingWrapper);
            d = bookingWrapper.proposedAmount;
        }else{
            
            amendsmentList = [SELECT Id,Name,Agreement__c,Amount__c,Payment_Mode__c,remarks__c ,Amount_Percentage__c,Due_Date__c,Installment__c,Installment_No__c,unit__r.unit_code__c,
                              Opportunity__c,Payment_Milestone__c,Is_Charges__c,transaction_id__c,Adjusted_To__c,Leasing_Remarks__c ,cheque_No__c,bank_branch__c,bank_city__c,bank__c,Is_Split__c,Proposed_Amount__c,Proposed_Date__c,Total_Amount__c,VAT_Amount__c,additional_charges__c,unit__c,is_reciept_created__c
                              FROM Schedule_Amendment__c
                              WHERE Opportunity__c = : oppId AND  Installment__c != 'Holding Deposit'];
            Cashier_Screen_Configuration__mdt cashierConfig = [SELECT MasterLabel,developername,Number_Value__c
                                                               FROM Cashier_Screen_Configuration__mdt 
                                                               WHERE developername = 'Proposed_Date_Threshold'];
            if(opp.unit_plans__r.size() == 1){
                parentWrapper.isBulk = false;
            }else{
                parentWrapper.isBulk = true;
            }
            
            if(amendsmentList.size()<=0){
                parentWrapper.isEdit = false;
                parentWrapper.oppId = oppId;
                if(opp.unit_plans__r.size() == 1){
                    List<Payment_Milestone__c> installmentList = [SELECT Id, OwnerId, IsDeleted, Name,Master_Payment_Plan__c, Amount_Percentage__c, Amount__c,
                                                                  Due_Date__c, Due_In_Days__c, Installment_No__c, Milestone_Trigger_Point__c, 
                                                                  Opportunity__c, Installment__c,Payable_Amount__c,payment_mode__c, Unit__c, Lead__c, Agreement__c,unit__r.unit_code__c,VAT_Amount__c
                                                                  FROM Payment_Milestone__c
                                                                  WHERE Opportunity__c = : oppId]; //and is_reciept_created__c = false];
                    List<Opportunity_Charges__c> additionalList = [SELECT Id, IsDeleted, Name, Due_Date__c ,Amount__c, Opportunity__c,VAT_Amount__c,VAT__c,
                                                                   Payable_Amount__c, Master_Additional_Charges__c, Project__c, Unit__c,unit__r.unit_code__c, Payment_Term_Type_Code__c   
                                                                   FROM Opportunity_Charges__c 
                                                                   WHERE Opportunity__c = : oppId ];
                    
                    for(Opportunity_Charges__c addObj: additionalList){
                        
                        ResultWrapper resultWrapper = new ResultWrapper();
                        resultWrapper.paymentTermType = addObj.Name;
                        resultWrapper.itemDescription = addObj.Payment_Term_Type_Code__c;
                        resultWrapper.itemDesValue = addObj.Name;
                        resultWrapper.dueDate = addObj.Due_Date__c;
                        resultWrapper.amount = addObj.Amount__c;
                        resultWrapper.vatAmount = addObj.VAT_Amount__c;
                        resultWrapper.totalAmount = addObj.Payable_Amount__c;
                        resultWrapper.proposedAmount = addObj.Payable_Amount__c;
                        resultWrapper.proposedDate = addObj.Due_Date__c;
                        resultWrapper.allocate = false;
                        resultWrapper.isReceiptCreated =false;
                        resultWrapper.paymentMode = 'Cash';
                        //resultWrapper.allocateComments = 
                        resultWrapper.isSplit = false;
                        resultWrapper.oppId = oppId; 
                        resultWrapper.recordId = addObj.Id;
                        resultWrapper.bankCity = 'Dubai';
                        resultWrapper.bankBranch = 'Dubai';
                        resultWrapper.isCharges = true;
                        resultWrapper.additionalChargesId = addObj.Id;
                        resultWrapper.unitCode = addObj.unit__r.unit_code__c;
                        resultWrapper.unitId = addObj.unit__c;
                        if(addObj.Due_Date__c!=null){
                            resultWrapper.proposedThresholdDate = addObj.Due_Date__c.addDays((Integer)cashierConfig.Number_Value__c);
                        }
                        
                        
                        resultList.add(resultWrapper);
                        d = d + resultWrapper.totalAmount;
                        
                        
                    }
                    for(Payment_Milestone__c payMilObj: installmentList){
                        
                        ResultWrapper resultWrapper = new ResultWrapper();
                        resultWrapper.paymentTermType = pickLabelApiMap.get(payMilObj.Installment__c);
                        resultWrapper.itemDescription = payMilObj.Installment__c;
                        resultWrapper.itemDesValue = pickLabelApiMap.get(payMilObj.Installment__c);
                        resultWrapper.dueDate = payMilObj.Due_Date__c;
                        if(payMilObj.Installment__c == '01-JGE'&& opp.Booking_Mode__c =='Reservation with token amount'){
                            resultWrapper.amount = payMilObj.amount__c  - opp.Booking_Amount__c;
                            resultWrapper.totalAmount = payMilObj.Payable_Amount__c - opp.Booking_Amount__c;
                            resultWrapper.proposedAmount = payMilObj.Payable_Amount__c - opp.Booking_Amount__c;
                            
                        }else{
                            resultWrapper.amount = payMilObj.Amount__c ;
                            resultWrapper.totalAmount = payMilObj.Payable_Amount__c;
                            resultWrapper.proposedAmount = payMilObj.Payable_Amount__c;
                        }
                        
                        if(payMilObj.Installment__c == '01-JGE' || payMilObj.Installment__c == 'SEC'){
                            resultWrapper.paymentMode = 'Cash';
                        }else{
                            resultWrapper.paymentMode = 'Cheque';
                        }// defaulting the payment modes
                        resultWrapper.vatAmount = payMilObj.VAT_Amount__c;
                        resultWrapper.proposedDate = payMilObj.Due_Date__c;
                        resultWrapper.allocate = false;
                        resultWrapper.isReceiptCreated =false;
                        resultWrapper.bankCity = 'Dubai';
                        resultWrapper.bankBranch = 'Dubai';
                        //resultWrapper.allocateComments = 
                        resultWrapper.isSplit = false;
                        resultWrapper.oppId = oppId;
                        resultWrapper.recordId = payMilObj.Id;
                        resultWrapper.isCharges = false;
                        resultWrapper.paymentMilestoneId = payMilObj.Id;
                        resultWrapper.unitCode = payMilObj.unit__r.unit_code__c;
                        resultWrapper.unitId = payMilObj.unit__c;
                        if(payMilObj.Due_Date__c!=null){
                            resultWrapper.proposedThresholdDate = payMilObj.Due_Date__c.addDays((Integer)cashierConfig.Number_Value__c);
                        }
                        resultList.add(resultWrapper);
                        d = d + resultWrapper.totalAmount;
                    }
                }else{ // code for bulk
                    List<Aggregated_Milestone__c> aggrList = [SELECT Id,Amount__c, Billing_Configuration__c, Due_Date__c, Payment_Status__c, Installment__c, 
                                                              Payment_Mode__c, Vat_Code__c, Vat__c, Vat_Amount__c, Total_Amount__c, Description__c,name ,
                                                              Is_Reciept_Created__c, Deal__c, IsAdditionalCharges__c, Payment_Term_Type__c  
                                                              FROM Aggregated_Milestone__c
                                                              WHERE deal__c =: oppId];
                    for(Aggregated_Milestone__c aggrObj : aggrList){
                        ResultWrapper resultWrapper = new ResultWrapper();
                        if(aggrObj.IsAdditionalCharges__c){
                            resultWrapper.paymentTermType = aggrObj.name;
                            resultWrapper.itemDescription = aggrObj.Payment_Term_Type__c;
                            resultWrapper.itemDesValue = aggrObj.name;
                            resultWrapper.isCharges = true;
                            
                        }else{
                            resultWrapper.paymentTermType = pickLabelApiMap.get(aggrObj.Installment__c);
                            resultWrapper.itemDescription = aggrObj.Installment__c;
                            resultWrapper.itemDesValue = pickLabelApiMap.get(aggrObj.Installment__c);
                            resultWrapper.isCharges = false;
                        }
                        resultWrapper.dueDate = aggrObj.Due_Date__c;
                        if(aggrObj.Installment__c == '01-JGE'&& opp.Booking_Mode__c =='Reservation with token amount'){
                            resultWrapper.amount = aggrObj.amount__c  - opp.Booking_Amount__c;
                            resultWrapper.totalAmount = aggrObj.Total_Amount__c - opp.Booking_Amount__c;
                            resultWrapper.proposedAmount = aggrObj.Total_Amount__c - opp.Booking_Amount__c;
                            
                        }else{
                            resultWrapper.amount = aggrObj.Amount__c ;
                            resultWrapper.totalAmount = aggrObj.Total_Amount__c;
                            resultWrapper.proposedAmount = aggrObj.Total_Amount__c;
                        }
                        if(aggrObj.Installment__c == '01-JGE' || aggrObj.Installment__c == 'SEC' || aggrObj.IsAdditionalCharges__c){
                            resultWrapper.paymentMode = 'Cash';
                        }else{
                            resultWrapper.paymentMode = 'Cheque';
                        }
                        
                        resultWrapper.vatAmount = aggrObj.VAT_Amount__c;
                        resultWrapper.proposedDate = aggrObj.Due_Date__c;
                        resultWrapper.allocate = false;
                        resultWrapper.isReceiptCreated =false;
                        resultWrapper.bankCity = 'Dubai';
                        resultWrapper.bankBranch = 'Dubai';
                        //resultWrapper.paymentMode = aggrObj.payment_mode__c;
                        resultWrapper.isSplit = false;
                        resultWrapper.oppId = oppId;
                        if(aggrObj.Due_Date__c!=null){
                            resultWrapper.proposedThresholdDate = aggrObj.Due_Date__c.addDays((Integer)cashierConfig.Number_Value__c);
                        }
                        resultList.add(resultWrapper);
                        d = d + resultWrapper.totalAmount;
                    }
                }
            }else{
                parentWrapper.isEdit = true;
                parentWrapper.oppId = oppId;
                for(Schedule_Amendment__c payMilObj: amendsmentList){
                    ResultWrapper resultWrapper = new ResultWrapper();
                    if(payMilObj.is_charges__c){
                        resultWrapper.itemDesValue = payMilObj.name;
                        resultWrapper.ischarges = true;
                    }else{
                        resultWrapper.itemDesValue = pickLabelApiMap.get(payMilObj.Installment__c);
                        resultWrapper.ischarges = false;
                    }
                    if(payMilObj.adjusted_to__c !=null){
                        resultWrapper.proposedAmount = null;
                    }else{
                        resultWrapper.proposedAmount = payMilObj.Proposed_Amount__c;
                    }
                    if( payMilObj.additional_charges__c !=null){
                        
                    }else{
                        
                    }
                    resultWrapper.paymentTermType = payMilObj.Name;
                    resultWrapper.itemDescription = payMilObj.Installment__c;
                    
                    resultWrapper.dueDate = payMilObj.Due_Date__c;
                    resultWrapper.amount = payMilObj.Amount__c;
                    resultWrapper.vatAmount = payMilObj.Vat_amount__c;
                    resultWrapper.totalAmount = payMilObj.total_amount__c;
                    resultWrapper.proposedDate = payMilObj.Proposed_Date__c;
                    resultWrapper.bankName = payMilObj.bank__c;
                    resultWrapper.bankCity = payMilObj.bank_city__c;
                    resultWrapper.bankBranch = payMilObj.bank_branch__c;
                    resultWrapper.chequeNo = payMilObj.cheque_no__c;
                    resultWrapper.allocate = false;
                    resultWrapper.paymentMode = payMilObj.Payment_Mode__c;
                    resultWrapper.isReceiptCreated = payMilObj.Is_Reciept_Created__c;
                    //resultWrapper.allocateComments = 
                    resultWrapper.isSplit = payMilObj.Is_Split__c ;
                    resultWrapper.oppId = oppId;
                    resultWrapper.recordId = payMilObj.Id;
                    resultWrapper.paymentMilestoneId = payMilObj.payment_milestone__c;
                    resultWrapper.additionalChargesId = payMilObj.additional_charges__c;
                    resultWrapper.unitCode = payMilObj.unit__r.unit_code__c;
                    resultWrapper.unitId = payMilObj.unit__c;
                    if(payMilObj.Proposed_Date__c!=null){
                        resultWrapper.proposedThresholdDate = payMilObj.Due_Date__c.addDays((Integer)cashierConfig.Number_Value__c); 
                    }
                    resultWrapper.transactionId = payMilObj.transaction_id__c;
                    resultWrapper.execRemarks = payMilObj.Leasing_Remarks__c;
                    resultList.add(resultWrapper);
                    d = d + resultWrapper.totalAmount;
                }            
            }
            
            parentWrapper.proposedThresholdDays = cashierConfig.Number_Value__c;
            parentWrapper.adjustmentList = adjustmentList;
            
        }
        parentWrapper.resultWrapperList = resultList;
        parentWrapper.totalAmount = d;
        parentWrapper.bankMap = bankMap;
        parentWrapper.bankBranchId = opp.project__r.bank__r.Bank_Account_Number__c;
        parentWrapper.buId = opp.project__r.business_unit__c;
        parentWrapper.paymentOptions = paymentOptions;
        return parentWrapper;
    }
    /*
@Author : Asams
@CreatedDate: 20/02/2022
@ This method fetch scheduleAmendments
*/    
    @AuraEnabled
    public static ParentWrapper getScheduleAmendments(String oppId){
        List<ResultWrapper> resultList = new List<ResultWrapper>();
        List<Schedule_Amendment__c> amendsmentList = new List<Schedule_Amendment__c>();
        
        String businessUnit ='';
        List<Payment_Milestone__c> installmentList = new List<Payment_Milestone__c>();
        ParentWrapper parentWrapper = new ParentWrapper();
        Opportunity opp = [SELECT id,Booking_Mode__c,createddate, Booking_Fee_gets_collected__c, Payment_Mode__c,Booking_Amount__c,Receipt_Generated__c,
                           project__r.bank__r.Bank_Account_Number__c,project__r.business_unit__c
                           FROM Opportunity
                           WHERE Id =: oppId];
        amendsmentList = [SELECT Id, OwnerId, IsDeleted,Leasing_Remarks__c,transaction_id__c , remarks__c,Name,Installment_No__c, Agreement__c, Amount_Percentage__c, Amount__c,Adjusted_To__c,bank__c,
                          Due_Date__c, Opportunity__c,Opportunity__r.project__r.business_unit__c, Payment_Milestone__c, Proposed_Amount__c, Proposed_Date__c, VAT_Amount__c,
                          Total_Amount__c, Method__c,cheque_no__c,Comment__c,Payment_Mode__c,Is_Charges__c, Additional_Charges__c, Installment__c,Is_Reciept_Created__c, Unit__r.business_unit__c ,unit__c,unit__r.unit_code__c
                          FROM Schedule_Amendment__c
                          WHERE Opportunity__c = : oppId and  Payment_Mode__c != 'Online' and is_reciept_created__c = false]; 
        Map<String, String> pickLabelApiMap = getPicklistValues('Payment_Milestone__c','Installment__c');
        decimal d = 0;
        for(Schedule_Amendment__c payMilObj: amendsmentList){
            
            ResultWrapper resultWrapper = new ResultWrapper();
            resultWrapper.adjustedTo = payMilObj.adjusted_to__c;
            resultWrapper.paymentTermType = payMilObj.Name;
            resultWrapper.itemDescription = payMilObj.Installment__c;
            if(payMilObj.is_charges__c != null){
                resultWrapper.itemDesValue = payMilObj.Name;
            }else{
                resultWrapper.itemDesValue = pickLabelApiMap.get(payMilObj.Installment__c);
            }
            resultWrapper.dueDate = payMilObj.Due_Date__c;
            resultWrapper.amount = payMilObj.Amount__c;
            resultWrapper.vatAmount = payMilObj.Vat_amount__c;
            resultWrapper.proposedAmount = payMilObj.proposed_amount__c;
            resultWrapper.proposedDate = payMilObj.Proposed_Date__c;
            resultWrapper.paymentMode = payMilObj.Payment_Mode__c;
            resultWrapper.isReceiptCreated = payMilObj.Is_Reciept_Created__c;
            resultWrapper.chequeNo = payMilObj.cheque_no__c;
            //resultWrapper.allocateComments = 
            //resultWrapper.isSplit = payMilObj.Is_Split__c ;
            resultWrapper.bankName =payMilObj.bank__c;
            resultWrapper.oppId = oppId;
            resultWrapper.recordId = payMilObj.Id;
            resultWrapper.isCharges = payMilObj.is_charges__c;
            resultWrapper.paymentMilestoneId = payMilObj.payment_milestone__c;
            resultWrapper.additionalChargesId = payMilObj.additional_charges__c;
            resultWrapper.unitCode = payMilObj.unit__r.unit_code__c;
            resultWrapper.unitId = payMilObj.unit__c;
            resultWrapper.remarks = payMilObj.remarks__c;
            resultWrapper.execRemarks = payMilObj.Leasing_Remarks__c;
            resultWrapper.transactionId = payMilObj.transaction_id__c;
            resultList.add(resultWrapper);
            d = d + payMilObj.proposed_amount__c;
        }
        parentWrapper.totalAmount = d;
        parentWrapper.bankBranchId = opp.project__r.bank__r.Bank_Account_Number__c;
        parentWrapper.buId = opp.project__r.business_unit__c;
        parentWrapper.resultWrapperList = resultList;
        parentWrapper.oppId = oppId;
        
        return parentWrapper;
    }
    
    /*
@Author : Swapnil Mohite
@CreatedDate: 20/02/2022
@ This method create scheduleAmendments
*/    
    @AuraEnabled
    public static boolean createScheduleAmendments(ParentWrapper parentWrapper,Boolean isEdit,Boolean fromCashier){//Add wrapper param
        List<Schedule_Amendment__c> schedAmendsList = new List<Schedule_Amendment__c>();
        List<ResultWrapper> amendmentList = new List<ResultWrapper>();
        List<Id> schedAmendIds = new List<Id>();
        Map<String, String> pickLabelApiMap = getPicklistValues('Payment_Milestone__c','Installment__c');
        Opportunity opp;/* = new Opportunity();*/ //did via swapnil
        if(parentWrapper.isBooking == true){
            system.debug('Inside If>>>>>');
            parentWrapper.bookingWrapper = parentWrapper.resultWrapperList[0];
            Schedule_Amendment__c schedAmend = new Schedule_Amendment__c();
            if(String.isNotBlank(parentWrapper.bookingWrapper.recordId) && isEdit){
                schedAmend.Id = parentWrapper.bookingWrapper.recordId;
            }
            schedAmend.Name =  parentWrapper.bookingWrapper.paymentTermType;
            schedAmend.Installment__c = parentWrapper.bookingWrapper.itemDescription;
            schedAmend.Proposed_Amount__c = parentWrapper.bookingWrapper.proposedAmount;
            schedAmend.Due_Date__c = parentWrapper.bookingWrapper.dueDate;
            schedAmend.Opportunity__c = parentWrapper.bookingWrapper.oppId;
            schedAmend.Payment_Mode__c =parentWrapper.bookingWrapper.paymentMode;
            schedAmend.bank__c =parentWrapper.bookingWrapper.bankName;
            schedAmend.bank_branch__c =parentWrapper.bookingWrapper.bankBranch;
            schedAmend.bank_city__c =parentWrapper.bookingWrapper.bankCity;
            schedAmend.cheque_no__c =parentWrapper.bookingWrapper.chequeNo;
            schedAmend.Amount__c = parentWrapper.bookingWrapper.amount;
            schedAmend.Leasing_Remarks__c = parentWrapper.bookingWrapper.execRemarks;
            if(schedAmend.payment_mode__c == 'Online'){
                schedAmend.remarks__c =  parentWrapper.bookingWrapper.execRemarks;
            }else{
                schedAmend.remarks__c = parentWrapper.bookingWrapper.remarks;
            }
            schedAmend.transaction_id__c = parentWrapper.bookingWrapper.transactionId;
            opp=new Opportunity();
            opp.Id = parentWrapper.bookingWrapper.oppId;
            opp.Cashier_Payment_Pending__c = true;
            
            schedAmendsList.add(schedAmend);
        }else{
            //if(scheduleAmendmentsWrapList.size()>0){
            system.debug('Inside Else>>>>>');
            for(ResultWrapper wrap:parentWrapper.resultWrapperList){
                Schedule_Amendment__c schedAmend = new Schedule_Amendment__c();
                if(String.isNotBlank(wrap.recordId) && isEdit){
                    schedAmend.Id = wrap.recordId;
                }
                if(wrap.paymentMode != 'Online' && !fromCashier){
                    opp=new Opportunity();//with swapnil
                    opp.Id = wrap.oppId;
                    system.debug('before Cashier Paymetn Pending flag update>>>>>');
                    opp.Cashier_Payment_Pending__c = true;
                }
                schedAmend.Name = wrap.paymentTermType;
                schedAmend.Installment__c =wrap.itemDescription;
                schedAmend.Amount__c = wrap.amount;
                schedAmend.Due_Date__c = wrap.dueDate;
                schedAmend.VAT_Amount__c = wrap.vatAmount;
                schedAmend.Proposed_Amount__c = wrap.proposedAmount;
                schedAmend.Proposed_Date__c = wrap.proposedDate;
                schedAmend.Opportunity__c = wrap.oppId;
                schedAmend.Payment_Milestone__c = wrap.paymentMilestoneId;
                schedAmend.Additional_Charges__c = wrap.additionalChargesId;
                schedAmend.Payment_Mode__c = wrap.paymentMode;
                schedAmend.unit__c = wrap.unitId;
                //schedAmend.Is_Split__c = wrap.isSplit;
                //schedAmend.Adjusted_To__c = wrap.adjustedTo;
                schedAmend.bank__c =wrap.bankName;
                schedAmend.bank_branch__c = wrap.bankBranch;
                schedAmend.bank_city__c = wrap.bankCity;
                schedAmend.cheque_no__c = wrap.chequeNo;
                if(wrap.ischarges){
                    schedAmend.Is_Charges__c = true;
                }
                if(schedAmend.payment_mode__c == 'Online'){
                    schedAmend.remarks__c =  wrap.execRemarks;
                }else{
                    schedAmend.remarks__c = wrap.remarks;
                }
                schedAmend.Leasing_Remarks__c = wrap.execRemarks;
                schedAmend.transaction_id__c = wrap.transactionId;
                schedAmendsList.add(schedAmend);
            }
        }
        upsert schedAmendsList;
        if(opp != null){
            update opp;
        }
        
        system.debug('Before createReceipts>>>>>');
        if(fromCashier){
            getScheduleAmendments(parentWrapper.oppId);
            return createReceipts(parentWrapper,false);
            
        }else{
            parentWrapper = getInstallments(parentWrapper.oppId);
            return createReceipts(parentWrapper,true);
        }
        
    }
    
    /*
@Author : Asams
@CreatedDate: 20/02/2022
@ This method will create receipts
*/       
    @AuraEnabled
    public static boolean createReceipts(ParentWrapper parentWrapper,Boolean excludeOther){
        system.debug('Inside createReceipts>>>>>');
        List<ResultWrapper> amendsmentList = parentWrapper.resultWrapperList;
        system.debug('amendsmentList>>>>'+amendsmentList);
        List<receipt__c> receiptsList = new List<receipt__c>();
        List<Receipt_Milestone__c> receiptMilestoneList = new List<Receipt_Milestone__c>();
        MAP<Id,receipt__c> scheduleReceiptIdsMap = new MAP<Id,receipt__c>();
        Map<String,String> receiptInsMapping = new Map<String,String>();
        Map<String,String> receiptMethodMap = new Map<String,String>();
        Set<Id> receiptIds = new Set<Id>();
        List<receipt__c> newReceiptsList = new List<receipt__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> scheduleAmendsIds = new Set<Id>();
        List<Schedule_Amendment__c> scheduleAmendsList = new List<Schedule_Amendment__c>();
        List<Payment_Milestone__c> pmList = new List<Payment_Milestone__c>();
        List<Opportunity_Charges__c> addList = new List<Opportunity_Charges__c>();
        Map<String,Receipt__c> cheqReceiptMap = new Map<String,Receipt__c>();
        Map<String,Decimal> totalAmountMap = new Map<String,Decimal>();
        Map<String,Decimal> holdingDepositMap = new Map<String,Decimal>();
        Map<String,String> onlineReceiptMap = new Map<String,String>();
        Boolean isSuccess;
        Boolean isBookingAmount = FALSE;
        Map<String, String> pickLabelApiMap = getPicklistValues('Payment_Milestone__c','Installment__c');
        Map<String,Unit_Plan__c> oppUnitMap = new Map<String,Unit_Plan__c>();
        // added for new receipt change - 
        for(Unit_Plan__c oppUnit : [SELECT id,name,unit__c,unit__r.security_deposit__c,unit__r.Holding_Deposit_Amount__c 
                                    FROM unit_plan__c 
                                    WHERE opportunity__c =: ParentWrapper.oppId]){
                                        oppUnitMap.put(oppUnit.unit__c, oppUnit);
                                        holdingDepositMap.put(oppUnit.Unit__c,oppUnit.unit__r.Holding_Deposit_Amount__c);
                                    }
        system.debug('->'+holdingDepositMap);
        system.debug('oppUnitMap>>>>>>->'+oppUnitMap);
        if(oppUnitMap.values().size() > 1){
            pmList = [SELECT id,installment__c,Is_Reciept_Created__c,payment_mode__c,total_amount__c,unit__c  
                      FROM payment_milestone__c
                      WHERE opportunity__c =: ParentWrapper.oppId];
            addList = [SELECT id,name,Is_Reciept_Created__c,total_amount__c,unit__c,Payment_Term_Type_Code__c 
                       FROM opportunity_charges__c
                       WHERE opportunity__c =: ParentWrapper.oppId];
            for(Payment_Milestone__c ins :  pmList){
                totalAmountMap.put(ins.unit__c+ins.Installment__c, ins.total_amount__c);
            }  
            for(Opportunity_Charges__c charges :  addList){
                totalAmountMap.put(charges.unit__c+charges.Payment_Term_Type_Code__c, charges.total_amount__c);
            }
            system.debug('totalAmountMap-->'+totalAmountMap);
        }
        system.debug('parentWrapper.buId-->'+parentWrapper.buId);
        List<Receipt_Method__c> receiptMethodList = [SELECT id,name,Payment_Mode__c,Business_Unit__c, Bank_Account_Number__c 
                                                     FROM Receipt_Method__c 
                                                     WHERE Business_Unit__c = : parentWrapper.buId and Bank_Account_Number__c =: parentWrapper.bankBranchId];
        for(Receipt_Method__c receiptMethod : receiptMethodList){
            receiptMethodMap.put(receiptMethod.Payment_Mode__c , receiptMethod.Id);
        }
        try{
            if(amendsmentList.size()>0){
                for(ResultWrapper schedAmend : amendsmentList){
                    system.debug('inside');
                    oppIds.add(schedAmend.oppId);
                    scheduleAmendsIds.add(schedAmend.recordId);
                    if(schedAmend.proposedAmount > 0){
                        if(((excludeOther && schedAmend.paymentMode == 'Online') || (!excludeOther && schedAmend.paymentMode != 'Online')) && schedAmend.isReceiptCreated == false){
                            system.debug('inside');
                            system.debug('inside>>>>'+oppUnitMap);
                            system.debug('unit>>>>'+schedAmend.unitId);         
                            if((oppUnitMap.containsKey(schedAmend.unitId) || schedAmend.itemDescription=='Holding Deposit') && oppUnitMap.values().size() == 1){
                                system.debug('Inside 1st If>>>>>');
                                Receipt__c receipt = new Receipt__c();
                                if(pickLabelApiMap.containsKey(schedAmend.itemDescription)){
                                    receipt.Name = pickLabelApiMap.get(schedAmend.itemDescription);
                                }else{
                                    receipt.Name = schedAmend.paymentTermType;
                                }
                                receipt.Payment_Mode__c = schedAmend.paymentMode;
                                receipt.Amount__c = schedAmend.proposedAmount;
                                receipt.Opportunity__c = schedAmend.oppId;
                                receipt.Schedule_Amendment__c = schedAmend.recordId;
                                receipt.Due_Date__c = schedAmend.dueDate;
                                if(parentWrapper.source != null){
                                    receipt.source__c = parentWrapper.source;
                                }else{
                                   receipt.source__c = 'Salesforce'; 
                                }
                                
                                if(schedAmend.itemDescription == 'Holding Deposit'){
                                    receipt.Unit__c =  (new list<string>(oppUnitMap.keySet())[0]);
                                }else{
                                    receipt.Unit__c = schedAmend.unitId;
                                }
                                receipt.Received_For__c = schedAmend.itemDescription;
                                if(schedAmend.paymentMode == 'Cash'){
                                    receipt.Payment_Status__c = 'Paid';
                                }else{
                                    receipt.Payment_Status__c = 'Pending';
                                }
                                receipt.Bank_Branch__c = schedAmend.bankBranch;
                                receipt.Business_Unit__c = parentWrapper.buId;
                                receipt.Bank__c = schedAmend.bankName;
                                receipt.Bank_City__c = schedAmend.bankCity;
                                receipt.cheque_no__c = schedAmend.chequeNo;
                                receipt.Receipt_Comments__c = schedAmend.remarks;
                                receipt.transaction_id__c = schedAmend.transactionId;
                                if(receiptMethodMap.containsKey(schedAmend.paymentMode)){
                                    receipt.Receipt_Method__c = receiptMethodMap.get(schedAmend.paymentMode);
                                }
                                //receipt.Installment_Type__c = schedAmend.itemDescription;
                                //receipt.Account__c = schedAmend.Opportunity__r.AccountId;
                                
                                //code added for cheques 
                                if(schedAmend.paymentMode == 'Online'){
                                    if(cheqReceiptMap.containsKey(schedAmend.unitId)){
                                        receipt__c rObj = cheqReceiptMap.get(schedAmend.unitId);
                                        rObj.Amount__c = rObj.Amount__c + receipt.Amount__c;
                                        rObj.Received_For__c = 'Total Rent';
                                        rObj.ReceivedForMapping__c = rObj.ReceivedForMapping__c +';'+schedAmend.itemDescription;
                                        cheqReceiptMap.put(schedAmend.unitId,rObj);
                                    }else{
                                        receipt.Due_Date__c = system.today();
                                        receipt.ReceivedForMapping__c  = schedAmend.itemDescription;
                                        cheqReceiptMap.put(schedAmend.unitId,receipt);
                                    }
                                }else{
                                    receipt.ReceivedForMapping__c  = schedAmend.itemDescription;
                                    system.debug('receipt before receiptsList>>>>>'+receipt);
                                    receiptsList.add(receipt);
                                }
                            }
                            else if(oppUnitMap.values().size()>1){
                                system.debug('inside');
                                for(Unit_Plan__c oppUnit : oppUnitMap.values()){
                                  if(totalAmountMap.containsKey(oppUnit.unit__c+schedAmend.itemDescription)){   
                                    Receipt__c receipt = new Receipt__c();
                                    receipt.Unit__c = oppUnit.unit__c;
                                    if(pickLabelApiMap.containsKey(schedAmend.itemDescription)){
                                        receipt.Name = pickLabelApiMap.get(schedAmend.itemDescription);
                                    }else{
                                        receipt.Name = schedAmend.paymentTermType;
                                    }
                                    receipt.Payment_Mode__c = schedAmend.paymentMode;
                                    if(schedAmend.itemDescription == 'Holding Deposit'){
                                        receipt.Unit__c = oppUnit.unit__c;
                                        receipt.Amount__c = holdingDepositMap.get(oppUnit.unit__c);
                                    }else{
                                        system.debug('-->'+oppUnit.unit__c+'-'+schedAmend.itemDescription);
                                        receipt.Amount__c = totalAmountMap.get(oppUnit.unit__c+schedAmend.itemDescription);
                                        
                                    }
                                    receipt.Opportunity__c = schedAmend.oppId;
                                    receipt.Schedule_Amendment__c = schedAmend.recordId;
                                    receipt.Due_Date__c = schedAmend.dueDate;
                                    receipt.Business_Unit__c = parentWrapper.buId;
                                       system.debug('receipt.Business_Unit__c-->'+receipt.Business_Unit__c);
                                    receipt.Received_For__c = schedAmend.itemDescription;
                                    if(schedAmend.paymentMode == 'Cash'){
                                        receipt.Payment_Status__c = 'Paid';
                                    }else{
                                        receipt.Payment_Status__c = 'Pending';
                                    }
                                    receipt.Bank_Branch__c = schedAmend.bankBranch;
                                    
                                    receipt.Bank__c = schedAmend.bankName;
                                    receipt.Bank_City__c = schedAmend.bankCity;
                                    receipt.cheque_no__c = schedAmend.chequeNo;
                                    receipt.Receipt_Comments__c = schedAmend.remarks;
                                    receipt.transaction_id__c = schedAmend.transactionId;
                                    if(receiptMethodMap.containsKey(schedAmend.paymentMode)){
                                        receipt.Receipt_Method__c = receiptMethodMap.get(schedAmend.paymentMode);
                                    }
                                    
                                    receipt.ReceivedForMapping__c  = schedAmend.itemDescription;
                                    //code added for cheques 
                                    if(schedAmend.paymentMode == 'Online'){
                                        receipt.Due_Date__c = schedAmend.dueDate;
                                        if(cheqReceiptMap.containsKey(oppUnit.unit__c)){
                                            system.debug('-->'+ receipt.Amount__c);
                                            receipt__c rObj = cheqReceiptMap.get(oppUnit.unit__c);
                                            system.debug('rObj-->'+ rObj.Amount__c);
                                            rObj.Amount__c = rObj.Amount__c + receipt.Amount__c;
                                            rObj.ReceivedForMapping__c = rObj.ReceivedForMapping__c +';'+schedAmend.itemDescription;
                                            cheqReceiptMap.put(oppUnit.unit__c,rObj);
                                            
                                        }else{
                                            receipt.Due_Date__c = system.today();
                                            receipt.ReceivedForMapping__c  = schedAmend.itemDescription;
                                            cheqReceiptMap.put(oppUnit.unit__c,receipt);
                                        }
                                    }else{
                                        receipt.Due_Date__c = schedAmend.dueDate;
                                        receipt.ReceivedForMapping__c  = schedAmend.itemDescription;
                                        receiptsList.add(receipt);
                                    }
                                }  
                                }// for loop for opp unit end
                            }
                        }
                    }
                }
                if(cheqReceiptMap.values().size() > 0){
                    receiptsList.addAll(cheqReceiptMap.values());
                }
                system.debug('receiptsList>>>>>>>>>>>>'+receiptsList.size());
                if(!receiptsList.isEmpty()){
                    Database.SaveResult[] saveResults = Database.insert(receiptsList, false);
                    system.debug('saveResults>>>>>>>>>>>>>>'+saveResults);
                    for (Database.SaveResult sr : saveResults) {
                        if(sr.isSuccess()){
                            receiptIds.add(sr.getId());
                        }
                        else{
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('Receipt Creation Error'+err.getStatusCode() + ': ' + err.getMessage());
                            }
                        }
                    }
                    Map<String,Receipt__c> receiptReceivedMap = new Map<String,Receipt__c>();
                    newReceiptsList = [Select Id,name,Schedule_Amendment__c,Payment_Milestone__c,Schedule_Amendment__r.Payment_Milestone__c,ReceivedForMapping__c ,
                                       Schedule_Amendment__r.Additional_Charges__c,Schedule_Amendment__r.is_Split__c, Received_For__c ,cheque_no__c,Payment_Mode__c,unit__c
                                       from receipt__c 
                                       where Id IN:receiptIds];
                    system.debug('newReceiptsList>>>>>>>>>>>>>>'+newReceiptsList);
                    for(receipt__c rec : newReceiptsList){
                        scheduleReceiptIdsMap.put(rec.Schedule_Amendment__c,rec);
                        if(rec.Schedule_Amendment__r.Additional_Charges__c != null && rec.Schedule_Amendment__r.is_Split__c == false){
                            receiptInsMapping.put(rec.Schedule_Amendment__r.Additional_Charges__c,rec.Id);
                        }else if(rec.Schedule_Amendment__r.Payment_Milestone__c != null && rec.Schedule_Amendment__r.is_Split__c == false){
                            receiptInsMapping.put(rec.Schedule_Amendment__r.Payment_Milestone__c,rec.Id);
                        }
                        if(!rec.ReceivedForMapping__c.contains(';')){
                            receiptReceivedMap.put(rec.ReceivedForMapping__c+rec.Unit__c,rec);
                        }else{
                            List<String> receivedForList = rec.ReceivedForMapping__c.split(';');
                            for(String s : receivedForList){
                                receiptReceivedMap.put(s+rec.Unit__c, rec);
                            }
                        }    
                        if(rec.Payment_Mode__c == 'Online'){
                            onlineReceiptMap.put(rec.Unit__c,rec.id);
                        }
                        cheqReceiptMap.put(rec.cheque_no__c,rec);
                    }
                    Opportunity oppObj = [Select Id,Receipt_Generated__c,Booking_Fee_gets_collected__c,(Select id,name from unit_plans__r) from Opportunity where Id =: parentWrapper.oppId];
                    
                    //Bulk Code
                    if(oppObj.unit_plans__r.size() > 1){
                        system.debug('Inside oppObj.unit_plans__r.size() >1');
                        for(ResultWrapper schedAmend : amendsmentList){
                            if(string.isNotEmpty(schedAmend.recordId) &&  Id.valueOf(schedAmend.recordId).getSObjectType().getDescribe().getName() == 'Schedule_Amendment__c'){
                                Schedule_Amendment__c scObj = new Schedule_Amendment__c();
                                scObj.Id = schedAmend.recordId;
                                if((excludeOther && schedAmend.paymentMode == 'Online') || (!excludeOther && schedAmend.paymentMode != 'Online')){
                                    scObj.Is_Reciept_Created__c = true;
                                    scheduleAmendsList.add(scObj); 
                                }
                            }
                        }
                        for(Payment_Milestone__c payMilObj : pmList){
                            if(receiptReceivedMap.containsKey(payMilObj.Installment__c+payMilObj.Unit__c) && !payMilObj.Is_Reciept_Created__c){
                                Receipt_Milestone__c receiptMilestone = new Receipt_Milestone__c();
                                receiptMilestone.Receipt__c = receiptReceivedMap.get(payMilObj.Installment__c+payMilObj.Unit__c).Id;
                                receiptMilestone.Installments__c = payMilObj.Id;
                                receiptMilestoneList.add(receiptMilestone);
                                payMilObj.Is_Reciept_Created__c = true;
                            }
                        }
                        for(Opportunity_Charges__c addCharges : addList){
                            if(receiptReceivedMap.containsKey(addCharges.Payment_Term_Type_Code__c+addCharges.Unit__c) && !addCharges.Is_Reciept_Created__c){
                                Receipt_Milestone__c receiptMilestone = new Receipt_Milestone__c();
                                receiptMilestone.Receipt__c = receiptReceivedMap.get(addCharges.Payment_Term_Type_Code__c+addCharges.Unit__c).Id;
                                receiptMilestone.Additional_Charges__c = addCharges.Id;
                                receiptMilestoneList.add(receiptMilestone);
                                addCharges.Is_Reciept_Created__c = true;
                            }
                        }
                        
                    }else{
                        system.debug('scheduleReceiptIdsMap'+scheduleReceiptIdsMap);
                        list<Schedule_Amendment__c> scheduleAmdList = new List<Schedule_Amendment__c>();
                        for(ResultWrapper schedAmend : amendsmentList){
                            if(!schedAmend.isReceiptCreated){
                                if(schedAmend.proposedAmount > 0){
                                    Receipt_Milestone__c receiptMilestone = new Receipt_Milestone__c();
                                    if(schedAmend.paymentMode == 'Online' && onlineReceiptMap.containsKey(schedAmend.unitId)){
                                        receiptMilestone.Receipt__c = onlineReceiptMap.get(schedAmend.unitId);
                                    }else if(scheduleReceiptIdsMap.containsKey(schedAmend.recordId)){
                                        receiptMilestone.Receipt__c = scheduleReceiptIdsMap.get(schedAmend.recordId).Id;
                                    }
                                    if(string.isNotEmpty(schedAmend.paymentMilestoneId)){
                                        receiptMilestone.Installments__c = schedAmend.paymentMilestoneId;
                                    }else if(string.isNotEmpty(schedAmend.additionalChargesId)){
                                        receiptMilestone.Additional_Charges__c = schedAmend.additionalChargesId;
                                    }
                                    if(receiptMilestone.Receipt__c != null){
                                        receiptMilestoneList.add(receiptMilestone);
                                    }
                                }
                                /* if(schedAmend.proposedAmount > 0 && scheduleReceiptIdsMap.containskey(schedAmend.recordId) &&  schedAmend.paymentMode!='Cheque' ){
Receipt_Milestone__c receiptMilestone = new Receipt_Milestone__c();
receiptMilestone.Receipt__c = scheduleReceiptIdsMap.get(schedAmend.recordId).Id;
if(string.isNotEmpty(schedAmend.paymentMilestoneId)){
receiptMilestone.Installments__c = schedAmend.paymentMilestoneId;
}else if(string.isNotEmpty(schedAmend.additionalChargesId)){
receiptMilestone.Additional_Charges__c = schedAmend.additionalChargesId;
}
receiptMilestoneList.add(receiptMilestone);
}else if(schedAmend.paymentMode == 'Cheque'){
Receipt_Milestone__c receiptMilestone = new Receipt_Milestone__c();
receiptMilestone.Receipt__c = cheqReceiptMap.get(schedAmend.chequeNo).Id;
if(string.isNotEmpty(schedAmend.paymentMilestoneId)){
receiptMilestone.Installments__c = schedAmend.paymentMilestoneId;
}else if(string.isNotEmpty(schedAmend.additionalChargesId)){
receiptMilestone.Additional_Charges__c = schedAmend.additionalChargesId;
}
receiptMilestoneList.add(receiptMilestone);
}*/// if mode is cheque then create seperate milestone based on cheque no bcz we dont have one to one mapping of sched Amendment and receipt
                                if(string.isNotEmpty(schedAmend.recordId) &&  Id.valueOf(schedAmend.recordId).getSObjectType().getDescribe().getName() == 'Schedule_Amendment__c'){
                                    Schedule_Amendment__c scObj = new Schedule_Amendment__c();
                                    scObj.Id = schedAmend.recordId;
                                    if((excludeOther && schedAmend.paymentMode == 'Online') || (!excludeOther && schedAmend.paymentMode != 'Online')){
                                        scObj.Is_Reciept_Created__c = true;
                                        scheduleAmendsList.add(scObj); 
                                    }
                                }
                                if(string.isNotEmpty(schedAmend.additionalChargesId)){  
                                    if((excludeOther && schedAmend.paymentMode == 'Online') || (!excludeOther && schedAmend.paymentMode != 'Online')){
                                        Opportunity_Charges__c oppCharges = new Opportunity_Charges__c();
                                        oppCharges.Id = schedAmend.additionalChargesId;  
                                        oppCharges.Is_Reciept_Created__c = true;
                                        addList.add(oppCharges);
                                    }
                                }
                                if(string.isNotEmpty(schedAmend.paymentMilestoneId)){
                                    if((excludeOther && schedAmend.paymentMode == 'Online') || (!excludeOther && schedAmend.paymentMode != 'Online')){
                                        Payment_Milestone__c payMilObj = new Payment_Milestone__c();
                                        payMilObj.Id = schedAmend.paymentMilestoneId;  
                                        payMilObj.Is_Reciept_Created__c = true;
                                        pmList.add(payMilObj);
                                    }
                                }
                            }
                        }
                    }
                    if(!scheduleAmendsList.isEmpty()){
                        update scheduleAmendsList;
                    }
                    system.debug('receiptMilestoneList->'+receiptMilestoneList);
                    if(!receiptMilestoneList.isEmpty()){
                        insert receiptMilestoneList;
                        //updating opp receipt check
                        //updating schedule amends receipt check
                        
                        //updating installments amends receipt check
                        if(!pmList.isEmpty()){
                            update pmList;
                        }
                        //updating installments amends receipt check
                        if(!addList.isEmpty()){
                            update addList;
                        }
                    }
                    isSuccess = true;
                }
                isSuccess = true;
            }
            
        }catch(Exception ex){
            isSuccess = false;
            system.debug('Receipt generation Error'+ex.getMessage());
        }
        return isSuccess;
    }
    /*
@Author : Asams
@CreatedDate: 20/02/2022
@ This method is to fetch receipt methods
*/     
    @AuraEnabled
    public static List<Receipt_Method__c> getReceiptMethods(string businessUnit){
        List<Receipt_Method__c> receiptsMethodList = new List<Receipt_Method__c>();
        receiptsMethodList = [select Id,Name,Bank_Account_Number__c,Business_Unit__c
                              from Receipt_Method__c
                              WHERE Business_Unit__c =: businessUnit];
        system.debug('receiptsMethodList'+receiptsMethodList);
        return receiptsMethodList;
    }
    
    /*
@Author : Asams
@CreatedDate: 20/02/2022
@ This method is to fetch picklist values
*/     
    @AuraEnabled 
    public static Map<String, String> getPicklistValues(string obj, string fld){
        Map<String, String> options = new Map<String, String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(obj) ;
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        for (Schema.PicklistEntry p: values) {
            options.put(p.getValue(), p.getLabel());
        }
        system.debug('values'+values);
        return options;
    }
    public class AdjustmentWrapper{
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public String value{get;set;}
    }
    public class ParentWrapper{
        @AuraEnabled
        public String oppId{get;set;}
        @AuraEnabled
        public String bankBranchId{get;set;}
        @AuraEnabled
        public String buId{get;set;}
        @AuraEnabled
        public Decimal totalAmount{get;set;}
        @AuraEnabled
        public Boolean isEdit{get;set;}
        @AuraEnabled
        public List<ResultWrapper> resultWrapperList{get;set;}
        @AuraEnabled
        public Decimal proposedThresholdDays{get;set;}
        @AuraEnabled
        public Boolean isBooking{get;set;}
        @AuraEnabled
        public ResultWrapper bookingWrapper{get;set;}
        @AuraEnabled
        public List<AdjustmentWrapper> adjustmentList{get;set;}
        @AuraEnabled
        public Map<String,String> bankMap{get;set;}
        @AuraEnabled
        public Map<String,String> paymentOptions{get;set;}
        @AuraEnabled
        public Boolean isBulk{get;set;}
        @AuraEnabled
        public String source{get;set;}
    }
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class ResultWrapper{
        @AuraEnabled
        public Boolean isTransactionId{get;set;}
        @AuraEnabled
        public Boolean isCharges{get;set;}
        @AuraEnabled
        public String adjustedTo{get;set;}
        @AuraEnabled
        public String chequeNo{get;set;}
        @AuraEnabled
        public String isSecurityDeposit{get;set;}
        @AuraEnabled
        public String itemDesValue{get;set;}
        @AuraEnabled
        public String paymentTermType{get;set;}
        @AuraEnabled
        public Boolean isReceiptCreated{get;set;}
        @AuraEnabled
        public String itemDescription{get;set;}
        @AuraEnabled
        public String paymentMode{get;set;}
        @AuraEnabled
        public Date dueDate{get;set;}
        @AuraEnabled
        public Decimal amount{get;set;}
        @AuraEnabled
        public Decimal vatAmount{get;set;}
        @AuraEnabled
        public Decimal totalAmount{get;set;}
        @AuraEnabled
        public Decimal proposedAmount{get;set;}
        @AuraEnabled
        public Date proposedDate{get;set;}
        @AuraEnabled
        public Boolean allocate{get;set;}
        @AuraEnabled
        public String allocateComments{get;set;}
        @AuraEnabled
        public Boolean isSplit{get;set;}
        @AuraEnabled
        public String oppId{get;set;}
        @AuraEnabled
        public String paymentMilestoneId{get;set;}
        @AuraEnabled
        public String additionalChargesId{get;set;}
        @AuraEnabled
        public String recordId{get;set;}
        @AuraEnabled
        public String isRemove{get;set;}
        @AuraEnabled
        public String bankName{get;set;}
        @AuraEnabled
        public String bankCity{get;set;}
        @AuraEnabled
        public String bankBranch{get;set;}
        @AuraEnabled
        public String bankCountry{get;set;}
        @AuraEnabled
        public Boolean isBank{get;set;}
        @AuraEnabled
        public String businessUnit{get;set;}
        @AuraEnabled
        public String unitCode{get;set;}
        @AuraEnabled
        public String unitId{get;set;}
        @AuraEnabled
        public String allocatedInstallmentId{get;set;}
        @AuraEnabled
        public Date proposedThresholdDate{get;set;}
        @AuraEnabled
        public Boolean isDisableProposedDate{get;set;}
        @AuraEnabled
        public String remarks{get;set;}
        @AuraEnabled
        public String collectedAmount{get;set;}
        @AuraEnabled
        public String previousChequeNo{get;set;}
        @AuraEnabled
        public String transactionId{get;set;}
        @AuraEnabled
        public String execRemarks{get;set;}
        
        
    }
    
}