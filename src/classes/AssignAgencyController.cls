public class AssignAgencyController {
    @AuraEnabled  
    public static List<Account> fetchAccounts(string accName,string accNum,string accEmail,string accMob,string accEID,string accTDN,boolean isPerson){
        string query ='';
        String recordType = '';
        try{
            recordType = isPerson ? 'PersonAccount' : 'Business_RecordType';
            query = 'select Id,Name,AccountNumber,Customer_Nationality__c,Primary_Email__c,Primary_Mobile__c,Primary_Country_Code__c,Emirates_Ids__c,Country_Of_Residence__c,Passport_Number__c,Trade_License_End_Date__c from Account where';
            
            if(string.isNotBlank(accName)){
                String tempInput ='\'%' + accName  + '%\'';
                query = query + ' name like ' + tempInput + ' AND '; 
            }
            if(string.isNotBlank(accNum)){
                String tempInput ='\'%' + accNum  + '%\'';
                query = query + ' AccountNumber like ' + tempInput + ' AND '; 
            }
            if(string.isNotBlank(accEmail)){
                String tempInput ='\'%' + accEmail  + '%\'';
                query = query + 'Primary_Email__c like ' + tempInput + ' AND '; 
            }
            if(string.isNotBlank(accMob)){
                String tempInput ='\'%' + accMob  + '%\'';
                query = query + 'Primary_Mobile__c like ' + tempInput + ' AND '; 
            }
            if(string.isNotBlank(accEID)){
                String tempInput ='\'%' + accEID  + '%\'';
                query = query + 'Emirates_Ids__c like ' + tempInput + ' AND '; 
            }
            if(string.isNotBlank(recordType)){
                query = query + 'RecordType.DeveloperName =:recordType' +   ' order by Name asc';  
            }
            system.debug('%%query'+query);
            List<Account> accList = Database.query(query);
            system.debug('%%accList'+accList.size());
            
            return accList;  
        }catch(exception ex){  
            system.debug('log message is '+ ex.getMessage() + ' at line number '+ ex.getLineNumber());
            return null;
        }
    }  
    
    @AuraEnabled  
    public static List<Account> fetchBrokerAccounts(string searchKey){
        string query ='';
        if(string.isNotBlank(searchKey)){
            query = 'select Id,Name,Trade_License_Number__c,Phone,Primary_Mobile__c,Primary_Country_Code__c,Primary_Email__c,Trade_License_End_Date__c from Account';
            String tempInput ='\'%' + searchKey  + '%\'';
            String recordType = 'Broker_Account';
            query = query + ' where (name like ' + tempInput + ' or Trade_License_Number__c like '+tempInput+' or Primary_Mobile__c like '+tempInput+'or Primary_Email__c like '+tempInput+')and RecordType.DeveloperName =:recordType' +   ' order by Name asc'; 
        }
        system.debug('%%query'+query);
        List<Account> accList = Database.query(query);
        system.debug('%%accList'+accList);
        return accList;  
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
    
    @AuraEnabled  
    public static ResultWrapper checkBrokerAccountExists(string recordId){
        ResultWrapper rwrap = new ResultWrapper();
        Opportunity opp;
        Boolean isExist = False;
        if(recordId!=null){
            opp = [Select Id,AccountId,Broker__c,Employee_name__c from Opportunity where Id=:recordId];
            if(opp!=null && (opp.Broker__c!=null)){
                rwrap.brokerExist = true;
                rwrap.brokerId = opp.Broker__c;
            }
            if(string.isNotBlank(opp.Employee_name__c)){
               rwrap.EmployeeExist = true; 
            }
        }
        system.debug('rwrap'+rwrap);
        return rwrap;
    }  
    
    @AuraEnabled  
    public static string createAccounts(List<Account> accList, string recordId){
        system.debug('%%accList'+accList);
        List<Opportunity> oppList = new List<Opportunity>();
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
           update  oppList;
        }
        return accList[0].Id;
    } 
    
    @AuraEnabled
    public static Boolean removeAgencyFromOpportunity(String recordId){
        List<Opportunity> oppList = [Select id, Agency_Name__c from Opportunity where id= :recordId];
       // oppList[0].Agency_Name__c = null;
        if(oppList.size() > 0){
            oppList[0].Agency_Name__c = null;
            update oppList;
            return true;
                }else{
                    return false;
                }
    }
    
    @AuraEnabled  
    public static boolean removeAccounts(string recordId){
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity Opp = [Select Id,AccountId,RecordType.Name from Opportunity where Id =:recordId];
        Opp.AccountId = null;
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
    public static Opportunity fetchBrokerAccountDetails(String recordId){
        List<Opportunity> oppList = [Select id, Agency_Name__c, Agency_Name__r.Name, Agency_Name__r.Email__c, 
									 Agency_Name__r.Trade_Licence_Number__c, Agency_Name__r.Primary_Mobile__c,
                                     Agency_Name__r.Trade_License_Number__c, Agency_Name__r.Primary_Country_Code__c,
                                     Agency_Name__r.Trade_License_Expiry_Date__c, Agency_Name__r.Primary_Email__c,
                                     Agency_Name__r.Rera_ORN__c, Agency_Name__r.Agency_Status__c from Opportunity where Id = :recordId];
        
        if(oppList.size() > 0 && oppList[0].Agency_Name__c != null){
            return oppList[0];
        }else{
            return null;
        }
    }
    
    @AuraEnabled  
    public static string createBrokerAccounts(List<Account> accList, string recordId){
        system.debug('%%accList'+accList);
        List<Opportunity> oppList = new List<Opportunity>();
        if(accList.size()>0 && string.isNotBlank(recordId)){
            Opportunity Opp = [Select Id,Agency_Name__c from Opportunity where Id =:recordId];
            Opp.Agency_Name__c = accList[0].Id;
            oppList.add(Opp);
        }
        if(oppList.size()>0){
           update  oppList;
        }
        return accList[0].Id;
    } 
    
    @AuraEnabled
    public static Map<String, Object> getAccountValues(string oppId){
        Map<String, Object> defaultValues = new Map<String, Object>();
        Opportunity Opp = [select Id,AccountId,Account.name,Account.FirstName,Account.LastName,Account.Customer_Nationality__c,Account.Primary_Email__c from Opportunity where Id =:oppId];
        //defaultValues.put('AccountId', Opp.AccountId);
        defaultValues.put('FirstName',Opp.Account.FirstName);
        defaultValues.put('LastName',Opp.Account.LastName);
        defaultValues.put('Customer_Nationality__c',Opp.Account.Customer_Nationality__c);
        defaultValues.put('Primary_Email__c',Opp.Account.Primary_Email__c);
        defaultValues.put('Name',Opp.Account.name);

        Map<String, Object> data = new Map<String, Object>();
        data.put('defaults', defaultValues);
        
        // get edit and read sections
        List<SObjectFieldWrapper> editFields = getSortedFieldSetFields('Account', 'Quick_Book_Fields');
        //List<SObjectFieldWrapper> readFields = getSortedFieldSetFields('Opportunity', 'Quick_Book_Fields');
        data.put('editFields', editFields);
        //data.put('readFields', readFields);
        system.debug('data'+data);
        return data;
    }
    
    @AuraEnabled
    public static Map<String, Object> getBrokerAccountValues(string oppId){
        Map<String, Object> defaultValues = new Map<String, Object>();
        Opportunity Opp = [select Id,AccountId,Account.name,Account.Trade_License_Number__c,Account.Phone,Account.Primary_Mobile__c,Account.Primary_Country_Code__c from Opportunity where Id =:oppId];

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
    
  /*  @AuraEnabled
    public static string createRecords(String recordJSON, String ObjectName, string recordId, Boolean personRecType, string accountId) {
        //sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
        System.debug('recordJSON '+recordJSON);
        system.debug('accountId'+accountId);
        Account sObj = new Account();
        Id recordTypeId;
        schema.SObjectType sobjType = Schema.getGlobalDescribe().get(ObjectName);
        Map<String, Schema.sObjectField> sObjectFields = sobjType.getDescribe().fields.getMap();
        Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(recordJSON);
        List<Opportunity> oppList = new List<Opportunity>();
        
        /*for(String fieldName : objMap.keySet()) {
            Object value = objMap.get(fieldName);
            Schema.DisplayType valueType = sObjectFields.get(fieldName).getDescribe().getType();
            if (value instanceof String && valueType != Schema.DisplayType.String){
                String svalue = (String)value;
                if (valueType == Schema.DisplayType.Date)
                    sObj.put(fieldName, Date.valueOf(svalue));
                else if(valueType == Schema.DisplayType.DateTime) {
                    try{
                        String d1 = svalue;
                        list<String> d2 = d1.split('-');
                        list<integer> timeComponent = new list<integer>();
                        timeComponent.add(Integer.valueOf(d2[0]));
                        timeComponent.add(Integer.valueOf(d2[1]));
                        timeComponent.add(Integer.valueOf(d2[2].left(2)));
                        String t = d2[2].substringBetween('T','.');
                        list<String> time1 = t.split(':');
                        timeComponent.add(Integer.valueOf(time1[0]));
                        timeComponent.add(Integer.valueOf(time1[1]));
                        timeComponent.add(Integer.valueOf(time1[2]));
                        Datetime dt = Datetime.newInstance(timeComponent[0],timeComponent[1],timeComponent[2],timeComponent[3],timeComponent[4],timeComponent[5]);
                        sObj.put(fieldName, dt);
                    }
                    catch(exception ex){
                        
                    }
                }
                else if (valueType == Schema.DisplayType.Percent || valueType == Schema.DisplayType.Currency)
                    sObj.put(fieldName, svalue == '' ? null : Decimal.valueOf(svalue));
                else if (valueType == Schema.DisplayType.Double)
                    sObj.put(fieldName, svalue == '' ? null : Double.valueOf(svalue));
                else if (valueType == Schema.DisplayType.Integer)
                    sObj.put(fieldName, Integer.valueOf(svalue));
                else if (valueType == Schema.DisplayType.Base64)
                    sObj.put(fieldName, Blob.valueOf(svalue));
                else
                    sObj.put(fieldName, svalue);
            }
            //else
                //sObj.put(fieldName, value);
        }
        
        if(string.isNotEmpty(accountId)){
            sObj.Id = accountId;  
        }else{
            if(personRecType == TRUE){
                recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(); 
            }else{
                recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business RecordType').getRecordTypeId();
                sObj.Name = objMap.get('FirstName') + ' '+objMap.get('LastName');
                objMap.remove('FirstName');
                objMap.remove('LastName');
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
        
        upsert sObj;
        
        Opportunity Opp = [Select Id,AccountId from Opportunity where Id =:recordId];
        Opp.AccountId = sObj.Id;
        Opp.Name = 'Quick Booking-' + sObj.LastName; 
        oppList.add(Opp);
        if(oppList.size()>0){
            update  oppList;
        }
        
        return sObj.Id;
    }*/
    
    @AuraEnabled
    public static List<Account> fetchExistingAccount(String jsonDt, String transactionId){
        Map<String, String> payLoadValues = new Map<String, String>();
        
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
        accList = [SELECT Id FROM Account WHERE Primary_Mobile__c =: payLoadValues.get('Mobile_No__c')];
        System.debug('@@@ accList '+ accList);
        if(accList.size() > 0){
            return accList;
        }else{
            
            Account newAcc = new Account();
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            newAcc.Name = 'Test Platform Events';
            newAcc.Record_Type__c = recordTypeId;
            //newAcc.Title = payLoadValues.get('Arabic_Title__c');  // need confirmation
            //newAcc. = payLoadValues.get('Passport_Type__c');
            newAcc.Passport_Number__c  = payLoadValues.get('Passport_Number__c');
            //newAcc.Emirates_Id__c  = payLoadValues.get('Emirates_Id_Number__c');  //we have two fields here withAPI name as 1. Emirates_Id__c(Number) 2. Emirates_Ids__c(Text)
            //Date issueDate = Date.parse(payLoadValues.get('Issue_Date__c'));
            //newAcc.Issue_Date__c  =  issueDate;
            //Date passportIssueDate = Date.parse(payLoadValues.get('Passport_Issue_Date__c'));
            //newAcc.Passport_Issue_Date__c  = passportIssueDate;
            //Date passExpiryDate = Date.parse(payLoadValues.get('Passport_Expiry_Date__c'));
            //newAcc.Passport_Expiry_Date__c  = passExpiryDate;
            //newAcc. = payLoadValues.get('Home_Address_Emirates_Code__c');
            //newAcc. = payLoadValues.get('UserId__c');  //formula field: USER_ID__c 
            //newAcc.Title = payLoadValues.get('Title__c');
            //newAcc. = payLoadValues.get('Transaction_Id__c');
            newAcc.Primary_Mobile__c  = payLoadValues.get('Mobile_No__c'); //need confirmation
            //newAcc. = payLoadValues.get('Arabic_Full_Name__c');
            //newAcc. = payLoadValues.get('Home_Address_Street__c');
            //Date DOB = Date.parse(payLoadValues.get('Date_of_birth__c'));
            //newAcc.Date_Of_Birth__c  = DOB;
            //newAcc. = payLoadValues.get('Full_Name__c');  // we have to capture this field from contact object.
            //newAcc. = payLoadValues.get('Home_Address_City__c');
            newAcc.Customer_Nationality__c = payLoadValues.get('Nationality__c');
            //Date expiryDate = Date.parse(payLoadValues.get('Expiry_Date__c'));
            //newAcc.Expiry_Date__c  = expiryDate;
            
            //newAcc. = payLoadValues.get('Id_Type__c');
            newAcc.Primary_Email__c  = payLoadValues.get('Email__c');   //person email is also available here.
            
            insert newAcc;
            accList.add(newAcc);
            return accList;
        }
    }
    
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
        @AuraEnabled public Boolean brokerExist;
        @AuraEnabled public Boolean EmployeeExist;
        @AuraEnabled public String brokerId; 
    }
}