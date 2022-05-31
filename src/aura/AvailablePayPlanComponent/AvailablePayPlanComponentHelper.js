({
    getData : function(component, event, helper) {
        var action = component.get("c.getOppUnits");
        action.setParams({"oppId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            component.set("v.totalLeaseAmount",result.totalLeaseAmount);
            component.set("v.totalBaseAmount",result.totalBaseAmount);
            component.set("v.totalDiscountAmount",result.totalDiscountAmount);
            component.set("v.unittype",result.oppObj.Leasing_Type__c);
            component.set("v.installMentList",result.installWrapperList);
            component.set("v.parentWrapper",result);
            if(component.get("v.unittype") == 'Residential Units'){
                if(!$A.util.isUndefinedOrNull(result.oppObj.Account.Emirates_Ids__c)){
                    component.set("v.empDiscount",true);   
                } else {
                    component.set("v.empDiscount",false);
                }   
            }
            if(component.get("v.unittype") == 'Residential Units'){
                component.set("v.isUnitFields",true);
                component.set("v.isShopFields",false); 
            }
            //alert(component.get("v.showUnitFields"));
            if(component.get("v.unittype") == 'Commercial Units' ){
                component.set("v.isShopFields",true);
                component.set("v.isUnitFields",false);    
            }  
        });
        $A.enqueueAction(action);  
    },
    paymentModeChangeHelper : function(component, event, helper) {
         if(component.get("v.paymentMode") == 'Cheque'){
            component.set("v.showCheques",true);
             component.set("v.selectcheque",null);
            component.set("v.selectcheque",1);
        } else {
            component.set("v.showCheques",false); 
            component.set("v.selectcheque",1);
            
        }
       this.calculateHelper(component,event,helper);    
    },
    calculateHelper : function(component, event, helper) {
        var action = component.get("c.calculateAmount");
        var employeeDiscount = component.get("v.employeeDiscount");
        if(employeeDiscount == null || employeeDiscount == ''){
            employeeDiscount = 0;
        }
        action.setParams({"oppId" : component.get("v.recordId"),
                          "selectedCheque" : component.get("v.selectcheque"),
                          "paymentMode" : component.get("v.paymentMode"),
                          "empDiscount" : employeeDiscount
                         });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            component.set("v.parentWrapper",result);
            component.set("v.installMentList",result.installWrapperList);
            
        });
        $A.enqueueAction(action);  
    },
    employeeDiscountHelper : function(component, event, helper) {
        var action = component.get("c.calculateAmount");
        var employeeDiscount = component.get("v.employeeDiscount");
        if(employeeDiscount == null || employeeDiscount == ''){
            employeeDiscount = 0;
        }
        action.setParams({"oppId" : component.get("v.recordId"),
                          "selectedCheque" : component.get("v.selectcheque"),
                          "paymentMode" : component.get("v.paymentMode"),
                          "empDiscount" : employeeDiscount
                         });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            component.set("v.parentWrapper",result);
            component.set("v.totalLeaseAmount",result.totalLeaseAmount);
            component.set("v.totalBaseAmount",result.totalBaseAmount);
            component.set("v.totalDiscountAmount",result.totalDiscountAmount);
            component.set("v.installMentList",result.installWrapperList);            
        });
        $A.enqueueAction(action);  
    },
    submitHelper :  function(component, event, helper) {
        var action = component.get("c.createInstallmentAndCharges");
        var parentWrapper = component.get('v.parentWrapper');
        var pricePerSqft = component.get("v.pricePerSqft");

         if(pricePerSqft == null || pricePerSqft == ''){
            pricePerSqft = 0;
        }
        parentWrapper.installWrapperList = component.get('v.installMentList');
        action.setParams({"parentWrapper" : parentWrapper,
                          "noOfCheques" : component.get("v.selectcheque"),
                          "paymentMode" : component.get("v.paymentMode"),
                          "pricePerSqft" : pricePerSqft
                         });
        action.setCallback(this, function(response) {
                if(!pricePerSqft){
                    this.showToast('Success','Installments Created Successfully','success');
                }
                $A.get('e.force:refreshView').fire();
            
            this.getData(component, event, helper);
        });
        $A.enqueueAction(action);  
        
    },
    shopPriceHelper : function(component, event, helper) {
        var action = component.get("c.calculateAmount");
        var pricePerSqft = component.get("v.pricePerSqft");
        if(pricePerSqft == null || pricePerSqft == ''){
            pricePerSqft = 0;
        }
        
        action.setParams({"oppId" : component.get("v.recordId"),
                          "selectedCheque" : component.get("v.selectcheque"),
                          "paymentMode" : component.get("v.paymentMode"),
                          "empDiscount" : 0,
                          "pricePerSqft" : pricePerSqft
                         });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            component.set("v.parentWrapper",result);
            component.set("v.totalLeaseAmount",result.totalLeaseAmount);
            component.set("v.totalBaseAmount",result.totalBaseAmount);
            component.set("v.totalDiscountAmount",result.totalDiscountAmount);
            component.set("v.installMentList",result.installWrapperList);            
        });
        $A.enqueueAction(action);  
    },
    reviseHelper :  function(component, event, helper) {
        var action = component.get("c.reviseInstallments");
        var parentWrapper = component.get('v.parentWrapper');
        
        action.setParams({"oppId" : parentWrapper.oppObj.Id   
                         });
        action.setCallback(this, function(response) {
            this.showToast('Success','Installments Deleted Successfully','success');
            
            this.getData(component, event, helper);
            $A.get('e.force:refreshView').fire();
            component.set('v.paymentMode','');
            component.set("v.showCheques",false); 
            component.set('v.pricePerSqft',null);
            component.set('v.selectedCheque',1);
            component.set('v.employeeDiscount',null)
            
            
            
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

    submitForApproval : function(component, event, helper){
        var action = component.get("c.submitForApproval");
        action.setParams({
            recordId : component.get("v.recordId"),
            rateReason : component.get("v.rateChangeReason"),
            pricePerSqft : component.get("v.pricePerSqft")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showWarning",false);
                this.showToast('Success','Price per sq.ft change is sent for approval, once approved revised price will reflect in the installments','success');
            }
        });
        $A.enqueueAction(action);
    }
})