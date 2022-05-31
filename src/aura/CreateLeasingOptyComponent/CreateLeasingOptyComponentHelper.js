({
	 showSpinner: function(component){
        var spinner = component.find('quote_spinner');
        $A.util.removeClass(spinner, 'slds-hide');
         
    },
    hideSpinner: function(component){
        var spinner = component.find('quote_spinner');
        $A.util.addClass(spinner, 'slds-hide');
    },
    
})