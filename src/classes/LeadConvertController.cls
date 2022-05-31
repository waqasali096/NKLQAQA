/**************************************************************************************************
* Name               : LeadConvertController                                                      
* Description        :
* Created Date       : 30/03/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      30/03/2022      Initial Draft.                                               
**************************************************************************************************/

public class LeadConvertController {
    
    @AuraEnabled
    public static ResultWrapper leadConvertMethod(String leadId){
        ResultWrapper objResultWrapper = new ResultWrapper();
        Lead ld =[select id,EID_Emirates_ID__c,Migrated_Old_Record__c ,
                  Company,Passport_Number__c,Trade_License_Number__c, Is_custom_convert__c ,
                  RecordType.DeveloperName,status ,Follow_Up_Done__c from Lead where id=: leadID];
        
        ld.Is_custom_convert__c = true;
        update ld;  
        
         //system.debug('ld.EID_Emirates_ID__c is '+ ld.EID_Emirates_ID__c); 
         //system.debug('ld.Passport_Number__c is '+ ld.Passport_Number__c); 
         system.debug(ld.Company);
         system.debug(ld.Trade_License_Number__c);
        if(!ld.Follow_Up_Done__c && ld.RecordType.DeveloperName!=system.label.Lead_WalkIn_RecordType){
           objResultWrapper.strMessage = 'Please complete all open activities before converting Lead ';
        }
        
      
       else if(((ld.EID_Emirates_ID__c==null ) && ld.Passport_Number__c==null) && ld.Company==null && 
               ld.Trade_License_Number__c==null && ld.Migrated_Old_Record__c==false){
               objResultWrapper.strMessage = 'Please fill either EID or passport for person Accounts ';
        }
        else if( ld.Company!=null && ld.Trade_License_Number__c==null && ld.Migrated_Old_Record__c==false){
             objResultWrapper.strMessage = 'Please fill Trade Liscence Number  for business Accounts ';
        }
        else if( ld.Company==null && ld.Trade_License_Number__c!=null && ld.Migrated_Old_Record__c==false){
             objResultWrapper.strMessage = 'Please fill Company  for business Accounts ';
        }
        
        else{
        
        try{
            LeadStatus CLeadStatus= [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true Limit 1];
            Database.LeadConvert objLeadConvert = new Database.LeadConvert();    
            objLeadConvert.setLeadId(Id.valueOf(leadId));
            Lead objLead = new Lead(Id= Id.valueOf(leadId));
            Account objAccount = NakheelUtility_Ctrl.findMatchingAccount(objLead, '');
            if(objAccount != null){            
                objLeadConvert.setAccountId(objAccount.Id);  
            }
            objLeadConvert.setConvertedStatus(CleadStatus.MasterLabel);
            //commented By Mamta
           Database.LeadConvertResult objLeadConvertResult= Database.convertLead(objLeadConvert, false);
            
            if(objLeadConvertResult.isSuccess()){
                objResultWrapper.strMessage = 'success';
                objResultWrapper.strOpportunityId = objLeadConvertResult.getOpportunityId();
                
                //Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Units Leasing').getRecordTypeId();
                Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Quick Book').getRecordTypeId();
                Opportunity objOpportunity = new Opportunity(Id= objLeadConvertResult.getOpportunityId(), RecordTypeId = oppRecordTypeId);
                //update objOpportunity;
                
            }
            else{
                objResultWrapper.strMessage = objLeadConvertResult.getErrors()[0].getMessage();
            }
            
        }
        catch(Exception e){
            system.debug('Error Msg => '+e.getMessage() + ' at '+ e.getLineNumber());
            
            objResultWrapper.strMessage = e.getMessage();
        }
        
        system.debug('**** objResultWrapper => '+objResultWrapper);
        
       
    }
     return objResultWrapper;    
    }
    
    public class ResultWrapper{
        @AuraEnabled public String strMessage;        
        @AuraEnabled public String strOpportunityId;
    }
}