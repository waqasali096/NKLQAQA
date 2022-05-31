({
    doInit : function(component, event, helper) {
        /******
        *	{label: 'Unit Name', fieldName: 'linkName', type: 'url',wrapText: true , typeAttributes: {label: { fieldName: 'Name'}, target: '_blank'},hideDefaultActions: true},
        *	{label: 'Style', fieldName: 'Unit_style__c', type: 'text',wrapText: true ,hideDefaultActions: true},
		*	{label: 'Unit Status', fieldName: 'Unit_Status__c', type: 'text',wrapText: true ,hideDefaultActions: true},
        *	{label: 'Location Code', fieldName: 'LocationName', type: 'url',wrapText: true , typeAttributes: {label: { fieldName: 'locationName'}, target: '_blank'},hideDefaultActions: true},
        */
        component.set('v.columnsforOnloadUnit', [
            {label: 'Unit Name', fieldName: 'linkName', type: 'url',wrapText: true , typeAttributes: {label: { fieldName: 'Name'}, target: '_blank'},hideDefaultActions: true},
            {label: 'Location Code', fieldName: 'Unit_Code__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Building', fieldName: 'BuildingName', type: 'url', wrapText: true ,typeAttributes: {label: {fieldName: 'buildingName'}, target: '_blank'},hideDefaultActions: true},
            {label: 'Unit Type', fieldName: 'Unit_type__c', type: 'text',wrapText: true ,hideDefaultActions: true},
			{label: 'Style', fieldName: 'Unit_style__c', type: 'text',wrapText: true ,hideDefaultActions: true},            
            {label: 'Usable Area', fieldName: 'Plot_Area_Sqft__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Total Area(sq.ft)', fieldName: 'Total_Saleable_Area_Sqft__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'No. of Bedrooms', fieldName: 'No_of_Bedrooms__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Unit Status', fieldName: 'Unit_Status__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Unit Price', fieldName: 'Amountincurrency', type: 'text',wrapText: true, sortable: true ,typeAttributes: {label: { fieldName: 'convertedcurrency'}, target: '_blank'},hideDefaultActions: true},
            
            /*{label: 'Payment Plan', fieldName: 'PaymentPlan',type : 'text' ,wrapText: true , typeAttributes: {label: {fieldName: 'paymentPlan'}, target: '_blank'},hideDefaultActions: true},
            {label: 'Master Community', fieldName: 'linkMasterName', type: 'url',wrapText: true , sortable: true, typeAttributes: {label: {fieldName: 'masterName'}, target: '_blank'},hideDefaultActions: true},
            {label: 'Cluster', fieldName: 'ClusterName', type: 'text', wrapText: true ,typeAttributes: {label: {fieldName: 'clusterName'}, target: '_blank'},hideDefaultActions: true},
            {label: 'Project', fieldName: 'ProjectName', type: 'text',wrapText: true , typeAttributes: {label: {fieldName: 'projectName'}, target: '_blank'},hideDefaultActions: true},
            {label: 'Architectural Type', fieldName: 'Architectural_Type__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Property Unit view', fieldName: 'Property_Unit_View__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Space Type', fieldName: 'Space_Type__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Unit Theme', fieldName: 'Unit_theme__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Unit Color', fieldName: 'Unit_color_option__c', type: 'text',wrapText: true ,hideDefaultActions: true},
            {label: 'Saleable Area', fieldName: 'Total_Saleable_Area_Sqft__c', type: 'Decimal',wrapText: true ,typeAttributes: {label: { fieldName: 'SaleableArea'}, target: '_blank'},hideDefaultActions: true},
            {label: 'Plot Area', fieldName: 'Plot_Area_Sqft__c', type: 'Decimal',wrapText: true ,typeAttributes: {label: { fieldName: 'PlotArea'}, target: '_blank'},hideDefaultActions: true},
            {label: 'ACD', fieldName: 'Anticipated_Completion_Date__c', type: 'Date',wrapText: true ,typeAttributes: {label: { fieldName: 'ACD'}, target: '_blank'},hideDefaultActions: true}
            {label: 'Type', fieldName: 'Type__c', type: 'text',sortable: true,wrapText: true ,hideDefaultActions: true}, */
        ]);
            component.set("v.isSpinner", true);
            //helper.callTypePicklict(component, event);
            var action = component.get("c.getExistingUnits");
            action.setParams({
            'recId' : component.get("v.recordId"),
            'objectType':component.get("v.sobjecttype"),
            });
            action.setCallback(this,function(response) {
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            if (state === "SUCCESS") {
            	var resultData = response.getReturnValue();
            console.log('resultData',resultData);
            if(resultData.unitExist){
                if(component.get("v.sobjecttype")=='Account'){
                    if(resultData.prerequisitesFilled){
                    	component.set("v.infoMsg",'Deals Already Linked to this Account.');
                    }else{
                    	$A.get("e.force:closeQuickAction").fire();
            			var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            title : 'Error Message',
                                            message:'Please fill Deals Prequisites Section.',
                                            type: 'error'
                                        });
                                        component.set("v.isSpinner", false);  
                                        toastEvent.fire();
            			//this.showErrorMsg(component,event,'Please fill Order Entries Prequisites Section.');
            		}
                }else if(component.get("v.sobjecttype")=='Opportunity'){
                    component.set("v.infoMsg",'Unit Already Linked to this Deal.');
            }else if(component.get("v.sobjecttype")=='Lead'){
            		// Lakshaya's else if block
            		component.set("v.infoMsg","Unit Already Linked to this Lead");
            	}
                component.set("v.showExistingUnit", true);
                component.set("v.Onloadflag", true);
                console.log('existing unit');
            }else{
            	
            	if(component.get("v.sobjecttype")=='Account'){
                    if(resultData.prerequisitesFilled){
                    	component.set("v.showExistingUnit", false);
                        component.set("v.Onloadflag", true);
                        component.set("v.componentVisibility", false);
            			component.set("v.resetBtn", true);
                    	helper.callNumofbedroomsLst(component, event);
                        helper.callUnitTypeGroupLst(component, event);
                        helper.callPropertyUnitViewLst(component, event);
                        helper.callSpaceTypePicklict(component, event);
                        helper.getUnits(component, helper);
                    }else{
            $A.get("e.force:closeQuickAction").fire();
                    	var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            title : 'Error Message',
                                            message:'Please Fill Document\'s Information First.',
                                            type: 'error'
                                        });
                                        component.set("v.isSpinner", false);  
                                        toastEvent.fire();
                    	
            		}
                }else if(component.get("v.sobjecttype")=='Opportunity'){
            		component.set("v.showExistingUnit", false);
                	component.set("v.Onloadflag", true);
            		component.set("v.componentVisibility", false);
            		component.set("v.resetBtn", true);
                    helper.callNumofbedroomsLst(component, event);
                    helper.callUnitTypeGroupLst(component, event);
                    helper.callPropertyUnitViewLst(component, event);
                    helper.callSpaceTypePicklict(component, event);
                    helper.getUnits(component, helper);
                }else if(component.get("v.sobjecttype")=='Lead'){
            		// Lakshaya's else if block
            if(resultData.recordTypeName == 'Sales Lead'){
            	
            		console.log('we are in if block of Lead');
            		component.set("v.showExistingUnit", false);
                	component.set("v.Onloadflag", true);
            		component.set("v.leadSalesModification",false);
            		
            		helper.callUnitTypeSalesStatus(component,event);
                    helper.callNumofbedroomsLst(component, event);
                    helper.callUnitTypeGroupLst(component, event);
                    helper.callPropertyUnitViewLst(component, event);
                    helper.callSpaceTypePicklict(component, event);

            		console.log('Just before get unit');
                    helper.getUnits(component, helper);
            }
            else if(resultData.recordTypeName == 'Residential Leasing Unit'){
            
            		console.log('We are in else if block of Lead');
            		component.set("v.showExistingUnit", false);
                	component.set("v.Onloadflag", true);
            		component.set("v.leadSalesModification",false);
            		component.set("v.leadLeasingModification",false);
            		helper.callUnitTypeSalesStatus(component,event);
                    helper.callNumofbedroomsLst(component, event);
                    helper.callUnitTypeGroupLst(component, event);
                    helper.callPropertyUnitViewLst(component, event);
                    helper.callSpaceTypePicklict(component, event);

            		console.log('Just before get unit');
                    helper.getUnits(component, helper);
            }
            
            else if(resultData.recordTypeName == 'Residential Leasing Shop'){
            
            		console.log('We are in else if block of Lead');
            		component.set("v.showExistingUnit", false);
                	component.set("v.Onloadflag", true);
            		component.set("v.leadSalesModification",false);
            		component.set("v.leadLeasingModification",false);
            		helper.callUnitTypeSalesStatus(component,event);
                    helper.callNumofbedroomsLst(component, event);
                    helper.callUnitTypeGroupLst(component, event);
                    helper.callPropertyUnitViewLst(component, event);
                    helper.callSpaceTypePicklict(component, event);

            		console.log('Just before get unit');
                    helper.getUnits(component, helper);
            }
                }   
            component.set("v.isSpinner", false);
            }
            }
            else if(state === "ERROR"){
            component.set("v.isSpinner", false);
            console.log(errors[0].message);
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
    
    handleNext : function(component, event, helper) { 
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber+1);
        helper.getUnits(component, helper);
    },
        onReset : function(component, event, helper) { 
        component.set("v.Projectrecord",'');
        component.set("v.Buildingrecord",'');
        component.set("v.selectednumofbedroom",'');
        helper.getUnits(component, helper);
    },
        
        handlePrev : function(component, event, helper) {        
            var pageNumber = component.get("v.pageNumber");
            component.set("v.pageNumber", pageNumber-1);
            helper.getUnits(component, helper);
        },
            
            handleSelectUnit : function(component, event,helper) {
                var selectedRows = event.getParam('selectedRows'); 
                var setRows = [];
                for ( var i = 0; i < selectedRows.length; i++ ) {
                    setRows.push(selectedRows[i]);
                }
                component.set("v.selectedUnits", setRows);
                /*var selectedRows = event.getParam('selectedRows');
                console.log('selectedRows',selectedRows);
                component.set("v.selectedUnits",selectedRows);
                var selectedUnitIds =[];
                for ( var i = 0; i < selectedRows.length; i++ ) {
                    console.log('selected rows are '+selectedRows[i].Id);
                    selectedUnitIds.push(selectedRows[i].Id);
                    component.set("v.selectedUnitId", selectedRows[i].Id);
                }
                component.set('v.listofSelectedUnitIDS' , selectedUnitIds) ; */
            },
                callcreateoffershelper: function(component, event, helper) {
                    helper.callCreateOffersMethod(component,event);
                },
                    search : function(component, event, helper) {
                        component.set("v.isSpinner", true);  
                        helper.getUnits(component,event);
                    },
                        handleSort: function (cmp, event, helper) {
                            var fieldName = event.getParam('fieldName');
                            var sortDirection = event.getParam('sortDirection');
                            cmp.set("v.sortedBy", fieldName);
                            cmp.set("v.sortedDirection", sortDirection);
                            helper.sortData(cmp, fieldName, sortDirection);
                        },
                            
                            handleClose : function(component, event, helper) {
                                $A.get("e.force:closeQuickAction").fire();
                            },
                                
                                addMoreFilters: function(component, event, helper) {
                                    component.set('v.showMore', true);
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
                                        
})({
	myAction : function(component, event, helper) {
		
	}
})