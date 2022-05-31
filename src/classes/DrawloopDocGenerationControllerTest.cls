/****************************************************************************************************************************
* @Name         DrawloopDocGenerationControllerTest
* @Author       Kaustubh Abhyankar
* @Date         27-April-2022
* @Description  Test Class for DrawloopDocGenerationController
****************************************************************************************************************************/

@isTest
public class DrawloopDocGenerationControllerTest {
    @isTest
    public static void dataSetup() {
        insert new AppSettings__c(Name = 'OrgWideEmailAddressForSR', DateValue__c = system.today(), NumberValue__c = 123, TextValue__c = 'lakshaya@cloudworks.ae');
        
        Test.startTest();
        
        String accBizRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('Business_RecordType').RecordTypeId;//
        String accPerRecType = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('PersonAccount').RecordTypeId;//Broker Account
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.Name = 'TestAccount0';
        acc.Primary_Email__c = 'test0@account.com';
        acc.Account_Number__c = '9999999990';
        acc.RecordTypeId = accBizRecType;
        accList.add(acc);//0
        
        insert accList;
        
        Loop__DDP__c ddp = new Loop__DDP__c();
        insert ddp;
        
        Loop__DDP_Integration_Option__c ddpio = new Loop__DDP_Integration_Option__c();
        ddpio.Loop__DDP__c = ddp.Id;
        insert ddpio;
        
        List<Id> idList = new List<Id>();
        idList.add(accList[0].Id);
        
        String ids = String.join(idList, ',');
        
        PageReference pageRef = Page.GenerateBookingForm; // Add your VF page Name here
        pageRef.getParameters().put('phone', '234567');
        pageRef.getParameters().put('ids', String.valueOf(ids));
        pageRef.getParameters().put('ddpId', String.valueOf(ddp.Id));
        pageRef.getParameters().put('deliveryOptionId', String.valueOf(ddpio.Id));
        pageRef.getParameters().put('sObjectType', String.valueOf('Account'));
        Test.setCurrentPage(pageRef);
        
        DrawloopDocGenerationController ddg = new DrawloopDocGenerationController();
        ddg.ddp = null;
        ddg.deliveryOption = null;
        
        Test.stopTest();
    }
}