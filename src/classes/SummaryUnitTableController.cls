public class SummaryUnitTableController {
    
    public static Map<String,Aggregated_Milestone__c> aggrMilestoneMap = new Map<String,Aggregated_Milestone__c>();
    /*
@Author : Hitesh Saini
@CreatedDate: 22/03/2022
@ This method will fetch all the leased units
*/  
    @AuraEnabled  
    public static Id createOpp1(List<RenewalSRUnitController.PropWrapper> listPropWrapper,List<RenewalSRUnitController.PropWrapper> listPropForTermination,date renewalDate,String renewalType,date renewalEndDate,String noOfCheques,Boolean ejariNeeded,String paymentMode,Boolean flag){
        system.debug('Inside createOpp >>>>>SummaryUnitTableController');
        Set<Id> setUnitId=new Set<Id>();
       Set<Id> setTerminationUnitId=new Set<Id>();
        Set<Id> setOldDealId=new Set<Id>();
        Set<String> spaceTypeIdSet = new Set<String>();
        Set<String> unitTypeSet = new Set<String>();
        String oldOppAccName;
        List<Opportunity> listOldOpp=new List<Opportunity>();
        List<Unit__c> listUnit=new List<Unit__c>();
        List<Unit_Plan__c>listUnitPlanInsert=new List<Unit_Plan__c>();
        List<Case_unit__c> lstCaseUnit=new List<Case_unit__c>();
        List<Unit__c> listUpdateUnit=new List<Unit__c>();
        Integer leaseDuration = 0 ;
        Boolean newUnitFlag = false;
        Id oppRenewRecordType= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Lease Renewal').getRecordTypeId();
        Id oppCommRenewRcdTyp= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Lease Renewal').getRecordTypeId();
        ID terminationRcdTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Termination').getRecordTypeId();
        try{
            listOldOpp.add(listPropWrapper[0].oppObj);
            
            oldOppAccName=listPropWrapper[0].oppObj.Account_Name__c;
            system.debug('oldOppAccName>>>>>>>>>>>'+oldOppAccName);
            system.debug('listOldOpp>>>>>>>'+listOldOpp.size());
            Opportunity opp=insertOpp(listPropWrapper[0].oppObj,noOfCheques,ejariNeeded,renewalType,renewalDate, renewalEndDate);
            system.debug('opp>>>>'+opp);
            if(renewalType=='Full'){
                renewalEndDate=opp.Lease_End_Date__c;
            }
            for(RenewalSRUnitController.PropWrapper p:listPropWrapper){
                Unit_Plan__c up=new Unit_Plan__c();
                up.Name=p.unitName;
                up.Opportunity__c=opp.Id;
                up.Unit__c=p.unitId;
                up.Project__c=opp.Project__c;
                Unit__c u=new Unit__c();
                 u.Id=p.UnitId;
                if(p.newUnit == true){
                    u.Unit_Status__c='On Hold';
                    newUnitFlag = true;
                    up.Renewal_new_unit__c = true;
                }else{
                    up.Renewal_new_unit__c = false;
                }
                up.Price_per_sqft__c= p.pricePerSqft;
                up.Base_Lease_Amount__c = p.rent;
                
                listUnitPlanInsert.add(up);
                listUpdateUnit.add(u);
            }
            // update opp 
            
            if(newUnitFlag == true){
                opp.Renewal_Scenario__c = 'Addition/Reduction';
            }else{
                opp.Renewal_Scenario__c = 'As is';
            }
            if(!listUnitPlanInsert.isEmpty()){
                insert listUnitPlanInsert;
            }
            if(!listUpdateUnit.isEmpty()){
                update listUpdateUnit;
            }
            leaseDuration=renewalDate.daysBetween( renewalEndDate ) +1 ;
            Integer intNoOfCheques=integer.valueof(noOfCheques);
            List<Opportunity> oppList=new List<Opportunity>();
            oppList.add(opp);
            
            //ParentWrapper parentWrapper=getOppUnits(opp.id,renewalType,leaseDuration);
            ParentWrapper parentWrapper=getOppUnits(opp,renewalType,leaseDuration);
            createInstallmentAndCharges(parentWrapper,noOfCheques,paymentMode,0.00,ejariNeeded);//Changed the default payment mode from cheque
            //end Financial calculation section
            if(!listPropForTermination.isEmpty()){
                system.debug('inside create case >>>>>');
                Case c=createTerminationCase(listOldOpp, renewalDate);
                system.debug('case c>>>>>>>>>' + c);
                For(RenewalSRUnitController.PropWrapper p:listPropForTermination){
                    setTerminationUnitId.add(p.unitId);
                }
                system.debug('setTerminationUnitId>>>>>>>'+setTerminationUnitId);
                for(Id i:setTerminationUnitId){
                    Case_unit__c cu=new Case_unit__c();
                    cu.Case__c=c.Id;
                    cu.Type__c='Existing';
                    lstCaseUnit.add(cu);
                }
                system.debug('lstCaseUnit>>>>>'+lstCaseUnit);
                insert lstCaseUnit;
            }
            if(flag == true){
                opp.Active_Customer_UnitFlag__c=true;
            }
            
            system.debug('Before generateOpportunityName Call >>>>>>>>');
            String strName = generateOpportunityName(oppList,oldOppAccName);
            opp.Name=strName;
            update opp;
            return opp.id;
        }
        catch(Exception e){
            System.debug('Error Line number>>>'+e.getLineNumber());
            System.debug('Error Message>>>'+e.getMessage());
            return null;
        }
        
    }
    //Method to create Case for termination of the units
    public static Case createTerminationCase(List<Opportunity>listOldOpp,date renewalDate){
        system.debug('Inside insert createTerminationCase>>>>>');
        ID terminationRcdTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Termination').getRecordTypeId();
        Case c=new case();
        try{            
            c.AccountId=listOldOpp[0].AccountId;
            c.Deal__c=listOldOpp[0].Id;
            c.End_of_Lease_Termination_Reason__c='Normal EOL';
            c.Expected_Termination_Date__c=renewalDate;
            c.Lease_End_Date__c=listOldOpp[0].Lease_End_Date__c;
            c.Lease_Start_Date__c=listOldOpp[0].Lease_Start_Date__c;
            c.Origin='Salesforce';
            c.RecordTypeId=terminationRcdTypId;
            c.Subject='Termination Request for multiple units';
            c.Termination_Type__c='End of Lease Termination';
            c.Actual_Termination_Date__c=listOldOpp[0].Lease_End_Date__c;
            c.No_of_Mths_Rent_Deduction__c=0;
            c.Penalty_charges__c=0;
            c.Refund_Applicable__c='No';            
            c.Type='Termination';            
            insert c;
        }
        catch(Exception e){
            System.debug('Error Line number>>>'+e.getLineNumber());
            System.debug('Error Message>>>'+e.getMessage());
        }
        
        return c;
        
    }
    
     //Method to create Opportunity - Hitesh 
    public static Opportunity insertOpp(Opportunity oppObj,String noOfCheques,Boolean ejariNeeded,String renewalType,date renewalDate,date renewalEndDate){
        Id oppRenewRecordType= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Lease Renewal').getRecordTypeId();
       	Id oppCommRenewRcdTyp= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Lease Renewal').getRecordTypeId();
        
        Opportunity opp=new Opportunity();//populate porject lookup on opportunity
        try{
            opp.name='Renewal - '+ oppObj.Account_Name__c;
            opp.StageName='In Progress';
            opp.CloseDate=System.today().addMonths(1);
            opp.Interested_In__c=oppObj.Interested_In__c;
            opp.Leasing_Type__c=oppObj.Leasing_Type__c;
            opp.AccountId=oppObj.AccountId;
            opp.Email__c=oppObj.Email__c;
            //opp.Account_Name__c=oppObj.Account_Name__c;
            if(oppObj.Leasing_Type__c=='Residential Units'){
                opp.RecordTypeId=oppRenewRecordType;
            }
            else{
                opp.RecordTypeId=oppCommRenewRcdTyp;
            }
            
            opp.Booking_Mode__c='Reservation without token amount';//oppObj.Booking_Mode__c;
            opp.OwnerId=UserInfo.getUserId();
            opp.Renewal__c=true;
            opp.No_Of_Cheques__c=noOfCheques;
            opp.Project__c=oppObj.Project__c;
             if(oppObj.Master_Opportunity__c != null){	
               opp.Master_Opportunity__c=oppObj.Master_Opportunity__c; 	
            }	
            else{	
                opp.Master_Opportunity__c=oppObj.id;	
            }
            opp.Opportunity__c=oppObj.Id;
            opp.Booking_Fee_gets_collected__c=true;//fr contract creation
            opp.Security_Deposit_Recevied__c=true;//fr contract creation
            opp.Ejari_Required__c=ejariNeeded;
            opp.Renewal_Type__c= renewalType;
            if(renewalType=='Full'){
                system.debug('Inside full');
                opp.Lease_Start_Date__c=renewalDate;
                opp.Lease_End_Date__c=renewalDate.addYears(1) - 1; //(opp.Lease_Start_Date__c).addYears(1) - 1;  
                renewalEndDate=opp.Lease_End_Date__c;
            }
            else if(renewalType=='Extension'){
                opp.Lease_Start_Date__c=renewalDate;
                opp.Lease_End_Date__c=renewalEndDate;
            }
            insert opp; 
        }
        catch(Exception e){
            System.debug('Error Line number>>>'+e.getLineNumber());
            System.debug('Error Message>>>'+e.getMessage());
        }
        return opp;
        
    }
    //Method to Generate Opportunity Name-  Hitesh
    public static String generateOpportunityName(list<Opportunity> recordNewList,String oldOppAccName){
        System.debug('Generate Opportunity Name@@@@@@@@@@@@@');
        set<String> oppId = new set<String>();
        String oppName;
        try{
            for(Opportunity opp:recordNewList){
                //if(opp.Account_Name__c!=null)
                    oppId.add(opp.Id);
            }
            List<Opportunity> oppsList =new List<Opportunity> ();
            List<Opportunity> oppList = [select id,RecordType.Name, Account_Name__c,Company_Name__c,
                                         Lease_Start_Date__c,Account.Name,(select unit__r.Unit_Code__c,id,opportunity__c from  Unit_Plans__r ORDER BY CreatedDate ASC) from Opportunity where Id IN:oppId];
            for(Opportunity op:oppList){
               // if(System.label.Leasing_RecordTypes.contains(op.RecordType.Name)){
                    if((op.Unit_Plans__r).size()>0 && (op.Unit_Plans__r).size()==1 && op.Unit_Plans__r[0].unit__r.Unit_Code__c!=null && op.Lease_Start_Date__c!=null){
                        system.debug('Single unit generateOpportunityName');
                        oppName = oldOppAccName +'-'+op.Unit_Plans__r[0].unit__r.Unit_Code__c+'-'+(op.Lease_Start_Date__c).year();
                        Opportunity opps= new Opportunity();
                        opps.Name = oppName;
                        opps.Id = op.Id;
                        oppsList.add(opps);
                    }
                    else if((op.Unit_Plans__r).size()>1 && op.Unit_Plans__r[0].unit__r.Unit_Code__c!=null && op.Lease_Start_Date__c!=null){
                        system.debug('Multi unit generateOpportunityName');
                        oppName = oldOppAccName +'-'+op.Unit_Plans__r[0].unit__r.Unit_Code__c+'-'+(op.Lease_Start_Date__c).year();          
                        Opportunity opps= new Opportunity();
                        opps.Name = oppName;
                        opps.Id = op.Id;
                        oppsList.add(opps);
                    }
                //}   
            }
            system.debug('oppsList>>>>>'+oppsList);
            return oppName;
        }
        catch(Exception e){
            
            System.debug('Error Line number generateOpportunityName>>>'+e.getLineNumber());
            System.debug('Error Message generateOpportunityName>>>'+e.getMessage());
            return null;
        }  
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
@CreatedDate: 05/03/2022
@ This method will create have the logic to create additional charges and installments
*/  
    @AuraEnabled
    public static void createInstallmentAndCharges(ParentWrapper parentWrapper,String noOfCheques,String paymentMode,Decimal pricePerSqft,Boolean ejariNeeded){
        List<Unit_Plan__c> unitPlanList = new List<Unit_Plan__c>();
        Map<String,Additional_Charges__c> masterChargesMap = new Map<String,Additional_Charges__c>();
        Map<String,Charges_Configuration__c> rentChargesMap = new Map<String,Charges_Configuration__c>();
        Map<String,Charges_Configuration__c> securityChargesMap = new Map<String,Charges_Configuration__c>();
        Map<String,List<Charges_Configuration__c>> additionalChargesMap = new Map<String,List<Charges_Configuration__c>>();
        Map<String, String> pickLabelApiMap = getPicklistValues('Payment_Milestone__c','Installment__c');
        List<Payment_Milestone__c> installmentList = new List<Payment_Milestone__c>();
        List<Opportunity_Charges__c> additionalChargesList = new List<Opportunity_Charges__c>();
        try{
            Installment_Configuration__mdt installmentMdt = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Termination_ID__c 
                                                             FROM Installment_Configuration__mdt 
                                                             WHERE MasterLabel =: noOfCheques];
            List<Installment_Line_Configuration__mdt> installmetLineList = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, 
                                                                            Installment_Configuration__c, Amount__c, Number_Of_Days__c,Installment_Name__c 
                                                                            FROM Installment_Line_Configuration__mdt
                                                                            WHERE Installment_Configuration__c =: installmentMdt.Id 
                                                                            ORDER BY Number_Of_Days__c ASC];
            // new charges implementation
            List<Additional_Charges__c> masterChargesList = [SELECT Id,name, Security_Deposit__c,  Project__c, Type__c, Amount__c, 
                                                             Default_Sales_Charge__c, Charge_Type__c, Amount_Leasing__c, Fixed_Amount__c, Space_Type__c, Required__c, 
                                                             Transaction_Type__c, Type_Leasing__c, Sub_Type__c, Applicable_for_renewal__c, Active__c, Payment_Purpose_Code__c, 
                                                             Payment_Term_Type_Code__c, Invoicing_Rule__c, Accounting_Rule__c, Frequency__c, Tax_Configuration__c,leasing_type__c,
                                                             Tax_Configuration__r.Tax_Rate__c,Amount_On__c
                                                             FROM Additional_Charges__c 
                                                             WHERE Project__c =:parentWrapper.oppObj.project__c 
                                                             and Required__c= true and Applicable_for_renewal__c=true];
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
                tempInstallmentList = createInstallments(parentWrapper,iObj,masterChargesMap,paymentMode,installmetLineList,pickLabelApiMap);
                installmentList.addAll(tempInstallmentList);
                system.debug('installmentList>>>>'+installmentList.size());
                List<Opportunity_Charges__c> tempAdditionalChargesList = new List<Opportunity_Charges__c>();
                tempAdditionalChargesList = createAdditionalCharges(parentWrapper,iObj,masterChargesMap.values(),paymentMode,ejariNeeded);
                additionalChargesList.addAll(tempAdditionalChargesList);
                system.debug('addchargesList-->'+additionalChargesList);
                Unit_Plan__c unitPlan = new Unit_Plan__c(id = iObj.oppUnitId);
                unitPlan.Base_Lease_Amount__c  = iObj.baseLeaseAmount;
                unitPlan.Discount__c = iObj.discount;
                unitPlan.Discount_Amount__c = iObj.discountAmount;
                system.debug('iObj.unitId>>>>>'+iObj.unitId);
                unitPlan.Unit__c=iObj.unitId;
                unitPlan.Final_Lease_Amount__c = iObj.finalLeaseAmount;
                unitPlan.Security_Deposit__c = iObj.deposit;
                unitPlan.payment_mode__c = paymentMode;
                unitPlan.No_Of_Cheques__c  = Integer.valueOf(noOfCheques);
                if(pricePerSqft != null && pricePerSqft !=0){
                    unitPlan.price_per_sqft__c = pricePerSqft;
                }else{
                    unitPlan.price_per_sqft__c = iObj.pricePerSqft;
                }
                unitPlan.Proposed_price_per_sqft__c  = pricePerSqft;
                system.debug('Unit_Status__c >>>>'+unitPlan.Unit_Status__c);
                unitPlanList.add(unitPlan);
            }
            if(installmentList.size() > 0){
                insert installmentList;
            }
            system.debug('additionalChargesList'+additionalChargesList);
            if(additionalChargesList.size() > 0){
                system.debug('additionalChargesList insert');
                insert additionalChargesList;
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
            //update opp;
        }
        catch(Exception e){
            System.debug('Error Line number>>>'+e.getLineNumber());
            System.debug('Error Message>>>'+e.getMessage());
        }
    }
    
    /*
@Author : Swapnil Mohite
@CreatedDate: 05/03/2022
@ This method will create the installments
*/
    @AuraEnabled
    /*public static List<Payment_Milestone__c> createInstallments(ParentWrapper parentWrapper,InstallmentWrapper iObj,Map<String,Charges_Configuration__c> rentChargesMap,Map<String,Charges_Configuration__c> securityChargesMap,
Map<String,List<Charges_Configuration__c>> additionalChargesMap,String paymentMode, List<Installment_Line_Configuration__mdt> installmetLineList){*/
    public static List<Payment_Milestone__c> createInstallments(ParentWrapper parentWrapper,InstallmentWrapper iObj,Map<String,Additional_Charges__c> masterChargesMap,String paymentMode, 
                                                                List<Installment_Line_Configuration__mdt> installmetLineList,Map<String,String> pickLabelApiMap){
                                                                    Integer i = 0;
                                                                    List<Payment_Milestone__c> installmentList = new List<Payment_Milestone__c>();
                                                                    
                                                                    // code for sec deposit
                                                                    if(iObj.isNewUnit == true){
                                                                    Payment_Milestone__c secInstallment = new Payment_Milestone__c();
                                                                    secInstallment.name = 'Security Deposit';
                                                                    secInstallment.Installment_No__c = 0;
                                                                    secInstallment.Due_Date__c = parentWrapper.oppObj.Lease_Start_Date__c;
                                                                    secInstallment.Installment__c = 'SEC';
                                                                    secInstallment.Opportunity__c = parentWrapper.oppObj.Id;
                                                                    secInstallment.Unit_Plan__c = iObj.oppUnitId;
                                                                    secInstallment.payment_mode__c = paymentMode;
                                                                    secInstallment.Amount__c = iObj.deposit; 
                                                                    secInstallment.Unit__c = iObj.unitId;
                                                                    if(masterChargesMap.containsKey('Security Deposit') && masterChargesMap.get('Security Deposit').Tax_Configuration__r.Tax_Rate__c !=0){                
                                                                        secInstallment.Payable_Amount__c = (iObj.deposit + ((masterChargesMap.get('Security Deposit').Tax_Configuration__r.Tax_Rate__c/100) * iObj.deposit)).setScale(2);// to be calculated with vat
                                                                    }else{
                                                                        secInstallment.Payable_Amount__c  = iObj.deposit;
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
                                                                    }
                                                                    //
                                                                    Map<String,String> mapInstallmentName=new Map<String,String>();
                                                                    Schema.DescribeFieldResult objFieldDescribe = Payment_Milestone__c.Installment__c.getDescribe();
                                                                    List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
                                                                    for (Schema.PicklistEntry objPickList : lstPickListValues) {
                                                                        mapInstallmentName.put(objPickList.getValue(),objPickList.getLabel());
                                                                    }
                                                                    Integer daysToAdd = 0; // used for change of unit
                                                                    Date startDate = parentWrapper.oppObj.Lease_Start_Date__c;
                                                                    for(Installment_Line_Configuration__mdt insLineObj : installmetLineList){
                                                                        Payment_Milestone__c installment = new Payment_Milestone__c();
                                                                        installment.name = pickLabelApiMap.get(insLineObj.Installment_Name__c);                                                                        
                                                                        installment.Installment_No__c = i;
                                                                        if(parentWrapper.renewalType == 'Extension'){
                                                                            installment.Due_Date__c = startDate;
                                                                            daysToAdd = ((parentWrapper.oppObj.Lease_Start_Date__c).daysBetween(Date.valueOf(parentWrapper.oppObj.Lease_End_Date__c)))/installmetLineList.size();
                                                                            startDate = startDate.addDays(daysToAdd);
                                                                        }else{
                                                                            installment.Due_Date__c = parentWrapper.oppObj.Lease_Start_Date__c.addDays(Integer.valueOf(insLineObj.Number_Of_Days__c));
                                                                        }
                                                                        installment.Installment__c = insLineObj.Installment_Name__c;
                                                                        installment.Opportunity__c = parentWrapper.oppObj.Id;
                                                                        installment.Unit_Plan__c = iObj.oppUnitId;
                                                                        installment.payment_mode__c = paymentMode;
                                                                        installment.Amount__c = ((insLineObj.Amount__c/100) * iObj.finalLeaseAmount).setScale(2);
                                                                       installment.unit__c = iObj.unitId;
                                                                        if(masterChargesMap.containsKey('Rent') && masterChargesMap.get('Rent').Tax_Configuration__r.Tax_Rate__c !=0){                
                                                                            installment.Payable_Amount__c = (installment.Amount__c + ((masterChargesMap.get('Rent').Tax_Configuration__r.Tax_Rate__c/100) * installment.Amount__c)).setScale(2);// to be calculated with vat
                                                                        }else{
                                                                            installment.Payable_Amount__c  = installment.Amount__c;
                                                                        }
                                                                        if(masterChargesMap.containsKey('Rent')){
                                                                            installment.master_additional_charges__c = masterChargesMap.get('Rent').Id;
                                                                        }
                                                                        if(aggrMilestoneMap.containsKey(installment.name)){
                                                                            Aggregated_Milestone__c aggr = aggrMilestoneMap.get(installment.name);
                                                                            aggr.Amount__c = aggr.Amount__c + installment.Amount__c;
                                                                            
                                                                        }else{
                                                                            Aggregated_Milestone__c aggr = createAggregatedMilestones(installment,null,false,pickLabelApiMap,null);
                                                                            aggrMilestoneMap.put(installment.name,aggr);
                                                                        }
                                                                        installmentList.add(installment);
                                                                        i++;
                                                                    }
                                                                    return installmentList;
                                                                }
    /*
@Author : hitesh saini
@CreatedDate: 24/03/2022‸‸
@ This method will calculate additional charges
*/  
    @AuraEnabled
    public static List<Opportunity_Charges__c> createAdditionalCharges(ParentWrapper parentWrapper,InstallmentWrapper iObj,List<Additional_Charges__c> masterList,String paymentMode,Boolean ejariNeeded){
        List<Opportunity_Charges__c> additionalChargesList = new List<Opportunity_Charges__c>();
        if(masterList.size() > 0){
            for(Additional_Charges__c charges: masterList){
                if(charges.Type_Leasing__c == 'Charges' && (charges.name != 'Leasing Commission' || 
                       (charges.name == 'Leasing Commission' && iObj.isNewUnit == true))){
                    Opportunity_Charges__c  addCharges = new Opportunity_Charges__c ();
                    addCharges.name = charges.name;
                    addCharges.Opportunity__c = parentWrapper.oppObj.Id;
                    addCharges.Unit__c = iObj.unitId;
                    addCharges.Due_Date__c = parentWrapper.oppObj.lease_Start_date__c;
                    if(charges.Fixed_Amount__c !=0 && charges.Fixed_Amount__c != null){
                        addCharges.Amount__c = charges.Fixed_Amount__c;
                    }else if(charges.Amount_Leasing__c !=0 && charges.Amount_Leasing__c  != null){
                         if(charges.Amount_On__c == 'Base Rent'){
                            addCharges.Amount__c = iObj.baseLeaseAmount * (charges.Amount_Leasing__c /100).setScale(2);
                        }else if(charges.Amount_On__c == 'Current Rent'){ 
                          addCharges.Amount__c = iObj.finalLeaseAmount * (charges.Amount_Leasing__c /100).setScale(2);
                        }
                    }else{
                        addCharges.Amount__c = 0;
                    }
                    addCharges.master_Additional_charges__c  = charges.Id;
                    if(addCharges.Amount__c != 0){
                        if(charges.Tax_Configuration__r.Tax_Rate__c != 0){
                            addCharges.Payable_Amount__c = (addCharges.Amount__c + (addCharges.Amount__c * (charges.Tax_Configuration__r.Tax_Rate__c)/100)).setScale(2);
                        }else{
                            addCharges.Payable_Amount__c = addCharges.Amount__c;
                        }
                        if( ejariNeeded ==false && !System.Label.ExcludeEjariNotRequiredAddCharges.contains(addCharges.Name)  /*&& addCharges.Name != 'Ejari'*/){//If ejari not needed the creat other additional charges
                            additionalChargesList.add(addCharges);
                        }
                        else if( ejariNeeded ==true){//if ejari needed then create all the additional charges
                            additionalChargesList.add(addCharges);
                        }
                        //ditionalChargesList.add(addCharges);commented as part of Ejari required checkbox
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
        }
        return additionalChargesList;
    }
    /*
@Author : Swapnil Mohite
@CreatedDate: 20/02/2022
@ This method is to fetch picklist values
*/ 
    @AuraEnabled 
    public static Aggregated_Milestone__c createAggregatedMilestones(Payment_Milestone__c installment,Opportunity_Charges__c charges,Boolean isCharges,Map<String,String> pickLabelApiMap,string paymentTermType){
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
        } 
        return aggrObj;
    }
    //Method to get parentWrapper - Hitesh
    @AuraEnabled
    public static ParentWrapper getOppUnits(Opportunity opp,String renewalType,Integer leaseDuration){
        
        Set<String> spaceTypeIdSet = new Set<String>();
        Set<String> unitTypeSet = new Set<String>();
        Set<Id> unitIds = new Set<Id>();
        Map<Id,Availabe_Payment_Plan__c> spaceTypeAppMap = new Map<Id,Availabe_Payment_Plan__c>(); // space type and available payment plan map
        ParentWrapper parentWrapper = new ParentWrapper();
            List<Unit_Plan__c> unitPlanList = [SELECT Id,Unit__c,Base_Rent__c,Unit__r.Unit_Code__c,unit__r.Unit_Leasing_Type__r.name,unit__r.Total_Leasable_Area__c,unit__r.Unit_Leasing_Type__c,
                                               unit__r.unit_type__c,unit__r.Discount__c,unit__r.Security_Deposit__c,unit__r.Base_Rent__c,Price_per_sqft__c,base_lease_amount__c,
                                               unit__r.Price_Per_SQ_FT__c,unit__r.Markup_Rent__c,unit__r.Renewal_Rent__c,unit__r.Leasing_Property_Type__c,Renewal_new_unit__c
                                               FROM Unit_Plan__c 
                                               WHERE Opportunity__c =: opp.Id];
            
            system.debug('unitPlanList size->>>>'+unitPlanList.size());
            system.debug('spacetype->'+spaceTypeAppMap);
            decimal totalDepositAmount = 0;
            decimal TotalBaseLeaseAmount = 0;
            List<InstallmentWrapper> installList = new List<InstallmentWrapper>();
            for(Unit_Plan__c unitPlan : unitPlanList){
                //for vat and additional charges - 
                system.debug('spacetype leasing->'+unitPlan.unit__r.Unit_Leasing_Type__c);
                system.debug('type leasing->'+unitPlan.unit__r.Leasing_Property_Type__c);
                
                spaceTypeIdSet.add(unitPlan.unit__r.Unit_Leasing_Type__c);
                unitTypeSet.add(unitPlan.unit__r.Leasing_Property_Type__c);//unitTypeSet.add(unitPlan.unit__r.unit_type__c);
                //
                InstallmentWrapper installmentWrapper = new InstallmentWrapper();
                installmentWrapper.spaceTypeId = unitPlan.unit__r.Unit_Leasing_Type__c;
                installmentWrapper.unitType = unitPlan.unit__r.Leasing_Property_Type__c;
                installmentWrapper.oppUnitId = unitPlan.Id;
                installmentWrapper.spaceType = unitPlan.unit__r.Unit_Leasing_Type__r.name;
                installmentWrapper.unitCode = String.valueOf(unitPlan.unit__r.Unit_Code__c);
                installmentWrapper.totalLeasableArea = unitPlan.unit__r.Total_Leasable_Area__c;
                installmentWrapper.unitId = unitPlan.Unit__c;
                InstallmentWrapper.isNewUnit = unitPlan.Renewal_new_unit__c;
                installmentWrapper.pricePerSqft = unitPlan.Price_per_sqft__c;
                installmentWrapper.deposit = unitPlan.unit__r.Security_Deposit__c  == null ? 0 :  unitPlan.unit__r.Security_Deposit__c;
                if(opp.Leasing_Type__c == 'Residential Units'){ 
                     if(renewalType=='Full'){
                        installmentWrapper.baseLeaseAmount = unitPlan.base_lease_amount__c == null ? 0 :  unitPlan.base_lease_amount__c;
                        installmentWrapper.finalLeaseAmount = unitPlan.base_lease_amount__c == null ? 0 :  unitPlan.base_lease_amount__c;
                    }
                    else{
                        installmentWrapper.baseLeaseAmount = unitPlan.base_lease_amount__c == null ? 0 :  (unitPlan.base_lease_amount__c*leaseDuration/365).setScale(2);
                        installmentWrapper.finalLeaseAmount = unitPlan.base_lease_amount__c == null ? 0 :  (unitPlan.base_lease_amount__c*leaseDuration/365).setScale(2);                        
                    }
                }else if(opp.Leasing_Type__c == 'Commercial Units'){
                    system.debug('opp leasing type >> Commercial Units');
                     if(renewalType=='Full'){
                        installmentWrapper.baseLeaseAmount = unitPlan.base_lease_amount__c == null ? 0 :  unitPlan.base_lease_amount__c;
                        installmentWrapper.finalLeaseAmount = unitPlan.base_lease_amount__c == null ? 0 :  unitPlan.base_lease_amount__c;
                    }
                    else{
                        installmentWrapper.baseLeaseAmount = unitPlan.base_lease_amount__c == null ? 0 :  (unitPlan.base_lease_amount__c*leaseDuration/365).setScale(2);
                        installmentWrapper.finalLeaseAmount = unitPlan.base_lease_amount__c == null ? 0 :  (unitPlan.base_lease_amount__c*leaseDuration/365).setScale(2);                        
                    }
                }
                // additional charges
                installList.add(installmentWrapper);
            }
            parentWrapper.installWrapperList = installList;
            parentWrapper.oppObj = opp;
            parentWrapper.renewalType = renewalType;
        return parentWrapper;
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
        public String renewalType{get;set;}
        
    } 
    public Class InstallmentWrapper {
        @AuraEnabled 
        public Boolean isNewUnit{get;set;}
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
    }
    
}