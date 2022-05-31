/*
Class Name: salesEventTabController
Class Description: Class for lwc salesEventTab
Author: Gaurav Malik
Created Date: 3 Jan, 2022
Updated by: 
Last Update Date: 4 Jan, 2022
*/
//Comment by Swapnil - neeed to use Business_Unit__c instead of master_community__c and use unit_Status__c instead of sales_status__c and leasing_status__c
public with sharing class salesEventTabController {

    @AuraEnabled(Cacheable = true)
    public static list<Unit__c> retriveUnits(String strUnitName) {
        system.debug('i am in retrieve units');
        strUnitName = '%' + strUnitName + '%';
        list<Unit__c> lstUnits = [SELECT  Id,Unit_Code__c, Building__c,Status__c,Space_Type__c,Selling_Price__c,Unit_Theme__c,Built_Up_Area__c,Total_Area__c,
        Final_Plot_Area__c From Unit__c WHERE Unit_Code__c LIKE :strUnitName];

        if(lstUnits.isEmpty()) {
            throw new AuraHandledException('No Record Found..');
        }
        return lstUnits; 
    }
   
    @AuraEnabled(cacheable=true)
    public static List<Business_Unit__c> getMasterCommunityRecords(){
       return [SELECT Id, Name FROM Business_Unit__c];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Project__c> getProjectRecords(){
        return [SELECT Id, Name FROM Project__c];
    }

    @AuraEnabled(cacheable=true)
    public static List<Space_Type__c> getSpaceTypeList(){
        return [SELECT Id, Name FROM Space_Type__c order by Name];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Building__c> getBuildingRecords(){
        return [SELECT Id, Name FROM Building__c];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Project__c> getProjectFromBU(String buId){
       return [SELECT Id, Name FROM Project__c WHERE Business_Unit__c =: buId];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Building__c> getBuildingFromProjectOrBU(String buId, String projectId){
        if(buId!=null){
           return [SELECT Id, Name FROM Building__c WHERE Business_Unit__c =: buId];
        }else{
            return [SELECT Id, Name FROM Building__c WHERE Project__c =: projectId];
        }
    }
    
    //Modified by Shivani
    @AuraEnabled
    public static List<Unit__c> getRecentlyUploadedUnits(String timeframe){
        DateTime objDateTime;
        //String queryBuilder = 'SELECT Id,Submitted_For_Release_Approval__c,Release_Status__c,CreatedBy.Name,CreatedDate, Blocked_Status__c,Unit_Theme_Name__c, Blocked_Sub_Status__c,Built_Up_Area__c,Total_Area__c,Final_Plot_Area__c ,Name,Unit_Code__c,Unit_Status__c,No_of_Bedrooms__c,Total_Selling_Price__c,Selling_Price__c,Unit_Theme__c,Space_Type_Name__c,Function_Type_Name__c ,Function_Type__c,Function_Type__r.Name,Space_Types__r.Name ,Space_Types__c, No_of_Bathrooms__c, Project__r.Name, Building__r.Name, Business_Unit__r.Name,Blocked_By__r.Name, Blocked_By__r.Profile.Name,Blocked_By__r.Profile_Name__c, LastModifiedBy.Profile.Name, Handover_Status__c FROM Unit__c WHERE Unit_Purpose__c = \'Sales\' AND  Unit_Status__c = \'Restricted\'';
        String queryBuilder = 'SELECT Id,Submitted_For_Release_Approval__c,Release_Status__c,CreatedBy.Name,CreatedDate, Blocked_Status__c,Unit_Theme_Name__c, Blocked_Sub_Status__c,Built_Up_Area__c,Total_Area__c,Final_Plot_Area__c ,Name,Unit_Code__c,Unit_Status__c,No_of_Bedrooms__c,Total_Selling_Price__c,Selling_Price__c,Unit_Theme__c,Space_Type_Name__c,Function_Type_Name__c ,Function_Type__c,Function_Type__r.Name,Space_Types__r.Name ,Space_Types__c, No_of_Bathrooms__c, Project__r.Name, Building__r.Name, Business_Unit__r.Name,Blocked_By__r.Name, Blocked_By__r.Profile.Name,Blocked_By__r.Profile_Name__c, LastModifiedBy.Profile.Name, Handover_Status__c FROM Unit__c WHERE Unit_Purpose__c = \'Sales\'';
		set<string> statuses = new set<string>();
        string profileName = getProfileInfo();
        
        if(profileName.containsIgnoreCase('Inventory')){
           statuses = new Set<String>{'Available','Blocked','Uploaded','Restricted'};
        }else if(profileName.containsIgnoreCase('Project')){
           statuses = new Set<String>{'Restricted','Blocked','Sold'};
        }else if(profileName == 'Sales Head' || profileName == 'Sales Manager'){
           statuses = new Set<String>{'Available','Blocked'};
        }
        
        if(statuses.isEmpty() == false){
            queryBuilder += ' AND Unit_Status__c in : statuses ';
        }
    
        if(timeframe.equalsIgnoreCase('day')){
            objDateTime = System.now()-1;
            String formattedDate = objDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            //queryBuilder+= 'AND (createdDate >='+formattedDate +' OR lastmodifieddate >= '+formattedDate + ')';
            queryBuilder+= 'AND createdDate >='+formattedDate;
        }else if(timeframe.equalsIgnoreCase('week')){
            objDateTime = System.now()-7;
            String formattedDate = objDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            //queryBuilder+= 'AND (createdDate >='+formattedDate +' OR lastmodifieddate >= '+formattedDate + ')';
            queryBuilder+= 'AND createdDate >='+formattedDate;
        }else if(timeframe.equalsIgnoreCase('month')){
            objDateTime = System.now()-30;
            String formattedDate = objDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            //queryBuilder+= 'AND (createdDate >='+formattedDate + ' OR lastmodifieddate >= '+formattedDate + ')';
            queryBuilder+= 'AND createdDate >='+formattedDate;
        }
        System.debug('queryBuilder ::' + queryBuilder);
        List<sObject> unitList = Database.query(queryBuilder);
        return unitList;
    }

    @AuraEnabled(cacheable=true)
    public static List<Sales_Event__c> getActiveSalesEvent(){
        return [Select Id, Name, Start_Date__c, End_Date__c  from Sales_Event__c where Status__c = 'Active' AND Start_Date__c <= TODAY AND End_Date__c >= TODAY];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Special_Offer__c> getActiveSpecialOffer(){
        return [Select Id, Name, Start_Date__c, End_Date__c from Special_Offer__c where Active__c  = true AND Start_Date__c <= TODAY AND End_Date__c >= TODAY];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Master_Amenity__c> getAmenities(){
        return [Select Id, Name from Master_Amenity__c];
    }
    
    @AuraEnabled
    public static Boolean addAmenitiestoUnit(List<String> selectedUnitIds, List<String> selectedAmenitiesId){
        
        Boolean flag = false;
        List<Amenity__c> amenityList = new List<Amenity__c>();
        Map<Id,Master_Amenity__c> masterAmenityMap = new Map<Id,Master_Amenity__c>([Select id, Name from Master_Amenity__c where ID in :selectedAmenitiesId]);
        
        for(String unitId : selectedUnitIds){
            for(String masterAmenityID : selectedAmenitiesId){
                Amenity__c amenityRecord = new Amenity__c();
                amenityRecord.Unit__c = unitId;
                //amenityRecord.Name = masterAmenityMap.get(masterAmenityID).Name;
                amenityList.add(amenityRecord);
            }
        }
        if(amenityList.size()>0){
         insert amenityList;
            flag = true;
        }
        System.debug(flag);
        return flag;
    }
    
    @AuraEnabled
    public static Boolean createSpecialOfferItem(List<String> selectedUnitIds, String selectedSpecialOfferID){
        
        List<Special_Offer_Item__c> specialOfferItemList = new List<Special_Offer_Item__c>();
        Boolean flag = false;
        
        for(String unitId : selectedUnitIds){
            Special_Offer_Item__c offerItemRecord = new Special_Offer_Item__c();
            offerItemRecord.Special_Offer__c = selectedSpecialOfferID;
            offerItemRecord.Unit__c = unitId;
            specialOfferItemList.add(offerItemRecord);
        }
        if(specialOfferItemList.size()>0){
            insert specialOfferItemList;
            flag = true;
        }
        return flag;
    }
    
    @AuraEnabled
    public static List<Sales_Event_Unit__c> createSalesEventUnitRecord(List<String> selectedUnitIds, String selectedSalesEventID){
        System.debug('Inside createSalesEventUnitRecord method');
        System.debug('Selected unit Ids '+selectedUnitIds);
        System.debug('Selected Sales Event ID '+selectedSalesEventID);
        List<Sales_Event_Unit__c> salesEventUnitList = new List<Sales_Event_Unit__c>();
        for(String unitId :selectedUnitIds){
            Sales_Event_Unit__c salesEventUnitRecord = new Sales_Event_Unit__c();
            salesEventUnitRecord.Unit__c = unitId;
            salesEventUnitRecord.Sales_Event__c = selectedSalesEventID;
            salesEventUnitList.add(salesEventUnitRecord);
        }
        insert salesEventUnitList;
        System.debug('Sales Event Unit List '+salesEventUnitList);
        return salesEventUnitList;
    }
    
    @AuraEnabled
    public static String getProfileInfo(){
        String profileId = UserInfo.getProfileId();
        Profile p = [Select id, name from Profile where ID =:profileId];
        return p.Name;
    }
    
    @AuraEnabled
    public static Approval__c submitUnitsForInventoryApproval(List<String> selectedUnitIdsList, String approvalType, String lineOfBusiness, String selectedComment){
        
        Approval__c approvalrecord = new Approval__c();
        approvalrecord.Approval_Type__c = 'Inventory Onboarding';
        approvalrecord.Line_of_Business__c = lineOfBusiness; 
        approvalrecord.Comments__c = selectedComment;
        insert approvalrecord;  
        
        List<Approval_Line_Item__c> lineItemList = new List<Approval_Line_Item__c>();
        List<Unit__c> listUnitsToBeUpdated = new List<Unit__c>();
        for(String unitId : selectedUnitIdsList){
            Approval_Line_Item__c lineItemRecord = new Approval_Line_Item__c();
            lineItemRecord.Approval__c = approvalRecord.Id;
            lineItemRecord.Unit__c = unitId;
            lineItemList.add(lineItemRecord);
            listUnitsToBeUpdated.add(new Unit__c( Id = unitId, Submitted_For_Release_Approval__c = true));
        }
        insert lineItemList;   
        
        if(!listUnitsToBeUpdated.isEmpty()){
            update listUnitsToBeUpdated;
        }
        
        approvalrecord = [SELECT ID,Name FROM Approval__c WHERE Id =: approvalrecord.Id LIMIT 1];
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Please Approve!');
        req.setObjectId(approvalrecord.Id);
        req.setProcessDefinitionNameOrId('Inventory_Onboarding_Process');
        req.setSkipEntryCriteria(true);
        // Submit the approval request for the Service Request
        Approval.ProcessResult result = Approval.process(req);
        
        return approvalRecord;
    }
    
    @AuraEnabled
    public static boolean createUnitOptions(List<String> selectedUnitIdsList, String masterOptionId,Decimal price,String pricebookId){
         system.debug('selectedUnitIdsList->'+selectedUnitIdsList);
        List<Unit_Option__c> unitOptionList = new List<Unit_Option__c>();
        Boolean flag = false;
        for(String unitId : selectedUnitIdsList){
            Unit_Option__c unitOption = new Unit_option__c();
            unitOption.Unit__c = unitId;
            unitOption.Master_Option__c = masterOptionId;
            unitOption.Price_Book__c = pricebookId;
            unitOption.Price__c = price;
            unitOptionList.add(unitOption);
        }
        if(unitOptionList.size()>0){
           insert unitOptionList;
            flag = true;
        }
        return flag;
        //system.debug('selectedUnitIdsList->'+unitOptionList);
    }
    
    @AuraEnabled
    public static List<Unit_Option__c> getUnitOptions(){
        return [SELECT id,name FROM Unit_Option__c];
    }
    
    //Modified by Shivani
    @AuraEnabled
    public static ButtonVisibilityWrapper getUnitsOnSearchUnit(String buId, String projectId, String buildingId, String noOfBedrooms, String unitStatus, 
    String blockedStatus, String spaceType, List<String> listUnitCodes ,String salesEvent, String unitCode, list<Unit__c> basketData){
        System.debug('@@@'+buId);
        System.debug('@@@'+projectId);
        System.debug('@@@'+buildingId);
        System.debug('@@@'+noOfBedrooms);
        System.debug('@@@'+unitStatus);
        System.debug('@@@'+blockedStatus);
        System.debug('@@@'+listUnitCodes);
        System.debug('@@@'+unitCode);
        System.debug('==basketData=='+basketData);
		Set<String> statuses = new Set<String>();       
        ButtonVisibilityWrapper wrapperRecord = new ButtonVisibilityWrapper();
        string profileName = getProfileInfo();
        
        String queryBuilder = 'SELECT Id,Submitted_For_Release_Approval__c,Sales_Event_Name__c,Release_Status__c ,CreatedBy.Name,CreatedDate, Blocked_Status__c,Unit_Theme_Name__c, Blocked_Sub_Status__c,Built_Up_Area__c,Total_Area__c,Final_Plot_Area__c ,Name,Unit_Code__c,Unit_Status__c,No_of_Bedrooms__c,Total_Selling_Price__c,Selling_Price__c,Unit_Theme__c,Space_Type_Name__c,Function_Type_Name__c ,Function_Type__c,Function_Type__r.Name,Space_Types__r.Name ,Space_Types__c, No_of_Bathrooms__c, Project__r.Name, Building__r.Name, Business_Unit__r.Name,Blocked_By__r.Name,Blocked_By__r.Profile_Name__c, LastModifiedBy.Profile_Name__c, Handover_Status__c FROM Unit__c WHERE Unit_Purpose__c = \'Sales\'';
        if(basketData != null && basketData.size() > 0){
            queryBuilder+=' AND Id Not in : basketData ';
        }
        if(buId.length()>0 || projectId.length()>0 || buildingId.length()>0 || noOfBedrooms.length()>0 || unitStatus.length()>0 || blockedStatus.length()>0 
            || listUnitCodes.size() > 0 || salesEvent.length()>0 || (string.isNotEmpty(unitCode) && unitCode.length()>0 || spaceType.length()>0) ){
            queryBuilder+= ' AND';
        }
        if(buId.length()>0){
            queryBuilder+=' Business_Unit__c =: buId AND';
        }
        if(projectId.length()>0){
            queryBuilder+= ' Project__c =: projectId AND';
        }
        if(string.isNotEmpty(unitCode) && unitCode.length()>0){
            unitCode = '%' + unitCode + '%';
            queryBuilder+= ' Unit_Code__c LIKE : unitCode AND';
            System.debug('unitCode.length() ==>'+queryBuilder);
        }
        if(buildingId.length()>0){
            queryBuilder+= ' Building__c =: buildingId AND';
        }
        if(noOfBedrooms.length()>0){
            queryBuilder+= ' No_of_Bedrooms__c=: noOfBedrooms AND';
        }
        if(unitStatus.length()>0){
               queryBuilder+= ' Unit_Status__c=: unitStatus AND';  
        }else if(unitStatus.length() == 0){
            if(profileName.containsIgnoreCase('Inventory')){
                statuses = new Set<String>{'Available','Blocked','Uploaded','Restricted'};
            }else if(profileName.containsIgnoreCase('Project')){
                statuses = new Set<String>{'Restricted','Blocked','Sold'};
            }else if(profileName == 'Sales Head' || profileName == 'Sales Manager'){
                statuses = new Set<String>{'Available','Blocked'};
            }          
        }
        
        if(statuses.size() > 0){
            if(queryBuilder.endsWithIgnoreCase('AND')){
                queryBuilder+= ' Unit_Status__c IN: statuses AND'; 
            }else{
                queryBuilder+= ' AND Unit_Status__c IN: statuses AND'; 
            }
        }
        
        if(blockedStatus.length()>0){
            queryBuilder+= ' Blocked_Status__c =: blockedStatus AND';
        }
        if(spaceType.length()>0){
            //List<Space_Type__c> listSpaceType = [Select ID FROM Space_Type__c WHERE Name =: spaceType];
            List<Space_Type__c> listSpaceType = [Select ID FROM Space_Type__c WHERE Name =: spaceType];
            queryBuilder+= ' Space_Types__c =: spaceType AND';
        }

        if(listUnitCodes.size() > 0){
            queryBuilder+= ' Unit_Code__c IN : listUnitCodes AND';
        }

        if(salesEvent.length()>0){
            List<Sales_Event_Unit__c> listSalesEventUnit = [Select ID FROM Sales_Event_Unit__c WHERE Sales_Event__c =: salesEvent];
            queryBuilder+= ' ID IN (SELECT Unit__c FROM Sales_Event_Unit__c WHERE ID =: listSalesEventUnit) AND';
        }
        system.debug('==statuses=='+statuses);
        System.debug('&&&'+queryBuilder.removeEnd('AND'));
        queryBuilder = queryBuilder.removeEnd('AND');
        queryBuilder = queryBuilder+' ORDER BY CreatedDate, LastModifiedDate desc LIMIT 2500';
        
        List<sObject> unitList = Database.query(queryBuilder);
        
        //get sales events by unit 
        map<Id, string> unitIdWithSalesEventNameMap = getSalesEventByUnitIds(unitList);
        List<sObject> salesTeamUnitList = new List<sObject>();
        
        for(sObject unit : unitList){
            if(unitIdWithSalesEventNameMap.containsKey(unit.Id)){
                unit.put('Sales_Event_Name__c', unitIdWithSalesEventNameMap.get(unit.Id));
                if(unit.get('Sales_Event_Name__c') != null && (profileName == 'Sales Head' || profileName == 'Sales Manager')){
                    salesTeamUnitList.add(unit);
                }
            }
        }
        if(salesTeamUnitList.isEmpty() == false){
            unitList = salesTeamUnitList;
        }
        System.debug(unitList);
        wrapperRecord.unitInfo = unitList;
        String profileId = UserInfo.getProfileId();
        Profile p = [Select id, Name from Profile where Id =:profileId];
        System.debug('Profile Name : '+p.Name);
        if(p.Name == 'System Administrator' || p.Name == 'Project Executive'){
            wrapperRecord.profileName = p.Name;
        }
        else if(p.Name == 'System Administrator' || p.Name == 'Inventory Executive'){
            wrapperRecord.profileName = p.Name;
        }else {
            wrapperRecord.profileName = 'System Administrator';
        }
        return wrapperRecord;
    }
    
    // Wraper to control visibility on UI
    public class ButtonVisibilityWrapper{
        
        @AuraEnabled
        public List<Unit__c> unitInfo;
        @AuraEnabled
        public String profileName;
    }
    
    @AuraEnabled
    public static Boolean checkUnitInApprovalLineItem(List<ID> ids){
        System.debug('Ids Value'+ids);
        List<Approval_Line_Item__c> recordList = [Select id, name from Approval_Line_Item__c where Unit__c in :ids];
        
        if(recordList != null && recordList.size()>0){
            return false;
        }else{
            return true;
        }
    }
    
    //Modified by Shivani
    @AuraEnabled
    public static map<Id, Object> updateSelectedUnits(List<String> selectedUnitsIdList, String statusToUpdate,String blockedStatus,String blockedSubStatus, String remarksOnUnit){
        System.debug('Selected Unit ID List '+selectedUnitsIdList);
        System.debug('Status to update '+statusToUpdate);
        System.debug('Blocked Status '+blockedStatus);
        System.debug('Blocked Sub Status '+blockedSubStatus);
        System.debug('Remarks on unit '+remarksOnUnit);
        Boolean flag =false;
        map<Id, Object> unitMap = new map<Id, Object>();
        List<Unit__c> updateUnitList = new List<Unit__c>();
        
        if(selectedUnitsIdList.size()>0){
            string queryString = 'SELECT Id, Name, Unit_Status__c, Blocked_By__c, Remarks__c, Blocked_By__r.Name, Blocked_Status__c, Blocked_Sub_status__c FROM Unit__c WHERE Id IN:selectedUnitsIdList';
            for(Unit__c unit: DataBase.query(queryString)){
                if(!String.isBlank(statusToUpdate)){
                    unit.Unit_Status__c = statusToUpdate;
                    if(statusToUpdate == 'Blocked'){
                        unit.Blocked_By__c = UserInfo.getUserId();
                    }else{
                        unit.Blocked_By__c = null;
                    }
                }
                if(!String.isEmpty(blockedStatus) && statusToUpdate == 'Blocked'){
                    unit.Blocked_Status__c = blockedStatus;
                }else{
                    unit.Blocked_Status__c = '';
                }
                if(!String.isEmpty(blockedSubStatus) && statusToUpdate == 'Blocked'){
                    unit.Blocked_Sub_status__c = blockedSubStatus;
                }else{
                    unit.Blocked_Sub_status__c = '';
                }
                if(!String.isEmpty(remarksOnUnit)){
                    unit.Remarks__c = remarksOnUnit;
                }else{
                    unit.Remarks__c = '';
                }
                updateUnitList.add(unit);
            }
            if(updateUnitList.size()>0){
                system.debug('==updateUnitList=='+updateUnitList);
                update updateUnitList;
                unitMap = new Map<Id, Unit__c>((List<Unit__c>)Database.query(queryString));
                flag=true;
            }
        }
        return unitMap;
    }

      /*** @createdDate : 22 March 2022  
        * @author : Mamta Gupta
        * @Version : V1
        * @usage : This function is to update ready for insepction in order to create Handover record
    **/

    @AuraEnabled
    public static boolean updateReadyForInspectiononUnit(List<String> selectedUnitsIdList,Date unitInspectionTargetDateSel){
        system.debug('selectedUnitsIdList is '+ selectedUnitsIdList);
        boolean isSuccess= true;
        if(selectedUnitsIdList.size()>0){
            List<Unit__c> updateUnitList = new List<Unit__c>();
            for(Unit__c unit:[SELECT Id, Name, Ready_for_Inspection__c,Handover_Status__c,Inspection_Target_Date__c FROM Unit__c WHERE Id IN:selectedUnitsIdList]){
                //unit.Ready_for_Inspection__c = True;
                unit.Handover_Status__c = 'Ready for Inspection';
                unit.Inspection_Target_Date__c = unitInspectionTargetDateSel;
                updateUnitList.add(unit);    
            }
            try{
                update updateUnitList;
                isSuccess = true;
            }
            catch(Exception ex){
                system.debug('error is '+ ex.getCause() + '  at' + ex.getLineNumber());
                isSuccess = false;
            }

    }
    return isSuccess;
}
    /** 
        * @createdDate : 17 March 2022  
        * @author : Ashok Kumar Nayak
        * @Version : V1
        * @usage : This function fetched the master Options and helps in displaying them upon clicking 'Add Unit Options' in the Inventory Wizard
    **/
    @AuraEnabled(cacheable=true)
    public static UnitOptionWrapperDataList getUnitOptionsAndMasterOptionData(String sourceOfInvocation){
       UnitOptionWrapperDataList optionsData = new UnitOptionWrapperDataList();
       List<MasterOptionDataWrap> masterOptionsDataList = new List<MasterOptionDataWrap>();
       List<DataTableColumn> columnList = new List<DataTableColumn>();
       switch on sourceOfInvocation {
            when 'fromInventoryWizard' {
                Integer masterOptionRowIndex = 0;
                DataTableColumn defaultDTC = new DataTableColumn();
                defaultDTC.label = 'Master Option Name';
                defaultDTC.fieldName = 'Master_Option__r.Name';
                defaultDTC.type = 'STRING';
                columnList.add(defaultDTC);
                for(Schema.FieldSetMember fsMember : getFieldSetMembers('Unit_Option__c','InventoryWizard_UnitOptionFieldSet')){
                    DataTableColumn dtc = new DataTableColumn();
                    dtc.label = fsMember.getLabel();
                    dtc.fieldName = fsMember.getFieldPath();
                    dtc.type = String.valueOf(fsMember.getType());
                    columnList.add(dtc);
                }
                optionsData.columnList = columnList;
                for(Master_Option__c masterOption : (List<Master_Option__c>)Database.query('SELECT Id,Name,Type__c,Additional_Area_Required__c,BUA_Update_Required__c,Unit_Theme_Automation_Required__c from Master_Option__c WHERE Is_Active__c=true order by Sequence_Order__c')) {
                    MasterOptionDataWrap masterOptionData = new MasterOptionDataWrap(masterOption,masterOptionRowIndex);
                    masterOptionRowIndex++;
                    masterOptionsDataList.add(masterOptionData);
                }
                optionsData.masterOptionsDataWrapper = masterOptionsDataList;
            }
        }   
       return optionsData;
    }

    /** 
        * @createdDate : 17 March 2022  
        * @author : Ashok Kumar Nayak
        * @Version : V1
        * @usage : This is the parent wrapper class with master options and unit options column details
    **/
    public class UnitOptionWrapperDataList{
        @AuraEnabled
        public List<MasterOptionDataWrap> masterOptionsDataWrapper{get;set;}
        @AuraEnabled
        public List<DataTableColumn> columnList{get;set;}
    }

    /** 
        * @createdDate : 17 March 2022  
        * @author : Ashok Kumar Nayak
        * @Version : V1
        * @usage : This is the wrapper class with master options data
    **/
    public class MasterOptionDataWrap{
        @AuraEnabled public Master_Option__c MasterOption;
        @AuraEnabled public String pricebookId;
        @AuraEnabled public Decimal additionalAreaRequired;
        @AuraEnabled public Decimal price;
        @AuraEnabled public Boolean isSelected;
        @AuraEnabled public Integer index;
        @AuraEnabled public Boolean hasAreaMissingError;
        @AuraEnabled public Boolean hasPriceMissingError;
        @AuraEnabled public String priceMissingErrorMsg;
        @AuraEnabled public String areaMissingErrorMsg;
        @AuraEnabled public Boolean displayPrice;
        public MasterOptionDataWrap(Master_Option__c MasterOption,Integer index){
            this.MasterOption = MasterOption;
            this.pricebookId = '';
            this.additionalAreaRequired = 0;
            this.price = 0;
            this.isSelected = false;
            this.hasPriceMissingError = false;
            this.hasAreaMissingError = false;
            this.priceMissingErrorMsg = '';
            this.areaMissingErrorMsg = '';
            this.index = index;
            if(MasterOption.Type__c == 'Paid'){
                this.displayPrice = true;
            }
            else{
                this.displayPrice = false;
            }
        }            
    }

    /** 
        * @createdDate : 17 March 2022  
        * @author : Ashok Kumar Nayak
        * @Version : V1
        * @usage : This is the wrapper class with unit options column details
    **/
    public class DataTableColumn{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String fieldName{get;set;}
        @AuraEnabled
        public String type{get;set;}
        @AuraEnabled
        public Boolean sortable{get;set;}
    }

    /** 
        * @createdDate : 17 March 2022  
        * @author : Ashok Kumar Nayak
        * @Version : V1
        * @usage : This function helps in fetching the fields from a fieldset on an Object.
    **/
    private static List<Schema.FieldSetMember> getFieldSetMembers(String objectTypeName,String fieldSetName) {
        DescribeSObjectResult[] describes = Schema.describeSObjects(new String[] {objectTypeName});
        if (describes != null && describes.size() > 0) {
            // There should only be the one match for the one object type name
            Schema.FieldSet fs = describes[0].fieldSets.getMap().get(fieldSetName);
            return fs.fields;
        } else {
            return null;
        }
    }

    /** 
        * @createdDate : 17 March 2022  
        * @author : Ashok Kumar Nayak
        * @Version : V1
        * @usage : This function creates the unit Options for the selected units and chosen master options from the Inventory Wizard
    **/
    @AuraEnabled
    public static String createUnitOptionsData(String unitOptionDataWrapper,List<String> selectedUnitsList){
        String returnString = '';
        List<Unit_Option__c> unitOptionList = new List<Unit_Option__c>();
        List<MasterOptionDataWrap> masterOptionWrapperList = (List<MasterOptionDataWrap>)JSON.deserialize(unitOptionDataWrapper,List<MasterOptionDataWrap>.class);
        for(MasterOptionDataWrap optionData : masterOptionWrapperList){
            for(String unit : selectedUnitsList){
                Unit_Option__c unitOption = new Unit_Option__c();
                unitOption.Master_Option__c = optionData.MasterOption.Id;
                unitOption.Price__c = optionData.price;
                unitOption.Unit__c = unit;
                unitOption.Additional_Area__c = optionData.additionalAreaRequired;
                unitOptionList.add(unitOption);
            }
        }
        if(unitOptionList.size() > 0){
            try{
                insert unitOptionList;
                returnString = 'SUCCESS';
            }
            catch(System.DmlException ex) {
                List<String> dmlErrorList = new List<String>();
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    // Process exception here
                    dmlErrorList.add(ex.getDmlMessage(i)); 
                }
                if(dmlErrorList.size() > 0){
                    returnString = string.join(dmlErrorList,',');
                }
            }
        }
        return returnString;
    }
    
    public static map<Id, string> getSalesEventByUnitIds(list<Unit__c> unitList){
        //list<Sales_Event_Unit__c> salesEventUnitList = 
        map<Id, string> unitIdWithSalesEventNameMap = new map<Id, string>();
        
        for(Sales_Event_Unit__c salesEventUnit : [Select Id, Sales_Event__r.Name, Unit__c
                                                  from Sales_Event_Unit__c 
                                                  where Unit__c in : unitList AND Sales_Event__r.Status__c = 'Active' AND Sales_Event__r.Start_Date__c <= : system.today() and Sales_Event__r.End_Date__c >= : system.today()]){
                                                      if(unitIdWithSalesEventNameMap.containskey(salesEventUnit.Unit__c)){
                                                          string salesEventName = unitIdWithSalesEventNameMap.get(salesEventUnit.Unit__c) + ', ' + salesEventUnit.Sales_Event__r.Name;
                                                          unitIdWithSalesEventNameMap.put(salesEventUnit.Unit__c, salesEventName);
                                                      }else{
                                                          unitIdWithSalesEventNameMap.put(salesEventUnit.Unit__c, salesEventUnit.Sales_Event__r.Name);
                                                      }
                                                  }
        return unitIdWithSalesEventNameMap;
    }
    
    @AuraEnabled
    public static string createSalesOffer(list<Unit__c> unitList){
        system.debug('%%unitList'+unitList);
        //list<Unit__c> unitsList = (List<Unit__c>)JSON.deserialize(unitList, List<Unit__c>.class);
        system.debug('==unitList='+unitList);
        
        List<Sales_Offer_Unit__c> salesOfferUnitList = new List<Sales_Offer_Unit__c>();
        MAP<Id,Id> unitIdtoPaymentPlanIDmap = new MAP<Id,Id>();
        List<Sales_Offer_Milestone__c> salesOfferMilestoneList = new List<Sales_Offer_Milestone__c>(); 
        Sales_Offer__c salesOffer = new Sales_Offer__c();
        
        try{
            if(unitList != null && !unitList.isEmpty()){
                //creating sales offer record
                insert salesOffer;
                
                //creating sales offer units for each of the unit.
                for(Unit__c units : [select Id, Name, Master_Payment_Plan__c, Selling_Price__c from Unit__c where Id in : unitList]){
                    Sales_Offer_Unit__c salesOfferUnit = new Sales_Offer_Unit__c();
                    salesOfferUnit.Unit__c = units.Id;
                    if(units.Selling_Price__c != null){
                        salesOfferUnit.Unit_Price__c = units.Selling_Price__c ;
                    }
                    salesOfferUnit.Sales_Offer__c = salesOffer.Id;
                    salesOfferUnitList.add(salesOfferUnit);
                    salesOfferUnit.Name = 'Sales Offer - '+ units.Name;
                    unitIdtoPaymentPlanIDmap.put(units.Id, units.Master_Payment_Plan__c);
                }
                if(!salesOfferUnitList.isEmpty()){
                    insert salesOfferUnitList;
                }
                system.debug('salesOfferUnitList'+salesOfferUnitList);
                //creating sales offer milestones for each of the unit.
                for(Sales_Offer_Unit__c salesOfferUnit : salesOfferUnitList){
                    Date startDate = System.today();
                    for(Master_Payment_Milestone__c masterPms : [Select id,name,Amount_Percentage__c,Due_In_Days__c,Installment__c,Installment_No__c,Master_Payment_Plan__c from Master_Payment_Milestone__c where Master_Payment_Plan__c =:unitIdtoPaymentPlanIDmap.get(salesOfferUnit.Unit__c) order by Installment_No__c]){ 
                        Sales_Offer_Milestone__c salesOfferMilestone = new Sales_Offer_Milestone__c();
                        salesOfferMilestone.Sales_Offer_Unit__c = salesOfferUnit.Id;
                        salesOfferMilestone.name = masterPms.Installment__c;
                        salesOfferMilestone.Installment__c = masterPms.Installment_No__c;
                        salesOfferMilestone.Milestone_Date__c = masterPms.Due_In_Days__c != null ? startDate.addDays(Integer.valueof(masterPms.Due_In_Days__c)) : null;
                        salesOfferMilestone.Milestone_Name__c = masterPms.Name;
                        salesOfferMilestone.Percentage__c = masterPms.Amount_Percentage__c;
                        //salesOfferMilestone.Total_Amount__c = masterPms.Name;
                        startDate = masterPms.Due_In_Days__c != null ? startDate.addDays(Integer.valueof(masterPms.Due_In_Days__c)) : null;
                        salesOfferMilestoneList.add(salesOfferMilestone);
                    }
                }
                system.debug('salesOfferMilestoneList'+salesOfferMilestoneList);
                if(!salesOfferMilestoneList.isEmpty()){
                    insert salesOfferMilestoneList; 
                }
            }
        }
        catch(Exception e){
            system.debug('Exception in sales offer'+e.getMessage() + ':'+ e.getLineNumber());
        }
        return salesOffer.Id;
    } 
}