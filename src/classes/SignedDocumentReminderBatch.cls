global class SignedDocumentReminderBatch implements Database.Batchable<sObject>, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID, CreatedDate, Signed_Document_Reminder_Days__c FROM Account Where DISTRICT_ONE_FZ_Flag__c = false' +
            ' OR Meydan_Group_L_L_C_Flag__c = false OR Nakheel_PJSC_Flag__c = false '
        );
    }
    global void execute(Database.BatchableContext bc, List<Account> scope){
        List<Account> accountList = new List<Account>();
        for (Account account : scope) {
            if(account.Signed_Document_Reminder_Days__c == null || account.Signed_Document_Reminder_Days__c < 3){
                Decimal con;
                if(account.Signed_Document_Reminder_Days__c == null){
                    con = 1;
                }else{
                    con = account.Signed_Document_Reminder_Days__c + 1;
                }
                account.Signed_Document_Reminder_Days__c = con;
                accountList.add(account);
            }
        }
        if(!accountList.isEmpty()){
            update accountList;
        }
    }
    global void finish(Database.BatchableContext bc){
    }

    global void execute(SchedulableContext sc) {
        SignedDocumentReminderBatch b = new SignedDocumentReminderBatch(); 
        database.executebatch(b);
     }
}