public without sharing class PaymentController {
  /*  @AuraEnabled
    //Comment by Swapnil - neeed to use Business_Unit__c instead of master_community__c and use unit_Status__c instead of sales_status__c and leasing_status__c
    public static List<Unit__c> findUnitByName(List<Unit__c> unitId) {
        List<Unit__c> unlist = [select id,Unit_Number__c,Cluster__r.Name,Space_Types__r.Name,Project__r.Name,Name,Building__r.Name,Leasing_Selling_Price__c,Assignable_Area__c from Unit__c where id IN:unitId];
        if(unlist <> null && unitId.size() > 0){
            return unlist;
        }
        return null;
    }
    
    
    @AuraEnabled 
    //Comment by Shruti - To show availabe payment plan for selected unit
    public static Map<String, String> showPaymentList(List<Unit__c> unitId){
        String spacId = '';
        String projId = '';
        List<Unit__c> unlist = [select id,Assignable_Area__c,Project__c,Project__r.Name,Name,Building__r.Name,Space_Types__c,Leasing_Selling_Price__c from Unit__c where id IN:unitId];
        if(unlist[0] <> null){
            spacId = unlist[0].Space_Types__c;
            projId = unlist[0].Project__c;
        }
        system.debug('spacId'+spacId);
        Map<String, String> options = new Map<String, String>();
        //List<Location> locList = [select Id,Name from Location];
        for(Schema.Availabe_Payment_Plan__c cls : [select Id,Name from Availabe_Payment_Plan__c where Space_Type__c =:spacId AND Project__c =:projId ORDER By No_of_cheques__c asc])
        {
            
            options.put(cls.Id,cls.Name);
            system.debug(options.size());
        }       
        return options;
    }
    @AuraEnabled
    //Comment by Shruti - To show amount for selected unit
    public static Availabe_Payment_Plan__c  showAmount(String selectedcheque,List<Unit__c> unitId) {
        system.debug('selectedcheque'+selectedcheque);
        system.debug('unitId'+unitId);
        List<Unit__c> unlist = [select id,Assignable_Area__c,Space_Types__c,project__c,Unit_type__c,Total_Saleable_Area_Sqft__c from Unit__c where id IN:unitId];
        system.debug('unlist'+unlist);//and project__c =: unlist[0].project__cAND 
        List<Availabe_Payment_Plan__c> payList =  [select id,No_of_cheques__c,Base_Lease_Amount__c,Discount__c,Final_Lease_Amount__c,Name from Availabe_Payment_Plan__c where Id =:selectedcheque AND Space_Type__c =:unlist[0].Space_Types__c AND project__c =: unlist[0].project__c ];
        system.debug('payList'+payList);
        if(unlist[0].Unit_type__c <> 'Shop'){
            system.debug('payList'+payList);
            return payList[0];
            
        }else{
            Integer amount = Integer.valueOf(payList[0].Base_Lease_Amount__c * unlist[0].Assignable_Area__c);
            Availabe_Payment_Plan__c avaiObj = new Availabe_Payment_Plan__c();
            avaiObj.No_of_cheques__c = payList[0].No_of_cheques__c;
            avaiObj.Base_Lease_Amount__c  = payList[0].Base_Lease_Amount__c;
            avaiObj.Final_Lease_Amount__c = amount;
            avaiObj.Discount__c = payList[0].Discount__c;
            avaiObj.Id = payList[0].Id;
            return avaiObj;
        }
        
        
    }
     
    @AuraEnabled
    public static void addUnitstoOpp(String OppId,List<unit__c> unitsList,String selectedcheques,double discount,double finalLeaseAmount,String paymentmode,decimal employeeDiscount,String PersqReason,String persqftprice,String changedpersfPrice){
        system.debug('OppId'+OppId);
        List<Payment_Milestone__c> currentpaymentMilestones = [Select Id FROM Payment_Milestone__c where Opportunity__c = : OppId and Name != 'Booking Amount'];
        if(currentpaymentMilestones.size() > 0){
            delete currentpaymentMilestones;
        }
        
        system.debug('%%selectedUnits'+selectedcheques);
        Integer finalAmounts;
        Decimal addAmounts = 0.0;
        Integer cheques;
        //Id recordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Leasing Opportunity').getRecordTypeId();
       List<String> unitIdlist = new List<String>();
        for(unit__c u : unitsList){
            unitIdlist.add(u.Id);
        }
        integer i=1;
        List<unit__c> unitsLists = [select id,Assignable_Area__c,Project__r.Name,Unit_type__c,Total_Saleable_Area_Sqft__c,Space_Types__c,Unit_Number__c,Building__c,Cluster__c,Project__c,Leasing_Selling_Price__c,name,Master_Payment_Plan__c,Master_Payment_Plan__r.No_of_cheques_Leasing__c,Unit_Code__c from Unit__c where id IN : unitIdlist];
        List<Availabe_Payment_Plan__c> avaipayList = [select id,No_of_cheques__c,Security_Deposit__c,Base_Lease_Amount__c,Discount__c,Final_Lease_Amount__c,Name from Availabe_Payment_Plan__c where Id =:selectedcheques AND Space_Type__c =:unitsLists[0].Space_Types__c and project__c =: unitsLists[0].project__c];
        avaipayList[0].Final_Lease_Amount__c = finalLeaseAmount;
        system.debug('avaipayList[0].No_of_cheques__c'+avaipayList[0].No_of_cheques__c);
        if(paymentmode == 'Cheque'){
            
            cheques = Integer.valueOf(avaipayList[0].No_of_cheques__c);
        } else {
            cheques = 1;
        }
        
        system.debug('cheques'+cheques);
        Opportunity opp = [Select Id,Account.Name,Lease_Start_Date__c,Lease_End_Date__c,Booking_Amount__c,Booking_Mode__c,Booking_Fee_gets_collected__c,Unit_Status__c,name,Final_Unit_Price__c from Opportunity where id=:OppId]; 
        List<Unit_Plan__c> unitPlanList = new List<Unit_Plan__c>();
        unitPlanList = [Select Id,opportunity__c,Number_of_Installment__c,Base_Lease_Amount__c,Final_Lease_Amount__c,Discount__c,Security_Deposit__c FROM Unit_Plan__c where Opportunity__c =: OppId];
        List<Payment_Milestone__c> payMileList = new List<Payment_Milestone__c>();
        Map<Id,Integer> unitIdVsAmount = new  Map<Id,Integer>();
         List<Unit_Plan__c> updateunitPlan = new List<Unit_Plan__c>();
        if(unitsLists.size()>0){
            for(Unit_Plan__c unit : unitPlanList){
                  Unit_Plan__c u = new Unit_Plan__c();  
                     u.Id = unit.Id;
                    u.Number_of_Installment__c = cheques;
                    u.Base_Lease_Amount__c = avaipayList[0].Base_Lease_Amount__c;
                    u.Final_Lease_Amount__c = avaipayList[0].Final_Lease_Amount__c;
                    u.Discount__c = avaipayList[0].Discount__c;
                    u.Security_Deposit__c = avaipayList[0].Security_Deposit__c;
                updateunitPlan.add(u);
                //i++;
            }
            if(updateunitPlan.size() > 0){
                update updateunitPlan;
            }
            
            system.debug('unitPlanList'+unitPlanList);
            Integer amount;
            
            if(unitsLists[0].Unit_type__c == 'Shop'){
                finalAmounts = Integer.valueOf(finalLeaseAmount*(unitsList.size())); 
            }else{
                finalAmounts = Integer.valueOf((avaipayList[0].Base_Lease_Amount__c)*(unitsList.size())); 
            }
            Set<Id> projId = new Set<Id>();
            Set<Id> unitId = new Set<Id>();
            List<Opportunity_Charges__c> oppCharge = new List<Opportunity_Charges__c>();
            List<Unit_Plan__c> unitlist = [select id,Unit__c,Project__c,Unit__r.Unit_Code__c from Unit_Plan__c where Opportunity__c =: OppId];
            if(unitlist <> null && unitlist.size() > 0){
                for(Unit_Plan__c uniObj : unitlist){
                    projId.add(uniObj.Project__c);
                    unitId.add(uniObj.Unit__c);
                }
            }
            double addnCharges = 0.0;
            List<Additional_Charges__c> chargesList = [Select id,Project__c,Payable_Amount__c,Name,VAT_Amount__c,VAT_Code__c,VAT__c,Swimming_Pool_Charges__c,Utility_Charges__c,Amount__c from Additional_Charges__c where Project__c  IN : projId 
                                                        AND Type__c = 'Leasing' and (Name = 'Ejari' OR Name = 'Leasing Commission')];
           system.debug('chargesList'+unitsList);
            for(Integer l =0; l < unitsList.size();l++){
              system.debug('chargesList'+unitsList[l].Unit_Code__c);
            for(Additional_Charges__c add : chargesList){
                Payment_Milestone__c oppCharges = new Payment_Milestone__c();
                oppCharges.Name = add.Name + '-'+ unitsList[l].Unit_Number__c;
                oppCharges.VAT_Amount__c = add.VAT_Amount__c;
                oppCharges.Unit__c = unitsList[l].Id;
                oppcharges.Amount__c = add.Amount__c;
                oppCharges.VAT_Code__c = add.VAT_Code__c;
                oppCharges.VAT__c = add.VAT__c;
                oppCharges.Frequency__c = 'yr';
                oppCharges.Due_Date__c = opp.Lease_Start_Date__c;
                oppCharges.Opportunity__c = OppId;
                oppCharges.Payable_Amount__c = add.Payable_Amount__c;
                oppCharges.Project__c = add.Project__c;
                payMileList.add(oppCharges);
                if(add.Amount__c != null){
                    addAmounts += add.Amount__c;
                }
                if(add.VAT_Amount__c != null){
                  
                }
            }
            }
            
            Integer unLine = unitsList.size();
            Integer cheque = Integer.valueOf(cheques)* (unitsList.size());
            Decimal amts;
            Decimal amts1;
            decimal empDisc;decimal discountedamount;
            Integer amtss;
            Decimal to;
            if(cheques == 1 && unitsLists[0].Unit_type__c != 'Shop'){
                if(employeeDiscount != null){
                    system.debug('employeeDiscount'+employeeDiscount);
                empDisc = (avaipayList[0].Base_Lease_Amount__c * employeeDiscount)/100;
                    system.debug('empDisc'+empDisc);
                  discountedamount =  avaipayList[0].Base_Lease_Amount__c -  empDisc;
                    system.debug('discountedamount'+discountedamount);
                    to = discountedamount * 0.05;
                     amts1 = discountedamount - to;
                    system.debug('amts1'+amts1);
                } else {
                to = avaipayList[0].Base_Lease_Amount__c * 0.05;
                
                amts1 =  (avaipayList[0].Base_Lease_Amount__c) - to;
                }
                amtss  = Integer.valueOf(amts1) *  (unitsList.size());  
                amts = amtss;
            }else{
            if(employeeDiscount != null){
              empDisc = (finalAmounts * employeeDiscount)/100;
              discountedamount = finalAmounts - empDisc;
              amts = discountedamount;
            } else {
                amts = finalAmounts;
                }
            }
            system.debug('amts'+amts);
            Decimal finalAmount = amts/cheque;
            Boolean flag = false;
            
            Integer num = 90;
            for(Integer l =0; l < unLine;l++){
                Payment_Milestone__c payMiles= new Payment_Milestone__c();
                payMiles.Opportunity__c = OppId;
                if(avaipayList[0].Security_Deposit__c <> null){
                    payMiles.Amount__c = avaipayList[0].Security_Deposit__c;
                }
                payMiles.Unit__c = unitsList[l].Id;
                payMiles.Vat_Amount__c = 0.0;
                payMiles.Vat_Code__c = '0.0';
                payMiles.Vat__c = 0.0;
                payMiles.Frequency__c = 'yr';
                payMiles.Installment_No__c = 0;
                payMiles.Name = 'Security Deposit';
                payMiles.Due_Date__c = opp.Lease_Start_Date__c;
                system.debug('payMiles'+payMiles);
                payMileList.add(payMiles);
            }
          system.debug('cheques****'+cheques);
            for(Unit__c u : unitsList){
                Integer k = 1;
                for(Integer j = 0; j < Integer.valueOf(cheques);j++){
                    
                    Payment_Milestone__c payMile = new Payment_Milestone__c();
                    
                    ///payMile.Master_Payment_Plan__c = payList[0].Master_Payment_Plan__c;
                    payMile.Opportunity__c = oppId;
                    payMile.Unit__c = u.Id;
                    payMile.Amount__c = finalAmount.setScale(2);
                    payMile.Installment_No__c = k;
                    payMile.Vat_Amount__c = 0.0;
                    payMile.Frequency__c = 'yr';
                    payMile.Vat_Code__c = '0.0';
                    payMile.Vat__c = 0.0;
                    payMile.Name = k+'-'+'Installment';
                    system.debug('payMile'+payMile);
                    if(flag == false){
                        payMile.Due_Date__c = opp.Lease_Start_Date__c;
                        
                        flag = true;
                    }else{
                        Date a = opp.Lease_Start_Date__c;
                        Date b = opp.Lease_End_Date__c;
                        Integer monthDiff = a.monthsBetween(b);
                        Integer mon = monthDiff/Integer.valueOf(cheques);
                        // payMile.Due_Date__c = a;
                        payMile.Due_Date__c =  opp.Lease_Start_Date__c.addmonths(mon*j);
                        
                    }
                    k++;
                    num += 90;
                    System.debug('payMile'+payMile);
                    payMileList.add(payMile);
                }
            }
            if(payMileList <> null && payMileList.size() > 0){
                insert payMileList;
            }
            
            system.debug('oppCharge'+oppCharge);
            if(oppCharge <> null && oppCharge.size() > 0){
                insert oppCharge;
                system.debug('After'+oppCharge);
            }
            Opportunity opty = new Opportunity();
            opty.Id = OppId;
            if(opp.Final_Unit_Price__c != null) {
                if(avaipayList[0].Security_Deposit__c != null){
                    opty.Final_Unit_Price__c = opp.Final_Unit_Price__c +  addAmounts + amts + (avaipayList[0].Security_Deposit__c * (unitsList.size()));
                } else {
                    opty.Final_Unit_Price__c = opp.Final_Unit_Price__c + addAmounts + amts; 
                }
                //opty.Final_Unit_Price__c = opp.Final_Unit_Price__c + addAmounts + amts + (avaipayList[0].Security_Deposit__c * (unitsList.size()));
            } else {
                if(avaipayList[0].Security_Deposit__c != null){
                    opty.Final_Unit_Price__c = addAmounts + amts + (avaipayList[0].Security_Deposit__c * (unitsList.size()));
                } else {
                    opty.Final_Unit_Price__c = addAmounts + amts; 
                }
                
            }
            //system.debug('opty.Final_Unit_Price__c'+opty.Final_Unit_Price__c);
            system.debug('double.valueOf(finalAmounts)'+double.valueOf(finalAmounts));
            opty.Employee_Discount__c = discount;
            opty.Payment_Mode__c = paymentmode;
            opty.Total_Additional_Charges__c = addAmounts;
            opty.One_Cheque_discount__c = avaipayList[0].Discount__c;
            opty.Base_Lease_Amount__c = (avaipayList[0].Base_Lease_Amount__c * (unitsList.size()));
            opty.Unit_Status__c = 'On Hold';
            opty.Installments_Generated__c = true;
            opty.PersqReason__c = PersqReason;
            opty.Assignable_Area__c = unitsLists[0].Assignable_Area__c;
            opty.Number_of_Installment__c = cheque;
            if(String.isNotBlank(changedpersfPrice)){
            opty.Change_Sqft_Pro__c = decimal.valueOf(changedpersfPrice) * (unitsList.size());
            }
            if(String.isNotBlank(persqftprice)){
                opty.Per_sqft_Price__c = decimal.valueOf(persqftprice) * (unitsList.size());}
            opty.Booking_Reservation_Date__c = system.today();
            if(unitsList.size() > 1){
                opty.name = 'Bulk'+'-'+opp.Account.Name+'-'+unitsLists[0].Project__r.Name;
            }else{
                opty.name = unitsLists[0].Unit_Number__c+'-'+opp.Account.Name+'-'+unitsLists[0].Project__r.Name;  
            }
            update opty;
            opty = [Select Id,Leasing_Type__c,StageName,Per_sqft_Price__c,Account.RecordType.DeveloperName FROM Opportunity where Id =: opty.Id];
            updateUnitStatus(unitsLists);
             if(opty.StageName != 'Under Approval'){
             if(opty.Leasing_Type__c == 'Residential Units' && unitPlanList.size() == 2 && opty.Account.RecordType.DeveloperName == 'PersonAccount'){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Please Approve!');
            req.setObjectId(opty.Id);
            req.setProcessDefinitionNameOrId('Units_Approval_Process');    
            req.setSkipEntryCriteria(true);
            // Submit the approval request for the Service Request
            Approval.ProcessResult result = Approval.process(req);
            }
           if(opty.Leasing_Type__c == 'Residential Shops' && opty.Per_sqft_Price__c != null){   
             Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Please Approve!');
            req.setObjectId(opty.Id);   
            req.setSkipEntryCriteria(true);
            // Submit the approval request for the Service Request
            Approval.ProcessResult result = Approval.process(req);
            req.setProcessDefinitionNameOrId('price_per_sq_ft_is_changed');
                }
           // successMessage = 'Record Updated Successfully';
        }
        }
        
    }
    
    public static void updateUnitStatus(List<Unit__c> unitlist){
        List<Unit__c> unitListUpdate  = new List<Unit__c>();
        
        for(Unit__c unit : unitlist){
            Unit__c unitObj = new Unit__c();
            unitObj.Unit_Status__c = 'On Hold';
            
            unitObj.Id = unit.Id;
            
            unitListUpdate.add(unitObj);
        }
        
        update unitListUpdate;
        
        
        
        
    }
    //Created by Jaskiran as part of functionality where 
    //we are adding attachment to opty along with Submitting the opty for Approval
    @AuraEnabled
    public static String updateAttachApprovalSubmit(String optyId,String fileName, String base64Data, String contentType,String rateChangeReason){
        Attachment attach = new Attachment();
        if(fileName != null && base64Data != null && contentType != null){
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        attach.parentId = optyId;
        attach.Body = EncodingUtil.base64Decode(base64Data);
        attach.Name = fileName;
        attach.ContentType = contentType;
        Insert attach;
        }

      return attach.Id;  
    }
    
    @AuraEnabled
    public static Availabe_Payment_Plan__c UpdatePaymentPlan(String selectedPaymentId,Double discount){
        List<Availabe_Payment_Plan__c> avaipayList = [select id,No_of_cheques__c,Base_Lease_Amount__c,Discount__c,Final_Lease_Amount__c,Name from Availabe_Payment_Plan__c where Id =:selectedPaymentId];
        avaipayList[0].Discount__c = discount;
        avaipayList[0].Final_Lease_Amount__c =  Double.valueOf(avaipayList[0].Base_Lease_Amount__c) - Double.valueOf(((avaipayList[0].Base_Lease_Amount__c)*discount)/100);
        update avaipayList[0];
        
        return avaipayList[0];
    }
    
   @AuraEnabled
    public static UnitPaymentClass paymentPlanDetails(String recordId){
        system.debug('recordId'+recordId);
        UnitPaymentClass upClass = new UnitPaymentClass();
        Opportunity opp = new Opportunity();
        opp = [Select Id,Project__c,Project__r.Name,Leasing_Type__c,Account.Emirates_Ids__c FROM Opportunity where Id =: recordId];
          system.debug('opp'+opp);
        List<Unit_Plan__c> unitPlanList = [Select Id,Unit__c FROM Unit_Plan__c where Opportunity__c =: recordId];
       List<String> unitIds = new List<String>();
           for(Unit_Plan__c up : unitPlanList){
            unitIds.add(up.Unit__c);
        }
         system.debug('unitIds'+unitIds);
        List<Unit__c> unitList = new List<Unit__c>();
        unitList = [Select Id,name,active__c,Business_Unit__c,Project__r.Name,No_of_Bedrooms__c,No_of_Car_Parkings__c,Location__r.Name,Floor__c,Floor__r.Name,Building__r.Name,Space_Type__c,Business_Group__c,unit_status__c,Unit_Number__c,Unit_type__c,Base_Rent__c,Usable_Area__c,Assignable_Area__c,Building__c,Project__c,Space_Types__c, Space_Types__r.Name,Built_Up_Area_Sqft__c from Unit__c where ID IN: unitIds];
        system.debug('unitList'+unitList);
        upClass.oppty = opp;
        upClass.unitList = unitList;
        
        return upClass;
    }


    
    public Class UnitPaymentClass {
        @AuraEnabled 
        public Opportunity oppty{get;set;}
        
        @AuraEnabled
        public List<Unit__c> unitList{get;set;}
    } 
    
       */
    
}