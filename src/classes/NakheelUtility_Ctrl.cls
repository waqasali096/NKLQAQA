/**************************************************************************************************
* Name               : NakheelUtility_Ctrl                                                      
* Description        :
* Created Date       : 30/03/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      30/03/2022      Initial Draft. 
Note: Class is without sharing to avoid insufficient access on account share
**************************************************************************************************/

public without sharing class NakheelUtility_Ctrl {
    
    
    public static Account findMatchingAccount(sObject objSObject, string recType){
        system.debug('objSObject is '+ objSObject);
        String strObjectName = ((SObject) objSObject).getSObjectType().getDescribe().getName();
        sObject obj;
        String accType;
        String strAccountQuery;
        String matchQuery='';
        
        Account objAccount = new Account(); 
        //Added by Ashams
        //Checks to separate Lead & Account checks
        if(strObjectName == 'Lead'){
            obj = getAllsObjectDetails(objSObject , strObjectName);
            accType = String.valueof(obj.get('Type__c'));
            //strAccountQuery = getAccountQuery(strObjectName , accType , obj);
            matchQuery= getmatchQuery( strObjectName,  accType , obj);
            
        }
        
        else if(strObjectName == 'Account'){
            if(recType == 'Person'){ 
                accType = 'Person'; 
            }else{
                accType = 'Business'; 
            }
            //strAccountQuery = getAccountQuery(strObjectName , accType , objSObject );
             matchQuery= getmatchQuery( strObjectName,  accType , objSObject);
        }
        
        
        system.debug('matchQuery is '+ matchQuery);
        strAccountQuery = getAccountQuery( matchQuery ,  accType);
        
        system.debug('strAccountQuery is '+ strAccountQuery);

        Map<Id, Account> mapAccount = new Map<Id, Account> ();
        
        if(matchQuery!=''){
          mapAccount = new Map<Id, Account>((List<Account>)Database.query(strAccountQuery));
        }
        
        system.debug('mapAccount is '+ mapAccount);
        system.debug('mapAccount size '+ mapAccount.size());
        
        if(mapAccount.size() > 0 ){ //Account not present            
            if(mapAccount.size() > 1){ //Multiple Accounts found
                system.debug('strObjectName is '+ strObjectName);
               // if(strObjectName == 'Lead'){
                    //check for Higher number of Closed won Opportunities
                    List<AggregateResult> listAggregateResult = [SELECT AccountId, Count(Id) OpptyCount, Max(Account.LastModifiedDate) LatestLMDAccount 
                                                                 FROM Opportunity 
                                                                 WHERE AccountId IN: mapAccount.keySet() AND AccountId != null AND IsClosed = true AND IsWon = true
                                                                 GROUP BY AccountId
                                                                 ORDER BY Count(Id) DESC, Max(Account.LastModifiedDate) DESC 
                                                                 LIMIT 1];
                    system.debug('listAggregateResult is '+ listAggregateResult);
                    
                    if(!listAggregateResult.isEmpty() && listAggregateResult.size() == 1){
                        objAccount = mapAccount.get((Id)listAggregateResult[0].get('AccountId'));
                        system.debug('objAccount is '+ objAccount);
                    }
                //}
                //else if(strObjectName == 'Account'){
                else{
                    objAccount = mapAccount.values()[0];//Added by Ashams,return first account from the duplicate accounts
                }
                //}
            }
            else{ //Single Account found
                objAccount = mapAccount.values()[0];
                 system.debug('objAccount is '+ objAccount);
            } 
        }
        else{ //Create new Account
            objAccount = null;
             system.debug('objAccount is '+ objAccount);
        }
        
       
        system.debug('objAccountis '+ objAccount);
        
     
     
          //or Record IN [list of IDs]
     
        if(objAccount!=null){
                Integer AccountShareReadCount = [select count()
                                               from accountshare
                                               where userorgroupid = :UserInfo.getUserID()
                                               and accountid = :objAccount.ID AND (AccountAccessLevel='Read' OR  AccountAccessLevel='Edit'  OR  AccountAccessLevel='All')];
               system.debug('AccountShareReadCount is '+ AccountShareReadCount);
               system.debug([select id, AccountAccessLevel from AccountShare where userorgroupid = :UserInfo.getUserID()
                                               and accountid = :objAccount.ID]);
            
            if(AccountShareReadCount==0){
                AccountShare ls = new AccountShare();
                ls.AccountID   = objAccount.ID;
                ls.AccountAccessLevel='Edit';
                ls.UserOrGroupId = userInfo.getUserId();
                ls.OpportunityAccessLevel ='None';
                insert ls;
                system.debug('ls is '+ ls);
            }
            else{
                 AccountShare share =[select id, AccountAccessLevel from AccountShare where userorgroupid = :UserInfo.getUserID()
                                               and accountid = :objAccount.ID];
                if(share.AccountAccessLevel=='Read'){
                 share.AccountAccessLevel ='Edit';
                 update share;
                }
                
            }
               

            /*UserRecordAccess hasAccess =new UserRecordAccess();
            hasAccess=[SELECT RecordId FROM UserRecordAccess WHERE UserId =:UserInfo.getUserID() AND 
                                      RecordId =: objAccount.ID ];*/
            
           /* Integer AccountShareReadCount = [select count()
                                               from accountshare
                                               where userorgroupid = :UserInfo.getUserID()
                                               and accountid = :objAccount.ID AND AccountAccessLevel='Read' AND  AccountAccessLevel!='Edit'];
            
            Integer AccountShareEditCount = [select count()
                                               from accountshare
                                               where userorgroupid = :UserInfo.getUserID()
                                               and accountid = :objAccount.ID AND AccountAccessLevel='Edit'];
            
            
            system.debug('AccountShareEditCount is '+ AccountShareEditCount);
            system.debug([select ID ,AccountAccessLevel
                                               from accountshare
                                               where userorgroupid = :UserInfo.getUserID()
                                               and accountid = :objAccount.ID ]);
            
            if(AccountShareEditCount==0&& AccountShareReadCount==0){//Added to avoid error when already has access, as upsert doesnot suffice
                AccountShare ls = new AccountShare();
                ls.AccountID   = objAccount.ID;
                ls.AccountAccessLevel='Edit';
                ls.UserOrGroupId = userInfo.getUserId();
                ls.OpportunityAccessLevel ='None';
                insert ls;
                system.debug('ls is '+ ls);
            }  
            else if(AccountShareReadCount==1){
                  AccountShare share =[select id, AccountAccessLevel from AccountShare where userorgroupid = :UserInfo.getUserID()
                                               and accountid = :objAccount.ID];
                 share.AccountAccessLevel ='Edit';
                 update share;
                
            }*/
        }
        return objAccount;    
    }
    
    
    //Check if any condition is matching from metadata
    public static String getmatchQuery(String strObjectName, String accType ,sObject objSObject){
        Map<String, Schema.SObjectField> mapSObjectFieldLead = Schema.SObjectType.Account.fields.getMap();
        String matchQuery ='';
        List<Find_Matching_Account_Setting__mdt > mdtLst = getMatchAccntSetting_Metadata(objSObject, strObjectName , accType);
        system.debug('mdtLst is '+ mdtLst);
        
        for(Find_Matching_Account_Setting__mdt mdt : mdtLst){
            if(matchQuery==''){
                if((objSObject.get(mdt.Source_Field__c))!=null ){  
                    matchQuery +=     ' AND ( ' + prepareWhereClauseSOQL(mapSObjectFieldLead, mdt, objSObject);
                }
                
            }
            else{
                if((objSObject.get(mdt.Source_Field__c))!=null  && mdt.Is_Old_Migrated_Record__c==false){ 
                    matchQuery +=   ' OR ' + prepareWhereClauseSOQL(mapSObjectFieldLead, mdt, objSObject);
                }
                
                else if((objSObject.get(mdt.Source_Field__c))!=null  && mdt.Is_Old_Migrated_Record__c==true){ 
                    matchQuery +=   ' AND ' + prepareWhereClauseSOQL(mapSObjectFieldLead, mdt, objSObject);
                }
            }                                                              
            
        } 
        system.debug('matchQuery is '+ matchQuery);
        return matchQuery;     
        
    }
    
   
    public static String getAccountQuery(String matchQuery , String accType){
         
        String byPassUserID = system.label.Bypass_for_Creator ;
        String strAccountQuery = 'SELECT Id, Name FROM Account WHERE Id != null ';
        if(system.label.Bypass_for_Creator !=''){
            strAccountQuery += ' AND CREATEDBY.ID != \'' ;// + byPassUserID+ '\'   ;//To prevent hampering UAT data
            strAccountQuery+= system.label.Bypass_for_Creator;
            strAccountQuery+= '\'';
        }
       
        if(accType=='Person'){
            strAccountQuery+= ' AND (IsPersonAccount = true )  '; 
        }
        else{
            strAccountQuery+= ' AND (IsPersonAccount = false  )  ';  
        }
       
        if(matchQuery==''){
            strAccountQuery+=  '  LIMIT 1000 ' ;
        }
        if(matchQuery!=''){
            strAccountQuery+=  matchQuery  + '  )'  ;
        }
        
        system.debug('getAccountQuery is '+ strAccountQuery);
        return strAccountQuery;    
        
    }
    
    //method to get metadata fields to compare
    public static List<Find_Matching_Account_Setting__mdt > getMatchAccntSetting_Metadata(sObject objSObject ,String strObjectName, String accType){
        
         String metadataquery ='SELECT Id, Account_Type__c, Account_Field__c, Source_Object__c,Is_Old_Migrated_Record__c, Source_Field__c ,Is_Resident__c FROM  '+
                             '  Find_Matching_Account_Setting__mdt  WHERE Source_Object__c =: strObjectName AND '+ 
                             '  Account_Type__c=:accType ';
        
        if(strObjectName=='Lead'){
            system.debug(objSObject.get('Resident__c'));
            Boolean isResident = Boolean.valueof(objSObject.get('Resident__c'));
            Boolean isOldRecord = Boolean.valueof(objSObject.get('Migrated_Old_Record__c'));
            if(isResident && !isOldRecord){//if record is not migrated old record and It is a Resident
                metadataquery += ' AND Is_Resident__c =True ';
            }
            
            else if(!isResident && !isOldRecord){//if record is not migrated old record and It is a Resident
                metadataquery += ' AND Is_Resident__c =False ';
            }
            
             else if(isOldRecord ){//if record is  migrated old record and It is a Person Account Lead
                metadataquery += ' AND Is_Resident__c =False  AND Is_Old_Migrated_Record__c=True';
            }
            
             
            
            
        }  
        
        if(strObjectName=='Account'){
            system.debug(objSObject.get('Country_Of_Residence__c'));
            Boolean isResident;
            if(objSObject.get('Country_Of_Residence__c') == 'AE'){
                isResident = TRUE;
            }else{
               isResident = FALSE; 
            }
            if(isResident){
                metadataquery += ' AND Is_Resident__c =True ';
            }
            else if(!isResident){
                metadataquery += ' AND Is_Resident__c =False ';
            }
            //else if(isOldRecord ){//if record is  migrated old record and It is a Person Account Lead
              //  metadataquery += ' AND Is_Resident__c =False  AND Is_Old_Migrated_Record__c=True';
            //}         
        }  
        system.debug('metadataquery is '+ metadataquery);
        
        List<Find_Matching_Account_Setting__mdt > mdtLst = Database.query(metadataquery);
        return mdtLst;     
        
    }
    
    //Return all fields query from sObject
    public static sObject getAllsObjectDetails(sObject objSObject ,String strObjectName){
        String recordId = (String)objSObject.get('Id');
        Set<String> setObjectFields = Schema.getGlobalDescribe().get(strObjectName).getDescribe().fields.getMap().keySet();        
        String strLeadQuery = 'SELECT ' + String.join(new List<String>(setObjectFields), ',');
        strLeadQuery += ' FROM ' + strObjectName + ' WHERE Id =: recordId';
        objSObject = Database.query(strLeadQuery);
        return objSObject;
    }
    
    
  
        
    public static String prepareWhereClauseSOQL(Map<String, Schema.SObjectField> mapSObjectFieldLead, Find_Matching_Account_Setting__mdt objFMA, sObject objSObject){
        system.debug('objSObject is '+ objSObject);
        String strQuery = '';
        system.debug('mapSObjectFieldLead.get(objFMA.Account_Field__c) is '+ mapSObjectFieldLead.get(objFMA.Account_Field__c));
        if(String.valueOf(mapSObjectFieldLead.get(objFMA.Account_Field__c).getDescribe().getType()) == 'DATE'){
            if((objSObject.get(objFMA.Source_Field__c))!=null){
                strQuery +=  objFMA.Account_Field__c + '= ' + String.valueOf(objSObject.get(objFMA.Source_Field__c)).removeEnd(' 00:00:00');
            }
        }
        else{
            if((objSObject.get(objFMA.Source_Field__c))!=null){
                strQuery +=   objFMA.Account_Field__c + '= \'' + objSObject.get(objFMA.Source_Field__c) + '\'';
            }
        }
        
        return strQuery;
    }
    
}