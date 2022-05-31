/**************************************************************************************************
* Name               : NKLResponse                                                      
* Description        : Response class for all lwc callouts
* Created Date       : 20/01/2022                                                                 
* Created By         : Cloudworks                                                                       
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     20/01/2021     Initial Draft.                                               
**************************************************************************************************/
public class NKLResponse {
    @AuraEnabled public Object data     {get;set;}
    @AuraEnabled public String message  {get;set;}
    @AuraEnabled public Boolean success {get;set;}

    public NKLResponse(){
        this.message = 'Success';
        this.success = true;
    }
}