({
       getFilterMethods : function(component, event, helper) {
        //component.set("v.isSpinner", true);
        var action = component.get("c.getFilters");
        action.setParams({recordId : component.get("v.recordId")});
           
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            //alert(JSON.stringify(response.getReturnValue()));
            var result = response.getReturnValue();
            var projectMap = [];
             var unitListUpdate = [];
            //alert(JSON.stringify(result.projectMap));
            var conts = result.projectMap;
            if(result.oppRecord.Leasing_Type__c === 'Residential Units'){
                component.set("v.residentialUnitsCheck",true);
                component.set("v.commercialUnitsCheck",false);
            }else{
                component.set("v.commercialUnitsCheck",true);
                component.set("v.residentialUnitsCheck",false);
            }
            for(var key in conts){
                projectMap.push({value:conts[key], key:key});
            }var buildMap = [];
            for(var key in result.buildingMap){
                buildMap.push({value:result.buildingMap[key], key:key})
            }
            component.set("v.buildingMap",buildMap);
            //alert(JSON.stringify(projectMap));
            component.set("v.ProjectsMap",projectMap);
            var clusterMap = [];
            for(var key in result.clusterMap){
                clusterMap.push({key: key, value: result.clusterMap[key]});
            }
            component.set("v.clusterMap",clusterMap);
            var propertyType = [];
            for(var key in result.propertyType){
                propertyType.push({key: key, value: result.propertyType[key]}); 
            }
            component.set("v.propertyTypeMap",propertyType);
            
            var unitType = [];
            for(var key in result.unitType){
                unitType.push({key: key, value: result.unitType[key]}); 
            }
            component.set("v.unitTypeMap",unitType);
            
            var LocationMap = [];
            for(var key in result.LocationMap){
                LocationMap.push({key: key , value: result.LocationMap[key]});
            }
            
            component.set("v.propertyViewMap",LocationMap);
            
            var NoOfBedroomsMap = [];
            for(var key in result.NoOfBedroomsMap){
                
                NoOfBedroomsMap.push({key: key , value: result.NoOfBedroomsMap[key]});
            }
            component.set("v.noOfBedroomMap",NoOfBedroomsMap);
            var spaceTypeMap = [];
            for(var key in result.spaceMap){
                spaceTypeMap.push({key: key,value: result.spaceMap[key]});
            }
            component.set("v.spaceTypeMap",spaceTypeMap);
            var unittype = [];
            for(var key in result.unitType){
                unittype.push({key: key,value: result.unitType[key]}); 
            }
            var unitlstdata = [];
            //component.set("v.selectedProject",result.oppRecord.Project__c);
            for(var key in conts){
                if(key == result.oppRecord.Project__c){
                component.set("v.selectedProject",key);
                    break;
                }
            }
           // component.set("v.isSpinner", false);swapnil
           // alert(JSON.stringify(result.oppRecord));
            component.set("v.unittype",result.oppRecord.Leasing_Type__c);
            if(result.oppRecord.Account != null){
                component.set("v.Emirate",result.oppRecord.Account.Emirates_Ids__c);
                if(result.oppRecord.Account.IsPersonAccount){
                    component.set("v.isPerson", true);
                    component.set("v.allSelected",true);
                }
              //  alert(result.oppRecord.Account.Emirates_Ids__c);
                 component.set("v.toggleComponent",true);
            } else {
                component.set("v.toggleComponent",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: 'Please select the customer before proceeding to Units!',
                    type: 'error',
                    duration:' 5000',
                });
                toastEvent.fire();
            }
           // alert(JSON.stringify(result.oppRecord));
            component.set("v.unitTypeMap",unittype);
            let unitlst = result.unitList;
            component.set("v.unittypelst",unitlst);
            if(result.unitWrapper.length > 0){
            if(unitlst.length > 0 && component.get("v.isPerson")){//result.oppRecord.Account.Emirates_Ids__c != null){
                for(let i = 0;i < result.unitWrapper.length;i++){
                  var rec = result.unitWrapper[i];
                    rec.propFlag = true;
                    unitlstdata.push(rec);
                }
               // alert(JSON.stringify(unitlstdata));
                //component.set("v.allSelected",true); //commented by karishma
            } else {
                unitlstdata = result.unitWrapper;
                //component.set("v.allSelected",false); //commented by karishma
            }
            //alert(JSON.stringify(unitlstdata));
            component.set("v.unitList", unitlstdata);
            var PagList = [];
                let selectedunit = 0;var totalcount = 0;
            for(var i =0;i<unitlstdata.length;i++){
                PagList.push(unitlstdata[i]); 
                if(PagList[i].unit.Project__c != null){
                    PagList[i].unit.ProjectName = PagList[i].unit.Project__r.Name;}
                if(PagList[i].unit.Building__c != null){
                    //  var concat1 = text1.concat(text2);
                    if(PagList[i].unit.Floor__c != null){
                        PagList[i].unit.BuildingName = PagList[i].unit.Building__r.Name+'-'+ PagList[i].unit.Floor__r.Name
                    } else {
                        PagList[i].unit.BuildingName = PagList[i].unit.Building__r.Name;  
                    }  
                    
                } 
               //alert(PagList[i].unit.Space_Types__c);
                if(PagList[i].unit.Unit_Leasing_Type__c != null){
                   // alert(PagList[i].unit.Space_Types__r.Name);
                    PagList[i].unit.SpaceType = PagList[i].unit.Unit_Leasing_Type__r.Name;
                }
                if(PagList[i].propFlag){
                    selectedunit += 1;
                }
                totalcount += 1;
            }
            
           
           /* for(var i = 0;i< PagList.length;i++){
                if(PagList[i].unit.Project__c != null){
                    PagList[i].unit.ProjectName = PagList[i].unit.Project__r.Name;}
                if(PagList[i].unit.Building__c != null){
                    //  var concat1 = text1.concat(text2);
                    if(PagList[i].unit.Floor__c != null){
                        PagList[i].unit.BuildingName = PagList[i].unit.Building__r.Name+'-'+ PagList[i].unit.Floor__r.Name
                    } else {
                        PagList[i].unit.BuildingName = PagList[i].unit.Building__r.Name;  
                    }  
                    
                } 
               //alert(PagList[i].unit.Space_Types__c);
                if(PagList[i].unit.Unit_Leasing_Type__c != null){
                   // alert(PagList[i].unit.Space_Types__r.Name);
                    PagList[i].unit.SpaceType = PagList[i].unit.Unit_Leasing_Type__r.Name;
                }
                if(PagList[i].propFlag){
                    selectedunit += 1;
                }
                totalcount += 1;
            }
            */   //commented by swapnil
            //component.set("v.selectedCount",selectedunit);
            component.set("v.totalRecordsCount",totalcount);
           // alert(result.oppRecord.Project__c);
            var paginationrecords = [];
            var pageSize = component.get("v.pageSize");
           // alert(component.get("v.pageSize"));
            component.set("v.totalRecords", PagList.length);
            component.set("v.startPage", 0);                
            component.set("v.endPage", pageSize - 1);
           // alert(component.get("v.endPage"));
            component.set("v.totalPagesCount", Math.ceil(PagList.length / pageSize)); 
            // component.set("v.PaginationList",PagList);
            for ( var i=0; i< pageSize; i++ ) {
                if ( component.get("v.unitList").length> i )
                    paginationrecords.push(component.get("v.unitList")[i]);    
            }
            //alert(JSON.stringify(component.get("v.PaginationList")));
            component.set("v.PaginationList",paginationrecords);
                component.set("v.DisplaySearchResultFlg",true);
            //component.set("v.isSpinner", false);
            } else {
               component.set("v.DisplaySearchResultFlg",false); 
            }  
        });
        $A.enqueueAction(action);
        //component.set("v.isSpinner", false);
       },
    
    
    // Method to search for the unit based upon the provided parameters
    callSearch: function(component, event) {
        
        var minPrice= component.get('v.minPrice');
        var maxPrice= component.get('v.maxPrice');
        var minSaleableArea=component.get('v.minSaleableArea')
        var maxSaleableArea   =   component.get('v.maxSaleableArea')
        var minPlotArea=component.get('v.minPlotArea');
        var maxPlotArea  =  component.get('v.maxPlotArea');
        var pageSize = component.get("v.pageSize").toString();
        var pageNumber = component.get("v.pageNumber").toString();
        if(minPrice ==''){
            minPrice=0;
        }
        
        if(maxPrice ==''){
            maxPrice=0;
        }
        
        if(minSaleableArea==''){
            minSaleableArea=0;
        }
        
        if(maxSaleableArea ==''){
            maxSaleableArea =0;      
        }
        
        if(minPlotArea ==''){
            minPlotArea=0;
        }
        
        if(maxPlotArea ==''){
            maxPlotArea=0;
        }
        var cluster = component.get("v.selectedCluster");
        var project = component.get("v.selectedProject");
        var building = component.get("v.selectedBuilding");
        
        console.log(component.get('v.maxPlotArea'));
        //alert(component.get("v.selectedUnitType"));
        var actionSearch = component.get("c.searchUnit");
        actionSearch.setParams({ 
            cluster : component.get("v.selectedCluster"),
            project : component.get("v.selectedProject"),
            building : component.get("v.selectedBuilding"),
            
            propertyType : component.get("v.selectedPropertyType"),
            propertyView : component.get("v.selectedPropertyView"),
            spaceType  : component.get("v.selectSpaceType"),
            type : component.get("v.selectedType"),
            minPrice : minPrice,
            maxPrice : maxPrice,  
            pageSize : pageSize,
            pageNumber : pageNumber,
            oppId : component.get("v.recordId"),
            noOfBedrooms: component.get("v.selectedBedroom"),
            unitType: component.get("v.selectedUnitType"),
            unitCode: component.get("v.SearchLocationCode"),
        });
        actionSearch.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               // alert(response.getReturnValue());
                var result = response.getReturnValue();
                //alert(JSON.stringify(result));
                if(result != null){
                    var unitlstdata = [];
                    component.set("v.DisplaySearchResultFlg",true);       
                    //alert(result.oppRecord.Account.Emirates_Id__c);
                    // component.set("v.unittype",result.oppRecord.Leasing_Type__c);
                    //component.set("v.Emirate",result.oppRecord.Account.Emirates_Id__c);
                    let unitlst = result.unitList;
                    // alert(result.unitWrapper.length);
                    if(unitlst.length > 0 && result.oppRecord.Account.Emirates_Ids__c != null){
                    for(let i = 0;i < result.unitWrapper.length;i++){
                        var rec = result.unitWrapper[i];
                        rec.propFlag = true;
                        unitlstdata.push(rec);
                    }
                //component.set("v.allSelected",true); //commented by karishma
            } else {
                unitlstdata = result.unitWrapper;
                //component.set("v.allSelected",false); //commented by karishma
            }
            //alert(JSON.stringify(unitlstdata));
            component.set("v.unitList", unitlstdata);
                    let selectedunit = 0;var totalcount = 0;
            var PagList = [];
            for(var i =0;i<unitlstdata.length;i++){
                PagList.push(unitlstdata[i]);
                if(PagList[i].unit.Project__c != null){
                    PagList[i].unit.ProjectName = PagList[i].unit.Project__r.Name;}
                if(PagList[i].unit.Building__c != null){
                    //  var concat1 = text1.concat(text2);
                    if(PagList[i].unit.Floor__c != null){
                        PagList[i].unit.BuildingName = PagList[i].unit.Building__r.Name+'-'+ PagList[i].unit.Floor__r.Name
                    } else {
                        PagList[i].unit.BuildingName = PagList[i].unit.Building__r.Name;  
                    }  
                    
                } 
               //alert(PagList[i].unit.Space_Types__c);
                if(PagList[i].unit.Space_Types__c != null){
                   // alert(PagList[i].unit.Space_Types__r.Name);
                    PagList[i].unit.SpaceType = PagList[i].unit.Space_Types__r.Name;
                }
                if(PagList[i].propFlag){
                    selectedunit += 1;
                }
                totalcount += 1;
            }
            
           // component.set("v.unitList", result.unitWrapper); 
           /* for(var i = 0;i< PagList.length;i++){
                if(PagList[i].unit.Project__c != null){
                    PagList[i].unit.ProjectName = PagList[i].unit.Project__r.Name;}
                if(PagList[i].unit.Building__c != null){
                    //  var concat1 = text1.concat(text2);
                    if(PagList[i].unit.Floor__c != null){
                        PagList[i].unit.BuildingName = PagList[i].unit.Building__r.Name+'-'+ PagList[i].unit.Floor__r.Name
                    } else {
                        PagList[i].unit.BuildingName = PagList[i].unit.Building__r.Name;  
                    }  
                    
                } 
               //alert(PagList[i].unit.Space_Types__c);
                if(PagList[i].unit.Space_Types__c != null){
                   // alert(PagList[i].unit.Space_Types__r.Name);
                    PagList[i].unit.SpaceType = PagList[i].unit.Space_Types__r.Name;
                }
                if(PagList[i].propFlag){
                    selectedunit += 1;
                }
                totalcount += 1;
            }*/ // commented by swapnil
            
           // component.set("v.selectedCount",selectedunit);
            component.set("v.totalRecordsCount",totalcount);
           // alert(result.oppRecord.Project__c);
            var paginationrecords = [];
            var pageSize = component.get("v.pageSize");
           // alert(component.get("v.pageSize"));
            component.set("v.totalRecords", PagList.length);
            component.set("v.startPage", 0);                
            component.set("v.endPage", pageSize - 1);
           // alert(component.get("v.endPage"));
            component.set("v.totalPagesCount", Math.ceil(PagList.length / pageSize)); 
            // component.set("v.PaginationList",PagList);
            for ( var i=0; i< pageSize; i++ ) {
                if ( component.get("v.unitList").length> i )
                    paginationrecords.push(component.get("v.unitList")[i]);    
            }
            //alert(JSON.stringify(component.get("v.PaginationList")));
            component.set("v.PaginationList",paginationrecords);
            //component.set("v.isSpinner", false);
                } else {
                    component.set("v.DisplaySearchResultFlg",false);
                }
            }
            else if(state === "ERROR"){
                //alert('here'+result);
                //component.set("v.DisplayMsgFlg",true);
                component.set("v.DisplaySearchResultFlg",false);
                var errors = action.getError();
                if (errors) {
                    this.showErrorMsg(component,event,'Something went wrong, please try again.');  
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
            //component.set("v.isSpinner", false);   swapnil
        });
        $A.enqueueAction(actionSearch);    
        
    },
    
    //Method to error message
    showErrorMsg : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message:message,
            type: 'error'
        });
       // component.set("v.isSpinner", false); swapnil 
        toastEvent.fire();
    },
    
    //Method to error message
    showMsg : function(component,event,message) {        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message:message,
            type: 'success'
        });
        //component.set("v.isSpinner", false); swapnil
        toastEvent.fire();
    },

    //Method to error message
    showWarnMsg : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Warn Message',
            message: message,
            type: 'warn'
        });
        //component.set("v.isSpinner", false);  swapnil
        toastEvent.fire();
    },
    
    // Method to add the selected unit against the opportunity   
    addUnits: function(component, event) {
        //component.set("v.isSpinner",true);
        var selectedUnits = component.get("v.selectedUnits");
        var unitId =  selectedUnits[0].Id;
        var unitList = component.get("v.unitList");
        var selectedUnit = [];
        component.set("v.unitId",selectedUnits);
        if(selectedUnits != null && selectedUnits != undefined){
            var action = component.get("c.addUnitstoOpp");
            action.setParams({OppId : component.get("v.recordId"),unitsList : selectedUnits});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state = "SUCCESS"){
                    component.set("v.selectedCount",0);
                    var selUnit = [];
                    component.set("v.selectedUnits",selUnit);
                    component.set("v.AddUnit",'Unit Added Successfully');
                    component.set("v.disableButton",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message:'Unit has been added successfully..',
                        type: 'success'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                //component.set("v.isSpinner",false);
            }
            
        });
        $A.enqueueAction(action); 
        } else {
             var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success Message',
                    message:'Please select the unit before proceeding further!',
                    type: 'error'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
        }
    },
            // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
       // alert(JSON.stringify(sObjectList));
        for(var i = end + 1; i < end + pageSize + 1; i++){
           // alert(i);
          //  alert(sObjectList.length);
            if(sObjectList.length > i){ 
                //alert(component.find("selectAllId").get("v.value"));
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]);  
                }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        //alert(JSON.stringify(Paginationlist));
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]); 
                }
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    unitSearchComponentVisibility : function(component, event, helper) {
        //alert('Call');
        var action = component.get("c.checkTaggedUnits");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result === true){
                    component.set("v.unitSearchScreenDisable",true);
                }else{
                    component.set("v.unitSearchScreenDisable",false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    propertyCheckOnCustomer : function(component, event, helper){
        this.fetchOpptyRecord(component, event, helper);
        var action = component.get("c.propertyCheckOnCustomer");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length == 1){
                    component.set("v.blockUnitSelection",false);
                    console.log('property details :',JSON.stringify(result));
                    if(component.get("v.opptyObj")){
                        var opportunityApprovalStatus = component.get("v.opptyObj").Lease_Renewal_Approval_Status__c;
                        if(opportunityApprovalStatus != 'Approved'){
                            component.set("v.propertyCheck",true);
                        }else{
                            component.set("v.propertyCheck",false);
                        }
                    }
                }else if(result.length > 1){
                    component.set("v.blockUnitSelection",true);
                    component.set("v.propertyCheck",false);
                }else{
                    component.set("v.blockUnitSelection",false);
                    component.set("v.propertyCheck",false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchOpptyRecord : function(component, event, helper){
        var action = component.get("c.getOptyRecord");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.Leasing_Type__c == 'Commercial Units') {
                    component.set("v.Iscompany", true);
                }else if (result.Leasing_Type__c == 'Residential Units') {
                    component.set("v.Iscompany", false);  
                }
                component.set("v.opptyObj",result);
                //console.log('opportunity :'+JSON.stringify(component.get("v.opptyObj")));
            }
        });
        $A.enqueueAction(action);
    },

    submitForApproval : function(component, event, helper){
        var action = component.get("c.submitForApproval");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showWarnMsg(component,event,'This customer already owns one active unit, We have sent this request for approval');
                //component.set("v.isSpinner", false); swapnil
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
})