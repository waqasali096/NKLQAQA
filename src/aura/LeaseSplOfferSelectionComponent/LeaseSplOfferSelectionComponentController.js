({
    doInit : function(component, event, helper) {
        //Check id component should be visiable
        console.log('@@@Inside Init LeaseSPLOffer comp');
         component.set('v.hideResultTblFlag',true);
        helper.leaseSplOfferScreenComponentVisibility(component,event,helper);
        //get the Columns for ther list
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'Name',sortable: true, type: 'text'},
            {label: 'Start Date', fieldName: 'Start_Date__c',sortable: true, type: 'text'},
            {label: 'End Date', fieldName: 'End_Date__c',sortable: true, type: 'text'},
            {label: 'Project', fieldName: 'Project__c',sortable: true, type: 'text'},
            {label: 'Property Type', fieldName: 'Property_Type__c',sortable: true, type: 'text'},
            {label: 'Unit Type', fieldName: 'Unit_Type__c',sortable: true, type: 'text'},
            {label: 'No of Bedrooms ', fieldName: 'No_of_Bedrooms__c',sortable: true, type: 'text'},
            {label: 'Rent Free Days', fieldName: 'Rent_Free_Days__c',sortable: true, type: 'text'},
            {label: 'Security Deposit Percentage', fieldName: 'Security_Deposit_Percentage__c',sortable: true, type: 'text'},
        ]);
            helper.getSplOffers(component,event,helper);   
            },
            
  addOffer : function(component, event, helper) {
            	console.log('@@AddOffer Method @@@@');
            let selectedOffer =[];
                      let offerList=component.get('v.splOfferList');
        console.log('offerList>>>>',offerList);
        for(let i=0; i<offerList.length; i++){
            if(offerList[i].isChecked==true){
                selectedOffer.push(offerList[i]);
            }
        }
        console.log('selectedOffer>>>>>',selectedOffer);
        if(selectedOffer.length >0){
            component.set('v.selectedOffer',selectedOffer);
            component.set('v.hideResultTblFlag',false);
            component.set('v.SplOffTblFlag',true);
            console.log('hideResultTblFlag>>>',component.get('v.hideResultTblFlag'));
            helper.saveAppliedOffer(component,event,helper); 
        }
        else{
            component.set('v.SplOffTblFlag',false);
            component.set('v.hideResultTblFlag',true);
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please select a special offer before saving it.",
                        "type": "error"
                    });
                    toastEvent.fire();
        }
        
        
            	
    },
removeOffer : function(component, event, helper) {
    let blankList=[];
  	component.set('v.hideResultTblFlag',true);
    component.set('v.selectedOffer',blankList);
    component.set('v.splOfferLst',blankList);
    component.set('v.SplOffTblFlag',false);
     helper.deleteAppliedOffer(component,event,helper); 
    /*let splOfferLst=component.get('v.splOfferList');
    for(let i=0;i<splOfferLst;i++){
        splOfferLst[i].isChecked=false;
    }*/
    //component.set('v.splOfferList',splOfferLst);
     doInit(component, event, helper);
     
     
}
})