({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component, event);
    },

    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.listOfProperty");
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

    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.checked");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfProperty = component.get("v.listOfProperty");
        var PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        for (var i = 0; i < listOfProperty.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfProperty[i].isChecked = true;
                component.set("v.selectedCount", listOfProperty.length);
            } else {
                listOfProperty[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfProperty[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listOfProperty", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
    },

    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.checked");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
    },

    addSelectedRecords: function(component, event, helper) {
        var allRecords = component.get("v.listOfProperty");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
         helper.createCaseUnits(component, event,selectedRecords);
    },
    navigateToRecord: function(component, event, helper) {
        var recordId = event.target.dataset.caseid;
		window.open('/' + recordId);  
    },
    showUnits: function(component, event, helper) {
        helper.showUnitsHelper(component, event);
        helper.helperFun(component,event,'articleOne');
        //helper.helperFun(component,event,'articleTwo');
        
    },
    sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');
    },
   sectionTwo : function(component, event, helper) {
      helper.helperFun(component,event,'articleTwo');
    },
})