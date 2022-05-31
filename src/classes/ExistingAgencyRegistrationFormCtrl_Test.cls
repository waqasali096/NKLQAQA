@isTest
public class ExistingAgencyRegistrationFormCtrl_Test {
    static TestMethod void TestgetAgencyRecord(){

        List<Broker__c> broList = TestDataFactory.createBrokers(1);
        broList[0].Email_Address__c = 'test@test.com';
        broList[0].Mobile__c = '12345678';
        update broList;

        Test.startTest();
        ExistingAgencyRegistrationFormController.getAgencyRecord( 'test@test.com', '12345678' );
        Test.stopTest(); 
    }
}