({
    doInit : function(component, event, helper) {
        //component.set("v.showWarning",true);
        component.set('v.columnsforexistingUnit', [
            {label: 'Unit Name', fieldName: 'Name', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Location Code', fieldName: 'Unit_Code__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Unit Type', fieldName: 'Unit_type__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Area(sq.ft)', fieldName: 'Internal_Area_Sqft__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Total Area(sq.ft)', fieldName: 'Total_Saleable_Area_Sqft__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Status', fieldName: 'Unit_Status__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'No. of Bedrooms', fieldName: 'No_of_Bedrooms__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Style', fieldName: 'Style__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Unit Price', fieldName: 'Selling_Price__c', type: 'text',wrapText: true,hideDefaultActions: true},
        ]);
            
        let action = component.get("c.fetchQuickBookCloseDate");
        action.setParams({
            "recId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                var oppCloseDt = new Date(result);
                var months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
				var monthName = months[oppCloseDt.getMonth()];
                var dateNumber = oppCloseDt.getDate();
                var yearNumber =  oppCloseDt.getFullYear();
                var closeDateVar = monthName+' '+dateNumber+' '+yearNumber;
                var opptyCloseDate = new Date( oppCloseDt);
                var now_date = new Date();
                var timeDiff = opptyCloseDate.getTime()- now_date.getTime();
                
                 if(timeDiff<=0){
                    component.set("v.isValid",false);
                    component.set("v.msg",'Booking Time Expired. Units are released now.');
                 }else{
                     var seconds=Math.floor(timeDiff/1000); 
                	 var minutes=Math.floor(seconds/60); 
                     //console.log('minutes is: ' +minutes);
                     if(minutes>=0){
                         console.log('%%Component Minutes');
                         helper.countDownAction(component, event, helper, opptyCloseDate);
                         //helper.checkBookingGenerated(component, event, helper, opptyCloseDate);
                     }else if(minutes<=2 && minutes>=0){
                         component.set("v.showWarning",true);
                     }else{
                         component.set("v.isValid",false);
                         component.set("v.msg",'Booking Time Expired. Units are released now.');
                     }
                     //helper.handleSelectedUnits(component, event,helper);
                 }
            }
        });
        $A.enqueueAction(action);
    }
})