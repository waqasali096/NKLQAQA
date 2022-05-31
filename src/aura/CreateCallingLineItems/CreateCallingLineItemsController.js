({
	 fetchCallingListItems : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Amount', fieldName: 'Amount__c', type: 'currency'},
            {label: 'Due Date', fieldName: 'Due_Date__c', type: 'date'},
            {label: 'Status', fieldName: 'Payment_Status__c', type: 'Text'}
            ]);
        var action = component.get("c.getAllPaymentMilestones");
        action.setParams({
            "clID":component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.paymentMilestoneList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSelect : function(cmp, evt,helper) {
        var selectedRows = evt.getParam('selectedRows');
        cmp.set("v.selectedMilestones",selectedRows);
        //(JSON.stringify(cmp.get('v.selectedMilestones')));
        var selectedMilestoneIds =[];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            selectedMilestoneIds.push(selectedRows[i].Id);
        }
        //alert('selectedMilestoneIds are '+ selectedMilestoneIds);
        cmp.set('v.selectedMilestoneIds' , selectedMilestoneIds) ; 
       
    },
    
    saveCallingItems: function(component, evt,helper) {
       var action = component.get("c.saveCLI");
        action.setParams({
            "clID":component.get('v.recordId'),
            "pms" : component.get("v.selectedMilestones")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToastMessage(
                    "Success!",
                    "Line Items are created successfully !",
                    "Success"
                );
                $A.get("e.force:refreshView").fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    cancel: function(component, evt,helper) {
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
    }
})