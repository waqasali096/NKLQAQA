({  
    getRecordType: function(component) {
        var action = component.get("c.fetchOppRecrdType");  
        action.setParams({
            'recordId' : component.get("v.recordId"),
        });
        action.setCallback(this,function(response){  
            var state = response.getState();
            component.set('v.spinner',false);
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                component.set("v.renewRecordtype",result);
                
                //console.log('Data'+JSON.stringify(component.get("v.data")));  
            }else{  
                console.log('something bad happend! ');  
            }  
        });
        
        $A.enqueueAction(action);
    },
    
    filterRecords: function(component) { 
        component.set('v.spinner',true);
        var searchKey = component.get("v.searchKey");  
        //console.log('searchKey'+searchKey);
        var action = component.get("c.fetchAdditionalCharges");  
        action.setParams({
            'searchKey' : searchKey,
            'renewRecordType': component.get("v.renewRecordtype"),
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                var result = response.getReturnValue();
                if(result.length == 0){
                    component.set("v.showNoRecord",true);
                } else {
                    component.set("v.showNoRecord",false);
                }
                if(result && result!= ''){
                    component.set('v.displayAccTable',true);
                    var data = [];
                    for(let i = 0;i < result.length;i++){
                        var record = result[i];
                        record.linkName = '/'+record.Id;
                        data.push(record);
                    }
                    
                    component.set("v.data",data);  
                }else if( result==''){
                    component.set('v.displayAccTable',false); 
                }
                //console.log('Data'+JSON.stringify(component.get("v.data")));  
            }else{  
                console.log('something bad happend! ');  
            }  
        });
        component.set('v.spinner',false);
        $A.enqueueAction(action);
    },
    
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
    }
})