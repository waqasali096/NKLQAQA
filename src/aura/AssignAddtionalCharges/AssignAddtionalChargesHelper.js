({
	fetchRecords : function(component,event,helper) {
        debugger;
		var action = component.get("c.findUnitByName");
        action.setParams({recordId : component.get("v.recordId")});
        action.setCallback(this,function(response) {
            var records = response.getReturnValue();
            records.forEach(function(record){
               // alert(record.Amount__c);
                //alert(record.Id);
                record.linkName = '/'+record.Id;
            });
            var projName = [];
            for(var i =0 ; i < records.length;i++){
                var proj = response.getReturnValue()[i];
                if(proj.Project__c != null){
                    proj.ProjectName = proj.Project__r.Name;
                }
                projName.push(proj);
            }
            component.set("v.adddatalist",projName);
        });
         $A.enqueueAction(action); 
	}
})