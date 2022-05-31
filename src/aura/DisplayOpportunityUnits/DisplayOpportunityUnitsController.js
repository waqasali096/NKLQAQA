({
    //function to show the units records.
    init : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        helper.getOpportunityDetail(component, event, recordId);
        //Data-table columns.
        
        component.set('v.residentialCols', [
            {label: 'Name', fieldName: 'linkName', type: 'url',
             typeAttributes: {
                 label: { 
                     fieldName: 'Name' 
                 },
                 target : '_blank'
             }
            },
            {label: 'Location Code', fieldName: 'UnitLocation', type:'text'},
            {label: 'No. of Bedrooms', fieldName: 'UnitnoOfBedroom', type: 'text'},
            {label: 'Property Type', fieldName: 'UnitPropertyType', type: 'text'},
            {label: 'Unit type', fieldName: 'UnitType', type: 'text'},
            {label: 'Unit Status', fieldName: 'UnitStatus', type: 'Phone'},
            {label: 'Leaseable Area', fieldName: 'leaseableArea', type: 'text'},
            {label: 'Base Rent', fieldName: 'BaseRent', type: 'Email'},
        ]);
        component.set('v.commericalCols', [
            {label: 'Name', fieldName: 'linkName', type: 'url',
             typeAttributes: {
                 label: { 
                     fieldName: 'Name' 
                 },
                 target : '_blank'
             }
            },
            {label: 'Location Code', fieldName: 'UnitLocation', type:'text'},
            {label: 'Property Type', fieldName: 'UnitPropertyType', type: 'text'},
            {label: 'Unit type', fieldName: 'UnitType', type: 'text'},
            {label: 'Unit Status', fieldName: 'UnitStatus', type: 'Phone'},
            {label: 'Price Per Sq.ft', fieldName: 'pricePerSqft', type: 'text'},
            {label: 'Leaseable Area', fieldName: 'leaseableArea', type: 'text'},
            {label: 'Base Rent', fieldName: 'BaseRent', type: 'Email'},
        ]);
        component.set('v.commercialPriceChangeCols', [
            {label: 'Name', fieldName: 'linkName', type: 'url',
             typeAttributes: {
                 label: { 
                     fieldName: 'Name' 
                 },
                 target : '_blank'
             }
            },
            {label: 'Location Code', fieldName: 'UnitLocation', type:'text'},
            {label: 'Property Type', fieldName: 'UnitPropertyType', type: 'text'},
            {label: 'Unit type', fieldName: 'UnitType', type: 'text'},
            {label: 'Unit Status', fieldName: 'UnitStatus', type: 'Phone'},
            {label: 'Price Per Sq.ft', fieldName: 'pricePerSqft', type: 'text'},
            {label: 'Leaseable Area', fieldName: 'leaseableArea', type: 'text'},
            {label: 'Base Rent', fieldName: 'BaseRent', type: 'text'},
            {label: 'Revised Price Per Sq.ft', fieldName: 'revisedPricePerSqft', type: 'text'},
        ]);
            //Calling apex method to featch the units details.
            var action = component.get('c.getOpportunityUnitList');
            var pageSize = component.get("v.pageSize");
            action.setParams({
                recordId : component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
            //store state of response
                var state = response.getState();
                if (state === "SUCCESS") {
            
                    var rows = response.getReturnValue();
                    if(rows.length > 0){
                        component.set("v.totalRecordsCount",rows.length);
                        
                        component.set("v.totalPagesCount", Math.ceil(rows.length / pageSize)); 
                        component.set("v.showUnits",true);
                        component.set("v.startPage", 0);
                        component.set("v.endPage", pageSize - 1);
                        rows.forEach(function(record){
                            record.linkName = '/'+record.Unit__c;
                            //record.parentId = '/' + record.Unit__r.Id;
                        });
                    }
                if(component.get("v.displayResidential")){
                    for (var i = 0; i < rows.length; i++) {
                        var row = rows[i];
                        // checking if any unit related data in row
                        if(row.Unit__r){
                            row.UnitLocation = row.Unit__r.Unit_Code__c;
                            row.UnitnoOfBedroom = row.Unit__r.No_of_Bedrooms__c;
                            row.UnitPropertyType = row.Unit__r.Leasing_Property_Type__c;
                            row.UnitType = row.Unit__r.Unit_space_Type__c;
                            row.UnitStatus = row.Unit__r.Unit_Status__c;
                            row.leaseableArea = row.Unit__r.Total_Leasable_Area__c;
                            row.BaseRent = row.Base_Lease_Amount__c ;
                        }
                           
                    }
                    component.set('v.data',rows);
                }else if(component.get("v.displayCommerical")){
                    for (var i = 0; i < rows.length; i++) {
                        var row = rows[i];
                        // checking if any unit related data in row
                        if(row.Unit__r){
                            row.UnitLocation = row.Unit__r.Unit_Code__c;
                            row.UnitPropertyType = row.Unit__r.Leasing_Property_Type__c;
                            row.UnitType = row.Unit__r.Unit_space_Type__c;
                            row.UnitStatus = row.Unit__r.Unit_Status__c;
                            row.pricePerSqft = row.Unit__r.Price_Per_SQ_FT__c;
                            row.leaseableArea = row.Unit__r.Total_Leasable_Area__c;
                            row.BaseRent = row.Base_Lease_Amount__c ;
                        }

                    }
                    console.log('rows :',rows);
                    component.set('v.commericalData',rows);   
                }else if(component.get("v.displayCommercialSpecial")){
                    for (var i = 0; i < rows.length; i++) {
                        var row = rows[i];
                        // checking if any unit related data in row
                        if(row.Unit__r){
                            row.UnitLocation = row.Unit__r.Unit_Code__c;
                            row.UnitPropertyType = row.Unit__r.Leasing_Property_Type__c;
                            row.UnitType = row.Unit__r.Unit_space_Type__c;
                            row.UnitStatus = row.Unit__r.Unit_Status__c;
                            row.pricePerSqft = row.Unit__r.Price_Per_SQ_FT__c;
                            row.leaseableArea = row.Unit__r.Total_Leasable_Area__c;
                            row.BaseRent = row.Base_Lease_Amount__c ;
                        }
                        if(row.Opportunity__r){
                            row.revisedPricePerSqft = row.Opportunity__r.Revised_Price_per_Sq_ft__c;
                        }

                    }
                    console.log('rows :',rows);
                    component.set('v.commericalData',rows);   
                }
            //Storing the reponse from server side to an attribute.
           /* component.set("v.PaginationList",rows);
            var paginationrecords = [];
            for ( var i=0; i< pageSize; i++ ) {
                if ( rows.length> i )
                    paginationrecords.push(rows[i]);    
            }
            component.set('v.data', paginationrecords); */  
                   
        }
    });
    $A.enqueueAction(action);
    },
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.PaginationList");
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

    
    
    //Function to fetch recordIds of each row and to show the count.
    updateSelectedText: function (component, event) {
        //Get sleceted Checkbox rows.
        var selectedRows = event.getParam('selectedRows');
        
        //Store a count in an attribute.
        component.set('v.selectedRowsCount', selectedRows.length);
        
        //Stored in var to display count in console.
        //You can skip next two lines.
        var slectCount =selectedRows.length;
        
        //Created var to store record id's for selected checkboxes. 
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            
            setRows.push(selectedRows[i]);
            
        }
        //Adding slelected recordIds to an attribute.
        
        component.set("v.selectedLeads", setRows);
        
        
        //Added this condition to show the button "Delete Leads".
        //If checkbox is selected then only it will show else no.
        if(slectCount>0){
            component.set('v.ButtonShow', true);
        }else{
            component.set('v.ButtonShow', false);
        }
    },
        
        //This fucntion to handle a delete functionality.
        handleClick : function(component, event, helper){
            //Created var that store the recordIds of selected rows.
            
            var records = component.get("v.selectedLeads");
            
            
            //Calling helper to perform delete action.
            helper.deltingCheckboxAccounts(component, event, records);
        },
            
            // function to handle the Modal Popup window.
            handleConfirmDialog : function(component, event, helper) {
                component.set('v.showDeleteBox', true);
            },
                
                //Function to handle Cancel Popup.
                handleConfirmDialogCancel : function(component, event, helper) {
                    console.log('Cancel');
                    component.set('v.showDeleteBox', false);
                },
})