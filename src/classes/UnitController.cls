/* 23 Jan 22
     Comment by Huzefa - neeed to use active checkbox going ahead as its also used in integration - Status__c -> active__c */
//Comment by Swapnil - neeed to use Business_Unit__c instead of master_community__c and use unit_Status__c instead of sales_status__c and leasing_status__c

public with sharing class UnitController {
    @AuraEnabled
    public static UnitWrapper getUnits(Integer pageSize, Integer pageNumber,String objRecordID,String masterPlan,String block, String project,String building, String bedroom,String architectural,String propertyView,String spaceType,String unitType,String unitTheme,String unitColor,Integer minPrice, Integer maxPrice,Integer minSaleableArea, Integer maxSaleableArea, Integer minPlotArea, Integer maxPlotArea,String recentlyAdded){
        Integer offset = (pageNumber - 1) * pageSize;
        UnitWrapper wrapper = new UnitWrapper();
        try {
            String UnitFlag = 'blueFlag';
            String countQuery = ' SELECT Count() FROM Unit__c where ';
            String filter = '';
            String query = 'Select Id,Unit_Flag__c, Unit_type__c,DLD_Customer_Share__c,Location__c,Location__r.Name,Plot_Area_Sqft__c,'+ 
                           ' name,No_of_Bedrooms__c,Master_Payment_Plan__c,Master_Payment_Plan__r.Name,Architectural_Type__c, '+ 
                           ' Selling_Price__c,Property_Unit_View__c,Space_Types__c,Property_Unit_Type__c, '+ 
                           ' Unit_Theme__c,Unit_Theme__r.Name,Unit_color_option__c,active__c,Cluster__c,Cluster__r.Name,Building__c, '+ 
                           ' Building__r.Name,Project__c,Project__r.Name, Business_Unit__c,Business_Unit__r.Name, Floor__c,Floor__r.Name, '+  
                           ' Business_Group__c,Business_Group__r.Name,Unit_Status__c,Unit_Code__c,Internal_Area_Sqft__c,Usable_Area__c,'+ 
                           ' Total_Saleable_Area_Sqft__c,Style__c from Unit__c where ';
            
            if(String.isNotBlank(recentlyAdded) && recentlyAdded == 'YES'){
                
                filter += ' Unit_Flag__c = \''+ UnitFlag +'\' AND ';
            }
            
            if(String.isNotBlank(masterPlan)){
                filter += ' Business_Unit__c = \''+ masterPlan +'\' AND '; 
            }
            if(String.isNotBlank(block)){
                filter += 'cluster__c=\''+ block +'\' AND ';
            }
            if(String.isNotBlank(project)){
                filter += 'project__c=\''+ project +'\' AND ';
            } 
            if(String.isNotBlank(building)){
                filter += 'Building__c=\''+ building +'\' AND ';
            }
            if(String.isNotBlank(bedroom)){
                filter += 'No_of_Bedrooms__c=\''+ bedroom +'\' AND ';
            }
            /*if(String.isNotBlank(selectedStatus)){
                filter += 'Unit_Status__c=\''+ selectedStatus +'\' AND ';
            } */
            if(String.isNotBlank(architectural)){
                filter += 'Architectural_Type__c=\''+ architectural +'\' AND ';
            }
            if(String.isNotBlank(propertyView)){
                filter += 'Property_Unit_View__c=\''+ propertyView +'\' AND ';
            }
            if(String.isNotBlank(spaceType)){
                filter += 'Space_Types__c=\''+ spaceType +'\' AND ';
             }
            if(String.isNotBlank(unitType)){
                
                filter += 'Unit_Type__c=\''+ unitType +'\' AND ';
            }
            /*if(String.isNotBlank(unitTheme)){
                filter += 'Unit_theme__c=\''+ spaceType +'\' AND ';//Commented by Mamta- Unit theme should not be mapped with spaceType
            }*/
            
            if(String.isNotBlank(unitTheme)){
                filter += 'Unit_theme__c=\''+ unitTheme +'\' AND ';//Added By Mamta
            }
            
            if(String.isNotBlank(unitColor)){
                filter += 'Unit_color_option__c=\''+ spaceType +'\' AND ';
            }
            if (minPrice != null && minPrice != 0){
                filter += ' Selling_Price__c   >= ' + minPrice + ' AND ';
            }                                    
            if (maxPrice != null && maxPrice != 0){
                filter += ' Selling_Price__c   <= ' + maxPrice + ' AND ';
            }
            if (minSaleableArea != null && minSaleableArea != 0 ){
                filter += ' Total_Saleable_Area_Sqft__c   >= ' + minSaleableArea + ' AND ';
            }                                
            if (maxSaleableArea != null && maxSaleableArea != 0 ){
                filter += ' Total_Saleable_Area_Sqft__c   <= ' + maxSaleableArea + ' AND ';
            }                               
            if (minPlotArea != null && minPlotArea != 0){
                filter += ' Plot_Area_Sqft__c     >= ' + minPlotArea + ' AND ';
            }                                      
            if (maxPlotArea != null && maxPlotArea != 0){
                filter += ' Plot_Area_Sqft__c     <= ' + maxPlotArea + ' AND ';
            } 
             filter += getRecordTypeCriteria(objRecordID ,project);//Added By Mamta- 28 Jan 22 
            // add the final filter which is mandatory 
            filter += ' Unit_Status__c = \'Available\' ';  
            query += filter;
            countQuery += filter;
            if(offset > 2000){
                offset = 2000; 
            }
            query += ' LIMIT :pageSize OFFSET :offset';
            countQuery += ' LIMIT 2000';
            List<Unit__c> productsList = Database.query(query);
            wrapper.totalUnits = Database.countQuery(countQuery);
  			wrapper.unitsList = productsList;
            if(productsList.size()>0){
                return wrapper;
            }else{
                return null;
            }
        } catch(exception ex){  
            system.debug('log message is '+ ex.getMessage() + ' at line number '+ ex.getLineNumber());
            return null;
        }
    }
    
    public class UnitWrapper{
        @AuraEnabled public Integer totalUnits;
        @AuraEnabled public string message;
        @AuraEnabled public List<Unit__c> unitsList;
    }
    
    /*Added By Mamta - 28 jan 22
    * Purpose - add criteria for specific record types for lead*/
    public static String  getRecordTypeCriteria(ID recordID ,String project){
        String criteria ='';    
        String sObjName = recordID.getSObjectType().getDescribe().getName();
        if(sObjName=='Lead'){
            Lead ld =[select id,Project__c, Inventory_Project__c,recordType.name from Lead WHERE ID=:recordID]  ;
            if(ld.recordType.name=='Sales Lead'){
                criteria =' RecordType.name=\'Sales\' AND  ';
            }
            else if(ld.recordType.name=='Residential Leasing Unit'){
                criteria =' RecordType.name=\'Leasing\' AND Leasing_Type__c  =\'Residential Leasing Unit\' AND  ';
            }
            else if(ld.recordType.name=='Residential Leasing Shop'){
                criteria =' RecordType.name=\'Leasing\' AND Leasing_Type__c  =\'Residential Leasing Shop\' AND ';
            }
            
            if(ld.Project__c!=null && String.isBlank(project)){
                criteria += 'project__c=\''+ ld.Inventory_Project__c +'\' AND ';
            }
        }    
        return  criteria; 
        
    }

    @AuraEnabled
    public static NKLResponse addUnitstoOpp(String recId,List<unit__c> unitsList,String objectType){
        NKLResponse response = new NKLResponse();
        Savepoint sp = Database.setSavepoint();
        response.success = false;
        if(!unitsList.isEmpty()){
            Id recordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
            List<Opportunity> oppList = new List<Opportunity>();
            List<Lead> lstLead = new List<Lead>(); // Lakshaya's Lead list
            if(objectType == 'Account'){
                List<Account> acc = [SELECT Id, Name FROM Account where Id=:recId];
                for(Unit__c unit : unitsList){
                    unit.Unit_Status__c = 'Booked';
                    Opportunity opp = new Opportunity();
                    opp.StageName = 'Booked';
                    opp.Unit__c = unit.Id;
                    opp.Name = acc[0].Name + ' - ' + unit.Name ;
                    opp.RecordTypeId = recordtypeid;
                    opp.CloseDate = System.today() + 30;
                    opp.CurrencyIsoCode = 'AED';
                    opp.AccountId = recId;
                    oppList.add(opp);
                }
            }else if(objectType == 'Opportunity'){
                //Added RecordType by Ashams - For Dynamic record type updates
                Opportunity masterOpp = [SELECT Id,CloseDate,AccountId,Account.Name,RecordTypeId,RecordType.DeveloperName,Time_to_Close_Quick_Book__c FROM Opportunity WHERE Id =: recId];
                for(Integer i = 0; i < unitsList.size(); i++ ){
                    unitsList[i].Unit_Status__c='Booked';
                    Opportunity opp = new Opportunity();
                    opp.StageName = Add_Unit_Status_Settings__c.getValues(masterOpp.RecordType.DeveloperName).Opportunity_Status__c;
                    if(masterOpp.RecordType.DeveloperName == 'Quick_Book'){
                        opp.Time_to_Close_Quick_Book__c = System.now().addMinutes(10);
                        opp.Booking_Reservation_Date__c = Date.today();
                    }
                    opp.No_of_Bedrooms__c = unitsList[i].No_of_Bedrooms__c;
                    opp.Name = masterOpp.Account.Name + ' - '+ unitsList[i].Name;
                    opp.DLD_Customer_Share__c = unitsList[i].DLD_Customer_Share__c;
                    opp.Project__c = unitsList[i].project__c;
                    opp.Theme__c = unitsList[i].Unit_Theme__c;
                    opp.Units_Cluster__c = unitsList[i].Cluster__c;
                    opp.Master_Payment_Plan__c = unitsList[i].Master_Payment_Plan__c;
                    if(i == 0){
                        opp.Id = recId;
                        opp.Unit__c = unitsList[0].Id;
                    }else{
                        opp.Unit__c = unitsList[i].Id;
                        opp.Name = masterOpp.Account.Name + ' - '+ unitsList[i].Name;
                        opp.RecordTypeId = masterOpp.RecordTypeId;
                        opp.CloseDate = System.today() + 30;
                        opp.CurrencyIsoCode = 'AED';
                        opp.Opportunity__c = recId;
                        opp.AccountId = masterOpp.AccountId;
                    }
                    oppList.add(opp);
                }
            }else if(objectType == 'Lead'){
                // Lakshaya's else if block
                Lead l = [Select id, No_of_Bedrooms__c, Architectural_Type__c, Property_Unit_View__c,  Cluster__c, Project__c, Inventory_Unit__c, Building__c from Lead where id =: recid]; 
                l.No_of_Bedrooms__c = unitsList[0].No_of_Bedrooms__c;
                //l.Architectural_Type__c = unitsList[0].Architectural_Type__c;
                //l.Property_Unit_View__c = unitsList[0].Property_Unit_View__c;
                l.Inventory_Unit__c = unitsList[0].id;
                //l.Project__c = unitsList[0].Project__r.Name;
                l.Space_Types__c = unitsList[0].Space_Types__c; 
               // l.Building__c = unitsList[0].Building__r.Name;
               // l.Cluster__c = unitsList[0].Cluster__r.Name; 
                /* Mappings - Added By Mamta*/
                l.Inventory_Project__c = unitsList[0].Project__c;
                l.Unit_Type__c = unitsList[0].Unit_Type__c;
                l.Inventory_Building__c = unitsList[0].Building__c;
                //l.Inventory_Cluster__c = unitsList[0].Cluster__c;
                //l.Property_Unit_View__c = unitsList[0].Property_Unit_View__c;
                l.Inventory_No_of_Bedrooms__c =  unitsList[0].No_of_Bedrooms__c;
                lstLead.add(l);
            }
            
            if(!oppList.isEmpty()){
                try{
                    upsert oppList;
                    update unitsList;
                    //response.data = oppList;
                    response.success = true;
                        if(oppList.size() == 1){
                            response.data =  oppList[0];
                        }
                }Catch(Exception ex){
                    system.debug('error==  + ' + ex);
                    response.message = ex.getMessage();
                    response.success = false;
                    Database.RollBack(sp);
                }
            }
            if(!lstLead.isEmpty()){
                try{
                    update lstLead;
                    addLeadIDonMilestones(lstLead);
                    
                    response.success = true;
                }Catch(Exception ex){
                    response.success = false;
                    response.message = ex.getMessage();
                    Database.RollBack(sp);
                }
            }
        }
        return response;
    }
    
    
    /*Added By Mamta - 2 Feb 2022
	* Purpose - Used specifically for quotation generation from Lead*/
     public static void addLeadIDonMilestones(List<Lead> lstLead){
        List<Payment_Milestone__c> payMilestones =[select id, Lead__c from Payment_Milestone__c WHERE Unit__c=:lstLead[0].Inventory_Unit__c];
         for(Payment_Milestone__c pm : payMilestones){
             pm.Lead__c = lstLead[0].ID;
             
         }
         update payMilestones;
         
    }
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Used specifically in Quick Booking Process*/
    @AuraEnabled
    public static NKLResponse addUnitstoQuickBookingOpp(String recId,List<unit__c> unitsList,String objectType){
        Savepoint sp = Database.setSavepoint();
        NKLResponse response = new NKLResponse();
        response.success = false;
        Opportunity masterOpp;
        
        if(!unitsList.isEmpty()){
            List<Opportunity> oppList = new List<Opportunity>();
            if(objectType == 'Opportunity'){
                masterOpp = [SELECT Id,CloseDate,AccountId,Account.Name,RecordTypeId,RecordType.DeveloperName,Time_to_Close_Quick_Book__c,Booking_Reservation_Date__c
                                         FROM Opportunity WHERE Id =: recId];
                for(Integer i = 0; i < unitsList.size(); i++ ){
                    unitsList[i].Unit_Status__c='Booked';
                    Opportunity opp = new Opportunity();
                    opp.StageName = Add_Unit_Status_Settings__c.getValues(masterOpp.RecordType.DeveloperName).Opportunity_Status__c;
                    if(masterOpp.RecordType.DeveloperName == 'Quick_Book'){
                        masterOpp.Units_Added__c = true;
                        if(masterOpp.Time_to_Close_Quick_Book__c==null || masterOpp.Units_Added__c==false){
                          masterOpp.Time_to_Close_Quick_Book__c = System.now().addMinutes(10);  
                        }
                        opp.Time_to_Close_Quick_Book__c = System.now().addMinutes(10); 
                        masterOpp.Booking_Reservation_Date__c = Date.today();
                        opp.Booking_Reservation_Date__c = Date.today();
                    }
                    opp.No_of_Bedrooms__c = unitsList[i].No_of_Bedrooms__c;
                    opp.DLD_Customer_Share__c = unitsList[i].DLD_Customer_Share__c;
                    opp.Project__c = unitsList[i].project__c;
                    opp.Units_Cluster__c = unitsList[i].Cluster__c;
                    opp.Master_Payment_Plan__c = unitsList[i].Master_Payment_Plan__c;
                    opp.Unit__c = unitsList[i].Id;
                    opp.Name = masterOpp.Account.Name + ' - '+ unitsList[i].Name;
                    opp.RecordTypeId = masterOpp.RecordTypeId;
                    opp.CloseDate = System.today() + 30;
                    opp.CurrencyIsoCode = 'AED';
                    opp.Opportunity__c = recId;
                    //opp.AccountId = masterOpp.AccountId;
                    oppList.add(opp);
                }
            }
            if(!oppList.isEmpty()){
                try{
                    insert oppList;
                    update unitsList;
                    update masterOpp;
                    response.success = true;
                }Catch(Exception ex){
                    system.debug('error==  + ' + ex);
                    response.message = ex.getMessage();
                    response.success = false;
                    Database.RollBack(sp);
                }
            }
        }
        return response;
    }
    
    @AuraEnabled  
    public static boolean removeSelectedUnits(List<unit__c> unitList, string recordId){
        system.debug('%%unitList'+unitList);
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> UnitsIds = new Set<Id>();
        Opportunity Opp;
        List<Opportunity> newOppList = new List<Opportunity>();
        
        if(unitList.size()>0 && string.isNotBlank(recordId)){
            Opp = [Select Id,AccountId,RecordType.Name,unit__c,(select id,name from Opportunities__r) from Opportunity where Id =:recordId];
            
            for(unit__c unit : unitList){
                UnitsIds.add(unit.Id);
            }
            if(UnitsIds.size()>0){
              oppList = [Select id from Opportunity where unit__c IN:UnitsIds and Opportunity__c=:recordId and recordTypeId =: System.Label.Quick_Book_Record_Id];  
            }
            if(UnitsIds.contains(Opp.unit__c)){
                Opp.unit__c = null;
                update Opp;
            }
        }
        try{
            system.debug('%%UnitsIds'+UnitsIds);
            system.debug('%%oppList'+oppList);
            if(oppList.size()>0){
                delete oppList ;
            } 
            for(unit__c u :unitList){
                u.Unit_Status__c = 'Available';
            }
            update unitList;
            Opportunity newOpp = [Select Id,AccountId,RecordType.Name,unit__c,(select id,name from Opportunities__r) from Opportunity where Id =:recordId];
            if(newOpp.Opportunities__r.size()==0){
                newOpp.Units_Added__c = false;
                newOppList.add(newOpp);
            }
            if(newOppList.size()>0){
               update newOppList; 
            }
            return true;
        }catch(Exception e){
            system.debug('Exception'+e);
            return false;
        }
    } 
    
    
    @AuraEnabled
    public static ResultWrapper getExistingUnits(String recId,String objectType){
        ResultWrapper wrap = new ResultWrapper();
        Boolean unitExist = false;
        Boolean prerequisitesFilled = false;
        Set<Id> unitIds = new Set<Id>();
        List<unit__c> unitLists = new List<unit__c>();//Added unitslist to display units related to opp by Ashams
        if(objectType == 'Account'){
            Account acc = [SELECT Id , Order_Entries_Prerequisite__c FROM Account WHERE Id =: recId];
            prerequisitesFilled = acc.Order_Entries_Prerequisite__c;
        }else if(objectType == 'Opportunity'){
            //String query = 'SELECT Id,Unit__c FROM Opportunity WHERE Id =:recId AND Unit__c != null';
            String query = 'Select Id,Unit__c from Opportunity where (Opportunity__c =:recId OR Id=:recId) and Unit__c !=null';
            List<Opportunity> oppList = Database.query(query);
            if(!oppList.isEmpty()){
                unitExist = true;
                for(Opportunity opp:oppList){
                    unitIds.add(opp.unit__c);
                }
                if(unitIds.size()>0){
                    unitLists =  [Select Id,name,No_of_Bedrooms__c,Master_Payment_Plan__c,Master_Payment_Plan__r.Name,Architectural_Type__c,
                                  Selling_Price__c,Property_Unit_View__c,Space_Types__c,Property_Unit_Type__c,Unit_color_option__c,
                                  active__c,Cluster__c,Cluster__r.Name,Building__c,Building__r.Name,Project__c,Project__r.Name,
                                  Business_Unit__c,Business_Unit__r.Name,Floor__c,Floor__r.Name, Business_Group__c,Business_Group__r.Name,
                                  Unit_Status__c,Unit_Code__c,Internal_Area_Sqft__c,Total_Saleable_Area_Sqft__c,Style__c,Unit_Theme__c,
                                  Unit_Theme__r.name,Usable_Area__c
                                  from Unit__c where ID IN:unitIds];
                }
            }
            else{
                unitExist = false;
            }
        }else if(objectType == 'Lead'){
            Lead leadRecordType = [Select id, RecordTypeId, RecordType.Name from Lead where id =:recId];
            String recordTypeName = leadRecordType.RecordType.Name;
            wrap.recordTypeName = recordTypeName ;
            String query = 'SELECT Id,Inventory_Unit__c FROM Lead WHERE Id =:recId AND Inventory_Unit__c != null';
            List<Lead> leadList = Database.query(query);
            //Lakshaya's else if block
            if(!leadList.isEmpty()){
                unitExist = true;
            }
            else{
                unitExist = false;
            }
        }
        system.debug('unitIds'+unitIds);
        system.debug('unitLists'+unitLists);
        wrap.unitExist = unitExist;
        wrap.prerequisitesFilled = prerequisitesFilled;
        wrap.unitsList = unitLists;
        return wrap;
    }
    public class ResultWrapper{
        @AuraEnabled public Boolean unitExist;
        @AuraEnabled public Boolean prerequisitesFilled;
        @AuraEnabled public String recordTypeName; // Lakshaya's variable
        @AuraEnabled public List<Unit__c> unitsList; //Added by Ashams, to display existing units 
    }
    @AuraEnabled 
    public static Map<String, String> getTypes(){ 
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','Unit_type__c'); 
        return options;
    }
    @AuraEnabled //Lakshaya's Method
    public static Map<String,String> getUnitSalesStatus(){
        Map<String,String> options = new Map<String,String>();
        options = getPicklistValues('Unit__c','Unit_Status__c');
        System.debug('Options : '+options);
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getNumberofBedroomsOptions(){
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','No_of_Bedrooms__c'); 
        return options;
    }
    @AuraEnabled 
    public static Map<String, String> getSpaceType(){
        Map<String, String> options = new Map<String, String>();
        for( Space_Type__c sp: [select id,name from Space_Type__c]){
            options.put(sp.id,sp.name);
        }
        //options = getPicklistValues('Unit__c','Space_Type__c'); 
        return options;
    }
     @AuraEnabled 
    public static Map<String, String> getUnitType(){
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','Unit_Type__c'); 
        return options;
    }
     @AuraEnabled 
    public static Map<String, String> getUnitColor(){
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','Unit_color_option__c'); 
        return options;
    }
     @AuraEnabled 
    public static Map<String, String> getUnitTheme(){
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','Unit_theme__c'); 
        return options;
    }
    @AuraEnabled 
    public static Map<String, String> getUnitTypeGroupOptions(){
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','Architectural_Type__c'); 
        return options;
    }
    @AuraEnabled 
    public static Map<String, String> getPropertyUnitViewOptions(){
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','Property_Unit_View__c'); 
        return options;
    }
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
    public static Map<String, String> getProjects(){ 
        List<Project__c> projectsList = [select Id,name from Project__c order by Name];
        Map<String, String> options = new Map<String, String>();
        for(Project__c p :projectsList){
           options.put(p.Id,p.Name); 
        }
        return options;
    }
}