({
    countDownAction : function(component, event, helper,closeDate) {
        let self = this;
        var interval = window.setInterval(
            $A.getCallback(function() {
                var opptyCloseDate = new Date(closeDate);
                var now_date = new Date();
                var timeDiff = opptyCloseDate.getTime()- now_date.getTime();   
                component.set("v.isValid",true);
                var seconds=Math.floor(timeDiff/1000); // seconds
                var minutes=Math.floor(seconds/60); //minute
                var hours=Math.floor(minutes/60); //hours
                var days=Math.floor(hours/24); //days
                hours %=24; 
                minutes %=60;
                seconds %=60;
                if(minutes>=0){
                    self.checkBookingGenerated(component, event, helper);
                    var stpTimer = component.get("v.stopTimer");
                    //console.log('%%stpTimer'+stpTimer);
                    if(stpTimer){
                        component.set("v.isValid",false); 
                        clearInterval(interval);
                    }else{
                        component.set("v.day",days);
                        component.set("v.hour",hours);
                        component.set("v.minute",minutes);
                        component.set("v.second",seconds);
                    }
                }else if(minutes<=2 && minutes>=0){
                    self.checkBookingGenerated(component, event, helper);
                    var stpTimer = component.get("v.stopTimer");
                    if(stpTimer){
                        component.set("v.isValid",false); 
                        clearInterval(interval);
                    }else{
                        component.set("v.showWarning",true);
                    }
                }else{
                    clearInterval(interval);
                    component.set("v.isValid",false);
                    component.set("v.msg",'Booking Time Expired. Units are released now.');
                    component.set("v.day",0);
                    component.set("v.hour",0);
                    component.set("v.minute",0);
                    component.set("v.second",0); 
                }
                //console.log('%%showWarning'+component.set("v.showWarning"));
            }), 1000);     
    },
    
    checkBookingGenerated: function(component, event, helper) {
        var action = component.get('c.fetchCheckBookingFormGenerated');
        action.setParams({
            "recId":component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var data = response.getReturnValue();
                if(data){
                    component.set("v.isValid",false);
                    component.set("v.stopTimer",true);
                }else{
                    component.set("v.stopTimer",false); 
                    //this.countDownAction(component, event, helper, closeDate);
                }
            }else if(state === 'ERROR'){
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error: " + errors[0].message);
                    } else if (errors.message) {
                        console.log("Error: " + errors.message);
                    }
                } else {
                    console.log("Something went wrong.");
                }
            }
        });
        $A.enqueueAction(action);
    }    
})