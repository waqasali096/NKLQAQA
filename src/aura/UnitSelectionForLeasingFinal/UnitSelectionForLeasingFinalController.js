({
    doInit : function(component, event, helper) {
        
        helper.unitSearchComponentVisibility(component,event,helper);
        // component.set("v.allSelected",true);
        component.set('v.commercialColumns', [
            {label: 'Location Code', fieldName: 'Unit_Code__c',sortable: true, type: 'text'},
            {label: 'Project', fieldName: 'ProjectName',sortable: true, type: 'text'},
            {label: 'Building-Floor', fieldName: 'BuildingName',sortable: true, type: 'text'},
            {label: 'Property Type', fieldName: 'Leasing_Property_Type__c',sortable: true, type: 'text'},
            {label: 'Unit Type', fieldName: 'Unit_space_Type__c',sortable: true, type: 'text'},
            {label: 'Price Per Sq.ft', fieldName: 'Price_Per_SQ_FT__c',sortable: true, type: 'text'},
            {label: 'Leasable Area', fieldName: 'Total_Leasable_Area__c',sortable: true, type: 'text'},
            {label: 'Base Rent', fieldName: 'Base_Rent__c',sortable: true, type: 'text'},
            // {label: 'Assignable Area', fieldName: 'Assignable_Area__c',sortable: true, type: 'text'},
        ]);     
            
            component.set('v.residentialColumns', [
            {label: 'Location Code', fieldName: 'Unit_Code__c',sortable: true, type: 'text'},
            {label: 'Project', fieldName: 'ProjectName',sortable: true, type: 'text'},
            {label: 'Building-Floor', fieldName: 'BuildingName',sortable: true, type: 'text'},
            {label: 'No Of Bedrooms', fieldName: 'No_of_Bedrooms__c',sortable: true, type: 'text'},
            {label: 'Property Type', fieldName: 'Leasing_Property_Type__c',sortable: true, type: 'text'},
            {label: 'Unit Type', fieldName: 'Unit_space_Type__c',sortable: true, type: 'text'},
            {label: 'Leasable Area', fieldName: 'Total_Leasable_Area__c',sortable: true, type: 'text'},
            {label: 'Base Rent', fieldName: 'Base_Rent__c',sortable: true, type: 'text'},
            // {label: 'Assignable Area', fieldName: 'Assignable_Area__c',sortable: true, type: 'text'},
        ]);     
        //component.set("v.isSpinner", true);
        
        helper.getFilterMethods(component,event,helper);   
        helper.propertyCheckOnCustomer(component,event,helper);
        //component.set("v.isSpinner",false);
    },
    navigateToRecord: function(component, event, helper) {
        var recordId = event.target.dataset.caseid;
        window.open('/' + recordId);  
    },
    handleProjectOnChange : function(component, event, helper) {
        //component.set("v.isSpinner", true);
        var project = component.get("v.selectedProject");
        // alert(component.get("v.selectedProject"));
        var action = component.get("c.fetchCluster");
        action.setParams({
            "project": project
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            var refreshBuilding = component.get('c.handleClusterOnChange');
            $A.enqueueAction(refreshBuilding);
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
        var cluster = component.get("v.selectedCluster");
        var project = component.get("v.selectedProject");
        var action = component.get("c.fetchBuilding");
        action.setParams({
            "cluster": cluster,
            "project" : project
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
                //component.set("v.isSpinner", false);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    // Method to send parameters to apex controller to perform search for unit
    search : function(component, event, helper) {
        var selUnit = [];
        component.set("v.selectedUnits",selUnit);
        component.set("v.selectedCount",0);
        component.set("v.currentPage", 1);
        // First check that atleast mandatory filters are selected
        var projectVal = component.get("v.selectedProject");
        console.log(component.get('v.maxPlotArea'));
        /*if(projectVal == '' || projectVal == null || projectVal == undefined){
            helper.showErrorMsg(component,event,'Please select a Project');            
        }*/
        //else{
        // call the helper method for the search
        helper.callSearch(component,event);
        //}
    },
    
    //Method to add selected property against the opportunity
    addUnit: function(component,event,helper){
        component.set("v.currentPage", 1);
        
        var unitlst = component.get("v.unitList");
        var selectedUnits = component.get("v.selectedUnits");
        if(selectedUnits.length == 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Success Message',
                message:'Please select the unit before proceeding further!',
                type: 'error'
            });
            toastEvent.fire();
            // $A.get('e.force:refreshView').fire();
        } else {
            
            var propertyCheck = component.get("v.propertyCheck");
            var blockUnitSelection = component.get("v.blockUnitSelection");
            var Flag = false;
            for(let i = 0;i < unitlst.length;i++){
                var rec = unitlst[i];
                if(selectedUnits.includes(rec.unit.Id)){
                    
                    if(rec.activeFlag){
                        Flag = true;
                        break;
                    }
                    
                }
            }
            if(blockUnitSelection){
                helper.showErrorMsg(component,event,'This customer already owns more than 1 active unit.');
            }else if(propertyCheck){
                if(!component.get("v.opptyObj").Unit_Selection_Sent_for_Approval__c && component.get("v.opptyObj").Lease_Renewal_Approval_Status__c === 'Draft'){
                    helper.submitForApproval(component,event,helper);
                }else if(component.get("v.opptyObj").Unit_Selection_Sent_for_Approval__c && component.get("v.opptyObj").Lease_Renewal_Approval_Status__c === 'Submitted for approval'){ 
                    helper.showWarnMsg(component,event,'Request is under approval');
                    
                }else if(component.get("v.opptyObj").Unit_Selection_Sent_for_Approval__c && component.get("v.opptyObj").Lease_Renewal_Approval_Status__c === 'Rejected'){ 
                    helper.showWarnMsg(component,event,'Request is Rejected, You cannot proceed further');
                    //component.set("v.isSpinner", false); swapnil
                }
            }else if(Flag){
                
                helper.showErrorMsg(component,event,'Unit has an active flag.');
            }else if(!Flag && !propertyCheck){
                component.set("v.disableButton",true);
                helper.addUnits(component,event,helper);   
                helper.getFilterMethods(component,event,helper); 
            }
            
        }
        
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
        component.set("v.selectedPropertyType","");
        component.set("v.minPrice","");
        component.set("v.maxPrice","");
        component.set("v.selectedPropertyView","");
        component.set("v.selectedUnitType","");
        component.set("v.selectedBedroom","");
        component.set("v.selectedCount",0);
        component.set("v.currentPage", 1);
        component.set("v.SearchLocationCode","");
        var selUnit = [];
        component.set("v.selectedUnits",selUnit);
        helper.getFilterMethods(component,event,helper);   
    },
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.unitList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        //alert(whichBtn);
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            //alert(JSON.stringify(sObjectList));
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
        var selectedUnit = component.get("v.selectedUnits");        
        var getSelectedNumber = component.get("v.selectedCount");
        var unitlst = component.get("v.unitList");var unitlstdata = [];
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        
        //alert(end);
        var pageSize = component.get("v.pageSize");
        //var emirate = component.get("v.Emirate");
        var isPerson = component.get("v.isPerson");
        if(isPerson){    //if(!$A.util.isUndefinedOrNull(emirate) && emirate != null && emirate != undefined && emirate != ''){
            component.set("v.allSelected",true); 
            //Commented by karishma
            /* if(selectedHeaderCheck == true){ 
            for(let i = 0;i < unitlst.length;i++){
                var rec = unitlst[i];
                rec.propFlag = true;
                unitlstdata.push(rec);
                getSelectedNumber++;
                //unitlst[0].unit.isChecked = true;
                //unitlst[0].propFlag = false;
                //selectedUnit.push(unitlst[0].unit.Id);
            }
            component.set("v.isAllSelected",true);
            component.set("v.selectedUnits",selectedUnit);
        } else {
            getSelectedNumber--;
        selectedUnit = [];
            for(let i = 0;i < unitlst.length;i++){
                var rec = unitlst[i];
                rec.propFlag = false;
                unitlst[0].unit.isChecked = false;
                unitlstdata.push(rec);
            }
            component.set("v.selectedUnit",selectedUnit);
            component.set("v.isAllSelected",false);
        }*/
    } else {
        if(selectedHeaderCheck == true){
            getSelectedNumber = 0; 
            for(let i = 0;i < unitlst.length;i++){
                var rec = unitlst[i];
                //rec.propFlag = true;
                rec.unit.isChecked = true;
                unitlstdata.push(rec);
                getSelectedNumber = getSelectedNumber + 1;
                selectedUnit.push(rec.unit.Id);
            }
            component.set("v.isAllSelected",true);
            component.set("v.selectedUnits",selectedUnit);
        } else {
            getSelectedNumber = 0;
            for(let i = 0;i < unitlst.length;i++){
                var rec = unitlst[i];
                //rec.propFlag = true;
                rec.unit.isChecked = false;
                unitlstdata.push(rec);
                //getSelectedNumber--;
                selectedUnit = [];
            }
            component.set("v.isAllSelected",false);
            component.set("v.selectedUnits",selectedUnit);
        }
        
    }
           component.set("v.selectedCount",getSelectedNumber);
           component.set("v.unitList",unitlstdata);
           //alert(JSON.stringify(unitlstdata));
           var paginationrecords = [];
           var currentpage =  component.get("v.currentPage");
           var initvar = (currentpage-1)*pageSize;
           //alert(initvar);
           for (var i=initvar; i< pageSize*currentpage; i++ ) {
               //alert(i);
               if (component.get("v.unitList").length> i)
                   paginationrecords.push(component.get("v.unitList")[i]);    
           }
           component.set("v.PaginationList",paginationrecords);
           
           
       },     
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.checked");
        var selectedUnit = component.get("v.selectedUnits");        
        var getSelectedNumber = component.get("v.selectedCount");
        var unitlst = component.get("v.unitList");var unitlstdata = [];
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var isPerson = component.get("v.isPerson");
        //alert(end);
        var pageSize = component.get("v.pageSize");
        if (selectedRec == true) {
            
            var recordId = event.target.dataset.caseid;
            var flag = event.getSource().get("v.name");
            
            if(!flag){
                selectedUnit.push(recordId);
                getSelectedNumber = getSelectedNumber + 1;
                //var emirate = component.get("v.Emirate");
                
                //alert(emirate);
                if(isPerson){                //(!$A.util.isUndefinedOrNull(emirate) && emirate != null && emirate != undefined && emirate != ''){
                    component.set("v.allSelected",true);    
                    for(let i = 0;i < unitlst.length;i++){
                        var rec = unitlst[i];
                        if(rec.unit.Id != recordId){
                            rec.propFlag = true;
                            unitlstdata.push(rec);
                        }
                    }
                    var paginationrecords = [];
                    var currentpage =  component.get("v.currentPage");
                    var initvar = (currentpage-1)*pageSize;
                    for (var i=initvar; i< pageSize*currentpage; i++ ) {
                        if (component.get("v.unitList").length> i)
                            paginationrecords.push(component.get("v.unitList")[i]);    
                    }
                    component.set("v.PaginationList",paginationrecords);
                } 
            }
            else{
                for(let i = 0;i < unitlst.length;i++){
                    var rec = unitlst[i];
                    if(rec.unit.Id == recordId){
                        
                        rec.unit.isChecked = false;
                        
                    }
                }
                var paginationrecords = [];
                var currentpage =  component.get("v.currentPage");
                var initvar = (currentpage-1)*pageSize;
                for (var i=initvar; i< pageSize*currentpage; i++ ) {
                    if (component.get("v.unitList").length> i)
                        paginationrecords.push(component.get("v.unitList")[i]);    
                }
                component.set("v.PaginationList",paginationrecords);
                helper.showErrorMsg(component, event, 'Unit has an active flag');
            }
            
        } else {
            var selectedUnit = [];
            component.set("v.isAllSelected",false);
            if(isPerson){ 
                component.set("v.allSelected",true);
            }else{
                component.set("v.allSelected",false);
            }
            var recordId = event.target.dataset.caseid;
            getSelectedNumber = getSelectedNumber - 1;;
            for(let i = 0;i< component.get("v.selectedUnits").length;i++){
                if(recordId != component.get("v.selectedUnits")[i]){
                    selectedUnit.push(component.get("v.selectedUnits")[i]); 
                }
            }
            component.find("selectAllId").set("v.value", false);
            if(component.get("v.Emirate") != null || component.get("v.Emirate") != 'undefined'){
                for(let i = 0;i < unitlst.length;i++){
                    var rec = unitlst[i];
                    //if(rec.unit.Id != recordId){
                    rec.propFlag = false;
                    unitlstdata.push(rec);
                    // }
                }
                //alert(JSON.stringify(unitlstdata));
                
                var paginationrecords = [];
                var currentpage =  component.get("v.currentPage");
                var initvar = (currentpage-1)*pageSize;
                for ( var i=initvar; i< pageSize*currentpage; i++ ) {
                    if ( component.get("v.unitList").length> i )
                        paginationrecords.push(component.get("v.unitList")[i]);    
                }
                component.set("v.PaginationList",paginationrecords);
            }
            
        }
        component.set("v.selectedUnits",selectedUnit);
        
        //alert(component.get("v.selectedUnits"));
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
    },
    
    
    handleRefresh : function(cmp, event,helper) {
        var message = event.getParam("message");
        
        // set the handler attributes based on event data
        cmp.set("v.messageFromEvent", message);
        if(message === 'Parent Refresh'){
            console.log('Message :',message);
            if(cmp.get("v.isAllSelected")){
                cmp.set("v.isAllSelected",false);
            }
            helper.callSearch(cmp,event,helper);
            //var self = this;
            // var action = cmp.get('c.clear');
            // $A.enqueueAction(action);
        }
    },
    showSpinner: function(component, event, helper) {
        component.set("v.isSpinner", true); 
    },
    hideSpinner : function(component,event,helper){
        component.set("v.isSpinner", false);
    }
    
})