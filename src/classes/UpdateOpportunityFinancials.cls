/*
*Name: UpdateOpportunityFinancials
*Description: This class is created in Collections development. And this is mainly used for Balance calculation on Calling List object.
*Author: Jayesh Shewale
*Modified By: Karishma Kotian to update cleared amount and receipt amount
*/

global class UpdateOpportunityFinancials{
    
    
    public static Decimal receiptAmount = 0;
    public static Decimal clearedAmount = 0;
    
    
    @InvocableMethod(label='Enter Opportunity Id')
    global static void updateTotalPaidAmount(List<Opportunity> OpportunityId) {
        
        try{
            if(OpportunityId!= Null){
                List<Receipt__c> receiptList = new List<Receipt__c>();
                
                receiptList = [SELECT Id , Amount__c, Receipt_Type__c, Payment_Status__c
                                FROM Receipt__c WHERE opportunity__C =: OpportunityId[0].Id];
                
                for(Receipt__c rcpt : receiptList){
                        System.debug('@@@ receiptAmount at the start'+ receiptAmount);
                        receiptAmount = receiptAmount + rcpt.Amount__c;

                        //Added by Karishma 23-02-2022 to calculate amount cleared
                        if(rcpt.Payment_Status__c == 'Cleared'){
                            clearedAmount += rcpt.Amount__c;
                        }
                }
                
                Opportunity oppoToUpdate = new Opportunity();
                oppoToUpdate = [SELECT Id, Total_Receipt_Amount__c,Total_Receipt_Amount_in_Words__c,
                                Cleared_Receipt_Amount__c 
                                FROM Opportunity WHERE Id =: OpportunityId[0].Id];
                oppoToUpdate.Total_Receipt_Amount__c  = receiptAmount;
                oppoToUpdate.Total_Receipt_Amount_in_Words__c = CommonUtility.convertAmountIntoWords(receiptAmount);
                oppoToUpdate.Cleared_Receipt_Amount__c = clearedAmount;
                //Database.Update(oppoToUpdate, false);
                update oppoToUpdate;
            }
        }
        catch(Exception e){
            System.debug('Exception has occured. ' + e.getMessage());
        }
        
    }
}