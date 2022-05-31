({
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    doInit : function(component,event,helper){ 
        helper.doInitHelper(component,event,helper);
    },
    selectAllCheckbox: function(component, event, helper) {
       helper.selectAllCheckBoxTab1Helper(component,event,helper);
    },
    selectAllCheckboxT2: function(component, event, helper) {
         helper.selectAllCheckBoxTab2Helper(component,event,helper);
    },
    tablSelect:function(component, event, helper){
        helper.tabSelectHelper(component,event,helper)
    },
    navigateToRecord: function(component, event, helper) {
        var recordId = event.target.dataset.caseid;
        window.open('/' + recordId);  
    },showSpinner: function(component, event, helper) {
        component.set("v.spinner", true); 
    },
    hideSpinner : function(component,event,helper){
        component.set("v.spinner", false);
    },
    search: function(component, event, helper) {        
        let leasingType=component.get("v.leasingType");
        let noOfBedroom=component.get("v.selectedBedroom");
        let unitCodeSearchString=component.get("v.unitCodeSearchString");
        let selectedPropertyType=component.get("v.selectedPropertyType");
        let selectedBuilding=component.get("v.selectedBuilding");//undefined
        let selectedUnitType=component.get("v.selectedUnitType");
        if((unitCodeSearchString == undefined || unitCodeSearchString =="") && noOfBedroom =="" && selectedUnitType ==""
                                   && selectedPropertyType  =="" && selectedBuilding  == ""){
                               helper.showUnitsHelperT2(component, event); 
        }else{
            helper.searchShowUnitsHelperT2(component,event);
        }  
    },
    clear: function(component, event, helper) {
       helper.clearHelper(component,event,helper);
        //helper.searchShowUnitsHelperT2(component,event,helper);// to correct oagination remove 
    },
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        let selectedRec = event.getSource().get("v.checked");
        let getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        }else{
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);//commented now
            var g=component.find("selectAllId").get("v.value");
            console.log('@@@@ >>> ', g );
            component.set("v.isAllSelected","false");
            console.log('@@@@ >>> ', component.get("v.isAllSelected") );
            //component.set("selectAllId",false);//remove if above uncommented
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);//commented now
        }
    },
    checkboxSelectT2: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        let selectedRec = event.getSource().get("v.checked");//no T2 to be added as its event ?
        let getSelectedNumber = component.get("v.selectedCountT2");
        if (selectedRec == true) {
            getSelectedNumber++;
        }else {
            getSelectedNumber--;
            component.find("selectAllIdT2").set("v.value", false);//commented now 
        }
        component.set("v.selectedCountT2", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCountT2")) {
            //component.find("selectAllId").set("v.value", true);//commented now 05/04/2022 as event is breaking
            //component.set("selectAllId",false);//remove if above uncommented
        }
    },
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        let sObjectList = component.get("v.listOfProperty");
        let end = component.get("v.endPage");
        let start = component.get("v.startPage");
        let pageSize = component.get("v.pageSize");
        let whichBtn = event.getSource().get("v.name");
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
    /* javaScript function for pagination for tab 2*/
    navigationT2: function(component, event, helper) {
        let searchRecordCount=component.get("v.totalSearchRecordListCount");
        let sObjectList;
        if(searchRecordCount==0){
            sObjectList = component.get("v.totalListT2");  
        }
        else{
            sObjectList = component.get("v.totalSearchRecordList");   
        }
        let end = component.get("v.endPageT2");
        let start = component.get("v.startPageT2");
        let pageSize = component.get("v.pageSizeT2");
        let whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPageT2", component.get("v.currentPageT2") + 1);
            helper.nextT2(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPageT2", component.get("v.currentPageT2") - 1);
            helper.previousT2(component, event, sObjectList, end, start, pageSize);
        }
    },
    
})