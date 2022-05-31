({
    doInit : function(component, event, helper) {
        debugger;
        //component.set('v.recordId', component.get("v.pageReference").state.c__id);
        //var x = component.get("v.recordId");
        //alert(x);
        component.set("v.toggleComponent",true);
        helper.callArchitecturalType(component, event);
        helper.callUnitType(component, event);
        helper.callPropertyView(component, event);
        helper.callBedroom(component, event);
        
        helper.callProjectList(component, event);
        helper.callSpaceType(component, event);
        helper.callFloorList(component, event);
        helper.callBusinessGroupList(component, event);
        helper.callCommunityList(component, event);
        //helper.getAvailablePlans(component,event);
        component.set("v.isSpinner", true);
        helper.SearchDefaultUnits(component,event,helper);
    },
    
    searchKeyChange: function(component, event) {
        var searchKey = component.find("searchKey").get("v.value");
        console.log('searchKey:::::'+searchKey);
        var action = component.get("c.findUnitByName");
        action.setParams({
            "searchKey": searchKey
        });
        action.setCallback(this, function(a) {
            component.set("v.unitList", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    handleProjectOnChange : function(component, event, helper) {
        debugger;
        var project = component.get("v.selectedProject");
        var action = component.get("c.fetchCluster");
        action.setParams({
            "project": project
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var projMap = [];
                for(var key in result){
                    projMap.push({key: key, value: result[key]});
                }
                component.set("v.clusterMap", projMap);
            }
        });
        $A.enqueueAction(action);
    },
    handleClusterOnChange :function(component, event, helper) {
        debugger;
        var cluster = component.get("v.selectedCluster");
        var action = component.get("c.fetchBuilding");
        action.setParams({
            "cluster": cluster
        });
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
    next: function (component, event, helper) {
        //component.set("v.selectedUnits", null);
        var sObjectList = component.get("v.unitList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i = end + 1; i < end + pageSize + 1; i++ ) {
            if ( sObjectList.length > i ) {
                PagList.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', PagList);
    },
    previous: function (component, event, helper) {
        //component.set("v.selectedUnits", null);
        var sObjectList = component.get("v.unitList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i= start-pageSize; i < start ; i++ ) {
            if ( i > -1 ) {
                PagList.push(sObjectList[i]);
                counter ++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', PagList);
    },
    
    // Method to send parameters to apex controller to perform search for unit
    search : function(component, event, helper) {
        component.set("v.isSpinner", true);  
        // First check that atleast mandatory filters are selected
        var projectVal = component.get("v.selectedProject");
        console.log(component.get('v.maxPlotArea'));
        /*if(projectVal == '' || projectVal == null || projectVal == undefined){
            helper.showErrorMsg(component,event,'Please select a Project');            
        }*/
        //else{
        // call the helper method for the search
        helper.callSearch(component,event);
       // helper.callProjectList(component,event,helper);
        //}
    },
    onGroup: function(cmp, evt,helper) {
        var selected = evt.getSource().get("v.label");
        //resultCmp = cmp.find("radioGroupResult");
        //resultCmp.set("v.value", selected);
    },
    
    //Method to add selected property against the opportunity
    addUnit: function(component,event,helper){
        //component.set("v.isSpinner", true); 
        // component.set("v.toggleComponent",false);       
        helper.addUnits(component,event,helper);   
        // helper.SearchDefaultUnits(component,event,helper);
        //helper.callProjectList(component,event,helper);
    },
    
    //Method to remove existing unit linked to the current opportunity
    removeUnit: function(component,event,helper)
    {
        component.set("v.isSpinner", true);   
        debugger;     
        helper.removeUnit(component,event); 
        helper.showExistingUnit(component,event);
    },
    
    handleSelect : function(component, event, helper) {
        debugger;
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i]);
        }
        //alert(JSON.stringify(setRows));
        component.set("v.selectedUnits", setRows);
        //alert(JSON.stringify(component.get("v.selectedUnits")));
    },
    clear : function(component,event,helper){
        component.set("v.selectedCluster","");
        component.set("v.selectedBuilding","");
        component.set("v.selectedUnitType","");
        component.set("v.minPrice","");
        component.set("v.maxPrice","");
        component.set("v.selectedPropertyView","");
        component.set("v.selectSpaceType","");
    },
    updateSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    getSelected : function(component,event,helper){
        // alert(' in parent');
        var params = event.getParam('arguments');
        //  alert(params.DisplayMsgFlag);
        if(params){
            var display = params.DisplayMsgFlag;
            component.set("v.DisplayMsgFlg",display);
            component.set("v.toggleComponent",true);
            var unitlist = params.parentunitId;
            // alert(JSON.stringify(params.parentunitId));
            // component.set("v.unitId",unitlist);
            helper.SearchDefaultUnits(component,event,helper);
            helper.callProjectList(component, event);
            component.set("v.selectedUnits", unitlist);
            // alert(JSON.stringify(component.get("v.selectedUnits")));
        }
    }
    
})