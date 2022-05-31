/**************************************************************************************************
* Name               : RaiseExceptionController                                                      
* Description        : Controller class for RaiseException component
* Created Date       : 24/03/2022                                                                
* Created By         : Cloudworks                                                                       
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     24/03/2022     Initial Draft.                                               
**************************************************************************************************/
public with sharing class RaiseExceptionController {
    
    @AuraEnabled(cacheable=true)
    public static List<exceptionWrapper> getOppData(Id oppId) {
        
        exceptionWrapper expWrapper = new exceptionWrapper();
        List<exceptionWrapper> resultWrapperList = new List<exceptionWrapper>();
        
        for(Opportunity opp : [SELECT Id,Day_to_Day_Exception_Type__c,Name,DLD_Customer_Share__c,DLD_Nakheel_Share__c,Unit_DLD_Share__c,
                               DLD_Paid__c,DLD_Waiver__c,DLD_Waiver_Reason__c,Single_Payment_Plan_Selected__c,Exception_Discount__c,
                               Exception_Discount_Amount__c,Net_Selling_Price__c,Exception_Approval_Status__c,Single_Payment_Plan_Exception_Status__c  FROM Opportunity WHERE Id =: oppId]){
                                   exceptionWrapper dldWrapper = new exceptionWrapper();
                                   dldWrapper.exceptionName = 'DLD Share Exception';
                                   dldWrapper.exceptionDLDPercentage = null;
                                   dldWrapper.unitDLDPercentage = opp.Unit_DLD_Share__c;
                                   dldWrapper.specialOfferDLDPercentage = opp.DLD_Customer_Share__c;
                                   dldWrapper.oppDLDPercentage = opp.DLD_Customer_Share__c;
                                   dldWrapper.DLDApplied = opp.DLD_Paid__c;
                                   dldWrapper.isDLD = TRUE;
                                   if(opp.Exception_Approval_Status__c == 'Approved'){
                                      dldWrapper.exceptionApproved = TRUE;
                                   }else{
                                       dldWrapper.exceptionApproved = FALSE;
                                   }
                                   if(!string.isempty(opp.Exception_Approval_Status__c) && opp.Exception_Approval_Status__c.contains('Pending')){
                                      dldWrapper.exceptionPending = TRUE;
                                   }else{
                                      dldWrapper.exceptionPending = FALSE;
                                   }
                                   dldWrapper.selected = FALSE;
                                   dldWrapper.longApproval = FALSE;
                                   dldWrapper.exceptionStatus = opp.Exception_Approval_Status__c;
                                   resultWrapperList.add(dldWrapper);
                                   exceptionWrapper spWrapper = new exceptionWrapper();
                                   spWrapper.exceptionName = 'Single Payment Plan Exception';
                                   spWrapper.exceptionDLDPercentage = null;
                                   spWrapper.unitDLDPercentage = opp.Unit_DLD_Share__c;
                                   spWrapper.specialOfferDLDPercentage = opp.DLD_Customer_Share__c;
                                   spWrapper.oppDLDPercentage = opp.DLD_Customer_Share__c;
                                   spWrapper.DLDApplied = FALSE;
                                   spWrapper.isDLD = FALSE;
                                   if(opp.Single_Payment_Plan_Exception_Status__c == 'Approved'){
                                      spWrapper.exceptionApproved = TRUE;
                                   }else{
                                       spWrapper.exceptionApproved = FALSE;
                                   }
                                   if(!string.isempty(opp.Single_Payment_Plan_Exception_Status__c) && opp.Single_Payment_Plan_Exception_Status__c.contains('Pending')){
                                      spWrapper.exceptionPending = TRUE;
                                   }else{
                                      spWrapper.exceptionPending = FALSE;
                                   }
                                   spWrapper.selected = FALSE;
                                   spWrapper.longApproval = FALSE;
                                   dldWrapper.exceptionStatus = opp.Single_Payment_Plan_Exception_Status__c;
                                   resultWrapperList.add(spWrapper);
                               }
        return resultWrapperList;
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
            /*for( Document__c docObj : [SELECT Id from Document__c WHERE Opportunity__c =: oppId AND Document_Type__c = 'Day To Day Exception Document'] ){
                doc = docObj;
            }*/
            if( doc == null ){
                Document__c docObj = new Document__c();
                docObj.Opportunity__c = oppId;
                docObj.Document_Type__c = 'Day To Day Exception Document';
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
    /*@AuraEnabled
    public static NKLResponse saveFile(Id oppId, List<exceptionWrapper> expWrapper, Id documentId, boolean longapproval){
        NKLResponse response = new NKLResponse();
        system.debug('%%expWrapper'+expWrapper);
        Savepoint sp = Database.setSavepoint();
        
        try{
            Opportunity opp = new Opportunity();
            String dldType;
            List<Approval_Line_Item__c> lineItemList = new List<Approval_Line_Item__c>();
            
            if(!expWrapper.isEmpty()){
                opp.Id = oppId;
                Approval__c approvalrecord = new Approval__c();
                approvalrecord.Approval_Type__c = 'Exception Approval';
                approvalrecord.Deal__C = oppId; 
                approvalrecord.Comments__c = 'Exception Approval';
                approvalrecord.Approval_Status__c = 'Pending 1st Level';
                approvalrecord.Long_Approval__c = longapproval;
                insert approvalrecord;
				string approvalProcess;                
                if(longapproval){
                     approvalProcess = 'Sales_Deal_Exception_Long_Approval';  
                }else{
                    approvalProcess = 'Sales_Deal_Exception_Approval'; 
                }
                system.debug('%%longapproval'+longapproval);
                system.debug('%%approvalProcess'+approvalProcess);
                for(exceptionWrapper exp : expWrapper){
                    if(exp.exceptionName == 'DLD Share Exception'){
                        Approval_Line_Item__c lineItemRecord = new Approval_Line_Item__c();
                        lineItemRecord.Approval__c = approvalRecord.Id;
                        lineItemRecord.Deal__c = oppId;
                        lineItemRecord.Exception_Type__c = 'DLD Exception';
                        lineItemList.add(lineItemRecord);
                        if(string.isBlank(dldType)){
                            dldType = 'DLD Waiver'; 
                        }else{
                            dldType = dldType + ';' +'DLD Waiver';  
                        }
                        opp.Exception_Approval_Status__c	 = 'Pending 1st Level';
                    }
                    if(exp.exceptionName == 'Single Payment Plan Exception'){
                        Approval_Line_Item__c lineItemRecord = new Approval_Line_Item__c();
                        lineItemRecord.Approval__c = approvalRecord.Id;
                        lineItemRecord.Deal__c = oppId;
                        lineItemRecord.Exception_Type__c = 'Single Payment Plan Exception';
                        lineItemList.add(lineItemRecord);
                        if(string.isBlank(dldType)){
                            dldType = 'Single Payment Plan'; 
                        }else{
                            dldType = dldType + ';' +'Single Payment Plan';  
                        }
                        opp.Single_Payment_Plan_Exception_Status__c = 'Pending 1st Level';
                    }
                }
                insert lineItemList; 
                opp.Day_to_Day_Exception_Type__c = dldType;
                update opp;
                
                approvalrecord = [SELECT ID,Name FROM Approval__c WHERE Id =: approvalrecord.Id LIMIT 1];
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Please Approve Exceptions!');
                req.setObjectId(approvalrecord.Id);
                req.setProcessDefinitionNameOrId(approvalProcess);
                req.setSkipEntryCriteria(true);
                Approval.ProcessResult result = Approval.process(req);
                system.debug('%%req'+req);
                system.debug('%%result'+result);
                Document__c dd = new Document__c();
                dd.Id = documentId;
                dd.Approval__c = approvalrecord.Id;
                update dd;
            }  
            //List<ProcessInstanceWorkitem> approvalReq = [Select p.Id, p.ProcessInstanceId from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: oppId order by createdDate Desc LIMIT 1];
            response.success = true;
        }catch(Exception ex) {
            System.debug('Error: '+ex.getMessage()+ex.getLineNumber());  
            response.success = false;
            response.message = ex.getMessage();
            Database.RollBack(sp);
        }
        return response;
    }*/
    
    /******************************************************************************************************
    * @Description        : Function to save the file                        
    * @Params             : Id oppId => opportunity Id  
    * @Params             : String discountType 
    * @Params             : String  discount => discount    
    * @Return             : NKLResponse => Response wrapper                                                                           
    *******************************************************************************************************/
    @AuraEnabled
    public static NKLResponse saveFile(Id oppId, List<exceptionWrapper> expWrapper, Id documentId, boolean longapproval){
        NKLResponse response = new NKLResponse();
        system.debug('%%expWrapper'+expWrapper);
        Savepoint sp = Database.setSavepoint();
        
        try{
            Opportunity opp = new Opportunity();
            String dldType;
            string approvalProcess;
            boolean isDLD = FALSE;
            boolean isSPP = FALSE;
            
            if(!expWrapper.isEmpty()){
                opp.Id = oppId;
                system.debug('%%longapproval'+longapproval);
                system.debug('%%approvalProcess'+approvalProcess);
                for(exceptionWrapper exp : expWrapper){
                    if(exp.exceptionName == 'DLD Share Exception'){
                        if(string.isBlank(dldType)){
                            dldType = 'DLD Waiver'; 
                        }else{
                            dldType = dldType + ';' +'DLD Waiver';  
                        }
                        opp.Exception_Approval_Status__c	 = 'Pending 1st Level';
                        opp.Exception_DLD_Share__c = exp.exceptionDLDPercentage;
                        isDLD = TRUE;
                    }
                    if(exp.exceptionName == 'Single Payment Plan Exception'){
                        if(string.isBlank(dldType)){
                            dldType = 'Single Payment Plan'; 
                        }else{
                            dldType = dldType + ';' +'Single Payment Plan';  
                        }
                        opp.Single_Payment_Plan_Exception_Status__c = 'Pending 1st Level';
                        isSPP = TRUE;
                    }
                }
                opp.Day_to_Day_Exception_Type__c = dldType;
                if(longapproval){
                  opp.Long_Approval__c = TRUE;  
                }
                update opp;
                system.debug('%%Values'+isSPP + isDLD);
                if(isSPP == TRUE && isDLD == FALSE){
                    approvalProcess = 'Single_Payment_Plan_Exception_Approval';  
                }else if(isSPP == FALSE && isDLD == TRUE){
                    approvalProcess = 'DLD_Exception_Approval'; 
                }else if(isSPP == TRUE && isDLD == TRUE){
                    approvalProcess = 'Single_PP_DLD_Exception_Bulk_Approval';
                }
                
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Please Approve Exceptions!');
                req.setObjectId(opp.Id);
                req.setProcessDefinitionNameOrId(approvalProcess);
                req.setSkipEntryCriteria(true);
                Approval.ProcessResult result = Approval.process(req);

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
            }  
            response.success = true;
        }catch(Exception ex) {
            System.debug('Error: '+ex.getMessage()+ex.getLineNumber());  
            response.success = false;
            response.message = ex.getMessage();
            Database.RollBack(sp);
        }
        return response;
    }

    public class exceptionWrapper {
        @AuraEnabled public String exceptionName{get;set;}
        @AuraEnabled public Decimal exceptionDLDPercentage{get;set;}
        @AuraEnabled public Decimal unitDLDPercentage{get;set;}
        @AuraEnabled public Decimal specialOfferDLDPercentage{get;set;}
        @AuraEnabled public Decimal oppDLDPercentage{get;set;}
        @AuraEnabled public Boolean DLDApplied{get;set;}
        @AuraEnabled public Boolean isDLD{get;set;}
        @AuraEnabled public Boolean selected{get;set;}
        @AuraEnabled public Boolean longApproval{get;set;}
        @AuraEnabled public String exceptionStatus{get;set;}
        @AuraEnabled public Boolean exceptionApproved{get;set;}
        @AuraEnabled public Boolean exceptionPending{get;set;}
    }
}