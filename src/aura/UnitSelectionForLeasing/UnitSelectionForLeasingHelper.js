({
    //get Industry Picklist Value
    /*callTypePicklict: function(component, event) {
        var action = component.get("c.getStatus");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var typeMap = [];
                for(var key in result){
                    typeMap.push({key: key, value: result[key]});
                }
                component.set("v.TypeMap", typeMap);
            }
        });
        $A.enqueueAction(action);
    },*/
    callArchitecturalType: function(component, event) {
        var action = component.get("c.getArchitecturalType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var typeMap = [];
                for(var key in result){
                    typeMap.push({key: key, value: result[key]});
                }
                component.set("v.architecturalMap", typeMap);
            }
        });
        $A.enqueueAction(action);
    },
    callUnitType: function(component, event) {
        var action = component.get("c.getUnitType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var typeMap = [];
                for(var key in result){
                    typeMap.push({key: key, value: result[key]});
                }
                component.set("v.unitTypeMap", typeMap);
            }
        });
        $A.enqueueAction(action);
    },
    callPropertyView: function(component, event) {
        var action = component.get("c.getLocation");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var typeMap = [];
                for(var key in result){
                    typeMap.push({key: key, value: result[key]});
                }
                component.set("v.propertyViewMap", typeMap);
            }
        });
        $A.enqueueAction(action);
    },
    callSpaceType: function(component, event) {
        var action = component.get("c.getSpaceType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var typeMap = [];
                for(var key in result){
                    typeMap.push({key: key, value: result[key]});
                }
                component.set("v.spaceTypeMap", typeMap);
            }
        });
        $A.enqueueAction(action);
    },
    callBedroom: function(component, event) {
        var action = component.get("c.getBedroom");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var typeMap = [];
                for(var key in result){
                    typeMap.push({key: key, value: result[key]});
                }
                component.set("v.bedroomMap", typeMap);
            }
        });
        $A.enqueueAction(action);
    },
    callCommunityList: function(component, event) {
        var action = component.get("c.getMasterCommunity");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var bedMap = [];
                for(var key in result){
                    bedMap.push({key: key, value: result[key]});
                }
                component.set("v.BedroomsMap", bedMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    callProjectList: function(component, event) {
        var action = component.get("c.fetchProjects");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var projMap = [];
                for(var key in result){
                    projMap.push({key: key, value: result[key]});
                }
                component.set("v.ProjectsMap", projMap);
                var act = component.get("c.getRecordDetails");
                act.setParams({recordId : component.get("v.recordId")});
                
                act.setCallback(this, function(a) {
                    var result = a.getReturnValue();
                    //alert(result.unitList.length);
                    component.set("v.selectedProject",result.oppty.Project__c);
                    component.set("v.unittype",result.oppty.Leasing_Type__c);
                    component.set("v.Emirate",result.oppty.Account.Emirates_Id__c);
                    //alert(component.get("v.unittype"));
                    // alert(result.unitList.length);
                    // alert(result.oppty.Account.Emirates_Ids__c);
                    if(component.get("v.unittype") == 'Residential Units'){
                        if(!$A.util.isUndefinedOrNull(result.oppty.Account.Emirates_Ids__c)){
                            if(result.unitList != null){
                                if(result.unitList.length == 1){
                                    component.set("v.maxRowSelection",0);  
                                }
                                /* if(result.unitList.length == 1){
                                  component.set("v.maxRowSelection",1);    
                                } */
                                if(result.unitList.length == 0){
                                    component.set("v.maxRowSelection",1);
                                }
                            } else {
                                component.set("v.maxRowSelection",1); 
                            }
                            
                            component.set("v.employeeDiscount",true);
                            //alert(component.get("v.employeeDiscount"));
                            /*  var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Warning',
                                message:'Please note that more than one unit will require approval and you can add upto 2 units!',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'warning',
                                mode: 'pester'
                            });
                            toastEvent.fire();*/
                        } else {
                            component.set("v.maxRowSelection",5);
                            component.set("v.employeeDiscount",false);
                        }
                         component.set('v.mycolumns', [
                {label: 'Unit Number', fieldName: 'Unit_Code__c',sortable: true, type: 'text'},
                {label: 'Project', fieldName: 'ProjectName',sortable: true, type: 'text'},
                {label: 'Building/Floor', fieldName: 'BuildingName',sortable: true, type: 'text'},
                {label: 'Space Type', fieldName: 'SpaceType',sortable: true, type: 'text'},
                {label: 'Unit Type', fieldName: 'Unit_type__c',sortable: true, type: 'text'},
                {label: 'Base Rent', fieldName: 'Base_Rent__c',sortable: true, type: 'text'},
                {label: 'Usable Area', fieldName: 'Usable_Area__c',sortable: true, type: 'text'},
                {label: 'Assignable Area', fieldName: 'Assignable_Area__c',sortable: true, type: 'text'},
            ]);                         
                    } else {
                        component.set("v.employeeDiscount",false);
                    }
                    //alert(component.get("v.unittype"));
             if(component.get("v.unittype") == 'Residential Shops'){
            component.set('v.mycolumns', [
                {label: 'Unit Number', fieldName: 'Unit_Code__c',sortable: true, type: 'text'},
                {label: 'Project', fieldName: 'ProjectName',sortable: true, type: 'text'},
                {label: 'Building/Floor', fieldName: 'BuildingName',sortable: true, type: 'text'},
                {label: 'Space Type', fieldName: 'SpaceType',sortable: true, type: 'text'},
                {label: 'Unit Type', fieldName: 'Unit_type__c',sortable: true, type: 'text'},
                {label: 'Per sqft Price', fieldName: 'Base_Rent__c',sortable: true, type: 'text'},
                {label: 'Assignable Area', fieldName: 'Assignable_Area__c',sortable: true, type: 'text'},
            ]);
                }
                });
                $A.enqueueAction(act);            
            }
        });
        $A.enqueueAction(action);
    },
    
    callBuildingList: function(component, event) {
        var action = component.get("c.fetchBuilding");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var projMap = [];
                for(var key in result){
                    projMap.push({key: key, value: result[key]});
                }
                component.set("v.buildingMap", projMap);
            }
        });
        $A.enqueueAction(action);
    },
    callFloorList: function(component, event) {
        var action = component.get("c.getFloor");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var viewMap = [];
                for(var key in result){
                    viewMap.push({key: key, value: result[key]});
                }
                component.set("v.ViewsMap", viewMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    callBusinessGroupList: function(component, event) {
        var action = component.get("c.getBusinessGroup");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var villaMap = [];
                for(var key in result){
                    villaMap.push({key: key, value: result[key]});
                }
                component.set("v.VillaTypeMap", villaMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    // Method to search for the unit based upon the provided parameters
    callSearch: function(component, event) {
        debugger;
        //alert(component.get("v.unittype"));
        var minPrice= component.get('v.minPrice');
        var maxPrice= component.get('v.maxPrice');
        var minSaleableArea=component.get('v.minSaleableArea')
        var maxSaleableArea   =   component.get('v.maxSaleableArea')
        var minPlotArea=component.get('v.minPlotArea');
        var maxPlotArea  =  component.get('v.maxPlotArea');
        var pageSize = component.get("v.pageSize").toString();
        var pageNumber = component.get("v.pageNumber").toString();
        if(component.get("v.unittype") == "Residential Units"){
                component.set('v.mycolumns', [
                {label: 'Unit Number', fieldName: 'Unit_Code__c',sortable: true, type: 'text'},
                {label: 'Project', fieldName: 'ProjectName',sortable: true, type: 'text'},
                {label: 'Building/Floor', fieldName: 'BuildingName',sortable: true, type: 'text'},
                {label: 'Space Type', fieldName: 'SpaceType',sortable: true, type: 'text'},
                {label: 'Unit Type', fieldName: 'Unit_type__c',sortable: true, type: 'text'},
                {label: 'Base Rent', fieldName: 'Base_Rent__c',sortable: true, type: 'text'},
                {label: 'Usable Area', fieldName: 'Usable_Area__c',sortable: true, type: 'text'},
                {label: 'Assignable Area', fieldName: 'Assignable_Area__c',sortable: true, type: 'text'},
            ]);   
                    } else {
                    component.set('v.mycolumns', [
                {label: 'Unit Number', fieldName: 'Unit_Code__c',sortable: true, type: 'text'},
                {label: 'Project', fieldName: 'ProjectName',sortable: true, type: 'text'},
                {label: 'Building/Floor', fieldName: 'BuildingName',sortable: true, type: 'text'},
                {label: 'Space Type', fieldName: 'SpaceType',sortable: true, type: 'text'},
                {label: 'Unit Type', fieldName: 'Unit_type__c',sortable: true, type: 'text'},
                {label: 'Per sqft Price', fieldName: 'Base_Rent__c',sortable: true, type: 'text'},
                {label: 'Assignable Area', fieldName: 'Assignable_Area__c',sortable: true, type: 'text'},
            ]);
                    }
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
        console.log(maxPlotArea);
        var actionSearch = component.get("c.searchUnit");
        actionSearch.setParams({ 
            cluster : component.get("v.selectedCluster"),
            project : component.get("v.selectedProject"),
            building : component.get("v.selectedBuilding"),
            
            unitType : component.get("v.selectedUnitType"),
            propertyView : component.get("v.selectedPropertyView"),
            spaceType  : component.get("v.selectSpaceType"),
            type : component.get("v.selectedType"),
            minPrice : minPrice,
            maxPrice : maxPrice,  
            pageSize : pageSize,
            pageNumber : pageNumber,
            oppId : component.get("v.recordId")
        });
        actionSearch.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            //alert(JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result == null){
                    component.set("v.DisplaySearchResultFlg",false);
                }
                else{
                    if(result.length > 0){	
                        var pageSize = component.get("v.pageSize");
                        component.set("v.totalRecords", result.length);
                        component.set("v.startPage", 0);                
                        component.set("v.endPage", pageSize - 1);
                        var PagList = []; 
                        component.set("v.DisplaySearchResultFlg",true);
                        var unitListUpdate = [];  
                        for (var i = 0; i < result.length; i++) {
                           // alert(result[i].Project__c);
                            if(result[i].Project__c != null){
                                result[i].ProjectName = result[i].Project__r.Name;
                            }
                            // alert(result[i].Building__c);
                            if(result[i].Building__c != null){
                                /*    if(result[i].Floor__c != null){
                                    result[i].BuildingName = result[i].Building__r.Name+'-'+ result[i].Floor__r.Name;
                                } else {*/
                                result[i].BuildingName = result[i].Building__r.Name;  
                                // }  
                                
                               // alert(result[i].Unit_Leasing_Type__c);
                                if(result[i].Unit_Leasing_Type__c != null ){
                                    result[i].SpaceType = result[i].Unit_Leasing_Type__r.Name;
                                }
                                //alert(result[i].Unit_code__c);
                                if(result[i].Unit_code__c != null){
                                    
                                    result[i].Unit_code__c = PagList[i].Unit_Code__c;
                                }} 
                            if(result[i].Base_Rent__c != null ){
                                result[i].Base_Rent__c = result[i].Base_Rent__c;
                            }
                            unitListUpdate.push(result[i]);
                        }
                       // alert(unitListUpdate.length);
                        component.set("v.unitList", unitListUpdate); 
                        //alert(JSON.stringify(component.get("v.unitList")));
                        for ( var i=0; i< pageSize; i++ ) {
                            if (component.get("v.unitList").length> i )
                                PagList.push(component.get("v.unitList")[i]);    
                        }
                        
                        component.set('v.PaginationList', PagList);
                        component.set("v.DisplayMsgFlg",false);
                        //alert(JSON.stringify(component.get("v.PaginationList")));
                    }                
                }                
            }
            else if(state === "ERROR"){
                //alert('here'+result);
                component.set("v.DisplayMsgFlg",true);
                component.set("v.DisplaySearchResultFlg",false);
                var errors = action.getError();
                if (errors) {
                    this.showErrorMsg(component,event,'Something went wrong, please try again.');  
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
            component.set("v.isSpinner", false);   
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
        component.set("v.isSpinner", false);  
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
        component.set("v.isSpinner", false); 
        toastEvent.fire();
    },
    
    // Method to add the selected unit against the opportunity   
    addUnits: function(component, event) {
        component.set("v.isSpinner",true);
        var selectedUnits = component.get("v.selectedUnits");
        var unitId =  selectedUnits[0].Id;
        var unitList = component.get("v.unitList");
        var selectedUnit = [];
        component.set("v.unitId",selectedUnits);
        var action = component.get("c.addUnitstoOpp");
        action.setParams({OppId : component.get("v.recordId"),unitsList : selectedUnits});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state = "SUCCESS"){
                component.set("v.AddUnit",'Unit Added Successfully');
                component.set("v.isSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success Message',
                    message:'Unit has been added successfully..',
                    type: 'success'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                
            }
            
        });
        $A.enqueueAction(action); 
        
    },
    
    // Method to check and display existing unit, if tied to the viewing opporunity
    showExistingUnit: function(component, event) {
        
        var actionUnitCheck = component.get("c.fetchExistingUnit");
        actionUnitCheck.setParams({ opportunityID : component.get("v.recordId")});
        
        actionUnitCheck.setCallback(this, function(response) {
            var state = response.getState();               
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != null)
                {
                    component.set("v.currentUnitList",result);
                    component.set("v.currentUnitExistFlg",true); 
                    component.set("v.DisplaySearchResultFlg",false);
                }  
                
                else
                {
                    component.set("v.currentUnitExistFlg",false);
                }
            }
            else if(state === "ERROR"){
                var errors = action.getError();
                component.set("v.currentUnitExistFlg",false);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
            component.set("v.isSpinner", false);  
        });
        $A.enqueueAction(actionUnitCheck);
        
    },
    
    //Method to remove existing unit linked to the current opportunity
    removeUnit: function(component,event)
    {	
        var updateId = [];
        var actionRemoveUnit = component.get("c.removeExistingUnit");
        var getUnitID = component.find("boxPackmain");
        //alert(getUnitID);
        
        console.log(getUnitID); 
        //Addition 
        if(!Array.isArray(getUnitID)){
            if (getUnitID.get("v.value") == true) {
                updateId.push(getUnitID.get("v.text"));
            }
        }else{ 
            for (var i = 0; i < getUnitID.length; i++) {
                if (getUnitID[i].get("v.value") == true) {
                    updateId.push(getUnitID[i].get("v.text"));
                }
            }
        }
        if(updateId.length == 0){
            this.showErrorMsg(component,event,'Please select the current unit.');
        }
        else if(updateId.length >= 1){
            
            var selectedUnitID = updateId;
            //alert('updateId'+updateId.length);
            
            actionRemoveUnit.setParams({  opportunityID : component.get("v.recordId"), ppIdList : selectedUnitID});
            debugger;              
            actionRemoveUnit.setCallback(this, function(response) {
                var state = response.getState();               
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result == true){   
                        console.log('length of current list>>>>>'+component.get("v.currentUnitList").length);
                        //alert(component.get("v.currentUnitList").length);
                        if(component.get("v.currentUnitList").length==0){
                            component.set("v.currentUnitExistFlg",false);  
                        }              
                        this.showMsg(component,event,'Unit has been removed successfully.'); 
                        $A.get('e.force:refreshView').fire();
                    }  
                    else{
                        component.set("v.currentUnitExistFlg",true);
                        this.showErrorMsg(component,event,'Unit is not allowed to remove at this stage');
                    }
                }
                else if(state === "ERROR"){
                    var errors = action.getError();
                    component.set("v.currentUnitExistFlg",true);
                    this.showErrorMsg(component,event,'Something went wrong, please try again.');
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log(errors[0].message);
                        }
                    }
                } 
                component.set("v.isSpinner",false); 
                component.set("v.DisplaySearchResultFlg",true); 
            });
            $A.enqueueAction(actionRemoveUnit);
        }
    },
    OppRecord : function(component,event,helper){
        var action = component.get("c.getRecordDetails");
        action.setParams({recordId : component.get("v.recordId")});
        
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            component.set("v.selectedProject",result.oppty.Project__c);
            // alert(component.get("v.selectedProject"));
        });
        $A.enqueueAction(action);
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var fname = fieldName;
        var data = cmp.get("v.unitList");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.unitList", data);
        cmp.set("v.PaginationList",data.slice(0,8)); 
    },
    sortBy: function (field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    SearchDefaultUnits : function(component,event,helper){
        var action = component.get("c.SearchUnits");
        action.setParams({recordId : component.get("v.recordId")});   
        action.setCallback(this, function(response){
            //component.set("v.unitList", response.getReturnValue());
            component.set("v.unitList", response.getReturnValue());
            // alert(JSON.stringify(component.get("v.unitList")));
            component.set("v.isSpinner", false);
            var PagList = [];
            for(var i =0;i<response.getReturnValue().length;i++){
                PagList.push(response.getReturnValue()[i]); 
            }
            component.set("v.unitList", response.getReturnValue()); 
            for(var i = 0;i< PagList.length;i++){
                if(PagList[i].Project__c != null){
                    PagList[i].ProjectName = PagList[i].Project__r.Name;}
                if(PagList[i].Building__c != null){
                    //  var concat1 = text1.concat(text2);
                    if(PagList[i].Floor__c != null){
                        PagList[i].BuildingName = PagList[i].Building__r.Name+'-'+ PagList[i].Floor__r.Name
                    } else {
                        PagList[i].BuildingName = PagList[i].Building__r.Name;  
                    }  
                    
                } 
                if(PagList[i].Unit_Leasing_Type__c != null ){
                    PagList[i].SpaceType = PagList[i].Unit_Leasing_Type__r.Name;
                }
                if(PagList[i].Unit_code__c != null){
                    
                    PagList[i].Unit_code__c = PagList[i].Unit_Code__c;
                }
                if(PagList[i].Base_Rent__c != null){
                    
                    PagList[i].Base_Rent__c = PagList[i].Base_Rent__c;
                }
            }
            var paginationrecords = [];
            var pageSize = component.get("v.pageSize");
            component.set("v.totalRecords", PagList.length);
            component.set("v.startPage", 0);                
            component.set("v.endPage", pageSize - 1);
            // component.set("v.PaginationList",PagList);
            for ( var i=0; i< pageSize; i++ ) {
                if ( component.get("v.unitList").length> i )
                    paginationrecords.push(component.get("v.unitList")[i]);    
            }
            //alert(JSON.stringify(component.get("v.PaginationList")));
            component.set("v.PaginationList",paginationrecords);
        });
        $A.enqueueAction(action);
    },
    getAvailablePlans : function(component,event,helper){
        var action = component.get("c.getAvailablePlans");
        action.setParams({projectId : component.get("v.selectedProject")});   
        action.setCallback(this, function(response){
            component.set("v.availablePlanList", response.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})