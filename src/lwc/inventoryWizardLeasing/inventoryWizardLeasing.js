import { LightningElement, track, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import fetchProjectNames from '@salesforce/apex/LeasingInventoryWizardController.fetchProjectNames'
import clusterPicklistValues from '@salesforce/apex/LeasingInventoryWizardController.clusterPicklistValues'
import buildingPicklistValues from '@salesforce/apex/LeasingInventoryWizardController.buildingPicklistValues'
import floorPicklistValues from '@salesforce/apex/LeasingInventoryWizardController.floorPicklistValues'
import fetchUnits from '@salesforce/apex/LeasingInventoryWizardController.fetchUnits'
import generateBookingForSelectedUnits from '@salesforce/apex/LeasingInventoryWizardController.generateBookingForSelectedUnits'
import createLeaseOfferRecords from '@salesforce/apex/LeasingInventoryWizardController.createLeaseOfferRecords'
import fetchLeasingInventoryWizardSetting from '@salesforce/apex/LeasingInventoryWizardController.fetchLeasingInventoryWizardSetting'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import UNIT_OBJECT from '@salesforce/schema/Unit__c';

export default class InventoryWizardLeasing extends NavigationMixin(LightningElement) {

    projectPicklistValues = [];
    bedroomPicklist = [{ value: '', label: 'All' }];
    unitStatusPicklist = [{ value: '', label: 'All' }];
    unitTypePicklist = [{ value: '', label: 'All' }];
    propertyTypePicklist = [{ value: '', label: 'All' }];
    clusterPicklist = [{ value: '', label: 'All' }];
    buildingPicklist = [{ value: '', label: 'All' }];
    floorPicklist = [{ value: '', label: 'All' }];
    unitsDataAll = [];
    selectedLeasingType = '';
    selectedProject = '';
    selectedBedroom = '';
    //selectedStatus = '';
    selectedUnitType = '';
    selectedPropertyType = '';
    selectedBuilding = '';
    selectedFloor = '';    
    selectedCluster = '';
    showResidentialFilter = true;
    showCommercialFilter = false;
    value = "resedential";
    isGenerateLeaseOfferModalOpen = false;
    isGenerateBookingModalOpen = false;
    hideAddButton = true;
    showEmailList = false;
    selectedEmailAddresses = [];
    emailValue = '';
    currentPage = 1;
    disablePrevious = true;
    disableNext = true;
    totalPagesCount = 1;
    pageSize = 3;
    totalRecordsCount = 0;
    unitRecordsData = [];    
    tableData = [];
    showUnitTable = false;
    showBucketTable = false;
    bucketTableColumns = [];
    bucketTableData = [];
    unitTableData = [];
    disableClusterPicklist = true;
    disableBuildingPicklist = true;
    disableFloorPicklist = true;
    startIndex;
    endIndex;
    leasingRecordTypeId = '';
    selectAllUnits = false;
    controllingValues = [];
    controlUnitTypeValues = [];
    totalDependentUnitTypeValues = [];
    controlPropertyTypeValues = [];
    totalDependentPropertyTypeValues = [];
    isLoading = false;
    leaseStartDate;
    todaysDate;
    disbleGenerateBooking = false;
    
    resedentialBucketColumns = [
        {
            label: 'Remove', type: 'button-icon', fieldName: '',
            typeAttributes: { iconName: 'utility:delete', name: 'delete', iconClass: 'slds-icon-text-error' },
            fixedWidth: 75,
            hideDefaultActions: true,
        },
        {
            label: 'Location Code', fieldName: 'linkName', type: 'url', hideDefaultActions: true,
            typeAttributes: { label: { fieldName: 'Unit_Code__c' }, target: '_blank' }
        },
        { label: 'Project', fieldName: 'ProjectName', hideDefaultActions: true },
        { label: 'No. Of Bedrooms', fieldName: 'No_of_Bedrooms__c', hideDefaultActions: true },
        { label: 'Unit Type', fieldName: 'Unit_space_Type__c', hideDefaultActions: true },        
        { label: 'Property type', fieldName: 'Leasing_Property_Type__c', hideDefaultActions: true },
        { label: 'Base Rent', fieldName: 'Base_Rent__c', hideDefaultActions: true },
        { label: 'Sec Deposit', fieldName: 'Security_Deposit__c', hideDefaultActions: true }
    ];

    commercialBucketColumns = [
        {
            label: 'Remove', type: 'button-icon', fieldName: '',
            typeAttributes: { iconName: 'utility:delete', name: 'delete', iconClass: 'slds-icon-text-error' },
            fixedWidth: 75,
            hideDefaultActions: true,
        },
        {
            label: 'Location Code', fieldName: 'linkName', type: 'url', hideDefaultActions: true,
            typeAttributes: { label: { fieldName: 'Unit_Code__c' }, target: '_blank' }
        },
        { label: 'Project', fieldName: 'ProjectName', hideDefaultActions: true },
        { label: 'Unit Type', fieldName: 'Unit_space_Type__c', hideDefaultActions: true },        
        { label: 'Property type', fieldName: 'Leasing_Property_Type__c', hideDefaultActions: true },
        { label: 'Base Rent', fieldName: 'Base_Rent__c', hideDefaultActions: true },
        { label: 'Sec Deposit', fieldName: 'Security_Deposit__c', hideDefaultActions: true },
    ];

    get leasingTypeValue() {
        return [{ label: 'Residential Units', value: 'resedential' },
        { label: 'Commercial Units', value: 'commercial' }];
    }    

    connectedCallback() {
        this.isLoading = true;
        this.value = 'resedential';
        this.bucketTableColumns = this.resedentialBucketColumns;
        var today = new Date();
        this.leaseStartDate = today.toISOString();
        this.todaysDate  = today.getFullYear() + '-' + (today.getMonth()+1) + '-' + today.getDate();

        fetchProjectNames().then(result => {
            if (result.length > 0) {
                console.log('inside if');
                result.map(resElement => {
                    console.log('element', resElement);
                    this.projectPicklistValues = [...this.projectPicklistValues, { value: resElement.Id, label: resElement.Name }];
                });
                this.selectedProject = this.projectPicklistValues[0].value;                
                this.isLoading = false;
                this.handleProjectChange();
            }
        }).catch(error => { });
    }

    @wire(getObjectInfo, { objectApiName: UNIT_OBJECT }) unitMetadata;

    @wire( fetchLeasingInventoryWizardSetting )  
    wiredRecs( value ) { 
        const { data, error } = value;
        if ( data ) {        
            this.pageSize = data[0].Unit_Table_Page_Size__c;                
            this.leasingRecordTypeId = data[0].Unit_Object_Leasing_Record_Type_Id__c;
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: UNIT_OBJECT, recordTypeId: "$leasingRecordTypeId"})
    leasingTypePicklistValues({error, data}) {
        if(data) {
            let leasingTypeOptions = [{label:'All', value:''}];

            data.picklistFieldValues.Leasing_Type__c.values.forEach(key => {
                leasingTypeOptions.push({
                    label : key.label,
                    value: key.value
                })
            });
            this.controllingValues = leasingTypeOptions;

            let leasingTypeValue = '';
            if(this.value == 'resedential'){
                // leasingTypeValue = 'Residential Leasing Unit';
                leasingTypeValue = 'Residential Unit';
            }

            if(this.value == 'commercial'){
                // leasingTypeValue = 'Residential Leasing Shop';
                leasingTypeValue = 'Commercial Unit';
            }

            //No of Bedroom values (No_of_Bedrooms__c)
            let bedroomOptions = [{label:'All', value:''}];
            let bedroomPicklistValues = data.picklistFieldValues.No_of_Bedrooms__c.values;
            bedroomPicklistValues.forEach(conValues => {
                bedroomOptions.push({
                    label: conValues.label,
                    value: conValues.value
                });
            });
            this.bedroomPicklist = bedroomOptions;

            //Unit Type values (Unit_space_Type__c)
            let unitTypeOptions = [{label:'All', value:''}];
            this.controlUnitTypeValues = data.picklistFieldValues.Unit_space_Type__c.controllerValues;
            this.totalDependentUnitTypeValues = data.picklistFieldValues.Unit_space_Type__c.values;
            this.totalDependentUnitTypeValues.forEach(conValues => {
                if(conValues.validFor[0] === this.controlUnitTypeValues[leasingTypeValue]) {
                    unitTypeOptions.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            });
            this.unitTypePicklist = unitTypeOptions;
            //Property Type values (Leasing_Property_Type__c)
            let propertyTypeOptions = [{label:'All', value:''}];
            this.controlPropertyTypeValues = data.picklistFieldValues.Leasing_Property_Type__c.controllerValues;
            this.totalDependentPropertyTypeValues = data.picklistFieldValues.Leasing_Property_Type__c.values;

            this.totalDependentPropertyTypeValues.forEach(conValues => {
                if(conValues.validFor[0] === this.controlPropertyTypeValues[leasingTypeValue]) {
                    propertyTypeOptions.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            });
            this.propertyTypePicklist = propertyTypeOptions;
        }
        else if(error) {
            console.log('Error => '+JSON.stringify(error));
        }
    }

    leasingTypeChange(event) {                
        this.isLoading = true;
        this.clearFilterMethod();

        if (event.detail.value == 'resedential') {
            this.value = 'resedential';
            this.bucketTableColumns = this.resedentialBucketColumns;
            this.showResidentialFilter = true;
            this.showCommercialFilter = false;
        } 

        if (event.detail.value == 'commercial') {
            this.value = 'commercial';
            this.bucketTableColumns = this.commercialBucketColumns;
            this.showCommercialFilter = true;
            this.showResidentialFilter = false;
        }

        let leasingTypeValue = '';
        if(this.value == 'resedential'){
            leasingTypeValue = 'Residential Unit';
        }

        if(this.value == 'commercial'){
            leasingTypeValue = 'Commercial Unit';
        }

        //Unit Type values (Unit_space_Type__c)
        let unitTypeOptions = [{label:'All', value:''}];
        this.totalDependentUnitTypeValues.forEach(conValues => {
            if(conValues.validFor[0] === this.controlUnitTypeValues[leasingTypeValue]) {
                unitTypeOptions.push({
                    label: conValues.label,
                    value: conValues.value
                })
            }
        });
        this.unitTypePicklist = unitTypeOptions;

        //Property Type values (Leasing_Property_Type__c)
        let propertyTypeOptions = [{label:'All', value:''}];
        this.totalDependentPropertyTypeValues.forEach(conValues => {
            if(conValues.validFor[0] === this.controlPropertyTypeValues[leasingTypeValue]) {
                propertyTypeOptions.push({
                    label: conValues.label,
                    value: conValues.value
                })
            }
        });
        this.propertyTypePicklist = propertyTypeOptions;
                        
        this.isLoading = false;
    }

    projectChange(event) {
        this.selectedProject = event.detail.value;
        this.handleProjectChange();
    }
    
    handleProjectChange() {                
        this.isLoading = true;
        this.clusterPicklist = [{ value: '', label: 'All' }];
        this.buildingPicklist = [{ value: '', label: 'All' }];
        this.floorPicklist = [{ value: '', label: 'All' }];
        this.selectedCluster = '';
        this.selectedBuilding = '';
        this.selectedFloor = '';
        this.disableClusterPicklist = true;
        this.disableBuildingPicklist = true;
        this.disableFloorPicklist = true;

        clusterPicklistValues({projectId: this.selectedProject }).then(result => {
            if (result.length > 0) {
                this.disableClusterPicklist = false;
                result.map(item => {
                    this.clusterPicklist = [...this.clusterPicklist, { value: item.Id, label: item.Name }];
                })
            }
            else{
                this.disableClusterPicklist = true;
            }                            
            this.isLoading = false;
        });

        buildingPicklistValues({projectId: this.selectedProject}).then(result => {
            if (result.length > 0) {
                this.disableBuildingPicklist = false;
                result.map(item => {
                    this.buildingPicklist = [...this.buildingPicklist, { value: item.Id, label: item.Name }];
                })
            }
            else{
                this.disableBuildingPicklist = true;
            }                            
            this.isLoading = false;
        });
    }

    bedroomChange(event) {
        this.selectedBedroom = event.detail.value;
    }

    unitTypeChange(event){
        this.selectedUnitType = event.detail.value;
    }

    propertyTypeChange(event){
        this.selectedPropertyType = event.detail.value;
    }

    clusterChange(event){
        this.selectedCluster = event.detail.value;
        this.handleClusterChange();        
    }

    handleClusterChange(){                
        this.isLoading = true;
        this.buildingPicklist = [{ value: '', label: 'All' }];
        this.floorPicklist = [{ value: '', label: 'All' }];
        this.selectedBuilding = '';
        this.selectedFloor = '';
        this.disableBuildingPicklist = true;
        this.disableFloorPicklist = true;

        buildingPicklistValues({projectId: this.selectedProject, clusterId: this.selectedCluster }).then(result => {
            if (result.length > 0) {
                this.disableBuildingPicklist = false;
                result.map(item => {
                    this.buildingPicklist = [...this.buildingPicklist, { value: item.Id, label: item.Name }];
                })
            }
            else{
                this.disableBuildingPicklist = true;
            }                            
            this.isLoading = false;
        });
    }

    buildingChange(event){
        this.selectedBuilding = event.detail.value;
        this.handleBuildingChange();
    }

    handleBuildingChange(){                
        this.isLoading = true;
        this.floorPicklist = [{ value: '', label: 'All' }];
        this.selectedFloor = '';
        this.disableFloorPicklist = true;
        
        floorPicklistValues({projectId: this.selectedProject, clusterId: this.selectedCluster, buildingId: this.selectedBuilding }).then(result => {
            if (result.length > 0) {
                this.disableFloorPicklist = false;
                result.map(item => {
                    this.floorPicklist = [...this.floorPicklist, { value: item.Id, label: item.Name }];
                })
            }
            else{
                this.disableFloorPicklist = true;
            }                
            this.isLoading = false;
        });
    }

    floorChange(event){
        this.selectedFloor = event.detail.value;
    }

    /*statusChange(event) {
        this.selectedStatus = event.detail.value;
    }*/

    searchUnits() {                
        this.isLoading = true;
        fetchUnits({ leasingType: this.value, projId: this.selectedProject, bedroom: this.selectedBedroom, unitSpaceType: this.selectedUnitType, propertyType: this.selectedPropertyType, cluster: this.selectedCluster, building: this.selectedBuilding, floor: this.selectedFloor}).then(result => {
            console.log('result', result);
            
            if (result) {
                let preparedArr = [];
                result.forEach(item => {
                    let preparedRec = {};
                    
                    if (item.Id !== null && item.Id !== undefined) {
                        preparedRec.Id = item.Id;
                        preparedRec.linkName = '/' + item.Id;
                        preparedRec.selected = false;
                    }
                    if (item.Name !== null && item.Name !== undefined) {
                        preparedRec.Name = item.Name;
                    }
                    if (item.Project__c !== null && item.Project__c !== undefined) {
                        preparedRec.Project__c = item.Project__c;
                        preparedRec.ProjectName = item.Project__r.Name;
                    }
                    if (item.Unit_Code__c !== null && item.Unit_Code__c !== undefined) {
                        preparedRec.Unit_Code__c = item.Unit_Code__c;
                    }
                    if (item.No_of_Bedrooms__c !== null && item.No_of_Bedrooms__c !== undefined) {
                        preparedRec.No_of_Bedrooms__c = item.No_of_Bedrooms__c;
                    }
                    if (item.Unit_space_Type__c !== null && item.Unit_space_Type__c !== undefined) {
                        preparedRec.Unit_space_Type__c = item.Unit_space_Type__c;
                    }
                    if (item.Unit_type__c !== null && item.Unit_type__c !== undefined) {
                        preparedRec.Unit_type__c = item.Unit_type__c;
                    }
                    if (item.Building__c !== null && item.Building__c !== undefined) {
                        preparedRec.Building__c = item.Building__c;
                        preparedRec.BuildingName = item.Building__r.Name;
                    }
                    if (item.Floor__c !== null && item.Floor__c !== undefined) {
                        preparedRec.Floor__c = item.Floor__c;
                        preparedRec.FloorName = item.Floor__r.Name;
                    }
                    if (item.Unit_Status__c !== null && item.Unit_Status__c !== undefined) {
                        preparedRec.Unit_Status__c = item.Unit_Status__c;
                    }
                    if (item.Leasing_Property_Type__c !== null && item.Leasing_Property_Type__c !== undefined) {
                        preparedRec.Leasing_Property_Type__c = item.Leasing_Property_Type__c;
                    }
                    if (item.Base_Rent__c !== null && item.Base_Rent__c !== undefined) {
                        preparedRec.Base_Rent__c = item.Base_Rent__c;
                    }
                    if (item.Security_Deposit__c !== null && item.Security_Deposit__c !== undefined) {
                        preparedRec.Security_Deposit__c = item.Security_Deposit__c;
                    }
                    if (item.Total_Leasable_Area__c !== null && item.Total_Leasable_Area__c !== undefined) {
                        preparedRec.Total_Leasable_Area__c = item.Total_Leasable_Area__c;
                    }
                    preparedArr.push(preparedRec);
                });

                this.selectAllUnits = false;
                if(preparedArr.length > 0){
                    this.showUnitTable = true;
                    this.unitsDataAll = preparedArr;
                    this.resetPagination();
                }
                else{                    
                    this.showUnitTable = false;
                    this.unitsDataAll = [];
                    this.unitTableData = [];
                }
            }                
            this.isLoading = false;
        }).catch(error => {
            console.log(error);
        });
    }

    handleSelectFlagAll(event){
        this.selectAllUnits = event.detail.checked;
        this.unitsDataAll.forEach(function (item) {
            if(event.detail.checked){
                item.selected = true;
            }
            else{
                item.selected = false;
            }
        });
        this.unitTableData = [];
        this.tableData = this.unitsDataAll;
        for (var i = this.startIndex; i < this.endIndex; i++) {
            this.unitTableData.push(this.tableData[i]);
        }
    }

    handleSelectFlag(event){
        let rowId = event.target.value;
        this.unitsDataAll.forEach(function (item) {
            if(item.Id == rowId){
                if(event.detail.checked){
                    item.selected = true;
                }
                else{                    
                    item.selected = false;
                }
            }
        });
        this.updateUnitTableDetails();
    }

    addToBucketMethod(event) {
        this.selectedEmailAddresses = [];
        this.emailValue = '';
        this.showEmailList = false;

        let tempBucketTableData = [];
        let tempUnitsDataAll = [];

        this.unitsDataAll.forEach(item => {
            if(item.selected){                
                tempBucketTableData.push(item);
            }
            else{
                tempUnitsDataAll.push(item);
            }
        });
        this.unitsDataAll = tempUnitsDataAll;        
        this.resetPagination();
        
        this.bucketTableData = this.bucketTableData.concat(tempBucketTableData);

        this.bucketTableData = this.bucketTableData.filter((obj, index, self) =>
            index === self.findIndex((el) => (
                el['Id'] === obj['Id']
            ))
        );        
        this.bucketTableData.sort((a,b) => (a.Name > b.Name) ? 1 : ((b.Name > a.Name) ? -1 : 0));

        if (this.unitsDataAll.length == 0) {
            this.selectAllUnits = false;
        }
        
        if(this.bucketTableData.length > 0){
            this.showBucketTable = true;
        }
    }

    selectedRowsFromBucket(event) {
        if (event.detail.action.name == 'delete') {
            let rowId = event.detail.row.Id;
            let tempBucketData = [];
            let tempUnitsData = [];

            this.bucketTableData.forEach(function (item) {
                if (item.Id != rowId) {
                    tempBucketData.push(item);
                }
                else{          
                    item.selected = false;          
                    tempUnitsData.push(item);
                }
            });

            this.unitsDataAll = this.unitsDataAll.concat(tempUnitsData);

            this.unitsDataAll = this.unitsDataAll.filter((obj, index, self) =>
                index === self.findIndex((el) => (
                    el['Id'] === obj['Id']
                ))
            );

            this.bucketTableData = tempBucketData;
            this.unitsDataAll.sort((a,b) => (a.Name > b.Name) ? 1 : ((b.Name > a.Name) ? -1 : 0));
            this.resetPagination();
            this.updateUnitTableDetails();

            if (this.bucketTableData.length == 0) {
                this.showBucketTable = false;
            }
        }
    }

    updateUnitTableDetails(){
        let selectAllTRUE = true;
        this.unitsDataAll.forEach(function (item) {
            if(!item.selected){
                selectAllTRUE = false;
                return;
            }
        });
        this.selectAllUnits = selectAllTRUE;
    }

    handleLeaseStartDateChange(event){
        const isInputsCorrect = [...this.template.querySelectorAll('.leaseStartDate')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (isInputsCorrect) {
            this.leaseStartDate = event.detail.value;
            this.disbleGenerateBooking = false;
        }
        else {
            this.disbleGenerateBooking = true;
        }


    }

    //This method is used to generate Booking For Selected Units
    generateBooking(event) {                
        this.isLoading = true;
        let newArray = [];
        this.bucketTableData.forEach(item => {
            newArray = [...newArray, item];
        });

        generateBookingForSelectedUnits({ strUnitDetails: JSON.stringify(newArray), projectId: this.selectedProject, strLeasingType: this.value, strLeaseStartDate: this.leaseStartDate }).then(result => {
            if (result != null && !result.includes("Error")) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        objectApiName: 'Opportunity',
                        actionName: 'view'
                    }
                });
            }
            else {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: result,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }                
            this.isLoading = false;
            this.isGenerateBookingModalOpen = false;
        });
    }

    generateLeaseOffer(event) {
        this.isGenerateLeaseOfferModalOpen = true;
    }

    closeGenerateLeaseOfferModal() {
        this.isGenerateLeaseOfferModalOpen = false;
    }

    generateBookingModal() {
        
        let setProjectId = new Set();
        this.bucketTableData.forEach(item => {
            setProjectId.add(item.Project__c);
        });
        if(setProjectId.size > 1){    
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please add Units from Same Project.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
        else{                   
            this.isGenerateBookingModalOpen = true;
        }
    }

    closeGenerateBookingModal() {
        this.isGenerateBookingModalOpen = false;
    }


    emailValueKeyPress(event) {
        if (event.keyCode == 13 && !this.hideAddButton) {
            this.addEmail();
        }
    }

    emailValueChange(event) {
        const isInputsCorrect = [...this.template.querySelectorAll('.validEmailValue')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (isInputsCorrect) {
            this.emailValue = event.target.value;
            this.hideAddButton = false;
        }
        else {
            this.hideAddButton = true;
        }
    }

    addEmail() {
        this.selectedEmailAddresses.push(this.emailValue);
        this.emailValue = '';
        this.hideAddButton = true;
        if (this.selectedEmailAddresses.length > 0) {
            this.showEmailList = true;
        }
        else {
            this.showEmailList = false;
        }
    }

    removeEmail(event) {
        let removeIndex = event.target.name;
        let tempSelectedEmailAddresses = this.selectedEmailAddresses;
        tempSelectedEmailAddresses.splice(removeIndex, 1);
        this.selectedEmailAddresses = tempSelectedEmailAddresses;

        if (this.selectedEmailAddresses.length > 0) {
            this.showEmailList = true;
        }
        else {
            this.showEmailList = false;
        }
    }

    sendEmail() {                
        this.isLoading = true;
        createLeaseOfferRecords({ strSelectedUnitDetails: JSON.stringify(this.bucketTableData), strSelectedEmails: JSON.stringify(this.selectedEmailAddresses) }).then(result => {
            if (result == 'success') {
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Lease Offer generated succesfully.',
                    variant: 'success',
                });
                this.dispatchEvent(evt);

                this.isGenerateLeaseOfferModalOpen = false;
                this.selectedEmailAddresses = [];
                this.emailValue = '';
                this.hideAddButton = true;
                this.showEmailList = false;
            }
            else {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: result,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }                
            this.isLoading = false;
        });
    }

    clearFilterMethod(){       
        this.clusterPicklist = [{ value: '', label: 'All' }];
        this.buildingPicklist = [{ value: '', label: 'All' }];
        this.floorPicklist = [{ value: '', label: 'All' }]; 
        this.selectedProject = this.projectPicklistValues[0].value;
        this.handleProjectChange();
        this.selectedBedroom = '';
        this.selectedUnitType = '';
        this.selectedPropertyType = '';
        this.selectedCluster = '';
        this.selectedBuilding = '';
        this.selectedFloor = '';
        //this.selectedStatus = '';
        this.disableClusterPicklist = true;
        this.disableBuildingPicklist = true;
        this.disableFloorPicklist = true;
        this.showUnitTable = false;
        this.bucketTableData = [];
        this.showBucketTable = false;
        this.selectAllUnits = false;
        this.unitsDataAll = [];
    }

    clearBucketMethod(){
        this.showBucketTable = false;
        this.selectAllUnits = false;

        let tempUnitsData = [];
        this.bucketTableData.forEach(function (item) {
            item.selected = false;          
            tempUnitsData.push(item);
        });
        this.unitsDataAll = this.unitsDataAll.concat(tempUnitsData);

        this.unitsDataAll = this.unitsDataAll.filter((obj, index, self) =>
            index === self.findIndex((el) => (
                el['Id'] === obj['Id']
            ))
        );
        this.unitsDataAll.sort((a,b) => (a.Name > b.Name) ? 1 : ((b.Name > a.Name) ? -1 : 0));

        this.resetPagination();
        
        this.bucketTableData = [];
    }

    resetPagination() {
        this.unitTableData = [];
        this.totalRecordsCount = this.unitsDataAll.length;
        this.tableData = this.unitsDataAll;

        this.startIndex = 0;
        this.endIndex = this.startIndex + this.pageSize;

        if (this.startIndex <= 0) {
            this.startIndex = 0;
        }

        if (this.endIndex >= this.totalRecordsCount) {
            this.endIndex = this.totalRecordsCount; 
        }

        for (var i = this.startIndex; i < this.endIndex; i++) {
            this.unitTableData.push(this.tableData[i]);
        }

        this.totalPagesCount = Math.ceil(this.totalRecordsCount / this.pageSize);

        if(this.totalPagesCount == 0){
            this.currentPage = 0;
        }

        this.currentPage = 1;
        this.disablePrevious = true;

        if (this.currentPage >= this.totalPagesCount) {
            this.disableNext = true;
        }
        else {
            this.disableNext = false;
        }
    }

    pgPreviousMethod() {  
        this.currentPage--;
        this.startIndex = this.startIndex - this.pageSize;
        this.endIndex = this.startIndex + this.pageSize;
        
        this.previousNextHandler();
    }

    pgNextMethod() {    
        this.currentPage++;
        this.startIndex = this.startIndex + this.pageSize;
        this.endIndex = this.endIndex + this.pageSize;

        this.previousNextHandler();
    }

    previousNextHandler(){
        this.unitTableData = [];
        this.tableData = this.unitsDataAll;

        if (this.startIndex <= 0) {
            this.startIndex = 0;
        }

        if (this.endIndex >= this.totalRecordsCount) {
            this.endIndex = this.totalRecordsCount;
        }

        if(this.startIndex == 0){
            this.disablePrevious = true;
        }
        else{
            this.disablePrevious = false;
        }
        if (this.currentPage >= this.totalPagesCount) {
            this.disableNext = true;
        }
        else {
            this.disableNext = false;
        }

        for (var i = this.startIndex; i < this.endIndex; i++) {
            this.unitTableData.push(this.tableData[i]);
        }
    }
}