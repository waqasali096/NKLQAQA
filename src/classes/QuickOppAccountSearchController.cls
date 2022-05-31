/*
* @author : Ashams
* @Module : Quick Booking
* @usage : used in Quick Booking Customer Details, Broker Details
*/
public without sharing class QuickOppAccountSearchController{
    /*
* @author : Ashams
* @usage : search Accounts based on search filters
*/
    @AuraEnabled  
    public static List<Account> fetchAccounts(string accName,string accNum,string accEmail,string accMob,string accEID,string accTDN,boolean isPerson){
        string query ='';
        String recordType = '';
        string userinfo = UserInfo.getUserId();
        try{
            if(isPerson == true){
                recordType = 'PersonAccount';
            }else{
                recordType = 'Business_RecordType';
            }
            query = 'select Id,Name,Trade_License_Number__c,ERP_Account_Number__c,toLabel(Nationality__c),toLabel(Customer_Nationality__c),'+
                'Relationship_with_Owner__c,Primary_Email__c,Primary_Mobile__c,Primary_Country_Code__c,Emirates_Ids__c,'+
                'toLabel(Country_Of_Residence__c),Passport_Number__c,Visa_Number__c,toLabel(Country__c) from Account where';
            if(string.isNotBlank(accName)){
                String tempInput ='\'%' + accName  + '%\'';
                query = query + ' name like ' + tempInput +' AND '; 
            }
            if(string.isNotBlank(accNum)){
                String tempInput ='\'%' + accNum  + '%\'';
                query = query + ' ERP_Account_Number__c like ' + tempInput +' AND '; 
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
            system.debug('%%AccQuery-'+query);
            List<Account> accList = Database.query(query);
            system.debug('%%aAccList'+accList.size());
            return accList;  
        }catch(exception ex){  
            system.debug('FetchAccount ErrMsg is '+ ex.getMessage() + ' at line number '+ ex.getLineNumber());
            return null;
        }
    }
    
    /*
* @author : Ashams
* @usage : search Broker Accounts based on search filters
*/
    @AuraEnabled  
    public static List<Account> fetchBrokerAccounts(string searchKeyName, string searchKeyTLNNumber , string primaryEmail){
        string query ='';
        
        system.debug('searchKeyName-->'+searchKeyName);
        system.debug('searchKeyTLNNumber-->'+searchKeyTLNNumber);
        system.debug('primaryEmail-->'+primaryEmail);
        
        if((string.isNotBlank(searchKeyName) && searchKeyName != null)|| (string.isNotBlank(searchKeyTLNNumber) && searchKeyTLNNumber != null) || (string.isNotBlank(primaryEmail) && primaryEmail != null)){
            system.debug('in if loop of searchKeyName ');
            
            String tempInput1 ='\'%' + searchKeyName  + '%\'';
            String tempInput2 ='\'%' + searchKeyTLNNumber + '%\'';
            String tempInput3 ='\'%' + primaryEmail+ '%\'';
            
            query = 'select Id,Name,Trade_License_Number__c,Phone,Primary_Mobile__c,Primary_Country_Code__c,Agency_Status__c,Is_Trade_Licence_Expired__c,Trade_License_End_Date__c, Primary_Email__c from Account';
            
            String recordType = 'Broker_Account';
            String terminatedStatus = 'Terminated';
            query = query + ' WHERE RecordType.DeveloperName =:recordType and Agency_Status__c !=:terminatedStatus AND (' ; 
            if(string.isNotBlank(searchKeyName) && searchKeyName != null){
                query = query + '  Name like '+ tempInput1 +' OR ';
            }
            
            if(string.isNotBlank(searchKeyTLNNumber) && searchKeyTLNNumber != null) {
                query = query + '  Trade_License_Number__c like '+ tempInput2 +' OR ';
            }	
            if(string.isNotBlank(primaryEmail) && primaryEmail != null){
                query = query + '  Primary_Email__c like '+ tempInput3 + ' OR ';
            }
            
            query = query.removeEnd(' OR ');
            
            query = query +   ') order by Name asc';
            
        }
        
        system.debug('%%query'+query);
        List<Account> accList = Database.query(query);
        system.debug('%%accList'+accList);
        return accList;  
    }
    
    /*
* @author : Ashams
* @usage : check if customer exists on Opp & returns customer details
*/
    @AuraEnabled  
    public static ResultWrapper checkAccountExists(string recordId){
        ResultWrapper rwrap = new ResultWrapper();
        Opportunity opp;
        Boolean isExist = False;
        List<Address__c> addrsList = new List<Address__c>();
        if(recordId!=null){
            opp = [Select Id,AccountId,Account.RecordType.DeveloperName from Opportunity where Id=:recordId];
            if(opp!=null && opp.AccountId!=null){
                isExist = true;
                rwrap.accExist = true;
                rwrap.accId = opp.AccountId;
                if(opp.Account.RecordType.DeveloperName == 'PersonAccount'){
                    rwrap.isPerson = true;
                }else{
                    rwrap.isOrg = true;
                }
                addrsList = [Select Id,Name,Account__c,City__c,toLabel(Country__c),Postal_Code__c,Primary__c,Status__c,PO_Box__c,
                             Arabic_Address__c,Street_Name__c,House_Apartment_No__c
                             from Address__c where Account__c =:opp.AccountId order by Primary__c desc];
                if(addrsList.size()>0){
                    rwrap.addressList = addrsList; 
                }
            }
        }
        system.debug('isExist'+isExist);
        return rwrap;
    }  
    
    /*
* @author : Ashams
* @usage : check if Broker Exists & return Broker details
*/
    @AuraEnabled  
    public static ResultWrapper checkBrokerAccountExists(string recordId){
        ResultWrapper rwrap = new ResultWrapper();
        Opportunity opp;
        Boolean isExist = False;
        if(recordId!=null){
            opp = [Select Id,AccountId,Broker__c,Employee_name__c, Referred_Customer__c from Opportunity where Id=:recordId];
            if(opp!=null && (opp.Broker__c!=null)){
                rwrap.brokerExist = true;
                rwrap.accId = opp.Broker__c;
            }
            if(opp.AccountId!= Null){
                rwrap.accExist = true;
            }else{
                rwrap.accExist = false;
            }
            if(string.isNotBlank(opp.Employee_name__c)){
                rwrap.EmployeeExist = true; 
            }
            if(String.valueOf(opp.Referred_Customer__c) != Null && opp!= Null){
                rwrap.referralCustomer = True;
                    }else{
                        rwrap.referralCustomer = false;
                    }
        }
        system.debug('rwrap'+rwrap.accExist);
        return rwrap;
    }  
    
    /*
* @author : Ashams
* @usage : Add Accounts to Opportunity
*/
    @AuraEnabled  
    public static ResultWrapper createAccounts(List<Account> accList, string recordId){
        system.debug('%%accList'+accList);
        ResultWrapper accWrap = new ResultWrapper();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Address__c> addrsList = new List<Address__c>();
        
        if(accList.size()>0 && string.isNotBlank(recordId)){
            List<Opportunity> OpportList = [Select Id,AccountId,RecordType.Name,Opportunity_Number__c from Opportunity where Id =:recordId OR Opportunity__c =:recordId];
            for(Opportunity Opp:OpportList){
                Opp.AccountId = accList[0].Id;
                if(accList[0].Name!=null){
                   Opp.Name = accList[0].Name + ' - '+ Opp.Opportunity_Number__c;  
                }
                oppList.add(Opp);
            }
        }
        if(oppList.size()>0){
            update  oppList;
            accWrap = getAccountDetails(accList[0].Id,'');
        }
        return accWrap;
    } 
    
    /*
    * @author : Rohit
    * @usage : Check Child Booked Opportunity
    */
    @AuraEnabled  
    public static boolean checkChildBookedOpportunity(string recordId){
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Opportunity__c =: recordId and move_to_advanced_screen__c = TRUE];
        if(oppList.size() > 0){
            return true;
        }else{
            return false;
        }    
    }

    /*
* @author : Ashams
* @usage : remove Account attached to Opportunity
*/
    @AuraEnabled  
    public static boolean removeAccounts(string recordId){
        List<Opportunity> oppList = new List<Opportunity>();
        List<Opportunity> OpporRemovetList = [Select Id,AccountId,RecordType.Name,Opportunity_Number__c from Opportunity where Id =:recordId OR Opportunity__c =:recordId];
        for(Opportunity Opp:OpporRemovetList){
            Opp.AccountId = null;
            Opp.Name = Opp.Opportunity_Number__c;
            oppList.add(Opp);
        }
        try{
            if(oppList.size()>0){
                update  oppList;
            } 
            return true;
        }catch(Exception e){
            system.debug('Exception'+e);
            return false;
        }    
    } 
    
    /*
* @author : Ashams
* @usage : remove Broker/Referrals attached to Opportunity
*/
    @AuraEnabled  
    public static boolean removeReferrals(string recordId, string referralType){
        system.debug('In method');
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity Opp = [Select Id,Broker__c,RecordType.Name,Employee_Name__c,Employee_Number__c from Opportunity where Id =:recordId];
        try{
            if(string.isNotEmpty(referralType)){
                if(referralType == 'broker'){
                    Opp.Broker__c = null;
                }else if(referralType == 'referral'){
                    Opp.Employee_Name__c = null;
                    Opp.Employee_Number__c = null;
                }else if(referralType == 'CustomerReferral'){
                    opp.Referred_Customer__c = null;
                }
                oppList.add(Opp);
            }
            if(oppList.size()>0){
                update  oppList;
            } 
            return true;
        }catch(Exception e){
            system.debug('Exception'+e);
            return false;
        }    
    } 
    
    /*
* @author : Ashams
* @usage : Attach Brokers to Opportunity
*/
    @AuraEnabled  
    public static string createBrokerAccounts(List<Account> accList, string recordId){
        system.debug('%%accList'+accList);
        List<Opportunity> oppList = new List<Opportunity>();
        if(accList.size()>0 && string.isNotBlank(recordId)){
            Opportunity Opp = [Select Id,Broker__c from Opportunity where Id =:recordId];
            Opp.Broker__c = accList[0].Id;
            oppList.add(Opp);
        }
        if(oppList.size()>0){
            update  oppList;
        }
        return accList[0].Id;
    } 
    
    /*
* @author : Ashams
* @usage : Get Broker Details
*/
    @AuraEnabled
    public static Map<String, Object> getBrokerAccountValues(string oppId){
        Map<String, Object> defaultValues = new Map<String, Object>();
        //Opportunity Opp = [select Id,AccountId,Account.name,Account.Trade_License_Number__c,
        //Account.Phone,Account.Primary_Mobile__c,Account.Primary_Country_Code__c 
        //from Opportunity where Id =:oppId];
        
        Map<String, Object> data = new Map<String, Object>();
        data.put('defaults', defaultValues);
        // get edit and read sections
        List<SObjectFieldWrapper> editFields = getSortedFieldSetFields('Account', 'Quick_Book_Broker_Fields');
        //List<SObjectFieldWrapper> readFields = getSortedFieldSetFields('Opportunity', 'Quick_Book_Fields');
        data.put('editFields', editFields);
        //data.put('readFields', readFields);
        system.debug('data'+data);
        return data;
    }
    
     /*
	* @author : Ashams
	* @usage : Create New Accounts & Address
	*/
    @AuraEnabled
    public static ResultWrapper addAccounts(Account accounts,Address__c primaryAddress,Address__c secAddress, boolean isEdit,string recordId, string recordType){
        system.debug('accounts'+accounts);
        //Account accounts = (Account)system.JSON.deserialize(accountObj, Account.class);
        Account newAccount = new Account();
        Account customer = new Account();
        Address__c primaryAddr = new Address__c();
        Address__c secAddr = new Address__c();
        sObject AccountSobj;
        Account duplicateAccount;
        List<Address__c> addressList = new List<Address__c>();
        ResultWrapper accWrap = new ResultWrapper();
        
        if(isEdit == FALSE){
            customer.Id = accounts.Id;
            if(recordType == 'PersonAccount'){
                customer.Passport_Number__c = accounts.Passport_Number__c;
                customer.Passport_Issue_Date__c = accounts.Passport_Issue_Date__c;
                customer.Passport_Expiry_Date__c = accounts.Passport_Expiry_Date__c;
                customer.Passport_Issue_Place__c = accounts.Passport_Issue_Place__c;
                customer.Visa_End_Date__c = accounts.Visa_End_Date__c;
                customer.Visa_Start_Date__c = accounts.Visa_Start_Date__c;
                customer.Visa_Number__c = accounts.Visa_Number__c;
            }else if(recordType == 'Business_RecordType'){
                customer.Trade_License_Number__c = accounts.Trade_License_Number__c;
            }
        }else{
            customer.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
            customer.Arabic_Name__c = accounts.Arabic_Name__c;
            customer.Primary_Country_Code__c = accounts.Primary_Country_Code__c;
            customer.Primary_Mobile__c = accounts.Primary_Mobile__c;
            customer.Primary_Email__c = accounts.Primary_Email__c;
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
                upsert customer; 
                if(accounts.Id==null){
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
            }
            List<Opportunity> oppList = [Select Id,AccountId,RecordType.Name,account.Name,Opportunity_Number__c from Opportunity where Id =:recordId OR Opportunity__c =:recordId];
            for(Opportunity op:oppList){
                op.AccountId = customer.Id;
                op.Name = op.Opportunity_Number__c +'-'+ customer.Name; 
            }
            update oppList;
            accWrap = getAccountDetails(customer.Id,recordId);
        }catch (DmlException e) {
            system.debug('error==  + ' + e);
            accWrap.accExist = FALSE;
            accWrap.accId = null;
            accWrap.respMsg = e.getDmlMessage(0);
            accWrap.isSucess = false;
            accWrap.accounts =null;
        }catch(Exception ex){
            system.debug('error==  + ' + ex);
            accWrap.accExist = FALSE;
            accWrap.accId = null;
            accWrap.respMsg = ex.getMessage();
            accWrap.isSucess = false;
            accWrap.accounts =null;
        }
        return accWrap;
    }
    
    /*
	* @author : Rohit
	* @usage : Update Third Party
	*/
    @AuraEnabled
    public static ResultWrapper updateThirdParty(string accId, string recordId){
        ResultWrapper Wrap = new ResultWrapper();
        Opportunity opp = new Opportunity();
        opp.Id = recordId;
        opp.Power_Of_Attorney__c = accId;
        try {
            update opp;
            Wrap.isSucess = true;
        } catch (Exception ex) {
            Wrap.isSucess = false;
            Wrap.respMsg = ex.getMessage();
        }
        return Wrap;
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
                           (SELECT Id,Name,Account__c,Primary__c,Arabic_Address__c,City__c,toLabel(Country_New__c),PO_Box__c,Postal_Code__c,Street_Name__c,House_Apartment_No__c from address__r)
                           from Account where ID =: AccId];
        }
        system.debug('&&accountList'+accountList);
        if(!accountList.isEmpty()){
           accWrap.accounts =accountList[0];
           accWrap.accExist = TRUE;
           accWrap.accId = accountList[0].Id;
           accWrap.respMsg = 'Success';
           accWrap.isSucess = TRUE;
        }
        system.debug('&&accWrap'+accWrap);
        return accWrap;
    }
    
    /*
* @author : Ashams
* @usage : Create New Accounts & Address
*/
    @AuraEnabled
    public static ResultWrapper createNewAccounts(String accValues, String ObjectName, string recordId, Boolean personRecType,string accountId, Address__c primaryAddrs,Address__c secAddrs){
        system.debug('recordJSON '+accValues);
        system.debug('accountId'+accountId);
        system.debug('primaryAddrs'+primaryAddrs);                                      
        system.debug('secAddrs'+secAddrs); 
        ResultWrapper rwrap = new ResultWrapper();
        
        Account sObj = new Account();
        Id recordTypeId;
        schema.SObjectType sobjType = Schema.getGlobalDescribe().get(ObjectName);
        Map<String, Schema.sObjectField> sObjectFields = sobjType.getDescribe().fields.getMap();
        Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(accValues);
        List<Opportunity> oppList = new List<Opportunity>();
        List<Address__c> addrsList = new List<Address__c>();
        Opportunity Opp;
        
        //Inserting Account
        if(string.isNotEmpty(accountId)){
            sObj.Id = accountId;  
        }else{
            if(personRecType == TRUE){
                recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(); 
            }else{
                recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_RecordType').getRecordTypeId(); 
                sObj.Name = objMap.get('FirstName') + ' '+objMap.get('LastName');
                objMap.remove('FirstName');
                objMap.remove('LastName');
                if(primaryAddrs!=null && string.isNotBlank(primaryAddrs.Country_New__c)){
                    //sObj.put('Country_Of_Residence__c',primaryAddrs.Country_New__c);
                }
            }
            system.debug('recordTypeId'+recordTypeId);
            sObj.RecordTypeId = recordTypeId;
            system.debug('sObj'+sObj);
        }
        for(String fieldName : objMap.keySet()){
            if(sObjectFields.get(fieldName).getDescribe().isUpdateable()){
                if(sObjectFields.get(fieldName).getDescribe().getType() == Schema.DisplayType.Date && objMap.get(fieldName)!=null){
                    system.debug('Date'+objMap.get(fieldName));
                    system.debug(Date.valueOf(String.valueof(objMap.get(fieldName))));
                    sObj.put(fieldName, Date.valueOf(String.valueof(objMap.get(fieldName))));
                }else{
                    sObj.put(fieldName, objMap.get(fieldName));
                }
            }
        }
        
        try{
            upsert sObj; 
            Opp = [Select Id,AccountId from Opportunity where Id =:recordId];
            Opp.AccountId = sObj.Id;
            if(personRecType == TRUE){
                Opp.Name = 'Quick Booking-' + sObj.LastName;
            }else{
               Opp.Name = 'Quick Booking-' + sObj.Name; 
            }
            oppList.add(Opp);
            if(oppList.size()>0){
                update  oppList;
            }
            rwrap.accId = sObj.Id;
        }catch(Exception e){
            system.debug('Error in Acc Insert'+e.getMessage());
            rwrap.isError = TRUE;
            rwrap.respMsg = e.getMessage();
            return rwrap;
        }	
        
        //Inserting address
        if(primaryAddrs!=null && string.isNotBlank(primaryAddrs.Name)){
            primaryAddrs.Account__c = sObj.Id;
            primaryAddrs.Status__c = 'Active';
            primaryAddrs.Primary__c = TRUE;
            try{
                insert primaryAddrs;
                addrsList.add(primaryAddrs);
            }catch(Exception e){
                system.debug('Error in PrimAddrs Insert'+e.getMessage());
                rwrap.respMsg = e.getMessage();
                rwrap.isError = TRUE;
                return rwrap;
            } 
        }
        if(secAddrs!=null && string.isNotBlank(secAddrs.Name)){
            secAddrs.Account__c = sObj.Id;
            secAddrs.Status__c = 'Active';
            try{
                insert secAddrs;
                addrsList.add(secAddrs);
            }catch(Exception e){
                system.debug('Error in PrimAddrs Insert'+e.getMessage());
                rwrap.respMsg = e.getMessage();
                rwrap.isError = TRUE;
                return rwrap;
            }   
        }
        
        rwrap.addressList = addrsList;
        system.debug('rwrap'+rwrap);
        //return sObj.Id;
        return rwrap;
    }
   
    
    /*
* @author : Jayesh
* @usage : Used in Emirates Id Integration
*/
    @AuraEnabled
    public static ResultWrapper fetchExistingAccount(String jsonDt, String transactionId, String oppId){
        Map<String, String> payLoadValues = new Map<String, String>();
        ResultWrapper accWrap = new ResultWrapper();
            
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(jsonDt);
        System.debug('results ' + results);
        String channel = (String)(results.get('channel'));        
        Map<String, Object> Data = (Map<String, Object>)(results.get('data'));
        System.debug('Data ' + Data);
        Map<String, Object> payload = (Map<String, Object>)(Data.get('payload'));
        System.debug('payload ' + payload);
        for (String customer : payload.keySet()) {
            System.debug('========> ' + customer);
            String cnt = (String)(payload.get(customer));
            System.debug('========> ' + cnt);
            
            payLoadValues.put(customer, cnt);
        }
        
        
        List<Account> accList = new List<Account>();
        accList = [SELECT Id FROM Account WHERE Primary_Mobile__c =: payLoadValues.get('Mobile_No__c') LIMIT 1];
        
        
        
        System.debug('@@@ accList '+ accList);
        if(accList.size() > 0){
            Opportunity opp = new Opportunity();
            opp = [SELECT Id, AccountId FROM Opportunity WHERE Id =: oppId];
            opp.AccountId = accList[0].Id;
            Database.update(opp,false);
            accWrap = getAccountDetails(opp.AccountId,oppId);
            return accWrap;
        }else{
            
            Account newAcc = new Account();
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            newAcc.LastName = payLoadValues.get('Full_Name__c');
            newAcc.recordTypeId = recordTypeId;
            //newAcc.Title = payLoadValues.get('Arabic_Title__c');  // need confirmation
            //newAcc. = payLoadValues.get('Passport_Type__c');
            newAcc.Passport_Number__c  = payLoadValues.get('Passport_Number__c');
            newAcc.Emirates_Ids__c  = payLoadValues.get('Emirates_Id_Number__c');  //we have two fields here withAPI name as 1. Emirates_Id__c(Number) 2. Emirates_Ids__c(Text)
            Date issueDate = Date.valueOf(payLoadValues.get('Issue_Date__c'));
            newAcc.Issue_Date__c  =  issueDate;
            // Date passportIssueDate = Date.valueOf(payLoadValues.get('Passport_Issue_Date__c'));
            //  newAcc.Passport_Issue_Date__c  = passportIssueDate;
            // Date passExpiryDate = Date.valueOf(payLoadValues.get('Passport_Expiry_Date__c'));
            //  newAcc.Passport_Expiry_Date__c  = passExpiryDate;
            //newAcc. = payLoadValues.get('Home_Address_Emirates_Code__c');
            //newAcc. = payLoadValues.get('UserId__c');  //formula field: USER_ID__c 
            //newAcc.Title = payLoadValues.get('Title__c');
            //newAcc. = payLoadValues.get('Transaction_Id__c');
            newAcc.Primary_Mobile__c  = '0'+ payLoadValues.get('Mobile_No__c'); //need confirmation
            //newAcc. = payLoadValues.get('Arabic_Full_Name__c');
            //newAcc. = payLoadValues.get('Home_Address_Street__c');
            Date DOB = Date.valueOf(payLoadValues.get('Date_of_birth__c'));
            newAcc.Date_Of_Birth__c  = DOB;
            //newAcc. = payLoadValues.get('Full_Name__c');  // we have to capture this field from contact object.
            //newAcc. = payLoadValues.get('Home_Address_City__c');
            //    newAcc.Customer_Nationality__c = payLoadValues.get('Nationality__c');
            Date expiryDate = Date.valueOf(payLoadValues.get('Expiry_Date__c'));
            newAcc.Expiry_Date__c  = expiryDate;
            
            //newAcc. = payLoadValues.get('Id_Type__c');
            newAcc.Primary_Email__c  = payLoadValues.get('Email__c');   //person email is also available here.
            
            insert newAcc;
            accList.add(newAcc);
            
            Opportunity oppRec = new Opportunity();
            oppRec = [SELECT Id, AccountId FROM Opportunity WHERE Id =: oppId];
            oppRec.AccountId = accList[0].Id;
            Database.update(oppRec,false);
            accWrap = getAccountDetails(oppRec.AccountId,oppId);
            return accWrap;
        }
    }
    
    /*
* @author : Ashams
* @usage : Fetch Fields from Field Sets
*/
    public static List<SObjectFieldWrapper> getSortedFieldSetFields(String sObjectName, String fieldSetName) {
        List<SObjectFieldWrapper> objFields = new List<SObjectFieldWrapper>();
        //describe the provided sObject
        Schema.DescribeSObjectResult res = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = res.fieldSets.getMap();
        Schema.FieldSet fs = fieldSetMap.get(fieldSetName);
        for(Schema.FieldSetMember fsm : fs.getFields()) {
            SObjectFieldWrapper sfw = new SObjectFieldWrapper();
            sfw.fieldName = fsm.getFieldPath();
            sfw.fieldType = fsm.getType().name();
            sfw.fieldLabel = fsm.getLabel();
            sfw.required = fsm.getRequired() || fsm.getDbRequired();
            objFields.add(sfw);
        }
        objFields.sort();
        return objFields;
    }
    
    /*
	* @author : Ashams
	* @usage : get Country Picklist values
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
	* @usage : get Country Picklist values
	*/
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
        return options;
    }
   
    /*
* @author : Jayesh Shewale
* @usage : Check if the given Opportunity has AccountId or Units added. /*
*/
    @AuraEnabled
    public static Boolean checksAccountAndUnit(Id oppId){
        System.debug('@@@ '+ oppId);
        if(oppId!=null){
            //Opportunity checkAccForOpp = [Select Id,AccountId,Account.RecordType.DeveloperName, [] from Opportunity where Id=:recordId LIMIT 1];
            List<Opportunity> oppList = [SELECT Id, Quick_Book_Opportunity__r.AccountId FROM Opportunity WHERE Opportunity__c   =: oppId];
            if(oppList.size() > 0){
                return True;
            }else{
                Opportunity checkAccForOpp = [Select Id, AccountId from Opportunity where Id=:oppId LIMIT 1];
                if(checkAccForOpp.AccountId != Null){
                    return True;
                }else{
                    return false;
                }
            }
        }else{
            return null;
        }
    }
    
    
    public class SObjectFieldWrapper implements Comparable {
        @AuraEnabled
        public String fieldName {get; public set;}
        @AuraEnabled
        public String fieldLabel {get; public set;}
        @AuraEnabled
        public String fieldType {get; public set;}
        @AuraEnabled
        public Boolean required {get; public set;}
        
        public Integer compareTo(Object withObj) {
            SObjectFieldWrapper compareTo = (SObjectFieldWrapper) withObj;
            return fieldLabel.compareTo(compareTo.fieldLabel);
        }
    }
    
    public class ResultWrapper{
        @AuraEnabled
        public Boolean brokerExist;
        @AuraEnabled
        public Boolean EmployeeExist;
        @AuraEnabled
        public Boolean accExist;
        @AuraEnabled
        public String accId; 
        @AuraEnabled
        public Boolean isSucess;
        @AuraEnabled
        public Boolean isPerson;
        @AuraEnabled
        public Boolean isOrg;
        @AuraEnabled
        public Boolean isError;
        @AuraEnabled
        public String respMsg;
        @AuraEnabled
        public Account accounts;
        @AuraEnabled
        public List<Address__c> addressList;
        @AuraEnabled
        public Decimal accCount; 
        @AuraEnabled
        public Boolean referralCustomer;
    }   
}