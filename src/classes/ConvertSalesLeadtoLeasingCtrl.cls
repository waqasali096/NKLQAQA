public without sharing class ConvertSalesLeadtoLeasingCtrl {
    
    @AuraEnabled
    public static String ConvertLeadToLeasing(String recordId){
        String message;
        try{
         Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Residential_Leasing_Unit').getRecordTypeId(); 
        Lead l = new Lead();
        l.Id = recordId;
        l.RecordTypeId = recordTypeId;
        update l;
        message =  'Record Updated SuccssFully!!';
        }catch(exception ex){
           message = ex.getMessage(); 
        }
        
        return message;
    }

}