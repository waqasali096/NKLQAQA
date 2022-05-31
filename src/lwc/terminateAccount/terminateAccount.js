/**************************************************************************************************
* Name               : terminateAccount.js                                              
* Description        : JS controller for terminateAccount component.                           
* Created Date       : 17/10/2021
* Created By         : Cloudworks                                                    
* ------------------------------------------------------------------------------------------------
* VERSION    AUTHOR      DATE            COMMENTS                                                 
* 1.0        Rohit       14/10/2021      Initial Draft.                                           
**************************************************************************************************/
import { LightningElement, wire, api, track } from 'lwc';

// Imports
import {deleteRecord} from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue  } from 'lightning/uiRecordApi';
import AGENCY_STATUS from '@salesforce/schema/Account.Agency_Status__c';
import saveFile from "@salesforce/apex/TerminateAccountController.saveFile";
import createDocument from "@salesforce/apex/TerminateAccountController.createDocument";
import deleteDocument from "@salesforce/apex/TerminateAccountController.deleteDocument";
import TERMINATE_ACCOUNT from '@salesforce/schema/Account.Terminate_Account__c';
import TERMINATION_REASON from '@salesforce/schema/Account.Termination_Reason__c';
import TERMINATION_NOTICE from '@salesforce/schema/Account.Termination_Notice_Verified_and_Uploaded__c';

const FIELDS = [ TERMINATION_NOTICE, TERMINATION_REASON, TERMINATE_ACCOUNT, AGENCY_STATUS ];

export default class TerminateAccount extends LightningElement {
    @api recordId;
    
    @track accountObj;
    @track terminationNotice;
    @track terminationReason;
    @track errorMessage;
    @track documentId;
    @track MAX_FILE_SIZE = 2000000;
    @track showFileName = false;
    @track isLoading = true;
    
    uploadedFiles = []; file; fileContents; fileReader; content; fileName;
    conDocId;

    checkDocumentAvailability(){
        createDocument({ accId: this.recordId })
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

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
        accDetail( result ){
            console.log( 'recordId >>> '+this.recordId );
            this.accountObj = result;
            this.terminationNotice = getFieldValue(this.accountObj.data, TERMINATION_NOTICE);
            this.terminationReason = getFieldValue(this.accountObj.data, TERMINATION_REASON);
            
            if( this.recordId ){
                this.checkDocumentAvailability(); 
            }

            this.isLoading = false;
            console.log( 'accountObj >>> '+JSON.stringify(this.accountObj) );
        }
    
    get agencyStatusTerminated(){
        let status = getFieldValue(this.accountObj.data, AGENCY_STATUS);
        return status == 'Terminated' ? true : false;
    }

    get terminateAccount(){
        return getFieldValue(this.accountObj.data, TERMINATE_ACCOUNT);
    }
    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg'];
    }

    noticeChange(event) {
        if (event.target.checked) {
            this.terminationNotice = true;
            this.errorMessage = undefined;
        } else {
            this.terminationNotice = false;
            this.errorMessage = 'Please select Termination Notice Verified and Uploaded.';
        }
    }

    reasonChange(event) {
        this.terminationReason = event.target.value;
        if(this.terminationReason == '' || this.terminationReason == undefined){
            this.errorMessage = 'Please provide Termination Reason.';
        }else{
            this.errorMessage = undefined;
        }
    }

    handleCancel( event ) {
        let status = getFieldValue(this.accountObj.data, AGENCY_STATUS);
        let terminationInProgress = getFieldValue(this.accountObj.data, TERMINATE_ACCOUNT)
        if( status != 'Terminated' && !terminationInProgress ){
            this.deleteDocumentRecord();
        }else{
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    deleteDocumentRecord(){
        this.isLoading = true;
        deleteDocument({ docId: this.documentId })
            .then(result => {  
                console.log( ' deleteDocumentRecord=> result => ',result );
                if(result.success){
                    this.dispatchEvent(new CloseActionScreenEvent());
                }else{
                    console.log( 'deleteDocumentRecord => error message =>'+result.message );
                    this.errorMessage = result.message;
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                this.errorMessage = error;
                console.log( 'deleteDocumentRecord => error =>'+JSON.stringify(error) );
            });
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
        this.errorMessage = 'Please upload required document.';
    }

    handleSave(){
        let status = getFieldValue(this.accountObj.data, AGENCY_STATUS);
        if(!this.terminationNotice){
            this.errorMessage = 'Please select Termination Notice Verified and Uploaded.';
        }
        else if(this.terminationReason == '' || this.terminationReason == undefined){
            this.errorMessage = 'Please provide Termination Reason.';
        }
        else if(!this.showFileName){
            this.errorMessage = 'Please upload required document.';
        }else if( status != 'Registered- Active' ){
            this.errorMessage = 'You can\'t terminate the account as it is not Registered- Active';
        }else{
            this.errorMessage = undefined;
            this.isLoading = true;
            saveFile({
                accId: this.recordId,
                noticeCheck: this.terminationNotice,
                reason: this.terminationReason,
                documentId: this.documentId,
                conDocId: this.conDocId,
            })
            .then(result => {  
                console.log( 'handleSave => result => ',result );
                if(result.success){
                    this.isLoading = false;
                    this.showToast( 'Success!', 'Account Termination Request submitted for Approval', 'success' );
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

    showToast( toastTitle, toastMessage, toastVariant ) {
        const event = new ShowToastEvent({
            title   : toastTitle,
            message : toastMessage,
            variant : toastVariant,
        });
        this.dispatchEvent(event);
    }
}