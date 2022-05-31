({
    doInit : function(component, event, helper) {
    },
    /*sendOTP : function(component, event, helper) {//commented by Mamta- Functionality not required
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        var action = component.get('c.getOpts'); 
        
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
                component.set("v.showVerifyOTP",true);
                console.log('==result==',a.getReturnValue());
                var result = a.getReturnValue();
                component.set("v.OTP", result);
                console.log('OTP', component.get("v.OTP"));
                component.set("v.sendOTPButton",true);
                component.set("v.sendButtonDisabled",true);
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
                            //alert('Count Down Completed');
                            clearInterval(refreshId);
                            component.set("v.OTP", "");
                            component.set("v.sendOTPButton",false);
                            component.set("v.resendOTPButton",true);
                            console.log('OTP', component.get("v.OTP"));
                            var countDownOTP = component.get("v.OTP");
                            if(countDownOTP == "" || countDownOTP == null){
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
    },
    verifyOTP : function(component, event, helper) {
        var delayInMilliseconds = 700; //0.7 seconds
        window.setTimeout(
            $A.getCallback(function() {
                helper.verifyOTPs(component, event, helper);
            }), delayInMilliseconds
        ); 
    },
    resendOTP : function(component, event, helper) {
        helper.resendOTP(component, event, helper);
        //helper.startCountDownTime(component, event, helper);
    },*/
    searchRecord : function(component, event, helper) {
        var email = component.get('v.email');
        var brokerNumber = component.get('v.brokerNumber');
        //var phoneCode = component.get('v.phoneCode');
        //var phone = component.get('v.phone');
        
        console.log('email', email);
        //console.log('phoneCode', phoneCode);
        //console.log('phone', phone);
        
        if(email === ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type": "Error",
                "message": 'Please Enter Email'
            });
            toastEvent.fire();
        }else if(brokerNumber === ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type": "Error",
                "message": 'Please Enter Agency Registration System Generated number sent over the email'
            });
            toastEvent.fire();
        }
        /*else if(phoneCode === ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type": "Error",
                "message": 'Please Enter Mobile Country Code'
            });
            toastEvent.fire();
        }else if(phone === ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type": "Error",
                "message": 'Please Enter Mobile'
            });
            toastEvent.fire();
        }*/else{
            var action = component.get("c.getAgencyRecord");        
            action.setParams({
                "email": email,
                "brokerNumber" : brokerNumber,
                //"phoneCode": phoneCode,
                //"phone": phone
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state', state);
                if (state === "SUCCESS") {
                    var response  = response.getReturnValue();
                    console.log('response==', response);
                    if(response === null){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "type": "Error",
                            "message": 'Sorry, we did not find any registration with this email/Registration Number'
                        });
                        toastEvent.fire();
                    }else{
                        console.log(JSON.stringify(response));
                        console.log('response.Id is '+ response.Id);
                        component.set('v.recordId', response.Id);
                        component.set('v.isVerifyInProgress', false); // Made true to false, because OTP functionality is not required. - Waqas
						component.set('v.mobile', response.Mobile_Country_Code__c+response.Mobile__c);
                        component.set('v.emailad', response.Email_Address__c);
                        
                        console.log('==response==', component.get("v.recordId"));
                        console.log('==mobile==', component.get("v.mobile"));
                        console.log('==email==', component.get("v.emailad"));
                    }
                }else if (response.getState() === "ERROR"){                    
                    var errors = action.getError();                    
                    if (errors) {                        
                        if (errors[0] && errors[0].message) {                            
                            console.log('==error==',errors[0].message);                           
                        }                        
                    }
                    
                }
            });
            $A.enqueueAction(action);
        }
    },
})