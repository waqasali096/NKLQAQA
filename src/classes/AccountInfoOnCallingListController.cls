/**************************************************************************************************
* Name               : ShowAccountIfo_Ctrl                                                      
* Description        : show Account Detail on Calling List Record
* Created Date       : 05/05/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      05/05/2022       Initial Draft.                                               
**************************************************************************************************/

public class AccountInfoOnCallingListController  {
    
    @AuraEnabled
    public static String getAccountID(Id recID, String obJname){
        String accID ='';
        if(obJname=='Calling_List__c'){ 
          Calling_List__c cl = [select id, Account__c from Calling_List__c WHERE ID=:recID LIMIT 1 ];
          accID = cl.Account__c;  
        }
        else if(obJname=='Calling_List_line_Item__c'){
            Calling_List_line_Item__c clItm= [select id,Calling_List__r.Account__c from  Calling_List_line_Item__c WHERE ID=:recID ];
            accID = clItm.Calling_List__r.Account__c;
            
        }
        return accID;
       
        
    }
    

}