/**
 * Name:          BatchGETBankListERP
 * Description:   Get Bank List from ERP
 * Author         Karishma Kotian
 */
public class BatchGETBankListERP implements Database.Batchable<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM>, Database.AllowsCallouts{
    public Iterable<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM> start(Database.BatchableContext BC){
        return ERPAPIIntegration.getBankDetails();
    }
    
    public void execute(Database.BatchableContext BC, List<ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM> scope){
        List<Bank__c> bankUnitsToUpsert = new List<Bank__c>();
        for(ERPAPIResponse.X_HELPER_RESULT_TBL1_ITEM bankItem : scope) {
            if(bankItem.X_ATTRIBUTE6 == 'AED'){
                Bank__c bank = new Bank__c();
                bank.Bank_Account_ID__c = bankItem.X_ATTRIBUTE1;
                bank.Bank_Account_Name__c = bankItem.X_ATTRIBUTE2;
                bank.Bank_Account_Number__c = bankItem.X_ATTRIBUTE3;
                bank.Bank_Branch_ID__c = bankItem.X_ATTRIBUTE4;
                bank.Bank_ID__c = bankItem.X_ATTRIBUTE5;
                bank.CurrencyIsoCode = bankItem.X_ATTRIBUTE6;
                bank.Swift_Code__c = bankItem.X_ATTRIBUTE8;
                bank.IBAN_Number__c = bankItem.X_ATTRIBUTE9;
                bank.Description__c = bankItem.X_ATTRIBUTE7;
                bankUnitsToUpsert.add(bank);
                system.debug('@@@bankUnitsToUpsert :'+bankUnitsToUpsert);
            }
            
        }
        if(!bankUnitsToUpsert.isEmpty())
        upsert bankUnitsToUpsert Bank_Account_ID__c;
    }

    public void finish(Database.BatchableContext BC){
    }
}