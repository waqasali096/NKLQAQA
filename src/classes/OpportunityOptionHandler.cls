/**************************************************************************************************
* Name               : OpportunityOptionHandler                                                      
* Description        : Handler class for OpportunityOptionTrigger
* Created Date       : 10/05/2022                                                                  
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     10/05/2022      Initial Draft.                                               
**************************************************************************************************/
public class OpportunityOptionHandler {
    List<Opportunity_Option__c> recordNewList = new List<Opportunity_Option__c>();
    List<Opportunity_Option__c> recordOldList = new List<Opportunity_Option__c>();
    Map<Id, Opportunity_Option__c> recordNewMap = new Map<Id, Opportunity_Option__c>();
    Map<Id, Opportunity_Option__c> recordOldMap = new Map<Id, Opportunity_Option__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = false;
    
    public OpportunityOptionHandler( List<Opportunity_Option__c> newList, 
                                   List<Opportunity_Option__c> oldList, 
                                   Map<Id, Opportunity_Option__c> newMap, 
                                   Map<Id, Opportunity_Option__c> oldMap, 
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
    
    public void AfterInsertEvent() {
        calculateBUAonUnitAfterInsertion(recordNewList);
    }
    public void AfterUpdateEvent() {
    }
    public void BeforeInsertEvent() {
        
    }
    public void BeforeUpdateEvent() {
    }

    public void BeforeDeleteEvent() {
    }
    public void AfterDeleteEvent() {
        calculateBUAonUnitAfterDeletion(recordOldList);
    }
    public void AfterUndeleteEvent() {
    }


    /******************************************************************************************************
    * @Description        : Update Final BUA Field on Unit when Option is inserted 
    * Date                : 10/05/2022
    * Author              : Rhoit Sharma                                                                   
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void calculateBUAonUnitAfterInsertion(List<Opportunity_Option__c> recordList){
        Map<Id,Double> mapunitIdToTotal = new Map<Id,Double>();
        for(Opportunity_Option__c oo : recordList){
            if(oo.Unit__c != null && oo.Additional_Area__c != null){
                if ( !mapunitIdToTotal.containsKey(oo.Unit__c) ) {
                    mapunitIdToTotal.put(oo.Unit__c , oo.Additional_Area__c);
                } else {
                    Double tempSum = mapunitIdToTotal.get(oo.Unit__c);
                    tempSum = tempSum + oo.Additional_Area__c;
                    mapunitIdToTotal.put(oo.Unit__c , tempSum );
                }
            }
        }
        if(!mapunitIdToTotal.isEmpty()){
            List<Unit__c> unitListToUpdate = new List<Unit__c>();
            for(Unit__c unit : [SELECT Id,Additional_area__c FROM Unit__c WHERE Id IN:mapunitIdToTotal.keySet()]){
                Unit__c un = new Unit__c();
                un.Id = unit.Id;
                if(unit.Additional_area__c != null){
                    un.Additional_area__c = unit.Additional_area__c + mapunitIdToTotal.get(unit.Id);
                }else{
                    un.Additional_area__c = mapunitIdToTotal.get(unit.Id);
                }
                unitListToUpdate.add(un);
            }
            if(!unitListToUpdate.isEmpty()){
                update unitListToUpdate;
            }
            system.debug('unitListToUpdate'+unitListToUpdate);
        }
    }

    /******************************************************************************************************
    * @Description        : Update Final BUA Field on Unit when option is deleted
    * Date                : 10/05/2022
    * Author              : Rhoit Sharma                                                                   
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void calculateBUAonUnitAfterDeletion(List<Opportunity_Option__c> recordList){
        Map<Id,Double> mapunitIdToTotal = new Map<Id,Double>();
        for(Opportunity_Option__c oo : recordList){
            if(oo.Unit__c != null && oo.Additional_Area__c != null){
                if ( !mapunitIdToTotal.containsKey(oo.Unit__c) ) {
                    mapunitIdToTotal.put(oo.Unit__c , oo.Additional_Area__c);
                } else {
                    Double tempSum = mapunitIdToTotal.get(oo.Unit__c);
                    tempSum = tempSum + oo.Additional_Area__c;
                    mapunitIdToTotal.put(oo.Unit__c , tempSum );
                }
            }
        }
        if(!mapunitIdToTotal.isEmpty()){
            List<Unit__c> unitListToUpdate = new List<Unit__c>();
            for(Unit__c unit : [SELECT Id,Additional_area__c FROM Unit__c WHERE Id IN:mapunitIdToTotal.keySet()]){
                Unit__c un = new Unit__c();
                un.Id = unit.Id;
                if(unit.Additional_area__c != null){
                    un.Additional_area__c = unit.Additional_area__c - mapunitIdToTotal.get(unit.Id);
                }else{
                    un.Additional_area__c = 0;
                }
                unitListToUpdate.add(un);
            }
            if(!unitListToUpdate.isEmpty()){
                update unitListToUpdate;
            }
            system.debug('unitListToUpdate'+unitListToUpdate);
        }
    }
}