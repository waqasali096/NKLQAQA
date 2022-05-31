/**
* @author : Ashams
* @createdDate : 08-Mar-2022
* @purpose : Used in Quick Booking Process - Sales
* @usage : controller foaccountr UnitDetails Component - 
           shows special pffers, floor plans, payment plan details
*/
public class UnitDetailsController {
    @AuraEnabled(cacheable=true)
    public static ResultWrapper fetchUnitDetails(String recordId, String oppId, string compName){
        ResultWrapper wrap = new ResultWrapper();
        List<milestones> milesStoneList = new List<milestones>();
        List<Special_Offer__c> specialOffers = new List<Special_Offer__c>();
        List<Id> specialOffersId = new List<Id>();
        List<String> floorPlanUrls = new List<String>();
        List<String> unitPlanUrls = new List<String>();
        List<Additional_Charges__c> additionalCharges = new List<Additional_Charges__c>();
        List<additionalCharges> additionalCharge = new List<additionalCharges>();
        List<Master_Payment_Milestone__c> masterMilestones = new List<Master_Payment_Milestone__c>();
        List<Payment_Milestone__c> paymentMilestones = new List<Payment_Milestone__c>();
        Map<Id,Special_Offer_Item__c> unitSpecialOfferMap = new Map<Id,Special_Offer_Item__c>();
        Date startDate = System.today();
        Integer dueDates;
        Decimal specialOfferDLDcharges;
        unit__c unit = new unit__c();
        system.debug('recordId'+recordId);
        if(string.isNotBlank(recordId)){
            unit = [Select Id,name,Master_Payment_Plan__c,unit_status__c,Unit_Prebooked__c,selling_price__c,Unit_Purpose__c,Project__c,DLD_Customer_Share__c
                    from unit__c  where id=:recordId];
            if(compName == 'salesEventTab'){
                masterMilestones = [Select id, name,Amount_Percentage__c, Due_In_Days__c,Installment__c,Installment_No__c,Master_Payment_Plan__c 
                                     from Master_Payment_Milestone__c where Master_Payment_Plan__c =:unit.Master_Payment_Plan__c order by Installment_No__c]; 
            }else if(unit.Master_Payment_Plan__c!=null && unit.unit_status__c == 'Available' && unit.Unit_Prebooked__c == FALSE){
                masterMilestones = [Select id, name,Amount_Percentage__c, Due_In_Days__c,Installment__c,Installment_No__c,Master_Payment_Plan__c 
                                     from Master_Payment_Milestone__c where Master_Payment_Plan__c =:unit.Master_Payment_Plan__c order by Installment_No__c]; 
            }else if(unit.Master_Payment_Plan__c!=null && (unit.unit_status__c != 'Available' || unit.Unit_Prebooked__c == TRUE)){
                List<Opportunity> salesOpp = [Select id, name from Opportunity where Unit__c =: unit.id and Opportunity__c=:oppId];
                system.debug('salesOpp'+salesOpp);
                if(!salesOpp.isEmpty()){
                    paymentMilestones =  [Select id, name,Amount_Percentage__c, Due_Date__c,Installment__c,Installment_No__c,Amount__c 
                                          from Payment_Milestone__c where Opportunity__c =: salesOpp[0].Id order by Installment_No__c];
                }
            }
            system.debug('masterMilestones'+masterMilestones);
            system.debug('paymentMilestones'+paymentMilestones);
            if(!masterMilestones.isEmpty()){
                for(Master_Payment_Milestone__c ms:masterMilestones){
                    milestones milesStn = new milestones();
                    milesStn.milestoneName = ms.Name;
                    milesStn.milestonePercentage = ms.Amount_Percentage__c/100;
                    milesStn.milestoneAmount = (unit.selling_price__c * ms.Amount_Percentage__c)/100;
                    milesStn.milestoneDate = startDate.addDays(Integer.valueof(ms.Due_In_Days__c));
                    milesStoneList.add(milesStn);
                    startDate = startDate.addDays(Integer.valueof(ms.Due_In_Days__c));
                }
            }
            else if(!paymentMilestones.isEmpty()){
                for(Payment_Milestone__c ms:paymentMilestones){
                    milestones milesStn = new milestones();
                    milesStn.milestoneName = ms.Name;
                    milesStn.milestonePercentage = ms.Amount_Percentage__c/100;
                    milesStn.milestoneAmount = ms.Amount__c;
                    milesStn.milestoneDate = ms.Due_Date__c;
                    milesStoneList.add(milesStn);
                }
            }
            system.debug('milesStoneList'+milesStoneList);
            List<Special_Offer_Item__c> specialOfferItems = [SELECT Id,Special_Offer__r.name,Special_Offer__r.Type__c,Special_Offer__c, 
                                                             Special_Offer__r.Start_Date__c, Special_Offer__r.End_Date__c 
                                                             from Special_Offer_Item__c 
                                                             where Unit__c =:recordId];
            system.debug('specialOfferItems'+specialOfferItems);
            if(specialOfferItems.size()>0){
                for(Special_Offer_Item__c item:specialOfferItems){
                    specialOffersId.add(item.Special_Offer__c);
                }
            }
            system.debug('specialOffersId'+specialOffersId);
            if(specialOffersId.size()>0){
                specialOffers = [SELECT Id,Name,Type__c,Start_Date__c,End_Date__c,Active__c
                                 from Special_Offer__c 
                                 where Id IN:specialOffersId AND Active__c = true AND (start_date__c < TODAY AND end_date__c > TODAY)];
            }
            additionalCharges = [Select Id,Name,Type__c,Tax_Configuration__r.Tax_Rate__c
                                 from Additional_Charges__c 
                                 where Default_Sales_Charge__c = true 
                                 AND Type__c =:'Sales' AND Charge_Type__c=:'DLD_FEE' AND Project__c =: unit.Project__c];
            unitSpecialOfferMap = SpecialOfferController.getActiveDLDOffers(new Set<Id>{recordId});
            if(unitSpecialOfferMap.size()>0){
                specialOfferDLDcharges = unitSpecialOfferMap.get(recordId).Special_Offer__r.DLD_Share__c;
            }
            floorPlanUrls = ImageQueryController.retriveFloorImages(recordId);
            unitPlanUrls = ImageQueryController.retriveUnitImages(recordId);
            system.debug('floorPlanUrls'+floorPlanUrls);
            system.debug('additionalCharges'+additionalCharges);
        }
        system.debug('specialOffers'+specialOffers);
        if(!additionalCharges.isEmpty()){
            for(Additional_Charges__c charges:additionalCharges){
                additionalCharges adCharge = new additionalCharges();
                adCharge.chargeName = charges.Name; 
                if(specialOfferDLDcharges!=null){
                    adCharge.chargePercentage = specialOfferDLDcharges/100;
                    if(unit.Selling_Price__c!=null){
                        adCharge.chargeAmount = (specialOfferDLDcharges/100) * unit.Selling_Price__c;
                    }
                }else if(unit.DLD_Customer_Share__c!=null){
                    adCharge.chargePercentage = unit.DLD_Customer_Share__c/100;
                    if(unit.Selling_Price__c!=null){
                        adCharge.chargeAmount = (unit.DLD_Customer_Share__c/100) * unit.Selling_Price__c;
                    }
                }
                adCharge.chargeVatPercentage = charges.Tax_Configuration__r.Tax_Rate__c/100;
                adCharge.chargeVatAmount = (charges.Tax_Configuration__r.Tax_Rate__c/100) * adCharge.chargeAmount;
                adCharge.chargeTotalAmount = adCharge.chargeVatAmount + adCharge.chargeAmount; 
                additionalCharge.add(adCharge);                
            }
            wrap.additionalCharges = additionalCharge; 
        }
        if(floorPlanUrls!=null){
          wrap.floorPlanUrls = floorPlanUrls;
        }
        if(unitPlanUrls!=null){
          wrap.unitPlanUrls = unitPlanUrls;
        }
        if(!specialOffers.isEmpty()){
           wrap.specialOffers = specialOffers;
        }
        if(!milesStoneList.isEmpty()){
            wrap.milestonesList = milesStoneList;
        }
        return wrap;
    }
    public class ResultWrapper{
        @AuraEnabled public Boolean floorPlanExist;
        @AuraEnabled public List<String> floorPlanUrls;
        @AuraEnabled public List<String> unitPlanUrls;
        @AuraEnabled public List<Special_Offer__c> specialOffers;
        @AuraEnabled public List<milestones> milestonesList;
        @AuraEnabled public List<additionalCharges> additionalCharges;
    }
    public class additionalCharges{
         @AuraEnabled public String chargeName; 
         @AuraEnabled public Decimal chargePercentage; 
         @AuraEnabled public Decimal chargeAmount; 
         @AuraEnabled public Decimal chargeVatPercentage;
         @AuraEnabled public Decimal chargeVatAmount;
         @AuraEnabled public Decimal chargeTotalAmount; 
    }
    public class milestones{
         @AuraEnabled public String milestoneName; 
         @AuraEnabled public Decimal milestonePercentage; 
         @AuraEnabled public Decimal milestoneAmount; 
         @AuraEnabled public Date milestoneDate; 
    }
}