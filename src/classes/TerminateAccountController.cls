/**************************************************************************************************
* Name               : TerminateAccountController                                                      
* Description        : Controller class for Image Terminate Account component
* Created Date       : 17/10/2021                                                                 
* Created By         : Cloudworks                                                                       
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     17/10/2021     Initial Draft.                                               
**************************************************************************************************/
public class TerminateAccountController {

    /******************************************************************************************************
    * @Description        : Function to create document                      
    * @Params             : Id accId => account Id  
    * @Return             : NKLResponse => Response wrapper                                                                           
    *******************************************************************************************************/
    @AuraEnabled
    public static NKLResponse createDocument( Id accId ){
        NKLResponse response = new NKLResponse();
        try{
            Document__c doc;
            for( Document__c docObj : [SELECT Id from Document__c WHERE Account__c =: accId AND Document_Type__c = 'Account Termination Notice'] ){
                doc = docObj;
            }
            if( doc == null ){
                Document__c docObj = new Document__c();
                docObj.Account__c = accId;
                docObj.Document_Type__c = 'Account Termination Notice';
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
    * @Description        : Function to delete the document                      
    * @Params             : Id docId => doc Id  
    * @Return             : NKLResponse => Response wrapper                                                                           
    *******************************************************************************************************/
    @AuraEnabled
    public static NKLResponse deleteDocument( String docId ){
        NKLResponse response = new NKLResponse();
        try{
            delete [ SELECT ID, Name FROM Document__c WHERE Id = :docId ];
        }catch( Exception ex ){
            system.debug( 'Exception => '+ex.getMessage() );
            response.success = false;
            response.message = ex.getMessage();
        }
        return response;
    }


    /******************************************************************************************************
    * @Description        : Function to save the file                        
    * @Params             : Id accId => account Id  
    * @Params             : Boolean noticeCheck 
    * @Params             : String reason => reason  
    * @Params             : String strFileName => file name  
    * @Params             : String base64String => base64 content for file     
    * @Return             : NKLResponse => Response wrapper                                                                           
    *******************************************************************************************************/
    @AuraEnabled
    public static NKLResponse saveFile(Id accId, Boolean noticeCheck, String reason, Id documentId, Id conDocId){
        NKLResponse response = new NKLResponse();
        ResultWrapper obj = new ResultWrapper();

        try{            
            Document__c dd = new Document__c();
            dd.Id = documentId;
            dd.Attachment_Id__c = conDocId;
            update dd;

            Account acc = new Account();
            acc.Id = accId;
            acc.Termination_Notice_Verified_and_Uploaded__c = noticeCheck;
            acc.Termination_Reason__c = reason;
            update acc;
            response.data = obj;
        }catch(Exception ex) {
            System.debug('Error: '+ex.getMessage()+' Please contact your system admin.');  
            response.success = false;
            response.message = ex.getMessage();
        }
        return response;
    }
    public class ResultWrapper {
        @AuraEnabled public Boolean isUpdateSuccess{get;set;}
        @AuraEnabled public Boolean terminationNotice{get;set;}
        @AuraEnabled public String terminationReason{get;set;}
    }
}