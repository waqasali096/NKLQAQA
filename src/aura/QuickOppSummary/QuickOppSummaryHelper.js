({  
    fetchChildOppstoCart: function(component, event, helper) {
        component.set("v.spinner", true);
        var action = component.get("c.getChildOpps");
        action.setParams({
            'recordId' : component.get("v.recordId"),
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!result.success){
                    console.log('Exception cart'+result.message);
                }else{
                    component.set("v.customerAdded", result.accExist);
                    component.set("v.accountId", result.accId);
                    if(result.resultWrapperList){
                        component.set("v.cartTotalPrice", result.cartTotalPrice);
                        this.setPagination(component, event, helper, result.resultWrapperList);
                    }
                    if(result.bookedWrapperList){
                        //console.log('bookedUnits'+JSON.stringify(result.bookedWrapperList));
                        component.set("v.bookedTotalPrice", result.bookedTotalPrice);
                        this.setBookingPagination(component, event, helper, result.bookedWrapperList);
                    }
                    if(result.jointOwnerList){
                        var records = result.jointOwnerList;
                        records.forEach(function(record){
                            record.joName = record.Name__c;
                            record.primaryName = record.Primary_Account__r.Name;
                            if(record.Relationship_with_Owner__c){
                                record.relation = record.Relationship_with_Owner__c;
                            }
                            if(record.Share_Percentage__c){
                                record.sharePercentage = record.Share_Percentage__c;
                            }
                        });
                        component.set("v.jointOwnerList", records);
                    }
                }
                component.set("v.spinner", false);
            }
            else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    this.showToast(component,'Something went wrong, please try again','Error','Error'); 
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
            component.set("v.spinner", false); 
        });
        $A.enqueueAction(action);  
    },

    //method to check Opp has account & set related attributes
    fetchAccountDetails : function(component,event,helper) {  
        var action = component.get("c.getAccountDetails");
        action.setParams({
            "accountId":'',
            "OppId":component.get("v.recordId"),
        });
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                if(result){
                    component.set('v.newAccount',result.accounts);
                    console.log('account'+JSON.stringify(result));  
                    component.set('v.accountId',result.accId);
            		component.set('v.spinner',false);
                }
            }else{  
            	component.set('v.spinner',false);
                console.log('something bad happend! ');  
            }              
        });
        $A.enqueueAction(action);
    },
    
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field  
        var dependentFields = [];
        //dependentFields.push('--- None ---');
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        // set the dependentFields variable values to store(dependent picklist field) on lightning:select
        component.set("v.listDependingValues", dependentFields);
    },
    
    //get sales type values
    getDependantTypeValues: function(component, event,helper) {
        var action = component.get("c.getDependentPicklistValues");
        action.setParams({
            "dependToken":'Sales_Sub_Type__c',
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.depnedentFieldMap",result);
            }
        });
        $A.enqueueAction(action);
    },

    
    //get sales type values
    getSalesTypeValues: function(component, event,helper) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "obj":'Opportunity',
            "fld":'Type_Of_Sale__c',
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var salesTypeMap = [];
                var i=0;
                for(var key in result){
                    salesTypeMap.push({key: key, value: result[key]});
                }
                component.set("v.salesTypeMap", salesTypeMap);
            }
        });
        $A.enqueueAction(action);
    },

    /*Purpose - Set the pagination*/
    setPagination: function(component, event, helper, allUnitsList){
        var pageSize = component.get("v.cartPageSize");
        var unitsList = allUnitsList;
        var unitListLength = unitsList.length ;
        component.set("v.cartTotalRecordsCount", unitListLength);
        component.set("v.cartStartPage",0);
        component.set("v.cartEndPage",pageSize-1);
        component.set("v.cartUnits", unitsList);
        var PaginationLst = [];
        for(var i=0; i < pageSize; i++){
            if(component.get("v.cartUnits").length > i){
                PaginationLst.push(allUnitsList[i]);    
            } 
        }
        component.set('v.paginationList', PaginationLst);
        component.set("v.cartSelectedCount" , 0);
        component.set("v.cartTotalPagesCount", Math.ceil(unitListLength / pageSize)); 
        component.set("v.cartCurrentPage", 1);
        var allUnitsList = component.get("v.cartUnits");
        var cartTotal = 0;
        for(var i = 0; i < allUnitsList.length; i++) {
            cartTotal = cartTotal + allUnitsList[i].netPrice;
        }
        component.set("v.cartTotalPrice", cartTotal);
    },
    
     /*Purpose - Set the pagination*/
    setBookingPagination: function(component, event, helper, allUnitsList){
        var pageSize = component.get("v.bookedPageSize");
        var unitsList = allUnitsList;
        var unitListLength = unitsList.length ;
        component.set("v.bookedTotalRecordsCount", unitListLength);
        component.set("v.bookedStartPage",0);
        component.set("v.bookedEndPage",pageSize-1);
        component.set("v.bookedUnits", unitsList);
        var pglist = [];
        for(var i=0; i < pageSize; i++){
            if(component.get("v.bookedUnits").length > i){
                pglist.push(allUnitsList[i]);    
            } 
        }
        try{
            component.set('v.bookedPaginationList', pglist);
            component.set("v.bookedSelectedCount" , 0);
            component.set("v.bookedTotalPagesCount", Math.ceil(unitListLength / pageSize)); 
            component.set("v.bookedCurrentPage", 1);  
        } catch(e){
            console.log('ERROR'+e);
        }
        
    },
    
    /*Purpose - get Opportunity options Amount*/
    getOptionsPrice: function(component, event, helper, oppId){
        var allUnitsList = component.get("v.cartUnits");
        var totalprice = 0;
        var action = component.get("c.getOptionsPrice");  
        action.setParams({
            'recordId' : oppId,
            'isDLD' : false
        });
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                if(result){
                    var unitLists = component.get("v.selectedUnit");
                    for(var i = 0; i < allUnitsList.length; i++) {
                        if(allUnitsList[i].oppId == unitLists.oppId) {
                            allUnitsList[i].optionsPrice = result;
                            allUnitsList[i].netPrice = allUnitsList[i].optionsPrice + allUnitsList[i].sellingPrice;
                        }
                        totalprice = totalprice +  allUnitsList[i].netPrice;
                    }
                    component.set('v.cartUnits', allUnitsList);
                    component.set('v.cartTotalPrice', totalprice);
                    this.setPagination(component, event, helper, allUnitsList);
                }
            }else{  
                console.log('something bad happend! ');  
            }  
        });
        $A.enqueueAction(action);
    },
    
    /*Purpose - get Opportunity options Amount*/
    getDLDPrice: function(component, event, helper, oppId){
        var allUnitsList = component.get("v.cartUnits");
        var totalprice = 0;
        var action = component.get("c.getOptionsPrice");  
        action.setParams({
            'recordId' : oppId,
            'isDLD' : true
        });
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                if(result){
                    var unitLists = component.get("v.selectedUnit");
                    for(var i = 0; i < allUnitsList.length; i++) {
                        if(allUnitsList[i].oppId == unitLists.oppId) {
                            allUnitsList[i].dldPrice = result;
                            //allUnitsList[i].netPrice = allUnitsList[i].optionsPrice + allUnitsList[i].sellingPrice + allUnitsList[i].chargesPrice;
                        }
                        //totalprice = totalprice +  allUnitsList[i].netPrice;
                    }
                    component.set('v.cartUnits', allUnitsList);
                    //component.set('v.cartTotalPrice', totalprice);
                    this.setPagination(component, event, helper, allUnitsList);
                }
            }else{  
                console.log('something bad happend! ');  
            }  
        });
        $A.enqueueAction(action);
    },
    
   
    checkAccountExists: function(component) { 
        component.set('v.spinner',true);
        var recordId = component.get('v.recordId');
        var action = component.get("c.checkAccountExists");  
        action.setParams({
            'recordId' : recordId
        });
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                console.log('result'+result);
                if(result){
                    //component.set('v.accExist',true); 
                    component.set('v.accountId','0013M00000lYrbCQAS');
                }else{
                }
            }else{  
                console.log('something bad happend! ');  
            }  
        });
        console.log('accExist'+component.get('v.accExist'));
        //component.set('v.spinner',false);
        $A.enqueueAction(action);
    },
   
    // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize,buttonName){
        var Paginationlist = [];
        var counter = 0;
        if(buttonName == 'next'){
            for(var i = end + 1; i < end + pageSize + 1; i++){
                if(sObjectList.length > i){ 
                    if(component.find("cartSelectAllId").get("v.value")){
                        Paginationlist.push(sObjectList[i]);
                    }else{
                        Paginationlist.push(sObjectList[i]);  
                    }
                }
                counter ++ ;
            }
            start = start + counter;
            end = end + counter;
            component.set("v.cartStartPage",start);
            component.set("v.cartEndPage",end);
            component.set('v.paginationList', Paginationlist);
        }else if(buttonName == 'booknext'){
            for(var i = end + 1; i < end + pageSize + 1; i++){
                if(sObjectList.length > i){ 
                        Paginationlist.push(sObjectList[i]);  
                }
                counter ++ ;
            }
            start = start + counter;
            end = end + counter;
            component.set("v.bookedStartPage",start);
            component.set("v.bookedEndPage",end);
            component.set('v.bookedPaginationList', Paginationlist);
        }
    },
    
    // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize,buttonName){
        var Paginationlist = [];
        var counter = 0;
        if(buttonName == 'previous'){
            for(var i= start-pageSize; i < start ; i++){
                if(i > -1){
                    if(component.find("cartSelectAllId").get("v.value")){
                        Paginationlist.push(sObjectList[i]);
                    }else{
                        Paginationlist.push(sObjectList[i]); 
                    }
                    counter ++;
                }else{
                    start++;
                }
            }
            start = start - counter;
            end = end - counter;
            component.set("v.cartStartPage",start);
            component.set("v.cartEndPage",end);
            component.set('v.paginationList', Paginationlist);
        }else if(buttonName == 'bookprevious'){
            for(var i= start-pageSize; i < start ; i++){
                if(i > -1){
                    Paginationlist.push(sObjectList[i]); 
                    counter ++;
                }else{
                    start++;
                }
            }
            start = start - counter;
            end = end - counter;
            component.set("v.bookedStartPage",start);
            component.set("v.bookedEndPage",end);
            component.set('v.bookedPaginationList', Paginationlist);
        }
    },
    
    /*Purpose - add units to cart by creating child opps*/
    callBookUnits : function(component,event,helper,selectedUnits) {
        component.set("v.spinner", true);
        var selUnits = selectedUnits;
        var existingBookedUnits = component.get("v.bookedUnits");
        var childOppId;
        for (var i = 0; i < selUnits.length; i++) {
            if(selUnits[i].isChecked){
                selUnits[i].isChecked = false;
                existingBookedUnits.push(selUnits[i]);
                //var childCmp = component.find("childQuestion");
                childOppId = selUnits[i].oppId;
                //childCmp.handleGenerateDocument(component,event,helper,childOppId);
            }
       	}
    	console.log('bookedunits'+JSON.stringify(existingBookedUnits));
        var action = component.get("c.bookUnits");
        action.setParams({
            'recordId' : component.get("v.recordId"),
            'bookedUnits' : selUnits,
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!result.success){
                    //show no units error
                }else if(result.bookedWrapperList){
                    component.set("v.bookedTotalPrice", result.bookedTotalPrice);
                    helper.setBookingPagination(component, event, helper, result.bookedWrapperList);
                    //helper.autoGenerateDocument(component,event,helper,childOppId);
                }
                component.set("v.spinner", false);
            }
            else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    this.showToast(component,'Something went wrong, please try again','Error','Error'); 
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
                component.set("v.spinner", false); 
            } 
        });
        $A.enqueueAction(action);
    },
    
        
    /*Purpose - add units to cart by creating child opps*/
    callSalesOfferCreation : function(component,event,helper,selectedUnits) {
        component.set("v.spinner", true);
        var selUnits = selectedUnits;
        
        var action = component.get("c.addtoSalesOffer");
        action.setParams({
            'salesOfferUnits' : selUnits,
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!result){
                    this.showToast(component,'Something went wrong, please try again','Error','Error'); 
                }else if(result){
                    component.set("v.selectedDropdown", "salesOffer");
                    component.set("v.modalContainer", true);
                }
                component.set("v.spinner", false);
            }
            else if(state === "ERROR"){
                var errors = action.getError();
                if (errors) {
                    this.showToast(component,'Something went wrong, please try again','Error','Error'); 
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            } 
            component.set("v.spinner", false); 
        });
        $A.enqueueAction(action);
    },
    
    //Method to show toast message
    showToast : function(component, message, title, type) {
        component.set('v.spinner',false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message:message,
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },
})