public class Ejari_XMLConstructorUtil {
    
    /*
    Description: As Person and Org XML have number of different tags.
    Below Two methods are defined for person and org separately.
    1-CreatePendingTenancyContractRequest_Person
    2-CreatePendingTenancyContractRequest_ORG
    */  public static String CreatePendingTenancyContractRequest_Person(Opportunity opp, Lease_Contract__c cont, Account acc, 
                                                                    list<Unit__c> unitList,Ejari_Integration_Credential__mdt e_IntgMDT, 
                                                                    list<Unit_Plan__c> lstunitPlan,Address__c address){
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"';
                body += ' xmlns:tem="http://tempuri.org/"';
                body += ' xmlns:ep4="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities"';
                body += ' xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays"';
                body += ' xmlns:ep41="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities.Common">';
            body += '<soapenv:Header/>' + '<soapenv:Body>';               
        try{            
            body += '<tem:CreatePendingTenancyContractRequest>';
                body+= '<tem:tenancyContract>';
                    body+= '<ep4:ContractAmount>'+(opp.Final_Lease_Amount__c != null ? opp.Final_Lease_Amount__c : 0.00)+'</ep4:ContractAmount>'; // opp.finalLeaseAmount Befor: opp.Base_Lease_Amount__c
                    body+= '<ep4:ContractEndDate>'+returnDate(cont.Contract_End__c)+'</ep4:ContractEndDate>';
                    body+= '<ep4:ContractStartDate>'+returnDate(cont.Contract_Start__c)+'</ep4:ContractStartDate>';
            		if(opp.Grace_End_Date__c != null && opp.Grace_Start_Date__c != null){
                        body+= '<ep4:GraceEndDate>'+returnDateOnly(opp.Grace_End_Date__c)+'</ep4:GraceEndDate>'; // required
                        body+= '<ep4:GraceStartDate>'+returnDateOnly(opp.Grace_Start_Date__c)+'</ep4:GraceStartDate>'; //required
                    }
                    body+= '<ep4:PaymentCount>'+returnNumberofCheques(lstunitPlan)+'</ep4:PaymentCount>'; // opportunity unit(unit plan).number of cheques
                    body+= '<ep4:PropertyInformations>';
                        for(Unit__c un: unitList){
                            body+= '<ep4:PropertyDetails>';// -- repeat this tag
                                body+= '<ep4:AnnualRent>'+returnRentAmount(lstunitPlan,un.Unit_Code__c)+'</ep4:AnnualRent>';
                                body+= '<ep4:ApprovalRefNumber>'+(un.DLD_Approval_Ref_Number__c != null ? un.DLD_Approval_Ref_Number__c:'')+'</ep4:ApprovalRefNumber>'; 
                                body+= '<ep4:UserRefNumber>'+(un.Unit_Code__c !=null ? un.Unit_Code__c : '')+'</ep4:UserRefNumber>'; //Unit.UnitCode Before: opp.Opportunity_Number__c
                            body+= '</ep4:PropertyDetails>';
                        }
                    body+= '</ep4:PropertyInformations>';
                    body+= '<ep4:ReferenceNumber>'+(opp.Opportunity_Number__c != null?opp.Opportunity_Number__c:'')+'</ep4:ReferenceNumber>';
                    body+= '<ep4:RentInformations>';
                        body+= '<ep4:RentInfo>';
                            body+= '<ep4:ActualValue>'+(opp.Base_Lease_Amount__c!=null?opp.Base_Lease_Amount__c:0.00)+'</ep4:ActualValue>'; //opp.finalleaseamount Before: opp.Base_Lease_Amount__c
                            body+= '<ep4:DiscountType>'+(opp.Total_Discount_Amount__c>0?'2':'1')+'</ep4:DiscountType>'; // total discount amount on opportunity -- need the logic on that
                            body+= '<ep4:DiscountValue>'+(opp.Total_Discount_Amount__c!=null?opp.Total_Discount_Amount__c:0.00)+'</ep4:DiscountValue>'; // total discount amount on opportunity -- need the logic on that
                            body+= '<ep4:FromDate>'+returnDate(cont.Contract_Start__c)+'</ep4:FromDate>';
                            body+= '<ep4:ToDate>'+returnDate(cont.Contract_End__c)+'</ep4:ToDate>';
                            body+= '<ep4:Value>'+(opp.Final_Lease_Amount__c !=null?opp.Final_Lease_Amount__c:0.00)+'</ep4:Value>';
                        body+= '</ep4:RentInfo>';
                    body+= '</ep4:RentInformations>';
                    body+= '<ep4:SecurityDeposit>'+(opp.Security_Deposit__c!=null?opp.Security_Deposit__c:0.00)+'</ep4:SecurityDeposit>'; //opp.SecurityDeposit - need new field 
                    body+= '<ep4:TenantInformations>';
                        body+= '<ep4:TenantInfo>';
                            body+= '<ep4:Address>'+(address.Name !=null ?address.Name + ' ' +address.City__c:'')+'</ep4:Address>'; // address object name + city Before: acc.PersonMailingStreet
                            body+= '<ep4:Country>'+(address.Country__c !=null?address.Country__c:'')+'</ep4:Country>'; // address object
                            body+= '<ep4:Email>'+(acc.Primary_Email__c!=null?acc.Primary_Email__c:'')+'</ep4:Email>';
                            body+= '<ep4:MobileNumber>'+returnMobileNumber(acc.Primary_Mobile__c)+'</ep4:MobileNumber>';
                            body+= '<ep4:NationalIDNumber>'+(acc.Emirates_Ids__c!=null?acc.Emirates_Ids__c.replaceAll('-',''):'')+'</ep4:NationalIDNumber>';
                            body+= '<ep4:POBox>'+(address.Postal_Code__c !=null ?address.Postal_Code__c :'')+'</ep4:POBox>';
                            body+= '<ep4:PassportExpiryDate>'+returnDate(acc.Passport_Expiry_Date__c)+'</ep4:PassportExpiryDate>';
                            body+= '<ep4:PassportIssueDate>'+returnDate(acc.Passport_Issue_Date__c)+'</ep4:PassportIssueDate>';
                            body+= '<ep4:PassportNo>'+(acc.Passport_Number__c!=null?acc.Passport_Number__c:'')+'</ep4:PassportNo>';
                            body+= '<ep4:TenantName>'+acc.FirstName + ' ' + acc.LastName+'</ep4:TenantName>';
                            body+= '<ep4:TenantNameAr>'+(acc.Arabic_Name__c!=null?acc.Arabic_Name__c:'')+'</ep4:TenantNameAr>'; // make this field required
                            if(acc.Visa_Number__c != null){
                                body+= '<ep4:VisaExpiryDate>'+returnDate(acc.Visa_End_Date__c)+'</ep4:VisaExpiryDate>';
                            	body+= '<ep4:VisaNo>'+(acc.Visa_Number__c!=null?acc.Visa_Number__c:'')+'</ep4:VisaNo>';
                            	body+= '<ep4:VisaStartDate>'+returnDate(acc.Visa_Start_Date__c)+'</ep4:VisaStartDate>';
                            }
                        body+= '</ep4:TenantInfo>';
                    body+= '</ep4:TenantInformations>';
                    body+= '<ep4:UsageInformations>';
                        for(Unit__c un: unitList){
                            body+= '<ep4:UsageInfo>'; //-- repeat this table
                                body+= '<ep4:AnnualRent>'+returnRentAmount(lstunitPlan,un.Unit_Code__c)+'</ep4:AnnualRent>';
                                body+= '<ep4:ApprovalRefNumber>'+(un.DLD_Approval_Ref_Number__c != null ? un.DLD_Approval_Ref_Number__c:'')+'</ep4:ApprovalRefNumber>'; 
                                body+= '<ep4:UserRefNumber>'+(un.Unit_Code__c !=null ? un.Unit_Code__c : '')+'</ep4:UserRefNumber>'; //Unit.UnitCode Before: opp.Opportunity_Number__c
                            body+= '</ep4:UsageInfo>';
                        }
                    body+= '</ep4:UsageInformations>';
                body+= '</tem:tenancyContract>';
                body+= '<tem:serviceCredential>';
                    body+= '<ep41:Password>'+e_IntgMDT.Password__c+'</ep41:Password>';
                    body+= '<ep41:ResponseStatusList/>';
                    body+= '<ep41:UserName>'+e_IntgMDT.User_Name__c+'</ep41:UserName>';
                    body+= '<ep41:UserReferenceNumber>'+(opp.Lease_Number__c !=null ? opp.Lease_Number__c:'')+'</ep41:UserReferenceNumber>'; //Unit.UnitCode Before: opp.Opportunity_Number__c
                body+= '</tem:serviceCredential>';
            body += '</tem:CreatePendingTenancyContractRequest>';
            body+= '</soapenv:Body>';
            body+= '</soapenv:Envelope>';
            return body;
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return null;
        }
    }
    public static String CreatePendingTenancyContractRequest_ORG(Opportunity opp, Lease_Contract__c cont, Account acc, list<Unit__c> unitList,
                                                                 Ejari_Integration_Credential__mdt e_IntgMDT,Contact con, 
                                                                 list<Unit_Plan__c> lstunitPlan, Address__c address){
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"';
                body += ' xmlns:tem="http://tempuri.org/"';
                body += ' xmlns:ep4="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities"';
                body += ' xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays"';
                body += ' xmlns:ep41="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities.Common">';
            body += '<soapenv:Header/>' + '<soapenv:Body>';
        try{
            body += '<tem:CreatePendingTenancyContractRequest>';
                body+= '<tem:tenancyContract>';
                    body+= '<ep4:ContractAmount>'+(opp.Final_Lease_Amount__c!=null?opp.Final_Lease_Amount__c:0.00)+'</ep4:ContractAmount>'; // opp.finalleaseamount
                    body+= '<ep4:ContractEndDate>'+returnDate(cont.Contract_End__c)+'</ep4:ContractEndDate>';
                    body+= '<ep4:ContractStartDate>'+returnDate(cont.Contract_Start__c)+'</ep4:ContractStartDate>';  
                    if(opp.Grace_End_Date__c != null && opp.Grace_Start_Date__c != null){
                        body+= '<ep4:GraceEndDate>'+returnDateOnly(opp.Grace_End_Date__c)+'</ep4:GraceEndDate>'; // required
                        body+= '<ep4:GraceStartDate>'+returnDateOnly(opp.Grace_Start_Date__c)+'</ep4:GraceStartDate>'; //required
                    }    
                    body+= '<ep4:PaymentCount>'+returnNumberofCheques(lstunitPlan)+'</ep4:PaymentCount>'; // get it from opportunity payment - number of cheques
                    body+= '<ep4:PropertyInformations>';
                    for(Unit__c un: unitList){    
                        body+= '<ep4:PropertyDetails>';
                            body+= '<ep4:AnnualRent>'+returnRentAmount(lstunitPlan,un.Unit_Code__c)+'</ep4:AnnualRent>';
                            body+= '<ep4:ApprovalRefNumber>'+(un.DLD_Approval_Ref_Number__c != null ? un.DLD_Approval_Ref_Number__c:'')+'</ep4:ApprovalRefNumber>';
                            body+= '<ep4:DEWANumber>'+(un.DEWA_Number__c !=null?un.DEWA_Number__c:'')+'</ep4:DEWANumber>'; // get it from unit.DEWA_Number__c Before:cont.DEWA_Registration__c 
                        body+= '</ep4:PropertyDetails>';
                    }
                    body+= '</ep4:PropertyInformations>';
                    body+= '<ep4:ReferenceNumber>'+(opp.Opportunity_Number__c!=null?opp.Opportunity_Number__c:'')+'</ep4:ReferenceNumber>';
                    body+= '<ep4:RentInformations>';
                        body+= '<ep4:RentInfo>';
                            body+= '<ep4:ActualValue>'+(opp.Final_Lease_Amount__c!=null?opp.Final_Lease_Amount__c:0.00)+'</ep4:ActualValue>';
                            body+= '<ep4:DiscountType>'+(opp.Total_Discount_Amount__c>0?'2':'1')+'</ep4:DiscountType>';
                            body+= '<ep4:DiscountValue>'+(opp.Total_Discount_Amount__c!=null?opp.Total_Discount_Amount__c:000)+'</ep4:DiscountValue>';
                            body+= '<ep4:FromDate>'+returnDate(cont.Contract_Start__c)+'</ep4:FromDate>';
                            body+= '<ep4:ToDate>'+returnDate(cont.Contract_End__c)+'</ep4:ToDate>';
                            body+= '<ep4:Value>'+(opp.Base_Lease_Amount__c!=null?opp.Base_Lease_Amount__c:0.00)+'</ep4:Value>';
                        body+= '</ep4:RentInfo>';
                    body+= '</ep4:RentInformations>';
                    body+= '<ep4:SecurityDeposit>'+(opp.Security_Deposit__c!=null?opp.Security_Deposit__c:0.00)+'</ep4:SecurityDeposit>';
                    body+= '<ep4:TenantInformations>';
                        body+= '<ep4:TenantInfo>';
                            body+= '<ep4:Address>'+(address.Name !=null ?address.Name + ' ' +address.City__c:'')+'</ep4:Address>'; // address object
                            body+= '<ep4:ContactPersonMobile>'+returnMobileNumber(con.MobilePhone)+'</ep4:ContactPersonMobile>'; 
                            body+= '<ep4:ContactPersonName>'+con.FirstName+' '+con.LastName+'</ep4:ContactPersonName>'; 
                            body+= '<ep4:Email>'+(acc.Primary_Email__c!=null?acc.Primary_Email__c:'')+'</ep4:Email>'; 
                            body+= '<ep4:LicenseExpiryDate>'+dateFormat(acc.Trade_License_End_Date__c)+'</ep4:LicenseExpiryDate>'; //required
                            body+= '<ep4:LicenseIssueDate>'+dateFormat(acc.Trade_License_Start_Date__c)+'</ep4:LicenseIssueDate>'; // required
                            body+= '<ep4:MobileNumber>'+returnMobileNumber(acc.Primary_Mobile__c)+'</ep4:MobileNumber>';
                            body+= '<ep4:POBox>'+(address.Postal_Code__c !=null ?address.Postal_Code__c :'')+'</ep4:POBox>';
                            body+= '<ep4:TenantName>'+(acc.Name!=null?acc.Name:'')+'</ep4:TenantName>'; // account name 
                            body+= '<ep4:TenantNameAr>'+(acc.Arabic_Name__c!=null?acc.Arabic_Name__c:'')+'</ep4:TenantNameAr>'; // account field  Before:con.Tennant_Name_Ar__c
                            body+= '<ep4:TradeLicenseIssuer>'+(acc.Trade_License_Issuer__c!=null?acc.Trade_License_Issuer__c:'')+'</ep4:TradeLicenseIssuer>'; // new object Trade License Issuer check ejari document, ejari code
                            body+= '<ep4:TradeLicenseNumber>'+(acc.Trade_License_Number__c!=null?acc.Trade_License_Number__c:'')+'</ep4:TradeLicenseNumber>';
                        body+= '</ep4:TenantInfo>';
                    body+= '</ep4:TenantInformations>';
                    body+= '<ep4:UsageInformations>';
                    for(Unit__c un: unitList){
                        body+= '<ep4:UsageInfo>'; //-- repeat this table
                            body+= '<ep4:AnnualRent>'+returnRentAmount(lstunitPlan,un.Unit_Code__c)+'</ep4:AnnualRent>';
                            body+= '<ep4:ApprovalRefNumber>'+(un.DLD_Approval_Ref_Number__c != null ? un.DLD_Approval_Ref_Number__c:'')+'</ep4:ApprovalRefNumber>'; //-- lookup table 
                            body+= '<ep4:UserRefNumber>'+(un.Unit_Code__c!=null?un.Unit_Code__c:'')+'</ep4:UserRefNumber>'; //-- lease number
                        body+= '</ep4:UsageInfo>';
                    }
                    body+= '</ep4:UsageInformations>';
                body+= '</tem:tenancyContract>';
                body+= '<tem:serviceCredential>';
                    body+= '<ep41:Password>'+e_IntgMDT.Password__c+'</ep41:Password>';
                    body+= '<ep41:ResponseStatusList/>';
                    body+= '<ep41:UserName>'+e_IntgMDT.User_Name__c+'</ep41:UserName>';
                    body+= '<ep41:UserReferenceNumber>'+(opp.Lease_Number__c!=null?opp.Lease_Number__c:'')+'</ep41:UserReferenceNumber>';
                body+= '</tem:serviceCredential>';
            body += '</tem:CreatePendingTenancyContractRequest>';
            body+= '</soapenv:Body>';
            body+= '</soapenv:Envelope>';
            return body; 
            
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return null;
        }
    }
    
   
    public static String PrintTcByContractNumber(Opportunity Opp, Lease_Contract__c cont,Ejari_Integration_Credential__mdt intgCreds){
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:ep4="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities.Common" xmlns:ep41="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities">';
        try{
            body += '<soapenv:Header/><soapenv:Body>';
            body += '<tem:PrintTcByContractNumberToStream>';
                body += '<tem:ContractNumber>'+(cont.Contract_Number__c!=null?cont.Contract_Number__c:'')+'</tem:ContractNumber>';
                body += '<tem:serviceCredential>';
                    body += '<ep4:Password>'+intgCreds.Password__c+'</ep4:Password>';
                    body += '<ep4:ResponseStatusList>';
                        body += '<ep41:ResponseStatus>';
                            //body += '<ep41:ErrorMessage>'+'</ep41:ErrorMessage>';
                            //body += '<ep41:ResponseType>'+'</ep41:ResponseType>';
                        body += '</ep41:ResponseStatus>';
                    body += '</ep4:ResponseStatusList>';
                body += '<ep4:UserName>'+intgCreds.User_Name__c+'</ep4:UserName>';
                body += '<ep4:UserReferenceNumber>'+(opp.Opportunity_Number__c!=null?opp.Opportunity_Number__c:'')+'</ep4:UserReferenceNumber>';
            body += '</tem:serviceCredential>';
            body += '</tem:PrintTcByContractNumberToStream>';
            body += '</soapenv:Body></soapenv:Envelope>';
            return body;    
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return null; 
        }
        
        
    }
    public static String PrintCertificateByContractNumberToStream(Opportunity opp, Lease_Contract__c cont,Ejari_Integration_Credential__mdt intgCreds){
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:ep4="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities.Common" xmlns:ep41="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities">';
        try{
            body += '<soapenv:Header/><soapenv:Body>';
            body += '<tem:PrintCertificateByContractNumberToStream>';
                body += '<tem:ContractNumber>'+(cont.Contract_Number__c!=null?cont.Contract_Number__c:'')+'</tem:ContractNumber>';
                body += '<tem:serviceCredential>';
                    body += '<ep4:Password>'+intgCreds.Password__c+'</ep4:Password>';
                    body += '<ep4:ResponseStatusList>';
                        body += '<ep41:ResponseStatus>';
                            //body += '<ep41:ErrorMessage>'+'</ep41:ErrorMessage>';
                            //body += '<ep41:ResponseType>'+'</ep41:ResponseType>';
                        body += '</ep41:ResponseStatus>';
                    body += '</ep4:ResponseStatusList>';
                    body += '<ep4:UserName>'+intgCreds.User_Name__c+'</ep4:UserName>';
                    //body += '<ep4:UserReferenceNumber>'+(opp.Opportunity_Number__c!=null?opp.Opportunity_Number__c:'')+'</ep4:UserReferenceNumber>';
                body += '</tem:serviceCredential>';
            body += '</tem:PrintCertificateByContractNumberToStream>';
            body += '</soapenv:Body></soapenv:Envelope>';
            return body;    
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return null;
        }
    }
    public static String ActivateTcByContractNumber(Opportunity opp, Lease_Contract__c cont, Ejari_Integration_Credential__mdt intgCreds){
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:ep4="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities.Common" xmlns:ep41="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities">';
        try{
            body += '<soapenv:Header/><soapenv:Body>';
            body += '<tem:ActivateTcByContractNumber>';
                body += '<tem:ContractNumber>'+(cont.Contract_Number__c!=null?cont.Contract_Number__c:'')+'</tem:ContractNumber>';
                body += '<tem:serviceCredential>';
                    body += '<ep4:Password>'+intgCreds.Password__c+'</ep4:Password>';
                    body += '<ep4:ResponseStatusList>';
                        body += '<ep41:ResponseStatus>';
                            //body += '<ep41:ErrorMessage>'+'</ep41:ErrorMessage>';
                            //body += '<ep41:ResponseType>'+'</ep41:ResponseType>';
                        body += '</ep41:ResponseStatus>';
                    body += '</ep4:ResponseStatusList>';
                    body += '<ep4:UserName>'+intgCreds.User_Name__c+'</ep4:UserName>';
                    body += '<ep4:UserReferenceNumber>'+(opp.Opportunity_Number__c!=null?opp.Opportunity_Number__c:'')+'</ep4:UserReferenceNumber>';
                body += '</tem:serviceCredential>';
            body += '</tem:ActivateTcByContractNumber>';
            body += '</soapenv:Body></soapenv:Envelope>';
            return body;    
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return null; 
        }
    }
    
    /*
    Description: As Person and Org XML have number of different tags.
    Below Two methods are defined for person and org separately.
    1-EditTenancyContract_Person
    2-EditTenancyContract_ORG
    */
    public static String EditTenancyContract_Person(Opportunity opp, Lease_Contract__c cont, Account acc, list<Unit__c> unitList,
                                                    Ejari_Integration_Credential__mdt e_IntgMDT,
                                                    list<Unit_Plan__c> lstunitPlan, Address__c address){
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"';
                body += ' xmlns:tem="http://tempuri.org/"';
                body += ' xmlns:ep4="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities"';
                body += ' xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays"';
                body += ' xmlns:ep41="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities.Common">';
            body += '<soapenv:Header/>' + '<soapenv:Body>';
        try{
            body += '<tem:EditTenancyContract>';
                body+= '<tem:tenancyContract>';
                    body+= '<ep4:ContractAmount>'+(opp.Final_Lease_Amount__c != null ? opp.Final_Lease_Amount__c : 0.00)+'</ep4:ContractAmount>';
                    body+= '<ep4:ContractEndDate>'+returnDate(cont.Contract_End__c)+'</ep4:ContractEndDate>';
                    body+= '<ep4:ContractStartDate>'+returnDate(cont.Contract_Start__c)+'</ep4:ContractStartDate>';
                    body+= '<ep4:PaymentCount>'+returnNumberofCheques(lstunitPlan)+'</ep4:PaymentCount>';
                    body+= '<ep4:PropertyInformations>';
                        for(Unit__c un: unitList){
                            body+= '<ep4:PropertyDetails>';// -- repeat this tag
                                body+= '<ep4:AnnualRent>'+returnRentAmount(lstunitPlan,un.Unit_Code__c)+'</ep4:AnnualRent>';
                                body+= '<ep4:ApprovalRefNumber>'+(un.DLD_Approval_Ref_Number__c != null ? un.DLD_Approval_Ref_Number__c:'')+'</ep4:ApprovalRefNumber>'; 
                                body+= '<ep4:UserRefNumber>'+(un.Unit_Code__c !=null ? un.Unit_Code__c : '')+'</ep4:UserRefNumber>';  //-- opp number
                            body+= '</ep4:PropertyDetails>';
                        }
                    body+= '</ep4:PropertyInformations>';
                    body+= '<ep4:ReferenceNumber>'+(opp.Opportunity_Number__c != null?opp.Opportunity_Number__c:'')+'</ep4:ReferenceNumber>';
                    body+= '<ep4:RentInformations>';
                        body+= '<ep4:RentInfo>';
                            body+= '<ep4:ActualValue>'+(opp.Base_Lease_Amount__c!=null?opp.Base_Lease_Amount__c:0.00)+'</ep4:ActualValue>';
                            body+= '<ep4:DiscountType>'+(opp.Total_Discount_Amount__c > 0?'2':'1')+'</ep4:DiscountType>';
                            body+= '<ep4:DiscountValue>'+(opp.Total_Discount_Amount__c!=null?opp.Total_Discount_Amount__c:0.00)+'</ep4:DiscountValue>';
                            body+= '<ep4:FromDate>'+returnDate(cont.Contract_Start__c)+'</ep4:FromDate>';
                            body+= '<ep4:ToDate>'+returnDate(cont.Contract_End__c)+'</ep4:ToDate>';
                            body+= '<ep4:Value>'+(opp.Final_Lease_Amount__c!=null?opp.Final_Lease_Amount__c:0.00)+'</ep4:Value>';
                        body+= '</ep4:RentInfo>';
                    body+= '</ep4:RentInformations>';
                    body+= '<ep4:SecurityDeposit>'+(opp.Security_Deposit__c!=null?opp.Security_Deposit__c:0.00)+'</ep4:SecurityDeposit>';
                    body+= '<ep4:TenantInformations>';
                        body+= '<ep4:TenantInfo>';
                            body+= '<ep4:Address>'+(address.Name !=null ?address.Name + ' ' +address.City__c:'')+'</ep4:Address>'; //Before: acc.PersonMailingStreet
                            body+= '<ep4:Country>'+(address.Country__c!=null?address.Country__c:'')+'</ep4:Country>'; //Before: acc.PersonMailingCountry
                            body+= '<ep4:Email>'+(acc.Primary_Email__c!=null?acc.Primary_Email__c:'')+'</ep4:Email>';
                            body+= '<ep4:MobileNumber>'+returnMobileNumber(acc.Primary_Mobile__c)+'</ep4:MobileNumber>';
                            body+= '<ep4:NationalIDNumber>'+(acc.Emirates_Ids__c!=null?acc.Emirates_Ids__c.replaceAll('-',''):'')+'</ep4:NationalIDNumber>';
                            body+= '<ep4:POBox>'+(address.Postal_Code__c !=null ?address.Postal_Code__c: '')+'</ep4:POBox>';
                            body+= '<ep4:PassportExpiryDate>'+returnDate(acc.Passport_Expiry_Date__c)+'</ep4:PassportExpiryDate>';
                            body+= '<ep4:PassportIssueDate>'+returnDate(acc.Passport_Issue_Date__c)+'</ep4:PassportIssueDate>';
                            body+= '<ep4:PassportNo>'+(acc.Passport_Number__c!=null?acc.Passport_Number__c:'')+'</ep4:PassportNo>';
                            body+= '<ep4:TenantName>'+acc.FirstName + ' ' + acc.LastName+'</ep4:TenantName>';
                            body+= '<ep4:TenantNameAr>'+(acc.Arabic_Name__c!=null?acc.Arabic_Name__c:'')+'</ep4:TenantNameAr>';
                            if(acc.Visa_Number__c != null){
                                body+= '<ep4:VisaExpiryDate>'+returnDate(acc.Visa_End_Date__c)+'</ep4:VisaExpiryDate>';
                            	body+= '<ep4:VisaNo>'+(acc.Visa_Number__c!=null?acc.Visa_Number__c:'')+'</ep4:VisaNo>';
                            	body+= '<ep4:VisaStartDate>'+returnDate(acc.Visa_Start_Date__c)+'</ep4:VisaStartDate>';
                            }
                        body+= '</ep4:TenantInfo>';
                    body+= '</ep4:TenantInformations>';
                    body+= '<ep4:UsageInformations>';
                        for(Unit__c un: unitList){
                            body+= '<ep4:UsageInfo>'; //-- repeat this table
                                body+= '<ep4:AnnualRent>'+returnRentAmount(lstunitPlan,un.Unit_Code__c)+'</ep4:AnnualRent>';
                                body+= '<ep4:ApprovalRefNumber>'+(un.DLD_Approval_Ref_Number__c != null ? un.DLD_Approval_Ref_Number__c:'')+'</ep4:ApprovalRefNumber>'; //-- lookup table 
                                body+= '<ep4:UserRefNumber>'+(un.Unit_Code__c!=null?un.Unit_Code__c:'')+'</ep4:UserRefNumber>'; //-- lease number
                            body+= '</ep4:UsageInfo>';
                        }
                    body+= '</ep4:UsageInformations>';
                body+= '</tem:tenancyContract>';
                body+= '<tem:serviceCredential>';
                    body+= '<ep41:Password>'+e_IntgMDT.Password__c+'</ep41:Password>';
                    body+= '<ep41:ResponseStatusList/>';
                    body+= '<ep41:UserName>'+e_IntgMDT.User_Name__c+'</ep41:UserName>';
                    body+= '<ep41:UserReferenceNumber>'+(opp.Lease_Number__c !=null ? opp.Lease_Number__c:'')+'</ep41:UserReferenceNumber>';
                body+= '</tem:serviceCredential>';
            body += '</tem:EditTenancyContract>';
            body+= '</soapenv:Body>';
            body+= '</soapenv:Envelope>';
            return body;
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return null;
        }
    }
    public static String EditTenancyContract_ORG(Opportunity opp, Lease_Contract__c cont, Account acc, list<Unit__c> unitList,Ejari_Integration_Credential__mdt e_IntgMDT,
                                                 Contact con, list<Unit_Plan__c> lstunitPlan, Address__c address){
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"';
                body += ' xmlns:tem="http://tempuri.org/"';
                body += ' xmlns:ep4="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities"';
                body += ' xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays"';
                body += ' xmlns:ep41="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities.Common">';
            body += '<soapenv:Header/>' + '<soapenv:Body>';
        try{
            body += '<tem:EditTenancyContract>';
                body+= '<tem:tenancyContract>';
                    body+= '<ep4:ContractAmount>'+(opp.Final_Lease_Amount__c!=null?opp.Final_Lease_Amount__c:0.00)+'</ep4:ContractAmount>';
                    body+= '<ep4:ContractEndDate>'+returnDate(cont.Contract_End__c)+'</ep4:ContractEndDate>';
                    body+= '<ep4:ContractStartDate>'+returnDate(cont.Contract_Start__c)+'</ep4:ContractStartDate>';                   
                    body+= '<ep4:GraceEndDate>'+returnDateOnly(opp.Grace_End_Date__c)+'</ep4:GraceEndDate>'; // required
                    body+= '<ep4:GraceStartDate>'+returnDateOnly(opp.Grace_Start_Date__c)+'</ep4:GraceStartDate>'; //required
                    body+= '<ep4:PaymentCount>'+returnNumberofCheques(lstunitPlan)+'</ep4:PaymentCount>';
                    body+= '<ep4:PropertyInformations>';
                    for(Unit__c un: unitList){    
                        body+= '<ep4:PropertyDetails>';
                            body+= '<ep4:AnnualRent>'+returnRentAmount(lstunitPlan,un.Unit_Code__c)+'0</ep4:AnnualRent>';
                            body+= '<ep4:ApprovalRefNumber>'+(un.DLD_Approval_Ref_Number__c != null ? un.DLD_Approval_Ref_Number__c:'')+'</ep4:ApprovalRefNumber>';
                            body+= '<ep4:DEWANumber>'+(un.DEWA_Number__c!=null?un.DEWA_Number__c:'')+'</ep4:DEWANumber>';
                        body+= '</ep4:PropertyDetails>';
                    }
                    body+= '</ep4:PropertyInformations>';
                    body+= '<ep4:ReferenceNumber>'+(opp.Opportunity_Number__c!=null?opp.Opportunity_Number__c:'')+'</ep4:ReferenceNumber>';
                    body+= '<ep4:RentInformations>';
                        body+= '<ep4:RentInfo>';
                            body+= '<ep4:ActualValue>'+(opp.Final_Lease_Amount__c!=null?opp.Final_Lease_Amount__c:0.00)+'</ep4:ActualValue>';
                            body+= '<ep4:DiscountType>'+(opp.Total_Discount_Amount__c > 0?'2':'1')+'</ep4:DiscountType>';
                            body+= '<ep4:DiscountValue>'+(opp.Total_Discount_Amount__c!=null?opp.Total_Discount_Amount__c:000)+'</ep4:DiscountValue>';
                            body+= '<ep4:FromDate>'+returnDate(cont.Contract_Start__c)+'</ep4:FromDate>';
                            body+= '<ep4:ToDate>'+returnDate(cont.Contract_End__c)+'</ep4:ToDate>';
                            body+= '<ep4:Value>'+(opp.Base_Lease_Amount__c!=null?opp.Base_Lease_Amount__c:0.00)+'</ep4:Value>';
                        body+= '</ep4:RentInfo>';
                    body+= '</ep4:RentInformations>';
                    body+= '<ep4:SecurityDeposit>'+(opp.Security_Deposit__c!=null?opp.Security_Deposit__c:0.00)+'</ep4:SecurityDeposit>';
                    body+= '<ep4:TenantInformations>';
                        body+= '<ep4:TenantInfo>';
                            body+= '<ep4:Address>'+(address.Name !=null ?address.Name + ' ' +address.City__c:'')+'</ep4:Address>';
                            body+= '<ep4:ContactPersonMobile>'+returnMobileNumber(con.MobilePhone)+'</ep4:ContactPersonMobile>';
                            body+= '<ep4:ContactPersonName>'+con.FirstName+' '+con.LastName+'</ep4:ContactPersonName>';
                            body+= '<ep4:Email>'+(acc.Primary_Email__c!=null?acc.Primary_Email__c:'')+'</ep4:Email>';
                            body+= '<ep4:LicenseExpiryDate>'+returnDateOnly(acc.Trade_License_End_Date__c)+'</ep4:LicenseExpiryDate>'; //required
                            body+= '<ep4:LicenseIssueDate>'+returnDateOnly(acc.Trade_License_Start_Date__c)+'</ep4:LicenseIssueDate>'; // required
                            body+= '<ep4:MobileNumber>'+returnMobileNumber(acc.Primary_Mobile__c)+'</ep4:MobileNumber>';
                            body+= '<ep4:POBox>'+(address.Postal_Code__c !=null ?address.Postal_Code__c :'')+'</ep4:POBox>';
                            body+= '<ep4:TenantName>'+(acc.Name!=null?acc.Name:'')+'</ep4:TenantName>';
                            body+= '<ep4:TenantNameAr>'+(acc.Arabic_Name__c!=null?acc.Arabic_Name__c:'')+'</ep4:TenantNameAr>';
                            body+= '<ep4:TradeLicenseIssuer>'+(acc.Trade_License_Issuer__c!=null?acc.Trade_License_Issuer__c:'')+'</ep4:TradeLicenseIssuer>';
                            body+= '<ep4:TradeLicenseNumber>'+(acc.Trade_License_Number__c!=null?acc.Trade_License_Number__c:'')+'</ep4:TradeLicenseNumber>';
                        body+= '</ep4:TenantInfo>';
                    body+= '</ep4:TenantInformations>';
                    body+= '<ep4:UsageInformations>';
                    for(Unit__c un: unitList){
                        body+= '<ep4:UsageInfo>'; //-- repeat this table
                            body+= '<ep4:AnnualRent>'+returnRentAmount(lstunitPlan,un.Unit_Code__c)+'</ep4:AnnualRent>';
                            body+= '<ep4:ApprovalRefNumber>'+(un.DLD_Approval_Ref_Number__c != null ? un.DLD_Approval_Ref_Number__c:'')+'</ep4:ApprovalRefNumber>'; //-- lookup table 
                            body+= '<ep4:UserRefNumber>'+(un.Unit_Code__c!=null?un.Unit_Code__c:'')+'</ep4:UserRefNumber>'; //-- lease number
                        body+= '</ep4:UsageInfo>';
                    }
                    body+= '</ep4:UsageInformations>';
                body+= '</tem:tenancyContract>';
                body+= '<tem:serviceCredential>';
                    body+= '<ep41:Password>'+e_IntgMDT.Password__c+'</ep41:Password>';
                    body+= '<ep41:ResponseStatusList/>';
                    body+= '<ep41:UserName>'+e_IntgMDT.User_Name__c+'</ep41:UserName>';
                    body+= '<ep41:UserReferenceNumber>'+(opp.Lease_Number__c!=null?opp.Lease_Number__c:'')+'</ep41:UserReferenceNumber>';
                body+= '</tem:serviceCredential>';
            body += '</tem:EditTenancyContract>';
            body+= '</soapenv:Body>';
            body+= '</soapenv:Envelope>';
            return body; 
            
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return null;
        }
    }
    
    public static String TCGetByContractNumber(Opportunity opp, Lease_Contract__c cont, Ejari_Integration_Credential__mdt intgCreds){
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:ep4="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities.Common" xmlns:ep41="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities">';
        try{
            body += '<soapenv:Header/><soapenv:Body>';
            body += '<tem:TCGetByContractNumber>';
                body += '<tem:ContractNumber>'+(cont.Contract_Number__c!=null?cont.Contract_Number__c:'')+'</tem:ContractNumber>';
                body += '<tem:serviceCredential>';
                    body += '<ep4:Password>'+intgCreds.Password__c+'</ep4:Password>';
                    body += '<ep4:ResponseStatusList>';
                        body += '<ep41:ResponseStatus>';
                            body += '<ep41:ErrorMessage>'+'</ep41:ErrorMessage>';
                            body += '<ep41:ResponseType>'+'</ep41:ResponseType>';
                        body += '</ep41:ResponseStatus>';
                    body += '</ep4:ResponseStatusList>';
                    body += '<ep4:UserName>'+intgCreds.User_Name__c+'</ep4:UserName>';
                    body += '<ep4:UserReferenceNumber>'+(opp.Opportunity_Number__c!=null?opp.Opportunity_Number__c:'')+'</ep4:UserReferenceNumber>';
                body += '</tem:serviceCredential>';
            body += '</tem:TCGetByContractNumber>';
            body += '</soapenv:Body></soapenv:Envelope>';
            return body;    
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return null;  
        }
    }
    
    /*
    Description: As Person and Org XML have number of different tags.
    Below Two methods are defined for person and org separately.
    1-RenewTenancyContract_Person
    2-RenewTenancyContract_ORG
    */
    public static String RenewTenancyContract_Person(Opportunity opp, Lease_Contract__c cont, Account acc, list<Unit__c> unitList,Ejari_Integration_Credential__mdt e_IntgMDT, 
                                                     list<Unit_Plan__c> lstunitPlan, Address__c address){
    String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"';
                body += ' xmlns:tem="http://tempuri.org/"';
                body += ' xmlns:ep4="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities"';
                body += ' xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays"';
                body += ' xmlns:ep41="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities.Common">';
            body += '<soapenv:Header/>' + '<soapenv:Body>';
        try{
            body += '<tem:RenewPendingTenancyContract>';
                body+= '<tem:tenancyContract>';
                    body+= '<ep4:ContractAmount>'+(opp.Final_Lease_Amount__c!=null?opp.Final_Lease_Amount__c:0.00)+'</ep4:ContractAmount>';
                    body+= '<ep4:ContractEndDate>'+returnDate(cont.Contract_End__c)+'</ep4:ContractEndDate>';
                    body+= '<ep4:ContractNumber>'+(cont.Contract_Number__c!=null?cont.Contract_Number__c:'')+'</ep4:ContractNumber>';
                    body+= '<ep4:ContractStartDate>'+returnDate(cont.Contract_Start__c)+'</ep4:ContractStartDate>';
                    body+= '<ep4:PaymentCount>'+returnNumberofCheques(lstunitPlan)+'</ep4:PaymentCount>';
                    body+= '<ep4:PropertyInformations>';
                        for(Unit__c un: unitList){
                            body+= '<ep4:PropertyDetails>';// -- repeat this tag
                                body+= '<ep4:AnnualRent>'+returnRentAmount(lstunitPlan,un.Unit_Code__c)+'</ep4:AnnualRent>';
                                body+= '<ep4:ApprovalRefNumber>'+(un.DLD_Approval_Ref_Number__c != null ? un.DLD_Approval_Ref_Number__c:'')+'</ep4:ApprovalRefNumber>'; 
                                body+= '<ep4:UserRefNumber>'+(un.Unit_Code__c!=null?un.Unit_Code__c:'')+'</ep4:UserRefNumber>';  //-- opp number
                            body+= '</ep4:PropertyDetails>';
                        }
                    body+= '</ep4:PropertyInformations>';
                    body+= '<ep4:ReferenceNumber>'+(opp.Opportunity_Number__c!=null?opp.Opportunity_Number__c:'')+'</ep4:ReferenceNumber>';
                    body+= '<ep4:RentInformations>';
                        body+= '<ep4:RentInfo>';
                            body+= '<ep4:ActualValue>'+(opp.Base_Lease_Amount__c!=null?opp.Base_Lease_Amount__c:0.00)+'</ep4:ActualValue>';
                            body+= '<ep4:DiscountType>'+(opp.Total_Discount_Amount__c> 0?'2':'1')+'</ep4:DiscountType>';
                            body+= '<ep4:DiscountValue>'+(opp.Total_Discount_Amount__c!=null?opp.Total_Discount_Amount__c:0.00)+'</ep4:DiscountValue>';
                            body+= '<ep4:FromDate>'+returnDate(cont.Contract_Start__c)+'</ep4:FromDate>';
                            body+= '<ep4:ToDate>'+returnDate(cont.Contract_End__c)+'</ep4:ToDate>';
                            body+= '<ep4:Value>'+(opp.Final_Lease_Amount__c!=null?opp.Final_Lease_Amount__c:0.00)+'</ep4:Value>';
                        body+= '</ep4:RentInfo>';
                    body+= '</ep4:RentInformations>';
                    body+= '<ep4:SecurityDeposit>'+(opp.Security_Deposit__c!=null?opp.Security_Deposit__c:0.00)+'</ep4:SecurityDeposit>';
                    body+= '<ep4:TenantInformations>';
                        body+= '<ep4:TenantInfo>';
                            body+= '<ep4:Address>'+(address.Name !=null ?address.Name + ' ' +address.City__c:'')+'</ep4:Address>';
                            body+= '<ep4:Country>'+(address.Country__c!=null?address.Country__c:'')+'</ep4:Country>';
                            body+= '<ep4:Email>'+(acc.Primary_Email__c!=null?acc.Primary_Email__c:'')+'</ep4:Email>';
                            body+= '<ep4:MobileNumber>'+returnMobileNumber(acc.Primary_Mobile__c)+'</ep4:MobileNumber>';
                            body+= '<ep4:NationalIDNumber>'+(acc.Emirates_Ids__c!=null?acc.Emirates_Ids__c.replaceAll('-',''):'')+'</ep4:NationalIDNumber>';
                            body+= '<ep4:POBox>'+(address.Postal_Code__c !=null ?address.Postal_Code__c :'')+'</ep4:POBox>';
                            body+= '<ep4:PassportExpiryDate>'+returnDate(acc.Passport_Expiry_Date__c)+'</ep4:PassportExpiryDate>';
                            body+= '<ep4:PassportIssueDate>'+returnDate(acc.Passport_Issue_Date__c)+'</ep4:PassportIssueDate>';
                            body+= '<ep4:PassportNo>'+(acc.Passport_Number__c!=null?acc.Passport_Number__c:'')+'</ep4:PassportNo>';
                            body+= '<ep4:TenantName>'+acc.FirstName + ' ' + acc.LastName+'</ep4:TenantName>';
                            body+= '<ep4:TenantNumber>'+(acc.Tenant_Number__c!=null?acc.Tenant_Number__c:'')+'</ep4:TenantNumber>';
                            if(acc.Visa_Number__c != null){
                                body+= '<ep4:VisaExpiryDate>'+returnDate(acc.Visa_End_Date__c)+'</ep4:VisaExpiryDate>';
                            	body+= '<ep4:VisaNo>'+(acc.Visa_Number__c!=null?acc.Visa_Number__c:'')+'</ep4:VisaNo>';
                            	body+= '<ep4:VisaStartDate>'+returnDate(acc.Visa_Start_Date__c)+'</ep4:VisaStartDate>';
                            }
                        body+= '</ep4:TenantInfo>';
                    body+= '</ep4:TenantInformations>';
                    body+= '<ep4:UsageInformations>';
                        for(Unit__c un: unitList){
                            body+= '<ep4:UsageInfo>'; //-- repeat this table
                                body+= '<ep4:AnnualRent>'+returnRentAmount(lstunitPlan,un.Unit_Code__c)+'</ep4:AnnualRent>';
                                body+= '<ep4:ApprovalRefNumber>'+(un.DLD_Approval_Ref_Number__c != null ? un.DLD_Approval_Ref_Number__c:'')+'</ep4:ApprovalRefNumber>'; //-- lookup table 
                                body+= '<ep4:UserRefNumber>'+(un.Unit_Code__c!=null?un.Unit_Code__c:'')+'</ep4:UserRefNumber>'; //-- lease number
                            body+= '</ep4:UsageInfo>';
                        }
                    body+= '</ep4:UsageInformations>';
                body+= '</tem:tenancyContract>';
                body+= '<tem:serviceCredential>';
                    body+= '<ep41:Password>'+e_IntgMDT.Password__c+'</ep41:Password>';
                    body+= '<ep41:ResponseStatusList/>';
                    body+= '<ep41:UserName>'+e_IntgMDT.User_Name__c+'</ep41:UserName>';
                    body+= '<ep41:UserReferenceNumber>'+(opp.Lease_Number__c!=null?opp.Lease_Number__c:'')+'</ep41:UserReferenceNumber>';
                body+= '</tem:serviceCredential>';
            body += '</tem:RenewPendingTenancyContract>';
            body+= '</soapenv:Body>';
            body+= '</soapenv:Envelope>';
            return body;
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return null;
        }
        
    }
    public static String RenewTenancyContract_ORG(Opportunity opp, Lease_Contract__c cont, Account acc, list<Unit__c> unitList,Ejari_Integration_Credential__mdt e_IntgMDT, 
                                                  Contact con, list<Unit_Plan__c> lstunitPlan, Address__c address){
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"';
            body += ' xmlns:tem="http://tempuri.org/"';
            body += ' xmlns:ep4="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities"';
            body += ' xmlns:arr="http://schemas.microsoft.com/2003/10/Serialization/Arrays"';
            body += ' xmlns:ep41="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities.Common">';
        body += '<soapenv:Header/>' + '<soapenv:Body>';
        try{
            body += '<tem:RenewPendingTenancyContract>';
                body+= '<tem:tenancyContract>';
                    body+= '<ep4:ContractAmount>'+(opp.Final_Lease_Amount__c!=null?opp.Final_Lease_Amount__c:0.00)+'</ep4:ContractAmount>';
                    body+= '<ep4:ContractEndDate>'+returnDate(cont.Contract_End__c)+'</ep4:ContractEndDate>';
                    body+= '<ep4:ContractNumber>'+(cont.Contract_Number__c!=null?cont.Contract_Number__c:'')+'</ep4:ContractNumber>';
                    body+= '<ep4:ContractStartDate>'+returnDate(cont.Contract_Start__c)+'</ep4:ContractStartDate>';
                    body+= '<ep4:PaymentCount>'+returnNumberofCheques(lstunitPlan)+'</ep4:PaymentCount>';
                    body+= '<ep4:RentInformations>';
                        body+= '<ep4:RentInfo>';
                            body+= '<ep4:ActualValue>'+(opp.Final_Lease_Amount__c!=null?opp.Final_Lease_Amount__c:0.00)+'</ep4:ActualValue>';
                            body+= '<ep4:DiscountType>'+(opp.Total_Discount_Amount__c> 0?'2':'1')+'</ep4:DiscountType>';
                            body+= '<ep4:DiscountValue>'+(opp.Total_Discount_Amount__c!=null?opp.Total_Discount_Amount__c:0.00)+'</ep4:DiscountValue>';
                            body+= '<ep4:FromDate>'+returnDate(cont.Contract_Start__c)+'</ep4:FromDate>';
                            body+= '<ep4:ToDate>'+returnDate(cont.Contract_End__c)+'</ep4:ToDate>';
                            body+= '<ep4:Value>'+(opp.Base_Lease_Amount__c!=null?opp.Base_Lease_Amount__c:0.00)+'</ep4:Value>';
                        body+= '</ep4:RentInfo>';
                    body+= '</ep4:RentInformations>';
                    body+= '<ep4:SecurityDeposit>'+(opp.Security_Deposit__c!=null?opp.Security_Deposit__c:0.00)+'</ep4:SecurityDeposit>';
                    body+= '<ep4:TenantInformations>';
                        body+= '<ep4:TenantInfo>';
                            body+= '<ep4:Address>'+(address.Name !=null ?address.Name + ' ' +address.City__c:'')+'</ep4:Address>';
                            body+= '<ep4:ContactPersonMobile>'+returnMobileNumber(con.MobilePhone)+'</ep4:ContactPersonMobile>';
                            body+= '<ep4:ContactPersonName>'+con.FirstName+' '+con.LastName+'</ep4:ContactPersonName>';
                            body+= '<ep4:Email>'+(acc.Primary_Email__c!=null?acc.Primary_Email__c:'')+'</ep4:Email>';
                            body+= '<ep4:LicenseExpiryDate>'+returnDateOnly(acc.Trade_License_End_Date__c)+'</ep4:LicenseExpiryDate>';
                            body+= '<ep4:LicenseIssueDate>'+returnDateOnly(acc.Trade_License_Start_Date__c)+'</ep4:LicenseIssueDate>';
                            body+= '<ep4:MobileNumber>'+returnMobileNumber(acc.Primary_Mobile__c)+'</ep4:MobileNumber>';
                            body+= '<ep4:POBox>'+(address.Postal_Code__c !=null ?address.Postal_Code__c :'')+'</ep4:POBox>';
                            body+= '<ep4:TenantName>'+(acc.Name!=null?acc.Name:'')+'</ep4:TenantName>';
                            body+= '<ep4:TenantNameAr>'+(acc.Arabic_Name__c!=null?acc.Arabic_Name__c:'')+'</ep4:TenantNameAr>';
                            body+= '<ep4:TenantNumber>'+acc.Tenant_Number__c+'</ep4:TenantNumber>';
                            body+= '<ep4:TradeLicenseIssuer>'+(acc.Trade_License_Issuer__c!=null?acc.Trade_License_Issuer__c:'')+'</ep4:TradeLicenseIssuer>';
                            body+= '<ep4:TradeLicenseNumber>'+(acc.Trade_License_Number__c!=null?acc.Trade_License_Number__c:'')+'</ep4:TradeLicenseNumber>';
                        body+= '</ep4:TenantInfo>';
                    body+= '</ep4:TenantInformations>';
                    body+= '<ep4:UsageInformations>';
                        for(Unit__c un: unitList){
                            body+= '<ep4:UsageInfo>'; //-- repeat this table
                                body+= '<ep4:AnnualRent>'+returnRentAmount(lstunitPlan,un.Unit_Code__c)+'</ep4:AnnualRent>';
                                body+= '<ep4:ApprovalRefNumber>'+(un.DLD_Approval_Ref_Number__c != null ? un.DLD_Approval_Ref_Number__c:'')+'</ep4:ApprovalRefNumber>'; //-- lookup table 
                                body+= '<ep4:UserRefNumber>'+(un.Unit_Code__c!=null?un.Unit_Code__c:'')+'</ep4:UserRefNumber>'; //-- lease number
                            body+= '</ep4:UsageInfo>';
                        }
                    body+= '</ep4:UsageInformations>';
            		body+= '</tem:tenancyContract>';
                    body+= '<tem:serviceCredential>';
                        body+= '<ep41:Password>'+e_IntgMDT.Password__c+'</ep41:Password>';
                        body+= '<ep41:ResponseStatusList/>';
                        body+= '<ep41:UserName>'+e_IntgMDT.User_Name__c+'</ep41:UserName>';
                        body+= '<ep41:UserReferenceNumber>'+(opp.Lease_Number__c!=null?opp.Lease_Number__c:'')+'</ep41:UserReferenceNumber>';
                    body+= '</tem:serviceCredential>';
            body += '</tem:RenewPendingTenancyContract>';
            body+= '</soapenv:Body>';
            body+= '</soapenv:Envelope>';
            return body;
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return null;
        }
    }
   
    public static String TerminateTcByContractNumber(opportunity opp, Lease_Contract__c cont,Ejari_Integration_Credential__mdt intgCreds){
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/" xmlns:ep4="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities.Common" xmlns:ep41="http://schemas.datacontract.org/2004/07/EP4.Integration.Entities">';
        try{
            body += '<soapenv:Header/><soapenv:Body>';
            body += '<tem:TerminateTcByContractNumber>';
                body += '<tem:ContractNumber>'+(cont.Contract_Number__c!=null?cont.Contract_Number__c:'')+'</tem:ContractNumber>';
                body += '<tem:terminationReason>'+(cont.Termination_Reason__c!=null?cont.Termination_Reason__c:'')+'</tem:terminationReason>';
                body += '<tem:serviceCredential>';
                    body += '<ep4:Password>'+intgCreds.Password__c+'</ep4:Password>';
                    body += '<ep4:ResponseStatusList>';
                        body += '<ep41:ResponseStatus>';
                               // body += '<ep41:ErrorMessage>'+'</ep41:ErrorMessage>';
                              //  body += '<ep41:ResponseType>'+'</ep41:ResponseType>';
                        body += '</ep41:ResponseStatus>';
                    body += '</ep4:ResponseStatusList>';
                    body += '<ep4:UserName>'+intgCreds.User_Name__c+'</ep4:UserName>';
                    body += '<ep4:UserReferenceNumber>'+(opp.Opportunity_Number__c!=null?opp.Opportunity_Number__c:'')+'</ep4:UserReferenceNumber>'; //
                body += '</tem:serviceCredential>';
            body += '</tem:TerminateTcByContractNumber>';
            body += '</soapenv:Body></soapenv:Envelope>';
            return body;    
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return null;
        }
        
        
    } 
    
    public static String returnDate(datetime dt){
        String myDate = '';
        try{
            if(dt != null){
                myDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
                myDate = myDate.substring(0,26)+':'+myDate.substring(26);
            }
            return myDate;
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return myDate;
        }
    } 
    
    public static String returnDateOnly(date dt){
        String myDate = '';
        try{
            if(dt != null)
            {
                Datetime dtNew = Datetime.newInstance(dt.year(), dt.month(), dt.day());
                myDate = dtNew.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
                myDate = myDate.substring(0,26)+':'+myDate.substring(26);
            }
            
            return myDate;
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return myDate;
        }
    } 

    public static String dateFormat(date dt){
        String myDate = '';
        try{
            if(dt != null)
            {
                Datetime dtNew = Datetime.newInstance(dt.year(), dt.month(), dt.day());
                myDate = dtNew.format('yyyy-MM-dd');
            }
            
            return myDate;
        }catch(Exception e){
            system.debug('Error: ' + e.getMessage() +' at line '+ e.getLineNumber());
            return myDate;
        }
    }


    public static integer returnNumberofCheques(list<Unit_Plan__c> lstUnitPlanRec)
    {
        try        
        {
            decimal numberofCheque = 0.0;
            // calculate number of cheques from unitPlan as we can have multiple
            for(Unit_Plan__c unitPlan : lstUnitPlanRec)
            {                  
                if(unitPlan.No_Of_Cheques__c != null)
                {
                    numberofCheque = numberofCheque + unitPlan.No_Of_Cheques__c;
                }   
                
            }
            return integer.valueOf(numberofCheque);
        }

        catch(exception ex)
        {
            return 0;
        }
        
    }

  
    public static Double returnRentAmount(list<Unit_Plan__c> lstUnitPlanRec,String unitCode){   
        double finalLeaseAmount = 0.00;
        try{
            for(Unit_Plan__c unitPlan : lstUnitPlanRec){ 
                if(unitPlan.name == unitCode){
                    finalLeaseAmount = unitPlan.Final_Lease_Amount__c;
                } 
            }
            return finalLeaseAmount;
        }catch(exception ex){
            return 0.00;
        }
        
    }
    
    public static String returnMobileNumber(String mobileNo){
        try{
            mobileNo = mobileNo.startsWith('0') ? mobileNo : '0'+mobileNo;
            return mobileNo;
        }catch(exception ex){
            return '';
        }

    }
}