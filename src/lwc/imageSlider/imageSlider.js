/**************************************************************************************************
* Name               : ImageSlider.js                                              
* Description        : JS controller for ImageSlider component.                           
* Created Date       : 14/10/2021
* Created By         : Cloudworks                                                    
* ------------------------------------------------------------------------------------------------
* VERSION    AUTHOR      DATE            COMMENTS                                                 
* 1.0        Rohit       14/10/2021      Initial Draft.                                           
**************************************************************************************************/
import { LightningElement, api, track } from 'lwc';

// Imports
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sliderResources from '@salesforce/resourceUrl/SliderResources';
import fetImageUrls from '@salesforce/apex/ImageSliderController.fetchImageSliderMetadata';

export default class ImageSlider extends LightningElement {

    @track imageUrls = [];

    carouselInit = true;
    metadataName = 'SliderImageMetadata';

    connectedCallback() {
        this.getImageSliderMetadata();
    }

    renderedCallback() {
        console.log('...renderedCallback');
        const style = document.createElement('style');
        style.innerText = `.slds-carousel__autoplay {
            display: none;
        }
        .slds-carousel__content {
            display: none;
        }
        `;
        this.template.querySelector('lightning-carousel').appendChild(style);
    }

    getImageSliderMetadata() {
        fetImageUrls({ metadataName: this.metadataName })
            .then(result => {
                if (result.success) {
                    console.log(' fetImageUrls => success data >>> ', result.data);
                    for (let i = 0; i < result.data.length; i++) {
                        this.imageUrls.push(sliderResources + '/SliderResources' + result.data[i]);
                    }
                } else {
                    console.log('fetImageUrls => Error Message >>> ' + error);
                    this.showToast('Error!', result.message, 'error');
                }
            })
            .catch(error => {
                console.log('fetImageUrls => Error >>> ' + JSON.stringify(error));
                this.showToast('Error!', error, 'error');
            });
    }

    showToast(toastTitle, toastMessage, toastVariant) {
        const event = new ShowToastEvent({
            title: toastTitle,
            message: toastMessage,
            variant: toastVariant,
        });
        this.dispatchEvent(event);
    }
}