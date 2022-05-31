({
    doInit : function(component, event, helper){
        component.set('v.spinner',true);
        var recordId = component.get("v.recordId");
        console.log('recordId',recordId);
        helper.getRecordType(component, event, helper);
        helper.getOpportunityDetail(component, event, recordId);
        helper.fetchSubject(component, event, recordId);
        helper.fetchUnits(component, event, recordId);
        component.set('v.isShowMainScreen',true);
        component.set('v.spinner',false);
        
    },

    handleSuccess : function(component, event, helper) {
        component.set('v.spinner',true);
        var record = event.getParam("response");
        var myRecordId = record.id; 
        component.set("v.caseId",myRecordId);
        helper.updateRecordType(component, event, myRecordId); 
        console.log('show table :',component.get('v.isShowtable'));
    },

    handleSubmit: function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting
        if(component.get("v.hasErrors")){
            var a = component.get('c.expectedDateValidation');
            $A.enqueueAction(a);
            var b = component.get('c.actualDateValidation');
            $A.enqueueAction(b);
        }else{
            component.set('v.spinner',true);
        	var fields = event.getParam('fields');
        	console.log('fields',fields);
        	fields.recordTypeId= component.get('v.recordTypeId');
        	fields.AccountId = component.get("v.accountValue");
        	fields.Subject = component.get('v.subjectValue');
            component.find('recordEditForm').submit(fields);
        }
    },

    onclickCancel: function (cmp, event, helper) {
       // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    onTypeChange : function(cmp, event, helper){
        var selectedValue = cmp.find("terminationTypeId").get("v.value");
        console.log('selectedValue',selectedValue);
        if(selectedValue == 'End of Lease Termination'){
            cmp.set('v.showEndOfLeaseReason',true);
            cmp.set('v.showPrematureReason',false);
            cmp.set('v.showExpectedTerminationDate',true);
            cmp.set('v.populateDate',false);
        }else if(selectedValue == 'Premature Termination'){
            cmp.set('v.showPrematureReason',true);
            cmp.set('v.showEndOfLeaseReason',false);
            cmp.set('v.showExpectedTerminationDate',true);
            cmp.set('v.populateDate',false);
        }else{
            cmp.set('v.showPrematureReason',false);
            cmp.set('v.showEndOfLeaseReason',false);
            cmp.set('v.showExpectedTerminationDate',false);
            cmp.set('v.populateDate',false);
        }
        
    },

    onEOLReasonChange : function(cmp, event, helper){
        var selectedValue = cmp.find("endOfLeaseReasonId").get("v.value");
        console.log('selectedValue',selectedValue);
        if(selectedValue === 'Legal Eviction'){
            cmp.set('v.showActualTerminationDate',true);
            cmp.set('v.showExpectedTerminationDate',false);
            cmp.set('v.populateDate',false);
        }else{
            cmp.set('v.showActualTerminationDate',false);
            cmp.set('v.showExpectedTerminationDate',true);
            cmp.set('v.populateDate',true);
        }
    },

    expectedDateValidation : function(cmp, event, helper){
        var terminationType = cmp.find("terminationTypeId").get("v.value");
        var today = new Date();
        let leaseEndDate = new Date(cmp.get("v.opportunitySobj").Lease_End_Date__c);
        if(terminationType && terminationType === 'Premature Termination'){
            var expectedDateValue = cmp.find("expectedTerminationDateId").get("v.value");
            let expectedDate = new Date(expectedDateValue);
            console.log('expectedDate :',expectedDate);
            if(expectedDate >= leaseEndDate){
                var toastEvent = $A.get("e.force:showToast");
                cmp.set("v.hasErrors",true);
                toastEvent.setParams({
                    title : 'Error Message',
                    message: 'For premature termination, this date cannot be greater than Lease End Date : '+ cmp.get("v.opportunitySobj").Lease_End_Date__c,
                    type: 'error',
                });
                toastEvent.fire();
            }else if(expectedDate <= today){
                var toastEvent = $A.get("e.force:showToast");
                cmp.set("v.hasErrors",true);
                toastEvent.setParams({
                    title : 'Error Message',
                    message: 'For premature termination, this date should be greater than today ',
                    type: 'error',
                });
                toastEvent.fire();
            }else{
                cmp.set("v.hasErrors",false);
            }
        }else if(terminationType && terminationType === 'End of Lease Termination'){
            var endOfLeaseReason = cmp.find("endOfLeaseReasonId").get("v.value");
            var expectedDateEOLValue = cmp.find("expectedTerminationDateIdEOL").get("v.value");
            let expectedDateEOL = new Date(expectedDateEOLValue);
            if(endOfLeaseReason != 'Legal Eviction' && expectedDateEOL < leaseEndDate){
                var toastEvent = $A.get("e.force:showToast");
                cmp.set("v.hasErrors",true);
                toastEvent.setParams({
                    title : 'Error Message',
                    message: 'For EOL, this date cannot be less than Lease end date : '+ cmp.get("v.opportunitySobj").Lease_End_Date__c,
                    type: 'error',
                });
                toastEvent.fire();
            }else{
                cmp.set("v.hasErrors",false);
            }
        }
    },

    actualDateValidation : function(cmp, event, helper){
        var actualDateValue = cmp.find("actualTerminationDateId").get("v.value");
        let actualDate = new Date(actualDateValue);
        var terminationType = cmp.find("terminationTypeId").get("v.value");
        let leaseEndDate = new Date(cmp.get("v.opportunitySobj").Lease_End_Date__c);
        let leaseStartDate = new Date(cmp.get("v.opportunitySobj").Lease_Start_Date__c);
        if(terminationType && terminationType === 'End of Lease Termination'){
            var endOfLeaseReason = cmp.find("endOfLeaseReasonId").get("v.value");
            if(endOfLeaseReason === 'Legal Eviction' && actualDate > leaseEndDate){
                cmp.set("v.hasErrors",true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: 'For Legal Eviction, this date should be less than Lease end date : '+ cmp.get("v.opportunitySobj").Lease_End_Date__c,
                    type: 'error',
                });
                toastEvent.fire();
            }else if(endOfLeaseReason === 'Legal Eviction' && actualDate < leaseStartDate){
                cmp.set("v.hasErrors",true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: 'For Legal Eviction, this date cannot be less than Lease start date : '+ cmp.get("v.opportunitySobj").Lease_Start_Date__c,
                    type: 'error',
                });
                toastEvent.fire();
            }else{
                cmp.set("v.hasErrors",false);
            }
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
            if (selectedHeaderCheck == true && listOfProperty[i].propFlag != true) {
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
            if (selectedHeaderCheck == true && PaginationList[i].propFlag !=true) {
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

    addSelectedRecords: function(component, event, helper) {
        let button = component.find('AddSelectRecords');
    	button.set('v.disabled',true);
        var allRecords = component.get("v.listOfProperty");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i]);
            }
        }
         helper.createCaseUnits(component, event,selectedRecords);
    },

})