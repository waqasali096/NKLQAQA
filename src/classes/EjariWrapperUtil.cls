/* Created By: Taha Hamid
Description: This class will be used as generic class to cater the payload xml and soapaction
*/
public class EjariWrapperUtil 
{
        @AuraEnabled        
        public string body {get;set;}
        @AuraEnabled       
        public string soapAction {get;set;}
}