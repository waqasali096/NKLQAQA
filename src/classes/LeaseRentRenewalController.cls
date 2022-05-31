/****************************************************************************************************************************
* @Name         LeaseRentRenewalController 
* @Author       Hitesh Patel
* @Date         15-Mar-2022
* @Description  Controller for LeaseRentRenewal Lightning Component. 
****************************************************************************************************************************/
public class LeaseRentRenewalController {
    
    public static List<Lease_Renewal_Setting__mdt> listLeaseRenewalSetting = [SELECT Id, Page_Size__c, Notify_Flag_Email_Alert__c 
                                                                              FROM Lease_Renewal_Setting__mdt 
                                                                              WHERE DeveloperName = 'Lease_Renewal_Setting'
                                                                              LIMIT 1];
    
    /***********************************************************************************************************************
* @Description  This method is used to fetch the Active Leasing Projects
* @Param        NA
* @Return       List<OptionsWrapper>
***********************************************************************************************************************/
    @AuraEnabled
    public static List<OptionsWrapper> getProjects(){
        List<OptionsWrapper> listOptionsWrapper = new List<OptionsWrapper>();        
        listOptionsWrapper.add(getOptions('', 'All'));        
        for(Project__c objProject : [SELECT Id, Name FROM Project__c WHERE Active__c = true AND Project_Purpose__c = 'Leasing' ORDER BY Name LIMIT 5000]){
            listOptionsWrapper.add(getOptions(objProject.Id, objProject.Name));
        }    
        return listOptionsWrapper; 
    }
    
    /***********************************************************************************************************************
* @Description  This method is used to fetch the Space Types related to selected Project
* @Param        NA
* @Return       List<OptionsWrapper>
***********************************************************************************************************************/
    /*@AuraEnabled
public static List<OptionsWrapper> getSpaceTypes(){
List<OptionsWrapper> listOptionsWrapper = new List<OptionsWrapper>(); 
listOptionsWrapper.add(getOptions('', 'All'));  

for(Space_Type__c objSpaceType : [SELECT Id, Name FROM Space_Type__c ORDER BY Name LIMIT 5000]){
listOptionsWrapper.add(getOptions(objSpaceType.Id, objSpaceType.Name));
}    
return listOptionsWrapper; 
}*/
    
    @AuraEnabled 
    public static List<OptionsWrapper> getNoOfBedroomValues(){
        List<OptionsWrapper> listOptionsWrapper = new List<OptionsWrapper>(); 
        listOptionsWrapper.add(getOptions('', 'All'));
        Schema.DescribeFieldResult fieldResult = Unit__c.No_of_Bedrooms__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues){            
            listOptionsWrapper.add(getOptions(p.getValue(), p.getLabel()));
        }
        return listOptionsWrapper;
    }
    
    @AuraEnabled 
    public static List<OptionsWrapper> getUnitTypeValues(){
        List<OptionsWrapper> listOptionsWrapper = new List<OptionsWrapper>(); 
        listOptionsWrapper.add(getOptions('', 'All'));
        Schema.DescribeFieldResult fieldResult = Unit__c.Unit_space_Type__c.getDescribe();
        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues){            
            listOptionsWrapper.add(getOptions(p.getValue(), p.getLabel()));
        }
        return listOptionsWrapper;
    }
    
    /***********************************************************************************************************************
* @Description  This method is used to fetch the Buildings related to selected Project
* @Param        NA
* @Return       List<OptionsWrapper>
***********************************************************************************************************************/
    @AuraEnabled
    public static List<OptionsWrapper> getBuildings(String selectedProject){
        List<OptionsWrapper> listOptionsWrapper = new List<OptionsWrapper>(); 
        Set<Id> setBuildingId = new Set<Id>();
        
        listOptionsWrapper.add(getOptions('', 'All'));  
        String query = 'SELECT id, name, Building__c, Building__r.Name FROM Unit__c WHERE Project__c =: selectedProject AND Building__c != null';
        query = query + ' ORDER BY NAME'; 
        List<Unit__c> unitList = Database.query(query);
        
        for(Unit__c objUnit : unitList){
            if(!setBuildingId.contains(objUnit.Building__c)){                
                listOptionsWrapper.add(getOptions(objUnit.Building__c, objUnit.Building__r.Name));
                setBuildingId.add(objUnit.Building__c);
            }
        }    
        return listOptionsWrapper; 
    }
    
    /***********************************************************************************************************************
* @Description  This method is used to fetch the Floors related to selected Project & Selected Building
* @Param        NA
* @Return       List<OptionsWrapper>
***********************************************************************************************************************/
    @AuraEnabled
    public static List<OptionsWrapper> getFloors(String selectedProject, String selectedBuilding){
        List<OptionsWrapper> listOptionsWrapper = new List<OptionsWrapper>();
        Set<Id> setFloorId = new Set<Id>();  
        
        listOptionsWrapper.add(getOptions('', 'All')); 
        
        String query = 'SELECT id, name, Floor__c, Floor__r.Name FROM Unit__c WHERE Project__c =: selectedProject AND Floor__c != null';
        if(!String.isBlank(selectedBuilding)){
            query = query + ' AND Building__c = \''+selectedBuilding+'\'';
        }
        query = query + ' ORDER BY NAME';
        List<Unit__c> unitList = Database.query(query);   
        
        for(Unit__c objUnit : unitList){
            if(!setFloorId.contains(objUnit.Floor__c)){
                listOptionsWrapper.add(getOptions(objUnit.Floor__c, objUnit.Floor__r.Name));
                setFloorId.add(objUnit.Floor__c);
            }
        } 
        
        return listOptionsWrapper; 
    }
    
    /***********************************************************************************************************************
* @Description  This method is used to prepare list for picklist
* @Param        String strKey, String strValue
* @Return       OptionsWrapper
***********************************************************************************************************************/
    @AuraEnabled
    public static OptionsWrapper getOptions(String strKey, String strValue){
        OptionsWrapper objOptionsWrapper = new OptionsWrapper();
        objOptionsWrapper.key = strKey;
        objOptionsWrapper.value = strValue;
        
        return objOptionsWrapper;
    }
    
    /***********************************************************************************************************************
* @Description  This method is used to fetch Pagination Size from Custom Metadata
* @Param        NA
* @Return       Integer
***********************************************************************************************************************/
    @AuraEnabled 
    public static Integer getPageSize(){
        Integer intPageSize;
        
        if(!listLeaseRenewalSetting.isEmpty()){
            intPageSize = Integer.valueOf(listLeaseRenewalSetting[0].Page_Size__c);
        }
        
        return intPageSize;        
    }
    
    /***********************************************************************************************************************
* @Description  This method is used to fetch Rent Update Reason picklist values
* @Param        NA
* @Return       Map<String, String> 
***********************************************************************************************************************/
    @AuraEnabled 
    public static Map<String, String> getRentUpdateReasonValues(){
        Map<String, String> options = new Map<String, String>();        
        Schema.DescribeFieldResult fieldResult = Unit__c.Rent_Update_Reason__c.getDescribe();        
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    /***********************************************************************************************************************
* @Description  This method is used to fetch Opportunity Units based on Project, Dates & Space Type
* @Param        String selectedProject, String selectedFromDate, String selectedToDate, String selectedSpaceType
* @Return       List<UnitPlansWrapper>
***********************************************************************************************************************/
    @AuraEnabled
    public static List<UnitPlansWrapper> getUnitPlans(String selectedProject, String selectedFromDate, String selectedToDate, String selectedBuilding, String selectedFloor, String selectedNoOfBedroom, String selectedLeasingType, String selectedPropertyType, String selectedUnitType){
        List<UnitPlansWrapper> listUnitPlansWrapper = new List<UnitPlansWrapper>();
        
        String strQuery = 'SELECT Id, Name, Opportunity__c, Project__c, Final_Lease_Amount__c, Price_per_sqft__c, ';
        strQuery += ' Unit__c, Unit__r.Unit_space_Type__c, Unit__r.Project__c, Unit__r.Base_Rent__c, Unit__r.Building__c, Unit__r.Floor__c, Unit__r.No_of_Bedrooms__c, Unit__r.Unit_type__c, Unit__r.Leasing_Property_Type__c, Unit__r.Last_updated_date_for_Rent__c, Unit__r.Space_Types__c, Unit__r.Unit_Leasing_Type__c, Unit__r.Renewal_Rent__c, Unit__r.Space_Types__r.Name, Unit__r.Unit_Leasing_Type__r.Name, Unit__r.Current_Rent__c, Unit__r.Renewal_Comments__c, Unit__r.Rent_Update_Reason__c, Unit__r.Renewal_Notification_Flag__c, Unit__r.Total_Leasable_Area__c, Unit__r.Unit_Code__c, ';
        strQuery += ' Opportunity__r.Name, Opportunity__r.Renewal__c, Opportunity__r.Renewal_Type__c, Opportunity__r.Lease_Number__c, Opportunity__r.Leasing_Number__c, Opportunity__r.Account.Name, Opportunity__r.Account.Primary_Email__c, Opportunity__r.Account.ERP_Account_ID__c, Opportunity__r.Lease_Start_Date__c, Opportunity__r.Lease_End_Date__c ';
        strQuery += ' FROM Unit_Plan__c';
        strQuery += ' WHERE Opportunity__r.IsClosed = true AND Opportunity__r.IsWon = true AND Project__r.Project_Purpose__c = \'Leasing\' AND Project__r.Active__c = true';
        
        if(!String.isEmpty(selectedProject)){
            strQuery += ' AND Project__c =: selectedProject';
        }
        
        strQuery += ' AND Opportunity__r.Lease_End_Date__c >= ' + String.valueOf(Date.valueOf(selectedFromDate)).removeEnd(' 00:00:00');
        strQuery += ' AND Opportunity__r.Lease_End_Date__c <= ' + String.valueOf(Date.valueOf(selectedToDate)).removeEnd(' 00:00:00');
        
        /*if(!String.isEmpty(selectedSpaceType)){
strQuery += ' AND Unit__r.Space_Types__c =: selectedSpaceType';
}*/
        if(!String.isEmpty(selectedBuilding)){
            strQuery += ' AND Unit__r.Building__c =: selectedBuilding';
        }
        if(!String.isEmpty(selectedFloor)){
            strQuery += ' AND Unit__r.Floor__c =: selectedFloor';
        }
        if(!String.isEmpty(selectedNoOfBedroom)){
            strQuery += ' AND Unit__r.No_of_Bedrooms__c =: selectedNoOfBedroom';
        }
        if(!String.isEmpty(selectedLeasingType)){
            strQuery += ' AND Unit__r.Leasing_Type__c =: selectedLeasingType';
        }
        if(!String.isEmpty(selectedPropertyType)){
            strQuery += ' AND Unit__r.Leasing_Property_Type__c =: selectedPropertyType';
        }
        if(!String.isEmpty(selectedUnitType)){
            strQuery += ' AND Unit__r.Unit_space_Type__c =: selectedUnitType';
        }
        system.debug('****strQuery => '+strQuery);
        
        List<Unit_Plan__c> listUnitPlans = Database.query(strQuery);
        
        String strReraRentIndexQuery = 'SELECT Id, Name, Project__c, No_of_Bedrooms__c, Property_Type__c, RERA_Rent_Average__c, RERA_Rent_Average_for_Commercial__c, ';
        strReraRentIndexQuery += ' RERA_Rent_From__c, RERA_Rent_To__c, Start_Date__c, End_Date__c, Default_Increase__c, Price_per_sqft_from__c, Price_per_sqft_to__c ';
        strReraRentIndexQuery += ' FROM RERA_Rent_Index__c WHERE Id != null';
        if(!String.isEmpty(selectedProject)){
            strReraRentIndexQuery += ' AND Project__c =: selectedProject';
        }   
        Id commercialRecordTypeId = Schema.SObjectType.RERA_Rent_Index__c.getRecordTypeInfosByName().get('Commercial').getRecordTypeId();
        Id residentialRecordTypeId = Schema.SObjectType.RERA_Rent_Index__c.getRecordTypeInfosByName().get('Residential').getRecordTypeId();
        
        if(selectedLeasingType == 'Residential Unit'){
            strReraRentIndexQuery += ' AND RecordTypeId =: residentialRecordTypeId';
        }
        
        if(selectedLeasingType == 'Commercial Unit'){
            strReraRentIndexQuery += ' AND RecordTypeId =: commercialRecordTypeId';
        }
        
        strReraRentIndexQuery += ' ORDER BY CREATEDDATE DESC';
        system.debug('***strReraRentIndexQuery => '+strReraRentIndexQuery);
        List<RERA_Rent_Index__c> listReraRentIndex = Database.query(strReraRentIndexQuery);
        String strType;
        if(selectedLeasingType == 'Residential Unit'){
            strType = 'Residential';
        }
        
        if(selectedLeasingType == 'Commercial Unit'){
            strType = 'Commercial';
        }
        
        List<RERA_Rent_Slab__mdt> listReraRentSlab = [SELECT Id, From__c, To__c, Increase__c, Type__c FROM RERA_Rent_Slab__mdt WHERE Type__c =: strType];
        
        for(Unit_Plan__c objUnitPlan : listUnitPlans){
            UnitPlansWrapper objUnitPlansWrapper = new UnitPlansWrapper();
            objUnitPlansWrapper.objUnitPlan = objUnitPlan;
            //objUnitPlansWrapper.dcmRenewalRent = objUnitPlan.Unit__r.Current_Rent__c;
            objUnitPlansWrapper.dcmRenewalRent = 0;
            
            if(selectedLeasingType == 'Residential Unit'){                
                if((objUnitPlan.Opportunity__r.Renewal_Type__c == null && !objUnitPlan.Opportunity__r.Renewal__c) || (objUnitPlan.Opportunity__r.Renewal_Type__c == 'Full' && objUnitPlan.Opportunity__r.Renewal__c)){
                    objUnitPlansWrapper.dcmCurrentRent = objUnitPlan.Final_Lease_Amount__c;
                }
                
                if(objUnitPlan.Opportunity__r.Renewal_Type__c == 'Extension' && objUnitPlan.Opportunity__r.Renewal__c){
                    objUnitPlansWrapper.dcmCurrentRent = objUnitPlan.Unit__r.Base_Rent__c;                
                }
                
                for(RERA_Rent_Index__c objReraRentIndex : listReraRentIndex){
                    if(objUnitPlan.Unit__r.Project__c == objReraRentIndex.Project__c 
                       && objUnitPlan.Unit__r.No_of_Bedrooms__c == objReraRentIndex.No_of_Bedrooms__c
                       && objUnitPlan.Unit__r.Leasing_Property_Type__c == objReraRentIndex.Property_Type__c
                       && objUnitPlan.Opportunity__r.Lease_End_Date__c >= objReraRentIndex.Start_Date__c
                       && objUnitPlan.Opportunity__r.Lease_End_Date__c <= objReraRentIndex.End_Date__c
                       && objUnitPlansWrapper.dcmCurrentRent != null){
                           Decimal dcmIncreasePercentage = 0;
                           if(objReraRentIndex.Default_Increase__c != null){                           
                               dcmIncreasePercentage = objReraRentIndex.Default_Increase__c;
                           }else{
                               for(RERA_Rent_Slab__mdt objReraRentSlab : listReraRentSlab){
                                   Decimal dcmDiffPercentage = (objReraRentIndex.RERA_Rent_Average__c - objUnitPlansWrapper.dcmCurrentRent) / objUnitPlansWrapper.dcmCurrentRent * 100;
                                   if(dcmDiffPercentage >= 100){
                                       dcmDiffPercentage = 100;
                                   }
                                   
                                   if(dcmDiffPercentage >= objReraRentSlab.From__c && dcmDiffPercentage <= objReraRentSlab.To__c){
                                       dcmIncreasePercentage = objReraRentSlab.Increase__c;
                                   }                           
                               }
                           }
                           objUnitPlansWrapper.dcmRenewalRent = objUnitPlansWrapper.dcmCurrentRent * (1 + (dcmIncreasePercentage/100));
                           objUnitPlansWrapper.dcmTempRenewalRent = objUnitPlansWrapper.dcmRenewalRent;
                           break;
                       }
                }
            }
            
            if(selectedLeasingType == 'Commercial Unit'){
                objUnitPlansWrapper.dcmCurrentRent = objUnitPlan.Price_per_sqft__c;
                
                for(RERA_Rent_Index__c objReraRentIndex : listReraRentIndex){
                    if(objUnitPlan.Unit__r.Project__c == objReraRentIndex.Project__c 
                       && objUnitPlan.Unit__r.Leasing_Property_Type__c == objReraRentIndex.Property_Type__c
                       && objUnitPlan.Opportunity__r.Lease_End_Date__c >= objReraRentIndex.Start_Date__c
                       && objUnitPlan.Opportunity__r.Lease_End_Date__c <= objReraRentIndex.End_Date__c
                       && objUnitPlansWrapper.dcmCurrentRent != null){
                           Decimal dcmIncreasePercentage = 0;
                           if(objReraRentIndex.Default_Increase__c != null){                           
                               dcmIncreasePercentage = objReraRentIndex.Default_Increase__c;
                           }
                           else{
                               for(RERA_Rent_Slab__mdt objReraRentSlab : listReraRentSlab){
                                   Decimal dcmDiffPercentage = (objReraRentIndex.RERA_Rent_Average_for_Commercial__c - objUnitPlansWrapper.dcmCurrentRent) / objUnitPlansWrapper.dcmCurrentRent * 100;
                                   if(dcmDiffPercentage >= 100){
                                       dcmDiffPercentage = 100;
                                   }
                                   
                                   if(dcmDiffPercentage >= objReraRentSlab.From__c && dcmDiffPercentage <= objReraRentSlab.To__c){
                                       dcmIncreasePercentage = objReraRentSlab.Increase__c;
                                   } 
                               }
                               objUnitPlansWrapper.dcmRenewalRent = objUnitPlansWrapper.objUnitPlan.Price_per_sqft__c * (1 + (dcmIncreasePercentage/100));
                               objUnitPlansWrapper.dcmTempRenewalRent = objUnitPlansWrapper.dcmRenewalRent;
                               break;
                           }
                       }
                }
            }    
            
            objUnitPlansWrapper.strRentUpdateReason = '';
            objUnitPlansWrapper.strComments = '';
            objUnitPlansWrapper.blnNotifyFlag = false;
            
            listUnitPlansWrapper.add(objUnitPlansWrapper);
        }
        
        return listUnitPlansWrapper;        
    }
    
    /***********************************************************************************************************************
* @Description  This method is used to Save details on Unit records.
* @Param        String strListUnitPlansWrapper
* @Return       ResponseWrapper
***********************************************************************************************************************/
    @AuraEnabled
    public static ResponseWrapper saveUnits(String strListUnitPlansWrapper, String selectedLeasingType){
        ResponseWrapper objResponseWrapper = new ResponseWrapper();
        objResponseWrapper.listUnitPlansWrapper = (List<UnitPlansWrapper>) System.JSON.deserialize(strListUnitPlansWrapper, List<UnitPlansWrapper>.class);
        List<Unit__c> listUnit = new List<Unit__c>();
        List<UnitPlansWrapper> listUnitPlansWrapperSendEmail = new List<UnitPlansWrapper>();
        
        for(UnitPlansWrapper objUnitPlansWrapper : objResponseWrapper.listUnitPlansWrapper){
            if(objUnitPlansWrapper.dcmRenewalRent != null && objUnitPlansWrapper.dcmRenewalRent > 0 && 
               (objUnitPlansWrapper.objUnitPlan.Unit__r.Current_Rent__c != objUnitPlansWrapper.dcmRenewalRent || objUnitPlansWrapper.objUnitPlan.Price_per_sqft__c != objUnitPlansWrapper.dcmRenewalRent || !String.isBlank(objUnitPlansWrapper.strRentUpdateReason) || !String.isBlank(objUnitPlansWrapper.strComments) || objUnitPlansWrapper.blnNotifyFlag)){
                Unit__c objUnit = new Unit__c(Id = objUnitPlansWrapper.objUnitPlan.Unit__c); 
                system.debug('***selectedLeasingType '+selectedLeasingType);
                if(selectedLeasingType == 'Residential Unit'){
                    objUnit.Renewal_Rent__c = objUnitPlansWrapper.dcmRenewalRent;
                }                
                
                if(selectedLeasingType == 'Commercial Unit'){
                    objUnit.Renewal_Rent_sqft__c = objUnitPlansWrapper.dcmRenewalRent;                    
                }
                
                objUnit.Rent_Update_Reason__c = objUnitPlansWrapper.strRentUpdateReason;
                objUnit.Renewal_Comments__c = objUnitPlansWrapper.strComments;
                objUnit.Renewal_Notification_Flag__c = objUnitPlansWrapper.blnNotifyFlag;
                
                if(objUnitPlansWrapper.objUnitPlan.Unit__r.Current_Rent__c != objUnitPlansWrapper.dcmRenewalRent){
                    objUnit.Last_updated_date_for_Rent__c = Date.Today();
                }
                
                if(objUnitPlansWrapper.blnNotifyFlag){
                    listUnitPlansWrapperSendEmail.add(objUnitPlansWrapper);
                }
                
                listUnit.add(objUnit);
            }
        }
        
        if(!listUnit.isEmpty()){
            try{                
                update listUnit;
                objResponseWrapper.strMessage = 'success';
                
                if(!listUnitPlansWrapperSendEmail.isEmpty() && !listLeaseRenewalSetting.isEmpty()){
                    List<SendMailForEmailAlerts.InvokeSendEmail> listInvokeSendEmail = new List<SendMailForEmailAlerts.InvokeSendEmail>();
                    
                    for(UnitPlansWrapper objUnitPlansWrapper : listUnitPlansWrapperSendEmail){
                        SendMailForEmailAlerts.InvokeSendEmail objInvokeSendEmail = new SendMailForEmailAlerts.InvokeSendEmail();
                        objInvokeSendEmail.EmailAlertAPIName = listLeaseRenewalSetting[0].Notify_Flag_Email_Alert__c;
                        objInvokeSendEmail.RecordId = objUnitPlansWrapper.objUnitPlan.Unit__c;
                        listInvokeSendEmail.add(objInvokeSendEmail);
                    }
                    system.debug('%%%%%%%%%%%'+listInvokeSendEmail);
                    if(!listInvokeSendEmail.isEmpty()){
                        SendMailForEmailAlerts.sendEmailBulk(listInvokeSendEmail);
                    }                 
                }      
            }
            catch(Exception ex){
                DebugUtility.logError(ex);
                objResponseWrapper.strMessage = 'Error : ' + ex.getMessage();
            }
        }else{
            objResponseWrapper.strMessage = 'Error : No records found for update.';
        }
        
        return objResponseWrapper;
    }
    
    //Wrapper Class
    public class UnitPlansWrapper{
        @AuraEnabled public Unit_Plan__c objUnitPlan;
        @AuraEnabled public Decimal dcmCurrentRent;
        @AuraEnabled public Decimal dcmRenewalRent;
        @AuraEnabled public Decimal dcmTempRenewalRent;
        @AuraEnabled public String strRentUpdateReason;
        @AuraEnabled public String strComments;
        @AuraEnabled public Boolean blnNotifyFlag;
    }
    
    //Wrapper Class
    public class ResponseWrapper{
        @AuraEnabled public List<UnitPlansWrapper> listUnitPlansWrapper;
        @AuraEnabled public String strMessage;
    }
    
    //Wrapper Class
    public class OptionsWrapper{
        @AuraEnabled public String key;
        @AuraEnabled public String value;
        
        public OptionsWrapper(){
            this.key = '';
            this.value = '';
        }
    }
}