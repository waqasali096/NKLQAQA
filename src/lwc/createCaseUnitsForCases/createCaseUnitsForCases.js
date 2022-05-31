import { LightningElement , api, wire, track} from 'lwc';
import getUnitsForTitleDeed from '@salesforce/apex/CaseUnitController.getUnitsForTitleDeed';
import createCaseUnitsForTitleDeed from '@salesforce/apex/CaseUnitController.createCaseUnitsForTitleDeed';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CreateCaseUnitsForCases extends LightningElement {
    @api recordId;
    @track units;
    @track selectedUnits = [];
    @track columns = [
        { 
            label: 'Name', fieldName: 'unitUrl', type:'url',
            typeAttributes: {
                label: { 
                    fieldName: 'Name' 
                },
                target : '_blank'
            }
        }
    ];
    baseUrl = window.location.origin;
    @track isLoading = true;
    @track noUnitOptionsAvailable = false;

    @wire(getUnitsForTitleDeed, { caseId : '$recordId'})
    wiredUnits({ error, data }) {
        if (data) {
            let unitDataClone = JSON.parse(JSON.stringify(data));
            unitDataClone.forEach(unit => {
                        unit.unitUrl = this.baseUrl+'/lightning/r/Unit__c/'+unit.Id+'/view';
                    });
            this.units = unitDataClone;
            if(this.units.length == 0) {
                this.noUnitOptionsAvailable = true; 
            }
            this.isLoading = false;
        } else if (error) {
            this.units = undefined;
            this.noUnitOptionsAvailable = true;
            this.isLoading = false;
        }
    }

    getSelectedUnitFromSearch(event){
        const selectedRows = event.detail.selectedRows;
        for(let i=0; i<selectedRows.length; i++){
            this.selectedUnits.push(selectedRows[i].Id);
        } 
        console.log('###Units###'+JSON.stringify(this.selectedUnits));      
    }

    createCaseUnits(event){       
        if(this.selectedUnits.length > 0){
            this.isLoading = true;
            createCaseUnitsForTitleDeed({caseId : this.recordId, unitList:this.selectedUnits})
            .then(result=>{
                if(result === 'SUCCESS'){
                    this.isLoading = false;
                    this.dispatchEvent(new CloseActionScreenEvent());
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Case Units added Successfully!',
                        variant: 'Success',
                    });
                    this.dispatchEvent(evt);
                }
                else{
                    this.isLoading = false;
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Something Wrong! Please contact your System Administrator',
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                }               
                }).catch(error => {
                    this.isLoading = false;
                    console.log('@@error@@',error);
                        const evt = new ShowToastEvent({
                                        title: 'Error',
                                        message: 'Something Wrong! Please contact your System Administrator',
                                        variant: 'error',
                                    });
                                    this.dispatchEvent(evt);
                });
        }
        else{
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Select a unit to add',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}