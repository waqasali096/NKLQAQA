/**************************************************************************************************
* Name               : RaiseException.js                                              
* Description        : JS controller for RaiseException component.                           
* Created Date       : 24/03/2022
* Created By         : Cloudworks                                                    
* ------------------------------------------------------------------------------------------------
* VERSION    AUTHOR      DATE            COMMENTS                                                 
* 1.0        Rohit       24/03/2022      Initial Draft.                                           
**************************************************************************************************/
import { LightningElement,api,wire,track } from 'lwc';
import {deleteRecord} from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveFile from "@salesforce/apex/RaiseExceptionController.saveFile";
import createDocument from "@salesforce/apex/RaiseExceptionController.createDocument";
import getOppData from "@salesforce/apex/RaiseExceptionController.getOppData";

export default class RaiseException extends LightningElement {
    @api recordId;
    @track exceptionOption;
    @track d2dException = [];
    @track documentId;
    @track errorMessage;
    @track isLoading = false;
    @track MAX_FILE_SIZE = 2000000;
    @track showFileName = false;
    @track isLoading = true;
    uploadedFiles = []; file; fileContents; fileReader; content; fileName;
    conDocId;
    @track excpetionList;
    @track dldCheck;
    @track disablebtn = true;
    @track exceptionSelectedList = [];
    @track index;
    @track longapproval = false;
    @track restrictSave = false;

    @wire(getOppData, { oppId: '$recordId'})
        oppDetail( result ){
            if (result.data) {
                console.log('result==>',result.data);
                this.checkDocumentAvailability(); 
                this.excpetionList = result.data;
            }else if (result.error) {
                this.error = result.error;
                console.log("---error----", this.error);
            }
            this.isLoading = false;
            if(this.excpetionList){
                let allExpList = JSON.parse(JSON.stringify(this.excpetionList));
                for(let i=0;i<allExpList.length;i++){
                    if(!allExpList[i].exceptionApproved){
                        this.disablebtn = false;
                    }
                }
            }
    }

    handleCheckBoxChange(event){
        let checkbutton = event.target.name;
        if(checkbutton && checkbutton=='DLD Share Exception' && event.target.checked){
            this.dldCheck = true;
        }else if(checkbutton && checkbutton=='DLD Share Exception' && !event.target.checked){
           this.dldCheck = false; 
        }
        let allExpList = JSON.parse(JSON.stringify(this.excpetionList));
        for(let i=0;i<allExpList.length;i++){
            if(allExpList[i].exceptionName == event.target.name){
                allExpList[i].selected = event.target.checked;
            }
        }
        this.excpetionList = allExpList;
        //console.log('excpetionList'+JSON.stringify(this.excpetionList));
    }

    handleDLDExcepChange(event){
        let dldException = event.target.value;
        let allExpList = JSON.parse(JSON.stringify(this.excpetionList));

        if(!dldException || dldException==0){
            this.showToast( 'Error!', 'Percentage cannot be Zero', 'error' );
            this.disablebtn = true;
        }else if(dldException){
            for(let i=0;i<allExpList.length;i++){
                if(!allExpList[i].DLDApplied){
                    if(allExpList[i].exceptionName == 'DLD Share Exception' && allExpList[i].oppDLDPercentage && dldException >= allExpList[i].oppDLDPercentage){
                        this.showToast( 'Error!', 'Exception cannot be greater than or equal to Unit DLD Share', 'error' );
                        this.disablebtn = true;
                    }else if(allExpList[i].exceptionName == 'DLD Share Exception' && allExpList[i].oppDLDPercentage && dldException < allExpList[i].oppDLDPercentage){
                        this.disablebtn = false;
                        allExpList[i].longApproval = true;
                        this.longapproval = true;
                        allExpList[i].exceptionDLDPercentage = dldException;
                    }
                }else if(allExpList[i].DLDApplied){
                    if(allExpList[i].exceptionName == 'DLD Share Exception' && allExpList[i].oppDLDPercentage && dldException >= allExpList[i].oppDLDPercentage){
                        this.showToast( 'Error!', 'Exception cannot be greater than or equal to Special offer DLD Share', 'error' );
                        this.disablebtn = true;
                    }
                    else if(allExpList[i].exceptionName == 'DLD Share Exception' && allExpList[i].oppDLDPercentage && dldException >= allExpList[i].unitDLDPercentage && dldException < allExpList[i].oppDLDPercentage){
                        allExpList[i].exceptionDLDPercentage = dldException;
                        this.disablebtn = false;
                    }
                    else if(allExpList[i].exceptionName == 'DLD Share Exception' && allExpList[i].oppDLDPercentage && dldException < allExpList[i].unitDLDPercentage){
                        allExpList[i].exceptionDLDPercentage = dldException;
                        allExpList[i].longApproval = true;
                        this.longapproval = true;
                        this.disablebtn = false;
                    }
                }
            }
            this.excpetionList = allExpList;
        }
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
    handleChange(event) {
        this.d2dException = event.detail.value;
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
        this.errorMessage = undefined;
        this.isLoading = true;
        
        for(let i=0;i<this.excpetionList.length;i++){
            if(this.excpetionList[i].selected){
                this.exceptionSelectedList.push(this.excpetionList[i]);
            }
        }
        console.log('exceptionSelectedLists 1'+JSON.stringify(this.exceptionSelectedList));

        if(this.exceptionSelectedList.length > 0){
            for(let i=0;i<this.exceptionSelectedList.length;i++){
                if(this.exceptionSelectedList[i].exceptionName == 'DLD Share Exception' && !this.exceptionSelectedList[i].exceptionDLDPercentage && this.exceptionSelectedList[i].selected){
                    this.showToast( 'Error!', 'Exception% cannot be blank', 'error');
                    this.restrictSave = true;
                    this.isLoading = false;
                    this.exceptionSelectedList = [];
                }
            }
        } else if(this.exceptionSelectedList.length == 0 ){
           this.showToast( 'Error!', 'Please select any option', 'error'); 
           this.restrictSave = true;
           this.isLoading = false;
        }
        
        console.log('exceptionSelectedLists 2'+JSON.stringify(this.exceptionSelectedList));

        if(this.restrictSave == false){
            saveFile({
            oppId: this.recordId,
            expWrapper : this.exceptionSelectedList,
            //selectedOption: this.d2dException,
            documentId: this.documentId,
            longapproval: this.longapproval
            })
            .then(result => {  
                console.log( 'handleSave => result => ',result );
                if(result.success){
                    this.isLoading = false;
                    this.showToast( 'Success!', 'Exception changes are saved.', 'success' );
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