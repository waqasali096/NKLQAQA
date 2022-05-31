/* Name:QuickBookTimerController
* Description: Controller for QuickBookTimer/Quick Book Summary Component
* Created Date: 20/01/2022
* LastModified Date: 20/01/2022
* Created By: Ashams
*/

/* 23 Jan 22
     Comment by Huzefa - neeed to use active checkbox going ahead as its also used in integration - Status__c -> active__c 
     changed sales_status__c to unit_status__c */
    // //Comment by Swapnil - neeed to use Business_Unit__c instead of master_community__c and use unit_Status__c instead of sales_status__c and leasing_status__c

public class QuickBookTimerController {
    
    @AuraEnabled
    public static DateTime fetchQuickBookCloseDate(String recId){
        Opportunity opp = [select Time_to_Close_Quick_Book__c from Opportunity where id =: recId];
        system.debug('Close Date: ' +opp.Time_to_Close_Quick_Book__c);
        return opp.Time_to_Close_Quick_Book__c;
    }
    
    @AuraEnabled
    public static Boolean fetchCheckBookingFormGenerated(String recId){
        Boolean valueCheck=false;
        List<Opportunity> opp = [select Booking_Form_Generated__c from Opportunity where id =: recId and Booking_Form_Generated__c= True];
        if(opp.size()>0){
            valueCheck=true;
        }
        return valueCheck;
    }
    
    //Method to get units attached to Opportunity
    @AuraEnabled
    public static ResultWrapper getExistingUnits(String recId){
        ResultWrapper wrap = new ResultWrapper();
        Boolean unitExist = false;
        Set<Id> unitIds = new Set<Id>();
        List<unit__c> unitLists = new List<unit__c>();
        
        String query = 'Select Id,Unit__c from Opportunity where (Opportunity__c =:recId OR Id=:recId) and Unit__c !=null';
        List<Opportunity> oppList = Database.query(query);
        if(!oppList.isEmpty()){
            unitExist = true;
            for(Opportunity opp:oppList){
                unitIds.add(opp.unit__c);
            }
            if(unitIds.size()>0){
                unitLists =  [Select Id,name,No_of_Bedrooms__c,Master_Payment_Plan__c,Master_Payment_Plan__r.Name,Architectural_Type__c,
                              Selling_Price__c,Property_Unit_View__c,space_types__c,space_types__r.name,
                              active__c,Cluster__c,Cluster__r.Name,Building__c,Building__r.Name,Project__c,Project__r.Name,
                              Floor__c,Floor__r.Name, Business_Group__c,Business_Group__r.Name, Unit_type__c,Total_Area__c,
                              Unit_Status__c,Unit_Code__c,Internal_Area_Sqft__c,Total_Saleable_Area_Sqft__c,Style__c 
                              from Unit__c where ID IN:unitIds];
            }
        }
        else{
            unitExist = false;
        }
        system.debug('unitIds'+unitIds);
        system.debug('unitLists'+unitLists);
        //wrap.unitExist = unitExist;
        //wrap.unitsList = unitLists;
        return wrap;
    }
    
    @AuraEnabled  
    public static string checkAccountExists(string recordId){
        Opportunity opp;
        Boolean isExist = False;
        if(recordId!=null){
            opp = [Select Id,AccountId from Opportunity where Id=:recordId];
            if(opp!=null && opp.AccountId!=null){
                isExist = true;
            }
        }
        system.debug('isExist'+isExist);
        return opp.AccountId;
    }  
    
    /*Added By Ashams - 16 MAR 22
	* Purpose - Create child Opps*/
    @AuraEnabled  
    public static ParentWrapper createChildOpps(string recordId,List<ResultWrapper> cartUnits){
        system.debug('cartUnits'+cartUnits);
        system.debug('cartUnits size'+cartUnits.size());
        Savepoint sp = Database.setSavepoint();
        ParentWrapper response = new ParentWrapper();
        ResultWrapper rswrap = new ResultWrapper();
        Opportunity parentOpp;
        List<Opportunity> childOppList = new List<Opportunity>();
        List<Id> unitIdList = new List<Id>();
        List<unit__c> unitsList = new List<unit__c>();
        List<ResultWrapper> unitWrapList = new List<ResultWrapper>();
        
        if(string.isNotBlank(recordId)){
            parentOpp = [SELECT Id,CloseDate,AccountId,Account.Name,RecordTypeId,RecordType.DeveloperName,Units_Added__c,Opportunity_Number__c,
                         Booking_Reservation_Date__c,Owner.Name FROM Opportunity WHERE Id =: recordId];
        }
        if(cartUnits.size()>0){
            for(ResultWrapper resWrap : cartUnits){
                if(resWrap.unitAdded == FALSE){
                    Opportunity childOpp = new Opportunity();
                    childOpp.Opportunity__c = recordId;
                    childOpp.Name = 'Draft Booking' + '-' + resWrap.unitName;
                    childOpp.Unit__c = resWrap.unitId;
                    childOpp.AccountId = parentOpp.AccountId;
                    //childOpp.No_of_Bedrooms__c = resWrap.bedroom;
                    childOpp.Project__c = resWrap.project;
                    childOpp.Units_Cluster__c = resWrap.cluster;
                    childOpp.Master_Payment_Plan__c = resWrap.masterPaymentPlanId;
                    childOpp.RecordTypeId = parentOpp.RecordTypeId;
                    childOpp.CloseDate = System.today() + 30;
                    childOpp.CurrencyIsoCode = 'AED';
                    childOpp.Booking_Reservation_Date__c = Date.today();
                    childOpp.stageName = 'Choose Units';
                    childOpp.Space_Type__c = resWrap.bedroomId;
                    childOpp.Theme__c =  resWrap.unitThemeId;
                    childOpp.Units_Cluster__c = resWrap.cluster;
                    childOpp.Business_Unit__c = resWrap.businessUnitId;
                    childOpp.DLD_Customer_Share__c = resWrap.dldShare;
                    childOpp.DLD_Nakheel_Share__c = resWrap.dldNakShare;
                    childOpp.CloseDate = System.today() + 30;
                    childOpp.Sales_Executive__c = resWrap.ownerId;
                    childOpp.Unit_Mortgaged__c = resWrap.Mortgage;    // added by Deep
                    childOppList.add(childOpp);
                    unit__c unit = new unit__c();
                    unit.Id = resWrap.unitId;
                    unit.Unit_Prebooked__c = True;
                    unit.Prebooked_By__c = parentOpp.Owner.Name;
                    unit.Time_to_Book_Unit__c = System.now().addminutes(20);
                    unitsList.add(unit);
                }
            } 
        }
        system.debug('childOppList'+childOppList);
        system.debug('childOppList size'+childOppList.size());
        if(!childOppList.isEmpty()){
            try{
                insert childOppList;
                update unitsList;
                if(parentOpp.AccountId == null){
                    parentOpp.name = 'Draft Booking' + '-'+ parentOpp.Opportunity_Number__c;
                }
                parentOpp.Units_Added__c = TRUE;
                update parentOpp;
                response = getChildOpps(recordId);
            }catch(Exception ex){
                system.debug('error==  + ' + ex+ex.getLineNumber());
                response.message = ex.getMessage();
                response.success = false;
                Database.RollBack(sp);
            }
        }
        return response;
    }
    
    /*Added By Ashams - 16 MAR 22
	* Purpose - Get existing child Opps & make wrapper*/
    @AuraEnabled  
    public static ParentWrapper getChildOpps(string recordId){
        Savepoint sp = Database.setSavepoint();
        ParentWrapper response = new ParentWrapper();
        ResultWrapper rswrap = new ResultWrapper();
        List<Opportunity> childOppList = new List<Opportunity>();
        Opportunity parentOpp = new Opportunity();
        List<ResultWrapper> unitWrapList = new List<ResultWrapper>();
        List<ResultWrapper> bookedWrapList = new List<ResultWrapper>();
        Decimal cartTotalPrice = 0;
        Decimal bookedTotalPrice = 0;
        String AccountId;
        List<joint_buyer__c> joList = new List<joint_buyer__c>();
        
        try{
            if(string.isNotBlank(recordId)){
                parentOpp = [Select Id,AccountId,units_added__c from Opportunity where Id=:recordId];
                childOppList = [Select Id,Name,Unit__c,Sales_Sub_Type__c,Project__c,Booking_Form_Generated__c,unit__r.Unit_Status__c,unit__r.Unit_Prebooked__c,unit__r.Unit_type__c,unit__r.Unit_Theme__r.Name,Opportunity__r.AccountId,Token_Amount__c,AccountId,
                                unit__r.Prebooked_By__c,unit__r.Time_to_Book_Unit__c,unit__r.Name,unit__r.Unit_Code__c,unit__r.Building__r.Name,unit__r.Unit_Style__r.name,unit__r.Usable_Area__c,Booking_Amount__c,Token_Amount_Paid__c,
                                unit__r.No_of_Bedrooms__c,unit__r.project__c,unit__r.cluster__c,unit__r.Master_Payment_Plan__c,unit__r.Master_Payment_Plan__r.Name,unit__r.Selling_Price__c,unit__r.Unit_Theme__c,Type_Of_Sale__c,Total_Charges_Amount__c,
                                Options_Total_Amount__c,unit__r.space_types__c,unit__r.space_types__r.name,DLD_Amount__c,unit__r.Total_Area__c,unit__r.Built_Up_Area__c,unit__r.Final_BUA__c,unit__r.Final_Total_Area__c,(select Id,Amount__c from Opportunity_Charges__r)
                                from Opportunity where Opportunity__c =: recordId];
                jolist = [Select Id,name,Name__c,First_Name__c,Last_Name__c,Unit__c,Primary_Account__c,Primary_Account__r.name,Opportunity__c,Email__c,Mobile__c,
                          Secondary_Account__c,Secondary_Account__r.name,Relationship_with_Owner__c,Share_Percentage__c 
                          FROM Joint_Buyer__c where Opportunity__c =: recordId];
            }
            system.debug('childOppList'+childOppList);
            if(!childOppList.isempty()){
                for(Opportunity childOpp:childOppList){
                    Decimal chargePrice = 0;
                    if(childOpp.unit__r.Unit_Status__c == 'Booked'){
                        ResultWrapper unitWrap = new ResultWrapper();
                        unitWrap.oppName = childOpp.Name;
                        unitWrap.oppId = childOpp.Id;
                        unitWrap.unitId = childOpp.unit__c;
                        unitWrap.unitName = childOpp.unit__r.Name;
                        unitWrap.locationCode = childOpp.unit__r.Unit_Code__c;
                        unitWrap.building = childOpp.unit__r.Building__r.Name;
                        unitWrap.unitType = childOpp.unit__r.Unit_type__c;
                        unitWrap.unitStyle = childOpp.unit__r.Unit_Style__r.name;
                        unitWrap.unitTheme = childOpp.unit__r.Unit_Theme__r.Name;
                        unitWrap.unitThemeId = childOpp.unit__r.Unit_Theme__c;
                        unitWrap.usableArea = String.valueof(childOpp.unit__r.Final_BUA__c);
                        unitWrap.totalArea = String.valueof(childOpp.unit__r.Final_Total_Area__c);
                        unitWrap.unitStatus = childOpp.unit__r.Unit_Status__c;
                        unitWrap.bedroom = childOpp.unit__r.space_types__r.name;
                        unitWrap.bedroomId = childOpp.unit__r.space_types__c;
                        unitWrap.project = childOpp.unit__r.project__c;
                        unitWrap.cluster = childOpp.unit__r.cluster__c;
                        unitWrap.masterPaymentPlanId = childOpp.unit__r.Master_Payment_Plan__c;
                        unitWrap.masterPaymentPlanName = childOpp.unit__r.Master_Payment_Plan__r.Name;
                        unitWrap.sellingPrice = childOpp.unit__r.Selling_Price__c;
                        unitWrap.optionsPrice = childOpp.Options_Total_Amount__c;
                        unitWrap.unitAdded = TRUE;
                        unitWrap.tokenAmount = childOpp.Token_Amount__c;
                        unitWrap.salesType = childOpp.Type_Of_Sale__c;
                        unitWrap.salesSubType = childOpp.Sales_Sub_Type__c;
                        if(childOpp.Token_Amount_Paid__c== TRUE)
                            unitWrap.tokenStatus = 'PAID';
                        else if(childOpp.Token_Amount__c!=null)
                            unitWrap.tokenStatus = 'PENDING';
                        if(childOpp.Opportunity_Charges__r.size()>0){
                            for(Opportunity_Charges__c opCharge : childOpp.Opportunity_Charges__r){
                                if(opCharge.Amount__c!=null){
                                    chargePrice = chargePrice + opCharge.Amount__c;
                                }
                            }
                        }
                        unitWrap.chargesPrice = chargePrice;
                        //unitWrap.netPrice = childOpp.unit__r.Selling_Price__c + childOpp.Options_Total_Amount__c + chargePrice;
                        unitWrap.netPrice = childOpp.unit__r.Selling_Price__c + childOpp.Options_Total_Amount__c;
                        unitWrap.dldPrice = childOpp.DLD_Amount__c;
                        bookedTotalPrice = bookedTotalPrice + unitWrap.netPrice;
                        bookedWrapList.add(unitWrap);
                        response.unitExist = true;
                    }else {
                        ResultWrapper unitWrap = new ResultWrapper();
                        unitWrap.oppName = childOpp.Name;
                        unitWrap.oppId = childOpp.Id;
                        unitWrap.unitId = childOpp.unit__c;
                        unitWrap.unitName = childOpp.unit__r.Name;
                        unitWrap.locationCode = childOpp.unit__r.Unit_Code__c;
                        unitWrap.building = childOpp.unit__r.Building__r.Name;
                        unitWrap.unitType = childOpp.unit__r.Unit_type__c;
                        unitWrap.unitStyle = childOpp.unit__r.Unit_Style__r.name;
                        unitWrap.unitTheme = childOpp.unit__r.Unit_Theme__r.Name;
                        unitWrap.unitThemeId = childOpp.unit__r.Unit_Theme__c;
                        unitWrap.usableArea = String.valueof(childOpp.unit__r.Final_BUA__c);
                        unitWrap.totalArea = String.valueof(childOpp.unit__r.Final_Total_Area__c);
                        unitWrap.unitStatus = childOpp.unit__r.Unit_Status__c;
                        unitWrap.prebookingTime = childOpp.unit__r.Time_to_Book_Unit__c;
                        unitWrap.bedroom = childOpp.unit__r.space_types__r.name;
                        unitWrap.bedroomId = childOpp.unit__r.space_types__c;
                        unitWrap.project = childOpp.unit__r.project__c;
                        unitWrap.cluster = childOpp.unit__r.cluster__c;
                        unitWrap.masterPaymentPlanId = childOpp.unit__r.Master_Payment_Plan__c;
                        unitWrap.masterPaymentPlanName = childOpp.unit__r.Master_Payment_Plan__r.Name;
                        unitWrap.sellingPrice = childOpp.unit__r.Selling_Price__c;
                        unitWrap.optionsPrice = childOpp.Options_Total_Amount__c;
                        unitWrap.unitAdded = TRUE;
                        unitWrap.tokenAmount = childOpp.Token_Amount__c;
                        unitWrap.salesType = childOpp.Type_Of_Sale__c;
                        unitWrap.salesSubType = childOpp.Sales_Sub_Type__c;
                        if(childOpp.Token_Amount_Paid__c== TRUE)
                            unitWrap.tokenStatus = 'PAID';
                        else if(childOpp.Token_Amount__c!=null)
                            unitWrap.tokenStatus = 'PENDING';
                        if(childOpp.Opportunity_Charges__r.size()>0){
                            for(Opportunity_Charges__c opCharge : childOpp.Opportunity_Charges__r){
                                if(opCharge.Amount__c!=null){
                                    chargePrice = chargePrice + opCharge.Amount__c;
                                }
                            }
                        }
                        unitWrap.chargesPrice = chargePrice;
                        //unitWrap.netPrice = unitWrap.sellingPrice + unitWrap.optionsPrice + chargePrice;
                        unitWrap.netPrice = childOpp.unit__r.Selling_Price__c + childOpp.Options_Total_Amount__c;
                        unitWrap.dldPrice = childOpp.DLD_Amount__c;
                        cartTotalPrice = cartTotalPrice + unitWrap.netPrice;
                        unitWrapList.add(unitWrap);
                        response.unitExist = true; 
                    }
                }
            }
            if(parentOpp!=null){
                response.accId = parentOpp.AccountId;
                response.accExist = TRUE;
            }else{
                response.accExist = FALSE;
            }
            response.jointOwnerList = jolist;
            response.resultWrapperList = unitWrapList;
            response.bookedWrapperList = bookedWrapList;
            response.parentOppId = recordId;
            response.cartTotalPrice = cartTotalPrice;
            response.bookedTotalPrice = bookedTotalPrice;
            response.success = TRUE;
            response.message = 'Units Added to Cart';
        }catch(Exception ex){
            system.debug('Exception'+ex.getMessage()+ex.getLineNumber());
            response.success = FALSE;
            response.message = ex.getMessage()+ex.getLineNumber();
        }
        return response;
    }
    
    /*Added By Ashams - 16 MAR 22
* Purpose - Book Units*/
    @AuraEnabled  
    public static ParentWrapper bookUnits(string recordId,List<ResultWrapper> bookedUnits){
        system.debug('bookedUnits'+bookedUnits);
        Savepoint sp = Database.setSavepoint();
        ParentWrapper response = new ParentWrapper();
        ResultWrapper rswrap = new ResultWrapper();
        List<unit__c> unitsList = new List<unit__c>();
        List<Opportunity> convertedSalesOppList = new List<Opportunity>();
        List<Joint_Buyer__c> jointBuyersList = new List<Joint_Buyer__c>();
        Opportunity parentOpp = new Opportunity();
        if(string.isNotEmpty(recordId)){
            parentOpp = [Select Id,AccountId, Account.Name,Move_to_Advanced_Screen__c,Employee_Name__c,
                         Employee_Number__c,Broker__c,Referred_Customer__c,Power_Of_Attorney__c,
                         (Select Id,First_Name__c,Last_Name__c,Unit__c,Primary_Account__c,Opportunity__c,Email__c,Mobile__c,
                          Secondary_Account__c,Relationship_with_Owner__c,Share_Percentage__c from Joint_Buyers__r)
                         from Opportunity where Id=:recordId limit 1];
        }
        
        
        if(bookedUnits.size()>0){
            for(ResultWrapper resWrap : bookedUnits){
                unit__c unit = new unit__c();
                unit.Id = resWrap.unitId;
                unit.Unit_Status__c = 'Booked';
                unit.Active_Deal__c = resWrap.oppId;
                unit.Active_Account__c = parentOpp.AccountId;//Added By Mamta - 29 April
                unitsList.add(unit);
                
                Opportunity salesOpp = new Opportunity();
                salesOpp.Id = resWrap.oppId;
                salesOpp.Move_to_Advanced_Screen__c	= TRUE;
                salesOpp.Name = parentOpp.Account.Name + '-'+ resWrap.unitName;
                salesOpp.Employee_Name__c = parentOpp.Employee_Name__c;
                salesOpp.Employee_Number__c = parentOpp.Employee_Number__c;
                salesOpp.Broker__c = parentOpp.Broker__c;
                salesOpp.Referred_Customer__c = parentOpp.Referred_Customer__c;
                salesOpp.RecordTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Opportunity').getRecordTypeId();
                salesOpp.StageName = 'Booked';
                salesOpp.Power_Of_Attorney__c = parentOpp.Power_Of_Attorney__c;
                convertedSalesOppList.add(salesOpp);
                system.debug('convertedSalesOppList'+convertedSalesOppList);
                if(parentOpp.Joint_Buyers__r.size()>0){
                    for(Joint_Buyer__c jointBuyer:parentOpp.Joint_Buyers__r){
                        joint_buyer__c jb = jointBuyer.clone(false, false, false, false);
                        jb.Opportunity__c = resWrap.oppId;
                        jb.unit__c = resWrap.unitId;
                        jointBuyersList.add(jb);
                    }
                }
            } 
            parentOpp.Move_to_Advanced_Screen__c = TRUE;
        }
        if(!unitsList.isEmpty()){
            try{
                if(!jointBuyersList.isEmpty()){
                   insert jointBuyersList; 
                }
                update unitsList;
                update convertedSalesOppList;
                update parentOpp;
                response = getChildOpps(recordId);
            }catch(Exception ex){
                system.debug('error==  + ' + ex);
                response.message = ex.getMessage();
                response.success = false;
                Database.RollBack(sp);
            }
        }
        return response;
    }
    
    /*Added By Ashams - 16 MAR 22
	* Purpose - Remove child Opps & remove unit prebooking*/
    @AuraEnabled  
    public static boolean removeChildOpps(List<ResultWrapper> removeCartUnits){
        List<Opportunity> deleteOppsList = new List<Opportunity>();
        List<unit__c> removedUnitsList = new List<unit__c>();
        Boolean isSuccess;
        if(removeCartUnits.size()>0){
            for(ResultWrapper resWrap : removeCartUnits){
                Opportunity childOpp = new Opportunity();
                childOpp.Id = resWrap.oppId;
                deleteOppsList.add(childOpp);
                unit__c unit = new unit__c();
                unit.Id = resWrap.unitId;
                unit.Unit_Prebooked__c = False;
                unit.Prebooked_By__c = '';
                unit.Time_to_Book_Unit__c = null;
                removedUnitsList.add(unit);
            } 
        }
        try{
            if(!deleteOppsList.isEmpty()){
                delete deleteOppsList;
            }
            if(!removedUnitsList.isEmpty()){
                update removedUnitsList;
            }
            isSuccess = true;
        }catch(Exception ex){
            system.debug('error in cart removal=  + ' + ex);
            isSuccess = false;
        }
        return isSuccess;
    }
    
    /*Added By Ashams - 16 MAR 22
	* Purpose - Add child Opps to sales offer generation*/
    @AuraEnabled  
    public static boolean addtoSalesOffer(List<ResultWrapper> salesOfferUnits){
        List<Opportunity> salesOfferOpps = new List<Opportunity>();
        Boolean isSuccess;
        if(salesOfferUnits.size()>0){
            for(ResultWrapper resWrap : salesOfferUnits){
                Opportunity childOpp = new Opportunity();
                childOpp.Id = resWrap.oppId;
                childOpp.Add_to_Sales_Offer__c = true;
                salesOfferOpps.add(childOpp);
            } 
        }
        try{
            if(!salesOfferOpps.isEmpty()){
                update salesOfferOpps;
            }
            isSuccess = true;
        }catch(Exception ex){
            system.debug('error in sales offer update=  + ' + ex);
            isSuccess = false;
        }
        return isSuccess;
    }
    
    /*Added By Ashams - 16 MAR 22
	* Purpose - Update Sales Type for opportunity*/
    @AuraEnabled  
    public static boolean updateSalesType(ResultWrapper childOpps){
        List<Opportunity> childOpportunities = new List<Opportunity>();
        Boolean isSuccess;
        if(childOpps!=null){
            Opportunity childOpp = new Opportunity();
            childOpp.Id = childOpps.oppId;
            childOpp.Type_Of_Sale__c = childOpps.salesType;
            childOpp.Sales_Sub_Type__c = childOpps.salesSubType;
            childOpportunities.add(childOpp);
        }
        try{
            if(!childOpportunities.isEmpty()){
                update childOpportunities;
            }
            isSuccess = true;
        }catch(Exception ex){
            system.debug('error in sale type update=  + ' + ex);
            isSuccess = false;
        }
        return isSuccess;
    }
    
    @AuraEnabled  
    public static Map<String, List<String>> getDependentPicklistValues(string dependToken) {
        Schema.sObjectType objType = Opportunity.getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        Schema.SObjectField theField = objFieldMap.get(dependToken);
        Schema.DescribeFieldResult depend = theField.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars = String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue = (controlEntries == null ?  (Object) (index == 1) :  (Object) (controlEntries[index].isActive() ? controlEntries[index].getValue() : null));
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if(controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if(!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        system.debug('dependentPicklistValues'+dependentPicklistValues);
        return dependentPicklistValues;
    }
    
    /*Added By Ashams - 16 MAR 22
	* Purpose - get Opportunity Options Total Amount*/
    @AuraEnabled  
    public static decimal getOptionsPrice(string recordId,boolean isDLD){
        decimal optionsPrice;
        try{
            if(string.isNotBlank(recordId)){
                Opportunity opp = [select Id,DLD_Amount__c,Options_Total_Amount__c,Total_Charges_Amount__c from Opportunity where Id=:recordId]; 
                if(isDLD){
                    if(opp.Total_Charges_Amount__c!=null){
                       optionsPrice = opp.Total_Charges_Amount__c; 
                    }else{
                        optionsPrice = opp.DLD_Amount__c; 
                    }
                }else{
                    optionsPrice = opp.Options_Total_Amount__c;
                }
            }
        }catch(Exception ex){
            system.debug('error in option/DLD price calculation=  + ' + ex);
        }
        system.debug('optionsPrice/DLDPrice  + ' + optionsPrice);
        return optionsPrice;
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
	* Purpose - to fetch document & view Booking form*/
    @AuraEnabled 
    public static ParentWrapper getBookingForm(string OppId){
        ParentWrapper resultWrapper = new ParentWrapper();
        Document__c BookingFormDoc = [SELect Id,Opportunity__r.Booking_Form_Generated_Sales__c,Document_Type__c,Attachment_Id__c 
                                      from Document__c where Opportunity__c =:OppId and Document_Type__c =: 'Booking Form'];
        try{
            if(BookingFormDoc!=null){
                if(BookingFormDoc.Attachment_Id__c != null){
                    resultWrapper.success = true;
                    resultWrapper.message = 'Booking form generated';
                    resultWrapper.bookingFormId = BookingFormDoc.Attachment_Id__c;
                    resultWrapper.bookingFormDocId = BookingFormDoc.Id;
                }else{
                    resultWrapper.success = true;
                    resultWrapper.message = 'Booking form is getting generated. Please try after sometime.';
                    resultWrapper.bookingFormDocId = BookingFormDoc.Id;
                }
            }else{
                resultWrapper.success = false;
                resultWrapper.message = 'Error in viewing booking form.Please try again/regenarate the form.';
            }
        }catch(Exception ex){
            system.debug('error getBookingForm  + ' + ex.getMessage());
            resultWrapper.success = false;
            resultWrapper.message = 'error getBookingForm'+ex.getMessage();
        }
        return resultWrapper;
    }

    /*
	* @author : Ashams
	* @usage : get AccountWrapper
	*/
    @AuraEnabled
    public static ResultWrapper getAccountDetails(string accountId, string OppId){
        List<Account> accountList = new List<Account>();
        ResultWrapper accWrap = new ResultWrapper();
        Opportunity Opp;
        String AccId = '';
        if(string.isNotBlank(OppId)){
           Opp = [Select Id,AccountId,Account.RecordType.DeveloperName from Opportunity where Id=:OppId limit 1];
           AccId = Opp.AccountId;
        }else{
           AccId = accountId; 
        }
        if(string.isNotBlank(AccId)){
            accountList = [SELECT Id,RecordTypeId,RecordType.Developername,FirstName,LastName,Name,Arabic_Name__c,Emirates_Ids__c,Nationality__c,toLabel(Customer_Nationality__c),
                           Primary_Country_Code__c,Primary_Mobile__c,Primary_Email__c,Passport_Number__c,Passport_Issue_Date__c,Passport_Expiry_Date__c,IsPersonAccount,
                           Passport_Issue_Place__c,Visa_End_Date__c,Visa_Start_Date__c,Visa_Number__c,toLabel(Country_Of_Residence__c),Trade_License_Number__c,
                           (SELECT Id,Name,Account__c,Primary__c,Arabic_Address__c,City__c,toLabel(Country__c),PO_Box__c,Postal_Code__c,Street__c from address__r)
                           from Account where ID =: AccId];
        }
        system.debug('&&accountList'+accountList);
        if(!accountList.isEmpty()){
           accWrap.accounts =accountList[0];
           accWrap.accId = accountList[0].Id;
        }
        system.debug('&&accWrap'+accWrap);
        return accWrap;
    }

    public class ResultWrapper{
        //Opp Unit & Unit details
        @AuraEnabled
        public String oppName{get;set;}
        @AuraEnabled
        public String oppId{get;set;}
        @AuraEnabled
        public Boolean hasUnit{get;set;}
        @AuraEnabled
        public Boolean isBooked{get;set;}
        @AuraEnabled
        public Boolean unitAdded{get;set;}
        @AuraEnabled
        public Boolean preBooked{get;set;}
        @AuraEnabled
        public String preBookedBy{get;set;} 
        @AuraEnabled
        public Datetime prebookingTime{get;set;}
        @AuraEnabled
        public String recordTypeName{get;set;} 
        @AuraEnabled
        public String unitId{get;set;}
        @AuraEnabled
        public String oppStatus{get;set;}
        @AuraEnabled
        public String unitName{get;set;}
        @AuraEnabled
        public String unitThemeId{get;set;}
        @AuraEnabled
        public String locationCode{get;set;}
        @AuraEnabled
        public String building{get;set;}
        @AuraEnabled
        public String unitType{get;set;}
        @AuraEnabled
        public String unitStyle{get;set;}
        @AuraEnabled
        public String unitTheme{get;set;}
        @AuraEnabled
        public String usableArea{get;set;}
        @AuraEnabled
        public String totalArea{get;set;}
        @AuraEnabled
        public String unitStatus{get;set;}
        @AuraEnabled
        public String bedroom{get;set;}
        @AuraEnabled
        public String bedroomId{get;set;}
        @AuraEnabled
        public String project{get;set;}
        @AuraEnabled
        public String cluster{get;set;}
        @AuraEnabled
        public String masterPaymentPlanId{get;set;}
        @AuraEnabled
        public String masterPaymentPlanName{get;set;}
        @AuraEnabled
        public decimal sellingPrice{get;set;}
        @AuraEnabled
        public decimal optionsPrice{get;set;}
        @AuraEnabled
        public decimal chargesPrice{get;set;}
        @AuraEnabled
        public decimal dldPrice{get;set;}
        @AuraEnabled
        public decimal netPrice{get;set;}
        @AuraEnabled
        public decimal tokenAmount{get;set;}
        @AuraEnabled
        public String tokenStatus{get;set;}
        @AuraEnabled
        public String salesType{get;set;}
        @AuraEnabled
        public String salesSubType{get;set;}
        @AuraEnabled
        public decimal dldShare{get;set;}
        @AuraEnabled
        public decimal dldNakShare{get;set;}
        @AuraEnabled
        public String clusterId{get;set;}
        @AuraEnabled
        public String businessUnit{get;set;}
        @AuraEnabled
        public String businessUnitId{get;set;}
        @AuraEnabled
        public String ownerId{get;set;}
        @AuraEnabled
        public boolean Mortgage{get;set;}    // added by Deep
        //Joint Owner details
        @AuraEnabled
        public String primaryAccId{get;set;} 
        @AuraEnabled
        public Decimal joCount{get;set;}
        @AuraEnabled
        public List<Address__c> addressList{get;set;}
        @AuraEnabled
        public String accId {get;set;}
        @AuraEnabled
        public Account accounts {get;set;}
    }
    public class Filterwrapper{
        @AuraEnabled
        public Map<string,string> projectMap{get;set;}
        @AuraEnabled
        public Map<string,string> salesEventMap{get;set;}
        @AuraEnabled
        public Map<string,string> unitTypeMap{get;set;}
        @AuraEnabled
        public Map<string,string> buildingMap{get;set;}
        @AuraEnabled
        public Map<string,string> bedroomMap{get;set;}
    }
    public class ParentWrapper{
        @AuraEnabled
        public Boolean success{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public String parentOppId{get;set;}
        @AuraEnabled
        public Boolean unitExist{get;set;}
        @AuraEnabled
        public Boolean bookingFormGen{get;set;}
        @AuraEnabled
        public String bookingFormId{get;set;}
        @AuraEnabled
        public String bookingFormDocId{get;set;}
        @AuraEnabled
        public String project{get;set;}
        @AuraEnabled
        public decimal cartTotalPrice{get;set;}
        @AuraEnabled
        public decimal bookedTotalPrice{get;set;}
        @AuraEnabled
        public List<ResultWrapper> resultWrapperList{get;set;}
        @AuraEnabled
        public List<ResultWrapper> bookedWrapperList{get;set;}
        @AuraEnabled
        public Filterwrapper filterwrapperList{get;set;}
        //Account details
        @AuraEnabled
        public List<joint_buyer__c> jointOwnerList{get;set;}
        @AuraEnabled
        public Boolean accExist{get;set;}
        @AuraEnabled
        public Boolean isPerson{get;set;}
        @AuraEnabled
        public Boolean isOrg{get;set;}
        @AuraEnabled
        public String accId{get;set;}
        @AuraEnabled
        public List<Address__c> addressList{get;set;}
        //Referral details
        @AuraEnabled
        public Boolean brokerExist{get;set;}
        @AuraEnabled
        public string brokerId{get;set;}
        @AuraEnabled
        public Boolean EmployeeExist{get;set;}
        @AuraEnabled
        public String empName{get;set;}
        @AuraEnabled
        public String empNumber{get;set;}
    }
}