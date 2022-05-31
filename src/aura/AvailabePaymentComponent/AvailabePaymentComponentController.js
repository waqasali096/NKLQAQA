({
    doInit : function(component, event, helper) {
        debugger;
       helper.fetchpaymentPlan(component,event,helper);  
        
    },
    addPayment: function(component, event) {
        debugger;
        var tempUnitList=[];
        var updateId = [];
        var selectedUnits = component.get("v.selectedUnits");
        var unlist = component.get("v.unlist");
        var recordId = component.get("v.recordId");
        if(selectedUnits.length == 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'Please select a payment plan.',
                type: 'error'
            });
            //component.set("v.isSpinner", false);  
            toastEvent.fire();
            
        }
        else if(selectedUnits.length >= 1)
        {
            console.log('%%Units'+selectedUnits);
            var actionUnit = component.get("c.addUnitstoOpp");
            actionUnit.setParams({ OppId : recordId,unitsList : unlist,selectedUnits : selectedUnits});
            actionUnit.setCallback(this, function(response) {
                var state = response.getState();               
                if (state === "SUCCESS"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message:'Unit has been added successfully..',
                        type: 'success'
                    });
                    //component.set("v.isSpinner", false);  
                    toastEvent.fire();
                    //this.showMsg(component,event,'Unit has been added successfully.');
                    //$A.get('e.force:refreshView').fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                    //var result = response.getReturnValue();
                    /*if(result != null){	
                        tempUnitList=result;
                        
                        $A.get('e.force:refreshView').fire();
                        this.showMsg(component,event,'Unit has been added successfully.');
                        $A.get("e.force:closeQuickAction").fire();
                    }  
                    else{
                        component.set("v.currentUnitExistFlg",false);
                    }*/
                }
                else if(state === "ERROR"){
                    component.set("v.isSpinner", false);
                }  
            });
            $A.enqueueAction(actionUnit);
        }
     },
    showErrorMsg : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message:message,
            type: 'error'
        });
        //component.set("v.isSpinner", false);  
        toastEvent.fire();
    },
    handleSelect : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i]);
        }
        component.set("v.selectedUnits", setRows);
    },
    handlecheque : function(component, event, helper) {
        helper.handlehelpercheque(component,event,helper);
    },

    backpage : function(component,event,helper){
        //alert('in package');
        var parentComponent = component.get("v.parent");    
        //alert(JSON.stringify(component.get("v.unitId")));
        parentComponent.unitLeasingMethod(component.get("v.unitId"),false);
    },
    paymentCalculation : function(component,event,helper) {
        var discount = component.get("v.employeeDiscount");
        var baserent = component.get("v.flAmount");
        var discountedAmount = ((baserent*discount)/100);
        var finalrent =  baserent - discountedAmount;
        component.set("v.finalLeaseAmount",finalrent);
        
        
        
    },
    onRateChange : function(component,event,helper){
        var baseLeaseAmount = component.get("v.baseLeaseAmount");
        var totalsqftArea = component.get("v.totalsqftArea");
        var persqarearent = baseLeaseAmount * totalsqftArea;
        if(component.get("v.discount") != null){
            var discountedAmount = (persqarearent * component.get("v.discount"))/100;
            var priceAfterdis =  persqarearent - discountedAmount;
            persqarearent = priceAfterdis;
        }
        component.set("v.finalLeaseAmount",persqarearent);
        component.set("v.rateChangePop",true);
        
    },
    closeModel : function(component,event,helper){
        component.set("v.showWarning",false);
    },
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    
    SubmitForApproval : function(component,event,helper){
        if(!$A.util.isUndefinedOrNull(component.find("fuploader").get("v.files"))){
           // alert(component.find("fuploader").get("v.files").length);
        if(component.find("fuploader").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } 
        }
        if($A.util.isUndefinedOrNull(component.find("fuploader").get("v.files"))){
            //alert('without attachment');
            helper.submit(component,event,helper);
        }
    },
    
    SubmitChange : function(component,event,helper){
        if(component.get("v.rateChangePop")){
           component.set("v.showWarning",true); 
        } else {
            helper.submit(component,event,helper);
        }
    },
    onpaymentModeChange : function(component,event,helper){
        if(component.get("v.paymentMode") == 'Cheque'){
            component.set("v.showCheques",true);
        } else {
             component.set("v.showCheques",false); 
            var result = component.get("v.chequeTypeMap");
            //alert(JSON.stringify(result));
            for(let i =0;i< result.length;i++){
               // alert(result[i].key);
                if(result[i].value == '1 Cheque' || result[i].value == '1 Installment'){
                   // alert(result[i].value);
                    component.set("v.selectcheque",result[i].key);
                   helper.handlehelpercheque(component,event,helper);
                    return;

                }
            }
            
        }
    }
    
})