({
    doInit : function(component, event, helper) {
        helper.getData(component,event,helper);
    },
    onpaymentModeChange : function(component,event,helper){
        helper.paymentModeChangeHelper(component,event,helper);
    },
    handleCalculate :  function(component,event,helper){
        helper.calculateHelper(component,event,helper);  
        
    },
    handleEmployeeDiscount :  function(component,event,helper){
        helper.employeeDiscountHelper(component,event,helper);          
    },
    handleSubmit : function(component,event,helper){
        var pricePerSqft = component.get("v.pricePerSqft");
            if(pricePerSqft){
                component.set("v.showWarning",true);
                component.set("v.rateChangePrice",pricePerSqft);
            }else{
                helper.submitHelper(component,event,helper);  
            } 
    },
    handleRevise : function(component,event,helper){
        helper.reviseHelper(component,event,helper);          
    },
    handleShopPrice : function(component,event,helper){
        helper.shopPriceHelper(component,event,helper);          
    },
    navigateToRecord: function(component, event, helper) {
        var recordId = event.target.dataset.caseid;
        window.open('/' + recordId);  
    },
    showSpinner: function(component, event, helper) {
        component.set("v.isSpinner", true); 
    },
    hideSpinner : function(component,event,helper){
        component.set("v.isSpinner", false);
    },
    closeModel : function(component,event,helper){
        component.set("v.showWarning",false);
    },
    SubmitForApproval : function(component,event,helper){
        helper.submitHelper(component,event,helper);  
        helper.submitForApproval(component,event,helper);
        
    }  
})