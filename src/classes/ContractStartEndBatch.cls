global class ContractStartEndBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global List<Lease_Contract__c> contractList = new List<Lease_Contract__c>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT Id, Contract_Start__c, Contract_End__c, Contract_Stages__c, Account__c, LeasingType__c  FROM Lease_Contract__c WHERE Contract_Stages__c IN (\'Expired\',\'Active\') ';
        query = query + label.ContractBatchWhereClause;
        //query = query + ' Id = \'a0c3M0000000RoyQAE\'';
        system.debug('Query:'+query);
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext BC, List<Lease_Contract__c> scope) {
        try{
           // List<Lease_Contract__c> contractList = new List<Lease_Contract__c>();
			for(Lease_Contract__c c : scope){
            	if(String.isNotBlank(String.valueOf(c.Contract_End__c))){
                	if(c.Contract_End__c == date.today() && c.Contract_Stages__c != 'Expired'){
                        Lease_Contract__c contract = new Lease_Contract__c();
                        contract.Id = c.Id;
                    	contract.Contract_Stages__c= 'Expired';
                        contractList.add(contract);
                	}    
                	Integer noOfDays = c.Contract_End__c.daysBetween(date.today());
                	if((noOfDays >= 15) && (c.Contract_Stages__c == 'Expired')){
                        Lease_Contract__c contract = new Lease_Contract__c();
                        contract.Id = c.Id;
                    	contract.Contract_Stages__c= 'Compliance';
                        contractList.add(contract);
                	}
            	}
        	}
        	//Database.update(contractList,false);         
        }catch(Exception ex){
            system.debug(ex.getMessage()+'at :'+ex.getLineNumber());
        }
        
    }
    global void finish(Database.BatchableContext BC) {
        Database.update(contractList,false);
    }
}