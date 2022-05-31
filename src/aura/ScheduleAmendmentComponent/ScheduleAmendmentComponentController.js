({
    doInit : function(component, event, helper) {
		// component.set('v.isSpinner',true);       
        var action = component.get("c.getInstallments");
        action.setParams({ oppId : component.get('v.recordId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
             //   component.set("v.isSpinner",false);
               
                var result = response.getReturnValue();
                component.set('v.parentWrapper',result);
                component.set('v.installmentList',result.resultWrapperList); 
                component.set('v.isEdit',result.isEdit);
                //component.set('v.totalAmount',result.totalAmount);
                component.set('v.totalAmount', Math.round(result.totalAmount).toFixed(2));
                component.set('v.thresDays',result.proposedThresholdDays);
                
                var bankList = [];
                var conts = result.bankMap;
                for(var key in conts){
                    bankList.push({label:conts[key], value:key});
                }
                component.set('v.bankList',bankList);
                var paymentoptions = [];
                var conts = result.paymentOptions;
                for(var key in conts){
                    paymentoptions.push({label:conts[key], value:key});
                }
                component.set('v.paymentOptions',paymentoptions);
                var today = new Date();
                var dd = String(today.getDate()).padStart(2, '0');
                var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
                var yyyy = today.getFullYear();
                today = mm + '/' + dd + '/' + yyyy;
                component.set('v.todaysDate',today);
                 component.set('v.isTable',true);
                var installmentList = result.resultWrapperList;
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
            component.set('v.installmentList',  installmentList);   
                                 
             
            }
            else{
                alert('Error...');
            }
        });
        $A.enqueueAction(action);
    },
    onDateChange : function(component, event, helper) {
        
        
    },
    doSplit : function(component, event, helper) {
        
        var installmentList = [];
        var predefinedList = component.get('v.installmentList');
        var diffList = [ ...predefinedList];
        var selectedId = event.getSource().get("v.value");
        for(var i=0 ; i<predefinedList.length ; i++){
            
            if(predefinedList[i].recordId+i == selectedId){
                predefinedList[i].payTermType = predefinedList[i].paymentTermType;
                installmentList.push(predefinedList[i]);
                var replicaObj =new Object();
                replicaObj.paymentTermType = predefinedList[i].paymentTermType;
                replicaObj.itemDescription = predefinedList[i].itemDescription;
                replicaObj.dueDate = predefinedList[i].dueDate;
                //replicaObj.vatAmount = predefinedList[i].vatAmount;
                //replicaObj.totalAmount = predefinedList[i].totalAmount;
                replicaObj.proposedAmount = predefinedList[i].proposedAmount;
                replicaObj.proposedDate = predefinedList[i].proposedDate;
                replicaObj.paymentMilestoneId = predefinedList[i].paymentMilestoneId;
                replicaObj.additionalChargesId = predefinedList[i].additionalChargesId;
                 replicaObj.proposedThresholdDate = predefinedList[i].proposedThresholdDate;
                replicaObj.unitId = predefinedList[i].unitId;
                replicaObj.unitCode = predefinedList[i].unitCode;
                replicaObj.allocate = false;
                replicaObj.isRemove = true;
                replicaObj.isSplit = true;
                replicaObj.oppId = predefinedList[i].oppId;
                
                installmentList.push(replicaObj);
            }else{
                installmentList.push(predefinedList[i]);
            }
        }
        
        component.set('v.installmentList',installmentList);
       component.set('v.parentWrapper.resultWrapperList',installmentList);
        component.set('v.isTable',false);
        component.set('v.isTable',true);
        
    },
    doSubmit : function(component, event, helper) {
        
        var allValid = [].concat(component.find('fieldId')).reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if(!allValid){
            helper.showToast('Error','Please resolve issues on the screen','error');  
        }else{
            var proposedAmountTotal = 0.00;
            var installmentList = component.get('v.installmentList');
            for(var i = 0;i<installmentList.length;i++){
                if(installmentList[i].proposedAmount != undefined)
                proposedAmountTotal = +proposedAmountTotal + +installmentList[i].proposedAmount;
            }
            //proposedAmountTotal = Math.round((proposedAmountTotal*20)/20).toFixed(2);
            //proposedAmountTotal = Math.round(proposedAmountTotal).toFixed(2);
            console.log('Proposed Amount'+proposedAmountTotal);
            console.log('Total Amount'+component.get('v.totalAmount'));
            if(component.get('v.parentWrapper.totalAmount')!= proposedAmountTotal){
                helper.showToast('Error','Total amount is not matching with proposed amount','error');  
            }else{
              //  component.set('v.isSpinner',true);
                var action = component.get("c.createScheduleAmendments");
                
                action.setParams({ parentWrapper :  component.get('v.parentWrapper'),
                                  isEdit : component.get('v.isEdit'),
                                 fromCashier : false} );
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS"){
                        helper.showToast('Success','Action performed successfully','success');
                     //   component.set('v.isSpinner',false);
                        $A.get("e.force:closeQuickAction").fire();
                         $A.get('e.force:refreshView').fire();
                    }
                    else{
                        
                        alert('Error...');
                    }
                });
                $A.enqueueAction(action);
            }
        }
        
    },
    doSubmitBooking : function(component, event, helper) {
        var auraIds = [];
         var allValid = auraIds.concat(component.find('fieldId')).reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if(!allValid){
            helper.showToast('Error','Please resolve issues on the screen','error');  
        }else{
            component.set('v.isSpinner',true);
            var installmentList = component.get('v.installmentList');
            var action = component.get("c.createScheduleAmendments");
            component.set('v.parentWrapper.bookingWrapper',installmentList[0]);
            action.setParams({ parentWrapper :  component.get('v.parentWrapper'),
                              isEdit : component.get('v.isEdit'),
                             fromCashier : false});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    helper.showToast('Success','Amendments done successfully','success');
                    component.set('v.isSpinner',false);
                    $A.get("e.force:closeQuickAction").fire();
                     $A.get('e.force:refreshView').fire();
                }
                else{
                    
                    alert('Error...');
                }
            });
            $A.enqueueAction(action);
        }
    },
    doRemove : function(component, event, helper) {
        var installmentList = [];
        var predefinedList = component.get('v.installmentList');
        var selectedId = event.getSource().get("v.value");
        for(var i=0 ; i<predefinedList.length ; i++){
            if(predefinedList[i].oppId+i != selectedId){
                installmentList.push(predefinedList[i]);
            }
        }
        
        component.set('v.installmentList',installmentList);
        component.set('v.parentWrapper.resultWrapperList',installmentList);
        component.set('v.isTable',false);
        component.set('v.isTable',true);
        
    },
    sortPaymentTermType: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'paymentTermType');
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, 'paymentTermType');
    },
    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.isSpinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.isSpinner", false);
    },
    onPaymentMethodChange : function(component,event,helper){
        helper.handlePayChangeHelper(component,event,helper);
      
    },
    handleChequeChange : function(component,event,helper){
        helper.handleChequeChangeHelper(component,event,helper);
    },
    handleBankChange :function(component,event,helper){
        helper.handleBankChangeHelper(component,event,helper);
    },
})