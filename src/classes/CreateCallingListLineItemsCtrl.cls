/**************************************************************************************************
* Name               : CreateCallingListLineItemsCtrl                                                      
* Description        : Create calling list line items from future payment milestones
* Created Date       : 16/05/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      16/05/2022      Initial Draft.                                               
**************************************************************************************************/
public class CreateCallingListLineItemsCtrl {
    
    
    @AuraEnabled
    public static List<Payment_Milestone__c> getAllPaymentMilestones(ID clID){
        Calling_List__c cl = [select id,Deal__c from Calling_List__c WHERE ID=:clID];
        List<Payment_Milestone__c> pmsToCreateclItems = new List<Payment_Milestone__c> ();
        List<Payment_Milestone__c> pms = [select id,Name ,Outstanding_Amount__c ,Amount__c,Due_Date__c,Opportunity__c, Payment_Status__c  from 
                                          Payment_Milestone__c WHERE Opportunity__c=:cl.Deal__c AND Due_Date__c > Today];
        
        List<Calling_List_line_Item__c> clItems =[select id, Payment_Milestone__c from Calling_List_line_Item__c WHERE Payment_Milestone__c IN:pms];
        Set<ID> pmIDS = new Set<ID>();
        for(Calling_List_line_Item__c cli : clItems){
            pmIDS.add(cli.Payment_Milestone__c);
        }
        for(Payment_Milestone__c pm: pms){
            if(!pmIDS.contains(pm.ID)){
                pmsToCreateclItems.add(pm);
                
            }
            
        }
        
        system.debug('pms are '+ pms);
        return pmsToCreateclItems;    
    }
    
    @AuraEnabled
    public static void saveCLI(ID clID, List<Payment_Milestone__c> pms){
        system.debug('pms are '+ pms);
        Calling_List__c cl = [select id,Deal__c,Account__r.Primary_Email__c from Calling_List__c WHERE ID=:clID];

        List<Calling_List_line_Item__c> ClItemLst = new List<Calling_List_line_Item__c>();
        for(Payment_Milestone__c pm: pms){
            Calling_List_line_Item__c  cli = new Calling_List_line_Item__c();
            cli.Calling_List__c = clID;
            cli.Payment_Milestone__c  = pm.ID;
            cli.Payment_Status__c ='Pending';
            cli.Outstanding_Amount__c = pm.Outstanding_Amount__c  ;
            cli.Amount_to_be_Paid__c = pm.AMount__c;
            //cli.Email__c = cl.Account__r.Primary_Email__c;
            ClItemLst.add(cli);
            
        }
        try{
           insert ClItemLst;
        }
        catch(Exception ex ){
            system.debug('error is '+ ex.getMessage() + ' at '+ ex.getLineNumber());
        
        }
        
          
    }

}