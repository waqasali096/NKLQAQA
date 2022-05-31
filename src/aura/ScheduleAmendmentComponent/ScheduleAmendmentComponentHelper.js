({
	showToast : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            type: type
        });
        toastEvent.fire();
    },
    sortBy: function(component, field){
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.installmentList");
        sortAsc = field == sortField? !sortAsc: true;
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.records", records);
    },
    handleChequeChangeHelper : function(component,event,helper){
     var installmentList = component.get('v.parentWrapper.resultWrapperList');
     var paymentMethod = event.getSource().get("v.value");
     var whichOne = event.getSource().get("v.name");
        var previousNo = whichOne;
        var previouscheqNo = installmentList[whichOne].previousChecqNo;
        for(var i= whichOne+1;i<installmentList.length;i++){
            if( previouscheqNo!= installmentList[whichOne].chequeNo){
               installmentList[whichOne].previousChecqNo = installmentList[whichOne].chequeNo;
            if(installmentList[i].paymentMode == 'Cheque' && !installmentList[i].isReceiptCreated && installmentList[i].bankName == installmentList[whichOne].bankName){
                installmentList[i].chequeNo = parseInt(installmentList[previousNo].chequeNo) + 1;
                previousNo = i;
                
            }
        }
        }
        component.set('v.isTable',false);
       component.set('v.parentWrapper.resultWrapperList',installmentList);
        component.set('v.installmentList',installmentList);
        component.set('v.isTable',true);
    },
     handleBankChangeHelper : function(component,event,helper){
        var installmentList = component.get('v.parentWrapper.resultWrapperList');
        //var paymentMethod = event.getSource().get("v.value");
        var whichOne = event.getSource().get("v.name");
        var bankName = installmentList[whichOne].bankName;
        for(var i= whichOne+1;i<installmentList.length;i++){
            if(installmentList[i].paymentMode == 'Cheque' && !installmentList[i].isReceiptCreated){
                installmentList[i].bankName = bankName;
            }
        }
        component.set('v.isTable',false);
        component.set('v.parentWrapper.resultWrapperList',installmentList);
        component.set('v.installmentList',installmentList);
        component.set('v.isTable',true);
    },
     handlePayChangeHelper : function(component,event,helper){
        var installmentList = component.get('v.parentWrapper.resultWrapperList');
        var paymentMethod = event.getSource().get("v.value");
        var whichOne = event.getSource().get("v.name");
        var bankName = installmentList[whichOne].bankName;
         var flag = false;
        if(paymentMethod != 'Cheque' && !installmentList[whichOne].isReceiptCreated){
            installmentList[whichOne].chequeNo = '';
            installmentList[whichOne].bankName = '';
        }else if(paymentMethod != 'Bank Transfer' && paymentMethod != 'Credit Card' && !installmentList[whichOne].isReceiptCreated){
            installmentList[whichOne].transactionId = '';
        }
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
         
        component.set('v.isTable',false);
        component.set('v.parentWrapper.resultWrapperList',installmentList);
        component.set('v.installmentList',installmentList);
        component.set('v.isTable',true);
    }
    
})