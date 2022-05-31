public with sharing class LeasingInventoryWizardController {

    @AuraEnabled( cacheable=true )  
    public static List <Leasing_Inventory_Wizard_Setting__mdt> fetchLeasingInventoryWizardSetting() {        
        List <Leasing_Inventory_Wizard_Setting__mdt> listMetadataSetting = [ SELECT Id, Unit_Table_Page_Size__c, Unit_Object_Leasing_Record_Type_Id__c FROM Leasing_Inventory_Wizard_Setting__mdt WHERE DeveloperName = 'Leasing_Inventory_Wizard_Setting' LIMIT 1];
        return listMetadataSetting; 
    }

    @AuraEnabled(Cacheable=true)
    public static List<Project__c> fetchProjectNames(){
        try {
            List<Project__c> projectList = [Select id, name from Project__c where Project_Purpose__c = 'Leasing' ORDER BY Name];
            return projectList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<Unit__c> fetchUnits(String leasingType, String projId, String bedroom, String unitSpaceType, String propertyType, String cluster, String building, String floor){
        try {
            String strLeasingType;
            if(leasingType == 'resedential'){
                strLeasingType = 'Residential Unit';
            }

            if(leasingType == 'commercial'){
                strLeasingType = 'Commercial Unit';
            } 

            String query = 'SELECT id, Name, Leasing_Type__c, Project__r.Name, Cluster__c, Unit_Code__c, No_of_Bedrooms__c, Unit_space_Type__c, Unit_type__c, Building__c, Building__r.Name, Floor__c, Floor__r.Name, Unit_Status__c, Leasing_Property_Type__c, Base_Rent__c, Security_Deposit__c, Total_Leasable_Area__c FROM Unit__c WHERE Unit_Status__c = \'Vacant\' AND';
            if(!String.isBlank(leasingType)){
                query = query + ' Leasing_Type__c = ' +'\''+strLeasingType+'\' AND';
            }
            if(!String.isBlank(projId)){
                query = query + ' Project__c = ' +'\''+projId+'\' AND';
            }
            if(!String.isBlank(bedroom)){
                query = query + ' No_of_Bedrooms__c = '+'\''+ bedroom+'\' AND';
            }
            if(!String.isBlank(unitSpaceType)){
                query = query + ' Unit_space_Type__c = \''+unitSpaceType+'\' AND';
            }
            if(!String.isBlank(propertyType)){
                query = query + ' Leasing_Property_Type__c = \''+propertyType+'\' AND';
            }
            if(!String.isBlank(cluster)){
                query = query + ' Cluster__c = \''+cluster+'\' AND';
            }
            if(!String.isBlank(building)){
                query = query + ' Building__c  = \''+building+'\' AND';
            }
            if(!String.isBlank(floor)){
                query = query + ' Floor__c = \''+floor+'\' AND';
            }
            /*if(!String.isBlank(status)){
                query = query + ' Unit_Status__c = \''+status+'\' AND';
            }*/

            query = query.removeEnd('AND');
            query = query + 'ORDER BY NAME';

            System.debug('query '+query);
            List<Unit__c> unitList = Database.query(query);
            System.debug('Unit List Value '+unitList);
            
            return unitList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Cluster__c> clusterPicklistValues(String projectId){
        try {
            List<Cluster__c> listCluster = new List<Cluster__c>();
            Set<Id> setClusterId = new Set<Id>();
            for(Unit__c objUnit : [SELECT id, name, Cluster__c, Cluster__r.Name FROM Unit__c WHERE Project__c =: projectId AND Unit_Purpose__c = 'Leasing' AND Cluster__c != null ORDER BY Cluster__r.Name]){
                
                if(!setClusterId.contains(objUnit.Cluster__c)){
                    listCluster.add(new Cluster__c(id=objUnit.Cluster__c, name=objUnit.Cluster__r.Name));
                    setClusterId.add(objUnit.Cluster__c);
                }
            }

            return listCluster;
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static List<Building__c> buildingPicklistValues(String projectId, String clusterId){
        try {
            List<Building__c> listBuilding = new List<Building__c>();
            List<Building__c> listBuildingNumber = new List<Building__c>();
            List<Building__c> listBuildingString = new List<Building__c>();
            Set<Id> setBuildingId = new Set<Id>();
            String query = 'SELECT id, name, Building__c, Building__r.Name FROM Unit__c WHERE Project__c =: projectId AND Unit_Purpose__c = \'Leasing\' AND Building__c != null' ;
            if(!String.isBlank(clusterId)){
                query = query + ' AND Cluster__c = \''+clusterId+'\'';
            }
            query = query + ' ORDER BY Building__r.Name ASC';
            List<Unit__c> unitList = Database.query(query);
            List<BuildingWrapper> listBuildingWrapper = new List<BuildingWrapper>();
            
            for(Unit__c objUnit : unitList){
                if(!setBuildingId.contains(objUnit.Building__c)){
                    if(objUnit.Building__r.Name.isNumeric()){
                        listBuildingWrapper.add(new BuildingWrapper(objUnit.Building__r));
                        
                        //mapBuildings.Put(integer.valueOf(objUnit.Building__r.Name), new Building__c(id=objUnit.Building__c, name=objUnit.Building__r.Name));
                        //listBuildingNumber.add();
                    }else{
                        listBuildingString.add(new Building__c(id=objUnit.Building__c, name=objUnit.Building__r.Name));
                    }
                    
                    setBuildingId.add(objUnit.Building__c);
                }
            }
            listBuildingWrapper.sort();
            for(BuildingWrapper bw: listBuildingWrapper){
                listBuildingNumber.add(new Building__c(id=bw.objBuilding.Id, name=bw.objBuilding.Name));
            }
            listBuildingString.sort();
            listBuilding.addAll(listBuildingNumber);
            listBuilding.addAll(listBuildingString);
            return listBuilding;
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Floor__c> floorPicklistValues(String projectId, String clusterId, String buildingId){
        try {
            List<Floor__c> listFloor = new List<Floor__c>();
            Set<Id> setFloorId = new Set<Id>();

            String query = 'SELECT id, name, Floor__c, Floor__r.Name FROM Unit__c WHERE Project__c =: projectId AND Unit_Purpose__c = \'Leasing\' AND Floor__c != null';
            if(!String.isBlank(buildingId)){
                query = query + ' AND Building__c = \''+buildingId+'\'';
            }
            if(!String.isBlank(clusterId)){
                query = query + ' AND Cluster__c = \''+clusterId+'\'';
            }
            query = query + ' ORDER BY Floor__r.Name';
            List<Unit__c> unitList = Database.query(query);
            for(Unit__c objUnit : unitList){
                if(!setFloorId.contains(objUnit.Floor__c)){
                    listFloor.add(new Floor__c(id=objUnit.Floor__c, name=objUnit.Floor__r.Name));
                    setFloorId.add(objUnit.Floor__c);
                }
            }

            return listFloor;
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /***********************************************************************************************************************
    * @Description  This method is used to generate Booking For Selected Units
    * @Param        String strUnitDetails, String projectId, String projectName, String strLeasingType
    * @Return       String
    ***********************************************************************************************************************/
    @AuraEnabled
    public static String generateBookingForSelectedUnits(String strUnitDetails, String projectId, String strLeasingType, String strLeaseStartDate){
        try {
            List<UnitDetailsWrapper> listUnitDetailsWrapper = (List<UnitDetailsWrapper>) JSON.deserialize(strUnitDetails, List<UnitDetailsWrapper>.class);

            if(!listUnitDetailsWrapper.isEmpty()){
                Id opptyRecordTypeId;
                String strOpptyLeasingType;
                if(strLeasingType == 'resedential'){
                    opptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Units Quick Leasing').getRecordTypeId();
                    strOpptyLeasingType = 'Residential Units';
                }

                if(strLeasingType == 'commercial'){
                    opptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Commercial Units Quick Leasing').getRecordTypeId();
                    strOpptyLeasingType = 'Commercial Units';
                }                

                Opportunity objOpportunity = new Opportunity();
                objOpportunity.Name = 'Draft Booking';
                objOpportunity.RecordTypeId = opptyRecordTypeId;
                objOpportunity.Project__c = projectId;
                objOpportunity.Leasing_Type__c = strOpptyLeasingType;
                objOpportunity.Interested_In__c = 'Residential Leasing';
                objOpportunity.StageName = 'New';
                objOpportunity.CloseDate = System.today() + 15;
                objOpportunity.Lease_Start_Date__c = Date.valueOf(strLeaseStartDate);
                insert objOpportunity;
                
                List<Unit_Plan__c> listUnitPlan = new List<Unit_Plan__c>();
                List<Unit__c> listUnits = new List<Unit__c>();

                for(UnitDetailsWrapper objUnitDetailsWrapper : listUnitDetailsWrapper){
                    Unit_Plan__c objUnitPlan = new Unit_Plan__c();
                    objUnitPlan.Name = objUnitDetailsWrapper.Name;
                    objUnitPlan.Unit__c = objUnitDetailsWrapper.Id;
                    objUnitPlan.Project__c = projectId;
                    objUnitPlan.Opportunity__c = objOpportunity.Id;
                    listUnitPlan.add(objUnitPlan);

                    listUnits.add(new Unit__c(Id = objUnitDetailsWrapper.Id, Unit_Status__c = 'On Hold'));
                }

                if(!listUnitPlan.isEmpty()){
                    insert listUnitPlan;
                } 

                if(!listUnits.isEmpty()){
                    update listUnits;
                }  

                return objOpportunity.Id;
            }

            return null;
        } catch (Exception e) {
            system.debug('Error : ' + e.getMessage());   
            return 'Error Occurred. Please Contact System Administrator.';
        }
    }

    /***********************************************************************************************************************
    * @Description  This method is used to generate Lease Offer For Selected Units
    * @Param        String strSelectedUnitDetails, String strSelectedEmails
    * @Return       String
    ***********************************************************************************************************************/
    @AuraEnabled
    public static String createLeaseOfferRecords(String strSelectedUnitDetails, String strSelectedEmails){
        try {
            List<UnitDetailsWrapper> listUnitDetailsWrapper = (List<UnitDetailsWrapper>) JSON.deserialize(strSelectedUnitDetails, List<UnitDetailsWrapper>.class);
            List<String> listEmails = (List<String>) JSON.deserialize(strSelectedEmails, List<String>.class);

            if(!listUnitDetailsWrapper.isEmpty()){
                Lease_Offer__c objLeaseOffer = new Lease_Offer__c();
                objLeaseOffer.Email__c = String.join(listEmails,',');
                insert objLeaseOffer;
                
                List<Offered_Items__c> listOfferedItems = new List<Offered_Items__c>();

                for(UnitDetailsWrapper objUnitDetailsWrapper : listUnitDetailsWrapper){
                    Offered_Items__c objOfferedItems = new Offered_Items__c();
                    objOfferedItems.Lease_Offer__c = objLeaseOffer.Id;
                    objOfferedItems.Unit__c = objUnitDetailsWrapper.Id;
                    listOfferedItems.add(objOfferedItems);
                }

                if(!listOfferedItems.isEmpty()){
                    insert listOfferedItems;
                }     
                
                return 'success';         
            }

            return null;
        } catch (Exception e) {
            system.debug('Error : ' + e.getMessage());   
            return 'Error Occurred. Please Contact System Administrator.';
        }
    }

    //Wrapper Class
    public class UnitDetailsWrapper{
        public String Id;
        public String Name;
    }
    
    /*
    * Author - Hitesh Patel
    * Date - 24 May 2022
    * Description - Comparable class to compare and sort during round robin assignment based on utilization.
    */
    public class BuildingWrapper implements Comparable{
        public Decimal score;
        public Building__c objBuilding;
        
        public BuildingWrapper(Building__c building){
            objBuilding = building;
        }
              
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            BuildingWrapper compareToResource = (BuildingWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (integer.valueOf(objBuilding.Name) > integer.valueOf(compareToResource.objBuilding.Name)) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (integer.valueOf(objBuilding.Name) < integer.valueOf(compareToResource.objBuilding.Name)) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            return returnValue;       
        }
    }
}