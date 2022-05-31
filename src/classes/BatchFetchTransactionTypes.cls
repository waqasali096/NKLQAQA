public class BatchFetchTransactionTypes implements Database.Batchable<Business_Unit__c>, Database.AllowsCallouts{
    public Iterable<Business_Unit__c> start(Database.BatchableContext BC){
        return [SELECT ID,ERP_Business_Unit_Id__c FROM Business_Unit__c WHERE ERP_Business_Unit_Id__c != null];
    }
    
    public void execute(Database.BatchableContext BC,  List<Business_Unit__c> scope){
        system.debug('@@Scope'+scope);
        List<Transaction_Type__c> transactionTypeToUpsert = new List<Transaction_Type__c>();
        Set<String> businessUnitID = new Set<String>();
        for(Business_Unit__c businessUnit : scope){
            businessUnitID.add(businessUnit.ERP_Business_Unit_Id__c);
        }
        system.debug('@@businessUnitID'+businessUnitID);
        //Set<String> setExt = new Set<String>();
        for(String businessUnitERPID : businessUnitID){
            //system.debug('@@businessUnitERPID'+businessUnitERPID);
            List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM> transactionTypeWrapperList = ERPAPIIntegration.getTransactionTypeDetails(businessUnitERPID,'TRANSACTION_TYPE');
            
            for(ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM ttItemWrap :  transactionTypeWrapperList){
                //if(!setExt.contains(ttItemWrap.X_ATTRIBUTE4+ttItemWrap.X_ATTRIBUTE3)) {
                    Transaction_Type__c tt = new Transaction_Type__c();
                    tt.Transaction_Type_Code__c = ttItemWrap.X_ATTRIBUTE1;
                    tt.Description__c = ttItemWrap.X_ATTRIBUTE2;
                    tt.Transaction_Type_Id__c = ttItemWrap.X_ATTRIBUTE3;
                    tt.ERP_BU_ID__c = ttItemWrap.X_ATTRIBUTE4;
                    tt.External_Id__c = ttItemWrap.X_ATTRIBUTE4+ttItemWrap.X_ATTRIBUTE3;
                    tt.Name = ttItemWrap.X_ATTRIBUTE4+ttItemWrap.X_ATTRIBUTE1;
                    tt.Business_Unit__r = new Business_Unit__c(ERP_Business_Unit_Id__c=ttItemWrap.X_ATTRIBUTE4);
                    tt.Transaction_Category__c = 'TRANSACTION_TYPE';
                    tt.Batch_Source_Id__c = ttItemWrap.X_ATTRIBUTE5;
                    transactionTypeToUpsert.add(tt);
                    //setExt.add(ttItemWrap.X_ATTRIBUTE4+ttItemWrap.X_ATTRIBUTE3);
                //}
                
            }
            
            List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM> transactionTypeCreditMemo = ERPAPIIntegration.getTransactionTypeDetails(businessUnitERPID,'CREDIT_MEMO');
            if(transactionTypeCreditMemo != null && !transactionTypeCreditMemo.isEmpty()) {
                for(ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM ttItemWrap :  transactionTypeCreditMemo){
                    //if(!setExt.contains(ttItemWrap.X_ATTRIBUTE4+ttItemWrap.X_ATTRIBUTE3)) {
                        Transaction_Type__c tt = new Transaction_Type__c();
                        tt.Transaction_Type_Code__c = ttItemWrap.X_ATTRIBUTE1;
                        tt.Description__c = ttItemWrap.X_ATTRIBUTE2;
                        tt.Transaction_Type_Id__c = ttItemWrap.X_ATTRIBUTE3;
                        tt.ERP_BU_ID__c = ttItemWrap.X_ATTRIBUTE4;
                        tt.External_Id__c = ttItemWrap.X_ATTRIBUTE4+ttItemWrap.X_ATTRIBUTE3;
                        tt.Name = ttItemWrap.X_ATTRIBUTE4+ttItemWrap.X_ATTRIBUTE1;
                        tt.Business_Unit__r = new Business_Unit__c(ERP_Business_Unit_Id__c=ttItemWrap.X_ATTRIBUTE4);
                        tt.Transaction_Category__c = 'CREDIT_MEMO';
                        tt.Batch_Source_Id__c = ttItemWrap.X_ATTRIBUTE5;
                        transactionTypeToUpsert.add(tt);
                        //setExt.add(ttItemWrap.X_ATTRIBUTE4+ttItemWrap.X_ATTRIBUTE3);
                    //}
                }
            }
        }
        //system.debug('@@@transactionTypeToUpsert :'+transactionTypeToUpsert);
        if(!transactionTypeToUpsert.isEmpty()){
            upsert transactionTypeToUpsert External_Id__c;
        }
    }

    public void finish(Database.BatchableContext BC){
    }
}