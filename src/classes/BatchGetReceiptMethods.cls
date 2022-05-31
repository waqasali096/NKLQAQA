public class BatchGetReceiptMethods implements Database.Batchable<Business_Unit__c>, Database.AllowsCallouts{
    public Iterable<Business_Unit__c> start(Database.BatchableContext BC){
        return [SELECT ID,ERP_Business_Unit_Id__c FROM Business_Unit__c WHERE ERP_Business_Unit_Id__c != null];
    }
    
    public void execute(Database.BatchableContext BC,  List<Business_Unit__c> scope){
        system.debug('@@Scope'+scope);
        List<Receipt_Method__c> receiptMethodToUpsert = new List<Receipt_Method__c>();
        Set<String> businessUnitID = new Set<String>();
        for(Business_Unit__c businessUnit : scope){
            businessUnitID.add(businessUnit.ERP_Business_Unit_Id__c);
        }
        system.debug('@@businessUnitID'+businessUnitID);
        for(String businessUnitERPID : businessUnitID){
            system.debug('@@businessUnitERPID'+businessUnitERPID);
            List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM> reciptMethodList = ERPAPIIntegration.getReceiptMethodDetails(businessUnitERPID);
            
            for(ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM rmItem :  reciptMethodList){
                if(rmItem.X_ATTRIBUTE4 == 'AED'){
                    Receipt_Method__c rm = new Receipt_Method__c();
                    //rm.Receipt_Method_Name__c = rmItem.X_ATTRIBUTE1;
                    rm.Receipt_Method_Id__c = rmItem.X_ATTRIBUTE2;
                    rm.Status__c = rmItem.X_ATTRIBUTE3;
                    rm.currencyISOCode = rmItem.X_ATTRIBUTE4;
                    rm.Receipt_Class_Name__c = rmItem.X_ATTRIBUTE5;
                    rm.Receipt_Method_Code__c = rmItem.X_ATTRIBUTE6;
                    rm.Payment_Type_Code__c = rmItem.X_ATTRIBUTE7;
                    rm.ERP_Business_Unit_Id__c = rmItem.X_ATTRIBUTE8;
                    rm.Operating_Unit__c = rmItem.X_ATTRIBUTE9;
                    //rm.Legal_Entity_ID__c = rmItem.X_ATTRIBUTE10; 
                    rm.Bank_Account_Number__c = rmItem.X_ATTRIBUTE11;
                    rm.Bank_ID__c = rmItem.X_ATTRIBUTE12;
                    rm.Bank_Branch_ID__c = rmItem.X_ATTRIBUTE13;
                    rm.Remit_Bank_Account_Id__c = rmItem.X_ATTRIBUTE14;
                    rm.ERP_Receipt_Method_Id__c = rmItem.X_ATTRIBUTE10; //rmItem.X_ATTRIBUTE2+rmItem.X_ATTRIBUTE14;
                    rm.Name = rmItem.X_ATTRIBUTE1; //rmItem.X_ATTRIBUTE1+rmItem.X_ATTRIBUTE14;
                    rm.Business_Unit__r = new Business_Unit__c(ERP_Business_Unit_Id__c=rmItem.X_ATTRIBUTE8); 
                    rm.Payment_Mode__c = rmItem.X_ATTRIBUTE15;
                    rm.Merchant_ID__c  = rmItem.X_ATTRIBUTE5;
                    rm.Working_Key__c = rmItem.X_ATTRIBUTE6;
                    rm.Access_Code__c = rmItem.X_ATTRIBUTE7;
                    receiptMethodToUpsert.add(rm);
                }
            }
        }
        system.debug('@@@receiptMethodToUpsert :'+receiptMethodToUpsert);
        if(!receiptMethodToUpsert.isEmpty()){
            upsert receiptMethodToUpsert ERP_Receipt_Method_Id__c;
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}