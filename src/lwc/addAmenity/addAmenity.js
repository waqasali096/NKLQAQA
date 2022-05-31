import { LightningElement, track, wire, api } from 'lwc';
import GETAMINITIES from '@salesforce/apex/AddAmenity.getAmenity';
import createRE from '@salesforce/apex/AddAmenity.addAmenities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
     { label: 'Name', fieldName: 'Name' }];

export default class AddAmenity extends LightningElement {

     showAmenityError = false;
     showAmenitySuccessMessage = false;
     @api listViewIds;
     @track amenities;
     error;
     columns = columns;
     selectedRecords;
     amenityToAdd = [];
     @track spinner = false;
     connectedCallback() {
          GETAMINITIES({})
               .then(result => {
                    this.amenities = result;
               })
               .catch(error => {
                    console.log('ERROR ' + error);
                    this.error = error;
               });
     }

     renderedCallback() {
          // const style = document.createElement('style');
          // style.innerText = `#auraErrorMessage {
          //      display: none;
          // }
          // `;
          // this.template.querySelector('.slds-scope').appendChild(style);
          // this.template.querySelector("#auraErrorMessage").style = 'display: none;';
     }


     hanldeRowAction() {
          this.showAmenityError = false;
     }
     processSelectedRecords() {
          this.selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
          //window.alert('id '+ this.selectedRecords[0].Name);
          if (this.selectedRecords == null || this.selectedRecords == '') {
               this.showAmenityError = true;
          }
          else {
               for (var i = 0; i < this.selectedRecords.length; ++i) {
                    //window.alert(this.selectedRecords[i].Id+' '+this.selectedRecords[i].Name);
                    this.amenityToAdd.push(this.selectedRecords[i].Name);
               }
               createRE({
                    unitIds: this.listViewIds,
                    amenityName: this.amenityToAdd
               })
                    .then(result => {
                         if (result) {
                              this.showAmenitySuccessMessage = true;
                              setTimeout(function () { window.history.back(); }, 1000);
                         }
                         else {
                              const event = new ShowToastEvent({
                                   title: 'unable to add Amenity',
                                   variant: 'Error'
                              });
                              this.dispatchEvent(event);
                         }
                    })
                    .catch(error => {
                         console.log(error);
                    })
          }

     }

     close() {
          setTimeout(
               function () {
                    window.history.back();
               },
               1000
          );
     }

}