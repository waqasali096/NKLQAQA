/*
Class Name: SpaceTyeUnitUpdate
Class Description: this class is created to dry update the unit with spacetype for leasing
Author: Swapnil Mohite
Created Date: 08 May 2021
*/
public class SpaceTypeUnitUpdate {
     /**
* This method is used to update spacetype with spacetype fields on unit are changed or new unit is inserted
* @date   21/01/2022
* @author Swapnil Mohite
*/
    public static void updateSpaceType(List<Unit__c> newList,Map<Id,Unit__c> oldMap){
        Set<String> noOfBedSet = new Set<String>();
        Set<String> unitTypeSet = new Set<String>();
        Set<String> propertyTypeSet = new Set<String>();
        Set<Id> unitIdSet = new Set<Id>();
        Map<String,Space_Type__c> spaceTypeMap = new Map<String,Space_Type__c>();
        for(Unit__c unitObj : newList){
            if(oldMap == null || (unitObj.Leasing_Property_Type__c != oldMap.get(unitObj.Id).leasing_property_type__c ||
                                  unitObj.Unit_space_Type__c != oldMap.get(unitObj.Id).Unit_space_Type__c || 
                                  unitObj.No_of_Bedrooms__c != oldMap.get(unitObj.Id).No_of_Bedrooms__c)){
                                      if(String.isNotBlank(unitObj.No_of_Bedrooms__c)){
                                          noOfBedSet.add(unitObj.No_of_Bedrooms__c);
                                      }
                                      if(String.isNotBlank(unitObj.Leasing_Property_Type__c)){
                                          propertyTypeSet.add(unitObj.Leasing_Property_Type__c);
                                      }
                                      if(String.isNotBlank(unitObj.Unit_space_Type__c)){
                                          unitTypeSet.add(unitObj.Unit_space_Type__c);
                                      }
                                      unitIdSet.add(unitObj.Id); 
                                  }
        }
        system.debug('noOfBedSet-->'+noOfBedSet);
        system.debug('propertyTypeSet-->'+propertyTypeSet);
        system.debug('unitTypeSet-->'+unitTypeSet);
        if(unitIdSet.size() > 0){
            List<Space_Type__c> spaceTypeList = [SELECT id,name,no_of_bedrooms__c,Unit_Type__c,Property_Type__c  
                                                 FROM Space_Type__c
                                                 WHERE purpose__c = 'Leasing' and
                                                 (No_of_bedrooms__c IN : noOfBedSet or  Unit_Type__c IN : unitTypeSet or  property_type__c IN : propertyTypeSet)];
            for(Space_Type__c spaceType : spaceTypeList){
                String key= '';
                if(String.isNotBlank(spaceType.No_of_bedrooms__c)){
                    key = spaceType.No_of_bedrooms__c + '-';
                }
                if(String.isNotBlank(spaceType.property_type__c)){
                    if(String.isBlank(key)){
                        key = spaceType.property_type__c + '-';
                    }else{
                        key = key + spaceType.property_type__c + '-';
                    } 
                }
                if(String.isNotBlank(spaceType.unit_Type__c)){
                     if(String.isBlank(key)){
                        key = spaceType.unit_type__c;
                    }else{
                        key = key + spaceType.unit_type__c;
                    }
                }
                
                spaceTypeMap.put(key,spaceType); 
            }
            System.debug('spaceTypeMap->'+spaceTypeMap);
            for(Unit__c unitObj : newList){
                String key='';
                if(String.isNotBlank(unitObj.No_of_bedrooms__c)){
                    key = unitObj.No_of_bedrooms__c + '-';
                }
                if(String.isNotBlank(unitObj.Leasing_Property_Type__c)){
                     if(String.isBlank(key)){
                        key = unitObj.Leasing_Property_Type__c + '-';
                    }else{
                        key = key + unitObj.Leasing_Property_Type__c + '-';
                    } 
                }
                if(String.isNotBlank(unitObj.Unit_space_Type__c)){
                    if(String.isBlank(key)){
                        key = unitObj.Unit_space_Type__c;
                    }else{
                        key = key + unitObj.Unit_space_Type__c;
                    }   
                }
                system.debug('Key->'+key);
                if(spaceTypeMap.containsKey(key)){
                     system.debug('Key from inside->'+key);
                    unitObj.Unit_Leasing_Type__c = spaceTypeMap.get(key).Id;
                    
                }
                UnitObj.Project_Name_Sharing__c = unitObj.project__r.name;
            }
            update newList;
        }
    }
     /**
* This method has param project id set and update the required fields on all units
* @date   08/05/2022
* @author Swapnil Mohite
*/
    public static void updateUnits(Set<Id> projectIdSet){ 
    List<Unit__c> unitList = [select id,unit_space_type__c, Leasing_Property_Type__c,no_of_bedrooms__c,unit_leasing_type__c,unit_leasing_type__r.name,project__r.name 
                          from unit__c 
                          where project__c  IN: projectIdSet
                          limit 1000];
 // and unit_leasing_type__c = null 
			SpaceTypeUnitUpdate.updateSpaceType(unitList,null);
    
    }
      /**
* This method is pass project id and update the building sharing
* @date   08/05/2022
* @author Swapnil Mohite
*/
    public static void updateBuildingSharing(Set<Id> projectIdSet){ 
    List<Building__c> buildingList = [select id,project_name__c,project__r.name
                          from Building__c 
                          where project__c  IN: projectIdSet
                          limit 1000];
        for(Building__c b : buildingList){
            b.project_name__c = b.project__r.name;
        }
      update buildingList;
    }
      /**
* This method is pass project id and update the cluster sharing
* @date   08/05/2022
* @author Swapnil Mohite
*/
    public static void updateClusterSharing(Set<Id> projectIdSet){ 
    List<Cluster__c> clusterList = [select id,project_name__c,project__r.name
                          from Cluster__c 
                          where project__c  IN: projectIdSet
                          limit 1000];
        for(Cluster__c c : clusterList){
            c.project_name__c = c.project__r.name;
        }
     update clusterList;
    }
      /**
* This method is pass project id and update the required fields on all units
* @date   08/05/2022
* @author Swapnil Mohite
*/
    public static void updateFloorSharing(Set<Id> projectIdSet){ 
    List<Floor__c> floorList = [select id,project_name__c,project__r.name
                          from Floor__c 
                          where project__c  IN: projectIdSet
                          limit 1000];
        for(Floor__c f : floorList){
            f.project_name__c = f.project__r.name;
        }
     update floorList;
    }

    
}