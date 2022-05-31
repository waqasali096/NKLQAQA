({
    doInit : function(component, event, helper) {
        helper.showReceiptsonLoad(component, event);
        helper.showRecoverablesonLoad(component, event);

        var currentUrl= window.location.hostname;
        var href =  'https://'+currentUrl+'/';
        console.log('href--->',href);
        component.set("v.hrefRecoverableLink", href);
    },
    
   
    cancel: function(component, event, helper) {
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    
    onActionTypeChange: function(component, event, helper) {
        var index =    event.getSource().get("v.label");
        var actionType =  event.getSource().get("v.value");
        var receiptsLst = component.get("v.caseReceipts");
        /*  if(actionType=='Partial Refund'){
            receiptsLst[index].SR_Receipt.Recoverable_Amount__c =  receiptsLst[index].SR_Receipt.Receipt_Amount1__c; 
            helper.recoverAmt_ChangeHelper(component, event);
            receiptsLst[index].isRecoverAmtReq =  true;
            receiptsLst[index].isFrfeitTypeReq =  false;
            receiptsLst[index].isFrfeitAmtReq =  false; 
            receiptsLst[index].isReversalAmtReq =  false;
            receiptsLst[index].isRefundAmtReq =  false;
            receiptsLst[index].SR_Receipt.Refund_Amount__c ='';
            receiptsLst[index].SR_Receipt.Reversal_Amount__c =''; 
            receiptsLst[index].SR_Receipt.Forfeit_Amount__c ='';
            
        }*/
        if(actionType=='Reversal'){
            receiptsLst[index].SR_Receipt.Reversal_Amount__c =  receiptsLst[index].SR_Receipt.Receipt_Amount1__c;
            helper.reversalAmt_ChangeHelper(component, event);
            receiptsLst[index].isReversalAmtReq =  true;
            receiptsLst[index].isRecoverAmtReq =  false;
            receiptsLst[index].isFrfeitTypeReq =  false;
            receiptsLst[index].isFrfeitAmtReq =  false; 
            receiptsLst[index].isRefundAmtReq =  false;
            receiptsLst[index].SR_Receipt.Recoverable_Amount__c = '';
            receiptsLst[index].SR_Receipt.Refund_Amount__c = '';
            receiptsLst[index].SR_Receipt.Forfeit_Amount__c ='';
            
            
        }
        else if(actionType=='Full Refund' || actionType=='Partial Refund'){
            receiptsLst[index].SR_Receipt.Refund_Amount__c =  receiptsLst[index].SR_Receipt.Receipt_Amount1__c;
            receiptsLst[index].isFrfeitTypeReq =  false;
            receiptsLst[index].isFrfeitAmtReq =  false;
            receiptsLst[index].isRefundAmtReq =  true;
            receiptsLst[index].isReversalAmtReq = false;
            receiptsLst[index].isRecoverAmtReq =  false;
            receiptsLst[index].SR_Receipt.Recoverable_Amount__c = '';
            receiptsLst[index].SR_Receipt.Reversal_Amount__c =''; 
            receiptsLst[index].SR_Receipt.Forfeit_Amount__c ='';
            
        }
            else if(actionType=='Full Forfeit' || actionType=='Partial Forfeit'){
                receiptsLst[index].SR_Receipt.Forfeit_Amount__c =  receiptsLst[index].SR_Receipt.Receipt_Amount1__c;
                receiptsLst[index].SR_Receipt.Recoverable_Amount__c = '';
                receiptsLst[index].SR_Receipt.Reversal_Amount__c =''; 
                receiptsLst[index].SR_Receipt.Refund_Amount__c = '';
                receiptsLst[index].isFrfeitTypeReq =  false;
                receiptsLst[index].isFrfeitAmtReq =  true;
                receiptsLst[index].isRefundAmtReq =  false;
                receiptsLst[index].isReversalAmtReq = false;
                receiptsLst[index].isRecoverAmtReq =  false;
            }
                else{
                    receiptsLst[index].isReversalAmtReq =  false;
                    receiptsLst[index].isRecoverAmtReq =  false;
                    receiptsLst[index].isFrfeitTypeReq =  false;
                    receiptsLst[index].isFrfeitAmtReq =  false; 
                    receiptsLst[index].isRefundAmtReq =  false;
                    
                }
        
        component.set("v.caseReceipts" , receiptsLst);
        helper.totalAmt_ChangeHelper(component, event);  
        
        
    },
    
    addRecoverableAmt : function(component, event, helper){
        var index =    event.getSource().get("v.label"); 
        var recoverID =    event.getSource().get("v.value");
        var receiptsLst = component.get("v.caseReceipts"); 
        var srvc_Receipt =   receiptsLst[index];
        //alert(JSON.stringify(srvc_Receipt));    
            
        var recover_Map =   component.get("v.recoverID_AmtMap" );
        var amt = recover_Map.get(recoverID);
        srvc_Receipt.SR_Receipt.Recoverable_Amount__c  = amt;
        component.set("v.caseReceipts" , receiptsLst);
        
        
    //var recover    
    
    },
    
    onChange : function(component, event, helper){
        var index =    event.getSource().get("v.label");
        var actionType =  event.getSource().get("v.value");
        var receiptsLst = component.get("v.caseReceipts");
        for (var i = 0; i < receiptsLst.length; i++) {
            if(receiptsLst[i].isChecked){
                //var receipt = receiptsLst[i].SR_Receipt;
                //selectedReceiptsLst.push(receiptsLst[i].SR_Receipt);
                receiptsLst[i].SR_Receipt.Recoverables__c =  component.find("distance").get("v.value");
            }
        }
        console.log('distance ',component.get("v.selectedRecoverableValue"));    
        //component.set("v.caseReceipts" , receiptsLst);
    },
    
    handleForfeitAmt_Change : function(component, event, helper) {
        //helper.forfeitAmt_ChangeHelper(component, event);
        var index =    event.getSource().get("v.label");
        helper.compareAmtonSRRecipt(component,index);
        helper.totalAmt_ChangeHelper(component, event); 
        
    },
    
    handleRefundAmt_Change : function(component, event, helper) {
        //helper.refundAmt_ChangeHelper(component, event);
        var index =    event.getSource().get("v.label");
        helper.compareAmtonSRRecipt(component,index);
        helper.totalAmt_ChangeHelper(component, event); 
        
    },
    
    handleRecoverAmt_Change : function(component, event, helper) {
        helper.recoverAmt_ChangeHelper(component, event);
    },
    
    handleReversalAmt_Change : function(component, event, helper) {
        //helper.reversalAmt_ChangeHelper(component, event);
        var index =    event.getSource().get("v.label");
        helper.compareAmtonSRRecipt(component,index);
        helper.totalAmt_ChangeHelper(component, event); 
    },
    
    cancel: function(component, event, helper) {
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    
    saveReceiptsAction: function(component, event, helper) {
        //alert('test');
        var allValid = component.find('field1').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        if (allValid) {
            helper.saveReceiptsHelper(component, event);
        } else {
            helper.showToastMessage(
                "Error!",
                "Please fill all mandatory fields !",
                "Error"
            ); 
        }
        
        
    },
    
    
    handleReceiptsSelection: function(component, event, helper) {
        var i = (event.getSource().get("v.name"));
        var checkboxVal = event.getSource().get("v.value")
        var allReceipts =    component.get('v.caseReceipts');
        if(checkboxVal==true){
            allReceipts[i].isActionReq =true;
        }
        else{
            allReceipts[i].isActionReq =false;
            allReceipts[i].isReversalAmtReq =  false;
            allReceipts[i].isRecoverAmtReq =  false;
            allReceipts[i].isRefundAmtReq =  false;
            allReceipts[i].isFrfeitTypeReq =  false;
            allReceipts[i].isFrfeitAmtReq =  false; 
            
        }
        component.set('v.caseReceipts' ,allReceipts );
        //('receipts are '+ JSON.stringify(allReceipts));
        //alert(component.find("field1").get("v.value"));
        
    },
    addRow: function(component, event, helper) {
        var recoverablesList = component.get("v.recoverablesList");
        recoverablesList.push({
            'sobjectType': 'Recoverables__c',
            'Name': '',
            'Name__c': '',
            'Amount__c': '',
            'Service_Request__c': component.get("v.recordId")
            
        });
        component.set("v.recoverablesList", recoverablesList);
    },
    removeRecord: function(component, event, helper) {
        var recoverablesList = component.get("v.recoverablesList");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        if(selectedItem.dataset.id != undefined){
            var action = component.get("c.deleteRecoverablesData");
            action.setParams({
                "recovRecordId": selectedItem.dataset.id
            });
            action.setCallback(this, function(response) {
                //get response status 
                var state = response.getState();
                console.log('state',state);
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been deleted successfully.",
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();                    
                    //alert('recoverables saved successfully');
                }
            }); 
            $A.enqueueAction(action);
            
        }
        recoverablesList.splice(index, 1);
        component.set("v.recoverablesList", recoverablesList);
        
    },
    saveRecoverables: function(component, event, helper) {  
        console.log('hi',component.get("v.recoverablesList"));
        if (helper.validaterecoverablesRecords(component, event)) {
            var action = component.get("c.saveRecoverablesData");
            action.setParams({
                "recList": component.get("v.recoverablesList")
            });
            action.setCallback(this, function(response) {
                //get response status 
                var state = response.getState();
                console.log('state',state);
                if (state === "SUCCESS") {
                    var action = component.get('c.doInit');
                    helper.showRecoverablesonLoad(component, event);

                    $A.enqueueAction(action);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been updated or inserted successfully.",
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            }); 
            $A.enqueueAction(action);
        }
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }
})