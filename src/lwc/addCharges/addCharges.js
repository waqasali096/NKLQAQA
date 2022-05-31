/**************************************************************************************************
* Name               : addCharges.js                                              
* Description        : JS controller for addCharges component.                           
* Created Date       : 20/01/2022
* Created By         : Cloudworks                                                    
* ------------------------------------------------------------------------------------------------
* VERSION    AUTHOR      DATE            COMMENTS                                                 
* 1.0        Rohit       20/01/2022      Initial Draft.                                           
**************************************************************************************************/
import { LightningElement, wire, track,api } from 'lwc';
import { getRecord, getFieldValue  } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import getAdditionalCharges from "@salesforce/apex/AddChargesController.getAdditionalCharges";
import createOppCharges from "@salesforce/apex/AddChargesController.createOppCharges";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UNIT from '@salesforce/schema/Opportunity.Unit__c';
const FIELDS = [ UNIT ];
const COLUMNS = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'VAT %', fieldName: 'VAT__c', type: 'percentage'},  
    { label: 'VAT Amount', fieldName: 'VAT_Amount__c', type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: 'VAT Code', fieldName: 'VAT_Code__c' },
];
export default class AddCharges extends LightningElement {
    @api recordId;
    @track isLoading = true;
    @track chargesAvailable = false;
    @track noChargesAvailable = false;
    @track unitId;
    @track oppObj;
    @track selectedData;
    @track errorMessage;
    data = [];
    columns = COLUMNS;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
        oppDetail( result ){
            this.oppObj = result;
            this.unitId = getFieldValue(this.oppObj.data, UNIT);
            if( this.unitId ){
                this.unitOptions(); 
            }
            this.isLoading = false;
        }

    get noUnitAvailable(){
        let status = getFieldValue(this.oppObj.data, UNIT);
        return status == null ? true : false;
    }

    unitOptions(){
        getAdditionalCharges({ 
            unitId: this.unitId,
            oppId: this.recordId
        })
            .then(result => {  
                console.log( ' getAdditionalCharges=> result => ',result );
                if(result.success){
                    if(result.data.length > 0 ){
                        this.data = result.data;
                        this.chargesAvailable = true;
                    }else{
                        this.noChargesAvailable = true;
                    }
                }else{
                    console.log( 'getAdditionalCharges => error message =>'+result.message );
                    this.errorMessage = result.message;
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.errorMessage = error;
                console.log( 'getAdditionalCharges => error =>'+JSON.stringify(error) );
            });
    }

    handleRowSelection(event) {
        var selectedRows = event.detail.selectedRows;
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i]);
        }
        this.selectedData = setRows;
        if(!this.selectedData.length > 0){
            this.selectedData = undefined;
        }
        console.log( ' SelectedData => ',this.selectedData);
    }

    handleSave(){
        this.isLoading = true;
        createOppCharges({ additionalChargesList: this.selectedData, oppId: this.recordId })
            .then(result => {  
                if(result.success){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Opportunity Charges Created!',
                            variant: 'success'
                        })
                    );
                    this.handleCancel();
                }else{
                    console.log( 'createOppCharges => error message =>'+result.message );
                    this.errorMessage = result.message;
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                this.errorMessage = error;
                console.log( 'createOppCharges => error =>'+JSON.stringify(error) );
            });
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}