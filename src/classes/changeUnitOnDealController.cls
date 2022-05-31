public with sharing class changeUnitOnDealController{
    
    @AuraEnabled( cacheable=true )  
    public static List <Change_Unit_Setting__mdt> fetchChangeUnitSetting() {        
        List <Change_Unit_Setting__mdt> listMetadataSetting = [SELECT Id, Unit_Table_Page_Size__c, Unit_Object_Leasing_Record_Type_Id__c FROM Change_Unit_Setting__mdt WHERE DeveloperName = 'Change_Unit_Setting' LIMIT 1];
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
            String query = 'SELECT id, Name, Leasing_Type__c, Project__r.Name, Cluster__c, Unit_Code__c, No_of_Bedrooms__c, Unit_space_Type__c, Unit_type__c, Building__c, Building__r.Name, Floor__c, Floor__r.Name, Total_Leasable_Area__c, Unit_Status__c, Leasing_Property_Type__c, Base_Rent__c, Security_Deposit__c FROM Unit__c WHERE Unit_Status__c = \'Vacant\' AND';
            if(!String.isBlank(projId)){
                query = query + ' Leasing_Type__c = ' +'\''+leasingType+'\' AND';
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
                query = query + ' Building__c = \''+building+'\' AND';
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
            Set<Id> setBuildingId = new Set<Id>();
            String query = 'SELECT id, name, Building__c, Building__r.Name FROM Unit__c WHERE Project__c =: projectId AND Unit_Purpose__c = \'Leasing\' AND Building__c != null';
            if(!String.isBlank(clusterId)){
                query = query + ' AND Cluster__c = \''+clusterId+'\'';
            }
            query = query + ' ORDER BY Building__r.Name';
            List<Unit__c> unitList = Database.query(query);
            for(Unit__c objUnit : unitList){
                if(!setBuildingId.contains(objUnit.Building__c)){
                    listBuilding.add(new Building__c(id=objUnit.Building__c, name=objUnit.Building__r.Name));
                    setBuildingId.add(objUnit.Building__c);
                }
            }

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
    * @Description  This method is used to generate Case record For Selected Units
    * @Param        String strSelectedUnitDetails, String strSelectedEmails
    * @Return       String
    ***********************************************************************************************************************/
    @AuraEnabled
    public static String createCaseRecord(String oppId, String strChangeUnit, String strReason, String strNewTenant, String strUnitDetails, Date dtPreferredLeaseStartDate){
        try {
            Opportunity objOpp = [SELECT Id, Name, Project__r.Name, Lease_Start_Date__c, Lease_End_Date__c, AccountId FROM Opportunity WHERE Id =: oppId];
            List<UnitDetailsWrapper> listUnitDetailsWrapper = (List<UnitDetailsWrapper>) JSON.deserialize(strUnitDetails, List<UnitDetailsWrapper>.class);
               
            if(strChangeUnit == 'During Lease'){            
                Id caseRecordTypeIdUnitChange = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unit Change').getRecordTypeId();
                
                Case objCase = new Case();
                objCase.RecordtypeId = caseRecordTypeIdUnitChange;
                objCase.Subject = 'Change of Unit request for - ' + objOpp.Name;
                // objCase.Lease_Start_Date__c = objOpp.Lease_Start_Date__c;
                objCase.Lease_End_Date__c = objOpp.Lease_End_Date__c;
                objCase.Unit_change_date__c = system.today();
                objCase.Reason_for_unit_change__c = strReason;
                objCase.Type = 'Unit Change';
                objCase.Origin = 'Salesforce';
                objCase.AccountId = objOpp.AccountId;
                objCase.Deal__c = objOpp.Id;
                objCase.Bulk_Add_Units__c = true;
                objCase.Do_you_want_to_be_treated_as_new_tenant__c = strNewTenant;
                objCase.Lease_Start_Date__c = dtPreferredLeaseStartDate;
                objCase.Flag_UnitAddedOnCase__c = true;
                insert objCase;
                
                
                List<Case_unit__c> listCaseUnit = new List<Case_unit__c>();
                Id leaseRecordTypeId = Schema.SObjectType.Case_unit__c.getRecordTypeInfosByName().get('Lease').getRecordTypeId();
                for(UnitDetailsWrapper objUnitDetailsWrapper : listUnitDetailsWrapper){
                    if(objUnitDetailsWrapper.selected){                    
                        Case_unit__c objCaseUnit = new Case_unit__c();
                        objCaseUnit.Case__c = objCase.Id;
                        objCaseUnit.RecordTypeId = leaseRecordTypeId;
                        objCaseUnit.Type__c = 'New';
                        objCaseUnit.Unit__c = objUnitDetailsWrapper.Id;
                        listCaseUnit.add(objCaseUnit);
                        
                        
                    }
                }
                
                for(Unit_Plan__c objUnitPlan : [SELECT Id, Unit__c FROM Unit_Plan__c WHERE Opportunity__c =: Id.valueOf(oppId)]){
                    Case_unit__c objCaseUnit = new Case_unit__c();
                    objCaseUnit.Case__c = objCase.Id;
                    objCaseUnit.RecordTypeId = leaseRecordTypeId;
                    objCaseUnit.Type__c = 'Existing';
                    objCaseUnit.Unit__c = objUnitPlan.Unit__c;
                    listCaseUnit.add(objCaseUnit);
                }

                if(!listCaseUnit.isEmpty()){
                    insert listCaseUnit;
                }
                ServiceRequestActions.execApprovalforUpgradeandDowngrade(objCase.Id);
                return objCase.Id;
            }
            
               
            if(strChangeUnit == 'End of Lease'){
                String strLocationCode = '';
                for(UnitDetailsWrapper objUnitDetailsWrapper : listUnitDetailsWrapper){
                    if(objUnitDetailsWrapper.selected){  
                        if(strLocationCode == ''){
                            strLocationCode = objUnitDetailsWrapper.strLocationCode;
                        }else{
                            strLocationCode += ', ' + objUnitDetailsWrapper.strLocationCode;
                        }
                    }
                }
                String strTaskComment = 'Customer has requested to change the units to this units. ' + strLocationCode;
                Task objTask = new Task();
                objTask.Subject = 'Change of Unit request for - ' + objOpp.Name;
                objTask.OwnerId = UserInfo.getUserId();
                objTask.WhatId = oppId;
                objTask.ActivityDate = objOpp.Lease_End_Date__c - 15;
                
                objTask.Description = strTaskComment; 
                insert objTask;

                return '';
            }
            
            return '';
        } catch (Exception e) {
            system.debug('Error : ' + e.getMessage());
            return 'Error Occurred. Please Contact System Administrator.';
        }
    }
    
    //Wrapper Class
    public class UnitDetailsWrapper{
        public Boolean selected;
        public String Id;
        public String Name;
        public String strLocationCode;
    }
}