public without sharing class LeasingOppAccountSearchCtrl {
    
    @AuraEnabled
    public static List<fieldsWrapper> getFieldSet(){
        List<fieldsWrapper> fieldwraplist = new List<fieldsWrapper>();
        List<Schema.FieldSetMember>  individualfields = SObjectType.Account.FieldSets.Leasing_Indiviual_Fieldset.getFields();
        for(Schema.FieldSetMember f : individualfields){
            fieldsWrapper fw = new fieldsWrapper();
            fw.field = f.getFieldPath();
            fw.fieldLabel = f.getLabel();
            fw.required = f.getRequired();
            fw.title = 'Individual';
            
            fieldwraplist.add(fw);
            
        }
        List<Schema.FieldSetMember>  orgfields = SObjectType.Account.FieldSets.Corporate_Leasing_Fieldset.getFields();
        for(Schema.FieldSetMember f : orgfields){
            fieldsWrapper fw = new fieldsWrapper();
            fw.field = f.getFieldPath();
            fw.required = f.getRequired();
            fw.fieldLabel = f.getLabel();
            fw.title = 'Organisation';
            fieldwraplist.add(fw);
            
        }
        
        List<Schema.FieldSetMember>  signatoryfields = SObjectType.Account.FieldSets.Signatory_Fieldset.getFields();
        for(Schema.FieldSetMember f : signatoryfields){
            fieldsWrapper fw = new fieldsWrapper();
            fw.field = f.getFieldPath();
            fw.required = f.getRequired();
            fw.fieldLabel = f.getLabel();
            fw.title = 'Signatory';
            fieldwraplist.add(fw);
            
        }
        List<Schema.FieldSetMember>  brandingfields = SObjectType.Account.FieldSets.Branding_Fieldset.getFields();
        for(Schema.FieldSetMember f : brandingfields){
            fieldsWrapper fw = new fieldsWrapper();
            fw.field = f.getFieldPath();
            fw.required = f.getRequired();
            fw.fieldLabel = f.getLabel();
            fw.title = 'Branding';
            fieldwraplist.add(fw);
            
        }
        System.debug('List: '+fieldwraplist);
        return fieldwraplist; 
    }
    
    
    @AuraEnabled
    public static Opportunity oppRecord(String recordId){
        Opportunity opp = new Opportunity();
        opp = [Select Id,Leasing_Type__c,Account.RecordType.DeveloperName, AccountId, (SELECT ID FROM Unit_Plans__r) FROM Opportunity where Id =: recordId limit 1];
        
        return opp;
    }
    
    @AuraEnabled
    public static List<Address__c> addressRecord(String recordId){
        
        Opportunity opp = new Opportunity();
        opp = [Select Id,Leasing_Type__c,Account.RecordType.DeveloperName, AccountId FROM Opportunity where Id =: recordId limit 1];
        
        
        return [Select Id,Name,Country_New__c, City__c, Postal_Code__c, Street__c, Arabic_Address__c, Primary__c FROM Address__c where Account__c =: opp.AccountId ];
        
    }
    
    @AuraEnabled  
    public static AccountWrapper fetchAccountList(string accName,String accNumber,String eid,String mobNumber,string accTDN,boolean isPerson,String accEmail){
        string query ='';
        String recordtypeName;
        AccountWrapper accWrap = new AccountWrapper();
        try{
            recordtypeName =   isPerson ? 'PersonAccount' : 'Business_RecordType';
            query = 'select Id,Name,Trade_License_Number__c,AccountNumber,ERP_Account_Number__c,Nationality__c,Relationship_with_Owner__c,Primary_Email__c,Primary_Mobile__c,Primary_Country_Code__c,Emirates_Ids__c,Country_Of_Residence__c,Passport_Number__c,Visa_Number__c,Country__c,BillingAddress,PersonMailingAddress, Passport_Expiry_Date__c, Visa_End_Date__c, Trade_License_End_Date__c from Account where';
            
            if(string.isNotBlank(accName)){
                String tempInput ='\'%' + accName  + '%\''; 
                query = query + ' name like ' + tempInput + ' AND '; 
            }
            system.debug('query'+query);
            if(string.isNotBlank(accNumber)){
                String tempInput ='\'%' + accNumber  + '%\'';
                query = query + ' ERP_Account_Number__c like ' + tempInput + ' AND '; 
                //query = query + ' AccountNumber like ' + tempInput + ' AND '; 
            }
            
            if(string.isNotBlank(mobNumber)){
                String tempInput ='\'%' + mobNumber  + '%\'';
                query = query + ' Primary_Mobile__c like ' + tempInput + ' AND '; 
            }
            
            if(string.isNotBlank(eid)){
                String tempInput ='\'%' + eid  + '%\'';
                query = query + ' Emirates_Ids__c like ' + tempInput + ' AND '; 
            }
            if(string.isNotBlank(accEmail)){
                String tempInput ='\'%' + accEmail  + '%\'';
                query = query + ' Primary_Email__c like ' + tempInput + ' AND '; 
            } 
            if(string.isNotBlank(accTDN)){
                String tempInput ='\'%' + accTDN  + '%\'';
                query = query + ' Trade_License_Number__c like ' + tempInput + ' AND '; 
            } 
            if(string.isNotBlank(recordtypeName)){
                query = query + ' RecordType.DeveloperName =: recordtypeName' +   ' order by Name asc';  
            }
            List<Account> accList = Database.query(query);
            Set<Id> accountIds = new Set<Id>();
            for(Account acc : accList){
                accountIds.add(acc.Id);
            }
            accWrap.accRecLst = accList;
            
            Map<Id,List<String>> accountFlags = new Map<Id,List<String>>();
            if(accountIds.size() > 0){
                accWrap.flagDescList = CheckFlags.checkAccountFlags(accountIds,false,true,false);
            }
            return accWrap;  
        }catch(exception ex){  
            system.debug('log message is '+ ex.getMessage() + ' at line number '+ ex.getLineNumber());
            return null;
        } 
    }
    
    @AuraEnabled  
    public static ResultWrapper createAccounts(List<Account> accList, string recordId){
        system.debug('%%accList'+accList);
        ResultWrapper rwrap = new ResultWrapper();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Address__c> addrsList = new List<Address__c>();
        
        if(accList.size()>0 && string.isNotBlank(recordId)){
            Opportunity Opp = [Select Id,AccountId,RecordType.Name from Opportunity where Id =:recordId];
            Opp.AccountId = accList[0].Id;
            if(String.valueOf(opp.RecordType.Name).contains('Leasing')){
                Opp.Name = 'Leasing-' + accList[0].Name;  
            } else {
                Opp.Name = 'Quick Booking-' + accList[0].Name; 
            }
            oppList.add(Opp);
        }
        if(oppList.size()>0){
            try{
                rwrap.respMsg = 'Opportunity Updated SuccessFully!!';
                update  oppList;
            } catch(Exception ex){
                rwrap.respMsg = ex.getMessage();
            }
            addrsList = [Select Id,Name,Account__c,City__c,Country_New__c,Postal_Code__c,
                         Account__r.BillingAddress,Account__r.PersonMailingAddress,
                         Primary__c,Status__c,Street__c from Address__c where Account__c =:accList[0].Id];
            rwrap.accId = accList[0].Id;
            if(addrsList.size()>0){
                rwrap.addressList = addrsList; 
            }
        }
        return rwrap;
    } 
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
                addrsList = [Select Id,Name,Account__c,City__c,Country_New__c,Postal_Code__c,Primary__c,Status__c,Street__c from Address__c where Account__c =:opp.AccountId];
                if(addrsList.size()>0){
                    rwrap.addressList = addrsList; 
                }
            }
        }
        system.debug('isExist'+isExist);
        //return opp.AccountId;
        return rwrap;
    }  
    
    @AuraEnabled  
    public static boolean removeAccounts(string recordId){
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity Opp = [Select Id,AccountId,RecordType.Name from Opportunity where Id =:recordId];
        Opp.AccountId = null;
        Opp.Name = 'Leasing';
        oppList.add(Opp);
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
    @AuraEnabled
    public static Map<String, String> getCountryValues(){
        Map<String, String> options = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = Address__c.Country_New__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            if (p.isDefaultValue()) {
                options.put(p.getValue(), p.getLabel());
                break;
            } 
        }
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());            
        }
        system.debug('options are '+ options);
        return options;
    }
    
    /*Method: to create/update account & address records of the deal
Author: 
Modified by: Karishma Kotian
Reason: as a part of code refactoring
*/
    @AuraEnabled
    public static ResultWrapper createRecords(String recordJSON,Boolean isNewAccount,String recordId,String accId,Boolean isPerson, String primaryAddress,String otherAddress, String updateAddress){
        ResultWrapper rwrap = new ResultWrapper();Address__c deserializedAddress;
        //Address__c deserailiseOtherAddress;
        List<Address__c> deserailiseOtherAddress = new List<Address__c>();
        try{
            system.debug('@@primaryAddress :'+primaryAddress);
            system.debug('@@otherAddress :'+otherAddress);
            
            if(primaryAddress != null) {
                deserializedAddress  = (Address__c)JSON.deserialize(primaryAddress, Type.forName('Address__c'));
                system.debug('@@deserializedAddress :'+deserializedAddress);}
            if(otherAddress != null){
                deserailiseOtherAddress  = (List<Address__c>)JSON.deserialize(otherAddress, List<Address__c>.class);
                //deserailiseOtherAddress  = (Address__c)JSON.deserialize(otherAddress, Type.forName('Address__c'));
            }
            List<Address__c> addressList = new List<Address__c>();
            Account newacc = (Account)JSON.deserialize(recordJSON, Account.class);
            
            String recordtypeName = isPerson ?  'PersonAccount' : 'Business_RecordType';
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId();
            system.debug('isNewAccount'+isNewAccount);
            system.debug('newacc'+newacc);
            
            /*********** Check Is new account to create *************/
            if(isNewAccount){
                
                if(newacc != null){
                    newacc.RecordTypeId =  devRecordTypeId;
                    system.debug('devRecordTypeId'+devRecordTypeId);
                    /*********** Refrence address record with account *************/
                    if(deserializedAddress != null){
                        
                        newacc.Country__c = deserializedAddress.Country_New__c;
                        newacc.Address_Line_1__c = deserializedAddress.Street__c;
                        newacc.Postal_Code__c = deserializedAddress.Postal_Code__c;
                        newacc.City__c = deserializedAddress.City__c;
                        newacc.Address_Line_4__c = deserializedAddress.Arabic_Address__c;
                        /*
                        if(!isPerson){
                            newacc.BillingCity = deserializedAddress.City__c != null ? deserializedAddress.City__c : '';
                            //newacc.BillingStreet = deserializedAddress.Name != null? deserializedAddress.Name : '';
                            newacc.BillingCountry = deserializedAddress.Country__c != null ? deserializedAddress.Country__c : 'AE';
                            newacc.BillingPostalCode = deserializedAddress.Postal_Code__c != null ? deserializedAddress.Postal_Code__c : '0000';
                            newacc.BillingStreet = deserializedAddress.Street__c != null ?  deserializedAddress.Street__c : '';
                        }else{

                            newacc.PersonMailingCity = deserializedAddress.City__c != null ? deserializedAddress.City__c : '';
                            //newacc.PersonMailingStreet = deserializedAddress.Name != null? deserializedAddress.Name : '';
                            newacc.PersonMailingCountry = deserializedAddress.Country__c != null ? deserializedAddress.Country__c : 'AE';
                            newacc.PersonMailingPostalCode = deserializedAddress.Postal_Code__c != null ? deserializedAddress.Postal_Code__c : '0000';
                            newacc.PersonMailingStreet = deserializedAddress.Street__c != null ?  deserializedAddress.Street__c : '';
                            
                        }
                      */
                    }
                    
                    system.debug('****newacc****'+newacc);
                    newacc.Send_Customer_to_ERP__c = true;
                    newacc.accOtpVerifiedFlag__c = true;
                    system.debug('New Account '+JSON.serialize(newacc));
                    
                    insert newacc;
                     /*********** Add Signatory for corporate Account *************/
                    if(!isPerson){
                        Contact signatoryContact = new Contact();
                        List<Contact> con = new List<Contact>();
                        
                        if(newacc.Signatory_Lastname__c != null){
                            if(newacc.Id != null){
                                con = [Select Id,FirstName,LastName,Email,Phone,Country_Code__c,AccountId   FROM Contact where AccountId = : newacc.Id limit 1];
                            }
                            
                            if(con.size() > 0){
                                signatoryContact = con[0];
                                signatoryContact.FirstName = newacc.Signatory_Firstname__c;
                                signatoryContact.LastName = newacc.Signatory_Lastname__c;
                                signatoryContact.Email = newacc.Signatory_Email__c;
                                signatoryContact.Phone = newacc.Signatory_Phone_Number__c;
                                signatoryContact.Country_Code__c = newacc.Signatory_Country_Code__c;
                                signatoryContact.Is_Primary__c = true; //Added by Sajid
                                update signatoryContact;
                            }
                            else {
                                
                                signatoryContact.FirstName = newacc.Signatory_Firstname__c;
                                signatoryContact.LastName = newacc.Signatory_Lastname__c;
                                signatoryContact.Email = newacc.Signatory_Email__c;
                                signatoryContact.Country_Code__c = newacc.Signatory_Country_Code__c;
                                signatoryContact.Phone = newacc.Signatory_Phone_Number__c;
                                signatoryContact.Is_Primary__c = true; //Added by Sajid
                                signatoryContact.AccountId = newacc.Id;
                                insert signatoryContact;
                                
                                newacc.Authorised_Signatory_Contact__c = signatoryContact.Id;
                                update newacc;
                            }
                        }
                    }
                    
                    system.debug('****newacc****'+newacc);
                    if(newacc.Id != null){
                        Opportunity opp = new Opportunity();
                        opp.Id = recordId;
                        opp.AccountId = newacc.Id;
                        update opp;
                    }
                    /*********** Refrence primary address to account *************/
                    if(deserializedAddress != null){
                        deserializedAddress.Primary__c = true;
                        deserializedAddress.Status__c = 'Active';
                        deserializedAddress.Account__c = newacc.Id;
                        insert deserializedAddress;
                        addressList = new list<Address__c> {deserializedAddress};
                    }
                    /*********** Refrence secondary address to account *************/
                    if(deserailiseOtherAddress.size() > 0){
                        List<Address__c> insertList = new List<Address__c>();
                        for(Address__c addr :deserailiseOtherAddress ){
                            addr.Primary__c = false;
                            addr.Status__c = 'Active';
                            addr.Account__c = newacc.Id;
                            
                            insertList.add(addr);
                        }
                        //deserailiseOtherAddress.Primary__c = false;
                        //deserailiseOtherAddress.Status__c = 'Active';
                        //deserailiseOtherAddress.Account__c = newacc.Id;
                        insert insertList;
                        for(Address__c address :insertList ){
                            addressList = new list<Address__c> {address};
                        }
                    }        
                } 
            }
             /*********** Existing Account *************/
            else{
                Contact signatoryContact = new Contact();
                
                if(newacc != null && accId != null){
                    newacc.Id = accId;
                    /*********** Update Signatory for corporate account *************/
                    if(!isPerson){
                        List<Contact> con = new List<Contact>();
                        if(newacc.Signatory_Lastname__c != null){
                            if(newacc.Id != null){
                                con = [Select Id,FirstName,LastName,Email,Phone,Country_Code__c,AccountId   FROM Contact where AccountId = : newacc.Id limit 1];
                            }
                            
                            if(con.size() > 0){
                                signatoryContact = con[0];
                                signatoryContact.FirstName = newacc.Signatory_Firstname__c;
                                signatoryContact.LastName = newacc.Signatory_Lastname__c;
                                signatoryContact.Email = newacc.Signatory_Email__c;
                                signatoryContact.Phone = newacc.Signatory_Phone_Number__c;
                                signatoryContact.Is_Primary__c = true; //Added by Sajid
                                signatoryContact.Country_Code__c = newacc.Signatory_Country_Code__c;
                                
                                update signatoryContact;
                            }
                            else {
                                signatoryContact.FirstName = newacc.Signatory_Firstname__c;
                                signatoryContact.LastName = newacc.Signatory_Lastname__c;
                                signatoryContact.Email = newacc.Signatory_Email__c;
                                signatoryContact.Phone = newacc.Signatory_Phone_Number__c;
                                signatoryContact.Country_Code__c = newacc.Signatory_Country_Code__c;
                                signatoryContact.Is_Primary__c = true; //Added by Sajid
                                signatoryContact.AccountId = newacc.Id;
                                insert signatoryContact;
                                
                                newacc.Authorised_Signatory_Contact__c = signatoryContact.Id;
                            }
                        }
                    }
                    
                    system.debug('newacc'+newacc);
                    system.debug('@@@acc'+newacc.Signatory_Email__c + newacc.Signatory_Firstname__c + newacc.Signatory_Lastname__c + newacc.Signatory_Phone_Number__c);
                    newacc.Send_Customer_to_ERP__c = true;
                    
                    
                    
                    if(updateAddress != null){
                        deserailiseOtherAddress  = (List<Address__c>)JSON.deserialize(updateAddress, List<Address__c>.class);
                        //deserailiseOtherAddress  = (Address__c)JSON.deserialize(otherAddress, Type.forName('Address__c'));
                    }
                    /*********** Update address *************/
                    if(deserailiseOtherAddress.size() > 0){
                        for(Address__c addres : deserailiseOtherAddress){
                            if(String.isNotEmpty(addres.Id) && addres.Primary__c){
                                
                                newacc.Country__c = addres.Country_New__c;
                                newacc.Address_Line_1__c = addres.Street__c;
                                newacc.Postal_Code__c = addres.Postal_Code__c;
                                newacc.City__c = addres.City__c;
                                newacc.Address_Line_4__c = addres.Arabic_Address__c;
                                System.debug('Account Update: '+newacc);
                                 /*
                                if(!isPerson){
                                    newacc.BillingCity = addres.City__c != null ? addres.City__c : '';
                                    //newacc.BillingStreet = deserializedAddress.Name != null? deserializedAddress.Name : '';
                                    newacc.BillingCountry = addres.Country__c != null ? addres.Country__c : 'AE';
                                    newacc.BillingPostalCode = addres.Postal_Code__c != null ? addres.Postal_Code__c : '0000';
                                    newacc.BillingStreet = addres.Street__c != null ?  addres.Street__c : '';
                                }else{
                                    
                                    newacc.PersonMailingCity = deserializedAddress.City__c != null ? deserializedAddress.City__c : '';
                                    //newacc.PersonMailingStreet = deserializedAddress.Name != null? deserializedAddress.Name : '';
                                    newacc.PersonMailingCountry = deserializedAddress.Country__c != null ? deserializedAddress.Country__c : 'AE';
                                    newacc.PersonMailingPostalCode = deserializedAddress.Postal_Code__c != null ? deserializedAddress.Postal_Code__c : '0000';
                                    newacc.PersonMailingStreet = deserializedAddress.Street__c != null ?  deserializedAddress.Street__c : '';
                                    
                                }
								*/
                            }
                        }
                    }
                    system.debug('accccc: '+ JSON.serialize(newacc));
                    update newacc;              
                    /*********** Refrence address to account if any new address is added *************/
                    if(deserailiseOtherAddress.size() > 0){
                        for(Address__c addres : deserailiseOtherAddress){
                            
                            if(String.isEmpty(addres.Id)){
                                
                                addres.Account__c = newacc.Id;
                            } 
                        }
                        upsert deserailiseOtherAddress; 
                    }
                    
                    /*
                    addressList = [Select Id,Name,City__c,Street__c,
                    Country__c,Postal_Code__c,Primary__c,
                    Status__c FROM Address__c where Account__c =: newacc.Id and Primary__c = true];
                    if(addressList.size() > 0  ){
                    //system.debug('@@@Existing address'+addressList+isPerson+' newacc.PersonMailingStreet :'+newacc.PersonMailingStreet + address.Name + newacc.BillingStreet + newacc.BillingStreet + address.Name);
                    Address__c address = addressList[0];
                    address.Name = isPerson ? newacc.PersonMailingStreet != null ? newacc.PersonMailingStreet : address.Name : newacc.BillingStreet != null ? newacc.BillingStreet : address.Name;
                    address.City__c = isPerson ? newacc.PersonMailingCity != null ? newacc.PersonMailingCity : address.City__c : newacc.BillingCity != null ? newacc.BillingCity : address.City__c;
                    address.Country__c = isPerson ? newacc.Country__c != null ? newacc.Country__c : newacc.Country_Of_Residence__c != null ? newacc.Country_Of_Residence__c : address.Country__c : address.Country__c ;
                    address.Postal_Code__c = isPerson ? newacc.PersonMailingPostalCode != null ? newacc.PersonMailingPostalCode : address.Postal_Code__c : newacc.BillingPostalCode != null ? newacc.BillingPostalCode : address.Postal_Code__c;
                    address.Primary__c = true;
                    address.Street__c = isPerson ? newacc.BillingStreet != null ? newacc.BillingStreet : address.Street__c : '';
                    address.Status__c = 'Active';
                    //system.debug('address*****'+address);
                    update address;
                    }else{
                    system.debug('@@@New address :'+isPerson+' newacc.PersonMailingStreet :'+newacc.PersonMailingStreet);
                    Address__c address = new Address__c();
                    address.Name = isPerson ? newacc.PersonMailingStreet != null ? newacc.PersonMailingStreet : address.Name : newacc.BillingStreet != null ? newacc.BillingStreet : address.Name;
                    address.City__c = isPerson ? newacc.PersonMailingCity != null ? newacc.PersonMailingCity : address.City__c : newacc.BillingCity != null ? newacc.BillingCity : address.City__c;
                    address.Country__c = isPerson ? newacc.Country__c != null ? newacc.Country__c : newacc.Country_Of_Residence__c != null ? newacc.Country_Of_Residence__c : address.Country__c : address.Country__c ;
                    address.Postal_Code__c = isPerson ? newacc.PersonMailingPostalCode != null ? newacc.PersonMailingPostalCode : address.Postal_Code__c : newacc.BillingPostalCode != null ? newacc.BillingPostalCode : address.Postal_Code__c;
                    address.Primary__c = true;
                    address.Street__c = isPerson ? newacc.BillingStreet != null ? newacc.BillingStreet : address.Street__c : '';
                    address.Status__c = 'Active';
                    insert address;
                    addressList.add(address);
                    }
                    */
                }
            }
            rwrap.accExist = true;
            rwrap.accId = newacc.Id;
            rwrap.isPerson = isPerson;
            rwrap.isOrg = isPerson ? false : true;
            rwrap.addressList = addressList; 
            
        }catch(Exception ex){
            system.debug('ex****'+ex.getMessage()+ex.getLineNumber()+ex.getMessage() );
            throw new AuraHandledException(ex.getMessage());
            
        }
        
        return rwrap;
        
        
    }
    
    /*  @author : Jayesh
* 	@usage : search Accounts based on search filters
*  @version 1.1 
*  @changes : changed mobile number to Emirates Id for existing customer check.
* 			   Added Nationality map to fetch customer nationality
*  @Owner : Ashams
*/
    @AuraEnabled
    public static List<Account> fetchExistingAccount(String jsonDt, String transactionId, String oppId){
        Map<String, String> payLoadValues = new Map<String, String>();
        List<Account> accList = new List<Account>();
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(jsonDt);
        String channel = (String)(results.get('channel'));        
        Map<String, Object> Data = (Map<String, Object>)(results.get('data'));
        Map<String, Object> payload = (Map<String, Object>)(Data.get('payload'));
        
        for (String customer : payload.keySet()) {
            String cnt = (String)(payload.get(customer));
            payLoadValues.put(customer, cnt);
            //System.debug('========> ' + customer);
            //System.debug('========> ' + cnt);
        }
           //
            String UnformatedId = payLoadValues.get('Emirates_Id_Number__c');
            String FormattedEmiratesId = UnformatedId.subString(0,3) + '-' +UnformatedId.subString(3,7) + '-' + UnformatedId.subString(7,14) +'-'+ UnformatedId.subString(14,15);
            //
        accList = [SELECT Id,Emirates_Ids__c,Passport_Number__c FROM Account WHERE Emirates_Ids__c =:FormattedEmiratesId LIMIT 1];
        
        
        if(accList.size() > 0){
            Opportunity opp = new Opportunity();
            opp = [SELECT Id, AccountId FROM Opportunity WHERE Id =: oppId];
            opp.AccountId = accList[0].Id;
            Database.update(opp,false);
            return accList;
        }else{
            Account newAcc = new Account();
            //newAcc.LastName = payLoadValues.get('Full_Name__c');
            
            //Added by Karishma to store first name and last name in separate fields without comma - 04-05-2022
            String fullName = payLoadValues.get('Full_Name__c');
            List<String> nameList = fullName.split(',');
            system.debug('nameList :'+nameList+'Size :'+nameList.size());
            boolean firstName = false;
            boolean lastNameStart = false;
            for(String name : nameList){	
                if(!firstName && nameList.size() > 1){	
                    newAcc.FirstName = name;
                    firstName = true;
                }else if(!lastNameStart) {	
                    lastNameStart = true;
                    newAcc.LastName = name;
                }else{
                    newAcc.LastName = newAcc.LastName +' '+name;
                }	
            }
            system.debug('firstname :'+newAcc.FirstName);
            system.debug('lastName :'+newAcc.LastName);

            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            Date issueDate = Date.valueOf(payLoadValues.get('Issue_Date__c'));
            Date DOB = Date.valueOf(payLoadValues.get('Date_of_birth__c'));
            Date expiryDate = Date.valueOf(payLoadValues.get('Expiry_Date__c'));
            //Added by Ashams - Added Nationality logic to get picklist value
            Map<String, String> nationalityMap = CommonUtility.getPicklistValuesByLabel('Account','Nationality__c');
            //system.debug('Nationality'+nationalityMap.get(payLoadValues.get('Nationality__c')));
            
            newAcc.recordTypeId = recordTypeId;
            newAcc.Passport_Number__c  = payLoadValues.get('Passport_Number__c');
            newAcc.Emirates_Ids__c  = FormattedEmiratesId;
            newAcc.Issue_Date__c  =  issueDate;
            newAcc.Primary_Mobile__c  = '0'+payLoadValues.get('Mobile_No__c'); //need confirmation
            newAcc.Date_Of_Birth__c  = DOB;
            newAcc.Signatory_Email__c = payLoadValues.get('Signatory_Email__c');
            newAcc.Signatory_Firstname__c = payLoadValues.get('Signatory_Firstname__c');
            newAcc.Signatory_Lastname__c = payLoadValues.get('Signatory_Lastname__c');
            newAcc.Signatory_Phone_Number__c = payLoadValues.get('Signatory_Phone_Number__c');
            if(string.isNotBlank(nationalityMap.get(payLoadValues.get('Nationality__c')))){
                newAcc.Nationality__c = nationalityMap.get(payLoadValues.get('Nationality__c')); 
            }
            newAcc.Expiry_Date__c  = expiryDate;
            newAcc.Primary_Email__c  = payLoadValues.get('Email__c');
            newAcc.Arabic_Name__c  = payLoadValues.get('Arabic_Full_Name__c');
            
            insert newAcc;
            accList.add(newAcc);
            
            Opportunity oppRec = new Opportunity();
            oppRec = [SELECT Id, AccountId FROM Opportunity WHERE Id =: oppId];
            oppRec.AccountId = accList[0].Id;
            Database.update(oppRec,false);
            
            return accList;
        }
    }
    
    public class ResultWrapper{
        @AuraEnabled public Boolean brokerExist;
        @AuraEnabled public Boolean EmployeeExist;
        @AuraEnabled public String accId; 
        @AuraEnabled public Boolean accExist;
        @AuraEnabled public Boolean isPerson;
        @AuraEnabled public Boolean isOrg;
        @AuraEnabled public Boolean isError;
        @AuraEnabled public String respMsg;
        @AuraEnabled public List<Address__c> addressList;
    }
    
    public class AccountWrapper {
        @AuraEnabled public List<Account> accRecLst;
        @AuraEnabled public Map<Id,List<String>> flagDescList;
        
    }
    
    public class fieldsWrapper {
        @AuraEnabled 
        public String field;
        @AuraEnabled
        public Boolean required;
        @AuraEnabled
        public Integer Id;
        @AuraEnabled
        public String title;
        @AuraEnabled 
        public String fieldLabel;
    }
}