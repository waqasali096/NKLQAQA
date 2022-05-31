/**
* @description      Fetch and Delete Opportunity units 
* @param            rnone
* @return           None
* @throws           NA
* @author Kshitij Tiwari
*/

public with sharing class FetchOpportunityUnits {

   //Method to retrive Opportunity Units

    @AuraEnabled//Annotation to use method in lightning component
    public static List<Unit_Plan__c> getOpportunityUnitList(String recordId) {//Fetch data
        return [SELECT Id, Name, Base_Rent__c, Unit_Status__c, Unit__r.name,Unit__r.Total_Leasable_Area__c, Opportunity__r.Revised_Price_per_Sq_ft__c,base_lease_amount__c,
                Unit__r.Unit_Status__c,Unit__r.Unit_Code__c,Unit__r.Base_Rent__c,Unit__r.Price_Per_SQ_FT__c,Opportunity__r.Leasing_Type__c, Opportunity__r.Price_Approval_Status__c,
                Unit__c, Unit__r.No_of_Bedrooms__c, Unit__r.Leasing_Property_Type__c , Unit__r.Unit_space_Type__c // Added by Sajid
                FROM Unit_Plan__c WHERE Opportunity__c =: recordId];
    }

    @AuraEnabled
    public static Opportunity getOpportunityDetail(String recordId){
        try {
            return [SELECT Id,Leasing_Type__c,Revised_Price_per_Sq_ft__c, Price_Approval_Status__c FROM Opportunity WHERE Id=: recordId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
 
    //Method to Delete Opportunity Units
    @AuraEnabled
    public static List<Unit_Plan__c> DeleteRecord(List<Unit_Plan__c> DeleteUnits) {
        List<Unit_Plan__c> up = new List<Unit_Plan__c>();
        set<Id> UnitIds = new set<Id>();
        List<Unit__c> unitList = new List<Unit__c>();
        String opportunityId = '';
       
        for(Unit_Plan__c u : [SELECT Id, Name,Unit__c,Opportunity__c FROM Unit_Plan__c WHERE Id IN : DeleteUnits]){
            opportunityId = u.Opportunity__c;
            up.add(u);
            UnitIds.add(u.Unit__c);
        }
        if(up.size() > 0){
            
            Delete  up;
        }
        
        //Added by karishma to update the units back to vacant and fetch the new list of oppty units
        if(UnitIds.size()>0){
            for(Id key : UnitIds){
                Unit__c unit = new Unit__c(Id=key, Unit_Status__c = 'Vacant');
                unitList.add(unit);
            }
        }

        if(!unitList.isEmpty()){
            update unitList;
        }
        List<Unit_Plan__c> opptyUnits = [SELECT ID FROM Unit_Plan__c WHERE Opportunity__c =: opportunityId];
        return opptyUnits;

        /*List<Unit_Plan__c> unitplanlst = new List<Unit_Plan__c>();
        UnitLeasingWrapperClass.filtersWrapper fieldWrap = new UnitLeasingWrapperClass.filtersWrapper();
        for(Unit_Plan__c unit : [Select Id,Unit__c FROM Unit_Plan__c where Opportunity__c =: opportunityId]){
            unitplanlst.add(unit);
        }
        fieldWrap.unitList = unitplanlst;
        fieldWrap.oppRecord =  UnitLeasingSelectionClass.getOptyRecord(opportunityId) != null ? UnitLeasingSelectionClass.getOptyRecord(opportunityId) : null;
        fieldWrap.unitWrapper = UnitLeasingSelectionClass.SearchUnits(opportunityId) != null ?  UnitLeasingSelectionClass.SearchUnits(opportunityId) : null;
        return fieldWrap;     */
    }

    
}