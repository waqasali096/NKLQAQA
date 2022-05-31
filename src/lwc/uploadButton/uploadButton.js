import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getDocRelatedToRec from "@salesforce/apex/LwcControllerForUpload.getDocRelatedToRec";
import uploadFile from "@salesforce/apex/LwcControllerForUpload.uploadFile";
import getRelatedFilesByRecordId from "@salesforce/apex/LwcControllerForUpload.getRelatedFilesByRecordId";
import { refreshApex } from "@salesforce/apex";
import getExpIssueDate from "@salesforce/apex/LwcControllerForUpload.getExpIssueDate";
import createObjectDocument from "@salesforce/apex/LwcControllerForUpload.createObjectDocument";
import signedDocUploadMeassage from '@salesforce/label/c.Signed_Booking_Form_Doc_Upload_Message';

export default class UploadButton extends NavigationMixin(LightningElement) {
    fileData;
    parameter;
    objectRecID;
    docRecName;
    @api recordId;
    @api hildUploadOtherDoc;
    @api disableEditReplace;
    @track Document__c;
    @track customMessage;
    @track data = [];
    filesList = [];
     //Edit By Vipul 10/05/2022 For Leasing
    @api objectApiName;
    checkInputValue = false;
    inputBoxShowHide = false;
    @track columns = [
        {
            label: "DOCUMENT TYPE",
            fieldName: "docType",
            type: "text",
            //fixedWidth: 400,
            hideDefaultActions: "true",
        },
        {
            label: "DOCUMENT NO",
            fieldName: "docName",
            type: "url",
            //fixedWidth: 150,
            hideDefaultActions: "true",
            typeAttributes: {
                label: {
                    fieldName: "Name",
                },
                target: "_blank",
            },
        },
        // {
        //     label: "ACCOUNT",
        //     fieldName: "accId",
        //     type: "url",
        //     //fixedWidth: 100,
        //     class: "slds-theme_shade slds-theme_alert-texture",
        //     hideDefaultActions: "true",
        //     typeAttributes: {
        //         label: {
        //             fieldName: "accName",
        //         },
        //         target: "_blank",
        //     },
        // },
        {
            label: "EXPIRY DATE",
            fieldName: "Expiry_Date__c",
            type: "date",
            //fixedWidth: 120,
            hideDefaultActions: "true",
        },
        {
            label: "ISSUE DATE",
            fieldName: "Issue_Date__c",
            type: "date",
            //fixedWidth: 120,
            hideDefaultActions: "true",
        },
        {
            label: "UPLOAD",
            type: "button",
            //fixedWidth: 120,
            typeAttributes: {
                label: "Upload",
                name: "Upload",
                title: "Upload",
                disabled: {
                    fieldName: "disableUploadButton",
                },
                value: "Upload",
                iconPosition: "left",
                variant: "base",
            },
        },
        {
            label: "VIEW",
            type: "button",
            //fixedWidth: 120,
            hideDefaultActions: "true",
            typeAttributes: {
                name: "View",
                disabled: {
                    fieldName: "disableViewButton",
                },
                label: "View",
                name: "View",
                title: "View",
                value: "View",
                iconPosition: "left",
                variant: "base",
            },
        },
        {
            label: "EDIT",
            type: "button",
            //fixedWidth: 120,
            hideDefaultActions: "true",
            typeAttributes: {
                name: "Edit",
                disabled: {
                    fieldName: "disableEditButton",
                },
                label: "Edit/Replace",
                name: "Edit",
                title: "Edit",
                value: "Edit",
                iconPosition: "left",
                variant: "base",
            },
        },
        {
            label: "DOC UPLOAD?",
            type: "text",
            //fixedWidth: 130,
            hideDefaultActions: "true",
            cellAttributes: {
                iconName: {
                    fieldName: "trendIcon",
                },
                iconPosition: "right",
            },
        },
    ];

    @track openModal = false;
    @track openModal1 = false;
    @track subRecordId;
    @track contentId;
    @track isIssueDateRequired = false;
    @track isExpiryDateRequired = false;
    @track errorMessage = false;
    @track resultData;
    @track dataUploaded = false;
    @track emirateType = false;
    @track emirateInvalid = false;
    @track disableAlert = false;
    @track wiredDocList = [];
    @track disableSave = false;
    @track disableUploadBut = false;
    @api isLoaded = false;
    @track isDocumentNumberRequired = false;
    @track isDocumentNumberDisabled = false;
    @track documentType = 'Other';
    @track documentNumberLabel = 'Document';
    @track issueDateCheck = false;
    @track expiryDateCheck = false;
    recordIdNew;

    @wire(getDocRelatedToRec, {
        recId: "$recordId",
    })
    WireDocumentsRecords(result) {
        this.wiredDocList = result;
        if (result.data) {
            let tempList = [];
            result.data.forEach((record) => {
                let tempRec = Object.assign({}, record);
                tempRec.docName = "/" + tempRec.Id;
                if (tempRec.Account__c != null) {
                    tempRec.accId = "/" + tempRec.Account__c;
                    tempRec.accName = tempRec.Account__r.Name;
                }

                if (tempRec.Document_Type__c == "Others") {
                    tempRec.docType = tempRec.Document_Name__c;
                } else {
                    tempRec.docType = tempRec.Document_Type__c;
                }
              
                tempRec.disableViewButton = true;
                if (tempRec.Is_Document_Uploaded__c == true) {
                    tempRec.trendIcon = "utility:check";
                    tempRec.disableUploadButton = true;
                    tempRec.disableViewButton = false;
                    tempRec.disableEditButton = false;
                } else {
                    tempRec.trendIcon = "utility:close";
                    tempRec.disableUploadButton = false;
                    tempRec.disableViewButton = true;
                    tempRec.disableEditButton = true;
                }

                // Added by Rohit to disable edit/replace
                if( this.disableEditReplace ){
                    tempRec.disableEditButton = true;
                }
                tempList.push(tempRec);
            });
            this.Document__c = tempList;
            this.error = undefined;
        } else if (result.error) {
            this.error = error;
            this.Document__c = undefined;
        }
    }

    refresh() {
        return refreshApex(this.wiredDocList);
    }

    callRowAction(Event) {
        const actionName = Event.detail.action.name;
        const row = Event.detail.row;
        switch (actionName) {
            case "View":
                console.log("inside view");
                this.callApex(row.Id);
                break;
            case "Upload":
                console.log("inside upload");
                this.subRecordId = Event.detail.row.Id;
                this.openModal = true;
                this.docRecName = Event.detail.row.Name;
                this.callApexForValidation();
                break;
            case "Edit":
                if (Event.detail.row.Document_Type__c == "Others") {
                    console.log("inside edit if");
                    this.subRecordId = Event.detail.row.Id;
                    this.openModal1 = true;
                    this.docRecName = Event.detail.row.Name;
                    this.callApexForValidation();
                    this.disableAlert = true;
                    this.dataUploaded = true;
                } else {
                    console.log("inside edit else");
                    this.subRecordId = Event.detail.row.Id;
                    this.openModal = true;
                    this.docRecName = Event.detail.row.Name;
                    this.callApexForValidation();
                    this.disableAlert = true;
                    this.dataUploaded = true;
                }
                break;
            default:
        }
    }
    closeModal() {
        this.openModal = false;
        this.fileData = null;
    }

    handleSuccess(event) {
        if (this.errorMessage == false) {
            this.openModal = false;
            if(!this.customMessage && !this.issueDateCheck && !this.expiryDateCheck && !this.emirateInvalid){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Data and File Uploaded successfully",
                        variant: "success",
                    })
                );
                this.refresh();
            }else{this.refresh();}
        }else{
            this.refresh();
        }

        
    }

    get acceptedFormats() {
        return [".pdf", ".png"];
    }

    openfileUpload(event) {
        const file = event.target.files[0];
        var reader = new FileReader();
        reader.onload = () => {
            var base64 = reader.result.split(",")[1];
            this.fileData = {
                filename: file.name,
                base64: base64,
                recordId: this.subRecordId,
            };
            console.log(this.fileData);
        };
        reader.readAsDataURL(file);
        this.dataUploaded = true;
    }

    handleClick(event) {
        console.log('expiry date check :'+this.expiryDateCheck);
        if(this.expiryDateCheck){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: 'Expiry date should be a future date',
                    variant: "Error",
                })
            );
        }else if(this.issueDateCheck){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: 'Issue Date should be past date',
                    variant: "Error",
                })
            );
        }else if(this.emirateInvalid){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: 'Please enter the emirates id in the correct format 784-1234-1234567-1',
                    variant: "Error",
                })
            );
        }else if (this.fileData) {
            if (this.openModal1 == true) {
                    this.fileData.recordId = this.recordIdNew;
            }
            
            const { base64, filename, recordId } = this.fileData;
                uploadFile({
                    base64,
                    filename,
                    recordId,
                });
                this.openModal = false;
                this.openModal1 = false;
                if(!this.customMessage){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: "Data and File Uploaded successfully",
                            variant: "success",
                        })
                    );
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Warning",
                            message: this.customMessage,
                            variant: "warning",
                        })
                    );
                }
                this.fileData = null;
            
        } else if (this.disableAlert == false) {
            this.errorMessage = true;
            alert("Please select file");
        }
    }

    callApex(parameter) {
        getRelatedFilesByRecordId({
            docID: parameter,
        })
            .then((data) => {
                this.contentId = data;
                this.error = null;
                this[NavigationMixin.Navigate]({
                    type: "standard__namedPage",
                    attributes: {
                        pageName: "filePreview",
                    },
                    state: {
                        selectedRecordId: this.contentId,
                    },
                });
            })
            .catch((error) => {
                this.contentId = null;
                this.error = error;
            });
    }

    callApexForValidation() {
        getExpIssueDate({
            objectRecID: this.recordId,
            docName: this.docRecName,
        })
            .then((data) => {
                this.recordsList = data[0];
                console.log(
                    "Single >>" + JSON.stringify(this.recordsList, null, "\t")
                );
                this.isIssueDateRequired = this.recordsList.Issue_Date_Mandatory__c;
                this.isExpiryDateRequired = this.recordsList.Expiry_Date_Mandatory__c;
        
                if(this.recordsList.Document_Type__c){
                    this.documentType = this.recordsList.Document_Type__c;
                }else if(this.recordsList.Document__r.Document_Type__c){
                    this.documentType = this.recordsList.Document__r.Document_Type__c;
                }

                if(this.recordsList.Document_Number__c != null){
                    this.isDocumentNumberDisabled = true;
                }else if(this.recordsList.Document__r.Document_Number__c != null){
                    this.isDocumentNumberDisabled = true;
                }else{
                    this.isDocumentNumberDisabled = false;
                }
                console.log('Document Number :',this.isDocumentNumberDisabled);

                if(this.documentType == 'Signed SPA'){
                    this.customMessage = signedDocUploadMeassage;
                }else{
                    this.customMessage = null;
                }
                //this.documentType = this.recordsList.Document__r.Document_Type__c;
                console.log('document type :',this.documentType);

                if(this.documentType == 'Emirates ID'){
                    this.emirateType = true;
                }else{
                    this.emirateType = false;
                    this.emirateInvalid = false;
                }

                if(this.documentType == 'Visa' || this.documentType == 'PASSPORT' || this.documentType == 'Emirates ID' || this.documentType == 'Trade License'){
                    if(!this.isDocumentNumberDisabled){
                        this.isDocumentNumberRequired = this.recordsList.Document_Number_Mandatory__c;
                    }else{
                        this.isDocumentNumberRequired = false;
                    }
                    this.documentNumberLabel = this.documentType == 'Visa' ? 'Visa Number' : this.documentType == 'PASSPORT' ? 'Passport No.' : this.documentType == 'Emirates ID' ?  'Emirates ID' : this.documentType == 'Trade License' ? 'Trade License Number' : 'Document Number';
                }else{
                    this.isDocumentNumberRequired = false;
                    this.documentNumberLabel = 'Document Number';
                }
                console.log('document label :',this.documentNumberLabel);
                this.error = null;
            })
            .catch((error) => {
                this.recordsList = null;
                this.error = error;
            });
    }

    emirateIdValidation(event){
        if(this.emirateType){
            let emirateId = event.detail.value;
            let regex = /^784-[0-9]{4}-[0-9]{7}-[0-9]{1}$/;
           
            this.emirateInvalid = !regex.test( emirateId);
           
        }
        
    }

    handleFieldValidation(event) {
        let expDate = new Date(event.detail.value);
        expDate.setMinutes(
            new Date().getMinutes() - new Date().getTimezoneOffset()
        );
        let newExpDate = expDate.toISOString().slice(0, 10);

        let rightNow = new Date();
        rightNow.setMinutes(
            new Date().getMinutes() - new Date().getTimezoneOffset()
        );
        let todaydate = rightNow.toISOString().slice(0, 10);
        console.log("new exp date" + newExpDate);
        if (todaydate > newExpDate && newExpDate != "1970-01-01") {
            this.expiryDateCheck = true;
            //alert("Expiry Date should be future date");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Expiry Date should be future date",
                    variant: "error",
                })
            );
            this.disableSave = true;
        } else {
            this.disableSave = false;
            this.expiryDateCheck = false;
        }
    }

    handleIssueDateFieldValidation(event) {
        let issueDate = new Date(event.detail.value);
        issueDate.setMinutes(
            new Date().getMinutes() - new Date().getTimezoneOffset()
        );
        let newIssueDate = issueDate.toISOString().slice(0, 10);

        let rightNow = new Date();
        rightNow.setMinutes(
            new Date().getMinutes() - new Date().getTimezoneOffset()
        );
        let todaydate = rightNow.toISOString().slice(0, 10);
        console.log("new Issue date" + newIssueDate);
        if (newIssueDate > todaydate) {
            //alert("Issue Date should be past or today's date");
            this.issueDateCheck = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "Issue Date should be past date",
                    variant: "error",
                })
            );
            this.disableSave = true;
        } else {
            this.disableSave = false;
            this.issueDateCheck = false;
        }
    }


    openModalForOtherDoc() {
        this.disableAlert = false;
        this.subRecordId = null;
        this.fileData = null;
        this.openModal1 = true;
    }
    closeModal1() {
        this.openModal1 = false;
        this.fileData = null;
    }

    //onsuccess
    uploadFileOnDoc(event) {
        this.recordIdNew = event.detail.id;
        this.handleClick();
        createObjectDocument({
            documentId: this.recordIdNew,
            recordIdObj: this.recordId,
            checkRelatedUnitUpload: this.checkInputValue
        }).then((data) => {
            this.refresh();
            this.isLoaded = !this.isLoaded;
        });

        if (this.errorMessage == false) {
            this.openModal1 = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Success",
                    message: "Data and File Uploaded successfully",
                    variant: "success",
                })
            );
        }
    }

    //onsubmit
    createDocRecord(event) {
        event.preventDefault();
        console.log("this.fileData =======" + this.fileData);


        if (this.fileData == undefined && this.disableAlert == false) {
            this.errorMessage = true;
            alert("Please select file");
        } else {
            this.isLoaded = !this.isLoaded;
            this.template.querySelector("lightning-record-edit-form").submit();
        }
    }
    relatedUnitsAsWell(event) {
         //Edit By Vipul 10/05/2022 For Leasing
        this.checkInputValue = event.target.checked
        console.log('checkValue-->', this.checkInputValue);
    }
    connectedCallback() {
        //Edit By Vipul 10/05/2022 For Leasing
        if (this.objectApiName == 'Project__c' || this.objectApiName == 'Floor__c' || this.objectApiName == 'Building__c') {
            this.inputBoxShowHide = true;
        }

        console.log('this....', this.objectApiName);

    }
}