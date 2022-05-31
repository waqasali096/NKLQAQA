public without sharing class LeaseRenewalResponseCapture {
    public String oppRecId;
    
    public LeaseRenewalResponseCapture(ApexPages.StandardController controller){
        oppRecId=System.currentPageReference().getParameters().get('Id');
        system.debug('Inside the Constructor'+oppRecId);

    }
    //system.debug('oppRecId>>>>'+oppRecId);
   /* public PageReference captureResponse(){
        system.debug('Inside the captureResponse>>>>'+oppRecId);
        Opportunity oppRec=new Opportunity();
    oppRec.id=oppRecId;
    oppRec.Renewal_customer_response__c='Agree';
        
        update oppRec;
         //DateTime start = System.Now();
        //while(System.Now().getTime()< start.getTime()+2000){} //Delay
        //calling again to get the status
        //getQueryStatus(taskId);
    return new PageReference('https://www.nakheel.com/en');//('javascript:window.close()');
    
    } */
     public void captureResponse(){
        system.debug('Inside the captureResponse>>>>'+oppRecId);
        Opportunity oppRec=new Opportunity();
    oppRec.id=oppRecId;
    oppRec.Renewal_customer_response__c='Agree';
        
        update oppRec;
         //DateTime start = System.Now();
        //while(System.Now().getTime()< start.getTime()+2000){} //Delay
        //calling again to get the status
        //getQueryStatus(taskId);
    //return new PageReference('https://www.nakheel.com/en');//('javascript:window.close()');
    
    }
    public void captureResponseDisagree(){
        system.debug('Inside the captureResponseDisagree>>>'+oppRecId);
        Opportunity oppRec=new Opportunity();
    oppRec.id=oppRecId;
    oppRec.Renewal_customer_response__c='Disagree';
        update oppRec;
    //return new PageReference('javascript:window.close()');
    
    } 
}