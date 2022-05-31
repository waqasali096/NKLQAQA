/*
@Author : Swapnil Mohite
@CreatedDate: 4/02/2022
@ This apex class will handle functionalities related to SRUnitSelectionComponent and case unit creation logic
*/
public class CaseUnitController{
    
    /*
@Author : Swapnil Mohite
@CreatedDate: 6/02/2022
@ This method will fetch all the leased units
*/  @AuraEnabled  
    public static ResultWrapper getUnits(String caseId){
        Case caseRec = getCaseRecord(caseId);
        Set<Id> unitCaseIdSet = new Set<Id>();
        Set<Id> unitIdSet = new Set<Id>();
        Map<String,String> oppMap = new Map<String,String>();
        ResultWrapper resultWrapper = new ResultWrapper();
        List<PropWrapper> listPropWrapper=new List<PropWrapper>();
        
        List<Property__c> flagPropList=new List<Property__c>();
        if(caseRec.AccountId == null){
            resultWrapper.isError = true;
            resultWrapper.message = 'Please link case with a customer';
            return resultWrapper;
        }
        List<Case_Unit__c> caseUnitList = getCaseUnits(caseId);
        for(Case_unit__c caseUnit : caseUnitList){
            unitCaseIdSet.add(caseUnit.Unit__c);
        }
        List<Property__c> propertyList = [SELECT id,name,unit__c,Unit__r.Opportunity__c,Deal__c,unit__r.opportunity__r.name,unit__r.unit_code__c,start_date__c,end_date__c,unit__r.name,Deal__r.name 
                                          FROM Property__c 
                                          WHERE Account__c =: caseRec.AccountId and Status__c = 'Leased' and Active__c=true and Unit__c NOT IN : unitCaseIdSet
                                          ORDER BY Unit__r.Opportunity__c];
        for(Property__c property : propertyList){
             oppMap.put(property.Deal__c,property.Deal__r.name);
            unitIdSet.add(property.unit__c);
        }
        List<Flag__c> listFlag=[select Id,  Name,  Dimension__c, Flag_Type__c, Active__c, Customer__c, Start_Date__c, End_Date__c, Error_Value__c, Description__c, ERP_ID__c, Master_Flag__c,
                                Formula_Description__c, Formula_Dimension__c, Formula_Flag_Type__c, Unit__c, Unit_Master_Flag__c from Flag__c where Unit__c in: unitIdSet and Active__c= true ];
        //if(listFlag.size()>0){
            for(Property__c p : propertyList){
                PropWrapper pw=new PropWrapper();
                pw.unitId=p.Unit__c;
                pw.unitName=p.unit__r.name;
                pw.dealId=p.Deal__c;
                pw.dealName=p.Deal__r.name;
                pw.startDate=p.start_date__c;
                pw.endDate=p.end_date__c;
                pw.propFlag=false;    
                for(Flag__c f:listFlag){
                    if(p.Unit__c==f.Unit__c){
                        pw.propFlag=true;
                    }
                }
                listPropWrapper.add(pw);
           // }
        }
        resultWrapper.isError = false;
        //resultWrapper.propertyList = propertyList;
        resultWrapper.propertyList =listPropWrapper;
        resultWrapper.oppMap = oppMap;
         resultWrapper.caseType = caseRec.Type;
        if(flagPropList.size()>0){
           // resultWrapper.flaggedPropertyList=flagPropList;
        }
        return resultWrapper;
    }
    /*
@Author : Swapnil Mohite
@CreatedDate: 6/02/2022
@ This method will fetch all the added caseUnits
*/
    public static List<Case_unit__c> getCaseUnits(String caseId){
        return [SELECT Id,Unit__c FROM Case_Unit__c WHERE Case__c =: caseId];
    }
    /*
@Author : Swapnil Mohite
@CreatedDate: 6/02/2022
@ This method will fetch all the added caseUnits
*/
    public static Case getCaseRecord(String caseId){
        Case caseRec = [SELECT id,accountId,Type,deal__c
                        FROM Case 
                        WHERE Id =: caseId];
        return caseRec;
    }
    /*
@Author : Swapnil Mohite
@CreatedDate: 6/02/2022
@ This method add selected records
*/
    @AuraEnabled 
    public static void createCaseUnitRecord(List<PropWrapper> propertyList,String caseId,integer noOfCheques,integer noOfMonths,String renewalType,String CaseType){
        List<Case_Unit__c> caseUnitList = new List<Case_Unit__c>();
        
        for(PropWrapper prop : propertyList){
            system.debug('prop>>'+prop);
            Case_unit__c caseUnit = new Case_unit__c();
            //caseUnit.Name = prop.unit__r.name;
            caseUnit.Unit__c = prop.unitId;
            caseUnit.Case__c = caseId;
            caseUnit.Type__c='Existing';
            caseUnitList.add(caseUnit);
        }
        system.debug('caseUnitList>>>'+caseUnitList);
        insert caseUnitList;
        if(propertyList.size() > 0){
             Opportunity opp=[select id,Final_Lease_Amount__c,Base_Lease_Amount__c, (Select id,Installment_Type__c,Amount__c from OnlinePayments__r where Installment_Type__c='Deposit' Limit 1 ) from Opportunity where id =: propertyList[0].dealId Limit 1 ];
            
            if(caseUnitList.size()==1){
                Receipt__c r=[Select id,Installment_Type__c,Amount__c,Opportunity__c from Receipt__c where Installment_Type__c='Deposit' and Opportunity__c =: propertyList[0].dealId  Limit 1];
                if(CaseType=='Unit Change'){
                  update new Case(id=caseId,Deal__c=propertyList[0].dealId,Lease_Start_Date__c=propertyList[0].startDate,Lease_End_Date__c=propertyList[0].endDate/*,Security_Deposit__c=r.Amount__c*/,Lease_Amount__c=opp.Final_Lease_Amount__c,Renewal_Type__c=renewalType,noOfMonths__c=noOfMonths,Number_of_cheques__c=noOfCheques,Status='New');
                
                }
                else if(CaseType=='Renewal'){
                    Date tempdate=propertyList[0].endDate;
                  update new Case(id=caseId,Deal__c=propertyList[0].dealId,Lease_Start_Date__c=propertyList[0].startDate,Lease_End_Date__c=propertyList[0].endDate/*,Security_Deposit__c=r.Amount__c*/,Lease_Amount__c=opp.Final_Lease_Amount__c,Renewal_Type__c=renewalType,noOfMonths__c=noOfMonths,Number_of_cheques__c=noOfCheques,Status='New',Lease_renewal_date__c=tempdate.addDays(1));
                  
                }
                else{
                    update new Case(id=caseId,Deal__c=propertyList[0].dealId,Lease_Start_Date__c=propertyList[0].startDate,Lease_End_Date__c=propertyList[0].endDate,Security_Deposit__c=r.Amount__c,Lease_Amount__c=opp.Final_Lease_Amount__c,Renewal_Type__c=renewalType,noOfMonths__c=noOfMonths,Number_of_cheques__c=noOfCheques);
               
                }
              
            }
            else{
                if(CaseType=='Unit Change' ){
                  update new Case(id=caseId,Deal__c=propertyList[0].dealId,Lease_Start_Date__c=propertyList[0].startDate,Lease_End_Date__c=propertyList[0].endDate/*,Security_Deposit__c=r.Amount__c*/,Lease_Amount__c=opp.Final_Lease_Amount__c,Renewal_Type__c=renewalType,noOfMonths__c=noOfMonths,Number_of_cheques__c=noOfCheques,Status='In Progress');
                
                }
                else if(CaseType=='Renewal'){
                    Date tempdate=propertyList[0].endDate;
                  update new Case(id=caseId,Deal__c=propertyList[0].dealId,Lease_Start_Date__c=propertyList[0].startDate,Lease_End_Date__c=propertyList[0].endDate/*,Security_Deposit__c=r.Amount__c*/,Lease_Amount__c=opp.Final_Lease_Amount__c,Renewal_Type__c=renewalType,noOfMonths__c=noOfMonths,Number_of_cheques__c=noOfCheques,Status='New',Lease_renewal_date__c=tempdate.addDays(1));
                  
                }
                else{
                    update new Case(id=caseId,Deal__c=propertyList[0].dealId,Lease_Start_Date__c=propertyList[0].startDate,Lease_End_Date__c=propertyList[0].endDate/*,Security_Deposit__c=r.Amount__c*/,Lease_Amount__c=opp.Final_Lease_Amount__c,Renewal_Type__c=renewalType,noOfMonths__c=noOfMonths,Number_of_cheques__c=noOfCheques);
              
                }
                
            }
                     
            
        }
    }
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class ResultWrapper{
        @AuraEnabled
        public List<PropWrapper> propertyList{get;set;}
        //public List<Property__c> propertyList{get;set;}
        @AuraEnabled
        public Boolean isError{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public Map<String,String> oppMap{get;set;}
        @AuraEnabled
        public String caseType{get;set;}
        /*@AuraEnabled
        public List<Property__c> flaggedPropertyList{get;set;}*/
        
        
        
    }
    
    public class PropWrapper{
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
    }

    /*
    @Author : Ashok Kumar Nayak
    @CreatedDate: 25/03/2022
    @ This method will get all the valid Units to be added for a case into the Case Unit object
    */
    @AuraEnabled(cacheable=true) 
    public static List<Unit__c> getUnitsForTitleDeed(String caseId){
        system.debug('CaseId'+caseId); 
        //system.debug('Case Account Id'+caseAccountId);
        Case caseRec = getCaseRecord(caseId);
        Set<Id> unitCaseIdSet = new Set<Id>();
        Set<Id> unitIdSet = new Set<Id>();
        List<Case_Unit__c> caseUnitList = getCaseUnits(caseId);
        for(Case_unit__c caseUnit : caseUnitList){
            unitCaseIdSet.add(caseUnit.Unit__c);
        }
        
        for(Property__c property : [SELECT unit__c from Property__c WHERE Account__c =:caseRec.accountId AND Active__c = true and Unit__c NOT IN : unitCaseIdSet]){
            unitIdSet.add(property.unit__c);
        }

        return [SELECT Id,Name from Unit__c WHERE Id IN :unitIdSet];
    }

    /*
    @Author : Ashok Kumar Nayak
    @CreatedDate: 25/03/2022
    @ This method will create case units for the case and selected units
    */
    @AuraEnabled
    public static String createCaseUnitsForTitleDeed(String caseId,List<String> unitList){
        String returnString;
        List<Case_Unit__c> caseUnitList = new List<Case_Unit__c>();
        Id recordTypeId = Schema.SObjectType.Case_unit__c.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        for(String UnitId : unitList){
            Case_unit__c caseUnit = new Case_unit__c();
            caseUnit.Unit__c = Id.valueOf(UnitId);
            caseUnit.Case__c = Id.valueOf(caseId);
            caseUnit.Type__c='Existing';
            caseUnit.recordTypeId = recordTypeId;
            caseUnitList.add(caseUnit);
        }

        try{
            if(caseUnitList.size() > 0) {
                insert caseUnitList;
                returnString = 'SUCCESS';
            }
            else{
                returnString = 'Empty List can not be inserted';
            }
        }
        catch(DMLException ex) {
            returnString = ex.getMessage();
        }
        
        return returnString;
    }
}