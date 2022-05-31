import {
    LightningElement,
    track,
    api
} from 'lwc';
import {
    loadScript
} from 'lightning/platformResourceLoader';
import {
    createRecord
} from 'lightning/uiRecordApi';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import PBE_OBJECT from '@salesforce/schema/PriceBook_Entry__c';
import UNIT_FIELD from '@salesforce/schema/PriceBook_Entry__c.Unit_Code__c';
import PRICE_FIELD from '@salesforce/schema/PriceBook_Entry__c.Price__c';
import PRICEBOOK_FIELD from '@salesforce/schema/PriceBook_Entry__c.Price_Book__c';
import {
    CloseActionScreenEvent
} from 'lightning/actions';
import checkExistingPriceBookEntries from '@salesforce/apex/UploadPriceBookEntryController.checkExistingPriceBookEntries';

export default class UploadPriceBookEntry extends LightningElement {
    @api recordId;
    parserInitialized = false;
    loading = false;
    @track _results;
    @track _rows;
    @track isErrorMessage = false;
    @track errorMessage = '';
    @track unitcodeUnique = false;
    btnVisible = true;
    temArray = [];
    doneButtonVisible = false;
    get columns() {
        const columns = [{
                label: 'Unit Code',
                fieldName: 'UnitCode'
            },
            {
                label: 'New Selling Price',
                fieldName: 'New Selling Price'
            },
            {
                label: 'Data result',
                fieldName: 'Data result'
            }
        ];
        if (this.results.length) {
            columns.push({
                label: 'Result',
                fieldName: 'result'
            });
        }
        return columns;
    }
    get rows() {
        console.log('==this._rows==', JSON.stringify(this._rows));

        if (this._rows) {
            return this._rows.map((row, index) => {
                row.key = index;
                if (this.results[index]) {
                    row.result = this.results[index].id || this.results[index].error;
                }
                return row;
            })
        }
        return [];
    }
    get results() {
        if (this._results) {
            return this._results.map(r => {
                const result = {};
                result.success = r.status === 'fulfilled';
                result.id = result.success ? 'Success' : undefined;
                result.error = !result.success ? r.reason.body.message : undefined;
                return result;
            });
        }
        return [];
    }
    renderedCallback() {
        if (!this.parserInitialized) {
            loadScript(this, PARSER)
                .then(() => {
                    this.parserInitialized = true;
                })
                .catch(error => console.error(error));
        }
    }
    handleInputChange(event) {
        if (event.target.files.length > 0) {
            console.log('==event.target.files==', JSON.stringify(event.target.files));
            const file = event.target.files[0];
            this.loading = true;
            console.log('this.temArray', JSON.stringify(file));
            Papa.parse(file, {
                quoteChar: '"',
                header: 'true',
                complete: (results) => {
                    this.temArray = results.data;
                    console.log('==this.temArray==', JSON.stringify(this.temArray));
                    //let temArrays = this.temArray.pop();
                    let toMap = {};
                    let resultToReturn = false;
                    let unitCodeSet = [];
                    let uniqueUnits = [];
                    let dublicateUnits = [];
                    
                    this.temArray.forEach((unit) => {
                        console.log('==unit.UnitCode=='+unit.UnitCode);
                        if (!uniqueUnits.includes(unit.UnitCode)) {
                            uniqueUnits.push(unit.UnitCode);
                        }else{
                            dublicateUnits.push(unit.UnitCode);
                        }
                    });

                    

                    console.log('==uniqueUnits==', JSON.stringify(uniqueUnits));
                    console.log('==dublicateUnits==', JSON.stringify(dublicateUnits));

                    for (let i = 0; i < this.temArray.length; i++) {
                        console.log('Inside for loop statement');
                        if(dublicateUnits.includes(this.temArray[i].UnitCode)){
                            resultToReturn = true;
                            this.isErrorMessage = true;
                            this.temArray[i]['Data result'] = 'duplicate Unit Found';
                        }else if (this.temArray[i]['New Selling Price'] == '') {
                            this.temArray[i]['Data result'] = 'Price can not be empty';
                            console.log(this.temArray[i].UnitCode + 'does not contain Price');
                            this.isErrorMessage = true;
                            this.errorMessage = ' *Price for Unit Codes are Empty.'
                        } else {
                            unitCodeSet.push(this.temArray[i].UnitCode);  
                        }
                    }

                    if (resultToReturn) {
                        this.isErrorMessage = true;
                        this.errorMessage = '*duplicate Unit Found';
                        this._rows = results.data;
                        this.loading = false;
                    }else{
                        checkExistingPriceBookEntries({
                            priceBookId: this.recordId,
                            unitCodeSet: unitCodeSet
                        })
                        .then(result => {
                            if (result) {
                                console.log('==result==' + result);
                                //check for duplicates
                                for (let i = 0; i < this.temArray.length; i++) {
                                    console.log('==this.temArray[i].UnitCode==' + this.temArray[i].UnitCode);
                                    if (result.includes(this.temArray[i].UnitCode)) {
                                        resultToReturn = true;
                                        this.temArray[i]['Data result'] = 'Price Booke Entry Unit Found';
                                    }
                                    //result[this.temArray[i].UnitCode] = true;
                                }

                                if (resultToReturn) {
                                    console.log('Duplicate elements exist');
                                    this.isErrorMessage = true;
                                    this.errorMessage = ' *Price Booke Entry Unit Found'
                                    this.unitcodeUnique = true;
                                } else {
                                    console.log('Duplicates does not exist');
                                }

                                this._rows = results.data;
                                this.loading = false;
                            }

                        }).catch(error => {
                            console.log('@@error@@', error);
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: 'Something Wrong! Please contact your System Administrator',
                                variant: 'warning',
                            });
                            this.dispatchEvent(evt);
                        });
                    }
                },
                error: (error) => {
                    console.error(error);
                    this.loading = false;
                }
            })
        }
    }
    createPbe() {
        const PbeToCreate = this.rows.map(row => {
            const fields = {};
            fields[UNIT_FIELD.fieldApiName] = row.UnitCode;
            fields[PRICE_FIELD.fieldApiName] = row['New Selling Price'];
            fields[PRICEBOOK_FIELD.fieldApiName] = this.recordId;
            const recordInput = {
                apiName: PBE_OBJECT.objectApiName,
                fields
            };
            console.log('==recordInput==' + JSON.stringify(recordInput));
            return createRecord(recordInput);
        });
        if (PbeToCreate.length) {
            console.log('----' + PbeToCreate.length);
            this.loading = true;
            Promise.allSettled(PbeToCreate)
                .then(results => {
                    this._results = results;
                    //this.dispatchEvent(new CloseActionScreenEvent());
                    this.btnVisible = false;
                    this.doneButtonVisible = true;
                })
                .catch(error => console.error(JSON.stringify(error)))
                .finally(() => this.loading = false);

        }
    }
    cancel() {
        this._rows = undefined;
        this._results = undefined;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    done() {
        eval("$A.get('e.force:refreshView').fire();");
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}