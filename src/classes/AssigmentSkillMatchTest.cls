@isTest
public class AssigmentSkillMatchTest {

    @isTest static void matchRecordtoSkillTest(){

    Engine_Instance__c EngineInstance = new Engine_Instance__c();
        EngineInstance.Closing_Criteria_Field_Value__c='New';
        EngineInstance.Closing_Criteria_Field__c='Status';
        EngineInstance.SObject__c='Lead';
        EngineInstance.MATCHING_RULE__c =3;
        EngineInstance.Assignment_Field_API__c = 'Assigned_Resource__c';
        EngineInstance.Enable_Logging__c=true;
        EngineInstance.Error_Log__c='test';
        //insert EngineInstance;
        
        Lead NewLead = new Lead();
        NewLead.LastName = 'TestLead';
        NewLead.Company = 'TEST';
       // NewLead.Matching_Rule__c = '3';
        NewLead.Industry='Agriculture';
        NewLead.LeadSource='Web';
        NewLead.email = 'huzefa@cloudworks.ae';
        insert NewLead;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(
                username = 'testkk@tst.com.emaar.cloudworks',
                Email = 'test@test.com',
                FirstName = 'test',
                LastName = 'tets',
                Alias = 'test',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles');
        insert u; 
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        insert EngineInstance;
        Assignment_Resource__c ar1 = new Assignment_Resource__c();
        ar1.User__c = u.id;
        ar1.Engine_Instance__c = EngineInstance.id;
        ar1.Workload__c=0;
        ar1.Skill_Mapping__c='{"Industry" : "Agriculture","LeadSource" : "Web"}';
        insert ar1;
        
        
        Assignment_Resource__c ar2 = new Assignment_Resource__c();
        ar2.User__c = u.id;
        ar2.Engine_Instance__c = EngineInstance.id;
        ar2.Workload__c=0;
        ar2.Skill_Mapping__c='{"Industry" : "Agriculture","LeadSource" : "Web"}';
        insert ar2;
        
        List<Lead> NewLeadList = new list<lead>();
        NewLeadList.add(NewLead);

        
       
        
        AssignmentEngineInstance engineInstance1 = new AssignmentEngineInstance(EngineInstance.id);
        database.executebatch(engineInstance1);
        NewLead.Assigned_Resource__c = null;
        update NewLead;        
        AssigmentSkillMatch.matchRecordtoSkill(NewLeadList, EngineInstance);
        
        EngineInstance.MATCHING_RULE__c =1;
        update EngineInstance;
        //NewLead.Matching_Rule__c = '2';
        NewLead.Assigned_Resource__c = null;
        update NewLead;
        AssigmentSkillMatch.matchRecordtoSkill(NewLeadList, EngineInstance);

        
        Test.stopTest();
        
    }

    @isTest static void EITest2(){

    Engine_Instance__c EngineInstance = new Engine_Instance__c();
        EngineInstance.Closing_Criteria_Field_Value__c='New';
        EngineInstance.Closing_Criteria_Field__c='Status';
        EngineInstance.SObject__c='Lead';
        EngineInstance.MATCHING_RULE__c =3;
        EngineInstance.Assignment_Field_API__c = 'Assigned_Resource__c';
        EngineInstance.Enable_Logging__c=true;
        EngineInstance.Error_Log__c='test';
        EngineInstance.Capacity_Treshold__c = 1000;
        //insert EngineInstance;
        
        Lead NewLead = new Lead();
        NewLead.LastName = 'TestLead';
        NewLead.Company = 'TEST';
        //NewLead.Matching_Rule__c = '3';
        NewLead.Industry='Agriculture';
        NewLead.LeadSource='Web';
        NewLead.email = 'huzefa@cloudworks.ae';
        insert NewLead;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(
                username = 'testkk@tst.com.emaar.cloudworks',
                Email = 'test@test.com',
                FirstName = 'test',
                LastName = 'tets',
                Alias = 'test',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles');
        insert u; 
         
         Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        insert EngineInstance;
        Assignment_Resource__c ar1 = new Assignment_Resource__c();
        ar1.User__c = u.id;
        ar1.Engine_Instance__c = EngineInstance.id;
        ar1.Workload__c=0;
        ar1.Skill_Mapping__c='{"Industry" : "Agriculture","LeadSource" : "Web"}';
        insert ar1;
        
        
        Assignment_Resource__c ar2 = new Assignment_Resource__c();
        ar2.User__c = u.id;
        ar2.Engine_Instance__c = EngineInstance.id;
        ar2.Workload__c=0;
        ar2.Skill_Mapping__c='{"Industry" : "Agriculture","LeadSource" : "Web"}';
        insert ar2;
        
        List<Lead> NewLeadList = new list<lead>();
        NewLeadList.add(NewLead);

        
       
        
        AssignmentEngineInstance engineInstance1 = new AssignmentEngineInstance(EngineInstance.id);
        database.executebatch(engineInstance1);
        NewLead.Assigned_Resource__c = null;
        update NewLead;        
        AssigmentSkillMatch.matchRecordtoSkill(NewLeadList, EngineInstance);
        
        EngineInstance.MATCHING_RULE__c =1;
        update EngineInstance;
        //NewLead.Matching_Rule__c = '2';
        NewLead.Assigned_Resource__c = null;
        update NewLead;
        AssigmentSkillMatch.matchRecordtoSkill(NewLeadList, EngineInstance);
        Test.startTest();
        EngineInstance.Active__c = true;
        update EngineInstance;

        EngineInstance.Active__c = false;
        update EngineInstance;

        EngineInstance.Run_Once__c =true;



        
        Test.stopTest();
        
    }
}