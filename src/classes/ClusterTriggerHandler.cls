/*
Class Name: clusterTriggerHandler
Class Description: Trigger handler for Cluster__c object
Author: Gaurav Malik
Created Date: 14 Jan 2021
Updated by: 
Last Update Date:
*/
public class ClusterTriggerHandler {
    List<Cluster__c> newList = new List<Cluster__c>();
    List<Cluster__c> oldList = new List<Cluster__c>();
    Map<Id, Cluster__c> newMap = new Map<Id, Cluster__c>();
    Map<Id, Cluster__c> oldMap = new Map<Id, Cluster__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public ClusterTriggerHandler(List<Cluster__c> newList, List<Cluster__c> oldList, Map<Id, Cluster__c> newMap, Map<Id, Cluster__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
        this.newList = newList;
        this.oldList = oldList;
        this.newMap = newMap;
        this.oldMap = oldMap;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    public void BeforeInsertEvent() {
        updateClusterDetails(newList, oldMap); // Added by Shivani - 6th April 2022
    }
    
    public void AfterInsertEvent() {
       // clusterCountUpdateOnProject(newList);
       // UpdateRollups();
        updateRollupQueable();
    }
    
    public void BeforeUpdateEvent() {
        System.debug('Before Update Event started');
      //  UpdateRollups();
        updateClusterDetails(newList, oldMap); // Added by Shivani - 6th April 2022

        System.debug('Before Update Event end');
    }
    
    public void AfterUpdateEvent() {
        //clusterCountUpdateOnProject(newList);
        //UpdateRollups();
        // updateRollupQueable();
    }
    
    public void BeforeDeleteEvent() {  
      //  UpdateRollups();
    }
    
    public void AfterUndeleteEvent() {
      //  UpdateRollups();   
       updateRollupQueable();
    }
    
    public void AfterDeleteEvent() {
      //  clusterCountUpdateOnProject(oldList);   
    //   updateRollupQueable();
    }
    
     public void updateRollupQueable(){
        Set<Id> projectIdList = new Set<Id>();
        for(Cluster__c u: newList){
            if(u.Project__c!=null){
                projectIdList.add(u.Project__c);
            }
        }
        //CustomRollupsQueueable myJob = new CustomRollupsQueueable(projectIdList);
       // System.enqueueJob(myJob);
    }

    /**
    * This method is used to update bussiness details on in Cluster Record.
    * @date   06/06/2022
    * @author Shivani Rathi
    */
    public static void updateClusterDetails(List<Cluster__c> newList, Map<Id,Cluster__c> oldMap){
        Set<String> projectIds = new Set<String>();
        for(Cluster__c objCluster : newList){
            if(String.isNotBlank(objCluster.Project__c) || (oldMap != null && oldMap.get(objCluster.Id).Project__c != objCluster.Project__c)){
                projectIds.add(objCluster.Project__c);
            }
        }
        Map<Id,Project__c> mapProject = new Map<Id,Project__c>([SELECT ID,Business_Group__c, Business_Unit__c, Project_Purpose__c FROM Project__c WHERE ID IN : projectIds]);
        for(Cluster__c objCluster : newList){
            if(String.isNotBlank(objCluster.Project__c) && mapProject.containsKey(objCluster.Project__c)){
                objCluster.Business_Group__c = mapProject.get(objCluster.Project__c).Business_Group__c;
                objCluster.Business_Unit__c = mapProject.get(objCluster.Project__c).Business_Unit__c;
                objCluster.Cluster_Purpose__c = mapProject.get(objCluster.Project__c).Project_Purpose__c;
            }
        }
    }   
}