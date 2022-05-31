({
    doInit: function(component, event, helper){
        var recordId = component.get("v.recordId");
        helper.fetchObjectDetails(component, event, recordId); 
    }
})