/**
 * Name:          BatchGETBUListeERP
 * Description:   Get BU List from ERP
 * Author         Vishal Agrawal
 */
public class BatchGETBUListeERP implements Database.Batchable<ERPAPIResponse.X_BU_TABLE_ITEM>, Database.AllowsCallouts{

    public Iterable<ERPAPIResponse.X_BU_TABLE_ITEM> start(Database.BatchableContext BC){
        return ERPAPIIntegration.getBUList();
    }
    
    public void execute(Database.BatchableContext BC, List<ERPAPIResponse.X_BU_TABLE_ITEM> responseBU){
        Set<String> setorgIds = new Set<String>();
        Set<String> setBGIds = new Set<String>();
        for(ERPAPIResponse.X_BU_TABLE_ITEM buItem : responseBU) {
            setorgIds.add(buItem.ORGANIZATION_ID);
            setBGIds.add(buItem.BUSINESS_GROUP_ID );
        }
        
        Map<String,Id> orgIDBU = new Map<String,Id>();
        for(Business_Unit__c bu : [Select Id,ERP_Business_Unit_Id__c FROM Business_Unit__c WHERE ERP_Business_Unit_Id__c In :setorgIds]) {
            orgIDBU.put(bu.ERP_Business_Unit_Id__c,bu.Id);
        }
        Map<String,Id> bgIDCode = new Map<String,Id>();
        for(Business_Group__c bg : [Select Id,Business_Group_Code__c FROM Business_Group__c WHERE Business_Group_Code__c In :setBGIds]) {
            bgIDCode.put(bg.Business_Group_Code__c,bg.Id);
        }
        List<Business_Unit__c> busUnitsToUpsert = new List<Business_Unit__c>();
        List<API_Mapping__mdt> erpMappingprj = new List<API_Mapping__mdt>();
        
        for(ERPAPIResponse.X_BU_TABLE_ITEM buItem : responseBU) {
            Business_Unit__c bunit = new Business_Unit__c();
            bunit.Id = orgIDBU.get(buItem.ORGANIZATION_ID);
            bunit.Business_Group__c = bgIDCode.get(buItem.BUSINESS_GROUP_ID);
            bunit.Name = buItem.ORGANIZATION_NAME;
            bunit.Business_Unit_Purpose__c = buItem.ORGANIZATION_TYPE;
            bunit.Business_Unit_Code__c = buItem.BU_CODE;
            bunit.ERP_Business_Unit_Id__c = buItem.ORGANIZATION_ID;
            busUnitsToUpsert.add(bunit);
        }
        upsert busUnitsToUpsert;
    }
    
    public void finish(Database.BatchableContext BC){
    }
}