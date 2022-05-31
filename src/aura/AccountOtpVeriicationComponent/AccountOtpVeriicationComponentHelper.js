({
    /*callsendOTP: function(component, event, helper) {
        console.log('==methodcalled==');
        component.set("v.showLoadingSpinner", true);
        //sendOTP(String customerName, String toMobileNumber, String templateName)
        var mobileNumber = component.find('mobileNumber').get('v.value');
        var customerName = component.get('v.customerName');
        var action = component.get("c.sendOTP");
        action1.setParams({
            customerName: customerName,
            toMobileNumber: mobileNumber,
            templateName: 'Pet_Registration'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('==state==',state);
            if (state === "SUCCESS") {
                console.log('==opt==',response.getReturnValue());
                component.set("v.OTP", response.getReturnValue());
                component.set("v.showLoadingSpinner", false);
                
            } else if (state === "INCOMPLETE") {
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
        });
        $A.enqueueAction(action); 
    },*/
    
    /*handleFormSubmit: function(component) {
        var showValidationError = false;
        var fields = component.find("field");
        var vaildationFailReason = '';
        var phoneRegexFormat = /^\d{10}$/;
        
        fields.forEach(function (field) {
            if(field.get("v.fieldName") === 'Primary_Country_Code__c' && $A.util.isEmpty(field.get("v.value"))){
                showValidationError = true;
                vaildationFailReason = "Please Enter Primary Code";
            }else if (field.get("v.fieldName") === 'Primary_Mobile__c' && $A.util.isEmpty(field.get("v.value"))){
                showValidationError = true;
                vaildationFailReason = "Please Enter Primary Mobile";
            }else if (field.get("v.fieldName") === 'Secondary_Country_Code__c' && $A.util.isEmpty(field.get("v.value"))){
                showValidationError = true;
                vaildationFailReason = "Please Enter Secondary Code";
            }else if (field.get("v.fieldName") === 'Secondary_Mobile__c' && $A.util.isEmpty(field.get("v.value"))){
                showValidationError = true;
                vaildationFailReason = "Please Enter Secondary Mobile";
            }else if (field.get("v.fieldName") === 'Tertiary_Country_Code__c' && $A.util.isEmpty(field.get("v.value"))){
                showValidationError = true;
                vaildationFailReason = "Please Enter Tertiary Mobile";
            }else if (field.get("v.fieldName") === 'Tertiary_Phone__c' && $A.util.isEmpty(field.get("v.value"))){
                showValidationError = true;
                vaildationFailReason = "Please Enter Tertiary Code";
            }else if(field.get("v.fieldName") === 'Primary_Mobile__c' && !field.get("v.value").match(phoneRegexFormat)){
                showValidationError = true;
                vaildationFailReason = "Please Enter Valid Mobile Number";
            }else if(field.get("v.fieldName") === 'Secondary_Mobile__c' && !field.get("v.value").match(phoneRegexFormat)){
                showValidationError = true;
                vaildationFailReason = "Please Enter Valid Mobile Number";
            }else if(field.get("v.fieldName") === 'Tertiary_Phone__c' && !field.get("v.value").match(phoneRegexFormat)){
                showValidationError = true;
                vaildationFailReason = "Please Enter Valid Mobile Number";
            }
        });
        
        if (!showValidationError) {
            component.set('v.loading', true);
            component.find("editForm").submit();  
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({ 
                "title": "Error",
                "type":"Error",
                "message": vaildationFailReason
            });
            toastEvent.fire();
        }
    },*/
    
    fetchTimeOutMinutes : function(component, event, helper) {
        var action = component.get('c.getTimeOutMinutes');        
        action.setParams({
            "strHandlerName": "OTP_Verification"
        });        
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                var result = a.getReturnValue();
                component.set("v.minutes", result);
            }
        });
        $A.enqueueAction(action);
    },
    
    sendOTP : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        var action = component.get('c.getOpt'); 
        component.set("v.otpExpired", false);
        component.set("v.otpNumber", "");
        // method name i.e. getEntity should be same as defined in apex class
        // params name i.e. entityType should be same as defined in getEntity method
        var mobileNumber = component.get('v.primaryMobileNumber');
        var customerName = component.get('v.customerName');
        if(customerName == undefined || customerName == ''){
            
        }
        var AccountId = component.get('v.recordId');
        console.log('customerName' , customerName);
        action.setParams({
            "AccountId": AccountId,
            "customerName" : customerName,
            "toMobileNumber" : mobileNumber//,
            //"templateName" : 'Account_Otp_Verification'
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                $A.util.addClass(spinner, "slds-hide");
                component.set("v.showVerifyOTP",true);
                component.set("v.showTimeLeft",true);
                console.log('==result==',a.getReturnValue());
                var result = a.getReturnValue();
                component.set("v.OTP", result);
                console.log('OTP', component.get("v.OTP"));
                component.set("v.sendOTPButton",false);
                //component.set("v.sendButtonDisabled",true);
                component.set("v.resendOTPButton",false);
                
                var minutes = component.get('v.minutes');
                if(minutes != null && minutes > 0){
                    component.set('v.countDownMinutes', minutes - 1);
                    component.set('v.countDownSeconds', 60);
                    
                    var refreshId = setInterval(function(){
                        var countDownMinutes = component.get('v.countDownMinutes');
                        var countDownSeconds = component.get('v.countDownSeconds');
                        
                        if(countDownSeconds == 0){
                            component.set('v.countDownMinutes', countDownMinutes - 1);
                            component.set('v.countDownSeconds', 60);
                        }else {
                            component.set('v.countDownSeconds', countDownSeconds - 1);
                        }
                        
                        var minutes = component.get('v.countDownMinutes');
                        var seconds = component.get('v.countDownSeconds');
                        
                        
                        var timeLeft =  minutes + "m " + seconds + "s ";
                        component.set("v.timeLeft", timeLeft);
                        
                        
                        if(minutes == 0 && seconds == 0){
                            clearInterval(refreshId);
                            component.set("v.OTP", "");
                            component.set("v.sendOTPButton",false);
                            component.set("v.resendOTPButton",false);
                            console.log('OTP', component.get("v.OTP"));
                            var countDownOTP = component.get("v.OTP");
                            if(countDownOTP == "" || countDownOTP == null){
                                component.set("v.otpExpired", true);
                                component.set("v.showVerifyOTP",false);
                                component.set("v.showTimeLeft",false);
                                component.set("v.otpNotVerified",false);
                                component.set("v.resendOTPButton",true);
                                //component.set("v.updateMobileCheckbox",false);
                            }
                            //$A.get("e.force:closeQuickAction").fire();
                        }
                    },1000);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    /*resendOTP : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        component.set("v.otpExpired", false);
        component.set("v.otpNumber", "");
        
        var action = component.get('c.getOpt'); 
        // method name i.e. getEntity should be same as defined in apex class
        // params name i.e. entityType should be same as defined in getEntity method
        var mobileNumber = component.get('v.primaryMobileNumber');
        var customerName = component.get('v.customerName');
        var AccountId = component.get('v.recordId');
        console.log('customerName' , customerName);
        action.setParams({
            "AccountId": AccountId,
            "customerName" : customerName,
            "toMobileNumber" : mobileNumber,
            //"templateName" : 'Verify_Customer_OTP'
            "templateName" : 'Account_Otp_Verification'
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                $A.util.addClass(spinner, "slds-hide");
                //component.set("v.resendButtonDisabled",true);
                component.set("v.showVerifyOTP",true);
                component.set("v.showTimeLeft",true);
                console.log('==result==',a.getReturnValue());
                var result = a.getReturnValue();
                component.set("v.OTP", result);
                console.log('OTP', component.get("v.OTP"));
                component.set("v.sendOTPButton",false);
                component.set("v.resendOTPButton",false);
                
                var minutes = component.get('v.minutes');
                if(minutes != null && minutes > 0){
                    component.set('v.countDownMinutes', minutes - 1);
                    component.set('v.countDownSeconds', 60);
                    
                    var refreshId = setInterval(function(){
                        var countDownMinutes = component.get('v.countDownMinutes');
                        var countDownSeconds = component.get('v.countDownSeconds');
                        
                        if(countDownSeconds == 0){
                            component.set('v.countDownMinutes', countDownMinutes - 1);
                            component.set('v.countDownSeconds', 60);
                        }else {
                            component.set('v.countDownSeconds', countDownSeconds - 1);
                        }
                        
                        var minutes = component.get('v.countDownMinutes');
                        var seconds = component.get('v.countDownSeconds');
                        console.log('minutes', minutes);
                        console.log('seconds', seconds);
                        
                        var timeLeft =  minutes + "m " + seconds + "s ";
                        component.set("v.timeLeft", timeLeft);
                        console.log('timeLeft', component.get('v.timeLeft'));
                        
                        if(minutes == 0 && seconds == 0){
                            clearInterval(refreshId);
                            component.set("v.OTP", "");
                            console.log('OTP', component.get("v.OTP"));
                            var countDownOTP = component.get("v.OTP");
                            if(countDownOTP == "" || countDownOTP == null){
                                //component.set("v.resendButtonDisabled",false);
                                component.set("v.otpExpired", true);
                                component.set("v.showVerifyOTP",false);
                                component.set("v.showTimeLeft",false);
                                component.set("v.otpNotVerified",false);
                                component.set("v.resendOTPButton",true);
                                //component.set("v.updateMobileCheckbox",false);
                            }
                            $A.get("e.force:closeQuickAction").fire();
                        }
                    },1000);
                }
                
            }
        });
        $A.enqueueAction(action);
    },*/
    
    verifyOTP : function(component, event, helper) {
        var AccountId = component.get('v.recordId');
        var otp = component.get('v.OTP');
        console.log('OTP' , otp);
        var verifyOTP = component.get('v.otpNumber');
        console.log('verifyOTP' , verifyOTP);
        
        if(verifyOTP == otp){
            component.set("v.otpVerified",true);
            component.set("v.mobileVerifyContainer",false);
            component.set("v.otpNotVerified",false);
            component.set("v.showVerifyOTP",true);
            component.set("v.showTimeLeft",false);
            component.set("v.timeLeft", "");
            
            var isPerson = component.get("v.isPersonAccount");
            if(isPerson){
                component.set("v.updateMobileCheckbox",false);
            }else{
                // component.set("v.updateMobileCheckbox",true);
            }
            //update the oyp verified flag on the record
            console.log('update the otp Verified flag on customer');
            var action = component.get('c.updateAccOtpVerifyFlag');
            action.setParams({
                "accId": AccountId            
            });
            action.setCallback(this, function(a){
                var state = a.getState();
                console.log('state>>>>>>>>>',state);
                if(state == 'SUCCESS') {
                    console.log('OTP Verified- successfuly flag updated on customer');
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "OTP Verified - Your mobile number is verified!",
                        "type": "success"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    
                    if(component.get("v.calledFromNewDeal") == true){
                        var compEvent = component.getEvent("leasingOppAccountOTPVerificationEvent");
                        compEvent.setParams({"showOTPModal" : false});
                        compEvent.setParams({"validOTP" : true});
                        compEvent.fire();
                    }            
                }
                else{
                    console.log('OTP Verified- failed flag updated on customer');
                }
                
            });
            $A.enqueueAction(action);
        }else {
            component.set("v.otpVerified",false);
            component.set("v.otpNotVerified",true);
            component.set("v.showVerifyOTP",true);
            component.set("v.showTimeLeft",true);
                        
            if(component.get("v.calledFromNewDeal") == true){
                var compEvent = component.getEvent("leasingOppAccountOTPVerificationEvent");
                compEvent.setParams({"showOTPModal" : true});
                compEvent.setParams({"validOTP" : false});
                compEvent.fire();
            }    
        }
    },
    
    /*onCheck : function(component, event, helper) {
        component.set("v.otpVerified",false);
        component.set("v.updateMobileNumber",true);
        /*var checkbox = component.find('checkbox').get('v.value');
        console.log('checkbox', checkbox);
        
        if(checkbox == true) {
            component.set("v.otpVerified",false);
            component.set("v.updateMobileNumber",true);
        }else {
            component.set("v.updateMobileNumber",false);
        }*/
        
    //},
    /*showToast : function(component, event, helper) {
        console.log('Inside Show Toast');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully.",
            "type": "success"
        });
        toastEvent.fire();
    },*/
    /*startCountDownTime : function(component, event, helper) {
        var minutes = component.get('v.minutes');
        if(minutes != null && minutes > 0){
            component.set('v.countDownMinutes', minutes - 1);
            component.set('v.countDownSeconds', 60);
            
            var refreshId = setInterval(function(){
                var countDownMinutes = component.get('v.countDownMinutes');
                var countDownSeconds = component.get('v.countDownSeconds');
                
                if(countDownSeconds == 0){
                    component.set('v.countDownMinutes', countDownMinutes - 1);
                    component.set('v.countDownSeconds', 60);
                }else {
                    component.set('v.countDownSeconds', countDownSeconds - 1);
                }
                
                var minutes = component.get('v.countDownMinutes');
                var seconds = component.get('v.countDownSeconds');
                console.log('minutes', minutes);
                console.log('seconds', seconds);
                
                var timeLeft =  minutes + "m " + seconds + "s ";
                component.set("v.timeLeft", timeLeft);
                console.log('timeLeft', component.get('v.timeLeft'));
                
                if(minutes == 0 && seconds == 0){
                    clearInterval(refreshId);
                    $A.get("e.force:closeQuickAction").fire();
                }
            },1000);
        }
    }*/
})