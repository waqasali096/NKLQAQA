import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import {
    CloseActionScreenEvent
} from 'lightning/actions';
import GETUSERS from '@salesforce/apex/AddSalesExecutive.getUser';
import getSalesExecutive from '@salesforce/apex/AddSalesExecutive.getSalesExecutive';
import ADDMEMBER from '@salesforce/apex/AddSalesExecutive.createSalesExecutive';
import getuserDataList from '@salesforce/apex/AddSalesExecutive.getuserDataList';

import removeSalesExecutiveEvent from '@salesforce/apex/AddSalesExecutive.removeSalesExecutiveEvent';
import {
    getRecord,
    getFieldValue
} from "lightning/uiRecordApi";
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

const FIELDS = ['Sales_Event__c.Start_Date__c', 'Sales_Event__c.End_Date__c'];

export default class AddSalesEventExecutive extends LightningElement {

    @api recordId;
    usersList;
    newFilterUserList;
    error;
    selectedRows;
    dataFromTable;
    spinner = true;
    showError = false;
    salesExecuitve = true;
    diableButton = false;
    StartdatevalFlag = false;
    EnddatevalFlag = false;
    //value = 'Sales Executive';
    value = 'Sales Head'
    executiveEvent;
    salesExecuitveEvent = false;
    salesManagerUserId;
    profileName;
    salesManagerValue;
    // For pagination
    @track pageSize = 10;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track recordEnd = 0;
    @track recordStart = 0;
    @track isPrev = true;
    @track isNext = true;

    // for Existing Pagination
    @track pageSizeExisting = 10;
    @track pageNumberExisting = 1;
    @track totalRecordsExisting = 0;
    @track totalPagesExisting = 0;
    @track recordEndExisting = 0;
    @track recordStartExisting = 0;
    @track isPrevExisting = true;
    @track isNextExisting = true;
    managerId;

    get optionsforProfile() {
        return [{
                label: 'None',
                value: 'None'
            },
            {
                label: 'Sales Executive',
                value: 'Sales Executive'
            },
            {
                label: 'Sales Head',
                value: 'Sales Head'
            },
            {
                label: 'Sales Manager',
                value: 'Sales Manager'
            },
        ];
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: FIELDS
    })
    salesevent;
    handleChangeProfile(e) {
        this.value = e.detail.value;
        this.pageNumber = 1;

        this.salesManagerUserId = undefined;
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
        //this.getUsers();
        this.getUserCall();

    };

    getUsers() {
        if (this.value != 'None' && this.value != undefined) {
            this.profileName = this.value;
        }
        GETUSERS({
                salesEventRecordId: this.recordId,
                profileName: this.profileName,
                salesManagerId: this.salesManagerUserId
            }).then(result => {
                this.usersList = result;
                this.newFilterUserList = result;
                if (JSON.stringify(this.usersList) === "[]") {
                    const evt = new ShowToastEvent({
                        title: 'Sales Executives are already added',
                        variant: 'WARNING',
                    });
                    this.dispatchEvent(evt);
                    this.salesExecuitve = false;
                    this.diableButton = true;
                } else {
                    this.salesExecuitve = true;
                    this.diableButton = false;
                }
                this.spinner = false;
            })
            .catch(error => {
                console.log('ERROR ' + JSON.stringify(error));
                this.error = error;
            });
    }

    getSalesExecutiveEvent() {
        getSalesExecutive({
                salesEventRecordId: this.recordId,
                pageSizeExisting: this.pageSizeExisting,
                pageNumberExisting: this.pageNumberExisting
            }).then(result => {


                if (result != null) {
                    var resultData = JSON.parse(result);
                    this.executiveEvent = resultData.salesEventList;
                    this.salesExecuitveEvent = true;
                    this.pageNumberExisting = resultData.pageNumber;
                    this.totalRecordsExisting = resultData.totalRecords;
                    this.recordStartExisting = resultData.recordStart;
                    this.recordEndExisting = resultData.recordEnd;
                    this.totalPagesExisting = Math.ceil(resultData.totalRecords / this.pageSize);
                    this.isNextExisting = (this.pageNumberExisting == this.totalPagesExisting || this.totalPagesExisting == 0);
                    this.isPrevExisting = (this.pageNumberExisting == 1 || this.totalRecordsExisting < this.pageSizeExisting);
                }
                console.log('hiii', result);
            })
            .catch(error => {
                console.log('ERROR ' + error);
                this.error = error;
            });
    }

    get startDate() {
        return this.salesevent.data.fields.Start_Date__c.value;
    }
    get endDate() {
        return this.salesevent.data.fields.End_Date__c.value;
    }

    handleStartDateChange(event) {
        let newUserList = JSON.parse(JSON.stringify(this.usersList));
        for (var i = 0; i < newUserList.length; i++) {
            if (event.target.dataset.id == newUserList[i].userId) {
                if (event.target.value && event.target.value < this.salesevent.data.fields.Start_Date__c.value) {
                    newUserList[i].startDateError = true;
                } else {
                    newUserList[i].startDateError = false;
                    newUserList[i].startDate = event.target.value;
                }
            }
        }
        this.usersList = newUserList;
    }

    handleEndDateChange(event) {
        let newUserList = JSON.parse(JSON.stringify(this.usersList));
        for (var i = 0; i < newUserList.length; i++) {
            if (event.target.dataset.id == newUserList[i].userId) {
                if (event.target.value && event.target.value > this.salesevent.data.fields.End_Date__c.value) {
                    newUserList[i].endDateError = true;
                } else {
                    newUserList[i].endDateError = false;
                    newUserList[i].endDate = event.target.value;
                }
            }
        }
        this.usersList = newUserList;
    }

    handleUserSelectionCheck(event) {
        let newUserList = JSON.parse(JSON.stringify(this.usersList));
        newUserList[event.target.dataset.index].isSelected = event.target.checked;
        this.usersList = newUserList;
    }

    /*strt(e){     
        if(e.target.value<this.salesevent.data.fields.Start_Date__c.value) {
            this.StartdatevalFlag = true;
            this.diableButton = true;
        }
        else{
            this.diableButton = false;
            this.StartdatevalFlag = false;
        } 
    }
    end(e){      
        if(e.target.value>this.salesevent.data.fields.End_Date__c.value) {
            this.EnddatevalFlag = true;
            this.diableButton = true;
        } 
        else{
            this.diableButton = false;
            this.EnddatevalFlag = false;
        }
    }*/
    getUserCall() {
        this.usersList = [];
        this.newFilterUserList = [];
        if (this.value != 'None' && this.value != undefined) {
            this.profileName = this.value;
        }
        getuserDataList({
                salesEventRecordId: this.recordId,
                profileName: this.profileName,
                salesManagerId: this.salesManagerUserId,
                pageSize: this.pageSize,
                pageNumber: this.pageNumber

            })
            .then(result => {

                //this.usersList = result;
                // this.newFilterUserList = result;
                // pagination start
                var resultData = JSON.parse(result);
                this.usersList = resultData.userWrapperList;
                this.newFilterUserList = resultData.userWrapperList;
                this.pageNumber = resultData.pageNumber;
                this.totalRecords = resultData.totalRecords;
                this.recordStart = resultData.recordStart;
                this.recordEnd = resultData.recordEnd;
                this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
                console.log('----', this.usersList);
                console.log('----result---', result);
                if (JSON.stringify(this.usersList) === "[]") {
                    const evt = new ShowToastEvent({
                        title: 'Sales Executives are already added',
                        variant: 'WARNING',
                    });
                    this.dispatchEvent(evt);
                    this.salesExecuitve = false;
                    this.diableButton = true;
                } else {
                    this.salesExecuitve = true;
                    this.diableButton = false;
                }
                this.spinner = false;
            })
            .catch(error => {
                console.log('ERROR ' + JSON.stringify(error));
                this.error = error;
            });
    }

    async connectedCallback() {

        setTimeout(() => {
            this.getSalesExecutiveEvent();
            this.getUserCall();
        }, 50);
    }

    addSalesExecutive() {
        let selectedUsers = [];
        let newUserList = JSON.parse(JSON.stringify(this.usersList));
        for (let i = 0; i < newUserList.length; i++) {
            if (newUserList[i].isSelected) {
                if (newUserList[i].startDateError || newUserList[i].endDateError) {
                    this.showError = true;
                    break;
                } else {
                    this.showError = false;
                    selectedUsers.push(newUserList[i]);
                }
            }
        }
        console.log('errormsg' + this.showError);
        this.usersList = newUserList;
        if (this.showError) {
            const evt = new ShowToastEvent({
                title: 'Info',
                message: 'Please choose proper start & end dates',
                variant: 'Warning',
            });
            this.dispatchEvent(evt);
        }
        if (selectedUsers.length == 0 && this.showError == false) {
            const evt = new ShowToastEvent({
                title: 'Info',
                message: 'Please select members',
                variant: 'Warning',
            });
            this.dispatchEvent(evt);
        } else if (selectedUsers.length > 0 && this.showError == false) {
            this.spinner = true;
            ADDMEMBER({
                    salesExecutiveData: JSON.stringify(selectedUsers),
                    salesEventRecordId: this.recordId
                })
                .then((result) => {
                    if (result) {
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: 'Members added successfully',
                            variant: 'SUCCESS',
                        });
                        this.getUsers();

                        // this.closePanel();
                        this.dispatchEvent(evt);
                        eval("$A.get('e.force:refreshView').fire();");
                        this.getSalesExecutiveEvent();
                    }
                })
                .catch(error => {
                    console.log('ERROR& ' + error);
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Try again later',
                        variant: 'ERROR',
                    });
                    this.closePanel();
                    this.dispatchEvent(evt);
                });
        }
        /*this.dataFromTable = '';
        this.selectedRows = this.template.querySelectorAll('lightning-input');
        let pivot = this.selectedRows.length/this.usersList.length;   
        for(let i=0;i<this.selectedRows.length; i+=pivot){          
           if(this.selectedRows[i].checked){                
                this.dataFromTable += this.usersList[i/pivot].Id+',';
                for(let j = i+1; j< i+pivot;j++){
                    this.dataFromTable += this.selectedRows[j].value+',';                   
                }
                this.dataFromTable += ';';    
            }
       }       
       if(this.dataFromTable ===""){           
            const evt = new ShowToastEvent({
                title: 'Info',
                message: 'Please select members',
                variant: 'Warning',
            });
            this.dispatchEvent(evt);
       }
       else{
           this.spinner = true;
            ADDMEMBER({salesExecutiveData: this.dataFromTable,salesEventRecordId: this.recordId})
            .then((result)=>{            
                if(result){
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Members added successfully',
                        variant: 'SUCCESS',
                    });
                    this.getUsers();                   
                    this.closePanel();
                    this.dispatchEvent(evt);
                    eval("$A.get('e.force:refreshView').fire();");
                }
            })
            .catch(error=>{
                console.log('ERROR& '+ error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Try again later',
                    variant: 'ERROR',
                });
                this.closePanel();
                this.dispatchEvent(evt);
            });
       }  */
    }

    closePanel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    getInputUser(event) {
        const arrayList = [];
        for (let i = 0; i < this.usersList.length; i++) {
            if (this.usersList[i].userName.toUpperCase().startsWith(event.target.value.toUpperCase())) {
                arrayList.push(this.usersList[i]);
            }
        }
        if (arrayList.length > 0) {
            this.newFilterUserList = [...arrayList];
        }
    }
    checkedId = [];
    SalesEventExecutiveSelection(event) {
        var rowId = event.currentTarget.dataset.id;
        var checked = event.detail.checked;
        if (checked) {
            this.checkedId.push(rowId);
        } else {
            var index = this.checkedId.indexOf(rowId);
            this.checkedId.splice(index, 1);
        }
    }
    allSelected(event) {
        const toggleList = this.template.querySelectorAll('[data-verid^="toggle"]');
        for (const toggleElement of toggleList) {
            toggleElement.checked = event.target.checked;
            if (toggleElement.checked) {
                this.checkedId.push(toggleElement.dataset.id);
            } else {
                this.checkedId = [];
            }
        }

    }
    removeMember() {
        removeSalesExecutiveEvent({
                salesExcecutiveEventRecordId: this.checkedId
            }).then(result => {
                console.log('hiii', result);

                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Record has been delete successfully',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.getSalesExecutiveEvent();
                this.getUserCall();
                const toggleList = this.template.querySelectorAll('[data-verid^="toggle"]');
                for (const toggleElement of toggleList) {
                    toggleElement.checked = false;
                }
            })
            .catch(error => {
                console.log('ERROR ' + error);
                this.error = error;
            });

    }
    allSelectedSalesEvent(event) {
        let newUserList = JSON.parse(JSON.stringify(this.usersList));
        console.log('newUserListbefore--->', newUserList);
        const toggleList = this.template.querySelectorAll('[data-allinput^="checkValue"]');
        for (const toggleElement of toggleList) {
            toggleElement.checked = event.target.checked;
            if (toggleElement.checked) {
                for (const checkData of newUserList) {
                    checkData.isSelected = event.target.checked;
                }

            } else {
                for (const checkData of newUserList) {
                    checkData.isSelected = false;
                }
            }
        }
        this.usersList = newUserList;
        //console.log('toggleList', toggleList);


        //newUserList[event.target.dataset.index].isSelected = event.target.checked;
        // this.usersList = newUserList; 
    }

    handleSalesManager(event) {
        this.pageNumber = 1;
        let salesMangerId = '';
        salesMangerId = (event.detail.value)[0];

        this.value = 'None';
        this.profileName = 'Sales Manager';
        this.salesManagerUserId = salesMangerId;
        console.log('this.salesManagerUserId' + this.salesManagerUserId);
        if (this.salesManagerUserId != undefined && this.salesManagerUserId != '') {
            this.getUserCall();
        }
    }
    //handle next
    handleNext() {
        this.pageNumber = this.pageNumber + 1;
        this.getUserCall();
    }

    //handle prev
    handlePrev() {
        this.pageNumber = this.pageNumber - 1;
        this.getUserCall();
    }
    handleNextExisting() {
        this.pageNumberExisting = this.pageNumberExisting + 1;
        this.getSalesExecutiveEvent();
    }

    //handle prev
    handlePrevExisting() {
        this.pageNumberExisting = this.pageNumberExisting - 1;
        this.getSalesExecutiveEvent();
    }

}