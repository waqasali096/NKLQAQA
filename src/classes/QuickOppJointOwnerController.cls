/*
* @author : Ashams
* @Module : Quick Booking
* @usage : used in Quick Booking Joint Owner Component, used in post sales joint owner changes
*/
public class QuickOppJointOwnerController {
    /*
	* @author : Ashams
	* @usage : get accounts based on search
	*/
    @AuraEnabled  
    public static List<Account> searchAccounts(string accName,string accNum,string accEmail,string accMob,
                                               string accEID,string accTDN,boolean isPerson,string recordId){
        string query ='';
        String recordType = '';
        set<Id> accIds = new set<Id>();
        string userinfo = UserInfo.getUserId();                                         
        system.debug('recordId'+recordId);
        
        if(string.isNotBlank(recordId)){
            String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            if(sObjName == 'Case'){
                recordId = [SELECT Deal__c from Case WHERE Id =:recordId]?.Deal__c;
            }
        }
        
        try{
            if(isPerson == true){
                recordType = 'PersonAccount';
            }else{
                recordType = 'Business_RecordType';
            }            
            query = 'select Id,Name,Trade_License_Number__c,AccountNumber, toLabel(Nationality__c),Relationship_with_Owner__c,'+
                'Primary_Email__c,Primary_Mobile__c,Primary_Country_Code__c,Emirates_Ids__c,toLabel(Country_Of_Residence__c),Passport_Number__c,'+
                'Visa_Number__c,Country__c from Account where';
            
            if(string.isNotBlank(accName)){
                String tempInput ='\'%' + accName  + '%\'';
                query = query + ' name like ' + tempInput +' AND '; 
            }
            if(string.isNotBlank(accNum)){
                String tempInput ='\'%' + accNum  + '%\'';
                query = query + ' AccountNumber like ' + tempInput +' AND '; 
            }
            if(string.isNotBlank(accEmail)){
                String tempInput ='\'%' + accEmail  + '%\'';
                query = query + ' Primary_Email__c like ' + tempInput +' AND '; 
            }
            if(string.isNotBlank(accMob)){
                String tempInput ='\'%' + accMob  + '%\'';
                query = query + ' Primary_Mobile__c like ' + tempInput +' AND '; 
            }
            if(string.isNotBlank(accEID)){
                String tempInput ='\'%' + accEID  + '%\'';
                query = query + ' Emirates_Ids__c like ' + tempInput +' AND '; 
            }
            if(string.isNotBlank(accTDN)){
                String tempInput ='\'%' + accTDN  + '%\'';
                query = query + ' Trade_License_Number__c like ' + tempInput +' AND '; 
            }
            if(string.isNotBlank(recordType)){
                query = query + ' RecordType.DeveloperName =:recordType' ;  
            }        
            query = query + ' and CreatedById =: userinfo' + ' order by Name asc';
            system.debug('%%query'+query);
            List<Account> accList = Database.query(query);
            system.debug('%%accList'+accList.size());
            return accList;  
        }catch(exception ex){  
            system.debug('FetchAccount ErrMsg is '+ ex.getMessage() + ' at line number '+ ex.getLineNumber());
            return null;
        }
    }
    /*
	* @author : Ashams
	* @usage : get existing joint owners from the opp/case
	*/
    @AuraEnabled  
    public static ResultWrapper getJointOwners(string recordId){
        ResultWrapper wrap = new ResultWrapper();
        List<joint_buyer__c> jointOwnerList = new List<joint_buyer__c>();
        try{
            if(recordId!=null){
                String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
                if(sObjName == 'Case'){
                    recordId = [SELECT Deal__c from Case WHERE Id =:recordId]?.Deal__c;
                }
                jointOwnerList = [select id,name__c,opportunity__c,Primary_Account__c, Primary_Account__r.Name,First_Name__c,Last_Name__c,
                                  Relationship_with_Owner__c,Unit__c,Email__c,Mobile__c,Share_Percentage__c,Secondary_Account__c
                                  from joint_buyer__c where opportunity__c=:recordId];            
            }
            system.debug('jointOwnerList'+jointOwnerList);
            if(jointOwnerList.size()>0){
                wrap.jointOwnersList = jointOwnerList;
                wrap.isError = FALSE;
                wrap.joCount = jointOwnerList.size();
            }else{
                wrap.jointOwnersList = null;
                wrap.isError = TRUE;
                wrap.joCount = 0; 
            } 
        }catch(Exception e){
            wrap.jointOwnersList = null;
            wrap.joCount = 0;
            system.debug('Error in jb fetch'+e.getMessage());
            wrap.isError = TRUE;
            wrap.respMsg = e.getMessage();
            return wrap;
        }
        system.debug('wrap'+wrap);
        return wrap;
    }
    /*
	* @author : Ashams
	* @usage : remove joint owners from table
	*/
    @AuraEnabled  
    public static ResultWrapper removeJointOwners(List<Joint_Buyer__c> joList, string recordId){
        List<Joint_Buyer__c> jointOwnList = new List<Joint_Buyer__c>();
        Set<Id> UnitsIds = new Set<Id>();
        Opportunity Opp;
        List<Opportunity> newOppList = new List<Opportunity>();
        
        if(joList.size()>0 && string.isNotBlank(recordId)){
            jointOwnList = [Select Id from Joint_Buyer__c where ID IN:joList and Opportunity__c =:recordId];
        }
        try{
            if(jointOwnList.size()>0){
                delete jointOwnList ;
            } 
        }catch(Exception e){
            system.debug('Exception'+e);
        }
        ResultWrapper wrap1 = getJointOwners(recordId);
        system.debug('wrap'+wrap1);
        return wrap1;
    }
    /*
	* @author : Ashams
	* @usage : create joint owners for selected Accounts
	*/
    @AuraEnabled  
    public static ResultWrapper createJointOwners(List<Account> accList, string recordId){
        ResultWrapper wrap = new ResultWrapper();
        List<Joint_Buyer__c> jointBuyers = new List<Joint_Buyer__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        Id caseRecId;
        String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        if(sObjName == 'Case'){
            caseRecId = recordId;
            recordId = [SELECT Deal__c from Case WHERE Id =:recordId]?.Deal__c;
        }
        
        Opportunity Opp = [select Id,AccountId,Account.name,Account.FirstName,Account.LastName,Account.Customer_Nationality__c,Unit__c,
                           Account.Primary_Email__c from Opportunity where Id =:recordId];
        if(Opp!=null){
            //creating Joint Owner for the Case : Begin
            if(sObjName == 'Case'){
                Joint_Buyer__c jbforCaseAndOpp =new Joint_Buyer__c();
                jbforCaseAndOpp.First_Name__c =  accList[0].FirstName;
                jbforCaseAndOpp.Last_Name__c = accList[0].LastName;
                jbforCaseAndOpp.Unit__c = Opp.Unit__c; 
                jbforCaseAndOpp.Primary_Account__c = Opp.AccountId;
                jbforCaseAndOpp.Opportunity__c = Opp.Id;
                jbforCaseAndOpp.Case__c = caseRecId;
                jbforCaseAndOpp.Email__c = accList[0].Primary_Email__c;
                jbforCaseAndOpp.Mobile__c = accList[0].Primary_Mobile__c;
                jbforCaseAndOpp.Secondary_Account__c = accList[0].Id;
                jbforCaseAndOpp.Relationship_with_Owner__c = accList[0].Relationship_with_Owner__c;
                jbforCaseAndOpp.Share_Percentage__c = accList[0].Percentage__c;
                jointBuyers.add(jbforCaseAndOpp);
            }
            else{
                oppList.add(Opp);
            }
            //creating Joint Owner for the Case : End
        }
        
        if(oppList.size()>0){
            for(Opportunity Op:oppList){
                Joint_Buyer__c jb =new Joint_Buyer__c();
                jb.First_Name__c =  accList[0].FirstName;
                jb.Last_Name__c = accList[0].LastName;
                jb.Unit__c = Op.Unit__c; 
                jb.Primary_Account__c = Opp.AccountId;
                jb.Opportunity__c = Op.Id;
                jb.Email__c = accList[0].Primary_Email__c;
                jb.Mobile__c = accList[0].Primary_Mobile__c;
                jb.Secondary_Account__c = accList[0].Id;
                jb.Relationship_with_Owner__c = accList[0].Relationship_with_Owner__c;
                jb.Share_Percentage__c = accList[0].Percentage__c;
                jointBuyers.add(jb);
            }
        }
        try{
            if(jointBuyers.size()>0){
                insert jointBuyers;
                wrap.jointOwnersList = jointBuyers;
                wrap.isError = FALSE;
            } 
        }catch (DmlException e) {
            wrap.jointOwnersList = null;
            wrap.isError = TRUE;
            wrap.respMsg = e.getDmlMessage(0);
            return wrap;
        }catch(Exception e){
            wrap.jointOwnersList = null;
            system.debug('Error in jb Insert'+e.getMessage());
            wrap.isError = TRUE;
            wrap.respMsg = e.getMessage();
            return wrap;
        }
        return wrap;
    }     

	/*
	* @author : Ashams
	* @usage : create new Account & realted joint owner
	*/
    @AuraEnabled
    public static ResultWrapper createAccounts(Account accounts,Address__c primaryAddress,Address__c secAddress,string recordId, string recordType){
        system.debug('accounts'+accounts);
        Account customer = new Account();
        Address__c primaryAddr = new Address__c();
        Address__c secAddr = new Address__c();
        Account duplicateAccount;
        List<Address__c> addressList = new List<Address__c>();
        List<Joint_Buyer__c> jbList = new List<Joint_Buyer__c>();
        ResultWrapper accWrap = new ResultWrapper();
        Opportunity ParentOpp = [Select Id,AccountId,Account.FirstName,Account.LastName,unit__c,Account.Primary_Email__c from Opportunity where Id =:recordId];
        
        if(accounts!=null){
            customer.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            customer.Arabic_Name__c = accounts.Arabic_Name__c;
            customer.Primary_Country_Code__c = accounts.Primary_Country_Code__c;
            customer.Primary_Mobile__c = accounts.Primary_Mobile__c;
            customer.Primary_Email__c = accounts.Primary_Email__c;
            customer.Relationship_with_Owner__c = accounts.Relationship_with_Owner__c;
            customer.Percentage__c = accounts.Percentage__c;
            if(recordType == 'PersonAccount'){
                customer.FirstName = accounts.FirstName;
                customer.LastName = accounts.LastName; 
                customer.Emirates_Ids__c = accounts.Emirates_Ids__c;
                customer.Nationality__c = accounts.Nationality__c;
                customer.Country_Of_Residence__c = accounts.Country_Of_Residence__c;
                customer.Passport_Number__c = accounts.Passport_Number__c;
                customer.Passport_Issue_Date__c = accounts.Passport_Issue_Date__c;
                customer.Passport_Expiry_Date__c = accounts.Passport_Expiry_Date__c;
                customer.Passport_Issue_Place__c = accounts.Passport_Issue_Place__c;
                customer.Visa_End_Date__c = accounts.Visa_End_Date__c;
                customer.Visa_Start_Date__c = accounts.Visa_Start_Date__c;
                customer.Visa_Number__c = accounts.Visa_Number__c;
                duplicateAccount = NakheelUtility_Ctrl.findMatchingAccount(customer, 'Person');
            }else if(recordType == 'Business_RecordType'){
                customer.Name = accounts.name; 
                customer.Trade_License_Number__c = accounts.Trade_License_Number__c; 
                duplicateAccount = NakheelUtility_Ctrl.findMatchingAccount(customer, 'Business');
            }
        }
        
        try{
            system.debug('duplicateAccount'+duplicateAccount);
            system.debug('customer'+customer);
            if(duplicateAccount!=null){
                customer.Id =  duplicateAccount.Id;
                update customer;
                if(primaryAddress!=null){
                    primaryAddress.Account__c = duplicateAccount.Id;
                    primaryAddress.primary__c = true;
                    insert primaryAddress;
                }
                if(secAddress!=null && (secAddress.City__c != null || secAddress.Postal_Code__c != null || secAddress.Street_Name__c != null || secAddress.House_Apartment_No__c != null || secAddress.Country_New__c != '')){
                    secAddress.Account__c = duplicateAccount.Id;
                    insert secAddress;
                }
            }else{
                insert customer; 
                if(primaryAddress!=null){
                    primaryAddress.Account__c = customer.Id;
                    primaryAddress.primary__c = true;
                    insert primaryAddress;
                }
                if(secAddress!=null && (secAddress.City__c != null || secAddress.Postal_Code__c != null || secAddress.Street_Name__c != null || secAddress.House_Apartment_No__c != null || secAddress.Country_New__c != '')){
                    secAddress.Account__c = customer.Id;
                    insert secAddress;
                }
            }            
            if(ParentOpp!=null){
                joint_Buyer__c jb =new Joint_Buyer__c();
                system.debug('jb'+jb);
                jb.First_Name__c = customer.FirstName;
                jb.Last_Name__c = customer.LastName;
                jb.Unit__c = ParentOpp.Unit__c; 
                jb.Primary_Account__c = ParentOpp.AccountId;
                jb.Secondary_Account__c = customer.Id;
                jb.Opportunity__c = ParentOpp.Id;
                jb.Email__c = customer.Primary_Email__c;
                jb.Mobile__c = customer.Primary_Mobile__c;
                jb.Relationship_with_Owner__c = customer.Relationship_with_Owner__c;
                jb.Share_Percentage__c = customer.Percentage__c;
                jbList.add(jb);
            }
            if(!jbList.isEmpty()){
                insert jbList;
            }
            accWrap = getAccountDetails(recordId);
        }catch (DmlException e) {
            system.debug('error==  + ' + e);
            accWrap.accExist = FALSE;
            accWrap.accId = null;
            accWrap.respMsg = e.getDmlMessage(0);
            accWrap.isSucess = false;
        }catch(Exception ex){
            system.debug('error==  + ' + ex);
            accWrap.accExist = FALSE;
            accWrap.accId = null;
            accWrap.respMsg = ex.getMessage();
            accWrap.isSucess = false;
        }
        return accWrap;
    }
    
    /*
	* @author : Ashams
	* @usage : Get Account & joint owner details from opp
	*/
    @AuraEnabled
    public static ResultWrapper getAccountDetails(string OppId){
        Opportunity parentOpp = new Opportunity();
        ResultWrapper accWrap = new ResultWrapper();
        if(string.isNotBlank(OppId)){
            parentOpp = [SELECT Id,RecordTypeId,RecordType.Developername,Name,AccountId,
                           (Select Id,Name__c,First_Name__c,Last_Name__c,Unit__c,Primary_Account__c,Opportunity__c,Email__c,Mobile__c,
                            Secondary_Account__c,Relationship_with_Owner__c,Share_Percentage__c from Joint_Buyers__r)
                           FROM Opportunity WHERE ID =: OppId];
        }
        system.debug('&&parentOpp'+parentOpp);
        if(parentOpp!=null){
            accWrap.accId = parentOpp.AccountId;
            if(parentOpp.AccountId != null){
                accWrap.accExist = TRUE;
            }
            if(parentOpp.Joint_Buyers__r.size()>0){
               accWrap.jointOwnersList = parentOpp.Joint_Buyers__r;
            }
            accWrap.respMsg = 'Success';
            accWrap.isSucess = TRUE;
        }
        system.debug('&&accWrap'+accWrap);
        return accWrap;
    }
    
    /*
	* @author : Ashams
	* @usage : Get relationship picklist values
	*/
    @AuraEnabled
    public static Map<String, String> getRelationshipValues(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Account.Relationship_with_Owner__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        system.debug('relation values are '+ options);
        return options;
    }
    
	/*
	* @author : Ashams
	* @usage : Get country picklist values
	*/    
    @AuraEnabled
    public static Map<String, String> getCountryValues(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Address__c.Country_New__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        system.debug('options are '+ options);
        return options;
    }
    
    @AuraEnabled
    public static Map<String, String> getResidenceCountryValues(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Account.Country_Of_Residence__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        system.debug('options are '+ options);
        return options;
    }
    
    @AuraEnabled
    public static Map<String, String> getNationalityValues(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Account.Nationality__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        system.debug('options are '+ options);
        return options;
    }
    
    /*
	* @author : Ashams
	* @usage : check if account exists for Opp/case
	*/ 
    @AuraEnabled
    public static Boolean checksAccountAndUnit(Id oppId){
       System.debug('@@@ '+ oppId);
       Boolean returnBoolean = false;
		if(oppId!=null){
            //Opportunity checkAccForOpp = [Select Id,AccountId,Account.RecordType.DeveloperName, [] from Opportunity where Id=:recordId LIMIT 1];
            String sObjName = oppId.getSObjectType().getDescribe().getName();
            if(sObjName == 'Opportunity') {
                Opportunity checkAccForOpp = [Select Id, AccountId from Opportunity where Id=:oppId LIMIT 1];
                if(checkAccForOpp.AccountId != Null){
                    returnBoolean = true;
                }else{
                    returnBoolean = false;
                }
            }
            if(sObjName == 'Case') {
                List<Case> caseList = [SELECT Id from Case WHERE AccountId <> NULL AND Unit__c <> NULL AND Id =: oppId];
                if(caseList.size() > 0) {
                    returnBoolean = true;
                } else{
                    returnBoolean = false;
                }
            }
            return returnBoolean;
        }else{
            return null;
        }
    }
    
    public class ResultWrapper{
        @AuraEnabled public String accId; 
        @AuraEnabled public Decimal joCount; 
        @AuraEnabled public Boolean isError;
        @AuraEnabled public String respMsg;
        @AuraEnabled public Boolean accExist;
        @AuraEnabled public Boolean isSucess;
        @AuraEnabled public List<Address__c> addressList;
        @AuraEnabled public List<Joint_Buyer__c> jointOwnersList;
    }
}