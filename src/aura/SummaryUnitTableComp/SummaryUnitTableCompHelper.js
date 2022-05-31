({
    doSaveHelper : function(component, event, helper){
        console.log('doSaveHelper SummaryUnitTable Hlper');
         var action = component.get("c.createOpp1");
        action.setParams({ 
            listPropWrapper : component.get('v.listOfProperty'),
            listPropForTermination: component.get('v.terminationUnitsList'),
            renewalDate : component.get('v.renewalDate'),
            renewalType : component.get('v.renewalType'),
            renewalEndDate : component.get('v.renewalEndDate'),
            noOfCheques : component.get('v.noOfCheques'),
            ejariNeeded: component.get('v.ejariNeeded'),
            paymentMode: component.get('v.paymentMode'),
            flag: component.get('v.flag')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state>>>>',state);
            
            if (state === "SUCCESS"){
                var oppRes = response.getReturnValue();
                debugger;
                console.log('oppRes>>>>>',oppRes);
                //console.log('oppRes',oppRes.id);                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": oppRes  
                 
                });
                navEvt.fire();
            }
            else{
                alert('Error....');
            }
            
        });
        $A.enqueueAction(action);
    }
})