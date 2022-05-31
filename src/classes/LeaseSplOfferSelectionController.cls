public class LeaseSplOfferSelectionController {
     @AuraEnabled
    public static Boolean checkTaggedUnits(String recordId){
        Boolean unitSearchScreenDisable = false; 
        System.debug('In CheckTagged');
        try {
            Opportunity oppty = [SELECT Id,RecordTypeId,RecordType.Name,StageName,(SELECT Id FROM Unit_Plans__r)
                                 FROM Opportunity WHERE Id =: recordId LIMIT 1];
            if(oppty.StageName != 'New' && oppty.Unit_Plans__r.Size() > 0){
                //unitSearchScreenDisable = true;
            }else{
               // unitSearchScreenDisable = false;
            }
            return unitSearchScreenDisable;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Opportunity getOpp(String recordId){
         Opportunity oppty = [SELECT Id,RecordTypeId,RecordType.Name,StageName,Leasing_Type__c,(SELECT Id,Unit__c FROM Unit_Plans__r)
                                 FROM Opportunity WHERE Id =: recordId LIMIT 1];
        return oppty;
        
        
    }
     @AuraEnabled
    public static List<Lease_Applied_Offer__c> getAppliedOffer(List<Id> setAppliedOfferId){
         List<Lease_Applied_Offer__c> lstAppliedOffer = [select id,Opportunity_Unit__c, Lease_Special_Offer__c,Lease_Special_Offer__r.Name,Lease_Special_Offer__r.Start_Date__c,Lease_Special_Offer__r.End_Date__c, Lease_Special_Offer__r.Project__c,
                                                         Lease_Special_Offer__r.Property_Type__c, Lease_Special_Offer__r.Unit_Type__c, Lease_Special_Offer__r.No_of_Bedrooms__c, 
                                      Lease_Special_Offer__r.Active__c,Lease_Special_Offer__r.Approval_Status__c, Lease_Special_Offer__r.Fit_Out_Days__c, Lease_Special_Offer__r.Rent_Free_Days__c, Lease_Special_Offer__r.Security_Deposit_Percentage__c,Lease_Special_Offer__r.Project__r.Name from Lease_Applied_Offer__c  WHERE Opportunity_Unit__c =: setAppliedOfferId];
        return lstAppliedOffer;
        
        
    }  
     @AuraEnabled
    public static Leasing_Special_Offer__c getOfferdetails(Id offerId){
         Leasing_Special_Offer__c lstAppliedOffer = [select Id, Name, Start_Date__c, End_Date__c, Project__c,Project__r.Name, Property_Type__c, Unit_Type__c, No_of_Bedrooms__c, 
                                      Active__c,Approval_Status__c, Fit_Out_Days__c, Rent_Free_Days__c, Security_Deposit_Percentage__c from Leasing_Special_Offer__c where id=:offerId Limit 1];
        return lstAppliedOffer;
        
        
    }    
    @AuraEnabled
    public static LeaseSplOfrResultWrapper getOffers(String recordId){
        Set<Id> setUnitId=new Set<Id>();
        List<Id> lstOppUnitId=new List<Id>();
        Set<String> setProjectId=new Set<String>();
         Set<String> setNoOfBedrooms=new Set<String>();
         Set<String> setPropertyType=new Set<String>();
        Set<String> setUnitType=new Set<String>();
        List<splOfferDisplayWrapper> lstDispWrap=new List<splOfferDisplayWrapper>();
        List<Unit__c> lstUnit=new List<Unit__c>();
        List<Lease_Applied_Offer__c> lstAppliedOfferExisting=new List<Lease_Applied_Offer__c>();
        List<Leasing_Special_Offer__c> lstLeaseSplOffer=new List<Leasing_Special_Offer__c>();
        LeaseSplOfrResultWrapper wrap=new LeaseSplOfrResultWrapper();
        Id splOfferRecordtype;
        try{
            Opportunity oppty = getOpp(recordId);/*[SELECT Id,RecordTypeId,RecordType.Name,StageName,Leasing_Type__c,(SELECT Id,Unit__c FROM Unit_Plans__r)
                                 FROM Opportunity WHERE Id =: recordId LIMIT 1];*/
            system.debug('oppty>>>>>>>>'+oppty);
            System.debug('oppty.Unit_Plans__r >>>>'+oppty.Unit_Plans__r);
            for(Unit_Plan__c up:oppty.Unit_Plans__r){
                setUnitId.add(up.Unit__c);
                lstOppUnitId.add(up.id);
            }
            if(setUnitId.size()==0){
                wrap.splOfferList=new List<splOfferDisplayWrapper>();
                        wrap.OffersAppliesFlag=false;
                        wrap.appliedOfferList=new List<splOfferDisplayWrapper>();
                        wrap.errorFlag=true;
                        wrap.msg='Please select a unit before selecting Special Offer';
                        system.debug('wrap>>>>'+wrap);
                        return wrap; 
            }
            system.debug('setUnitId>>>>'+setUnitId);
            system.debug('oppty.Leasing_Type__c>>>>'+oppty.Leasing_Type__c);
            if(oppty.Leasing_Type__c=='Residential Units'){
               splOfferRecordtype= Schema.SObjectType.Leasing_Special_Offer__c.getRecordTypeInfosByDeveloperName().get('Residential_Unit').getRecordTypeId(); 
            }
            else if (oppty.Leasing_Type__c=='Commercial Units'){
                splOfferRecordtype=Schema.SObjectType.Leasing_Special_Offer__c.getRecordTypeInfosByDeveloperName().get('Commercial_Unit').getRecordTypeId();
            }
            system.debug('splOfferRecordtype>>>>>'+splOfferRecordtype);
            lstAppliedOfferExisting=getAppliedOffer(lstOppUnitId);
            system.debug('lstAppliedOfferExisting>>>>>'+lstAppliedOfferExisting.size());
            //check if the offers are applied already
            if(lstAppliedOfferExisting.isEmpty()){
                
            
            if(!setUnitId.isEmpty()){
                lstUnit=[select id,Project__c, No_of_Bedrooms__c,  Unit_type__c,Unit_space_Type__c from Unit__c where id in:setUnitId];
                if(!lstUnit.isEmpty()){
                    for(Unit__c u:lstUnit){
                        if(u.Project__c !=null){
                            setProjectId.add(u.Project__c);
                        }
                        if(u.No_of_Bedrooms__c !=null){
                            setNoOfBedrooms.add(u.No_of_Bedrooms__c);
                        }
                        if(u.Unit_type__c !=null){
                            setPropertyType.add(u.Unit_type__c);
                        }
                        if(u.Unit_space_Type__c !=null){
                            setUnitType.add(u.Unit_space_Type__c);
                        }
                    }
                    system.debug('setProjectId>>>>'+setProjectId);
                    system.debug('setNoOfBedrooms>>>>>'+setNoOfBedrooms);
                    system.debug('setPropertyType>>>>>'+setPropertyType);
                    system.debug('setUnitType>>>>'+setUnitType);
                    lstLeaseSplOffer=[select Id, Name, Start_Date__c, End_Date__c, Project__c,Project__r.Name, Property_Type__c, Unit_Type__c, No_of_Bedrooms__c, 
                                      Active__c,Approval_Status__c, Fit_Out_Days__c, Rent_Free_Days__c, Security_Deposit_Percentage__c from Leasing_Special_Offer__c
                                      where Start_Date__c <= today and End_Date__c >= today and Active__c= true and RecordTypeId=: splOfferRecordtype 
                                      and Project__c =: setProjectId and No_of_Bedrooms__c=:setNoOfBedrooms and Property_Type__c =:setPropertyType and Unit_Type__c =: setUnitType ];
                    if(lstLeaseSplOffer.isEmpty()){
                        lstLeaseSplOffer=[select Id, Name, Start_Date__c, End_Date__c, Project__c,Project__r.Name, Property_Type__c, Unit_Type__c, No_of_Bedrooms__c, 
                                      Active__c,Approval_Status__c, Fit_Out_Days__c, Rent_Free_Days__c, Security_Deposit_Percentage__c from Leasing_Special_Offer__c
                                      where Start_Date__c <= today and End_Date__c >= today and Active__c= true and RecordTypeId=: splOfferRecordtype 
                                      and Project__c =: setProjectId and Property_Type__c =:setPropertyType and Unit_Type__c =: setUnitType ];
                    }
                    if(lstLeaseSplOffer.isEmpty()){
                        lstLeaseSplOffer=[select Id, Name, Start_Date__c, End_Date__c, Project__c,Project__r.Name, Property_Type__c, Unit_Type__c, No_of_Bedrooms__c, 
                                      Active__c,Approval_Status__c, Fit_Out_Days__c, Rent_Free_Days__c, Security_Deposit_Percentage__c from Leasing_Special_Offer__c
                                      where Start_Date__c <= today and End_Date__c >= today and Active__c= true and RecordTypeId=: splOfferRecordtype 
                                      and Project__c =: setProjectId and Property_Type__c =:setPropertyType ];
                    }
                    system.debug('lstLeaseSplOffer>>>>>'+lstLeaseSplOffer.size());
                    system.debug('lstLeaseSplOffer>>>>'+lstLeaseSplOffer);
                    if(!lstLeaseSplOffer.isEmpty()){
                        //LeaseSplOfrResultWrapper wrap=new LeaseSplOfrResultWrapper();
                        //make dispWrap List for special offers
                        for(Leasing_Special_Offer__c sp:lstLeaseSplOffer){
                            splOfferDisplayWrapper d=new splOfferDisplayWrapper();
                            d.splOfferId=sp.id;
                            d.name=sp.Name;
                            d.startDate=sp.Start_Date__c;
                            d.endDate=sp.End_Date__c;
                            d.project=sp.Project__c;
                            d.projectName=sp.Project__r.Name;
                            d.propertyType=sp.Property_Type__c;
                            d.unitType=sp.Unit_Type__c;
                            d.noOfBedrooms=sp.No_of_Bedrooms__c;
                            d.rentFreeDays=sp.Rent_Free_Days__c;
                            d.securityDepositPercentage=sp.Security_Deposit_Percentage__c;
                            d.fitOutDays=sp.Fit_Out_Days__c;
                             lstDispWrap.add(d);  
                        }
                        wrap.splOfferList=lstDispWrap;
                        wrap.OffersAppliesFlag=false;
                        wrap.appliedOfferList=new List<splOfferDisplayWrapper>();
                        wrap.errorFlag=false;
                        system.debug('wrap>>>>'+wrap);
                        return wrap;
                    }
                    else{
                        wrap.splOfferList=new List<splOfferDisplayWrapper>();
                        wrap.OffersAppliesFlag=false;
                        wrap.appliedOfferList=new List<splOfferDisplayWrapper>();
                        wrap.errorFlag=true;
                        wrap.msg='No Result found';
                        system.debug('wrap>>>>'+wrap);
                        return wrap;
                    }
                    
                }
            }
            }
            else{
                wrap.splOfferList=null;
                wrap.OffersAppliesFlag=true;
                for(Lease_Applied_Offer__c sp:lstAppliedOfferExisting){
                            splOfferDisplayWrapper d=new splOfferDisplayWrapper();
                            d.splOfferId=sp.Lease_Special_Offer__c;
                            d.name=sp.Lease_Special_Offer__r.Name;
                            d.startDate=sp.Lease_Special_Offer__r.Start_Date__c;
                            d.endDate=sp.Lease_Special_Offer__r.End_Date__c;
                            d.project=sp.Lease_Special_Offer__r.Project__c;
                            d.projectName=sp.Lease_Special_Offer__r.Project__r.Name;
                            d.propertyType=sp.Lease_Special_Offer__r.Property_Type__c;
                            d.unitType=sp.Lease_Special_Offer__r.Unit_Type__c;
                            d.noOfBedrooms=sp.Lease_Special_Offer__r.No_of_Bedrooms__c;
                            d.rentFreeDays=sp.Lease_Special_Offer__r.Rent_Free_Days__c;
                            d.securityDepositPercentage=sp.Lease_Special_Offer__r.Security_Deposit_Percentage__c;
                            d.fitOutDays=sp.Lease_Special_Offer__r.Fit_Out_Days__c;
                             lstDispWrap.add(d);  
                        }
                wrap.appliedOfferList=lstDispWrap;
                wrap.errorFlag=false;
                system.debug('wrap>>>>'+wrap);
                return wrap;
            }
            return wrap;
        }
        catch(Exception e){
            system.debug('Error Occured in LeaseSplOfferSelectionController.getOffer>>>>'+e.getMessage());
            system.debug(e.getLineNumber());
            return null;
        }
    }
    @AuraEnabled
    public static void saveAppliedOffer1(Id offerId,Id oppId){
       List< Leasing_Special_Offer__c> listsp=new List<Leasing_Special_Offer__c>();
        list<Lease_Applied_Offer__c> listAppOff=new list<Lease_Applied_Offer__c>();
        list<Unit_Plan__c> listunitPlan=new List<Unit_Plan__c>();
        list<Unit__c> lstUnit=new list<Unit__c>();
        Map<id,String> mapUnitIdTokeyString=new Map<id,String>();
        Map<id,String> mapUnitIdTokeyString2=new Map<id,String>();
        Map<id,String> mapUnitIdTokeyString3=new Map<id,String>();
        Map<id,String> mapUnitIdTokeyString4=new Map<id,String>();
        Set<Id> setUnitId=new Set<Id>();
        Id appliedOfferRecordtype;
        try{
            Opportunity oppty=getOpp(oppId);
             for(Unit_Plan__c up:oppty.Unit_Plans__r){
                setUnitId.add(up.Unit__c);
            }
            if(!setUnitId.isEmpty()){
                lstUnit=[select id,Project__c, No_of_Bedrooms__c,  Unit_type__c,Unit_space_Type__c from Unit__c where id in:setUnitId];
                if(!lstUnit.isEmpty()){
                    for(Unit__c u:lstUnit){
                        String tempstr=u.Project__c+u.No_of_Bedrooms__c+u.Unit_type__c+u.Unit_space_Type__c;
                        system.debug('tempstr >>>>'+tempstr);
                        mapUnitIdTokeyString.put(u.id,tempstr);
                        String tempstr2=u.Project__c+u.Unit_type__c+u.Unit_space_Type__c;
                        system.debug('tempstr2 >>>>'+tempstr2);
                        mapUnitIdTokeyString2.put(u.id,tempstr2);
                         String tempstr3=u.Project__c+u.Unit_type__c;
                        system.debug('tempstr3 >>>>'+tempstr3);
                        mapUnitIdTokeyString3.put(u.id,tempstr3);
                         
                    }
                    
                }
                
            }
        system.debug('mapUnitIdTokeyString >>>>'+mapUnitIdTokeyString);            
            listsp=[select Id, Name, Start_Date__c, End_Date__c, Project__c, Property_Type__c, Unit_Type__c, No_of_Bedrooms__c, 
               Active__c,Approval_Status__c, Fit_Out_Days__c, Rent_Free_Days__c, Security_Deposit_Percentage__c from Leasing_Special_Offer__c where id =: offerId Limit 1];
            String splOfferKey=listsp[0].Project__c+listsp[0].No_of_Bedrooms__c+listsp[0].Property_Type__c+listsp[0].Unit_Type__c;
           system.debug('splOfferKey'+splOfferKey);
            String splOfferKey2=listsp[0].Project__c+listsp[0].Property_Type__c+listsp[0].Unit_Type__c;
           system.debug('splOfferKey2'+splOfferKey2);
            String splOfferKey3=listsp[0].Project__c+listsp[0].Property_Type__c;
           system.debug('splOfferKey3'+splOfferKey3);
            
            system.debug('oppty.Leasing_Type__c>>>>'+oppty.Leasing_Type__c);
            if(oppty.Leasing_Type__c=='Residential Units'){
               appliedOfferRecordtype= Schema.SObjectType.Lease_Applied_Offer__c.getRecordTypeInfosByDeveloperName().get('Residential_Unit').getRecordTypeId(); 
            }
            else if (oppty.Leasing_Type__c=='Commercial Units'){
                appliedOfferRecordtype=Schema.SObjectType.Lease_Applied_Offer__c.getRecordTypeInfosByDeveloperName().get('Commercial_Unit').getRecordTypeId();
            }
            system.debug('appliedOfferRecordtype>>>>>'+appliedOfferRecordtype);
            
            for(Unit_Plan__c up:oppty.Unit_Plans__r){
                if(mapUnitIdTokeyString.containsKey(up.Unit__c) && mapUnitIdTokeyString.get(up.Unit__c)==splOfferKey){
                    system.debug('>>>>>>>>>>'+mapUnitIdTokeyString.get(up.Unit__c));
                    system.debug('>>>>>>>>>>'+splOfferKey);
                    
                        Lease_Applied_Offer__c ao=new Lease_Applied_Offer__c();
                        ao.Lease_Special_Offer__c=OfferId;
                        ao.Opportunity_Unit__c=up.id;
                    ao.RecordTypeId=appliedOfferRecordtype;
                        listAppOff.add(ao);
                    
                }
               else if(mapUnitIdTokeyString2.containsKey(up.Unit__c) && mapUnitIdTokeyString2.get(up.Unit__c)==splOfferKey2){
                    system.debug('>>>>>>>>>>'+mapUnitIdTokeyString2.get(up.Unit__c));
                    system.debug('>>>>>>>>>>'+splOfferKey2);
                    
                        Lease_Applied_Offer__c ao=new Lease_Applied_Offer__c();
                        ao.Lease_Special_Offer__c=OfferId;
                        ao.Opportunity_Unit__c=up.id;
                   ao.RecordTypeId=appliedOfferRecordtype;
                        listAppOff.add(ao);
                    
                }
                else if(mapUnitIdTokeyString3.containsKey(up.Unit__c) && mapUnitIdTokeyString3.get(up.Unit__c)==splOfferKey3){
                    system.debug('>>>>>>>>>>'+mapUnitIdTokeyString.get(up.Unit__c));
                    system.debug('>>>>>>>>>>'+splOfferKey);
                   
                        Lease_Applied_Offer__c ao=new Lease_Applied_Offer__c();
                        ao.Lease_Special_Offer__c=OfferId;
                        ao.Opportunity_Unit__c=up.id;
                    ao.RecordTypeId=appliedOfferRecordtype;
                        listAppOff.add(ao);
                    
                }
            }
            system.debug('listAppOff'+listAppOff);
            if(!listAppOff.isEmpty()){
                insert listAppOff;
                system.debug('@@@@Grace period Update@@@@');
                Leasing_Special_Offer__c splOfr=getOfferdetails(OfferId);
                Opportunity o=new Opportunity();
                o.id=oppty.Id;
                system.debug('.Leasing_Type__c'+oppty.Leasing_Type__c);
                if(oppty.Leasing_Type__c=='Residential Units'){
                    o.Grace_Period_Days__c=splOfr.Rent_Free_Days__c;
                }
                else{
                    o.Grace_Period_Days__c=splOfr.Fit_Out_Days__c;
                }
                
                update o;
            }
            
        }
        catch(Exception e){
            system.debug('Error Occured in LeaseSplOfferSelectionController.saveAppliedOffer>>>>'+e.getMessage());
            system.debug(e.getLineNumber());
            //return null;
        }
    }
    @AuraEnabled
    public static void deleteAppliedOffer1(String opp){
       list<Lease_Applied_Offer__c> listAppliedOfferonOpp=new list<Lease_Applied_Offer__c>();
        Set<Id>setOppUnitId=new Set<Id>();
        try{
            Opportunity oppty=getOpp(opp);
            for(Unit_Plan__c up:oppty.Unit_Plans__r){
                setOppUnitId.add(up.id);
            }
            listAppliedOfferonOpp=[select id,Lease_Special_Offer__c,Opportunity_Unit__c from Lease_Applied_Offer__c where Opportunity_Unit__c =:setOppUnitId ];
            delete listAppliedOfferonOpp;
        }
        catch(Exception e){
            system.debug('Error Occured in LeaseSplOfferSelectionController.saveAppliedOffer>>>>'+e.getMessage());
            system.debug(e.getLineNumber());
            //return null;
        }
    }
    
    public class LeaseSplOfrResultWrapper{
         @AuraEnabled 
        public List<splOfferDisplayWrapper> splOfferList{get;set;}
         @AuraEnabled 
        public Boolean offersAppliesFlag{get;set;}
         @AuraEnabled 
        public List<splOfferDisplayWrapper> appliedOfferList{get;set;}
        @AuraEnabled 
        public Boolean errorFlag{get;set;}
        @AuraEnabled 
        public string msg{get;set;}
    }
    Public class splOfferDisplayWrapper{//this wrapper is used to diaplay applied and available offers
        @AuraEnabled 
        public string splOfferId{get;set;} 
        @AuraEnabled 
        public string name{get;set;}
        @AuraEnabled 
        public date startDate{get;set;}
        @AuraEnabled 
        public date endDate{get;set;}
        @AuraEnabled 
        public String project{get;set;}
        @AuraEnabled 
        public String projectName{get;set;}
        @AuraEnabled 
        public String propertyType{get;set;}
        @AuraEnabled 
        public String unitType{get;set;}
        @AuraEnabled 
        public String noOfBedrooms{get;set;}
        @AuraEnabled 
        public Decimal rentFreeDays{get;set;}
        @AuraEnabled 
        public Decimal securityDepositPercentage{get;set;}
        @AuraEnabled 
        public Decimal fitOutDays{get;set;}
        
        
    }
}