/*
Class Name: AddSalesExecutive.
Class Description: Adding members to sales events.
Author: Karan Jain
Created Date: 01/04/2022
Updated by: 
Last Update Date:
*/
public without sharing class AddSalesExecutive {
    
    /*Purpose : get Users list based on selected profile,remove the previously added members from list
* Modified by Ashams on 03/04/2022
* Changes : Changed return type to wrapper
*/
    @AuraEnabled(cacheable=false)
    public static List<resultWrapper> getUser(String salesEventRecordId,String profileName, string salesManagerId){
        Set<Id> useridSet = new Set<Id>();
        List<User> userList = new List<User>();
        List<resultWrapper> userWrapperList = new List<resultWrapper>();
        
        Sales_Event__c salesEvent = [SELECT Id,start_date__c,end_date__c,(select Id,User__c from Sales_Event_Executives__r) 
                                     FROM Sales_Event__c WHERE Id=:salesEventRecordId limit 1];
        if(salesEvent!=null && salesEvent.Sales_Event_Executives__r.size()>0){
            for(Sales_Event_Executive__c exec : salesEvent.Sales_Event_Executives__r){
                useridSet.add(exec.User__c);
            }
        }
        if(useridSet.size()>0){
            userList = [SELECT Id, Name FROM User WHERE Profile.Name =:profileName AND ID NOT IN : useridSet]; 
        }else {
            userList = [SELECT Id, Name FROM User WHERE Profile.Name =:profileName];
        }
        
        if(string.isNotEmpty(salesManagerId)){
            for(User user : [SELECT Id, Name FROM User WHERE ManagerId =: salesManagerId]){
                userList.add(user);
            }
        }
        
        if(userList.size()>0){
            for(user u:userList){
                resultWrapper rwrap = new resultWrapper();
                rwrap.userName = u.Name;
                rwrap.userId = u.Id;
                rwrap.startDate = salesEvent.Start_Date__c;
                rwrap.endDate = salesEvent.End_Date__c;
                rwrap.isSelected  = false;
                rwrap.startDateError = false;
                rwrap.endDateError = false;
                userWrapperList.add(rwrap);
            }
        }
        return userWrapperList;
    }
    
    /*Purpose : create sales event executives based on selection
* Modified by Ashams on 03/04/2022
* Changes : changed params type for salesExecutiveData
*/
    @AuraEnabled
    public static boolean createSalesExecutive( string salesExecutiveData, String salesEventRecordId){
        List<resultWrapper> salesExecutivesList = (List<resultWrapper>)JSON.deserialize(salesExecutiveData,List<resultWrapper>.class);
        List<Sales_Event_Executive__c> salesEventExecutiveList = new List<Sales_Event_Executive__c>();
        List<String> listUsrId = new List<String>();
        List<Sales_Event_Executive__c> salesExecListtoDelete = new List<Sales_Event_Executive__c>();
        Map<String,Sales_Event_Executive__c> salesExecUserIdmap = new Map<String,Sales_Event_Executive__c>();
        
        List<Sales_Event_Executive__c> existingSalesExecList = [SELECT Id,User__c FROM Sales_Event_Executive__c 
                                                                WHERE Sales_Event__c = : salesEventRecordId ];
        for(Sales_Event_Executive__c obj : existingSalesExecList){
            salesExecUserIdmap.put(obj.User__c, obj);
        }
        
        for(resultWrapper salesEventExec: salesExecutivesList){
            Sales_Event_Executive__c obj = new 	Sales_Event_Executive__c();
            if(salesExecUserIdmap.containsKey(salesEventExec.userId)){
                obj.Id = salesExecUserIdmap.get(salesEventExec.userId).Id;
                salesExecListtoDelete.add(obj);
            }else{
                obj.User__c = salesEventExec.userId;
                obj.Name = salesEventExec.userName;
                obj.Start_date__c = salesEventExec.startDate;
                obj.End_Date__c = salesEventExec.endDate;
                obj.Sales_Event__c = salesEventRecordId;
                salesEventExecutiveList.add(obj);    
            }
        }
        try{
            if(!salesExecListtoDelete.isEmpty()){
                delete salesExecListtoDelete;
            }
            if(!salesEventExecutiveList.isEmpty()){
                insert salesEventExecutiveList;
            }
            return true;
        }catch(Exception e){
            system.debug('Error'+e.getMessage());
            return false;
        }
    } 
    
    public class resultWrapper{
        @AuraEnabled public string userName;
        @AuraEnabled public string userId;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public Boolean isSelected;
        @AuraEnabled public boolean startDateError;
        @AuraEnabled public boolean endDateError;
    }
    
    @AuraEnabled
    public static String getSalesExecutive(String salesEventRecordId,Integer pageSizeExisting, Integer pageNumberExisting){
        String jsonDT = '';
        
        //Offset for SOQL
        Integer offset = (pageNumberExisting - 1) * pageSizeExisting;
        
        //Total Records
        Integer totalRecords = [SELECT COUNT() FROM Sales_Event_Executive__c where Sales_Event__c =:salesEventRecordId];
        Integer recordEnd = pageSizeExisting * pageNumberExisting;
        
        salesEventRecordWrapper objDT =  new salesEventRecordWrapper();  
        objDT.pageSize = pageSizeExisting;
        objDT.pageNumber = pageNumberExisting;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.salesEventList = [Select Id,Name,User__c,End_Date__c,Start_Date__c from Sales_Event_Executive__c 
                                where Sales_Event__c =:salesEventRecordId LIMIT :pageSizeExisting OFFSET :offset];
        jsonDT = JSON.serialize(objDT);
        return jsonDT;
    }
    /*  List<Sales_Event_Executive__c> salesEventExc = [Select Id,Name,User__c,End_Date__c,Start_Date__c from Sales_Event_Executive__c 
where Sales_Event__c =:salesEventRecordId];
if(salesEventExc.size() > 0){
return salesEventExc;
}
else{
return null; 
}*/
    
    public class salesEventRecordWrapper {
        public Integer pageSize {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordStart {get;set;}
        public Integer recordEnd {get;set;}
        public List<Sales_Event_Executive__c> salesEventList {get;set;}
    }
    
    @AuraEnabled
    public static List<Sales_Event_Executive__c>  removeSalesExecutiveEvent(List<String> salesExcecutiveEventRecordId){
        List<Sales_Event_Executive__c> salesEventExc = new List<Sales_Event_Executive__c> () ;
        if(salesExcecutiveEventRecordId.size()>0){
            salesEventExc = [Select Id,Name,User__c,End_Date__c,Start_Date__c from Sales_Event_Executive__c 
                             where Id IN :salesExcecutiveEventRecordId];   
        }
        
        if(salesEventExc.size()>0){
            Delete salesEventExc;
        }
        return salesEventExc;
        
    }
    @AuraEnabled
    public static String getuserDataList(String salesEventRecordId,String profileName, string salesManagerId,Integer pageSize, Integer pageNumber){
        Integer offset = (pageNumber - 1) * pageSize;
        List<resultWrapper> userWrapperList = new List<resultWrapper>();
        Set<Id> useridSet = new Set<Id>();
        List<User> userList = new List<User>();
        Integer userListForCount = 0 ;
        Sales_Event__c salesEvent = [SELECT Id,start_date__c,end_date__c,(select Id,User__c from Sales_Event_Executives__r) 
                                     FROM Sales_Event__c WHERE Id=:salesEventRecordId limit 1];
        if(salesEvent!=null && salesEvent.Sales_Event_Executives__r.size()>0){
            for(Sales_Event_Executive__c exec : salesEvent.Sales_Event_Executives__r){
                useridSet.add(exec.User__c);
            }
        }

        if(string.isNotEmpty(salesManagerId)){
            userListForCount = [SELECT count() FROM User WHERE ID NOT IN : useridSet AND (ManagerId =: salesManagerId OR Id =:salesManagerId)];
            for(User user : [SELECT Id, Name FROM User WHERE ID NOT IN : useridSet AND (ManagerId =: salesManagerId OR Id =:salesManagerId)  LIMIT :pageSize OFFSET :offset]){
                userList.add(user);
            }
        }
        else{
            if(useridSet.size()>0){
                userList = [SELECT Id, Name FROM User WHERE Profile.Name =:profileName AND ID NOT IN : useridSet LIMIT :pageSize OFFSET :offset]; 
                userListForCount = [SELECT count() FROM User WHERE Profile.Name =:profileName AND ID NOT IN : useridSet];
            }else {
                userList = [SELECT Id, Name FROM User WHERE Profile.Name =:profileName LIMIT :pageSize OFFSET :offset];
                userListForCount = [SELECT count() FROM User WHERE Profile.Name =:profileName];
    
            }
        }
        if(userList.size()>0){
            for(user u:userList){
                resultWrapper rwrap = new resultWrapper();
                rwrap.userName = u.Name;
                rwrap.userId = u.Id;
                rwrap.startDate = salesEvent.Start_Date__c;
                rwrap.endDate = salesEvent.End_Date__c;
                rwrap.isSelected  = false;
                rwrap.startDateError = false;
                rwrap.endDateError = false;
                userWrapperList.add(rwrap);
            }
        }
        String jsonDT = '';
        
        //Offset for SOQL
        
        
        //Total Records
        Integer totalRecords = userListForCount;
        Integer recordEnd = pageSize * pageNumber;
        
        UserDTWrapper objDT =  new UserDTWrapper();  
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.userWrapperList = userWrapperList;
        jsonDT = JSON.serialize(objDT);
        return jsonDT;
    }
    public class UserDTWrapper {
        public Integer pageSize {get;set;}
        public Integer pageNumber {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordStart {get;set;}
        public Integer recordEnd {get;set;}
        public List<resultWrapper> userWrapperList {get;set;}
    }
    
}