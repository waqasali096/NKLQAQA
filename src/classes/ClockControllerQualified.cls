public class ClockControllerQualified {
   
     @AuraEnabled
    public static Lead getEndTime(Id recordId) {
        Lead l = [select SLA_Expected_Time_For_Qualified__c,SLA_Response_Time_For_Qualified__c  from Lead where id=: recordId];
        return l;
    }
    
    @AuraEnabled
    public static Lead getResponseTime(Id recordId) {
        Lead l = [select id,SLA_Expected_Time_For_Qualified__c,SLA_Response_Time_For_Qualified__c  from Lead where /*SLA_Response_Time_For_Qualified__c  != Null AND*/ id=: recordId];
        system.debug('l is '+ l);
        system.debug(l.SLA_Response_Time_For_Qualified__c > l.SLA_Expected_Time_For_Qualified__c);
        system.debug(l.SLA_Response_Time_For_Qualified__c <= l.SLA_Expected_Time_For_Qualified__c);

        return l;
    }
    
    @AuraEnabled
    public static boolean isSLAAcheived(Id recordId) {
        
        Lead l = [select SLA_Expected_Time_For_Qualified__c,SLA_Response_Time_For_Qualified__c  from Lead where/* SLA_Response_Time_For_Qualified__c  != Null AND*/ id=: recordId];

        boolean isAcheived= false;
        if(l.SLA_Response_Time_For_Qualified__c !=null && l.SLA_Response_Time_For_Qualified__c !=null){
            
            if(l.SLA_Response_Time_For_Qualified__c <= l.SLA_Response_Time_For_Qualified__c ){
               isAcheived = true; 
            }
        }
        return isAcheived;
    }
}