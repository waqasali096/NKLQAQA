public class UnitLeasingWrapperClass {
    
        public class filtersWrapper {
        
        @AuraEnabled
       public Map<String, String> propertyType{get;set;}
            
             @AuraEnabled
       public Map<String, String> unitType{get;set;}
        
        @AuraEnabled
       public Map<String, String> LocationMap{get;set;}
            
        @AuraEnabled
       public Map<String, String> NoOfBedroomsMap{get;set;}
        
        @AuraEnabled
       public Map<String, String> spaceMap{get;set;}
        
        @AuraEnabled
        public Map<String,String> projectMap{get;set;}
        
        @AuraEnabled
        public Map<String,String>  buildingMap{get;set;}
        
        @AuraEnabled
        public Map<String,String>  clusterMap{get;set;}
        
        @AuraEnabled
        public Opportunity oppRecord{get;set;}
            
        @AuraEnabled
        public List<Unit_Plan__c> unitList{get;set;}
        
        @AuraEnabled 
        public List<unitwrapper> unitWrapper{get;set;}    
        
        
    }
        public class unitwrapper {
        @AuraEnabled 
        public Unit__c unit{get;set;}
        
        @AuraEnabled
        public Boolean propFlag{get;set;}
            
        @AuraEnabled
        public Boolean activeFlag{get;set;}
    }


}