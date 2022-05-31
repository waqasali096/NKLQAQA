/*
@Author : Taha Hamid
@CreatedDate: 06/05/2022
@ This class will be called by the 3rd party system to get the tenancy details (opportunity)
*/
@RestResource(urlMapping='/getTenancyDetails/*')
global class RetrieveTenancyDetailCls {
    /*
    Method Description: This method will be used to get opportunity and related record details
    for external system. 
    */
    @HttpPost
    global static leaseOutputWrapper getDetails(){
        //Initiating the wrappers
        leaseInputWrapper leaseInput = new leaseInputWrapper();
        leaseOutputWrapper leaseOutput = new leaseOutputWrapper();          
        Boolean IsRecordExistFlag = false;
        RestRequest request = RestContext.request;    
        RestContext.response.addHeader('Content-Type', 'application/json');
 
        try{
            // Below wrapper will store the lease number came as a response 	
            leaseInput = (leaseInputWrapper )System.JSON.deserialize(RestContext.request.requestBody.toString(),leaseInputWrapper.class);
            string leaseNumber = leaseInput.leaseNumber;
            string locationCodeString = '';
            
            Opportunity opportunityRec = new Opportunity();

            // Querying the fields related to lease number
            for(Opportunity oppRec : [Select StageName, Lease_Start_Date__c, Lease_End_Date__c,
                                      Opportunity.AccountId, Account.Primary_Email__c,
                                      Account.Primary_Country_Code__c, Account.Primary_Mobile__c,
                                      Final_Lease_Amount__c,Security_Deposit__c,Total_Charges_Amount__c
                                      ,(select id,Unit__r.Unit_Code__c from Unit_Plans__r)
                                      from Opportunity where Leasing_Number__c =:leaseNumber or Lease_Number__c =:leaseNumber])
            {
                IsRecordExistFlag = true;           

                opportunityRec = oppRec;

                for(Unit_Plan__c unitRec: oppRec.Unit_Plans__r)
                {
                    locationCodeString = locationCodeString + unitRec.Unit__r.Unit_Code__c;
                }

            }	

            if(locationCodeString != '' && locationCodeString.contains(','))
            {
                locationCodeString = locationCodeString.removeEnd(',');                
            }

            for(Address__c addressRec : [Select Street__c, Postal_Code__c, PO_Box__c,City__c, Country__c from Address__c where Primary__c = True 
                                         And Account__c = :opportunityRec.AccountId ])
            {
                //Mapping the fields in wrapper
                
                leaseOutput.Address = addressRec.Street__c +' '+ addressRec.Postal_Code__c +' '+ addressRec.PO_Box__c +' '+ addressRec.City__c +' '+ addressRec.Country__c;
                
            }  
            leaseOutput.leaseStatus = opportunityRec.StageName; 
            leaseOutput.leaseCommencementDate = opportunityRec.Lease_Start_Date__c;
            leaseOutput.leaseTerminationDate = opportunityRec.Lease_End_Date__c;
            leaseOutput.Mobile = opportunityRec.Account.Primary_Country_Code__c + opportunityRec.Account.Primary_Mobile__c;
            leaseOutput.Email = opportunityRec.Account.Primary_Email__c;
            leaseOutput.propertyCode = locationCodeString;
            leaseOutput.receiptNumber = '';
            leaseOutput.locationCode = locationCodeString;
            leaseOutput.rentalAmount = opportunityRec.Final_Lease_Amount__c != null ? opportunityRec.Final_Lease_Amount__c : 0.00;
            leaseOutput.securityDepositAmount = opportunityRec.Security_Deposit__c != null ? opportunityRec.Security_Deposit__c : 0.00;
            leaseOutput.totalAdditionalCharges = opportunityRec.Total_Charges_Amount__c != null ? opportunityRec.Total_Charges_Amount__c : 0.00;
            leaseOutput.totalAmount = leaseOutput.rentalAmount + leaseOutput.securityDepositAmount + leaseOutput.totalAdditionalCharges;
            
            if(!IsRecordExistFlag)
            {
                 //Mapping Output wrapper	
                 leaseOutput.message = 'No Record Found';
                 leaseOutput.responseCode = 204;        
            } else{
                 //Mapping Output wrapper	
                leaseOutput.message = 'Success';
                leaseOutput.responseCode = 200; 
            }      

            return leaseOutput;
            
            
        }
        catch(Exception ex){
            //Mapping Output wrapper	
            leaseOutput.message = ex.getMessage();
            leaseOutput.responseCode = 400;           
            system.debug('Taha Error Message: '+ex.getMessage());

            return leaseOutput;
            
        }             
    }

    /*
    This wrapper will contain the responce(LeaseNumber) from callout 
    */	
    global class leaseInputWrapper {
        
        global String leaseNumber;
    }
    
    /*
    This wrapper will contain the field mapping 
    */
    global class leaseOutputWrapper {
        global String leaseStatus;
        global Date leaseCommencementDate;
        global Date leaseTerminationDate;
        global String Address; 
        global String Mobile;
        global String Email;
        global String propertyCode;
        global String receiptNumber;
        global String message;
        global Integer responseCode;
        global string locationCode;
        global decimal rentalAmount;
        global decimal securityDepositAmount;
        global decimal totalAdditionalCharges;
        global decimal totalAmount;
    }

    
}