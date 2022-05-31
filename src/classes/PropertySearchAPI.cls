/****************************************************************************************************************************
* @Name         PropertySearchAPI
* @Author       Hitesh Patel, Kitaracloud Techlabs
* @Date         12-May-2022
* @Description  Property Search Metadata & Property Search
****************************************************************************************************************************/
@RestResource(urlMapping='/PropertySearch')
global class PropertySearchAPI {
    @httpPost
    global static PropertySearchResponse doPostMethod(){
        RestRequest request = RestContext.request;
        PropertySearchResponse objPSR = new PropertySearchResponse();
        objPSR.context = '';
        objPSR.propertyCode = '';
        objPSR.listOfProjects = new List<ProjectWrapper>();
        objPSR.listOfBuilding = new List<BuildingWrapper>();
        objPSR.listOfFloors = new List<FloorWrapper>();
        objPSR.listOfSpaceTypes = new List<SpaceTypeWrapper>();
        
        PropertySearchRequest objReq = (PropertySearchRequest) System.JSON.deserialize(request.requestBody.toString(), PropertySearchRequest.class);
        
        if(objReq.context != null && objReq.context != ''){ 
            if(objReq.context == 'propertyName'){
                String strSOQL = 'SELECT Id, Name, Project_Code__c FROM Project__c WHERE Project_Purpose__c = \'Leasing\' AND Project_Code__c != null';
                String strPropertyCode;
                if(objReq.propertyCode != null && objReq.propertyCode != ''){
                    strPropertyCode = objReq.propertyCode;
                    strSOQL += ' AND Project_Code__c =: strPropertyCode';
                }
                List<Project__c> projectListFound = database.query(strSOQL);
                if(!projectListFound.isEmpty()){
                    
                    List<ProjectWrapper> projectList = new List<ProjectWrapper>();
                    ProjectWrapper objPW;
                    for(Project__c prj: projectListFound){
                        objPW = new ProjectWrapper();
                        objPW.propertyCode = '';
                        if(prj.Project_Code__c != null){
                            objPW.propertyCode = prj.Project_Code__c;
                        }
                        objPW.propertyName = prj.Name;
                        projectList.add(objPW);
                    }
                    objPSR.context = 'propertyName';
                    objPSR.propertyCode = '';
                    objPSR.listOfProjects = projectList;
                    objPSR.status = 'Success';
                    objPSR.message = 'Projects found successfully!';
                }else{
                    objPSR.status = 'Success';
                    objPSR.message = 'Projects not found!';
                }
            }else if(objReq.context == 'Building'){
                if(objReq.propertyCode != null && objReq.propertyCode != ''){
                    objPSR.propertyCode = objReq.propertyCode;
                    String strSOQL = 'SELECT Id, Name, Building_Code__c FROM Building__c WHERE Project__r.Project_Purpose__c = \'Leasing\' AND Project__r.Project_Code__c != null';
                    String strPropertyCode = objReq.propertyCode;
                    strSOQL += ' AND Project__r.Project_Code__c =: strPropertyCode';
                    
                    String strBuildingCode;
                    if(objReq.buildingCode != null && objReq.buildingCode != ''){
                        strBuildingCode = objReq.buildingCode;
                        strSOQL += ' AND Building_Code__c =: strBuildingCode';
                    }
                    List<Building__c> buildingListFound = database.query(strSOQL);
                    List<BuildingWrapper> buildingList = new List<BuildingWrapper>();
                    BuildingWrapper objBW;
                    for(Building__c bw: buildingListFound){
                        objBW = new BuildingWrapper();
                        objBW.buildingCode = '';
                        if(bw.Building_Code__c != null){
                            objBW.buildingCode = bw.Building_Code__c;
                        }
                        objBW.buildingName = bw.Name;
                        buildingList.add(objBW);
                    }
                    objPSR.context = 'building';
                    objPSR.listOfBuilding = buildingList;
                    objPSR.status = 'Success';
                    if(!buildingList.isEmpty()){
                        objPSR.message = 'Buildings found successfully!';
                    }else{
                        objPSR.message = 'No Building found.';
                    }
                }else{
                    objPSR.status = 'Success';
                    objPSR.message = 'Please Provide propertyCode!';
                }
            }else if(objReq.context == 'Floor'){
                if(objReq.propertyCode != null){
                    if(objReq.buildingCode != null){
                        String strSOQL = 'SELECT Id, Name, Floor_Code__c FROM Floor__c WHERE Project__r.Project_Purpose__c = \'Leasing\' AND Project__r.Project_Code__c != null';
                        String strPropertyCode = objReq.propertyCode;
                        strSOQL += ' AND Project__r.Project_Code__c =: strPropertyCode';
                        
                        String strBuildingCode = objReq.buildingCode;
                        strSOQL += ' AND Building_Code__c =: strBuildingCode';
						
						
                        List<Floor__c> floorListFound = database.query(strSOQL);
                        List<FloorWrapper> floorList = new List<FloorWrapper>();
                        FloorWrapper objFW;
                        for(Floor__c fl: floorListFound){
                            objFW = new FloorWrapper();
                            objFW.floorCode = '';
                            if(fl.Floor_Code__c != null){
                                objFW.floorCode = fl.Floor_Code__c;
                            }
                            objFW.floorName = fl.Name;
                            floorList.add(objFW);
                        }
                        objPSR.context = 'floor';
                        objPSR.listOfFloors = floorList;
                        objPSR.status = 'Success';
                        
                        if(!floorList.isEmpty()){
                            objPSR.message = 'Floors found successfully!';
                        }else{
                            objPSR.message = 'No Floor found.';
                        }
                    }else{
                        objPSR.status = 'Success';
                        objPSR.message = 'Please Provide buildingCode!';
                    }
                }else{
                    objPSR.status = 'Success';
                    objPSR.message = 'Please Provide propertyCode!';
                }
                
            }else if(objReq.context == 'SpaceType'){
                if(objReq.propertyCode != null){
                    String strSOQL = 'SELECT Id, Space_Types__c, Space_Types__r.Name, Space_Types__r.Space_Type_Lookup_Code__c FROM Unit__c WHERE Project__r.Project_Purpose__c = \'Leasing\' AND Project__r.Project_Code__c != null';
                    String strPropertyCode = objReq.propertyCode;
                    strSOQL += ' AND Project__r.Project_Code__c =: strPropertyCode AND Space_Types__r.Space_Type_Lookup_Code__c != null';
					String strBuildingCode;
                    if(objReq.buildingCode != null && objReq.buildingCode != ''){
                        strBuildingCode = objReq.buildingCode;
                        strSOQL += ' AND Building_Code__c =: strBuildingCode';
                    }
					
					
					String strFloorCode;
                    if(objReq.floorCode != null && objReq.floorCode != ''){
                        strFloorCode = objReq.floorCode;
                        strSOQL += ' AND Floor_Code__c =: strFloorCode';
                    }
					
					strSOQL += ' ORDER BY Space_Types__r.Name ASC';
					
                    List<Unit__c> unitListFound = database.query(strSOQL);
                    
                    List<SpaceTypeWrapper> spaceTypeList = new List<SpaceTypeWrapper>();
                    SpaceTypeWrapper objST;
                    for(Unit__c u: unitListFound){
                        objST = new SpaceTypeWrapper();
                        objST.spaceTypeCode = '';
                        if(u.Space_Types__r.Space_Type_Lookup_Code__c != null){
                            objST.spaceTypeCode = u.Space_Types__r.Space_Type_Lookup_Code__c;
                        }
                        objST.spaceTypeName = '';
                        if(u.Space_Types__r.Name != null){
                            objST.spaceTypeName = u.Space_Types__r.Name;   
                        }
                        spaceTypeList.add(objST);
                    }
                    objPSR.listOfSpaceTypes = spaceTypeList;
                    objPSR.context = 'SpaceType';
                    objPSR.propertyCode = objReq.propertyCode;
                    objPSR.status = 'Success';
                    if(!spaceTypeList.isEmpty()){
                        objPSR.message = 'Space type found successfully!';
                    }else{
                        objPSR.message = 'No Space type found.';
                    }
                    
                }else{
                    objPSR.status = 'Success';
                    objPSR.message = 'Please Provide propertyCode!';
                }
            }
        }else{
            
            objPSR.status = 'Success';
            objPSR.message = 'Please Provide Context!';
        }
        
        return objPSR;
    }
    
    global class PropertySearchRequest{
        global String context;
        global String propertyCode;
        global String buildingCode;
		global String floorCode;
    }
    
    global class PropertySearchResponse{
        global String context;
        global List<ProjectWrapper> listOfProjects;
        global List<BuildingWrapper> listOfBuilding;
        global List<FloorWrapper> listOfFloors;
		global List<SpaceTypeWrapper> listOfSpaceTypes;
        global String propertyCode;
        global String status;
        global String message;
        
    }
    global class ProjectWrapper{
        global String propertyCode;
        global String propertyName;
        
    }
    global class BuildingWrapper{
        global String buildingCode;
        global String buildingName;
        
    }
    global class FloorWrapper{
        global String floorCode;
        global String floorName;
    }
	global class SpaceTypeWrapper{
        global String spaceTypeCode;
        global String spaceTypeName;
    }
}