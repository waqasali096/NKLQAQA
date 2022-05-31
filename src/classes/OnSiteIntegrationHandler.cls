@RestResource(urlMapping='/OnSiteCustomerDetails/')
global class OnSiteIntegrationHandler {
    
    @HttpPost
    global static AccountWrapper getCustomerInfo(String projectCode, String modifiedDateTime){
        AccountWrapper acctWrapper = new AccountWrapper();
        String modDate;
        
        if(projectCode==null){
            acctWrapper.Status = 'Failed';
            acctWrapper.Message = 'Please send the project code.';
            acctWrapper.CustomerDetails = null;
            return acctWrapper;
        }
        if(modifiedDateTime==null ){
            acctWrapper.Status = 'Failed';
            acctWrapper.Message = 'Please send the modified date time.';
            acctWrapper.CustomerDetails = null;
            return acctWrapper;
        }else{
            try{                
                Datetime dateTimeInGMT= DateTime.parse(modifiedDateTime);
                modDate = dateTimeInGMT.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');                
            }catch(Exception e){
                acctWrapper.Status = 'Failed';
                acctWrapper.Message = 'Please provide proper date format: eg. MM/DD/YYYY, HH:MM A (01/30/2020,12:00 AM)';
                acctWrapper.CustomerDetails = null;
                return acctWrapper;
            }
        }
        
        try{            
            String query = 'SELECT Account__c, Account__r.Name, Account__r.Primary_Email__c,  Account__r.Primary_Mobile__c,  Unit__r.unit_code__c, Modified_Date_Time__c FROM Property__c '+
                +' WHERE Active__c= true AND Modified_Date_Time__c >= ' + modDate + ' AND Project_Code__c =: projectCode';
            List<Property__c> propertyList = Database.Query(query);
            System.debug('@@@ '+ propertyList);
            
            if(propertyList.size()>0){
                List<CustomerDetails> custList = new List<CustomerDetails>();
                
                for(Property__c pr : propertyList){
                    CustomerDetails cus = new CustomerDetails(
                        pr.Account__r.Name, 
                        pr.Account__r.Primary_Email__c, 
                        String.valueOf(pr.Account__r.Primary_Mobile__c), 
                        String.valueOf(pr.Unit__r.unit_code__c),
                        pr.Modified_Date_Time__c);
                    
                    custList.add(cus);
                }
                acctWrapper.Status = 'Success';
                acctWrapper.Message = '';
                acctWrapper.CustomerDetails = custList;
            }else{
                acctWrapper.Status = 'Failed';
                acctWrapper.Message = 'No Customer Found for given unit codes / modified date time.';
                
            }
            
        } catch(Exception e){
            System.debug('Error:  ' + e.getMessage());
            acctWrapper.Status = 'Failed';
            acctWrapper.Message = 'Error Occured: '+ e.getMessage() + '. Please contact System Administrator for more help.';
            
        }
        return acctWrapper;
    }
    //Response Wrapper
    global class AccountWrapper{        
        global String Status{get; set;}
        global String Message{get; set;}
        global List<CustomerDetails> CustomerDetails{get; set;}
    }
    
    
    global class CustomerDetails{
        global String Name{get; set;}
        global String Email{get; set;}
        global String Mobile{get; set;}
        global String UnitCode{get; set;}
        global String ModifiedDateTime{get;set;}
        //global String Message{get; set;}
        
        global CustomerDetails(String Name, String Email, String Mobile, String UnitCode, DateTime ModifiedDateTime){
            this.Name = Name;
            this.Email = Email;
            this.Mobile = Mobile;
            this.UnitCode = UnitCode;
            this.ModifiedDateTime = null;
            if(ModifiedDateTime!=null){
                this.ModifiedDateTime = ModifiedDateTime.format('dd/MM/YYYY hh:mm a');
            }
            //this.Message = Message;
        }
    }
}