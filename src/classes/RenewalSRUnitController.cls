public class RenewalSRUnitController {
    
    /*
@Author : Swapnil Mohite
@CreatedDate: 6/02/2022
@ This method will fetch all the leased units
*/  @AuraEnabled  
    public static ResultWrapper getUnits(String oppId){
        Opportunity oppRec = getOppRecord(oppId);
        Account accRec=getAccRecord(oppRec.AccountId);
        decimal temprent=oppRec.Final_Lease_Amount__c/365;
        decimal rentPerday=temprent.setScale(2);
        String projectName;
        String unitCategory = '';
        String m='';
        ResultWrapper resultWrapper = new ResultWrapper();
        Map<String,String> oppMap = new Map<String,String>();
        Map<ID,Unit__c> mapUnit=new Map<Id,Unit__c>();
        Map<ID,Flag__c> mapFlag=new Map<Id,Flag__c>();
        Map<String,String> mapOfNoOfBedrooms = new Map<String,String>();
        Map<String,String> mapOfUnitType = new Map<String,String>();
        Map<String,String> mapOfPropertyType = new Map<String,String>();
        Map<String,String> mapOfBuilding = new Map<String,String>();
        Map<String,Unit_Plan__c> oppUnitMap = new Map<String,Unit_Plan__c>();
        Set<Id> unitCaseIdSet = new Set<Id>();
        Set<Id> unitIdSet = new Set<Id>();
        List<Property__c> flagPropList=new List<Property__c>();
        List<Unit__c> listProjectUnit=new List<Unit__c>();
        List<PropWrapper> listProjUnitWrapper=new List<PropWrapper>();
        List<PropWrapper> listPropWrapper=new List<PropWrapper>();
        List<Flag__c> listFlag = new List<flag__c>();
        // code to identify commercial or residential deal and units
        List<Lease_Contract__c> listContract=[select id,Opportunity__c from Lease_Contract__c where Opportunity__c =: oppRec.id];
        if(oppRec.Leasing_Type__c != null){
            if(oppRec.Leasing_Type__c =='Residential Units'){
                unitCategory='Residential Unit';
            }
            else if(oppRec.Leasing_Type__c == 'Commercial Units'){
                unitCategory='Commercial Unit';
            }
        }
        mapOfUnitType = getDependentPicklistValuesAsPerLeasingType(unitCategory,'Unit__c','Leasing_Type__c','Unit_space_Type__c'); 
        mapOfPropertyType = getDependentPicklistValuesAsPerLeasingType(unitCategory,'Unit__c','Leasing_Type__c','Leasing_Property_Type__c'); 
        mapOfNoOfBedrooms = getPicklistValues('Unit__c', 'No_of_Bedrooms__c');
        // fetch active properties
        List<Property__c> propertyList = fetchPropertyRecords(oppRec.Id);   
        resultWrapper.message=''; 
        if(propertyList.isEmpty()){
            resultWrapper.isError=true;
            m=resultWrapper.message;
            m=m+'No existing property to renew.';
            resultWrapper.message=m;
            return resultWrapper; 
        }
        for(Unit_Plan__c oppUnit : oppRec.Unit_Plans__r){
            oppUnitMap.put(oppUnit.unit__c,oppUnit);
        }
        for(Property__c property : propertyList){
            projectName=property.unit__r.Project__r.Name;
            oppMap.put(property.Deal__c,property.Deal__r.name);
            unitIdSet.add(property.unit__c);
        }
        listFlag  = fetchFlagRecords(unitIdSet,oppRec);
        
        for(Flag__c f:listFlag){
            mapFlag.put(f.Unit__c,f);
        }
        if(!listFlag.isEmpty()){
            resultWrapper.flag=true;
        }
        if(listContract.isEmpty()){
            //resultWrapper.isError=true;
            m=resultWrapper.message;
            m=m+'Deal is not having a valid contract to renew.';
            resultWrapper.message=m;
        }
        if(accRec.IsPersonAccount==true ){
            if(accRec.Passport_Expiry_Date__c<=System.today()){
                resultWrapper.isError=true;
                m=resultWrapper.message;
                m=m+'Please upload the updated passport before renewal.';
                resultWrapper.message=m;
                
            }
            if( accRec.Visa_Uploaded__c== true && accRec.Visa_End_Date__c<=System.today()){
                resultWrapper.isError=true;
                m=resultWrapper.message;
                m=m+'Please upload the updated visa before renewal.';
                resultWrapper.message=m;
            }
            if(accRec.Emirates_ID_Uploaded__c== false ){
                resultWrapper.isError=true;
                m=resultWrapper.message;
                m=m+'Please upload the updated Emirates before renewal.';
                resultWrapper.message=m;
            }
        }else if(accRec.IsPersonAccount==false && accRec.Trade_License_End_Date__c <= System.today()){
            resultWrapper.isError=true;
            m=resultWrapper.message;
            m=m+'Please upload the updated Trade License before renewal.';
            resultWrapper.message=m;
        }
        if( resultWrapper.isError==true){
            return resultWrapper;
        }
        listProjectUnit = fetchVacantUnits(unitCategory,oppRec);
        //Code added to remove flagged units from the project unit list 
        set<Id> setProjectUnitId=new set<ID>();
        List<flag__c> lstFlagProjUnit=new List<flag__c>();
        Map<ID,Flag__c> mapProjectUnitIdToFlag=new Map<Id,Flag__c>();
        if(!listProjectUnit.isEmpty()){
            for(Unit__c u:listProjectUnit){
                setProjectUnitId.add(u.id);
            }
            lstFlagProjUnit=fetchFlagRecords(setProjectUnitId,oppRec);
            if(!lstFlagProjUnit.isEmpty()){
                for(flag__c f:lstFlagProjUnit){
                    mapProjectUnitIdToFlag.put(f.Unit__c,f);
                }
            }
        }
        system.debug('mapProjectUnitIdToFlag  >>>>>'+mapProjectUnitIdToFlag);
        
        //End-Code added to remove flagged units from the project unit list
        for(Property__c p : propertyList){
            PropWrapper pw=new PropWrapper();
            pw.oppObj = oppRec;
            pw.unitId=p.Unit__c;
            pw.unitName=p.unit__r.unit_code__c;
            pw.dealId=p.Deal__c;
            pw.dealName=p.Deal__r.name;
            pw.startDate=p.start_date__c;
            pw.endDate=p.end_date__c;
            pw.propFlag=false; 
            pw.newUnit=false;
            pw.building_Floor=p.unit__r.Building__r.Name+p.unit__r.Floor__r.Name;
            pw.noOfBedrooms= p.unit__r.No_of_Bedrooms__c;
            pw.propertyType = p.unit__r.Leasing_Property_Type__c;
            //pw.pricePerSqft = p.unit__r.Price_Per_SQ_FT__c;
            pw.leasableArea = p.unit__r.Total_Leasable_Area__c;
            pw.unitType=p.unit__r.Unit_space_Type__c;
            pw.leasingType = p.unit__r.leasing_type__c;
            pw.isExisting = true;
            pw.buildingId = p.unit__r.building__c;
            if(mapFlag.containsKey(p.Unit__c)){
                pw.propFlag=true;
            }
            if(p.unit__r.leasing_type__c == 'Commercial Unit'){
                 if(p.unit__r.Renewal_Rent_sqft__c != null && p.unit__r.Renewal_Rent_sqft__c !=0){
                      pw.pricePerSqft = p.unit__r.Renewal_Rent_sqft__c;
                 }else if(oppRec.Price_Approval_Status__c == 'Approved'){
                      pw.pricePerSqft = oppRec.Revised_Price_per_Sq_ft__c;
                 }else{
                      pw.pricePerSqft = oppUnitMap.get(p.unit__c).Price_per_sqft__c;
                 }
                if(pw.LeasableArea!=null && pw.pricePerSqft !=null)
                pw.rent =  pw.leasableArea * pw.pricePerSqft;
            }else if(p.unit__r.leasing_type__c == 'Residential Unit'){
                if(p.unit__r.Renewal_Rent__c != null && p.unit__r.Renewal_Rent__c !=0){
                      pw.rent = p.unit__r.Renewal_Rent__c;
                 }else{
                      pw.rent = oppUnitMap.get(p.unit__c).Base_Lease_Amount__c;
                 } 
            }
            listPropWrapper.add(pw);
            resultWrapper.leasingType = p.unit__r.leasing_type__c;
        }
        for(Unit__c u:listProjectUnit){
             if(/*mapProjectUnitIdToFlag.isEmpty()==false &&*/ mapProjectUnitIdToFlag.containsKey(u.id)==false){//added for the flagged units
            PropWrapper puw=new PropWrapper();
            puw.oppObj = oppRec;
            puw.unitId=u.Id;
            puw.unitName=u.Unit_Code__c;
            puw.building_Floor=u.Building__r.Name+'/'+u.Floor__r.Name;
            puw.noOfBedrooms=u.No_of_Bedrooms__c;
            puw.unitType=u.Unit_space_Type__c;
            puw.propertyType = u.Leasing_Property_Type__c;
            puw.leasableArea = u.Total_Leasable_Area__c;
            puw.leasingType = u.leasing_type__c;
            puw.buildingId = u.Building__c;
            puw.buildingName = u.building__r.name;
            mapOfBuilding.put(u.building__c,u.building__r.name);
            //puw.rent=u.Base_Rent__c;
            puw.newUnit=true;
            puw.isExisting = false;
            
            if(u.leasing_type__c == 'Commercial Unit'){
                puw.pricePerSqft = u.Price_Per_SQ_FT__c;
                if(puw.LeasableArea!=null && puw.pricePerSqft !=null)
                puw.rent =  puw.leasableArea * puw.pricePerSqft;
            }else{
                puw.rent = u.base_rent__c;
            }
            puw.securityDeposit = u.security_deposit__c;
            listProjUnitWrapper.add(puw);
             }
        }
        resultWrapper.oppObj = oppRec;
        resultWrapper.isError = false;
        resultWrapper.propertyList =listPropWrapper;
        resultWrapper.projectUnitList=listProjUnitWrapper;
        resultWrapper.oppMap = oppMap;
        if(propertyList.size()>1){
            resultWrapper.isSingleUnitAcc=false;
        }else{
            resultWrapper.isSingleUnitAcc=true;
        }
        resultWrapper.leaseRenewalDate=oppRec.Lease_End_Date__c.addDays(1);
        Date tempDate= resultWrapper.leaseRenewalDate.addDays(-1);
        tempDate=tempDate.addYears(1);
        resultWrapper.leaseRenewalEndDate=tempDate;
        resultWrapper.noOfCheques=oppRec.No_Of_Cheques__c;
        resultWrapper.projectName=projectName;
        resultWrapper.NoOfBedroomsMap=mapOfNoOfBedrooms;
        resultWrapper.propertyTypeMap = mapOfPropertyType;
        resultWrapper.buildingMap = mapOfBuilding;
        resultWrapper.unitType=mapOfUnitType;
        //resultWrapper.leasingType = oppRec.Leasing_Type__c;
        resultWrapper.rentPerDay=rentPerday;
        return resultWrapper;
        
    }
    
    
    /*
@Author : Swapnil Mohite
@CreatedDate: 14/05/2022
@ This method will fetch all the vacant units
*/
    public static List<Unit__c> fetchVacantUnits(String unitCategory,Opportunity oppRec){    
        return [select id,Name,Unit_Code__c, Building__r.Name, Floor__r.Name,  Space_Type__c, Space_Types__r.Name,leasing_type__c,security_deposit__c,building__c,
                Unit_type__c, Renewal_Rent__c,Project__c,Base_Rent__c,No_of_Bedrooms__c,Unit_space_Type__c,Leasing_Property_Type__c,Price_Per_SQ_FT__c,Total_Leasable_Area__c, 
                renewal_Rent_sqft__c 
                from Unit__c where Project__c=:oppRec.Project__c and Unit_Status__c='Vacant' and Leasing_Type__c=:unitCategory];
    }                              
    /*
@Author : Swapnil Mohite
@CreatedDate: 14/05/2022
@ This method will fetch all the active flags
*/
    public static List<flag__c> fetchFlagRecords(Set<Id> unitIdSet,Opportunity oppRec){    
        return [select Id,  Name,  Dimension__c, Flag_Type__c, Active__c, Customer__c, Start_Date__c, End_Date__c, Error_Value__c, Description__c, ERP_ID__c, Master_Flag__c,
                Formula_Description__c, Formula_Dimension__c, Formula_Flag_Type__c, Unit__c, Unit_Master_Flag__c
                from Flag__c where (Unit__c in: unitIdSet OR  Customer__c=: oppRec.AccountId) and Active__c= true ];
    }
    /*
@Author : Swapnil Mohite
@CreatedDate: 14/05/2022
@ This method will fetch all the active properties opportunity wise
*/
    public static List<Property__c> fetchPropertyRecords(String oppId){
        return [SELECT id,name,unit__c,unit__r.Project__r.Name,Unit__r.Opportunity__c,Deal__c,unit__r.opportunity__r.name,unit__r.unit_code__c,unit__r.building__c,
                start_date__c,end_date__c,unit__r.name,Deal__r.name,Unit__r.No_of_Bedrooms__c,unit__r.Building__r.Name,unit__r.leasing_type__c,
                unit__r.Floor__r.Name,unit__r.leasing_property_type__c,unit__r.Renewal_Rent__c,unit__r.Project__c,unit__r.Unit_space_Type__c,unit__r.Total_Leasable_Area__c,
                unit__r.renewal_Rent_sqft__c
                FROM Property__c 
                WHERE Deal__c =: oppId and Status__c in ('Lease Expired','Leased')   and Active__c=true/* and Unit__c NOT IN : unitCaseIdSet*/
                ORDER BY Unit__r.Opportunity__c];
    }
    
    /*
@Author : Swapnil Mohite
@CreatedDate: 6/02/2022
@ This method will fetch all the added caseUnits
*/
    public static Opportunity getOppRecord(String oppId){
        system.debug('oppId>>>>'+oppId);
        Opportunity oppRec = [SELECT id,AccountId,StageName,Lease_End_Date__c,Lease_Start_Date__c,No_Of_Cheques__c,Leasing_Type__c,Final_Lease_Amount__c,Revised_Price_per_Sq_ft__c,
                              Price_Approval_Status__c ,Project__c,CloseDate,Interested_In__c,Booking_Mode__c,Renewal__c,Project__r.Business_Unit__c,Account_Name__c,Company_Name__c,Account_Email__c,Email__c,Master_Opportunity__c,
                              (Select id,unit__c,Base_Lease_Amount__c,Renewal_Rent__c,Price_per_sqft__c,Security_Deposit__c from Unit_Plans__r)
                              FROM Opportunity 
                              WHERE Id =: oppId];
        return oppRec;
    }
    public static Account getAccRecord(Id accId){
        system.debug('accId>>>>'+accId);
        Account accRec = [select id,IsPersonAccount,Trade_License_End_Date__c, Passport_Expiry_Date__c, Visa_Uploaded__c, Visa_End_Date__c, Passport_Uploaded__c, Emirates_ID_Uploaded__c, Trade_License_Expiry_Date__c from Account  
                          WHERE Id =: accId];
        return accRec;
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
        system.debug('values '+JSON.serialize(options));
        return options;
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
    public class PicklistOption {
        public String label { get; set; }
        public String value { get; set; }
        public PicklistOption( String label, String value ) {
            this.label = label;
            this.value = value;
        }
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
    //Added by Karishma for dependent picklist 29th March 2022
    public class TPicklistEntry{
        public string active {get;set;}
        public string defaultValue {get;set;}
        public string label {get;set;}
        public string value {get;set;}
        public string validFor {get;set;}
    }
    
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class ResultWrapper{
        @AuraEnabled
        public List<PropWrapper> propertyList{get;set;}
        @AuraEnabled
        public List<PropWrapper> projectUnitList{get;set;}
        @AuraEnabled
        public Boolean isError{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public Map<String,String> oppMap{get;set;}
        @AuraEnabled
        public String caseType{get;set;}
        @AuraEnabled
        public Boolean isSingleUnitAcc{get;set;}
        @AuraEnabled
        public Date leaseRenewalDate{get;set;}
        @AuraEnabled
        public Date leaseRenewalEndDate{get;set;}
        @AuraEnabled
        public String noOfCheques{get;set;}
        @AuraEnabled
        public String projectName{get;set;}
        @AuraEnabled
        public Map<String, String> NoOfBedroomsMap{get;set;}
        @AuraEnabled
        public Map<String, String> propertyTypeMap{get;set;}
        @AuraEnabled
        public Map<String, String> unitType{get;set;}
        @AuraEnabled
        public Map<String, String> buildingMap{get;set;}
        @AuraEnabled
        public String leasingType{get;set;} 
        @AuraEnabled
        public String paymentMode{get;set;}
        @AuraEnabled
        public Boolean flag {get;set;}
        @AuraEnabled
        public Decimal rentPerDay {get;set;} 
        @AuraEnabled
        public Opportunity oppObj {get;set;} 
    }
    public class PropWrapper{
        @AuraEnabled
        public Opportunity oppObj {get;set;} 
        @AuraEnabled
        public String unitId{get;set;} 
        @AuraEnabled
        public String unitName{get;set;} 
        @AuraEnabled
        public String dealId{get;set;} 
        @AuraEnabled
        public String dealName{get;set;} 
        @AuraEnabled
        public Date startDate{get;set;} 
        @AuraEnabled
        public Date endDate{get;set;} 
        @AuraEnabled
        public Boolean propFlag{get;set;} 
        @AuraEnabled
        public String building_Floor{get;set;} 
        @AuraEnabled
        public String noOfBedrooms{get;set;} 
        @AuraEnabled
        public String propertyType{get;set;} 
        @AuraEnabled
        public String unitType{get;set;} 
        @AuraEnabled
        public Decimal rent{get;set;} 
        @AuraEnabled
        public Decimal securityDeposit{get;set;} 
        @AuraEnabled
        public Boolean newUnit{get;set;}
        @AuraEnabled
        public Boolean isExisting{get;set;}
        @AuraEnabled
        public Decimal pricePerSqft{get;set;}
        @AuraEnabled
        public Decimal leasableArea{get;set;}
        @AuraEnabled
        public String leasingType{get;set;}
        @AuraEnabled
        public String buildingId{get;set;}
        @AuraEnabled
        public String buildingName{get;set;}
    }
    
}