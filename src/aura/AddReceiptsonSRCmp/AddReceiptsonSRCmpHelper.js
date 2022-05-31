({
    showReceiptsonLoad: function(component, event) {
       
        var action = component.get("c.getAllReceiptsonOpp");
        action.setParams({ 
            "recID" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               
                var result = response.getReturnValue();
                console.log('result',result);
                component.set('v.caseReceipts' ,     result.rcpWrppr);
                
                /* Set totals- Start */
                component.set('v.Total_ReceptAmt' ,  result.totalReceiptAmt);
                component.set('v.Total_ForfeitAmt' ,  result.sRequest.Total_Forfeit_Amount__c);
                component.set('v.Total_RecoverAmt' ,  result.sRequest.Total_Recoverable_Amount__c);
                component.set('v.Total_RefundAmt' ,  result.sRequest.Total_Refund_Amount__c);
                component.set('v.Total_ReversalAmt' ,  result.sRequest.Total_Reversal_Amount__c);
                component.set('v.recoverablePicklistList' ,  result.recList);
                /* Set totals- End */
                
                var actionPickList_Values = result.receiptActionValues;
                console.log('values are '+ JSON.stringify(result.receiptActionValues));
                this.getReceiptActionValues(component, event ,actionPickList_Values);
                this.getForfeitValues(component, event ,result.forfeitTypeValues);
                // this.hideSpinner(component);
                
            }
        });
        $A.enqueueAction(action);
        
    },
    
    compareAmtonSRRecipt: function(component,index) {
    //alert('entered' + index);    
    var receiptsLst = component.get("v.caseReceipts"); 
    var SRRecept =   receiptsLst[index].SR_Receipt;
    //alert('SRRecept is '+ JSON.stringify(SRRecept));   
    var totalRecptAmt =  SRRecept.Receipt_Amount1__c;
    var addedRcptAmt = 0.000;    
         if(SRRecept.Forfeit_Amount__c!=undefined ){
            addedRcptAmt =  (parseFloat(addedRcptAmt)+  parseFloat(SRRecept.Forfeit_Amount__c)).toFixed(3);
            //alert('addedRcptAmt is '+ addedRcptAmt);
        }
        
        if(SRRecept.Refund_Amount__c!=undefined ){
                addedRcptAmt= (parseFloat(addedRcptAmt)+  parseFloat(SRRecept.Refund_Amount__c)).toFixed(3);
                 //alert('addedRcptAmt is '+ addedRcptAmt);
                
            }
        
         if(SRRecept.Reversal_Amount__c!=undefined ){
             addedRcptAmt = (parseFloat(addedRcptAmt)+  parseFloat(SRRecept.Reversal_Amount__c)).toFixed(3);
             //alert('addedRcptAmt is '+ addedRcptAmt);
                
            }
        
        if(SRRecept.Recoverable_Amount__c!=undefined ){
                addedRcptAmt = (parseFloat(addedRcptAmt)+  parseFloat(SRRecept.Recoverable_Amount__c)).toFixed(3);
            //alert('addedRcptAmt is '+ addedRcptAmt);
                
            }
       // alert('addedRcptAmt is '+ addedRcptAmt);
        //alert('totalRecptAmt is '+ totalRecptAmt);
        if(addedRcptAmt>totalRecptAmt){
            receiptsLst[index].isAmtInvalid = true;
        }
        else{
          receiptsLst[index].isAmtInvalid = false;  
        }
       component.set("v.caseReceipts" , receiptsLst); 
    },
    
    
    
    forfeitAmt_ChangeHelper: function(component, event) {
        var receiptsLst = component.get("v.caseReceipts");
        var totalFrfeit_Amt =0.000;
        for (var i = 0; i < receiptsLst.length; i++) {
            var SRRecept = receiptsLst[i].SR_Receipt;
            if(SRRecept.Forfeit_Amount__c!=undefined ){
                //alert('receiptsLst[i].Forfeit_Amount__c is '+ SRRecept.Forfeit_Amount__c);
                totalFrfeit_Amt =  (parseFloat(totalFrfeit_Amt)+  parseFloat(SRRecept.Forfeit_Amount__c)).toFixed(3);
                // alert('totalFrfeit_Amtis '+ totalFrfeit_Amt);
                
            }
        }
        component.set("v.Total_ForfeitAmt" , totalFrfeit_Amt);
        
    },
    
    recoverAmt_ChangeHelper:function(component, event) {
        var receiptsLst = component.get("v.caseReceipts");
        var totalRecover_Amt =0.000;
        for (var i = 0; i < receiptsLst.length; i++) {
            var SRRecept = receiptsLst[i].SR_Receipt;
            if(SRRecept.Recoverable_Amount__c!=undefined ){
                //alert('receiptsLst[i].Forfeit_Amount__c is '+ SRRecept.Forfeit_Amount__c);
                totalRecover_Amt +=  (parseFloat(totalRecover_Amt)+  parseFloat(SRRecept.Recoverable_Amount__c)).toFixed(3);
                // alert('totalFrfeit_Amtis '+ totalFrfeit_Amt);
                
            }
        }
        component.set("v.Total_RecoverAmt" , totalRecover_Amt);    
    },
    
    
    
    
    reversalAmt_ChangeHelper:function(component, event) {
        var receiptsLst = component.get("v.caseReceipts");
        var totalReversal_Amt =0.000;
        for (var i = 0; i < receiptsLst.length; i++) {
            var SRRecept = receiptsLst[i].SR_Receipt;
            if(SRRecept.Reversal_Amount__c!=undefined ){
                totalReversal_Amt = (parseFloat(totalReversal_Amt)+  parseFloat(SRRecept.Reversal_Amount__c)).toFixed(3);
                
            }
        }
        component.set("v.Total_ReversalAmt" , totalReversal_Amt);  
    },
    
    
    refundAmt_ChangeHelper:function(component, event) {
        var receiptsLst = component.get("v.caseReceipts");
        var totalRefund_Amt =0.000;
        
        for (var i = 0; i < receiptsLst.length; i++) {
            var SRRecept = receiptsLst[i].SR_Receipt;
            if(SRRecept.Refund_Amount__c!=undefined ){
                totalRefund_Amt= (parseFloat(totalRefund_Amt)+  parseFloat(SRRecept.Refund_Amount__c)).toFixed(3);
                
            }
        }
        component.set("v.Total_RefundAmt" , totalRefund_Amt);  
    },
    
    
    totalAmt_ChangeHelper:function(component, event) {
        var receiptsLst = component.get("v.caseReceipts");
        var totalRefund_Amt =0.000;
        var totalFrfeit_Amt =0.000;
        var totalRecover_Amt=0.000;
        var totalReversal_Amt =0.000;
        
        for (var i = 0; i < receiptsLst.length; i++) {
            var SRRecept = receiptsLst[i].SR_Receipt;
            
            if(SRRecept.Refund_Amount__c!=undefined && SRRecept.Refund_Amount__c!=''){
                totalRefund_Amt= (parseFloat(totalRefund_Amt)+  parseFloat(SRRecept.Refund_Amount__c)).toFixed(3);
            }
            if(SRRecept.Forfeit_Amount__c!=undefined && SRRecept.Forfeit_Amount__c!='' ){
                totalFrfeit_Amt =  (parseFloat(totalFrfeit_Amt)+  parseFloat(SRRecept.Forfeit_Amount__c)).toFixed(3);
            }
            if(SRRecept.Recoverable_Amount__c!=undefined && SRRecept.Recoverable_Amount__c!=''){
                totalRecover_Amt =  (parseFloat(totalRecover_Amt)+  parseFloat(SRRecept.Recoverable_Amount__c)).toFixed(3);
            }
            if(SRRecept.Reversal_Amount__c!=undefined && SRRecept.Reversal_Amount__c!=''){
                totalReversal_Amt = (parseFloat(totalReversal_Amt)+  parseFloat(SRRecept.Reversal_Amount__c)).toFixed(3);
            }
        }
        
        //alert('Total_RefundAmt is '+  component.get("v.Total_RefundAmt"));
        //alert('Total_ForfeitAmt is '+  component.get("v.Total_ForfeitAmt"));
       // alert('Total_RecoverAmt is '+  component.get("v.Total_RecoverAmt"));
        component.set("v.Total_RefundAmt" , totalRefund_Amt);
        component.set("v.Total_ForfeitAmt" , totalFrfeit_Amt);
        component.set("v.Total_RecoverAmt" , totalRecover_Amt);
        component.set("v.Total_ReversalAmt" , totalReversal_Amt);  
    },
    
    
    getReceiptActionValues:function(component, event ,result) {
        var actionMap = [];
        for(var key in result){
            actionMap.push({key: key, value: result[key]});
        }
        component.set("v.receiptActionMap", actionMap);    
        
    },
    
    getForfeitValues:function(component, event ,result) {
        var actionMap = [];
        for(var key in result){
            actionMap.push({key: key, value: result[key]});
        }
        component.set("v.forfeitValuesMap", actionMap);    
        
    },
    
    saveReceiptsHelper: function(component, event) {
        var receiptsLst = component.get("v.caseReceipts");
        console.log('receiptsLst ',receiptsLst);
        //alert('values are '+ JSON.stringify(receiptsLst));
        var selectedReceiptsLst =[];
        var isError= false;
        for (var i = 0; i < receiptsLst.length; i++) {
            if(receiptsLst[i].isChecked){
                var receipt = receiptsLst[i].SR_Receipt;
                selectedReceiptsLst.push(receiptsLst[i].SR_Receipt);
                if(receiptsLst[i].isAmtInvalid ==true){
                    isError = true;
                }
                
            }
        } 
        console.log('selectedReceiptsLst ',selectedReceiptsLst);
        component.set('v.selectedSRReceipts' ,selectedReceiptsLst);
        var action = component.get("c.saveReceipts");
        action.setParams({ 
            "SR_Receipts" : component.get("v.selectedSRReceipts"),
            "recID": component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToastMessage(
                    "Success!",
                    "Receipts are added successfully!",
                    "Success"
                );
                $A.get("e.force:refreshView").fire();
                $A.get("e.force:closeQuickAction").fire();
                
            }
            else{
                this.showToastMessage(
                    "Error!",
                    "There is some issue.Please contact admin !",
                    "Error"
                ); 
            }
        });
        
        if(isError ==true){
            this.showToastMessage(
                    "Error!",
                    "There are some errors !",
                    "Error"
                );
            
        }
        else{
         $A.enqueueAction(action);
        }
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
    
    validaterecoverablesRecords: function(component, event) {
        //Validate all account records
        var isValid = true;
        var recoverablesList = component.get("v.recoverablesList");
        console.log('recoverablesList',recoverablesList)
        for (var i = 0; i < recoverablesList.length; i++) {
            if (recoverablesList[i].Name__c == '' || recoverablesList[i].Amount__c == '') {
                isValid = false;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Recoverable Name or Recoverable Amount  cannot be blank on '"+(i + 1)+"' row number",
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                //lert('Recoverable Name or Recoverable Amount  cannot be blank on '+(i + 1)+' row number');
            }
        }
        return isValid;
    }, 
    showRecoverablesonLoad: function(component, event) {
         // this.showSpinner(component);
        var action = component.get("c.getRecoverablesData");
        action.setParams({ 
            "recID" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            //get response status 
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {
               
                component.set("v.recoverablesList", response.getReturnValue());
                
                var recoverLst = component.get("v.recoverablesList");
                
                var recoverableMap = new Map(); 
                for(var i=0; i< recoverLst.length;i++){
                   
                    recoverableMap.set(recoverLst[i].Id,recoverLst[i].Amount__c);
                } 
               
                component.set("v.recoverID_AmtMap", recoverableMap);
               
            }
        }); 
        $A.enqueueAction(action);
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
    
})