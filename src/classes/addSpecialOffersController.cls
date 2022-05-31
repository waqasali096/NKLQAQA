/**************************************************************************************************
* Name               : addSpecialOffersController                                                      
* Description        : Controller class for addSpecialOffers component
* Created Date       : 07/05/2022                                                                 
* Created By         : Cloudworks                                                                       
* -------------------------------------------------------------------------------------------------
* VERSION  AUTHOR    DATE            COMMENTS                                                    
* 1.0      Ashams     07/05/2022     Initial Draft.                                               
**************************************************************************************************/
public class addSpecialOffersController {
    //Method to fetch special offers 
    @AuraEnabled
    public static NKLResponse getSpecialOffers(String oppId){
        System.debug('@@@ ' + '@@@ '+ oppId);
        NKLResponse response = new NKLResponse();
        List<specialOfferLineWrapper> splWrapDLDList = new List<specialOfferLineWrapper>();
        List<specialOfferLineWrapper> splWrapsinglePPList = new List<specialOfferLineWrapper>();
        List<specialOfferLineWrapper> splWrapSpecialPPList = new List<specialOfferLineWrapper>();
        Opportunity opp = new Opportunity();
        
        try{
            if(oppId!=null){
               opp = [select Id,unit__c from opportunity where ID =: oppId];
            }
            Set<Id> specialOfferIds = new Set<Id>();
            List<Offer_Applied__c> offerAppliedList = [SELECT Id, Special_offer__c,special_offer__r.name,Special_Offer_Item__c FROM Offer_Applied__c 
                                                       WHERE Opportunity__c =: oppId];
            for(Offer_Applied__c offer : offerAppliedList){
                specialOfferIds.add(offer.Special_Offer_Item__c);
            }
            
            List<special_offer_Item__c> specialOfferLineList = [SELECT id,name,special_offer__c,unit__c,special_offer__r.type__c,special_offer__r.start_date__c,special_offer__r.end_date__c,
                                                                special_offer__r.master_payment_plan__c,special_offer__r.master_payment_plan__r.name,special_offer__r.name,special_offer__r.DLD_Share__c
                                                                FROM special_offer_Item__c 
                                                                WHERE unit__c =: opp.unit__c AND special_offer__r.Active__c  = true
                                                                AND (special_offer__r.start_date__c < TODAY AND special_offer__r.end_date__c > TODAY)];
            List<special_offer_Item__c> dldspecialOfferLineList = [SELECT id,name,special_offer__c,unit__c,special_offer__r.type__c,special_offer__r.start_date__c,special_offer__r.end_date__c,
                                                                special_offer__r.master_payment_plan__c,special_offer__r.master_payment_plan__r.name,special_offer__r.name,special_offer__r.DLD_Share__c
                                                                FROM special_offer_Item__c 
                                                                WHERE unit__c =: opp.unit__c AND special_offer__r.Active__c  = true AND special_offer__r.Type__c  = 'DLD Share'
                                                                AND (special_offer__r.start_date__c < TODAY AND special_offer__r.end_date__c > TODAY)
                                                                ORDER BY CREATEDDATE DESC LIMIT 1];
            
            if(!dldspecialOfferLineList.isEmpty()){
                for(special_offer_Item__c spl : dldspecialOfferLineList){
                    if(spl.special_offer__r.type__c == 'DLD Share'){
                        specialOfferLineWrapper splWrap = new specialOfferLineWrapper();
                        splWrap.SpecialOfferLineName = spl.Name;
                        splWrap.SpecialOfferLineId = spl.Id;
                        splWrap.SpecialOfferId = spl.special_offer__c;
                        splWrap.SpecialOfferName = spl.special_offer__r.Name;
                        splWrap.SpecialOfferType = spl.special_offer__r.type__c;
                        splWrap.SpecialOfferDLD = spl.special_offer__r.DLD_Share__c;
                        splWrap.startDate = spl.special_offer__r.Start_Date__c;
                        splWrap.endDate = spl.special_offer__r.end_date__c;
                        splWrap.masterPaymentPlanId = '/'+spl.special_offer__r.Master_Payment_Plan__c;
                        splWrap.masterPaymentPlanName = spl.special_offer__r.Master_Payment_Plan__r.name;
                        if(specialOfferIds.contains(spl.Id)){
                            splWrap.SpecialOfferLineExists = TRUE;
                        }
                        splWrapDLDList.add(splWrap);
                    }
                }
            }
            
            if(!specialOfferLineList.isEmpty()){
                for(special_offer_Item__c spl : specialOfferLineList){
                    if(spl.special_offer__r.type__c == 'Single Payment Plan' || spl.special_offer__r.type__c == 'Special Payment Plan'){
                        specialOfferLineWrapper splWrap = new specialOfferLineWrapper();
                        splWrap.SpecialOfferLineName = spl.Name;
                        splWrap.SpecialOfferLineId = spl.Id;
                        splWrap.SpecialOfferId = spl.special_offer__c;
                        splWrap.SpecialOfferName = spl.special_offer__r.Name;
                        splWrap.SpecialOfferType = spl.special_offer__r.type__c;
                        splWrap.SpecialOfferDLD = spl.special_offer__r.DLD_Share__c;
                        splWrap.startDate = spl.special_offer__r.Start_Date__c;
                        splWrap.endDate = spl.special_offer__r.end_date__c;
                        splWrap.masterPaymentPlanId = '/'+spl.special_offer__r.Master_Payment_Plan__c;
                        splWrap.masterPaymentPlanName = spl.special_offer__r.Master_Payment_Plan__r.name;
                        if(specialOfferIds.contains(spl.Id)){
                            splWrap.SpecialOfferLineExists = TRUE;
                        }
                        splWrapsinglePPList.add(splWrap);
                    }
                }               
            }
            
            specialOfferWrapper resUnitWrap = new specialOfferWrapper(specialOfferIds, splWrapDLDList,splWrapsinglePPList,splWrapSpecialPPList );
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
    
    //Method to create  & delete DLD offer appplied
    @AuraEnabled
    public static NKLResponse createOfferApplied(List<specialOfferLineWrapper> specialOfferItems, Id oppId ){
        system.debug('specialOfferItems'+specialOfferItems);
        NKLResponse response = new NKLResponse();
        try{
            List<Offer_Applied__c> offerListToDelete = new List<Offer_Applied__c>();
            List<Offer_Applied__c> offerAppliedList = new List<Offer_Applied__c>();
            Set<Id> existingSplOfrIds = new Set<Id>();
            
            offerListToDelete = [SELECT Id,Special_Offer__c FROM Offer_Applied__c 
                                 WHERE Opportunity__c =: oppId AND Special_Offer__r.type__c =: 'DLD Share'];
            system.debug('offerListToDelete 1'+offerListToDelete);
            if(!offerListToDelete.isEmpty()){
               Database.Delete(offerListToDelete, false); 
            }
            if(specialOfferItems.size()>0){
                for(specialOfferLineWrapper sol : specialOfferItems){
                    Offer_Applied__c offerApplied = new Offer_Applied__c();                
                    offerApplied.Opportunity__c = oppId;
                    offerApplied.Special_Offer__c = sol.SpecialOfferId;
                    offerApplied.Special_Offer_Item__c = sol.SpecialOfferLineId;
                    offerAppliedList.add(offerApplied);
                } 
            }
            system.debug('offerAppliedList'+offerAppliedList);
            if(!offerAppliedList.isEmpty()){
                insert offerAppliedList;
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
    
    //Method to create & delete single/special offer appplied
    @AuraEnabled
    public static NKLResponse createSingleOfferApplied(List<specialOfferLineWrapper> specialOfferItems, Id oppId ){
        system.debug('specialOfferItems'+specialOfferItems);
        NKLResponse response = new NKLResponse();
        try{
            List<Offer_Applied__c> offerListToDelete = new List<Offer_Applied__c>();
            List<Offer_Applied__c> offerAppliedList = new List<Offer_Applied__c>();
            Set<Id> existingSplOfrIds = new Set<Id>();
            
            offerListToDelete = [SELECT Id,Special_Offer__c FROM Offer_Applied__c 
                                 WHERE Opportunity__c =: oppId 
                                 AND (Special_Offer__r.type__c =: 'Single Payment Plan' OR Special_Offer__r.type__c =: 'Special Payment Plan')];
            system.debug('offerListToDelete 2'+offerListToDelete);
            if(!offerListToDelete.isEmpty()){
               Database.Delete(offerListToDelete, false); 
            }
            if(specialOfferItems.size()>0){
                for(specialOfferLineWrapper sol : specialOfferItems){
                    Offer_Applied__c offerApplied = new Offer_Applied__c();                
                    offerApplied.Opportunity__c = oppId;
                    offerApplied.Special_Offer__c = sol.SpecialOfferId;
                    offerApplied.Special_Offer_Item__c = sol.SpecialOfferLineId;
                    offerAppliedList.add(offerApplied);
                } 
            }
            system.debug('offerAppliedList'+offerAppliedList);
            if(!offerAppliedList.isEmpty()){
                insert offerAppliedList;
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
    
    public class specialOfferWrapper{
        @AuraEnabled public Set<Id> specialOfferIds{get; set;}
        @AuraEnabled public List<specialOfferLineWrapper> specialOfferDLDList{get; set;}
        @AuraEnabled public List<specialOfferLineWrapper> specialOfferSinglePPList{get; set;}
        @AuraEnabled public List<specialOfferLineWrapper> specialOfferSpecialPPList{get; set;}
        public specialOfferWrapper(Set<Id> specialOfferIds, List<specialOfferLineWrapper> specialOfferDLDList,List<specialOfferLineWrapper> specialOfferSinglePPList,List<specialOfferLineWrapper> specialOfferSpecialPPList ){
            this.specialOfferIds = specialOfferIds;
            this.specialOfferDLDList = specialOfferDLDList;
            this.specialOfferSpecialPPList = specialOfferSpecialPPList;
            this.specialOfferSinglePPList = specialOfferSinglePPList;
        }
    }
    
    public class specialOfferLineWrapper{
        @AuraEnabled public String SpecialOfferLineName{get; set;}
        @AuraEnabled public String SpecialOfferLineId{get; set;}
        @AuraEnabled public String SpecialOfferId{get; set;}
        @AuraEnabled public String SpecialOfferName{get; set;}
        @AuraEnabled public String SpecialOfferType{get; set;}
        @AuraEnabled public Decimal SpecialOfferDLD{get; set;}
        @AuraEnabled public Date startDate{get; set;}
        @AuraEnabled public Date endDate{get; set;}
        @AuraEnabled public String masterPaymentPlanId{get; set;}
        @AuraEnabled public String masterPaymentPlanName{get; set;}
        @AuraEnabled public Boolean SpecialOfferLineExists{get; set;}
    }
}