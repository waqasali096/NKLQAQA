({
    doInit : function(component, event, helper) {
        helper.checkFormGenerated(component, event,helper);
        helper.getAvailableUnits(component, event,helper);
	},
    
    /*Purpose - search units based on user selected filters*/
    search : function(component, event, helper) {
        helper.getUnits(component,event);
    },
    
    /*Purpose - reset user selected filers*/
    reset : function(component, event, helper) {
    	component.set("v.selectedprojects", '');  
        component.set("v.selectedLocationCode", '');  
        component.set("v.selectedSalesEvent", '');  
        component.set("v.selectedUnitType", '');  
        component.set("v.selectedBuilding", '');  
        component.set("v.selectedBedroom", '');  
        component.set('v.DisplaySearchResultFlg',false);
    },
    
    /*Purpose - view unit details,Invokes child component*/
    viewUnits : function(component, event, helper) {
        component.set("v.modalContainer", true);
        var unitLists = component.get("v.allUnitsList");
        var index = event.getSource().get("v.name");
        //var unitToView = unitLists[index];
        var unitToView;
        for(var i = 0; i < unitLists.length; i++) {
            if(unitLists[i].unitId == index){
               unitToView =  unitLists[i];
            }
        }
        component.set("v.unitDetailId", unitToView.unitId);
    },
    
    /*Purpose - close view unit pop up*/
    closeViewDetails : function(component, event, helper) {
        component.set("v.modalContainer", false);
    },
    
    /*Purpose - main checkbox selection*/
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.checked");
        var allUnitsList = component.get("v.allUnitsList");
        var PaginationList = component.get("v.onloadUnitList");
        var selectedUnits= [];
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        
        for(var i = 0; i < allUnitsList.length; i++) {
            if(selectedHeaderCheck == true) {
                if(!allUnitsList[i].preBooked){
                    allUnitsList[i].isChecked = true;
                    selectedUnits.push(allUnitsList[i]);
                }
                component.set("v.selectedCount", selectedUnits.length);
            }else{
                allUnitsList[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(allUnitsList[i]);
        }
        // update the checkbox for 'PaginationList' based on header checkbox 
        for(var i = 0; i < PaginationList.length; i++) {
            if(selectedHeaderCheck == true){
                if(!PaginationList[i].preBooked){
                    PaginationList[i].isChecked = true;
                }
            }else{
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.allUnitsList", updatedAllRecords);
        component.set("v.onloadUnitList", updatedPaginationList);
    },
    
    /*Purpose - checkbox selection*/
    checkboxSelect: function(component, event, helper) {
        var selectedRec = event.getSource().get("v.checked");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
    },
    
    /*Purpose - pagination buttons functionality*/
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.allUnitsList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },

    callAddUnitstoOpp: function(component, event, helper) {
    	helper.addUnitstoOpp(component,event);
    },
    
    callSalesOffer: function(component, event, helper) {
    	helper.createSalesOffers(component,event);
    },
    
    handleSort: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');                       
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
                            
    handleClose : function(component, event, helper) {
    	$A.get("e.force:closeQuickAction").fire();
    },
    
    handleSearchRefresh : function(component, event, helper) {
    	var refreshSearch = event.getParam("refreshSearch");
        var closePopup = event.getParam("closePopUp");
        if(refreshSearch && component.get("v.DisplaySearchResultFlg")){
           helper.getUnits(component,event); 
        }
        if(!closePopup){
            component.set("v.salesOfferContainer", closePopup); 
            component.set("v.bulkOfferContainer", closePopup); 
        } 
    },
        
    removeUnits : function(component, event, helper) {
        component.set("v.spinner", true);
        
        var unitLists = component.get("v.currentUnitList");
        var index = event.getSource().get("v.name");
        var unitsDelete;
        //console.log('%%index'+JSON.stringify(index));
        for(var i = 0; i < unitLists.length; i++) {
            if(unitLists[i].unitId == index){
               unitsDelete =  unitLists[i];
            }
        }
        //var unitsDelete = unitLists[index];
        //console.log('%%unitsDelete'+JSON.stringify(unitsDelete));
        
        var unitsToDelete = [];
        unitsToDelete.push(unitsDelete);
        var action = component.get("c.removeSelectedUnits");  
        action.setParams({
            'unitList' : unitsToDelete,
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this,function(response){ 
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                console.log('%%result'+JSON.stringify(result));
                if(result){
                    component.set('v.spinner',false);
                    helper.showToast(component,'Unit Removed','Success','Success');
                    $A.get('e.force:refreshView').fire();
                }
            }else{  
                component.set('v.spinner',false);
                console.log('something bad happend! ');  
            }  
        });
        //$A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
    },    
    
    getValueFromLwc : function(component, event, helper) {
        console.log('%%Value from LWC'+event.getParam('value'));
        $A.get('e.force:refreshView').fire();
		//component.set("v.inputValue",event.getParam('value'));
	}

})