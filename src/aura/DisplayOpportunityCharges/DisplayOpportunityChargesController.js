({
    //function to show the units records.
    init : function(component, event, helper) {
        //Data-table columns.
        component.set('v.columns', [
            {label: 'Name', fieldName: 'linkName',type: 'url', 
             typeAttributes:{label: { fieldName: 'Name' }, target: '_blank'}}, 
            {label: 'Fixed Amount', fieldName: 'FixedAmount', type: 'Number'},
            {label: '% Amount', fieldName: 'Amount', type: 'Number'},
            
        ]);
            /*
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
                            record.linkName = '/'+record.Id;
                            //record.parentId = '/' + record.Unit__r.Id;
                        });
                    }
                    
                for (var i = 0; i < rows.length; i++) {
                var row = rows[i];
                // checking if any unit related data in row
                if(row.Unit__r){
                    row.UnitLocation = row.Unit__r.Unit_Code__c;
                    row.UnitStatus = row.Unit__r.Unit_Status__c;
                    row.BaseRent = row.Unit__r.Base_Rent__c;
                }
            }
            //Storing the reponse from server side to an attribute.
           /* component.set("v.PaginationList",rows);
            var paginationrecords = [];
            for ( var i=0; i< pageSize; i++ ) {
                if ( rows.length> i )
                    paginationrecords.push(rows[i]);    
            }
            component.set('v.data', paginationrecords); */
            /*
            component.set('v.data',rows);          
        }
    });
    $A.enqueueAction(action);
*/
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
        var setRowIndex = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            selectedRows[i].isSelect = !selectedRows[i].isSelect;
            setRows.push(selectedRows[i]);
            
            var rows = component.get("v.data");
            var rowIndex = rows.indexOf(selectedRows[i]);
            setRowIndex.push(rowIndex);
            
        }
        //Adding slelected recordIds to an attribute.
        
        component.set("v.selectedRecord", setRows);
        component.set("v.selectedRecordIndex", setRowIndex);
        
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
            component.set('v.showDeleteBox', false);
            var records = component.get("v.selectedRecord");
            var recordIndexes = component.get("v.selectedRecordIndex");
            
            
            //Calling helper to perform delete action.
            helper.deltingCheckboxAccounts(component, event, records, recordIndexes);
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