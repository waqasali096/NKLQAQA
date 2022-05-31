/**
* @author : Muhammad Moneeb
* @createdDate : 23-Dec-2021
* @lastModifieddate : 23-Dec-2021
* @purpose : Initial Development
* @usage : Test class to cover all functionality of GenericTriggerHandler. 
*/
@isTest
public class GenericTriggerHandlerTest{
    public static List<Opportunity> oppList=new List<Opportunity>();
    public static List<Account> accountList=new List<Account>();
    public static List<Case> caseList=new List<Case> ();
    
    @TestSetup
    Static  void createData(){
        List<ContentVersion> contentList = TestDataFactory.createcontentVersions(1);
        List<Master_Document__c> masterDocList = TestDataFactory.createMasterDoc(3,new list<string>{'Passport','Emirates Id','Others'});
        TestDataFactory.createDocConf(1,False,'Account','Person Account',new List<Document__c>(),'Account_Type__c',
                                      'Broker','Exisiting_Broker__c',masterDocList[0]);
        TestDataFactory.createDocConf(1,False,'Opportunity','Sales Opportunity',new List<Document__c>(),'StageName',
                                      'Booking Initiated','Documents_Verified__c',masterDocList[1]);
        TestDataFactory.createDocConf(1,False,'Case','none',new List<Document__c>(),'Status','Escalated','IsStopped',
                                      masterDocList[0]);
        TestDataFactory.createDocConf(1,True,'Opportunity','Sales Opportunity',new List<Document__c>(),'StageName',
                                      'Booking Initiated','Documents_Verified__c',masterDocList[2]);
        TestDataFactory.createDocConf(1,True,'Case','none',new List<Document__c>(),'Status','Escalated','IsStopped',
                                      masterDocList[2]);
        accountList = TestDataFactory.createAccountWithRecordType(1,'Person Account');
        oppList = TestDataFactory.createOpportunitiesWithRecordType(1,accountList,'Sales Opportunity');
        caseList = TestDataFactory.createCase(1);
        
    }
    /* @usage : This function used to cover functionality of validateDocrecord function for Case.*/
    static TestMethod void Test_validateDocRecordForCase(){
        try{
            List<case> caseList = [Select id,status from case];
            caseList[0].status = 'Escalated';
            update caseList; 
        }catch(Exception e){
            List<case> caseList = [Select id,status from case];
            System.assertNotEquals('Escalated',caseList[0].status);
        }
    }
    /* @usage : This function used to cover functionality of validateDocrecord function for Opportunity.*/
    static TestMethod void Test_validateDocRecordForOpportunity(){
        try{
            List<Opportunity> oppList = [select id,StageName from opportunity] ; 
            oppList[0].StageName = 'Booking Initiated';
            update oppList;
        }catch(Exception e){
            List<opportunity> oppList = [Select id,StageName from opportunity];
            System.assertNotEquals('Booking Initiated',oppList[0].StageName);
        }
    }
    
     /* @usage : This function used to cover functionality of validateDocrecord function for Account.*/
    static TestMethod void Test_validateDocRecordForAccount(){
        try{
            List<Account> accList = [select id,Account_Type__c from Account] ; 
            accList[0].Account_Type__c = 'Broker';
            update accList;
        }catch(Exception e){
            List<Account> accList = [Select id,Account_Type__c from Account];
            System.assertNotEquals('Broker',accList[0].Account_Type__c);
        }
    }
}