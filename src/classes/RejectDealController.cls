/**************************************************************************************************
* Name               : RejectDealController                                                      
* Description        : Controller class for rejectDeal component
* Created Date       : 05/05/2022                                                                 
* Created By         : Cloudworks                                                                       
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     05/05/2022     Initial Draft.                                               
**************************************************************************************************/
public with sharing class RejectDealController {

    /******************************************************************************************************
    * @Description        : Function to check for Signed Booking Document                     
    * @Params             : Id oppId, Boolean userSelection
    * @Return             : NKLResponse => Response wrapper                                                                           
    *******************************************************************************************************/
    @AuraEnabled
    public static NKLResponse checkForSignedDocument(Id oppId, Boolean userSelection,String remarks){
        NKLResponse response = new NKLResponse();
        List<String> receivedFor = new List<String>{'Token Amount','Deposit','DLD_FEE'};
        Savepoint sp = Database.setSavepoint();
        try {
            
            Opportunity oppToUpdate = new Opportunity();
            oppToUpdate.Id = oppId;
            oppToUpdate.Unit_Reject_Remarks__c = remarks;

            List<Document__c> docList = [SELECT Id, Attachment_Id__c FROM Document__c WHERE Opportunity__c =: oppId AND Document_Type__c = 'Signed Booking Form'];
            if(!docList.isEmpty()){
                if(userSelection){
                    if(docList[0].Attachment_Id__c == null){
                        response.message = 'Please upload "Signed Booking Form" to proceed.';
                    }else{
                        /*Logic If Signed Booking form Found and User select Yes*/
                        List<Receipt__c> receiptList = [SELECT Id,Received_For__c,Payment_Status__c FROM Receipt__c WHERE Opportunity__c =:oppId AND Received_For__c IN: receivedFor AND Payment_Status__c = 'Cleared'];
                        if(!receiptList.isEmpty()){
                            /*If Signed Booking Form Document has been uploaded and entire amount has been realized (DLD Fee, Down payment and Booking Amount receipts are cleared)*/
                            if(receiptList.size() == 3){
                                oppToUpdate.Reject_Unit__c = true;
                                update oppToUpdate;
                                response.message = 'Close Reject Deal Screen';
                            } 
                            /*If Signed Booking Form Document has been uploaded and partial amount has been realized (some receipts have been cleared only)*/
                            else if(receiptList.size() < 3){
                                update oppToUpdate;
                                submitForApproval('Reject_Unit_Approval', oppId);
                                response.message = 'Close Reject Deal Screen';
                            }
                        }else{
                            /*If No receipt found & Signed Booking form is uploded and user selected Yes*/
                            oppToUpdate.Reject_Unit__c = true;
                            update oppToUpdate;
                            response.message = 'Close Reject Deal Screen';
                        }
                    }
                }else{
                    if(docList[0].Attachment_Id__c == null){
                        /*Logic if Signed Booking form not Found and User select No*/
                        List<Receipt__c> receiptList = [SELECT Id,Received_For__c,Payment_Status__c FROM Receipt__c WHERE Opportunity__c =:oppId AND Received_For__c IN: receivedFor AND Payment_Status__c = 'Cleared'];
                        if(!receiptList.isEmpty()){
                            /*If Signed Booking Form document has not been uploaded and payment was done entire or partial (that is any receipt cleared)*/
                            update oppToUpdate;
                            submitForApproval('Reject_Deal_Partial_Or_Full_Payment', oppId);
                            response.message = 'Close Reject Deal Screen';
                        }else{
                            /*If Signed Booking Form document has not been uploaded and no payment received*/
                            update oppToUpdate;
                            submitForApproval('Reject_Deal_No_Payment_Approval', oppId);
                            response.message = 'Close Reject Deal Screen';
                        }
                    }else{
                        response.message = '"Signed Booking Form" already uploaded please select "Yes" to proceed.';
                    }
                }
            }else{
                if(userSelection){
                    response.message = 'Please Upload "Signed Booking Form" document to proceed.';
                }else{
                    /*Logic if Signed Booking form not Found and User select No*/
                    List<Receipt__c> receiptList = [SELECT Id,Received_For__c,Payment_Status__c FROM Receipt__c WHERE Opportunity__c =:oppId AND Received_For__c IN: receivedFor AND Payment_Status__c = 'Cleared'];
                    if(!receiptList.isEmpty()){
                        /*If Signed Booking Form document has not been uploaded and payment was done entire or partial (that is any receipt cleared)*/
                        update oppToUpdate;
                        submitForApproval('Reject_Deal_Partial_Or_Full_Payment', oppId);
                        response.message = 'Close Reject Deal Screen';
                    }else{
                        /*If Signed Booking Form document has not been uploaded and no payment received*/
                        update oppToUpdate;
                        submitForApproval('Reject_Deal_No_Payment_Approval', oppId);
                        response.message = 'Close Reject Deal Screen';
                    }
                }
            }
        }catch(DmlException e) {            
            if( e.getMessage().contains( 'FIELD_CUSTOM_VALIDATION_EXCEPTION' ) ){
                response.message = e.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').replace(':','').replace('[]','');
            }else{
                response.message = e.getMessage();
            }
            response.success = false;
            Database.RollBack(sp);
        }catch (Exception ex) {
            response.success = false;
            response.message = ex.getMessage();
            Database.RollBack(sp);
        }
        return response;
    }

    public static void submitForApproval(String processName, Id recId){
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        //req.setComments('Submitting request for approval.');
        req.setObjectId(recId);
        req.setSubmitterId(UserInfo.getUserId()); 
        req.setProcessDefinitionNameOrId(processName);
        //req.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req);
    }
}