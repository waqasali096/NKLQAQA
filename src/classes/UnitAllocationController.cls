/*
@Author : Swapnil Mohite
@CreatedDate: 17/01/2022
@This apex class will handle all Visibility related functionality of unit
*/
public class UnitAllocationController {
    /*
*@ This method will create unit visibility records
* @date   16/01/2022
* @author Swapnil Mohite
*/
    public static void createVisibility(Map<String,List<Sales_Event_Executive__c>>UnitExecMap,Map<String,Unit__Share> unitShareMap,Set<String> accessSet, Set<String> deleteAccessSet){
        List<Unit__Share> unitShareToInsertList = new List<Unit__Share>();
        List<Unit__Share> unitShareToDeleteList = new List<Unit__Share>();
        Set<String> unitExecSet = new Set<String>();
        
        Savepoint sp = Database.setSavepoint();
        
        for(Id unitId : UnitExecMap.keySet()){
            for(Sales_Event_Executive__c salesEventExec : UnitExecMap.get(unitId)){
                system.debug('==salesEventExec=='+salesEventExec);
                String key = String.valueOf(unitId)+String.valueOf(salesEventExec.user__c);
                if(salesEventExec.Start_Date__c <= system.today() && salesEventExec.End_Date__c>= system.today() 
                   && !unitShareMap.containsKey(key) && !unitExecSet.contains(key)){
                       Unit__Share unitShr  = new Unit__Share();                
                       // Set the ID of record being shared.
                       unitShr.ParentId = unitId;                
                       // Set the ID of user or group being granted access.
                       unitShr.UserOrGroupId = salesEventExec.user__c;                
                       // Set the access level.
                       unitShr.AccessLevel = 'edit';                
                       // Set rowCause to 'manual' for manual sharing.
                       // This line can be omitted as 'manual' is the default value for sharing objects.
                       unitShr.RowCause = Schema.Unit__Share.RowCause.Manual;                
                       unitShareToInsertList.add(unitShr);
                       unitExecSet.add(key);
                   }
                
                if(salesEventExec.End_Date__c < system.today()){   
                    system.debug('==cond1=='+(unitShareMap.containsKey(key)));
                    system.debug('==cond2=='+(!unitShareToDeleteList.contains(unitShareMap.get(key))));
                    system.debug('==cond3=='+(!accessSet.contains(key)));
                    if(unitShareMap.containsKey(key) && !unitShareToDeleteList.contains(unitShareMap.get(key)) && !accessSet.contains(key)){
                        unitShareToDeleteList.add(unitShareMap.get(key));
                    }                
                }
                if(deleteAccessSet.contains(key)){                    
                    unitShareToDeleteList.add(unitShareMap.get(key));
                }
            }
        }
        try{
            if(unitShareToInsertList.isEmpty() == false){
                insert unitShareToInsertList;
            }
            if(unitShareToDeleteList.isEmpty() == false){
                system.debug('==unitShareToDeleteList='+unitShareToDeleteList);
                delete unitShareToDeleteList;
            }
        }catch(Exception ex){
            Database.RollBack(sp);
        }
    }
    /*
*@ This method will prepare data for unit visibility records
* @date   17/01/2022
* @author Swapnil Mohite
*/
    public static void prepareData(List<Sales_Event_Executive__c> salesEventExecList,List<Sales_Event_Unit__c> salesEventUnitList,Set<Id> salesEventIdSet){
        Set<String> userIdSet = new Set<String>();
        Map<String,Unit__Share> unitShareMap = new Map<String,Unit__Share>();
        Map<String,List<Sales_Event_Executive__c>> salesEventExecMap = new Map<String,List<Sales_Event_Executive__c>>();
        Map<String,List<Sales_Event_Executive__c>> salesEventExecOtherMap = new Map<String,List<Sales_Event_Executive__c>>();
        Map<String,List<Sales_Event_Executive__c>> UnitEventExecMap = new Map<String,List<Sales_Event_Executive__c>>();
        Map<String,List<Sales_Event_Executive__c>> UnitEventExecOtherMap = new Map<String,List<Sales_Event_Executive__c>>();
        Set<String> accessSet = new Set<String>();
        Set<String> deleteAccessSet = new Set<String>();
        for(Sales_Event_Executive__c salesEventExecRec: salesEventExecList){
            if(salesEventExecMap.containsKey(salesEventExecRec.Sales_Event__c)){
                salesEventExecMap.get(salesEventExecRec.Sales_Event__c).add(salesEventExecRec);
            }else{
                salesEventExecMap.put(salesEventExecRec.Sales_Event__c,new List<Sales_Event_Executive__c>{salesEventExecRec});
            }
            userIdSet.add(salesEventExecRec.User__c);
        }
        for(Sales_Event_Unit__c salesEventUnit : salesEventUnitList){
            if(salesEventExecMap.containsKey(salesEventUnit.Sales_Event__c)){
                if(UnitEventExecMap.containsKey(salesEventUnit.unit__c)){
                    UnitEventExecMap.get(salesEventUnit.unit__c).addAll(salesEventExecMap.get(salesEventUnit.Sales_Event__c));
                }else{
                    UnitEventExecMap.put(salesEventUnit.unit__c, salesEventExecMap.get(salesEventUnit.Sales_Event__c));
                }
            }
        }
        for(Unit__Share unitShare : getUnitsShareByParentId(userIdSet,UnitEventExecMap.keySet())){
            String key = String.valueOf(unitShare.ParentId)+String.valueOf(unitShare.UserOrGroupId);
            unitShareMap.put(key, unitShare);            
        } 
        // prepare data to check if acess from other sales event is given?
        for(Sales_Event_Executive__c salesEventExecRec: [SELECT Id,Name,Sales_Event__c,End_Date__c,Start_Date__c,User__c,Access_Given__c
                                                         FROM Sales_Event_Executive__c 
                                                         WHERE Sales_Event__c NOT IN : salesEventIdSet AND Access_Given__c = True]){
                                                             if( salesEventExecOtherMap.containsKey(salesEventExecRec.Sales_Event__c)){
                                                                 salesEventExecOtherMap.get(salesEventExecRec.Sales_Event__c).add(salesEventExecRec);
                                                             }else{
                                                                 salesEventExecOtherMap.put(salesEventExecRec.Sales_Event__c,new List<Sales_Event_Executive__c>{salesEventExecRec});
                                                             }  
                                                         }
        
        for(Sales_Event_Unit__c salesEventUnit : [SELECT Id,Name,Sales_Event__c,Access_Given__c,Unit__c
                                                  FROM Sales_Event_Unit__c 
                                                  WHERE Sales_Event__c NOT IN : salesEventIdSet AND Access_Given__c = True]){
                                                      if(salesEventExecMap.containsKey(salesEventUnit.Sales_Event__c)){
                                                          for(Sales_Event_Executive__c salesEventExecRec : salesEventExecMap.get(salesEventUnit.Sales_Event__c)){
                                                              if(salesEventExecRec.Access_Given__c){
                                                                  accessSet.add(String.valueOf(salesEventUnit.Unit__c)+String.valueOf(salesEventExecRec.User__c));
                                                              }                                                              
                                                          }
                                                      }
                                                      if(salesEventExecOtherMap.containsKey(salesEventUnit.Sales_Event__c)){
                                                          for(Sales_Event_Executive__c salesEventExecRec : salesEventExecOtherMap.get(salesEventUnit.Sales_Event__c)){
                                                              if(salesEventExecRec.Access_Given__c){
                                                                  accessSet.add(String.valueOf(salesEventUnit.Unit__c)+String.valueOf(salesEventExecRec.User__c));
                                                              }
                                                          }
                                                      }
                                                  }
        
        set<Id> deletedSalesEventUnitIdSet = new set<Id>();
        for(Sales_Event_Unit__c salesEventUnitRec : [select Id,IsDeleted from Sales_Event_Unit__c where Id in : salesEventUnitList AND IsDeleted = true ALL ROWS]){
            deletedSalesEventUnitIdSet.add(salesEventUnitRec.Id);
        }
        
        set<Id> deletedSalesEventExecutiveIdSet = new set<Id>();
        for(Sales_Event_Executive__c salesEventExecRec : [select Id,IsDeleted from Sales_Event_Executive__c where Id in : salesEventExecList AND IsDeleted = true ALL ROWS]){
            deletedSalesEventExecutiveIdSet.add(salesEventExecRec.Id);
        }
        
        for(Sales_Event_Unit__c salesEventUnit : salesEventUnitList){
            for(Sales_Event_Executive__c salesEventExecRec : salesEventExecMap.get(salesEventUnit.Sales_Event__c)){
                if(unitShareMap.containsKey(String.valueOf(salesEventUnit.Unit__c)+String.valueOf(salesEventExecRec.User__c))){
                    if(deletedSalesEventUnitIdSet.contains(salesEventUnit.Id) && !accessSet.contains(String.valueOf(salesEventUnit.Unit__c)+String.valueOf(salesEventExecRec.User__c))){
                        deleteAccessSet.add(String.valueOf(salesEventUnit.Unit__c)+String.valueOf(salesEventExecRec.User__c));                        
                    } 
                    if(deletedSalesEventExecutiveIdSet.contains(salesEventExecRec.Id) && !accessSet.contains(String.valueOf(salesEventUnit.Unit__c)+String.valueOf(salesEventExecRec.User__c))){
                        deleteAccessSet.add(String.valueOf(salesEventUnit.Unit__c)+String.valueOf(salesEventExecRec.User__c));                        
                    } 
                }                 
            }
        }
        
        system.debug('==salesEventExecMap=='+salesEventExecMap);
        system.debug('==salesEventExecOtherMap=='+salesEventExecOtherMap);
        system.debug('==accessSet=='+accessSet);
        system.debug('==UnitEventExecMap=='+UnitEventExecMap);
        system.debug('==unitShareMap=='+unitShareMap);
        system.debug('==deleteAccessSet=='+deleteAccessSet);
        
        createVisibility(UnitEventExecMap,unitShareMap,accessSet,deleteAccessSet);
    }
    /**
* This method is used fetch unit shares based on unitIds
* @date   17/01/2022
* @author Swapnil Mohite
*/
    public static list<Unit__Share> getUnitsShareByParentId(Set<String> userIdSet,Set<String> unitIdSet){
        return [SELECT id, ParentId, UserOrGroupId 
                from Unit__Share 
                where ParentId IN : unitIdSet AND UserOrGroupId IN : userIdSet AND RowCause = 'Manual'];
    }
}