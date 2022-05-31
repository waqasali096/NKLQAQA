({
    /*Purpose - get available units to form dynamic fileters on load*/
    getAvailableUnits : function(component, helper) {
        component.set("v.spinner",true);  
        var action = component.get("c.getAvailableUnits");
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('%%result',JSON.stringify(result));
                if(!result.success){
                    //component.set("v.DisplayMsgFlg",true);
                    //component.set("v.DisplaySearchResultFlg",false);
                }else{
                    if(result.filterwrapperList){
                        var filters = result.filterwrapperList;
                        console.log('%%filters',JSON.stringify(filters.projectMap));
                        var projectsMap = [];
                        var salesEventMap = [];
                        var unitTypeMap = [];
                        var buildingMap = [];
                        var bedroomMap = [];
                        for(var key in filters.projectMap){
                            projectsMap.push({key: key, value: filters.projectMap[key]});
                        }
                        component.set("v.projectsMap",projectsMap);
                        for(var key in filters.unitTypeMap){
                            unitTypeMap.push({key: key, value: filters.unitTypeMap[key]});
                        }
                        for(var key in filters.salesEventMap){
                            salesEventMap.push({key: key, value: filters.salesEventMap[key]});
                        }
                        for(var key in filters.buildingMap){
                            buildingMap.push({key: key, value: filters.buildingMap[key]});
                        }
                        for(var key in filters.bedroomMap){
                            bedroomMap.push({key: key, value: filters.bedroomMap[key]});
                        }
                        component.set("v.unitTypeMap",unitTypeMap);
                        component.set("v.salesEventMap",salesEventMap);
                        component.set("v.buildingMap",buildingMap);
                        component.set("v.bedroomsMap",bedroomMap);
                    }
                }
                component.set("v.spinner", false);
            }
            else if(state === "ERROR"){
                component.set("v.DisplayMsgFlg",true);
                var errors = action.getError();
                if (errors) {
                    this.showToast(component,'Something went wrong, please try again','Error','Error'); 
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
            component.set("v.spinner", false); 
        });
        $A.enqueueAction(action);
    },
    
    /*Purpose - search units based on user selected filters*/
    getUnits : function(component, helper) {
        component.set("v.spinner",true);  
        var project = component.get("v.selectedprojects");
        var locationCode = component.get("v.selectedLocationCode");
        var salesEvent = component.get("v.selectedSalesEvent");
        var unitType = component.get("v.selectedUnitType");
        var building = component.get("v.selectedBuilding");
        var bedroom = component.get("v.selectedBedroom");
        var pageSize = component.get("v.pageSize").toString();
        var recId = component.get("v.recordId");
        
        var action = component.get("c.getSearchUnits");
        action.setParams({
            'project' : project,
            'locationCode' : locationCode,
            'salesEvent' : salesEvent,
            'unitType' : unitType,
            'building' : building, 
            'bedroom' : bedroom,
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!result.success){
                    component.set("v.DisplayMsgFlg",true);
                    component.set("v.DisplaySearchResultFlg",false);
                }else if(result.resultWrapperList){
                    this.setPagination(component, event, helper, result.resultWrapperList);
                    component.set("v.DisplayMsgFlg",false);
                    component.set("v.DisplaySearchResultFlg",true);
                }
                component.set("v.spinner", false);
            }
            else if(state === "ERROR"){
                component.set("v.DisplayMsgFlg",true);
                var errors = action.getError();
                if (errors) {
                    this.showToast(component,'Something went wrong, please try again','Error','Error'); 
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
            component.set("v.spinner", false); 
        });
        $A.enqueueAction(action);
    },
    
    /*Purpose - Set the pagination*/
    setPagination: function(component, event, helper, allUnitsList){
        var pageSize = component.get("v.pageSize");
        var unitsList = allUnitsList;
        var unitListLength = unitsList.length ;
        component.set("v.totalRecordsCount", unitListLength);
        component.set("v.startPage",0);
        component.set("v.endPage",pageSize-1);
        component.set("v.allUnitsList", unitsList);
        var PaginationLst = [];
        for(var i=0; i < pageSize; i++){
            if(component.get("v.allUnitsList").length > i){
                PaginationLst.push(allUnitsList[i]);    
            } 
        }
        component.set('v.onloadUnitList', PaginationLst);
        component.set("v.selectedCount" , 0);
        component.set("v.totalPagesCount", Math.ceil(unitListLength / pageSize)); 
        component.set("v.currentPage", 1);
    },
    
    checkFormGenerated: function(component, event, helper) {
        var action = component.get("c.checkFormGenerated");
        action.setParams({
            'recId' : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var resultData = response.getReturnValue();
                component.set("v.bookingFormGen",resultData);
                console.log('%%FormCheck'+component.get("v.bookingFormGen"));  
                component.set("v.spinner", false);
            }
            else if(state === "ERROR"){
                console.log(errors[0].message);
                var errors = action.getError();
                if (errors){
                    this.showToast(component,'Something went wrong, please try again','Error','Error'); 
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
                component.set("v.spinner", false);
            } 
        });
        $A.enqueueAction(action);
    },
    
    // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
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
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.onloadUnitList', Paginationlist);
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
        component.set('v.onloadUnitList', Paginationlist);
    },
    
    //Purpose - call event to add to cart
    addUnitstoOpp: function(component, event, helper) {
        component.set('v.spinner',true);
        var allRecords = component.get("v.allUnitsList");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
                allRecords.splice(i,1);
                i--;
            }
        }
        this.setPagination(component, event, helper,allRecords);
        if(selectedRecords.length == 0){
            this.showToast(component,'Please select a unit.','Error','Error'); 
        }
        else if(selectedRecords.length >= 1){
            var qbEvent = $A.get("e.c:QuickBookEvent");
            //var qbEvent = component.getEvent("QuickBookEvent");
            qbEvent.setParams({
                "selectedUnits" : selectedRecords 
            });
            qbEvent.fire();
            component.find("selectAllId").set("v.checked", false);
        }
        component.set('v.spinner',false);
    },
    
    //Purpose - call to create sales offer
    createSalesOffers: function(component, event, helper) {
        component.set('v.spinner',true);
        var buttonPressed = event.getSource().getLocalId();
        var allRecords = component.get("v.allUnitsList");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
        if(selectedRecords.length == 0){
            this.showToast(component,'Please select a unit.','Error','Error'); 
        }else if(selectedRecords.length > 5 && buttonPressed && buttonPressed == 'salesOffer'){
            this.showToast(component,'Sales Offer with floor plans can be generated with maximum of 5 units.Please use bulk offer','Error','Error'); 
        }else if(selectedRecords.length >= 1){
            var action = component.get("c.createSalesOffer");
            action.setParams({
                'unitList' : JSON.stringify(selectedRecords)
            });
            action.setCallback(this,function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result.success){
                        if(buttonPressed && buttonPressed == 'salesOffer'){
                           component.set("v.salesOfferContainer", true); 
                        }else if(buttonPressed && buttonPressed == 'bulkOffer'){
                           component.set("v.bulkOfferContainer", true); 
                        }
                        component.set("v.salesOfferId", result.salesOfferId);
                        component.find("selectAllId").set("v.checked", false);
                    }else if(!result.success){
                         this.showToast(component,result.message,'Error','Error'); 
                    }
                    component.set("v.spinner", false);
                }
                else if(state === "ERROR"){
                    component.set("v.DisplayMsgFlg",true);
                    var errors = action.getError();
                    if (errors) {
                        this.showToast(component,'error in sales offer part','Error','Error'); 
                        if (errors[0] && errors[0].message) {
                            console.log(errors[0].message);
                        }
                    }
                } 
                component.set("v.spinner", false); 
            });
            $A.enqueueAction(action);
        }
        component.set('v.spinner',false);
    },
    
    //Method to show toast message
    showToast : function(component, message, title, type) {
        component.set('v.spinner',false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message:message,
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },
    
    sortBy: function(field, reverse, primer) {
        var key = primer
        ? function(x) {
            return primer(x[field]);
        }
        : function(x) {
            return x[field];
        };
        
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.onloadUnitList");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.onloadUnitList", data);
    },
    
})