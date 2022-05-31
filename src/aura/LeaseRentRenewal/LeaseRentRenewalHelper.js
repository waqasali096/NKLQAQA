({    
    //fetch projects
    fetchProjects: function(component, event) {  
        component.set("v.spinner", true); 
        var action = component.get("c.getProjects");
        action.setParams({ });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.listProjectOptions", result);
            }
        });
        $A.enqueueAction(action);
        component.set("v.spinner", false);
    },
    
    //fetch No. of Bedrooms
    fetchNoOfBedrooms: function(component, event) {  
        component.set("v.spinner", true); 
        var action = component.get("c.getNoOfBedroomValues");
        action.setParams({ });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.listNoOfBedroomOptions", result);
            }
        });
        $A.enqueueAction(action);  
        component.set("v.spinner", false); 
    },
    
    //fetch Unit Types
    fetchUnitTypes: function(component, event) {  
        component.set("v.spinner", true);  
        var action = component.get("c.getUnitTypeValues");
        action.setParams({ });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.listUnitTypeOptions", result);
            }
        });
        $A.enqueueAction(action);  
        component.set("v.spinner", false); 
    },
    
    //fetch Space Types
    /*fetchSpaceTypes: function(component, event) {  
        var action = component.get("c.getSpaceTypes");
        action.setParams({ });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.listSpaceTypesOptions", result);
            }
        });
        $A.enqueueAction(action);  
    },*/
    
    //fetch Buildings
    fetchBuildings: function(component, event) { 
        component.set("v.spinner", true); 
        var action = component.get("c.getBuildings");
        action.setParams({ 
            selectedProject : component.get("v.selectedProject")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.listBuildingOptions", result);                
            }
        });
        $A.enqueueAction(action);
        component.set("v.spinner", false); 
    },
    
    //fetch Floors
    fetchFloors: function(component, event) {  
        component.set("v.spinner", true); 
        var action = component.get("c.getFloors");
        action.setParams({ 
            selectedProject : component.get("v.selectedProject"),
            selectedBuilding : component.get("v.selectedBuilding")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.listFloorOptions", result);
            }
        });
        $A.enqueueAction(action);  
        component.set("v.spinner", false); 
    },
    
    //fetch Page Size
    fetchPageSize: function(component, event) {
        var action = component.get("c.getPageSize");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.pageSize", result);
                
                this.searchMethod(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    
    //fetch Rent Update Reason Values
    fetchRentUpdateReasonValues: function(component, event) {
        var action = component.get("c.getRentUpdateReasonValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
                component.set("v.rentUpdateReasonMap", fieldMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    //Search button method
    searchMethod : function(component, event) {
        component.set("v.spinner", true);
        
        var action = component.get("c.getUnitPlans");
        action.setParams({ 
            selectedProject : component.get("v.selectedProject"),
            selectedFromDate : component.get("v.selectedFromDate"),
            selectedToDate : component.get("v.selectedToDate"),
            selectedBuilding : component.get("v.selectedBuilding"),
            selectedFloor : component.get("v.selectedFloor"),
            selectedNoOfBedroom : component.get("v.selectedNoOfBedroom"),
            selectedLeasingType : component.get("v.selectedLeasingType"),
            selectedPropertyType : component.get("v.selectedPropertyType"),
            selectedUnitType : component.get("v.selectedUnitType")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.listUnitPlansWrapper", result);
                component.set("v.spinner", false);           
                this.handleNotifyFlagAll(component, event);
                this.resetPagination(component, event);
            } 
            else {
                console.log(state);
            }
        });
        $A.enqueueAction(action);
    },
    
    //Reset Pagination method
    resetPagination : function(component, event) {
        var pageSize = component.get("v.pageSize");
        var listUnitPlansWrapper = component.get("v.listUnitPlansWrapper");
        var totalLength = listUnitPlansWrapper.length;
        component.set("v.totalRecordsCount", totalLength);
        component.set("v.startIndex", 0);
        component.set("v.endIndex", component.get("v.startIndex") + pageSize);
        component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize)); 
        var totalPagesCount = component.get("v.totalPagesCount");
        component.set("v.currentPage", 1);
        if(component.get("v.currentPage") == totalPagesCount){
            component.set("v.disableNext", true);
        }
        else{
            component.set("v.disableNext", false);
        }   
    },
    
    //Apply button method
    applyMethod : function(component, event) {
        component.set("v.spinner", true);
        var listUnitPlansWrapper = component.get("v.listUnitPlansWrapper");
        var selectedAddUpliftType = component.get("v.selectedAddUpliftType");
        var selectedAddUpliftValue = component.get("v.selectedAddUpliftValue");
        var defaultRenewalRentPrice = component.get("v.defaultRenewalRentPrice");
        var selectedRentUpdateReason = component.get("v.selectedRentUpdateReason");
        
        listUnitPlansWrapper.forEach(function (item) {            
            if(selectedAddUpliftValue != null && selectedAddUpliftValue != ''){ 
                if(selectedAddUpliftType == 'Percentage'){
                    item.dcmRenewalRent = parseInt(parseInt(item.dcmCurrentRent) * (1 + (parseInt(selectedAddUpliftValue)/100)));
                }
                
                if(selectedAddUpliftType == 'Amount'){
                    item.dcmRenewalRent = parseInt(parseInt(item.dcmCurrentRent) + parseInt(selectedAddUpliftValue));
                }
            }
            
            if(defaultRenewalRentPrice != null && defaultRenewalRentPrice != ''){
                item.dcmRenewalRent = defaultRenewalRentPrice;
            }
            
            if(selectedRentUpdateReason != null){
                item.strRentUpdateReason = selectedRentUpdateReason;
            }
        }); 
        component.set("v.listUnitPlansWrapper", listUnitPlansWrapper);
        component.set("v.spinner", false);
    },
    
    //Save button method
    saveMethod : function(component, event) {
        component.set("v.spinner", true);
        var action = component.get("c.saveUnits");
        action.setParams({
            strListUnitPlansWrapper: JSON.stringify(component.get('v.listUnitPlansWrapper')),
            selectedLeasingType : component.get("v.selectedLeasingType")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.spinner", false);
                if(result.strMessage == 'success'){
                    this.showToastMessage('success', 'Successfully updated details on Units.');
                    component.set("v.listUnitPlansWrapper", result.listUnitPlansWrapper);                    
                }
                else{
                    this.showToastMessage('error', result.strMessage);
                }                
            }
        });
        $A.enqueueAction(action);
    },
    
    //Notify Flag (table header) check/uncheck method
    handleNotifyFlagAll : function(component, event) {
        var listUnitPlansWrapper = component.get("v.listUnitPlansWrapper");
        var notifyFlagAll = component.get("v.notifyFlagAll");
        listUnitPlansWrapper.forEach(function (item) {            
            if(notifyFlagAll){
                item.blnNotifyFlag = true;
            }
            else{
                item.blnNotifyFlag = false;
            }
        }); 
        component.set("v.listUnitPlansWrapper", listUnitPlansWrapper);
    },
    
    //Reset button method
    resetPriceMethod : function(component, event) {
        /*var listUnitPlansWrapper = component.get("v.listUnitPlansWrapper");
        listUnitPlansWrapper.forEach(function (item) {   
            item.dcmRenewalRent = item.objUnitPlan.Unit__r.Current_Rent__c;
            item.strRentUpdateReason = "";
            item.strComments = "";
            item.blnNotifyFlag = false;
        });*/ 
        //component.set("v.listUnitPlansWrapper", listUnitPlansWrapper);
        component.set("v.defaultRenewalRentPrice", "");
        component.set("v.selectedAddUpliftType", "Percentage");
        component.set("v.selectedAddUpliftValue", "");
        component.set("v.selectedRentUpdateReason", "");
        component.set("v.disableApplyButton", true);
        component.set("v.notifyFlagAll", true);
        this.resetPagination(component, event);
        this.applyButtonVisibility(component, event);
        this.searchMethod(component, event);
    },
    
    //populate FromDate & ToDate based on selected DateFilter
    updateFromDateToDate : function(component, event) {
        var date = new Date();
        var todayDate = date.getFullYear() + '-' + (date.getMonth()+1) + '-' + date.getDate(); 
        
        if(component.get("v.selectedDateFilter") == '0'){
            component.set("v.selectedFromDate", "");
            component.set("v.selectedToDate", "");
        }
        
        if(component.get("v.selectedDateFilter") == '60'){
            component.set("v.selectedFromDate", todayDate);
            date.setDate(date.getDate() + 60);
            var toDate = date.getFullYear() + '-' + ('0' + (date.getMonth()+1)).slice(-2)  + '-' + ('0' + (date.getDate())).slice(-2); 
            component.set("v.selectedToDate", toDate);
        }
        
        if(component.get("v.selectedDateFilter") == '90'){
            component.set("v.selectedFromDate", todayDate);
            date.setDate(date.getDate() + 90);
            var toDate = date.getFullYear() + '-' + ('0' + (date.getMonth()+1)).slice(-2)  + '-' + ('0' + (date.getDate())).slice(-2); 
            component.set("v.selectedToDate", toDate);
        }
    },
    
    //control Seach button visibility based on Project & Dates
    searchButtonVisibility : function(component, event) {        
        var validFromDate = false;
        var fromDatevalidity = component.find("filterFromDate").get("v.validity");
        if(fromDatevalidity && fromDatevalidity.valid){
            validFromDate = true;
        }
        
        var validToDate = false;
        var toDatevalidity = component.find("filterToDate").get("v.validity");
        if(toDatevalidity && toDatevalidity.valid){
            validToDate = true;
        }
        
        if(validFromDate && validToDate){
            component.set("v.disableSearchButton", false);
        }
        else{
            component.set("v.disableSearchButton", true);
        }
        
        if(component.get("v.selectedDateFilter") == '0'){
            component.set("v.disableSearchButton", true);
        }
    },
    
    //toastMessage
    showToastMessage : function(type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    //control Apply button visibility based on Uplift value & DefaultRenewalRentPrice
    applyButtonVisibility : function(component, event) {
        var disableApplyButton = true;
        
        var validValue = false;
        if(component.get("v.selectedLeasingType") == 'Residential Unit'){
            var addUpliftValue = component.find("addUpliftValueId").get("v.validity");
            if(!$A.util.isEmpty(component.get("v.selectedAddUpliftValue")) && addUpliftValue && addUpliftValue.valid){
                disableApplyButton = false;
                validValue = true;
            }
            var defaultRenewalRentPrice = component.find("defaultRenewalRentPriceId").get("v.validity");
            if(!$A.util.isEmpty(component.get("v.defaultRenewalRentPrice")) && defaultRenewalRentPrice && defaultRenewalRentPrice.valid){
                disableApplyButton = false;
                validValue = true;
            }
            if($A.util.isEmpty(component.get("v.defaultRenewalRentPrice")) && $A.util.isEmpty(component.get("v.selectedAddUpliftValue"))){
                validValue = true;
            }
        }
        if((component.get("v.selectedLeasingType") == 'Commercial Unit' || validValue) && !$A.util.isEmpty(component.get("v.selectedRentUpdateReason"))){
            disableApplyButton = false;
        }
        component.set("v.disableApplyButton", disableApplyButton);
    }
})