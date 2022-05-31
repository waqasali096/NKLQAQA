({
	leaseSplOfferScreenComponentVisibility : function(component, event, helper) {
		//alert('Call');
		console.log('@@@@leaseSplOfferScreenComponentVisibility');
        var action = component.get("c.checkTaggedUnits");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('>>>>>response',state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result === true){
                    component.set("v.leaseSplOfferScreenDisable",true);
                }else{
                    component.set("v.leaseSplOfferScreenDisable",false);
                }
            }
        });
        $A.enqueueAction(action);
	},
    getSplOffers : function(component, event, helper) {
        console.log('@@@@getSplOffers helper');
         var action = component.get("c.getOffers");
        action.setParams({ 
            recordId : component.get('v.recordId')
        
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            
            if (state === "SUCCESS"){
                var splOffrRes = response.getReturnValue();
                debugger;
                console.log('splOffrRes>>>>',splOffrRes);
				let splOfferAppliedFlag=splOffrRes.offersAppliesFlag;
                console.log('splOfferAppliedFlag>>>>',splOfferAppliedFlag);
                let errorFlag=splOffrRes.errorFlag;
                console.log('errorFlag>>>>',errorFlag);
                
                if(errorFlag==true){
                    let errorMsg=splOffrRes.msg;
                    component.set('v.errorMsg',errorMsg);
                    component.set('v.noRcdFoundSplOffTblFlag',true);
                    console.log('errorMsg>>>>',errorMsg);
                   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": errorMsg,
                        "type": "error"
                    });
                    toastEvent.fire(); 
                }
                else if(splOfferAppliedFlag ==true){
                    let appliedOfferList=splOffrRes.appliedOfferList;
                    console.log('appliedOfferList',appliedOfferList);
                    component.set('v.selectedOffer',appliedOfferList);
            		component.set('v.hideResultTblFlag',false);
            		component.set('v.SplOffTblFlag',true);
                }
                else if(splOfferAppliedFlag ==false){
                    let splOfferList=splOffrRes.splOfferList;
                    if(splOfferList.length >0){
                        component.set("v.totalRecordsCount",splOfferList.length);
                component.set("v.splOfferList",splOfferList); 
                    component.set("v.noRcdFoundSplOffTblFlag",false);
                    }
                    else{
                    component.set("v.totalRecordsCount",0);
                    component.set("v.noRcdFoundSplOffTblFlag",true);
                }
                   
                }
                
                
            }
            else{
                alert('Error....');
            }
            
        });
        $A.enqueueAction(action);
    },
    saveAppliedOffer : function(component, event, helper) {
        console.log('@@@@saveAppliedOffer helper');
        let selectedOffer=component.get('v.selectedOffer');
        let selectOffId=selectedOffer[0].splOfferId;
        console.log('selectOffId>>>>>',selectOffId);
         var action = component.get("c.saveAppliedOffer1");
        action.setParams({ 
            offerId : selectOffId,
            oppId : component.get('v.recordId')
        
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            
            if (state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Offer applied successfully.",
                        "type": "info"
                    });
                    toastEvent.fire();
                
            }
            else{
                 var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error in offer application.Please contact System Admin.",
                        "type": "error"
                    });
                    toastEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
        
    },
    deleteAppliedOffer : function(component, event, helper) {
        console.log('@@@@deleteAppliedOffer helper');
        
         var action = component.get("c.deleteAppliedOffer1");
        action.setParams({ 
            opp : component.get('v.recordId')
        
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            
            if (state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Offer applied deleted successfully.",
                        "type": "info"
                    });
                    toastEvent.fire();
                
            }
            else{
                 var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error in offer deletion.Please contact System Admin.",
                        "type": "error"
                    });
                    toastEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
    }
})