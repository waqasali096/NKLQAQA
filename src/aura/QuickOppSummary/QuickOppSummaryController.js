({  
    doInit : function(component, event, helper) {
        helper.fetchChildOppstoCart(component, event,helper);
        helper.fetchAccountDetails(component, event,helper);
        helper.getSalesTypeValues(component, event,helper);
        helper.getDependantTypeValues(component, event,helper);
        component.set('v.jocolumns', [
            {label: 'Secondary Joint Buyer Name', fieldName: 'joName', type: 'text'},
            {label: 'Primary Owner', fieldName: 'primaryName', type: 'text'},
            {label: 'Relationship', fieldName: 'relation', type: 'text'},
            {label: 'Share Percentage', fieldName: 'sharePercentage', type: 'percentage'}
        ]);
    },
            
    /*Purpose - add units to cart by creating child opps*/
    handleAddUnitEvent : function(component,event,helper) {
        var closePopup = event.getParam("closePopUp");
        var selUnits = event.getParam("selectedUnits");
        var customerAdded = event.getParam("customerAdded");
        //component.set( "v.newAccount", event.getParam("addedAccount"));
        
        if(!closePopup){
            component.set("v.modalContainer", closePopup); 
            if(component.get("v.selectedDropdown") && component.get("v.selectedDropdown") == 'AddOffers'){
                helper.getDLDPrice(component, event,helper,component.get("v.selectedRecordId"));
            }
        } 
        if(event.getParam("selectedUnits")){
            component.set("v.spinner", true);
            var existingCartUnits = component.get("v.cartUnits");
            for (var i = 0; i < selUnits.length; i++) {
                if(selUnits[i].isChecked){
                    selUnits[i].isChecked = false;
                    existingCartUnits.push(selUnits[i]);
                }
            }
            console.log('cartunit'+JSON.stringify(existingCartUnits));
            var action = component.get("c.createChildOpps");
            action.setParams({
                'recordId' : component.get("v.recordId"),
                'cartUnits' : existingCartUnits,
            });
            action.setCallback(this,function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(!result.success){
                        //show no units error
                    }else if(result.resultWrapperList){
                        component.set("v.cartTotalPrice", result.cartTotalPrice);
                        //component.set("v.customerAdded", result.accExist);
                        component.set("v.accountId", result.accId);
                        helper.setPagination(component, event, helper, result.resultWrapperList);
                        //component.set("v.cartUnits", result.resultWrapperList);
                    }
                    component.set("v.spinner", false);
                }
                else if(state === "ERROR"){
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
        }
        if(customerAdded){
            //component.set("v.customerAdded", true); 
            var accountId = event.getParam("accountId");
            component.set("v.accountId", accountId);
            component.set( "v.newAccount", event.getParam("addedAccount"));
            console.log('newAccount'+ JSON.stringify(event.getParam("addedAccount")));
        }else{
          //component.set("v.customerAdded", false); 
          component.set("v.accountId", "");
          component.set( "v.newAccount","");
        }
    },
    
    /*Purpose - invoke sales offer creation component*/
    handleSalesOffer : function(component,event,helper) {
        component.set('v.spinner',true);
        var cartUnits = component.get("v.cartUnits");
        var selectedRecords = [];
        for (var i = 0; i < cartUnits.length; i++) {
            if (cartUnits[i].isChecked) {
                selectedRecords.push(cartUnits[i]);
            }
        }
        if(selectedRecords.length == 0){
            helper.showToast(component,'Please select a unit.','Error','Error'); 
        }
        else if(selectedRecords.length >= 1){
            //component.set("v.selectedDropdown", "salesOffer");
            //component.set("v.modalContainer", true);
            helper.callSalesOfferCreation(component, event, helper,selectedRecords);
        }
        component.set('v.spinner',false); 
    },
    
     /*Purpose - main checkbox selection*/
    selectAllCart: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.checked");
        var allUnitsList = component.get("v.cartUnits");
        var PaginationList = component.get("v.paginationList");
        var selectedUnits= [];
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        
        for(var i = 0; i < allUnitsList.length; i++) {
            if(selectedHeaderCheck == true) {
                allUnitsList[i].isChecked = true;
                selectedUnits.push(allUnitsList[i]);
                component.set("v.cartSelectedCount", selectedUnits.length);
            }else{
                allUnitsList[i].isChecked = false;
                component.set("v.cartSelectedCount", 0);
            }
            updatedAllRecords.push(allUnitsList[i]);
        }
        // update the checkbox for 'PaginationList' based on header checkbox 
        for(var i = 0; i < PaginationList.length; i++) {
            if(selectedHeaderCheck == true){
                PaginationList[i].isChecked = true;
            }else{
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.cartUnits", updatedAllRecords);
        component.set("v.paginationList", updatedPaginationList);
    },
    
     /*Purpose - booked main checkbox selection*/
    selectAllBooked: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.checked");
        var allUnitsList = component.get("v.bookedUnits");
        var PaginationList = component.get("v.bookedPaginationList");
        var selectedUnits= [];
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        
        for(var i = 0; i < allUnitsList.length; i++) {
            if(selectedHeaderCheck == true) {
                allUnitsList[i].isChecked = true;
                selectedUnits.push(allUnitsList[i]);
                component.set("v.bookedSelectedCount", selectedUnits.length);
            }else{
                allUnitsList[i].isChecked = false;
                component.set("v.bookedSelectedCount", 0);
            }
            updatedAllRecords.push(allUnitsList[i]);
        }
        // update the checkbox for 'PaginationList' based on header checkbox 
        for(var i = 0; i < PaginationList.length; i++) {
            if(selectedHeaderCheck == true){
                PaginationList[i].isChecked = true;
            }else{
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.bookedUnits", updatedAllRecords);
        component.set("v.bookedPaginationList", updatedPaginationList);
    },
    
    /*Purpose - checkbox selection*/
    cartSelection: function(component, event, helper) {
        var selectedRec = event.getSource().get("v.checked");
        var getSelectedNumber = component.get("v.cartSelectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("cartSelectAllId").set("v.value", false);
        }
        component.set("v.cartSelectedCount", getSelectedNumber);
        if (getSelectedNumber == component.get("v.cartTotalRecordsCount")) {
            component.find("cartSelectAllId").set("v.value", true);
        }
    },
    
    /*Purpose - checkbox selection*/
    bookedSelection: function(component, event, helper) {
        var selectedRec = event.getSource().get("v.checked");
        var getSelectedNumber = component.get("v.bookedSelectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("bookedSelectAllId").set("v.value", false);
        }
        component.set("v.bookedSelectedCount", getSelectedNumber);
        if (getSelectedNumber == component.get("v.bookedTotalRecordsCount")) {
            component.find("bookedSelectAllId").set("v.value", true);
        }
    },
    
    /*Purpose - pagination buttons functionality*/
    /*cartNavigation: function(component, event, helper) {
        var sObjectList = component.get("v.cartUnits");
        var end = component.get("v.cartEndPage");
        var start = component.get("v.cartStartPage");
        var pageSize = component.get("v.cartPageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.cartCurrentPage", component.get("v.cartCurrentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.cartCurrentPage", component.get("v.cartCurrentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },*/
    
    /*Purpose - booked pagination buttons functionality*/
    cartNavigation: function(component, event, helper) {
        var whichBtn = event.getSource().get("v.name");
        var sObjectList;
        var end;
        var start;
        var pageSize;
        
        if (whichBtn == 'next' || whichBtn == 'previous') {
            sObjectList = component.get("v.cartUnits");
            end = component.get("v.cartEndPage");
            start = component.get("v.cartStartPage");
            pageSize = component.get("v.cartPageSize");
            whichBtn = event.getSource().get("v.name");
        }else if(whichBtn == 'booknext' || whichBtn == 'bookprevious'){
            sObjectList = component.get("v.bookedUnits");
            end = component.get("v.bookedEndPage");
            start = component.get("v.bookedStartPage");
            pageSize = component.get("v.bookedPageSize");
        }
        
        if (whichBtn == 'next') {
            component.set("v.cartCurrentPage", component.get("v.cartCurrentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize,whichBtn);
        }
        else if (whichBtn == 'previous') {
            component.set("v.cartCurrentPage", component.get("v.cartCurrentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize,whichBtn);
        }
        else if (whichBtn == 'booknext') {
            component.set("v.bookedCurrentPage", component.get("v.bookedCurrentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize,whichBtn);
        }
        else if (whichBtn == 'bookprevious') {
            component.set("v.bookedCurrentPage", component.get("v.bookedCurrentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize,whichBtn);
        }
    },
    
    /*Purpose - remove units from cart*/
    handleCartRemoval: function(component, event, helper) {
        component.set("v.spinner", true);
        var allUnitsList = component.get("v.cartUnits");
        var selectedUnits= [];
        var deselectedUnits= [];
        for(var i = 0; i < allUnitsList.length; i++) {
            if(allUnitsList[i].isChecked == true) {
                selectedUnits.push(allUnitsList[i]);
            }else{
                deselectedUnits.push(allUnitsList[i]);
            }
        }
        var action = component.get("c.removeChildOpps");
        action.setParams({
            'removeCartUnits' : selectedUnits
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result){
                    helper.showToast(component,'Units Removed from Cart','Success','Success');
                    component.set("v.cartUnits", deselectedUnits);
                    component.set("v.isCartAllSelected", false);
                    component.find("cartSelectAllId").set("v.value", false);
                    component.set("v.accountId", '');
                    helper.setPagination(component, event, helper, component.get("v.cartUnits"));
                    var qbEvent = $A.get("e.c:QuickBookEvent");
                    qbEvent.setParams({
                        "refreshSearch" : true 
                    });
                    qbEvent.fire();
                }else{
                    helper.showToast(component,'Error in Unit Removal','Error','Error');
                }
                component.set("v.spinner", false);
            }
            else if(state === "ERROR"){
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
    
    /*Purpose - handle Booking units, add to booking cart*/
    handleUnitsBooking : function(component, event, helper) {
        if(!component.get('v.accountId')){
            helper.showToast(component,'Please add Customer before Booking','Error','Error');
        }else{
            var cartUnits = component.get("v.cartUnits");
            var selectedRecords = [];
            for (var i = 0; i < cartUnits.length; i++) {
                if (cartUnits[i].isChecked) {
                    selectedRecords.push(cartUnits[i]);
                    cartUnits.splice(i,1);
                    i--;
                }
            }
            if(selectedRecords.length == 0){
                this.showToast(component,'Please select a unit.','Error','Error'); 
            }
            else if(selectedRecords.length >= 1){
                helper.setPagination(component, event, helper,cartUnits);
                helper.callBookUnits(component, event, helper,selectedRecords);
            }
        }
    },
        
    /*Purpose - handle Add Options, view details, calls child components*/
    handleMenuOption : function(component, event, helper) {
        component.set('v.spinner',true);
        component.set("v.modalContainer", true);
        var selectedMenuItemValue = event.getParam("value");
        var unitLists = component.get("v.cartUnits");
        var index = event.getSource().get("v.name");
        var unitToView = unitLists[index];
        component.set("v.selectedDropdown", selectedMenuItemValue);
        if(selectedMenuItemValue &&  selectedMenuItemValue =='ViewDetails'){
           component.set("v.selectedRecordId", unitToView.unitId); 
        }else if(selectedMenuItemValue &&  selectedMenuItemValue =='AddOptions'){
           component.set("v.selectedRecordId", unitToView.oppId); 
        }
        else if(selectedMenuItemValue &&  selectedMenuItemValue =='AddOffers'){
           component.set("v.selectedRecordId", unitToView.oppId); 
        }
        else if(selectedMenuItemValue &&  selectedMenuItemValue =='AddSaleType'){
           component.set("v.selectedRecordId", unitToView.oppId); 
        }
        component.set("v.selectedUnit", unitToView); 
        component.set('v.spinner',false);
    },
    
    /*Purpose - handle Add Options, view details, calls child components*/
    handleBookingMenuOption : function(component, event, helper) {
        component.set("v.modalContainer", true);
        var selectedMenuItemValue = event.getParam("value");
        var bookedUnitLists = component.get("v.bookedUnits");
        var index = event.getSource().get("v.name");
        var unitToView = bookedUnitLists[index];
        console.log(unitToView);
        component.set("v.selectedDropdown", selectedMenuItemValue);
        if(selectedMenuItemValue &&  selectedMenuItemValue =='ViewDetails'){
           component.set("v.selectedRecordId", unitToView.unitId); 
        }else if(selectedMenuItemValue &&  selectedMenuItemValue =='SendCredit'){
           component.set("v.selectedRecordId", unitToView.oppId); 
        }else if(selectedMenuItemValue &&  selectedMenuItemValue =='ViewAdvanceScreen'){
            var redirect = $A.get("e.force:navigateToSObject");
            redirect.setParams({
                "recordId": unitToView.oppId
            });
            redirect.fire();
        }else if(selectedMenuItemValue &&  selectedMenuItemValue =='ViewBookingForm'){
            component.set("v.selectedRecordId", unitToView.oppId); 
            var action = component.get("c.getBookingForm");
            action.setParams({
                'OppId' : unitToView.oppId
            });
            action.setCallback(this,function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result && result.bookingFormId){
                        var nagigateLightning = component.find('navigate');
                        var pageReference = {
                            type: 'standard__namedPage',
                            attributes: {
                                pageName: "filePreview",
                            },
                            state: {
                                selectedRecordId : result.bookingFormId,
                            } 
                        };
                        nagigateLightning.navigate(pageReference);
                    }else if(result && !result.bookingFormId){
                        helper.showToast(component,result.message,'Error','Error');
                    }
                    component.set("v.spinner", false);
                }
                else if(state === "ERROR"){
                    var errors = action.getError();
                    if (errors) {
                        helper.showToast(component,'Something went wrong, please try again','Error','Error'); 
                        if (errors[0] && errors[0].message) {
                            console.log(errors[0].message);
                        }
                    }
                }
                component.set("v.spinner", false); 
            });
            $A.enqueueAction(action);
        }
        component.set("v.selectedUnit", unitToView); 
    },
    
    /*Purpose - close view unit pop up*/
    closeViewDetails : function(component, event, helper) {
        component.set("v.modalContainer", false);
        if(component.get("v.selectedDropdown") == 'AddOptions' && event.getParam('isSaved')){
           //helper.getOptionsPrice(component, event, helper,component.get("v.selectedRecordId"));
           helper.fetchChildOppstoCart(component, event,helper);
        }
        if(component.get("v.selectedDropdown") == 'SendCredit'){
           helper.fetchChildOppstoCart(component, event,helper);
        }
    },

	onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); 
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        
        if(controllerValueKey != '--- None ---' && controllerValueKey){
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields && ListOfDependentFields.length > 0){
                component.set("v.bDisabledDependentFld" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.bDisabledDependentFld",true); 
                component.set("v.listDependingValues", ['--- None ---']);
            }  
        }else{
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld" , true);
        }
    },
    
    /*Purpose - add Sales Type to Deal*/
    addSalesTypes : function(component, event, helper) {
        component.set("v.spinner", true); 
        var childOpp = component.get("v.selectedUnit"); 
        var action = component.get("c.updateSalesType");
        action.setParams({
            'childOpps' : childOpp
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result){
                    helper.showToast(component,'Sale Type Added','Success','Success');
                    component.set("v.modalContainer", false);
                }else{
                    //helper.showToast(component,'Error','Error','Error');
                }
                component.set("v.spinner", false);
            }
            else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    helper.showToast(component,'Something went wrong, please try again','Error','Error'); 
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            }
            component.set("v.spinner", false); 
        });
        $A.enqueueAction(action);
    },
    
    /*Purpose - handle booking time expiry*/
    handleTimeExpiry : function(component, event, helper) {
        if(event.getParam('expired')){
            console.log('event callback'+JSON.stringify(event.getParam('expired')));
            var expiredUnit = event.getParam('expired');
            var allUnitsList = component.get("v.cartUnits");
            var selectedUnits= [];
        	var deselectedUnits= [];
            selectedUnits.push(expiredUnit);
            for(var i = 0; i < allUnitsList.length; i++) {
                if(allUnitsList[i].oppId == expiredUnit.oppId) {
                    allUnitsList.splice(i,1);
                }/*else{
                    deselectedUnits.push(allUnitsList[i]);
                    cartTotal = cartTotal + allUnitsList[i].cartTotalPrice;
                }*/
            }
            console.log('selectedUnits'+JSON.stringify(selectedUnits));
            if(selectedUnits.length>0){
                var action = component.get("c.removeChildOpps");
                action.setParams({
                    'removeCartUnits' : selectedUnits
                });
                action.setCallback(this,function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        if(result){
                            component.set("v.isCartAllSelected", false);
                            component.set("v.cartUnits", allUnitsList);
                            component.find("cartSelectAllId").set("v.value", false);
                            helper.setPagination(component, event, helper, component.get("v.cartUnits"));
                        }else{
                            //helper.showToast(component,'Error in Unit Removal','Error','Error');
                        }
                        component.set("v.spinner", false);
                    }
                    else if(state === "ERROR"){
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
                var qbEvent = $A.get("e.c:QuickBookEvent");
                qbEvent.setParams({
                    "refreshSearch" : true 
                });
                qbEvent.fire();
            }
        }
    },
})