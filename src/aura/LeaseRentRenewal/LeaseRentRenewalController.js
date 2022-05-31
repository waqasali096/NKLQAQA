({
    //this method will execute on page load
	doInit : function(component, event, helper) {        
        var d = new Date();
        var todayDate = d.getFullYear() + '-' + (d.getMonth()+1) + '-' + d.getDate(); 
        component.set("v.todayDate", todayDate);
        
        component.set("v.selectedProject", "");
        component.set("v.selectedNoOfBedroom", "");
        component.set("v.selectedLeasingType", "Residential Unit");
        component.set("v.selectedUnitType", "");
        component.set("v.selectedBuilding", "");        
        component.set("v.selectedPropertyType", "");
        component.set("v.selectedFloor", "");
        component.set("v.selectedDateFilter","90");
        helper.updateFromDateToDate(component, event);
        helper.fetchProjects(component, event);  
        helper.fetchUnitTypes(component, event);  
        helper.fetchNoOfBedrooms(component, event); 
        //helper.fetchSpaceTypes(component, event);
        helper.fetchBuildings(component, event);
        helper.fetchFloors(component, event);
        helper.fetchRentUpdateReasonValues(component, event);   
        helper.fetchPageSize(component, event);
    },
    
    /*handleOnLoad : function(component, event, helper) {
        if(component.find("leasingTypeId")){
            component.find("leasingTypeId").set("v.value", "Residential Unit");
        }
	},*/
    
    //this method will execute on Search button click
    searchMethod : function(component, event, helper) {
		helper.searchMethod(component, event);
	},
    
    //this method will execute on Apply button click
    applyMethod : function(component, event, helper) {
        helper.applyMethod(component, event);
    },
    
    //this method will execute on Save button click
    saveMethod : function(component, event, helper) {        
        var listUnitPlansWrapper = component.get("v.listUnitPlansWrapper");
        //let blnShowError = false;
        let blnShowLimitError = false;
        /*listUnitPlansWrapper.forEach(function (item) {
            if(item.dcmRenewalRent == '' || item.dcmRenewalRent == 0){                
                blnShowError = true;
                return;
            }
        });*/
        
        listUnitPlansWrapper.forEach(function (item) {
            if(item.dcmRenewalRent != '' && item.dcmRenewalRent != 0){
                var varDiffernce = item.dcmRenewalRent - item.dcmCurrentRent;
                if(varDiffernce > 20000){                                    
                    blnShowLimitError = true;
                    return;
                }
            }
        });
        
        //if(blnShowError){
          //  helper.showToastMessage('error', 'Renewal Rent should be populated.');
        // }
        
        if(blnShowLimitError){
            helper.showToastMessage('error', 'Max rent increase can not be more than 20,000');
        }
        
        if(!blnShowLimitError){
        	helper.saveMethod(component, event);            
        }
    },
    
    //this method will execute on Notify Flag (table header) check/uncheck
    handleNotifyFlagAll : function(component, event, helper) {
        helper.handleNotifyFlagAll(component, event);
    },
    
    //this method will execute on Reset button click
    resetPriceMethod : function(component, event, helper) {
        helper.resetPriceMethod(component, event);
    },
    
    //this method will execute on Project change
    handleProjectChange : function(component, event, helper) {        
        component.set("v.listBuildingOptions", []);
        component.set("v.selectedBuilding", "");
        component.set("v.listFloorOptions", []);
        component.set("v.selectedFloor", "");
        helper.fetchBuildings(component, event);
        helper.fetchFloors(component, event);
    },
    
    //this method will execute on Building change
    handleBuildingChange : function(component, event, helper) {        
        component.set("v.listFloorOptions", []);
        component.set("v.selectedFloor", "");
        helper.fetchFloors(component, event);
    },
    
    //control Seach button visibility based on Project & Dates
    handleSearchButtonVisibility : function(component, event, helper) {
        helper.searchButtonVisibility(component, event);
    },
    
    //disable "Default Renewal Rent Price" if "Uplift Value" is populated
    handleAddUpliftValueChange : function(component, event, helper) {
        component.set("v.defaultRenewalRentPrice", "");
        helper.applyButtonVisibility(component, event);
    },
	
	//disable "Uplift Value" if "Default Renewal Rent Price" is populated    
    handleDefaultRenewalRentPriceChange : function(component, event, helper) {
        component.set("v.selectedAddUpliftValue", "");
        helper.applyButtonVisibility(component, event);
    },
    
    //enable "Apply" button on Reason selection.
    handleReasonChange : function(component, event, helper) {
        helper.applyButtonVisibility(component, event);
    },
    
    //populate FromDate & ToDate based on selected DateFilter
    handleDateFilterChange : function(component, event, helper) {
        helper.updateFromDateToDate(component, event);
        helper.searchButtonVisibility(component, event);
    },
    
    //Next button method (Pagination)
    pgNextMethod : function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPagesCount = component.get("v.totalPagesCount");
        var pageSize = component.get("v.pageSize");
        var startIndex = component.get("v.startIndex");
        var endIndex = component.get("v.endIndex");
        var startIndexUpdate = startIndex + pageSize;
        var endIndexUpdate = endIndex + pageSize;  
        currentPage++;
        component.set("v.startIndex", startIndexUpdate);
        component.set("v.endIndex", endIndexUpdate);
        component.set("v.currentPage", currentPage);
        
        if(currentPage == totalPagesCount){
            component.set("v.disableNext", true);
        }
        else{
            component.set("v.disableNext", false);
        }        
    },
    
    //Previous button method (Pagination)
    pgPreviousMethod : function(component, event, helper) {
        var currentPage = component.get("v.currentPage");
        var totalPagesCount = component.get("v.totalPagesCount");
        var pageSize = component.get("v.pageSize");
        var startIndex = component.get("v.startIndex");
        var endIndex = component.get("v.endIndex");
        var startIndexUpdate = startIndex - pageSize;
        var endIndexUpdate = endIndex - pageSize;
        currentPage--;
        component.set("v.startIndex", startIndexUpdate);
        component.set("v.endIndex", endIndexUpdate);
        component.set("v.currentPage", currentPage);
        if(currentPage == totalPagesCount){
            component.set("v.disableNext", true);
        }
        else{
            component.set("v.disableNext", false);
        }        
    },
})