/**
 * @description       : this class is ceated for "UploadPriceBookEntry" LWC Controller
 * @author            : Husain Sayyed
 * @group             : 
 * @last modified on  : 05-16-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class UploadPriceBookEntryController {
    @AuraEnabled
    public static list<string> checkExistingPriceBookEntries(string priceBookId, list<string> unitCodeSet) {
        list<string> unitIdSet = new list<string>();

        for(PriceBook_Entry__c priceBookEntry : [SELECT Id, Unit_Code__c,Price__c, Unit__c,Price_Book__c 
                                                    from PriceBook_Entry__c 
                                                    where Price_Book__c =: priceBookId AND Unit_Code__c in : unitCodeSet]){
            unitIdSet.add(priceBookEntry.Unit_Code__c);
        }

        return unitIdSet;
    }
}