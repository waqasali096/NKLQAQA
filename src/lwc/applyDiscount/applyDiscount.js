/**************************************************************************************************
* Name               : applyDiscount.js                                              
* Description        : JS controller for applyDiscount component.                           
* Created Date       : 22/03/2022
* Created By         : Cloudworks                                                    
* ------------------------------------------------------------------------------------------------
* VERSION    AUTHOR      DATE            COMMENTS                                                 
* 1.0        Rohit       22/03/2022      Initial Draft.                                           
**************************************************************************************************/
import { LightningElement,api,wire,track } from 'lwc';
import {deleteRecord} from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveFile from "@salesforce/apex/applyDiscountController.saveFile";
import createDocument from "@salesforce/apex/applyDiscountController.createDocument";
import getOppData from "@salesforce/apex/applyDiscountController.getOppData";

export default class ApplyDiscount extends LightningElement {
    @api recordId;
    @track discountOption;
    @track discountType;
    @track discountApprovalStatus;
    @track discount;
    @track documentId;
    @track errorMessage;
    @track isLoading = false;
    @track MAX_FILE_SIZE = 2000000;
    @track showFileName = false;
    @track isLoading = true;
    uploadedFiles = []; file; fileContents; fileReader; content; fileName;
    conDocId;
    @wire(getOppData, { oppId: '$recordId'})
        oppDetail( result ){
            if (result.data) {
                console.log('result==>',result.data);
                this.checkDocumentAvailability(); 
                this.discountType = result.data.discountType;
                this.discount = result.data.discount;
                this.discountApprovalStatus = result.data.discountApprovalStatus;
                let tempPicVal = [];
                for (let i = 0; i < result.data.discountOption.length; i++) {
                    const option = {
                        label: result.data.discountOption[i],
                        value: result.data.discountOption[i]
                    };
                    tempPicVal = [...tempPicVal, option];
                }
                this.discountOption = tempPicVal;
                this.isLoading = false;
            }else if (result.error) {
                this.error = result.error;
                console.log("---error----", this.error);
            }
            this.isLoading = false;
        }

    checkDocumentAvailability(){
        createDocument({ oppId: this.recordId })
            .then(result => {  
                console.log( ' checkDocumentAvailability=> result => ',result );
                if(result.success){
                    this.documentId = result.data.Id;
                }else{
                    console.log( 'checkDocumentAvailability => error message =>'+result.message );
                    this.errorMessage = result.message;
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.errorMessage = error;
                console.log( 'checkDocumentAvailability => error =>'+JSON.stringify(error) );
            });
    }
    handleTypeChange(event) {
        this.discountType = event.detail.value;
    }
    handleDiscountChange(event) {
        this.discount = event.detail.value;
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg'];
    }
    onFileUpload(event) {
        const uploadedFiles = event.detail.files;
        console.log("No. of files uploaded : " +JSON.stringify(event.detail) );
        if (event.detail.files.length > 0) {
            this.uploadedFiles = event.detail.files;
            this.fileName = event.detail.files[0].name;
            this.showFileName = true;
            this.conDocId = this.uploadedFiles[0].documentId;
            this.errorMessage = undefined;           
        }
    }
    handleRemoveDoc(){
        deleteRecord( this.conDocId )
        .then(() => {     
            this.conDocId = undefined;
            this.fileName = undefined;
            this.showFileName = false;
        })
        this.showFileName = false;
    }
    showToast( toastTitle, toastMessage, toastVariant ) {
        const event = new ShowToastEvent({
            title   : toastTitle,
            message : toastMessage,
            variant : toastVariant,
        });
        this.dispatchEvent(event);
    }
    handleCancel( event ) {
        if(this.conDocId){
            this.handleRemoveDoc();
        }
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleSave(){
        console.log(this.discountType);
        console.log(this.discount);
        console.log(this.discountApprovalStatus);
        if(this.discountApprovalStatus == 'Approved'){
            this.errorMessage = 'Cannot apply for discount as discount is already Approved';
        }
        else if(!this.discountType){
            this.errorMessage = 'Please select Dicount Type';
        }
        else if(!this.discount){
            this.errorMessage = 'Please provide Discount Percentage / Amount';
        }else{
            this.errorMessage = undefined;
            this.isLoading = true;
            saveFile({
                oppId: this.recordId,
                discountType: this.discountType,
                discount: this.discount,
                documentId: this.documentId,
            })
            .then(result => {  
                console.log( 'handleSave => result => ',result );
                if(result.success){
                    this.isLoading = false;
                    this.showToast( 'Success!', 'Request for Discount is submitted for Approval', 'success' );
                    this.dispatchEvent(new CloseActionScreenEvent()); 
                }else{
                    this.isLoading = false;
                    console.log( 'handleSave => error message =>'+result.message );
                    this.errorMessage = result.message;
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.errorMessage = error;
                console.log( 'handleSave => error =>'+JSON.stringify(error) );
            }); 
        }
    }
}