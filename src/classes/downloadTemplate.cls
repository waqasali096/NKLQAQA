public with sharing class downloadTemplate {
    
    @AuraEnabled
    public static void downloadExcelTemplate(String projectId) {
        System.debug('### '+projectId);
        List<Unit__c> unitList = new List<Unit__c>();
        unitList = [SELECT Id,Name FROM Unit__c WHERE Project__c =:projectId];
    }
}