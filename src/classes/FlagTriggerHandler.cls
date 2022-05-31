/**************************************************************************************************
* Name               : FlagTriggerHandler                                                      
* Description        : Trigger Handler for FlagTrigger
* Created Date       : 21/03/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      21/03/2022      Initial Draft.                                               
**************************************************************************************************/

public class FlagTriggerHandler {
    List<Flag__c> recordNewList = new List<Flag__c>();
    List<Flag__c> recordOldList = new List<Flag__c>();
    Map<Id, Flag__c> recordNewMap = new Map<Id, Flag__c>();
    Map<Id, Flag__c> recordOldMap = new Map<Id, Flag__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = false;
    
    public FlagTriggerHandler(List<Flag__c> newList, List<Flag__c> oldList, Map<Id, Flag__c> newMap, Map<Id, Flag__c> oldMap, 
                              boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete, Boolean isBefore, Boolean isAfter) {
        this.recordNewList = newList;
        this.recordOldList = oldList;
        this.recordNewMap = newMap;
        this.recordOldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent() {
       
    }
    public void BeforeUpdateEvent() {
        
        
    }
    public void BeforeDeleteEvent() {
    }
    public void AfterInsertEvent() {
    UpdateUnitAndAccountFlags(recordNewList);  
     //sendFlagUNFlagToERP();  
    }
    public void AfterUpdateEvent() {
    UpdateUnitAndAccountFlags(recordNewList);    
	sendFlagUNFlagToERP();
    }
    public void AfterDeleteEvent() {
    UpdateUnitAndAccountFlags(recordOldList);    
    }
    public void AfterUndeleteEvent() {
    UpdateUnitAndAccountFlags(recordNewList);    
    }
    
    
/********************************************************************************************** 
* @Description  : Check active flags 
* @Params       : Flag Id
* @Return       : void
* @Author       : Mamta Gupta
**********************************************************************************************/
    
    private void UpdateUnitAndAccountFlags(List<Flag__c> flgList){
     Set<Id> unitIDS = new Set<Id>();
     Set<Id> accIDS = new Set<Id>();   
        for(Flag__c flg :flgList){
            if(flg.Unit__c!=null){
                if(isAfter && isUpdate){
                    if((flg.Unit__c != recordOldMap.get(flg.Id).Unit__c)||(flg.Active__c!=recordOldMap.get(flg.Id).Active__c)){
                        unitIDS.add(flg.Unit__c);
                    }
                }else{
                    unitIDS.add(flg.Unit__c);
                }
            }
            else if(flg.Customer__c!=null){
                    if(isAfter && isUpdate){
                        if((flg.Customer__c != recordOldMap.get(flg.Id).Customer__c)||(flg.Active__c!=recordOldMap.get(flg.Id).Active__c)){
                            accIDS.add(flg.Customer__c);
                        }
                    }else{
                        accIDS.add(flg.Customer__c);
                    }
                    
            }
        }
        if(!unitIDS.isEmpty()){
            updateFlagonUnit(unitIDS);
            }
        
         if(!accIDS.isEmpty()){
            updateFlagonAccount(accIDS);
            }
        }
    
    
    private void updateFlagonUnit(Set<Id> unitIDS){
        List<Unit__c> unitList = new List<Unit__c>();
        if(unitIDS.size() > 0){
            AggregateResult[] agrResult= [SELECT Unit__c ,COUNT(ID) IDS FROM Flag__c WHERE Unit__C IN: unitIDS AND Active__c =true
                                          group by Unit__C];
            system.debug('agrResult is '+ agrResult);
            for(AggregateResult ag : agrResult){
                
                Unit__c unit = new Unit__c();
                Integer count = (Integer)ag.get('IDS');
                system.debug('count is '+ count);
                if(count>0){
                    unit.Unit_Flagged__c = true;
                }
                else{
                    unit.Unit_Flagged__c = false; 
                }
                unit.Id = (Id)ag.get('Unit__c');
                
                unitList.add(unit);
                
            }
            if(agrResult.isEmpty()){
                for(ID  un: unitIDS){
                    Unit__c unit = new Unit__c();
                    unit.ID = un;
                    unit.Unit_Flagged__c = false; 
                    unitList.add(unit);
                }
            }
            
            try{
                update unitList;
            }
            catch(Exception ex){
                system.debug('error is '+ ex.getLineNumber() + ex.getMessage()); 
            }
        }
        
    }
    
    
     private void updateFlagonAccount(Set<Id> accIDS){
       List<Account> accList = new List<Account>();
            if(accIDS.size() > 0){
                AggregateResult[] agrResult= [SELECT Customer__c  ,COUNT(ID) IDS FROM Flag__c WHERE Customer__c  IN: accIDS AND Active__c =true
                                              group by Customer__c ];
                system.debug('agrResult is '+ agrResult);
                for(AggregateResult ag : agrResult){
                    
                    Account acc = new Account();
                    Integer count = (Integer)ag.get('IDS');
                    system.debug('count is '+ count);
                    if(count>0){
                        acc.Unit_Flagged__c = true;
                    }
                    else{
                        acc.Unit_Flagged__c = false; 
                    }
                    acc.Id = (Id)ag.get('Customer__c');
                    accList.add(acc);
                    
                }
                if(agrResult.isEmpty()){
                    for(ID  un: accIDS){
                        Account acc = new Account();
                        acc.ID = un;
                        acc.Unit_Flagged__c = false; 
                        accList.add(acc);
                    }
                }
                
                try{
                   update accList;
                }
                catch(Exception ex){
                  system.debug('error is '+ ex.getLineNumber() + ex.getMessage()); 
 
                }
            }
        }
     
    /**********************************************************************************************
* @Description  : Method to invoke Flag-unflag APIs
* @Date         : 12/may/2022
* @Return       : void
* @Author       : Vishal Agrawal
**********************************************************************************************/
    public void sendFlagUNFlagToERP(){
        Set<Id> unitFlagId = new Set<Id>();
        Set<Id> unitUnFlagId = new Set<Id>();
        Set<Id> customerFlagId = new Set<Id>();
        Set<Id> customerUnFlagId = new Set<Id>();
        for(Flag__c flag : recordNewList){
            if(flag.Send_Unit_Flag_ERP__c && (recordOldMap == null || flag.Send_Unit_Flag_ERP__c != recordOldMap.get(flag.Id).Send_Unit_Flag_ERP__c)){
                unitFlagId.add(flag.Id);
            }
            if(flag.Send_Unit_UnFlag_ERP__c && (recordOldMap == null || flag.Send_Unit_UnFlag_ERP__c != recordOldMap.get(flag.Id).Send_Unit_UnFlag_ERP__c)){
                unitUnFlagId.add(flag.Id);
            }
            if(flag.Send_Customer_Flag_ERP__c && (recordOldMap == null || flag.Send_Customer_Flag_ERP__c != recordOldMap.get(flag.Id).Send_Customer_Flag_ERP__c)){
                customerFlagId.add(flag.Id);
            }
            if(flag.Send_Customer_UnFlag_ERP__c && (recordOldMap == null || flag.Send_Customer_UnFlag_ERP__c != recordOldMap.get(flag.Id).Send_Customer_UnFlag_ERP__c)){
                customerUnFlagId.add(flag.Id);
            }
        }
        if(!unitFlagId.isEmpty()){
            ERPIntegrationHelper.createFlagUnit(unitFlagId);
        }
        if(!unitUnFlagId.isEmpty()){
            ERPIntegrationHelper.createUNFlagUnit(unitUnFlagId);
        }
        if(!customerFlagId.isEmpty()){
            ERPIntegrationHelper.createFlagCustomer(customerFlagId);
        }
        if(!customerUnFlagId.isEmpty()){
            ERPIntegrationHelper.createUNFlagCustomer(customerUnFlagId);
        }
    }
    }