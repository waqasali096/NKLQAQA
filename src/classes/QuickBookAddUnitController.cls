/**
* @author : Ashams
* @createdDate : 30-Jan-2022
* @purpose : Used in Quick Booking Process - Sales
* @usage : controller for QuickBookAddUnit Component
*/
public with sharing class QuickBookAddUnitController {
    
    /*Added By Ashams - 15 MAR 22
	* Purpose - make dynamic filters based on available units*/
    @AuraEnabled
    public static ParentWrapper getAvailableUnits(){
        ParentWrapper response = new ParentWrapper();
        Filterwrapper filterWrap = new Filterwrapper();
        Map<string,string> projectMap = new Map<string,string>();
        Map<string,string> salesEventMap = new Map<string,string>();
       	Map<string,string> unitTypeMap = new Map<string,string>();
        Map<string,string> buildingMap = new Map<string,string>();
        Map<string,string> bedroomMap = new Map<string,string>();
        Map<String, String> unitTypes = new Map<String, String>();
        Map<String, String> buildingValues = new Map<String, String>();
        Map<String, String> bedroomValues = new Map<String, String>();
        Set<Id> availableUnitIds = new Set<Id>();
        List<Sales_Event_Executive__c> salesEventExecutives = new List<Sales_Event_Executive__c>();
        unitTypes = getPicklistValues('Unit__c','Unit_type__c'); 
        bedroomValues = getPicklistValues('Unit__c','No_of_Bedrooms__c'); 
        
        try{           
            
            List<Unit__c> unitList = getUnitQuery(null,null,null,null,null,null);
            //System.debug('After Query '+unitList);
            
            if(!unitList.isEmpty()){
                for(unit__c unit:unitList){
                    projectMap.put(unit.Project__c,unit.Project__r.Name); 
                    unitTypeMap.put(unit.Unit_type__c,unitTypes.get(unit.Unit_type__c));
                    buildingMap.put(unit.Building__c,unit.Building__r.Name);
                    bedroomMap.put(unit.Space_Types__c,unit.Space_Types__r.name);
                    availableUnitIds.add(unit.Id);
                }
                salesEventExecutives = [select Id,Sales_Event__c,Sales_Event__r.name from Sales_Event_Executive__c where User__c =: UserInfo.getUserId()];
                if(!salesEventExecutives.isEmpty()){
                    for(Sales_Event_Executive__c salesExec:salesEventExecutives){
                        salesEventMap.put(salesExec.Sales_Event__c,salesExec.Sales_Event__r.name);
                    }
                }
                filterWrap.salesEventMap = salesEventMap;
                filterWrap.projectMap = projectMap;
                filterWrap.unitTypeMap = unitTypeMap;
                filterWrap.buildingMap = buildingMap;
                filterWrap.bedroomMap = bedroomMap;
                response.filterwrapperList = filterWrap;
                response.success = TRUE;
                response.message = 'Available Units Found';
            }else{
                response.success = FALSE;
                response.message = 'No Available Units';
            }
            return response;
        }catch(exception ex){  
            system.debug('log message is '+ ex.getMessage() + ' at line number '+ ex.getLineNumber());
            response.message = ex.getMessage();
            response.success = FALSE;
            return response;
        }
    }
    
    /*Added By Ashams - 15 JAN 22
	* Purpose - fetch units based on search*/
    @AuraEnabled
    public static ParentWrapper getSearchUnits(string project,string locationCode,string salesEvent,string unitType,string building,string bedroom){
        ParentWrapper response = new ParentWrapper();
        List<ResultWrapper> unitWrapList = new List<ResultWrapper>();
        
        try{           
            
            List<Unit__c> unitList = getUnitQuery(project,locationCode,salesEvent,unitType,building,bedroom);
            //System.debug('After Query '+unitList);
            
            if(!unitList.isEmpty()){
                for(unit__c unit:unitList){
                    ResultWrapper unitWrap = new ResultWrapper();
                    unitWrap.unitId = unit.Id;
                    unitWrap.unitName = unit.Name;
                    unitWrap.locationCode = unit.Unit_Code__c;
                    unitWrap.building = unit.Building__r.Name;
                    unitWrap.unitType = unit.Unit_type__c;
                    unitWrap.unitStyle = unit.Unit_Style__r.name;
                    unitWrap.unitTheme = unit.Unit_Theme__r.Name;
                    unitWrap.unitThemeId = unit.Unit_Theme__c;
                    unitWrap.usableArea = String.valueof(unit.Built_Up_Area__c);
                    unitWrap.unitStatus = unit.Unit_Status__c;
                    unitWrap.bedroom = unit.Space_Types__r.name;
                    unitWrap.bedroomId = unit.Space_Types__c;
                    unitWrap.project = unit.project__c;
                    unitWrap.businessUnit = unit.Business_Unit__r.name;
                    unitWrap.cluster = unit.cluster__c;
                    unitWrap.businessUnitId = unit.Business_Unit__c;
                    unitWrap.dldShare = unit.DLD_Customer_Share__c;
                    unitWrap.dldNakShare = unit.DLD_Nakheel_Share__c;
                    unitWrap.masterPaymentPlanId = unit.Master_Payment_Plan__c;
                    unitWrap.masterPaymentPlanName = unit.Master_Payment_Plan__r.Name;
                    unitWrap.sellingPrice = unit.Selling_Price__c;
                    unitWrap.unitAdded = FALSE;
                    unitwrap.ownerId = UserInfo.getUserId();
                    unitwrap.Mortgage = unit.Mortgaged__c;
                    unitWrapList.add(unitWrap);
                }
                response.resultWrapperList = unitWrapList;
                response.success = TRUE;
                response.message = 'Units Found';
            }else{
                response.success = FALSE;
                response.message = 'No Available Units';
            }
            return response;
        }catch(exception ex){  
            system.debug('log message is '+ ex.getMessage() + ' at line number '+ ex.getLineNumber());
            response.message = ex.getMessage();
            response.success = FALSE;
            return response;
        }
    }
    
    /*Added By Ashams - 15 MAR 22
	* Purpose - form query string for units*/
    @AuraEnabled
    public static List<Unit__c> getUnitQuery(string project,string locationCode,string salesEvent,string unitType,string building,string bedroom){
        List<Sales_Event_Unit__c> salesEventUnitList = new List<Sales_Event_Unit__c>();
        
        string query = 'Select Id, Unit_type__c,Plot_Area_Sqft__c,'+ 
            ' name,No_of_Bedrooms__c,Master_Payment_Plan__c,Master_Payment_Plan__r.Name,Architectural_Type__c,DLD_Customer_Share__c,DLD_Nakheel_Share__c, '+ 
            ' Selling_Price__c,Property_Unit_View__c,Space_Types__c,Space_Types__r.name,Project__r.Project_Purpose__c, '+ 
            ' Unit_Theme__c,Unit_Theme__r.Name,Color_Option__c,Cluster__c,Cluster__r.Name,Building__c,Mortgaged__c,Built_Up_Area__c,'+ 
            ' Building__r.Name,Project__c,Project__r.Name, Business_Unit__c,Business_Unit__r.Name, Floor__c,Floor__r.Name, '+  
            ' Business_Group__c,Business_Group__r.Name,Unit_Status__c,Unit_Code__c,Internal_Area_Sqft__c,Usable_Area__c,'+ 
            ' Total_Saleable_Area_Sqft__c,Unit_Style__c,Unit_Style__r.name,Prebooked_By__c,Unit_Prebooked__c from Unit__c where ';
        
        if(String.isNotBlank(project)){
            query += 'project__c=\''+ project +'\' AND ';
        } 
        if(String.isNotBlank(locationCode)){
            query += 'Unit_Code__c =\''+ locationCode +'\' AND ';
        } 
        if(String.isNotBlank(unitType)){
            query += 'Unit_type__c=\''+ unitType +'\' AND ';
        }
        if(String.isNotBlank(building)){
            query += 'Building__c=\''+ building +'\' AND ';
        }
        if(String.isNotBlank(bedroom)){
            query += 'Space_Types__c=\''+ bedroom +'\' AND';
        }
        
        query += ' Unit_Prebooked__c=FALSE AND Unit_Status__c = \'Available\' AND Project__r.Project_Purpose__c = \'Sales\'';

        if(String.isNotBlank(salesEvent)){
            Map<Id, Sales_Event_Unit__c> salesEventIdMap = new Map<Id, Sales_Event_Unit__c>([Select Id,Unit__r.Id from Sales_Event_Unit__c  where Sales_Event__c =:salesEvent]);
            SET<ID> unitkeys = new SET<ID>();
            for(Id salesEvUnit : salesEventIdMap.keySet()){
                unitkeys.add(salesEventIdMap.get(salesEvUnit).Unit__r.Id);
            }
            system.debug('unitkeys'+unitkeys);
            query = query + ' AND Id IN :unitkeys';
        }
        System.debug('Before Query '+query);
        List<Unit__c> unitList = Database.query(query);
        System.debug('After Query '+unitList);
        return unitList;
    }
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Add units to Opportunity*/
    @AuraEnabled
    public static ResultWrapper addUnitstoQuickBookingOpp(String recId,List<unit__c> unitsList,String objectType){
        Savepoint sp = Database.setSavepoint();
        ResultWrapper response = new ResultWrapper();
        //response.success = false;
        Opportunity masterOpp;
        
        if(!unitsList.isEmpty()){
            List<Opportunity> oppList = new List<Opportunity>();
            if(objectType == 'Opportunity'){
                masterOpp = [SELECT Id,CloseDate,AccountId,Account.Name,RecordTypeId,RecordType.DeveloperName,Time_to_Close_Quick_Book__c,
                             Booking_Reservation_Date__c,Owner.Name FROM Opportunity WHERE Id =: recId];
                for(Integer i = 0; i < unitsList.size(); i++ ){
                    Opportunity opp = new Opportunity();
                    //unitsList[i].Unit_Status__c='Booked'; Removed Booking Status
                    unitsList[i].Unit_Prebooked__c = True;
                    unitsList[i].Prebooked_By__c = masterOpp.Owner.Name;
                    unitsList[i].Time_to_Book_Unit__c = System.now().addminutes(1);
                    opp.StageName = Add_Unit_Status_Settings__c.getValues(masterOpp.RecordType.DeveloperName).Opportunity_Status__c;
                    if(masterOpp.RecordType.DeveloperName == 'Quick_Book'){
                        masterOpp.Units_Added__c = true;
                        if(masterOpp.Time_to_Close_Quick_Book__c==null || masterOpp.Units_Added__c==false){
                          masterOpp.Time_to_Close_Quick_Book__c = System.now().addMinutes(10);  
                        }
                        //opp.Time_to_Close_Quick_Book__c = System.now().addMinutes(10); 
                        masterOpp.Booking_Reservation_Date__c = Date.today();
                        opp.Booking_Reservation_Date__c = Date.today();
                    }
                    opp.No_of_Bedrooms__c = unitsList[i].Space_Types__r.name;
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
                    //response.unitsList = unitsList;
                    //response.success = true;
                }catch(Exception ex){
                    system.debug('error==  + ' + ex);
                    //response.message = ex.getMessage();
                    //response.success = false;
                    Database.RollBack(sp);
                }
            }
        }
        return response;
    }
    
    /*Added By Ashams - 28 jan 22
	* Purpose - To remove selected units*/
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
                u.Prebooked_By__c = null;
                u.Unit_Prebooked__c = FALSE;
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
    
    /*Added By Ashams - 28 jan 22
	* Purpose - To get existing units attached to Opp*/
    @AuraEnabled
    public static ResultWrapper getExistingUnits(String recId,String objectType){
        ResultWrapper wrap = new ResultWrapper();
        Boolean unitExist = false;
        Set<Id> unitIds = new Set<Id>();
        List<unit__c> unitLists = new List<unit__c>();
        
        if(objectType == 'Opportunity'){
            //String query = 'SELECT Id,Unit__c FROM Opportunity WHERE Id =:recId AND Unit__c != null';
            String query = 'Select Id,Unit__c,Project__c,Booking_Form_Generated__c from Opportunity where (Opportunity__c =:recId OR Id=:recId)';
            List<Opportunity> oppList = Database.query(query);
            if(!oppList.isEmpty()){
                //wrap.projectId = oppList[0].Project__c;
                //wrap.bookingFormGen = oppList[0].Booking_Form_Generated__c;
                for(Opportunity opp:oppList){
                    unitIds.add(opp.unit__c);
                }
                if(unitIds.size()>0){
                    unitLists =  [Select Id,name,No_of_Bedrooms__c,Master_Payment_Plan__c,Master_Payment_Plan__r.Name,Architectural_Type__c,
                                  Selling_Price__c,Property_Unit_View__c,Space_Types__c,Unit_type__c,Unit_color_option__c,Space_Types__r.name,
                                  active__c,Cluster__c,Cluster__r.Name,Building__c,Building__r.Name,Project__c,Project__r.Name,
                                  Business_Unit__c,Business_Unit__r.Name,Floor__c,Floor__r.Name, Business_Group__c,Business_Group__r.Name,
                                  Unit_Status__c,Unit_Code__c,Internal_Area_Sqft__c,Total_Saleable_Area_Sqft__c,Style__c,Unit_Theme__c,
                                  Unit_Theme__r.name,Usable_Area__c,Prebooked_By__c,Unit_Prebooked__c,Time_to_Book_Unit__c
                                  from Unit__c where ID IN:unitIds];
                }
            }
            else{
                unitExist = false;
            }
        }
        system.debug('unitIds'+unitIds);
        system.debug('unitLists'+unitLists);
        if(unitLists.size()>0){
           // wrap.unitExist = true;
           // wrap.unitsList = unitLists;
        }else{
           // wrap.unitExist = false;
           // wrap.unitsList = null;
        }
        return wrap;
    }
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Checks Booking form gnerated for opportunity*/
    @AuraEnabled
    public static Boolean checkFormGenerated(String recId){
        Boolean formGenerated = false;
        try{
            List<Opportunity> oppList = [Select Id,Unit__c,Project__c,Booking_Form_Generated__c from Opportunity where Id=:recId];
            if(!oppList.isEmpty()){
                formGenerated = oppList[0].Booking_Form_Generated__c;
            }
        }catch(Exception e){
            system.debug('Exception'+e);
        }
        return formGenerated;
    }
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Reset Unit values on timer limit*/
    @AuraEnabled
    public static ResultWrapper resetUnitValues(unit__c units){
        ResultWrapper wrap = new ResultWrapper();
        Opportunity Opp;
        try{
            if(units!=null){
               units.Prebooked_By__c = null;
               units.Unit_Prebooked__c = false;
               units.Time_to_Book_Unit__c = null;
               Opp = [Select id,Opportunity__r.Booking_Form_Generated__c from Opportunity where unit__c=: units.Id and recordtype.developername ='Quick_Book' 
                      and Opportunity__c!=null order by createddate desc limit 1];
            }
            system.debug('Delete opp'+Opp);
            if(Opp!=null && Opp.Opportunity__r.Booking_Form_Generated__c == FALSE){
                delete Opp;
                update units;
            }
            //wrap.success = true;
        }catch(Exception ex){
            system.debug('Unit Reset Error: '+ex);
            //wrap.success = true;
            //wrap.message = ex.getMessage();
        }
        return wrap;
    }
    
    @AuraEnabled
    public static ParentWrapper createSalesOffer(string unitList){
        system.debug('%%unitList'+unitList);
        List<ResultWrapper> rw = (List<ResultWrapper>)JSON.deserialize(unitList,List<ResultWrapper>.class);
        ParentWrapper wrap = new ParentWrapper();
        List<Sales_Offer_Unit__c> salesOfferUnitList = new List<Sales_Offer_Unit__c>();
        MAP<Id,Id> unitIdtoPaymentPlanIDmap = new MAP<Id,Id>();
        List<Sales_Offer_Milestone__c> salesOfferMilestoneList = new List<Sales_Offer_Milestone__c>();
        
        system.debug('==rw=='+rw);
        try{
            if(!rw.isEmpty()){
                //creating sales offer record
                Sales_Offer__c salesOffer = new Sales_Offer__c();
                insert salesOffer;
                
                //creating sales offer units for each of the unit.
                for(ResultWrapper units : rw){
                    Sales_Offer_Unit__c salesOfferUnit = new Sales_Offer_Unit__c();
                    salesOfferUnit.Unit__c = units.unitId;
                    if(units.sellingPrice != null){
                       salesOfferUnit.Unit_Price__c = units.sellingPrice; 
                    }
                    salesOfferUnit.Sales_Offer__c = salesOffer.Id;
                    salesOfferUnitList.add(salesOfferUnit);
                    salesOfferUnit.Name = 'Sales Offer - '+ units.unitName;
                    unitIdtoPaymentPlanIDmap.put(units.unitId,units.masterPaymentPlanId);
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
                wrap.salesOfferId = salesOffer.Id;
                wrap.success = true;
                wrap.message = 'Sales Offer Generated Successfully';
            }
        }
        catch(Exception e){
            system.debug('Exception in sales offer'+e.getMessage() + ':'+ e.getLineNumber());
            wrap.success = false;
            wrap.message = 'Error in sales offer creation';
            wrap.salesOfferId = null;
        }
        return wrap;
    }  
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Fetch unit timings in Timer Component*/
    @AuraEnabled
    public static unit__c getUnitList(String recordId) {
        system.debug('%%recordId'+recordId);
        unit__c unit = new unit__c();
        if(string.isNotEmpty(recordId)){
            unit = [SELECT Id, Name, Time_to_Book_Unit__c FROM Unit__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
        }
        system.debug('unit'+unit);
        return unit;
    }
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Fetch Unit Type values*/
    @AuraEnabled 
    public static Map<String, String> getTypes(){ 
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','Unit_type__c'); 
        return options;
    }    
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Fetch Unit Type values*/
    @AuraEnabled 
    public static Map<String, String> getNumberofBedroomsOptions(){
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','No_of_Bedrooms__c'); 
        return options;
    }
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Fetch Unit Type values*/
    @AuraEnabled 
    public static Map<String, String> getSpaceType(){
        Map<String, String> options = new Map<String, String>();
        for( Space_Type__c sp: [select id,name from Space_Type__c]){
            options.put(sp.id,sp.name);
        }
        return options;
    }
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Fetch Unit Type values*/
    @AuraEnabled 
    public static Map<String, String> getUnitType(){
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','Unit_type__c'); 
        return options;
    }
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Fetch Unit Type values*/
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
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Fetch Unit Type values*/
    @AuraEnabled 
    public static Map<String, String> getUnitTypeGroupOptions(){
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','Architectural_Type__c'); 
        return options;
    }
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Fetch Unit Type values*/
    @AuraEnabled 
    public static Map<String, String> getPropertyUnitViewOptions(){
        Map<String, String> options = new Map<String, String>();
        options = getPicklistValues('Unit__c','Property_Unit_View__c'); 
        return options;
    }
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Fetch Unit Type values*/
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
    
    /*Added By Ashams - 28 jan 22
	* Purpose - Fetch Unit Type values*/
    @AuraEnabled 
    public static Map<String, String> getProjects(){ 
        List<Project__c> projectsList = [select Id,name from Project__c order by Name];
        Map<String, String> options = new Map<String, String>();
        for(Project__c p :projectsList){
           options.put(p.Id,p.Name); 
        }
        return options;
    }
    
    @AuraEnabled
    public static List<Opportunity> fetchAccounts() {
        List<Opportunity> accList = [SELECT Id,Name,ERP_Account_Number__c,Project__c,CreatedDate
                                     from Opportunity where RecordType.DeveloperName = 'Quick_Book' order by createddate desc limit 10 ];
        system.debug('accList'+accList);
        return accList;
    }
    
    public class ResultWrapper{
        //Opp Unit & Unit details
        @AuraEnabled public String oppName;
        @AuraEnabled public String oppId;
        @AuraEnabled public Boolean hasUnit;
        @AuraEnabled public Boolean isBooked;
        @AuraEnabled public Boolean unitAdded;
        @AuraEnabled public Boolean preBooked;
        @AuraEnabled public String preBookedBy; 
        @AuraEnabled public String recordTypeName; 
        @AuraEnabled public String unitId;
        @AuraEnabled public String oppStatus;
        @AuraEnabled public String unitName;
        @AuraEnabled public String unitThemeId;
        @AuraEnabled public String locationCode;
        @AuraEnabled public String building;
        @AuraEnabled public String unitType;
        @AuraEnabled public String unitStyle;
        @AuraEnabled public String unitTheme;
        @AuraEnabled public String usableArea;
        @AuraEnabled public String unitStatus;
        @AuraEnabled public String bedroom;
        @AuraEnabled public String bedroomId;
        @AuraEnabled public String project;
        @AuraEnabled public String cluster;
        @AuraEnabled public String masterPaymentPlanId;
        @AuraEnabled public String masterPaymentPlanName;
        @AuraEnabled public decimal sellingPrice;
        @AuraEnabled public decimal optionsPrice;
        @AuraEnabled public decimal dldShare{get;set;}
        @AuraEnabled public decimal dldNakShare{get;set;}
        @AuraEnabled public String businessUnit{get;set;}
        @AuraEnabled public String businessUnitId{get;set;}
        @AuraEnabled public String ownerId{get;set;}
        @AuraEnabled public boolean Mortgage{get;set;} // added by Deep
        //Joint Owner details
        @AuraEnabled public String primaryAccId; 
        @AuraEnabled public Decimal joCount; 
        @AuraEnabled public List<Address__c> addressList;
    }
    public class Filterwrapper{
         @AuraEnabled public Map<string,string> projectMap;
         @AuraEnabled public Map<string,string> salesEventMap;
         @AuraEnabled public Map<string,string> unitTypeMap;
       	 @AuraEnabled public Map<string,string> buildingMap;
         @AuraEnabled public Map<string,string> bedroomMap;
    }
    public class ParentWrapper{
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String salesOfferId;
        @AuraEnabled public String parentOppId;
        @AuraEnabled public Boolean unitExist;
        @AuraEnabled public Boolean bookingFormGen;
        @AuraEnabled public String project;
        @AuraEnabled public decimal totalPrice;
        @AuraEnabled public List<ResultWrapper> resultWrapperList;
        @AuraEnabled public List<ResultWrapper> bookedWrapperList;
        @AuraEnabled public Filterwrapper filterwrapperList;
        //Account details
        @AuraEnabled public Boolean accExist;
        @AuraEnabled public Boolean isPerson;
        @AuraEnabled public Boolean isOrg;
        @AuraEnabled public String accId;
        @AuraEnabled public List<Address__c> addressList;
        //Referral details
        @AuraEnabled public Boolean brokerExist;
        @AuraEnabled public string brokerId;
        @AuraEnabled public Boolean EmployeeExist;
        @AuraEnabled public String empName;
        @AuraEnabled public String empNumber;
    }
}