/**************************************************************************************************
* Name               : QuickCreateLead_Ctrl                                                      
* Description        : Create Lead 
* Created Date       : 07/04/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      07/04/2022      Initial Draft.                                               
**************************************************************************************************/
public class QuickCreateLead_Ctrl {
    
     @AuraEnabled
    public static leadWrapper getWrapperValues(){
        leadWrapper wrp = new leadWrapper();
        wrp.leasingTypes=    getPicklistvalues('Lead', 'Leasing_Type__c');
        return wrp;    
    }
    
    
    @AuraEnabled
    public static String getRecordTypeID(String leasingType){
        system.debug('leasingType is '+ leasingType);
        String recordTypeName='';    
        if(leasingType==system.label.Lead_Commercial_Unit) {
            recordTypeName= system.label.Lead_Commercial_Unit_Rec_Type;
        }
        
        else if(leasingType==system.label.Lead_Res_Leasing_Type	){
            recordTypeName = system.label.Lead_Res_Unit_Record_Type	;
            
        }
        system.debug('recordTypeName is '+ recordTypeName);
        String recordTypeID = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        system.debug('recordTypeID is '+ recordTypeID);
        return recordTypeID;
}
    
    
    
   //get picklist values dynamically based on object name and field name
   @AuraEnabled
    public static Map<String, String> getPicklistvalues(String objectName, String field_apiname){
        Map<String, String> options = new Map<String, String>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry p: picklistValues) {
            options.put(p.getValue(), p.getLabel());
        }
        system.debug('options are '+ options);
        return options;
    }  
    public class leadWrapper{
    @AuraEnabled    
    public Map<String, String> leasingTypes;
    @AuraEnabled     
    public Map<String, String> propertyTypes;
     
    }

}