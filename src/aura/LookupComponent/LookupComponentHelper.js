({
	itemSelected : function(component, event, helper) {
        var target = event.target;   
        var SelIndex = helper.getIndexFrmParent(target,helper,"data-selectedIndex");  
        if(SelIndex){
            var serverResult = component.get("v.server_result");
            var selItem = serverResult[SelIndex];
            if(selItem.val){
               component.set("v.selItem",selItem);
               component.set("v.last_ServerResult",serverResult);
            } 
            component.set("v.server_result",null); 
        } 
	}, 
    serverCall : function(component, event, helper) {  
       
        var target = event.target;  
        var searchText = target.value; 
         console.log('searchText in lookup',searchText);
        var last_SearchText = component.get("v.last_SearchText");
        //Escape button pressed 
        if (event.keyCode == 27 || !searchText.trim()) { 
            helper.clearSelection(component, event, helper);
        }else if( searchText && searchText.trim() != last_SearchText){ 
         
            var objectName = component.get("v.objectName");
            var field_API_text = component.get("v.field_API_text");
            var field_API_val = component.get("v.field_API_val");
            var field_API_search = component.get("v.field_API_search");
            var limit = component.get("v.limit");
            //=========================================
            var Selectedmasterplans = component.get("v.Seleted_Master");
            var SeletedBlook = component.get("v.Seleted_Blook");
            var SeletedProject = component.get("v.Seleted_Project");
            var SeletedBuilding = component.get("v.Seleted_Building");
            var SelectedUnitTheme = component.get("v.Seleted_UnitTheme");
                
            if(Selectedmasterplans !=null){
               var masterP = Selectedmasterplans.val;
            }
            if(SeletedBlook !=null){
               var SeletedBlookId = SeletedBlook.val;
                console.log('SeletedBlookId=='+SeletedBlookId);
            }
            if(SeletedProject !=null){
               var SeletedProjectId = SeletedProject.val;
                console.log('SeletedProjectId=='+SeletedProjectId);
            }
             if(SelectedUnitTheme !=null){      
               var SeletedUnitThemeId = SelectedUnitTheme.val;
                console.log('SeletedUnitThemeId=='+SeletedUnitThemeId);
            }
            //==========================================
            var action = component.get('c.getrecord');
            action.setStorable();
            
            action.setParams({
                objectName : objectName,
                fld_API_Text : field_API_text,
                fld_API_Val : field_API_val,
                lim : limit, 
                fld_API_Search : field_API_search,
                searchText : searchText,
                Selectedmasterplan : masterP,
                SelectedblockId : SeletedBlookId,
                SelectedProjectId : SeletedProjectId ,
                selectedUnitThemeID: SeletedUnitThemeId
            });
    
            action.setCallback(this,function(a){
                this.handleResponse(a,component,helper);
            });
            
            component.set("v.last_SearchText",searchText.trim());
            console.log('Server call made');
            $A.enqueueAction(action); 
        }else if(searchText && last_SearchText && searchText.trim() == last_SearchText.trim()){ 
            component.set("v.server_result",component.get("v.last_ServerResult"));
            console.log('Server call saved');
        }         
	},
    handleResponse : function (res,component,helper){
        if (res.getState() === 'SUCCESS') {
            var retObj = JSON.parse(res.getReturnValue());
            if(retObj.length <= 0){
                var noResult = JSON.parse('[{"text":"No Results Found"}]');
               
                component.set("v.server_result",noResult); 
            	component.set("v.last_ServerResult",noResult);
            }else{
                 //console.log('retObj===',retObj);
                component.set("v.server_result",retObj); 
            	component.set("v.last_ServerResult",retObj);
            }  
        }else if (res.getState() === 'ERROR'){
            var errors = res.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    alert(errors[0].message);
                }
            } 
        }
    },
    getIndexFrmParent : function(target,helper,attributeToFind){
        var SelIndex = target.getAttribute(attributeToFind);
        while(!SelIndex){
            target = target.parentNode ;
			SelIndex = helper.getIndexFrmParent(target,helper,attributeToFind);           
        }
        return SelIndex;
    },
    clearSelection: function(component, event, helper){ 
        //Added updatelookup null checks by Ashams
        var updatelookup = component.get("v.selItem");
                //console.log('masterplan null if true==',updatelookup.objName);
            if(updatelookup && updatelookup.objName == 'Master_Community__c'){
              component.set("v.Seleted_Blook",null);
              component.set("v.Seleted_Project",null);
              component.set("v.Seleted_Building",null);
            }else if(updatelookup && updatelookup.objName == 'Block__c'){
                component.set("v.Seleted_Project",null);
                component.set("v.Seleted_Building",null);
            }else if(updatelookup && updatelookup.objName == 'Project__c'){
                component.set("v.Seleted_Building",null);
            }
        component.set("v.selItem",null);
        component.set("v.server_result",null);
    } 
})