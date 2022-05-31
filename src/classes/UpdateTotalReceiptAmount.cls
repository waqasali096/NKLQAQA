/*
*Name: UpdateTotalReceiptAmount
*Description: This class is created to calculate total receipt amount and update on opportunity.
*Author: Sajid Hameed
*/

public class UpdateTotalReceiptAmount {

    
    public static void calculateTotalReceiptAmount(List<Receipt__c> newList){
        try{
            Id recordTypeId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Shop_Opportunity').getRecordTypeId();
            Id recordTypeId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Unit_Opportunity').getRecordTypeId();
            Id recordTypeId3 = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Unit_Corporate').getRecordTypeId();
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Lease_Renewal').getRecordTypeId();
            Id oppCommRcdTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Commercial_Lease_Renewal').getRecordTypeId();
            Set<Id> oppIds = new Set<Id>();
            
            for(Receipt__c rec :[SELECT Id , Amount__c, Receipt_Type__c, Payment_Status__c, opportunity__c,
                                 opportunity__r.RecordTypeId FROM Receipt__c WHERE Id IN: newList]){
                                     
                                     if(rec.opportunity__c != null){
                                         if((rec.opportunity__r.RecordTypeId == recordTypeId1) || 
                                            (rec.opportunity__r.RecordTypeId ==  recordTypeId2) || 
                                            (rec.opportunity__r.RecordTypeId ==  recordTypeId3)||
                                           (rec.opportunity__r.RecordTypeId ==  oppRecordTypeId)||
                                           (rec.opportunity__r.RecordTypeId ==  oppCommRcdTypeId)){
                                                oppIds.add(rec.opportunity__c);
                                            }
                                     }
                                 }
            if(!oppIds.isEmpty() && oppIds != null){
                List<Opportunity> oppList = new List<Opportunity>();
                for(AggregateResult ag : [SELECT opportunity__c ,SUM(Amount__c)amt FROM Receipt__c WHERE opportunity__c IN: oppIds GROUP BY opportunity__c]){
                    opportunity opp = new opportunity();
                    opp.Total_Receipt_Amount_Leasing__c = (Decimal)ag.get('amt');
                    opp.Id = (Id)ag.get('opportunity__c');
                    oppList.add(opp);
                }
                if(!oppList.isEmpty()){
                    Database.update(oppList, false);
                }
            }
        }catch (Exception ex){
            system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
        }  
    }
}