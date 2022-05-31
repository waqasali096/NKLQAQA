@isTest
public class Nakheel_BrokerTriggerHandler_Test {
    
    static TestMethod void TestcreateAccountContact(){
        
        map<id, Broker__c> newMap = new map<id, Broker__c>();
        map<id, Broker__c> oldMap = new map<id, Broker__c>();
        List<Broker__c> tempList = TestDataFactory.createBrokers(2);
        List<Broker__c> brokers = TestDataFactory.createBrokers(2);
        List<Broker_Agents__c> brokerAgentsToUpdate = new List<Broker_Agents__c>();
        List<Broker_Agents__c> brokerAgents = TestDataFactory.createBrokerAgentsAuths(brokers);
        for(Broker_Agents__c ba  : brokerAgents){
            ba.Last_Name__c = 'test';
            brokerAgentsToUpdate.add(ba);
        }
        update brokerAgentsToUpdate;
        for(Broker__c br : brokers){
            br.Admin_Approval_Status__c = 'Approved';
            tempList.add(br);
        }
        update tempList;
         
        
        system.debug('>>>>'+brokerAgents);
        //List<Account> accs = TestDataFactory.createAccounts(2);
        List<ContentVersion> cvVersion = TestDataFactory.createcontentVersions(2);
        List<Document__c> docs = TestDataFactory.createDocuments(cvVersion,brokers[0].Id);
        //List<rsdoc__Document_Action__c>  docactionList = TestDataFactory.create_rsdocDocumentAction(1);
        //TestDataFactory.create_rsdocDocumeRequest(1,docactionList,accs);
        
        Test.startTest();
        
        //Nakheel_BrokerTriggerHandler oCEE = new Nakheel_BrokerTriggerHandler(brokers,null,null,null,false,true,false,false);
        //Nakheel_BrokerTriggerHandler var = new Nakheel_BrokerTriggerHandler();
        //Nakheel_BrokerTriggerHandler.createAccountContact(brokers);
        //Nakheel_BrokerTriggerHandler.agreementGeneration(brokers);
        Test.stopTest();
        
    }
    
    
    
    static TestMethod void TestcreatePartnerPortalUser(){

        Counter_Setting__c setting = new Counter_Setting__c();
        setting.Name = 'User_Count';
        setting.Counter__c = 10;
        insert setting;

        List<Account> accounts = TestDataFactory.createAccounts(2);
        List<Contact> contacts = TestDataFactory.createContacts(2,accounts);
        List<Broker__c> brokers = TestDataFactory.createBrokers(2);
        Test.startTest();
        //Nakheel_BrokerTriggerHandler var = new Nakheel_BrokerTriggerHandler(brokers,null,null,null,false,true,false,false);
        Nakheel_BrokerTriggerHandler.createPartnerPortalUser(contacts); 
        
        Test.stopTest();
        
    }
    static TestMEthod void TestaddMembersInGroup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<Broker__c> brokers = TestDataFactory.createBrokers(2);
        List<String> userIdList = new List<String>();
        
        Test.startTest();
        List<User> userList = TestDataFactory.createUsers(10,p.Id);
        for(User u : userList){
            userIdList.add(u.Id);
        }
        Nakheel_BrokerTriggerHandler.addMembersInGroup(userIdList); 
        delete brokers;
        Test.stopTest();
    }

    static TestMethod void roundRobinBrokerAssingment_Test() {
        Profile execProfile = [
            SELECT Id FROM Profile WHERE Name = 'Partner support executive'
        ];

        List<User> execUsers = TestDataFactory.createUsers(5, execProfile.Id);

        Test.startTest();
        List<Broker__c> brokers = TestDataFactory.createBrokers(20);
        Test.stopTest();
    }


}