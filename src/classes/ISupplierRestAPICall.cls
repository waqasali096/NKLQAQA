public without sharing class ISupplierRestAPICall {
    /**
* Being called from process builder to initiate vendor creation request
*/
    @InvocableMethod
    public static void SendAccountToiSupplier(List<Id> accountIdList) {
        try {
            Set<Id> accountIds = new Set<Id>();
            for (Id accountId : accountIdList) {
                accountIds.add(accountId);
            }
            System.enqueueJob(new CreateISupplierVendor(AccountIds));
        } catch (Exception e) {
        }
    }
    public static void SendAccountToiSupplier(Set<Id> accountSet) {
        try {
            System.enqueueJob(new CreateISupplierVendor(accountSet));
        } catch (Exception e) {
        }
    }
    
    public static void SendDocumentToiSupplier(Set<Id> accountSet,Set<ID> docSet) {
        try {
            System.enqueueJob(new calloutfromDoc(accountSet,docSet));
        } catch (Exception e) {
        }
    }
    
    /**
* Create Supplier Vendor in iSupplier system.
*/
    public class CreateISupplierVendor implements Queueable, Database.AllowsCallouts {
        public Set<Id> accountIds;
        public CreateISupplierVendor(Set<Id> accountIds) {
            this.AccountIds = accountIds;
        }
        public void execute(QueueableContext context) {
            iSupplierAccountCreation(accountIds);
            system.debug('first execute chain');
            if(IsfileJobExceute){
                system.debug('vendorIdForFile0**'+ vendorIdForFile);
                System.enqueueJob(new CreateISupplierVendorForFile(accountIds,vendorIdForFile));
            }
        }
    }
    
    public class calloutfromDoc implements Queueable, Database.AllowsCallouts {
        public Set<Id> accountIds;
        public Set<ID> docIDS;
        public calloutfromDoc(Set<Id> accountIds, Set<ID> docIDS) {
            this.AccountIds = accountIds;
            this.docIDS = docIDS;
        }
        public void execute(QueueableContext context) {
            XMLForFileGenerator(accountIds,null,docIDS);
        }
    }
    
    public static boolean IsfileJobExceute = False;
    public static String vendorIdForFile= '';
    
    /**
* Create Supplier Vendor in iSupplier system for Files.
*/
    public class CreateISupplierVendorForFile implements Queueable, Database.AllowsCallouts {
        public Set<Id> accountIds;
        public String vendorIDFile;
        public CreateISupplierVendorForFile(Set<Id> accountIds,String vendorIDFile) {
            system.debug('vendorIdForFile2**'+ vendorIDFile);
            this.AccountIds = accountIds;
            this.vendorIDFile = vendorIDFile;
        }
        public void execute(QueueableContext context) {
            XMLForFileGenerator(accountIds,vendorIDFile,null);
        }
    }
    
    public static void iSupplierAccountCreation(Set<Id> accountSet) {
        List<Account> accountList = new List<Account>();
        try{
            accountList = getAccountDetails(accountSet);
            Map<Id, List<ContentVersion>> mapAccountToContentVersions = getDocumentDetailsForAccountsSet(accountSet,null);
            Map<Id, List<Contact>> mapAccountToContacts = getContactDetails(accountSet);
            string createdDateTime = generateTimestamp();
            ISupplier_Credentials__mdt credential = [
                SELECT label,Nonce__c,Username__c,Endpoint__c,Password__c
                FROM ISupplier_Credentials__mdt
                WHERE MasterLabel = 'ISupplier Access'
            ];
            String VendorId = '';
            
            
            String xml = '<soapenv:Envelope xmlns:cre="http://xmlns.oracle.com/apps/ap/soaprovider/plsql/xxims_salesforce_supplier_int_pkg/create_amend_supplier/" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<soapenv:Header>' +
                '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' +
                '<wsse:UsernameToken wsu:Id="UsernameToken-4BD877E8C4A41BE64516322916439962">' +
                '<wsse:Username>' + credential.Username__c + '</wsse:Username>' +
                '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + credential.Password__c + '</wsse:Password>' +
                '<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + credential.Nonce__c + '</wsse:Nonce>' +
                '<wsu:Created>' + createdDateTime + '</wsu:Created>' +
                '</wsse:UsernameToken>' +
                '</wsse:Security>' +
                '</soapenv:Header>' +
                '<soapenv:Body>' +
                '<cre:InputParameters>' +
                '<cre:P_OPERATION_TYPE/>';
            
            system.debug('*** 1.xml :' + xml);
            
            xml = xml + '<cre:P_VENDOR_REC>';
            
            system.debug('*** 2.xml :' + xml);
            
            for (Account acc : accountList) {
                VendorId = acc.Vendor_Id__c != null ? acc.Vendor_Id__c : '';
                xml = xml + '<!--Zero or more repetitions:-->' +
                    '<cre:P_VENDOR_REC_ITEM>' +
                    '<cre:VENDOR_NAME>' + acc.Name + '</cre:VENDOR_NAME>' +
                    '<cre:VENDOR_NAME_ALT>' + acc.Name + '</cre:VENDOR_NAME_ALT>' +
                    '<cre:START_DATE_ACTIVE/>' +
                    '<cre:END_DATE_ACTIVE/>' +
                    '<cre:ATTRIBUTE_CATEGORY>' + 'Supplier Profile' + '</cre:ATTRIBUTE_CATEGORY>' +
                    '<cre:ATTRIBUTE1>' + 'CORPORATE' + '</cre:ATTRIBUTE1>' +
                    '<cre:ATTRIBUTE2/>' +
                    '<cre:ATTRIBUTE3>' + 'Yes' + '</cre:ATTRIBUTE3>' +
                    '<cre:ATTRIBUTE4/>' +
                    '<cre:ATTRIBUTE5/>' +
                    '<cre:AUTO_TAX_CALC_FLAG>' + 'Y' + '</cre:AUTO_TAX_CALC_FLAG>' +
                    '<cre:OFFSET_TAX_FLAG>' + 'N' + '</cre:OFFSET_TAX_FLAG>' +
                    '<cre:VAT_REGISTRATION_NUM>' + '12345' + '</cre:VAT_REGISTRATION_NUM>' +
                    '<cre:AP_TAX_ROUNDING_RULE/>' +
                    '<cre:AMOUNT_INCLUDES_TAX_FLAG/>' +
                    '<cre:AP_TAX_ROUNDING_LEVEL_CODE/>' +
                    '<cre:VENDOR_SITE_CODE>' + 'PAYOFFICE' + '</cre:VENDOR_SITE_CODE>' +
                    '<cre:ADDRESS_LINE1>' + acc.BillingStreet + '</cre:ADDRESS_LINE1>' +
                    '<cre:ADDRESS_LINE2>' + '' + '</cre:ADDRESS_LINE2>' +
                    '<cre:ADDRESS_LINE3>' + '' + '</cre:ADDRESS_LINE3>' +
                    '<cre:ADDRESS_LINE4/>' +
                    '<cre:CITY>' + acc.BillingCity + '</cre:CITY>' +
                    '<cre:STATE>' + acc.BillingState + '</cre:STATE>' +
                    '<cre:COUNTRY>' + acc.BillingCountry + '</cre:COUNTRY>' +
                    '<cre:VAT_CODE>' + 'SR05' + '</cre:VAT_CODE>' +
                    '<cre:PURCHASING_SITE_FLAG>' + 'Y' + '</cre:PURCHASING_SITE_FLAG>' +
                    '<cre:PAY_SITE_FLAG>' + 'Y' + '</cre:PAY_SITE_FLAG>' +
                    '<cre:SITE_AREA_CODE>' + acc.Primary_Country_Code__c + '</cre:SITE_AREA_CODE>' +
                    '<cre:SITE_PHONE>' + acc.Primary_Mobile__c + '</cre:SITE_PHONE>' +
                    '<cre:SITE_EMAIL_ADDRESS>' + acc.Primary_Email__c + '</cre:SITE_EMAIL_ADDRESS>' +
                    '<cre:CONTACT_PERSON_FIRST_NAME>' + '' + '</cre:CONTACT_PERSON_FIRST_NAME>' +
                    '<cre:CONTACT_PERSON_LAST_NAME>' + '' + '</cre:CONTACT_PERSON_LAST_NAME>' +
                    '<cre:CONTACT_ORGANIZATION_NAME_PHONETIC/>' +
                    '<cre:CONTACT_AREA_CODE>' + '' + '</cre:CONTACT_AREA_CODE>' +
                    '<cre:CONTACT_PHONE>' + '' + '</cre:CONTACT_PHONE>' +
                    '<cre:CONTACT_EMAIL_ADDRESS>' + '' + '</cre:CONTACT_EMAIL_ADDRESS>' +
                    '<cre:ATTACHED_FILES>';
                system.debug('*** 3.xml :' + xml);
                if (mapAccountToContentVersions.containsKey(acc.Id)) {
                    for (ContentVersion fileData : mapAccountToContentVersions.get(acc.Id)) {
                        //                  if(fileData.Title != 'DISTRICT ONE – FZ' || fileData.Title != 'Meydan Group L.L.C' || fileData.Title != 'Nakheel PJSC')
                        //                      continue;
                        if(fileData != null){
                            //String fileDescription = fileData.Description != null? fileData.Description: fileData.Title;
                            xml = xml + '<!--Zero or more repetitions:-->' +
                                '<cre:ATTACHED_FILES_ITEM>' +
                                '<cre:P_FILE_TYPE/>' +
                                '<cre:P_FILE_NAME/>' +
                                '<cre:P_FILE_DESC/>'   +
                                '<cre:P_FILE_DATA/>' +
                                '</cre:ATTACHED_FILES_ITEM>';
                        }
                        
                    }
                } else {
                    xml = xml + '<!--Zero or more repetitions:-->' +
                        '<cre:ATTACHED_FILES_ITEM>' +
                        '<cre:P_FILE_TYPE/>' +
                        '<cre:P_FILE_NAME/>' +
                        '<cre:P_FILE_DESC/>' +
                        '<cre:P_FILE_DATA/>' +
                        '</cre:ATTACHED_FILES_ITEM>';
                }
                system.debug('*** 3.xml :' + xml);
                xml = xml + '</cre:ATTACHED_FILES>' +
                    '<cre:TRADE_LICENSE_NUMBER>' + acc.Agency_Registration__r.Trade_Licence_Number__c + '</cre:TRADE_LICENSE_NUMBER>' +
                    '<cre:TRADE_LICENSE_EXPIRY_DATE/>' +
                    '<cre:TRADE_LICENSE_ISSUE_AUTHORITY/>' +
                    '<cre:TRN/>' +
                    '<cre:TRN_DETAILS/>' +
                    '<cre:TRN_EXPIRY_DATE>' + '' + '</cre:TRN_EXPIRY_DATE>' +
                    '<cre:TRN_ISSUING_AUTHROITY/>' +
                    '<cre:BANK_NAME>' + acc.Bank_Name__c + '</cre:BANK_NAME>' +
                    '<cre:BANK_BRANCH>' + acc.Bank_Branch__c + '</cre:BANK_BRANCH>' +
                    '<cre:BANK_ACCOUNT_NUMBER>' + acc.Account_Number__c + '</cre:BANK_ACCOUNT_NUMBER>' +
                    '<cre:BANK_ACCOUNT_NAME>' + acc.Bank_Account_Name__c + '</cre:BANK_ACCOUNT_NAME>' +
                    '<cre:IBAN>' + acc.Bank_IBAN_Number__c + '</cre:IBAN>' +
                    '<cre:CURRENCY_CODE>' + acc.CurrencyIsoCode + '</cre:CURRENCY_CODE>' +
                    '<cre:SWIFT_CODE>' + acc.Bank_SWIFT_Code__c + '</cre:SWIFT_CODE>' +
                    '<cre:PRODUCTS_AND_SERVICES/>' +
                    '<cre:PAYMENT_MODE/>' +
                    '<cre:ADMIN_NAME/>' +
                    '<cre:TRADE_LICENSE_ATTACHMENT/>' +
                    '<cre:BANKACCOUNTDETAILS_ATTACHMENT/>' +
                    '<cre:TRNDETAILS_ATTACHMENT/>' +
                    '<cre:ADDITIONAL_VENDOR_INFO>' +
                    '<cre:VENDOR_ID/>' +
                    '<cre:SEGMENT1/>' +
                    '<cre:VENDOR_NAME/>' +
                    '<cre:VENDOR_NAME_ALT/>' +
                    '<cre:SUMMARY_FLAG/>' +
                    '<cre:ENABLED_FLAG/>' +
                    '<cre:SEGMENT2/>' +
                    '<cre:SEGMENT3/>' +
                    '<cre:SEGMENT4/>' +
                    '<cre:SEGMENT5/>' +
                    '<cre:EMPLOYEE_ID/>' +
                    '<cre:VENDOR_TYPE_LOOKUP_CODE/>' +
                    '<cre:CUSTOMER_NUM/>' +
                    '<cre:ONE_TIME_FLAG/>' +
                    '<cre:PARENT_VENDOR_ID/>' +
                    '<cre:MIN_ORDER_AMOUNT/>' +
                    '<cre:TERMS_ID/>' +
                    '<cre:SET_OF_BOOKS_ID/>' +
                    '<cre:ALWAYS_TAKE_DISC_FLAG/>' +
                    '<cre:PAY_DATE_BASIS_LOOKUP_CODE/>' +
                    '<cre:PAY_GROUP_LOOKUP_CODE/>' +
                    '<cre:PAYMENT_PRIORITY/>' +
                    '<cre:INVOICE_CURRENCY_CODE/>' +
                    '<cre:PAYMENT_CURRENCY_CODE/>' +
                    '<cre:INVOICE_AMOUNT_LIMIT/>' +
                    '<cre:HOLD_ALL_PAYMENTS_FLAG/>' +
                    '<cre:HOLD_FUTURE_PAYMENTS_FLAG/>' +
                    '<cre:HOLD_REASON/>' +
                    '<cre:TYPE_1099/>' +
                    '<cre:WITHHOLDING_STATUS_LOOKUP_CODE/>' +
                    '<cre:WITHHOLDING_START_DATE/>' +
                    '<cre:ORGANIZATION_TYPE_LOOKUP_CODE/>' +
                    '<cre:START_DATE_ACTIVE/>' +
                    '<cre:END_DATE_ACTIVE/>' +
                    '<cre:MINORITY_GROUP_LOOKUP_CODE/>' +
                    '<cre:WOMEN_OWNED_FLAG/>' +
                    '<cre:SMALL_BUSINESS_FLAG/>' +
                    '<cre:HOLD_FLAG/>' +
                    '<cre:PURCHASING_HOLD_REASON/>' +
                    '<cre:HOLD_BY/>' +
                    '<cre:HOLD_DATE/>' +
                    '<cre:TERMS_DATE_BASIS/>' +
                    '<cre:INSPECTION_REQUIRED_FLAG/>' +
                    '<cre:RECEIPT_REQUIRED_FLAG/>' +
                    '<cre:QTY_RCV_TOLERANCE/>' +
                    '<cre:QTY_RCV_EXCEPTION_CODE/>' +
                    '<cre:ENFORCE_SHIP_TO_LOCATION_CODE/>' +
                    '<cre:DAYS_EARLY_RECEIPT_ALLOWED/>' +
                    '<cre:DAYS_LATE_RECEIPT_ALLOWED/>' +
                    '<cre:RECEIPT_DAYS_EXCEPTION_CODE/>' +
                    '<cre:RECEIVING_ROUTING_ID/>' +
                    '<cre:ALLOW_SUBSTITUTE_RECEIPTS_FLAG/>' +
                    '<cre:ALLOW_UNORDERED_RECEIPTS_FLAG/>' +
                    '<cre:HOLD_UNMATCHED_INVOICES_FLAG/>' +
                    '<cre:TAX_VERIFICATION_DATE/>' +
                    '<cre:NAME_CONTROL/>' +
                    '<cre:STATE_REPORTABLE_FLAG/>' +
                    '<cre:FEDERAL_REPORTABLE_FLAG/>' +
                    '<cre:ATTRIBUTE_CATEGORY/>' +
                    '<cre:ATTRIBUTE1/>' +
                    '<cre:ATTRIBUTE2/>' +
                    '<cre:ATTRIBUTE3/>' +
                    '<cre:ATTRIBUTE4/>' +
                    '<cre:ATTRIBUTE5/>' +
                    '<cre:ATTRIBUTE6/>' +
                    '<cre:ATTRIBUTE7/>' +
                    '<cre:ATTRIBUTE8/>' +
                    '<cre:ATTRIBUTE9/>' +
                    '<cre:ATTRIBUTE10/>' +
                    '<cre:ATTRIBUTE11/>' +
                    '<cre:ATTRIBUTE12/>' +
                    '<cre:ATTRIBUTE13/>' +
                    '<cre:ATTRIBUTE14/>' +
                    '<cre:ATTRIBUTE15/>' +
                    '<cre:AUTO_CALCULATE_INTEREST_FLAG/>' +
                    '<cre:VALIDATION_NUMBER/>' +
                    '<cre:EXCLUDE_FREIGHT_FROM_DISCOUNT/>' +
                    '<cre:TAX_REPORTING_NAME/>' +
                    '<cre:CHECK_DIGITS/>' +
                    '<cre:ALLOW_AWT_FLAG/>' +
                    '<cre:AWT_GROUP_ID/>' +
                    '<cre:AWT_GROUP_NAME/>' +
                    '<cre:PAY_AWT_GROUP_ID/>' +
                    '<cre:PAY_AWT_GROUP_NAME/>' +
                    '<cre:GLOBAL_ATTRIBUTE1/>' +
                    '<cre:GLOBAL_ATTRIBUTE2/>' +
                    '<cre:GLOBAL_ATTRIBUTE3/>' +
                    '<cre:GLOBAL_ATTRIBUTE4/>' +
                    '<cre:GLOBAL_ATTRIBUTE5/>' +
                    '<cre:GLOBAL_ATTRIBUTE6/>' +
                    '<cre:GLOBAL_ATTRIBUTE7/>' +
                    '<cre:GLOBAL_ATTRIBUTE8/>' +
                    '<cre:GLOBAL_ATTRIBUTE9/>' +
                    '<cre:GLOBAL_ATTRIBUTE10/>' +
                    '<cre:GLOBAL_ATTRIBUTE11/>' +
                    '<cre:GLOBAL_ATTRIBUTE12/>' +
                    '<cre:GLOBAL_ATTRIBUTE13/>' +
                    '<cre:GLOBAL_ATTRIBUTE14/>' +
                    '<cre:GLOBAL_ATTRIBUTE15/>' +
                    '<cre:GLOBAL_ATTRIBUTE16/>' +
                    '<cre:GLOBAL_ATTRIBUTE17/>' +
                    '<cre:GLOBAL_ATTRIBUTE18/>' +
                    '<cre:GLOBAL_ATTRIBUTE19/>' +
                    '<cre:GLOBAL_ATTRIBUTE20/>' +
                    '<cre:GLOBAL_ATTRIBUTE_CATEGORY/>' +
                    '<cre:BANK_CHARGE_BEARER/>' +
                    '<cre:MATCH_OPTION/>' +
                    '<cre:CREATE_DEBIT_MEMO_FLAG/>' +
                    '<cre:PARTY_ID/>' +
                    '<cre:PARENT_PARTY_ID/>' +
                    '<cre:JGZZ_FISCAL_CODE/>' +
                    '<cre:SIC_CODE/>' +
                    '<cre:TAX_REFERENCE/>' +
                    '<cre:INVENTORY_ORGANIZATION_ID/>' +
                    '<cre:TERMS_NAME/>' +
                    '<cre:DEFAULT_TERMS_ID/>' +
                    '<cre:VENDOR_INTERFACE_ID/>' +
                    '<cre:NI_NUMBER/>' +
                    '<cre:EXT_PAYEE_REC>' +
                    '<cre:PAYEE_PARTY_ID/>' +
                    '<cre:PAYMENT_FUNCTION/>' +
                    '<cre:EXCLUSIVE_PAY_FLAG/>' +
                    '<cre:PAYEE_PARTY_SITE_ID/>' +
                    '<cre:SUPPLIER_SITE_ID/>' +
                    '<cre:PAYER_ORG_ID/>' +
                    '<cre:PAYER_ORG_TYPE/>' +
                    '<cre:DEFAULT_PMT_METHOD/>' +
                    '<cre:ECE_TP_LOC_CODE/>' +
                    '<cre:BANK_CHARGE_BEARER/>' +
                    '<cre:BANK_INSTR1_CODE/>' +
                    '<cre:BANK_INSTR2_CODE/>' +
                    '<cre:BANK_INSTR_DETAIL/>' +
                    '<cre:PAY_REASON_CODE/>' +
                    '<cre:PAY_REASON_COM/>' +
                    '<cre:INACTIVE_DATE/>' +
                    '<cre:PAY_MESSAGE1/>' +
                    '<cre:PAY_MESSAGE2/>' +
                    '<cre:PAY_MESSAGE3/>' +
                    '<cre:DELIVERY_CHANNEL/>' +
                    '<cre:PMT_FORMAT/>' +
                    '<cre:SETTLEMENT_PRIORITY/>' +
                    '<cre:REMIT_ADVICE_DELIVERY_METHOD/>' +
                    '<cre:REMIT_ADVICE_EMAIL/>' +
                    '<cre:EDI_PAYMENT_FORMAT/>' +
                    '<cre:EDI_TRANSACTION_HANDLING/>' +
                    '<cre:EDI_PAYMENT_METHOD/>' +
                    '<cre:EDI_REMITTANCE_METHOD/>' +
                    '<cre:EDI_REMITTANCE_INSTRUCTION/>' +
                    '<cre:REMIT_ADVICE_FAX/>' +
                    '</cre:EXT_PAYEE_REC>' +
                    '<cre:EDI_PAYMENT_FORMAT/>' +
                    '<cre:EDI_TRANSACTION_HANDLING/>' +
                    '<cre:EDI_PAYMENT_METHOD/>' +
                    '<cre:EDI_REMITTANCE_METHOD/>' +
                    '<cre:EDI_REMITTANCE_INSTRUCTION/>' +
                    '<cre:URL/>' +
                    '<cre:SUPPLIER_NOTIF_METHOD/>' +
                    '<cre:REMITTANCE_EMAIL/>' +
                    '<cre:CEO_NAME/>' +
                    '<cre:CEO_TITLE/>' +
                    '<cre:VAT_CODE/>' +
                    '<cre:AUTO_TAX_CALC_FLAG/>' +
                    '<cre:OFFSET_TAX_FLAG/>' +
                    '<cre:VAT_REGISTRATION_NUM/>' +
                    '<cre:AP_TAX_ROUNDING_RULE/>' +
                    '<cre:AMOUNT_INCLUDES_TAX_FLAG/>' +
                    '<cre:AP_TAX_ROUNDING_LEVEL_CODE/>' +
                    '</cre:ADDITIONAL_VENDOR_INFO>' +
                    '<cre:ADDITIONAL_VENDOR_SITE_INFO>' +
                    '<!--Zero or more repetitions:-->' +
                    '<cre:ADDITIONAL_VENDOR_SITE_INFO_ITEM>' +
                    '<cre:AREA_CODE/>' +
                    '<cre:PHONE/>' +
                    '<cre:CUSTOMER_NUM/>' +
                    '<cre:SHIP_TO_LOCATION_ID/>' +
                    '<cre:BILL_TO_LOCATION_ID/>' +
                    '<cre:SHIP_VIA_LOOKUP_CODE/>' +
                    '<cre:FREIGHT_TERMS_LOOKUP_CODE/>' +
                    '<cre:FOB_LOOKUP_CODE/>' +
                    '<cre:INACTIVE_DATE/>' +
                    '<cre:FAX/>' +
                    '<cre:FAX_AREA_CODE/>' +
                    '<cre:TELEX/>' +
                    '<cre:TERMS_DATE_BASIS/>' +
                    '<cre:DISTRIBUTION_SET_ID/>' +
                    '<cre:ACCTS_PAY_CODE_COMBINATION_ID/>' +
                    '<cre:PREPAY_CODE_COMBINATION_ID/>' +
                    '<cre:PAY_GROUP_LOOKUP_CODE/>' +
                    '<cre:PAYMENT_PRIORITY/>' +
                    '<cre:TERMS_ID/>' +
                    '<cre:INVOICE_AMOUNT_LIMIT/>' +
                    '<cre:PAY_DATE_BASIS_LOOKUP_CODE/>' +
                    '<cre:ALWAYS_TAKE_DISC_FLAG/>' +
                    '<cre:INVOICE_CURRENCY_CODE/>' +
                    '<cre:PAYMENT_CURRENCY_CODE/>' +
                    '<cre:VENDOR_SITE_ID/>' +
                    '<cre:LAST_UPDATE_DATE/>' +
                    '<cre:LAST_UPDATED_BY/>' +
                    '<cre:VENDOR_ID/>' +
                    '<cre:VENDOR_SITE_CODE/>' +
                    '<cre:VENDOR_SITE_CODE_ALT/>' +
                    '<cre:PURCHASING_SITE_FLAG/>' +
                    '<cre:RFQ_ONLY_SITE_FLAG/>' +
                    '<cre:PAY_SITE_FLAG/>' +
                    '<cre:ATTENTION_AR_FLAG/>' +
                    '<cre:HOLD_ALL_PAYMENTS_FLAG/>' +
                    '<cre:HOLD_FUTURE_PAYMENTS_FLAG/>' +
                    '<cre:HOLD_REASON/>' +
                    '<cre:HOLD_UNMATCHED_INVOICES_FLAG/>' +
                    '<cre:TAX_REPORTING_SITE_FLAG/>' +
                    '<cre:ATTRIBUTE_CATEGORY/>' +
                    '<cre:ATTRIBUTE1/>' +
                    '<cre:ATTRIBUTE2/>' +
                    '<cre:ATTRIBUTE3/>' +
                    '<cre:ATTRIBUTE4/>' +
                    '<cre:ATTRIBUTE5/>' +
                    '<cre:ATTRIBUTE6/>' +
                    '<cre:ATTRIBUTE7/>' +
                    '<cre:ATTRIBUTE8/>' +
                    '<cre:ATTRIBUTE9/>' +
                    '<cre:ATTRIBUTE10/>' +
                    '<cre:ATTRIBUTE11/>' +
                    '<cre:ATTRIBUTE12/>' +
                    '<cre:ATTRIBUTE13/>' +
                    '<cre:ATTRIBUTE14/>' +
                    '<cre:ATTRIBUTE15/>' +
                    '<cre:VALIDATION_NUMBER/>' +
                    '<cre:EXCLUDE_FREIGHT_FROM_DISCOUNT/>' +
                    '<cre:BANK_CHARGE_BEARER/>' +
                    '<cre:ORG_ID/>' +
                    '<cre:CHECK_DIGITS/>' +
                    '<cre:ALLOW_AWT_FLAG/>' +
                    '<cre:AWT_GROUP_ID/>' +
                    '<cre:PAY_AWT_GROUP_ID/>' +
                    '<cre:DEFAULT_PAY_SITE_ID/>' +
                    '<cre:PAY_ON_CODE/>' +
                    '<cre:PAY_ON_RECEIPT_SUMMARY_CODE/>' +
                    '<cre:GLOBAL_ATTRIBUTE_CATEGORY/>' +
                    '<cre:GLOBAL_ATTRIBUTE1/>' +
                    '<cre:GLOBAL_ATTRIBUTE2/>' +
                    '<cre:GLOBAL_ATTRIBUTE3/>' +
                    '<cre:GLOBAL_ATTRIBUTE4/>' +
                    '<cre:GLOBAL_ATTRIBUTE5/>' +
                    '<cre:GLOBAL_ATTRIBUTE6/>' +
                    '<cre:GLOBAL_ATTRIBUTE7/>' +
                    '<cre:GLOBAL_ATTRIBUTE8/>' +
                    '<cre:GLOBAL_ATTRIBUTE9/>' +
                    '<cre:GLOBAL_ATTRIBUTE10/>' +
                    '<cre:GLOBAL_ATTRIBUTE11/>' +
                    '<cre:GLOBAL_ATTRIBUTE12/>' +
                    '<cre:GLOBAL_ATTRIBUTE13/>' +
                    '<cre:GLOBAL_ATTRIBUTE14/>' +
                    '<cre:GLOBAL_ATTRIBUTE15/>' +
                    '<cre:GLOBAL_ATTRIBUTE16/>' +
                    '<cre:GLOBAL_ATTRIBUTE17/>' +
                    '<cre:GLOBAL_ATTRIBUTE18/>' +
                    '<cre:GLOBAL_ATTRIBUTE19/>' +
                    '<cre:GLOBAL_ATTRIBUTE20/>' +
                    '<cre:TP_HEADER_ID/>' +
                    '<cre:ECE_TP_LOCATION_CODE/>' +
                    '<cre:PCARD_SITE_FLAG/>' +
                    '<cre:MATCH_OPTION/>' +
                    '<cre:COUNTRY_OF_ORIGIN_CODE/>' +
                    '<cre:FUTURE_DATED_PAYMENT_CCID/>' +
                    '<cre:CREATE_DEBIT_MEMO_FLAG/>' +
                    '<cre:SUPPLIER_NOTIF_METHOD/>' +
                    '<cre:EMAIL_ADDRESS/>' +
                    '<cre:PRIMARY_PAY_SITE_FLAG/>' +
                    '<cre:SHIPPING_CONTROL/>' +
                    '<cre:SELLING_COMPANY_IDENTIFIER/>' +
                    '<cre:GAPLESS_INV_NUM_FLAG/>' +
                    '<cre:LOCATION_ID/>' +
                    '<cre:PARTY_SITE_ID/>' +
                    '<cre:ORG_NAME/>' +
                    '<cre:DUNS_NUMBER/>' +
                    '<cre:ADDRESS_STYLE/>' +
                    '<cre:LANGUAGE/>' +
                    '<cre:PROVINCE/>' +
                    '<cre:COUNTRY/>' +
                    '<cre:ADDRESS_LINE1/>' +
                    '<cre:ADDRESS_LINE2/>' +
                    '<cre:ADDRESS_LINE3/>' +
                    '<cre:ADDRESS_LINE4/>' +
                    '<cre:ADDRESS_LINES_ALT/>' +
                    '<cre:COUNTY/>' +
                    '<cre:CITY/>' +
                    '<cre:STATE/>' +
                    '<cre:ZIP/>' +
                    '<cre:TERMS_NAME/>' +
                    '<cre:DEFAULT_TERMS_ID/>' +
                    '<cre:AWT_GROUP_NAME/>' +
                    '<cre:PAY_AWT_GROUP_NAME/>' +
                    '<cre:DISTRIBUTION_SET_NAME/>' +
                    '<cre:SHIP_TO_LOCATION_CODE/>' +
                    '<cre:BILL_TO_LOCATION_CODE/>' +
                    '<cre:DEFAULT_DIST_SET_ID/>' +
                    '<cre:DEFAULT_SHIP_TO_LOC_ID/>' +
                    '<cre:DEFAULT_BILL_TO_LOC_ID/>' +
                    '<cre:TOLERANCE_ID/>' +
                    '<cre:TOLERANCE_NAME/>' +
                    '<cre:VENDOR_INTERFACE_ID/>' +
                    '<cre:VENDOR_SITE_INTERFACE_ID/>' +
                    '<cre:EXT_PAYEE_REC>' +
                    '<cre:PAYEE_PARTY_ID/>' +
                    '<cre:PAYMENT_FUNCTION/>' +
                    '<cre:EXCLUSIVE_PAY_FLAG/>' +
                    '<cre:PAYEE_PARTY_SITE_ID/>' +
                    '<cre:SUPPLIER_SITE_ID/>' +
                    '<cre:PAYER_ORG_ID/>' +
                    '<cre:PAYER_ORG_TYPE/>' +
                    '<cre:DEFAULT_PMT_METHOD/>' +
                    '<cre:ECE_TP_LOC_CODE/>' +
                    '<cre:BANK_CHARGE_BEARER/>' +
                    '<cre:BANK_INSTR1_CODE/>' +
                    '<cre:BANK_INSTR2_CODE/>' +
                    '<cre:BANK_INSTR_DETAIL/>' +
                    '<cre:PAY_REASON_CODE/>' +
                    '<cre:PAY_REASON_COM/>' +
                    '<cre:INACTIVE_DATE/>' +
                    '<cre:PAY_MESSAGE1/>' +
                    '<cre:PAY_MESSAGE2/>' +
                    '<cre:PAY_MESSAGE3/>' +
                    '<cre:DELIVERY_CHANNEL/>' +
                    '<cre:PMT_FORMAT/>' +
                    '<cre:SETTLEMENT_PRIORITY/>' +
                    '<cre:REMIT_ADVICE_DELIVERY_METHOD/>' +
                    '<cre:REMIT_ADVICE_EMAIL/>' +
                    '<cre:EDI_PAYMENT_FORMAT/>' +
                    '<cre:EDI_TRANSACTION_HANDLING/>' +
                    '<cre:EDI_PAYMENT_METHOD/>' +
                    '<cre:EDI_REMITTANCE_METHOD/>' +
                    '<cre:EDI_REMITTANCE_INSTRUCTION/>' +
                    '<cre:REMIT_ADVICE_FAX/>' +
                    '</cre:EXT_PAYEE_REC>' +
                    '<cre:RETAINAGE_RATE/>' +
                    '<cre:SERVICES_TOLERANCE_ID/>' +
                    '<cre:SERVICES_TOLERANCE_NAME/>' +
                    '<cre:SHIPPING_LOCATION_ID/>' +
                    '<cre:VAT_CODE/>' +
                    '<cre:VAT_REGISTRATION_NUM/>' +
                    '<cre:REMITTANCE_EMAIL/>' +
                    '<cre:EDI_ID_NUMBER/>' +
                    '<cre:EDI_PAYMENT_FORMAT/>' +
                    '<cre:EDI_TRANSACTION_HANDLING/>' +
                    '<cre:EDI_PAYMENT_METHOD/>' +
                    '<cre:EDI_REMITTANCE_METHOD/>' +
                    '<cre:EDI_REMITTANCE_INSTRUCTION/>' +
                    '<cre:PARTY_SITE_NAME/>' +
                    '<cre:OFFSET_TAX_FLAG/>' +
                    '<cre:AUTO_TAX_CALC_FLAG/>' +
                    '<cre:REMIT_ADVICE_DELIVERY_METHOD/>' +
                    '<cre:REMIT_ADVICE_FAX/>' +
                    '<cre:CAGE_CODE/>' +
                    '<cre:LEGAL_BUSINESS_NAME/>' +
                    '<cre:DOING_BUS_AS_NAME/>' +
                    '<cre:DIVISION_NAME/>' +
                    '<cre:SMALL_BUSINESS_CODE/>' +
                    '<cre:CCR_COMMENTS/>' +
                    '<cre:DEBARMENT_START_DATE/>' +
                    '<cre:DEBARMENT_END_DATE/>' +
                    '<cre:AP_TAX_ROUNDING_RULE/>' +
                    '<cre:AMOUNT_INCLUDES_TAX_FLAG/>' +
                    '<cre:ACK_LEAD_TIME/>' +
                    '<cre:AP_TAX_ROUNDING_LEVEL_CODE/>' +
                    '</cre:ADDITIONAL_VENDOR_SITE_INFO_ITEM>' +
                    '</cre:ADDITIONAL_VENDOR_SITE_INFO>' +
                    '<cre:ADDITIONAL_VENDOR_CONTACT_INFO>';
                system.debug('*** 4.xml :' + xml);
                if (mapAccountToContacts.containsKey(acc.Id)) {
                    for (Contact con : mapAccountToContacts.get(acc.Id)) {
                        //--Zero or more repetitions:--
                        xml = xml + '<cre:ADDITIONAL_VENDOR_CONTACT_INFO_ITEM>' +
                            '<cre:VENDOR_CONTACT_ID/>' +
                            '<cre:VENDOR_SITE_ID/>' +
                            '<cre:VENDOR_ID/>' +
                            '<cre:PER_PARTY_ID/>' +
                            '<cre:RELATIONSHIP_ID/>' +
                            '<cre:REL_PARTY_ID/>' +
                            '<cre:PARTY_SITE_ID/>' +
                            '<cre:ORG_CONTACT_ID/>' +
                            '<cre:ORG_PARTY_SITE_ID/>' +
                            '<cre:PERSON_FIRST_NAME>' + con.FirstName + '</cre:PERSON_FIRST_NAME>' +
                            '<cre:PERSON_MIDDLE_NAME/>' +
                            '<cre:PERSON_LAST_NAME>' + con.LastName + '</cre:PERSON_LAST_NAME>' +
                            '<cre:PERSON_TITLE/>' +
                            '<cre:ORGANIZATION_NAME_PHONETIC/>' +
                            '<cre:PERSON_FIRST_NAME_PHONETIC/>' +
                            '<cre:PERSON_LAST_NAME_PHONETIC/>' +
                            '<cre:ATTRIBUTE_CATEGORY/>' +
                            '<cre:ATTRIBUTE1/>' +
                            '<cre:ATTRIBUTE2/>' +
                            '<cre:ATTRIBUTE3/>' +
                            '<cre:ATTRIBUTE4/>' +
                            '<cre:ATTRIBUTE5/>' +
                            '<cre:ATTRIBUTE6/>' +
                            '<cre:ATTRIBUTE7/>' +
                            '<cre:ATTRIBUTE8/>' +
                            '<cre:ATTRIBUTE9/>' +
                            '<cre:ATTRIBUTE10/>' +
                            '<cre:ATTRIBUTE11/>' +
                            '<cre:ATTRIBUTE12/>' +
                            '<cre:ATTRIBUTE13/>' +
                            '<cre:ATTRIBUTE14/>' +
                            '<cre:ATTRIBUTE15/>' +
                            '<cre:INACTIVE_DATE/>' +
                            '<cre:PARTY_NUMBER/>' +
                            '<cre:DEPARTMENT/>' +
                            '<cre:MAIL_STOP/>' +
                            '<cre:AREA_CODE>' + con.Country_Code__c + '</cre:AREA_CODE>' +
                            '<cre:PHONE>' + con.MobilePhone + '</cre:PHONE>' +
                            '<cre:ALT_AREA_CODE/>' +
                            '<cre:ALT_PHONE/>' +
                            '<cre:FAX_AREA_CODE/>' +
                            '<cre:FAX_PHONE/>' +
                            '<cre:EMAIL_ADDRESS>' + con.Email + '</cre:EMAIL_ADDRESS>' +
                            '<cre:URL/>' +
                            '<cre:VENDOR_CONTACT_INTERFACE_ID/>' +
                            '<cre:VENDOR_INTERFACE_ID/>' +
                            '<cre:VENDOR_SITE_CODE/>' +
                            '<cre:ORG_ID/>' +
                            '<cre:OPERATING_UNIT_NAME/>' +
                            '<cre:PREFIX/>' +
                            '<cre:CONTACT_NAME_PHONETIC/>' +
                            '<cre:PARTY_SITE_NAME/>' +
                            '</cre:ADDITIONAL_VENDOR_CONTACT_INFO_ITEM>';
                    }
                }
                system.debug('*** 5.xml :' + xml);
                xml = xml + '</cre:ADDITIONAL_VENDOR_CONTACT_INFO>' +
                    '</cre:P_VENDOR_REC_ITEM>';
            }
            system.debug('*** 5.xml :' + xml);
            xml = xml + '</cre:P_VENDOR_REC>' +
                '<cre:P_VENDOR_ID>' + VendorId + '</cre:P_VENDOR_ID>' +
                '</cre:InputParameters>' +
                '</soapenv:Body>' +
                '</soapenv:Envelope>';
            system.debug('credential :' + credential);
            system.debug('Body :' + xml);
            doOracleCallout(xml, credential, accountSet);
        }catch(Exception e){
            List<Account> accList = new List<Account>(); 
            for(ID accID : accountSet){
                Account acc1 = new Account(ID= accID ,Error_Message__c = e.getMessage());
                accList.add(acc1);
            }
            if(accList.size() > 0){
                update accList;
            }
        }
    }
    
    public static void doOracleCallout(String body, ISupplier_Credentials__mdt credential, set<Id> accountSet) {
        Account account = new Account();
        for (Id accId : accountSet) {
            account.Id = accId;
            break;
        }
        HTTPResponse resp;
        try {
            HTTP h = new HTTP();
            HTTPRequest r = new HTTPRequest();
            String username = credential.Username__c; //Oracle_Username
            String password = credential.Password__c;//Oracle_Password
            r.setEndpoint(credential.Endpoint__c);//Oracle_Endpoint
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            r.setHeader('Authorization', authorizationHeader);
            r.setHeader('Content-Type', 'text/xml; charset=UTF-8');
            r.setBody(body);
            r.setMethod('POST');
            r.setTimeout(120000);
            resp = h.send(r);
            system.debug('response-->' + resp.getBody());
            if (resp.getStatusCode() == 200) {
                
                system.debug('vendor Id before 1->>>' + account.Vendor_Id__c);
                
                Dom.Document doc = new Dom.Document();
                doc.load(resp.getBody());
                Dom.XMLNode rootElement = doc.getRootElement();
                for (Dom.XMLNode childElement : rootElement.getChildElements()) {
                    for (Dom.XMLNode detailElement : childElement.getChildElements()) {
                        if (detailElement.getName() == 'OutputParameters') {
                            for (Dom.XMLNode grandChild : detailElement.getChildElements()) {
                                
                                system.debug('*** grand node: ' + grandChild.getName());
                                if (grandChild.getName() == 'X_MSG_DATA') {
                                    system.debug('***msg data: ' + grandChild.getName() + 'value : ' + grandChild.getText());
                                    if (grandChild.getText() != '')account.Error_Message__c = grandChild.getText();
                                }
                                if (grandChild.getName() == 'X_VENDOR_ID') {
                                    system.debug('***Vendor data: ' + grandChild.getName() + 'value : ' + grandChild.getText());
                                    if (grandChild.getText() != '')account.Vendor_Id__c = grandChild.getText();
                                }
                                if (grandChild.getName() == 'X_PARTY_ID') {
                                    system.debug('***Party data: ' + grandChild.getName() + 'value : ' + grandChild.getText());
                                    if (grandChild.getText() != '')account.Party_Id__c = grandChild.getText();
                                }
                            }
                        }
                    }
                }
                account.Send_To_iSupplier__c = false;
                system.debug('vendor Id before ->>>' + account.Vendor_Id__c);
                system.debug('account updated ->>>' + IsfileJobExceute);
                Database.SaveResult acc_up =  Database.update(account, false);
                if (acc_up.isSuccess()){
                    IsfileJobExceute = true;
                    system.debug('account updated after ->>>' + IsfileJobExceute);
                }
                vendorIdForFile = account.Vendor_Id__c;
                system.debug('vendor Id after ->>>' + vendorIdForFile);
                //update account;               
                String iSupplierSuccess = System.Label.NKHL_ISupplier_Success_Log;
                if(iSupplierSuccess != null && iSupplierSuccess.toUpperCase() == 'TRUE'){
                    LoggerUtility.logException( null, body, resp.getBody() );
                }
                // return account.Vendor_Id__c;
            }else{
                LoggerUtility.logException( null, String.valueOf(body), String.valueOf(resp.getBody()) );
                account.Error_Message__c = resp.getStatus();
                update account;
            }
            
        } catch (exception e) {
            system.debug('e:' + e);
            String responseBody = resp != null ? String.valueOf(resp.getBody()) : null;
            LoggerUtility.logException( e, String.valueOf(body), responseBody );
            account.Error_Message__c = e.getMessage();
            update account;
        }
    }
    
    public static List<Account> getAccountDetails(set<Id> accountSet) {
        List<Account> accountList = new List<Account>();
        DescribeSObjectResult describeResult = Account.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String>(describeResult.fields.getMap().keySet());
        String query = ' SELECT  ' + 'Agency_Registration__r.Trade_Licence_Number__c  ' + ', ' + String.join(fieldNames, ',') + ' FROM ' ;
        query += describeResult.getName() + '  where ID IN:accountSet' ;
        accountList = database.query(query);
        system.debug('***accountList' + accountList);
        return accountList;
    }
    
    public static Map<Id, List<Contact>> getContactDetails(set<Id> accountSet) {
        List<Contact> contactList = new List<Contact>();
        Map<Id, List<Contact>> mapAccountToContacts = new Map<Id, List<Contact>>();
        DescribeSObjectResult describeResult = Contact.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String>(describeResult.fields.getMap().keySet());
        String query = ' SELECT  ' + String.join(fieldNames, ',') + ' FROM ' ;
        query += describeResult.getName() + '  where AccountId  IN:accountSet' ;
        contactList = database.query(query);
        system.debug('***contactList' + contactList);
        for (Contact con : contactList) {
            if (mapAccountToContacts.containsKey(con.AccountId)) {
                mapAccountToContacts.get(con.AccountId).add(con);
            } else {
                mapAccountToContacts.put(con.AccountId, new List<Contact>{
                    con
                        });
            }
        }
        return mapAccountToContacts;
    }
    public static Map<Id, Document__c>  getDocumentCvMap(set<Id> accountSet){
        system.debug('accountSet##' + accountSet.size());
        Set< String > setDocumentTypes = new Set< String >();
        Map<Id, Document__c> cvDocMap = new Map<Id, Document__c>(); 
        // Get the document types
        for (Broker_Documents__mdt metadataConfig : [SELECT Id, MasterLabel FROM Broker_Documents__mdt]) {
            setDocumentTypes.add(metadataConfig.MasterLabel);
        }
        system.debug('setDocumentTypes@@' + setDocumentTypes);
        List<Document__c> docList = [
            SELECT Id, Name, Broker_Agreement_Id__c, Account__c
            FROM Document__c
            WHERE Account__c IN :accountSet
            AND Document_Type__c IN :setDocumentTypes
        ];
        system.debug('docListSize@@'+ docList.size());
        for (Document__c doc : docList) {
            cvDocMap.put(doc.Broker_Agreement_Id__c, doc);
        }
        return cvDocMap;
    }
    
    public static Map<Id, List<ContentVersion>> getDocumentDetailsForAccountsSet(set<Id> accountSet,Set<ID> docIDS) {
        Map<Id, List<ContentVersion>> mapAccountToContentVersion = new Map<Id, List<ContentVersion>>();
        Set< String > setDocumentTypes = new Set< String >();
        Set< String > setAttachmentIds = new Set< String >();
        Map<Id, ContentVersion> mapConDocumentToConVersion = new Map<Id, ContentVersion>();
        
        // Get the document types
        for (Broker_Documents__mdt metadataConfig : [SELECT Id, MasterLabel FROM Broker_Documents__mdt]) {
            setDocumentTypes.add(metadataConfig.MasterLabel);
        }
        System.debug('@@@'+setDocumentTypes);
        List<Document__c> docList = new List<Document__c>();
        if(docIDS == null){
            docList = [SELECT Id, Name, Account__c FROM Document__c WHERE Account__c IN :accountSet 
                       AND Document_Type__c IN :setDocumentTypes];    
        }else{
            docList = [SELECT Id, Name, Broker_Agreement_Id__c, Account__c FROM Document__c WHERE ID IN : docIDS
                       AND Document_Type__c IN :setDocumentTypes]; 
        }
        
        system.debug('docList@@@@'+docList);
        for (Document__c doc : docList) {
            setAttachmentIds.add(doc.Broker_Agreement_Id__c);
        }
        
        system.debug('setAttachmentIds@@@@'+setAttachmentIds);
        List<ContentVersion> contentVersions = [
            SELECT Id,FileType,FileExtension,Title,
            ContentDocumentId,Description,VersionData
            FROM ContentVersion
            WHERE ContentDocumentId IN:setAttachmentIds
        ];
        for (ContentVersion cv : contentVersions) {
            mapConDocumentToConVersion.put(cv.ContentDocumentId, cv);
        }
        
        for (Document__c temp : docList) {
            if (mapAccountToContentVersion.containskey(temp.Account__c)) {
                mapAccountToContentVersion.get(temp.Account__c).add(mapConDocumentToConVersion.get(temp.Broker_Agreement_Id__c));
            } else {
                mapAccountToContentVersion.put(temp.Account__c, new List<ContentVersion>{
                    mapConDocumentToConVersion.get(temp.Broker_Agreement_Id__c)
                        });
            }
        }
        system.debug('***mapAccountToContentVersion' + mapAccountToContentVersion);
        return mapAccountToContentVersion;
    }
    
    public static String generateTimestamp() {
        return Datetime.now().formatGmt('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
    }
    
    /**
* Create XML request for File Data.
*/
    public static void XMLForFileGenerator(Set<Id> accountSet,String vendorIDs,Set<ID> docIDS){
        system.debug('docIDS@@@@@'+docIDS);
        Map<Id, Document__c> cvDocMap = new Map<Id, Document__c>();
        ISupplier_Credentials__mdt credential = new ISupplier_Credentials__mdt();
        Map<Id, List<ContentVersion>> cvMap = new Map<Id,List<ContentVersion>>();
        String xml;
        String username;
        String password;
        String endpoint;
        try{
            String createdDateTime = generateTimestamp();
            cvDocMap = getDocumentCvMap(accountSet);
            cvMap = getDocumentDetailsForAccountsSet(accountSet,docIDS);    
            credential = [
                SELECT label,Nonce__c,Username__c,Endpoint__c,Password__c
                FROM ISupplier_Credentials__mdt
                WHERE MasterLabel = 'ISupplier Access For Attachment'
            ];
            username =  credential.Username__c;
            password = credential.Password__c;
            endPoint = credential.Endpoint__c;
            system.debug('cvMap >>'+ cvMap);
            system.debug('credential >>'+ credential);
            system.debug('vendorIdForFile' + vendorIDs);
            xml = '<soapenv:Envelope xmlns:att="http://xmlns.oracle.com/apps/ap/soaprovider/plsql/xxims_salesforce_supplier_int_pkg/attach_file/" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<soapenv:Header>' +
                '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' +
                '<wsse:UsernameToken wsu:Id="UsernameToken-4359394290A6A9FBBA16423989909581">' +
                '<wsse:Username>' +  credential.Username__c + '</wsse:Username>' +
                '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' +  credential.Password__c + '</wsse:Password>' +
                '<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + credential.Nonce__c + '</wsse:Nonce>' +
                '<wsu:Created>' + createdDateTime + '</wsu:Created>' +
                '</wsse:UsernameToken>' +
                '</wsse:Security>' +
                '</soapenv:Header>' +
                '<soapenv:Body>' +
                '<att:InputParameters>' +
                '<att:P_PRIMARY_KEY1>'  + vendorIDs + '</att:P_PRIMARY_KEY1>' +
                '<att:P_PRIMARY_KEY2>'  + vendorIDs + '</att:P_PRIMARY_KEY2>' +
                '<att:P_ENTITY_NAME>' + 'PO_VENDORS' + '</att:P_ENTITY_NAME>' ;
            system.debug('xml 1 >>' + xml);
        }catch(Exception e){
            List<Document__c> docList = cvDocMap.values();
            List<Document__c> UpdateDocErrorMsg = new List<Document__c>();
            for(Document__c doc: docList){
                doc.Error_Message__c = e.getMessage();
                doc.Isupplier_Callout_Status__c = 'Failure';
                UpdateDocErrorMsg.add(doc);
            }
            if(UpdateDocErrorMsg.size() > 0){
                update UpdateDocErrorMsg;
            }
        }
        system.debug('cvMap@@@@'+cvMap);
        sendRequestFileData(cvMap,cvDocMap,xml,username,password,endpoint);
    }
    
    /**
* Create XML request for File Data.
*/
    
    public static void sendRequestFileData(Map<Id, List<ContentVersion>> cvMap,Map<Id, Document__c> cvDocMap,
                                           String xml,String username,String password,String endpoint){
                                               List<Document__c> finalDocList = new List<Document__c>();
                                               for(ID accId : cvMap.keySet()){
                                                   
                                                   system.debug('cvMap@@@@'+cvMap);
                                                   for(ContentVersion fileData: cvMap.get(accID)){
                                                       if(fileData != null){
                                                           system.debug('fileData**' + fileData);
                                                           String fileDescription = fileData.Description != null? fileData.Description: fileData.Title;
                                                           String body = xml + '<!--Zero or more repetitions:-->' +
                                                               '<att:P_FILE_OBJECT>' +
                                                               '<att:P_FILE_OBJECT_ITEM>' +
                                                               '<att:P_FILE_TYPE>' + 'File' + '</att:P_FILE_TYPE>' +
                                                               '<att:P_FILE_NAME>' + fileData.Title + '</att:P_FILE_NAME>' +
                                                               '<att:P_FILE_DESC>' + fileDescription  + '</att:P_FILE_DESC>' +
                                                               '<att:P_FILE_DATA>' + EncodingUtil.base64Encode(fileData.VersionData) + '</att:P_FILE_DATA>' +
                                                               '</att:P_FILE_OBJECT_ITEM>' +
                                                               '</att:P_FILE_OBJECT>' +
                                                               '</att:InputParameters>' +
                                                               '</soapenv:Body>' +
                                                               '</soapenv:Envelope>';
                                                           Document__c doc = cvDocMap.get(fileData.contentDocumentID);
                                                           Document__c doc1 = calloutForFile(body,doc, username, password, endpoint);
                                                           if(doc1 != null){
                                                                finalDocList.add(doc1);
                                                           }
                                                          
                                                       }
                                                   }
                                                   if(finalDocList.size() > 0){
                                                       update finalDocList;
                                                   }
                                               }
                                           }
    
    /**
* HTTP callout to Oracle with File Body Request.
*/
    public static Document__c calloutForFile(String body,Document__c doc,String username,String password,String endpoint){
        system.debug('BODY -->' + body);
        HTTPResponse resp;
        try{
            HTTP h = new HTTP();
            HTTPRequest r = new HTTPRequest();
            r.setEndpoint(endpoint);//Oracle_Endpoint
            Blob headerValue = Blob.valueOf(username + ':' + password);
            System.debug(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            r.setHeader('Authorization', authorizationHeader);
            r.setHeader('Content-Type', 'text/xml; charset=UTF-8');
            r.setBody(body);
            r.setMethod('POST');
            r.setTimeout(120000);
            resp = h.send(r);
            system.debug('response1-->' + resp);
            
            if (resp.getStatusCode() == 200) {
                doc.Error_Message__c = '';
                doc.Isupplier_Callout_Status__c = 'Success';
            }else{
                doc.Isupplier_Callout_Status__c = 'Failure';
                doc.Error_Message__c = resp.getStatus();
                LoggerUtility.logException( null, String.valueOf(body), String.valueOf(resp.getBody()) );
            }
            return doc;
        }catch(Exception e){
            doc.Error_Message__c = e.getMessage();
            doc.Isupplier_Callout_Status__c = 'Failure';
            update doc;
            system.debug('e:' + e);
            String responseBody = resp != null ? String.valueOf(resp.getBody()) : null;
            LoggerUtility.logException( e, String.valueOf(body), responseBody );
            return null;
        }
    }
}