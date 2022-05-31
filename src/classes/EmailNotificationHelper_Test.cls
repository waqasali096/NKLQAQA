@isTest
public class EmailNotificationHelper_Test {
    static TestMethod void TestGetOrgWideEmailAddress(){

        List< OrgWideEmailAddress > owAddresses = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1];
        List< EmailTemplate > templates = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate ];

        Test.startTest();
        string address; //= owAddresses != null ?  owAddresses[0].Address : 'test String';
        if( owAddresses != null && owAddresses.size() > 0 ){
            address = owAddresses[0].Address;
        }else{
            address = 'test String';
        }
        EmailNotificationHelper.getOrgWideEmailAddress( address );
        Test.stopTest();
    }

    static TestMethod void TestGetEmailTemplateByName(){

        Set< String > setTemplateNames = new Set< String >{ 'test_template_Name' };

        Test.startTest();
        EmailNotificationHelper.getEmailTemplateByName( setTemplateNames );
        Test.stopTest();
    }

    // static TestMethod void TestbuildEmailRequest(){

    //     List<Account> accounts =TestDataFactory.createAccounts( 1 );
    //     List<Contact> Contacts =  TestDataFactory.createContacts( 1, accounts );

    //     List< OrgWideEmailAddress > owAddresses = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1];
    //     List< EmailTemplate > templates = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate ];

    //     List< String > setEmailList = new List< String >{ 'Test@test.com' };

    //     string address = owAddresses != null ?  owAddresses[0].Address : 'test String';
    //     string templateId = owAddresses != null ?  templates[0].Id : null ;

    //     Test.startTest();
    //     EmailNotificationHelper.buildEmailRequest( setEmailList, templateId, Contacts[0].Id, address );
    //     Test.stopTest();
    // }

    static TestMethod void TestbuildEmailRequest1(){

        List<Account> accounts =TestDataFactory.createAccounts( 1 );
        List<Contact> Contacts =  TestDataFactory.createContacts( 1, accounts ); 

        List< OrgWideEmailAddress > owAddresses = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1];
        List< EmailTemplate > templates = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate ];

        List< String > setEmailList = new List< String >{ 'Test@test.com' };

        Test.startTest();
        EmailNotificationHelper.buildEmailRequest( setEmailList, templates[0].Id, Contacts[0].Id, null );
        Test.stopTest();
    }

    static TestMethod void TestSendEmail(){

        List<Account> accounts =TestDataFactory.createAccounts( 1 );
        List<Contact> Contacts =  TestDataFactory.createContacts( 1, accounts );

        List< OrgWideEmailAddress > owAddresses = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1];
        List< EmailTemplate > templates = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate ];

        Set< String > setEmailList = new Set< String >{ 'Test@test.com' };

        List<  Messaging.SingleEmailMessage > emailList = new List<  Messaging.SingleEmailMessage >();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(new String[] {'test@test.com' });
        message.setTemplateId(templates[0].Id);
        message.setSaveAsActivity(true);
        message.setWhatId(accounts[0].Id);
        message.setTargetObjectId( Contacts[0].Id );
        emailList.add( message );

        Test.startTest();
        EmailNotificationHelper.sendEmail( emailList );
        Test.stopTest();
    }
    
}