public with sharing class UnitLeasingSelectionClass {
    
    @AuraEnabled
    public static UnitLeasingWrapperClass.filtersWrapper getFilters(String recordId){
        UnitLeasingWrapperClass.filtersWrapper fieldWrap = new UnitLeasingWrapperClass.filtersWrapper();
        String LeasingUnitType = System.Label.Unit_Type_for_Units;
        String LeasingShopUnitType = System.Label.UnitType_For_Shops;
        Map<String,String> mapOfPropertyType = new Map<String,String>();
        Map<String,String> mapOfUnitType = new Map<String,String>();
        Map<String,String> mapOfprojects = new Map<String,String>();
        Map<String,String> mapOflocation = new Map<String,String>();
        Map<String,String> mapOfNoOfBedrooms = new Map<String,String>();
        Map<String,String> mapOfSpaceType = new Map<String,String>();
        Map<String,String> mapOfCluster = new Map<String,String>();
        Map<String,String> mapOfBuilding = new Map<String,String>();
        String leasingType = '';
        
        if(recordId != null){
            //Added by Karishma for dependent picklist 29th March 2022
            Opportunity oppty = getOptyRecord(recordId);
            if(oppty.Leasing_Type__c != null){
                leasingType = oppty.Leasing_Type__c == 'Residential Units' ? 'Residential Unit' : 'Commercial Unit';
            }
            /* if(getOptyRecord(recordId).Leasing_Type__c == System.Label.Shop_Leasing_type){
for(String s : LeasingShopUnitType.split(',')){
mapOfUnitType.put(s,s);
}
}
if(getOptyRecord(recordId).Leasing_Type__c == System.Label.Units_Leasing_type){
for(String s : LeasingShopUnitType.split(',')){
mapOfUnitType.put(s,s);
}
}
} else {*/
            
            //}
            mapOfPropertyType = getDependentPicklistValuesAsPerLeasingType(leasingType,'Unit__c','Leasing_Type__c','Leasing_Property_Type__c');//getPicklistValues('Unit__c','Leasing_Property_Type__c'); //Added by Karishma for dependent picklist 29th March 2022
            mapOfUnitType = getDependentPicklistValuesAsPerLeasingType(leasingType,'Unit__c','Leasing_Type__c','Unit_space_Type__c'); //getPicklistValues('Unit__c','Unit_space_Type__c'); //Added by Karishma for dependent picklist 29th March 2022
            mapOfprojects = getObjectValues('Project__c', 'Leasing');
            mapOflocation = getObjectValues('Location','');
            mapOfSpaceType = getObjectValues('Space_Type__c','');
            mapOfNoOfBedrooms = getPicklistValues('Unit__c', 'No_of_Bedrooms__c');
            mapOfCluster = getOptyRecord(recordId).project__c != null ? getObjectValues('Cluster__c', getOptyRecord(recordId).project__c) : null;
            mapOfBuilding = getOptyRecord(recordId).project__c != null ? getObjectValues('Building__c',getOptyRecord(recordId).project__c) : null;
            fieldWrap.propertyType = mapOfPropertyType != null ? mapOfPropertyType : null;
            fieldWrap.unitType = mapOfUnitType != null ? mapOfUnitType : null;
            fieldWrap.LocationMap = mapOflocation != null ? mapOflocation : null;
            fieldWrap.spaceMap = mapOfSpaceType != null ? mapOfSpaceType : null;
            fieldWrap.NoOfBedroomsMap = mapOfNoOfBedrooms != null ? mapOfNoOfBedrooms : null;
            fieldWrap.projectMap = mapOfprojects != null ? mapOfprojects : null;
            fieldWrap.clusterMap = mapOfCluster != null ? mapOfCluster : null;
            fieldWrap.buildingMap = mapOfBuilding;
            List<Unit_Plan__c> unitplanlst = new List<Unit_Plan__c>();
            for(Unit_Plan__c up : [Select Id,Unit__c FROM Unit_Plan__c where Opportunity__c =: recordId]){
                unitplanlst.add(up);
            }
            fieldWrap.unitList = unitplanlst;
            fieldWrap.oppRecord =  getOptyRecord(recordId) != null ? getOptyRecord(recordId) : null;
            fieldWrap.unitWrapper = SearchUnits(recordId) != null ?  SearchUnits(recordId) : null;
        }
        
        return fieldWrap; 
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
    public static map<string,string> fetchBuilding(String cluster,String project){
        map<string,string> mapBuilding = new map<string,string>();
        if(String.isNotBlank(cluster)){
            for(Building__c cls :[select Id,Name from Building__c where Cluster__c =:cluster and project__c =: project])
            {
                mapBuilding.put(cls.Id,cls.Name);
                system.debug(mapBuilding.size());
            }  
        } else {
            for(Building__c cls :[select Id,Name from Building__c where project__c =: project])
            {
                mapBuilding.put(cls.Id,cls.Name);
                system.debug(mapBuilding.size());
            }  
        }
        return mapBuilding;
    }
    @AuraEnabled
    public static Opportunity getOptyRecord(String recordId){
        Opportunity  opp = [Select Id,Project__c,Project__r.Name,Leasing_Type__c,Account.RecordType.Name,Account.IsPersonAccount,Lease_Renewal_Approval_Status__c,Unit_Selection_Sent_for_Approval__c,
                            Account.Emirates_Ids__c From Opportunity where ID =: recordId limit 1]; 
        
        return opp;
        
    }
    @AuraEnabled
    public static Opportunity OptyRecord(String recordId){
        Opportunity  opp = [Select Id,Project__c,Project__r.Name,Leasing_Type__c,Account.RecordType.Name,Account.IsPersonAccount,Lease_Renewal_Approval_Status__c,Unit_Selection_Sent_for_Approval__c,
                            Account.Emirates_Ids__c From Opportunity where ID =: recordId limit 1]; 
        
        return opp;
        
    }
    
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
        system.debug('values '+JSON.serialize(options));
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getObjectValues(string obj,String filter){
        Map<String, String> options = new Map<String, String>();
        String recordQuery = 'SELECT Id, Name FROM ';
        if(String.isNotBlank(obj)){
            recordQuery += obj;
            if(String.isNotBlank(filter)){
                if(obj == 'Project__c'){
                    recordQuery += ' where Project_Purpose__c =\''+ filter +'\'';
                }  
                if(obj == 'Cluster__c'){
                    recordQuery += ' where Project__c =\''+ filter +'\'';
                } 
                if(obj == 'Building__c'){
                    recordQuery += ' where Project__c =\''+ filter +'\'';
                }
            }
            List<sObject> records = Database.query(recordQuery);
            for(sObject sobj : records){
                options.put(String.valueof(sobj.get('Id')),String.valueof(sobj.get('Name')));
            }
            
        }   
        return options;
    }
    @AuraEnabled
    public static List<UnitLeasingWrapperClass.unitwrapper> SearchUnits(String recordId){
        system.debug('inside search methods :'+recordId);
        String query = 'Select Id,name,active__c,unit_code__c,unit_leasing_type__r.name,unit_leasing_type__c,Business_Unit__c,Project__r.Name,No_of_Bedrooms__c,No_of_Car_Parkings__c,Location__r.Name,Floor__c,Floor__r.Name,Building__r.Name,Space_Type__c,Business_Group__c,unit_status__c,Unit_type__c,Base_Rent__c,Usable_Area__c,Assignable_Area__c,Building__c,Project__c,Space_Types__c,Space_Types__r.Name,Built_Up_Area_Sqft__c,Total_Leasable_Area__c,Unit_space_Type__c,Leasing_Property_Type__c,Price_Per_SQ_FT__c,Leasing_Type__c from Unit__c where RecordType.Name = \'Leasing\' and unit_status__c = \'Vacant\' ';
        List<UnitLeasingWrapperClass.unitwrapper> unitwraplst = new List<UnitLeasingWrapperClass.unitwrapper>();
        Opportunity  opp = getOptyRecord(recordId);
        system.debug('opp'+opp);
        if(getOptyRecord(recordId).Leasing_Type__c != null){
            if(getOptyRecord(recordId).Leasing_Type__c == System.Label.Shop_Leasing_type){
                query += ' AND Leasing_Type__c =\'Commercial Unit\''; 
            }
            system.debug('query'+query);
            if(getOptyRecord(recordId).Leasing_Type__c == System.Label.Units_Leasing_type){
                query += ' AND Leasing_Type__c =\'Residential Unit\''; 
            }
            system.debug('query'+query);
        }
        if(String.isNotBlank(getOptyRecord(recordId).project__c)){
            String project = getOptyRecord(recordId).project__c;
            query += ' AND project__c =\''+ project +'\'';
        }
        system.debug('query'+query);
        List<Unit__c> unitlst = database.query(query);
        system.debug('unitlst'+unitlst);
        
        List<Id> listUnitId =new List<Id>(); 
        List<Id> buildingIdList =new List<Id>();  
        List<Id> projectIdList =new List<Id>();  
        
        
        for(Unit__c unit : unitlst){
            listUnitId.add(unit.Id);
            if(String.isNotEmpty(unit.Building__c)){
                buildingIdList.add(unit.Building__c);
            }
            if(String.isNotEmpty(unit.Project__c)){
                projectIdList.add(unit.Project__c);
            } 
        }
        
        Map<Id, List<String>> activeUnitFlag = CheckFlags.checkUnitFlags(listUnitId);
        Map<Id, List<String>> activeBuildingFlag = CheckFlags.checkBuildingFlags(buildingIdList);
        Map<Id, List<String>> activeProjectFlag = CheckFlags.checkProjectFlags(projectIdList);
        
        
        For(Unit__c u : unitlst){
            UnitLeasingWrapperClass.unitwrapper uwrap = new UnitLeasingWrapperClass.unitwrapper();
            
            if(activeUnitFlag.containsKey(u.id) || activeBuildingFlag.containsKey(u.Building__c) || activeProjectFlag.containsKey(u.Project__c)) {
                uwrap.activeFlag = true;
            }
            else{
                uwrap.activeFlag = false;
            }
            
            uwrap.propFlag = false;
            uwrap.unit = u;
            unitwraplst.add(uwrap);
        }
        
        return unitwraplst;
    }
    
    @AuraEnabled
    public static List<Unit__c> findUnitByName(String searchKey) {
        List<unit__c> unitlist = new List<unit__c> ();
        if(string.isBlank(searchKey)){
            
            unitlist = [Select Id,name,active__c,unit_code__c,unit_leasing_type__r.name,unit_leasing_type__c,Business_Unit__c,Project__c, Floor__c, Business_Group__c,unit_status__c,Total_Leasable_Area__c,Unit_space_Type__c,Leasing_Property_Type__c from Unit__c  WHERE active__c = true order by name]; 
            //Status__c='Active' 
        }
        else{
            String name =  + '%' + searchKey + '%';
            unitlist =  [Select Id,name,active__c,unit_code__c,unit_leasing_type__r.name,unit_leasing_type__c,Business_Unit__c,Project__c, Floor__c, Business_Group__c,unit_status__c,Total_Leasable_Area__c,Unit_space_Type__c,Leasing_Property_Type__c from Unit__c  WHERE name LIKE :name and active__c = true order by name];
        }
        return unitlist;
    }
    @AuraEnabled
    public static UnitLeasingWrapperClass.filtersWrapper searchUnit(string cluster, string project, string building,String propertyType,String propertyView,String spaceType,
                                                                    string type, Integer minPrice, Integer maxPrice,
                                                                    String pageSize, String pageNumber,String oppId, String noOfBedrooms, String unitType, String unitCode){
                                                                        system.debug('inside search method :'+oppId);
                                                                        UnitLeasingWrapperClass.filtersWrapper fieldWrap = new UnitLeasingWrapperClass.filtersWrapper(); 
                                                                        List<UnitLeasingWrapperClass.unitwrapper> unitwraplst = new List<UnitLeasingWrapperClass.unitwrapper>();
                                                                        Opportunity  opp = [Select Id,project__c,Leasing_Type__c From Opportunity where ID =: oppId limit 1];
                                                                        List<Unit_Plan__c> unitIds = new List<Unit_Plan__c>();
                                                                        for(Unit_Plan__c up : [Select Id,Unit__c FROM Unit_Plan__c where Opportunity__c =: oppId]){
                                                                            unitIds.add(up);
                                                                        }
                                                                        // try {           
                                                                        String query = 'Select Id,name,active__c,Unit_Code__c,Unit_space_Type__c,unit_leasing_type__r.name,unit_leasing_type__c,Business_Unit__c,Project__r.Name,No_of_Bedrooms__c,No_of_Car_Parkings__c,Location__r.Name,Floor__c,Floor__r.Name,Building__r.Name,Space_Type__c,Business_Group__c,unit_status__c,Unit_type__c,Base_Rent__c,Usable_Area__c,Assignable_Area__c,Building__c,Project__c,Space_Types__c,Space_Types__r.Name,Built_Up_Area_Sqft__c,Total_Leasable_Area__c,Leasing_Property_Type__c,Price_Per_SQ_FT__c,Leasing_Type__c from Unit__c where RecordType.Name = \'Leasing\' and unit_status__c = \'Vacant\' ';
                                                                        if(String.isNotBlank(cluster)){
                                                                            query += ' AND cluster__c=\''+ cluster +'\'';
                                                                        }
                                                                        if(String.isNotBlank(noOfBedrooms)){
                                                                            query += ' AND No_of_Bedrooms__c =\''+ noOfBedrooms +'\'';
                                                                        }
                                                                        if(String.isNotBlank(unitType)){
                                                                            query += ' AND Unit_space_Type__c =\''+ unitType +'\'';
                                                                        }
                                                                        if(String.isNotBlank(building)){
                                                                            query += ' AND Building__c=\''+ building +'\'';
                                                                        }
                                                                        
                                                                        if(String.isNotBlank(propertyType)){
                                                                            query += ' AND Leasing_Property_Type__c=\''+ propertyType +'\'';
                                                                        }
                                                                        if(String.isNotBlank(propertyView)){
                                                                            query += ' AND Location__c=\''+ propertyView +'\'';
                                                                        }
                                                                        
                                                                        if(String.isNotBlank(project)){
                                                                            query += ' AND project__c =\''+ project +'\' ';
                                                                        }
                                                                        
                                                                        if(String.isNotBlank(spaceType)){
                                                                            query += ' AND Unit_Leasing_Type__c =\''+ spaceType +'\'';
                                                                        }
                                                                        
                                                                        
                                                                        if(getOptyRecord(oppId).Leasing_Type__c == System.Label.Shop_Leasing_type){
                                                                            query += ' AND Leasing_Type__c =\'Commercial Unit\''; 
                                                                        }
                                                                        system.debug('query'+query);
                                                                        if(getOptyRecord(oppId).Leasing_Type__c == System.Label.Units_Leasing_type){
                                                                            query += ' AND Leasing_Type__c =\'Residential Unit\''; 
                                                                        }
                                                                        //Added by Sajid
                                                                        if(String.isNotBlank(unitCode)){
                                                                            String tempInput = '%' + unitCode + '%';
                                                                            query += ' AND Unit_Code__c LIKE \''+ tempInput +'\'';
                                                                        }
                                                                        system.debug('@@@TH>>query>>' + query);
                                                                        // query on unit to fetch results
                                                                        
                                                                        List<Unit__c> lstUnit = Database.query(query);
                                                                        System.debug('TH' + lstUnit.size());
                                                                        System.debug('@@@TH' + lstUnit);
                                                                        
                                                                        if(lstUnit.size() > 0){
                                                                            List<Id> listUnitId =new List<Id>(); 
                                                                            List<Id> buildingIdList =new List<Id>();  
                                                                            List<Id> projectIdList =new List<Id>();  
                                                                            
                                                                            
                                                                            for(Unit__c unit : lstUnit){
                                                                                listUnitId.add(unit.Id);
                                                                                if(String.isNotEmpty(unit.Building__c)){
                                                                                    buildingIdList.add(unit.Building__c);
                                                                                }
                                                                                if(String.isNotEmpty(unit.Project__c)){
                                                                                    projectIdList.add(unit.Project__c);
                                                                                } 
                                                                            }
                                                                            
                                                                            Map<Id, List<String>> activeUnitFlag = CheckFlags.checkUnitFlags(listUnitId);
                                                                            Map<Id, List<String>> activeBuildingFlag = CheckFlags.checkBuildingFlags(buildingIdList);
                                                                            Map<Id, List<String>> activeProjectFlag = CheckFlags.checkProjectFlags(projectIdList);
                                                                            
                                                                            List<Id> unitIdList=new List<Id>();                    
                                                                            for(Unit__c u : lstUnit){
                                                                                
                                                                                unitIdList.add(u.id);
                                                                                UnitLeasingWrapperClass.unitwrapper uwrap = new UnitLeasingWrapperClass.unitwrapper();
                                                                                
                                                                                if(activeUnitFlag.containsKey(u.id) || activeBuildingFlag.containsKey(u.Building__c) || activeProjectFlag.containsKey(u.Project__c)) {
                                                                                    uwrap.activeFlag = true;
                                                                                }
                                                                                else{
                                                                                    uwrap.activeFlag = false;
                                                                                }
                                                                                
                                                                                uwrap.propFlag = false;
                                                                                uwrap.unit = u;
                                                                                unitwraplst.add(uwrap);
                                                                            }
                                                                            fieldWrap.oppRecord =  getOptyRecord(oppId) != null ? getOptyRecord(oppId) : null;
                                                                            fieldWrap.unitWrapper = unitwraplst;
                                                                            fieldWrap.unitList = unitIds;  
                                                                            return fieldWrap;
                                                                        }
                                                                        else {
                                                                            return null;    
                                                                        }
                                                                        /*} 
catch(exception ex){
system.debug(ex.getMessage());
return null;
}*/
                                                                        
                                                                    }
    @AuraEnabled
    public static void addUnitstoOpp(String OppId,List<ID> unitsList){
        system.debug('%%unitsList'+unitsList);
        system.debug('OppId'+OppId);
        integer i=1;
        List<unit__c> unitsLists = [select id,unit_code__c,Commission_Amount__c ,base_rent__c,unit_leasing_type__r.name,unit_leasing_type__c,Assignable_Area__c,Project__r.Name,Unit_type__c,Total_Saleable_Area_Sqft__c,Space_Types__c,Building__c,Cluster__c,Project__c,Leasing_Selling_Price__c,name,Master_Payment_Plan__c,Master_Payment_Plan__r.No_of_cheques_Leasing__c from Unit__c where id IN : unitsList];
        Opportunity opp = [Select Id,Booking_Fee_gets_collected__c,Unit_Status__c,name from Opportunity where id=:OppId]; 
        List<Unit_Plan__c> unitPlanList = new List<Unit_Plan__c>();
        opp.Unit_Status__c = 'On Hold';
        update opp;
        List<Payment_Milestone__c> payMileList = new List<Payment_Milestone__c>();
        Map<Id,Integer> unitIdVsAmount = new  Map<Id,Integer>();
        List<Unit__c> updateUnitLst = new List<Unit__c>();
        if(unitsLists.size()>0){
            for(unit__c unit : unitsLists){
                //unitIdVsAmount.put(unit.Master_Payment_Plan__c,Integer.valueOf(unit.Leasing_Selling_Price__c));
                Unit_Plan__c unitObj = new Unit_Plan__c(
                    Name =  unit.unit_code__c,
                    //StageName__c = 'Choose Units',
                    unit__c = unit.Id,
                    Project__c = unit.Project__c,
                    opportunity__c = OppId,
                    Leasing_commission__c = unit.Commission_Amount__c,
                    base_lease_amount__c = unit.base_rent__c
                );
                Unit__c u = new Unit__c();
                u.Id = unit.Id;
                u.unit_Status__c = 'On Hold';                
                unitPlanList.add(unitObj);
                i++;
                updateUnitLst.add(u);
            }
            system.debug('unitPlanList'+unitPlanList);
            insert unitPlanList;
            if(updateUnitLst.size()>0){
                update updateUnitLst;
            }
            
        }
    }
    
    @AuraEnabled
    public static Boolean checkTaggedUnits(String recordId){
        Boolean unitSearchScreenDisable = false; 
        System.debug('In CheckTagged');
        try {
            Opportunity oppty = [SELECT Id,RecordTypeId,RecordType.Name,StageName,(SELECT Id FROM Unit_Plans__r)
                                 FROM Opportunity WHERE Id =: recordId LIMIT 1];
            if(oppty.StageName != 'New' && oppty.Unit_Plans__r.Size() > 0){
                unitSearchScreenDisable = true;
            }else{
                unitSearchScreenDisable = false;
            }
            return unitSearchScreenDisable;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static List<UnitLeasingWrapperClass.unitwrapper> fetchUnits(String recordId){
        try {
            UnitLeasingWrapperClass.filtersWrapper fieldWrap = new UnitLeasingWrapperClass.filtersWrapper();
            fieldWrap.unitWrapper = new List<UnitLeasingWrapperClass.unitwrapper>();
            fieldWrap.unitWrapper = SearchUnits(recordId) != null ?  SearchUnits(recordId) : null;
            system.debug('unit wrapper :'+fieldWrap.unitWrapper);
            return fieldWrap.unitWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //Added by Karishma for dependent picklist 29th March 2022
    @AuraEnabled
    public static Map<String,String> getDependentPicklistValuesAsPerLeasingType(String leasingType, String pObjName,String pControllingFieldName,String pDependentFieldName){
        Map<String,List<PicklistOption>> mapResults = new Map<String,List<PicklistOption>>();
        mapResults = getDependentOptions(pObjName,pControllingFieldName,pDependentFieldName);
        Map<String, String> options = new Map<String, String>();
        for(String controllingFieldValue :mapResults.keySet()){
            if(controllingFieldValue.equalsIgnoreCase(leasingType)){
                for(PicklistOption option : mapResults.get(controllingFieldValue)){
                    options.put(option.value, option.label);
                }
            }
        }
        return options;
    }
    
    //Added by Karishma for dependent picklist 29th March 2022
    @AuraEnabled(cacheable=true)
    public static Map<String,List<PicklistOption>> getDependentOptions(String pObjName,String pControllingFieldName,String pDependentFieldName) {
        Map<String,List<PicklistOption>> mapResults = new Map<String,List<PicklistOption>>();
        //verify/get object schema
        Schema.SObjectType pType = Schema.getGlobalDescribe().get(pObjName);
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
        //get the control & dependent values
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
        //clear heap
        objFieldMap = null;
        //initialize results mapping
        for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){
            mapResults.put( ctrl_ple[pControllingIndex].getValue(), new List<PicklistOption>());
        }
        //serialize dep entries
        List<TPicklistEntry> objDS_Entries = new List<TPicklistEntry>();
        objDS_Entries = (List<TPicklistEntry>)JSON.deserialize(JSON.serialize(dep_ple), List<TPicklistEntry>.class);
        List<Integer> validIndexes;
        for (TPicklistEntry objDepPLE : objDS_Entries){
            validIndexes = cnvBits(objDepPLE.validFor);
            for (Integer validIndex : validIndexes){
                if( validIndex != 0 ) {
                    mapResults.get( ctrl_ple[validIndex-1].getValue() ).add( new PicklistOption(objDepPLE.label, objDepPLE.Value ));
                }
            }
        }
        //clear heap
        objDS_Entries = null;
        system.debug('@@@dependent PicklistValues :'+mapResults);
        //return JSON.serialize(mapResults);
        return mapResults;
    }
    
    //Added by Karishma for dependent picklist 29th March 2022
    public class PicklistOption {
        public String label { get; set; }
        public String value { get; set; }
        public PicklistOption( String label, String value ) {
            this.label = label;
            this.value = value;
        }
    }
    
    //Added by Karishma for dependent picklist 29th March 2022
    public class TPicklistEntry{
        public string active {get;set;}
        public string defaultValue {get;set;}
        public string label {get;set;}
        public string value {get;set;}
        public string validFor {get;set;}
    }
    
    //Added by Karishma for dependent picklist 29th March 2022
    // Converts a base64 string into a list of integers indicating at which position the bits are on
    private static List<Integer> cnvBits (String b64Str) {
        List<Integer> lstOut = new List<Integer>();
        if ( b64Str == null || b64Str == '') return lstOut;
        List<Integer> lstBytes = B64ToBytes(b64Str);
        Integer i, b, v;
        for ( i = 0; i < lstBytes.size(); i++ ) {
            v = lstBytes[i];
            for ( b = 1; b <= 8; b++ ) {
                if ( ( v & 128 ) == 128 ) lstOut.add( (i*8) + b );
                v <<= 1;
            }
        }
        return lstOut;
    }
    
    //Added by Karishma for dependent picklist 29th March 2022
    private static List<Integer> B64ToBytes (String sIn) {
        Map<Integer,Integer> base64 = new Map<Integer,Integer>{65=>0,66=>1,67=>2,68=>3,69=>4,70=>5,71=>6,72=>7,73=>8,74=>9,75=>10,76=>11,77=>12,78=>13,79=>14,80=>15,
            81=>16,82=>17,83=>18,84=>19,85=>20,86=>21,87=>22,88=>23,89=>24,90=>25,97=>26,98=>27,99=>28,100=>29,101=>30,
            102=>31,103=>32,104=>33,105=>34,106=>35,107=>36,108=>37,109=>38,110=>39,111=>40,112=>41,113=>42,114=>43,
            115=>44,116=>45,117=>46,118=>47,119=>48,120=>49,121=>50,122=>51,48=>52,49=>53,50=>54,51=>55,52=>56,53=>57,
            54=>58,55=>59,56=>60,57=>61,43=>62,47=>63};
                List<Integer> lstOut = new List<Integer>();
        if ( sIn == null || sIn == '' ) return lstOut;
        sIn += '='.repeat( 4 - Math.mod( sIn.length(), 4) );
        for ( Integer idx=0; idx < sIn.length(); idx += 4 ) {
            if ( base64.get(sIn.charAt(idx+1)) != null ) lstOut.add( (base64.get(sIn.charAt(idx)) << 2) | (base64.get(sIn.charAt(idx+1)) >>> 4) );
            if ( base64.get(sIn.charAt(idx+2)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+1)) & 15)<<4) | (base64.get(sIn.charAt(idx+2)) >>> 2) );
            if ( base64.get(sIn.charAt(idx+3)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+2)) & 3)<<6) | base64.get(sIn.charAt(idx+3)) );
        }
        return lstOut;
    }
    
    
    @AuraEnabled
    public static List<Property__c> propertyCheckOnCustomer(String recordId){
        Boolean sendForApproval = false; 
        List<Property__c> properties = new List<Property__c>();
        system.debug('In CheckTagged');
        try {
            Opportunity oppty = [SELECT Id,AccountId, Account.IsPersonAccount, RecordType.Name, Lease_Renewal_Approval_Status__c,Unit_Selection_Sent_for_Approval__c FROM 
                                 Opportunity WHERE Id =: recordId AND RecordType.DeveloperName = 'Leasing_Records' AND Account.IsPersonAccount = true LIMIT 1];
            if(oppty != null){
                List<Property__c> propertyList = [SELECT Id,Status__c,Active__c,Deal__c, Deal__r.Lease_Renewal_Approval_Status__c FROM Property__c WHERE 
                                                  Account__c =: oppty.AccountId AND Active__c = true];
                system.debug('In propertyList :'+propertyList);
                for(Property__c property : propertyList){
                    if(property.Status__c.contains('Leased')){
                        properties.add(property);
                    }
                }
                system.debug('In propertyIds :'+properties);
                
            }return properties;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void submitForApproval(String recordId){
        try {
            Opportunity oppty = [SELECT Id, Unit_Selection_Sent_for_Approval__c, Email__c, Account.Primary_Email__c 
                                 FROM Opportunity WHERE Id=:recordId];
            system.debug('@@oppty :'+oppty);
            oppty.Id = recordId;
            oppty.Unit_Selection_Sent_for_Approval__c = true;
            oppty.Email__c = String.valueOf(oppty.Account.Primary_Email__c);
            update oppty;
            // call approval process
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setComments('Customer Owns/Leases one active unit and is looking for another unit');
            request.setObjectId(recordId);
            // Submit on behalf of a specific submitter
            request.setSubmitterId(userinfo.getUserId()); 
            // Submit the record to specific process and skip the criteria evaluation
            request.setProcessDefinitionNameOrId('Approval_Process_for_Property_Selection');
            request.setSkipEntryCriteria(true);
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(request);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}