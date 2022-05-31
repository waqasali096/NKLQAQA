/**
* @author : Ashams
* @createdDate : 07-Apr-202w
* @lastModifieddate : 
* @purpose : Sales
* @usage : Trigger handler for OfferApplied. 
*/
public class OfferAppliedTriggerHandler {
	public void BeforeInsertEvent(List<Offer_Applied__c> newOfferList, Map<Id, Offer_Applied__c> recordNewMap){

    }
    
    public void AfterInsertEvent(List<Offer_Applied__c> newOfferList, Map<Id, Offer_Applied__c> recordOldMap, Map<Id, Offer_Applied__c> recordNewMap){
        MAP<Id,Id> OfferIdOppIdMap = new MAP<Id,Id>();
        Set<Id> oppIds = new Set<Id>();
        MAP<Id,Special_offer__c> OppIdOfferMap = new MAP<Id,Special_offer__c>();
        MAP<Id,Opportunity> offerIdOpportunityMap = new MAP<Id,Opportunity>();
        
        if(!newOfferList.isEmpty()){
            for(Offer_Applied__c offerApplied : newOfferList){
                if(offerApplied.Special_Offer__c != null){
                    OfferIdOppIdMap.put(offerApplied.Special_Offer__c,offerApplied.Opportunity__c);
                    oppIds.add(offerApplied.Opportunity__c);
                }
            } 
        }
        if(oppIds.size()>0){
            Map<Id,Opportunity> opportunityIdMap = new Map<Id,Opportunity>([Select Id,name,DLD_Customer_Share__c,DLD_Nakheel_Share__c,
                                                                           DLD_Paid__c,DLD_Waiver__c,DLD_Waiver_Reason__c,Single_Payment_Plan_Selected__c,
                                                                           Exception_Discount__c,Exception_Discount_Amount__c,Net_Selling_Price__c 
                                                                           from Opportunity where Id IN:oppIds]);
            if(opportunityIdMap.size()>0){
                for(Offer_Applied__c offerApplied : newOfferList){
                    if(opportunityIdMap.get(offerApplied.Opportunity__c)!=null){
                        offerIdOpportunityMap.put(offerApplied.Special_Offer__c,opportunityIdMap.get(offerApplied.Opportunity__c));
                    }
                }
            }
            if(offerIdOpportunityMap.size()>0){
                OfferApplyActions(offerIdOpportunityMap,OfferIdOppIdMap,'Insert',null);
            }
        }
        
    }
    
    public void BeforeUpdateEvent(List<Offer_Applied__c> newOfferList,Map<Id, Offer_Applied__c> recordOldMap,Map<Id, Offer_Applied__c> recordNewMap){
        
    }
    
    public void AfterUpdateEvent(List<Offer_Applied__c> newOfferList,Map<Id, Offer_Applied__c> recordOldMap,Map<Id, Offer_Applied__c> recordNewMap){
        
    }
    
    public void BeforeDeleteEvent(List<Offer_Applied__c> newOfferList,Map<Id, Offer_Applied__c> recordNewMap){
        
    }
    
    public void AfterDeleteEvent(List<Offer_Applied__c> oldOfferList,Map<Id, Offer_Applied__c> recordOldMap,Map<Id, Offer_Applied__c> recordNewMap){
        MAP<Id,Id> OfferIdOppIdMap = new MAP<Id,Id>();
        MAP<Id,Special_offer__c> OppIdOfferMap = new MAP<Id,Special_offer__c>();
        
        if(!oldOfferList.isEmpty()){
            for(Offer_Applied__c offerApplied : oldOfferList){
                if(offerApplied.Special_Offer__c != null){
                    OfferIdOppIdMap.put(offerApplied.Special_Offer__c,offerApplied.Opportunity__c);
                }
            } 
        }
        if(OfferIdOppIdMap.size()>0){
            Map<ID,Opportunity> oppMap = new Map<ID,Opportunity>([Select Id,unit__c,unit__r.Master_payment_plan__c, unit__r.DLD_Customer_Share__c from Opportunity where ID IN:OfferIdOppIdMap.values()]);
            OfferApplyActions(null,OfferIdOppIdMap,'Delete',oppMap);
        }
    }
    
    //Method to apply offer applied changes to Opportunity level based on special offer type
    public static void OfferApplyActions(MAP<Id,Opportunity> offerIdOpportunityMap,MAP<Id,Id> OfferIdOppIdMap,String action,MAP<Id,Opportunity> oppMap){
        List<Opportunity> OpportunityList = new List<Opportunity>();
        Set<Id> setOpptyIds = new Set<Id>();
        List<Opportunity_Charges__c> dldChargeList = new List<Opportunity_Charges__c>();
        List<Opportunity_Charges__c> dldChargeListtoUpdate = new List<Opportunity_Charges__c>();
        
        if(OfferIdOppIdMap.size()>0){
            List<Special_offer__c> specialOfferList = [Select Id,Type__c,DLD_Share__c,Master_Payment_Plan__c,Discount__c from Special_offer__c where Id IN:OfferIdOppIdMap.keyset()]; 
            if(!specialOfferList.isEmpty()){
                for(Special_Offer__c sp : specialOfferList){
                    Opportunity Opp = new Opportunity();
                    Opp.Id = OfferIdOppIdMap.get(sp.Id);
                    if(action == 'Insert'){
                        if(sp.Type__c == 'DLD Share'){
                            Opp.DLD_Customer_Share__c = sp.DLD_Share__c;
                            Opp.DLD_Paid__c = TRUE;
                            Opp.DLD_Waiver__c = TRUE;
                            //Opp.DLD_Waiver_Reason__c = 'Special Offer';
                            setOpptyIds.add(Opp.Id);
                        }else if(sp.Type__c == 'Single Payment Plan' || sp.Type__c == 'Special Payment Plan'){
                            Opp.Master_Payment_Plan__c = sp.Master_Payment_Plan__c;
                            if(sp.Type__c == 'Special Payment Plan'){
                                Opp.Special_Payment_Plan_Applied__c = TRUE;
                            }
                            if(sp.Type__c == 'Single Payment Plan'){
                                Opp.Single_Payment_Plan_Selected__c = TRUE; 
                                Opp.Exception_Discount__c = sp.Discount__c;
                                system.debug('Opp.Net_Selling_Price__c'+offerIdOpportunityMap.get(sp.Id).Net_Selling_Price__c);
                                Opp.Exception_Discount_Amount__c = (sp.Discount__c * (offerIdOpportunityMap.get(sp.Id).Net_Selling_Price__c))/100;
                            }
                        } 
                    }else if(action == 'Delete'){
                        if(sp.Type__c == 'DLD Share'){
                            Opp.DLD_Customer_Share__c = oppMap.get(OfferIdOppIdMap.get(sp.Id)).unit__r.DLD_Customer_Share__c;
                            Opp.DLD_Paid__c = FALSE;
                            Opp.DLD_Waiver__c = FALSE;
                            Opp.DLD_Waiver_Reason__c = null;
                        }else if(sp.Type__c == 'Single Payment Plan' || sp.Type__c == 'Special Payment Plan'){
                            Opp.Master_Payment_Plan__c = oppMap.get(OfferIdOppIdMap.get(sp.Id)).unit__r.Master_payment_plan__c;
                            if(sp.Type__c == 'Special Payment Plan'){
                                Opp.Special_Payment_Plan_Applied__c = FALSE;
                            }
                            if(sp.Type__c == 'Single Payment Plan'){
                                Opp.Single_Payment_Plan_Selected__c = FALSE; 
                                Opp.Exception_Discount__c = null;
                                Opp.Exception_Discount_Amount__c = null;
                            }
                        } 
                    }
                    OpportunityList.add(Opp);
                }
            }
        }  
        system.debug('%%OpportunityList'+OpportunityList);
        try{
            if(OpportunityList.size()>0){
                update OpportunityList; 
            } 
            system.debug('**setOpptyIds'+setOpptyIds);
            if(!setOpptyIds.isEmpty()){
                dldChargeList = [SELECT Id,Amount__c,Opportunity__r.DLD_Customer_Share__c,Opportunity__r.Unit__r.Selling_Price__c from Opportunity_Charges__c where Opportunity__c IN: setOpptyIds AND 
                                 Master_Additional_Charges__r.Type__c  ='Sales' AND Master_Additional_Charges__r.Charge_Type__c ='DLD_FEE' ];
                if(!dldChargeList.isEmpty()){
                    for(Opportunity_Charges__c charge:dldChargeList){
                        charge.Amount__c = (charge.Opportunity__r.DLD_Customer_Share__c/100) * charge.Opportunity__r.Unit__r.Selling_Price__c;
                        dldChargeListtoUpdate.add(charge);
                    } 
                }
                if(!dldChargeListtoUpdate.isEmpty()){
                    update dldChargeListtoUpdate;
                }
            }
            system.debug('**dldChargeList'+dldChargeList);
            system.debug('**dldChargeListtoUpdate'+dldChargeListtoUpdate);
        }catch(Exception e){
            system.debug('Offer Exp'+e.getMessage()+e.getLineNumber());
        }
        
    }
}