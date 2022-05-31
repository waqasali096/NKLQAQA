/*
Class Name: AddAmenity.
Class Description: Adding multiple Amenities on multiple Unit level.
Author: Karan Jain
Created Date: 11/16/2021
Updated by: 
Last Update Date:
*/

public with sharing class AddAmenity{

    @AuraEnabled(cacheable=true)
    public static List<Master_Amenity__c> getAmenity() 
    {
        return [SELECT Id, Name FROM Master_Amenity__c];
    }

    @AuraEnabled
    public static boolean addAmenities(List<String> unitIds, List<String> amenityName){
        
        List<Amenity__c> amenityList = new List<Amenity__c>();
        for(String unit: unitIds){
            for(String amenity: amenityName)
            {
                Amenity__c obj = new Amenity__c();
                obj.Name = amenity;
                obj.Unit__c = unit;
                amenityList.add(obj);
            }
        }
        try {
            insert amenityList;
            return true;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return false;
        }
    }
}