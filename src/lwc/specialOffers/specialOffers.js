import { LightningElement,api,track,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import CREATECAMPAIGNMETHOD from '@salesforce/apex/SpecialOffer.createCampaign';
//import SEARCHDOCUMENT from '@salesforce/apex/SpecialOffer.searchDocument';
import SEARCHMPP from '@salesforce/apex/SpecialOffer.searchMasterPaymentPlan';

const FIELDS = [
    'Project__c.Name',
    'Project__c.Start_Date__c',
    'Project__c.End_Date__c',
];

export default class SpecialOffers extends LightningElement {
    @api recordId;
    uploadDisbale = false;
    uploadDisbaleDoc = false;
    labelForFileUpload ='Document';
    labelForDocUpload = 'Approval Emails';
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    project(result){
        if(result.data){
            this.projectName = getFieldValue(result.data, FIELDS[0]);
            //this.startDate = getFieldValue(result.data, FIELDS[1]);
            //this.endDate = getFieldValue(result.data, FIELDS[2]); 
        }
        else if(result.error)
        {
           console.log('ERRRORORORORR '+ result.error);
        }
    };

    get acceptedFormats() {
        return ['.pdf', '.png','.jpeg','.gif'];
    }
    get acceptedFormatsDoc(){
        return ['.pdf'];
    }
    handleUploadFinished(){
        this.uploadDisbale = true;
        this.labelForFileUpload = 'File Uploaded Successfully';
    }
    handleUploadFinishedDoc(){
        this.uploadDisbaleDoc = true;
        this.labelForDocUpload = 'Documnet Uploaded Successfully';
    }
    /*
    connectedCallback(){
        window.alert(this.recordId)
        PORJECTDETAILS({projectId: this.recordId})
        .then(result=>{
            console.log('s date '+result.Start_Date__c);
            this.startDate = result.Start_Date__c;
            this.endDate = result.End_Date__c;
            this.projectName = result.name;
        })
        .catch(error=>{
            console.log(error);
        });
    }
    */  
    
    
    spinner = false;
    dld;
    agentComissions;
    staffCommissions;
    startDate;
    endDate; 
    projectName;
    handleDld(event){
        this.dld = event.target.value;
    }
    handleAgentComm(event){
        this.agentComissions = event.target.value;
    }
    handleStaffComm(event){
        this.staffCommissions = event.target.value;
    }
    handleStartDate(event){
        this.startDate = event.target.value;
    }
    handleEndDate(event){
        this.endDate = event.target.value;
    }
    createCampaignAction(){

        let myCampaign = { 'sobjectType': 'Campaign' };
        myCampaign.Name = this.projectName + ' Special Offer';
        myCampaign.Start_Date__c = this.startDate;
        myCampaign.End_Date__c = this.endDate;
        myCampaign.DLD__c = this.dld;
        myCampaign.Agent_Commissions__c = this.agentComissions;
        myCampaign.Staff_Commissions__c = this.staffCommissions;
        myCampaign.Project__c = this.recordId;
        //myCampaign.Document__c = this.selectedDocumentID;
        myCampaign.Master_Payment_Plan__c = this.selectedMasterPaymentPlanId;
        

        this.resultExistingMPP = undefined;
        this.resultExistingDocuments = undefined;
        CREATECAMPAIGNMETHOD({campObj: myCampaign})
            .then(result => {
                if(result){
                    this.spinner = true;
                    const event = new ShowToastEvent({
                        title: 'Campaign Created',
                        variant: 'Success'
                    });
                    this.dispatchEvent(event);
                       
                    this.dispatchEvent(new CloseActionScreenEvent());
                    setTimeout(function() {
                        location.reload();
                        },1001 );
                }
            })
            .catch(error => {
                console.log(error);
            });

    }
    
    
    //@track selectedDocumentID;
    //@track resultExistingDocuments;
    //@track selectedDocument;

    /*handleDocSearch(event){
        if(this.selectedDocument ==undefined)
        {
            this.docTerm = event.target.value;
        
            SEARCHDOCUMENT({searchTerm:this.docTerm})
                .then(result =>{
                
                this.resultExistingDocuments = result;
            })
        }
        
        
    }

    handleDocumentSelect(event){
        this.selectedDocument = event.target.dataset.name;
        this.selectedDocumentID = event.target.dataset.id;
        this.resultExistingDocuments = undefined;
    }
    */

    @track mppterm;
    @track selectedMasterPaymentPlan;
    @track selectedMasterPaymentPlanId;
    @track resultExistingMPP;
    handleMasterPaymentSearch(event){
        if(this.selectedMasterPaymentPlan == undefined)
        {
            this.mppterm = event.target.value;
        
            SEARCHMPP({mppSearchTerm:this.mppterm})
                .then(result =>{
                
                this.resultExistingMPP = result;
            })
        }
    }
    handleMPPSelect(event){
        this.selectedMasterPaymentPlan = event.target.dataset.name;
        this.selectedMasterPaymentPlanId = event.target.dataset.id;
        this.resultExistingMPP = undefined;
    }

    closePanel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}