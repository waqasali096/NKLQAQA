({  
    filterRecords: function(component) { 
        component.set('v.spinner',true);
        var searchKey = component.get("v.searchKey");  
        //console.log('searchKey'+searchKey);
        var action = component.get("c.fetchBrokerAccounts");  
        action.setParams({
            'searchKey' : searchKey
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