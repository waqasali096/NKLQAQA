/****************************************************************************************************************************
* @Name         UnitSearchAPI
* @Author       Hitesh Patel, Kitaracloud Techlabs
* @Date         12-May-2022
* @Description  Property Search Metadata & Property Search
****************************************************************************************************************************/
@RestResource(urlMapping='/UnitSearch')
global class UnitSearchAPI {
	@httpPost
    global static UnitSearchResponse doPostMethod(){
        RestRequest request = RestContext.request;
        UnitSearchResponse objUSR = new UnitSearchResponse();
        
        UnitSearchRequest objReq = (UnitSearchRequest) System.JSON.deserialize(request.requestBody.toString(), UnitSearchRequest.class);
        if(objReq.propertyCode != null && objReq.propertyCode != ''){
            String soql = 'SELECT ';
            soql += queryAllFields('Unit__c') + ', ';
            soql += ' Project__r.Project_Code__c, Location__r.Name, Floor__r.Name, ';
            soql += ' Business_Unit__r.Business_Group_Id__c, Business_Unit__r.Business_Unit_Code__c, Business_Unit__r.Name,Unit_Leasing_Type__r.Name ';
            soql += ' FROM Unit__c ';
            String strPropertycode = objReq.propertyCode;
            if(objReq.propertyCode != null && objReq.propertyCode != ''){
                 soql += ' WHERE Project__r.Project_Code__c =: strPropertycode';
            }
            String strCommunityName = '';
            if(objReq.CommunityName != null && objReq.CommunityName != ''){
                strCommunityName = objReq.CommunityName;
                soql += ' AND Project__r.Name =: strCommunityName';
            }
            String strBuildingCode = '';
            if(objReq.buildingCode != null && objReq.buildingCode != ''){
                strBuildingCode = objReq.buildingCode;
                soql += ' AND Building_Code__c =: strBuildingCode';
            }
            String strFloorCode = '';
            if(objReq.floorCode != null && objReq.floorCode != ''){
                strFloorCode = objReq.floorCode;
                soql += ' AND Floor_Code__c =: strFloorCode';
            }
            String strSpaceTypeCode = '';
            if(objReq.spaceTypeCode != null && objReq.spaceTypeCode != ''){
                strSpaceTypeCode = objReq.spaceTypeCode;
                soql += ' AND Space_Type_Lookup_Code__c =: strSpaceTypeCode';
            }
            
            decimal minimumBaseRent = 0;
            if(objReq.MinPrice != null && objReq.MinPrice != 'Any'){
                minimumBaseRent = Decimal.valueOf(objReq.MinPrice);
                soql += ' AND Base_Rent__c >=: minimumBaseRent';
            }
            
            decimal maximumBaseRent = 0;
            if(objReq.MaxPrice != null && objReq.MaxPrice != 'Any'){
                maximumBaseRent = Decimal.valueOf(objReq.MaxPrice);
                soql += ' AND Base_Rent__c <=: maximumBaseRent';
            }
            
            String strStatus = '';
            if(objReq.Status != null && objReq.Status != ''){
                strStatus = objReq.Status;
                soql += ' AND Unit_Status__c =: strStatus';
            }
            
            decimal minimumArea = 0;
            if(objReq.MinArea != null && objReq.MinArea != 'Any'){
                minimumArea = Decimal.valueOf(objReq.MinArea);
                soql += ' AND Total_Leasable_Area__c >=: minimumArea';
            }
            
            decimal maximumArea = 0;
            if(objReq.MaxArea != null && objReq.MaxArea != 'Any'){
                maximumArea = Decimal.valueOf(objReq.MaxArea);
                soql += ' AND Total_Leasable_Area__c <=: maximumArea';
            }
            set<String> sUnitStatustoReturn = new set<String>();
            sUnitStatustoReturn.add('Vacant');
            sUnitStatustoReturn.add('Refurbishment');
            soql += ' AND Unit_Status__c IN: sUnitStatustoReturn';
            
            System.debug('SOQL'+soql);
            List<Unit__c> unitListFound = database.query(soql);
            objUSR.success = 'true';
            objUSR.total = string.valueOf(unitListFound.size());
            
            List<UnitWrapper> unitList = new List<UnitWrapper>();
            UnitWrapper objUW;
            String strGParentLocationCode = '';
            String strGParentLocationName = '';
            String strParentLocationCode = '';
            String strParentLocationName = '';
            for(Unit__c uw: unitListFound){
                strGParentLocationCode = '';
                strGParentLocationName = '';
                strParentLocationCode = '';
                strParentLocationName = '';
                
                objUW = new UnitWrapper();
                objUW.assignableArea = '';
                if(uw.Total_Leasable_Area__c != null){
                    objUW.assignableArea = String.valueOf(uw.Total_Leasable_Area__c);
                }
                objUW.anticipatedCompletionDate = ''; // Not Found
                objUW.communityLink = ''; // Not Found
                objUW.functionType = ''; // ?
                objUW.functionTypeLookupCode = ''; // ?
                if(uw.Building_Code__c != null){
                    strGParentLocationCode = uw.Building_Code__c;
                    strGParentLocationName = uw.Building_Name__c;
                }else{
                    if(uw.Project__c != null && uw.Project__r.Project_Code__c != null){
                        strGParentLocationCode = uw.Project__r.Project_Code__c;
                        strGParentLocationName = uw.Project_Name__c;
                    }
                }
                objUW.GParentLocationCode = strGParentLocationCode;
                objUW.GParentLocationName = strGParentLocationName;
                objUW.LocationCode = '';
                if(uw.Unit_Code__c != null){
                    objUW.LocationCode = uw.Unit_Code__c;
                }
                objUW.LocationId = '';
                if(uw.ERP_Unit_Id__c != null){
                    objUW.LocationId = uw.ERP_Unit_Id__c;
                }
                
                objUW.LocationName = '';
                if(uw.Leasing_Property_Type__c != null){
                    objUW.LocationName = uw.Leasing_Property_Type__c;
                }
                objUW.MasterCommunity = '';
                if(uw.Project_Name__c != null){
                    objUW.MasterCommunity = uw.Project_Name__c;
                }
                if(uw.Floor__c != null && uw.Floor_Code__c != null){
                    strParentLocationCode = uw.Floor_Code__c;
                    strParentLocationName = uw.Floor__r.Name;
                }else{
                    if(uw.Project__c != null && uw.Project__r.Project_Code__c != null){
                        strParentLocationCode = uw.Project__r.Project_Code__c;
                        strParentLocationName = uw.Project_Name__c;
                    }
                }
                objUW.ParentLocationCode = strParentLocationCode;
                objUW.ParentLocationName = strParentLocationName;
                objUW.PropertyCode = '';
                objUW.PropertyName = '';
                if(uw.Business_Unit__c != null && uw.Business_Unit__r.Business_Unit_Code__c != null){
                    objUW.PropertyCode = uw.Business_Unit__r.Business_Unit_Code__c;
                    objUW.PropertyName = uw.Business_Unit__r.Name;
                }
                objUW.RentValue = '';
                if(uw.Base_Rent__c != null){
                    objUW.RentValue = String.valueOf(uw.Base_Rent__c);
                }
                objUW.SpaceType = '';
                if(uw.Unit_Leasing_Type__r.Name != null){
                    objUW.SpaceType = uw.Unit_Leasing_Type__r.Name;
                }
                objUW.SpaceTypeLookupCode = '';
                if(uw.Space_Type_Lookup_Code__c != null){
                    objUW.SpaceTypeLookupCode = uw.Space_Type_Lookup_Code__c;
                }
                objUW.StandardType = '';
                if(uw.Unit_space_Type__c != null){
                    objUW.StandardType = uw.Unit_space_Type__c;
                }
                objUW.StandardTypeLookupCode = ''; // Not found
                objUW.Status = '';
                if(uw.Unit_Status__c != null){
                    objUW.Status = uw.Unit_Status__c;
                }
                objUW.UsableArea = '';
                if(uw.Total_Leasable_Area__c != null){
                    objUW.UsableArea = String.valueOf(uw.Total_Leasable_Area__c);
                }
               
                unitList.add(objUW);
            }
            objUSR.listOfUnits = unitList;
        }else{
            objUSR.success = 'Please specify property code.';
            objUSR.total = '0';
            objUSR.listOfUnits = new List<UnitWrapper>();
        }
        return objUSR;
    }
    global class UnitSearchRequest{
        global String CommunityName;
        global String propertyCode;
        global String buildingCode;
        global String floorCode;
        global String spaceTypeCode;
        global String MinPrice;
        global String MaxPrice;
        global String Status;
        global String MinArea;
        global String MaxArea;
    }
    
    global class UnitSearchResponse{
        global String success;
        global String total;
        global List<UnitWrapper> listOfUnits;
    }
    global class UnitWrapper{
        global String assignableArea;
        global String anticipatedCompletionDate;
        global String communityLink;
        global String functionType;
        global String functionTypeLookupCode;
        global String GParentLocationCode;
        global String GParentLocationName;
        global String LocationCode;
        global String LocationId;
        global String LocationName;
        global String MasterCommunity;
        global String ParentLocationCode;
        global String ParentLocationName;
        global String PropertyCode;
        global String PropertyName;
        global String RentValue;
        global String SpaceType;
        global String SpaceTypeLookupCode;
        global String StandardType;
        global String StandardTypeLookupCode;
        global String Status;
        global String UsableArea;
    }
    /*
        Method Name: queryAllFields
        Description: This method is used to return all fields of sObject 
        Parameter  : sObject API Name
    */
    Public static string queryAllFields(String strObjectAPIName){
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(strObjectAPIName).getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        String queryFields = String.join( fieldNames, ',' );
        return queryFields;
    }// END OF METHOD - queryAllFields
}