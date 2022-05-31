/**************************************************************************************************
* Name               : addOptions.js                                              
* Description        : JS controller for addOptions component.                           
* Created Date       : 20/01/2022
* Created By         : Cloudworks                                                    
* ------------------------------------------------------------------------------------------------
* VERSION    AUTHOR      DATE            COMMENTS                                                 
* 1.0        Rohit       20/01/2022      Initial Draft.                                           
**************************************************************************************************/
import { LightningElement, wire, track,api } from 'lwc';
import { getRecord, getFieldValue  } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import getUnitOptions from "@salesforce/apex/AddOptionsController.getUnitOptions";
import createOppOptions from "@salesforce/apex/AddOptionsController.createOppOptions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UNIT from '@salesforce/schema/Opportunity.Unit__c';
const FIELDS = [ UNIT ];
const COLUMNS = [
    { label: 'Master Option', fieldName: 'MasterOption', type: 'text', wrapText: true ,typeAttributes: {label: {fieldName: 'masterOption'}, target: '_blank'},hideDefaultActions: true},
    //{ label: 'Option Type', fieldName: 'Option_Type__c', type: 'STRING', cellAttributes: { alignment: 'left' }},
    { label: 'Price', fieldName: 'Price__c', type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: 'Additional Area (SFT)', fieldName: 'Additional_Area__c', type: 'NUMBER', cellAttributes: { alignment: 'left' }},
    { label: 'Unit Theme', fieldName: 'UnitTheme', type: 'text', wrapText: true ,typeAttributes: {label: {fieldName: 'unitTheme'}, target: '_blank'},hideDefaultActions: true},
    { label: 'Option Width (SFT)', fieldName: 'Optional_Width__c', type: 'NUMBER', cellAttributes: { alignment: 'left' }},
    { label: 'Option Length (SFT)', fieldName: 'Optional_Length__c', type: 'NUMBER', cellAttributes: { alignment: 'left' }},
];
export default class AddOptions extends LightningElement {
    @api recordId;
    @track isLoading = true;
    @track unitOptionsAvailable = false;
    @track noUnitOptionsAvailable = false;
    @track unitId;
    @track oppObj;
    @track selectedData;
    @track freeList;
    @track paidList;
    @track errorMessage;
    data = [];
    freeData = [];
    columns = COLUMNS;
    @api custominvocation = false;
    @api showSave = false;
    @api optionsSaved = false;
    @track unitOptionsModalFlag = true;
    @track preSelectedRows = [];

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
        getUnitOptions({ unitId: this.unitId, oppId: this.recordId})
            .then(result => {  
                console.log( ' getUnitOptions=> result => ',result );
                if(result.success){
                    this.preSelectedRows = result.data.unitOptionIds;
                    this.freeList = result.data.freeList;
                    this.paidList = result.data.paidList;
                    if(result.data && result.data.optionList && result.data.optionList.length > 0 ){
                        result.data.optionList.forEach(function(record){
                            if (record.Master_Option__c !== null && record.Master_Option__c !== undefined) {
                                record.MasterOption = record.Master_Option__r.Name;
                                record.masterOption = record.Master_Option__r.Name;
                            }
                            if (record.Unit_Theme__c !== null && record.Unit_Theme__c !== undefined) {
                                record.UnitTheme = record.Unit_Theme__r.Name;
                                record.unitTheme = record.Unit_Theme__r.Name;
                            }
                        });
                        let tempData =  result.data.optionList;
                        for(var i=0; i< tempData.length; i++){
                            if(tempData[i].Option_Type__c != null && tempData[i].Option_Type__c == 'Free'){
                                this.freeData.push(tempData[i]);
                            }else{
                                this.data.push(tempData[i]);
                            }
                        }
                        this.unitOptionsAvailable = true;
                    }else{
                        this.noUnitOptionsAvailable = true;
                    }
                }else{
                    console.log( 'getUnitOptions => error message =>'+result.message );
                    this.errorMessage = result.message;
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.errorMessage = error;
                console.log( 'getUnitOptions => error =>'+JSON.stringify(error) );
            });
    }

    handleRowSelectionFree(event) {
        var selectedRows = event.detail.selectedRows;
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i]);
        }
        this.freeList = setRows;
        if(!this.freeList.length > 0){
            this.freeList = undefined;
        }
        console.log( ' freeList => ',this.freeList);
    }
    handleRowSelectionPaid(event) {
        var selectedRows = event.detail.selectedRows;
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i]);
        }
        this.paidList = setRows;
        if(!this.paidList.length > 0){
            this.paidList = undefined;
        }
        console.log( ' paidList => ',this.paidList);
    }

    handleSave(){
            this.isLoading = true;
            createOppOptions({ 
                freeList: this.freeList, 
                paidList: this.paidList, 
                oppId: this.recordId 
            })
                .then(result => {  
                    if(result.success){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Opportunity Options Created!',
                                variant: 'success'
                            })
                        );
                        this.optionsSaved = true;
                        this.handleCancel();
                    }else{
                        console.log( 'createOppOptions => error message =>'+result.message );
                        this.errorMessage = result.message;
                    }
                    this.isLoading = false;
                })
                .catch(error => {
                    this.isLoading = false;
                    this.errorMessage = error;
                    console.log( 'createOppOptions => error =>'+JSON.stringify(error) );
                });
        
    }

    handleCancel() {
        if(!this.custominvocation){
            this.dispatchEvent(new CloseActionScreenEvent());
        }
        if(this.custominvocation){
            const closePopUpEvent = new CustomEvent("closePopUp",{detail:{isSaved:this.optionsSaved}});
            this.dispatchEvent(closePopUpEvent);
        }
    }
}