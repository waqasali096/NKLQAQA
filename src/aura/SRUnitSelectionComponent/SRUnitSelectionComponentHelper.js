({
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    doInitHelper : function(component,event){ 
        
        var action = component.get("c.getUnits");
        action.setParams({ caseId : component.get('v.recordId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                if(oRes.isError){
                    this.showToast('Error',oRes.message,'error');
                    $A.get("e.force:closeQuickAction").fire();
                }else if(oRes.propertyList.length > 0){
                    component.set('v.totalList', oRes.propertyList);
                    component.set('v.oppMap', oRes.oppMap);
                    var result = oRes.oppMap;
                    
                    var fieldMap = [];
                    for(var key in result){
                        fieldMap.push({key: key, value: result[key]});
                    }
                    component.set("v.oppMap", fieldMap);
                    /*var pageSize = component.get("v.pageSize");
                    var totalRecordsList = oRes.propertyList;
                    var totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfProperty").length > i){
                            PaginationLst.push(oRes.propertyList[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));   */ 
                }else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                } 
            }
            else{
                alert('Error...');
            }
        });
        $A.enqueueAction(action);
    },
    showUnitsHelper : function(component,event){ 
       component.set('v.isShowTable',true);
        var totalList = component.get('v.totalList');
        var selectedOppId = component.find("oppPicklist").get("v.value");
        var propertyList = [];
        for(let i=0;i<totalList.length;i++){
            if(totalList[i].Deal__c == selectedOppId){
                propertyList.push(totalList[i]);
            }
        }
        component.set("v.listOfProperty",propertyList);
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
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));  
         component.set('v.isShowtable',true);
        component.set('v.renewalType',null);
        component.set('v.noOfCheques',null);
        component.set('v.noOfMonths',null);

        	
       
    },
    // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]);  
                }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                if(component.find("selectAllId").get("v.value")){
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
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    showToast : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            type: type
        });
        toastEvent.fire();
    },
    createCaseUnits : function(component,event,selectedList){
        var action = component.get("c.createCaseUnitRecord");
        action.setParams({ propertyList : selectedList,
                          caseId : component.get('v.recordId') 
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                this.showToast('Success','Units Added Successfully','success');
                $A.get("e.force:closeQuickAction").fire();
            }
            else{
                alert('Error...');
            }
        });
        $A.enqueueAction(action);
    },
    helperFun : function(component,event,secId) {
	  var acc = component.find(secId);
        	for(var cmp in acc) {
        	$A.util.toggleClass(acc[cmp], 'slds-show');  
        	$A.util.toggleClass(acc[cmp], 'slds-hide');  
       }
    }
})