({
    getUnits : function(component, helper) {
        var mastrplan = component.get("v.MasterPlanrecord");
        var SeletedBlook = component.get("v.Blockrecord");
        var Projectrecord = component.get("v.Projectrecord");
        var Buildingrecord = component.get("v.Buildingrecord");
        var minPrice = component.get('v.minPrice');
        var maxPrice = component.get('v.maxPrice');
        var minSaleableArea = component.get('v.minSaleableArea');
        var maxSaleableArea   =   component.get('v.maxSaleableArea');
        var minPlotArea = component.get('v.minPlotArea');
        var maxPlotArea  =  component.get('v.maxPlotArea');
        
        if(mastrplan !=null){
            var mastrplanId = mastrplan.val;
            console.log('mastrplanId=='+mastrplanId);
        }
        if(SeletedBlook !=null){
            var SeletedBlookId = SeletedBlook.val;
            console.log('SeletedBlookId=='+SeletedBlookId);
        }
        if(Projectrecord !=null){
            var SeletedProjectId = Projectrecord.val;
            console.log('SeletedProjectId=='+SeletedProjectId);
        }
        if(Buildingrecord !=null){
            var BuildingrecordId = Buildingrecord.val;
            
            console.log('BuildingrecordId=='+BuildingrecordId);
        }
        if(minPrice ==''){
            minPrice=0;
        }
        
        if(maxPrice ==''){
            maxPrice=0;
        }
        
        if(minSaleableArea==''){
            minSaleableArea=0;
        }
        
        if(maxSaleableArea ==''){
            maxSaleableArea =0;      
        }
        
        if(minPlotArea ==''){
            minPlotArea=0;
        }
        
        if(maxPlotArea ==''){
            maxPlotArea=0;
        }
        var action = component.get("c.getUnits");
        var pageSize = component.get("v.pageSize").toString();
        var pageNumber = component.get("v.pageNumber").toString();
        var recId = component.get("v.recordId"); //Lakshaya's variable
        var integerVal = parseInt(1);
        console.log('We are in get unit block');
        action.setParams({
            'pageSize' : pageSize,
            'pageNumber' : pageNumber,
            'objRecordID' : component.get("v.recordId"),
            'masterPlan' : mastrplanId,
            'block' : SeletedBlookId,
            'project' : SeletedProjectId,
            'building' : BuildingrecordId, 
            'bedroom' : component.get("v.selectednumofbedroom"),
            'architectural' : component.get("v.selectedunitgroup"),
            'propertyView' : component.get("v.selectedpropertyunitview"),
            "spaceType" : component.get("v.selectedspacetype"),
            "unitType" : component.get('v.selectedunittype'),
            "unitTheme" : component.get('v.selectedthemetype'),
            "unitColor" : component.get('v.selectedcolortype'),
            "minPrice" : minPrice,
            "maxPrice" : maxPrice,   
            "minSaleableArea" : minSaleableArea,
            "maxSaleableArea" : maxSaleableArea,
            "minPlotArea" : minPlotArea,
            "maxPlotArea" :  maxPlotArea,
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            console.log('Get Unit State',state);
            
            if (state === "SUCCESS") {
                let finalResult = response.getReturnValue();
                console.log('Get Unit Result',finalResult);
                if(finalResult == null){
                    component.set("v.DisplayMsgFlg",true);
                    component.set("v.DisplaySearchResultFlg",false);
                }else{
                    var resultData = finalResult.unitsList;
                    resultData.forEach(function(record){
                        
                        if (record.Id !== null && record.Id !== undefined) {
                            record.linkName = '/'+record.Id;
                        }
                        if (record.Master_Payment_Plan__c !== null && record.Master_Payment_Plan__c !== undefined) {
                            record.PaymentPlan = record.Master_Payment_Plan__r.Name;
                            record.paymentPlan = '/'+record.Master_Payment_Plan__r.Id;
                        }
                       /* if (record.Master_Community__c !== null && record.Master_Community__c !== undefined) {
                            record.linkMasterName = '/'+record.Master_Community__c;
                            record.masterName = record.Master_Community__r.Name;
                        } */
                        
                        if (record.Project__c !== null && record.Project__c !== undefined) {
                            record.ProjectName = record.Project__r.Name;
                            record.projectName = record.Project__r.Name;
                        }
                        if (record.Building__c !== null && record.Building__c !== undefined) {
                            record.BuildingName = '/'+record.Building__c;
                            record.buildingName = record.Building__r.Name;
                        }
                        if (record.Location__c !== null && record.Location__c !== undefined) {
                            record.LocationName = '/'+record.Location__c;
                            record.locationName = record.Location__r.Name;
                        }
                        
                        var amount = record.Selling_Price__c;
                        if(amount !== null && amount !== undefined){
                            //var amountstr = helper.formatCurr(amount);
                            var amountstr = amount.toString();
                            record.Amountincurrency = amountstr+'.00 AED';
                            record.convertedcurrency = amountstr+'.00 AED';
                        }else{
                            record.Amountincurrency ='00.00 AED';
                            record.convertedcurrency ='00.00 AED';
                        } 
                    });
                    if(recId.substring(0,3) === '00Q'){
                        // Lakshaya's if block
                        console.log('Phase 1');
                       // component.set("v.maxSelectedRows",integerVal);
                        component.set('v.maxrowselection',integerVal);
                    }else{
                        console.log('Phase 2');
                        // Lakshaya's else block
                      
                    }
                    
                    if(resultData.length < component.get("v.pageSize")){
                        component.set("v.isLastPage", true);
                    } else{
                        component.set("v.isLastPage", false);
                    }
                    component.set("v.dataSize", resultData.length);
                    component.set("v.onloadUnitList", resultData);
                    component.set("v.DisplayMsgFlg",false);
                    component.set("v.DisplaySearchResultFlg",true);
                    
                }
                component.set("v.isSpinner", false);
            }
            else if(state === "ERROR"){
                component.set("v.DisplayMsgFlg",true);
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
    callTypePicklict: function(component, event) {
        var action = component.get("c.getTypes");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var typeMap = [];
                for(var key in result){
                    typeMap.push({key: key, value: result[key]});
                }
                component.set("v.TypeMap", typeMap);
            }
        });
        $A.enqueueAction(action);
    },
    callSpaceTypePicklict: function(component, event) {
        var action = component.get("c.getSpaceType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var typeMap = [];
                for(var key in result){
                    typeMap.push({key: key, value: result[key]});
                }
                component.set("v.SpaceTypeMap", typeMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    callUnitColorPicklist: function(component, event) {
        var action = component.get("c.getUnitColor");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var typeMap = [];
                for(var key in result){
                    typeMap.push({key: key, value: result[key]});
                }
                console.log('Color Map is '+typeMap);
                component.set("v.ColorTypeMap", typeMap);
            }
        });
        $A.enqueueAction(action);
    },
    callUnitTypePicklist: function(component, event) {
        var action = component.get("c.getUnitType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var typeMap = [];
                for(var key in result){
                    typeMap.push({key: key, value: result[key]});
                }
                console.log('Unit Map is '+typeMap);
                component.set("v.UnitTypeMap", typeMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    //Lakshaya's helper method
    callUnitTypeSalesStatus: function(component,event){
        
        console.log('@@@@ SalesStatusMap @@@@');
        var action = component.get("c.getUnitSalesStatus");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                var salesStatusMap = [];
                for(var key in result){
                    salesStatusMap.push({key:key,value:result[key]});
                }
                console.log('SalesStatusMap is '+salesStatusMap);
                component.set("v.SalesStatusMap", salesStatusMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    callNumofbedroomsLst: function(component, event) {  
        var action = component.get("c.getNumberofBedroomsOptions");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var BedroomsMap = [];
                for(var key in result){
                    BedroomsMap.push({key: key, value: result[key]});
                }
                console.log('BedroomsMap is '+ BedroomsMap);
                component.set("v.NumofBedroomsMap", BedroomsMap);
            }
        });
        $A.enqueueAction(action);
    },
    callUnitTypeGroupLst: function(component, event) {
        var action = component.get("c.getUnitTypeGroupOptions");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var UnitytypeGroupMap = [];
                for(var key in result){
                    UnitytypeGroupMap.push({key: key, value: result[key]});
                }
                console.log('UnitytypeGroupMap is '+ UnitytypeGroupMap);
                component.set("v.UnitTypeGroupMap", UnitytypeGroupMap);
            }
        });
        $A.enqueueAction(action);
    },
    callPropertyUnitViewLst: function(component, event) {
        var action = component.get("c.getPropertyUnitViewOptions");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var propertyUnitViewMap = [];
                for(var key in result){
                    propertyUnitViewMap.push({key: key, value: result[key]});
                }
                console.log('propertyUnitViewMap is '+ propertyUnitViewMap);
                component.set("v.PropertyUnitViewMap", propertyUnitViewMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    callCreateOffersMethod: function(component, event) {
        component.set("v.isSpinner", true);
        var tempUnitList=[];
        var updateId = [];
        var selectedUnits = component.get("v.selectedUnits");
        if(selectedUnits.length == 0){
            this.showErrorMsg(component,event,'Please select a unit.');
        }
        else if(selectedUnits.length >= 1)
        {
            var actionUnit = component.get("c.addUnitstoOpp");
            actionUnit.setParams({ 
                'recId' : component.get("v.recordId"),
                'unitsList' : selectedUnits,
                'objectType':component.get("v.sobjecttype"),
            });
            actionUnit.setCallback(this, function(response) {
                var state = response.getState();    
                var resultData = response.getReturnValue();   
                console.log('AddUnit ==> callCreateOffersMethod >> '+JSON.stringify(resultData));        
                if (state === "SUCCESS"){
                    if(resultData.success){
                        if(component.get("v.sobjecttype")=='Account'){
                            this.showMsg(component,event,'Deals has been created successfully.');
                            var oppRecId;
                            //  alert(JSON.stringify(resultData.data));
                            
                            if(resultData.data.Id != null){
                                oppRecId = resultData.data.Id;
                                
                                //  alert('oppRecId'+oppRecId);
                                var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    recordId: oppRecId,
                                    slideDevName: "related"
                                });
                                navEvt.fire();
                                $A.get("e.force:closeQuickAction").fire();
                                $A.get('e.force:refreshView').fire();
                            }    
                        }else if(component.get("v.sobjecttype")=='Opportunity'){
                            this.showMsg(component,event,'Unit has been added successfully.');
                        }else if(component.get("v.sobjecttype")=='Lead'){
                            //Lakshaya's else if block
                            this.showMsg(component,event,'Unit has been added successfully.');
                        }
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                    }else{
                        this.showErrorMsg(component,event,'There is some error','error');
                    }  
                }
                else if(state === "ERROR"){
                    this.showErrorMsg(component,event,'There is some error, Please Contact System Admin','error');
                }  
                component.set("v.isSpinner", false);
            });
            $A.enqueueAction(actionUnit);
        }
    },
    
    //Method to error message
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
    
    //Method to error message
    showMsg : function(component,event,message) {        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message:message,
            type: 'success'
        });
        component.set("v.isSpinner", false); 
        toastEvent.fire();
    },
    
    sortBy: function(field, reverse, primer) {
        var key = primer
        ? function(x) {
            return primer(x[field]);
        }
        : function(x) {
            return x[field];
        };
        
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.onloadUnitList");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.onloadUnitList", data);
    },
    
    formatCurr : function(price){    
        return price.toLocaleString();
    }
})