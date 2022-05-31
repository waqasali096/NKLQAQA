/*
Class Name:                 RollupsQueueable
Class Description:          Runs whenever DML operation on inventory objects to calculate rollups 
Author:                     Swapnil Mohite
Created Date:               15/02/2021
Updated by:
Last Update Date:
*/
public class CustomRollupsQueueable implements Queueable {
    
    Set<Id> projectIds = new Set<Id>(); // Project Id set will come from inventory object(Unit,Floor,Building,Cluster) trigger
    
    //constructor to initialize the set of project ids
    public CustomRollupsQueueable(Set<Id> projectIdSet){
        this.projectIds= projectIdSet;
    }
    
    /*
*@ This method will calculate rollups and update it on respective records
* @date   15/02/2022
* @author Swapnil Mohite
*/    
    public void execute(QueueableContext context) {
        //   if(system.Label.EnableRollups == 'true'){
        //project rollup vairables 
        
        Map<Id,Decimal> availableUnitProjectMap = new Map<id,decimal>();
        Map<Id,Decimal> bookedUnitProjectMap = new Map<id,decimal>();
        Map<Id,Decimal> leasedUnitProjectMap = new Map<id,decimal>();
        Map<Id,Decimal> soldUnitProjectMap = new Map<id,decimal>();
        Map<Id,Decimal> reservedUnitProjectMap = new Map<id,decimal>();
        Map<Id,Decimal> othersUnitProjectMap = new Map<id,decimal>();
        Map<Id,Decimal> vacantUnitProjectMap = new Map<id,decimal>();
        
        // cluster rollup variables
        Map<Id,Decimal> totalUnitClusterMap = new Map<id,decimal>();
        Map<Id,Decimal> availableUnitClusterMap = new Map<id,decimal>();
        Map<Id,Decimal> bookedUnitClusterMap = new Map<id,decimal>();
        Map<Id,Decimal> leasedUnitClusterMap = new Map<id,decimal>();
        Map<Id,Decimal> soldUnitClusterMap = new Map<id,decimal>();
        Map<Id,Decimal> reservedUnitClusterMap = new Map<id,decimal>();
        Map<Id,Decimal> noBuildingClusterMap = new Map<id,decimal>();
        Map<Id,Decimal> othersUnitClusterMap = new Map<id,decimal>();
        Map<Id,Decimal> vacantUnitClusterMap = new Map<id,decimal>();
        
        
        // Building rollup variables
        Map<Id,Decimal> totalUnitBuildingMap = new Map<id,decimal>();
        Map<Id,Decimal> availableUnitBuildingMap = new Map<id,decimal>();
        Map<Id,Decimal> bookedUnitBuildingMap = new Map<id,decimal>();
        Map<Id,Decimal> leasedUnitBuildingMap = new Map<id,decimal>();
        Map<Id,Decimal> soldUnitBuildingMap = new Map<id,decimal>();
        Map<Id,Decimal> reservedUnitBuildingMap = new Map<id,decimal>();
        Map<Id,Decimal> noFloorBuildingMap = new Map<id,decimal>();
        Map<Id,Decimal> othersUnitBuildingMap = new Map<id,decimal>();
        Map<Id,Decimal> vacantUnitBuildingMap = new Map<id,decimal>();
        
        // Floor rollup variables
        Map<Id,Decimal> totalUnitFloorMap = new Map<id,decimal>();
        Map<Id,Decimal> availableUnitFloorMap = new Map<id,decimal>();
        Map<Id,Decimal> bookedUnitFloorMap = new Map<id,decimal>();
        Map<Id,Decimal> leasedUnitFloorMap = new Map<id,decimal>();
        Map<Id,Decimal> soldUnitFloorMap = new Map<id,decimal>();
        Map<Id,Decimal> reservedUnitFloorMap = new Map<id,decimal>();
        Map<Id,Decimal> noFloorFloorMap = new Map<id,decimal>();
        Map<Id,Decimal> othersUnitFloorMap = new Map<id,decimal>();
        Map<Id,Decimal> vacantUnitFloorMap = new Map<id,decimal>();
        
        // update lists
        List<Project__c> projUpdList = new List<Project__c>();
        List<cluster__c> clusterUpdList = new List<cluster__c>();
        List<Building__c> buildingUpdList = new List<Building__c>();
        List<Floor__c> floorUpdList = new List<Floor__c>();
        List<Cluster__c> clusterList = [SELECT id,Name 
                                        FROM Cluster__c 
                                        WHERE project__c IN : projectIds];
        List<Floor__c> floorList = [Select id,Name,building__c
                                    FROM Floor__c
                                    WHERE project__c IN : projectIds];
        List<Building__c> buildingList = [SELECT id,Name,cluster__c
                                          FROM Building__c 
                                          WHERE project__c IN : projectIds];
        List<Unit__c> unitList = [SELECT id,Name,Unit_status__c,floor__c,building__c,cluster__c,project__c 
                                  FROM Unit__c 
                                  WHERE project__c IN : projectIds];
        Map<Id,List<Unit__c>> buildUnitMap = new Map<Id,List<Unit__c>>();
        Map<Id,List<Unit__c>> floorUnitMap = new Map<Id,List<Unit__c>>();
        Map<Id,List<Unit__c>> clusterUnitMap = new Map<Id,List<Unit__c>>();
        For(Unit__c u : unitList){
            if(buildUnitMap.containsKey(u.Building__c)){
                buildUnitMap.get(u.building__c).add(u);
            }else{
                buildUnitMap.put(u.building__c,new List<Unit__c>{u});
            }
            if(floorUnitMap.containsKey(u.floor__c)){
                floorUnitMap.get(u.floor__c).add(u);
            }else{
                floorUnitMap.put(u.floor__c,new List<Unit__c>{u});
            }
            if(clusterUnitMap.containsKey(u.cluster__c)){
                clusterUnitMap.get(u.cluster__c).add(u);
            }else{
                clusterUnitMap.put(u.cluster__c,new List<Unit__c>{u});
            }  
        }
        
        
        for(Project__c project :[Select id,Name
                                 //(Select id,Name,Unit_status__c,floor__c,building__c,cluster__c,project__c from Units__r) 
                                 from Project__c 
                                 where Id in : projectIds]){
                                     system.debug('Rollups-->'+(Limits.getLimitQueryRows() - Limits.getQueryRows()));
                                     // project rollup initialization
                                     availableUnitProjectMap.put(project.Id,0);
                                     bookedUnitProjectMap.put(project.Id,0);
                                     leasedUnitProjectMap.put(project.Id,0);
                                     soldUnitProjectMap.put(project.Id,0);
                                     reservedUnitProjectMap.put(project.Id,0);
                                     othersUnitProjectMap.put(project.Id,0);
                                     vacantUnitProjectMap.put(project.Id,0);
                                     
                                     
                                     
                                     // code for Cluster rollups
                                     for(Cluster__c clusterLoop : clusterList){
                                         // Cluster rollup initialization
                                         
                                         totalUnitClusterMap.put(clusterLoop.Id,0);
                                         availableUnitClusterMap.put(clusterLoop.Id,0);
                                         bookedUnitClusterMap.put(clusterLoop.Id,0);
                                         leasedUnitClusterMap.put(clusterLoop.Id,0);
                                         soldUnitClusterMap.put(clusterLoop.Id,0);
                                         reservedUnitClusterMap.put(clusterLoop.Id,0);
                                         othersUnitClusterMap.put(clusterLoop.Id,0);
                                         vacantUnitClusterMap.put(clusterLoop.Id,0);
                                         if(clusterUnitMap.containsKey(clusterLoop.Id)){
                                             for(Unit__c unitLoop : clusterUnitMap.get(clusterLoop.Id)){
                                                 
                                                 if(unitLoop.Cluster__c == clusterLoop.Id){
                                                     totalUnitClusterMap.put(clusterLoop.Id,totalUnitClusterMap.get(clusterLoop.Id)+1);
                                                     if(unitLoop.Unit_Status__c == 'Available'){
                                                         availableUnitClusterMap.put(clusterLoop.Id,availableUnitClusterMap.get(clusterLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Booked'){
                                                         bookedUnitClusterMap.put(clusterLoop.Id,bookedUnitClusterMap.get(clusterLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Leased'){
                                                         leasedUnitClusterMap.put(clusterLoop.Id,leasedUnitClusterMap.get(clusterLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Sold'){
                                                         soldUnitClusterMap.put(clusterLoop.Id,soldUnitClusterMap.get(clusterLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Reserved'){
                                                         reservedUnitClusterMap.put(clusterLoop.Id,reservedUnitClusterMap.get(clusterLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Vacant'){
                                                         vacantUnitClusterMap.put(clusterLoop.Id,vacantUnitClusterMap.get(clusterLoop.Id)+1);
                                                     }else{
                                                         othersUnitClusterMap.put(clusterLoop.Id,othersUnitClusterMap.get(clusterLoop.Id)+1);
                                                     }
                                                 }
                                             }
                                         }
                                     } // code for Cluster rollup end
                                     system.debug('clusterCount-->'+totalUnitClusterMap);
                                     // code for Building rollup
                                     
                                     for(Building__c buildingLoop : buildingList){
                                         // Building rollup initialization
                                         totalUnitBuildingMap.put(buildingLoop.Id,0);
                                         availableUnitBuildingMap.put(buildingLoop.Id,0);
                                         bookedUnitBuildingMap.put(buildingLoop.Id,0);
                                         leasedUnitBuildingMap.put(buildingLoop.Id,0);
                                         soldUnitBuildingMap.put(buildingLoop.Id,0);
                                         reservedUnitBuildingMap.put(buildingLoop.Id,0);
                                         othersUnitBuildingMap.put(buildingLoop.Id,0);
                                         vacantUnitBuildingMap.put(buildingLoop.Id,0);
                                         
                                         // No of Building for Cluster rollup
                                         if(buildingLoop.cluster__c != null){
                                             noBuildingClusterMap.put(buildingLoop.cluster__c,
                                                                      noBuildingClusterMap.get(buildingLoop.cluster__c) == null ? 1 : noBuildingClusterMap.get(buildingLoop.cluster__c)+1);
                                             
                                         }
                                         if(buildUnitMap.containsKey(buildingLoop.Id)){  
                                             for(Unit__c unitLoop : buildUnitMap.get(buildingLoop.Id)){
                                                 if(unitLoop.Building__c == buildingLoop.Id){
                                                     totalUnitBuildingMap.put(buildingLoop.Id,totalUnitBuildingMap.get(buildingLoop.Id)+1);
                                                     if(unitLoop.Unit_Status__c == 'Available'){
                                                         availableUnitBuildingMap.put(buildingLoop.Id,availableUnitBuildingMap.get(buildingLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Booked'){
                                                         bookedUnitBuildingMap.put(buildingLoop.Id,bookedUnitBuildingMap.get(buildingLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Leased'){
                                                         leasedUnitBuildingMap.put(buildingLoop.Id,leasedUnitBuildingMap.get(buildingLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Sold'){
                                                         soldUnitBuildingMap.put(buildingLoop.Id,soldUnitBuildingMap.get(buildingLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Reserved'){
                                                         reservedUnitBuildingMap.put(buildingLoop.Id,reservedUnitBuildingMap.get(buildingLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Vacant'){
                                                         vacantUnitBuildingMap.put(buildingLoop.Id,vacantUnitBuildingMap.get(buildingLoop.Id)+1);
                                                     }else{
                                                         othersUnitBuildingMap.put(buildingLoop.Id,othersUnitBuildingMap.get(buildingLoop.Id)+1);
                                                     }
                                                 }
                                             }
                                         }
                                     }// code for Building rollup end
                                     system.debug('buildingCount-->'+totalUnitBuildingMap);
                                     // code for Floor rollup
                                     for(Floor__c floorLoop : floorList){
                                         // Floor rollup initialization
                                         totalUnitFloorMap.put(floorLoop.Id,0);
                                         availableUnitFloorMap.put(floorLoop.Id,0);
                                         bookedUnitFloorMap.put(floorLoop.Id,0);
                                         leasedUnitFloorMap.put(floorLoop.Id,0);
                                         soldUnitFloorMap.put(floorLoop.Id,0);
                                         reservedUnitFloorMap.put(floorLoop.Id,0);
                                         othersUnitFloorMap.put(floorLoop.Id,0);
                                         vacantUnitFloorMap.put(floorLoop.Id,0);
                                         
                                         // no of Floors for Building rollup
                                         if(floorLoop.building__c != null){
                                             noFloorBuildingMap.put(floorLoop.building__c,
                                                                    noFloorBuildingMap.get(floorLoop.building__c)==null ? 1 : noFloorBuildingMap.get(floorLoop.building__c)+1);
                                         }
                                         if(floorUnitMap.containsKey(floorLoop.Id)){  
                                             for(Unit__c unitLoop : floorUnitMap.get(floorLoop.Id)){
                                                 
                                                 if(unitLoop.Floor__c == floorLoop.Id){
                                                     totalUnitFloorMap.put(floorLoop.Id,totalUnitFloorMap.get(floorLoop.Id)+1);
                                                     if(unitLoop.Unit_Status__c == 'Available'){
                                                         availableUnitFloorMap.put(floorLoop.Id,availableUnitFloorMap.get(floorLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Booked'){
                                                         bookedUnitFloorMap.put(floorLoop.Id,bookedUnitFloorMap.get(floorLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Leased'){
                                                         leasedUnitFloorMap.put(floorLoop.Id,leasedUnitFloorMap.get(floorLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Sold'){
                                                         soldUnitFloorMap.put(floorLoop.Id,soldUnitFloorMap.get(floorLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Reserved'){
                                                         reservedUnitFloorMap.put(floorLoop.Id,reservedUnitFloorMap.get(floorLoop.Id)+1);
                                                     }else if(unitLoop.Unit_Status__c == 'Vacant'){
                                                         vacantUnitFloorMap.put(floorLoop.Id,vacantUnitFloorMap.get(floorLoop.Id)+1);
                                                     }else{
                                                         othersUnitFloorMap.put(floorLoop.Id,othersUnitFloorMap.get(floorLoop.Id)+1);
                                                     }
                                                 }
                                             }
                                         }
                                     }// code for Floor rollup end
                                     system.debug('FloorCount-->'+totalUnitFloorMap);
                                     // take no of building on cluster from building loop --> create map with cluster id and building count.
                                     
                                     // Floor rollup update
                                     for(Id floorKey : totalUnitFloorMap.keySet()){
                                         Floor__c f = new Floor__c(Id = floorKey);
                                         f.Total_Units__c = totalUnitFloorMap.get(floorKey);
                                         f.Available_Units__c = availableUnitFloorMap.get(floorKey);
                                         f.Booked_Units__c = bookedUnitFloorMap.get(floorKey);
                                         f.Leased_Units__c = leasedUnitFloorMap.get(floorKey);
                                         f.Sold_Units__c = soldUnitFloorMap.get(floorKey);
                                         f.Reserved_Units__c = reservedUnitFloorMap.get(floorKey);
                                         f.Others__c = othersUnitFloorMap.get(floorKey);
                                         f.Vacant_Units__c = vacantUnitFloorMap.get(floorKey);
                                         floorUpdList.add(f);
                                     }// Floor rollup update end
                                     
                                     // Building rollup update
                                     for(Id buildingKey : totalUnitBuildingMap.keySet()){
                                         building__c b = new building__c(Id = buildingKey);
                                         b.No_of_Units__c = totalUnitBuildingMap.get(buildingKey);
                                         b.Available_Units__c = availableUnitBuildingMap.get(buildingKey);
                                         b.Booked_Units__c = bookedUnitBuildingMap.get(buildingKey);
                                         b.Leased_Units__c = leasedUnitBuildingMap.get(buildingKey);
                                         b.Sold_Units__c = soldUnitBuildingMap.get(buildingKey);
                                         b.Reserved_Units__c = reservedUnitBuildingMap.get(buildingKey);
                                         b.no_of_floors__c = noFloorBuildingMap.get(buildingKey);
                                         b.Others__c = othersUnitBuildingMap.get(buildingKey);
                                         b.Vacant_Units__c = vacantUnitBuildingMap.get(buildingKey);
                                         buildingUpdList.add(b);
                                     }// Building rollup update end
                                     system.debug('cluster build no-->'+noBuildingClusterMap);
                                     //Cluster rollup update
                                     for(Id clusterKey : totalUnitClusterMap.keySet()){
                                         cluster__c c = new cluster__c(Id = clusterKey);
                                         c.No_of_units__c = totalUnitClusterMap.get(clusterKey);
                                         c.Available_Units__c = availableUnitClusterMap.get(clusterKey);
                                         c.Booked_Units__c = bookedUnitClusterMap.get(clusterKey);
                                         c.Leased_Units__c = leasedUnitClusterMap.get(clusterKey);
                                         c.Sold_Units__c = soldUnitClusterMap.get(clusterKey);
                                         c.Reserved_Units__c = reservedUnitClusterMap.get(clusterKey);
                                         c.No_of_Buildings__c = noBuildingClusterMap.get(clusterKey);
                                         c.Others__c = othersUnitClusterMap.get(clusterKey);
                                         c.Vacant_Units__c = vacantUnitClusterMap.get(clusterKey);
                                         clusterUpdList.add(c);
                                     }// Cluster rollup update end
                                     
                                     //project rollups update
                                     for(Unit__c unitLoop : unitList){
                                         if(unitLoop.Unit_Status__c == 'Available'){
                                             availableUnitProjectMap.put(unitLoop.Project__c,availableUnitProjectMap.get(unitLoop.Project__c)+1);
                                         }else if(unitLoop.Unit_Status__c == 'Booked'){
                                             bookedUnitProjectMap.put(unitLoop.Project__c,bookedUnitProjectMap.get(unitLoop.Project__c)+1);
                                         }else if(unitLoop.Unit_Status__c == 'Leased'){
                                             leasedUnitProjectMap.put(unitLoop.Project__c,leasedUnitProjectMap.get(unitLoop.Project__c)+1);
                                         }else if(unitLoop.Unit_Status__c == 'Sold'){
                                             soldUnitProjectMap.put(unitLoop.Project__c,soldUnitProjectMap.get(unitLoop.Project__c)+1);
                                         }else if(unitLoop.Unit_Status__c == 'Reserved'){
                                             reservedUnitProjectMap.put(unitLoop.Project__c,reservedUnitProjectMap.get(unitLoop.Project__c)+1);
                                         }else if(unitLoop.Unit_Status__c == 'Vacant'){
                                             vacantUnitProjectMap.put(unitLoop.Project__c,vacantUnitProjectMap.get(unitLoop.Project__c)+1);
                                         }else{
                                             othersUnitProjectMap.put(unitLoop.Project__c,othersUnitProjectMap.get(unitLoop.Project__c)+1);
                                         }
                                     }
                                     project.No_of_Units__c = unitList.size();//project.units__r.size();
                                     project.Available_Units__c = availableUnitProjectMap.get(project.Id);
                                     project.Booked_Units__c = bookedUnitProjectMap.get(project.Id);
                                     project.Leased_Units__c = leasedUnitProjectMap.get(project.Id);
                                     project.Sold_Units__c = soldUnitProjectMap.get(project.Id);
                                     project.Reserved_Units__c = reservedUnitProjectMap.get(project.Id);
                                     project.No_of_Buildings__c = buildingList.size();
                                     project.No_of_Clusters__c = clusterList.size();
                                     project.Others__c = othersUnitProjectMap.get(project.Id);
                                     project.Vacant_Units__c = vacantUnitProjectMap.get(project.Id);
                                     projUpdList.add(project);
                                     
                                     
                                     
                                     //project rollups update end
                                 }
        if(!floorUpdList.isEmpty()){
            System.debug('FlooList : '+floorUpdList);
            Update floorUpdList;
        }
        if(!buildingUpdList.isEmpty()){
            System.debug('BuildingList : '+buildingUpdList);
            Update buildingUpdList;
        }
        if(!clusterUpdList.isEmpty()){
            System.debug('ClusterList : '+clusterUpdList);
            Update clusterUpdList;
        }
        if(!projUpdList.isEmpty()){
            System.debug('ProjectList : '+projUpdList);
            Update projUpdList;
        }
        
        
        //}
    }
}