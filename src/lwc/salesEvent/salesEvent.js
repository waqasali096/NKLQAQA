import { LightningElement, api, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import Campaign_Object from '@salesforce/schema/Sales_Event__c';
import Name_Field from '@salesforce/schema/Sales_Event__c.Name';
import Start_Date from '@salesforce/schema/Sales_Event__c.Start_Date__c';
import End_Date from '@salesforce/schema/Sales_Event__c.End_Date__c';
import Project from '@salesforce/schema/Sales_Event__c.Project__c';
//import Project from '@salesforce/schema/Campaign.Project__c';

import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import retrieveRecords from '@salesforce/apex/MultiSelectLookupController.retrieveRecords';
import addSalesExecutives from '@salesforce/apex/MultiSelectLookupController.addSalesExecutives';
import getClusterAndBuildings from '@salesforce/apex/MultiSelectLookupController.getClusterAndBuildings';
import getAllRelatedUnits from '@salesforce/apex/MultiSelectLookupController.getAllRelatedUnits';
import UserPreferencesDisableMentionsPostEmail from '@salesforce/schema/User.UserPreferencesDisableMentionsPostEmail';
import pushNewUnitToCampaign from '@salesforce/apex/MultiSelectLookupController.pushNewUnitToCampaign';


export default class SalesEvent extends LightningElement {

    //@api objectApiName;
    @api recordId; //stores the recordId
    @track currentstep; //stores the lightning progress bar step
    @track campaignIdCreate; 
    @track addExecutives = []; //list to keep all the users that will be added
    @track accountId; //this accountId is a campaign Id

    @track selectedItemsToDisplay = []; //to display items in comma-delimited way
    @track values = []; //stores the labels in this array
    @track isItemExists = false; //flag to check if message can be displayed
    @track clusterTobuildingValues = [];
    @track clusterValues = [];
    @track unitValues=[];
    @track selectedCluster='';
    @track selectedBuilding='';
    @track selectedUnits = [];
    isRenderedCallbackExecuted = false;

    @track columns = [{
        label:'Name',
        fieldName:'Name'
    },{
        label:'Leasing Status',
        fieldName:'Leasing_Status__c'
    },{
        label:'Sales Status',
        fieldName:'Sales_Status__c'
    }];

    
    campaignObject = Campaign_Object;
    campaignFields = [Name_Field, Start_Date, End_Date];

    campaignName;
    startDate;
    endDate;
    project;

    renderedCallback(){
        if(this.isRenderedCallbackExecuted){
            return;
        }
        //getBuildings({})
        console.log('we are in rendered callback');
        console.log(JSON.stringify(this.recordId));
        this.project = this.recordId;
        //
        if(typeof this.recordId!== "undefined"){
            this.isRenderedCallbackExecuted=true;
            console.log(this.recordId.length);
            this.clusterValues=[];
            getClusterAndBuildings({projectId: this.recordId})
                .then(result=>{
                    if(result.length>0){
                        console.log(result);
                        result.map(resElement=>{
                            //prepare items array using spread operator which will be used as checkbox options
                            console.log(resElement);
                            this.clusterValues = [...this.clusterValues, {value:resElement.Id,
                                                                            label:resElement.Name,
                                                                        buildings: resElement.Buildings__r}];
                        });
                        console.log("@@@"+JSON.stringify(typeof this.clusterValues));
                    }
                })
        }
        
    }

    clusterSelectChangeHandler(e){
        //console.log(this.template.querySelector('selected-cluster'));
        //this.selectedCluster=null;
        this.clusterTobuildingValues=[];
        //console.log('$$$'+this.selectedCluster);
        //console.log('@@@@'+JSON.stringify(e.detail.value));
        //console.log(this.clusterValues);
        for(let i=0;i< this.clusterValues.length;i++){
            if(this.clusterValues[i]['value']=== e.detail.value){
                this.selectedCluster = this.clusterValues[i];
                break;
            }
        }
        //console.log(this.selectedCluster['buildings']);
        if(typeof this.selectedCluster['buildings']!='undefined'){
            this.selectedCluster['buildings'].map(buildingElement=>{
                console.log('In selected Cluster');
                console.log(buildingElement);
                this.clusterTobuildingValues = [...this.clusterTobuildingValues, {value:buildingElement['Id'],
                                                                                    label:buildingElement['Name']}];
            });
        }
        
    }

    buildingSelectChangeHandler(e){
        for(let i=0;i<this.clusterTobuildingValues.length;i++){
            if(this.clusterTobuildingValues[i]['value']===e.detail.value){
                this.selectedBuilding = this.clusterTobuildingValues[i];
                break;
            }
        }
        this.unitValues=[];
        getAllRelatedUnits({clusterId:this.selectedCluster['value'],
                            buildingId:this.selectedBuilding['value']})
                            .then(result=>{
                                console.log(result);
                                if(result.length>0){
                                    this.unitValues = result;
                                }
                            })
        
    }

    getUnitsHandler(e){
        console.log('In unit handler');
        console.log(this.selectedCluster['value']);
        console.log(this.selectedBuilding['value']);
                            
        console.log(this.unitValues);
    }

    handleName(e){
        //console.log("This is running");
        this.campaignName = e.target.value;
        //this.campaignNae = e.tartget.value;
    }
    handleStartDate(e){
        this.startDate = e.target.value;
    }
    handleEndDate(e){
        this.endDate = e.target.value;
        if(this.startDate>this.endDate){
            alert("End Date must be after Start Date!");
            e.target.value = null;
            this.endDate = null;
        }
    }
    /*handleChange(e){
        if(e.tartget.name === "campaignName"){
            this.campaignName = e.target.value;

        }else if(e.target.name === "startDate"){
            this.startDate = e.target.value;
        }else if(e.target.name === "endDate"){
            this.endDate = e.target.value;
        }
    }*/

    getUnitId(e){
        const selectedRows = e.detail.selectedRows;
        console.log(selectedRows.target);
    }

    createCampaingAndUnits(){
        console.log("hello");
        const Campaignfields = {};
        console.log(Campaignfields);
        Campaignfields[Name_Field.fieldApiName] = this.campaignName;
        Campaignfields[Start_Date.fieldApiName] = this.startDate;
        Campaignfields[End_Date.fieldApiName] = this.endDate;
        Campaignfields[Project.fieldApiName] = this.project;
        console.log("@we are here");
        /*if(objectApiName==='Project__c'){
            fields[Project.fieldApiName] = this.project;
        }*/
        console.log("Heelloo");
        console.log(Campaignfields.Name);
        const recordInput = {
            apiName : Campaign_Object.objectApiName,
            fields : Campaignfields
        };
        console.log(recordInput);
            createRecord(recordInput)
                .then(beep => {
                    this.accountId = beep.id;
                    console.log('@@@');
                    console.log(this.accountId);
                    //this.currentstep='2';
                    //this.template.querySelector('div.campaign').classList.add('slds-hide');
                    console.log("Campaign was successfully created.");
                    //this.template.querySelector('div.campaignButton').classList.add('slds-hide');
                    //this.template.querySelector('div.executives').classList.remove('slds-hide');
                    
                    var selectedRows = this.template.querySelector("lightning-datatable").getSelectedRows();
                    console.log(selectedRows);
                    console.log('4444');
                    this.selectedUnits = selectedRows;
                    //console.log(JSON.stringify(this.selectedUnits[0]['Id']));
                    var unitId =[];
                    for(let i=0;i<this.selectedUnits.length;i++){
                        unitId.push(this.selectedUnits[i]['Id']);
                    }
                    if(unitId.length>0){
                    pushNewUnitToCampaign({campaignId:this.accountId,
                                            unitIdList:unitId})
                                            .then(result=>{
                                                console.log('Unit Pushed Successfully!');
                                            })
                                                .catch(error=>{
                                                    console.log('Something went wrong while pushing the units');
                                                });
                                            }
                    this.currentstep='2';
                    this.template.querySelector('div.campaign').classList.add('slds-hide');                       
                    this.template.querySelector('div.executives').classList.remove('slds-hide');   
                    
                })
                .catch(error=>{
                    console.log(JSON.stringify(error));
                    console.log('Something went wrong'+error);
                });
    }

    addExecutivesHandler(){
        console.log("hello");
        //this.template.querySelector('div.executives').classList.add('slds-hide');
        //this.template.querySelector('div.units').classList.remove('slds-hide');
        console.log("Hello we are in add Exec");
        console.log(this.addExecutives);
        console.log("Tha's it!");
        addSalesExecutives({campaignId: this.accountId,
                            userIdList: this.addExecutives})
                        .then(result=>{
                            console.log("Success in creating the records");
                            window.history.back();
                        })
                        .catch(error=>{
                            console.log("Error");
                        })

    }

    /*addUnits(){
        this.template.querySelector('div.executives').classList.add('slds-hide');
        this.template.querySelector('div-units').classList.add('slds-hide');
    }*/

    //captures the retrieve event propagated from lookup component
    selectItemEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);        
    }

    //captures the remove event propagated from lookup component
    deleteItemEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);
    }

    //displays the items in comma-delimited way
    displayItem(args){
        console.log('>>'+JSON.stringify(args));
        this.values = []; //initialize first
        console.log("we will display if we get ids");
        this.addExecutives = [];
        let localValueId = [];
        args.map(element=>{
            console.log('@@@'+JSON.stringify(element.value));
            localValueId.push(element.value);
            //this.addExecutives.push(element.value);
            console.log("we want to check here");
            console.log('&&&'+JSON.stringify(this.addExecutives));
            this.values.push(element.label);
        });
        console.log('Local Ids'+JSON.stringify(localValueId));
        this.addExecutives = localValueId;
        console.log('Local Ids'+JSON.stringify(this.addExecutives));
        this.isItemExists = (args.length>0);
        this.selectedItemsToDisplay = this.values.join(', ');
    }
}