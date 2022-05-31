/**
* @author Mamta Gupta
* @date 02/08/2021
* @purpose - Parent class of AgencyRegistrationFormHelperCtrl
* @usage -AgencyRegistrationForm Aura Bundle
*/

public without sharing class AgencyRegistrationFormController { 
    
    public static Map<Id, String> recordtypemap {get;set;}
   
    /* @param - recordId (Broker ID)
    * @return - (Broker Agency Details)*/
    public static Broker__c getBrokerDetails(string recordId){
       return  AgencyRegistrationFormHelperCtrl.getBrokerDetails(recordId);
    }
    
    /* @param - recordId (Broker ID)
    * @return - (Broker Proprietor Details)*/
    public static list<Broker_Proprietor__c> getbrokerpropDetails(string recordId){
        return AgencyRegistrationFormHelperCtrl.getbrokerpropDetails(recordId);
    }
    
    /* @param - recordId (Broker ID)
    *           recordTypeName(record type of Agent)
    * @return - Broker Agent Details*/
    public static list<Broker_Agents__c> getbrokerAgentAuthDetails(string recordId, string recordTypeName){
        return AgencyRegistrationFormHelperCtrl.getbrokerAgentAuthDetails(recordId,recordTypeName);
    }
    
    
    /* @param - recordId (Broker ID)
    *           recordTypeName(record type of Agent)
    * @return - Broker Agent Details*/
    public static list<Broker_Agents__c> getbrokerAdditionalContactDetails(string recordId, string recordTypeName){
        return AgencyRegistrationFormHelperCtrl.getbrokerAdditionalContactDetails(recordId,recordTypeName);
    }
    
      @AuraEnabled
    public static void deletePreviousDocuments(String country, String Emirates,String agencyID){
    AgencyRegistrationFormHelperCtrl.deletePreviousDocuments(country,Emirates,agencyID);  
    }
    
    @AuraEnabled
    public static void deleteBrokerPartners(List<Broker_Proprietor__c> bokerPartnerLst){
        system.debug('inside delete com');
     AgencyRegistrationFormHelperCtrl.deleteBrokerPartners(bokerPartnerLst);  
    }
    
    @AuraEnabled
    public static void deleteBrokerAgents(List<Broker_Agents__c> bokerAgentLst){
      AgencyRegistrationFormHelperCtrl.deleteBrokerAgents(bokerAgentLst); 
    }
    
    @AuraEnabled
    public static boolean checkIfAllBrokerFilesUploaded(String agencyRecordId){
      return AgencyRegistrationFormHelperCtrl.checkIfAllBrokerFilesUploaded(agencyRecordId);
    }
    
    
    /* @param - recordId (Broker ID)
    * @return - Broker and its related record Details*/
    @AuraEnabled        
    public static DataWrapper getBrokerRegistrationDetails(string recordId){
        DataWrapper wrapper = new DataWrapper();
        wrapper.broker = getBrokerDetails(recordId);
        wrapper.brokerprop  = getbrokerpropDetails(recordId);
        wrapper.brokerAgentAuth = getbrokerAgentAuthDetails(recordId, 'Authorized_Signatory');
        wrapper.brokerAgentRepresentativeList = getbrokerAgentAuthDetails(recordId, 'Agent_Representative');
        wrapper.brokerAgentContactsList = getbrokerAdditionalContactDetails(recordId, 'Agent_Representative');

        return wrapper;
    }
    
    @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Broker__c.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master'  && rt.getName() != 'Company' && rt.getName() != 'Individual' ){
                recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }
        }        
        return recordtypemap.values();
    }
    
    /* @param - recordTypeLabel (record type name)
    * @return - RecordType ID of specfic record type name for broker*/

    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    } 
    
    
    /* @param - AgencyDetails (Broker details captured from AgencyRegistrationForm Aura Bundle)
    * @return - return created record of broker*/

    @AuraEnabled
    public static Broker__c createAgencyRegistrationRecord (Broker__c AgencyDetails,Boolean saveAsDraft) {
        return  AgencyRegistrationFormHelperCtrl.createAgencyRegistrationRecord(AgencyDetails,saveAsDraft);
    }
    
     @AuraEnabled
    public static Account updateAccount (Account account) {
        return AgencyRegistrationFormHelperCtrl.updateAccount(account);    
    }
    
    /* @param - agencyRecordId- Broker ID
                brokerProprietorsList-  List of Broker Proprietors 
    * @return - return created records of Broker Proprietors */

    @AuraEnabled
    public static List<Broker_Proprietor__c> createBrokerProprietorsRecord (string agencyRecordId, List<Broker_Proprietor__c> brokerProprietorsList) {
    List<Broker_Proprietor__c> brokerPropertiors=   AgencyRegistrationFormHelperCtrl.createBrokerProprietorsRecord(agencyRecordId,brokerProprietorsList);
    return brokerPropertiors;    
    }
    
   /* public static list<BrokerDataWrapper> createBrokerProprietorsRecord (string agencyRecordId, List<Broker_Proprietor__c> brokerProprietorsList) {
            system.debug('brokerProprietorsList' + brokerProprietorsList);
            //upsert brokerProprietorsList;
            list<BrokerDataWrapper> wrpLst = new list<BrokerDataWrapper> (); //AgencyRegistrationFormHelperCtrl.createBrokerProprietorsRecord(agencyRecordId,brokerProprietorsList);
            return wrpLst;
        }*/
    
    
   /* @param - agencyRecordId- Broker ID
                brokerAgentAuthList-  List of Broker Agents  of record type Authorized_Signatory
    * @return - return created records of Broker Agents */
    @AuraEnabled
    public static List<Broker_Agents__c> createBrokerAgentsAuthorisedSignatoryRecord (string agencyRecordId, List<Broker_Agents__c> brokerAgentAuthList) {
     brokerAgentAuthList= AgencyRegistrationFormHelperCtrl.createBrokerAgentsAuthorisedSignatoryRecord(agencyRecordId,brokerAgentAuthList); 
     return brokerAgentAuthList;   
    }
    
    
    /* @param - agencyRecordId- Broker ID
                brokerAgentAuthList-  List of Broker Agents of record type Agent_Representative
    * @return - return created records of Broker Agents */
    @AuraEnabled
    public static List<Broker_Agents__c> createBrokerAgentsRepresentativeRecord (string agencyRecordId, List<Broker_Agents__c> brokerAgentRepresentativeList) {
       system.debug('brokerAgentRepresentativeList' + brokerAgentRepresentativeList);
       brokerAgentRepresentativeList= AgencyRegistrationFormHelperCtrl.createBrokerAgentsRepresentativeRecord(agencyRecordId,brokerAgentRepresentativeList);
       return brokerAgentRepresentativeList;  
    }
    
    
   /* @param - agencyRecordId- Broker ID
                brokerAgentContactsList-  List of Broker Agents of record type Agent_Representative with no broker access type
    * @return - return created records of Broker Agents */
    @AuraEnabled
    public static List<Broker_Agents__c> createBrokerAgentsAdditionalContactsRecord (string agencyRecordId, List<Broker_Agents__c> brokerAgentContactsList) {
     brokerAgentContactsList = AgencyRegistrationFormHelperCtrl.createBrokerAgentsAdditionalContactsRecord(agencyRecordId,brokerAgentContactsList);
     return   brokerAgentContactsList; 
    }
    
    
   /* @param - agencyRecordId- Broker ID
                brokerProprietorsList-   Broker Proprietors
                brokerAgentAuthList - List of Broker Agents of record type Agent_Representative
                brokerAgentContactsList - List of Broker Agents of record type Agent_Representative with no broker access type
    * @return - return isSuccess/isError with error detail */
    @AuraEnabled
    public static List<String> createBrokerProprietorsAndAgentsRecord (string agencyRecordId, List<Broker_Proprietor__c> brokerProprietorsList, List<Broker_Agents__c> brokerAgentAuthList, List<Broker_Agents__c> brokerAgentRepresentativeList, List<Broker_Agents__c> brokerAgentContactsList,boolean saveAsDraft){
        system.debug('brokerProprietorsList' + brokerProprietorsList);
        system.debug('brokerAgentAuthList' + brokerAgentAuthList);
        system.debug('brokerAgentRepresentativeList' + brokerAgentRepresentativeList);
        system.debug('brokerAgentContactsList' + brokerAgentContactsList);
        system.debug('User' + userinfo.getLastName());
        List<string> IsSuccessmessage = new List<STring>();
        IsSuccessmessage=AgencyRegistrationFormHelperCtrl.createBrokerProprietorsAndAgentsRecord(agencyRecordId,brokerProprietorsList,brokerAgentAuthList,brokerAgentRepresentativeList,brokerAgentContactsList,saveAsDraft);
        return IsSuccessmessage;
    }
    
    /* @param - recordId- Broker ID
    * @return - return Broker record Detail */
    public static Broker__c getBroker(string recordId){
        return AgencyRegistrationFormHelperCtrl.getBroker(recordId);
    }
    
    //get Agency Type picklist values of Broker
    @AuraEnabled
    public static Map<String, String> getAgencyType(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Broker__c.Agency_Type__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    //get Agency Location picklist values of Broker

    @AuraEnabled
    public static Map<String, String> getAgencyLocation(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Broker__c.Agency_Location__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            
            options.put(p.getValue(), p.getLabel());
        }
        system.debug('options are '+ options);
        return options;
    }
    
    //get Bank Name picklist values for  Broker
    @AuraEnabled
    public static Map<String, String> getBankName(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Broker__c.Bank_Name__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    //get Bank Name Mobile Country code picklist values for  Broker
    @AuraEnabled
    public static Map<String, String> getAgencyCountryCode(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Broker__c.Mobile_Country_Code__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
     
        for (Schema.PicklistEntry p: pList) {
            //if(p.getValue()!='971')
            options.put(p.getValue(), p.getLabel());    
        }

  
        return options;
    }
    
    
    //get Bank Name Mobile Country code picklist values for  Broker

    @AuraEnabled
    public static Map<String, String> getAgencyBankAccountCurrency(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Broker__c.Bank_Currency_of_Account__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    /*@AuraEnabled
    public static Map<String, String> getCountryList(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Broker__c.Country__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }*/
    
    
   //get  Country code picklist values for  Broker
    @AuraEnabled
    public static Map<String, String> getCountryCode(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Broker_Agents__c.Country_Code__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //if(p.getValue()!='971')
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    //get Broker Access picklist values for  Broker
 
    @AuraEnabled
    public static Map<String, String> getBrokerAccessType(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Broker_Agents__c.Broker_Access_Type__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
     @AuraEnabled
    public static Map<String,String> getrecIDDocStatusMap(List<Broker_Proprietor__c> brokerProprietorsList,List<Broker_Agents__c> brokerAgentsList){
     Map<String,String> recIDDocumentStatusMap= AgencyRegistrationFormHelperCtrl.getrecIDDocStatusMap(brokerProprietorsList,brokerAgentsList);
     system.debug('recIDDocumentStatusMap is '+ recIDDocumentStatusMap);   
     return recIDDocumentStatusMap;    
    }
    
    //get Place of incorporation picklist values for  Broker
    @AuraEnabled
    public static Map<String, String> getPlaceOfIncorporation(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Broker__c.Place_of_Incorporation__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    
    //get  emirates picklist values for  Broker
    @AuraEnabled
    public static Map<String, String> getEmirate(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Broker__c.Emirate__c.getDescribe();
        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    //get  agreement status picklist values for  Account
    @AuraEnabled
    public static Map<String, String> getAgreementStatus(){
        return AgencyRegistrationFormHelperCtrl.getAgreementStatus();
    }
    @AuraEnabled
    public static Map<String, String> getNationality(){
        return AgencyRegistrationFormHelperCtrl.getNationalityPicVal();
    }
    //check if duplicate TRN number exists in system 
    @AuraEnabled
    public static Boolean checkDuplicateTRN(String tradeLicenseNumber, Id brokerId){
        system.debug('BrokerrecordId==>'+brokerId);
        return AgencyRegistrationFormHelperCtrl.checkDuplicateTradeLicenseNumber(tradeLicenseNumber.trim(),brokerId);
    }
    
    //check if duplicate Email address exists in system 
    @AuraEnabled
    public static Boolean checkDuplicateEmailAddress(String brokerEmail,Id brokerId){
        system.debug('---Onchange method called---'+brokerEmail);
        return AgencyRegistrationFormHelperCtrl.checkDuplicateEmail(brokerEmail,brokerId);
    }
    
    public class DataWrapper{        
        @AuraEnabled public Broker__c broker {get;set;}
        @AuraEnabled public List<Broker_Proprietor__c> brokerprop {get;set;}
        @AuraEnabled public List<Broker_Agents__c> brokerAgentAuth {get;set;}
        @AuraEnabled public List<Broker_Agents__c> brokerAgentRepresentativeList {get;set;}
        @AuraEnabled public List<Broker_Agents__c> brokerAgentContactsList {get;set;}
        @AuraEnabled public Map<String,String> IDDocSttausMap{get;set;}  

    }
    
    public class BrokerDataWrapper{        
        @AuraEnabled public Broker__c broker {get;set;}
        @AuraEnabled public Broker_Proprietor__c brokerprop {get;set;} 
        @AuraEnabled public Broker_Agents__c brokerAgentAuth {get;set;}
        @AuraEnabled public Broker_Agents__c brokerAgentRepresentativeList {get;set;}
        @AuraEnabled public Broker_Agents__c  brokerAgentContactsList {get;set;}
        @AuraEnabled public String  DocUploadStatus {get;set;}

        
    }
    
   
    
}