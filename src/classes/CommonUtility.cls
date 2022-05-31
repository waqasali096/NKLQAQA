/*
* Description: This class is for common utility methods
* Author: Cloudworks
* Name: CommonUtility
*/
public class CommonUtility {
    
    public static Boolean isSandbox(){
        return [SELECT Id, IsSandbox, Name FROM Organization LIMIT 1].IsSandbox;
    }
    
    public static String getRandomString(Integer len) {
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    public static Long getRandomNumber(Integer len) {
        Long randomNumber = 0;
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        randomNumber = Long.valueOf(str.substring(0, len));
        return randomNumber;
    }
    
    //get recordTypeId by Object Name & Record Type Developer Name
    public static Id recordTypeIdByDevName(Schema.SObjectType sObjType, string recTypeDevName){
        Id recTypeId;
        if(sObjType != NULL && String.isNotBlank(recTypeDevName)){
            recTypeId = sObjType.getDescribe().getRecordTypeInfosByDeveloperName().get(recTypeDevName).getRecordTypeId();
        }  
        return recTypeId;  
    }
    
    //get picklist field value label from api value
    public static String getPicklistLabel(Schema.SObjectType sObjType, String fieldAPIName, String fieldAPIValue){
        String label = '';
        Schema.DescribeSObjectResult desResult = sObjType.getDescribe();
        Map<String,Schema.SObjectField> sObjectFields = desResult.fields.getMap() ;
        Schema.DescribeFieldResult fieldDesResult = sObjectFields.get(fieldAPIName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldDesResult.getPicklistValues();
        for(Schema.PicklistEntry pval : ple){
            if(fieldAPIValue == pval.getValue()){
                label = pval.getLabel();
                break;
            }
        }
        return label;
    }
    
    //Check what id is case record id
    public static Boolean isCaseId(string whatId){
        String casePrefix = Schema.SObjectType.Case.getKeyPrefix();
        return whatId.startsWith(casePrefix);
    }
    
    
    //Convert a value < 100 to English.    
    public static String convert_nn(integer val) {
        String[] to_19 = ConstantUtility.to_19;
        String[] tens = ConstantUtility.tens;
        if (val < 20)  
            return to_19[val];  
        if(val == 100)  
            return 'One Hundred';  
        for (integer v = 0; v < tens.size(); v++) {  
            String dcap = tens[v];  
            integer dval = 20 + 10 * v;  
            if (dval + 10 > val) {  
                if (Math.Mod(val,10) != 0)  
                    return dcap + ' ' + to_19[Math.Mod(val,10)];  
                return dcap;  
            }      
        }  
        return 'Should never get here, less than 100 failure';  
    }  
    
    public static String convert_nnn(integer val) {  
        String word = '';  
        integer rem = val / 100;  
        integer mod = Math.mod(val,100);
        String[] to_19 = ConstantUtility.to_19;
        if (rem > 0) {  
            word = to_19[rem] + ' hundred';  
            if (mod > 0) {  
                word += ' ';  
            }  
        }  
        if (mod > 0) {  
            word += convert_nn(mod);  
        }  
        return word;  
    }
    
    public static String english_number(long val) {  
        if (val < 100) {  
            return convert_nn(val.intValue());  
        }  
        if (val < 1000) {  
            return convert_nnn(val.intValue());  
        } 
        String[] denom = ConstantUtility.denom;
        for (integer v = 0; v < denom.size(); v++) {  
            integer didx = v - 1;  
            integer dval = (integer)Math.pow(1000, v);  
            if (dval > val) {  
                integer mod = (integer)Math.pow(1000, didx);  
                integer l = (integer) val / mod;  
                integer r = (integer) val - (l * mod);  
                String ret = convert_nnn(l) + ' ' + denom[didx];  
                if (r > 0) {  
                    ret += ' ' + english_number(r);  
                }  
                return ret;  
            }  
        }  
        return 'Should never get here, bottomed out in english_number';  
    } 
    
    //Convert amount into words
    public static String convertAmountIntoWords(Decimal val){
        String strVal = String.ValueOf(val); // Convert Number to string
        String NumberToString1;
        String NumberToString2;
        String integerPart =strVal;
        String decimalPart;
        if(strVal.contains('.')){
            integerPart =strVal.substringBefore('.');
            decimalPart =strVal.substringAfter('.');
        }
        
        NumberToString1 = english_number(long.valueof(integerPart));// Get Number to String of before decimal place.
        if(!String.isBlank(decimalPart) && decimalPart != null){
            NumberToString2 = english_number(long.valueof(decimalPart));// Get Number to String of after decimal place.
        }
        
        //Here you will get exact out put
        return NumberToString1.toUppercase() + ' UAE DIRHAMS '+ (NumberToString2 != null ? 'AND '+NumberToString2.toUppercase() +' FILS ONLY' : 'AND ZERO FILS ONLY') ;
    }
    
    //get phone/mobile number with country code
    public static String getMobileNumberWithCountryCode(String mobileNumber, string countryCode){
        
        if(String.isNotBlank(countryCode) && String.isNotBlank(mobileNumber)){
            //check for local UAE number
            if(countryCode.contains('971') && mobileNumber.startsWith('0')){
                return mobileNumber;
            }else if(countryCode.contains('971') && !mobileNumber.startsWith('0')){
                return '0' + mobileNumber;
            }else{
                countryCode = countryCode.replaceAll('[+]','');
                return '00' + countryCode + mobileNumber;
            }
        }
        return mobileNumber;
    }
    
    //get picklist field values
    public static Map<String, String> getPicklistLabelValues(Schema.SObjectType sObjType, String fieldAPIName){
        Map<String, String> picklistValues = new Map<String, String>();
        Schema.DescribeSObjectResult desResult = sObjType.getDescribe();
        Map<String,Schema.SObjectField> sObjectFields = desResult.fields.getMap() ;
        Schema.DescribeFieldResult fieldDesResult = sObjectFields.get(fieldAPIName).getDescribe();
        for(Schema.PicklistEntry ple : fieldDesResult.getPicklistValues()){
            picklistValues.put(ple.getValue(), ple.getLabel());
        }
        return picklistValues;
    }
    
    //get picklist field labels
    public static List<String> getPicklistLabels(Schema.SObjectType sObjType, String fieldAPIName){
        List<String> picklistValues = new List<String>();
        Schema.DescribeSObjectResult desResult = sObjType.getDescribe();
        Map<String,Schema.SObjectField> sObjectFields = desResult.fields.getMap() ;
        Schema.DescribeFieldResult fieldDesResult = sObjectFields.get(fieldAPIName).getDescribe();
        for(Schema.PicklistEntry ple : fieldDesResult.getPicklistValues()){
            picklistValues.add(ple.getLabel());
        }
        return picklistValues;
    }
    
    //get picklist field values
    public static List<String> getPicklistValues(Schema.SObjectType sObjType, String fieldAPIName){
        List<String> picklistValues = new List<String>();
        Schema.DescribeSObjectResult desResult = sObjType.getDescribe();
        Map<String,Schema.SObjectField> sObjectFields = desResult.fields.getMap() ;
        Schema.DescribeFieldResult fieldDesResult = sObjectFields.get(fieldAPIName).getDescribe();
        for(Schema.PicklistEntry ple : fieldDesResult.getPicklistValues()){
            picklistValues.add(ple.getValue());
        }
        return picklistValues;
    }

    @AuraEnabled 
    public static Map<String, String> getPicklistValues(string obj, string fld){
        Map<String, String> options = new Map<String, String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(obj) ;
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        for (Schema.PicklistEntry p: values) {
            options.put(p.getValue(), p.getLabel());
        }
        system.debug('values'+values);
        return options;
    }
    
    @AuraEnabled 
    public static Map<String, String> getPicklistValuesByLabel(string obj, string fld){
        Map<String, String> options = new Map<String, String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(obj) ;
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        for (Schema.PicklistEntry p: values) {
            options.put(p.getLabel(), p.getValue());
        }
        system.debug('options'+options);
        return options;
    }
    
    /******************************************************************************************************
    * @Description        : Function to create email message                            
    * @Params             : NKLWrapperUtil.SendEmailWrapper input    
    * @Return             : Messaging.SingleEmailMessage                                                                        
    *******************************************************************************************************/
    public static Messaging.SingleEmailMessage createEmail( NKLWrapperUtil.SendEmailWrapper input ){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        message.setTargetObjectId( input.whoId ); // whoId => Whom to send email
        if( input.replyTo != null && String.isNotEmpty(input.replyTo) ){
            message.setReplyTo( input.replyTo );
        }
        message.setUseSignature( false ); 
        message.setBccSender( false ); 
        message.setSaveAsActivity( false ); 
        message.setTemplateID( input.emailTemplateId ); 
        message.setWhatId( input.whatId ); // whatId => This is important for the merge fields in template to work
        message.toAddresses = input.additionalEmailAddresses;
        if( input.orgWideAddress != null ){
            message.setOrgWideEmailAddressId( input.orgWideAddress );
        }else{
            message.setSenderDisplayName( input.senderDisplayName ); 
        }
        
        if( input.setTargetAsRecipient != null && !input.setTargetAsRecipient ){
            message.setTreatTargetObjectAsRecipient(false);
        }
        
        return message;
    }
    /******************************************************************************************************
    * @Description        : Function to create Task                            
    * @Params             : NKLWrapperUtil.TaskWrapper input    
    * @Return             : Task                                                                        
    *******************************************************************************************************/
    public static Task createTask( NKLWrapperUtil.TaskWrapper input ){
        Task tsk = new Task();
        tsk.Subject                     = input.subject;
        tsk.OwnerId                     = input.assignedTo;
        tsk.CurrencyIsoCode             = input.currencyIsoCode;
        tsk.Priority                    = input.priority;
        tsk.Status                      = input.status;
        tsk.Description                 = input.description;
        if(input.fieldUpdate != null && input.fieldUpdate != ''){
            tsk.Parent_Flag_API_Name__c = input.fieldUpdate;
        }
        if(input.relatedTo != null && input.relatedTo != ''){
            tsk.whatId = input.relatedTo;
        }
        if(input.dueDate != null){
            tsk.ActivityDate = input.dueDate;
        }               
        return tsk;
    }

    /******************************************************************************************************
    * @Description        : Function to check profile/user permission to bypass trigger                           
    * @Params             : SObjectType  
    * @Return             : Boolean                                                                      
    *******************************************************************************************************/
    public static Boolean isTriggerDisabled(SObjectType sObjectName){
        system.debug('Sobject Type :'+String.valueOf(sObjectName));
        Trigger_Setting__mdt triggerMeta ;
        for( Trigger_Setting__mdt tsm : [Select DeveloperName, is_Active__c, Object_Name__c, is_Disabled__c
                                         from Trigger_Setting__mdt 
                                         where Object_Name__c=:String.valueOf(sObjectName) 
                                         LIMIT 1] ){
            triggerMeta = tsm;
        }
        if( triggerMeta != null ){
            system.debug('triggerMeta :'+triggerMeta);
            Custom_Permission__c  triggerSetting = Custom_Permission__c.getInstance();
            Boolean bypassCheck = triggerSetting.Bypass_Trigger__c;
            system.debug('bypassCheck :'+bypassCheck);
            if(bypassCheck && triggerMeta.is_Disabled__c ){
                return true;
            }else 
                return false;
        }else{
            return false;
        }
        
    }

    public static String formatDate(Date d) {
        return d.year() + '-' + d.month() + '-' + d.day();
    }
    

}