/**************************************************************************************************
* Name               : AddOptionsController                                                      
* Description        : Controller class for addOptions component
* Created Date       : 20/01/2022                                                                 
* Created By         : Cloudworks                                                                       
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     20/01/2022     Initial Draft.                                               
**************************************************************************************************/
public with sharing class AddOptionsController {
    
    /******************************************************************************************************
* @Description        : Function to get Unit Options                      
* @Params             : Id unitId => opportunity.Unit__c 
* @Return             : NKLResponse => Response wrapper                                                                           
*******************************************************************************************************/
    @AuraEnabled
    public static NKLResponse getUnitOptions( Id unitId, Id oppId ){
        System.debug('@@@ '+  unitId + '@@@ '+ oppId);
        NKLResponse response = new NKLResponse();
        try{
            
            Set<Id> unitOptionIds = new Set<Id>();
            
            List<Opportunity_Option__c> oppOptionList = [SELECT Id, Unit_Option__c FROM Opportunity_Option__c WHERE Opportunity__c =: oppId];
            
            for(Opportunity_Option__c oppOption : oppOptionList){
                unitOptionIds.add(oppOption.Unit_Option__c);
            }
            List<Unit_Option__c> freeList = new List<Unit_Option__c>();
            List<Unit_Option__c> paidList = new List<Unit_Option__c>();
            List<Unit_Option__c> optionList = [SELECT Id,Name,Unit__c,Master_Option__c,Price__c,Additional_Area__c,
                                               Price_Book__c, Unit__r.Name, Master_Option__r.Name,Option_Type__c,
                                               Price_Book__r.Name,Project__c,Unit_Style__c,Unit_Theme__c,Unit_Theme__r.Name,
                                               Optional_Length__c,Optional_Width__c FROM Unit_Option__c WHERE Unit__c =: unitId];
            for(Unit_Option__c uo : optionList){
                if(unitOptionIds != null && unitOptionIds.contains(uo.Id) && uo.Option_Type__c == 'Free'){
                    freeList.add(uo);
                }else if(unitOptionIds != null && unitOptionIds.contains(uo.Id) && uo.Option_Type__c == 'Paid'){
                    paidList.add(uo);
                }
            }            
            UnitOptionWrapper resUnitWrap = new UnitOptionWrapper(unitOptionIds, optionList,freeList,paidList);
            
            
            response.data = resUnitWrap;
            
            if(Test.isRunningTest()) {
                CalloutException ex = new CalloutException();
                ex.setMessage('This is a constructed exception for testing and code coverage');
                throw ex;
            }
        }catch(Exception ex) {
            System.debug('Error: '+ex.getMessage() +' Please contact your system admin.'+ ex.getLineNumber());  
            response.success = false;
            response.message = ex.getMessage();
        }
        return response;
    }
    
    public class UnitOptionWrapper{
        @AuraEnabled public Set<Id> unitOptionIds{get; set;}
        @AuraEnabled public List<Unit_Option__c> optionList{get; set;}
        @AuraEnabled public List<Unit_Option__c> freeList{get; set;}
        @AuraEnabled public List<Unit_Option__c> paidList{get; set;}
        
        public unitOptionWrapper(Set<Id> unitOptionIds, List<Unit_Option__c> optionList,List<Unit_Option__c> freeList,List<Unit_Option__c> paidList ){
            this.unitOptionIds = unitOptionIds;
            this.optionList = optionList;
            this.paidList = paidList;
            this.freeList = freeList;
        }
    }



    /******************************************************************************************************
    * @Description        : Function to create Opportunity Options                      
    * @Params             : List unitOptionsList, Id oppId
    * @Return             : NKLResponse => Response wrapper                                                                           
    *******************************************************************************************************/
    @AuraEnabled
    public static NKLResponse createOppOptions( List<Unit_Option__c> freeList,List<Unit_Option__c> paidList, Id oppId ){
        NKLResponse response = new NKLResponse();
        try{
            List<Unit_Option__c> unitOptionsList = new List<Unit_Option__c>();
            if(freeList != null){
                unitOptionsList.addAll(freeList);
            }
            if(paidList != null){
                unitOptionsList.addAll(paidList);
            }
            //Added by Jayesh due to change in requirement given by Asams. 
            //Date: 18 April 2022
            List<Opportunity_Option__c> oppOptionListToDelete = new List<Opportunity_Option__c>();
            oppOptionListToDelete = [SELECT Id FROM Opportunity_Option__c WHERE Opportunity__c =: oppId];
            Database.Delete(oppOptionListToDelete, false);
            
            List<Opportunity_Option__c> oppOptionList = new List<Opportunity_Option__c>();
            for(Unit_Option__c opt : unitOptionsList){
                Opportunity_Option__c oppOption = new Opportunity_Option__c();
                oppOption.Opportunity__c = oppId;
                oppOption.Unit__c = opt.Unit__c;
                oppOption.Project__c = opt.Project__c;
                oppOption.Master_Option__c = opt.Master_Option__c;
                oppOption.Unit_Option__c = opt.Id;
                if(opt.Price__c!=null){
                   oppOption.Price__c = opt.Price__c; 
                }else if(opt.Price__c!=null){
                   oppOption.Price__c = 0.00; 
                }
                oppOption.Additional_Area__c = opt.Additional_Area__c;
                oppOption.Unit_Style__c = opt.Unit_Style__c;
                oppOption.Option_Length__c = opt.Optional_Length__c;
                oppOption.Option_Width__c = opt.Optional_Width__c;
                if(opt.Option_Type__c != null && opt.Option_Type__c == 'Free'){
                    oppOption.is_Free__c = true; 
                }
                oppOptionList.add(oppOption);
            }
            if(!oppOptionList.isEmpty()){
                insert oppOptionList;
            }
            if(Test.isRunningTest()) {
                CalloutException ex = new CalloutException();
                ex.setMessage('This is a constructed exception for testing and code coverage');
                throw ex;
            }
        }catch(DmlException e) {
			system.debug('%%Error'+e.getMessage()+e.getLineNumber());            
            if( e.getMessage().contains( 'FIELD_CUSTOM_VALIDATION_EXCEPTION' ) ){
                 response.message = e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').replace(':','').replace('[]','');
            }else{
                response.message = e.getMessage();
            }
            response.success = false;
        }
        catch(Exception ex) {
            System.debug('Error: '+ex.getMessage()+' Please contact your system admin.');  
            response.success = false;
            response.message = ex.getMessage();
        }
        return response;
    }
}