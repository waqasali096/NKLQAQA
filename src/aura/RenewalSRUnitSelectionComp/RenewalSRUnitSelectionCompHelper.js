({
    doInitHelper : function(component,event,helper){
        console.log('Inside Do initHelper RenewalSRUnitController');
        var action = component.get("c.getUnits");
        action.setParams({ oppId : component.get('v.recordId') });
        action.setCallback(this, function(response) {
            var state = response.getState();       
            if (state === "SUCCESS"){
                component.set("v.selTabId", "tab1");
                var oRes = response.getReturnValue();
                console.log('oRes>>>',oRes);
                //console.log('oRes.propertyList.length>>>',oRes.propertyList.length);
                
                if(oRes.isError == true){
                    component.set('v.errorMessage',oRes.message);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": component.get("v.errorMessage"),
                        "type": "error"
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();   
                }
                if(oRes.propertyList.length > 0){
                    component.set('v.totalList', oRes.propertyList);
                    component.set('v.flag', oRes.flag);
                    
                    component.set('v.totalListT2', oRes.projectUnitList);
                    
                    component.set('v.oppMap', oRes.oppMap);
                    component.set('v.projectUnitList', oRes.projectUnitList);
                    
                    component.set('v.isSingleUnitAcc',oRes.isSingleUnitAcc);
                    component.set('v.renewalDate',oRes.leaseRenewalDate);//renewalDateDefault
                    component.set('v.renewalDateDefault',oRes.leaseRenewalDate);
                    component.set('v.renewalEndDateDefault',oRes.leaseRenewalEndDate);
                    
                    component.set('v.rentPerDay',oRes.rentPerDay);//rent perDay
                    
                    component.set('v.ProjectName',oRes.projectName);
                    component.set('v.leasingType',oRes.leasingType);
                    console.log('Leasing type >>>',oRes.leasingType);
                    component.set('v.noOfCheques',"1");//made default to 1 from oRes.noOfCheques
                    component.set("v.renewalType","Full");//made default to Full                   
                    if(oRes.isSingleUnitAcc){//remove if not used hitesh
                        component.set('v.summaryList', oRes.projectUnitList);
                    }
                    var result = oRes.oppMap;
                    var fieldMap = [];
                    for(var key in result){
                        fieldMap.push({key: key, value: result[key]});
                    }
                    component.set("v.oppMap", fieldMap);
                    this.showUnitsHelper(component, event);
                    let NoOfBedroomsMap = [];
                    for(let key in oRes.NoOfBedroomsMap){
                        NoOfBedroomsMap.push({key: key , value: oRes.NoOfBedroomsMap[key]});
                    }
                    component.set("v.noOfBedroomMap",NoOfBedroomsMap);
                    let unittype = [];
                    for(let key in oRes.unitType){
                        unittype.push({key: key,value: oRes.unitType[key]}); 
                    }
                    component.set("v.unitTypeMap",unittype);
                    let propertyTypeMap = [];
                    for(let key in oRes.propertyTypeMap){
                        propertyTypeMap.push({key: key,value: oRes.propertyTypeMap[key]}); 
                    }
                    component.set("v.propertyTypeMap",propertyTypeMap);
                    let buildingMap = [];
                    for(let key in oRes.buildingMap){
                        buildingMap.push({key: key,value: oRes.buildingMap[key]}); 
                    }
                    component.set("v.buildingMap",buildingMap);
                }else{
                    component.set("v.bNoRecordsFound" , true);
                }
                component.set('v.isTab1',true); 
            }
            else{
                alert('Error...');
            }
        });
        $A.enqueueAction(action);
    }, 
	 showUnitsHelper : function(component,event){ 
       component.set('v.isShowTable',true);
        let totalList = component.get('v.totalList');
        let selectedOppId = component.get("v.recordId");
         console.log('selectedOppId>>>>',selectedOppId);
        let propertyList = [];
        for(let i=0;i<totalList.length;i++){
            console.log(totalList[i].dealId);
            if(totalList[i].dealId == selectedOppId){
                totalList[i].isChecked = true;//commented to see if the check box is unchecked
                propertyList.push(totalList[i]);
            }
        }
        console.log(propertyList);
        component.set("v.listOfProperty",propertyList);
        let pageSize = component.get("v.pageSize");
                    let totalRecordsList = propertyList;
                    let totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    let PaginationLst = [];
                    for(let i=0; i < pageSize; i++){
                        if(component.get("v.listOfProperty").length > i){
                            PaginationLst.push(propertyList[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
        			console.log('PaginationLst',PaginationLst);
                    component.set("v.selectedCount" , totalLength);
         			component.set("v.isAllSelected" , true);
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));  
        component.set('v.isShowtable',true);
        component.set('v.renewalType',null);
        component.set('v.noOfMonths',null);
    },
     //Helper for the Tab 2 add unit// call this on reset as well
    showUnitsHelperT2 : function(component,event){ //Helper for the 
        let totalList = component.get('v.totalListT2');
        let selectedOppId = component.get("v.recordId");
        //end
        let pageSize = component.get("v.pageSizeT2");
                    let totalRecordsList = totalList;
                    let totalLength = totalRecordsList.length ;
                    component.set("v.totalRecordsCountT2", totalLength);
                    component.set("v.startPageT2",0);
                    component.set("v.endPageT2",pageSize-1);
                    let PaginationLst = [];
                    for(let i=0; i < pageSize; i++){
                           if(totalList[i] != null){
                           PaginationLst.push(totalList[i]); 
                        }     
                    }
                    component.set('v.PaginationListT2', PaginationLst);
                    component.set("v.totalPagesCountT2", Math.ceil(totalLength / pageSize));  
                    component.set('v.isShowtable',true);
        component.set('v.totalSearchRecordListCount',0);
        component.set('v.totalSearchRecordList',null);
    },
    //Helper for the Tab 2 add unit// call this on reset as well
    searchShowUnitsHelperT2 : function(component,event){ 
        component.set('v.isShowTable',true);
        let listOfPropertyT2 = component.get('v.totalListT2');
        let pageSize = component.get("v.pageSizeT2");
        let noOfBedroom=component.get("v.selectedBedroom");
        let unitCodeSearchString=component.get("v.unitCodeSearchString");
        let selectedPropertyType=component.get("v.selectedPropertyType");
        let selectedBuilding=component.get("v.selectedBuilding");//undefined
        let selectedUnitType=component.get("v.selectedUnitType");
        debugger;
                    let totalLength = listOfPropertyT2.length ;
                    let PaginationLst = [];
        			let TotalSearchRecord = [];
                    for(let i=0; i < listOfPropertyT2.length; i++){
                            if(noOfBedroom!="" && (unitCodeSearchString === null || unitCodeSearchString=="") && selectedUnitType=="" 
                               && selectedPropertyType =="" && selectedBuilding == ""){
                                 if(listOfPropertyT2[i].noOfBedrooms==noOfBedroom){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                             }
                            } // only no of bedrooms 1
                            else if(selectedUnitType!="" &&( unitCodeSearchString=="") 
                                    && noOfBedroom=="" && selectedPropertyType =="" && selectedBuilding == ""){
                                 if(listOfPropertyT2[i].unitType==selectedUnitType){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }
                            }// only unit type2
                            else if((unitCodeSearchString !=""  ) && noOfBedroom=="" && selectedUnitType==""
                                    && selectedPropertyType =="" && selectedBuilding == ""){
                                let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas)){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }  
                            }// only search string3
                           else if((unitCodeSearchString =="") && noOfBedroom=="" && selectedUnitType==""
                                    && selectedPropertyType !="" && selectedBuilding == ""){
                                if(listOfPropertyT2[i].propertyType==selectedPropertyType){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }  
                            }// only property type4
                         else if((unitCodeSearchString == undefined || unitCodeSearchString =="") && noOfBedroom=="" && selectedUnitType==""
                                    && selectedPropertyType =="" && selectedBuilding != ""){
                               if(listOfPropertyT2[i].buildingId==selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                             }  
                            }// only building5
                            else if((unitCodeSearchString!= undefined || unitCodeSearchString!="") && noOfBedroom!="" && selectedUnitType==""
                                   && selectedPropertyType =="" && selectedBuilding == ""){
                                let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas) && listOfPropertyT2[i].noOfBedrooms==noOfBedroom ){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                             }   
                            }// search string and no of bedrooms 6
                            else if((unitCodeSearchString!= undefined || unitCodeSearchString!="") && noOfBedroom=="" && selectedUnitType!=""
                                   && selectedPropertyType =="" && selectedBuilding == ""){
                                let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas)  && listOfPropertyT2[i].unitType==selectedUnitType){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }    
                           }// search string and unit type7
                          else if((unitCodeSearchString!= undefined || unitCodeSearchString!="") && noOfBedroom=="" && selectedUnitType==""
                                   && selectedPropertyType !="" && selectedBuilding == ""){
                                let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas)  && listOfPropertyT2[i].propertyType == selectedPropertyType){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }    
                           }// search string and property type8
                          else if((unitCodeSearchString!= undefined || unitCodeSearchString!="") && noOfBedroom=="" && selectedUnitType==""
                                   && selectedPropertyType =="" && selectedBuilding != ""){
                                let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas)  && listOfPropertyT2[i].buildingId == selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }    
                           }// search string and building9
                           else if((unitCodeSearchString == undefined || unitCodeSearchString =="") && noOfBedroom !="" && selectedUnitType !=""
                                   && selectedPropertyType =="" && selectedBuilding == ""){
                                if(listOfPropertyT2[i].noOfBedrooms==noOfBedroom && listOfPropertyT2[i].unitType==selectedUnitType){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }    
                           }//unit type and no of bedrooms10
                          else if((unitCodeSearchString == undefined || unitCodeSearchString =="") && noOfBedroom =="" && selectedUnitType !=""
                                   && selectedPropertyType !="" && selectedBuilding == ""){
                                if(listOfPropertyT2[i].propertyType == selectedPropertyType && listOfPropertyT2[i].unitType==selectedUnitType){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                                }
                           }// unit type and property type11
                          else if((unitCodeSearchString == undefined || unitCodeSearchString =="") && noOfBedroom =="" && selectedUnitType !=""
                                   && selectedPropertyType =="" && selectedBuilding != ""){
                                if(listOfPropertyT2[i].unitType == selectedUnitType && listOfPropertyT2[i].buildingId== selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                                }
                           }// unit type and building12
                          else if((unitCodeSearchString == undefined || unitCodeSearchString =="") && noOfBedroom !="" && selectedUnitType ==""
                                   && selectedPropertyType =="" && selectedBuilding != ""){
                                if(listOfPropertyT2[i].noOfBedrooms == noOfBedroom && listOfPropertyT2[i].buildingId== selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                                }
                           }// no of bedrooms and building13
                          else if((unitCodeSearchString == undefined || unitCodeSearchString =="") && noOfBedroom !="" && selectedUnitType ==""
                                   && selectedPropertyType !="" && selectedBuilding == ""){
                                if(listOfPropertyT2[i].noOfBedrooms == noOfBedroom && listOfPropertyT2[i].propertyType== selectedPropertyType){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                                }
                           }// no of bedrooms and property Type14
                           else if((unitCodeSearchString == undefined || unitCodeSearchString =="") && noOfBedroom =="" && selectedUnitType ==""
                                   && selectedPropertyType !="" && selectedBuilding != ""){
                                if(listOfPropertyT2[i].propertyType == selectedPropertyType && listOfPropertyT2[i].buildingId== selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                                }
                           }// building and property type15
                            else if((unitCodeSearchString != undefined || unitCodeSearchString!="") && noOfBedroom!="" && selectedUnitType!=""
                                   && selectedPropertyType =="" && selectedBuilding == ""){
                                console.log("three criteria scenario");
                                let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas) && listOfPropertyT2[i].noOfBedrooms==noOfBedroom && listOfPropertyT2[i].unitType==selectedUnitType){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   // search string,no of bedrooms,unit type16
                            } 
                        else if((unitCodeSearchString != undefined || unitCodeSearchString!="") && noOfBedroom!="" && selectedUnitType==""
                                   && selectedPropertyType !="" && selectedBuilding == ""){
                                console.log("three criteria scenario");
                                let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas) && listOfPropertyT2[i].noOfBedrooms==noOfBedroom && listOfPropertyT2[i].propertyType==selectedPropertyType){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            } // search string,no of bedrooms,property type17
                        else if((unitCodeSearchString != undefined || unitCodeSearchString!="") && noOfBedroom!="" && selectedUnitType==""
                                   && selectedPropertyType =="" && selectedBuilding != ""){
                                console.log("three criteria scenario");
                                let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas) && listOfPropertyT2[i].noOfBedrooms==noOfBedroom && listOfPropertyT2[i].buildingId==selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            }// search string,no of bedrooms,building18
                        else if((unitCodeSearchString == undefined || unitCodeSearchString=="") && noOfBedroom!="" && selectedUnitType!=""
                                   && selectedPropertyType !="" && selectedBuilding == ""){
                                console.log("three criteria scenario");
                              
                                if(listOfPropertyT2[i].noOfBedrooms==noOfBedroom && listOfPropertyT2[i].unitType==selectedUnitType && listOfPropertyT2[i].propertyType==selectedPropertyType){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            }// no of bedrooms,unit type,property type19
                        else if((unitCodeSearchString == undefined || unitCodeSearchString=="") && noOfBedroom!="" && selectedUnitType!=""
                                   && selectedPropertyType =="" && selectedBuilding != ""){
                                console.log("three criteria scenario");
                                
                                if(listOfPropertyT2[i].noOfBedrooms==noOfBedroom && listOfPropertyT2[i].unitType==selectedUnitType && listOfPropertyT2[i].buildingId==selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            }// no of bedrooms,unit type,building20
                         else if((unitCodeSearchString == undefined || unitCodeSearchString=="") && noOfBedroom=="" && selectedUnitType!=""
                                   && selectedPropertyType !="" && selectedBuilding != ""){
                                console.log("three criteria scenario");
                                
                                if(listOfPropertyT2[i].unitType==selectedUnitType && listOfPropertyT2[i].propertyType==selectedPropertyType && listOfPropertyT2[i].buildingId==selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            }// unit type,property type,building21
                         else if((unitCodeSearchString != undefined || unitCodeSearchString!="") && noOfBedroom=="" && selectedUnitType!=""
                                   && selectedPropertyType !="" && selectedBuilding == ""){
                                console.log("three criteria scenario");
                                 let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas) && listOfPropertyT2[i].unitType==selectedUnitType && listOfPropertyT2[i].propertyType==selectedPropertyType ){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            }// unit type,property type,search string 22
                        else if((unitCodeSearchString != undefined || unitCodeSearchString!="") && noOfBedroom=="" && selectedUnitType==""
                                   && selectedPropertyType !="" && selectedBuilding != ""){
                                console.log("three criteria scenario");
                                 let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas) && listOfPropertyT2[i].buildingId==selectedBuilding && listOfPropertyT2[i].propertyType==selectedPropertyType ){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            }// property type,Building,search string23
                        else if((unitCodeSearchString== undefined || unitCodeSearchString=="") && noOfBedroom!="" && selectedUnitType==""
                                   && selectedPropertyType !="" && selectedBuilding != ""){
                                console.log("four criteria scenario");
                                 
                                if( listOfPropertyT2[i].noOfBedrooms==noOfBedroom && listOfPropertyT2[i].propertyType==selectedPropertyType && listOfPropertyT2[i].buildingId==selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            }// noOfBedroom,Property type,building24
                        else if((unitCodeSearchString != undefined || unitCodeSearchString!="") && noOfBedroom=="" && selectedUnitType!=""
                                   && selectedPropertyType =="" && selectedBuilding != ""){
                                console.log("four criteria scenario");
                                 let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas) && listOfPropertyT2[i].unitType==selectedUnitType && listOfPropertyT2[i].buildingId==selectedBuilding ){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            }// search string,unit type,Building25
                        else if((unitCodeSearchString != undefined || unitCodeSearchString!="") && noOfBedroom!="" && selectedUnitType!=""
                                   && selectedPropertyType !="" && selectedBuilding == ""){
                                console.log("four criteria scenario");
                                 let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas) && listOfPropertyT2[i].noOfBedrooms==noOfBedroom && listOfPropertyT2[i].unitType==selectedUnitType && listOfPropertyT2[i].propertyType==selectedPropertyType){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            }// search string,noOfBedroom,unit type,property type26
                        else if((unitCodeSearchString != undefined || unitCodeSearchString!="") && noOfBedroom!="" && selectedUnitType!=""
                                   && selectedPropertyType =="" && selectedBuilding != ""){
                                console.log("four criteria scenario");
                                 let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas) && listOfPropertyT2[i].noOfBedrooms==noOfBedroom && listOfPropertyT2[i].unitType==selectedUnitType && listOfPropertyT2[i].buildingId==selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            }// search string,noOfBedroom,unit type,building27
                         
                        else if((unitCodeSearchString== undefined || unitCodeSearchString=="") && noOfBedroom!="" && selectedUnitType!=""
                                   && selectedPropertyType !="" && selectedBuilding != ""){
                                console.log("four criteria scenario");
                                 
                                if( listOfPropertyT2[i].noOfBedrooms==noOfBedroom && listOfPropertyT2[i].unitType==selectedUnitType && listOfPropertyT2[i].propertyType==selectedPropertyType && listOfPropertyT2[i].buildingId==selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            }// noOfBedroom,unit type,Property type,building28
                        else if((unitCodeSearchString != undefined || unitCodeSearchString!="") && noOfBedroom=="" && selectedUnitType!=""
                                   && selectedPropertyType !="" && selectedBuilding != ""){
                                console.log("four criteria scenario");
                                 let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas) &&  listOfPropertyT2[i].unitType==selectedUnitType && listOfPropertyT2[i].propertyType==selectedPropertyType && listOfPropertyT2[i].buildingId==selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            }// search string,unit type, property type, building29
                        else if((unitCodeSearchString != undefined || unitCodeSearchString!="") && noOfBedroom!="" && selectedUnitType==""
                                   && selectedPropertyType !="" && selectedBuilding != ""){
                                console.log("four criteria scenario");
                                 let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas) &&  listOfPropertyT2[i].noOfBedrooms==noOfBedroom && listOfPropertyT2[i].propertyType==selectedPropertyType && listOfPropertyT2[i].buildingId==selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                            }// search string,noOfBedrooms, property type, building30
                         else if((unitCodeSearchString != undefined || unitCodeSearchString!="") && noOfBedroom!="" && selectedUnitType!=""
                                   && selectedPropertyType !="" && selectedBuilding != ""){
                                console.log("four criteria scenario");
                                 let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas) &&  listOfPropertyT2[i].noOfBedrooms==noOfBedroom && listOfPropertyT2[i].unitType==selectedUnitType && listOfPropertyT2[i].propertyType==selectedPropertyType && listOfPropertyT2[i].buildingId==selectedBuilding){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }   
                           
                            }// search string,noOfBedrooms, uNIT TYPE,property type, building31
                    }
        			//next and previous param
        			console.log("TotalSearchRecord before set@@@@",component.get("v.totalSearchRecordList"));
        			component.set("v.totalRecordsCountT2", TotalSearchRecord.length);
                    component.set("v.startPageT2",0);
                    component.set("v.endPageT2",pageSize-1);
        			component.set("v.totalSearchRecordList", TotalSearchRecord);
        			component.set("v.totalSearchRecordListCount",TotalSearchRecord.length);
                    component.set('v.PaginationListT2', PaginationLst);
                    component.set("v.totalPagesCountT2", Math.ceil(TotalSearchRecord.length / pageSize));  
                    component.set('v.isShowtable',true);
                    
    },
    //Helper for the Tab 2 commercial
    searchShowUnitsHelperT2Commercial : function(component,event){ 
       component.set('v.isShowTable',true);
        let listOfPropertyT2 = component.get('v.listOfPropertyT2');
        let pageSize = component.get("v.pageSizeT2");
        let selectedUnitType=component.get("v.selectedUnitType");
        let unitCodeSearchString=component.get("v.unitCodeSearchString");//undefined
         console.log('selectedUnitType@@@',selectedUnitType);
        console.log('unitCodeSearchString@@@',unitCodeSearchString);
                    let totalRecordsList = listOfPropertyT2;
                    let totalLength = totalRecordsList.length ;
                    
                    debugger;
                    let PaginationLst = [];
        			let TotalSearchRecord = [];
                    for(let i=0; i < listOfPropertyT2.length; i++){
                        if(component.get("v.listOfPropertyT2").length > i){
                            if(selectedUnitType!="" &&(unitCodeSearchString== undefined || unitCodeSearchString=="")){
                                console.log("bedroom not selected");
                                console.log('listOfPropertyT2[i].unitType inside unit type>>>',listOfPropertyT2[i].unitType);
                                 if(listOfPropertyT2[i].unitType==selectedUnitType){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }
                            }
                            else if((unitCodeSearchString!= undefined || unitCodeSearchString!="") && selectedUnitType==""){
                                console.log("unit code not selected");
                                let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                if(unitNameLwCas.includes(searchStrgLwCas)){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }
                               
                            }  
                            
                            else if((unitCodeSearchString!= undefined || unitCodeSearchString!="") && selectedUnitType!=""){
                                console.log("two criteria scenario");
                                let unitNameLwCas=listOfPropertyT2[i].unitName.toLocaleLowerCase();
                                let searchStrgLwCas=unitCodeSearchString.toLocaleLowerCase();
                                console.log('listOfPropertyT2[i].unitType inside both>>>',listOfPropertyT2[i].unitType);
                                if(unitNameLwCas.includes(searchStrgLwCas) && listOfPropertyT2[i].unitType==selectedUnitType){
                                  if(PaginationLst.length<pageSize){
                                	PaginationLst.push(listOfPropertyT2[i]);
                                  }
                                  TotalSearchRecord.push(listOfPropertyT2[i]);
                            }
                               
                            } 
                        } 
                    }
        			//next and previous param
        			console.log("TotalSearchRecord before set@@@@",component.get("v.totalSearchRecordList"));
        			component.set("v.totalRecordsCountT2", TotalSearchRecord.length);
                    component.set("v.startPageT2",0);
                    component.set("v.endPageT2",pageSize-1);
        			component.set("v.totalSearchRecordList", TotalSearchRecord);
        			component.set("v.totalSearchRecordListCount",TotalSearchRecord.length);
        			console.log("TotalSearchRecord after set@@@@",component.get("v.totalSearchRecordList"));
        
                    component.set('v.PaginationListT2', PaginationLst);
        			console.log('PaginationLstT2',PaginationLst);
                    //component.set("v.selectedCountT2" , totalLength);//In tab2 rows not preselected
         			//component.set("v.isAllSelectedT2" , true);//In tab2 rows not preselected
                    component.set("v.totalPagesCountT2", Math.ceil(totalLength / pageSize));  
                     component.set('v.isShowtable',true);
                    //component.set('v.renewalType',null);
                    //component.set('v.noOfCheques',null);
                    //component.set('v.noOfMonths',null);
    },
     // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        let Paginationlist = [];
        let counter = 0;
        for(let i = end + 1; i < end + pageSize + 1; i++){
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
        let Paginationlist = [];
        let counter = 0;
        for(let i= start-pageSize; i < start ; i++){
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
     // navigate to next pagination record set   
    nextT2 : function(component,event,sObjectList,end,start,pageSize){
        let Paginationlist = [];
        let counter = 0;
        for(let i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                if(component.find("selectAllIdT2").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]);  
                }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPageT2",start);
        component.set("v.endPageT2",end);
        component.set('v.PaginationListT2', Paginationlist);
    },
    // navigate to previous pagination record set   
    previousT2 : function(component,event,sObjectList,end,start,pageSize){
        let Paginationlist = [];
        let counter = 0;
        for(let i= start-pageSize; i < start ; i++){
            if(i > -1){
                if(component.find("selectAllIdT2").get("v.value")){
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
        component.set("v.startPageT2",start);
        component.set("v.endPageT2",end);
        component.set('v.PaginationListT2', Paginationlist);
    },
    selectAllCheckBoxTab1Helper : function(component,event,helper){
         let selectedHeaderCheck = event.getSource().get("v.checked");
        let updatedAllRecords = [];
        let updatedPaginationList = [];
        let listOfProperty = component.get("v.listOfProperty");
        let PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        for (let i = 0; i < listOfProperty.length; i++) {
            if (selectedHeaderCheck == true ) {
                listOfProperty[i].isChecked = true;
                component.set("v.selectedCount", listOfProperty.length);
            } else {
                listOfProperty[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfProperty[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (let i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true ) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listOfProperty", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
    },
    selectAllCheckBoxTab2Helper : function(component,event,helper){
        let selectedHeaderCheck = event.getSource().get("v.checked");
        let updatedAllRecords = [];
        let updatedPaginationList = [];
        let listOfProperty = component.get("v.totalListT2");
        let PaginationList = component.get("v.PaginationListT2");
        // play a for loop on all records list 
        for (let i = 0; i < listOfProperty.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            debugger;
            console.log("selectedHeaderCheck>>>>",selectedHeaderCheck);
            if (selectedHeaderCheck == true ) {
                
                listOfProperty[i].isChecked = true;
                component.set("v.selectedCountT2", listOfProperty.length);
            } else {
                listOfProperty[i].isChecked = false;
                component.set("v.selectedCountT2", 0);
            }
            updatedAllRecords.push(listOfProperty[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (let i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true ) {
                debugger;
                console.log(">>>>",PaginationList.length);
                PaginationList[i].isChecked = true;
            } else {
                debugger;
                console.log(">>>>",PaginationList.length);
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.totalListT2", updatedAllRecords);
        component.set("v.PaginationListT2", updatedPaginationList);
    },
    tabSelectHelper : function(component,event,helper){
    let selectedTab=component.get("v.selTabId"); 
        console.log("selectedTab >>>>",selectedTab);
        let listOfProperty=component.get("v.listOfProperty");
        let listOfPropertyT2=component.get("v.totalListT2"); 
        let renewalType= component.get("v.renewalType");//renewal end date
        let renewalDate=component.get("v.renewalEndDate");
        let paymentMode=component.get("v.paymentMode");
        let renewalStartDate=component.get("v.renewalDate");
        let renewalStartDateDefault=component.get("v.renewalDateDefault");
        let renewalEndDateDefault=component.get("v.renewalEndDateDefault");
        console.log('renewalEndDateDefault>>>>>',renewalEndDateDefault);
        if(selectedTab ==="tab1"){
            
            component.set('v.isTab1',true); 
            component.set('v.isTab2',false);
            component.set('v.isTab3',false); 
        }
        if(selectedTab ==="tab2"){
            
            if(renewalType=='' || renewalType==null || renewalType== undefined ){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please select Renewal Type before proceeding",
                    "type": "warning"
                });
                toastEvent.fire();
                component.set('v.isTab1',true); 
                component.set('v.isTab2',false);
                component.set('v.isTab3',false); 
                component.set("v.selTabId","tab1"); 
            }
            else if(renewalStartDate=='' || renewalStartDate==null || renewalStartDate==undefined){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please select the renewal start before proceeding",
                    "type": "warning"
                });
                toastEvent.fire();
                component.set('v.isTab1',true); 
                component.set('v.isTab2',false);
                component.set('v.isTab3',false); 
                component.set("v.selTabId","tab1");  
            }
                else if(renewalStartDate < renewalStartDateDefault){
                    var toastEvent = $A.get("e.force:showToast");
                    
                    const [year, month, day] = renewalStartDate.split('-');
                    const result = [month, day, year].join('/');
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please enter valid date.As renewal date cannot be before:- "+result,
                        "type": "warning"
                    });
                    toastEvent.fire();
                    component.set('v.isTab1',true); 
                    component.set('v.isTab2',false);
                    component.set('v.isTab3',false); 
                    component.set("v.selTabId","tab1");  
                }else if(renewalType == 'Extension' && (renewalDate=='' || renewalDate==null || renewalDate==undefined)){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please enter the renewal end date before proceeding",
                        "type": "warning"
                    });
                    toastEvent.fire();
                    component.set('v.isTab1',true); 
                    component.set('v.isTab2',false);
                    component.set('v.isTab3',false); 
                    component.set("v.selTabId","tab1");  
                }
                    else if(renewalType == 'Extension' && renewalEndDateDefault < renewalDate){
                        var toastEvent = $A.get("e.force:showToast");
                        const [year, month, day] = renewalEndDateDefault.split('-');
                        const result = [month, day, year].join('/');
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Renewal end date cannot be grater than "+result,
                            "type": "warning"
                        });
                        toastEvent.fire();
                        component.set('v.isTab1',true); 
                        component.set('v.isTab2',false);
                        component.set('v.isTab3',false); 
                        component.set("v.selTabId","tab1");  
                    }
                        else if(renewalType == 'Extension' && renewalStartDate >= renewalDate){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Lease renewal date should be grater than renewal end date",
                                "type": "warning"
                            });
                            toastEvent.fire();
                            component.set('v.isTab1',true); 
                            component.set('v.isTab2',false);
                            component.set('v.isTab3',false); 
                            component.set("v.selTabId","tab1");  
                        }else{
                            component.set('v.isTab1',false);
                            component.set('v.isTab3',false);
                            // Fix for initial load
                            component.set("v.selectedBedroom",'');
                            component.set("v.unitCodeSearchString",'');
                            this.clearHelper(component, event); 
                            //helper.searchShowUnitsHelperT2(component,event);
                            
                            // End
                            component.set('v.isTab2',true);
                        }
            
        }
        if(selectedTab ==="tab3"){
            debugger;
            if(renewalType=='' || renewalType==null || renewalType== undefined ){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please select Renewal Type before proceeding",
                    "type": "warning"
                });
                toastEvent.fire();
                component.set('v.isTab1',true); 
                component.set('v.isTab2',false);
                component.set('v.isTab3',false); 
                component.set("v.selTabId","tab1");
            }
            else if(renewalStartDate=='' || renewalStartDate==null || renewalStartDate==undefined){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please select the renewal start before proceeding",
                    "type": "warning"
                });
                toastEvent.fire();
                component.set('v.isTab1',true); 
                component.set('v.isTab2',false);
                component.set('v.isTab3',false); 
                component.set("v.selTabId","tab1");  
            }
                else if(renewalType == 'Extension' && (renewalDate=='' || renewalDate==null || renewalDate==undefined)){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please enter the renewal end date before proceeding",
                        "type": "warning"
                    });
                    toastEvent.fire();
                    component.set('v.isTab1',true); 
                    component.set('v.isTab2',false);
                    component.set('v.isTab3',false); 
                    component.set("v.selTabId","tab1");  
                }
                    else if(renewalType == 'Extension' && renewalEndDateDefault < renewalDate){
                        var toastEvent = $A.get("e.force:showToast");
                        const [year, month, day] = renewalEndDateDefault.split('-');
                        const result = [month, day, year].join('/');
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Please enter a valid date as the renewal end date cannot be after "+result,
                            "type": "warning"
                        });
                        toastEvent.fire();
                        component.set('v.isTab1',true); 
                        component.set('v.isTab2',false);
                        component.set('v.isTab3',false); 
                        component.set("v.selTabId","tab1");  
                    }
                        else if(renewalType == 'Extension' && renewalStartDate >= renewalDate){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "Lease renewal date should be grater than renewal end date",
                                "type": "warning"
                            });
                            toastEvent.fire();
                            component.set('v.isTab1',true); 
                            component.set('v.isTab2',false);
                            component.set('v.isTab3',false); 
                            component.set("v.selTabId","tab1");  
                        }
                            else{
                                
                            
            component.set('v.isTab1',false);
            component.set('v.isTab2',false);
            //component.set("v.selTabId", "tab3");
            let completePropList = [];
            let terminationUnitsList = [];
            for(let i=0; i < listOfProperty.length; i++){
                if(listOfProperty[i].isChecked==true){
                    completePropList.push(listOfProperty[i]);    
                }
                else if(listOfProperty[i].isChecked==false){
                    terminationUnitsList.push(listOfProperty[i]);
                }
            }
            
            for(let i=0; i < listOfPropertyT2.length; i++){
                if(listOfPropertyT2[i].isChecked==true){
                    completePropList.push(listOfPropertyT2[i]);    
                } 
            }
            
            component.set("v.completePropertyList",completePropList);
            component.set("v.completePropertyCount",completePropList.length);
            component.set("v.terminationUnitsList",terminationUnitsList);
            
            component.set('v.isTab3',true);
            
            //component.set("v.selTabId", "tab3");
            console.log(component.get("v.completePropertyList")); 
                            }
        }
    },      
        clearHelper : function(component,event,helper){
            component.set("v.selectedBedroom",'');
            component.set("v.unitCodeSearchString",'');
            component.set("v.selectedUnitType",'');
            component.set("v.selectedPropertyType",'');
            component.set("v.selectedBuilding",'');
            this.showUnitsHelperT2(component, event); 
        }
    
})