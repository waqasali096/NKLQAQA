/*
Class Name:                 SpecialOfferTriggerController
Class Description:          Controller to handle operations for Special Offers
Author:                     Swapnil Mohite
Created Date:               1/20/2022
Updated by:
Last Update Date:
*/
public class SpecialOfferController {
    public static Map<Id,special_offer_Item__c> getSpecialOffers(Set<Id> unitIds){
        Map<Id,Special_Offer_Item__c> unitSpecialOfferMap = new Map<Id,Special_Offer_Item__c>();
        List<special_offer_Item__c> specialOfferList = [SELECT id,name,special_offer__c,unit__c,special_offer__r.type__c,special_offer__r.master_payment_plan__c
                                                        FROM special_offer_Item__c 
                                                        WHERE unit__c IN: unitIds AND special_offer__r.Active__c  = true
                                                        AND (special_offer__r.start_date__c < TODAY AND special_offer__r.end_date__c > TODAY)];
        for(special_offer_Item__c spcOfferItem : specialOfferList){
            unitSpecialOfferMap.put(spcOfferItem.unit__c,spcOfferItem);
            system.debug(unitSpecialOfferMap);
        }
        //asdasd
        return unitSpecialOfferMap;
    }
    //Added by ashams to get lastest added active DLD offer - used in OpportunitytriggerHandler
    public static Map<Id,special_offer_Item__c> getActiveDLDOffers(Set<Id> unitIds){
        Map<Id,Special_Offer_Item__c> unitSpecialOfferMap = new Map<Id,Special_Offer_Item__c>();
        List<special_offer_Item__c> specialOfferList = [SELECT id,name,special_offer__c,unit__c,special_offer__r.type__c,special_offer__r.master_payment_plan__c,special_offer__r.DLD_Share__c
                                                        FROM special_offer_Item__c 
                                                        WHERE unit__c IN: unitIds AND special_offer__r.Active__c  = true AND special_offer__r.Type__c  = 'DLD Share'
                                                        AND (special_offer__r.start_date__c < TODAY AND special_offer__r.end_date__c > TODAY) 
                                                        ORDER BY CREATEDDATE DESC LIMIT 1];
        for(special_offer_Item__c spcOfferItem : specialOfferList){
            unitSpecialOfferMap.put(spcOfferItem.unit__c,spcOfferItem);
            system.debug('DLD Special offer'+unitSpecialOfferMap);
        }
        return unitSpecialOfferMap;
    }   
}