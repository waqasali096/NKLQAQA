/*
Class Name:                 CheckFlags
Class Description:          To decide wheter give permission to update or not.
Author:                     Sajid Hameed
Created Date:               02/02/2022
Updated by:
Last Update Date:
*/

public class CheckFlags {

    /* @Usage: This method used to check flag records on Account .
    * 1st parameter: List of account Ids.
    * 2nd parameter: Boolean to check only owner dimension.
    * 3rd parameter: Boolean to check only tenant dimension.
    * 4th parameter: Boolean to check both dimensions.
    */
    
    public static Map<Id, List<String>> checkAccountFlags(Set<Id> SObjectRecordId, Boolean Owner, Boolean Tenant, Boolean Both)
    {
        /* Initailization */
        Map<Id, List<String>> returnMap = new Map<Id, List<String>>();
        List<String> flagDescList = new List<String>();
        String query;
        
        /* Create query for owner dimension */
        if(Owner){
              query = 'Select Id, Active__c, Start_Date__c, End_Date__c, Formula_Dimension__c ,Formula_Description__c, Customer__c from Flag__c where Customer__c IN: SObjectRecordId AND Formula_Dimension__c = \'OWNER\' AND Active__c = true ORDER BY Customer__c';  
        }
        /* Create query for tenant dimension */
        else if(Tenant){
             query = 'Select Id, Active__c, Start_Date__c, End_Date__c, Formula_Dimension__c ,Formula_Description__c, Customer__c from Flag__c where Customer__c IN: SObjectRecordId AND Formula_Dimension__c = \'TENANT\' AND Active__c = true ORDER BY Customer__c';  
        }
        /* Create query for both dimensions */
        else if(Both){
             query = 'Select Id, Active__c, Start_Date__c, End_Date__c, Formula_Dimension__c ,Formula_Description__c, Customer__c from Flag__c where Customer__c IN: SObjectRecordId AND Active__c = true ORDER BY Customer__c';  
        }
        
        /* Get records of flag. */
        for(Flag__c flag : Database.query(query))
        {
            /* Check today's date lie between start and end date */
            if(System.today() >= flag.Start_Date__c && System.today() <= flag.End_Date__c){
                
                String Id = String.valueOf(flag.get('Customer__c'));
                
                if(!returnMap.containsKey(Id)){
                    flagDescList = new List<String>();
                    flagDescList.add(flag.Formula_Description__c);
                    returnMap.put(Id, flagDescList);
                }
                else{
                    flagDescList = returnMap.get(Id);
                    flagDescList.add(flag.Formula_Description__c);
                    returnMap.put(Id, flagDescList);
                }
            }
        }
        
        
        return returnMap;
    }
    
    /* @Usage: This method used to check flag records on Unit .
    * 1st parameter: List of unit Ids.
    */
    
    public static Map<Id, List<String>> checkUnitFlags(List<Id> SObjectRecordId)
    {
        /* Initailization */
        Map<Id, List<String>> returnMap = new Map<Id, List<String>>();
        List<String> flagDescList = new List<String>();
        String query ;
        
        /* Get records of flag. */
        for(Flag__c flag : [Select Id, Active__c, Start_Date__c, End_Date__c, Formula_Dimension__c ,Formula_Description__c, 
                            Unit__c from Flag__c where Unit__c IN: SObjectRecordId AND Active__c = true ORDER BY Unit__c])
        {
            /* Check today's date lie between start and end date */
            if(System.today() >= flag.Start_Date__c && System.today() <= flag.End_Date__c){
                
                String Id = String.valueOf(flag.get('Unit__c'));
                if(!returnMap.containsKey(Id)){
                    flagDescList = new List<String>();
                    flagDescList.add(flag.Formula_Description__c);
                    returnMap.put(Id, flagDescList);
                }
                else{
                    flagDescList = returnMap.get(Id);
                    flagDescList.add(flag.Formula_Description__c);
                    returnMap.put(Id, flagDescList);
                }
            }
        }
        
        
        return returnMap;
    }
    
     /* @Usage: This method used to check flag records on Building.
    * 1st parameter: List of building Ids.
    */
    
    public static Map<Id, List<String>> checkBuildingFlags(List<Id> SObjectRecordId)
    {
        /* Initailization */
        Map<Id, List<String>> returnMap = new Map<Id, List<String>>();
        List<String> flagDescList = new List<String>();
        String query ;
        
        /* Get records of flag. */
        for(Flag__c flag : [Select Id, Active__c, Start_Date__c, End_Date__c, Formula_Dimension__c ,Formula_Description__c, 
                            Building__c from Flag__c where Building__c IN: SObjectRecordId AND Active__c = true ORDER BY Building__c])
        {
            /* Check today's date lie between start and end date */
            if(System.today() >= flag.Start_Date__c && System.today() <= flag.End_Date__c){
                
                String Id = String.valueOf(flag.get('Building__c'));
                if(!returnMap.containsKey(Id)){
                    flagDescList = new List<String>();
                    flagDescList.add(flag.Formula_Description__c);
                    returnMap.put(Id, flagDescList);
                }
                else{
                    flagDescList = returnMap.get(Id);
                    flagDescList.add(flag.Formula_Description__c);
                    returnMap.put(Id, flagDescList);
                }
            }
        }
        
        
        return returnMap;
    }
    
     /* @Usage: This method used to check flag records on Project.
    * 1st parameter: List of project Ids.
    */
    
    public static Map<Id, List<String>> checkProjectFlags(List<Id> SObjectRecordId)
    {
        /* Initailization */
        Map<Id, List<String>> returnMap = new Map<Id, List<String>>();
        List<String> flagDescList = new List<String>();
        String query ;
        
        /* Get records of flag. */
        for(Flag__c flag : [Select Id, Active__c, Start_Date__c, End_Date__c, Formula_Dimension__c ,Formula_Description__c, 
                            Project__c from Flag__c where Project__c IN: SObjectRecordId AND Active__c = true ORDER BY Project__c])
        {
            /* Check today's date lie between start and end date */
            if(System.today() >= flag.Start_Date__c && System.today() <= flag.End_Date__c){
                
                String Id = String.valueOf(flag.get('Project__c'));
                if(!returnMap.containsKey(Id)){
                    flagDescList = new List<String>();
                    flagDescList.add(flag.Formula_Description__c);
                    returnMap.put(Id, flagDescList);
                }
                else{
                    flagDescList = returnMap.get(Id);
                    flagDescList.add(flag.Formula_Description__c);
                    returnMap.put(Id, flagDescList);
                }
            }
        }
        
        return returnMap;
    }

}