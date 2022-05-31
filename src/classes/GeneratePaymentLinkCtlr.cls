/*
* @author : Dinesh
* @Module : Sales 
* @usage : used in generate payment link component
*/
public with sharing class GeneratePaymentLinkCtlr {

    @AuraEnabled
    public static Opportunity getTokenAmount(string DLSId) {
        try {
            Opportunity deal = [ select Id, Token_Amount__c from Opportunity where id =: DLSId ]; 

            return deal;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
	* @update : Added logic to update token amount on opportunity
	*/
    @AuraEnabled
    public static string createReceipt(string DLSId, Decimal Amount){
        try {
            list<Opportunity> oppList = [ select Id,AccountId,Token_Amount__c,unit__c from Opportunity where id =: DLSId order by CreatedDate DESC limit 1 ]; 	
            if(!oppList.isEmpty()) {
                Receipt__c res = new Receipt__c();
                res.Account__c = oppList[0].AccountId;
                res.Receipt_Date__c = system.today();
                res.Amount__c = Amount;
                res.Received_From__c = oppList[0].AccountId;
                res.Installment_Type__c = 'Deposit';
                res.Name = 'Token Amount';
                res.Received_For__c = 'Token Amount';
                res.Payment_Status__c = 'Pending';
                res.Opportunity__c = DLSId;
                res.Unit__c = oppList[0].Unit__c;
                res.Payment_Mode__c = 'Online Payment';
                insert res;
                oppList[0].Token_Amount__c = Amount;
                update oppList;
                return res.Id;
            }	
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}