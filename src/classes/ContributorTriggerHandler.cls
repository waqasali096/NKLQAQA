/**************************************************************************************************
* Name               : ContributorTriggerHandler                                                      
* Description        : Handler class for Contributor Trigger
* Created Date       : 04/02/2022                                                                   
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     04/02/2022      Initial Draft.                                               
**************************************************************************************************/
public without sharing class ContributorTriggerHandler {
    List< Contributor__c  > recordNewList = new List< Contributor__c >();
    List< Contributor__c  > recordOldList = new List< Contributor__c >();
    Map<Id, Contributor__c > recordNewMap = new Map<Id, Contributor__c >();
    Map<Id, Contributor__c > recordOldMap = new Map<Id, Contributor__c >();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    public static boolean recursionController = false;
    
    public ContributorTriggerHandler( List< Contributor__c > newList, 
                                     List< Contributor__c > oldList, 
                                     Map<Id, Contributor__c > newMap, 
                                     Map<Id, Contributor__c > oldMap, 
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

    public void AfterInsertEvent(List<sObject> newOppList) {
        createOpptyTeamMembers(  newOppList );
    }

    public void BeforeUpdateEvent(List<sObject> newOppList,Map<Id, sObject> recordOldMap,Map<Id, sObject> recordNewMap) {

    }

    public void BeforeDeleteEvent() {
        deleteOpptyTeamMembers( recordOldList );
    }

    public void AfterUpdateEvent(){

    }

    public void AfterDeleteEvent() {
    }
    
    public void AfterUndeleteEvent() {
    }

    /******************************************************************************************************
    * @Description        : Function to create opportunity team members                                                                                            
    * @Param              : List< Contributor__c > newList => new list  
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public static void createOpptyTeamMembers( List< Contributor__c > newList ){
        
        List< OpportunityTeamMember  > lstOpptyTeamMember = new List< OpportunityTeamMember  >();
        for( Contributor__c cont : newList ){
            OpportunityTeamMember otm = new OpportunityTeamMember();
            otm.OpportunityId  = cont.Opportunity__c;
            otm.UserId = cont.User__c;
            otm.OpportunityAccessLevel = cont.Access__c;
            otm.TeamMemberRole = cont.Role__c;
            lstOpptyTeamMember.add( otm );
        }

        if( !lstOpptyTeamMember.isEmpty() ){
            insert lstOpptyTeamMember;
        }
    }

    /******************************************************************************************************
    * @Description        : Function to detele opportunity team members                                                                                            
    * @Param              : List< Contributor__c > newList => new list  
    * @Return             : void                                                                         
    *******************************************************************************************************/
    public static void deleteOpptyTeamMembers( List< Contributor__c > newList ){
        List< OpportunityTeamMember  > lstOpptyTeamMember = new List< OpportunityTeamMember  >();
        Set< Id > setUserIds = new Set< Id >();
        Set< Id > setOpptyIds = new Set< Id >();
        
        for( Contributor__c cont : newList ){
            setUserIds.add( cont.User__c );
            setOpptyIds.add( cont.Opportunity__c );
        }

        if( !setUserIds.isEmpty() && !setOpptyIds.isEmpty() ){
            for( OpportunityTeamMember otm : [ SELECT Id FROM OpportunityTeamMember WHERE UserId IN :setUserIds AND OpportunityId IN :setOpptyIds ] ){
                lstOpptyTeamMember.add( otm );
            }
        }

        if( !lstOpptyTeamMember.isEmpty() ){
            delete lstOpptyTeamMember;
        }
    }
}