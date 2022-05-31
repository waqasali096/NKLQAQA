/**************************************************************************************************
* Name               : rejectDeal.js                                              
* Description        : JS controller for rejectDeal component.                           
* Created Date       : 05/05/2022
* Created By         : Cloudworks                                                    
* ------------------------------------------------------------------------------------------------
* VERSION    AUTHOR      DATE            COMMENTS                                                 
* 1.0        Rohit       05/05/2022      Initial Draft.                                           
**************************************************************************************************/
import { LightningElement,api,track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import checkForSignedDocument from "@salesforce/apex/RejectDealController.checkForSignedDocument";
export default class RejectDeal extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track errorMessage;
    @track value = 'true';
    @track remarks;

    get TypeOptions() {
        return [
          { label: "Yes", value: "true" },
          { label: "No", value: "false" },
        ];
    }
    handleTypeChange(event) {
        this.value = event.detail.value;
        this.errorMessage = undefined;
    }
    handleRemarks(event) {
        this.remarks = event.detail.value;
        this.errorMessage = undefined;
    }
    handleSave(){
        if(this.remarks == undefined || this.remarks == ''){
            this.errorMessage = 'Please provide reject reason.';
        }else{
            this.isLoading = true;
            checkForSignedDocument({ 
                oppId: this.recordId,
                userSelection: this.value,
                remarks: this.remarks
            })
            .then(result => {  
                if(result.success){
                    if(result.message == 'Close Reject Deal Screen'){
                        this.handleCancel();
                    }else{
                        this.errorMessage = result.message;
                    }
                }else{
                    console.log( 'RejectDealComponent => error message =>'+result.message );
                    this.errorMessage = result.message;
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                this.errorMessage = error;
                console.log( 'RejectDealComponent => error =>'+JSON.stringify(error) );
            });
        }
        
    }
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}