import {
    LightningElement,
    track,
    wire
} from 'lwc';
import {
    getPicklistValues,
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import {
    getRecord,
    getFieldValue
} from 'lightning/uiRecordApi';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import UNIT_OBJECT from '@salesforce/schema/Unit__c';
import SPACE_TYPE_FIELD from '@salesforce/schema/Unit__c.Space_Type__c';
import BEDROOM_FIELD from '@salesforce/schema/Unit__c.No_of_Bedrooms__c';
import UNIT_STATUS_FIELD from '@salesforce/schema/Unit__c.Unit_Status__c';
import BLOCKED_FIELD from '@salesforce/schema/Unit__c.Blocked_Status__c';
// import SPACE_TYPE_FIELD from '@salesforce/schema/Unit__c.Space_Type_Name__c';

import getBUList from '@salesforce/apex/salesEventTabController.getMasterCommunityRecords';
import getProjectList from '@salesforce/apex/salesEventTabController.getProjectRecords';
import getSpaceTypeList from '@salesforce/apex/salesEventTabController.getSpaceTypeList';
import getBuildingList from '@salesforce/apex/salesEventTabController.getBuildingRecords';
import getProjectFromBu from '@salesforce/apex/salesEventTabController.getProjectFromBU';
import getBuildingFromProjectOrBU from '@salesforce/apex/salesEventTabController.getBuildingFromProjectOrBU';
import getUnitsOnSearch from '@salesforce/apex/salesEventTabController.getUnitsOnSearchUnit';
import updateSelectedUnits from '@salesforce/apex/salesEventTabController.updateSelectedUnits';
import getRecentlyUploadedUnits from '@salesforce/apex/salesEventTabController.getRecentlyUploadedUnits';
import getActiveSalesEvent from '@salesforce/apex/salesEventTabController.getActiveSalesEvent';
import createSalesEventUnitRecord from '@salesforce/apex/salesEventTabController.createSalesEventUnitRecord';
import getActiveSpecialOffer from '@salesforce/apex/salesEventTabController.getActiveSpecialOffer';
import getAmenities from '@salesforce/apex/salesEventTabController.getAmenities';
import submitUnitsForInventoryApproval from '@salesforce/apex/salesEventTabController.submitUnitsForInventoryApproval';
import createSpecialOfferItem from '@salesforce/apex/salesEventTabController.createSpecialOfferItem';
import addAmenitiestoUnit from '@salesforce/apex/salesEventTabController.addAmenitiestoUnit';
import getProfileInfo from '@salesforce/apex/salesEventTabController.getProfileInfo';
import createUnitOptions from '@salesforce/apex/salesEventTabController.createUnitOptions';
import checkUnitInApprovalLineItem from '@salesforce/apex/salesEventTabController.checkUnitInApprovalLineItem';
import getUnitOptionsAndMasterOptionData from '@salesforce/apex/salesEventTabController.getUnitOptionsAndMasterOptionData';
import createUnitOptionsData from '@salesforce/apex/salesEventTabController.createUnitOptionsData';
import updateReadyForInspectiononUnit from '@salesforce/apex/salesEventTabController.updateReadyForInspectiononUnit';
import retriveUnits from '@salesforce/apex/salesEventTabController.retriveUnits';
import createSalesOffer from '@salesforce/apex/salesEventTabController.createSalesOffer';
import {
    loadStyle
} from "lightning/platformResourceLoader";
import WrappedHeaderTable from "@salesforce/resourceUrl/WrappedHeaderTable";
import {
    refreshApex
} from '@salesforce/apex';

const columns = [{
        label: 'Location Code',
        fieldName: 'linkName',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Unit_Code__c'
            },
            target: '_blank'
        }
    },

    {
        label: 'Project',
        fieldName: 'ProjectName'
    },
    {
        label: 'Building',
        fieldName: 'BuildingName'
    },
    {
        label: 'Status',
        fieldName: 'Unit_Status__c'
    },
    {
        label: 'Bedrooms',
        fieldName: 'spaceType'
    },
    {
        label: 'Unit Price',
        fieldName: 'Total_Selling_Price__c'
    },
    {
        label: 'Theme',
        fieldName: 'unitTheme'
    },
    {
        label: 'BUA',
        fieldName: 'BuiltUpArea'
    },
    {
        label: 'Total Area',
        fieldName: 'TotalArea'
    },
    {
        label: 'Plot Area',
        fieldName: 'FinalPlotArea'
    },
    {
        label: 'Blocked Status',
        fieldName: 'BlockedStatus'
    },
    {
        label: 'Blocked Sub Status',
        fieldName: 'Blocked_Sub_status__c'
    },
    {
        label: 'Blocked By',
        fieldName: 'Blocked_By__c'
    },
    {
        label: 'Uploaded Date',
        fieldName: 'CreatedDate',
        type: 'date',
        typeAttributes: {
            day: 'numeric',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: true
        },
        sortable: false
    },
    {
        label: 'Uploaded By',
        fieldName: 'CreatedBy'
    },
    {
        label: 'Sales Event',
        fieldName: 'Sales_Event_Name__c'
    },
    {
        label: 'Details ',
        type: "button",
        typeAttributes: {
            label: 'Details ',
            name: 'View ',
            title: 'View ',
            disabled: false,
            value: 'View ',
            iconPosition: 'center'
        },
        cellAttributes: {
            class: {
                fieldName: 'buttonSize'
            }
        }
    },

];
const excelColumns = [{
        label: "Unit Code",
        fieldName: "Unit_Code__c",
        type: "text"
    },
    {
        label: "New Selling Price",
        fieldName: "UnitPrice",
        type: "Decimal"
    },
    {
        label: "Current Selling Price",
        fieldName: "Selling_Price__c",
        type: "Decimal"
    },
    {
        label: "Status",
        fieldName: "Unit_Status__c",
        type: "text"
    },
    {
        label: "Project Name",
        fieldName: "ProjectName",
        type: "text"
    },

];
const projectColumns = [{
        label: 'Location Code',
        fieldName: 'linkName',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Unit_Code__c'
            },
            target: '_blank'
        }
    },
    {
        label: 'Project',
        fieldName: 'ProjectName'
    },
    {
        label: 'Building',
        fieldName: 'BuildingName'
    },
    {
        label: 'Status',
        fieldName: 'Unit_Status__c'
    },
    {
        label: 'Bedrooms',
        fieldName: 'spaceType'
    },
    {
        label: 'Unit Price',
        fieldName: 'Total_Selling_Price__c'
    },
    {
        label: 'Theme',
        fieldName: 'unitTheme'
    },
    {
        label: 'BUA',
        fieldName: 'BuiltUpArea'
    },
    {
        label: 'Total Area',
        fieldName: 'TotalArea'
    },
    {
        label: 'Plot Area',
        fieldName: 'FinalPlotArea'
    },
    {
        label: 'Blocked Status',
        fieldName: 'BlockedStatus'
    },
    {
        label: 'Blocked Sub Status',
        fieldName: 'Blocked_Sub_status__c'
    },
    {
        label: 'Blocked By',
        fieldName: 'Blocked_By__c'
    },
    {
        label: 'Release Status',
        fieldName: 'Release_Status__c'
    },
    {
        label: 'Handover Status',
        fieldName: 'handoverStatus'
    },
    {
        label: 'Uploaded Date',
        fieldName: 'CreatedDate',
        type: 'date',
        typeAttributes: {
            day: 'numeric',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: true
        },
        sortable: false
    },
    {
        label: 'Uploaded By',
        fieldName: 'CreatedBy'
    },
    {
        label: 'Details ',
        type: "button",
        typeAttributes: {
            label: 'Details ',
            name: 'View ',
            title: 'View ',
            disabled: false,
            value: 'View ',
            iconPosition: 'center'
        },
        cellAttributes: {
            class: {
                fieldName: 'buttonSize'
            }
        }
    },
];
const salesColumns = [{
        label: 'Location Code',
        fieldName: 'linkName',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Unit_Code__c'
            },
            target: '_blank'
        }
    },
    {
        label: 'Project',
        fieldName: 'ProjectName'
    },
    {
        label: 'Building',
        fieldName: 'BuildingName'
    },
    {
        label: 'Status',
        fieldName: 'Unit_Status__c'
    },
    {
        label: 'Bedrooms',
        fieldName: 'spaceType'
    },
    {
        label: 'Unit Price',
        fieldName: 'Total_Selling_Price__c'
    },
    {
        label: 'Theme',
        fieldName: 'unitTheme'
    },
    {
        label: 'BUA',
        fieldName: 'BuiltUpArea'
    },
    {
        label: 'Total Area',
        fieldName: 'TotalArea'
    },
    {
        label: 'Plot Area',
        fieldName: 'FinalPlotArea'
    },
    {
        label: 'Blocked Status',
        fieldName: 'BlockedStatus'
    },
    {
        label: 'Blocked Sub Status',
        fieldName: 'Blocked_Sub_status__c'
    },
    {
        label: 'Blocked By',
        fieldName: 'Blocked_By__c'
    },
    {
        label: 'Sales Event',
        fieldName: 'Sales_Event_Name__c'
    },
    {
        label: 'Details ',
        type: "button",
        typeAttributes: {
            label: 'Details ',
            name: 'View ',
            title: 'View ',
            disabled: false,
            value: 'View ',
            iconPosition: 'center'
        },
        cellAttributes: {
            class: {
                fieldName: 'buttonSize'
            }
        }
    },
];
const inventoryColumns = [{
        label: 'Location Code',
        fieldName: 'linkName',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'Unit_Code__c'
            },
            target: '_blank'
        }
    },
    {
        label: 'Project',
        fieldName: 'ProjectName'
    },
    {
        label: 'Building',
        fieldName: 'BuildingName'
    },
    {
        label: 'Status',
        fieldName: 'Unit_Status__c'
    },
    {
        label: 'Bedrooms',
        fieldName: 'spaceType'
    },
    {
        label: 'Unit Price',
        fieldName: 'Total_Selling_Price__c'
    },
    {
        label: 'Theme',
        fieldName: 'unitTheme'
    },
    {
        label: 'BUA',
        fieldName: 'BuiltUpArea'
    },
    {
        label: 'Total Area',
        fieldName: 'TotalArea'
    },
    {
        label: 'Plot Area',
        fieldName: 'FinalPlotArea'
    },
    {
        label: 'Blocked Status',
        fieldName: 'BlockedStatus'
    },
    {
        label: 'Blocked Sub Status',
        fieldName: 'Blocked_Sub_status__c'
    },
    {
        label: 'Blocked By',
        fieldName: 'Blocked_By__c'
    },
    {
        label: 'Sales Event',
        fieldName: 'Sales_Event_Name__c'
    },
    {
        label: 'Details ',
        type: "button",
        typeAttributes: {
            label: 'Details ',
            name: 'View ',
            title: 'View ',
            disabled: false,
            value: 'View ',
            iconPosition: 'center'
        },
        cellAttributes: {
            class: {
                fieldName: 'buttonSize'
            }
        }
    },
];

export default class SalesEventTab extends LightningElement {
    @track bedroomPicklist = [{
        label: 'None',
        value: ''
    }];
    @track unitStatusPicklist = [{
        label: 'None',
        value: ''
    }];
    @track blockedStatusPicklist = [{
        label: 'None',
        value: ''
    }];
    @track blockedStatusPicklistNEW = [{
        label: 'None',
        value: ''
    }];
    @track buPicklistValues = [{
        label: 'None',
        value: ''
    }];
    @track salesEventPicklistValues = [{
        label: 'None',
        value: ''
    }];
    @track projectPicklistValues = [{
        label: 'None',
        value: ''
    }];
    @track buildingPicklistValues = [{
        label: 'None',
        value: ''
    }];
    @track spaceTypePicklistValues = [{
        label: 'None',
        value: ''
    }];
    //@track salesEventPicklistValues = [];
    @track specialOfferPicklistValues = [];
    @track amenitiesPicklistValues = [];
    @track salesEventStartDate = '';
    @track salesEventEndDate = '';
    @track selectedBU = '';
    @track selectedProject = '';
    @track selectedBuilding = '';
    @track unitData = [];
    @track cartData = [];
    @track basketData = [];
    @track selectedUnitsToAddInBucket = [];
    @track unitBucketData = [];
    @track selectedUnitsToRemoveFromBucket = [];
    @track selectedBaskedUnits = [];
    @track unitUpdateModalFlag = false;
    @track unitUpdateModalSpinnerFlag = false;
    @track salesEventModalFlag = false;
    @track specialOfferModalFlag = false;
    @track availableUnitFlag = false;
    @track amenitiesModalFlag = false;
    @track unitOptionsModalFlag = false;
    @track approvalModalFlag = false;
    @track downloadTemplateModalFlag = false;
    @track inventoryApprovalVisibilityFlag = true;
    @track salesEventVisibilityFlag = true;
    @track specialOfferVisibilityFlag = true;
    @track addAmenitiesVisibilityFlag = true;
    @track updateUnitsVisibilityFlag = true;
    @track initiateHandoverVisibilityFlag = true;
    @track addUnitOptionsVisibilityFlag = true;
    @track downloadTemplateVisibilityFlag = true;
    @track unitUpdateHandoverModal = false;
    @track unitHandoverStatus = 'Ready for Inspection';
    @track unitInspectionTargetDate;
    @track showUnitUpdateHandoverLoader = false;
    @track unsoldFlag = false;
    @track selectedUnitsToAddInBucketTemp = [];
    @track selectedUnitsToRemoveFromCart = [];
    @track selectedSalesEventId = '';
    selectedSalesEventName = '';
    @track selectedSpecialOfferId = '';
    @track selectedApprovalTypeValue = '';
    @track selectedLineOfBusinessValue = '';
    @track selectedCommentValue = '';
    @track selectedUpdateStatus = '';
    @track selectedBlockedStatus = '';
    @track selectedBlockedSubStatus = '';
    @track remarksOnUpdate = '';
    @track selectedBedroom = '';
    @track selectedUnitStatus = '';
    @track selectedSpaceType = '';
    @track selectedRecentlyUploaded = '';
    @track isDisabled = false;
    @track isBlockedReasonDisabled = true;
    @track areDetailsVisible = false;
    @track hasEventSelected = false;
    @track hasValue = false;
    @track cartToggle = false;
    @track masterOptionId = '';
    @track price = 0;
    @track pricebookId = '';
    @track hrefdata;
    @track blockedStatus = [];
    @track blockedSubStatus = [];
    @track addUnitOptionsColumns = [];
    @track addUnitOptionsData = [];
    @track selectedUnitOptionsData;
    @track showMasterOptionsLoading = false;
    @track isDisabledBlocked = true;
    @track isShowUnitDetails = false;
    @track isdisableRecentlyUploaded = true;
    unitRecordId = '';
    tempSalesEventBucket = [];
    tempSpecialOfferBucket = [];
    tempAmenitiesBucket = [];
    tempBucketListForApproval = [];
    selectedAmenityListboxValue = [];
    profileName = '';
    currentUserName = '';
    removeFromCartButtonFlag = false;
    emptyCartButtonFlag = true;
    searchAndResetButtonFlag = true;
    searchUnitByCSVButtonFlag = true;
    removeFromBucketFlag = false;
    addAmenityFlag = false;
    count = 0;
    @track blockedStatusDefault = '';
    @track blockedSubStatusDefault = '';

    @track showCSVUploadBox = false;
    @track unitCodesFromCSV = [];
    @track unitCodeSearch;
    @track disableBlockedReason = true;
    @track dataSpinner = true;
    @track showLoadingApproval = false;
    @track initiateHandoverVisibilityFlag = false;
    @track salesOfferVisibilityFlag = false;
    @track bulkOfferVisibilityFlag = false;
    @track showSalesOfferModel = false;
    @track showBulkOfferModel = false;
    @track salesOfferId = '';

    //defiining variables for searchUnits
    @track searchData;
    @track errorMsg = '';

    // Defining variables for Pagination for search results

    @track page = 1; //this will initialize 1st page
    @track items = []; //it contains all the records.
    @track startingRecord = 1; //start record position per page
    @track endingRecord = 0; //end record position per page
    @track pageSize = 20; //default value we are assigning
    @track totalRecountCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number of page is needed to display all records

    // Defining variables for Pagination for Basket
    @track basketPage = 1; //this will initialize 1st page
    @track basketItems = []; //it contains all the records.
    @track genratePricingTemplate = []; //it contains all the records.
    @track startingBasketRecord = 1; //start record position per page
    @track endingBasketRecord = 0; //end record position per page
    @track totalBasketCount = 0; //total record count received from all retrieved records
    @track totalBasketPage = 0; //total number of page is needed to display all records
    @track isLoading = false;
    stylesLoaded = false;

    columns = columns;
    excelColumns = excelColumns;
    @wire(getObjectInfo, {
        objectApiName: UNIT_OBJECT
    }) unitMetadata;

    @wire(getPicklistValues, {
        recordTypeId: '$unitMetadata.data.defaultRecordTypeId',
        fieldApiName: SPACE_TYPE_FIELD /*BEDROOM_FIELD*/
    }) bedroomPicklistValues({
        error,
        data
    }) {
        if (data) {
            for (let i = 0; i < data.values.length; i++) {
                this.bedroomPicklist = [...this.bedroomPicklist, {
                    value: data.values[i]['value'],
                    label: data.values[i]['label']
                }];
            }
        }
    };

    @wire(getPicklistValues, {
        recordTypeId: '$unitMetadata.data.defaultRecordTypeId',
        fieldApiName: UNIT_STATUS_FIELD
    }) unitStatusPicklist({
        error,
        data
    }) {
        if (data) {
            for (let i = 0; i < data.values.length; i++) {
                this.unitStatusPicklist = [...this.unitStatusPicklist, {
                    value: data.values[i]['value'],
                    label: data.values[i]['label']
                }];
                console.log("values--" + this.unitStatusPicklist);
            }
        }
    };

    @wire(getPicklistValues, {
        recordTypeId: '$unitMetadata.data.defaultRecordTypeId',
        fieldApiName: BLOCKED_FIELD
    }) blockedStatusPicklist({
        error,
        data
    }) {
        if (data) {
            console.log("blocked picklist");
            this.blockedStatusPicklist = [];
            for (let i = 0; i < data.values.length; i++) {
                this.blockedStatusPicklist = [...this.blockedStatusPicklist, {
                    value: data.values[i]['value'],
                    label: data.values[i]['label']
                }];
                console.log("values---" + this.blockedStatusPicklist);
            }

        }
    };

    @wire(getActiveSalesEvent) salesEventPicklistValues({
        error,
        data
    }) {
        console.log("sales event picklist values--");
        if (data) {
            this.tempSalesEventBucket = data;

            data.map(resElement => {
                console.log(resElement);
                this.salesEventPicklistValues = [...this.salesEventPicklistValues, {
                    value: resElement.Id,
                    label: resElement.Name
                }];
            });
        }
    }

    @wire(getActiveSpecialOffer) specialOfferPicklistValues({
        error,
        data
    }) {
        if (data) {
            this.tempSpecialOfferBucket = data;
            console.log('Special Offer Data ', data);
            data.map(resElement => {
                console.log(resElement);
                this.specialOfferPicklistValues = [...this.specialOfferPicklistValues, {
                    value: resElement.Id,
                    label: resElement.Name
                }];
            });
        }
    }

    @wire(getAmenities) amenitiesPicklistValues({
        error,
        data
    }) {
        if (data) {
            this.tempAmenitiesBucket = data;
            data.map(resElement => {
                console.log(resElement);
                this.amenitiesPicklistValues = [...this.amenitiesPicklistValues, {
                    value: resElement.Id,
                    label: resElement.Name
                }];
            });
        }
    }


    get recentlyUploadedUnits() {
        return [{
                label: '24 Hours',
                value: 'day'
            },
            {
                label: '7 days',
                value: 'week'
            },
            {
                label: '30 days',
                value: 'month'
            },
        ];
    }

    get unitStatusPicklistValuesTemp() {
        if (this.profileName == 'Project Executive') {
            return [{
                    label: 'None',
                    value: ''
                },
                {
                    label: 'Restricted',
                    value: 'Restricted'
                },
                {
                    label: 'Blocked',
                    value: 'Blocked'
                },
                {
                    label: 'Sold',
                    value: 'Sold'
                },
            ];
        } else if (this.profileName == 'Inventory Executive') {
            return [{
                    label: 'None',
                    value: ''
                },
                {
                    label: 'Uploaded',
                    value: 'Uploaded'
                },
                {
                    label: 'Available',
                    value: 'Available'
                },
                {
                    label: 'Blocked',
                    value: 'Blocked'
                },
            ];
        } else if (this.profileName == 'Sales Manager' || this.profileName == 'Sales Head') {
            return [{
                    label: 'None',
                    value: ''
                },
                {
                    label: 'Available',
                    value: 'Available'
                },
                {
                    label: 'Blocked',
                    value: 'Blocked'
                },
            ];

        } else {
            console.log("i am in else block--" + this.profileName + "--" + this.role + "---" + this.currentUserName);
            return [{
                    label: 'None',
                    value: ''
                },
                {
                    label: 'Available',
                    value: 'Available'
                },
                {
                    label: 'Blocked',
                    value: 'Blocked'
                },
                {
                    label: 'Uploaded',
                    value: 'Uploaded'
                },
                {
                    label: 'Restricted',
                    value: 'Restricted'
                },
            ];
        }
    }

    get unitStatusPicklistValuesForUpdateOperation() {

        if (this.profileName == 'Inventory Executive') {
            return [{
                    label: 'None',
                    value: ''
                },
                {
                    label: 'Available',
                    value: 'Available'
                },
                {
                    label: 'Blocked',
                    value: 'Blocked'
                },
            ];
        } else if (this.profileName == 'Project Executive') {
            return [{
                    label: 'None',
                    value: ''
                },
                {
                    label: 'Blocked',
                    value: 'Blocked'
                },
                {
                    label: 'Restricted',
                    value: 'Restricted'
                },

            ];
        } else if (this.profileName == 'Sales Manager' || this.profileName == 'Sales Head') {
            return [{
                    label: 'None',
                    value: ''
                },
                {
                    label: 'Available',
                    value: 'Available'
                },
                {
                    label: 'Blocked',
                    value: 'Blocked'
                },
            ];
        } else {
            return [{
                    label: 'None',
                    value: ''
                },
                {
                    label: 'Restricted',
                    value: 'Restricted'
                },
                {
                    label: 'Blocked',
                    value: 'Blocked'
                },
                {
                    label: 'Available',
                    value: 'Available'
                },
                {
                    label: 'Uploaded',
                    value: 'Uploaded'
                },
            ];
        }
    }
    handleChangeCheck(event) {

        if (this.areDetailsVisible == false) {
            this.areDetailsVisible = true;
            this.isDisabled = true;
            this.searchAndResetButtonFlag = false;
            this.searchUnitByCSVButtonFlag = false;
        } else {
            this.searchAndResetButtonFlag = true;
            this.areDetailsVisible = false;
            this.isDisabled = false;
        }
    }
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.currentUserName = data.fields.Name.value;
        }
    }

    connectedCallback() {

        console.log("In rendered callback" + this.currentUserName + "---" + this.profileName);

        getProfileInfo({}).then(result => {
            if (result) {
                this.profileName = result;
                console.log(this.profileName + "---it is" + this.isdisableRecentlyUploaded);
                this.blockedStatusPicklist = [];
                if (this.profileName == 'Sales Manager') {
                    this.columns = salesColumns;
                    this.isdisableRecentlyUploaded = false;
                    console.log("Now i am ---" + this.isdisableRecentlyUploaded);
                }
                if (result == 'Project Executive' || result == 'Project Head' || result == 'Project Manager') {
                    this.columns = projectColumns;
                    this.blockedStatusPicklist = [{
                        label: 'Development',
                        value: 'Development'
                    }];
                } else if (this.profileName == 'Inventory Executive' || this.profileName == 'Inventory Head' || this.profileName == 'Inventory Manager') {
                    this.isdisableRecentlyUploaded = false;
                    this.columns = inventoryColumns;
                    this.blockedStatusPicklist = [];
                    this.blockedStatusPicklist = [{
                            label: 'Sales',
                            value: 'Sales'
                        },
                        {
                            label: 'Customer Care',
                            value: 'Customer Care'
                        },
                        {
                            label: 'Legal',
                            value: 'Legal'
                        },
                        {
                            label: 'Development',
                            value: 'Development'
                        }
                    ];
                } else {
                    this.blockedStatusPicklist = [{
                            label: 'Development',
                            value: 'Development'
                        },
                        {
                            label: 'Customer Care',
                            value: 'Customer Care'
                        },
                        {
                            label: 'Sales',
                            value: 'Sales'
                        },
                        {
                            label: 'Legal',
                            value: 'Legal'
                        }
                    ];
                }
                console.log('==blockedStatusPicklist==' + this.blockedStatusPicklist);
                if (result === 'Project Executive') {
                    this.inventoryApprovalVisibilityFlag = true;
                    this.salesEventVisibilityFlag = false;
                    this.specialOfferVisibilityFlag = false;
                    this.addAmenitiesVisibilityFlag = false;
                    this.updateUnitsVisibilityFlag = true;
                    this.addUnitOptionsVisibilityFlag = true;
                    this.downloadTemplateVisibilityFlag = true;
                    this.initiateHandoverVisibilityFlag = true;
                }
                if (result === 'Inventory Executive') {
                    this.inventoryApprovalVisibilityFlag = false;
                    this.salesEventVisibilityFlag = true;
                    this.specialOfferVisibilityFlag = true;
                    this.addAmenitiesVisibilityFlag = true;
                    this.updateUnitsVisibilityFlag = true;
                    this.addUnitOptionsVisibilityFlag = false;
                    this.downloadTemplateVisibilityFlag = false;
                    this.initiateHandoverVisibilityFlag = false;
                }

                if (result === 'Sales Manager' || this.currentUserName == 'Sales Head') {
                    this.updateUnitsVisibilityFlag = true;
                    this.addUnitOptionsVisibilityFlag = false;
                    this.downloadTemplateVisibilityFlag = false;
                    this.addUnitOptionsVisibilityFlag = false;
                    this.salesEventVisibilityFlag = false;
                    this.specialOfferVisibilityFlag = false;
                    this.inventoryApprovalVisibilityFlag = false;
                    this.initiateHandoverVisibilityFlag = false;
                    this.searchUnitByCSVButtonFlag = false;
                    this.salesOfferVisibilityFlag = true;
                    this.bulkOfferVisibilityFlag = true;
                }

                if (result === 'System Administrator') {
                    this.salesOfferVisibilityFlag = true;
                    this.bulkOfferVisibilityFlag = true;
                    this.initiateHandoverVisibilityFlag = true;
                }
            }
        });
        getBUList({})
            .then(result => {
                if (result.length > 0) {
                    //console.log('Result Map : ',result.map);
                    result.map(resElement => {
                        //console.log(resElement);
                        this.buPicklistValues = [...this.buPicklistValues, {
                            value: resElement.Id,
                            label: resElement.Name
                        }];
                    });
                }
            })
        getSpaceTypeList({})
            .then(result => {
                if (result.length > 0) {
                    console.log('Result Map : ', result.map);
                    result.map(resElement => {
                        console.log(resElement);
                        this.spaceTypePicklistValues = [...this.spaceTypePicklistValues, {
                            value: resElement.Id,
                            label: resElement.Name
                        }];
                    });
                }
            })
        getProjectList({})
            .then(result => {
                console.log('Hello in project');
                if (result.length > 0) {
                    result.map(resElement => {
                        //console.log(resElement);
                        this.projectPicklistValues = [...this.projectPicklistValues, {
                            value: resElement.Id,
                            label: resElement.Name
                        }];
                    });
                }
            });
        getBuildingList({})
            .then(result => {
                console.log('Hello in building');
                if (result.length > 0) {
                    result.map(resElement => {
                        console.log(resElement);
                        this.buildingPicklistValues = [...this.buildingPicklistValues, {
                            value: resElement.Id,
                            label: resElement.Name
                        }];
                    });
                }
            })
            .catch(error => {
                console.log("Something went wrong in building");
            });


    }

    buChange(e) {
        console.log('Yo');
        console.log(e.detail.value);
        this.selectedBU = e.detail.value;
        getProjectFromBu({
            buId: e.detail.value
        }).then(result => {
            this.projectPicklistValues = [];
            if (result.length > 0) {
                result.map(resElement => {
                    this.projectPicklistValues = [...this.projectPicklistValues, {
                        value: resElement.Id,
                        label: resElement.Name
                    }];
                });
            }
        });
        getBuildingFromProjectOrBU({
            buId: e.detail.value
        }).then(result => {
            this.buildingPicklistValues = [];
            if (result.length > 0) {
                result.map(resElement => {
                    this.buildingPicklistValues = [...this.buildingPicklistValues, {
                        value: resElement.Id,
                        label: resElement.Name
                    }];
                });
            }
        });
    }

    projectChange(e) {
        console.log('To To');
        this.selectedProject = e.detail.value;
        console.log(this.selectedProject);
        getBuildingFromProjectOrBU({
            projectId: e.detail.value
        }).then(result => {
            this.buildingPicklistValues = [];
            if (result.length > 0) {
                result.map(resElement => {
                    this.buildingPicklistValues = [...this.buildingPicklistValues, {
                        value: resElement.Id,
                        label: resElement.Name
                    }];
                });
            }
        });
    }

    buildingChange(e) {
        this.selectedBuilding = e.detail.value;
        //console.log(this.selectedBuilding);
    }

    bedroomChange(e) {
        this.selectedBedroom = e.detail.value;
    }

    unitStatusChange(e) {
        this.selectedUnitStatus = e.detail.value;
        console.log("unit status change");
        this.blockedStatusPicklistNEW = [];

        if (this.selectedUnitStatus == '' || this.selectedUnitStatus == 'None' || this.selectedUnitStatus == 'Available' || this.selectedUnitStatus == 'Uploaded' || this.selectedUnitStatus == 'Restricted') {
            this.disableBlockedReason = true;
            this.isBlockedReasonDisabled = true;
            this.selectedBlockedStatus = '';
        } else {
            console.log("==blockedStatusPicklist==" + JSON.stringify(this.blockedStatusPicklist));
            if (this.profileName == 'Sales Manager') {
                this.blockedStatusPicklistNEW = this.blockedStatusPicklist = [...this.blockedStatusPicklistNEW, {
                    value: 'Sales',
                    label: 'Sales'
                }];
            } else if (this.profileName == 'Project Executive' || this.profileName == 'Project Head' || this.profileName == 'Project Manager') {
                this.columns = projectColumns;
                this.blockedStatusPicklistNEW = [{
                    label: 'Development',
                    value: 'Development'
                }];
            } else {
                this.blockedStatusPicklistNEW = [];
                this.blockedStatusPicklistNEW = this.blockedStatusPicklist;
                console.log('@@@@ line 745 in else ');
            }
            this.disableBlockedReason = false;
            this.isBlockedReasonDisabled = false;
        }
    }

    blockedReasonChange(e) {
        this.selectedBlockedStatus = e.detail.value;
    }

    specialOfferChange(e) {
        this.selectedSpecialOfferId = e.target.value;
        for (let i = 0; i < this.tempSpecialOfferBucket.length; i++) {
            if (this.tempSpecialOfferBucket[i].Id == e.target.value) {
                this.hasEventSelected = true;
                this.salesEventStartDate = this.tempSpecialOfferBucket[i].Start_Date__c;
                this.salesEventEndDate = this.tempSpecialOfferBucket[i].End_Date__c;
            }
        }
    }

    amenityChange(e) {

    }

    amenityListboxChange(e) {
        let tempArray = [];
        let tarGETVal = e.target.value;
        tempArray = [...tempArray, ...targetVal];

        console.log('Target Value ' + targetVal);
        console.log('TempArray ', tempArray);

        this.selectedAmenityListboxValue = tempArray;
        if (this.selectedAmenityListboxValue.length > 0) {
            this.addAmenityFlag = true;
        } else {
            this.addAmenityFlag = false;
        }
        console.log('Selectd Amenity Listbox value ', this.selectedAmenityListboxValue);
    }

    salesEventChange(event) {
        console.log("i am inside sales event change");
        this.selectedSalesEventName = '';
        this.selectedSalesEventId = event.target.value;
        this.selectedSalesEventName = event.target.options.find(opt => opt.value === event.detail.value).label;
        console.log('==this.selectedSalesEventName==' + this.selectedSalesEventName);

        for (let i = 0; i < this.tempSalesEventBucket.length; i++) {
            if (this.tempSalesEventBucket[i].Id == event.target.value) {
                this.hasEventSelected = true;
                this.salesEventStartDate = this.tempSalesEventBucket[i].Start_Date__c;
                this.salesEventEndDate = this.tempSalesEventBucket[i].End_Date__c;
            }
        }
    }

    recentlyUploadedChange(e) {
        this.selectedRecentlyUploaded = e.detail.value;
        getRecentlyUploadedUnits({
                timeframe: e.detail.value
            })
            .then(result => {
                console.log('Hello in Recently Uploaded Change');
                if (result) {
                    console.log('Inside result if block');
                    let preparedArr = [];
                    result.forEach(item => {
                        console.log('==item==' + JSON.stringify(item));
                        let preparedRec = {};
                        if (item.Id !== null && item.Id !== undefined) {
                            preparedRec.Id = item.Id;
                            preparedRec.linkName = '/' + item.Id;
                        }
                        if (item.Name !== null && item.Name !== undefined) {
                            preparedRec.Name = item.Name;
                        }
                        preparedRec.No_of_Bedrooms__c = item.No_of_Bedrooms__c;
                        //preparedRec.spaceType = item.Space_Type__c;
                        preparedRec.BuiltUpArea = item.Built_Up_Area__c;
                        preparedRec.Built_Up_Area__c = item.Built_Up_Area__c;
                        preparedRec.TotalArea = item.Total_Area__c;
                        preparedRec.FinalPlotArea = item.Final_Plot_Area__c;
                        preparedRec.DateofUpload = item.CreatedDate;
                        preparedRec.UserWhoUploaded = item.CreatedBy.Name;
                        preparedRec.CreatedDate = item.CreatedDate;
                        preparedRec.CreatedBy = item.CreatedBy.Name;

                        if (item.Project__c !== null && item.Project__c !== undefined) {
                            preparedRec.ProjectName = item.Project__r.Name;
                        }
                        if (item.Building__c !== null && item.Building__c !== undefined) {
                            preparedRec.BuildingName = item.Building__r.Name;
                        }
                        if (item.Master_Community__c !== null && item.Master_Community__c !== undefined) {
                            preparedRec.BusinessName = item.Master_Community__r.Name;
                        }
                        if (item.Unit_Status__c !== null && item.Unit_Status__c !== undefined) {
                            preparedRec.Unit_Status__c = item.Unit_Status__c;
                        }
                        if (item.Space_Types__c !== null && item.Space_Types__c !== undefined) {
                            preparedRec.spaceType = item.Space_Types__r.Name;
                        }
                        if (item.Blocked_By__c !== null && item.Blocked_By__c !== undefined) {
                            preparedRec.Blocked_By__c = item.Blocked_By__r.Name;
                            preparedRec.BlockedByProfile = item.Blocked_By__r.Profile_Name__c;
                        }
                        if (item.Function_Type_Name__c !== null && item.Function_Type_Name__c !== undefined) {
                            preparedRec.Function_Type_Name__c = item.Function_Type_Name__c;
                        }
                        if (item.Unit_Theme_Name__c !== null && item.Unit_Theme_Name__c !== undefined) {
                            preparedRec.unitTheme = item.Unit_Theme_Name__c;
                        }
                        if (item.Selling_Price__c !== null && item.Selling_Price__c !== undefined) {
                            preparedRec.Selling_Price__c = item.Selling_Price__c;
                        }
                        if (item.Unit_Code__c !== null && item.Unit_Code__c !== undefined) {
                            preparedRec.Unit_Code__c = item.Unit_Code__c;
                        }
                        if (item.Total_Selling_Price__c !== null && item.Total_Selling_Price__c !== undefined) {
                            preparedRec.Total_Selling_Price__c = item.Total_Selling_Price__c;
                        }
                        if (item.Total_Selling_Price__c !== null && item.Total_Selling_Price__c !== undefined) {
                            preparedRec.TotalSellingPrice = item.Total_Selling_Price__c;
                        }
                        preparedRec.Release_Status__c = item.Release_Status__c;
                        if (item.Handover_Status__c !== '') {
                            preparedRec.handoverStatus = item.Handover_Status__c;
                        }
                        if (item.Blocked_Status__c !== '' && item.Blocked_Status__c) {
                            preparedRec.BlockedStatus = item.Blocked_Status__c;
                        }
                        // console.log('item.Blocked_Sub_status__c ::' + item.Blocked_Sub_status__c);
                        if (item.Blocked_Sub_status__c !== '') {
                            preparedRec.Blocked_Sub_status__c = item.Blocked_Sub_status__c;
                        }
                        preparedRec.Handover_Status__c = item.Handover_Status__c;


                        preparedArr.push(preparedRec);
                    });


                    this.items = preparedArr;
                    this.totalRecountCount = result.length;
                    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);

                    this.unitData = this.items.slice(0, this.pageSize);
                    this.dataSpinner = false;
                    this.endingRecord = this.pageSize;
                }
            })
            .catch(error => {
                console.log("Something went wrong!" + error);
                console.log("Something went wrong!" + JSON.stringify(error));
            });
        this.template.querySelector('div.unitBucket').classList.add('slds-hide');
        this.template.querySelector('div.unitSearch').classList.remove('slds-hide');
        this.selectedUnitsToAddInBucket = [];
    }

    spaceTypeChange(e) {
        this.selectedSpaceType = e.detail.value;
    }

    resetPicklistValues(event) {
        eval("$A.get('e.force:refreshView').fire();");
        const lwcPicklistFields = this.template.querySelectorAll(
            'lightning-combobox'
        );
        if (lwcPicklistFields) {
            lwcPicklistFields.forEach(each => {
                each.value = undefined;
            });
        }
        this.template.querySelector('div.unitSearch').classList.add('slds-hide');
        this.unitData = [];
    }


    searchUnits(e) {
        // this.dataSpinner = true;
        this.isLoading = true;
        this.unitCodesFromCSV = [];
        this.callSearchUnitFunction();
    }

    handleUnitCodeChange(e) {
        this.unitCodeSearch = e.target.value;
    }

    callSearchUnitFunction() {
        console.log('In search unit block', this.unitCodesFromCSV + "----" + this.currentUserName + "---profile--" + this.Profile);
        if (this.unitCodesFromCSV != undefined && this.unitCodesFromCSV.length > 0) {
            this.selectedBU = '';
            this.selectedProject = '';
            this.selectedBuilding = '';
            this.selectedBedroom = '';
            this.selectedUnitStatus = '';
            this.selectedBlockedStatus = '';
            //this.selectedSpaceType = '';
            this.selectedSalesEventId = '';
        }

        getUnitsOnSearch({
            buId: this.selectedBU,
            projectId: this.selectedProject,
            buildingId: this.selectedBuilding,
            noOfBedrooms: this.selectedBedroom,
            unitStatus: this.selectedUnitStatus,
            blockedStatus: this.selectedBlockedStatus,
            spaceType: this.selectedSpaceType,
            listUnitCodes: this.unitCodesFromCSV,
            salesEvent: this.selectedSalesEventId,
            unitCode: this.unitCodeSearch,
            basketData: this.basketData
        }).then(result => {
            console.log('Got the Result--' + this.currentUserName);
            console.log('basketData--' + JSON.stringify(this.basketData));
            console.log(this.unitCodeSearch);
            this.isLoading = false;
            if (result) {

                let preparedArr = [];
                result.unitInfo.forEach(item => {

                    console.log('item ::', item);
                    let preparedRec = {};
                    if (item.Id !== null && item.Id !== undefined) {
                        preparedRec.Id = item.Id;
                        preparedRec.linkName = '/' + item.Id;
                    }
                    if (item.Name !== null && item.Name !== undefined) {
                        preparedRec.Name = item.Name;
                    }
                    preparedRec.No_of_Bedrooms__c = item.No_of_Bedrooms__c;
                    preparedRec.spaceType = item.Space_Type__c;
                    preparedRec.BuiltUpArea = item.Built_Up_Area__c;
                    preparedRec.Built_Up_Area__c = item.Built_Up_Area__c;
                    preparedRec.TotalArea = item.Total_Area__c;
                    preparedRec.FinalPlotArea = item.Final_Plot_Area__c;
                    preparedRec.CreatedDate = item.CreatedDate;
                    preparedRec.CreatedBy = item.CreatedBy.Name;
                    if (this.currentUserName != "Inventory Executive" || this.currentUserName != "Inventory Executive" || this.currentUserName != "Inventory Head") {
                        preparedRec.DateofUpload = item.CreatedDate;
                        preparedRec.UserWhoUploaded = item.CreatedBy.Name;
                    } else {

                        console.log("i am inventory");
                        return {
                            ...item,
                            "HideUploadedDate": "slds-hide",
                        }

                    }
                    if (item.Project__c !== null && item.Project__c !== undefined) {
                        preparedRec.ProjectName = item.Project__r.Name;
                    }
                    if (item.Building__c !== null && item.Building__c !== undefined) {
                        preparedRec.BuildingName = item.Building__r.Name;
                    }
                    if (item.Master_Community__c !== null && item.Master_Community__c !== undefined) {
                        preparedRec.BusinessName = item.Master_Community__r.Name;
                    }
                    if (item.Unit_Status__c !== null && item.Unit_Status__c !== undefined) {
                        preparedRec.Unit_Status__c = item.Unit_Status__c;
                    }
                    if (item.Space_Types__c !== null && item.Space_Types__c !== undefined) {
                        preparedRec.spaceType = item.Space_Types__r.Name;
                    }
                    if (item.Blocked_By__c !== null && item.Blocked_By__c !== undefined) {
                        console.log('==item.Blocked_By__r.Profile_Name__c==' + item.Blocked_By__r.Profile_Name__c);
                        preparedRec.Blocked_By__c = item.Blocked_By__r.Name;
                        preparedRec.BlockedByProfile = item.Blocked_By__r.Profile_Name__c;
                    }
                    if (item.Function_Type_Name__c !== null && item.Function_Type_Name__c !== undefined) {
                        preparedRec.Function_Type_Name__c = item.Function_Type_Name__c;
                    }
                    if (item.Unit_Theme_Name__c !== null && item.Unit_Theme_Name__c !== undefined) {
                        preparedRec.unitTheme = item.Unit_Theme_Name__c;
                    }
                    if (item.Selling_Price__c !== null && item.Selling_Price__c !== undefined) {
                        preparedRec.Selling_Price__c = item.Selling_Price__c;
                    }
                    if (item.Unit_Code__c !== null && item.Unit_Code__c !== undefined) {
                        preparedRec.Unit_Code__c = item.Unit_Code__c;
                    }
                    if (item.Total_Selling_Price__c !== null && item.Total_Selling_Price__c !== undefined) {
                        preparedRec.Total_Selling_Price__c = item.Total_Selling_Price__c;
                    }
                    if (item.Total_Selling_Price__c !== null && item.Total_Selling_Price__c !== undefined) {
                        preparedRec.TotalSellingPrice = item.Total_Selling_Price__c;
                    }

                    preparedRec.Release_Status__c = item.Release_Status__c;
                    if (item.Handover_Status__c !== '') {
                        preparedRec.handoverStatus = item.Handover_Status__c;
                    }
                    if (item.Blocked_Status__c !== '' && item.Blocked_Status__c) {
                        preparedRec.BlockedStatus = item.Blocked_Status__c;
                    }
                    if (item.Blocked_Sub_status__c !== '') {
                        preparedRec.Blocked_Sub_status__c = item.Blocked_Sub_status__c;
                    }
                    preparedRec.Handover_Status__c = item.Handover_Status__c;
                    preparedRec.Sales_Event_Name__c = item.Sales_Event_Name__c;
                    console.log(' preparedRec ::', preparedRec);
                    preparedArr.push(preparedRec);

                });


                this.items = preparedArr;
                this.totalRecountCount = result.unitInfo.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                if (this.totalPage == 0) {
                    this.page = 0;
                } else {
                    this.page = 1;
                }
                this.unitData = this.items.slice(0, this.pageSize);
                this.dataSpinner = false;
                this.endingRecord = this.pageSize;

            }
        }).catch(error => {
            console.log('error', error);
            this.isLoading = false;
        });
        this.template.querySelector('div.unitSearch').classList.remove('slds-hide');
        this.selectedUnitsToAddInBucket = [];
    }

    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //this method displays records page by page
    displayRecordPerPage(page) {


        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) ?
            this.totalRecountCount : this.endingRecord;

        this.unitData = this.items.slice(this.startingRecord, this.endingRecord);
        this.dataSpinner = false;


        this.startingRecord = this.startingRecord + 1;
    }

    //clicking on previous button this method will be called
    previousBasketHandler() {
        if (this.basketPage > 1) {
            this.basketPage = this.basketPage - 1; //decrease page by 1
            this.displayBasketPerPage(this.basketPage);
        }
    }

    //clicking on next button this method will be called
    nextBasketHandler() {
        console.log('inside next');
        if ((this.basketPage < this.totalBasketPage) && this.basketPage !== this.totalBasketPage) {
            this.basketPage = this.basketPage + 1; //increase page by 1
            this.displayBasketPerPage(this.basketPage);
        }
    }

    //this method displays records page by page
    displayBasketPerPage(basketPage) {


        this.startingBasketRecord = ((basketPage - 1) * this.pageSize);
        this.endingBasketRecord = (this.pageSize * basketPage);

        this.endingBasketRecord = (this.endingBasketRecord > this.totalBasketCount) ?
            this.totalBasketCount : this.endingBasketRecord;

        this.basketData = this.basketItems.slice(this.startingBasketRecord, this.endingBasketRecord);


        this.startingBasketRecord = this.startingBasketRecord + 1;
    }

    getSelectedUnitFromCart(e) {

        const selectedRows = e.detail.selectedRows;

        this.selectedUnitsToRemoveFromCart = selectedRows;
        if (this.selectedUnitsToRemoveFromCart.length > 0) {
            this.removeFromCartButtonFlag = true;
        } else {
            this.removeFromCartButtonFlag = false;
        }
    }
    removeAllRecordsFromCart(e) {
        this.emptyCartButtonFlag = false;
        this.cartData = [];

    }

    removeSelectedUnitsFromCart(e) {
        this.cartData = this.cartData.filter(item => !this.selectedUnitsToRemoveFromCart.includes(item))
    }

    hideCartFromTheLayout(e) {
        this.hasValue = false;
        this.cartToggle = true;
    }

    renderCartOnLayout(e) {
        this.hasValue = true;
        this.cartToggle = false;
    }

    getSelectedUnitFromSearch(e) {
        console.log('Inside selected unit from search');
        const selectedRows = e.detail.selectedRows;
        console.log('Selected Rows', selectedRows);
        for (let i = 0; i < selectedRows.length; i++) {
            console.log('Check for Id ', selectedRows[i].Id);
        }
        console.log('Hello');
        console.log(this.unitData);
        console.log('No');
        console.log(selectedRows);
        this.selectedUnitsToAddInBucketTemp = selectedRows;

    }

    addSelectedUnitsToCart(e) {
        this.hasValue = true;

        this.cartData = [...this.cartData, ...this.selectedUnitsToAddInBucketTemp];
        this.emptyCartButtonFlag = true;
    }

    addSelectedUnitsToBucket(e) {
        //this.selectedUnitsToAddInBucket = this.selectedUnitsToAddInBucketTemp;
        var unitsToRemove = [];
        var tempUnitsTobeKept = [];
        this.selectedUnitsToAddInBucket = this.selectedUnitsToAddInBucketTemp;
        console.log(' this.items[i].BlockedByProfile ::', this.selectedUnitsToAddInBucketTemp);
        console.log(' this.items[i].selectedUnitsToAddInBucket ::', this.selectedUnitsToAddInBucket);

        for (let i = 0; i < this.selectedUnitsToAddInBucket.length; i++) {
            console.log('==this.selectedUnitsToAddInBucket[i]=' + JSON.stringify(this.selectedUnitsToAddInBucket[i]));
            console.log(' this.items[i].BlockedByProfile ::', JSON.stringify(this.selectedUnitsToAddInBucket[i].BlockedByProfile));
            console.log(' this.profileName ::', this.profileName);
            if (this.selectedUnitsToAddInBucket[i].Unit_Status__c === 'Blocked') {
                if (this.selectedUnitsToAddInBucket[i].BlockedByProfile != undefined && this.selectedUnitsToAddInBucket[i].BlockedByProfile != '' &&
                    (this.selectedUnitsToAddInBucket[i].BlockedByProfile === 'Project Executive' && (this.profileName == 'Project Executive' || this.profileName === 'System Administrator') && this.selectedUnitsToAddInBucket[i].Blocked_By__c == this.currentUserName) ||
                    (this.selectedUnitsToAddInBucket[i].BlockedByProfile === 'Inventory Executive' && (this.profileName == 'Inventory Executive' || this.profileName === 'Inventory Head' || this.profileName === 'Inventory Manager' || this.profileName === 'System Administrator')) ||
                    (this.selectedUnitsToAddInBucket[i].BlockedByProfile === 'Project Executive' && (this.profileName === 'Project Head' || this.profileName === 'Project Manager' || this.profileName === 'System Administrator')) ||
                    (this.selectedUnitsToAddInBucket[i].BlockedByProfile === 'Sales Manager' && (this.profileName === 'Sales Manager' || this.profileName === 'Sales Head' || this.profileName === 'System Administrator')) ||
                    (this.selectedUnitsToAddInBucket[i].BlockedByProfile === 'Sales Head' && (this.profileName === 'Sales Manager' || this.profileName === 'Sales Head' || this.profileName === 'System Administrator'))
                ) {
                    unitsToRemove.push(this.selectedUnitsToAddInBucket[i].Id);
                    console.log('===unitsToRemove==', JSON.stringify(unitsToRemove));
                } else {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'The List of units you selected may be blocked by some other user or team!',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                }
            } else {
                unitsToRemove.push(this.selectedUnitsToAddInBucket[i].Id);
            }

        }
        console.log('Selected Units in Bucket ', JSON.stringify(unitsToRemove));

        console.log('Selected Units in Bucket ', JSON.stringify(this.selectedUnitsToAddInBucket));

        //this.template.querySelector('div.unitSearch').classList.add('slds-hide');
        if (this.basketItems.length <= 0 && this.selectedUnitsToAddInBucket.length > 0) {
            this.template.querySelector('div.unitBucket').classList.remove('slds-hide');
        }
        // for pagination
        for (let i = 0; i < this.items.length; i++) {
            if (!unitsToRemove.includes(this.items[i].Id)) {
                //console.log('items removed'+ this.items[i]);
                tempUnitsTobeKept.push(this.items[i]);
            } else {
                console.log('==this.items[i]=' + JSON.stringify(this.items[i]));
                if (this.items[i].Unit_Status__c === 'Blocked') {
                    if (this.items[i].BlockedByProfile != undefined && this.items[i].BlockedByProfile != '' &&
                        (this.items[i].BlockedByProfile === 'Project Executive' && (this.profileName == 'Project Executive' || this.profileName === 'System Administrator') && this.items[i].Blocked_By__c == this.currentUserName) ||
                        (this.items[i].BlockedByProfile === 'Inventory Executive' && (this.profileName == 'Inventory Executive' || this.profileName == 'Inventory Head' || this.profileName == 'Inventory Manager' || this.profileName === 'System Administrator')) ||
                        (this.items[i].BlockedByProfile === 'Project Executive' && (this.profileName == 'Project Head' || this.profileName == 'Project Manager' || this.profileName === 'System Administrator')) ||
                        (this.items[i].BlockedByProfile === 'Sales Manager' && (this.profileName === 'Sales Manager' || this.profileName === 'Sales Head' || this.profileName === 'System Administrator')) ||
                        (this.items[i].BlockedByProfile === 'Sales Head' && (this.profileName === 'Sales Manager' || this.profileName === 'Sales Head' || this.profileName === 'System Administrator'))
                    ) {
                        this.basketItems.push(this.items[i]);
                    } else {
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: 'The List of units you selected may be blocked by some other user or team!',
                            variant: 'warning',
                        });
                        this.dispatchEvent(evt);
                    }
                } else {
                    this.basketItems.push(this.items[i]);
                }
                console.log('bucket added' + this.items[i]);
            }
        }

        //this.basketItems.push.apply(this.basketItems, this.tempBucketListForApproval);
        this.totalBasketCount = this.basketItems.length;
        this.totalBasketPage = Math.ceil(this.totalBasketCount / this.pageSize);

        this.basketData = this.basketItems.slice(0, this.pageSize);
        this.endingBasketRecord = this.pageSize;
        // to remove from previous list
        this.items = tempUnitsTobeKept;
        this.unitData = tempUnitsTobeKept.slice(0, this.pageSize);
        this.dataSpinner = false;
        this.totalRecountCount = this.items.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        if (this.totalPage == 0) {
            this.page = 0;
        }
        this.unitData = this.items.slice(0, this.pageSize);
        this.endingRecord = this.pageSize;

    }

    submitForInventoryApproval(e) {
        if (this.selectedBaskedUnits.length > 0) {
            for (let i = 0; i < this.selectedBaskedUnits.length; i++) {
                console.log('==this.selectedBaskedUnits[i].Release_Status__c==' + this.selectedBaskedUnits[i].Release_Status__c);
                if (this.selectedBaskedUnits[i].Unit_Status__c == 'Restricted' && this.selectedBaskedUnits[i].Release_Status__c !== 'Pending') {
                    this.approvalModalFlag = true;
                } else if (this.selectedBaskedUnits[i].Unit_Status__c == 'Restricted' && this.selectedBaskedUnits[i].Release_Status__c == 'Pending') {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Unit ' + this.selectedBaskedUnits[i].Unit_Code__c + ' is already submitted for approval!',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.approvalModalFlag = false;
                    break;
                } else {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Only Restricted Units can be submitted for Release Approval',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.approvalModalFlag = false;
                    break;
                }

            }
        } else {
            this.showMasterOptionsLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select atleast one unit',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }

    submitForApproval(e) {
        console.log('Temporary bucket list ', this.tempBucketListForApproval);
        console.log('bucket final ', this.selectedUnitsToAddInBucket);
        let finalList = [];
        for (let i = 0; i < this.selectedBaskedUnits.length; i++) {
            if (this.selectedBaskedUnits[i].Unit_Status__c == 'Restricted') {
                finalList.push(String(this.selectedBaskedUnits[i].Id));
            } else {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Unit Status should be set as Restricted!',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                this.approvalModalFlag = false;
                break;
            }
        }

        console.log('final list ', finalList);
        if (finalList.length > 0) {
            this.showLoadingApproval = true;
            submitUnitsForInventoryApproval({
                    selectedUnitIdsList: finalList,
                    approvalType: this.selectedApprovalTypeValue,
                    lineOfBusiness: this.selectedLineOfBusinessValue,
                    selectedComment: this.selectedCommentValue
                })
                .then(result => {
                    console.log('Result', result);
                    if (result) {

                        this.basketData.forEach(function (unit) {
                            if (finalList.includes(unit.Id)) {
                                unit.Release_Status__c = 'Pending';
                            }
                        });

                        this.basketData = [...this.basketData];

                        this.showLoadingApproval = false;
                        this.approvalModalFlag = false;
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: 'Unit(s) has been submitted for approval ' + result.Name,
                            variant: 'Success',
                        });
                        this.dispatchEvent(evt);

                        //eval("$A.get('e.force:refreshView').fire();");
                    }
                });

        }
    }
    addUnitOptions(e) {
        console.log('Temporary bucket list ', this.tempBucketListForApproval);
        console.log('bucket final ', this.selectedUnitsToAddInBucket);
        let finalList = [];
        for (let i = 0; i < this.selectedBaskedUnits.length; i++) {

            finalList.push(String(this.selectedBaskedUnits[i].Id));
        }
        console.log('final list ', finalList);
        createUnitOptions({
                selectedUnitIdsList: finalList,
                masterOptionId: this.masterOptionId,
                price: this.price,
                pricebookId: this.pricebookId
            })
            .then(result => {
                console.log('Inside result unit option');
                if (result) {
                    this.unitOptionsModalFlag = false;

                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Unit added to Units successfully',
                        variant: 'Success',
                    });
                    this.dispatchEvent(evt);
                }
                this.amenitiesModalFlag = false;
                0
            }).catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Something Wrong! Please contact your System Administrator',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            });
    }

    getSelectedUnitFromBucket(e) {
        const selectedRowsToRemove = e.detail.selectedRows;
        console.log(selectedRowsToRemove);
        this.selectedUnitsToRemoveFromBucket = selectedRowsToRemove;
        this.selectedBaskedUnits = selectedRowsToRemove;
        if (this.selectedUnitsToRemoveFromBucket.length > 0) {
            this.removeFromBucketFlag = true;
        } else {
            this.removeFromBucketFlag = false;
        }

    }

    removeUnitsFromBucket(e) {
        console.log('Start to rmove');
        const unitsToRemoveFromBucketId = [];
        const tempUnitsTobeKept = [];
        const removeSelectedBucket = []
        console.log('RR');
        for (let i = 0; i < this.selectedUnitsToRemoveFromBucket.length; i++) {
            console.log('In first for loop');
            unitsToRemoveFromBucketId.push(this.selectedUnitsToRemoveFromBucket[i].Id);
        }
        console.log(unitsToRemoveFromBucketId);
        console.log(this.selectedUnitsToAddInBucket[1]);
        for (let i = 0; i < this.selectedUnitsToAddInBucket.length; i++) {
            console.log('second for loop');
            if (!unitsToRemoveFromBucketId.includes(this.selectedUnitsToAddInBucket[i].Id)) {
                console.log('in if');
                tempUnitsTobeKept.push(this.selectedUnitsToAddInBucket[i]);
            } else {
                this.items.push(this.selectedUnitsToAddInBucket[i]);
            }
        }
        for (let i = 0; i < this.selectedUnitsToAddInBucket.length; i++) {
            console.log('second for loop');
            if (!unitsToRemoveFromBucketId.includes(this.selectedBaskedUnits[i].Id)) {
                console.log('in if');
                removeSelectedBucket.push(this.selectedBaskedUnits[i]);
            } else {
                this.selectedBaskedUnits.push(this.selectedBaskedUnits[i]);
            }
        }
        this.unitData = this.items.slice(0, this.pageSize);
        this.dataSpinner = false;
        this.totalRecountCount = this.items.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        this.page = 1;
        this.unitData = this.items.slice(0, this.pageSize);
        this.endingRecord = this.pageSize;

        this.basketItems = tempUnitsTobeKept;
        this.basketData = tempUnitsTobeKept.slice(0, this.pageSize);
        this.totalBasketCount = this.basketItems.length;
        this.totalBasketPage = Math.ceil(this.totalBasketCount / this.pageSize);
        this.endingBasketRecord = this.pageSize;
        if (tempUnitsTobeKept.length <= 0) {
            this.template.querySelector('div.unitBucket').classList.add('slds-hide');
        }
    }
    showSalesEvent(e) {
        if (this.selectedBaskedUnits.length > 0) {

            this.availableUnitFlag = false;

            for (let i = 0; i < this.selectedBaskedUnits.length; i++) {

                if (this.selectedBaskedUnits[i].Unit_Status__c != 'Available') {
                    this.availableUnitFlag = true;
                    break;
                }
            }

            if (this.availableUnitFlag == true) {
                this.showMasterOptionsLoading = false;
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Only available units can be added for sales event',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            } else {
                this.salesEventModalFlag = true;
            }

        } else {
            this.showMasterOptionsLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select atleast one unit',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }

    showSpecialOffer(e) {
        if (this.selectedBaskedUnits.length > 0) {
            this.specialOfferModalFlag = true;
        } else {
            this.showMasterOptionsLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select atleast one unit',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }

    showSalesOffer(e) {
        this.showSalesOfferModel = false;

        if (this.selectedBaskedUnits.length > 5) {
            this.showSalesOfferModel = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Sales Offer with floor plans can be generated with maximum of 5 units.Please use bulk offer',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        } else if (this.selectedBaskedUnits.length > 0) {
            console.log('==this.selectedBaskedUnits==' + JSON.stringify(this.selectedBaskedUnits));

            createSalesOffer({
                    unitList: this.selectedBaskedUnits
                })
                .then(result => {
                    if (result) {
                        console.log('==result==', result);
                        this.salesOfferId = result;
                        this.showSalesOfferModel = true;
                    }

                }).catch(error => {
                    this.showUnitUpdateHandoverLoader = false;
                    console.log('@@error@@', error);
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Something Wrong! Please contact your System Administrator',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.showSalesOfferModel = false;
                });

        } else {
            this.showSalesOfferModel = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select atleast one unit',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }

    showBulkOffer(e) {
        this.showBulkOfferModel = false;
        if (this.selectedBaskedUnits.length > 0) {
            console.log('==this.selectedBaskedUnits==' + JSON.stringify(this.selectedBaskedUnits));

            createSalesOffer({
                    unitList: this.selectedBaskedUnits
                })
                .then(result => {
                    if (result) {
                        console.log('==result==', result);
                        this.salesOfferId = result;
                        this.showBulkOfferModel = true;
                    }

                }).catch(error => {
                    this.showUnitUpdateHandoverLoader = false;
                    console.log('@@error@@', error);
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Something Wrong! Please contact your System Administrator',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.showBulkOfferModel = false;
                });

        } else {
            this.showBulkOfferModel = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select atleast one unit',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }

    showAmenity(e) {
        if (this.selectedBaskedUnits.length > 0) {
            this.amenitiesModalFlag = true;
        } else {
            this.showMasterOptionsLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select atleast one unit',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }
    showHandoverPopup(e) {
        this.showUnitUpdateHandoverLoader = false;
        this.unsoldFlag = false;
        let errorMessage = '';
        console.log(JSON.stringify(this.selectedBaskedUnits));
        if (this.selectedBaskedUnits.length > 0) {
            this.unitInspectionTargetDate = null;
            for (let i = 0; i < this.selectedBaskedUnits.length; i++) {
                console.log(this.selectedBaskedUnits[i].Unit_Status__c);
                if (this.selectedBaskedUnits[i].Unit_Status__c != 'Sold') {
                    this.unsoldFlag = true;
                    errorMessage = 'Please select only Sold Units';
                    break;
                }
                console.log('==this.selectedBaskedUnits[i].Handover_Status__c==' + this.selectedBaskedUnits[i].Handover_Status__c);
                if (this.selectedBaskedUnits[i].Handover_Status__c == 'Ready for Inspection') {
                    this.unsoldFlag = true;
                    errorMessage = 'Handover is Already Processed for ' + this.selectedBaskedUnits[i].Unit_Code__c;
                    break;
                }
            }
            if (this.unsoldFlag) {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            } else {
                this.unitUpdateHandoverModal = true;
            }
        } else {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select atleast one unit',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }


    }
    showUnitOptions(e) {
        this.showMasterOptionsLoading = true;
        if (this.selectedUnitsToRemoveFromBucket.length > 0) {
            this.unitOptionsModalFlag = true;
            getUnitOptionsAndMasterOptionData({
                    sourceOfInvocation: 'fromInventoryWizard'
                })
                .then((result) => {
                    this.addUnitOptionsColumns = result.columnList;
                    this.addUnitOptionsData = result.masterOptionsDataWrapper;
                    this.showMasterOptionsLoading = false;
                })
                .catch((error) => {
                    this.showMasterOptionsLoading = false;
                    console.log('Error while Calling getUnitOptionsAndMasterOptionData' + JSON.stringify(error));
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                });
        } else {
            this.showMasterOptionsLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select atleast one unit',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }
    allUnitOptionsSelected(event) {
        let addUnitOptionsDataClone = JSON.parse(JSON.stringify(this.addUnitOptionsData));
        for (var i = 0; i < addUnitOptionsDataClone.length; i++) {
            addUnitOptionsDataClone[i].isSelected = event.target.checked;
        }
        this.addUnitOptionsData = addUnitOptionsDataClone;
    }
    handleUnitOptionCheckChange(event) {
        let addUnitOptionsDataClone = JSON.parse(JSON.stringify(this.addUnitOptionsData));
        addUnitOptionsDataClone[event.target.value].isSelected = event.target.checked;
        if (!event.target.checked && (addUnitOptionsDataClone[event.target.value].hasPriceMissingError || addUnitOptionsDataClone[event.target.value].hasAreaMissingError)) {
            addUnitOptionsDataClone[event.target.value].hasPriceMissingError = false;
            addUnitOptionsDataClone[event.target.value].hasAreaMissingError = false;
            addUnitOptionsDataClone[event.target.value].priceMissingErrorMsg = '';
            addUnitOptionsDataClone[event.target.value].areaMissingErrorMsg = '';
        }
        this.addUnitOptionsData = addUnitOptionsDataClone;
    }
    handlePriceChangeForUnit(event) {
        let addUnitOptionsDataClone = JSON.parse(JSON.stringify(this.addUnitOptionsData));
        for (var i = 0; i < addUnitOptionsDataClone.length; i++) {
            if (event.target.value && addUnitOptionsDataClone[i].hasPriceMissingError) {
                addUnitOptionsDataClone[i].hasPriceMissingError = false;
                addUnitOptionsDataClone[i].priceMissingErrorMsg = '';
            }
            if (addUnitOptionsDataClone[i].MasterOption.Id === event.target.dataset.id) {
                addUnitOptionsDataClone[i].price = event.target.value;
            }
        }
        this.addUnitOptionsData = addUnitOptionsDataClone;
    }
    areaRequiredChange(event) {
        let addUnitOptionsDataClone = JSON.parse(JSON.stringify(this.addUnitOptionsData));
        for (var i = 0; i < addUnitOptionsDataClone.length; i++) {
            if (addUnitOptionsDataClone[i].MasterOption.Id === event.target.dataset.id) {
                addUnitOptionsDataClone[i].additionalAreaRequired = event.target.value;
            }
            if (event.target.value && addUnitOptionsDataClone[i].hasAreaMissingError) {
                addUnitOptionsDataClone[i].hasAreaMissingError = false;
                addUnitOptionsDataClone[i].areaMissingErrorMsg = '';
            }
        }
        this.addUnitOptionsData = addUnitOptionsDataClone;
    }
    submitUnitOptionsSelected(event) {
        let pageHasError = false;
        let nothingIsSelected = true;
        this.selectedUnitOptionsData = [];
        let addUnitOptionsDataClone = JSON.parse(JSON.stringify(this.addUnitOptionsData));
        for (var i = 0; i < addUnitOptionsDataClone.length; i++) {
            if (addUnitOptionsDataClone[i].isSelected) {
                nothingIsSelected = false;
                if (addUnitOptionsDataClone[i].MasterOption.Type__c === 'Paid' && addUnitOptionsDataClone[i].price == 0) {
                    addUnitOptionsDataClone[i].hasPriceMissingError = true;
                    addUnitOptionsDataClone[i].priceMissingErrorMsg = 'Price is not added';
                    pageHasError = true;
                }
                if (addUnitOptionsDataClone[i].MasterOption.Additional_Area_Required__c && addUnitOptionsDataClone[i].additionalAreaRequired == 0) {
                    addUnitOptionsDataClone[i].hasAreaMissingError = true;
                    addUnitOptionsDataClone[i].areaMissingErrorMsg = 'Area required is not specified';
                    pageHasError = true;
                } else {
                    this.selectedUnitOptionsData.push(addUnitOptionsDataClone[i]);
                }
            }
        }
        if (nothingIsSelected) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select atleast one master option',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
            return;
        }
        this.addUnitOptionsData = addUnitOptionsDataClone;
        if (pageHasError) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please fill in the required field values',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        } else {
            this.showMasterOptionsLoading = true;
            let selectedUnitsList = [];
            for (var i = 0; i < this.selectedUnitsToRemoveFromBucket.length; i++) {
                selectedUnitsList.push(this.selectedUnitsToRemoveFromBucket[i].Id);
            }
            createUnitOptionsData({
                    unitOptionDataWrapper: JSON.stringify(this.selectedUnitOptionsData),
                    selectedUnitsList: selectedUnitsList
                })
                .then((result) => {
                    if (result === 'SUCCESS') {
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: 'Master Options added to the Units',
                            variant: 'success',
                        });
                        this.dispatchEvent(evt);
                    } else {
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'warning',
                        });
                        this.dispatchEvent(evt);
                    }
                    this.showMasterOptionsLoading = false;
                    this.unitOptionsModalFlag = false;
                })
                .catch((error) => {
                    this.showMasterOptionsLoading = false;
                    console.log('Error while Calling getUnitOptionsAndMasterOptionData' + JSON.stringify(error));
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                });
        }
    }

    showPopup(e) {
        console.log("i am in show popup");
        if (this.selectedBaskedUnits.length > 0) {
            for (let i = 0; i < this.selectedBaskedUnits.length; i++) {
                if ((this.profileName == 'System Administrator')) {
                    this.unitUpdateModalFlag = true;
                }
                if ((this.profileName == 'Inventory Executive' || this.profileName == 'Inventory Head' || this.profileName == 'Inventory Manager') && (this.selectedBaskedUnits[i].Unit_Status__c == 'Uploaded' || this.selectedBaskedUnits[i].Unit_Status__c == 'Available' || this.selectedBaskedUnits[i].Unit_Status__c == 'Blocked')) {
                    this.unitUpdateModalFlag = true;
                    this.isDisabledBlocked = true;
                    this.isBlockedReasonDisabled = true;
                } else if ((this.profileName == 'Inventory Executive' || this.profileName == 'Inventory Head' || this.profileName == 'Inventory Manager')) {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Only Applicable for Uploaded, Blocked and Available Units',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.unitUpdateModalFlag = false;
                    break;
                }

                if ((this.profileName == 'Project Executive' || this.profileName == 'Project Head' || this.profileName == 'Project Manager') && this.selectedBaskedUnits[i].Unit_Status__c == 'Restricted' || this.selectedBaskedUnits[i].Unit_Status__c == 'Blocked') {
                    this.unitUpdateModalFlag = true;
                    this.isDisabledBlocked = true;
                    this.isBlockedReasonDisabled = true;
                } else if ((this.profileName == 'Project Executive' || this.profileName == 'Project Head' || this.profileName == 'Project Manager')) {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Only Applicable for Restircted and Blocked Units',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.unitUpdateModalFlag = false;
                    break;
                }

                if ((this.profileName == 'Sales Manager') && (this.selectedBaskedUnits[i].Unit_Status__c == 'Available' || this.selectedBaskedUnits[i].Unit_Status__c == 'Blocked')) {
                    this.unitUpdateModalFlag = true;
                    this.isDisabledBlocked = true;
                    this.isBlockedReasonDisabled = true;
                } else if ((this.profileName == 'Sales Manager')) {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Only Applicable for Blocked and Available Units',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.unitUpdateModalFlag = false;
                    break;
                }
            }
        } else {

            this.showMasterOptionsLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select atleast one unit',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }
    showDownloadTemplate(e) {
        if (this.selectedBaskedUnits.length > 0) {
            let isError = false;
            this.genratePricingTemplate = [];

            for (let i = 0; i < this.selectedBaskedUnits.length; i++) {
                if (this.selectedBaskedUnits[i].Unit_Status__c == 'Restricted') {
                    this.genratePricingTemplate.push(this.selectedBaskedUnits[i]);
                } else {
                    isError = true;
                    break;
                }
            }

            if (isError) {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Only Applicable for Restricted Units',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                this.downloadTemplateModalFlag = false;
            } else {
                this.downloadTemplateModalFlag = true;
            }
        } else {
            this.showMasterOptionsLoading = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select atleast one unit',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }

    closeModal(e) {
        this.unitUpdateModalFlag = false;
        this.salesEventModalFlag = false;
        this.specialOfferModalFlag = false;
        this.amenitiesModalFlag = false;
        this.approvalModalFlag = false;
        this.unitOptionsModalFlag = false;
        this.downloadTemplateModalFlag = false;
        this.showCSVUploadBox = false;
        this.unitUpdateHandoverModal = false;
    }

    unitInspectionTargetDateChange(e) {
        this.unitInspectionTargetDate = e.target.value;
    }

    get todaysDate() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;
        console.log('==today==', today);
        return today
    }

    updateUnitsReadyTobeInspected(e) {
        this.showUnitUpdateHandoverLoader = true;
        let finalList = [];
        console.log(this.selectedUnitsToAddInBucket.length);
        console.log('unitHandoverStatus', this.unitHandoverStatus);
        for (let i = 0; i < this.selectedBaskedUnits.length; i++) {
            finalList.push(String(this.selectedBaskedUnits[i].Id));
        }
        console.log(finalList);
        console.log('showUnitUpdateHandoverLoader', this.showUnitUpdateHandoverLoader);
        console.log('unitInspectionTargetDate', this.unitInspectionTargetDate);

        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;
        console.log('==today==', today);

        if (this.unitInspectionTargetDate == null || this.unitInspectionTargetDate == undefined) {
            this.showUnitUpdateHandoverLoader = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Inspection Target Date is Required!',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        } else if (this.unitInspectionTargetDate < today) {
            this.showUnitUpdateHandoverLoader = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Inspection Target Date must be today or future!',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        } else if (finalList.length > 0) {
            updateReadyForInspectiononUnit({
                    selectedUnitsIdList: finalList,
                    unitInspectionTargetDateSel: this.unitInspectionTargetDate
                })
                .then(result => {
                    if (result) {

                        this.basketData.forEach(function (unit) {
                            if (finalList.includes(unit.Id)) {
                                unit.Handover_Status__c = 'Ready for Inspection';
                                unit.handoverStatus = 'Ready for Inspection';
                            }
                        });

                        this.basketData = [...this.basketData];
                        this.showUnitUpdateHandoverLoader = false;
                        console.log('@@success@@', result);
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: 'Your Handover is initiated for the process!',
                            variant: 'Success',
                        });
                        this.dispatchEvent(evt);
                        this.unitUpdateHandoverModal = false;
                    } else {
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: 'Something Wrong! Please contact your System Administrator',
                            variant: 'warning',
                        });
                        this.dispatchEvent(evt);
                        this.unitUpdateHandoverModal = false;
                    }
                }).catch(error => {
                    this.showUnitUpdateHandoverLoader = false;
                    console.log('@@error@@', error);
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Something Wrong! Please contact your System Administrator',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    this.unitUpdateHandoverModal = false;
                });
        }
    }

    submitUpdateDetails(e) {
        let finalList = [];
        console.log('==selectedBaskedUnits==' + JSON.stringify(this.selectedBaskedUnits));

        this.unitUpdateModalSpinnerFlag = true;
        for (let i = 0; i < this.selectedBaskedUnits.length; i++) {
            finalList.push(String(this.selectedBaskedUnits[i].Id));
        }
        console.log('==finalList==' + JSON.stringify(finalList));
        console.log('==basketData==' + JSON.stringify(this.basketData));

        if (this.selectedUpdateStatus == 'Blocked' && (this.selectedBlockedStatus == '' || this.selectedBlockedSubStatus == '')) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please Select Block Status and Sub Status',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
            this.unitUpdateModalSpinnerFlag = false;
        } else {
            updateSelectedUnits({
                    selectedUnitsIdList: finalList,
                    statusToUpdate: this.selectedUpdateStatus,
                    blockedStatus: this.selectedBlockedStatus,
                    blockedSubStatus: this.selectedBlockedSubStatus,
                    remarksOnUnit: this.remarksOnUpdate
                })
                .then(result => {
                    if (result) {
                        this.blockedStatus = [];
                        this.blockedSubStatus = [];

                        console.log('==result==' + JSON.stringify(result));

                        this.basketData.forEach(function (unit) {
                            if (finalList.includes(unit.Id)) {
                                unit.Unit_Status__c = result[unit.Id].Unit_Status__c;
                                unit.Blocked_By__c = result[unit.Id].Blocked_By__c != undefined && result[unit.Id].Blocked_By__c != null ? result[unit.Id].Blocked_By__r.Name : '';
                                unit.BlockedStatus = result[unit.Id].Blocked_Status__c != undefined ? result[unit.Id].Blocked_Status__c : '';
                                unit.Blocked_Sub_status__c = result[unit.Id].Blocked_Sub_status__c != undefined ? result[unit.Id].Blocked_Sub_status__c : '';
                                unit.Remarks__c = result[unit.Id].Remarks__c != undefined ? result[unit.Id].Remarks__c : '';
                            }
                        });

                        this.basketData = [...this.basketData];
                        console.log('==this.basketData==' + JSON.stringify(this.basketData));

                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: 'Units Updated Successfully!',
                            variant: 'Success',
                        });
                        this.dispatchEvent(evt);

                        this.selectedBlockedStatus = '';
                        this.remarksOnUpdate = '';
                        this.selectedBlockedSubStatus = '';
                        this.selectedUpdateStatus = '';

                        this.unitUpdateModalSpinnerFlag = false;
                        this.unitUpdateModalFlag = false;

                    }
                }).catch(error => {
                    console.log('@@error@@', error);
                    this.unitUpdateModalSpinnerFlag = false;
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Something Wrong! Please contact your System Administrator',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                });
            this.unitUpdateModalFlag = false;
        }

    }

    addSalesEvent(e) {
        console.log('Inside Sales Event function');
        console.log('Bucket final ', this.selectedUnitsToAddInBucket);
        let finalList = [];
        for (let i = 0; i < this.selectedBaskedUnits.length; i++) {
            finalList.push(String(this.selectedBaskedUnits[i].Id));
        }
        console.log('Final List ID ', finalList);
        console.log('Selected Sales Event Id ', this.selectedSalesEventId);

        let selectedSalesEventName = this.selectedSalesEventName;
        let isExistingSalesEventName = false;


        this.basketData.forEach(function (unit) {
            console.log('==unit.Sales_Event_Name__c==' + unit.Sales_Event_Name__c);
            if (finalList.includes(unit.Id)) {
                if (unit.Sales_Event_Name__c != undefined && unit.Sales_Event_Name__c.includes(selectedSalesEventName)) {
                    isExistingSalesEventName = true;
                }
            }
        });

        if (isExistingSalesEventName) {
            this.salesEventModalFlag = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Unit Already Added to this Sales Event',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else {
            createSalesEventUnitRecord({
                    selectedUnitIds: finalList,
                    selectedSalesEventID: this.selectedSalesEventId
                })
                .then(result => {
                    console.log('Inside Sales Event ', result);
                    console.log('==this.basketData== ', JSON.stringify(this.basketData));
                    if (result) {
                        console.log('==this.selectedSalesEventName==', this.selectedSalesEventName);
                        let selectedSalesEventName = this.selectedSalesEventName;
                        this.basketData.forEach(function (unit) {
                            console.log('==unit.Sales_Event_Name__c==' + unit.Sales_Event_Name__c);
                            if (finalList.includes(unit.Id)) {
                                if (unit.Sales_Event_Name__c == undefined) {
                                    unit.Sales_Event_Name__c = selectedSalesEventName != undefined ? selectedSalesEventName : '';
                                } else {
                                    unit.Sales_Event_Name__c += ', ' + selectedSalesEventName;
                                }
                            }
                        });

                        this.basketData = [...this.basketData];

                        this.salesEventModalFlag = false;
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: 'Units Successfully Added to Sales Event',
                            variant: 'Success',
                        });
                        this.dispatchEvent(evt);
                    } else {
                        this.salesEventModalFlag = false;
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: result.response,
                            variant: 'warning',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                    }
                }).catch(error => {
                    console.log(error);
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Something Wrong! Please contact your System Administrator',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                });
        }
    }

    addAmenity(e) {
        let finalList = [];
        for (let i = 0; i < this.selectedBaskedUnits.length; i++) {
            finalList.push(String(this.selectedBaskedUnits[i].Id));
        }
        console.log('Selected Units ', finalList);
        addAmenitiestoUnit({
                selectedUnitIds: finalList,
                selectedAmenitiesId: this.selectedAmenityListboxValue
            })
            .then(result => {
                console.log('Inside result addAmenity');
                if (result) {
                    this.amenitiesModalFlag = false;

                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Amenities added to Units successfully',
                        variant: 'Success',
                    });
                    this.dispatchEvent(evt);
                }
                this.amenitiesModalFlag = false;
            }).catch(error => {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Something Wrong! Please contact your System Administrator',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            });
    }

    addSpecialOffer(e) {
        let finalList = [];
        let unitsNotAllowed = [];

        for (let i = 0; i < this.selectedBaskedUnits.length; i++) {
            // Added by Rohit Sharma - NAK-1628
            let unit = this.selectedBaskedUnits[i];
            if (unit.Unit_Status__c != 'Available' && unit.Unit_Status__c != 'Uploaded') {
                unitsNotAllowed.push(unit);
            }

            finalList.push(String(this.selectedBaskedUnits[i].Id));
        }

        // Added by Rohit Sharma - NAK-1628
        if (unitsNotAllowed && unitsNotAllowed.length > 0) {
            this.showToast('Error', 'Special Offer can only be given to Available or Uploaded units', 'warning');
        } else {
            createSpecialOfferItem({
                    selectedUnitIds: finalList,
                    selectedSpecialOfferID: this.selectedSpecialOfferId
                })
                .then(result => {
                    if (result) {
                        this.specialOfferModalFlag = false;
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: 'Units Successfully Added to Special Offer',
                            variant: 'Success',
                        });
                        this.dispatchEvent(evt);
                    } else {
                        this.specialOfferModalFlag = false;
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: 'Something Wrong! Please contact your System Administrator',
                            variant: 'warning',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                    }
                    this.specialOfferModalFlag = false;
                }).catch(error => {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Something Wrong! Please contact your System Administrator',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                });
        }

    }

    /*  addSalesEvent(e){
          let finalList = [];
          console.log('Selected Units Length',this.selectedUnitsToAddInBucket.length);
          for(let i=0; i<this.selectedUnitsToAddInBucket.length; i++){
              finalList.push(String(this.selectedUnitsToAddInBucket[i].Id));
          }
          console.log('Final List',finalList);
          console.log('hello this is selectedSalesEventId '+this.selectedSalesEventId);
          updateSelectedUnits({selectedUnitsIdList: finalList, salesEventId: this.selectedSalesEventId,
              statusToUpdate: this.selectedUpdateStatus, remarksOnUnit: this.remarksOnUpdate}).then(result=>{
                                  console.log('Sucessfully Update Units!');
                              })
          this.unitUpdateModalFlag = false;
      } */

    selectedApprovalType(e) {
        console.log(e.target.value);
        this.selectedApprovalTypeValue = e.target.value;
    }

    selectedLineOfBusiness(e) {
        console.log(e.target.value);
        this.selectedLineOfBusinessValue = e.target.value;
    }

    selectedComments(e) {
        this.selectedCommentValue = e.target.value;
    }

    selectedStatusToUpdate(e) {
        console.log(e.target.value);
        this.selectedUpdateStatus = e.target.value;
        console.log('==this.selectedUpdateStatus==' + this.selectedUpdateStatus);

        if (this.selectedUpdateStatus == 'Blocked') {
            this.isDisabledBlocked = false;
            if (this.profileName == 'Project Executive' || this.profileName == 'Project Head' || this.profileName == 'Project Manager') {
                this.blockedStatus = [{
                    label: 'Development',
                    value: 'Development'
                }];
            } else if (this.profileName == 'Inventory Executive' || this.profileName == 'Inventory Head' || this.profileName == 'Inventory Manager') {
                this.blockedStatus = [{
                        label: 'Sales',
                        value: 'Sales'
                    },
                    {
                        label: 'Customer Care',
                        value: 'Customer Care'
                    },
                    {
                        label: 'Legal',
                        value: 'Legal'
                    }
                ];
            } else if (this.profileName == 'Sales Manager' || this.profileName == 'Sales Head') {
                this.blockedStatus = [{
                    label: 'Sales',
                    value: 'Sales'
                }];
                this.blockedSubStatus = [{
                    label: 'Salesforce block',
                    value: 'Salesforce block'
                }];
                this.blockedStatusDefault = 'Sales';
                this.blockedSubStatusDefault = 'Salesforce block';
                this.isDisabledBlocked = true;
                this.selectedBlockedStatus = 'Sales';
                this.selectedBlockedSubStatus = 'Salesforce block';
                console.log('==this.profileName==' + this.profileName);
            } else {
                console.log("else blocked");
                this.blockedStatus = [{
                        label: 'Development',
                        value: 'Development'
                    },
                    {
                        label: 'Customer Care',
                        value: 'Customer Care'
                    },
                    {
                        label: 'Sales',
                        value: 'Sales'
                    },
                    {
                        label: 'Legal',
                        value: 'Legal'
                    }
                ];
            }
            console.log('Blocked Status')
        } else if (this.selectedUpdateStatus == 'Restricted') {
            if (this.profileName == 'Project Executive' || this.profileName == 'Project Head' || this.profileName == 'Project Manager') {
                this.isDisabledBlocked = true;
                this.blockedStatusDefault = '';
                this.blockedSubStatusDefault = '';
                this.blockedStatus = [];
                this.blockedSubStatus = [];
            }
        } else if (this.selectedUpdateStatus == 'Available' || this.selectedUpdateStatus == '') {
            console.log("blocked status---");
            this.isDisabledBlocked = true;
            this.blockedStatusDefault = '';
            this.blockedSubStatusDefault = '';
            this.blockedStatus = [];
            this.blockedSubStatus = [];
        }

    }
    selectedBlockedStatusToUpdate(e) {
        //console.log('selectedBlockedStatusT ::',e.target.value);
        console.log("i am in selected blocked status to update");
        this.selectedBlockedStatus = e.target.value;
        if (this.selectedBlockedStatus == 'Development') {
            this.blockedSubStatus = [{
                    label: 'Under planning',
                    value: 'Under planning'
                },
                {
                    label: 'Strategic Block',
                    value: 'Strategic Block'
                },
                {
                    label: 'Unapproved',
                    value: 'Unapproved'
                }
            ];
        } else if (this.selectedBlockedStatus == 'Customer Care') {
            this.blockedSubStatus = [{
                    label: 'Settlement',
                    value: 'Settlement'
                },
                {
                    label: 'Reinstate',
                    value: 'Reinstate'
                }
            ];
        } else if (this.selectedBlockedStatus == 'Legal') {
            this.blockedSubStatus = [{
                label: 'Legal',
                value: 'Legal'
            }, ];
        } else if (this.selectedBlockedStatus == 'Sales') {
            this.blockedSubStatus = [{
                    label: 'Strategy',
                    value: 'Strategy'
                },
                {
                    label: 'Salesforce block',
                    value: 'Salesforce block'
                },
                {
                    label: 'Unreleased',
                    value: 'Unreleased'
                },
                // {label: 'Booked Cancelled', value: 'Booked Cancelled'},
                // {label: 'Reserved Cancelled', value: 'Reserved Cancelled'},
                // {label: 'Sold Cancelled', value: 'Sold Cancelled'}
            ];
        } else if (this.currentUserName == 'Sales Manager' || this.currentUserName == 'Sales Head') {
            console.log("i am disabled as blocked reason");
            this.isDisabledBlocked = true;
            this.blockedSubStatus = [{
                    label: 'Strategy',
                    value: 'Strategy'
                },
                {
                    label: 'Salesforce block',
                    value: 'Salesforce block'
                },
                {
                    label: 'Unreleased',
                    value: 'Unreleased'
                },
                // {label: 'Booked Cancelled', value: 'Booked Cancelled'},
                // {label: 'Reserved Cancelled', value: 'Reserved Cancelled'},
                // {label: 'Sold Cancelled', value: 'Sold Cancelled'}
            ];

        }

    }
    selectedBlockedSubStatusToUpdate(e) {
        console.log(e.target.value);
        this.selectedBlockedSubStatus = e.target.value;
    }

    updateRemarks(e) {
        this.remarksOnUpdate = e.target.value;
        console.log(this.remarksOnUpdate);
    }
    selectedMasterOption(e) {
        console.log(e.target.value);
        this.masterOptionId = e.target.value;
    }
    selectedPrice(e) {
        console.log(e.target.value);
        this.price = e.target.value;
    }
    selectedPriceBook(e) {
        console.log(e.target.value);
        this.pricebookId = e.target.value;
    }
    exportToCSV() {
        let columnHeader = ["UnitCode", "New Selling Price", "Current Selling Price", "Status", "Project Name"]; // This array holds the Column headers to be displayd
        let jsonKeys = ["Unit_Code__c", , "UnitPrice", "Selling_Price__c", "Unit_Status__c", "ProjectName"]; // This array holds the keys in the json data  
        var jsonRecordsData = this.selectedBaskedUnits;
        let csvIterativeData;
        let csvSeperator
        let newLineCharacter;
        csvSeperator = ",";
        newLineCharacter = "\n";
        csvIterativeData = "";
        csvIterativeData += columnHeader.join(csvSeperator);
        csvIterativeData += newLineCharacter;
        for (let i = 0; i < jsonRecordsData.length; i++) {
            let counter = 0;
            for (let iteratorObj in jsonKeys) {
                let dataKey = jsonKeys[iteratorObj];
                if (counter > 0) {
                    csvIterativeData += csvSeperator;
                }
                if (jsonRecordsData[i][dataKey] !== null &&
                    jsonRecordsData[i][dataKey] !== undefined
                ) {
                    csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';
                } else {
                    csvIterativeData += '""';
                }
                counter++;
            }
            csvIterativeData += newLineCharacter;
        }
        console.log("csvIterativeData", csvIterativeData);

        var element = "data:text/csv;charset=utf-8," + encodeURI(csvIterativeData);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download = 'ExportToCSV.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();


        // this.hrefdata = "data:text/csv;charset=utf-8," + encodeURI(csvIterativeData);  
        this.downloadTemplateModalFlag = false;
    }

    unitSearchbyCSV() {
        console.log("unit search csv");
        this.showCSVUploadBox = true;

    }

    readFiles() {
        [...this.template
            .querySelector('input[type="file"]')
            .files
        ].forEach(async file => {
            try {
                const result = await this.load(file);
                // Process the CSV here
                console.log('resulttt :: ', result);
                let data = JSON.parse(this.csvJSON(result));
                console.log('1-data..' + JSON.stringify(data));
                console.log('data..' + data.length);
                let listUnitCodes = [];
                let i = 0;
                for (let i = 0; i < data.length; i++) {
                    listUnitCodes.push(data[i].UnitCode);
                }
                this.unitCodesFromCSV = listUnitCodes;
                console.log('listUnitCodes ::', listUnitCodes);

                this.callSearchUnitFunction();
                // this.items = data;
                // console.log('data..' + JSON.parse(JSON.stringify(this.unitData)));
                // this.totalRecountCount = data.length; 
                // this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 

                // this.unitData = this.items.slice(0,this.pageSize);
                // this.endingRecord = this.pageSize;
                // this.columns =  [{  
                //     label: "Unit Code",  
                //     fieldName: "Unit_Code__c",  
                //     type: "text"  
                //   }];
                // this.template.querySelector('div.unitSearch').classList.remove('slds-hide');
                this.showCSVUploadBox = false;

            } catch (e) {
                // handle file load exception
            }
        });
    }
    async load(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = function () {
                resolve(reader.result);
            };
            reader.onerror = function () {
                reject(reader.error);
            };
            reader.readAsText(file);
        });
    }
    csvJSON(csv) {
        var lines = csv.split(/\r\n|\n/);
        var result = [];
        var headers = lines[0].split(",");
        console.log('headers..' + JSON.stringify(headers));

        console.log('==lines==' + JSON.stringify(lines));

        for (var i = 1; i <= lines.length - 1; i++) {
            var obj = {};
            var currentline = lines[i].split(",");
            for (var j = 0; j < headers.length; j++) {
                obj[headers[j]] = currentline[j];
            }
            result.push(obj);
        }
        console.log('result..' + JSON.stringify(result));
        //return result; //JavaScript object
        return JSON.stringify(result); //JSON
    }

    showToast(toastTitlt, toastMessage, toastVariant) {
        const event = new ShowToastEvent({
            title: toastTitlt,
            message: toastMessage,
            variant: toastVariant
        });
        this.dispatchEvent(event);
    }

    callRowAction(event) {
        const recId = event.detail.row.Id;
        const actionName = event.detail.action.name;
        console.log('==recId==' + recId);
        console.log('==actionName==' + actionName);

        this.isShowUnitDetails = true;
        this.unitRecordId = event.detail.row.Id;
        console.log('==this.isShowUnitDetails==' + this.isShowUnitDetails);
    }

    closeViewDetails(event) {
        console.log('===closeViewDetails==');
        this.isShowUnitDetails = false;
    }

    renderedCallback() {
        if (!this.stylesLoaded) {
            Promise.all([loadStyle(this, WrappedHeaderTable)])
                .then(() => {
                    console.log("Custom styles loaded");
                    this.stylesLoaded = true;
                })
                .catch((error) => {
                    console.error("Error loading custom styles");
                });
        }
    }

}