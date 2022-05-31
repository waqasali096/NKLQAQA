/**************************************************************************************************
* Name               : RequestJointBuyerTriggerHandler                                                      
* Description        : Handler class for Request Joint Buyer Trigger
* Created Date       : 16/02/2022                                                                 
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta     16/02/2022      Initial Draft.                                               
**************************************************************************************************/
public class RequestJointBuyerTriggerHandler {
    List<Requested_Joint_Owner__c> recordNewList = new List<Requested_Joint_Owner__c>();
    List<Requested_Joint_Owner__c> recordOldList = new List<Requested_Joint_Owner__c>();
    Map<Id, Requested_Joint_Owner__c> recordNewMap = new Map<Id, Requested_Joint_Owner__c>();
    Map<Id, Requested_Joint_Owner__c> recordOldMap = new Map<Id, Requested_Joint_Owner__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = false;
    
    public RequestJointBuyerTriggerHandler( List<Requested_Joint_Owner__c> newList, 
                                    List<Requested_Joint_Owner__c> oldList, 
                                    Map<Id, Requested_Joint_Owner__c> newMap, 
                                    Map<Id, Requested_Joint_Owner__c> oldMap, 
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
       
    }
    public void AfterInsertEvent(){
        JBAlerts(recordNewList);
    }
    public void BeforeUpdateEvent(){
    }
    public void BeforeDeleteEvent() {
        
    }
    
    public void AfterUpdateEvent(){
        JBAlerts(recordNewList);
    }
    public void AfterDeleteEvent() {
    }
    
    public void AfterUndeleteEvent() {
    }
    
   
    
    /******************************************************************************************************
    * @Description        : Function to add error for share percentage > 100 & Duplicate Secondary JB on Same Deal                                                                                             
    * @Return             : void                                                                         
    *******************************************************************************************************/    
    public void JBAlerts(List<Requested_Joint_Owner__c> newList){
        Set<Id> oppIdSet = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        for(Requested_Joint_Owner__c jb : newList){
            oppIdSet.add(jb.Case__c);
        }
        Map<Id,List<Requested_Joint_Owner__c>> mapOpJB = new Map<Id,List<Requested_Joint_Owner__c>>();
        for(Requested_Joint_Owner__c jb : [ SELECT Id, Case__c,Share_Percentage__c,Secondary_Account__c FROM Requested_Joint_Owner__c WHERE Case__c IN: oppIdSet ]){
           if(jb.Case__c!=null){
            if ( !mapOpJB.containsKey(jb.Case__c) ) {
                mapOpJB.put(jb.Case__c , new List<Requested_Joint_Owner__c>{jb});
            } else {
                List<Requested_Joint_Owner__c> tempJb = mapOpJB.get(jb.Case__c);
                tempJb.add(jb);
                mapOpJB.put(jb.Case__c , tempJb );
            }
           }
        }
        for( Requested_Joint_Owner__c joint : newList ){
            Decimal shareTotal = 0;
            Boolean duplicateSecondaryAcc = false;
            if(mapOpJB.get(joint.Case__c)!=null){
                for(Requested_Joint_Owner__c jb : mapOpJB.get(joint.Case__c)){
                    if(jb.Share_Percentage__c != null){
                        shareTotal += jb.Share_Percentage__c;
                    }
                    
                }
            }
            
            system.debug('shareTotal is '+ shareTotal);
            if(shareTotal > 100){
                joint.addError('Total Share Percentage of Requested Joint Buyers cannot be greater than 100.');
            }
        }
    }


}