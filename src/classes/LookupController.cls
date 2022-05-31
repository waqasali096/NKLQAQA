/**************************************************************************************************
* Name               : LookupController                                                      
* Description        : Controller class for lookup component
* Created Date       : 09/01/2022                                                                 
* Created By         : Cloudworks                                                                     
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     09/01/2022      Initial Draft.                                               
**************************************************************************************************/
//Comment by Swapnil - neeed to use Business_Unit__c instead of master_community__c and use unit_Status__c instead of sales_status__c and leasing_status__c
public class LookupController {

    /******************************************************************************************************
    * @Description        : Function to get the record
    * @Return             : List<Unit__c>
    *******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static String getrecord(String objectName, String fld_API_Text, String fld_API_Val, 
                                   Integer lim,String fld_API_Search,String searchText,
                                   String Selectedmasterplan,String SelectedblockId,String SelectedProjectId ,String selectedUnitThemeID){
                                       
                                       // Master_Plan__c mplanobj = (Master_Plan__c)System.JSON.deserialize(Selectedmasterplan, Master_Plan__c.class);
                                       // Map<String, Object> metaJSON = (Map<String, Object>) JSON.deserializeUntyped(Selectedmasterplan);
                                       //Block__c Blockobj = (Block__c)System.JSON.deserialize(SeletedBlook, Block__c.class);
                                       // Project__c Probj = (Project__c)System.JSON.deserialize(SeletedProject, Project__c.class);
                                       // Building__c Buildobj = (Building__c)System.JSON.deserialize(SeletedBuilding, Building__c.class);
                                       system.debug('mplanobj.id==='+Selectedmasterplan);
                                       searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
                                       
                                       
                                       String query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val+
                                           ' FROM '+objectName+
                                           ' WHERE '+fld_API_Search+' LIKE '+searchText;
                                       
                                       if(String.isNotBlank(Selectedmasterplan) && Selectedmasterplan != null){
                                           query +=' AND'+' Business_Unit__c = \''+ Selectedmasterplan+'\'';
                                       }
                                       if(String.isNotBlank(SelectedblockId) && SelectedblockId != null){
                                           query +=' AND'+' Block__c = \''+ SelectedblockId+'\'';
                                       }
                                       if(String.isNotBlank(SelectedProjectId) && SelectedProjectId != null){
                                           query +=' AND'+' Project__c = \''+ SelectedProjectId+'\'';
                                       }
                                  
                                       query +=' LIMIT '+lim;
                                       
                                       system.debug('query==='+query);
                                       List<sObject> sobjList = Database.query(query);
                                       List<ResultWrapper> lstRet = new List<ResultWrapper>();
                                       
                                       for(SObject s : sobjList){
                                           ResultWrapper obj = new ResultWrapper();
                                           obj.objName = objectName;
                                           obj.text = String.valueOf(s.get(fld_API_Text)) ;
                                           obj.val = String.valueOf(s.get(fld_API_Val))  ;
                                           lstRet.add(obj);
                                       } 
                                       return JSON.serialize(lstRet) ;
                                   }
    
    // Wrapper Class
    public class ResultWrapper{
        @AuraEnabled
        public String objName {get;set;}
        @AuraEnabled
        public String text{get;set;}
        @AuraEnabled
        public String val{get;set;}
    }
}