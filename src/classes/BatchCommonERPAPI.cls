/**
* Name:          BatchCommonERPAPI
* Description:   Common ERP Apis in Bulk
* Author         Vishal Agrawal
*/
public class BatchCommonERPAPI implements Database.Batchable<Sobject>, Database.AllowsCallouts,Database.Stateful{
    public String apiName;
    public String objName;
    public String headerName;
    public List<API_Mapping__mdt> apiMapping;
    public Set<Id> recordIds;
    public List<SObject> recordsToUdpate;
    public List<Logger__c> logs;
    
    public BatchCommonERPAPI(String objName, String apiName, String headerName, Set<Id> recordIds) {
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
        Set<String> setFields = new Set<String>();
        for(API_Mapping__mdt erpMap : [Select Data_Type__c, ERP_Field__c, Salesforce_Field__c, SF_Object_Name__c,IsConstant__c, Constant_Value__c  FROM API_Mapping__mdt WHERE API_Header__c In (SELECT Id FROM API_Header__mdt where API_Name__c =: apiName) Order By SF_Object_Name__c]) {
            if(erpMap.SF_Object_Name__c == objName) {
                if(!String.isBlank(erpMap.ERP_Field__c)) {
                    apiMapping.add(erpMap);
                }
                
                if(!String.isBlank(erpMap.Salesforce_Field__c) && !setFields.contains(erpMap.Salesforce_Field__c)) {
                    queryFields += erpMap.Salesforce_Field__c + ',';
                    setFields.add(erpMap.Salesforce_Field__c);
                }
            }
        }
        queryFields = queryFields.removeEnd(',');
        
        String whereClause = ' Where Id In: recordIds';
        if(ERPUtilities.API_NAME_BILL_LINE_CREATION == apiName && (recordIds == null || recordIds.isEmpty())){
            whereClause = ' Where ERP_Billing_Push_Date__c= TODAY AND ERP_Billing_Line_Id__c = null';
        }
        String finalQry = 'Select ' + queryFields + ' FROM '+objName + whereClause  ;
        
        return Database.getQueryLocator(finalQry );
    }
    
    public void execute(Database.BatchableContext BC, List<Sobject> sobjs){
        ERPAPIIntegration.WrpGenericAPIResponse commonWrapper = null;
        if(apiName == ERPUtilities.API_NAME_SALES_SO_CREATION && objName == ERPUtilities.OBJECT_NAME_AGREEMENT) {
            makeSOAPICallSales(sobjs);            
        } else if(apiName == ERPUtilities.API_NAME_LEASING_SO_CREATION && objName == ERPUtilities.OBJECT_NAME_LEASE_CONTRACT) {
            makeSOAPICallLeasing(sobjs);            
        } else if(apiName == ERPUtilities.API_NAME_OPPORTUNITY_CREATION && objName == ERPUtilities.OBJECT_NAME_OPPORTUNITY) {
            makeOpportunityAPICallLeasing(sobjs);            
        } else {
            for(Sobject sobj : sobjs) {
                commonWrapper = ERPAPIIntegration.initGenericERPAPICall(objName, apiName, headerName,sobj, apiMapping);
                saveBatchOutcome(commonWrapper);
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        if(recordsToUdpate!=null & !recordsToUdpate.isEmpty()){
            update recordsToUdpate;
            
            if(apiName == ERPUtilities.API_NAME_REFUND) {
                List<Receipt_Refund__c> refunds = (List<Receipt_Refund__c>) recordsToUdpate;
                
                Set<Id> creditMemoIds = new Map<Id,Credit_Memo__c>([Select Id FROM Credit_Memo__c Where Service_Request_Receipt__c In (Select Service_Request_Receipt__c FROM Receipt_Refund__c WHERE Id In : refunds )]).keySet();
                if(!creditMemoIds.isEmpty()) {
                    ERPIntegrationHelper.createCreditMemo(creditMemoIds);
                }
            }
        }
        if(logs!=null & !logs.isEmpty()){
            upsert logs;
        }
    }
    
    /*
    @Author : Vishal A
    @CreatedDate: 01/04/2022
    @ Prepare data for sales order API - Sales
    */
    public void makeSOAPICallSales(List<Sobject> sobjs){
        Map<Id,Unit__c> mapIdUnits = new Map<Id,Unit__c>();
        Map<Id,Id> mapAgrIdUnitIds = new Map<Id,Id>();
        List<API_Mapping__mdt> erpMappingUnt = new List<API_Mapping__mdt>();
        
        Set<Id> unitIds = new Set<Id>();
        for(Sobject sbj : sobjs) {
            Agreement__c  agr = (Agreement__c) sbj;
            unitIds.add(agr.Unit__c); 
            mapAgrIdUnitIds.put(agr.Id,agr.Unit__c);
        }
        
        Set<String> setFIeldUnits = new Set<String>();
        String queryUntFields = '';
        
        for(API_Mapping__mdt erpMap : [Select Data_Type__c, ERP_Field__c, Salesforce_Field__c, SF_Object_Name__c,IsConstant__c, Constant_Value__c  FROM API_Mapping__mdt WHERE API_Header__c In (SELECT Id FROM API_Header__mdt where API_Name__c =:ERPUtilities.API_NAME_SALES_SO_CREATION) AND SF_Object_Name__c = 'Unit__c' Order By SF_Object_Name__c]) {
            if(erpMap.SF_Object_Name__c == 'Unit__c') {
                erpMappingUnt.add(erpMap);
                if(!String.isBlank(erpMap.Salesforce_Field__c) && !setFIeldUnits.contains(erpMap.Salesforce_Field__c)) {
                    queryUntFields += erpMap.Salesforce_Field__c + ',';
                    setFIeldUnits.add(erpMap.Salesforce_Field__c);
                }
            }
        }
        queryUntFields = queryUntFields.removeEnd(',');
        String finalUntQry = 'Select ' + queryUntFields + ' FROM Unit__c Where Id In: unitIds';
        List<Unit__c> unnts = Database.query(finalUntQry);
        mapIdUnits = new Map<Id,Unit__c>(unnts);
        
        
        for(Sobject sobj : sobjs) {
            ERPAPIIntegration.WrpGenericAPIResponse commonWrapper = ERPAPIIntegration.salesAgreementSOCreation((Agreement__c)sobj, apiMapping, mapIdUnits.get(mapAgrIdUnitIds.get(sobj.Id)), erpMappingUnt);
            saveBatchOutcome(commonWrapper);
        }
    }
    
    /*
    @Author : Vishal A
    @CreatedDate: 01/04/2022
    @ Prepare data for sales order API - Leasing
    */
    public void makeSOAPICallLeasing(List<Sobject> sobjs){
        String queryUntFields = '';
        String queryPayMileFields = '';
        String queryAddChrgFields = '';
        List<API_Mapping__mdt> erpMappingUnt = new List<API_Mapping__mdt>();
        List<API_Mapping__mdt> erpMappingPayMile = new List<API_Mapping__mdt>();
        List<API_Mapping__mdt> erpMappingAddChrg = new List<API_Mapping__mdt>();
        Set<String> setFIeldUnits = new Set<String>();
        Set<String> setFIeldPayMiles = new Set<String>();
        Set<String> setFIeldAddChrg = new Set<String>();
        
        
        for(API_Mapping__mdt erpMap : [Select Data_Type__c, ERP_Field__c, Salesforce_Field__c, SF_Object_Name__c,IsConstant__c, Constant_Value__c  FROM API_Mapping__mdt WHERE API_Header__c In (SELECT Id FROM API_Header__mdt where API_Name__c =:apiName) Order By ERP_Field__c,SF_Object_Name__c]) {
            if(erpMap.SF_Object_Name__c == 'Unit_Plan__c') {
                erpMappingUnt.add(erpMap);
                if(!String.isBlank(erpMap.Salesforce_Field__c) && !setFIeldUnits.contains(erpMap.Salesforce_Field__c)) {
                    queryUntFields += erpMap.Salesforce_Field__c + ',';
                    setFIeldUnits.add(erpMap.Salesforce_Field__c);
                }
            }
            /*if(erpMap.SF_Object_Name__c == 'Payment_Milestone__c') {
                erpMappingPayMile.add(erpMap);
                if(!String.isBlank(erpMap.Salesforce_Field__c) && !setFIeldPayMiles.contains(erpMap.Salesforce_Field__c)) {
                    queryPayMileFields += erpMap.Salesforce_Field__c + ',';
                    setFIeldPayMiles.add(erpMap.Salesforce_Field__c);
                }
            }
            if(erpMap.SF_Object_Name__c == 'Opportunity_Charges__c') {
                erpMappingAddChrg.add(erpMap);
                if(!String.isBlank(erpMap.Salesforce_Field__c) && !setFIeldAddChrg.contains(erpMap.Salesforce_Field__c)) {
                    queryAddChrgFields += erpMap.Salesforce_Field__c + ',';
                    setFIeldAddChrg.add(erpMap.Salesforce_Field__c);
                }
            }*/
        }
        
        for(API_Mapping__mdt erpMap : [Select Data_Type__c, ERP_Field__c, Salesforce_Field__c, SF_Object_Name__c,IsConstant__c, Constant_Value__c,Sequence__c  FROM API_Mapping__mdt WHERE API_Header__c In (SELECT Id FROM API_Header__mdt where API_Name__c =:apiName) AND SF_Object_Name__c = 'Payment_Milestone__c' Order By Sequence__c Nulls Last]) {
            
            if(erpMap.SF_Object_Name__c == 'Payment_Milestone__c') {
                erpMappingPayMile.add(erpMap);
                if(!String.isBlank(erpMap.Salesforce_Field__c) && !setFIeldPayMiles.contains(erpMap.Salesforce_Field__c)) {
                    queryPayMileFields += erpMap.Salesforce_Field__c + ',';
                    setFIeldPayMiles.add(erpMap.Salesforce_Field__c);
                }
            }
        }
        for(API_Mapping__mdt erpMap : [Select Data_Type__c, ERP_Field__c, Salesforce_Field__c, SF_Object_Name__c,IsConstant__c, Constant_Value__c,Sequence__c FROM API_Mapping__mdt WHERE API_Header__c In (SELECT Id FROM API_Header__mdt where API_Name__c =:apiName) AND SF_Object_Name__c = 'Opportunity_Charges__c' Order By Sequence__c Nulls Last]) {
            if(erpMap.SF_Object_Name__c == 'Opportunity_Charges__c') {
                erpMappingAddChrg.add(erpMap);
                if(!String.isBlank(erpMap.Salesforce_Field__c) && !setFIeldAddChrg.contains(erpMap.Salesforce_Field__c)) {
                    queryAddChrgFields += erpMap.Salesforce_Field__c + ',';
                    setFIeldAddChrg.add(erpMap.Salesforce_Field__c);
                }
            }
        }
        
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id,Id> mapContractOppIds = new Map<Id,Id>();
        for(Sobject sbj : sobjs) {
            Lease_Contract__c  lc = (Lease_Contract__c) sbj;
            if(lc.Opportunity__c != null) {
                opportunityIds.add(lc.Opportunity__c); 
                mapContractOppIds.put(lc.Id,lc.Opportunity__c);
            }
        }
        
        queryUntFields = queryUntFields.removeEnd(',');
        String finalUntQry = 'Select ' + queryUntFields + ' ,Opportunity__c,Unit__r.Rentable_Area__c FROM Unit_Plan__c Where Opportunity__c In: opportunityIds';
        List<Unit_Plan__c> unnts = Database.query(finalUntQry);
        
        queryPayMileFields = queryPayMileFields.removeEnd(',');
        String finalPayMile = 'Select ' + queryPayMileFields + ' ,Opportunity__c,Unit__r.ERP_Unit_Id__c,Unit__r.Unit_Code__c,Unit_Plan__r.Unit__r.Unit_Code__c,Unit_Plan__r.Unit__r.ERP_Unit_Id__c FROM Payment_Milestone__c Where Opportunity__c In: opportunityIds';
        List<Payment_Milestone__c> mileStones = Database.query(finalPayMile);
        
        queryAddChrgFields = queryAddChrgFields.removeEnd(',');
        String finalAddChrg = 'Select ' + queryAddChrgFields + ' ,Opportunity__c,Unit__r.ERP_Unit_Id__c,Unit__r.Unit_Code__c FROM Opportunity_Charges__c Where Opportunity__c In: opportunityIds';
        List<Opportunity_Charges__c> addCharges = Database.query(finalAddChrg);
        
        Map<Id,List<Unit_Plan__c>> mapOppUnitPlan = new Map<Id,List<Unit_Plan__c>>();
        Map<Id,List<Payment_Milestone__c>> mapOppPayMilestone = new Map<Id,List<Payment_Milestone__c>>();
        Map<Id,List<Opportunity_Charges__c>> mapOppAddCharge = new Map<Id,List<Opportunity_Charges__c>>();
        
        createMapOfList(mapOppUnitPlan,unnts,'Opportunity__c');
        createMapOfList(mapOppPayMilestone,mileStones,'Opportunity__c');
        createMapOfList(mapOppAddCharge,addCharges,'Opportunity__c');
        
        
        for(Sobject sobj : sobjs) {
            Id oppId = mapContractOppIds.get(sobj.Id);
            ERPAPIIntegration.WrpGenericAPIResponse commonWrapper = ERPAPIIntegration.leaseContracatSOCreation((Lease_Contract__c)sobj,apiMapping,
                                                                                                               erpMappingUnt,erpMappingPayMile,
                                                                                                               erpMappingAddChrg,
                                                                                                               mapOppUnitPlan.get(oppId),
                                                                                                               mapOppPayMilestone.get(oppId),
                                                                                                               mapOppAddCharge.get(oppId)
                                                                                                              );
            saveBatchOutcome(commonWrapper);
        }
    }
    
    /*
    @Author : Vishal A
    @CreatedDate: 09/05/2022
    @ Prepare data for Opportunity API 
    */
    public void makeOpportunityAPICallLeasing(List<Sobject> sobjs){
        Map<Id,List<Unit_Plan__c>> mapIdUnits = new Map<Id,List<Unit_Plan__c>>();
        List<API_Mapping__mdt> erpMappingUnt = new List<API_Mapping__mdt>();
        
        Set<Id> opportunityIds = new Set<Id>();
        for(Sobject sbj : sobjs) {
            opportunityIds.add(sbj.Id);
        }
        
        Set<String> setFIeldUnits = new Set<String>();
        String queryUntFields = '';
        
        for(API_Mapping__mdt erpMap : [Select Data_Type__c, ERP_Field__c, Salesforce_Field__c, SF_Object_Name__c,IsConstant__c, Constant_Value__c,Sequence__c  FROM API_Mapping__mdt WHERE API_Header__c In (SELECT Id FROM API_Header__mdt where API_Name__c =:ERPUtilities.API_NAME_OPPORTUNITY_CREATION) AND SF_Object_Name__c = 'Unit_Plan__c' Order By Sequence__c Nulls Last]) {
            if(erpMap.SF_Object_Name__c == 'Unit_Plan__c') {
                erpMappingUnt.add(erpMap);
                if(!String.isBlank(erpMap.Salesforce_Field__c) && !setFIeldUnits.contains(erpMap.Salesforce_Field__c)) {
                    queryUntFields += erpMap.Salesforce_Field__c + ',';
                    setFIeldUnits.add(erpMap.Salesforce_Field__c);
                }
            }
        }
        queryUntFields = queryUntFields.removeEnd(',');
        String finalUntQry = 'Select ' + queryUntFields + ' FROM Unit_Plan__c Where Opportunity__c In: opportunityIds';
        List<Unit_Plan__c> unnts = Database.query(finalUntQry);
        
        createMapOfList(mapIdUnits,unnts,'Opportunity__c');
        
        
        for(Sobject sobj : sobjs) {
            ERPAPIIntegration.WrpGenericAPIResponse commonWrapper = ERPAPIIntegration.opportunityCreation((Opportunity)sobj, apiMapping, mapIdUnits.get(sobj.Id), erpMappingUnt);
            saveBatchOutcome(commonWrapper);
        }
    }
    
    /*
    @Author : Vishal A
    @CreatedDate: 01/04/2022
    @ Save batch outcome to insert to SF afterwards
    */
    public void saveBatchOutcome(ERPAPIIntegration.WrpGenericAPIResponse commonWrapper){
        if(commonWrapper!=null){
            if(commonWrapper.sobj != null){
                recordsToUdpate.add(commonWrapper.sobj);
            }
            if(commonWrapper.log != null){
                logs.add(commonWrapper.log);
            }
        }
    }
    
    public void createMapOfList(Map<Id,List<Sobject>> mapSobj, List<Sobject> sobjects, String field) {
        if(sobjects != null) {
            for(Sobject sobj: sobjects) {
                    
                List<Sobject> lstSobj = mapSobj.get((Id)sobj.get(field));
                if(lstSobj == null) {
                    lstSobj = new List<Sobject>();
                }
                lstSobj.add(sobj);
                mapSobj.put((Id)sobj.get(field),lstSobj);
            }
        }
    }
}