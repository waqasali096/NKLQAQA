({
	 checkIFSLAAcheived: function(component, event ) {
        var action = component.get("c.getResponseTime");
          action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var result = response.getReturnValue();
               component.set("v.endTime",result.SLA_Expected_Time_For_Qualified__c );  
                if(result.SLA_Response_Time_For_Qualified__c !=null && result.SLA_Response_Time_For_Qualified__c !=''){
                   component.set("v.checkTime1",true);
                    this.calculateTime(component, event, result, true );
                    $A.get('e.force:refreshView').fire();
                  }
                else{
                   this.calculateTime(component, event, result, false );
                }
                   
                   

                
            }
        });
        $A.enqueueAction(action);
    },
    
    calculateTime: function(component, event, lead, taskAchieved ) {
     //alert('lead is '+ lead );   
      var countDownDate = new Date(component.get("v.endTime")) ;
            var timer = setInterval(function() {
                
                // Get todays date and time
                var now = new Date().getTime();
                // alert('now '+now);
                
                // Find the distance between now and the count down date
                var distance = countDownDate - now;
                
                // Time calculations for days, hours, minutes and seconds
                var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                var seconds = Math.floor((distance % (1000 * 60)) / 1000);
                    var timeLeft1 = lead.SLA_Expected_Time_For_Qualified__c ;
                    console.log('timeLeft1 is '+ timeLeft1);
                    /*if(timeLeft1.includes("-")) {
                        component.set("v.checkTime1",true);
                    }*/
                    
                    
              //  });
                //helper.checkIFSLAAcheived(component, event);
                var timeLeft =  hours + "h " + minutes + "m " + seconds + "s ";
                if(taskAchieved === false){
                    
                    component.set("v.timeLeft",timeLeft);
                    if(timeLeft.includes("-")) {
                        component.set("v.checkTime",true);
                    }
                }else if(taskAchieved === true){
                     var timeDiffrence = new Date(lead.SLA_Expected_Time_For_Qualified__c).getTime() - new Date(lead.SLA_Response_Time_For_Qualified__c).getTime();
                    console.log('timeLeft1 is '+ timeDiffrence);
                    var diff = timeDiffrence.toString(2);
                    console.log('timeLeft2 is '+ diff.includes("-"));
                    if(diff.includes("-")) {
                        component.set("v.slaViolated",true);
                    }
                }
            }, 1000);
      //  });


        
    },
})