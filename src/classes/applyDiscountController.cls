/**************************************************************************************************
* Name               : applyDiscountController                                                      
* Description        : Controller class for applyDiscount component
* Created Date       : 22/03/2022                                                                
* Created By         : Cloudworks                                                                       
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     22/03/2022     Initial Draft.                                               
**************************************************************************************************/
public with sharing class applyDiscountController {


    @AuraEnabled(cacheable=true)
    public static ResultWrapper getOppData(Id oppId) {
        ResultWrapper wrapper = new ResultWrapper();
        List<String> pickOptions = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Discount_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            pickOptions.add(f.getLabel());
        } 
        for(Opportunity opp : [SELECT Id,Discount_Type__c, Discount__c,Discount_Approval_Status__c  FROM Opportunity WHERE Id =: oppId]){
            wrapper.discountType = opp.Discount_Type__c;
            wrapper.discount = opp.Discount__c;
            wrapper.discountApprovalStatus = opp.Discount_Approval_Status__c;
        }
        wrapper.discountOption = pickOptions;
        system.debug(wrapper);
        return wrapper;
    }
    /******************************************************************************************************
    * @Description        : Function to create document                      
    * @Params             : Id oppId => opportunity Id  
    * @Return             : NKLResponse => Response wrapper                                                                           
    *******************************************************************************************************/
    @AuraEnabled
    public static NKLResponse createDocument( Id oppId ){
        NKLResponse response = new NKLResponse();
        try{
            Document__c doc;
            /*for( Document__c docObj : [SELECT Id from Document__c WHERE Opportunity__c =: oppId AND Document_Type__c = 'Discount Approval Document'] ){
                doc = docObj;
            }*/
            if( doc == null ){
                Document__c docObj = new Document__c();
                docObj.Opportunity__c = oppId;
                docObj.Document_Type__c = 'Discount Approval Document';
                insert docObj;
                
                // store document object
                doc = docObj;
            }
            response.data = doc;
        }catch(Exception ex) {
            System.debug('Error: '+ex.getMessage()+' Please contact your system admin.');  
            response.success = false;
            response.message = ex.getMessage();
        }
        return response;
    }
    /******************************************************************************************************
    * @Description        : Function to save the file                        
    * @Params             : Id oppId => opportunity Id  
    * @Params             : String discountType 
    * @Params             : String  discount => discount    
    * @Return             : NKLResponse => Response wrapper                                                                           
    *******************************************************************************************************/
     @AuraEnabled
    public static NKLResponse saveFile(Id oppId, String discountType, String discount, Id documentId){
        NKLResponse response = new NKLResponse();
        try{            
            Opportunity opp = new Opportunity();
            opp.Id = oppId;
            opp.Discount_Type__c = discountType;
            opp.Discount__c = discount != null ? Decimal.valueOf(discount) : null;
            update opp;

            List<ProcessInstanceWorkitem> approvalReq = [Select p.Id, p.ProcessInstanceId from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: oppId order by createdDate Desc LIMIT 1];

            if(!approvalReq.isEmpty()){
                List<Document__c> ddList = [SELECT Id,Is_Document_Uploaded__c FROM Document__c WHERE Id =:documentId];
                if(ddList != null && ddList[0].Is_Document_Uploaded__c){
                    Document__c dd = new Document__c();
                    dd.Id = documentId;
                    dd.Approval_Request_Id__c = approvalReq[0].ProcessInstanceId;
                    update dd;
                }
            }
            response.success = true;
        }catch(DmlException e) {            
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

    public class ResultWrapper {
        @AuraEnabled public String discountType             {get;set;}
        @AuraEnabled public String discountApprovalStatus   {get;set;}
        @AuraEnabled public Decimal discount                {get;set;}
        @AuraEnabled public List<String> discountOption     {get;set;}
    }
}