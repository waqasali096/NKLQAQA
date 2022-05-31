({
    //fetching Deal Deatils
    fetchDealDetails: function (component, event) {
        var action = component.get("c.getBookingDetails");
        var dealId = component.get("v.recordId");
        action.setParams({
            OppId: dealId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var dealList = response.getReturnValue();
                component.set("v.deal", dealList);
                component.set("v.defaultCustomerName",component.get("v.deal").customerName);
                component.set("v.receiptObj.Received_From__c",component.get("v.deal").accountId);
                component.set("v.receiptObj.Account__c ",component.get("v.deal").accountId);		
            } else {
				// Show an alert if the state is incomplete or error
				//alert('Error in getting data');
			}
		});
		$A.enqueueAction(action);
	},

	fetchPPs: function (component, event) {
		console.log('calling method');
		var actionPP = component.get("c.getPaymentPlans");
		var dealId = component.get("v.recordId");
		console.log(actionPP);
		console.log(dealId);
		actionPP.setParams({
			OppId: dealId
		});		
		actionPP.setCallback(this, function (response) {			
			// Getting the response state
			var state = response.getState();
			console.log(state);
			// Check if response state is success
			if (state === 'SUCCESS') {
				// Getting the list of payment plans from response and storing in js variable
				var ppList = response.getReturnValue();
				// Set the list attribute in component with the value returned by function
				component.set("v.paymentplans", ppList);

				console.log("Records: " + ppList);
			} else {
				// Show an alert if the state is incomplete or error
				//alert('Error in getting data');
			}
		});
		$A.enqueueAction(actionPP);
	},

	fetchReceipts: function (component, event) {
		var actionRec = component.get("c.getReceipts");
		var dealId = component.get("v.recordId");

		actionRec.setParams({
			OppId: dealId
		});

		actionRec.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var rclst = response.getReturnValue();

				component.set("v.receipts", rclst);

				console.log(rclst);
			} else {
				//alert("Something went wrong");
			}
		});
		$A.enqueueAction(actionRec);
	},

	fetchmodePicklist: function (component, event) {
		var actionPick = component.get("c.getPicklistvalues");
		actionPick.setParams({
			'objectName': component.get("v.ObjectName"),
			'field_apiname': component.get("v.Payment_Mode__c"),
			'nullRequired': true // includes --None--
		});
		actionPick.setCallback(this, function (a) {
			var state = a.getState();
			if (state === "SUCCESS") {
				var modeValues = [];
				var result = a.getReturnValue();
				//component.set("v.ModePicklist", a.getReturnValue());
				for ( var key in result ) {
                	modeValues.push({value:result[key], key:key});
                }
                component.set("v.ModePicklist", modeValues);
			}
		});
		$A.enqueueAction(actionPick);
	},

	fetchReceivedForPicklist: function (component, event) {
		var actionPick = component.get("c.getReceivedForValues");
		actionPick.setParams({
			'objectName': 'Receipt__c',
			'field_apiname': 'Received_For__c',
			'nullRequired': true // includes --None--
		});
		actionPick.setCallback(this, function (a) {
			var state = a.getState();
			if (state === "SUCCESS") {
				var modeValues = [];
				var result = a.getReturnValue();
				//component.set("v.ModePicklist", a.getReturnValue());
				for ( var key in result ) {
                	modeValues.push({value:result[key], key:key});
                }
                component.set("v.ReceivedForPicklist", modeValues);
			}
		});
		$A.enqueueAction(actionPick);
	},

	fetchInstallmentTypeValues: function (component, event) {
		var actionPick = component.get("c.getInstallmentTypeValues");
		actionPick.setParams({
			'objectName': 'Receipt__c',
			'field_apiname': 'Installment_Type__c',
			'nullRequired': true // includes --None--
		});
		actionPick.setCallback(this, function (a) {
			var state = a.getState();
			if (state === "SUCCESS") {
				var modeValues = [];
				var result = a.getReturnValue();
				//component.set("v.ModePicklist", a.getReturnValue());
				for ( var key in result ) {
                	modeValues.push({value:result[key], key:key});
                }
                component.set("v.installmentTypeValues", modeValues);
			}
		});
		$A.enqueueAction(actionPick);
	},
    
    fetchReceiptMethods: function (component, event) {
        var dealId = component.get("v.recordId");
        var actionPick = component.get("c.getReceiptMethods");
        actionPick.setParams({
            'oppId': dealId,
        });
        actionPick.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var modeValues = [];
                var result = a.getReturnValue();
                /*for ( var key in result ) {
                	modeValues.push({value:result[key], key:key});
                }
                component.set("v.receiptMethodPicklist", modeValues);*/
                component.set("v.receiptMethods", result);
                this.setReceiptMethodsOption(component,'');
            }
        });
        $A.enqueueAction(actionPick);
    },
    
    getBankPicklist: function (component, event) {
		var actionPick = component.get("c.getPicklistvalues");
		actionPick.setParams({
			'objectName': component.get("v.ObjectName"),
			'field_apiname': 'Bank__c',
			'nullRequired': true // includes --None--
		});
		actionPick.setCallback(this, function (a) {
			var state = a.getState();
			if (state === "SUCCESS") {
				var modeValues = [];
				var result = a.getReturnValue();
				for ( var key in result ) {
                	modeValues.push({value:result[key], key:key});
                }
                component.set("v.bankPicklist", modeValues);
			}
		});
		$A.enqueueAction(actionPick);
	},
	
	calculations: function (component, event) {
		var actionCal = component.get("c.calculation");
		var dealId = component.get("v.recordId");
		actionCal.setParams({
			OppId: dealId
		})


		actionCal.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var calc = response.getReturnValue();
				component.set("v.cal", calc);
			} else {
				//alert("Something went wrong");
			}

		});
		$A.enqueueAction(actionCal);
	},
    
    resetFieldsOnSaveReceipt: function (component, event) {
		component.set("v.receiptObj.Name",'');
        component.set("v.receiptObj.Amount__c",null);
        component.set("v.receiptObj.Amount_in_Words__c",'');
        component.set("v.receiptObj.Receipt_Date__c",null);
        component.set("v.receiptObj.Maturity_Date__c",null);
        component.set("v.receiptObj.Receipt_Comments__c",'');
        component.set("v.receiptObj.Bank_Branch__c",'');
        component.set("v.receiptObj.Bank__c",'');
        component.set("v.selectedmode",'');
        component.set("v.selectedReceivedFor",'');
        //component.set("v.selectedinstallmentType",'');
        component.set("v.seletedReceiptMethodId",'');
        component.set("v.selectedBank",'');
        component.set("v.accountRecord",null);
        component.set("v.defaultCustomer",true);
        component.set('v.showBankName', false);
        component.set('v.showBankBranch',false);
        component.set('v.bankFieldsRequired',false);
        component.set('v.showMaturityDate',false);
	},
    
    setReceiptMethodsOption: function (component,paymentMode) {
        var modeValues = [];
        if(paymentMode != null && paymentMode != "") {
            var recMethods = component.get("v.receiptMethods");
            for(var i=0;i<recMethods.length;i++) {
                if(paymentMode == recMethods[i].Payment_Mode__c) {
                    modeValues.push({value:recMethods[i].Id, key:recMethods[i].Name});
                }
            }
        }
        component.set("v.receiptMethodPicklist", modeValues);
    }
})