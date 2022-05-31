import { LightningElement,api } from 'lwc';
import retriveFloorImages from '@salesforce/apex/ImageQueryController.retriveFloorImages';
import retriveUnitImages from '@salesforce/apex/ImageQueryController.retriveUnitImages';
export default class FloorDetailsComponent extends LightningElement {

@api recordId;
urls;
unit_urls;
error;
unit_error;
index = -1;

    connectedCallback(){
        retriveFloorImages({recordId : this.recordId})
        .then((result) => {
            console.log('@@@ '+ result);
            if(result != null){
                this.urls = result;
                this.error = undefined;
            }else{
                console.log('@@@ '+ result);
                this.error = error;
                this.urls = undefined;
            }
            
        })
        .catch((error) => {
            this.error = error;
            this.urls = undefined;
        });

        retriveUnitImages({recordId : this.recordId})
        .then((result)=>{
            debugger;
            console.log('@@@ '+ result);
            if(result != null){
                this.unit_urls = result;
                this.unit_error = undefined;
            }else{
                this.error = error;
                this.urls = undefined;
            }
            
        })
        .catch((error)=>{
            this.unit_error = error;
            this.unit_urls = undefined;
        });
    }

    get indexValue(){
            this.increaseIndex();
            return 'Image '+ (this.index + 1);
    }

    increaseIndex(){
        this.index ++;
        console.log('Increased Index : '+this.index);
    }
}