/**************************************************************************************************
* Name               : JointBuyerTriggerHandler                                                      
* Description        : Handler class for Joint Buyer Trigger
* Created Date       : 12/01/2022                                                                 
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     12/01/2022      Initial Draft.                                               
**************************************************************************************************/
public class JointBuyerTriggerHandler {
    List<Joint_Buyer__c> recordNewList = new List<Joint_Buyer__c>();
    List<Joint_Buyer__c> recordOldList = new List<Joint_Buyer__c>();
    Map<Id, Joint_Buyer__c> recordNewMap = new Map<Id, Joint_Buyer__c>();
    Map<Id, Joint_Buyer__c> recordOldMap = new Map<Id, Joint_Buyer__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = false;
    
    public JointBuyerTriggerHandler( List<Joint_Buyer__c> newList, 
                                    List<Joint_Buyer__c> oldList, 
                                    Map<Id, Joint_Buyer__c> newMap, 
                                    Map<Id, Joint_Buyer__c> oldMap, 
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
        populateName(recordNewList);
        attachJointOwnertoAgreement(recordNewList);
    }
    public void AfterInsertEvent(){
        JBAlerts(recordNewList);
    }
    public void BeforeUpdateEvent(){
        populateName(recordNewList);
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
    * @Description        : Function to link agreement to Joint buyer Record                                                                                             
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void attachJointOwnertoAgreement(List<Joint_Buyer__c> newList){
        Set<Id> setOppId = new Set<Id>();
        Map<Id, Id> mapOppAgreementId = new Map<Id, Id>();
       
        for(Joint_Buyer__c JB: newList){
            setOppId.add(JB.Opportunity__c);
        }
        
        for(Agreement__c ag: [Select Id, Opportunity__c from Agreement__c where Opportunity__c IN: setOppId])
        {
            mapOppAgreementId.put(ag.Opportunity__c, ag.Id);
        }
        
        if(!mapOppAgreementId.isEmpty()){
            for(Joint_Buyer__c JB: newList){
                JB.Agreement__c = mapOppAgreementId.get(JB.Opportunity__c);   
            }  
        }
        
        
    }
    
    /******************************************************************************************************
    * @Description        : Function to add error for share percentage > 100 & Duplicate Secondary JB on Same Deal                                                                                             
    * @Return             : void                                                                         
    *******************************************************************************************************/    
    public void JBAlerts(List<Joint_Buyer__c> newList){
        Set<Id> oppIdSet = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        for(Joint_Buyer__c jb : newList){
            oppIdSet.add(jb.Opportunity__c);
        }
        Map<Id,List<Joint_Buyer__c>> mapOpJB = new Map<Id,List<Joint_Buyer__c>>();
        for(Joint_Buyer__c jb : [ SELECT Id, Share_Percentage__c,Opportunity__c,Secondary_Account__c FROM Joint_Buyer__c WHERE Opportunity__c IN: oppIdSet ]){
           if(jb.Opportunity__c!=null){
            if ( !mapOpJB.containsKey(jb.Opportunity__c) ) {
                mapOpJB.put(jb.Opportunity__c , new List<Joint_Buyer__c>{jb});
            } else {
                List<Joint_Buyer__c> tempJb = mapOpJB.get(jb.Opportunity__c);
                tempJb.add(jb);
                mapOpJB.put(jb.Opportunity__c , tempJb );
            }
           }
        }
        for( Joint_Buyer__c joint : newList ){
            Decimal shareTotal = 0;
            Boolean duplicateSecondaryAcc = false;
            if(mapOpJB.get(joint.Opportunity__c)!=null){
                for(Joint_Buyer__c jb : mapOpJB.get(joint.Opportunity__c)){
                    if(jb.Share_Percentage__c != null){
                        shareTotal += jb.Share_Percentage__c;
                    }
                    if( !duplicateSecondaryAcc && joint.Secondary_Account__c == jb.Secondary_Account__c && joint.Id != jb.Id ){
                        duplicateSecondaryAcc = true;
                    }
                }
            }
            
            system.debug('shareTotal is '+ shareTotal);
            if(shareTotal > 100){
                joint.addError('Total Share Percentage of Joint Buyers on Order Entry cannot be greater than 100.');
            }else if(duplicateSecondaryAcc){
                joint.addError('Selected Secondary Joint Buyer is already added to this deal.');
            }
        }
    }


    /******************************************************************************************************
    * @Description        : Function to populate first & Last Name                                                                                           
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public void populateName(List<Joint_Buyer__c> newList){
        Set<Id> accIdSet = new Set<Id>();
        for(Joint_Buyer__c jb : newList){
            accIdSet.add(jb.Secondary_Account__c);
        } 
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,FirstName,LastName FROM Account WHERE Id IN:accIdSet]);
        for(Joint_Buyer__c jb : newList){
            if(jb.Secondary_Account__c!=null && accMap.get(jb.Secondary_Account__c)!=null){
                jb.First_Name__c = accMap.get(jb.Secondary_Account__c).FirstName;
                jb.Last_Name__c = accMap.get(jb.Secondary_Account__c).LastName;
            }
        } 
    }
}