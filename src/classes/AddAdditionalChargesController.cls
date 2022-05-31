/**
* @description      Search and add additional charges to opp through AddAdditionalCharges comp.
* @author Sajid Hameed
*/
public class AddAdditionalChargesController {
 
/********************************************************************************************** 
* @Description  : Check opp record type is Lease Renewal.
* @Params       : opp record ID
* @Return       : Boolean
* @Author       : Sajid Hameed
**********************************************************************************************/
    
    @AuraEnabled  
    public static Boolean fetchOppRecrdType(String recordId){
        Boolean renewRecordtype = false;
        Id oppRenewRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Lease Renewal').getRecordTypeId();

        try{
            Opportunity opp = [Select Id, RecordTypeId from Opportunity where Id =: recordId limit 1];
            
            if(opp.RecordTypeId == oppRenewRecordType){
                renewRecordtype = true;
            }
        }catch(Exception ex){
            System.debug('error is '+ ex.getMessage() +' at line number ' + ex.getLineNumber());
        }
        
        return renewRecordtype;
    }
    
/********************************************************************************************** 
* @Description  : Search additional charges .
* @Params       : String Search Key.
* @Params       : Boolean renewRecordType.
* @Return       : List<Wrapper>
* @Author       : Sajid Hameed
**********************************************************************************************/
    @AuraEnabled  
    public static List<Wrapper> fetchAdditionalCharges(string searchKey, Boolean renewRecordType,String recordId){
        string query ='';
        Opportunity opp = [Select Id, RecordTypeId,project__c from Opportunity where Id =: recordId limit 1];
        List<Wrapper> wrapperList = new List<Wrapper>();

        if(string.isNotBlank(searchKey)){
            query = 'Select Id,name, Security_Deposit__c, Fixed_Amount__c,Amount_Leasing__c, Project__c, Type__c, Amount__c,Amount_On__c, Transaction_Type__c, Type_Leasing__c, Sub_Type__c, Applicable_for_renewal__c, Active__c, Payment_Purpose_Code__c,Payment_Term_Type_Code__c,  Tax_Configuration__c,leasing_type__c,Tax_Configuration__r.Tax_Rate__c from Additional_Charges__c';
            String tempInput ='\'%' + searchKey  + '%\'';
            if(renewRecordType){
                query = query + ' where name like ' + tempInput +' AND Active__c = true AND Required__c = false AND Type_Leasing__c = \'Charges\' AND Applicable_for_renewal__c = true order by Name asc'; 
            }else{
                query = query + ' where name like ' + tempInput +' AND Active__c = true AND Required__c = false AND Type_Leasing__c = \'Charges\' AND Project__c = \''+ opp.project__c+'\' order by Name asc'; 
            }
        }
        system.debug('%%query'+query);
        
        For(Additional_Charges__c addCharges : Database.query(query)){
            Wrapper wrapper = new Wrapper();
            wrapper.Id = addCharges.Id;
            wrapper.Name = addCharges.Name;
            wrapper.FixedAmount = addCharges.Fixed_Amount__c;
            wrapper.Amount = addCharges.Amount_Leasing__c;
            wrapper.taxRate = addCharges.Tax_Configuration__r.Tax_Rate__c;
            wrapper.isSelect = false;
            wrapper.charges = addCharges;
            
            wrapperList.add(wrapper);
        }
        return wrapperList;  
    }  
    
/********************************************************************************************** 
* @Description  : Add additional charges .
* @Params       : List<Wrapper> wrapperList.
* @Params       : opp record ID
* @Return       : Void
* @Author       : Sajid Hameed
**********************************************************************************************/
    @AuraEnabled  
    public static void addAdditionalCharges(List<Wrapper> wrapperList, String recordId){
        List<Opportunity_Charges__c> additionalChargesList = new List<Opportunity_Charges__c>();
        Map<String,Aggregated_Milestone__c> aggrMilestoneMap = new Map<String,Aggregated_Milestone__c>();
        //Get opp units linked to this opportunity.
        List<Unit_Plan__c> oppUnitList = [Select Id, Unit__c, Opportunity__r.lease_Start_date__c,Final_Lease_Amount__c,Base_Lease_Amount__c,
                                          Opportunity__r.Final_Lease_Amount__c from Unit_Plan__c where Opportunity__c =: recordId];
            

        for(Wrapper wrapper: wrapperList){
            for(Unit_Plan__c oppUnit: oppUnitList){
                 Opportunity_Charges__c  addCharges = new Opportunity_Charges__c ();
                    addCharges.name = wrapper.Name;
                    addCharges.Master_Additional_Charges__c = wrapper.Id;
                    addCharges.Opportunity__c = recordId;
                    addCharges.Unit__c = oppUnit.Unit__c;
                    addCharges.Due_Date__c = oppUnit.Opportunity__r.lease_Start_date__c;
                    if(wrapper.FixedAmount !=0 && wrapper.FixedAmount != null){
                        addCharges.Amount__c =  wrapper.FixedAmount;
                    }else if(wrapper.Amount !=0 && wrapper.Amount  != null){
                         if(wrapper.charges.Amount_On__c == 'Base Rent'){
                            addCharges.Amount__c = oppUnit.Base_Lease_Amount__c * (wrapper.Amount /100).setScale(2);
                        }else if(wrapper.charges.Amount_On__c == 'Current Rent'){
                            addCharges.Amount__c = oppUnit.Final_Lease_Amount__c * (wrapper.Amount /100).setScale(2);
                        }
                    }else{
                        addCharges.Amount__c = 0;
                        //  addCharges.VAT__c = 0;
                    }
                if(addCharges.Amount__c != 0 && addCharges.Amount__c != null){
                    if(wrapper.taxRate != 0 && wrapper.taxRate != null){
                        addCharges.Payable_Amount__c = (addCharges.Amount__c + (addCharges.Amount__c * (wrapper.taxRate)/100)).setScale(2);
                    }else{
                        addCharges.Payable_Amount__c = addCharges.Amount__c;
                    }
                    additionalChargesList.add(addCharges);
                    
                    if(oppUnitList.size() > 1){
                        if(aggrMilestoneMap.containsKey(wrapper.charges.Payment_Term_Type_Code__c)){
                            Aggregated_Milestone__c aggr = aggrMilestoneMap.get(wrapper.charges.Payment_Term_Type_Code__c);
                            aggr.Amount__c = aggr.Amount__c + addCharges.Amount__c;
                            aggrMilestoneMap.put(wrapper.charges.Payment_Term_Type_Code__c,aggr);
                            System.debug('After Contains '+aggr);
                        }else{
                            Aggregated_Milestone__c aggr = AvailablePayPlanController.createAggregatedMilestones(null,addCharges,true,null,wrapper.charges.Payment_Term_Type_Code__c);
                            aggrMilestoneMap.put(wrapper.charges.Payment_Term_Type_Code__c,aggr);
                            System.debug('After Creation '+ aggr);
                        }
                    }
                }
            }           
        }
        
        if(additionalChargesList.size() > 0){
            System.debug('additionalChargesList '+ additionalChargesList);
            insert additionalChargesList;
        }	
        if(aggrMilestoneMap.values().size() > 0){
            System.debug('aggrMilestoneMap '+ aggrMilestoneMap.values());
            insert aggrMilestoneMap.values();
        }
        
    }
    
    public class Wrapper {
        @AuraEnabled 
        public String Id{get;set;}
        
        @AuraEnabled 
        public String Name{get;set;}
        
        @AuraEnabled 
        public Decimal FixedAmount{get;set;}
        
        @AuraEnabled 
        public Decimal Amount{get;set;}
        
        @AuraEnabled
        public Boolean isSelect{get;set;}
        
        @AuraEnabled
        public Decimal taxRate{get;set;}
        
        @AuraEnabled
        public Additional_Charges__c charges{get;set;}
        
    }
}