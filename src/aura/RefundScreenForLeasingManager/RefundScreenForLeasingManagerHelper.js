({
    fetchCaseDetails : function(component, event, recordId) {
        var action = component.get("c.getCaseDetails");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {   
              var result = response.getReturnValue();
              console.log('result '+ JSON.stringify(result));
              component.set("v.caseObj",result);
              component.set("v.numberOfMonthsRentDeduction",result.No_of_Mths_Rent_Deduction__c);
              component.set("v.penaltyCharges",result.Penalty_charges__c);
              if(result.Refund_Applicable__c === 'Yes'){
                component.set('v.refundApplicable','Yes');
                component.set("v.refundApplicableValue",result.Refund_Applicable__c);
              }else if(result.Refund_Applicable__c === 'No'){
                component.set('v.refundApplicable','No');
                component.set("v.refundApplicableValue",result.Refund_Applicable__c);
              }
          }
        });
        $A.enqueueAction(action);
    }
})