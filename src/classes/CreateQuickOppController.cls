/**
* @author : Ashams
* @createdDate : 30-Jan-2022
* @purpose : Used in Quick Booking Process - Sales
* @usage : controller for CreateQuickOpp Component
*/
public class CreateQuickOppController {
    //Method to set default values for Quick Opp
    @AuraEnabled
    public static Map<String,Object> getQuickOppDefaultValue(){
        Map<String, Object> defaultValues = new Map<String, Object>();
        defaultValues.put('Name', 'Quick Booking');
        defaultValues.put('StageName', 'Choose Units');
        defaultValues.put('CloseDate', Date.today());
        Map<String, Object> data = new Map<String, Object>();
        data.put('defaults', defaultValues);
        return data;
    }
    
    // Method to get the Projects List 
    @AuraEnabled
    public static List<Project__c> fetchProjects(){
        List<Project__c> projLists = new List<Project__c>();
       	projLists = [select Id,Name,Available_Units__c from Project__c where Project_Purpose__c = 'Sales']; 
        return projLists;
    }
    
    // Method to get the Create Quick Booking opportunity 
    @AuraEnabled  
    public static ResultWrapper createOpps(String oppValues){
        ResultWrapper wrap = new ResultWrapper();
        Map<String,Object> objMap = (Map<String,Object>) JSON.deserializeUntyped(oppValues);
        system.debug('%%objMap'+objMap);
        List<Opportunity> oppList = new List<Opportunity>();
        try{
            if(objMap.size()>0){
                Opportunity sObj = new Opportunity();
                sObj.Name = 'Quick Booking';
                sObj.StageName = 'Choose Units';
                sObj.RecordTypeId = System.Label.Quick_Book_Record_Id;
                sObj.CloseDate = Date.today();
                //sObj.Project__c = String.valueof(objMap.get('Project__c'));
                oppList.add(sObj);
            }
            if(oppList.size()>0){
                insert oppList;
                system.debug('oppList'+oppList);
                wrap.success = true;
                wrap.message = 'Quick Booking Created';
                wrap.recId = oppList[0].Id;
            } 
        }catch(Exception e){
            wrap.success = false;
            wrap.message = e.getMessage();
            wrap.recId = null; 
        }
        return wrap;
    } 
    
	 public class ResultWrapper{
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public String recId;
    }   
}