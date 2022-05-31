({
    //method to set Search Existing Accounts
    getAmendments : function(component, helper) {
        var action = component.get("c.getScheduleAmendments");
        action.setParams({
            'oppId': component.get("v.recordId"),
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                console.log('amendments result'+JSON.stringify(result));
                if(result && result!= ''){
                    component.set('v.parentWrapper',result); 
                    component.set("v.selectedCount" , 0);
                    var installmentList = result.resultWrapperList;
                    if(result.resultWrapperList != undefined && result.resultWrapperList != null ){
                        component.set("v.totalRecordsCount", result.resultWrapperList.length);
                    }
                    var flag = false;
                    for(var i= 0;i<installmentList.length;i++){
                        if(installmentList[i].paymentMode == 'Bank Transfer' || installmentList[i].paymentMode == 'Credit Card'){
                            component.set('v.isBankTransfer',true);
                            installmentList[i].isTransactionId = false;
                            flag = true;
                            
                        }else{
                            if(!flag){
                                component.set('v.isBankTransfer',false);
                            }
                            installmentList[i].isTransactionId = true;
                        }
                    }
                    for(var i= 0;i<installmentList.length;i++){
                        if(installmentList[i].paymentMode == 'Cheque'){
                            component.set('v.isChequeMode',true);
                            break;
                        }else{
                            component.set('v.isChequeMode',false);
                        }
                    } 
                    
                    component.set('v.isTable',true); 
                }else if( result==''){
                    console.log('Error in Apex call/no result1');
                }
            }else if(state === "ERROR"){
                var errors = action.getError();
                if(errors){
                    this.showErrorMsg(component,event,'Something went wrong, please try again.');  
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
        });
        $A.enqueueAction(action);
    },
    
    //method to get Comments picklist
    getComments : function(component, helper) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            'obj' : 'Schedule_Amendment__c',
            'fld' : 'Comment__c'
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                //console.log('commentsMap'+JSON.stringify(result));
                var commentsMap = [];
                var i=0;
                for(var key in result){
                    commentsMap.push({key: key, value: result[key]});
                    i++;                 
                }
                
                if(result && result!= ''){
                    component.set('v.commentMap',commentsMap); 
                }else if( result==''){
                    console.log('Error in Apex call');
                }
            }else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    this.showErrorMsg(component,event,'Something went wrong, please try again.');  
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
        });
        $A.enqueueAction(action);
    },
    
    //method to get method picklist
    getMethods : function(component, helper) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            'obj' : 'Schedule_Amendment__c',
            'fld' : 'Method__c'
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                //console.log('methodsMap'+JSON.stringify(result));
                var methodsMap = [];
                var i=0;
                for(var key in result){
                    methodsMap.push({key: key, value: result[key]});
                    i++;                 
                }
                if(result && result!= ''){
                    component.set('v.methodMap',methodsMap); 
                }else if( result==''){
                    console.log('Error in Apex call');
                }
            }else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    this.showErrorMsg(component,event,'Something went wrong, please try again.');  
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
            //console.log('methodsMap'+JSON.stringify(component.get('v.methodMap')));
        });
        $A.enqueueAction(action);
    },
    
    //method to get method picklist
    getReceiptMethods : function(component, helper) {
        //var amendmentsList = component.get('v.amendmentsList');
        //console.log('amendmentsList 2'+JSON.stringify(amendmentsList));
        var buUnits = component.get('v.businessUnit');
        console.log('buUnits 2'+buUnits);
        var action = component.get("c.getReceiptMethods");
        action.setParams({
            'businessUnit' : buUnits,
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                console.log('result'+JSON.stringify(result));
                if(result && result!= ''){
                    component.set('v.receiptMethods',result); 
                }else if( result==''){
                    console.log('Error in Apex call');
                }
            }else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    this.showErrorMsg(component,event,'Something went wrong, please try again.');  
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
            //console.log('receiptMethods'+JSON.stringify(component.get('v.receiptMethods')));
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            type: type
        });
        toastEvent.fire();
    },
    validateAmountHelper : function(component,event,helper) {
        var whichOne = event.getSource().get("v.name");
        var newAmount = event.getSource().get("v.value");
        var resultList = component.get('v.parentWrapper.resultWrapperList');
        var rejectren = component.find("rejectrn");
        var errorDiv = component.find("errorCapture");
        var isArray = Array.isArray(rejectren);
        if(newAmount != resultList[whichOne].proposedAmount){
            
            if(isArray){
                $A.util.removeClass(errorDiv[whichOne],"slds-hide");
                $A.util.addClass(errorDiv[whichOne],"slds-show");
                $A.util.addClass(rejectren[whichOne], 'slds-has-error');//add red border
            }else{
                $A.util.removeClass(errorDiv,"slds-hide");
                $A.util.addClass(errorDiv,"slds-show");
                $A.util.addClass(rejectren, 'slds-has-error');//add red border 
            }
            // component.set('v.isError',true);
        }
        else{
            if(isArray){
                $A.util.removeClass(errorDiv[whichOne],"slds-show");
                $A.util.addClass(errorDiv[whichOne],"slds-hide");
                $A.util.removeClass(rejectren[whichOne], "slds-has-error");
            }else{
                $A.util.removeClass(errorDiv,"slds-show");
                $A.util.addClass(errorDiv,"slds-hide");
                $A.util.removeClass(rejectren, "slds-has-error");
            }
            //   component.set('v.isError',false);
            // remove red border
            // $A.util.addClass(rejectren[whichOne], "hide-error-message"); 
        }
    }, 
    handleConfirmDialog : function(component, event, helper) {
        component.set('v.showConfirmBox', true);
    },
    //method to get save receipts
    handleSubmit : function(component,helper) {
        var totalAmount = 0.00;
        var installmentList = component.get('v.parentWrapper.resultWrapperList');
        
        var action = component.get("c.createScheduleAmendments");
        var selectedRecords = [];
        var parentWrapper =  component.get('v.parentWrapper');
        var installList = component.get('v.parentWrapper.resultWrapperList')
        for (var i = 0; i < installList.length; i++) {
            if (installList[i].isChecked) {
                selectedRecords.push(installList[i]);
            }
        }
        parentWrapper.resultWrapperList = selectedRecords;
        action.setParams({ parentWrapper :  parentWrapper,
                                  isEdit : true,
                                 fromCashier : true} );
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                if(result){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Receipts created successfully',
                        type: 'success'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }else{
                    helper.showToast(component,'Error in Receipt Creation','Error','Error');
                    console.log('Error in receipt creation');
                }
            }else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    helper.showToast(component,'Error in Receipt Creation','Error','Error');
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
        });
        $A.enqueueAction(action);
        
    },
    
    
})