public with sharing class ExportToExcelController { 
    public class UnitWrapper{  
      @AuraEnabled  
      public string UnitNumber;  
      @AuraEnabled  
      public String UnitPrice; 
      @AuraEnabled  
      public String Status;
      @AuraEnabled  
      public String ProjectName;  
      public UnitWrapper(Unit__c unitObj){  
        this.UnitNumber = unitObj.Unit_Code__c;  
        this.UnitPrice = '';  
        this.Status = unitObj.Unit_Status__c;
        this.ProjectName = unitObj.Project__r.name;
      }  
    }  
    @AuraEnabled  
    public static List<UnitWrapper> getUnits(String PricebookId){ 
      system.debug('***'+PricebookId); 
      Price_Book__c prId = [select id,Project__c from Price_Book__c where Id=:PricebookId];
      List<UnitWrapper> unitWrapperList = new List<UnitWrapper>();  
      for(Unit__c cwObj : [select id,Project__c,Unit_Status__c,Project__r.name, Unit_Code__c,Unit_Number__c, Selling_Price__c from Unit__c where Project__c=:prId.Project__c AND Unit_Code__c!=Null]){  
        unitWrapperList.add(new UnitWrapper(cwObj));  
      }  
      return unitWrapperList;  
    }  
  }