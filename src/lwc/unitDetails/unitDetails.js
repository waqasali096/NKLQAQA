import { LightningElement, api, wire, track } from 'lwc';
import fetchUnitDetails from '@salesforce/apex/UnitDetailsController.fetchUnitDetails';
const offerColumns = [
    { label: 'Offer Name', fieldName: 'Name', type:'text'},
    { label: 'Special Offer Type', fieldName: 'Type__c', type: 'text' },
    { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date' },
    { label: 'End Date', fieldName: 'End_Date__c', type: 'date' },
];
const milestoneColumns = [
    { label: 'Name', fieldName: 'milestoneName', type:'text'},
    { label: 'Percentage', fieldName: 'milestonePercentage', type: 'percent',cellAttributes: {alignment: 'left'},typeAttributes: { step: '0.01'} },
    { label: 'Date', fieldName: 'milestoneDate', type: 'date' },
    { label: 'Amount', fieldName: 'milestoneAmount', type: 'currency',cellAttributes: {alignment:'left'}},
];
const chargesColumns = [
    { label: 'Name', fieldName: 'chargeName', type:'text'},
    { label: 'Charge%', fieldName: 'chargePercentage', type: 'percent',cellAttributes: {alignment: 'left'},typeAttributes: { step: '0.01'} },
    { label: 'Charge Amount', fieldName: 'chargeAmount', type: 'currency',cellAttributes: {alignment: 'left'}},
    { label: 'VAT%', fieldName: 'chargeVatPercentage', type: 'percent',cellAttributes: {alignment: 'left'},typeAttributes: { step: '0.01'} },
    { label: 'VAT Amount', fieldName: 'chargeVatAmount', type: 'currency',cellAttributes:{alignment: 'left'}},
    { label: 'Total Amount', fieldName: 'chargeTotalAmount', type: 'currency',cellAttributes:{alignment: 'left'}},
];
export default class UnitDetails extends LightningElement {

    @api modalcheck = undefined;
    @api unitid = undefined;
    @api modalCheck;
    @api unitId;
    @api oppId;
    @track offerColumns = offerColumns;
    @track offersData;
    @track chargesData;
    @track urls;
    @track unitPlanurls;
    @track milestoneColumns = milestoneColumns;
    @track chargesColumns = chargesColumns;
    @track milestonesData;
    compName = '';

    connectedCallback(){
       console.log( 'unitId' + this.unitid );
       console.log( 'modalCheck' + this.modalcheck );
       if(this.unitid != undefined){
        this.unitId = this.unitid;
        this.compName = 'salesEventTab';
       }
       if(this.modalcheck != undefined){
        this.modalCheck = this.modalcheck;
       }
       
       fetchUnitDetails( {recordId: this.unitId, oppId: this.oppId, compName: this.compName})
            .then(result => {
                this.offersData = result.specialOffers;
                this.chargesData = result.additionalCharges;
                this.milestonesData = result.milestonesList;
                console.log('oppId'+ this.oppId);
                console.log('charges'+JSON.stringify(this.chargesData));
                this.urls = result.floorPlanUrls;
                this.unitPlanurls = result.unitPlanUrls;
            })
    }
    closeModalAction(){
        console.log('===closeModalAction1==');
        this.modalCheck=false;
        const closepopupevent = new CustomEvent("closepopup", {});
        this.dispatchEvent(closepopupevent);
    }
}