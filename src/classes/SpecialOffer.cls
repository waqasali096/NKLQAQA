/*
Class Name: SpecialOffer.
Class Description: Create Special offers for the Projects.
Author: Karan Jain
Created Date: 11/14/2021
Updated by: 
Last Update Date:
*/

public with sharing class SpecialOffer {
    public SpecialOffer() {

    }

    @AuraEnabled
    public static boolean createCampaign(Campaign campObj){
        
        try 
        {
            insert campObj;
            return true;    
        } catch (Exception e) {
            System.debug(e.getMessage());
            return false;
        }
    }
    
    @AuraEnabled
    public static list<Master_Payment_Plan__c> searchMasterPaymentPlan(String mppSearchTerm){
        
        try 
        {
           if(mppSearchTerm == '' || mppSearchTerm == null){
               return [SELECT ID, Name FROM Master_Payment_Plan__c];
           } 
           else{
               return [SELECT ID, Name FROM Master_Payment_Plan__c WHERE Name LIKE: '%'+mppSearchTerm+'%'];
           }
        }catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
}