({
    
    doInit : function(component, event, helper) {
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        component.set("v.todayDate",todayFormattedDate);
        component.set("v.isSpinner", true);  
        var action = component.get("c.getUnitInfo");
        action.setParams({
            'oppId' : component.get("v.recordId"),
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();
                console.log('data',resultData);
                if(resultData.unitExist){
                    component.set("v.hasUnit", true);
                    if(resultData.discountApproved){
                        component.set("v.discountApproved", true);
                        //helper.getMilestonePoint(component, event);
                        helper.getInstallments(component, event);
                        component.set("v.documentId", resultData.documentId);
                        component.set("v.bookingList", resultData.oppResult);
                        component.set("v.totalPrice", resultData.oppResult[0].netSellingPrice);
                        component.set("v.bookingReservationDate", resultData.oppResult[0].bookingReservationDate);
                        component.set("v.requestedPaymentMilestones", resultData.pmResult);
                        component.set("v.originalPaymentMilestones", resultData.omResult);
                        helper.calculateTotalPercentage(component, event);
                    }else{
                        component.set("v.discountApproved", false);
                    }
                    
                }else{
                    component.set("v.hasUnit", false);
                }
            }
            else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    this.showErrorMsg(component,event,'Something went wrong, please try again.'); 
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
            component.set("v.isSpinner", false); 
        });
        $A.enqueueAction(action);
    },

    onFileUpload : function(component, event, helper) {
        const uploadedFiles = event.getParam("files");
        console.log("uploadedFiles : " +JSON.stringify(uploadedFiles) );
        if (event.getParam("files").length > 0) {
            component.set("v.fileName", uploadedFiles[0].name);
            component.set("v.conDocId", uploadedFiles[0].documentId);
            component.set("v.showFileName", true);                   
        }
    },
    handleRemoveDoc : function(component, event, helper){ 
        var action = component.get("c.deleteContentDoc");
        action.setParams({ 
            "conDocId" : component.get("v.conDocId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                component.set("v.fileName", undefined);
                component.set("v.conDocId", undefined);
                component.set("v.showFileName", false);
            }else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    this.showToastMessage('Error!','Something went wrong, please try again.','Error');
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
        });
        $A.enqueueAction(action);  
    },
    deleteAllRows : function(component, event, helper) {
        var setRows = [];
        for ( var i = 0; i < component.get("v.requestedPaymentMilestones").length; i++ ) {
            if(component.get("v.requestedPaymentMilestones")[i].Id != undefined){
                setRows.push(component.get("v.requestedPaymentMilestones")[i].Id);
            }
        }
        component.set("v.deleteList", setRows);
        component.set('v.requestedPaymentMilestones', []);
        helper.calculateTotalPercentage(component, event);   
    },
    
    showErrorMsg : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message:message,
            type: 'error'
        });
        component.set("v.isSpinner", false);  
        toastEvent.fire();
    },
    
    addRow : function(component, event, helper) {
        var numOfInstallments = component.get('v.numofInstallments');    
        var mileStoneList = component.get('v.requestedPaymentMilestones');           
        var newReqPyaPlansList = [];
        for ( var i = 0; i < mileStoneList.length; i++ ) {
            newReqPyaPlansList.push(mileStoneList[i]);
        }
        
        for(var i=0; i< numOfInstallments;i++){
            var newReq = new Object();
            newReq.amountPercent = 0;
            newReq.amount = 0;
            newReq.milestone = '';
            newReq.dueInDays = '';
            newReq.dueDate=  '';
            newReqPyaPlansList.push(newReq); 
        }
        component.set('v.requestedPaymentMilestones', newReqPyaPlansList); 
        helper.calculateTotalPercentage(component, event); 
    },
    
    removeRow: function(component, event, helper) {
        var requestMileList = component.get("v.requestedPaymentMilestones");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        var dataId = requestMileList[index].Id;
        if(dataId != undefined){
            var setRows = [];
            setRows.push(dataId);
            for ( var i = 0; i < component.get("v.deleteList").length; i++ ) {
                setRows.push(component.get("v.deleteList")[i]);
            }
            component.set("v.deleteList", setRows);
        }
        console.log(component.get("v.deleteList"));
        requestMileList.splice(index, 1);
        component.set("v.requestedPaymentMilestones", requestMileList);
        
        helper.calculateTotalPercentage(component, event);
    },
    
    onInstallmentChange:function(component, event, helper) {
        var rowIndex=event.getSource().get("v.value");
        var index =  event.getSource().get("v.label");
        var reqPayLst = component.get("v.requestedPaymentMilestones"); 
        console.log('reqPayLst ', reqPayLst);         
        component.set('v.requestedPaymentMilestones', reqPayLst);
    },
    
    onDateChange:function(component, event, helper) {
        var bookingReservationDate = component.get("v.bookingReservationDate");
        if(bookingReservationDate != undefined){
            var index = event.getSource().get("v.label");
            var selectedDateValue = event.getSource().get("v.value");
            console.log(selectedDateValue);
            var Difference_In_Time = new Date(selectedDateValue).getTime() - new Date(bookingReservationDate).getTime();
            var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
            var reqPayLst = component.get("v.requestedPaymentMilestones");
            for(let i=0; i < index; i++){
                if( selectedDateValue <= reqPayLst[i].dueDate ){
                    reqPayLst[index].maxDate = true;
                    break;
                }else{
                    reqPayLst[index].maxDate = false;
                }
            }
            reqPayLst[index].dueInDays = Difference_In_Days;
            component.set('v.requestedPaymentMilestones', reqPayLst);
        }
        
    },
    
    onDueDaysChange:function(component, event, helper) {
        var index =  event.currentTarget.dataset.rowIndex;// event.getSource().get("v.name");  
        var reqPayLst = component.get("v.requestedPaymentMilestones");
        console.log('bookingReservationDate=> ', component.get("v.bookingReservationDate"));
        var bookingReservationDate = component.get("v.bookingReservationDate");
        var dueDays = reqPayLst[index].dueInDays;
        if(dueDays == null || dueDays == ''){
            dueDays = 0;
        }
        if(bookingReservationDate != undefined){
            var resultDate = new Date(bookingReservationDate);
            var conDate = new Date(resultDate.setDate(resultDate.getDate() + parseInt(dueDays))).toJSON();
            reqPayLst[index].dueDate = conDate.split('T')[0];
        }
        console.log('reqPayLst ', reqPayLst[index].dueDate); 
        console.log('reqPayLst ', reqPayLst);         
        component.set('v.requestedPaymentMilestones', reqPayLst);

        var newreqPayLst = component.get("v.requestedPaymentMilestones");

        for(let i=0; i < index; i++){
            if( newreqPayLst[index].dueDate <= newreqPayLst[i].dueDate ){
                newreqPayLst[index].maxDate = true;
                break;
            }else{
                newreqPayLst[index].maxDate = false;
            }
        }
        component.set('v.requestedPaymentMilestones', newreqPayLst);
    },
    
    calculateMilestone: function(component, event, helper) {
        var index = event.getSource().get("v.label");
        var requestMileList = component.get("v.requestedPaymentMilestones");
        var Prcnt =requestMileList[index].amountPercent;
        var totalSellingPrice = component.get("v.totalPrice"); 
        var amount = parseFloat((Prcnt*totalSellingPrice)/100).toFixed(3);
        requestMileList[index].amount= amount;
        component.set("v.requestedPaymentMilestones", requestMileList);
        helper.calculateTotalPercentage(component, event);  
    } ,
    
    calculatePercentage: function(component, event, helper) {
        var index = event.getSource().get("v.label");
        var amountInDec = event.getSource().get("v.value");
        console.log('amountInDec is '+ amountInDec);
        var requestMileList = component.get("v.requestedPaymentMilestones");
        var amount =requestMileList[index].amount;
        var totalSellingPrice = component.get("v.totalPrice"); 
        var percent = parseFloat((amountInDec*100)/totalSellingPrice).toFixed(3);
        console.log('percent is '+ percent);
        requestMileList[index].amountPercent= percent;
        component.set("v.requestedPaymentMilestones", requestMileList);
        helper.calculateTotalPercentage(component, event);  
    } ,
    
    /*addInstallmentsInRow : function(component, event, helper) {
        var  mileStoneList = component.get('v.requestedPaymentMilestones');
        var numInstallments = component.get('v.numofInstallments');
        console.log('mileStoneList is '+ mileStoneList.length);
        var installmentMap = component.get('v.installmentIndexMap');
        var milestoneDaysMap =  component.get('v.milestonesDaysMap');
        
        var masterPayMilestoneMap = component.get('v.nameMasterMilestoneMap');
        
        
        if(mileStoneList.length==0){
            var days =0;
            var milestone;
            var newRePayList = component.get('v.requestedPaymentMilestones');
            var date = new Date();
            for(var i=0;i< numInstallments-1;i++){ 
                console.log('date is '+ date);
                var datatoday = new Date();
                var datatodays = datatoday.setDate(new Date(date).getDate() + days);
                var todate = new Date(datatodays);
                console.log('todate is '+ todate);
                console.log('format date is '+ todate.getFullYear() + "-" + todate.getMonth()  + "-" + todate.getDate());
                var milestoneDate = todate.getFullYear() + "-" + todate.getMonth()  + "-" + todate.getDate();
                console.log('milestoneDate is '+ milestoneDate);
                
                if(i>0){
                    console.log('req date  is '+ newRePayList[i-1].dueDate);
                }
                console.log('milestoneDaysMap.has(days) is '+ milestoneDaysMap.has(days));
                console.log('days is '+ days);
                var masterPayMilestone;
                var masterPayEN ;
                if( milestoneDaysMap.has(days)){
                    masterPayMilestone = milestoneDaysMap.get(days);
                }
                console.log('masterPayMilestoneName is '+ JSON.stringify(masterPayMilestone));
                
                if(masterPayMilestone!=null && masterPayMilestone!=undefined && masterPayMilestone!=''){
                    
                }
                if(i==0){
                    newRePayList.push({
                        'milestone':'', 
                        'dueDate': milestoneDate,
                        'dueInDays': days,
                        'amountPercent':0,
                        'amount': ''
                    });
                    
                }
                else{
                    newRePayList.push({
                        'milestone':'', 
                        'dueDate': milestoneDate,
                        'dueInDays': days,
                        'amountPercent':0,
                        'amount': ''                        
                    });
                    
                }
                
                days= days + 30;
                console.log('new days are '+ days)         
            }
            if(numInstallments>1){   
                newRePayList.push({
                    'milestone':'', 
                    'dueDate': milestoneDate,
                    'dueInDays': days,
                    'amountPercent':0,
                    'amount': ''
                });
                
            }
            
            component.set('v.requestedPaymentMilestones', newRePayList); 
            helper.calculateTotalPercentage(component, event);
        }
        helper.calculateTotalPercentage(component, event);
    },*/
    
    SaveReqMilestones:  function(component, event, helper) {
        console.log('save call');
        var reqPayMiletones=  component.get("v.requestedPaymentMilestones") ;
        var totalPrcnt = 0; 
        var isPrcntNegative = false; 
        var isFieldsBlank = false;
        var isDueDateInvalid = false;
        var isDueDateMax = false;
        var dualDownPayment = false;
        var count = 0;
        
        for(var i=0; i<reqPayMiletones.length; i++){
            totalPrcnt= parseInt(totalPrcnt) + parseInt(reqPayMiletones[i].amountPercent);
            
            if(reqPayMiletones[i].installment == 'Down Payment'){
                count++;
                if(count >= 2){
                    dualDownPayment = true;
                }
            }
            
            if(parseInt(reqPayMiletones[i].amountPercent)<0){
                isPrcntNegative = true;
            }
            if(reqPayMiletones[i].dueDate < component.get("v.todayDate")){
                isDueDateInvalid = true;
            }
            if(reqPayMiletones[i].maxDate){
                isDueDateMax = true;
            }
            /*for(let j=0; j < i; j++){
                if( reqPayMiletones[i].dueDate <= reqPayMiletones[j].dueDate ){
                    isDueDateMax = true;
                    break;
                }
            }*/
            if((reqPayMiletones[i].amountPercent)==''||(reqPayMiletones[i].amountPercent)==null
               ||reqPayMiletones[i].dueInDays==''||reqPayMiletones[i].dueInDays==null ||reqPayMiletones[i].installment==null
               ||reqPayMiletones[i].installment==''
              ){
                isFieldsBlank = true;
            }
        }
        console.log('totalPrcnt is '+ totalPrcnt);
        if(isPrcntNegative==true){
            helper.showToastMessage('Error!','Percentage can not be less than zero','Error');   
        }
        else if(isDueDateInvalid == true){
            helper.showToastMessage('Error!','Due date must be future date','Error'); 
        }
        else if(isDueDateMax == true){
            helper.showToastMessage('Error!','Due date must be greater than previous milestones','Error'); 
        }
        else if(isFieldsBlank==true){
            helper.showToastMessage('Error!','Please fill all the fields','Error');   
        }
        else if(totalPrcnt != 100){
            helper.showToastMessage('Error!','Total Percentage should be 100% ','Error');
        }
        else if(totalPrcnt == 100){ 
            if(dualDownPayment==true){
                helper.showToastMessage('Error!','Downpayment should not be selected agian on revise payment milestones','Error');   
            }
            else
            {
                helper.callsaveRequestedMilestones(component, event); 
            }
        }
    },
    
    cancel: function(component, event, helper) {
        if(component.get("v.conDocId")){
            var action = component.get("c.deleteContentDoc");
            action.setParams({ 
                "conDocId" : component.get("v.conDocId"),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();            
                if (state === "SUCCESS") {
                    component.set("v.fileName", undefined);
                    component.set("v.conDocId", undefined);
                    component.set("v.showFileName", false);
                }else if(state === "ERROR"){
                    var errors = action.getError();
                    if (errors) {
                        this.showToastMessage('Error!','Something went wrong, please try again.','Error');
                        if (errors[0] && errors[0].message) {
                            console.log(errors[0].message);
                        }
                    }
                } 
            });
            $A.enqueueAction(action);
        }
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();   
    },    
})