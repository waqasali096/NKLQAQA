/*
Class Name: FloorTriggerHandler
Class Description: Trigger handler for Floor__c object
Author: Gaurav Malik
Created Date: 14 Jan 2021
Updated by: 
Last Update Date:
*/
public class FloorTriggerHandler {
    List<Floor__c> newList = new List<Floor__c>();
    List<Floor__c> oldList = new List<Floor__c>();
    Map<Id, Floor__c> newMap = new Map<Id, Floor__c>();
    Map<Id, Floor__c> oldMap = new Map<Id, Floor__c>();
    Boolean isInsert, isUpdate, isDelete, isUndelete = false;
    public static boolean recursionController = false;
    
    public FloorTriggerHandler(List<Floor__c> newList, List<Floor__c> oldList, Map<Id, Floor__c> newMap, Map<Id, Floor__c> oldMap, boolean isInsert, boolean isUpdate, Boolean isDelete, Boolean isUndelete) {
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
        for(Floor__c flr: newList){
            flr.Send_Floor_to_ERP__c = true;
        }
        // GenerateInventoryCode.generateFloorCode(newList); // added by huzefa - 15 feb 2022
        updateFloorDetails(newList,oldMap); //Added by Shivani - 6th April 2022
    }
    
    
    public void AfterInsertEvent() {
      //  floorCountUpdateOnBuilding(newList);
      //  UpdateRollups();
       updateRollupQueable();
        floorCreation();
    }
    
    public void BeforeUpdateEvent() {
        System.debug('Before Update Event started');
        //UpdateRollups();
        // GenerateInventoryCode.generateFloorCode(newList); // added by huzefa - 15 feb 2022
        floorCreation();
        System.debug('Before Update Event end');
        updateFloorDetails(newList,oldMap); //Added by Shivani - 6th April 2022
    }
    
    public void AfterUpdateEvent() {
        //floorCountUpdateOnBuilding(newList);
        //UpdateRollups();
        // updateRollupQueable();
    }
    
    public void BeforeDeleteEvent() {  
      //  UpdateRollups();
    }
    
    public void AfterUndeleteEvent() {
     //   UpdateRollups();   
      updateRollupQueable();
    }
    
    public void AfterDeleteEvent() {
      //  floorCountUpdateOnBuilding(oldList);   
      // updateRollupQueable();
    }
    
    public void updateRollupQueable(){
        Set<Id> projectIdList = new Set<Id>();
        for(Floor__c u: newList){
            if(u.Project__c!=null){
                projectIdList.add(u.Project__c);
            }
        }
     //   CustomRollupsQueueable myJob = new CustomRollupsQueueable(projectIdList);
      //  System.enqueueJob(myJob);
    }
    
    public void UpdateRollups(){
        // Add try catch for the whole method and log exceptions.
        try{
            // user already defined boolean instead of new.
            Map<String,String> recordCountFields = New Map<String,String>();
            Map<String,String> sumFields = New Map<String,String>(); 
            Set<Id> buildingIdSet = New Set<Id>(); 
            Set<Id> productIdSet = New Set<Id>(); 
            List<String> buildingFields = new List<String>(); 
            List<String> floorFields = new List<String>();
            Map<Id,Integer> buildingToProductCount = New Map<Id,Integer>();
            
            Map<id,List<Id>> buildingToProductIdListMap = New Map<id,List<Id>>(); 
            Map<Id,Map<String,Decimal>> buildingIdToFieldValueMap = New  Map<Id,Map<String,Decimal>>(); 
            
            
            List<Building_Rollup_fields__c> rollupfields = Building_Rollup_fields__c.getall().values();
            
            for(Building_Rollup_fields__c rollupField :rollupfields){  // for loop to capture field from custom setting as a string
                
                if(rollupField.SUM__c){
                    sumFields.put(rollupField.floor_Field__c, rollupField.Building_Field__c);
                }
                if(rollupField.COUNT__c){
                    recordCountFields.put(rollupField.floor_Field__c, rollupField.Building_Field__c);
                }
                if(rollupField.floor_Field__c != null && rollupField.floor_Field__c != ''){
                    floorFields.add(rollupField.floor_Field__c);
                }
                if(rollupField.Building_Field__c != null && rollupField.Building_Field__c != ''){
                    buildingFields.add(rollupField.Building_Field__c);
                }
                
            }
            for(floor__c product : newList){  // trigger loop of product for capturing ids of building & product
                
                buildingIdSet.add(product.Building__c);
                productIdSet.add(product.Id);
                if(!buildingToProductIdListMap.containsKey(product.Building__c)){
                    List<Id> idlist = New LIst<Id>();
                    idlist.add(product.id);
                    buildingToProductIdListMap.put(product.Building__c, idlist);
                }else{
                    buildingToProductIdListMap.get(product.Building__c).add(product.Id);
                }
                
            }
            Schema.SObjectType bldgobjectType = Schema.getGlobalDescribe().get('Building__c');
            Map<String, SObjectField> BuildingfieldMap = bldgobjectType.getDescribe().fields.getMap();  // map of sobject field
            
            Schema.SObjectType floorobjectType = Schema.getGlobalDescribe().get('floor__c');
            Map<String, SObjectField> floorfieldMap = floorobjectType.getDescribe().fields.getMap();  // map of sobject field
            
            
            // -----------------------building qry--------------------------------------------------        
            String bldgqry = 'Select Id,';
            for(String unt : buildingFields){
                
                Schema.SobjectField theField = BuildingfieldMap.get(unt);
                if(theField!=null){
                    bldgqry = bldgqry + theField + ','; }
            }
            bldgqry = bldgqry.removeEnd(',');
            bldgqry = bldgqry + ' from Building__c where Id IN: buildingIdSet';
            
            system.debug('qry==== ' + bldgqry);
            List<Building__c>buildingList = New List<Building__c>(); 
            List<Building__c> buildingLstToUpdate = new List<Building__c>();
            
            buildingList = Database.query(bldgqry);
            
            
            //----------------------ends---------------------------------------------------------
            //
            //   -------------------------------------------------Product qry---------------------------
            String Productqry = 'Select Id,';
            for(String floorFieldString : floorFields){
                
                Schema.SobjectField floorField = floorfieldMap.get(floorFieldString);
                if(floorField!=null){
                    Productqry = Productqry + floorField + ','; 
                }
            }
            Productqry = Productqry.removeEnd(',');
            Productqry = Productqry + ' ,Building__c from floor__c where Building__c IN: buildingIdSet';
            
            
            List<floor__c>ProductList = New List<floor__c>(); 
            
            ProductList = Database.query(Productqry);
            
            
            
            //  ---------------------------------------------------------------------------------------        
            system.debug('qryres ' + ProductList);
            // Check if building exist to avoid null pointer exception
            for(floor__c product : ProductList){ 
                if(product.Building__c != Null)  {   
                    if(newMap.containsKey(product.id)){
                        product = newMap.get(product.id);
                    }
                    Map<String,Decimal> floorFieldSum = New Map<String,Decimal>(); 
                    for(String fieldName : sumFields.keySet()){ 
                        Schema.SobjectField floorFieldName = floorfieldMap.get(fieldName); // never user number
                        if(Integer.valueof(product.get(floorFieldName)) > 0){
                            floorFieldSum.put(fieldName,Integer.valueof(product.get(floorFieldName)));  // map for field string name and its value from record
                        }
                    }
                    system.debug('floorFieldSum is '+ floorFieldSum);
                    if(!buildingIdToFieldValueMap.containsKey(product.Building__c)){
                        Map<String,Decimal> floorFieldTofloorFieldSum = New Map<String,Decimal>(); //NEVER use temp :D
                        floorFieldTofloorFieldSum.putAll(floorFieldSum);
                        system.debug('floorFieldTofloorFieldSum if not contains key '+ floorFieldTofloorFieldSum);
                        buildingIdToFieldValueMap.put(product.Building__c,floorFieldTofloorFieldSum);
                        system.debug('buildingIdToFieldValueMap if not contains key '+ buildingIdToFieldValueMap);
                        buildingToProductCount.put(product.Building__c,1);
                    }else{
                        Map<String,Decimal> floorFieldTofloorFieldSum = New Map<String,Decimal>();
                        floorFieldTofloorFieldSum.putAll(buildingIdToFieldValueMap.get(product.Building__c));
                        system.debug('floorFieldTofloorFieldSum if contains key '+ floorFieldTofloorFieldSum);
                        for(String st : floorFieldTofloorFieldSum.keySet()){
                            Decimal val = floorFieldTofloorFieldSum.get(st);
                            if(Integer.valueOf(floorFieldSum.get(st)) > 0){
                                val = val + floorFieldSum.get(st);
                                
                                floorFieldTofloorFieldSum.put(st,val); 
                            }
                        }
                        buildingIdToFieldValueMap.put(product.Building__c,floorFieldTofloorFieldSum);
                        Integer Productcount = buildingToProductCount.get(product.Building__c);
                        Productcount = Productcount + 1; 
                        buildingToProductCount.put(product.Building__c,Productcount);
                    }
                }
            }
            
            for(Building__c building : buildingList){ // for loop for assigning values to building field and update
                if(buildingIdToFieldValueMap.containsKey(building.Id)){
                    Map<String,Decimal> buildingFieldToSumMap = New Map<String,Decimal>();
                    buildingFieldToSumMap.putAll(buildingIdToFieldValueMap.get(building.Id));
                    system.debug('buildingFieldToSumMap.keySet() is '+ buildingFieldToSumMap.keySet());
                    for(String str :buildingFieldToSumMap.keySet()){
                        Schema.SobjectField buildingFieldName = BuildingfieldMap.get(sumFields.get(str));
                        
                        Decimal sumOfField = 0.00;
                        // system.debug('building.get(buildingFieldName) is '+ building.get(buildingFieldName));
                        system.debug('buildingFieldName is '+ buildingFieldName );
                        if(buildingFieldName!=null){
                            if(Integer.valueof(building.get(buildingFieldName)) > 0 ){
                                sumOfField  = Integer.valueof(building.get(buildingFieldName));
                                
                                sumOfField = buildingFieldToSumMap.get(str);
                                
                                building.put(buildingFieldName,sumOfField);
                            }else{
                                sumOfField = buildingFieldToSumMap.get(str);
                                building.put(buildingFieldName,sumOfField);
                            }
                        }
                        system.debug('building is '+ building);
                        
                        
                        
                    }
                }
                system.debug('building is '+ building);
                building.No_of_floors__c = buildingToProductCount.get(building.id);
                buildingLstToUpdate.add(building);
            }
            
            system.debug('buildingList is '+ buildingList);
            
            //update buildingList;  
            if(buildingLstToUpdate.size()>0){
                update buildingLstToUpdate;
            }
            
            // logger object
            
            
            // only one try catch
            
            //Add count logic in this method only.
        }catch(Exception ex){
            
            system.debug('error is '+ ex.getCause() + ' '+ ex.getMessage()+ ' '+ ex.getLineNumber());
        }
    }
    

    public void floorCountUpdateOnBuilding (List<floor__c> floorList) {
        
        Set<Id> setBuildingIds = new Set<Id>();
        
        for(floor__c floorRecord : floorList){
            setBuildingIds.add(floorRecord.Building__c);
            system.debug('==ProdIds==' + floorRecord.Building__c);
            system.debug('==setBuildingIds==' + floorRecord.Building__c);
        }
        
        for(floor__c floorRecord : floorList){
            //Condition to check if the Building lookup field is updated or not
            if(oldMap !=null && oldMap.get(floorRecord.Id) != null && floorRecord.Building__c!=oldMap.get(floorRecord.Id).Building__c){
                setBuildingIds.add(floorRecord.Building__c);
                setBuildingIds.add(oldMap.get(floorRecord.Id).Building__c);
                system.debug('==setBuildingIds==' + setBuildingIds);
            }
        }
        
        for(floor__c floorRecord : floorList) {
            setBuildingIds.add(floorRecord.Building__c);
        }
        
        List<Building__c> buildingList=new List<Building__c>();
        Decimal availableUnits = 0;
        Decimal soldUnits = 0;
        Decimal leasedUnits = 0;
        Decimal reservedUnits=0;
        Decimal bookedUnits = 0;
        Decimal totalUnits = 0;
        for(Building__c building :[Select id,No_of_floors__c ,(Select id,Leased_Units__c, Available_Units__c, Sold_Units__c, Reserved_Units__c, Booked_Units__c, Total_Units__c from floors__r) from Building__c where Id in : setBuildingIds]){
            availableUnits = 0;
            soldUnits = 0;
            leasedUnits = 0;
            reservedUnits=0;
            bookedUnits = 0;
            totalUnits = 0;
            if(building.Floors__r.size()>0){
                for(Floor__c floor: building.Floors__r){
                    
                    availableUnits+= (null == floor.Available_Units__c) ? 0 : floor.Available_Units__c;
                    soldUnits += (null == floor.Sold_Units__c) ? 0 : floor.Available_Units__c;
                    leasedUnits += (null == floor.Leased_Units__c) ? 0 : floor.Available_Units__c;
                    reservedUnits += (null == floor.Reserved_Units__c) ? 0 : floor.Available_Units__c;
                    bookedUnits += (null == floor.Booked_Units__c) ? 0 : floor.Available_Units__c; 
                    totalUnits+= (null == floor.Total_Units__c) ? 0 : floor.Available_Units__c;
                }
            }
            system.debug('==floorSize==' + building.floors__r.size());
            building.No_of_floors__c = building.floors__r.size();
            building.Available_Units__c = availableUnits;
            building.Sold_Units__c = soldUnits;
            building.Leased_Units__c = leasedUnits;
            building.Reserved_Units__c = reservedUnits;
            building.Booked_Units__c = bookedUnits;
            building.No_of_Units__c = totalUnits;
            buildingList.add(building);
        }
        
        
        if(!buildingList.isEmpty()){
            
            system.debug('==buildingList==' + buildingList);
            update buildingList;
            
            
        }
        
    }
    
    //Check for ERP criteria and call
    public void floorCreation() {
        Set<Id> florId = new Set<Id>();
        
        for(Floor__c flr : newList){
            if(flr.Send_Floor_to_ERP__c && (oldMap == null || flr.Send_Floor_to_ERP__c != oldMap.get(flr.Id).Send_Floor_to_ERP__c)){
                florId.add(flr.Id);
                if(oldMap != null) {
                    flr.Send_Floor_to_ERP__c = false;
                }
            }
        }
        if(!florId.isEmpty()){
            createFloor(florId);
        }
    }
    
     /*Method: createFloor
* Desc:  Create Floor in ERP
* Param: Floor - Set of Floor Ids
* Return: None
*/
    //@Future(Callout=true)
    public Static void createFloor(Set<Id> floorIds) {
        ERPIntegrationHelper.createFloor(floorIds);
    }
    /**
    * This method is used to update bussiness details on in Floor Record.
    * @date   06/04/2022
    * @author Shivani Rathi
    */
    public static void updateFloorDetails(List<Floor__c> newList, Map<Id,Floor__c> oldMap){
        Set<String> buildingIds = new Set<String>();
        for(Floor__c objFloor : newList){
            if(String.isNotBlank(objFloor.Building__c) || (oldMap != null && oldMap.get(objFloor.Id).Building__c != objFloor.Building__c)){
                buildingIds.add(objFloor.Building__c);
            }
        }
        Map<Id,Building__c> mapBuilding = new Map<Id,Building__c>([SELECT ID,Business_Group__c, Business_Unit__c, Building_Purpose__c, Project__c, 
                                                                        Cluster__c FROM Building__c WHERE ID IN : buildingIds]);
        for(Floor__c objFloor : newList){
            if(String.isNotBlank(objFloor.Building__c) && mapBuilding.containsKey(objFloor.Building__c)){
                objFloor.Business_Group__c = mapBuilding.get(objFloor.Building__c).Business_Group__c;
                objFloor.Business_Unit__c = mapBuilding.get(objFloor.Building__c).Business_Unit__c;
                objFloor.Floor_Purpose__c = mapBuilding.get(objFloor.Building__c).Building_Purpose__c;
                objFloor.Project__c = mapBuilding.get(objFloor.Building__c).Project__c;
                objFloor.Cluster__c = mapBuilding.get(objFloor.Building__c).Cluster__c;

            }
        }
    }
}