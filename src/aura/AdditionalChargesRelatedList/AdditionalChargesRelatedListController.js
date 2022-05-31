({
	doInit : function(component, event, helper) {
        console.log('record id :'+component.get("v.recordId"));
		helper.fetchAdditionalCharges(component,event);
	}
})