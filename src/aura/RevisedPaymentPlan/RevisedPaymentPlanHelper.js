({
    getMilestonePoint: function(component, event) {  
        var action = component.get("c.getMilestonePoint");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var mileMap = [];
                for(var key in result){
                    mileMap.push({key: key, value: result[key]});
                }
                component.set("v.milestonesMap", mileMap);
            }
        });
        $A.enqueueAction(action);
    },
    getInstallments: function(component, event) {  
        var action = component.get("c.getInstallments");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var insMap = [];
                for(var key in result){
                    insMap.push({key: key, value: result[key]});
                }
                component.set("v.installmentMap", insMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    calculateTotalPercentage:function(component, event){
        var reqPayList = component.get('v.requestedPaymentMilestones'); 
        var totalPrcnt = 0;
        for(var i=0;i<reqPayList.length;i++){
            totalPrcnt += parseInt(reqPayList[i].amountPercent); 
        } 
        console.log('totalPrcnt is '+ totalPrcnt);
        component.set('v.totalPaymentPercent ',totalPrcnt );
    },
    
    showToastMessage : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" :type
        });
        toastEvent.fire();
    },
    
    callsaveRequestedMilestones :function(component,event){
        component.set("v.isSpinner", true);
        console.log('requestedPaymentMilestones is '+ JSON.stringify(component.get("v.requestedPaymentMilestones")));
        var jsStr = JSON.stringify(component.get("v.requestedPaymentMilestones"));
        var jsStrOriginal = JSON.stringify(component.get("v.originalPaymentMilestones"));
        jsStr = jsStr.replaceAll('"amount"','"Amount__c"').replaceAll('amountPercent','Amount_Percentage__c').replaceAll('dueInDays','Due_In_Days__c').replaceAll('dueDate','Due_Date__c').replaceAll('milestone','Milestone_Trigger_Point__c').replaceAll('installment','Installment__c');
        jsStrOriginal = jsStrOriginal.replaceAll('"amount"','"Amount__c"').replaceAll('amountPercent','Amount_Percentage__c').replaceAll('dueInDays','Due_In_Days__c').replaceAll('dueDate','Due_Date__c').replaceAll('milestone','Milestone_Trigger_Point__c').replaceAll('installment','Installment__c');
        var createdReqPayMIlestones =  JSON.parse(jsStr); 
        var originalListPM =  JSON.parse(jsStrOriginal);
        console.log(createdReqPayMIlestones);
        var action = component.get("c.saveRequestedMilestones");
        console.log('save action called');
        action.setParams({ 
            "oppId" : component.get("v.recordId"),
            "originalMilestoneList" : originalListPM,
            "requestedPaymentMilestoneList" : createdReqPayMIlestones,
            "deleteList" : component.get("v.deleteList"),
            "documentId" : component.get("v.documentId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result is ',result);
                if(result.pmUpdate){
                    this.showToastMessage('Success!','Requested Payment Plans are created','Success');
                    $A.get('e.force:refreshView').fire();
            		$A.get("e.force:closeQuickAction").fire();
                }
                else{
                    this.showToastMessage('Error!','There is an error.Please contact admin ','Error');
                }
            }else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    this.showToastMessage('Error!','Something went wrong, please try again.','Error');
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
            component.set("v.isSpinner", false);
        });
        $A.enqueueAction(action); 
    }, 
})