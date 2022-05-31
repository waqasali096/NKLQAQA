({
    
    sectionOne : function(component, event, helper) {
        var acc = component.find('articleOne');
        acc.forEach(function(element) {
            $A.util.toggleClass(element, "slds-hide");
        });
        $A.util.addClass(event.target, "slds-show");    }
    
})