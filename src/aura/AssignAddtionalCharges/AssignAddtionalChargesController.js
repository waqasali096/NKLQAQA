({
    doInit : function(component, event, helper) {

           var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'View', name: 'view' } ];
        var columns = [{label: 'Name', fieldName: 'Name', type: 'text'},
                       
                       {label: 'Project', fieldName: 'ProjectName', type: 'text'},
                       {label: 'Payable Amount', fieldName: 'Payable_Amount__c', type: 'text'},
                        {label: 'VAT %', fieldName: 'VAT__c', type: 'text'},
                      {label: 'VAT Amount', fieldName: 'VAT_Amount__c', type: 'text'},
                       {label: 'Total Amount', fieldName: 'Amount__c', type: 'text'},
                      ];
                       
                       component.set("v.columns",columns); 
                var columnsdata = [
                       {label:  'Name', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
                       {label: 'VAT Amount', fieldName: 'VAT_Amount__c', type: 'text'},
                       {label: 'VAT', fieldName: 'VAT__c', type: 'text'},
                       //{label: 'VAT Amount', fieldName: 'VAT__c', type: 'text'},
                       {label: 'Final Amount', fieldName: 'Amount__c', type: 'text'},
                       {label: 'Payable Amount', fieldName: 'Payable_Amount__c'},
                       { type: 'action', typeAttributes: { rowActions: actions }}];
        component.set("v.columnsList",columns);
        helper.fetchRecords(component,event,helper);
   },
      handleSelectUnit : function(component, event,helper) {
                       var selectedRows = event.getParam('selectedRows'); 
                       var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i]);
        }
        component.set("v.selectedCharges", setRows);
        
    },
    callKeyUp : function(component,event,helper){
       if($A.util.isUndefinedOrNull( component.get("v.searchText"))){
           var nData = [];
           component.set("v.datalist",nData);
       } else {
        if ( event.keyCode == 13 )  {
            component.set("v.loaded",false);
        var action = component.get("c.fetchAdditionalCharges");
        action.setParams({recordId : component.get("v.recordId"),
                          searchString : component.get("v.searchText")});
        action.setCallback(this,function(response) {
            var projName = [];
            var result = response.getReturnValue();
          //  alert(response.getReturnValue().length);
            if(result.length > 0){
            for(var i =0 ; i<response.getReturnValue().length;i++){
                var proj = response.getReturnValue()[i];
                if(proj.Project__c != null){
                    proj.ProjectName = proj.Project__r.Name;
                }
                projName.push(proj);
            }
            component.set("v.datalist",projName);
             component.set("v.loaded",true);
            component.set("v.ShowDatatable",true);
            } else {
               component.set("v.loaded",true);
                component.set("v.ShowDatatable",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "No Additional Charges records found!",
                    "type" : "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);    
        } 
       }
    },
    save : function(component,event,helper){
         component.set("v.loaded",false);
        var action = component.get("c.saveRecord");
        action.setParams({recordId : component.get("v.recordId"),
                          addList : component.get("v.selectedCharges")});
        action.setCallback(this,function(response) {
            var result = response.getReturnValue();
             var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: result,
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
            helper.fetchRecords(component,event,helper);
            $A.get('e.force:refreshView').fire(); 
              component.set("v.loaded",true);
               component.set("v.ShowDatatable",false);
        });
          $A.enqueueAction(action); 
    },
    closeModel : function(component,event,helper){
        
    },
    onSave : function(component,event,helper){
         var updatedRecords = component.find("dataTableID").get("v.draftValues");  
       // alert(JSON.stringify(updatedRecords));
         var id = updatedRecords[0].id;
         var rowId = id.split("-")[1];
        var datalist = component.get("v.datalist");
        var updateList = [];
        for(var i = 0;i<datalist.length;i++){
            var data = datalist[i];
            if(i == rowId){
                data.Amount__c = updatedRecords[0].Amount__c;
            }
            updateList.push(data);
        }
        component.set("v.datalist",updateList);
       // alert(JSON.stringify(component.get("v.datalist")));
    },
      handleRowAction: function ( cmp, event, helper ) {
       
        var action = event.getParam('action');
        var row = event.getParam('row');
        var recId = row.Id;

        switch ( action.name ) {
            case 'edit':
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": recId
                });
                editRecordEvent.fire();
                break;
            case 'view':
                var viewRecordEvent = $A.get("e.force:navigateToURL");
                viewRecordEvent.setParams({
                    "url": "/" + recId
                });
                viewRecordEvent.fire();
                break;
        }
    }
})