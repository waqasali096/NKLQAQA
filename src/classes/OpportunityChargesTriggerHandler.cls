/**************************************************************************************************
* Name               : OpportunityChargesTriggerHandler                                                      
* Description        : Handler class for Opportunity Charges Trigger
* Created Date       : 03/02/2022                                                                  
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     03/02/2022       Initial Draft.                                               
**************************************************************************************************/
public class OpportunityChargesTriggerHandler {
    List<Opportunity_Charges__c> recordNewList = new List<Opportunity_Charges__c>();
    List<Opportunity_Charges__c> recordOldList = new List<Opportunity_Charges__c>();
    Map<Id, Opportunity_Charges__c> recordNewMap = new Map<Id, Opportunity_Charges__c>();
    Map<Id, Opportunity_Charges__c> recordOldMap = new Map<Id, Opportunity_Charges__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = false;
    
    public OpportunityChargesTriggerHandler( List<Opportunity_Charges__c> newList, 
                                            List<Opportunity_Charges__c> oldList, 
                                            Map<Id, Opportunity_Charges__c> newMap, 
                                            Map<Id, Opportunity_Charges__c> oldMap, 
                                            boolean isInsert, 
                                            boolean isUpdate, 
                                            Boolean isDelete, 
                                            Boolean isUndelete, 
                                            Boolean isBefore, 
                                            Boolean isAfter){
                                                this.recordNewList = newList;
                                                this.recordOldList = oldList;
                                                this.recordNewMap = newMap;
                                                this.recordOldMap = oldMap;
                                                this.isInsert = isInsert;
                                                this.isUpdate = isUpdate;
                                                this.isDelete = isDelete;
                                                this.isUndelete = isUndelete;
                                                this.isBefore = isBefore;
                                                this.isAfter = isAfter;        
                                            }
    
    public void BeforeInsertEvent() {
        setBillingConfig();
    }
    public void AfterInsertEvent(){
        calculateChargesTotal(recordNewList);
        calculateTotalChargesAmount(recordNewList);        
    }
    public void BeforeUpdateEvent(){
        //setBillingConfig();
    }
    public void BeforeDeleteEvent() {
        
    }
    
    public void AfterUpdateEvent(){
        calculateChargesTotal(recordNewList);
        calculateTotalChargesAmount(recordNewList);

    }
    public void AfterDeleteEvent() {
        calculateTotalChargesAmount(recordOldList);
    }
    
    public void AfterUndeleteEvent() {
        calculateTotalChargesAmount(recordNewList);
    }
    
    public static void calculateChargesTotal(List<Opportunity_Charges__c> newList){
        Set<Id> oppIdSet = new Set<Id>();
        for(Opportunity_Charges__c op : newList){
            if(/*op.VAT_Amount__c != null &&*/ op.Opportunity__c != null){
                oppIdSet.add(op.Opportunity__c);
            }
        }
        if(!oppIdSet.isEmpty()){
            Map<Id,Decimal> mapOp = new Map<Id,Decimal>();
            for(Opportunity_Charges__c charge : [ SELECT Id,/* VAT_Amount__c,*/Opportunity__c FROM Opportunity_Charges__c WHERE Opportunity__c IN: oppIdSet ]){
               // if(charge.VAT_Amount__c != null){
                    if ( !mapOp.containsKey(charge.Opportunity__c) ) {
                    //    mapOp.put(charge.Opportunity__c , charge.VAT_Amount__c);
                    } else {
                        Decimal tempJb = mapOp.get(charge.Opportunity__c);
                       // tempJb += charge.VAT_Amount__c;
                        mapOp.put(charge.Opportunity__c , tempJb );
                    }
               // }
            }
            if(!mapOp.isEmpty()){
                List<Opportunity> oppUpdateList = new List<opportunity>();
                for(Id oppId : mapOp.keySet()){
                    Opportunity opp = new Opportunity();
                    opp.Id = oppId;
                    opp.Total_Additional_Charges__c = mapOp.get(oppId);
                    oppUpdateList.add(opp);
                }
                if(!oppUpdateList.isEmpty()){
                    update oppUpdateList;
                }
            }
        }
    }
    
    // Set Billing Configuration Lookup in Additional Charges
    public void setBillingConfig() {
        
        Map<String,List<Opportunity_Charges__c>> mapBUIdAddCharge = new Map<String,List<Opportunity_Charges__c>>();
        Set<String> businessUnitSet = new Set<String>();
        
        for(Opportunity_Charges__c oppChrg : recordNewList) {
            if(String.isNotBlank(oppChrg.Business_Unit_Id__c) && 
                (oppChrg.Opportunity_Record_Type__c == 'Deal_Unit_Sold' || oppChrg.Opportunity_Record_Type__c == 'Deal_Read_Only' || oppChrg.Opportunity_Record_Type__c == 'Sales_Opportunity')) {
                List<Opportunity_Charges__c> addCharges = mapBUIdAddCharge.get(oppChrg.Business_Unit_Id__c);
                if(addCharges == null) {
                    mapBUIdAddCharge.put(oppChrg.Business_Unit_Id__c, new List<Opportunity_Charges__c>());
                }
                mapBUIdAddCharge.get(oppChrg.Business_Unit_Id__c).add(oppChrg);
                
                businessUnitSet.add(oppChrg.Business_Unit_Id__c);
            }
        }
        
        if(!mapBUIdAddCharge.isEmpty()) {
            
            for(Billing_Configuration__c billConf : [Select Id,Payment_Term_Type_Code__c,Business_Unit__c FROM Billing_Configuration__c WHERE Payment_Term_Type_Code__c = 'ADMIN' AND Business_Unit__c In :businessUnitSet AND Payment_Purpose_Code__c = 'ADMIN']) {
                if(String.isNotBlank(billConf.Payment_Term_Type_Code__c) && String.isNotBlank(billConf.Business_Unit__c)) {
                    String concatPayTermBusUnit = billConf.Business_Unit__c;
                    if(mapBUIdAddCharge.containsKey(concatPayTermBusUnit)) {
                        for(Opportunity_Charges__c oppChrg : mapBUIdAddCharge.get(concatPayTermBusUnit)) {
                            oppChrg.Billing_Configuration__c = billConf.Id;
                        }
                    }
                }
            }
        }
    }
    /******************************************************************************************************
    * @Description        : Function to set Total Charges Amount on Deal
    * @Params             : List< Opportunity_Charges__c > newList                                                                                             
    * @Return             : void       
    * @Author             : Rohit Sharma                                                                  
    *******************************************************************************************************/
        
    public void calculateTotalChargesAmount(List<Opportunity_Charges__c> newList){
        List<Id> oppId = new List<Id>();
        for(Opportunity_Charges__c pm :newList){
            if(isAfter && isUpdate){
                if(pm.Total_Amount__c != recordOldMap.get(pm.Id).Total_Amount__c){
                    oppId.add(pm.Opportunity__c);
                }
            }else{
                oppId.add(pm.Opportunity__c);
            }
            
        }
        if(!oppId.isEmpty()){
            List<Opportunity> oppList = new List<Opportunity>();
            if(oppId.size() > 0){
                // added condition for null check - swapnil 25/05/2022
                for(AggregateResult ag : [SELECT Opportunity__c ,SUM(Total_Amount__c)amt FROM Opportunity_Charges__c WHERE Opportunity__c IN: oppId and Opportunity__r.Leasing_type__c =null group by Opportunity__c]){
                    
                    Opportunity opp = new Opportunity();
                    opp.Total_Charges_Amount__c = (Decimal)ag.get('amt');
                    opp.Id = (Id)ag.get('Opportunity__c');
                    
                    oppList.add(opp);
                    
                }
                if(!oppList.isEmpty()){
                    Database.update(oppList, false);
                }
            }
        }
    }
}