({

    callUnitMethod : function(component, event, helper) 
    {
        helper.fetchDealDetails(component,event);       
        helper.fetchPPs(component,event);
        helper.calculations(component,event);
        helper.fetchReceipts(component,event);
        helper.fetchmodePicklist(component,event);
        helper.fetchReceivedForPicklist(component,event);
        helper.fetchInstallmentTypeValues(component,event);
        helper.fetchReceiptMethods(component,event);
    },
    
    saveReceipt: function(component, event, helper) {
        component.set("v.showSpinner", true);
        var accountRecord = component.get("v.accountRecord");
        var defaultCustomerCheck = component.get("v.defaultCustomer");
        if(accountRecord !=null && !defaultCustomerCheck){
            var SeletedAccountId = accountRecord.val;
        }else{
            var SeletedAccountId = component.get("v.receiptObj.Received_From__c");
        }
        if(component.get("v.selectedBank") != null){
            component.set("v.receiptObj.Bank__c ",component.get("v.selectedBank"));    
        }else if(component.get("v.selectedBank") == '--none--' ){
            component.set("v.receiptObj.Bank__c ",null);
        }
        var receipt = component.get("v.receiptObj");
        var action = component.get("c.saveRec");
        //console.log(component.find("receiptField1").get("v.value"));
        action.setParams({          
            "mode":component.get("v.selectedmode"),
            "ReceivedFor" : component.get("v.selectedReceivedFor"),
            //"InstallmentType" : component.get("v.selectedinstallmentType"),
            "OppId" : component.get("v.recordId"),
            "receipt" : receipt,
            "receivedFrom" : SeletedAccountId,
            "receiptMethodId" : component.get("v.seletedReceiptMethodId")
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var toastEvent;
            if (state === "SUCCESS") {
                var rclst = a.getReturnValue();
                component.set("v.receipts", rclst);
                helper.resetFieldsOnSaveReceipt(component,event);
                helper.calculations(component,event);
                
                toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            title : 'Success Message',
                                            message:'Receipt created successfully',
                                            type: 'success'
                                        });
            }
            else
            {
                toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:'Something went wrong please try again later',
                    type: 'error'
                });
            }
            toastEvent.fire();
            
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    paymentModeChange : function (component, event, helper) {
        var selectedPaymentMode = event.getSource().get("v.value");
        console.log('selectedPaymentMode :', selectedPaymentMode);
       // var selectedPaymentMode = component.get("v.selectedPaymentMode");
        
        if (selectedPaymentMode == 'PDC') {
            component.set('v.showBankName', true);
            component.set('v.showBankBranch',true);
            component.set('v.bankFieldsRequired',true);
            component.set('v.showMaturityDate',true);
            
            helper.getBankPicklist(component, event);
        }else {
            component.set('v.showBankName', false);
            component.set('v.showBankBranch',false);
            component.set('v.bankFieldsRequired',false);
            component.set('v.showMaturityDate',false);
        }
        helper.setReceiptMethodsOption(component,selectedPaymentMode);
    },
    
    onCustomerChange: function(component, event, helper) {
        console.log('customer is changed');
        component.set("v.defaultCustomer",false);
        component.find("customer").set("v.value", "");

      },

      callDocGeneration: function(component, event, helper) {
        var dealId = component.get("v.recordId");
        var vfUrl = '/apex/rsdoc__GenerateDocument?id='+dealId+'&templateId=GDT-000014&attach=true&download=true&output=pdf&mergeAdditional=false&redirectTo=Record';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": vfUrl
        });
        urlEvent.fire();
      }
})