({
    doInit : function(component, event, helper) {
        var source = component.get('v.source');
        if(source == 'salesOffer'){
            var action = component.get('c.generateDocument');
            $A.enqueueAction(action);
        }
    },
    
	generateDocument : function(component, event, helper) {
        var documentPackageId = component.get('v.documentPackageId');
        var deliveryOptionId = component.get('v.deliveryOptionId');
        var recordIds = component.get('v.recordIds');
        var sObjectType = component.get('v.sObjectType');
        var source = component.get('v.source');
        
        var body = component.find('body');
        if(source == 'bookingForm'){
            var url = window.location.protocol + '//' + window.location.host + '/apex/GenerateBookingForm';
        }else{
            var url = window.location.protocol + '//' + window.location.host + '/apex/GenerateSalesOffer';
        }
        url = url + '?ddpId=' + documentPackageId;
        url = url + '&deliveryOptionId=' + deliveryOptionId;
        url = url + '&ids=' + recordIds;
        url = url + '&sObjectType=' + sObjectType;

        console.log('url'+url);
        if (!component.get('v.iframeUrl')) {
            component.set('v.iframeUrl', url);
        }
        else {
            // Set blank and then set in order to reset iframe
            component.set('v.iframeUrl', '');
            setTimeout($A.getCallback(function() {
                component.set('v.iframeUrl', url);
            }), 2000);will
        }
	},
    
    closeModal : function(component, event, helper){
        var qbEvent = $A.get("e.c:QuickBookEvent");
        qbEvent.setParams({
            "closePopUp" : false 
        });
        qbEvent.fire();
    }
})