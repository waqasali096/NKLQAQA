import { LightningElement, wire, track,api } from 'lwc';
import { getRecord, getFieldValue, updateRecord  } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RESERVE_UNIT_MESSAGE from '@salesforce/schema/Opportunity.Reserve_Unit_Message__c';
import UNIT_RESERVED from '@salesforce/schema/Opportunity.Unit_Reserved__c';
import UNIT from '@salesforce/schema/Opportunity.Unit__c';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
const FIELDS = [ RESERVE_UNIT_MESSAGE , UNIT_RESERVED , UNIT];

export default class ReserveUnit extends LightningElement {
    @api recordId;
    @track isLoading = true;
    @track oppObj;
    @track reserveUnitMessage;
    @track noUnitAvailable = false;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    oppDetail( result ){
        this.oppObj = result;
        let status = getFieldValue(this.oppObj.data, UNIT);
        this.noUnitAvailable =  status == null ? true : false;
        let message = getFieldValue(this.oppObj.data, RESERVE_UNIT_MESSAGE);
        this.reserveUnitMessage =  message != null ? message : 'Are you sure?';
        this.isLoading = false;
    }
    handleSave(){
        this.isLoading = true;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[UNIT_RESERVED.fieldApiName] = true;
        const recordInput = {
        fields: fields
        };
        updateRecord(recordInput).then((record) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Unit status changed to Reserved!',
                    variant: 'success'
                })
            );
            this.handleCancel();
        });
    }
    handleCancel() {
        const value = '1';
        const valueChangeEvent = new CustomEvent("valuechange", {
        detail: { value }
        });
        this.dispatchEvent(valueChangeEvent);
    }
}