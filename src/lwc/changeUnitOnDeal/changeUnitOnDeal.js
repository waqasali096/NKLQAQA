import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi'; 
import PROJECT_FIELD from '@salesforce/schema/Opportunity.Project__c';
import LEASING_TYPE_FIELD from '@salesforce/schema/Opportunity.Leasing_Type__c';
import OPPTY_LEASE_END_DATE_FIELD from '@salesforce/schema/Opportunity.Lease_End_Date__c';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import clusterPicklistValues from '@salesforce/apex/changeUnitOnDealController.clusterPicklistValues'
import buildingPicklistValues from '@salesforce/apex/changeUnitOnDealController.buildingPicklistValues'
import floorPicklistValues from '@salesforce/apex/changeUnitOnDealController.floorPicklistValues'
import fetchUnits from '@salesforce/apex/changeUnitOnDealController.fetchUnits'
import createCaseRecord from '@salesforce/apex/changeUnitOnDealController.createCaseRecord'

import fetchChangeUnitSetting from '@salesforce/apex/changeUnitOnDealController.fetchChangeUnitSetting'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import UNIT_OBJECT from '@salesforce/schema/Unit__c';

import modal from '@salesforce/resourceUrl/modal_changUnit';
import { loadStyle } from 'lightning/platformResourceLoader';
import { CloseActionScreenEvent } from 'lightning/actions';


const fields = [PROJECT_FIELD, OPPTY_LEASE_END_DATE_FIELD, LEASING_TYPE_FIELD];
export default class ChangeUnitOnDeal extends NavigationMixin(LightningElement) {
    @api recordId;
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
    leaseEndDate;
    activeTab = 'detailsTab';
    @track opportunity;
    @track error;    
    @track changeUnitReason = '';
    @track whentoChangeUnit = '';
    @track isDuringLease = false;
    @track newTenantValue = '';
    preferredLeaseStartDate;
    disableContinue = true;
    disableSelectAllFlag = false;
    
    @wire(getRecord, { recordId: '$recordId', fields })
    wiredOpps({ error, data }) {
        if (error) {
            this.error = error;
            this.opportunity = undefined;
        } else if (data) {
            this.opportunity = data;
            this.error = undefined;
            this.selectedProject = this.projectValue;
            this.leaseEndDate = this.opptyLeaseEndDate;

            if (this.opptyleasingTypeValue == 'Residential Units') {
                this.showResidentialFilter = true;
                this.showCommercialFilter = false;
                this.selectedLeasingType = 'Residential Unit';
                this.disableSelectAllFlag = true;
            }

            if (this.opptyleasingTypeValue == 'Commercial Units') {
                this.showResidentialFilter = false;
                this.showCommercialFilter = true;
                this.selectedLeasingType = 'Commercial Unit';
                this.disableSelectAllFlag = false;
            }

            this.handleProjectChange();
        }
    }

    get projectValue() {
        return getFieldValue(this.opportunity, PROJECT_FIELD);
    }

    get opptyLeaseEndDate() {
        return getFieldValue(this.opportunity, OPPTY_LEASE_END_DATE_FIELD);
    }

    get opptyleasingTypeValue() {
        return getFieldValue(this.opportunity, LEASING_TYPE_FIELD);
    }

    residentialBucketColumns = [
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
        return [{ label: 'Residential Units', value: 'residential' },
        { label: 'Commercial Units', value: 'commercial' }];
    }

    connectedCallback() {
        this.isLoading = true;
        this.bucketTableColumns = this.residentialBucketColumns;
        var today = new Date();
        this.leaseStartDate = today.toISOString();
        this.isLoading = false;
        Promise.all([
            loadStyle(this, modal)
        ])
    }

    @wire(getObjectInfo, { objectApiName: UNIT_OBJECT }) unitMetadata;

    @wire(fetchChangeUnitSetting)
    wiredRecs(value) {
        const { data, error } = value;
        if (data) {
            this.pageSize = data[0].Unit_Table_Page_Size__c;
            this.leasingRecordTypeId = data[0].Unit_Object_Leasing_Record_Type_Id__c;
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: UNIT_OBJECT, recordTypeId: "$leasingRecordTypeId" })
    leasingTypePicklistValues({ error, data }) {
        if (data) {
            let leasingTypeOptions = [{ label: 'All', value: '' }];

            data.picklistFieldValues.Leasing_Type__c.values.forEach(key => {
                leasingTypeOptions.push({
                    label: key.label,
                    value: key.value
                })
            });
            this.controllingValues = leasingTypeOptions;

            let leasingTypeValue = '';
            if (this.opptyleasingTypeValue == 'Residential Units') {
                // leasingTypeValue = 'Residential Leasing Unit';
                leasingTypeValue = 'Residential Unit';
            }

            if (this.opptyleasingTypeValue == 'Commercial Units') {
                // leasingTypeValue = 'Residential Leasing Shop';
                leasingTypeValue = 'Commercial Unit';
            }

            //No of Bedroom values (No_of_Bedrooms__c)
            let bedroomOptions = [{ label: 'All', value: '' }];
            let bedroomPicklistValues = data.picklistFieldValues.No_of_Bedrooms__c.values;
            bedroomPicklistValues.forEach(conValues => {
                bedroomOptions.push({
                    label: conValues.label,
                    value: conValues.value
                });
            });
            this.bedroomPicklist = bedroomOptions;

            //Unit Type values (Unit_space_Type__c)
            let unitTypeOptions = [{ label: 'All', value: '' }];
            this.controlUnitTypeValues = data.picklistFieldValues.Unit_space_Type__c.controllerValues;
            this.totalDependentUnitTypeValues = data.picklistFieldValues.Unit_space_Type__c.values;
            this.totalDependentUnitTypeValues.forEach(conValues => {
                if (conValues.validFor[0] === this.controlUnitTypeValues[leasingTypeValue]) {
                    unitTypeOptions.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            });
            
            this.unitTypePicklist = unitTypeOptions;
            //Property Type values (Leasing_Property_Type__c)
            let propertyTypeOptions = [{ label: 'All', value: '' }];
            this.controlPropertyTypeValues = data.picklistFieldValues.Leasing_Property_Type__c.controllerValues;
            this.totalDependentPropertyTypeValues = data.picklistFieldValues.Leasing_Property_Type__c.values;

            this.totalDependentPropertyTypeValues.forEach(conValues => {
                if (conValues.validFor[0] === this.controlPropertyTypeValues[leasingTypeValue]) {
                    propertyTypeOptions.push({
                        label: conValues.label,
                        value: conValues.value
                    })
                }
            });
            this.propertyTypePicklist = propertyTypeOptions;
        }
        else if (error) {
            console.log('Error => ' + JSON.stringify(error));
        }
    }

    handleDateChange(event){
        this.preferredLeaseStartDate = event.detail.value;
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
        clusterPicklistValues({ projectId: this.selectedProject }).then(result => {
            if (result.length > 0) {
                this.disableClusterPicklist = false;
                result.map(item => {
                    this.clusterPicklist = [...this.clusterPicklist, { value: item.Id, label: item.Name }];
                });
            }
            else {
                this.disableClusterPicklist = true;
            }
            this.isLoading = false;
        });

        buildingPicklistValues({ projectId: this.selectedProject }).then(result => {
            if (result.length > 0) {
                this.disableBuildingPicklist = false;
                result.map(item => {
                    this.buildingPicklist = [...this.buildingPicklist, { value: item.Id, label: item.Name }];
                })
            }
            else {
                this.disableBuildingPicklist = true;
            }
            this.isLoading = false;
        });
    }

    bedroomChange(event) {
        this.selectedBedroom = event.detail.value;
    }

    unitTypeChange(event) {
        this.selectedUnitType = event.detail.value;
    }

    propertyTypeChange(event) {
        this.selectedPropertyType = event.detail.value;
    }

    clusterChange(event) {
        this.selectedCluster = event.detail.value;
        this.handleClusterChange();
    }

    handleClusterChange() {
        this.isLoading = true;
        this.buildingPicklist = [{ value: '', label: 'All' }];
        this.floorPicklist = [{ value: '', label: 'All' }];
        this.selectedBuilding = '';
        this.selectedFloor = '';
        this.disableBuildingPicklist = true;
        this.disableFloorPicklist = true;

        buildingPicklistValues({ projectId: this.selectedProject, clusterId: this.selectedCluster }).then(result => {
            if (result.length > 0) {
                this.disableBuildingPicklist = false;
                result.map(item => {
                    this.buildingPicklist = [...this.buildingPicklist, { value: item.Id, label: item.Name }];
                })
            }
            else {
                this.disableBuildingPicklist = true;
            }
            this.isLoading = false;
        });
    }

    buildingChange(event) {
        this.selectedBuilding = event.detail.value;
        this.handleBuildingChange();
    }

    handleBuildingChange() {
        this.isLoading = true;
        this.floorPicklist = [{ value: '', label: 'All' }];
        this.selectedFloor = '';
        this.disableFloorPicklist = true;

        floorPicklistValues({ projectId: this.selectedProject, clusterId: this.selectedCluster, buildingId: this.selectedBuilding }).then(result => {
            if (result.length > 0) {
                this.disableFloorPicklist = false;
                result.map(item => {
                    this.floorPicklist = [...this.floorPicklist, { value: item.Id, label: item.Name }];
                })
            }
            else {
                this.disableFloorPicklist = true;
            }
            this.isLoading = false;
        });
    }

    floorChange(event) {
        this.selectedFloor = event.detail.value;
    }

    /*statusChange(event) {
        this.selectedStatus = event.detail.value;
    }*/

    searchUnits() {
        this.isLoading = true;
        fetchUnits({ leasingType: this.selectedLeasingType, projId: this.selectedProject, bedroom: this.selectedBedroom, unitSpaceType: this.selectedUnitType, propertyType: this.selectedPropertyType, cluster: this.selectedCluster, building: this.selectedBuilding, floor: this.selectedFloor }).then(result => {
            console.log('result', result);

            if (result) {
                let preparedArr = [];
                result.forEach(item => {
                    let preparedRec = {};

                    if (item.Id !== null && item.Id !== undefined) {
                        preparedRec.Id = item.Id;
                        preparedRec.linkName = '/' + item.Id;
                        preparedRec.selected = false;
                        preparedRec.strLocationCode = item.Unit_Code__c;
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
                if (preparedArr.length > 0) {
                    this.showUnitTable = true;
                    this.unitsDataAll = preparedArr;
                    this.resetPagination();
                }
                else {
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

    handleSelectFlagAll(event) {
        this.selectAllUnits = event.detail.checked;
        this.disableContinue = true;
        let selectedRowCount = 0;
        this.unitsDataAll.forEach(function (item) {
            if (event.detail.checked) {
                item.selected = true;
                selectedRowCount++;
            }
            else {
                item.selected = false;
            }
        });

        if(selectedRowCount > 0){
            this.disableContinue = false;
        }

        this.unitTableData = [];
        this.tableData = this.unitsDataAll;
        for (var i = this.startIndex; i < this.endIndex; i++) {
            this.unitTableData.push(this.tableData[i]);
        }
    }

    handleSelectFlag(event) {
        let rowId = event.target.value;
        this.disableContinue = true;
        let selectedRowCount = 0;

        if (this.opptyleasingTypeValue == 'Residential Units') {
            this.unitsDataAll.forEach(function (item) {
                if (item.Id == rowId) {
                    if (event.detail.checked) {
                        item.selected = true;
                        selectedRowCount++;
                    }
                    else {
                        item.selected = false;
                    }
                }
                else{
                    item.selected = false;
                }
            });
        }

        if (this.opptyleasingTypeValue == 'Commercial Units') {
            this.unitsDataAll.forEach(function (item) {
                if (item.Id == rowId) {
                    if (event.detail.checked) {
                        item.selected = true;
                        selectedRowCount++;
                    }
                    else {
                        item.selected = false;
                    }
                }
            });
        }

        

        if(selectedRowCount > 0){
            this.disableContinue = false;
        }
        
        this.updateUnitTableDetails();
    }

    
    updateUnitTableDetails() {
        let selectAllTRUE = true;
        this.unitsDataAll.forEach(function (item) {
            if (!item.selected) {
                selectAllTRUE = false;
                return;
            }
        });
        this.selectAllUnits = selectAllTRUE;
    }

    clearFilterMethod() {
        this.clusterPicklist = [{ value: '', label: 'All' }];
        this.buildingPicklist = [{ value: '', label: 'All' }];
        this.floorPicklist = [{ value: '', label: 'All' }];
        this.selectedProject = this.projectValue;
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

        if (this.totalPagesCount == 0) {
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

    previousNextHandler() {
        this.unitTableData = [];
        this.tableData = this.unitsDataAll;

        if (this.startIndex <= 0) {
            this.startIndex = 0;
        }

        if (this.endIndex >= this.totalRecordsCount) {
            this.endIndex = this.totalRecordsCount;
        }

        if (this.startIndex == 0) {
            this.disablePrevious = true;
        }
        else {
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

    changeTabHandler(event) {
        this.activeTab = event.target.value;
    }

    goNextChangeUnitTab() {
        this.activeTab = 'changeUnit';
    }

    get whenToChangeoptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'During Lease', value: 'During Lease' },
            { label: 'End of Lease', value: 'End of Lease' },
        ];
    }

    get newTenantOptions() {
        return [
            { label: '--None--', value: '' },
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    whentochangehandleChange(event) {
        this.whentoChangeUnit = event.detail.value;
        this.isDuringLease = false;
        if (this.whentoChangeUnit == 'During Lease') {
            this.isDuringLease = true;
        }
    }

    handlechangeUnitReason(event) {
        this.changeUnitReason = event.detail.value;
    }

    newTenantHandleChange(event) {
        this.newTenantValue = event.detail.value;
    }

    handleSaveUnitChange() {
        this.isLoading = true;
        var today = new Date(); 
        if (this.isDuringLease && (this.changeUnitReason == undefined || this.changeUnitReason == '')) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please Enter reason.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
        } 
        else if (this.isDuringLease && (this.preferredLeaseStartDate == undefined || this.preferredLeaseStartDate == '')) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please Enter Preferred Lease Start Date.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
        }
        else if (this.isDuringLease && (this.preferredLeaseStartDate != undefined && this.preferredLeaseStartDate != '' && this.preferredLeaseStartDate < today.toISOString().slice(0, 10))) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Preferred Lease Start Date cannot be in past.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
        } 
        else if (this.isDuringLease && (this.preferredLeaseStartDate != undefined && this.preferredLeaseStartDate != '' && this.preferredLeaseStartDate > this.leaseEndDate)) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Preferred Lease Start Date should not later than Deal Lease end date',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.isLoading = false;
        } 
        else {
            createCaseRecord({ oppId: this.recordId, strChangeUnit: this.whentoChangeUnit, strReason: this.changeUnitReason, strNewTenant: this.newTenantValue, strUnitDetails: JSON.stringify(this.unitsDataAll), dtPreferredLeaseStartDate: this.preferredLeaseStartDate }).then(result => {
                if (result != null && !result.includes("Error")) {
                    if (this.whentoChangeUnit == 'During Lease') {
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: 'Case generated succesfully.',
                            variant: 'success',
                        });
                        this.dispatchEvent(evt);

                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: result,
                                objectApiName: 'Case',
                                actionName: 'view'
                            }
                        });
                    }

                    if (this.whentoChangeUnit == 'End of Lease') {

                        this.dispatchEvent(new CloseActionScreenEvent());

                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.recordId,
                                objectApiName: 'Opportunity',
                                actionName: 'view'
                            }
                        });
                    }

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

    }

    handleCloseQuickAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}