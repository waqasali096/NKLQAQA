({
    doInit: function(component, event, helper) {
        helper.fetchTimeOutMinutes(component, event, helper);
        
        //$A.get("e.force:closeQuickAction").fire();
        var action = component.get('c.getAccount');
        var recordId = component.get("v.recordId");
        action.setParams({
            "AccountId": recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state', state);
            var result = JSON.stringify(response.getReturnValue());
            console.log('result', result);
            console.log('isValid', component.isValid());
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.accLst", response.getReturnValue());
                var accLst = component.get('v.accLst');
                console.log('accLst', accLst);
                var cCode = accLst[0].Primary_Country_Code__c;
                var isPersonAccount = accLst[0].RecordType.DeveloperName;
                console.log('isPersonAccount'+isPersonAccount);
                if(isPersonAccount == 'PersonAccount'){
                    component.set("v.isPersonAccount", true);
                }else{
                    component.set("v.isPersonAccount", false);
                }
                var mNumber = accLst[0].Primary_Mobile__c;
                var mobNumber = '+'+cCode+mNumber;
                var email = accLst[0].Primary_Email__c;
                component.set("v.primaryMobileNumber", mobNumber);
                
                console.log('mobNumber', component.get('v.primaryMobileNumber'));
                component.set("v.primaryEmail", email);
                console.log('email', component.get('v.primaryEmail'));
                component.set("v.customerName", accLst[0].Name);
                console.log('v.accLst', v.accLst);
                console.log('v.customerName', accLst[0].Name);
            }
        });
        $A.enqueueAction(action);
    },
    sendOTP : function(component, event, helper) {
        helper.sendOTP(component, event, helper);
        //helper.startCountDownTime(component, event, helper);
    },
    
    /*resendOTP : function(component, event, helper) {
        helper.resendOTP(component, event, helper);
        //helper.startCountDownTime(component, event, helper);
    },*/
    verifyOTP : function(component, event, helper) {
        var delayInMilliseconds = 500; //0.5 seconds
        window.setTimeout(
            $A.getCallback(function() {
                helper.verifyOTP(component, event, helper);
            }), delayInMilliseconds
        );
    },
    /*onCheck : function(component, event, helper) {
        var delayInMilliseconds = 700; //0.7 seconds
        window.setTimeout(
            $A.getCallback(function() {
                helper.onCheck(component, event, helper);
            }), delayInMilliseconds
        );  
    },
    handleOnLoad : function(component, event, helper) {
        
    },
    
    handleOnSubmit : function(component, event, helper) {
        
    },
    
    handleOnSuccess : function(component, event, helper) {
        component.set("v.reloadForm", false);
        component.set("v.reloadForm", true);
        $A.get("e.force:closeQuickAction").fire();  
        $A.get('e.force:refreshView').fire();
        helper.showToast(component, event, helper);
    },
    
    handleOnError : function(component, event, helper) {
        
    },*/
    
    /*handleSubmitButtonClick : function(component, event, helper) {
        //component.find("editForm").submit();
        event.preventDefault();
        helper.handleFormSubmit(component);
    },*/
    
    cancel : function(component, event, helper) {        
        if(component.get("v.calledFromNewDeal") == true){
            var compEvent = component.getEvent("leasingOppAccountOTPVerificationEvent");
            compEvent.setParams({"showOTPModal" : false});
            compEvent.setParams({"validOTP" : false});
            compEvent.fire();
        }
        
        if(component.get("v.calledFromNewDeal") == false){
            $A.get("e.force:closeQuickAction").fire();            
        }
    },
    // this function automatic call by aura:waiting event  
    /*showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
    toggle: function (component, event, helper) {
        var selectedNumber = component.get("v.selectedNumber");
        if (selectedNumber == "None"){
            component.set("v.primarySelected", false);
            component.set("v.secondarySelected", false);
            component.set("v.tertiarySelected", false);
            
            component.set("v.mobileCategorySelectedSaveButton", false);
        }
        else if (selectedNumber == "Primary") {
            component.set("v.primarySelected", true);
            component.set("v.secondarySelected", false);
            component.set("v.tertiarySelected", false);
            component.set("v.mobileCategorySelectedSaveButton", true);
        }
            else if(selectedNumber == "Secondary"){
                component.set("v.primarySelected", false);
                component.set("v.secondarySelected", true);
                component.set("v.tertiarySelected", false);
                component.set("v.mobileCategorySelectedSaveButton", true);
            }
                else if(selectedNumber == "Tertiary"){
                    component.set("v.primarySelected", false);
                    component.set("v.secondarySelected", false);
                    component.set("v.tertiarySelected", true);
                    component.set("v.mobileCategorySelectedSaveButton", true);
                }
    },
    startTimer : function(component, event, helper) {
        var countDownDate = new Date(component.get("v.endTime"));
        
        console.log('==countDownDate==',countDownDate);
        // Update the count down every 1 second
        var timer = setInterval(function() {
            
            // Get todays date and time
            var now = new Date().getTime();
            console.log('==now==',now);
            
            // Find the distance between now and the count down date
            var distance = now - countDownDate;
            
            // Time calculations for days, hours, minutes and seconds
            var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            var seconds = Math.floor((distance % (1000 * 60)) / 1000);
            
            // Display the result in the element with id="demo"
            var timeLeft =  minutes + "m " + seconds + "s ";
            component.set("v.timeLeft", timeLeft);
        }, 1000);
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },*/
    
})