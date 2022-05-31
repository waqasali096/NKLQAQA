({
    
    
    deltingCheckboxAccounts : function(component, event, deltIds, recordIndexes) {
        //Calling apex method.
        component.set("v.isSpinner",true);
        
        var rows = component.get("v.data");
        
        for ( var i = 0; i < recordIndexes.length; i++ ) {
            rows.splice(recordIndexes[i], 1);
        }
        
        
        
        if(rows.length > 0){
            component.set("v.showCharges",true);
        }else{
            component.set("v.showCharges",false);  
        }
        
        component.set("v.data", rows);
        
        var cmpEvent = component.getEvent("cmpEvent");
        cmpEvent.setParams({
            "message" : component.get("v.data")
           
        });
        cmpEvent.fire();
        component.set("v.isSpinner",false);
        
        /*
        var action = component.get('c.DeleteRecord');
        //passing the all selected record's Id's to apex method.
        action.setParams({
            "DeleteUnits": deltIds
        });
        //Getting response.
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            //If state is sucess then refreshing the View.
            if (state === "SUCCESS") {
                component.set("v.unitSearchScreenDisable",false);
                var selectedRowsIds = [];
                    var ltngCmp = component.find("ltngCmp");
                    if(ltngCmp){
                        ltngCmp.set("v.selectedRows", selectedRowsIds);
                        component.set("v.selectedRowsCount",0);           
                    }  
                if(response.getReturnValue()){
                    var result = response.getReturnValue();
                    var pageSize = component.get("v.pageSize");
                    component.set("v.startPage", 0);
                    component.set("v.endPage", pageSize - 1);
                    if(result.length > 0){
                        component.set("v.totalRecordsCount",result.length);
                        component.set("v.totalPagesCount", Math.ceil(result.length / pageSize)); 
                        component.set("v.currentPage",1);
                        component.set("v.showUnits",true);
                        
                    }else{
                        component.set("v.totalRecordsCount",0);
                        component.set("v.totalPagesCount", 0);
                        component.set("v.currentPage",1);
                        component.set("v.showUnits",false);
                        
                    }
                    
                }
                $A.get('e.force:refreshView').fire();
                component.set('v.showDeleteBox', false);
                component.set("v.isSpinner",false);
                //var result = response.getReturnValue();
                var cmpEvent = component.getEvent("cmpEvent");
                cmpEvent.setParams({
                        "message" : "Parent Refresh" });
                cmpEvent.fire();
                
                //Refresh the View.
                //$A.get('e.force:refreshView').fire();
                //component.set('v.showDeleteBox', false);
            }
        });
        
        $A.enqueueAction(action);
        */
    },
     next : function(component,event,sObjectList,end,start,pageSize){
        console.log('sObjectList :',JSON.stringify(sObjectList));
        console.log('end',end);
        console.log('start',start);
        console.log('pageSize',pageSize);
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                //if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
               // }else{
                   // Paginationlist.push(sObjectList[i]);  
                //}
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.data', Paginationlist);
    },
    // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                //if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                //}else{
                    //Paginationlist.push(sObjectList[i]); 
                //}
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.data', Paginationlist);
    },
   
    
    
})