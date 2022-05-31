public class TerminationServiceRequestController {
    @AuraEnabled
    public static string getRecordTypeId(){
        try {
            String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Termination').getRecordTypeId();
            return recordTypeId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Opportunity getOpportunityDetail(String recordId){
        try {
            Opportunity oppty = [SELECT accountId,Lease_Start_Date__c, Lease_End_Date__c
                                     FROM Opportunity WHERE Id=: recordId];
            return oppty;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String updateRecordType(String recordId, String recordTypeId){
        String singleUnit = '';
        try {
            Case caseRecord = [SELECT Id, RecordType.Name, RecordTypeId, Deal__c, 
                                Deal__r.Lease_Start_Date__c, Deal__r.Lease_End_Date__c  FROM Case WHERE Id =: recordId];
            if(caseRecord.RecordType.Name != 'Termination'){
                Case cse = new Case();
                cse.Id = recordId;
                cse.RecordTypeId = recordTypeId;
                cse.Lease_Start_Date__c = caseRecord.Deal__r.Lease_Start_Date__c;
                cse.Lease_End_Date__c = caseRecord.Deal__r.Lease_End_Date__c;
                cse.Status = 'In Progress';
                update cse;
                GenericTriggerHandler.createDocRecord(new List<Case>{cse},'Case');
                deleteCaseUnits(caseRecord);
            }else{
                Case cse = new Case();
                cse.Id = recordId;
                cse.Lease_Start_Date__c = caseRecord.Deal__r.Lease_Start_Date__c;
                cse.Lease_End_Date__c = caseRecord.Deal__r.Lease_End_Date__c;
                cse.OwnerId = userInfo.getUserId();
                cse.Status = 'In Progress';
                update cse;
            }
            singleUnit = insertCaseUnits(caseRecord);
            return singleUnit;
        } catch (Exception e) {
           // throw new AuraHandledException(e.getMessage());
            return singleUnit;
        }
    }

    @AuraEnabled
    public static string updateTerminationSubject(String recordId){
        try {
            String Subject = '';
            List<Unit_Plan__c> opptyUnits = [SELECT ID, Name, Unit__c, Opportunity__c,Contract__r.Contract_Start_Date__c, 
                                            Unit__r.Unit_Code__c,Opportunity__r.Lease_Start_Date__c,
                                            Opportunity__r.Lease_End_Date__c
                                            FROM Unit_Plan__c WHERE Opportunity__c =: recordId];
            if(opptyUnits.Size() == 1){
                Subject = 'Termination Request for Unit ('+opptyUnits[0].Unit__r.Unit_Code__c+')';
            }else if(opptyUnits.Size() > 1){
                Subject = 'Termination Request for multiple units';
            }
            return Subject;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String insertCaseUnits(Case caseRecord){
        String singleUnit = '';
        try {
            List<Case_Unit__c> caseUnitList = new List<Case_Unit__c>();
            if(caseRecord.Deal__c != null){
                List<Unit_Plan__c> opptyUnits = [SELECT ID, Name, Unit__c, Opportunity__c,Contract__r.Contract_Start_Date__c, 
                                                Unit__r.Unit_Code__c,Opportunity__r.Lease_Start_Date__c,
                                                Opportunity__r.Lease_End_Date__c
                                                FROM Unit_Plan__c WHERE Opportunity__c =: caseRecord.Deal__c];
                if(opptyUnits.size() > 0 && opptyUnits.size() == 1){
                    for(Unit_Plan__c opptyUnit : opptyUnits){
                        Case_Unit__c caseUnit = new Case_Unit__c();
                        caseUnit.Case__c = caseRecord.Id;
                        caseUnit.Unit__c = opptyUnit.Unit__c;
                        caseUnit.Type__c = 'Existing';
                        caseUnitList.add(caseUnit);
                    }
                    if(!caseUnitList.isEmpty()){
                        insert caseUnitList;
                    }
                    singleUnit = 'Yes';
                }else{
                    singleUnit = 'No';
                }                            
                return singleUnit;
            }           
        } catch (Exception e) {
            singleUnit = '';
            throw new AuraHandledException(e.getMessage());
        }
        return singleUnit;
    }

    @AuraEnabled
    public static void deleteCaseUnits(Case caseRecord){
        try {
            List<Case_unit__c> caseUnits = [SELECT Id FROM Case_Unit__c WHERE Case__c =: caseRecord.Id];
            if(caseUnits.size() > 0){
                delete caseUnits;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled  
    public static ResultWrapper getUnits(String recordId){
        Set<Id> unitIdSet = new Set<Id>();
        Map<String,String> oppMap = new Map<String,String>();
        ResultWrapper resultWrapper = new ResultWrapper();
        List<OpptyUnitWrapper> listOpptyUnitWrapper=new List<OpptyUnitWrapper>();
        
        List<Property__c> flagPropList=new List<Property__c>();
        if(recordId != null){
            List<Unit_Plan__c> opptyUnits = [SELECT ID, Name, Unit__c, Opportunity__c,Contract__r.Contract_Start_Date__c, 
                                            Unit__r.Unit_Code__c,Opportunity__r.Lease_Start_Date__c, unit__r.Name,
                                            Opportunity__r.Lease_End_Date__c
                                            FROM Unit_Plan__c WHERE Opportunity__c =: recordId AND Is_Terminated__c = false];
        
        
        
            for(Unit_Plan__c opptyUnit : opptyUnits){
                unitIdSet.add(opptyUnit.unit__c);
            }
             List<Flag__c> listFlag=[select Id,  Name,  Dimension__c, Flag_Type__c, Active__c, Customer__c, Start_Date__c, End_Date__c, Error_Value__c, Description__c, ERP_ID__c, Master_Flag__c,
                                Formula_Description__c, Formula_Dimension__c, Formula_Flag_Type__c, Unit__c, Unit_Master_Flag__c from Flag__c where Unit__c in: unitIdSet and Active__c= true ];
        
            for(Unit_Plan__c opptyUnit : opptyUnits){
                OpptyUnitWrapper opptyUnitWrap = new OpptyUnitWrapper();
                opptyUnitWrap.unitId = opptyUnit.Unit__c;
                opptyUnitWrap.unitName = opptyUnit.unit__r.Name;
                opptyUnitWrap.startDate = opptyUnit.Opportunity__r.Lease_Start_Date__c;
                opptyUnitWrap.endDate = opptyUnit.Opportunity__r.Lease_End_Date__c;
                opptyUnitWrap.propFlag = false;    
                for(Flag__c f:listFlag){
                    if(opptyUnit.Unit__c==f.Unit__c){
                        opptyUnitWrap.propFlag=true;
                    }
                }
                listOpptyUnitWrapper.add(opptyUnitWrap);
            }
                resultWrapper.isError = false;
                resultWrapper.opptyUnitWrapperList =listOpptyUnitWrapper;
            }
        return resultWrapper;
    }

    @AuraEnabled 
    public static void createCaseUnitRecord(List<OpptyUnitWrapper> opptyUnitWrapperList, String caseId){
        List<Case_Unit__c> caseUnitList = new List<Case_Unit__c>();
        
        for(OpptyUnitWrapper opptyUnitWrap : opptyUnitWrapperList){
            system.debug('@@opptyUnitWrap :'+opptyUnitWrap);
            Case_Unit__c caseUnit = new Case_Unit__c();
            caseUnit.Unit__c = opptyUnitWrap.unitId;
            caseUnit.Case__c = caseId;
            caseUnit.Type__c='Existing';
            caseUnitList.add(caseUnit);
        }
        system.debug('caseUnitList>>>'+caseUnitList);
        insert caseUnitList;
        
    }

    public class OpptyUnitWrapper{
        @AuraEnabled
        public String unitId{get;set;} 
        @AuraEnabled
        public String unitName{get;set;} 
        @AuraEnabled
        public Date startDate{get;set;} 
        @AuraEnabled
        public Date endDate{get;set;} 
        @AuraEnabled
        public Boolean propFlag{get;set;} 
    }

    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class ResultWrapper{
        @AuraEnabled
        public List<OpptyUnitWrapper> opptyUnitWrapperList{get;set;}
        @AuraEnabled
        public Boolean isError{get;set;}
        @AuraEnabled
        public String message{get;set;}
    }

}