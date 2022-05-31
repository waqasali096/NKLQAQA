@isTest
public class CommonUtilityTest {
    @IsTest
    static void testIsSandbox() {
        CommonUtility.isSandbox();
    }
    @IsTest
    static void testGetRandomString() {
        CommonUtility.getRandomString(10);
    }
    @IsTest
    static void testGetRandomNumber() {
        CommonUtility.getRandomNumber(5);
    }
    @IsTest
    static void testRecordTypeIdByDevName() {
        CommonUtility.recordTypeIdByDevName(Account.sObjectType,'Broker_Account');
    }
    @IsTest
    static void testgetPicklistLabel() {
        CommonUtility.getPicklistLabel(Account.sObjectType,'Bank_Name__c','ABN');
    }
    @IsTest
    static void testIsCaseId() {
        CommonUtility.isCaseId('124');
    }
    @IsTest
    static void testConvert_nn() {
        CommonUtility.convert_nn(2);
    }
    @IsTest
    static void testConvert_nnn() {
        CommonUtility.convert_nnn(2);
    }
    @IsTest
    static void testEnglish_number() {
        CommonUtility.english_number(20000);
    }
    @IsTest
    static void testConvertAmountIntoWords() {
        CommonUtility.convertAmountIntoWords(200);
    }
    @IsTest
    static void testGetMobileNumberWithCountryCode() {
        CommonUtility.getMobileNumberWithCountryCode('1234','098');
    }
    @IsTest
    static void testGetPicklistLabelValues() {
        CommonUtility.getPicklistLabelValues(Account.sObjectType,'Bank_Name__c');
    }
    @IsTest
    static void testGetPicklistLabels() {
        CommonUtility.getPicklistLabels(Account.sObjectType,'Bank_Name__c');
    }
    @IsTest
    static void testGetPicklistValues() {
        CommonUtility.getPicklistValues(Account.sObjectType,'Bank_Name__c');
    }
}