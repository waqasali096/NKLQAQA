import { LightningElement, track, api } from 'lwc';

export default class DrawLoopDocumentGenration extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 

    @track iframeUrl = '';
    @api modalcheck;
    @api documentpackageid = '';
    @api deliveryoptionid = '';
    @api recordids = '';
    @api sobjecttype = '';
    @api source = '';

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.modalcheck = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.modalcheck = false;
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.modalcheck = false;
    }

    connectedCallback() {
        this.generateDocument();
    }

    generateDocument() {
        let url = '';
        console.log('==source==' + this.source);
        console.log('==source==' + this.recordIds);
        console.log('==source==' + this.sObjectType);

        if (this.source == 'bookingForm') {
            url = window.location.protocol + '//' + window.location.host + '/apex/GenerateBookingForm';
        } else {
            url = window.location.protocol + '//' + window.location.host + '/apex/GenerateSalesOffer';
        }

        url = url + '?ddpId=' + this.documentpackageid;
        url = url + '&deliveryOptionId=' + this.deliveryoptionid;
        url = url + '&ids=' + this.recordids;
        url = url + '&sObjectType=' + this.sobjecttype;

        this.iframeUrl = url;

        console.log('==iframeUrl==' + this.iframeUrl);
    }
}