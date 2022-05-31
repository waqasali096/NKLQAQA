/**
* Name:          BuildingTriggerHandler
* Description:   Trigger Handler for Building Trigger
* Author         Vishal Agrawal
*/
public class BuildingTriggerHandler {
    List<Building__c> recordNewList = new List<Building__c>();
    List<Building__c> recordOldList = new List<Building__c>();
    Map<Id, Building__c> recordNewMap = new Map<Id, Building__c>();
    Map<Id, Building__c> recordOldMap = new Map<Id, Building__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete, isBefore, isAfter = false;
    
    Public Static Boolean blnRecursivPDCRC = false;
    
    public BuildingTriggerHandler(List<Building__c> newList, List<Building__c> oldList, Map<Id, Building__c> newMap, Map<Id, Building__c> oldMap, 
                                  boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete, Boolean isBefore, Boolean isAfter){
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
    
    
    public void beforeInsertEvent(){
        sendBuildingERP();
        // GenerateInventoryCode.generateBuildingCode(recordNewList); // added by huzefa - 15 feb 2022
        updateBuildingDetails(recordNewList,recordOldMap); //Added by Shivani - 6th April 2022
    }
    
    public void AfterInsertEvent() {
       // buildingCountUpdateOnCluster(recordNewList);
        //UpdateRollups();
        updateRollupQueable();
        createBuildingERP();
    }
    
    public void BeforeUpdateEvent() {
        System.debug('Before Update Event started');
      //  UpdateRollups();
     //GenerateInventoryCode.generateBuildingCode(recordNewList); // added by huzefa - 15 feb 2022
        createBuildingERP();
        updateBuildingDetails(recordNewList,recordOldMap); //Added by Shivani - 6th April 2022
        System.debug('Before Update Event end');
    }
    
    public void AfterUpdateEvent() {
     //   buildingCountUpdateOnCluster(recordNewList);
       // UpdateRollups();
      // updateRollupQueable();
    }
    
    public void BeforeDeleteEvent() {  
       // UpdateRollups();
    }
    
    public void AfterUndeleteEvent() {
       // UpdateRollups();   
       updateRollupQueable();
    }
    
    public void AfterDeleteEvent() {
        //buildingCountUpdateOnCluster(recordOldList);   
        updateRollupQueable();
    }
    
     public void updateRollupQueable(){
        Set<Id> projectIdList = new Set<Id>();
        for(building__c u: recordNewList){
            if(u.Project__c!=null){
                projectIdList.add(u.Project__c);
            }
        }
      // CustomRollupsQueueable myJob = new CustomRollupsQueueable(projectIdList);
       // System.enqueueJob(myJob);
    }
    
    public void UpdateRollups(){
        // Add try catch for the whole method and log exceptions.
        try{
            // user already defined boolean instead of new.
            Map<String,String> recordCountFields = New Map<String,String>();
            Map<String,String> sumFields = New Map<String,String>(); 
            Set<Id> ClusterIdSet = New Set<Id>(); 
            Set<Id> BuildingIdSet = New Set<Id>(); 
            List<String> clusterFields = new List<String>(); 
            List<String> buildingFields = new List<String>();
            Map<Id,Integer> clusterToBuildingCount = New Map<Id,Integer>();
            
            Map<id,List<Id>> clusterToBuildingIdListMap = New Map<id,List<Id>>(); 
            Map<Id,Map<String,Decimal>> clusterIdToFieldValueMap = New  Map<Id,Map<String,Decimal>>(); 
            
            Map<Id,Integer> clusterToSoldbuildingCount = new Map<Id,Integer>();
            Map<Id,Integer> clusterToLeasedbuildingCount = new Map<Id,Integer>();
            Map<Id,Integer> clusterToAvailablebuildingCount = new Map<Id,Integer>();
            Map<Id,Integer> clusterToBookedbuildingCount = new Map<Id,Integer>();
            Map<Id,Integer> clusterToReservedbuildingCount = new Map<Id,Integer>();
            
            List<Cluster_Rollup_Fields__c> rollupfields = Cluster_Rollup_Fields__c.getall().values();
            
            for(Cluster_Rollup_Fields__c rollupField :rollupfields){  // for loop to capture field from custom setting as a string
                
                if(rollupField.SUM__c){
                    sumFields.put(rollupField.Building_Field__c, rollupField.Cluster_Field__c);
                }
                if(rollupField.COUNT__c){
                    recordCountFields.put(rollupField.Building_Field__c, rollupField.Cluster_Field__c);
                }
                if(rollupField.Building_Field__c != null && rollupField.Building_Field__c != ''){
                    buildingFields.add(rollupField.Building_Field__c);
                }
                if(rollupField.Cluster_Field__c != null && rollupField.Cluster_Field__c != ''){
                    clusterFields.add(rollupField.Cluster_Field__c);
                }
                
            }
            for(Building__c building : recordNewList){  // trigger loop of product for capturing ids of cluster & building
                
                ClusterIdSet.add(building.Cluster__c);
                BuildingIdSet.add(building.Id);
                if(!clusterToBuildingIdListMap.containsKey(building.Cluster__c)){
                    List<Id> idlist = New LIst<Id>();
                    idlist.add(building.id);
                    clusterToBuildingIdListMap.put(building.Cluster__c, idlist);
                }else{
                    clusterToBuildingIdListMap.get(building.Cluster__c).add(building.Id);
                }
                
            }
            Schema.SObjectType clusterObjectType = Schema.getGlobalDescribe().get('Cluster__c');
            Map<String, SObjectField> clusterFieldMap = clusterObjectType.getDescribe().fields.getMap();  // map of sobject field
            System.debug('@@@@##'+clusterFieldMap);
            Schema.SObjectType buildingObjectType = Schema.getGlobalDescribe().get('Building__c');
            Map<String, SObjectField> buildingFieldMap = buildingObjectType.getDescribe().fields.getMap();  // map of sobject field
            
            
            // -----------------------cluster qry--------------------------------------------------        
            String clusterqry = 'Select Id,';
            for(String unt : clusterFields){
                
                Schema.SobjectField theField = clusterFieldMap.get(unt);
                system.debug('the field '+theField);
                if(theField!=null){
                    clusterqry = clusterqry + theField + ','; 
                }
            }
            clusterqry = clusterqry.removeEnd(',');
            clusterqry = clusterqry + ' from Cluster__c where Id IN: ClusterIdSet';
            
            system.debug('qry==== ' + clusterqry);
            List<Cluster__c>clusterList = New List<Cluster__c>(); 
            List<Cluster__c> clusterLstToUpdate = new List<Cluster__c>();
            
            clusterList = Database.query(clusterqry);
            
            
            //----------------------ends---------------------------------------------------------
            //
            //   -------------------------------------------------building qry---------------------------
            String buildingqry = 'Select Id,';
            for(String buildingFieldstring : buildingFields){
                
                Schema.SobjectField buildingField = buildingFieldMap.get(buildingFieldstring);
                System.debug('the building field '+buildingField);
                if(buildingField!=null){
                    buildingqry = buildingqry + buildingField + ','; 
                }
            }
            buildingqry = buildingqry.removeEnd(',');
            buildingqry = buildingqry + '  ,Cluster__c from Building__c where Cluster__c IN: ClusterIdSet';
            
            
            List<Building__c>buildingList = New List<Building__c>(); 
            
            buildingList = Database.query(buildingqry);
            
            //  ---------------------------------------------------------------------------------------        
            system.debug('qryres ' + buildingList);
            // Check if cluster exist to avoid null pointer exception
            for(Building__c building : buildingList){ 
                if(building.Cluster__c != Null)  {   
                    if(recordNewMap.containsKey(building.id)){
                        building = recordNewMap.get(building.id);
                    }
                    Map<String,Decimal> buildingFieldsum = New Map<String,Decimal>(); 
                    for(String fieldName : sumFields.keySet()){ 
                        Schema.SobjectField buildingFieldName = buildingFieldMap.get(fieldName); // never user number
                        if(Integer.valueof(building.get(buildingFieldName)) > 0){
                            buildingFieldsum.put(fieldName,Integer.valueof(building.get(buildingFieldName)));  // map for field string name and its value from record
                        }
                    }                   
                    if(!clusterIdToFieldValueMap.containsKey(building.Cluster__c)){
                        Map<String,Decimal> buildingFieldTobuildingFieldsum = New Map<String,Decimal>(); //NEVER use temp :D
                        buildingFieldTobuildingFieldsum.putAll(buildingFieldsum);
                        clusterToBuildingCount.put(building.Cluster__c,1);
                        clusterIdToFieldValueMap.put(building.Cluster__c,buildingFieldTobuildingFieldsum);            
                    }else{
                        Map<String,Decimal> buildingFieldTobuildingFieldsum = New Map<String,Decimal>();
                        buildingFieldTobuildingFieldsum.putAll(clusterIdToFieldValueMap.get(building.Cluster__c));
                        system.debug('buildingFieldTobuildingFieldsum if contains key '+ buildingFieldTobuildingFieldsum);
                        for(String st : buildingFieldTobuildingFieldsum.keySet()){
                            Decimal val = buildingFieldTobuildingFieldsum.get(st);
                            if(Integer.valueOf(buildingFieldsum.get(st)) > 0){
                                val = val + buildingFieldsum.get(st);
                                
                                buildingFieldTobuildingFieldsum.put(st,val); 
                            }
                        }
                        clusterIdToFieldValueMap.put(building.Cluster__c,buildingFieldTobuildingFieldsum);
                        Integer Productcount = clusterToBuildingCount.get(building.Cluster__c);
                        Productcount = Productcount + 1; 
                        clusterToBuildingCount.put(building.Cluster__c,Productcount);       
                    }
                }
            }
            
            for(Cluster__c cluster : clusterList){ // for loop for assigning values to cluster field and update
                if(clusterIdToFieldValueMap.containsKey(cluster.Id)){
                    Map<String,Decimal> clusterFieldToSumMap = New Map<String,Decimal>();
                    clusterFieldToSumMap.putAll(clusterIdToFieldValueMap.get(cluster.Id));                   
                    for(String str :clusterFieldToSumMap.keySet()){
                        Schema.SobjectField clusterFieldName = clusterFieldMap.get(sumFields.get(str    ));                        
                        Decimal sumOfField = 0.00;                                             
                        if(clusterFieldName!=null){
                            if(Integer.valueof(cluster.get(clusterFieldName)) > 0 ){
                                sumOfField  = Integer.valueof(cluster.get(clusterFieldName));              
                                sumOfField = clusterFieldToSumMap.get(str);                         
                                cluster.put(clusterFieldName,sumOfField);
                            }else{
                                sumOfField = clusterFieldToSumMap.get(str);
                                cluster.put(clusterFieldName,sumOfField);
                            }
                        }    
                    }
                }
                cluster.No_of_Buildings__c = clusterToBuildingCount.get(cluster.id);
                
                clusterLstToUpdate.add(cluster);
            }            
            //update clusterList;  
            if(clusterLstToUpdate.size()>0){
                update clusterLstToUpdate;
            }
            
            // logger object
            // only one try catch        
            //Add count logic in this method only.
        }catch(Exception ex){
            system.debug('error is '+ ex.getCause() + ' '+ ex.getMessage()+ ' '+ ex.getLineNumber());
        }
    }
    public void buildingCountUpdateOnCluster (List<building__c> buildingList) {
        //Savepoint sp = Database.setSavepoint();
        Set<Id> setClusterIds = new Set<Id>();
        //try{
            
        
        for(building__c buildingRecord : buildingList){
            setClusterIds.add(buildingRecord.Cluster__c);
            system.debug('==ProdIds==' + buildingRecord.Cluster__c);
        }
        
        for(building__c buildingRecord : buildingList){
            //Condition to check if the Building lookup field is updated or not
            if(recordOldMap !=null && recordOldMap.get(buildingRecord.Id) != null && buildingRecord.Cluster__c!=recordOldMap.get(buildingRecord.Id).Cluster__c){
                setClusterIds.add(buildingRecord.Cluster__c);
                setClusterIds.add(recordOldMap.get(buildingRecord.Id).Cluster__c);                
            }
        }
        for(building__c buildingRecord : buildingList) {
            setClusterIds.add(buildingRecord.Cluster__c);
        }
        
        List<Cluster__c> clusterList=new List<Cluster__c>();
        Decimal availableUnits = 0;
        Decimal soldUnits = 0;
        Decimal leasedUnits = 0;
        Decimal reservedUnits=0;
        Decimal bookedUnits = 0;
        Decimal totalUnits = 0;
        for(Cluster__c cluster :[Select id,No_of_buildings__c ,(Select id,Leased_Units__c, Available_Units__c, Sold_Units__c, Reserved_Units__c, Booked_Units__c, No_of_Units__c from buildings__r) from Cluster__c where Id in : setClusterIds]){
            availableUnits = 0;
            soldUnits = 0;
            leasedUnits = 0;
            reservedUnits=0;
            bookedUnits = 0;
            totalUnits = 0;
            system.debug('==buildingSize==' + cluster.buildings__r.size());
            if(cluster.buildings__r.size()>0){
                for(building__c building: cluster.buildings__r){
                    availableUnits+= (null == building.Available_Units__c ) ? 0 : building.Available_Units__c;
                    soldUnits += (null == building.Sold_Units__c ) ? 0 : building.Sold_Units__c;
                    leasedUnits += (null == building.Leased_Units__c ) ? 0 : building.Leased_Units__c;
                    reservedUnits += (null == building.Reserved_Units__c ) ? 0 : building.Reserved_Units__c;
                    bookedUnits += (null == building.Booked_Units__c ) ? 0 : building.Booked_Units__c;
                    totalUnits+= (null == building.No_of_Units__c ) ? 0 : building.No_of_Units__c;}}
            cluster.No_of_buildings__c = cluster.buildings__r.size();
            system.debug('==buildingSize==' + cluster.No_of_buildings__c);
            cluster.Available_Units__c = availableUnits;
            cluster.Sold_Units__c = soldUnits;
            cluster.Leased_Units__c = leasedUnits;
            cluster.Reserved_Units__c = reservedUnits;
            cluster.Booked_Units__c = bookedUnits;
            cluster.No_of_Units__c = totalUnits;
            clusterList.add(cluster);
        }
        if(!clusterList.isEmpty()){
           
            update clusterList;
        }
      //}
        //catch(exception e){
            //database.rollback(sp);
            //system.debug('*****'+e);
            //buildingList[0].addError('Rollup can not be updated from blank values on child records');
        //}
    }  
    public void createBuildingERP(){
        Set<Id> buildId = new Set<Id>();
        
        for(Building__c bld : recordNewList){
            if(bld.Send_Building_to_ERP__c && (recordOldMap == null || bld.Send_Building_to_ERP__c != recordOldMap.get(bld.Id).Send_Building_to_ERP__c)){
                buildId.add(bld.Id);
                if(recordOldMap != null) {
                    bld.Send_Building_to_ERP__c = false;
                }
            }
        }
        if(!buildId.isEmpty()){
            createBuilding(buildId);
        }
    } 
    /*Method: createBuilding
* Desc:  Create Bulding in ERP
* Param: Building - Set of Building Ids
* Return: None
*/
    //@Future(Callout=true)
    public Static void createBuilding(Set<Id> buildingIds) {
        ERPIntegrationHelper.createBuilding(buildingIds);
    }

    /**
    * This method is used to update bussiness details on in Unit Record.
    * @date   06/06/2022
    * @author Shivani Rathi
    */
    public static void updateBuildingDetails(List<Building__c> newList, Map<Id,Building__c> oldMap){
        Set<String> projectIds = new Set<String>();
        for(Building__c objBuilding : newList){
            if(String.isNotBlank(objBuilding.Project__c) || (oldMap != null && oldMap.get(objBuilding.Id).Project__c != objBuilding.Project__c)){
                projectIds.add(objBuilding.Project__c);
            }
        }
        Map<Id,Project__c> mapProject = new Map<Id,Project__c>([SELECT ID,Business_Group__c, Business_Unit__c, Project_Purpose__c FROM Project__c WHERE ID IN : projectIds]);
        for(Building__c objBuilding : newList){
            if(String.isNotBlank(objBuilding.Project__c) && mapProject.containsKey(objBuilding.Project__c)){
                objBuilding.Business_Group__c = mapProject.get(objBuilding.Project__c).Business_Group__c;
                objBuilding.Business_Unit__c = mapProject.get(objBuilding.Project__c).Business_Unit__c;
                objBuilding.Building_Purpose__c = mapProject.get(objBuilding.Project__c).Project_Purpose__c;
            }
        }
    }
    
    /**
    * This method is used to check checkbox Send Building to ERP.
    * @author Vishal A
    */
    public void sendBuildingERP() {
        for(building__c u: recordNewList){
            u.Send_Building_to_ERP__c = true;
        }
    }
}