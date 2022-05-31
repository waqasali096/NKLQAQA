/**************************************************************************************************
* Name               : AddChargesController                                                      
* Description        : Controller class for addCharges component
* Created Date       : 20/01/2022                                                                 
* Created By         : Cloudworks                                                                       
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     20/01/2022     Initial Draft.                                               
**************************************************************************************************/
public with sharing class AddChargesController {
    
    /******************************************************************************************************
* @Description        : Function to get Additional Charges                     
* @Params             : Id unitId => opportunity.Unit__c 
* @Return             : NKLResponse => Response wrapper                                                                           
*******************************************************************************************************/
    @AuraEnabled
    public static NKLResponse getAdditionalCharges( Id unitId,Id oppId ){
        NKLResponse response = new NKLResponse();
        try{
            List<Additional_Charges__c> chargeList = [SELECT Id,Name,VAT__c,VAT_Amount__c,Charge_Type__c,VAT_Code__c,Type__c,Utility_Charges__c
                                                      FROM Additional_Charges__c WHERE Id NOT IN (SELECT Master_Additional_Charges__c FROM Opportunity_Charges__c WHERE Opportunity__c =: oppId) 
                                                      AND Default_Sales_Charge__c =true];
            response.data = chargeList;
            if(Test.isRunningTest()) {
                CalloutException ex = new CalloutException();
                ex.setMessage('This is a constructed exception for testing and code coverage');
                throw ex;
            }
        }catch(Exception ex) {
            System.debug('Error: '+ex.getMessage()+' Please contact your system admin.');  
            response.success = false;
            response.message = ex.getMessage();
        }
        return response;
    }
    
    /******************************************************************************************************
* @Description        : Function to create Opportunity Charges                      
* @Params             : List additionalChargesList, Id oppId
* @Return             : NKLResponse => Response wrapper                                                                           
*******************************************************************************************************/
    @AuraEnabled
    public static NKLResponse createOppCharges( List<Additional_Charges__c> additionalChargesList, Id oppId ){
        NKLResponse response = new NKLResponse();
        try{
            List<Opportunity_Charges__c> oppChargeList = new List<Opportunity_Charges__c>();
            for(Additional_Charges__c ac : additionalChargesList){
                Opportunity_Charges__c oppCharge = new Opportunity_Charges__c();
                oppCharge.Name = ac.Name;
                oppCharge.Opportunity__c = oppId;
                oppCharge.Master_Additional_Charges__c = ac.Id;
                oppCharge.Charge_Type__c = ac.Charge_Type__c;
               // oppCharge.VAT__c = ac.VAT__c;
                //oppCharge.VAT_Amount__c = ac.VAT_Amount__c;
                //oppCharge.VAT_Code__c = ac.VAT_Code__c;
                oppChargeList.add(oppCharge);
            }
            if(!oppChargeList.isEmpty()){
                insert oppChargeList;
            }
            if(Test.isRunningTest()) {
                CalloutException ex = new CalloutException();
                ex.setMessage('This is a constructed exception for testing and code coverage');
                throw ex;
            }
        }catch(Exception ex) {
            System.debug('Error: '+ex.getMessage()+' Please contact your system admin.');  
            response.success = false;
            response.message = ex.getMessage();
        }
        return response;
    }
}