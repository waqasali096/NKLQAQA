/*
Author - Huzefa
Date - 15 Feb 2022
Comment - Created to generate unique building, floor and unit code for inventory objects
*/

public class GenerateInventoryCode{

    
    public static void generateFloorCode(List<Floor__c> listFloor){
        
        for(Floor__c floorLoop : listFloor){
            if(!String.isBlank(floorLoop.Building_Code__c) && !String.isBlank(floorLoop.Floor_Alias__c))
            floorLoop.Floor_Code__c = floorLoop.Building_Code__c+'-'+floorLoop.Floor_Alias__c;
  //          else
            //floorLoop.addError('Cannot Generate Floor Code as Floor Alias or Parent code is missing');
        
        }
    
    }
    
    
    public static void generateUnitCode(List<Unit__c> listUnits){
        
        for(Unit__c unitLoop : listUnits){
        
            if((!String.isBlank(unitLoop.Unit_type__c) && unitLoop.Unit_type__c.containsIgnoreCase('villa')) || String.isBlank(unitLoop.floor__c) ){
                if(!String.isBlank(unitLoop.Unit_Alias__c))
                unitLoop.Unit_Code__c = unitLoop.Unit_Alias__c;
            //    else
             //   unitLoop.addError('Cannot Generate Unit Code as Unit Alias is blank');
            }
            else{
            if(!String.isBlank(unitLoop.Floor_Code__c) && !String.isBlank(unitLoop.Unit_Alias__c))
            unitLoop.Unit_Code__c = unitLoop.Floor_Code__c+'-'+unitLoop.Unit_Alias__c;
          //  else
            //unitLoop.addError('Cannot Generate Unit Code as either Unit Alias or Parent code is missing');
            }
        
        }
    
    }
    
    public static void generateBuildingCode(List<Building__c> listBuilding){
        
        for(Building__c buildingLoop: listBuilding){
            if(!String.isBlank(buildingLoop.Building_Alias__c))
            buildingLoop.Building_Code__c = buildingLoop.Building_Alias__c;
           // else
           // buildingLoop.addError('Cannot Generate Building Code as Building Alias is blank');
        
        }
    
    }
    
    



}