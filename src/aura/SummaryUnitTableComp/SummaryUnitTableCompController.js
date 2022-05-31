({
	doInit : function(component, event, helper) {
        console.log("SummaryUnitTable Component");
        let renewalDate=component.get("v.renewalDate");
        component.set("v.renewalDateDefault",renewalDate);
        console.log('renewalEndDateDefault in init>>>',component.get('v.renewalEndDateDefault'));
        console.log(renewalDate);
		var propertyList=component.get("v.listOfProperty");
        console.log(">>>>",propertyList);
        var pageSize = component.get("v.pageSize");
        
                    var totalRecordsList = propertyList;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfProperty").length > i){
                            PaginationLst.push(propertyList[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
        			console.log('PaginationLst',PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));  
         component.set('v.isShowtable',true);
        //component.set('v.renewalType',null);
       // component.set('v.noOfCheques',null);
        //component.set('v.noOfMonths',null);
	},
    doSave : function(component, event, helper) {
        console.log("call doSaveHelper");
        var renewType=component.get("v.renewalType");
        var renewalEndDate=component.get("v.renewalEndDate");
        var renewalDate=component.get("v.renewalDate");
        var renewalType=component.get("v.renewalType");
        var paymentMode=component.get("v.paymentMode");
        let rentPerDay=component.get("v.rentPerDay");
        let renewalStartDateDefault=component.get("v.renewalDateDefault");    
        let renewalEndDateDefault=component.get("v.renewalEndDateDefault");
        console.log("renewType>>>>>",renewType);
        console.log("renewalEndDate>>>>>",renewalEndDate);
        console.log("renewalEndDateDefault>>>>>",renewalEndDateDefault);
       // if(renewType=='Extension' && renewalEndDate==null ){
            //alert('Error.. Please enter renewal end date for extension');
        //}
        if(renewType=='Extension' && renewalEndDate==null ){
            //alert('Error.. Please enter renewal end date for extension');
             var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Please enter renewal end date for extension",
                            "type": "warning"
                        });
                        toastEvent.fire();
        }
        else if(renewType=='Extension' && renewalDate >= renewalEndDate ){
            //alert('Error.. Please enter renewal end date for extension');
             var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Renewal End date should be greater than lease renewal date ",
                            "type": "warning"
                        });
                        toastEvent.fire();
        }
        else if( renewalDate==null ){
            //alert('Error.. Please enter renewal end date for extension');
             var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Please enter renewal date ",
                            "type": "warning"
                        });
                        toastEvent.fire();
        }
         else if( renewType=='' || renewType==null || renewType==undefined  ){
            //alert('Error.. Please enter renewal end date for extension');
             var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Please enter renewal type ",
                            "type": "warning"
                        });
                        toastEvent.fire();
             
        }
        else if(renewalDate < renewalStartDateDefault){
                var toastEvent = $A.get("e.force:showToast");
            const [year, month, day] = renewalStartDateDefault.split('-');
        		const result = [month, day, year].join('/');
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please enter a valid date as the renewal date cannot be before:- "+result,
                    "type": "warning"
                });
                toastEvent.fire();
                  
            }
        else if(renewType=='Extension' && renewalEndDate > renewalEndDateDefault){
                var toastEvent = $A.get("e.force:showToast");
            const [year, month, day] = renewalEndDateDefault.split('-');
        		const result = [month, day, year].join('/');
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please enter a valid date as the renewal end date cannot be after:- "+result,
                    "type": "warning"
                });
                toastEvent.fire();
            }
        else{
            console.log('before>>>>');
           helper.doSaveHelper(component, event, helper);
            console.log('after>>>>');
        }  
    },
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    doCancel : function(component,event,helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
    },
    navigateToRecord: function(component, event, helper) {
        var recordId = event.target.dataset.caseid;
        window.open('/' + recordId);  
    }
})