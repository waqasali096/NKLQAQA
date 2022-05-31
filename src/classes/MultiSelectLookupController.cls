public with sharing class MultiSelectLookupController {
    //This method retrieves the data from database table. It search input is '*', then retrieve all records
    @AuraEnabled (cacheable=true)
    public static List<SObjectQueryResult> retrieveRecords(String objectName, 
                                                    String fieldAPINames,
                                                    String filterFieldAPIName,
                                                    String strInput){
        
        List<SObjectQueryResult> lstReturnResult = new List<SObjectQueryResult>();
        if(strInput.equals('*')){
            strInput = '';
        }
        String str = strInput + '%';
        String strQueryField = '';
        List<String> fieldList = fieldAPINames.split(',');

        //check if Id is already been passed
        if(!fieldList.contains('Id')){
            fieldList.add('Id');
            strQueryField = String.join(fieldList, ',');
        }else {
            strQueryField = fieldAPINames;
        }

        String strQuery = 'SELECT ' + String.escapeSingleQuotes(strQueryField) 
                        + ' FROM ' 
                        + String.escapeSingleQuotes(objectName) 
                        + ' WHERE ' + filterFieldAPIName + '  LIKE \'' + str + '%\''
                        + ' ORDER BY ' + filterFieldAPIName
                        + ' LIMIT 50';
                        
        System.debug('strQuery=' + strQuery);

        List<SObject> lstResult = database.query(strQuery);
        //create list of records that can be easily be parsable at js controller.
        for(String strField:fieldList){
            for(SObject sobj:lstResult){                
                if(strField != 'Id'){
                    SObjectQueryResult result = new SObjectQueryResult();
                    result.recordId = (String) sobj.get('Id');
                    result.recordName = (String) sobj.get(strField);
                    lstReturnResult.add(result);
                }                
            }
        }
        return lstReturnResult;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Cluster__c> getClusterAndBuildings(String projectId){
        try {
            List<Cluster__c> clusterList = [SELECT Id, Name, (SELECT Id, Name from Buildings__r) FROM Cluster__c WHERE Project__c =: projectId];
            return clusterList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void pushNewUnitToCampaign(String campaignId, List<String> unitIdList){
        List<Sales_Event_Unit__c> campaignUnitList = new List<Sales_Event_Unit__c>();
        List<Unit__c> unitStatusUpdateList = new List<Unit__c>();
        for(Unit__c u:[SELECT Id, Name, Sales_Status__c FROM Unit__c WHERE Id in: unitIdList]){
            Sales_Event_Unit__c seu = new Sales_Event_Unit__c();
            seu.Sales_Event__c = campaignId;
            seu.Unit__c = u.Id;
            seu.Name = u.Name;
            seu.Unit_Previous_Status__c = u.Sales_Status__c;
            campaignUnitList.add(seu);
            u.Sales_Status__c = 'Blocked';
            unitStatusUpdateList.add(u);
        }
        /*for(String s: unitIdList){
            Unit_Campaign__c uc = new Unit_Campaign__c();
            uc.Campaign__c = campaignId;
            uc.Unit__c = s;
            campaignUnitList.add(uc);
        }*/
        try{
            insert campaignUnitList;
            update unitStatusUpdateList;
        }catch(Exception e){
            System.debug('There was an error==>'+e);
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Unit__c> getAllRelatedUnits(String clusterId, String buildingId){
        try{
            List<Unit__c> resultUnitList = [SELECT Id, Name, Building__c, Cluster__c, Sales_Status__c, Leasing_Status__c FROM Unit__c WHERE Building__c=: buildingId AND Cluster__c=:clusterId AND Sales_Status__c = 'Available'];
            System.debug('@@@'+resultUnitList);
            return resultUnitList;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void addSalesExecutives(String campaignId, List<String> userIdList){
        System.debug('we are in the green zone!');
        System.debug('@@@'+userIdList);
        Map<Id, User> userIdToNameMap = new Map<Id, User>([Select Id, Name FROM User WHERE Id IN: userIdList]);
        system.debug(userIdToNameMap);
        Boolean isSuccess = false;
        List<Sales_Event_Executive__c> listNewSalesExecutiveCampaign = new List<Sales_Event_Executive__c>();
        for(String s: userIdList){
            Sales_Event_Executive__c sec = new Sales_Event_Executive__c();
            sec.Name = userIdToNameMap.get(s).Name;
            sec.Sales_Event__c = campaignId;
            sec.User__c = s;
            listNewSalesExecutiveCampaign.add(sec);
            System.debug('sec@@@+>'+sec);
        }
        if(listNewSalesExecutiveCampaign.size()>0){
            try{
                System.debug('we are also creating some records');
                insert listNewSalesExecutiveCampaign;
                isSuccess = true;
            }
            catch(Exception e){
                System.debug('Error@@@'+e);
            }
        }
    }
    
    public class SObjectQueryResult {
        @AuraEnabled
        public String recordId;

        @AuraEnabled
        public String recordName;
    }
}