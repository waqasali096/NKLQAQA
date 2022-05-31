import { LightningElement,wire,api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import calloutPrepration from '@salesforce/apex/CCAvenueCallout.calloutPrepration';
import createReceipt from '@salesforce/apex/GeneratePaymentLinkCtlr.createReceipt'; 
//import controlComponentVisibility from '@salesforce/apex/CCAvenueCallout.controlComponentVisibility'; 
  
export default class Generate_Payment_Link extends LightningElement {

    @api recordId;
    @api custominvocation = false;
    @track TokenAmount; 
    @track receiptId;
    @track disableSendOnlinePaymentLink = true;  
    @api isSpinner = false;

    onchangeHandler(event) {
        this.TokenAmount = event.target.value;
        this.disableSendOnlinePaymentLink = this.TokenAmount == "" || this.TokenAmount == 0 ?  true : false ;
    }

	createReceiptMtd() {
        this.isSpinner = true;
		createReceipt({
			DLSId: this.recordId,
            Amount: this.TokenAmount,
		}) 
		.then((result) => {
			this.receiptId = result;
            this.completePayment();
		})
		.catch((error) => {
			this.error = error;
            this.isSpinner = false;
		});
	}
    
    completePayment(){
        console.log(this.receiptId);
        calloutPrepration({id:this.receiptId}).then(result =>{
            console.log(result);
            this.isSpinner = false;
                const event = new ShowToastEvent({
                    title: 'Success!',
                    message: 'Online payment link sent to customer successfully!',
                    variant: 'Success'
                });
                this.dispatchEvent(event);
            this.handleCancel();
        }).catch(error=>{
            this.isSpinner = false;
        })
    }

    handleCancel() {
        if(!this.custominvocation){
            this.dispatchEvent(new CloseActionScreenEvent());
        }
        if(this.custominvocation){
            const closePopUpEvent = new CustomEvent("closePopUp",{});
            this.dispatchEvent(closePopUpEvent);
        }
    }

}