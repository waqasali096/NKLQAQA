({
    verifyOTPs : function(component, event, helper) {
        
        var otp = component.get('v.OTP');
        console.log('OTP' , otp);
        var verifyOTP = component.get('v.otpNumber');
        console.log('verifyOTP' , verifyOTP);
        
        if(verifyOTP == otp){
            //alert('OTP verified');
            component.set("v.otpVerified",true);
            component.set("v.mobileVerifyContainer",false);
            component.set("v.otpNotVerified",false);
            component.set("v.updateMobileCheckbox",true);
            component.set("v.isVerifyInProgress",false);
            
        }else {
            //alert('Invalid OTP');
            component.set("v.otpVerified",false);
            component.set("v.otpNotVerified",true);
        }
    },
    
    resendOTP : function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        component.set("v.otpExpired", false);
        
        var action = component.get('c.getOpts'); 
        // method name i.e. getEntity should be same as defined in apex class
        // params name i.e. entityType should be same as defined in getEntity method
        var mobileNumber = component.get("v.mobile");
        var emailAddress = component.get("v.emailad");
        var recordId = component.get("v.recordId");
        
        action.setParams({
            "recordId" : recordId,
            "toMobileNumber" : mobileNumber,
            "templateName" : 'Verify_Customer_OTP',
            "emailAdd": emailAddress
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                $A.util.addClass(spinner, "slds-hide");
                component.set("v.resendButtonDisabled",true);
                component.set("v.showVerifyOTP",true);
                console.log('==result==',a.getReturnValue());
                var result = a.getReturnValue();
                component.set("v.OTP", result);
                console.log('OTP', component.get("v.OTP"));
                component.set("v.sendOTPButton",false);
                component.set("v.resendOTPButton",true);
                
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
                            //alert('Count Down Completed');
                            clearInterval(refreshId);
                            component.set("v.OTP", "");
                            console.log('OTP', component.get("v.OTP"));
                            var countDownOTP = component.get("v.OTP");
                            if(countDownOTP == "" || countDownOTP == null){
                                component.set("v.resendButtonDisabled",false);
                                component.set("v.otpExpired", true);
                                component.set("v.showVerifyOTP",false);
                                component.set("v.otpNotVerified",false);
                                component.set("v.updateMobileCheckbox",false);
                            }
                            $A.get("e.force:closeQuickAction").fire();
                        }
                    },1000);
                }
                
            }
        });
        $A.enqueueAction(action);
    }
})