/*
@Author : Swapnil Mohite
@CreatedDate: 03/03/2022
@ This apex class will handle all the functionality related to Available Payment Plan/Installments
*/
public class AvailablePayPlanController {
    
    public static Set<String> spaceTypeIdSet = new Set<String>();
    public static Set<String> unitTypeSet = new Set<String>();
    public static Map<String,Aggregated_Milestone__c> aggrMilestoneMap = new Map<String,Aggregated_Milestone__c>();
    /*
@Author : Swapnil Mohite
@CreatedDate: 04/02/2022
@ This method will fetch the installments
*/  
    @AuraEnabled
    public static ParentWrapper getOppUnits(String oppId){
        Set<Id> unitIds = new Set<Id>();
        Map<Id,Availabe_Payment_Plan__c> spaceTypeAppMap = new Map<Id,Availabe_Payment_Plan__c>(); // space type and available payment plan map
        ParentWrapper parentWrapper = new ParentWrapper();
        
        Opportunity opp = [SELECT Id,Project__c,Project__r.Name,Leasing_Type__c,Account.Emirates_Ids__c,Lease_Start_Date__c,Project__r.Business_Unit__r.ERP_Business_Unit_Id__c,
                           Project__r.Business_Unit__c,Account.Primary_Email__c,Change_Unit__c,Lease_End_Date__c,Agency_name__c
                           FROM Opportunity 
                           WHERE Id =: oppId];
        List<Payment_Milestone__c> installmentList = [SELECT id,name
                                                      FROM Payment_Milestone__c
                                                      WHERE opportunity__c=: opp.Id];
        if(installmentList.size() <= 0){
            List<Unit_Plan__c> unitPlanList = [SELECT Id,Unit__c,Unit__r.Unit_Code__c,unit__r.Unit_Leasing_Type__r.name,unit__r.Total_Leasable_Area__c,unit__r.Unit_Leasing_Type__c,
                                               unit__r.unit_type__c,unit__r.Discount__c,unit__r.Security_Deposit__c,unit__r.Base_Rent__c,
                                               unit__r.Price_Per_SQ_FT__c,unit__r.Markup_Rent__c, unit__r.Leasing_Property_Type__c
                                               FROM Unit_Plan__c 
                                               WHERE Opportunity__c =: oppId];
            decimal totalDepositAmount = 0;
            decimal TotalBaseLeaseAmount = 0;
            decimal originalTotalBaseLeaseAmount = 0;
            List<InstallmentWrapper> installList = new List<InstallmentWrapper>();
            for(Unit_Plan__c unitPlan : unitPlanList){
                //for vat and additional charges - 
                spaceTypeIdSet.add(unitPlan.unit__r.Unit_Leasing_Type__c); //changes by karishma replaced unit_Type with Leasing_Property_Type__c
                unitTypeSet.add(unitPlan.unit__r.Leasing_Property_Type__c); //changes by karishma replaced unit_Type with Leasing_Property_Type__c
                //
                InstallmentWrapper installmentWrapper = new InstallmentWrapper();
                installmentWrapper.spaceTypeId = unitPlan.unit__r.Unit_Leasing_Type__c;
                installmentWrapper.unitType = unitPlan.unit__r.Leasing_Property_Type__c; //changes by karishma replaced unit_Type with Leasing_Property_Type__c
                installmentWrapper.oppUnitId = unitPlan.Id;
                installmentWrapper.employeeDiscountAmount = 0;
                installmentWrapper.discountAmount = 0;
                installmentWrapper.spaceType = unitPlan.unit__r.Unit_Leasing_Type__r.name;
                installmentWrapper.unitCode = String.valueOf(unitPlan.unit__r.Unit_Code__c);
                installmentWrapper.totalLeasableArea = unitPlan.unit__r.Total_Leasable_Area__c;
                installmentWrapper.unitId = unitPlan.Unit__c;
                // Availabe_Payment_Plan__c availPlan = spaceTypeAppMap.get(unitPlan.unit__r.Unit_Leasing_Type__c);
                //fields from APP
                InstallmentWrapper.availableDiscount = unitPlan.unit__r.Discount__c == null ? 0 : unitPlan.unit__r.Discount__c;
                installmentWrapper.discount = 0;
                
                installmentWrapper.pricePerSqft = unitPlan.unit__r.Price_Per_SQ_FT__c  == null ? 0 :  unitPlan.unit__r.Price_Per_SQ_FT__c;
                installmentWrapper.deposit = unitPlan.unit__r.Security_Deposit__c  == null ? 0 :  unitPlan.unit__r.Security_Deposit__c;
                if(opp.Leasing_Type__c == 'Residential Units'){
                    installmentWrapper.baseLeaseAmount = unitPlan.unit__r.Base_rent__c == null ? 0 :  unitPlan.unit__r.Base_rent__c;
                    installmentWrapper.finalLeaseAmount = unitPlan.unit__r.Base_rent__c == null ? 0 :  unitPlan.unit__r.Base_rent__c;
                    installmentWrapper.markupAmount = unitPlan.unit__r.Markup_rent__c == null ? 0 :  unitPlan.unit__r.Markup_rent__c;
                     installmentWrapper.originalFinalLeaseAmount = unitPlan.unit__r.Base_rent__c == null ? 0 :  unitPlan.unit__r.Base_rent__c;
                }else if(opp.Leasing_Type__c == 'Commercial Units'){
                    installmentWrapper.baseLeaseAmount = unitPlan.unit__r.Price_Per_SQ_FT__c * unitPlan.unit__r.Total_Leasable_Area__c;
                    installmentWrapper.finalLeaseAmount = unitPlan.unit__r.Price_Per_SQ_FT__c * unitPlan.unit__r.Total_Leasable_Area__c;
                    installmentWrapper.originalBaseLeaseAmount = unitPlan.unit__r.Price_Per_SQ_FT__c * unitPlan.unit__r.Total_Leasable_Area__c; //Added by Karishma 07-05-2022
                    installmentWrapper.originalFinalLeaseAmount = unitPlan.unit__r.Price_Per_SQ_FT__c * unitPlan.unit__r.Total_Leasable_Area__c; //Added by Karishma 07-05-2022
                }
                totalBaseLeaseAmount = TotalBaseLeaseAmount + installmentWrapper.baseLeaseAmount;
                if(installmentWrapper.originalBaseLeaseAmount != 0 && installmentWrapper.originalBaseLeaseAmount != null){
                originalTotalBaseLeaseAmount = originalTotalBaseLeaseAmount + installmentWrapper.originalBaseLeaseAmount; 
                }//Added by Karishma 07-05-2022
                totalDepositAmount = totalDepositAmount + unitPlan.unit__r.Security_Deposit__c;
                // additional charges
                installList.add(installmentWrapper);
            }
            parentWrapper.installWrapperList = installList;
            parentWrapper.oppObj = opp;
            parentWrapper.totalLeaseAmount = totalBaseLeaseAmount;
            parentWrapper.totalBaseAMount = totalBaseLeaseAmount;
            parentWrapper.originalTotalBaseAmount = originalTotalBaseLeaseAmount; //Added by Karishma 07-05-2022
            parentWrapper.originalTotalDiscountAmount = 0; //Added by Karishma 07-05-2022
            parentWrapper.totalDiscountAmount = 0;
            parentWrapper.totalDepositAmount = totalDepositAmount;
            parentWrapper.spacetypeIdSet = new List<String>(spaceTypeIdSet);
            parentWrapper.unitTypeSet = new List<String>(unitTypeSet);
            
        }else{
            parentWrapper.oppObj = opp;
            parentWrapper.totalLeaseAmount = 0;
            parentWrapper.totalBaseAMount = 0;
            parentWrapper.totalDiscountAmount = 0;
            parentWrapper.isInsCreated = true;
            
        }
        return parentWrapper;
    } 
    /*
@Author : Swapnil Mohite
@CreatedDate: 04/03/2022‸‸
@ This method will calculate all amount fields needed to create the installment
*/  
    @AuraEnabled
    public static ParentWrapper calculateAmount(String oppId,Integer selectedCheque,String paymentMode,Decimal empDiscount,Decimal pricePerSqft){
        decimal totalLeaseAmount = 0;
        decimal totalBaseAmount = 0;
        Decimal totalDiscount = 0;
        
        ParentWrapper parentWrapper = getOppUnits(oppId);
        Integer noOfCheques = Integer.valueOf(selectedCheque);
        List<InstallmentWrapper> insList = new List<installmentWrapper>();
        for(InstallmentWrapper ins : parentWrapper.installWrapperList){
            if(noOfCheques == 1 && parentWrapper.oppObj.Leasing_Type__c == 'Residential Units'){
                if(ins.availableDiscount != 0){
                    ins.discountAmount = (ins.baseLeaseAmount * (ins.availableDiscount/100)).setScale(2);
                    ins.finalLeaseAmount = ins.baseLeaseAmount - ins.discountAmount;
                    ins.discount = ins.availableDiscount;
                    ins.employeeDiscountAmount = 0;
                }else if(empDiscount != 0 &&empDiscount != null){
                    ins.employeeDiscountAmount = (ins.baseLeaseAmount * (empDiscount/100)).setScale(2);
                    ins.finalLeaseAmount = ins.baseLeaseAmount - ins.employeeDiscountAmount; // only applicable in case of single unit - person account
                    ins.discountAmount = (ins.baseLeaseAmount * (empDiscount/100)).setScale(2);
                    ins.discount = empDiscount;
                }else{
                    ins.finalLeaseAmount = ins.baseLeaseAmount;
                    ins.discountAmount = 0;
                    ins.discount = 0;
                }
            }else if(noOfCheques == 12 && parentWrapper.oppObj.Leasing_Type__c == 'Residential Units'){
                ins.baseLeaseAmount = ins.markupAmount;
                ins.finalLeaseAmount = ins.markupAmount;
                ins.discount = 0;
                ins.discountAmount = 0;
            }else{
                if(parentWrapper.oppObj.Leasing_Type__c == 'Residential Units'){
                    ins.finalLeaseAmount = ins.baseLeaseAmount;
                    ins.discountAmount = 0;
                }else{
                    if(pricePerSqft !=0 && pricePerSqft != null){
                        ins.finalLeaseAmount = (pricePerSqft * ins.totalLeasableArea).setScale(2);
                        if(pricePerSqft < ins.pricePerSqft){
                            ins.discountAmount = (ins.pricePerSqft * ins.totalLeasableArea).setScale(2) -(pricePerSqft * ins.totalLeasableArea).setScale(2);
                        }
                    }else{
                        ins.finalLeaseAmount = (ins.pricePerSqft * ins.totalLeasableArea).setScale(2);
                    }
                    ins.baseLeaseAmount = (ins.pricePerSqft * ins.totalLeasableArea).setScale(2);
                }
            } // if cheques other than 1 or 12 are selected - as 1 and 12 cheques have different price calculation
            if(empDiscount != 0 && empDiscount != null && ins.discountAmount == 0 && parentWrapper.oppObj.Leasing_Type__c == 'Residential Units'){
                ins.employeeDiscountAmount = (ins.baseLeaseAmount * (empDiscount/100)).setScale(2);
                ins.finalLeaseAmount = ins.baseLeaseAmount - ins.employeeDiscountAmount; // only applicable in case of single unit - person account
                ins.discountAmount = (ins.baseLeaseAmount * (empDiscount/100)).setScale(2);
                ins.discount = empDiscount;
            }else{
                ins.employeeDiscountAmount = 0;
                
            }  
            insList.add(ins);
            totalLeaseAmount = totalLeaseAmount + ins.finalLeaseAmount;
            totalBaseAmount = totalBaseAmount + ins.baseLeaseAmount;
            totalDiscount = totalDiscount + ins.discountAmount;
            
        }
        parentWrapper.totalLeaseAmount = totalLeaseAmount.setScale(2);
        parentWrapper.totalBaseAmount = totalBaseAmount.setScale(2);
        parentWrapper.totalDiscountAmount = totalDiscount.setScale(2);
        parentWrapper.installWrapperList = insList;
        return parentWrapper;
    }
    /*
@Author : Swapnil Mohite
@CreatedDate: 05/03/2022
@ This method will create have the logic to create additional charges and installments
*/  
    @AuraEnabled
    public static void createInstallmentAndCharges(ParentWrapper parentWrapper,String noOfCheques,String paymentMode,Decimal pricePerSqft){
        
        List<Unit_Plan__c> unitPlanList = new List<Unit_Plan__c>();
        Map<String,Additional_Charges__c> masterChargesMap = new Map<String,Additional_Charges__c>();
        Map<String,Charges_Configuration__c> rentChargesMap = new Map<String,Charges_Configuration__c>();
        Map<String,Charges_Configuration__c> securityChargesMap = new Map<String,Charges_Configuration__c>();
        Map<String,List<Charges_Configuration__c>> additionalChargesMap = new Map<String,List<Charges_Configuration__c>>();
        Map<String, String> pickLabelApiMap = getPicklistValues('Payment_Milestone__c','Installment__c');
        List<Payment_Milestone__c> installmentList = new List<Payment_Milestone__c>();
        List<Opportunity_Charges__c> additionalChargesList = new List<Opportunity_Charges__c>();
        Installment_Configuration__mdt installmentMdt = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Termination_ID__c 
                                                         FROM Installment_Configuration__mdt 
                                                         WHERE MasterLabel =: noOfCheques];
        List<Installment_Line_Configuration__mdt> installmetLineList = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, 
                                                                        Installment_Configuration__c, Amount__c, Number_Of_Days__c,Installment_Name__c 
                                                                        FROM Installment_Line_Configuration__mdt
                                                                        WHERE Installment_Configuration__c =: installmentMdt.Id 
                                                                        ORDER BY Number_Of_Days__c ASC];
        system.debug('parentWrapper.oppObj.project__r.business_unit__c->'+parentWrapper.oppObj.project__r.business_unit__c);
        system.debug('spacetype->'+parentWrapper.spaceTypeIdSet);
        system.debug('type->'+parentWrapper.unitTypeSet);
        String LeasingTypeForCharges = '';
        if(parentWrapper.oppObj.Leasing_type__c == 'Commercial Units'){
            LeasingTypeForCharges = 'Commercial';
        }else if(parentWrapper.oppObj.Leasing_type__c == 'Residential Units'){
            LeasingTypeForCharges = 'Residential';
        }
        
        // new charges implementation
        List<Additional_Charges__c> masterChargesList = [SELECT Id,name, Security_Deposit__c,  Project__c, Type__c, Amount__c,Amount_On__c, 
                                                         Default_Sales_Charge__c, Charge_Type__c, Amount_Leasing__c, Fixed_Amount__c, Space_Type__c, Required__c, 
                                                         Transaction_Type__c, Type_Leasing__c, Sub_Type__c, Applicable_for_renewal__c, Active__c, Payment_Purpose_Code__c, 
                                                         Payment_Term_Type_Code__c, Invoicing_Rule__c, Accounting_Rule__c, Frequency__c, Tax_Configuration__c,leasing_type__c,
                                                         Tax_Configuration__r.Tax_Rate__c
                                                         FROM Additional_Charges__c 
                                                         WHERE Project__c =:parentWrapper.oppObj.project__c 
                                                         and Required__c= true and Active__c = true];
        for(Additional_Charges__c masterCharges : masterChargesList){
            if(masterCharges.Type_Leasing__c == 'Charges'){
               masterChargesMap.put(masterCharges.Type_Leasing__c + masterCharges.Id,masterCharges);
            }else{
               masterChargesMap.put(masterCharges.Type_Leasing__c,masterCharges);
            }
        }
        for(InstallmentWrapper iObj : parentWrapper.installWrapperList){
            Integer i = 1;
            List<Payment_Milestone__c> tempInstallmentList = new List<Payment_Milestone__c>();
            // tempInstallmentList = createInstallments(parentWrapper,iObj,rentChargesMap,securityChargesMap,additionalChargesMap,paymentMode,installmetLineList,pickLabelApiMap);
            tempInstallmentList = createInstallments(parentWrapper,iObj,masterChargesMap,paymentMode,installmetLineList,pickLabelApiMap,pricePerSqft);
            installmentList.addAll(tempInstallmentList);
            List<Opportunity_Charges__c> tempChargesList = new List<Opportunity_Charges__c>();
            tempChargesList = createAdditionalCharges(parentWrapper,iObj,masterChargesMap.values(),paymentMode,pricePerSqft);
            additionalChargesList.addAll(tempChargesList);
            system.debug('addChargesList'+additionalChargesList);
            Unit_Plan__c unitPlan = new Unit_Plan__c(id = iObj.oppUnitId);
            //unitPlan.Base_Lease_Amount__c  = iObj.baseLeaseAmount;   
            unitPlan.Discount__c = iObj.discount;
            //unitPlan.Discount_Amount__c = iObj.discountAmount;
            //unitPlan.Final_Lease_Amount__c = iObj.finalLeaseAmount;
            unitPlan.Security_Deposit__c = iObj.deposit;
            unitPlan.payment_mode__c = paymentMode;
            unitPlan.No_Of_Cheques__c  = Integer.valueOf(noOfCheques);
            if(pricePerSqft != null && pricePerSqft !=0){
                unitPlan.price_per_sqft__c = iObj.pricePerSqft;
                unitPlan.Proposed_price_per_sqft__c  = pricePerSqft;
                unitPlan.Base_Lease_Amount__c = iObj.originalBaseLeaseAmount;
                unitPlan.Final_Lease_Amount__c = iObj.originalFinalLeaseAmount;
                unitPlan.Discount_Amount__c = iObj.originalDiscountAmount;
                unitPlan.Final_Lease_Amount_Calculated__c = iObj.finalLeaseAmount;
                unitPlan.Base_Lease_Amount_Calculated__c = iObj.baseLeaseAmount;
                unitPlan.Discount_Amount_Calculated__c = iObj.discountAmount;
            }else{
                unitPlan.price_per_sqft__c = iObj.pricePerSqft;
                unitPlan.Base_Lease_Amount__c  = iObj.baseLeaseAmount;
                unitPlan.Discount_Amount__c = iObj.discountAmount;
                unitPlan.Final_Lease_Amount__c = iObj.finalLeaseAmount;
            }
            unitPlanList.add(unitPlan);
        }
        if(additionalChargesList.size() > 0){
            insert additionalChargesList;
        }
        if(installmentList.size() > 0){
            insert installmentList;
        }
        
        if(unitPlanList.size() > 0){
            update unitPlanList;
        }
        if(unitPlanList.size() > 1){
            insert aggrMilestoneMap.values();
        }
        Opportunity opp = new Opportunity();
        opp.Id = parentWrapper.oppObj.Id;
        opp.No_Of_Cheques__c = noOfCheques;   
        update opp;
    }
    /*
@Author : Swapnil Mohite
@CreatedDate: 05/03/2022
@ This method will revise the installments
*/  
    @AuraEnabled
    public static void reviseInstallments(String oppId){
      List<Payment_Milestone__c> installmentList = [SELECT id,name
                                                      FROM Payment_Milestone__c
                                                      WHERE opportunity__c=: oppId];
        List<Opportunity_Charges__c> oppChargesList = [SELECT id,name
                                                      FROM Opportunity_Charges__c
                                                      WHERE opportunity__c=: oppId];
        List<Aggregated_Milestone__c> aggrList = [SELECT id,name 
                                                 FROM Aggregated_Milestone__c 
                                                 WHERE deal__c =: oppId];
        if(installmentList.size() > 0){
            delete installmentList;
        }
        if(oppChargesList.size() > 0){
            delete oppChargesList;
        }
         if(aggrList.size() > 0){
            delete aggrList;
        }
    }
         /*
@Author : Hitesh Saini
@CreatedDate: 05/03/2022
@ This method will check the spl Offer if applied - new method
*/
@AuraEnabled
public static Lease_Applied_Offer__c getappliedOffer(String oppUnitId){
    Lease_Applied_Offer__c appliedOffer=new Lease_Applied_Offer__c();
   List<Lease_Applied_Offer__c> lstappliedOffer=new List<Lease_Applied_Offer__c>();
    
    lstappliedOffer=[select id,Opportunity_Unit__c, Lease_Special_Offer__c,Lease_Special_Offer__r.Name,Lease_Special_Offer__r.Start_Date__c,Lease_Special_Offer__r.End_Date__c, Lease_Special_Offer__r.Project__c,
                                                     Lease_Special_Offer__r.Property_Type__c, Lease_Special_Offer__r.Unit_Type__c, Lease_Special_Offer__r.No_of_Bedrooms__c, 
                                  Lease_Special_Offer__r.Active__c,Lease_Special_Offer__r.Approval_Status__c, Lease_Special_Offer__r.Fit_Out_Days__c, Lease_Special_Offer__r.Rent_Free_Days__c, Lease_Special_Offer__r.Security_Deposit_Percentage__c,Lease_Special_Offer__r.Project__r.Name,Security_Deposit_Percentage__c from Lease_Applied_Offer__c  WHERE Opportunity_Unit__c =: oppUnitId Limit 1];
    system.debug('lstappliedOffer>>>>>'+lstappliedOffer); 
    if(!lstappliedOffer.isEmpty()){
        return lstappliedOffer[0];
    }
    else{
        return null;
    }
    
}

    /*
@Author : Swapnil Mohite
@CreatedDate: 05/03/2022
@ This method will create the installments
*/
    @AuraEnabled
    /* public static List<Payment_Milestone__c> createInstallments(ParentWrapper parentWrapper,InstallmentWrapper iObj,Map<String,Charges_Configuration__c> rentChargesMap,Map<String,Charges_Configuration__c> securityChargesMap,
Map<String,List<Charges_Configuration__c>> additionalChargesMap,String paymentMode, List<Installment_Line_Configuration__mdt> installmetLineList,Map<String,String> pickLabelApiMap){*/
    public static List<Payment_Milestone__c> createInstallments(ParentWrapper parentWrapper,InstallmentWrapper iObj,Map<String,Additional_Charges__c> masterChargesMap,String paymentMode, 
                                                                List<Installment_Line_Configuration__mdt> installmetLineList,Map<String,String> pickLabelApiMap,decimal pricePerSqft){
                                                                    Integer i = 0;
                                                                    List<Payment_Milestone__c> installmentList = new List<Payment_Milestone__c>();                               
                                                                    Payment_Milestone__c secInstallment = new Payment_Milestone__c();
                                                                    secInstallment.name = 'Security Deposit';
                                                                    secInstallment.Installment_No__c = 0;
                                                                    secInstallment.Due_Date__c = parentWrapper.oppObj.Lease_Start_Date__c;
                                                                    secInstallment.Installment__c = 'SEC';
                                                                    secInstallment.Opportunity__c = parentWrapper.oppObj.Id;
                                                                    secInstallment.Unit_Plan__c = iObj.oppUnitId;
                                                                    secInstallment.payment_mode__c = paymentMode;
                                                                    //Code Added for Spl Offer - Hitesh
                                                                    Lease_Applied_Offer__c appOffer=new Lease_Applied_Offer__c();
                                                                    appOffer=getappliedOffer(iObj.oppUnitId);
                                                                    system.debug('appOffer>>>>'+appOffer);
                                                                    if(appOffer!=null){
                                                                      secInstallment.Amount__c = iObj.deposit -  (appOffer.Security_Deposit_Percentage__c*iObj.deposit) /100;
                                                                    }
                                                                    else{
                                                                       secInstallment.Amount__c = iObj.deposit; 
                                                                    }
                                                                     //End Code Added for Spl Offer - Hitesh
                                                                    secInstallment.Unit__c = iObj.unitId;
                                                                    
                                                                    if(masterChargesMap.containsKey('Security Deposit') && masterChargesMap.get('Security Deposit').Tax_Configuration__r.Tax_Rate__c !=0){                
                                                                        secInstallment.Payable_Amount__c = (iObj.deposit + ((masterChargesMap.get('Security Deposit').Tax_Configuration__r.Tax_Rate__c/100) * iObj.deposit)).setScale(2);// to be calculated with vat
                                                                        
                                                                    }else{
                                                                        secInstallment.Payable_Amount__c  = iObj.deposit;
                                                                        //   secInstallment.Vat__c = 0;
                                                                        // secInstallment.Vat_Amount__c = 0;
                                                                    }
                                                                    
                                                                    if(masterChargesMap.containsKey('Security Deposit')){
                                                                        secInstallment.Master_Additional_Charges__c  = masterChargesMap.get('Security Deposit').Id;
                                                                    }
                                                                    // added for aggregate ->
                                                                    if(aggrMilestoneMap.containsKey('Security Deposit')){
                                                                        Aggregated_Milestone__c aggr = aggrMilestoneMap.get('Security Deposit');
                                                                        aggr.Amount__c = aggr.Amount__c + secInstallment.Amount__c;
                                                                        
                                                                    }else{
                                                                        Aggregated_Milestone__c aggr = createAggregatedMilestones(secInstallment,null,false,pickLabelApiMap,null);
                                                                        aggrMilestoneMap.put('Security Deposit',aggr);
                                                                    }
                                                                    // code end for aggregate
                                                                    installmentList.add(secInstallment);
                                                                     
                                                                    //code for security deposit end
                                                                    Integer daysToAdd = 0; // used for change of unit
                                                                    Date startDate = parentWrapper.oppObj.Lease_Start_Date__c;
                                                                    for(Installment_Line_Configuration__mdt insLineObj : installmetLineList){
                                                                        Payment_Milestone__c installment = new Payment_Milestone__c();
                                                                        installment.name = pickLabelApiMap.get(insLineObj.Installment_Name__c);
                                                                        installment.Installment_No__c = i;
                                                                        if(parentWrapper.oppObj.change_unit__c){
                                                                            installment.Due_Date__c = startDate;
                                                                            daysToAdd = ((parentWrapper.oppObj.Lease_Start_Date__c).daysBetween(Date.valueOf(parentWrapper.oppObj.Lease_End_Date__c)))/installmetLineList.size();
                                                                            startDate = startDate.addDays(daysToAdd);
                                                                        }else{
                                                                            installment.Due_Date__c = parentWrapper.oppObj.Lease_Start_Date__c.addDays(Integer.valueOf(insLineObj.Number_Of_Days__c));
                                                                        }
                                                                        installment.Installment__c = insLineObj.Installment_Name__c;
                                                                        installment.Opportunity__c = parentWrapper.oppObj.Id;
                                                                        installment.Unit_Plan__c = iObj.oppUnitId;
                                                                        installment.Unit__c = iObj.unitId;
                                                                        installment.payment_mode__c = paymentMode;
                                                                        if(pricePerSqft != null && pricePerSqft !=0){
                                                                          installment.Amount__c = ((insLineObj.Amount__c/100) * iObj.originalFinalLeaseAmount).setScale(2);
                                                                        }else{
                                                                          installment.Amount__c = ((insLineObj.Amount__c/100) * iObj.finalLeaseAmount).setScale(2);
                                                                        }
                                                                        installment.Revised_Amount__c = ((insLineObj.Amount__c/100) * iObj.finalLeaseAmount).setScale(2);
                                                                        if(masterChargesMap.containsKey('Rent') && masterChargesMap.get('Rent').Tax_Configuration__r.Tax_Rate__c !=0){                
                                                                            installment.Payable_Amount__c = (installment.Amount__c + ((masterChargesMap.get('Rent').Tax_Configuration__r.Tax_Rate__c/100) * installment.Amount__c)).setScale(2);// to be calculated with vat
                                                                            installment.New_Payable_Amount__c = (installment.Revised_Amount__c + ((masterChargesMap.get('Rent').Tax_Configuration__r.Tax_Rate__c/100) * installment.Revised_Amount__c)).setScale(2);// to be calculated with vat added by karishma 07-05-2022
                                                                            //  installment.Vat__c = rentChargesMap.get(iObj.unitType + iObj.spaceTypeId).Billing_Configuration__r.Tax_Configuration__r.Tax_Rate__c;
                                                                            //   installment.Vat_Amount__c = ((rentChargesMap.get(iObj.unitType + iObj.spaceTypeId).Billing_Configuration__r.Tax_Configuration__r.Tax_Rate__c/100) * installment.Amount__c).setScale(2);
                                                                            
                                                                        }else{
                                                                            installment.Payable_Amount__c  = installment.Amount__c;
                                                                            installment.New_Payable_Amount__c  = installment.Revised_Amount__c; //Added by karishma 07-05-2022
                                                                            //   installment.Vat__c = 0;
                                                                            //  installment.Vat_Amount__c = 0;
                                                                        }
                                                                        system.debug('key->'+iObj.unitType + iObj.spaceTypeId);
                                                                        if(masterChargesMap.containsKey('Rent')){
                                                                            installment.master_additional_charges__c = masterChargesMap.get('Rent').Id;
                                                                        }
                                                                        if(aggrMilestoneMap.containsKey(installment.Installment__c)){
                                                                            Aggregated_Milestone__c aggr = aggrMilestoneMap.get(installment.Installment__c);
                                                                            aggr.Amount__c = aggr.Amount__c + installment.Amount__c;
                                                                            aggr.Calculated_Amount__c = aggr.Calculated_Amount__c +  installment.Revised_Amount__c;
                                                                            aggrMilestoneMap.put(installment.Installment__c,aggr);
                                                                        }else{
                                                                            Aggregated_Milestone__c aggr = createAggregatedMilestones(installment,null,false,pickLabelApiMap,null);
                                                                            aggrMilestoneMap.put(installment.Installment__c,aggr);
                                                                        }
                                                                        installmentList.add(installment);
                                                                        i++;
                                                                    }
                                                                    return installmentList;
                                                                }
    /*
@Author : Swapnil Mohite
@CreatedDate: 05/03/2022
@ This method will create the additional charges
*/
    @AuraEnabled
    public static List<Opportunity_Charges__c> createAdditionalCharges(ParentWrapper parentWrapper,InstallmentWrapper iObj,List<Additional_Charges__c> masterList,string paymentMode,Decimal pricePerSqft){
        
        List<Opportunity_Charges__c> additionalChargesList = new List<Opportunity_Charges__c>();
        // if(!additionalChargesMap.isEmpty() && additionalChargesMap.containsKey(iObj.unitType + iObj.spaceTypeId)){
        if(masterList.size() > 0){
            for(Additional_Charges__c charges: masterList){
                if(charges.Type_Leasing__c == 'Charges' 
                   && (charges.Sub_Type__c != 'Leasing Commission' || 
                       (charges.Sub_Type__c == 'Leasing Commission' 
                        && ((parentWrapper.oppObj.change_unit__c == true && parentWrapper.oppObj.Do_you_want_to_be_treated_as_new_tenant__c == 'Yes') 
                            ||  parentWrapper.oppObj.Agency_name__c == null)))){
                    Opportunity_Charges__c  addCharges = new Opportunity_Charges__c ();
                    addCharges.name = charges.name;
                    addCharges.Opportunity__c = parentWrapper.oppObj.Id;
                    addCharges.Unit__c = iObj.unitId;
                    addCharges.Due_Date__c = parentWrapper.oppObj.lease_Start_date__c;
                    if(charges.Fixed_Amount__c !=0 && charges.Fixed_Amount__c != null){
                        addCharges.Amount__c = charges.Fixed_Amount__c;
                        addCharges.Revised_Amount__c = charges.Fixed_Amount__c;
                    }else if(charges.Amount_Leasing__c !=0 && charges.Amount_Leasing__c  != null){
                        if(charges.Amount_On__c == 'Base Rent'){
                            addCharges.Amount__c = iObj.baseLeaseAmount * (charges.Amount_Leasing__c /100).setScale(2);
                            addCharges.Revised_Amount__c = iObj.baseLeaseAmount * (charges.Amount_Leasing__c /100).setScale(2);
                        }else if(charges.Amount_On__c == 'Current Rent'){
                            if(pricePerSqft !=null && pricePerSqft !=0){
                                addCharges.Amount__c = iObj.originalFinalLeaseAmount * (charges.Amount_Leasing__c /100).setScale(2);
                                
                            }else{
                                addCharges.Amount__c = iObj.finalLeaseAmount * (charges.Amount_Leasing__c /100).setScale(2);
                            }
                            addCharges.Revised_Amount__c = iObj.finalLeaseAmount * (charges.Amount_Leasing__c /100).setScale(2);
                        }
                        // addCharges.VAT__c = 0;
                    }else{
                        addCharges.Amount__c = 0;
                        //  addCharges.VAT__c = 0;
                    }
                    addCharges.master_Additional_charges__c  = charges.Id;
                    if(addCharges.Amount__c != 0){
                        if(charges.Tax_Configuration__r.Tax_Rate__c != 0){
                            addCharges.Payable_Amount__c = (addCharges.Amount__c + (addCharges.Amount__c * (charges.Tax_Configuration__r.Tax_Rate__c)/100)).setScale(2);
                           addCharges.New_Payable_Amount__c = (addCharges.Revised_Amount__c + (addCharges.Revised_Amount__c * (charges.Tax_Configuration__r.Tax_Rate__c)/100)).setScale(2);
                        }else{
                            addCharges.Payable_Amount__c = addCharges.Amount__c;
                            addCharges.New_Payable_Amount__c = addCharges.Revised_Amount__c;
                        }
                        additionalChargesList.add(addCharges);
                    }
                    if(aggrMilestoneMap.containsKey(charges.Payment_Term_Type_Code__c)){
                        Aggregated_Milestone__c aggr = aggrMilestoneMap.get(charges.Payment_Term_Type_Code__c);
                        aggr.Amount__c = aggr.Amount__c + addCharges.Amount__c;
                        aggrMilestoneMap.put(charges.Payment_Term_Type_Code__c,aggr);
                    }else{
                        Aggregated_Milestone__c aggr = createAggregatedMilestones(null,addCharges,true,null,charges.Payment_Term_Type_Code__c);
                        aggrMilestoneMap.put(charges.Payment_Term_Type_Code__c,aggr);
                    }
                }
            }
        }
        return additionalChargesList;
    }
    /*
@Author : Swapnil Mohite
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
    /*
@Author : Swapnil Mohite
@CreatedDate: 20/02/2022
@ This method is to fetch picklist values
*/ 
    @AuraEnabled 
    public static Aggregated_Milestone__c createAggregatedMilestones(Payment_Milestone__c installment,Opportunity_Charges__c charges,Boolean isCharges,Map<String,String> pickLabelApiMap,String paymentTermtype){
        Aggregated_Milestone__c aggrObj = new Aggregated_Milestone__c();
        if(!isCharges){
            aggrObj.Name =  installment.name;
            aggrObj.Due_Date__c  = installment.Due_Date__c;
            aggrObj.Installment__c  = installment.Installment__c;
            aggrObj.Deal__c = installment.Opportunity__c ;
            aggrObj.Description__c  = installment.name;
            aggrObj.Billing_Configuration__c   = installment.billing_configuration__c;
            aggrObj.payment_mode__c = installment.payment_mode__c;
            aggrObj.Amount__c =  installment.Amount__c;
            aggrObj.Master_Additional_Charges__c = installment.Master_Additional_Charges__c;
            aggrObj.Calculated_Amount__c = installment.Revised_Amount__c;
        }else{
            aggrObj.Name = charges.Name;
            aggrObj.Payment_Term_Type__c = paymentTermType;
            aggrObj.Deal__c = charges.Opportunity__c;
            aggrObj.Description__c  = charges.Name;
            aggrObj.Billing_Configuration__c   = charges.Billing_Configuration__c;
            aggrObj.Due_Date__c  =  charges.Due_Date__c;
            // aggrObj.payment_mode__c = c;
            aggrObj.Amount__c = charges.Amount__c;
            aggrObj.IsAdditionalCharges__c = true;
            aggrObj.Master_Additional_Charges__c = charges.Master_Additional_Charges__c;
            aggrObj.Calculated_Amount__c = charges.Revised_Amount__c;
        } 
        return aggrObj;
    }
    @AuraEnabled
    public static void submitForApproval(String recordId, String rateReason, Integer pricePerSqft){
        try {
            Opportunity oppty = [SELECT Id, Price_Per_Sq_ft_Change_Sent_for_Approval__c, Email__c, Account.Primary_Email__c,
                                Revised_Price_per_Sq_ft__c FROM Opportunity WHERE Id=:recordId];
            system.debug('@@oppty :'+oppty);
            oppty.Id = recordId;
            oppty.Price_Per_Sq_ft_Change_Sent_for_Approval__c = true;
            oppty.Email__c = String.valueOf(oppty.Account.Primary_Email__c);
            oppty.Revised_Price_per_Sq_ft__c = pricePerSqft;

            update oppty;
            // call approval process
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setComments(rateReason);
            request.setObjectId(recordId);
            // Submit on behalf of a specific submitter
            request.setSubmitterId(userinfo.getUserId()); 
            // Submit the record to specific process and skip the criteria evaluation
            request.setProcessDefinitionNameOrId('price_per_sq_ft_is_changed');
            request.setSkipEntryCriteria(true);
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(request);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public Class ParentWrapper {
        @AuraEnabled 
        public Opportunity oppObj{get;set;}
        @AuraEnabled 
        public List<installmentWrapper> installWrapperList{get;set;}
        @AuraEnabled 
        public Decimal totalLeaseAmount{get;set;}
        @AuraEnabled 
        public Decimal totalBaseAmount{get;set;}
        @AuraEnabled 
        public Decimal totalDiscountAmount{get;set;}
        @AuraEnabled 
        public Boolean isInsCreated{get;set;}
        @AuraEnabled 
        public Decimal totalDepositAmount{get;set;}
        @AuraEnabled 
        public List<String> spaceTypeIdSet{get;set;}
        @AuraEnabled 
        public List<String> unitTypeSet{get;set;}
        @AuraEnabled 
        public Decimal originalTotalLeaseAmount{get;set;}
        @AuraEnabled 
        public Decimal originalTotalBaseAmount{get;set;}
        @AuraEnabled 
        public Decimal originalTotalDiscountAmount{get;set;}
        
    } 
    public Class InstallmentWrapper {
        
        @AuraEnabled 
        public String oppUnitId{get;set;}
        @AuraEnabled 
        public String unitId{get;set;}
        @AuraEnabled 
        public String unitType{get;set;}
        @AuraEnabled 
        public String spaceTypeId{get;set;}
        @AuraEnabled 
        public decimal deposit{get;set;}
        @AuraEnabled 
        public String spaceType{get;set;}
        @AuraEnabled 
        public String unitCode{get;set;}
        @AuraEnabled 
        public String paymentMode{get;set;}
        @AuraEnabled 
        public String numberOfCheques{get;set;}
        @AuraEnabled 
        public Decimal employeeDiscountAmount{get;set;}
        @AuraEnabled 
        public Decimal availableDiscount{get;set;}
        @AuraEnabled 
        public Decimal discount{get;set;}
        @AuraEnabled 
        public Decimal discountAmount{get;set;}
        @AuraEnabled 
        public Decimal totalLeasableArea{get;set;}
        @AuraEnabled 
        public Decimal baseLeaseAmount{get;set;} // base amount
        @AuraEnabled 
        public Decimal finalBaseAmount{get;set;} // without additional charges
        // lease amount with additional charges
        @AuraEnabled 
        public Decimal finalLeaseAmount{get;set;} // total deal amount
        @AuraEnabled 
        public Decimal markupAmount{get;set;}
        @AuraEnabled 
        public Decimal pricePerSqft{get;set;}
        @AuraEnabled 
        public List<Additional_Charges__c> chargesList{get;set;}
        @AuraEnabled 
        public Decimal originalDiscountAmount{get;set;}
        @AuraEnabled 
        public Decimal originalFinalLeaseAmount{get;set;}
        @AuraEnabled 
        public Decimal originalBaseLeaseAmount{get;set;}

        
    } 
    
}