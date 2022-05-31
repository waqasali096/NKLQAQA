@isTest
public class Test_CW_AgencyRegistrationFormHelper {
 @TestSetup
    Static  void createData(){
         List<Broker__c> brokers =TestDataFactory.createBrokers(1);
         List<Broker_Proprietor__c> brokerPropertiers =   TestDataFactory.createBrokerProprietors(brokers); 
         List<Broker_Agents__c> brokerAgents =   TestDataFactory.createBrokerAgentsAuths(brokers);
         List<Broker_Agents__c> brokerSignAuths =   TestDataFactory.createBrokerAgentsSignatories(brokers); 
         List<Broker_Agents__c>   AdditionlaContactAgents =   TestDataFactory.createAdditionlaContactAgents(brokers); 
         List<ContentVersion> contentVersions=TestDataFactory.createcontentVersions(2);
         List<AppSettings__c > appSettings = TestDataFactory.createAppSettings();
         TestDataFactory.createDocuments(contentVersions,brokerAgents[0].id); 
    
      
    }
    
    Static TestMethod void getBroker_Coverage(){
        Broker__c broker=   [SELECT id ,Admin_Approval_Status__c from Broker__c LIMIT 1 ];
        Broker_Proprietor__c brokerPropertier =   [SELECT id  from Broker_Proprietor__c LIMIT 1 ];
        String  SignatoryRecordTypeID= CommonUtility.recordTypeIdByDevName(Broker_Agents__c.sObjectType, 'Authorized_Signatory');  
        String RepRecordTYpeID =CommonUtility.recordTypeIdByDevName(Broker_Agents__c.sObjectType, 'Agent_Representative');
            
        Broker_Agents__c  brokerAgent1 =  [SELECT id from Broker_Agents__c WHERE recordTypeID=:RepRecordTYpeID AND Broker_Access_Type__c!=null  LIMIT 1 ];
        Broker_Agents__c  brokerAgent2 =  [SELECT id from Broker_Agents__c WHERE recordTypeId=:SignatoryRecordTypeID LIMIT 1 ];
        Broker_Agents__c  brokerAgent3 =  [SELECT id from Broker_Agents__c WHERE  recordTypeID=:RepRecordTYpeID AND Broker_Access_Type__c=null  LIMIT 1 ];
            
    
        CW_AgencyRegistrationFormHelper.getBrokerDetails(broker.id);
        CW_AgencyRegistrationFormHelper.getbrokerpropDetails(brokerPropertier.id);
        CW_AgencyRegistrationFormHelper.getbrokerAgentAuthDetails(brokerAgent1.id,'Agent_Representative'); 
        CW_AgencyRegistrationFormHelper.getbrokerAdditionalContactDetails(brokerAgent3.id,'Agent_Representative');
        CW_AgencyRegistrationFormHelper.getbrokerAgentAuthDetails(brokerAgent2.id,'Agent_Representative');  
        /*CW_AgencyRegistrationFormHelper.getAgencyLocation();
        CW_AgencyRegistrationFormHelper.getBankName();
        CW_AgencyRegistrationFormHelper.getAgencyCountryCode();
        CW_AgencyRegistrationFormHelper.getAgencyBankAccountCurrency();
        CW_AgencyRegistrationFormHelper.getCountryCode();
        CW_AgencyRegistrationFormHelper.getBrokerAccessType();
        CW_AgencyRegistrationFormHelper.getPlaceOfIncorporation();
        CW_AgencyRegistrationFormHelper.getEmirate();*/
        CW_AgencyRegistrationFormHelper.getAgreementStatus();  
            
        //CW_AgencyRegistrationFormHelper.getBrokerRegistrationDetails(broker.id);
        //broker.Admin_Approval_Status__c ='Approved';
        //update broker;
        

    }
        Static TestMethod void getCreateBrokerAgents_Coverage(){
            Broker__c broker=   [SELECT id,Email_Address__c, Place_of_Incorporation__c, Emirate__c from Broker__c LIMIT 1 ];
            AppSettings__c app =[select TextValue__c from AppSettings__c LIMIT 1 ];
            List<Broker_Proprietor__c> brokerPropertiers =   [SELECT id from Broker_Proprietor__c LIMIT 1 ];
            String  SignatoryRecordTypeID= CommonUtility.recordTypeIdByDevName(Broker_Agents__c.sObjectType, 'Authorized_Signatory');  
            String RepRecordTYpeID =CommonUtility.recordTypeIdByDevName(Broker_Agents__c.sObjectType, 'Agent_Representative');
                
            List<Broker_Agents__c>  brokerAgent1 =  [SELECT id,First_Name__c,Broker_Access_Type__c, RecordType.DeveloperName,RecordTypeId from Broker_Agents__c WHERE recordTypeID=:RepRecordTYpeID AND Broker_Access_Type__c!=null  LIMIT 1 ];
            List<Broker_Agents__c>  brokerAgent2 =  [SELECT id,First_Name__c, Broker_Access_Type__c,RecordType.DeveloperName,RecordTypeId from Broker_Agents__c WHERE recordTypeId=:SignatoryRecordTypeID LIMIT 1 ];
            List<Broker_Agents__c>  brokerAgent3 =  [SELECT id,First_Name__c, Broker_Access_Type__c,RecordType.DeveloperName,RecordTypeId from Broker_Agents__c WHERE  recordTypeID=:RepRecordTYpeID AND Broker_Access_Type__c=null  LIMIT 1 ];
            CW_AgencyRegistrationFormHelper.createAgencyRegistrationRecord(broker);
            
            CW_AgencyRegistrationFormHelper.createBrokerProprietorsRecord(broker.id,brokerPropertiers);
            
            CW_AgencyRegistrationFormHelper.createBrokerAgentsAuthorisedSignatoryRecord(broker.id,brokerAgent2);
            CW_AgencyRegistrationFormHelper.createBrokerAgentsRepresentativeRecord(broker.id,brokerAgent1);
            //CW_AgencyRegistrationFormHelper.createBrokerAgentsAdditionalContactsRecord(broker.id,brokerAgent3);
          //  CW_AgencyRegistrationFormHelper.createBrokerProprietorsAndAgentsRecord(broker.id,brokerPropertiers,brokerAgent2,brokerAgent1,brokerAgent3);
            //CW_AgencyRegistrationFormHelper.createBrokerProprietorsAndAgentsRecord(broker.id,brokerPropertiers,brokerAgent2,brokerAgent1,brokerAgent3, true);

            CW_AgencyRegistrationFormHelper.getDocumentTemplates(brokerAgent3[0].id);
            //CW_AgencyRegistrationFormHelper.sendEmailtoAgency(broker.Id,'Agency_Registration_Acknowledgement_Email');
            //AgencyRegistrationFormController.createBrokerProprietorsAndAgentsRecord(broker.id);

        }
    
    static TestMethod void Test_createAgencyRegistrationRecord(){
        
        List<Broker__c> brokers = TestDataFactory.createBrokers(1);
        List<Broker_Proprietor__c> brokersProprietors = TestDataFactory.createBrokerProprietors(brokers);
        List<ContentVersion> cVersion = TestDataFactory.createcontentVersions(1);
        List<Account> acc = TestDataFactory.createAccounts(1);
        List<Contact> conList = TestDataFactory.createContacts(1,acc);
        List<Opportunity> oppList = TestDataFactory.createOpportunities(1,acc);
        TestDataFactory.createDocuments(cVersion,acc[0].Id);
        List<Broker__c> tempBrokerList = new List<Broker__c>();
        for(Broker__c br : brokers){
            br.Trade_Licence_Number__c = '12345';
            tempBrokerList.add(br);
        }
        update tempBrokerList;
        
        Test.startTest();
        //CW_AgencyRegistrationFormHelper.checkDuplicateEmail('test@gmail.com');
        //CW_AgencyRegistrationFormHelper.fetchRecordTypeValues();
        //CW_AgencyRegistrationFormHelper.createAgencyRegistrationRecord(brokers[0], false);
        CW_AgencyRegistrationFormHelper.getBroker(brokers[0].Id);
        CW_AgencyRegistrationFormHelper.checkDuplicateTradeLicenseNumber('12345');
        CW_AgencyRegistrationFormHelper.getDocumentList(null,acc[0].Id);
        CW_AgencyRegistrationFormHelper.updateAccount(acc[0]);
        //AgencyRegistrationFormHelperCtrl.getDocumentType('Other_Document');
        CW_AgencyRegistrationFormHelper.getDocumentTemplates(acc[0].id);
        CW_AgencyRegistrationFormHelper.getDocumentTemplates(brokers[0].id);
        CW_AgencyRegistrationFormHelper.getDocumentTemplates(brokersProprietors[0].id);
        CW_AgencyRegistrationFormHelper.getDocumentTemplates(oppList[0].id);
        Test.stopTest();
        
    }

    // static TestMethod void Test_getDocumentList(){
        
    //     List<Broker__c> brokers = TestDataFactory.createBrokers(1);
    //     List<Broker_Proprietor__c> brokersProprietors = TestDataFactory.createBrokerProprietors(brokers);
    //     List<ContentVersion> cVersion = TestDataFactory.createcontentVersions(1);
    //     List<Account> acc = TestDataFactory.createAccounts(1);
    //     List<Opportunity> oppList = TestDataFactory.createOpportunities(1,acc);
    //     TestDataFactory.createDocuments(cVersion,acc[0].Id);
    //     List<Broker__c> tempBrokerList = new List<Broker__c>();
    //     for(Broker__c br : brokers){
    //         br.Trade_Licence_Number__c = '12345';
    //         tempBrokerList.add(br);
    //     }
    //     update tempBrokerList;
        
    //     Test.startTest();
    //     AgencyRegistrationFormHelperCtrl.getDocumentList( acc[0].Id ,acc[0].Id);
        
    //     Test.stopTest();
        
    // }

    // static TestMethod void Test_fetchAttachments(){
        
    //     List<Broker__c> brokers = TestDataFactory.createBrokers(1);
    //     List<Broker_Proprietor__c> brokersProprietors = TestDataFactory.createBrokerProprietors(brokers);
    //     List<ContentVersion> cVersion = TestDataFactory.createcontentVersions(1);
    //     List<Account> acc = TestDataFactory.createAccounts(1);

    //     Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Broker_Account').getRecordTypeId();
    //     acc[0].RecordTypeId = recordTypeId;
    //     update acc;

    //     List<Opportunity> oppList = TestDataFactory.createOpportunities(1,acc);
    //     TestDataFactory.createDocuments(cVersion,acc[0].Id);
    //     List<Broker__c> tempBrokerList = new List<Broker__c>();
    //     for(Broker__c br : brokers){
    //         br.Trade_Licence_Number__c = '12345';
    //         tempBrokerList.add(br);
    //     }
    //     update tempBrokerList;

    //     List<ContentVersion> cVersion1 = TestDataFactory.createcontentVersions(1);
    //     List<Document__c> documents = TestDataFactory.createDocuments(cVersion,acc[0].Id);
        
    //     Test.startTest();
    //     AgencyRegistrationFormHelperCtrl.fetchAttachments( acc[0].Id ,documents[0].Id);
        
    //     Test.stopTest();
        
    // }
    

}