import { LightningElement, api, wire } from 'lwc';
export default class QuickBookTimerLWC extends LightningElement {

    @api unitDetails;
    units;
    error;
    activeDateTime;
    timer;
    setTimeInterval;
    totalMilliseconds;


    connectedCallback()
    {
        this.activeDateTime = this.unitDetails.prebookingTime;
                if(this.activeDateTime){
                        this.setTimeInterval = setInterval( () => {
                        var timeToBook = new Date(this.activeDateTime);
                        var now_date = new Date();
                        var timeDiff = timeToBook.getTime()- now_date.getTime();   
                        var seconds=Math.floor(timeDiff/1000); 
                        var minutes=Math.floor(seconds/60); 
                        var hours=Math.floor(minutes/60); 
                        var days=Math.floor(hours/24); 
                        hours %=24; 
                        minutes %=60;
                        seconds %=60;
                        if(hours>=0 && minutes>=0 ){
                            this.timer=hours + ":" + minutes + ":" + seconds; 
                        }else{
                            clearInterval(this.setTimeInterval);
                            this.timer= "Time Expired";
                            this.handleChange();
                        }
                    }, 100 );
                }
    }
   
    handleChange() {
        const valueChangeEvent = new CustomEvent("valueChange",{detail:{expired:this.unitDetails}});
        this.dispatchEvent(valueChangeEvent);
    }
     
}