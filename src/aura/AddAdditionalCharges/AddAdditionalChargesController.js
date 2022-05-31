({  
    doInit :function(component,event,helper){  
        //Setting Account columns for Data Table
        
        component.set('v.spinner',true);
        component.set('v.columns', [
            {label: 'Name', fieldName: 'linkName',type: 'url', 
             typeAttributes:{label: { fieldName: 'Name' }, target: '_blank'}}, 
            {label: 'Fixed Amount', fieldName: 'FixedAmount', type: 'Number'},
            {label: '% Amount', fieldName: 'Amount', type: 'Number'},
            {label: 'Vat %', fieldName: 'taxRate', type: 'Number'},
            
            {type: "button", typeAttributes: {
                    label: 'Add',
                    name: 'Select',
                    title: 'Select',
                    class : 'buttonColor',
                    disabled: false,
                    value: 'Select'
                }}]);
        var recordId = component.get("v.recordId");
        
        if(recordId != null){
            helper.getRecordType(component);
        }else{
           component.set('v.spinner',false); 
        }		
    }, 

    cancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleSubmit : function(component, event, helper) {
        console.log('In save');
        event.preventDefault();   
        const fields = event.getParam('fields');
        component.find('myRecordForm').submit(fields);
        component.set('v.displaySalesSelection',false);
        $A.get('e.force:refreshView').fire();
    },

    doFilter: function(component, event, helper) {
        //console.log(JSON.stringify(event.getSource().get("v.value")));
        component.set('v.searchKey', event.getSource().get("v.value"));
        if(component.get('v.searchKey')){
            helper.filterRecords(component, event); 
        }else{
           component.set("v.data", "");
           component.set('v.displayAccTable',false); 
        }
        $A.get('e.force:refreshView').fire();
    },
    
    handleAccSelect : function(component, event, helper) {
       
        console.log('%%selectedAccRows :- '+JSON.stringify(component.get("v.selectedAccts")));
    },

    removeOperation : function(component, event, helper) {
        component.set('v.spinner',true);
        var action = component.get("c.removeAgencyFromOpportunity"); 
        action.setParams({
                'recordId' : component.get("v.recordId")
            });
            action.setCallback(this,function(response){ 
                component.set('v.spinner',false);
                var state = response.getState();  
                if(state == 'SUCCESS'){  
                    var result = response.getReturnValue();
                    if(result == true){
                        component.set('v.filter',null);
                        component.set('v.isRecordSelected',false);
                        component.set('v.hideSearchOption',true);
                    }else{
                        console.log('Something went wrong!!');
                    }
                    helper.showToast(component,'Agency Removed','Success','Success'); 
                    $A.get('e.force:refreshView').fire();
                  //  $A.get("e.force:closeQuickAction").fire();
                }else{  
                    console.log('something bad happend! ');  
                }  
            });
            //component.set('v.spinner',false);
            $A.get('e.force:refreshView').fire();
            $A.enqueueAction(action);
        
    },
    
    addCustomer : function(component, event, helper) {
        
        component.set('v.spinner',true);
         var recId = event.getParam('row').Id;
        console.log('record id ',recId);
		var selectedRow = event.getParam('row');
        
        console.log('selected Row ', selectedRow);

        if(selectedRow){
            console.log('set rows value ',selectedRow);
            var myData = component.get("v.selectedData");
            myData.push(selectedRow);
            component.set("v.selectedData", myData);
            component.set('v.filter', "");
            component.set("v.data", "");
            component.set('v.displayAccTable',false);
            component.set("v.showCharges",true);
            component.set('v.spinner',false);
            component.set('v.searchKey',"");
            

        }
        
    },
    
    handleRefresh : function(component, event,helper) {
        var message = event.getParam("message");
        console.log('Message :',message);
        component.set("v.selectedData",message);
    },
    
    addCharges : function(component, event,helper) {
        
        component.set('v.spinner',true);
        var action = component.get("c.addAdditionalCharges");  
        action.setParams({
            'wrapperList' : component.get("v.selectedData"),
            'recordId' : component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state == 'SUCCESS'){  
                component.set('v.spinner',false);
                var result = response.getReturnValue();
                if(result){
                    component.set('v.selectedData',[]); 
                    component.set('v.showCharges',false);
                }
                helper.showToast(component,'Added Successfully','Success','Success'); 
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            }else{  
                component.set('v.spinner',false);
                console.log('something bad happend! ');  
            }  
        });
        
        $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
    }

})