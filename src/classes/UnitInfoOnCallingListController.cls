/**************************************************************************************************
* Name               : UnitInfoOnCallingListController                                                      
* Description        : show Unit Detail on Calling List Record
* Created Date       : 12/05/2022                                                                 
* Created By         : Cloudworks                                                                    
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Mamta      12/05/2022       Initial Draft.                                               
**************************************************************************************************/

public class UnitInfoOnCallingListController {
    
     @AuraEnabled
    public static String getUnitID(Id recID){
        String unitID ='';
        Calling_List_line_Item__c clItm= [select id,Calling_List__r.Account__c ,Calling_List__r.Unit__c  
                                          from  Calling_List_line_Item__c WHERE ID=:recID ];
        if(clItm.Calling_List__r.Unit__c!=null){ unitID = clItm.Calling_List__r.Unit__c;}
         return unitID;
    }

}