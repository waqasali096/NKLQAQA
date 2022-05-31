/* Name:NakheelUtility
* Description: Utility Class to hold Generic Metgods
* Created Date: 01/01/2022
* LastModified Date: 30/03/2022
*LastModifiedBy: Mamta Gupta
*/
public class NakheelUtility {
     /*
	* @author : Hitesh Patel
	* @usage : find duplicate accounts for leads & Accounts
			   fields to check are configured in Find_Matching_Account_Setting__mdt metadata
	* @params : sObject record to compare
	*/
    public static Account findMatchingAccount(sObject objSObject){
        Account objAccount;
        
        if(objSObject != null){
            objAccount = new Account();
            String strObjectName = ((SObject) objSObject).getSObjectType().getDescribe().getName();
            
            Map<String, List<Find_Matching_Account_Setting__mdt>> mapFMAByAccountType = new Map<String, List<Find_Matching_Account_Setting__mdt>>();
            for(Find_Matching_Account_Setting__mdt objFMA : [SELECT Id, Account_Type__c, Account_Field__c, Source_Object__c, Source_Field__c FROM Find_Matching_Account_Setting__mdt WHERE Source_Object__c =: strObjectName]){
                List<Find_Matching_Account_Setting__mdt> listFMA = new List<Find_Matching_Account_Setting__mdt>();
                if(mapFMAByAccountType.containsKey(objFMA.Account_Type__c)){
                    listFMA = mapFMAByAccountType.get(objFMA.Account_Type__c);
                }
                listFMA.add(objFMA);
                mapFMAByAccountType.put(objFMA.Account_Type__c, listFMA);
            }
            
            String recordId = (String) objSObject.get('Id');
            //Lead ld =[select id, company from Lead where id=:recordId]
            Set<String> setObjectFields = Schema.getGlobalDescribe().get(strObjectName).getDescribe().fields.getMap().keySet();        
            String strLeadQuery = 'SELECT ' + String.join(new List<String>(setObjectFields), ',');
            strLeadQuery += ' FROM ' + strObjectName + ' WHERE Id =: recordId';
            objSObject = Database.query(strLeadQuery);
            
            String strAccountQuery = 'SELECT Id, Name FROM Account WHERE Id != null ';
            
            boolean isPersonLead =true;
            if(objSObject.get('Company')!=null){
               isPersonLead = false; 
            }
            
            Map<String, Schema.SObjectField> mapSObjectFieldLead = Schema.SObjectType.Account.fields.getMap();
            String matchQuery ='';
            //Prepare WHERE Clause if both Person & Business Type criteria present in Custom Metadata
            if(mapFMAByAccountType.containsKey('Person') && mapFMAByAccountType.containsKey('Business')){
                Boolean blnPersonAccountCheckIncluded = false;
                List<Find_Matching_Account_Setting__mdt> mdtLst = new List<Find_Matching_Account_Setting__mdt>();
                system.debug('mdtLst is '+ mdtLst);
                if(isPersonLead==true){
                    mdtLst = mapFMAByAccountType.get('Person');
                     strAccountQuery += ' AND (IsPersonAccount = true ) ';
                }
                else{
                      mdtLst = mapFMAByAccountType.get('Business');
                      strAccountQuery += ' AND (IsPersonAccount = false ) ';
                }
                for(Find_Matching_Account_Setting__mdt objFMA : mdtLst/*mapFMAByAccountType.get('Person')*/){
                    if(objSObject.get(objFMA.Source_Field__c) != null){                    
                       /* if(!blnPersonAccountCheckIncluded){
                            //strAccountQuery += ' AND ((IsPersonAccount = true ';
                             strAccountQuery += ' AND (IsPersonAccount = true )    ';
                            // blnPersonAccountCheckIncluded = true;
                        } 
                        
                        else{
                            //strAccountQuery += ' AND ((IsPersonAccount = true ';
                             strAccountQuery += ' AND (IsPersonAccount = false )    ';
                             //blnPersonAccountCheckIncluded = true;
                        }*/  
                       // strAccountQuery += ' OR  ' + prepareWhereClauseSOQL(mapSObjectFieldLead, objFMA, objSObject);
                        if(matchQuery==''){
                           matchQuery +=     ' AND ( ' + prepareWhereClauseSOQL(mapSObjectFieldLead, objFMA, objSObject);
                        }
                        else{
                             matchQuery +=   ' OR ' + prepareWhereClauseSOQL(mapSObjectFieldLead, objFMA, objSObject);
                        }
                        
                    } 
                }
                strAccountQuery += matchQuery;
                if(blnPersonAccountCheckIncluded){
                   // strAccountQuery += ')';
                }
                
                /*Boolean blnBusinessAccountCheckIncluded = false;
                for(Find_Matching_Account_Setting__mdt objFMA : mapFMAByAccountType.get('Business')){
                    if(objSObject.get(objFMA.Source_Field__c) != null){                    
                        if(!blnBusinessAccountCheckIncluded && blnPersonAccountCheckIncluded){
                            strAccountQuery += ' OR (IsPersonAccount = false ';
                            blnBusinessAccountCheckIncluded = true;
                        }else{
                            if(blnBusinessAccountCheckIncluded && !blnPersonAccountCheckIncluded){
                                strAccountQuery += ' AND (IsPersonAccount = false ';
                                blnBusinessAccountCheckIncluded = true;
                            }
                        }
                        strAccountQuery += prepareWhereClauseSOQL(mapSObjectFieldLead, objFMA, objSObject);                  
                    } 
                }
                
                if(blnBusinessAccountCheckIncluded && blnPersonAccountCheckIncluded){
                    strAccountQuery += '))';
                }
                
                if(!blnBusinessAccountCheckIncluded && blnPersonAccountCheckIncluded){
                    strAccountQuery += ')';
                }
                
                  system.debug('if');*/
            }
            else{
                
                system.debug('else');
                
                //Prepare WHERE Clause if OLNY Person Type criteria present in Custom Metadata
                if(mapFMAByAccountType.containsKey('Person')){
                    strAccountQuery += ' AND (IsPersonAccount = true ';
                    for(Find_Matching_Account_Setting__mdt objFMA : mapFMAByAccountType.get('Person')){
                        if(objSObject.get(objFMA.Source_Field__c) != null){
                            strAccountQuery += prepareWhereClauseSOQL(mapSObjectFieldLead, objFMA, objSObject); 
                        } 
                    }
                    strAccountQuery += ')';
                }
                
                //Prepare WHERE Clause if OLNY Business Type criteria present in Custom Metadata
                if(mapFMAByAccountType.containsKey('Business')){
                    strAccountQuery += ' AND (IsPersonAccount = false ';
                    for(Find_Matching_Account_Setting__mdt objFMA : mapFMAByAccountType.get('Business')){
                        if(objSObject.get(objFMA.Source_Field__c) != null){
                            strAccountQuery += prepareWhereClauseSOQL(mapSObjectFieldLead, objFMA, objSObject); 
                        }
                    }
                    strAccountQuery += ')';
                }
            }        
            strAccountQuery += ' ORDER BY LastModifiedDate DESC';   
            
            system.debug('****strAccountQuery => '+strAccountQuery);
            
            Map<Id, Account> mapAccount = new Map<Id, Account>((List<Account>)Database.query(strAccountQuery));
            
            if(mapAccount.size() > 0){ //Account not present            
                if(mapAccount.size() > 1){ //Multiple Accounts found
                    if(strObjectName == 'Lead'){
                        //check for Higher number of Closed won Opportunities
                        List<AggregateResult> listAggregateResult = [SELECT AccountId, Count(Id) OpptyCount, Max(Account.LastModifiedDate) LatestLMDAccount 
                                                                     FROM Opportunity 
                                                                     WHERE AccountId IN: mapAccount.keySet() AND AccountId != null AND IsClosed = true AND IsWon = true
                                                                     GROUP BY AccountId
                                                                     ORDER BY Count(Id) DESC, Max(Account.LastModifiedDate) DESC 
                                                                     LIMIT 1];
                        
                        if(!listAggregateResult.isEmpty() && listAggregateResult.size() == 1){
                            objAccount = mapAccount.get((Id)listAggregateResult[0].get('AccountId'));
                        }
                    }
                    
                    if(strObjectName == 'Account'){
                        //check for Latest LastModifiedDate on Account
                        List<AggregateResult> listAggregateResult = [SELECT Id, Max(LastModifiedDate) LatestLMDAccount 
                                                                     FROM Account 
                                                                     WHERE Id IN: mapAccount.keySet() AND Id != null
                                                                     GROUP BY Id
                                                                     ORDER BY Count(Id) DESC, Max(LastModifiedDate) DESC 
                                                                     LIMIT 1];
                        
                        if(!listAggregateResult.isEmpty() && listAggregateResult.size() == 1){
                            objAccount = mapAccount.get((Id)listAggregateResult[0].get('Id'));
                        }
                    }      
                }
                else{ //Single Account found
                    objAccount = mapAccount.values()[0];
                }      
            }
            else{ //Create new Account
                objAccount = null;
            }
        }
        system.debug('objAccount is '+ objAccount);
        return objAccount;
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