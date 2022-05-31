/**************************************************************************************************
* Name               : ImageSliderController                                                      
* Description        : Controller class for Image Slider lwc component
* Created Date       : 14/10/2021                                                                 
* Created By         : Cloudworks                                                                       
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Rohit     14/10/2021     Initial Draft.                                               
**************************************************************************************************/
public class ImageSliderController {
    
    /******************************************************************************************************
    * @Description        : Function to get the slider images                        
    * @Params             : String metadataName => Metadata name for slider      
    * @Return             : NKLResponse => Response wrapper                                                                           
    *******************************************************************************************************/
    @AuraEnabled
    public static NKLResponse fetchImageSliderMetadata( String metadataName ){
        NKLResponse response = new NKLResponse();
        List< String > lstUrlsToReturn = new List< String >();
        try{    
            NKL_Org_Config__mdt config;
            for( NKL_Org_Config__mdt orgConfig : [ SELECT Id, MasterLabel, DeveloperName, Process_Name__c, Config_Details_JSON__c
                                                   FROM NKL_Org_Config__mdt
                                                   WHERE Process_Name__c = : metadataName ] ){
                config = orgConfig;
            }

            List< String > imageUrls = new List< String >();
            String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
            if( config != null ){
                imageUrls = ( List< String > )System.JSON.deserialize( config.Config_Details_JSON__c, List< String >.class );
            }
            response.data = imageUrls;
        }catch( Exception ex ){
            system.debug( 'Exception => '+ex.getMessage() );
            response.success = false;
            response.message = ex.getMessage();
        }
        return response;
    }
}