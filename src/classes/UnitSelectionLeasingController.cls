/* 23 Jan 22
Comment by Huzefa - neeed to use active checkbox going ahead as its also used in integration - Status__c -> active__c 
changed sales_status__c to unit_status__c  */
//Comment by Swapnil - neeed to use Business_Unit__c instead of master_community__c and use unit_Status__c instead of sales_status__c and leasing_status__c
public with sharing  class UnitSelectionLeasingController {
    //Method to search unit by name
    @AuraEnabled
    public static List<Unit__c> findUnitByName(String searchKey) {
        List<unit__c> unitlist = new List<unit__c> ();
        if(string.isBlank(searchKey)){
            
            unitlist = [Select Id,name,active__c,unit_code__c,unit_leasing_type__r.name,unit_leasing_type__c,Business_Unit__c,Project__c, Floor__c, Business_Group__c,unit_status__c from Unit__c  WHERE active__c = true order by name]; 
            //Status__c='Active' 
        }
        else{
            String name =  + '%' + searchKey + '%';
            unitlist =  [Select Id,name,active__c,unit_code__c,unit_leasing_type__r.name,unit_leasing_type__c,Business_Unit__c,Project__c, Floor__c, Business_Group__c,unit_status__c from Unit__c  WHERE name LIKE :name and active__c = true order by name];
        }
        return unitlist;
    }
    
    @AuraEnabled
    public Static objectWrapper getRecordDetails(String recordId){
        objectWrapper objWrapper = new objectWrapper();
        Opportunity opp = new Opportunity();
        opp = [Select Id,Project__c,Project__r.Name,Leasing_Type__c,Account.Emirates_Ids__c FROM Opportunity where Id =: recordId];
        List<Unit_Plan__c> unitList = [Select Id FROM Unit_Plan__c where Opportunity__c = : recordId];
        objWrapper.oppty = opp;
        objWrapper.unitList = unitList;
        
        
        return objWrapper;
    }
    
    //Method to show Vacant units on page load
    @AuraEnabled
    public static List<unitwrapper> SearchUnits(String recordId){
        String Append = '';
        List<unitwrapper> unitwraplst = new List<unitwrapper>();
        Opportunity  opp = [Select Id,project__c,Leasing_Type__c From Opportunity where ID =: recordId limit 1];
        set<String> unitIds = new Set<String>();
        for(Unit_Plan__c up : [Select Id,Unit__c FROM Unit_Plan__c where Opportunity__c =: recordId]){
            unitIds.add(up.Unit__c);
        }
        List<Unit__c> lstUnit = new List<Unit__c>();
        Map<Integer,Unit__c> mapOfUnits = new Map<Integer,Unit__c>();
        if(String.isNotBlank(opp.Project__c)){
            system.debug('opp.Project__c'+opp.Project__c+opp.Leasing_Type__c+'opp.Leasing_Type__c');
            if(opp.Leasing_Type__c == 'Residential Units'){
                lstUnit = [Select Id,name,active__c,unit_code__c,unit_leasing_type__r.name,unit_leasing_type__c,Business_Unit__c,Project__r.Name,No_of_Bedrooms__c,No_of_Car_Parkings__c,Location__r.Name,Floor__c,Floor__r.Name,Building__r.Name,Space_Type__c,Business_Group__c,unit_status__c,Unit_type__c,Base_Rent__c,Usable_Area__c,Assignable_Area__c,Building__c,Project__c,Space_Types__c, Space_Types__r.Name,Built_Up_Area_Sqft__c from Unit__c where RecordType.Name = 'Leasing' and unit_status__c = 'Vacant' and project__c =: opp.Project__c and Leasing_Type__c = 'Residential Leasing Unit'];  
                system.debug('lstUnit'+lstUnit);
            }
            if(opp.Leasing_Type__c == 'Residential Shops'){
                lstUnit = [Select Id,name,active__c,unit_code__c,unit_leasing_type__r.name,unit_leasing_type__c,Business_Unit__c,Project__r.Name,No_of_Bedrooms__c,No_of_Car_Parkings__c,Location__r.Name,Floor__c,Floor__r.Name,Building__r.Name,Space_Type__c, Business_Group__c,unit_status__c,Unit_type__c,Base_Rent__c,Usable_Area__c,Assignable_Area__c,Building__c,Project__c,Space_Types__c, Space_Types__r.Name,Built_Up_Area_Sqft__c from Unit__c where RecordType.Name = 'Leasing' and unit_status__c = 'Vacant' and project__c =: opp.Project__c and Leasing_Type__c = 'Residential Leasing Shop'];   
            }
            if(String.isBlank(opp.Leasing_Type__c)){
                lstUnit = [Select Id,name,active__c,unit_code__c,unit_leasing_type__r.name,unit_leasing_type__c,Business_Unit__c,Project__r.Name,No_of_Bedrooms__c,No_of_Car_Parkings__c,Location__r.Name,Floor__c,Floor__r.Name,Building__r.Name,Space_Type__c, Business_Group__c,unit_status__c,Unit_type__c,Base_Rent__c,Usable_Area__c,Assignable_Area__c,Building__c,Project__c,Space_Types__c, Space_Types__r.Name,Built_Up_Area_Sqft__c from Unit__c where RecordType.Name = 'Leasing' and unit_status__c = 'Vacant' and project__c =: opp.Project__c];   
            }
            
        } else {
            if(opp.Leasing_Type__c == 'Residential Units'){
                lstUnit = [Select Id,name,active__c,unit_code__c,unit_leasing_type__r.name,unit_leasing_type__c,Business_Unit__c,Project__r.Name,No_of_Bedrooms__c,No_of_Car_Parkings__c,Location__r.Name,Floor__c,Floor__r.Name,Building__r.Name,Space_Type__c, Business_Group__c,unit_status__c,Unit_type__c,Base_Rent__c,Usable_Area__c,Assignable_Area__c,Building__c,Project__c,Space_Types__c, Space_Types__r.Name,Built_Up_Area_Sqft__c from Unit__c where RecordType.Name = 'Leasing' and unit_status__c = 'Vacant' and project__c =: opp.Project__c and Leasing_Type__c = 'Residential Leasing Unit'];   
            }
            if(opp.Leasing_Type__c == 'Residential Shops'){
                lstUnit = [Select Id,name,active__c,unit_code__c,unit_leasing_type__r.name,unit_leasing_type__c,Business_Unit__c,Project__r.Name,No_of_Bedrooms__c,No_of_Car_Parkings__c,Location__r.Name,Floor__c,Floor__r.Name,Building__r.Name,Space_Type__c, Business_Group__c,unit_status__c,Unit_type__c,Base_Rent__c,Usable_Area__c,Assignable_Area__c,Building__c,Project__c,Space_Types__c, Space_Types__r.Name,Built_Up_Area_Sqft__c from Unit__c where RecordType.Name = 'Leasing' and unit_status__c = 'Vacant' and project__c =: opp.Project__c and Leasing_Type__c = 'Residential Leasing Shop'];   
            }
            if(String.isBlank(opp.Leasing_Type__c)){
                lstUnit = [Select Id,name,active__c,unit_code__c,unit_leasing_type__r.name,unit_leasing_type__c,Business_Unit__c,Project__r.Name,No_of_Bedrooms__c,No_of_Car_Parkings__c,Location__r.Name,Floor__c,Floor__r.Name,Building__r.Name,Space_Type__c, Business_Group__c,unit_status__c,Unit_type__c,Base_Rent__c,Usable_Area__c,Assignable_Area__c,Building__c,Project__c,Space_Types__c, Space_Types__r.Name,Built_Up_Area_Sqft__c from Unit__c where RecordType.Name = 'Leasing' and unit_status__c = 'Vacant' ];   
            }
        }
        for(Unit__c u : lstUnit){
            unitwrapper uwrap = new unitwrapper();
            uwrap.propFlag = false;
            uwrap.unit = u;
            unitwraplst.add(uwrap);
        }
        
        
        return unitwraplst;
    }
    
    // Method to get the Project List 
    @AuraEnabled
    public static map<string,string> fetchProjects(){
        map<string,string> mapProjects = new map<string,string>();
        for(Project__c proj :[select Id,Name from Project__c where Project_Purpose__c = 'Leasing'])
        {
            mapProjects.put(proj.Id,proj.Name);
            system.debug(mapProjects.size());
        }       
        return mapProjects;
    }
    @AuraEnabled
    public static map<string,string> fetchCluster(String project){
        system.debug('selectedProject'+project);
        map<string,string> mapCluster = new map<string,string>();
        for(Cluster__c cls :[select Id,Name from Cluster__c where Project__c =:project ])
        {
            system.debug('cls'+cls);
            mapCluster.put(cls.Id,cls.Name);
            system.debug(mapCluster.size());
        }       
        return mapCluster;
    }
    @AuraEnabled
    public static map<string,string> fetchBuilding(String cluster){
        map<string,string> mapBuilding = new map<string,string>();
        for(Building__c cls :[select Id,Name from Building__c where Cluster__c =:cluster])
        {
            mapBuilding.put(cls.Id,cls.Name);
            system.debug(mapBuilding.size());
        }       
        return mapBuilding;
    }
    
    
    @AuraEnabled 
    public static Map<String, String> getUnitType(){
        Map<String, String> options = new Map<String, String>();
        Map<String, String> availMap = new Map<String, String>();
        availMap = getPicklistValues('Unit__c','Unit_Type__c'); 
        for(String value : availMap.keySet()){
            if(availMap.get(value) != 'Storage' && availMap.get(value) != 'Common Area' && availMap.get(value) != 'Substation' && availMap.get(value) != 'Island'){
                options.put(value,availMap.get(value));
            }
        }
        
        return options;
    }
    @AuraEnabled 
    public static Map<String, String> getLocation(){
        Map<String, String> options = new Map<String, String>();
        //List<Location> locList = [select Id,Name from Location];
        for(Schema.Location cls : [select Id,Name from Location])
        {
            
            options.put(cls.Id,cls.Name);
            //system.debug(options.size());
        }       
        return options;
    }
    @AuraEnabled 
    public static Map<String, String> getSpaceType(){
        Map<String, String> options = new Map<String, String>();
        //List<Location> locList = [select Id,Name from Location];
        for(Schema.Space_Type__c cls : [select Id,Name from Space_Type__c])
        {
            
            options.put(cls.Id,cls.Name);
            //system.debug(options.size());
        }       
        return options;
    }
    @AuraEnabled 
    public static Map<String, String> getBedroom(){
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','No_of_Bedrooms__c'); 
        return options;
    }
    @AuraEnabled 
    public static Map<String, String> getArchitecturalType(){
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','Architectural_Type__c');  
        return options;
    }
    @AuraEnabled 
    public static Map<String, String> getFloor(){
        Map<String, String> options = new Map<String, String>();
        options = getObjectValues('Floor__c');    
        return options;
    }
    @AuraEnabled 
    public static Map<String, String> getBusinessGroup(){
        Map<String, String> options = new Map<String, String>();
        options = getObjectValues('Business_Group__c');    
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getMasterCommunity(){
        Map<String, String> options = new Map<String, String>();
        options = getObjectValues('Business_Unit__c');    
        return options;
    }
    
    // Method to search the unit based on search criteria
    @AuraEnabled
    public static List<unitwrapper> searchUnit(string cluster, string project, string building,String unitType,String propertyView,String spaceType,
                                               string type, Integer minPrice, Integer maxPrice,
                                               String pageSize, String pageNumber,String oppId){
                                                   
                                                   List<unitwrapper> unitwraplst = new List<unitwrapper>();
                                                   Opportunity  opp = [Select Id,project__c,Leasing_Type__c From Opportunity where ID =: oppId limit 1];
                                                   set<String> unitIds = new Set<String>();
                                                   for(Unit_Plan__c up : [Select Id,Unit__c FROM Unit_Plan__c where Opportunity__c =: oppId]){
                                                       unitIds.add(up.Unit__c);
                                                   }
                                                   try {           
                                                       String query = 'Select Id, name, unit_leasing_type__r.name,unit_leasing_type__c,Project__r.Name, Business_Unit__c, No_of_Bedrooms__c, No_of_Car_Parkings__c, Location__r.Name, Floor__c, Building__r.Name, Space_Type__c, Business_Group__c, Unit_Status__c, Unit_type__c, Base_Rent__c, Usable_Area__c, Assignable_Area__c, Building__c, Project__c,Built_Up_Area_Sqft__c,Space_Types__r.Name from Unit__c where ';
                                                       if(String.isNotBlank(cluster)){
                                                           query += 'cluster__c=\''+ cluster +'\' AND ';
                                                       }
                                                       if(String.isNotBlank(building)){
                                                           query += 'Building__c=\''+ building +'\' AND ';
                                                       }
                                                       
                                                       if(String.isNotBlank(unitType)){
                                                           query += 'Unit_Type__c=\''+ unitType +'\' AND ';
                                                       }
                                                       if(String.isNotBlank(propertyView)){
                                                           query += 'Location__c=\''+ propertyView +'\' AND ';
                                                       }
                                                       
                                                       if(String.isNotBlank(project)){
                                                           query += 'project__c=\''+ project +'\' AND ';
                                                       }
                                                       
                                                       if(String.isNotBlank(spaceType)){
                                                           query += 'unit_leasing_type__c=\''+ spaceType +'\' AND ';
                                                       }
                                                         
                                                       
                                                       // add the final filter which is mandatory 
                                                       query += ' Unit_Status__c = \'Vacant\'';                   
                                                       if(opp.Leasing_Type__c == 'Residential Units'){
                                                           query += ' and Leasing_Type__c = \'Residential Leasing Unit\'';
                                                       }
                                                       if(opp.Leasing_Type__c == 'Residential Shops'){
                                                           query += ' and  Leasing_Type__c = \'Residential Leasing Shop\'';
                                                       }
                                                       query += ' and RecordType.Name = \'Leasing\'';
                                                       system.debug('TH>>query>>' + query);
                                                       // query on unit to fetch results
                                       
                                                       List<Unit__c> lstUnit = Database.query(query);
                                                       System.debug('TH' + lstUnit.size());
                                                       System.debug('TH' + lstUnit);
                                                       
                                                       if(lstUnit.size() > 0){ 
                                                           List<Id> unitIdList=new List<Id>();                    
                                                           for(Unit__c u : lstUnit){
                                                               unitIdList.add(u.id);
                                                               unitwrapper uwrap = new unitwrapper();
                                                               uwrap.propFlag = false;
                                                               uwrap.unit = u;
                                                               unitwraplst.add(uwrap);
                                                           }
                                                           return unitwraplst;
                                                       }
                                                       else {
                                                           return null;    
                                                       }
                                                   } 
                                                   catch(exception ex){
                                                       system.debug(ex.getMessage());
                                                       return null;
                                                   }
                                                   
                                               }
    
    //Method to add selected unit to that opportunity
    @AuraEnabled
    public static void addUnitstoOpp(String OppId,List<ID> unitsList){
        system.debug('%%unitsList'+unitsList);
        system.debug('OppId'+OppId);
        integer i=1;
        List<unit__c> unitsLists = [select id,unit_code__c,unit_leasing_type__r.name,unit_leasing_type__c,Assignable_Area__c,Project__r.Name,Unit_type__c,Total_Saleable_Area_Sqft__c,Space_Types__c,Building__c,Cluster__c,Project__c,Leasing_Selling_Price__c,name,Master_Payment_Plan__c,Master_Payment_Plan__r.No_of_cheques_Leasing__c from Unit__c where id IN : unitsList];
        Opportunity opp = [Select Id,Booking_Fee_gets_collected__c,Unit_Status__c,name from Opportunity where id=:OppId]; 
        List<Unit_Plan__c> unitPlanList = new List<Unit_Plan__c>();
        opp.Unit_Status__c = 'On Hold';
        update opp;
        List<Payment_Milestone__c> payMileList = new List<Payment_Milestone__c>();
        Map<Id,Integer> unitIdVsAmount = new  Map<Id,Integer>();
        if(unitsLists.size()>0){
            for(unit__c unit : unitsLists){
                //unitIdVsAmount.put(unit.Master_Payment_Plan__c,Integer.valueOf(unit.Leasing_Selling_Price__c));
                Unit_Plan__c unitObj = new Unit_Plan__c(
                    Name =  unit.unit_code__c,
                    //StageName__c = 'Choose Units',
                    unit__c = unit.Id,
                    Project__c = unit.Project__c,
                    Building__c = unit.Building__c,
                    Cluster__c = unit.Cluster__c,
                    opportunity__c = OppId
       
                );
                
                unitPlanList.add(unitObj);
                i++;
            }
            system.debug('unitPlanList'+unitPlanList);
            insert unitPlanList;
            
        }
        
        
        
    }
    //Method to display existing unit tied to the opportunity, on load of component
    @AuraEnabled
    public static void fetchExistingUnit(string opportunityID)
    {
        /*try
{              
if(string.isNotBlank(opportunityID))
{                
//get the unit id from opportunity 
Opportunity opp = [select id from Opportunity where 
ID =: opportunityID limit 1];
List<Opportunity_unit__c> listOppUnits = [select id,unit__c,Unit__r.name,Unit__r.Type__c,Unit__r.Status__c,Unit__r.Total_Price__c,Unit__r.Plot_Area__c,
Unit__r.Total_Bedrooms__c,Unit__r.View__c,Unit__r.GSA__c,Unit__r.ADM_NO__c,Unit__r.Governance_Offer__c,Unit__r.Med__c,
Unit__r.project__r.Name,Opportunity__c,Opportunity__r.Payment_Plan__r.Name
from Opportunity_unit__c where Opportunity__c=:opportunityID];
List<Opportunity_Payment_Plan__c> listOppPaymentPlan=[select id,name,Opportunity__c,Payment_Plan_Name__c,Opportunity_Unit__c 
from Opportunity_Payment_Plan__c where Opportunity__c=:opportunityID];

system.debug('listOppUnits>>>>>'+listOppUnits);
List<id> lstOppPaymentPlanId=new List<id>();
for (Opportunity_Payment_Plan__c p:listOppPaymentPlan){


}
system.debug('lstOppPaymentPlanId>>>>>'+lstOppPaymentPlanId);
//string unitID = opp.Unit_Number__c;

// Query the unit attributes from unit and return list



if(listOppUnits.size() > 0)
{
return listOppUnits;
}
else
{
return null;
}
}

else 
{
return null;
}
}

catch(exception ex)
{
system.debug(ex.getMessage());
return null;
}*/
    }
    
    //Method to remove existing unit tied to the opportunity
    /*@AuraEnabled
public static boolean removeExistingUnit(string opportunityID,  List<string> ppIdList)
{
try{              
if(string.isNotBlank(opportunityID)){          
// query on opportunity
List<opportunity> OpportunityList = new List<opportunity>();
Opportunity oppStage = [select StageName,Amount from opportunity where id =: opportunityID limit 1];
// only allow the removal of unit from opportunity for the following stages
if(oppStage.StageName == System.label.Opportunity_New_Stage || oppStage.StageName == System.label.Opportunity_In_Progress_Stage
|| oppStage.StageName == System.label.Opportunity_Proposal_Shared_stage){

Opportunity opp = new Opportunity();
system.debug('ppIdList>>>>'+ppIdList);
system.debug('ppIdList>>>>'+ppIdList.size());
List<Opportunity_Unit__c> listOppUnit=new List<Opportunity_Unit__c>();
List<Opportunity_Payment_Plan__c> listOppPaymentPlan=[select id,name,Opportunity__c,
Payment_Plan_Name__c,Opportunity_Unit__c from Opportunity_Payment_Plan__c 
where Opportunity_Unit__c=:ppIdList and Opportunity__c=:opportunityID ];
system.debug('listOppPaymentPlan>>>>'+listOppPaymentPlan);

List<Id> oppUnitIdList=new List<Id>();
if(listOppPaymentPlan.size()>0){
for(Opportunity_Payment_Plan__c opp1:listOppPaymentPlan){
oppUnitIdList.add(opp1.Opportunity_Unit__c);
}  
}

if(oppUnitIdList.size()>0){
listOppUnit=[Select id from Opportunity_Unit__c where id=:oppUnitIdList ];
system.debug('listOppUnit>>>>'+listOppUnit);
}
if(listOppPaymentPlan.size()>0 && listOppUnit.size()>0){
delete listOppPaymentPlan; 
delete listOppUnit; 
oppStage.Amount = 0;

oppStage.Unit__c = null;
update oppStage;
}
return true;
}
else{
// don't allow the removal of unit on further stages
return false;
}
}
else {
return false;
}
}
catch(exception ex)
{
system.debug(ex.getMessage());
return false;
}
}*/
    
    //Method to fetch picklist values
    @AuraEnabled 
    public static Map<String, String> getPicklistValues(string obj, string fld){
        Map<String, String> options = new Map<String, String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(obj) ;
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        for (Schema.PicklistEntry p: values) {
            options.put(p.getValue(), p.getLabel());
        }
        system.debug('values'+values);
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getObjectValues(string obj){
        Map<String, String> options = new Map<String, String>();
        String recordQuery = 'SELECT Id, Name FROM '+obj+' LIMIT 100';
        List<sObject> records = Database.query(recordQuery);
        for(sObject sobj:records){
            options.put(String.valueof(sobj.get('Id')),String.valueof(sobj.get('Name')));
        }
        return options;
    }
    @AuraEnabled
    public static String getOpportunityRecord(String recordId){
        String message = '';
        List<Opportunity> opplist = [select id,Booking_Amount__c,Booking_Mode__c,stageName from Opportunity where id =:recordId];
        //if(opplist[0].stageName == 'Unit Reservation' && opplist[0].Booking_Amount__c <> null && opplist[0].Booking_Mode__c <> null){
        message = 'success';
        //}
        
        return message;            
    }
    @AuraEnabled
    public static List<Availabe_Payment_Plan__c> getAvailablePlans(String recordId){
        String message = '';
        List<Availabe_Payment_Plan__c> availList = [select id,Base_Lease_Amount__c,space_type__c from Availabe_Payment_Plan__c where project__c =:recordId];
        //if(opplist[0].stageName == 'Unit Reservation' && opplist[0].Booking_Amount__c <> null && opplist[0].Booking_Mode__c <> null){
        message = 'success';
        //}\
        return availList;            
    }
    
    
    public class objectWrapper {
        @AuraEnabled
        public Opportunity oppty{get;set;}
        
        @AuraEnabled
        public List<Unit_Plan__c> unitList{get;set;}
        
        @AuraEnabled 
        public List<unitwrapper> unitWrapper{get;set;}
    }
    
    public class unitwrapper {
        @AuraEnabled 
        public Unit__c unit{get;set;}
        
        @AuraEnabled
        public Boolean propFlag{get;set;}
    }
    
}