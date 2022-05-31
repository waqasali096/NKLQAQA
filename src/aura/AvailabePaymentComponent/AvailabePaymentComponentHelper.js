({
      MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
	showPayment : function(component, event) {
             debugger;
            var unitId = component.get("v.unitId");
         var action = component.get("c.showPaymentList");
        action.setParams({
            "unitId": unitId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //alert(JSON.stringify(result));
                var villaMap = [];
                for(var key in result){
                    villaMap.push({key: key, value: result[key]});
                }
                component.set("v.chequeTypeMap", villaMap);
            }        });
        $A.enqueueAction(action);
             },  
    uploadHelper: function(component, event) {
        var fileInput = component.find("fuploader").get("v.files");
        var file = fileInput[0];
        var self = this;
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
        var objFileReader = new FileReader();  
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
             
            fileContents = fileContents.substring(dataStart);
            self.uploadProcess(component, file, fileContents);
        });
         
        objFileReader.readAsDataURL(file);
    },
     
    uploadProcess: function(component, file, fileContents) {
        var startPosition = 0;
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        //alert('in here');
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },
     
     
    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.updateAttachApprovalSubmit");
        action.setParams({
            optyId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId,
            rateChangeReason : component.get("v.rateChangeReason")
        });
         
        action.setCallback(this, function(response) { 
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert(state);
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
//alert('File has been uploaded successfully');
                     var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message:'File has been uploaded successfully',
                        type: 'success'
                    });
                    component.set("v.isSpinner", false);  
                   
                    toastEvent.fire();

                }
                   //alert(state);
            component.set("v.showWarning",false);
                component.set("v.showWarning",false);
        var selectedchequea = component.get("v.selectcheque");
        //alert(selectedchequea);
        component.set("v.isSpinner", true);  
        if(selectedchequea === ""){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'Please select a number of cheque.',
                type: 'error'
            });
            
            toastEvent.fire();
            component.set("v.isSpinner", false); 
        }else{
            var unitId = component.get("v.unitId");
            var recordId = component.get("v.recordId");
            var actionUnit = component.get("c.addUnitstoOpp");
          // alert(component.get("v.rateChangeReason"));

            actionUnit.setParams({ OppId : recordId,unitsList : unitId,selectedcheques : selectedchequea,discount: component.get("v.employeeDiscount"),finalLeaseAmount : component.get("v.finalLeaseAmount"),paymentmode : component.get("v.paymentMode"),employeeDiscount : component.get("v.employeeDiscount"),PersqReason : component.get("v.rateChangeReason"),persqftprice :component.get("v.baseLeaseAmount") ,changedpersfPrice : component.get("v.rateChangePrice")});
            actionUnit.setCallback(this, function(response) {
                var state = response.getState();               
                if (state === "SUCCESS"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message:'Unit has been added successfully..',
                        type: 'success'
                    });
                    component.set("v.isSpinner", false);  
                   
                    toastEvent.fire();
                    //this.showMsg(component,event,'Unit has been added successfully.');
                    $A.get('e.force:refreshView').fire();
                    var parentComponent = component.get("v.parent");    
                    parentComponent.unitLeasingMethod(component.get("v.unitId"),false);
                }
                else if(state === "ERROR"){
                }  
            });
            $A.enqueueAction(actionUnit);
            
        }
      
            } else if (state === "INCOMPLETE") {
               // alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
             // alert(state);
            component.set("v.showWarning",false);
            
        });

        $A.enqueueAction(action);
    },
    
        submit : function(component, event, helper) {
        debugger;
        component.set("v.showWarning",false);
        var selectedchequea = component.get("v.selectcheque");
        //alert(selectedchequea);
        component.set("v.isSpinner", true);  
        if(selectedchequea === ""){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'Please select a number of cheque.',
                type: 'error'
            });
            
            toastEvent.fire();
            component.set("v.isSpinner", false); 
        }else{
            var unitId = component.get("v.unitId");
            var recordId = component.get("v.recordId");
            var actionUnit = component.get("c.addUnitstoOpp");
            actionUnit.setParams({ OppId : recordId,unitsList : unitId,selectedcheques : selectedchequea,discount: component.get("v.employeeDiscount"),finalLeaseAmount : component.get("v.finalLeaseAmount"),paymentmode : component.get("v.paymentMode"),employeeDiscount : component.get("v.employeeDiscount"),PersqReason : component.get("v.rateChangeReason"),persqftprice :component.get("v.baseLeaseAmount") ,changedpersfPrice : component.get("v.rateChangePrice")});
            actionUnit.setCallback(this, function(response) {
                var state = response.getState();               
                if (state === "SUCCESS"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message:'Unit has been added successfully..',
                        type: 'success'
                    });
                    component.set("v.isSpinner", false);  
                   
                    toastEvent.fire();
                    //this.showMsg(component,event,'Unit has been added successfully.');
                    $A.get('e.force:refreshView').fire();
                    //var parentComponent = component.get("v.parent");    
                   // parentComponent.unitLeasingMethod(component.get("v.unitId"),false);
                }
                else if(state === "ERROR"){
                }  
            });
            $A.enqueueAction(actionUnit);
            
        }
    },
        handlehelpercheque : function(component, event, helper) {
        debugger;
        var selectedcheque = component.get("v.selectcheque");
        var unitIds = component.get("v.unitId");
        var action = component.get("c.showAmount");
        action.setParams({
            "selectedcheque": selectedcheque,
            "unitId" : unitIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
               component.set("v.baseLeaseAmount",result.Base_Lease_Amount__c);
                component.set("v.rateChangePrice",result.Base_Lease_Amount__c);
                component.set("v.discount",result.Discount__c);
                if(component.get("v.unittype") != 'Residential Shops' ){
                    var chequ = 1;
                    if(result.No_of_cheques__c === chequ){
                        var amt = result.Base_Lease_Amount__c * 0.05;
                        var final = result.Base_Lease_Amount__c - amt;
                        component.set("v.finalLeaseAmount",final);
                        component.set("v.flAmount",final);
                    }else{
                        component.set("v.finalLeaseAmount",result.Base_Lease_Amount__c);
                        component.set("v.flAmount",result.Base_Lease_Amount__c);
                    }
                //component.set("v.finalLeaseAmount",result.Final_Lease_Amount__c);
                }
                
                if(component.get("v.unittype") == 'Residential Shops'){
                    var baseLeaseAmount = component.get("v.baseLeaseAmount");
                    var totalsqftArea = component.get("v.totalsqftArea");
                   // alert('baseLeaseAmount'+baseLeaseAmount);
                   var cheque = 1;
                    if(result.No_of_cheques__c === cheque){
                    var persqarearents = baseLeaseAmount * 0.05;
                     var persqareare = baseLeaseAmount -  persqarearents;
                     var   persqarearent = persqareare * totalsqftArea; 
                    }else{
                       var persqarearent = baseLeaseAmount * totalsqftArea; 
                    }
                    var discount = component.get("v.discount");
                     var discountedAmount = 0;
                    if(discount != 'undefined'){
                     discountedAmount = ((persqarearent*discount)/100);
                    }
                    var finalrent =  persqarearent - discountedAmount;
                    
                    component.set("v.finalLeaseAmount",persqarearent);
                   // alert(component.get("v.finalLeaseAmount"));  
                }
                  
                
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchpaymentPlan : function(component,event,helper){
        var action = component.get("c.paymentPlanDetails");
        action.setParams({"recordId" : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            component.set("v.unittype",result.oppty.Leasing_Type__c);
            component.set("v.unlist",result.unitList);
            component.set("v.unitId",result.unitList);
            component.set("v.totalsqftArea",component.get("v.unlist")[0].Assignable_Area__c); 
            if(component.get("v.unittype") == 'Residential Units'){
            if(!$A.util.isUndefinedOrNull(result.oppty.Account.Emirates_Ids__c)){
             component.set("v.empDiscount",true);   
            } else {
                component.set("v.empDiscount",false);
            }   
            }
       if(component.get("v.unittype") == 'Residential Units'){
            component.set("v.showUnitFields",true);
            component.set("v.showShopFields",false); 
        }
        //alert(component.get("v.showUnitFields"));
        if(component.get("v.unittype") == 'Residential Shops' ){
            component.set("v.showShopFields",true); 
            component.set("v.showUnitFields",false);    
        }
            var act = component.get("c.showPaymentList");
            act.setParams({
                "unitId": component.get("v.unitId")
            });
            act.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    //alert(JSON.stringify(result));
                    var villaMap = [];
                    for(var key in result){
                        villaMap.push({key: key, value: result[key]});
                    }
                    component.set("v.chequeTypeMap", villaMap);
                }        });
            $A.enqueueAction(act);    
            
        });
        $A.enqueueAction(action);  
    }
    
})