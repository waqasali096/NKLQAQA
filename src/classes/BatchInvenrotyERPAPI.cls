/**
* Name:          BatchInvenrotyERPAPI
* Description:   Inventory ERP Api in Bulk
* Author         Vishal Agrawal
*/
public class BatchInvenrotyERPAPI implements Database.Batchable<Sobject>, Database.AllowsCallouts,Database.Stateful{
    public String apiName;
    public String objName;
    public String headerName;
    public List<API_Mapping__mdt> apiMapping;
    public Set<Id> recordIds;
    public List<SObject> recordsToUdpate;
    public List<Logger__c> logs;
  
    public BatchInvenrotyERPAPI(String objName, String apiName, String headerName, Set<Id> recordIds) {
        this.recordIds = recordIds;
        this.objName = objName;
        this.apiName = apiName;
        this.headerName = headerName;
        recordsToUdpate = new List<SObject>();
        logs = new List<Logger__c>();

    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        String queryFields = '';
        apiMapping = new List<API_Mapping__mdt>(); 
        for(API_Mapping__mdt erpMap : [Select Data_Type__c, ERP_Field__c, Salesforce_Field__c, SF_Object_Name__c,IsConstant__c, Constant_Value__c  FROM API_Mapping__mdt WHERE API_Header__c In (SELECT Id FROM API_Header__mdt where API_Name__c =: apiName) Order By SF_Object_Name__c]) {
            if(erpMap.SF_Object_Name__c == objName) {
                apiMapping.add(erpMap);
                if(!String.isBlank(erpMap.Salesforce_Field__c)) {
                    queryFields += erpMap.Salesforce_Field__c + ',';
                }
            }
        }
        queryFields = queryFields.removeEnd(',');
        String finalQry = 'Select ' + queryFields + ' FROM '+objName+' Where Id In: recordIds';
        
        return Database.getQueryLocator(finalQry );
    }
    
    public void execute(Database.BatchableContext BC, List<Sobject> sobjs){
        for(Sobject sobj : sobjs) {
            ERPAPIIntegration.WrpInventoryResp inventoryWrapper = ERPAPIIntegration.initInventoryAPICall(objName, apiName, headerName,sobj, apiMapping);
            if(inventoryWrapper!=null){
                if(inventoryWrapper.sobj != null){
                   recordsToUdpate.add(inventoryWrapper.sobj);
                }
                if(inventoryWrapper.log != null){
                    logs.add(inventoryWrapper.log);
                }
            }
            /*
            if(this.apiName == ERPUtilities.API_NAME_PROJECT_CREATION) {
                ERPAPIIntegration.projectCreation((Project__c)sobj, apiMapping);
            } else if(this.apiName == ERPUtilities.API_NAME_BUILDING_CREATION) {
                ERPAPIIntegration.createBuilding((Building__c)sobj, apiMapping);
            } else if(this.apiName == ERPUtilities.API_NAME_FLOOR_CREATION) {
                ERPAPIIntegration.createFloor((Floor__c)sobj, apiMapping);
            } else if(this.apiName == ERPUtilities.API_NAME_UNIT_CREATION) {
                ERPAPIIntegration.createUnit((Unit__c)sobj, apiMapping);
            } else if(this.apiName == ERPUtilities.API_NAME_MASTERCOMMUNITY_CREATION) {
                ERPAPIIntegration.createMasterCommunity((Master_Community2__c)sobj, apiMapping);
            }*/
        }
    }
    
    public void finish(Database.BatchableContext BC){
        if(recordsToUdpate!=null & !recordsToUdpate.isEmpty()){
            update recordsToUdpate;
        }
        if(logs!=null & !logs.isEmpty()){
            upsert logs;
        }
    }
}