({
    getRecordType : function(component,event,recordid){
        var action = component.get("c.getRecordTypeId");
        action.setParams({
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {   
              var result = response.getReturnValue();
              console.log('result '+ JSON.stringify(result));
              component.set("v.recordTypeId",result); 
          }
        });
        $A.enqueueAction(action);
      },

      getOpportunityDetail : function(component,event,recordId){

        var action = component.get("c.getOpportunityDetail");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {   
              var result = response.getReturnValue();
              console.log('account result '+ JSON.stringify(result));
              component.set("v.accountValue",result.AccountId); 
              component.set("v.opportunitySobj",result);
          }
        });
        $A.enqueueAction(action);
      },

      updateRecordType : function(component, event, myRecordId){
        var action = component.get("c.updateRecordType");
        action.setParams({
            recordId : myRecordId,
            recordTypeId : component.get("v.recordTypeId")
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {   
              var result = response.getReturnValue();
              console.log('Success result '+ JSON.stringify(result));
              if(result === 'No'){
                component.set('v.isShowtable',true);
                component.set('v.isShowMainScreen',false);
                /*var navService = component.find("navService");        
                var pageReference = {
                  "type": 'standard__recordPage',         
                  "attributes": {              
                  "recordId": myRecordId, //component.get("v.recordId"),
                  "actionName": "view",               
                  "objectApiName":"Case"              
                  }     
                };*/
                
            //component.set("v.pageReference", pageReference);
                component.set('v.spinner',false);
            //var pageReference = component.get("v.pageReference");
            //navService.navigate(pageReference);
            }else{
              component.set('v.isShowtable',false);
              component.set('v.isShowMainScreen',false);
              var navService = component.find("navService");        
                var pageReference = {
                  "type": 'standard__recordPage',         
                  "attributes": {              
                  "recordId": myRecordId, //component.get("v.recordId"),
                  "actionName": "view",               
                  "objectApiName":"Case"              
                  }     
                };
                component.set("v.pageReference", pageReference);
                var pageReference = component.get("v.pageReference");
                navService.navigate(pageReference);
            }
          }
        });
        $A.enqueueAction(action);
      },

      fetchSubject : function(component,event,recordId){

        var action = component.get("c.updateTerminationSubject");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {   
              var result = response.getReturnValue();
              console.log('Subject result '+ JSON.stringify(result));
              component.set("v.subjectValue",result); 
          }
        });
        $A.enqueueAction(action);
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
    console.log('selectedList',selectedList);
    
    var action = component.get("c.createCaseUnitRecord"); 
    action.setParams({ 
      opptyUnitWrapperList : selectedList,
      caseId : component.get("v.caseId"),
                     });
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS"){
            this.showToast('Success','Request created Successfully','success');
            //$A.get("e.force:closeQuickAction").fire();
            var navService = component.find("navService");        
                var pageReference = {
                  "type": 'standard__recordPage',         
                  "attributes": {              
                  "recordId": component.get("v.caseId"),
                  "actionName": "view",               
                  "objectApiName":"Case"              
                  }     
                };
                
            component.set("v.pageReference", pageReference);
            var pageReference = component.get("v.pageReference");
            navService.navigate(pageReference);
        }
        else{
            alert('Error in adding Unit');
        }
    });
    $A.enqueueAction(action);
  },

  fetchUnits : function(component,event,helper){
    var action = component.get("c.getUnits");
    action.setParams({ 
      recordId : component.get('v.recordId') 
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS"){
        var oRes = response.getReturnValue();
                console.log(oRes.opptyUnitWrapperList.length);
                if(oRes.isError){
                    this.showToast('Error',oRes.message,'error');
                    $A.get("e.force:closeQuickAction").fire();
                }else if(oRes.opptyUnitWrapperList.length > 0){
                    var propertyList = [];
                    for(let i=0;i<oRes.opptyUnitWrapperList.length;i++){
                          propertyList.push(oRes.opptyUnitWrapperList[i]);
                    }
                    component.set("v.listOfProperty",oRes.opptyUnitWrapperList);
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
        			      console.log('PaginationLst',PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));  
                }
      }
    });
        $A.enqueueAction(action);
  },


  
})